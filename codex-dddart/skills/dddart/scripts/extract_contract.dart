#!/usr/bin/env dart
/// extract_contract — G1 승인 직후 server-contract.json 기계 절단 (설계 §7).
///
/// 명세가 인용한 엔드포인트 paths를 동결본(openapi-full.json)에서 정확 일치로
/// 선별하고 `$ref` 전이 폐쇄까지 추적해 경량본을 만든다. '관련' 판단이 명세 인용으로
/// 치환돼 LLM 재량이 소멸하고, 손절단의 dangling `$ref`를 막는다(본설계 §5-7).
///
/// 사용:
///   dart run extract_contract.dart <openapi-full.json> --paths <paths-file> --out <server-contract.json>
///
/// paths-file: 한 줄에 `GET /api/v1/members/{id}` (메서드 생략 시 그 path 전 메서드).
/// 종료코드: 0=성공 / 1=인용 누락·파싱 실패(blocker 의미론 없음 — 게이트 도구가 아니다).
/// 인용 누락은 그 자체가 발견이다 — 존재하지 않는 엔드포인트 인용 = architect 임의 가정.
library;

import 'dart:convert';
import 'dart:io';

const _httpMethods = {'get', 'put', 'post', 'delete', 'options', 'head', 'patch', 'trace'};

