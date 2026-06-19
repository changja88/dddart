#!/usr/bin/env dart
/// dump_to_ir — 위젯 타입 트리(dump_probe 산출 JSON) → layout-ir.json (FID 코드 쪽 판정원).
///
/// 시안 파서(`extract_layout.dart`)와 **같은 스키마·대칭 번역표(위젯판)**를 산출해
/// `compare_layout.dart`로 시안↔코드 대조한다. 산출물 위젯 트리 덤프(`dump_probe`·flutter test)
/// 가 낸 `{type,text?,icon?,img?,tap?,children}` 트리를 받아 정규화한다(렌더 덤프의 정규화 절반).
///
/// 번역표(위젯·스키마 §2): `*AppBar`=appbar · `Image`=image · `*Section`=section ·
///   `BottomNavigationBar`/`NavigationBar`=bottomnav / `Text`·`RichText`=text · `Icon`=icon · `*Button`=button.
/// 정규화: Scaffold element 순서≠시각 순서 → **appbar 맨앞·bottomnav 맨뒤**. 레이아웃 위젯만 펼침
///   (Column·Row·ListView·SizedBox…), `InkWell`/`_MetricCard`/커스텀은 반복 단위. near-isomorphic ≥2=repeat-group.
///
/// 사용: dart run dump_to_ir.dart <tree.json> --screen <name> --out <layout-ir.json>
/// 종료: 0=성공 / 1=사용법·파일.
library;

import 'dart:convert';
import 'dart:io';

void main(List<String> argv) {
  String? inFile;
  String? outFile;
  String? screen;
  for (var i = 0; i < argv.length; i++) {
    switch (argv[i]) {
      case '--out':
        outFile = argv[++i];
      case '--screen':
        screen = argv[++i];
      default:
        inFile = argv[i];
    }
  }
  if (inFile == null || outFile == null) {
    stderr.writeln('사용: dart run dump_to_ir.dart <tree.json> --screen <name> --out <layout-ir.json>');
    exit(1);
  }
  final root = jsonDecode(File(inFile).readAsStringSync()) as Map<String, dynamic>;
  final areas = _collectAreas(root);
  final out = <String, dynamic>{
    'meta': <String, dynamic>{'generator': 'dump_to_ir.dart', 'version': 1},
    'screens': <Map<String, dynamic>>[
      <String, dynamic>{'screen': screen ?? (root['type'] ?? 'screen'), 'areas': areas},
    ],
  };
  File(outFile).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  stdout.writeln('[dump-to-ir] 영역 ${areas.length} → $outFile');
  exit(0);
}

List<Map<String, dynamic>> _kids(Map<String, dynamic> n) =>
    (n['children'] as List? ?? const <dynamic>[]).cast<Map<String, dynamic>>();

// ===== 번역표(위젯판) =====

bool _isAppbar(String t) => t.endsWith('AppBar');
bool _isBottomNav(String t) => t.contains('BottomNav') || t == 'NavigationBar';
bool _isSection(String t) => t.endsWith('Section');
bool _isImage(Map<String, dynamic> n) => n['img'] == true || n['type'] == 'Image';

/// 반복 단위 후보 — InkWell·카드/타일·커스텀 묶음. 그 외(순수 레이아웃·ListView internal
/// Scrollable/Viewport/Sliver… 20+겹)는 전부 펼친다 — 화이트리스트 열거(취약·버전 의존) 대신
/// "단위만 식별·나머지 투명" 역전으로 element 트리 깊이에 견고.
bool _isUnit(String t) => t == 'InkWell' || t == 'GestureDetector' || t.endsWith('Card') || t.endsWith('Tile');

/// 단일 시각 슬롯 타입(컨테이너면 null → 펼침).
String? _dominant(Map<String, dynamic> n) {
  final t = n['type'] as String;
  if (n['icon'] != null || t == 'Icon') return 'icon';
  if (_isImage(n)) return 'image';
  if (t.endsWith('Button')) return 'button';
  if (t == 'Text' || t == 'RichText') return 'text';
  return null;
}

