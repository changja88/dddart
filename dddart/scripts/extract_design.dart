#!/usr/bin/env dart
/// extract_design — Phase 0 직후 동결 Stitch design-ref를 design-tokens.json으로 기계 절단 (feedback-005 목표1).
///
/// 동결 HTML의 `<script id="tailwind-config">`(색·spacing·borderRadius·타이포)과 본문
/// `material-symbols-outlined`(아이콘 `data-icon`+`FILL`)·임의값(`shadow-[...]`·음수마진)을
/// 결정론 추출한다. LLM 추출(피드백3 재현)을 제거하고 architect는 산출물만 소비한다(설계 §목표1).
///
/// 사용:
///   dart run extract_design.dart <design-ref-dir> --out <design-tokens.json> [--icon-map <icon_map.json>]
///
/// 종료코드: 0=성공(미매핑 아이콘은 경고·산출물에 `flutter:null`로 표시) / 1=사용법·HTML 없음·config 파싱 실패.
/// HTML 부재는 그 자체가 발견이다 — Phase 0이 이미 G0 차단하지만 여기서도 exit 1(동결 누락 = 시안 미반영).
library;

import 'dart:convert';
import 'dart:io';

void main(List<String> argv) {
  String? dir;
  String? outFile;
  String? iconMapFile;
  for (var i = 0; i < argv.length; i++) {
    switch (argv[i]) {
      case '--out':
        outFile = argv[++i];
      case '--icon-map':
        iconMapFile = argv[++i];
      default:
        dir = argv[i];
    }
  }
  if (dir == null || outFile == null) {
    stderr.writeln('사용: dart run extract_design.dart <design-ref-dir> --out <design-tokens.json> [--icon-map <icon_map.json>]');
    exit(1);
  }

  final dirEntity = Directory(dir);
  if (!dirEntity.existsSync()) {
    stderr.writeln('[extract-design] design-ref 디렉터리 없음: $dir');
    exit(1);
  }
  final htmlFiles = dirEntity
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.toLowerCase().endsWith('.html'))
      .map((File f) => f.path)
      .toList()
    ..sort(); // 디렉터리 나열 순서는 플랫폼 의존 → 정렬로 결정론 확보
  if (htmlFiles.isEmpty) {
    stderr.writeln('[extract-design] 동결 HTML 없음: $dir/*.html — Stitch htmlCode 동결이 누락됐다(Phase 0 위반).');
    exit(1);
  }

  final iconMap = _loadIconMap(iconMapFile);

  // 화면 간 공유 토큰(같은 디자인시스템)은 합집합·불일치는 경고. 아이콘은 화면별 합집합.
  final colors = <String, String>{};
  final spacing = <String, String>{};
  final borderRadius = <String, String>{};
  final typography = <String, Map<String, String>>{};
  final icons = <String, _IconAgg>{}; // key: "name|fill"
  final arbitrary = <String>{};
  final negativeMargins = <String>{};
  final screens = <Map<String, String>>[];
  final warnings = <String>[];

  for (final path in htmlFiles) {
    final name = path.split(Platform.pathSeparator).last;
    final html = File(path).readAsStringSync();
    screens.add(<String, String>{'file': name, 'title': _title(html)});

    final block = _configBlock(html);
    if (block == null) {
      warnings.add('$name: <script id="tailwind-config"> 없음 — 색·타이포 미추출(시안 누락 신호)');
    } else {
      final config = _parseConfig(block);
      if (config == null) {
        stderr.writeln('[extract-design] $name: tailwind-config 파싱 실패 — JS→JSON 정규화 후에도 비해석. 동결본을 확인하라.');
        exit(1);
      }
      final extend = _extend(config);
      _mergeStringMap(colors, extend['colors'], name, 'colors', warnings);
      _mergeStringMap(spacing, extend['spacing'], name, 'spacing', warnings);
      _mergeStringMap(borderRadius, extend['borderRadius'], name, 'borderRadius', warnings);
      _mergeTypography(typography, extend['fontFamily'], extend['fontSize']);
    }

    _collectIcons(html, name, iconMap, icons);
    _collectClassTokens(html, arbitrary, negativeMargins);
  }

  // fail-loud: tailwind-config 토큰이 0이면(블록 부재·빈 config) 시안 색·spacing·타이포를 기계 추출
  // 못 한 것 — 빈 토큰으로 충실도 게이트가 헛발동하지 않게 exit 1(command가 has_stitch_html=false로 처리).
  if (colors.isEmpty && spacing.isEmpty && typography.isEmpty) {
    stderr.writeln('[extract-design] tailwind-config 토큰 0 — 동결 HTML에 <script id="tailwind-config">가 '
        '없거나 비었다. 색·spacing·타이포를 기계 추출할 수 없다(has_stitch_html=false·이미지+인간 오라클 보조로 진행).');
    exit(1);
  }

  final unmapped = icons.values.where((_IconAgg a) => a.flutter == null).map((_IconAgg a) => a.name).toSet().toList()..sort();

  final out = <String, dynamic>{
    'meta': <String, dynamic>{
      'generator': 'extract_design.dart',
      'version': 1,
      'screens': screens,
    },
    'colors': _sorted(colors),
    'spacing': _sorted(spacing),
    'borderRadius': _sorted(borderRadius),
    'typography': _sortedNested(typography),
    'icons': _emitIcons(icons),
    'arbitraryValues': arbitrary.toList()..sort(),
    'negativeMargins': negativeMargins.toList()..sort(),
    'unmappedIcons': unmapped,
  };

  File(outFile).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  for (final w in warnings) {
    stdout.writeln('[warn] $w');
  }
  if (unmapped.isNotEmpty) {
    stdout.writeln('[warn] 미매핑 아이콘 ${unmapped.length}종(icon_map.json 미수록·architect가 ui_extension에 수동 매핑): ${unmapped.join(', ')}');
  }
  stdout.writeln('[extract-design] 화면 ${screens.length} · 색 ${colors.length} · spacing ${spacing.length} · 타이포 ${typography.length} · 아이콘 ${icons.length}(미매핑 ${unmapped.length}) · 임의값 ${arbitrary.length} → $outFile');
  exit(0);
}

