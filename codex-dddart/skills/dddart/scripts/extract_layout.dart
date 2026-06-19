#!/usr/bin/env dart
/// extract_layout — 동결 Stitch HTML → layout-ir.json (FID 시각 구조 충실도·무의존).
///
/// extract_design.dart가 *토큰*(색·타이포·아이콘)을 절단한다면, 이 도구는 화면의 *구조*
/// (영역·섹션 구성·말단 슬롯)를 결정론 layout-ir로 절단한다. 시안 쪽 판정원이며, 코드 쪽
/// 렌더 덤프(workspace/eval/tools/)와 같은 스키마를 산출해 compare_layout.dart로 대조한다.
///
/// 스키마(동결본·SSOT): workspace/eval/tools/layout-ir-schema.md
/// 분류(번역표 §2): class에 material-symbols=icon · <button>/<a role=button>=button ·
///   <img>=image · 텍스트=text / width: w-N·size-N=fixed, flex-1·grow=flex / align: text-*·justify-*·items-*.
/// 영역(§1): <header>=appbar · <img>=image · <section>=section · <nav>=bottomnav. main·div는 투명 펼침.
///
/// 사용: dart run extract_layout.dart <design-ref-dir> --out <layout-ir.json>
/// 종료: 0=성공 / 1=사용법·HTML 없음·body 없음(Phase 0 동결 누락 = 시안 미반영 신호).
library;

import 'dart:convert';
import 'dart:io';

void main(List<String> argv) {
  String? dir;
  String? outFile;
  for (var i = 0; i < argv.length; i++) {
    if (argv[i] == '--out') {
      outFile = argv[++i];
    } else {
      dir = argv[i];
    }
  }
  if (dir == null || outFile == null) {
    stderr.writeln('사용: dart run extract_layout.dart <design-ref-dir> --out <layout-ir.json>');
    exit(1);
  }
  final d = Directory(dir);
  if (!d.existsSync()) {
    stderr.writeln('[extract-layout] design-ref 디렉터리 없음: $dir');
    exit(1);
  }
  final htmls = d
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.toLowerCase().endsWith('.html'))
      .map((File f) => f.path)
      .toList()
    ..sort(); // 플랫폼 의존 나열 순서 → 정렬로 결정론
  if (htmls.isEmpty) {
    stderr.writeln('[extract-layout] 동결 HTML 없음: $dir/*.html — Stitch htmlCode 동결 누락(Phase 0 위반).');
    exit(1);
  }

  final screens = <Map<String, dynamic>>[];
  for (final path in htmls) {
    final name = path.split(Platform.pathSeparator).last;
    final html = File(path).readAsStringSync();
    final root = _parseHtml(html);
    final body = _find(root, 'body');
    if (body == null) {
      stderr.writeln('[extract-layout] $name: <body> 없음 — 비정상 HTML.');
      exit(1);
    }
    screens.add(<String, dynamic>{
      'screen': name.replaceAll('.html', ''),
      'areas': _collectAreas(body),
    });
  }

  final out = <String, dynamic>{
    'meta': <String, dynamic>{'generator': 'extract_layout.dart', 'version': 1},
    'screens': screens,
  };
  File(outFile).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  final areaCount = screens.fold<int>(0, (int a, Map<String, dynamic> s) => a + (s['areas'] as List).length);
  stdout.writeln('[extract-layout] 화면 ${screens.length} · 영역 $areaCount → $outFile');
  exit(0);
}

// ===== HTML 토크나이저 → 트리 (무의존) =====

class _N {
  _N(this.tag);
  final String tag; // 소문자 태그명 또는 '#text'
  final Map<String, String> attrs = <String, String>{};
  final List<_N> children = <_N>[];
  String text = '';
  String get cls => attrs['class'] ?? '';
}

const _voidTags = <String>{
  'img', 'br', 'hr', 'input', 'meta', 'link', 'source', 'area', 'base', 'col', 'embed', 'param', 'track', 'wbr',
};