// ===== L1: 영역 =====

List<Map<String, dynamic>> _collectAreas(Map<String, dynamic> root) {
  final raw = <Map<String, dynamic>>[];
  void walk(Map<String, dynamic> n) {
    for (final c in _kids(n)) {
      final t = c['type'] as String;
      if (_isAppbar(t)) {
        raw.add(<String, dynamic>{'role': 'appbar', 'slots': _slots(c)});
      } else if (_isBottomNav(t)) {
        raw.add(<String, dynamic>{'role': 'bottomnav', 'slots': _slots(c)});
      } else if (_isSection(t)) {
        raw.add(<String, dynamic>{'role': 'section', 'children': _blocks(c)});
      } else if (_isImage(c)) {
        raw.add(<String, dynamic>{'role': 'image'});
      } else {
        walk(c);
      }
    }
  }

  walk(root);
  // 시각 순서 정규화(안정): appbar 먼저 · bottomnav 마지막 · 나머지 원순서.
  return <Map<String, dynamic>>[
    ...raw.where((Map<String, dynamic> a) => a['role'] == 'appbar'),
    ...raw.where((Map<String, dynamic> a) => a['role'] != 'appbar' && a['role'] != 'bottomnav'),
    ...raw.where((Map<String, dynamic> a) => a['role'] == 'bottomnav'),
  ];
}

// ===== L2: section children (near-isomorphic → repeat-group) =====

List<Map<String, dynamic>> _blocks(Map<String, dynamic> section) {
  final units = _units(section);
  final out = <Map<String, dynamic>>[];
  var i = 0;
  while (i < units.length) {
    if (_isUnit(units[i]['type'] as String)) {
      // 묶음 단위(card 등): near-isomorphic 연속 ≥2 → repeat-group
      final sig = _sig(units[i]);
      var j = i + 1;
      while (j < units.length && _isUnit(units[j]['type'] as String) && _sig(units[j]) == sig) {
        j++;
      }
      final slots = _slots(units[i]);
      if (j - i >= 2) {
        out.add(<String, dynamic>{'kind': 'repeat-group', 'unit': <String, dynamic>{'slots': slots}});
      } else if (slots.isNotEmpty) {
        out.add(<String, dynamic>{'kind': 'block', 'slots': slots});
      }
      i = j;
    } else {
      // 단독 slot(Text·Icon 등): 연속분을 한 block에 모음(near-iso 미적용 — 비반복 적층)
      final slots = <Map<String, dynamic>>[];
      while (i < units.length && !_isUnit(units[i]['type'] as String)) {
        final d = _dominant(units[i]);
        if (d != null) slots.add(<String, dynamic>{'type': d});
        i++;
      }
      if (slots.isNotEmpty) out.add(<String, dynamic>{'kind': 'block', 'slots': slots});
    }
  }
  return out;
}

/// 콘텐츠 단위 수집 — 반복 단위(InkWell·*Card)·단독 slot은 멈춤, 나머지(레이아웃·internal)는 펼침.
List<Map<String, dynamic>> _units(Map<String, dynamic> n) {
  final out = <Map<String, dynamic>>[];
  for (final c in _kids(n)) {
    final t = c['type'] as String;
    if (_isUnit(t) || _dominant(c) != null) {
      out.add(c);
    } else {
      out.addAll(_units(c));
    }
  }
  return out;
}

// ===== L3: slots(펼침 후 dominant) =====

List<Map<String, dynamic>> _slots(Map<String, dynamic> n) {
  final out = <Map<String, dynamic>>[];
  for (final c in _kids(n)) {
    final d = _dominant(c);
    if (d != null) {
      out.add(<String, dynamic>{'type': d});
    } else {
      out.addAll(_slots(c));
    }
  }
  return out;
}

String _sig(Map<String, dynamic> n) => _slots(n).map((Map<String, dynamic> s) => s['type']).join(',');