void main(List<String> argv) {
  String? input;
  String? pathsFile;
  String? outFile;
  for (var i = 0; i < argv.length; i++) {
    switch (argv[i]) {
      case '--paths':
        pathsFile = argv[++i];
      case '--out':
        outFile = argv[++i];
      default:
        input = argv[i];
    }
  }
  if (input == null || pathsFile == null || outFile == null) {
    stderr.writeln('사용: dart run extract_contract.dart <openapi-full.json> --paths <paths-file> --out <server-contract.json>');
    exit(1);
  }

  final Map<String, dynamic> doc;
  try {
    doc = jsonDecode(File(input).readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    stderr.writeln('[extract-contract] 파싱 실패: $e — OpenAPI 3.x JSON 전제(YAML·Swagger 2.0은 범위 밖, 설계 §7)');
    exit(1);
  }
  if (doc.containsKey('swagger')) {
    stderr.writeln('[extract-contract] Swagger 2.0 문서 — OpenAPI 3.x만 지원. 서버에 3.x 엔드포인트를 확인하라.');
    exit(1);
  }
  final paths = doc['paths'] as Map<String, dynamic>? ?? {};

  // 인용 목록 파싱
  final cited = <String, Set<String>>{}; // path → 메서드(빈 집합 = 전 메서드)
  for (final raw in File(pathsFile).readAsLinesSync()) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length >= 2 && _httpMethods.contains(parts[0].toLowerCase())) {
      cited.putIfAbsent(parts[1], () => {}).add(parts[0].toLowerCase());
    } else {
      cited[parts.last] = cited[parts.last] ?? {}; // 전 메서드
    }
  }
  if (cited.isEmpty) {
    stderr.writeln('[extract-contract] 인용 path 0개 — paths-file이 비었다.');
    exit(1);
  }

  // 정확 일치 검증 + 근사 후보 병기(§7 — trailing slash·파라미터명 차이의 오귀책 방지)
  final missing = <String>[];
  for (final p in cited.keys) {
    if (!paths.containsKey(p)) missing.add(p);
  }
  if (missing.isNotEmpty) {
    stderr.writeln('[extract-contract] 인용 path가 동결본에 없음 — 명세의 임의 가정 여부를 확인하라(본설계 §5-1):');
    for (final p in missing) {
      final near = _nearMatches(p, paths.keys);
      stderr.writeln('  - $p${near.isEmpty ? '' : '  (유사 path 존재: ${near.join(', ')})'}');
    }
    exit(1);
  }

  // path item 통째 복사 후 비인용 메서드 키만 제거(§7-1 — 공유 parameters·servers 보존)
  final outPaths = <String, dynamic>{};
  for (final e in cited.entries) {
    final item = _deepCopy(paths[e.key]);
    if (e.value.isNotEmpty && item is Map<String, dynamic>) {
      item.removeWhere((k, _) => _httpMethods.contains(k) && !e.value.contains(k));
    }
    outPaths[e.key] = item;
  }

  // $ref 전이 폐쇄 (visited 집합 — 순환 스키마 대비, discriminator.mapping 값 포함)
  final components = doc['components'] as Map<String, dynamic>? ?? {};
  final keptComponents = <String, Map<String, dynamic>>{};
  final visited = <String>{};
  final warnings = <String>[];
  final queue = <String>[];

  void collectRefs(dynamic node) {
    if (node is Map) {
      node.forEach((k, v) {
        if (k == r'$ref' && v is String) {
          queue.add(v);
        } else if (k == 'discriminator' && v is Map && v['mapping'] is Map) {
          (v['mapping'] as Map).values.whereType<String>().forEach(queue.add);
          collectRefs(v);
        } else {
          collectRefs(v);
        }
      });
    } else if (node is List) {
      node.forEach(collectRefs);
    }
  }

  collectRefs(outPaths);
  while (queue.isNotEmpty) {
    final ref = queue.removeLast();
    if (!visited.add(ref)) continue;
    if (ref.startsWith('#/components/')) {
      final segs = ref.substring('#/components/'.length).split('/');
      if (segs.length < 2) {
        warnings.add('해석 불가 components ref: $ref');
        continue;
      }
      final section = segs[0];
      final name = _unescape(segs[1]);
      final src = (components[section] as Map<String, dynamic>?)?[name];
      if (src == null) {
        warnings.add('dangling ref: $ref — 동결본 자체가 비자기완결');
        continue;
      }
      final copy = _deepCopy(src);
      keptComponents.putIfAbsent(section, () => {})[name] = copy as Map<String, dynamic>;
      collectRefs(copy);
    } else if (ref.startsWith('#/paths/')) {
      // operation 재사용 관례 — 경고 + 해당 path item 동반 복사(§7-3, dangling 침묵 금지)
      final pathKey = _unescape(ref.substring('#/paths/'.length).split('/').first);
      if (paths.containsKey(pathKey) && !outPaths.containsKey(pathKey)) {
        final copy = _deepCopy(paths[pathKey]);
        outPaths[pathKey] = copy;
        collectRefs(copy);
      }
      warnings.add('#/paths/ 로컬 ref 동반 복사: $ref');
    } else if (ref.startsWith('#/')) {
      warnings.add('components 외 로컬 ref(원문 보존): $ref');
    } else {
      warnings.add('비로컬 ref(원문 보존 — 동결본 비자기완결 신호): $ref');
    }
  }

  // 보존 목록(§7-4): openapi·info·servers·루트 security·securitySchemes 전체
  final out = <String, dynamic>{
    if (doc['openapi'] != null) 'openapi': doc['openapi'],
    if (doc['info'] != null) 'info': doc['info'],
    if (doc['servers'] != null) 'servers': doc['servers'],
    if (doc['security'] != null) 'security': doc['security'],
    'paths': outPaths,
  };
  final secSchemes = components['securitySchemes'];
  if (keptComponents.isNotEmpty || secSchemes != null) {
    out['components'] = {
      ...keptComponents,
      if (secSchemes != null) 'securitySchemes': _deepCopy(secSchemes),
    };
  }
  if (doc.containsKey('webhooks')) warnings.add('webhooks 비복사(무음 드롭 금지 — 필요하면 수동 확인)');
  if (components.containsKey('pathItems')) warnings.add('components.pathItems는 ref로 닿은 것만 복사');

  File(outFile).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  for (final w in warnings) {
    stdout.writeln('[warn] $w');
  }
  final compCount = keptComponents.values.fold<int>(0, (n, m) => n + m.length);
  stdout.writeln('[extract-contract] paths ${outPaths.length}개 · components $compCount개 → $outFile');
  exit(0);
}

dynamic _deepCopy(dynamic v) => jsonDecode(jsonEncode(v));

String _unescape(String s) => s.replaceAll('~1', '/').replaceAll('~0', '~');

/// 근사 후보: 대소문자·trailing slash·경로 파라미터명 차이를 무시한 일치.
List<String> _nearMatches(String want, Iterable<String> have) {
  String norm(String p) => p
      .toLowerCase()
      .replaceAll(RegExp(r'\{[^}]*\}'), '{}')
      .replaceAll(RegExp(r'/+$'), '');
  final w = norm(want);
  return have.where((h) => norm(h) == w).take(3).toList();
}
