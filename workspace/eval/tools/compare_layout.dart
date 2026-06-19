#!/usr/bin/env dart
/// compare_layout — 시안 layout-ir vs 코드 layout-ir 대조 → FID-L1·L2·L3 리포트.
///
/// 평가측 단일출처(workspace/eval/tools/·eval). 시안 파서(extract_layout.dart)와
/// 코드 렌더 덤프(dump_layout — step 2b)가 산출한 같은 스키마 두 layout-ir을 받아
/// 구조 충실도를 대조한다. 스키마(동결본): workspace/eval/tools/layout-ir-schema.md
///   L1(골격): areas role 시퀀스(존재·종류·순서).
///   L2(섹션 구성): section children 평탄화 시퀀스(block 펼침·repeat-group 경계 보존·group 펼침·§3).
///   L3(말단 슬롯): slot type·width·align(약신호 ⚠·게이트 아님).
///
/// 사용: dart run compare_layout.dart --ref <시안.json> --got <코드.json> [--screen <name>] [--gate]
/// 종료: --gate 시 L1 또는 L2 불일치=2(게이트 활성·RUBRIC §H 조건 충족 후만 사용) / 그 외 0.
///   **--gate 없으면 항상 0**(리포트·약신호만·게이트 비활성 — 도구·positive-control 미충족 시 기본).
library;

import 'dart:convert';
import 'dart:io';

void main(List<String> argv) {
  String? refF;
  String? gotF;
  String? only;
  var gate = false;
  for (var i = 0; i < argv.length; i++) {
    switch (argv[i]) {
      case '--ref':
        refF = argv[++i];
      case '--got':
        gotF = argv[++i];
      case '--screen':
        only = argv[++i];
      case '--gate':
        gate = true;
    }
  }
  if (refF == null || gotF == null) {
    stderr.writeln('사용: dart run compare_layout.dart --ref <시안.json> --got <코드.json> [--screen <name>] [--gate]');
    exit(1);
  }
  final refScreens = _load(refF);
  final gotScreens = _load(gotF);
  final gotByName = <String, Map<String, dynamic>>{for (final s in gotScreens) s['screen'] as String: s};

  var l1l2Fail = false;
  final names = refScreens.map((Map<String, dynamic> s) => s['screen'] as String).toList()..sort();
  for (final name in names) {
    if (only != null && name != only) continue;
    final r = refScreens.firstWhere((Map<String, dynamic> s) => s['screen'] == name);
    final g = gotByName[name];
    stdout.writeln('[화면 $name]');
    if (g == null) {
      stdout.writeln('  L1 ❌ 코드에 화면 없음(시안에만 존재)');
      l1l2Fail = true;
      continue;
    }

    // ---- L1: 영역 골격 ----
    final refRoles = _areas(r).map((Map<String, dynamic> a) => a['role'] as String).toList();
    final gotRoles = _areas(g).map((Map<String, dynamic> a) => a['role'] as String).toList();
    final l1 = _seqDiff(refRoles, gotRoles);
    if (l1.equal) {
      stdout.writeln('  L1 영역 ✓ [${refRoles.join(', ')}]');
    } else {
      l1l2Fail = true;
      stdout.writeln('  L1 영역 ❌ 시안=[${refRoles.join(', ')}] 코드=[${gotRoles.join(', ')}]'
          '${l1.missing.isEmpty ? '' : ' · 누락=${l1.missing}'}${l1.extra.isEmpty ? '' : ' · 추가=${l1.extra}'}'
          '${l1.missing.isEmpty && l1.extra.isEmpty ? ' · 순서변경' : ''}');
    }

    // ---- L2: 섹션 구성(평탄화) ----
    final refSecs = _areas(r).where((Map<String, dynamic> a) => a['role'] == 'section').toList();
    final gotSecs = _areas(g).where((Map<String, dynamic> a) => a['role'] == 'section').toList();
    if (refSecs.length != gotSecs.length) {
      l1l2Fail = true;
      stdout.writeln('  L2 섹션 수 ❌ 시안 ${refSecs.length} ≠ 코드 ${gotSecs.length}');
    }
    final secN = refSecs.length < gotSecs.length ? refSecs.length : gotSecs.length;
    for (var i = 0; i < secN; i++) {
      final rf = _flattenSection(refSecs[i]);
      final gf = _flattenSection(gotSecs[i]);
      final d = _seqDiff(rf, gf);
      if (d.equal) {
        stdout.writeln('  L2 섹션#${i + 1} ✓ [${rf.join(', ')}]');
      } else {
        l1l2Fail = true;
        stdout.writeln('  L2 섹션#${i + 1} ❌ 시안=[${rf.join(', ')}] 코드=[${gf.join(', ')}]'
            '${d.missing.isEmpty ? '' : ' · 누락=${d.missing}'}${d.extra.isEmpty ? '' : ' · 추가=${d.extra}'}'
            '${d.missing.isEmpty && d.extra.isEmpty ? ' · 순서변경' : ''}');
      }
    }

    // ---- L3: 말단 슬롯(약신호·게이트 아님) ----
    for (var i = 0; i < secN; i++) {
      final rd = _slotDetail(refSecs[i]);
      final gd = _slotDetail(gotSecs[i]);
      if (rd.join('|') != gd.join('|')) {
        stdout.writeln('  L3 섹션#${i + 1} ⚠ 슬롯 배치 차이(약신호·사용자 눈) 시안=$rd 코드=$gd');
      }
    }
  }

  if (gate && l1l2Fail) {
    stdout.writeln('[compare-layout] FID-L1/L2 불일치 — 게이트 FAIL (--gate)');
    exit(2);
  }
  stdout.writeln('[compare-layout] 완료${gate ? ' · 게이트 PASS' : ' · 리포트(게이트 비활성)'}');
  exit(0);
}

