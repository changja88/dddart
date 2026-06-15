/// PJ — pubspec 토대 어설션 2종 (feedback-006 Fix 2a). 게이트: 입력 불변식(시나리오 무관·항상).
///
/// *왜 결정적 백스톱인가*: @riverpod 코드젠 토대(flutter_riverpod 메이저 3+·generator 동반)는
/// 어느 입력에도 불변인 사실이며, 그 부재는 "수동 Notifier로 통째 우회"(ST-5)의 토대다.
/// NM7/NM8이 @riverpod *존재* 시 위치만 보는 사각(누락된 @riverpod 비가시)을 토대에서 닫는다.
/// 골든(정렬 등 시나리오 행위) 무관 → blind grader 제약 안전.
/// 거짓양성 가드: flutter_riverpod이 dependencies에 *선언된 경우에 한해* 발화(미사용 정상본 면책).
library;

import 'dart:io';

import 'common.dart';

const _rulePj = '토대 규약 — @riverpod 코드젠(flutter_riverpod ≥3 · annotation/generator/build_runner 동반)';

List<Finding> runPubspec(BackstopContext ctx) {
  final out = <Finding>[];
  final pubspec = File('${ctx.root.path}/pubspec.yaml');
  if (!pubspec.existsSync()) return out; // build()가 이미 보장하나 방어

  final deps = _depMajors(pubspec.readAsStringSync());

  // 거짓양성 가드 — riverpod 미선언 정상본(순수 도메인 등)은 면책.
  if (!deps.containsKey('flutter_riverpod')) return out;

  // ---- PJ1: flutter_riverpod 메이저 하한 3
  final major = deps['flutter_riverpod'];
  if (major != null && major < 3) {
    out.add(Finding('PJ1', 'pubspec.yaml', null,
        'flutter_riverpod 메이저 $major (<3) — riverpod 2.x는 @riverpod 코드젠·AsyncNotifier retry 토대가 없어 수동 provider로 침몰(ST-5·ST-8)',
        _rulePj,
        'flutter_riverpod을 ^3.x로 올린다 — `flutter pub add flutter_riverpod`(무핀)로 호환 최신 resolve 후 핀.',
        rootRel: true));
  }

  // ---- PJ2: 코드젠 도구 동반(annotation·generator·build_runner)
  const required = {'riverpod_annotation', 'riverpod_generator', 'build_runner'};
  final missing = required.where((p) => !deps.containsKey(p)).toList()..sort();
  if (missing.isNotEmpty) {
    out.add(Finding('PJ2', 'pubspec.yaml', null,
        '@riverpod 코드젠 토대 부재 — 누락: ${missing.join(', ')} (이 토대 없이는 @riverpod 클래스형이 불가해 수동 Notifier로 우회된다)',
        _rulePj,
        '`flutter pub add riverpod_annotation` + `flutter pub add dev:riverpod_generator dev:build_runner`(무핀)로 도입한다.',
        rootRel: true));
  }

  return out;
}

/// dependencies + dev_dependencies + dependency_overrides의 *직속*(2-space) 패키지 →
/// 메이저 버전(파싱 불가는 null). 백스톱은 외부 의존 0이라 YAML을 정규식으로 경량 파싱한다.
Map<String, int?> _depMajors(String text) {
  final out = <String, int?>{};
  var inSection = false;
  for (final raw in text.split('\n')) {
    final line = raw.replaceAll('\t', '  ');
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    // 섹션 헤더(좌측 정렬·콜론 종료)
    if (RegExp(r'^(dependencies|dev_dependencies|dependency_overrides):\s*$').hasMatch(line)) {
      inSection = true;
      continue;
    }
    // 다른 최상위 키 → 섹션 이탈
    if (RegExp(r'^\S').hasMatch(line)) {
      inSection = false;
      continue;
    }
    if (!inSection) continue;
    // 직속 패키지 = 정확히 2-space 들여쓰기 + 이름 + 콜론(중첩 sdk:/git: 등은 더 깊어 비매치)
    final m = RegExp(r'^  ([a-z0-9_]+):(.*)$').firstMatch(line);
    if (m == null) continue;
    out[m.group(1)!] = _majorOf(m.group(2)!.trim());
  }
  return out;
}

/// 버전 제약에서 메이저 추출 — 캐럿(^2.6.1→2)·범위(>=3.0.0 <4.0.0→3·관용 순서 가정)·고정(2.6.1→2).
/// any·빈값(sdk/git/path)은 null(하한 미상 → PJ1 비교 통과, PJ2 존재 검사엔 영향 없음).
int? _majorOf(String spec) {
  final s = spec.replaceAll(RegExp('["\']'), '').trim();
  if (s.isEmpty || s == 'any') return null;
  final m = RegExp(r'\d+').firstMatch(s);
  return m == null ? null : int.tryParse(m.group(0)!);
}