_N _parseHtml(String html) {
  final root = _N('#root');
  final stack = <_N>[root];
  var i = 0;
  while (i < html.length) {
    final lt = html.indexOf('<', i);
    if (lt < 0) {
      _addText(stack.last, html.substring(i));
      break;
    }
    if (lt > i) _addText(stack.last, html.substring(i, lt));
    if (html.startsWith('<!--', lt)) {
      final end = html.indexOf('-->', lt);
      i = end < 0 ? html.length : end + 3;
      continue;
    }
    if (html.startsWith('<!', lt)) {
      final end = html.indexOf('>', lt);
      i = end < 0 ? html.length : end + 1;
      continue;
    }
    final gt = _tagEnd(html, lt);
    if (gt < 0) break;
    final raw = html.substring(lt + 1, gt).trim();
    if (raw.isEmpty) {
      i = gt + 1;
      continue;
    }
    if (raw.startsWith('/')) {
      final tag = raw.substring(1).trim().toLowerCase();
      for (var s = stack.length - 1; s > 0; s--) {
        if (stack[s].tag == tag) {
          stack.removeRange(s, stack.length);
          break;
        }
      }
      i = gt + 1;
      continue;
    }
    final selfClose = raw.endsWith('/');
    final bodyText = selfClose ? raw.substring(0, raw.length - 1).trim() : raw;
    final sp = bodyText.indexOf(RegExp(r'\s'));
    final tag = (sp < 0 ? bodyText : bodyText.substring(0, sp)).toLowerCase();
    final node = _N(tag);
    if (sp >= 0) _parseAttrs(bodyText.substring(sp + 1), node.attrs);
    stack.last.children.add(node);
    if (tag == 'script' || tag == 'style') {
      final close = '</$tag>';
      final ce = html.indexOf(close, gt + 1);
      i = ce < 0 ? html.length : ce + close.length;
      continue;
    }
    if (!_voidTags.contains(tag) && !selfClose) stack.add(node);
    i = gt + 1;
  }
  return root;
}

/// lt의 `<`부터 짝 맞는 `>`까지 위치(따옴표 안 `>`는 무시).
int _tagEnd(String s, int lt) {
  String? quote;
  for (var i = lt + 1; i < s.length; i++) {
    final c = s[i];
    if (quote != null) {
      if (c == quote) quote = null;
    } else if (c == '"' || c == "'") {
      quote = c;
    } else if (c == '>') {
      return i;
    }
  }
  return -1;
}

final _attrRe = RegExp('''([\\w:-]+)\\s*=\\s*("([^"]*)"|'([^']*)'|(\\S+))''');

void _parseAttrs(String s, Map<String, String> into) {
  for (final m in _attrRe.allMatches(s)) {
    into[m[1]!.toLowerCase()] = m[3] ?? m[4] ?? m[5] ?? '';
  }
}

void _addText(_N parent, String raw) {
  final t = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.isEmpty) return;
  parent.children.add(_N('#text')..text = t);
}

_N? _find(_N node, String tag) {
  for (final c in node.children) {
    if (c.tag == tag) return c;
    final r = _find(c, tag);
    if (r != null) return r;
  }
  return null;
}

// ===== 번역표 정규화: 트리 → layout-ir =====

/// L1: body 트리를 DFS하며 시맨틱 영역(appbar/image/section/bottomnav)을 순서대로 수집.
/// 비시맨틱 컨테이너(main·div)는 투명 펼침(자식 재귀).
List<Map<String, dynamic>> _collectAreas(_N body) {
  final areas = <Map<String, dynamic>>[];
  void walk(_N n) {
    for (final c in n.children) {
      switch (c.tag) {
        case 'header':
          areas.add(<String, dynamic>{'role': 'appbar', 'slots': _slots(c)});
        case 'nav':
          areas.add(<String, dynamic>{'role': 'bottomnav', 'slots': _slots(c)});
        case 'section':
          final label = _label(c);
          areas.add(<String, dynamic>{
            'role': 'section',
            if (label != null) 'label': label,
            'children': _blocks(c),
          });
        case 'img':
          areas.add(<String, dynamic>{'role': 'image', 'src': c.attrs['src'] ?? '', 'alt': c.attrs['alt'] ?? ''});
        case '#text':
          break;
        default:
          walk(c); // 투명 펼침(main·div 등)
      }
    }
  }
  walk(body);
  return areas;
}

/// L2: section children → block / repeat-group (near-isomorphic 형제 ≥2).
List<Map<String, dynamic>> _blocks(_N section) {
  // heading은 label로 *기록*하되 children에도 콘텐츠 슬롯으로 포함한다(hero의 날짜 h2처럼
  // heading이 콘텐츠인 경우 누락 방지). label은 참고용(비교 키 아님·스키마 §1).
  final items = <_N>[];
  for (final c in section.children) {
    if (c.tag == '#text') continue;
    items.add(c);
  }
  final out = <Map<String, dynamic>>[];
  var i = 0;
  while (i < items.length) {
    final sig = _sig(items[i]);
    var j = i + 1;
    while (j < items.length && _sig(items[j]) == sig) {
      j++;
    }
    if (j - i >= 2) {
      // 반복 그룹: 횟수는 비교 제외(스키마 §1) — unit 템플릿만
      out.add(<String, dynamic>{
        'kind': 'repeat-group',
        'unit': <String, dynamic>{'slots': _slotsOf(items[i])},
      });
    } else {
      out.add(<String, dynamic>{'kind': 'block', 'slots': _slotsOf(items[i])});
    }
    i = j;
  }
  return out;
}