// ---- 화면 제목 ----

final _titleRe = RegExp(r'<title>([^<]*)</title>', caseSensitive: false);

String _title(String html) {
  final m = _titleRe.firstMatch(html);
  return m != null ? m.group(1)!.trim() : '';
}

// ---- tailwind-config 블록 ----

String? _configBlock(String html) {
  const marker = '<script id="tailwind-config">';
  final start = html.indexOf(marker);
  if (start < 0) return null;
  final contentStart = html.indexOf('>', start) + 1;
  final end = html.indexOf('</script>', contentStart);
  if (end < 0) return null;
  return html.substring(contentStart, end);
}

/// `tailwind.config = { ... }`의 객체 리터럴을 JS→JSON 정규화 후 디코드.
/// Stitch 출력은 무인용 상위 키(darkMode·theme·extend)와 trailing comma만 JS-ism이다.
Map<String, dynamic>? _parseConfig(String block) {
  final eq = block.indexOf('=');
  final braceStart = block.indexOf('{', eq < 0 ? 0 : eq);
  if (braceStart < 0) return null;
  final objText = _balanced(block, braceStart);
  if (objText == null) return null;
  try {
    final decoded = jsonDecode(_jsToJson(objText));
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

/// JS 객체 리터럴 → JSON. **문자열 리터럴 안은 보존**하고 그 밖에서만 무인용 키 인용 + trailing
/// comma 제거 — 따옴표 무인지 정규화가 값 안의 `,ident:`·`{ident:`를 손상시키는 것을 막는다(따옴표·
/// 이스케이프 추적). 단일따옴표 문자열은 보존돼 jsonDecode가 fail-loud(현 Stitch 출력은 큰따옴표만).
String _jsToJson(String src) {
  final out = StringBuffer();
  final seg = StringBuffer(); // 비문자열 구간 누적
  void flushSeg() {
    if (seg.isEmpty) return;
    out.write(seg
        .toString()
        .replaceAllMapped(RegExp(r'([{,]\s*)([A-Za-z_$][A-Za-z0-9_$]*)\s*:'), (Match m) => '${m[1]}"${m[2]}":')
        .replaceAllMapped(RegExp(r',(\s*[}\]])'), (Match m) => '${m[1]}'));
    seg.clear();
  }

  String? quote;
  for (var i = 0; i < src.length; i++) {
    final c = src[i];
    if (quote != null) {
      out.write(c);
      if (c == r'\' && i + 1 < src.length) {
        out.write(src[i + 1]);
        i++; // 이스케이프 다음 문자 보존
      } else if (c == quote) {
        quote = null;
      }
      continue;
    }
    if (c == '"' || c == "'") {
      flushSeg();
      quote = c;
      out.write(c);
      continue;
    }
    seg.write(c);
  }
  flushSeg();
  return out.toString();
}

/// braceStart의 `{`부터 짝 맞는 `}`까지 부분 문자열(따옴표 안 중괄호는 무시).
String? _balanced(String s, int braceStart) {
  var depth = 0;
  String? quote;
  for (var i = braceStart; i < s.length; i++) {
    final c = s[i];
    if (quote != null) {
      if (c == r'\') {
        i++; // 이스케이프 다음 문자 건너뜀
      } else if (c == quote) {
        quote = null;
      }
      continue;
    }
    if (c == '"' || c == "'") {
      quote = c;
    } else if (c == '{') {
      depth++;
    } else if (c == '}') {
      depth--;
      if (depth == 0) return s.substring(braceStart, i + 1);
    }
  }
  return null;
}

Map<String, dynamic> _extend(Map<String, dynamic> config) {
  final theme = config['theme'];
  if (theme is Map<String, dynamic>) {
    final extend = theme['extend'];
    if (extend is Map<String, dynamic>) return extend;
    return theme;
  }
  return config;
}

void _mergeStringMap(Map<String, String> into, dynamic src, String screen, String key, List<String> warnings) {
  if (src is! Map) return;
  src.forEach((dynamic k, dynamic v) {
    if (v is String) {
      final name = k.toString();
      final prev = into[name];
      if (prev != null && prev != v) {
        warnings.add('$screen: $key.$name 값 불일치($prev → $v) — 화면 간 디자인시스템 차이, 첫 값 유지');
        return;
      }
      into[name] = v;
    }
  });
}

void _mergeTypography(Map<String, Map<String, String>> into, dynamic fontFamily, dynamic fontSize) {
  void ensure(String name) => into.putIfAbsent(name, () => <String, String>{});
  if (fontFamily is Map) {
    fontFamily.forEach((dynamic k, dynamic v) {
      final fam = v is List && v.isNotEmpty ? v.first.toString() : (v is String ? v : null);
      if (fam != null) {
        ensure(k.toString());
        into[k.toString()]!['family'] = fam;
      }
    });
  }
  if (fontSize is Map) {
    fontSize.forEach((dynamic k, dynamic v) {
      ensure(k.toString());
      final m = into[k.toString()]!;
      if (v is List && v.isNotEmpty) {
        m['size'] = v.first.toString();
        if (v.length > 1 && v[1] is Map) {
          final meta = v[1] as Map;
          for (final attr in const ['lineHeight', 'fontWeight', 'letterSpacing']) {
            if (meta[attr] != null) m[attr] = meta[attr].toString();
          }
        }
      } else if (v is String) {
        m['size'] = v;
      }
    });
  }
}

// ---- 본문: 아이콘·임의값 ----

final _iconElement = RegExp(
    r'<(span|button|a|i)\b([^>]*material-symbols-outlined[^>]*)>([^<]*)</\1>',
    caseSensitive: false);
final _dataIcon = RegExp(r'data-icon="([^"]+)"');
final _fill = RegExp(r"'FILL'\s*(\d)");

void _collectIcons(String html, String screen, Map<String, String> iconMap, Map<String, _IconAgg> into) {
  for (final m in _iconElement.allMatches(html)) {
    final attrs = m.group(2)!;
    final inner = m.group(3)!.trim();
    final di = _dataIcon.firstMatch(attrs);
    final name = di != null ? di.group(1)! : inner;
    if (name.isEmpty || name.contains(' ')) continue; // 리거처 아이콘명은 단일 토큰
    // FILL: 인라인 스타일 우선, 없으면 Material Symbols 기본 0
    final fm = _fill.firstMatch(attrs);
    final fill = fm != null ? int.parse(fm.group(1)!) : 0;
    final key = '$name|$fill';
    final agg = into.putIfAbsent(key, () => _IconAgg(name, fill, iconMap[name]));
    agg.screens.add(screen);
  }
}

final _classAttr = RegExp(r'class="([^"]*)"');
final _arbitrary = RegExp(r'^[a-zA-Z][\w-]*-\[[^\]]+\]$');
final _negMargin = RegExp(r'^-m[trblxyse]?-');

void _collectClassTokens(String html, Set<String> arbitrary, Set<String> negativeMargins) {
  for (final m in _classAttr.allMatches(html)) {
    for (final tok in m.group(1)!.split(RegExp(r'\s+'))) {
      if (tok.isEmpty) continue;
      final bare = tok.contains(':') ? tok.split(':').last : tok; // hover:/active:/md: 변형 제거
      if (_arbitrary.hasMatch(bare)) arbitrary.add(bare);
      if (_negMargin.hasMatch(bare)) negativeMargins.add(bare);
    }
  }
}

// ---- icon_map ----

Map<String, String> _loadIconMap(String? path) {
  if (path == null) return <String, String>{};
  final f = File(path);
  if (!f.existsSync()) {
    stderr.writeln('[extract-design] icon-map 없음(매핑 생략): $path');
    return <String, String>{};
  }
  try {
    final doc = jsonDecode(f.readAsStringSync());
    final icons = doc is Map ? doc['icons'] : null;
    if (icons is Map) {
      return icons.map((dynamic k, dynamic v) => MapEntry(k.toString(), v.toString()));
    }
  } catch (e) {
    stderr.writeln('[extract-design] icon-map 파싱 실패(매핑 생략): $e');
  }
  return <String, String>{};
}

// ---- 출력 정렬(결정론) ----

Map<String, String> _sorted(Map<String, String> m) {
  final keys = m.keys.toList()..sort();
  return <String, String>{for (final k in keys) k: m[k]!};
}

Map<String, Map<String, String>> _sortedNested(Map<String, Map<String, String>> m) {
  final keys = m.keys.toList()..sort();
  return <String, Map<String, String>>{for (final k in keys) k: _sorted(m[k]!)};
}

List<Map<String, dynamic>> _emitIcons(Map<String, _IconAgg> icons) {
  final list = icons.values.toList()
    ..sort((a, b) => a.name == b.name ? a.fill.compareTo(b.fill) : a.name.compareTo(b.name));
  return [
    for (final a in list)
      <String, dynamic>{
        'name': a.name,
        'fill': a.fill,
        'flutter': a.flutter,
        'screens': a.screens.toList()..sort(),
      },
  ];
}

class _IconAgg {
  _IconAgg(this.name, this.fill, this.flutter);
  final String name;
  final int fill;
  final String? flutter;
  final Set<String> screens = <String>{};
}