List<Map<String, dynamic>> _load(String path) {
  final doc = jsonDecode(File(path).readAsStringSync());
  final screens = doc is Map ? doc['screens'] : doc;
  return (screens as List).cast<Map<String, dynamic>>();
}

List<Map<String, dynamic>> _areas(Map<String, dynamic> screen) =>
    (screen['areas'] as List).cast<Map<String, dynamic>>();

/// L2 평탄화(§3): block.slots 펼침 · repeat-group은 경계 보존(단일 `repeat{…}` 토큰) · group 슬롯 펼침.
List<String> _flattenSection(Map<String, dynamic> section) {
  final out = <String>[];
  for (final b in (section['children'] as List? ?? const <dynamic>[]).cast<Map<String, dynamic>>()) {
    if (b['kind'] == 'repeat-group') {
      final unit = (b['unit'] as Map<String, dynamic>?)?['slots'] as List? ?? const <dynamic>[];
      out.add('repeat{${_flattenSlots(unit.cast<Map<String, dynamic>>()).join(',')}}');
    } else {
      out.addAll(_flattenSlots((b['slots'] as List? ?? const <dynamic>[]).cast<Map<String, dynamic>>()));
    }
  }
  return _collapse(out);
}

/// 연속 동종 slot 축약(measure-first 보정·step 2b hero) — 시안 div 흡수(여러 text가 한 컨테이너) vs
/// 코드 위젯 분리(`Text`×2)의 비대칭 해소. 인접 같은 type(text,text→text)을 1로 본다. 진짜 차이
/// (누락·순서·종류·repeat 경계 토큰)는 토큰 자체가 달라 그대로 검출된다. 양쪽 대칭 적용.
List<String> _collapse(List<String> seq) {
  final out = <String>[];
  for (final x in seq) {
    if (out.isEmpty || out.last != x) out.add(x);
  }
  return out;
}

List<String> _flattenSlots(List<Map<String, dynamic>> slots) {
  final out = <String>[];
  for (final s in slots) {
    if (s['type'] == 'group') {
      out.addAll(_flattenSlots((s['slots'] as List? ?? const <dynamic>[]).cast<Map<String, dynamic>>()));
    } else {
      out.add(s['type'] as String);
    }
  }
  return _collapse(out);
}

/// L3 약신호: 섹션의 슬롯 type+width+align 상세(반복 unit·block 공통).
List<String> _slotDetail(Map<String, dynamic> section) {
  final out = <String>[];
  for (final b in (section['children'] as List? ?? const <dynamic>[]).cast<Map<String, dynamic>>()) {
    final slots = b['kind'] == 'repeat-group'
        ? ((b['unit'] as Map<String, dynamic>?)?['slots'] as List? ?? const <dynamic>[])
        : (b['slots'] as List? ?? const <dynamic>[]);
    for (final s in slots.cast<Map<String, dynamic>>()) {
      out.add('${s['type']}(${s['width'] ?? '-'},${s['align'] ?? '-'})');
    }
  }
  return out;
}

class _Diff {
  _Diff(this.equal, this.missing, this.extra);
  final bool equal;
  final List<String> missing; // 시안엔 있고 코드엔 없음
  final List<String> extra; // 코드에만
}

/// 순서보존 시퀀스 대조 — 정확 일치 여부 + 멀티셋 누락/추가.
_Diff _seqDiff(List<String> ref, List<String> got) {
  if (ref.length == got.length) {
    var same = true;
    for (var i = 0; i < ref.length; i++) {
      if (ref[i] != got[i]) {
        same = false;
        break;
      }
    }
    if (same) return _Diff(true, const <String>[], const <String>[]);
  }
  final gotPool = <String, int>{};
  for (final x in got) {
    gotPool[x] = (gotPool[x] ?? 0) + 1;
  }
  final refPool = <String, int>{};
  for (final x in ref) {
    refPool[x] = (refPool[x] ?? 0) + 1;
  }
  final missing = <String>[];
  for (final x in ref) {
    if ((gotPool[x] ?? 0) > 0) {
      gotPool[x] = gotPool[x]! - 1;
    } else {
      missing.add(x);
    }
  }
  final extra = <String>[];
  for (final x in got) {
    if ((refPool[x] ?? 0) > 0) {
      refPool[x] = refPool[x]! - 1;
    } else {
      extra.add(x);
    }
  }
  return _Diff(false, missing, extra);
}