/// L3: 컨테이너 직속 슬롯 수집(투명 노드는 펼침).
List<Map<String, dynamic>> _slots(_N container) {
  final out = <Map<String, dynamic>>[];
  for (final c in container.children) {
    if (c.tag == '#text') continue;
    final s = _slotOf(c);
    if (s != null) {
      out.add(s);
    } else if (_hasContent(c)) {
      out.addAll(_slots(c)); // 투명 컨테이너 펼침
    }
  }
  return out;
}

/// 노드가 단일 시각 타입이면 슬롯, 혼합·빈 컨테이너면 null(상위가 펼침).
Map<String, dynamic>? _slotOf(_N n) {
  if (n.tag == '#text') return null;
  final t = _dominantType(n);
  if (t == null) return null;
  final s = <String, dynamic>{'type': t};
  final w = _width(n);
  if (w != null) s['width'] = w;
  final a = _align(n);
  if (a != null) s['align'] = a;
  return s;
}

/// node가 단일 슬롯이면 [slot], slot 묶음(card 등)이면 그 자식 슬롯들.
List<Map<String, dynamic>> _slotsOf(_N n) {
  final self = _slotOf(n);
  if (self != null) return <Map<String, dynamic>>[self];
  return _slots(n);
}

/// 서브트리의 지배 시각 타입. 단일이면 그 타입, 혼합이면 null(group·상위 펼침).
String? _dominantType(_N n) {
  if (n.cls.contains('material-symbols')) return 'icon';
  if (n.tag == 'img') return 'image';
  if (n.tag == 'button' || (n.tag == 'a' && n.attrs['role'] == 'button')) return 'button';
  final kinds = <String>{};
  var hasText = false;
  void scan(_N x) {
    for (final c in x.children) {
      if (c.tag == '#text') {
        if (c.text.isNotEmpty) hasText = true;
      } else if (c.cls.contains('material-symbols')) {
        kinds.add('icon');
      } else if (c.tag == 'img') {
        kinds.add('image');
      } else if (c.tag == 'button' || (c.tag == 'a' && c.attrs['role'] == 'button')) {
        kinds.add('button');
      } else {
        scan(c);
      }
    }
  }

  scan(n);
  if (hasText) kinds.add('text');
  if (kinds.length == 1) return kinds.first;
  if (kinds.isEmpty) return null;
  return null; // 혼합 → 상위가 펼쳐 개별 슬롯화
}

String? _width(_N n) {
  final c = n.cls;
  if (RegExp(r'(^|\s)(flex-1|flex-grow|grow)(\s|$)').hasMatch(c)) return 'flex';
  if (RegExp(r'(^|\s)(w-\d+|size-\d+|w-\[)').hasMatch(c)) return 'fixed';
  return null;
}

String? _align(_N n) {
  final c = n.cls;
  if (c.contains('text-right') || c.contains('justify-end') || c.contains('items-end')) return 'right';
  if (c.contains('text-center') || c.contains('justify-center') || c.contains('items-center')) return 'center';
  if (c.contains('text-left') || c.contains('justify-start') || c.contains('items-start')) return 'left';
  return null;
}

bool _hasContent(_N n) {
  if (_dominantType(n) != null) return true;
  return n.children.any((_N c) => c.tag != '#text' && _hasContent(c));
}

String _sig(_N n) => _slotsOf(n).map((Map<String, dynamic> s) => s['type']).join(',');

String? _label(_N section) {
  for (final c in section.children) {
    if (RegExp(r'^h[1-6]$').hasMatch(c.tag)) {
      final t = _textOf(c).trim();
      if (t.isNotEmpty) return t;
    }
  }
  return null;
}

String _textOf(_N n) {
  final b = StringBuffer();
  void walk(_N x) {
    for (final c in x.children) {
      if (c.tag == '#text') {
        b.write('${c.text} ');
      } else {
        walk(c);
      }
    }
  }

  walk(n);
  return b.toString().trim();
}
