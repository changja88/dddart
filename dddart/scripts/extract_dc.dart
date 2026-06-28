#!/usr/bin/env dart
/// extract_dc — Claude Design PROJECT(`.dc.html`) 앱화면에서 아이콘·이미지·게이트텍스트 결정론 추출 (claude 전용).
///
/// dddart가 디자인시스템 키트의 *예시 화면*이 아니라 사용자가 실제로 그린 **앱 PROJECT의 `.dc.html` 화면**을
/// 시안 출처로 쓰게 한다. 토큰(색·간격·타이포)은 기존 `extract_design --from-ds-manifest`가 먼저 산출하고,
/// 이 도구는 그 `design-tokens.json`을 **read-modify-write**로 열어 `icons[]`·`unmappedIcons`만 주입한다
/// (colors/spacing/typography/borderRadius/arbitraryValues 보존 — 통째 덮어쓰기 금지). `<img>`는 바이트 복사로
/// `asset-manifest.json`(기존 스키마)에, 게이트 텍스트(`.title`·`.subtitle`·카드 `.rtitle`)는 신규
/// `screen-meta.json`으로 절단한다.
///
/// **대상은 앱 콘텐츠(`.screen` 서브트리)만**이다 — `.stage`/`.phone`/`.decor`/`.statusbar`는 폰 목업
/// device-chrome이라 그 아이콘(`signal_cellular_alt`·`wifi`·`battery_full`)은 출력에 절대 나오지 않는다.
/// `.screen`이 `<div>` 짝맞춤으로 추출되므로 그 밖의 크롬은 자동 제외된다.
///
/// HTML 파싱은 미러 스크립트(`fetch_images.dart`의 토크나이저 `_tagEnd`·`_parseAttrs`·`_camel`·`_uniqueToken`·
/// `_fetchOne`, `extract_design.dart`의 아이콘 스키마 `_IconAgg`·`_emitIcons`·`_loadIconMap`)의 검증된 로직을
/// **국소 복제**한다 — 미러 파일은 release `[2/7] diff -q` 게이트가 codex와 byte-동일 강제라 한 글자도 손대지 않는다.
///
/// 실행 순서(MF-3·고정): ① `extract_design --from-ds-manifest`가 `design-tokens.json`을 통째 기록(icons[] 빈 채)
/// → ② `extract_dc.dart`가 그 파일을 RMW로 채운다. design-tokens.json 부재면 fail-loud(exit 1).
///
/// 사용:
///   dart run extract_dc.dart <dc_html> --tokens <design-tokens.json> \
///     --asset-manifest <asset-manifest.json> --assets-root <root> --asset-base <dir> \
///     --meta <screen-meta.json> [--icon-map <icon_map.json>]
///   --asset-base: `<img src>` 상대경로를 `.dc.html` 디렉터리 기준으로 해소해 로컬 복사.
///
/// 종료: 0=성공(이미지 부분 실패는 status로 표면화) / 1=사용법·`.dc.html` 부재·`.screen` 부재·tokens 부재.
library;

import 'dart:convert';
import 'dart:io';

const _connectTimeout = Duration(seconds: 15);
const _responseTimeout = Duration(seconds: 20);
const _bodyTimeout = Duration(seconds: 30);

Future<void> main(List<String> argv) async {
  String? dcHtml;
  String? tokensPath;
  String? manifestPath;
  String? assetsRoot;
  String? assetBase; // .dc.html 디렉터리 — 상대경로 src 해소 기준
  String? metaPath;
  String? iconMapPath;
  for (var i = 0; i < argv.length; i++) {
    switch (argv[i]) {
      case '--tokens':
        tokensPath = argv[++i];
      case '--asset-manifest':
        manifestPath = argv[++i];
      case '--assets-root':
        assetsRoot = argv[++i];
      case '--asset-base':
        assetBase = argv[++i];
      case '--meta':
        metaPath = argv[++i];
      case '--icon-map':
        iconMapPath = argv[++i];
      default:
        dcHtml = argv[i];
    }
  }
  if (dcHtml == null ||
      tokensPath == null ||
      manifestPath == null ||
      assetsRoot == null ||
      assetBase == null ||
      metaPath == null) {
    stderr.writeln('사용: dart run extract_dc.dart <dc_html> --tokens <design-tokens.json> '
        '--asset-manifest <asset-manifest.json> --assets-root <root> --asset-base <dir> '
        '--meta <screen-meta.json> [--icon-map <icon_map.json>]');
    exit(1);
  }

  final dcFile = File(dcHtml);
  if (!dcFile.existsSync()) {
    stderr.writeln('[extract-dc] .dc.html 부재: $dcHtml — Phase 0 동결 누락(시안 미반영).');
    exit(1);
  }

  // RMW 전제: design-tokens.json이 먼저 있어야 한다(extract_design --from-ds-manifest 선행·MF-3).
  // 부재면 fail-loud — 통째 생성은 colors/spacing/typography를 비워 충실도 게이트를 헛발동시킨다.
  if (!File(tokensPath).existsSync()) {
    stderr.writeln('[extract-dc] design-tokens.json 부재: $tokensPath — extract_design --from-ds-manifest '
        '선행이 누락됐다(실행 순서 위반·MF-3). extract_dc는 통째 생성하지 않는다.');
    exit(1);
  }

  final html = dcFile.readAsStringSync();

  // 앱 콘텐츠 = `.screen` 서브트리만. device-chrome(.stage/.phone/.decor/.statusbar)은 `.screen` 밖이라 자동 제외.
  final app = _appContent(html);
  if (app == null) {
    stderr.writeln('[extract-dc] `.screen` 서브트리 없음: $dcHtml — 앱 콘텐츠 미검출(동결 누락 또는 '
        'device-chrome만). 동결본을 확인하라.');
    exit(1);
  }

  final screenName = dcFile.uri.pathSegments.last; // 아이콘 screens[] 귀속용 화면 식별자
  final slug = screenName.replaceAll(RegExp(r'\.dc\.html?$|\.html?$', caseSensitive: false), '');

  // 아이콘: material-symbols 리거처 수집 → icon_map 룩업(읽기만) → 미수록은 unmappedIcons.
  final iconMap = _loadIconMap(iconMapPath);
  final icons = <String, _IconAgg>{};
  _collectMsIcons(app, screenName, iconMap, icons);
  final unmapped = icons.values
      .where((_IconAgg a) => a.flutter == null)
      .map((_IconAgg a) => a.name)
      .toSet()
      .toList()
    ..sort();

  // 이미지: `<img src>` 상대경로를 assetBase 기준으로 해소·바이트 복사 → asset-manifest.json(기존 스키마).
  final assetsDir = Directory('$assetsRoot/assets/images');
  final images = await _collectImages(app, slug, assetBase, assetsDir);

  // 게이트 텍스트: `.title`·`.subtitle`·카드 `.rtitle` → screen-meta.json(§7 확인 게이트가 *이 파일만* 인용).
  final meta = _gateText(app);

  File(manifestPath).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(<String, dynamic>{'images': images})}\n');
  File(metaPath).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(meta)}\n');

  // RMW: design-tokens.json을 읽어 icons[]·unmappedIcons만 교체(나머지 토큰군 보존).
  _rmwTokens(tokensPath, _emitIcons(icons), unmapped);

  int count(String s) => images.where((Map<String, dynamic> e) => e['status'] == s).length;
  stdout.writeln('[extract-dc] $screenName · 아이콘 ${icons.length}(미매핑 ${unmapped.length}) · '
      '이미지 ${images.length}(ok ${count('ok')}·failed ${count('failed')}·inline ${count('inline')}·skipped ${count('skipped')}) · '
      '카드 ${(meta['cards'] as List).length} → tokens RMW($tokensPath)·$manifestPath·$metaPath');
  if (unmapped.isNotEmpty) {
    stdout.writeln('[warn] 미매핑 아이콘 ${unmapped.length}종(icon_map.json 미수록·architect가 ui_extension에 수동 매핑): ${unmapped.join(', ')}');
  }
  exit(0);
}

// ---- 앱 콘텐츠: `.screen` 서브트리 절단 ----

/// `.screen` 서브트리(앱 콘텐츠)만 반환. device-chrome은 `.screen` 밖이라 포함되지 않는다.
String? _appContent(String html) {
  final start = _findScreenStart(html);
  if (start < 0) return null;
  return _divSubtree(html, start);
}

/// class 토큰에 `screen`을 가진 첫 `<div>`의 `<` 위치. 없으면 -1.
/// (`fullscreen`·`touchscreen` 같은 부분일치는 토큰 단위 비교라 매칭되지 않는다.)
int _findScreenStart(String html) {
  final lower = html.toLowerCase();
  var i = 0;
  while (true) {
    final lt = lower.indexOf('<div', i);
    if (lt < 0) return -1;
    if (_wordCharAt(html, lt + 4)) {
      // `<divider` 등 다른 태그명 — 태그명 경계 아님, 건너뛴다.
      i = lt + 4;
      continue;
    }
    final gt = _tagEnd(html, lt);
    if (gt < 0) return -1;
    final raw = html.substring(lt + 1, gt); // div class="screen" ...
    final sp = raw.indexOf(_wsRe);
    if (sp >= 0) {
      final attrs = <String, String>{};
      _parseAttrs(raw.substring(sp + 1), attrs);
      if (_hasClass(attrs['class'] ?? '', 'screen')) return lt;
    }
    i = gt + 1;
  }
}

/// startLt의 `<div ...>`부터 짝 맞는 `</div>`까지 부분 문자열 — `<div>`/`</div>` 깊이추적
/// (extract_design `_balanced`의 중괄호 짝맞춤을 태그 짝맞춤으로 적응). `<img>`·`<span>`·`<a>` 등
/// 비-div 태그는 깊이에 무관하고 `_tagEnd`로 건너뛴다(따옴표 안 `>`는 무시). 균형 실패면 null.
String? _divSubtree(String html, int startLt) {
  final lower = html.toLowerCase();
  var depth = 0;
  var i = startLt;
  while (i < html.length) {
    final lt = lower.indexOf('<', i);
    if (lt < 0) break;
    if (lower.startsWith('</div', lt) && !_wordCharAt(html, lt + 5)) {
      final gt = _tagEnd(html, lt);
      if (gt < 0) break;
      depth--;
      if (depth == 0) return html.substring(startLt, gt + 1);
      i = gt + 1;
    } else if (lower.startsWith('<div', lt) && !_wordCharAt(html, lt + 4)) {
      final gt = _tagEnd(html, lt);
      if (gt < 0) break;
      depth++;
      i = gt + 1;
    } else {
      final gt = _tagEnd(html, lt);
      if (gt < 0) break;
      i = gt + 1;
    }
  }
  return null;
}

final _wordRe = RegExp(r'[A-Za-z0-9]');
final _wsRe = RegExp(r'\s');

bool _wordCharAt(String s, int pos) => pos < s.length && _wordRe.hasMatch(s[pos]);

/// class 속성 문자열에 주어진 토큰이 공백 구분 단어로 들어있는가(부분일치 아님).
bool _hasClass(String cls, String token) {
  for (final t in cls.split(RegExp(r'\s+'))) {
    if (t == token) return true;
  }
  return false;
}

// ---- 아이콘: material-symbols 리거처(extract_design 스키마 동형) ----

// `.dc.html`은 `<span class="material-symbols-rounded">manage_accounts</span>`(리거처 텍스트).
// 광학변종 rounded|outlined|sharp 모두 수용. extract_design `_iconElement`(outlined 전용)을 `.dc.html`에 적응.
final _msIconElement = RegExp(
    r'<(span|button|a|i)\b([^>]*material-symbols-(?:rounded|outlined|sharp)[^>]*)>([^<]*)</\1>',
    caseSensitive: false);
final _dataIcon = RegExp(r'data-icon="([^"]+)"');
final _fill = RegExp(r"'FILL'\s*(\d)");

void _collectMsIcons(String app, String screen, Map<String, String> iconMap, Map<String, _IconAgg> into) {
  for (final m in _msIconElement.allMatches(app)) {
    final attrs = m.group(2)!;
    final inner = m.group(3)!.trim();
    final di = _dataIcon.firstMatch(attrs);
    final name = di != null ? di.group(1)! : inner;
    if (name.isEmpty || name.contains(' ')) continue; // 리거처 아이콘명은 단일 토큰
    // FILL: 인라인 font-variation-settings 우선, 없으면 Material Symbols 기본 0(.dc.html은 통상 미지정).
    final fm = _fill.firstMatch(attrs);
    final fill = fm != null ? int.parse(fm.group(1)!) : 0;
    final key = '$name|$fill';
    final agg = into.putIfAbsent(key, () => _IconAgg(name, fill, iconMap[name]));
    agg.screens.add(screen);
  }
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

// ---- 게이트 텍스트: .title·.subtitle·카드 .rtitle ----

/// §7 확인 게이트가 인용할 결정론 텍스트. 코디네이터 본문 손-추출(=LLM 추출·dddart.md L120) 금지의 단일 출처.
Map<String, dynamic> _gateText(String app) {
  return <String, dynamic>{
    'title': _firstTextByClass(app, 'title') ?? '',
    'subtitle': _firstTextByClass(app, 'subtitle') ?? '',
    'cards': _allTextByClass(app, 'rtitle'),
  };
}

String? _firstTextByClass(String html, String cls) {
  final all = _allTextByClass(html, cls);
  return all.isEmpty ? null : all.first;
}

final _wsCollapse = RegExp(r'\s+');

/// class 토큰이 일치하는 모든 요소의 직속 텍스트(여는 태그 다음~다음 `<`)를 공백 정규화해 수집.
/// `.title`/`.subtitle`/`.rtitle`은 리프 텍스트 노드라 이 단순 절단으로 충분하다.
List<String> _allTextByClass(String html, String cls) {
  final out = <String>[];
  final lower = html.toLowerCase();
  var i = 0;
  while (true) {
    final lt = lower.indexOf('<', i);
    if (lt < 0) break;
    final gt = _tagEnd(html, lt);
    if (gt < 0) break;
    final raw = html.substring(lt + 1, gt);
    final sp = raw.indexOf(_wsRe); // 닫는 태그(`/div`)·속성 없는 태그는 공백 없음 → 건너뜀
    if (sp >= 0) {
      final attrs = <String, String>{};
      _parseAttrs(raw.substring(sp + 1), attrs);
      if (_hasClass(attrs['class'] ?? '', cls)) {
        final nextLt = html.indexOf('<', gt + 1);
        final text = html.substring(gt + 1, nextLt < 0 ? html.length : nextLt);
        final clean = text.replaceAll(_wsCollapse, ' ').trim();
        if (clean.isNotEmpty) out.add(clean);
      }
    }
    i = gt + 1;
  }
  return out;
}

// ---- 이미지: fetch_images 토크나이저·_fetchOne 국소 복제(미러 무변경 대가) ----

/// 앱 콘텐츠의 모든 `<img src>`를 assetBase 기준으로 해소·복사 → asset-manifest 엔트리 목록.
/// fetch_images의 JSX `--asset-base` 루프와 동형(상대경로는 resolveBase로 해소·동적 src={}는 skipped).
Future<List<Map<String, dynamic>>> _collectImages(
    String app, String slug, String assetBase, Directory assetsDir) async {
  final images = <Map<String, dynamic>>[];
  final usedTokens = <String>{};
  final resolveBase = Directory(assetBase).absolute.path; // 상대경로 해소 기준(절대화)
  final lower = app.toLowerCase();
  var n = 0;
  var i = 0;
  while (true) {
    final lt = lower.indexOf('<img', i);
    if (lt < 0) break;
    // `<img` 뒤가 단어문자면 `<image`·`<imgfoo` 등 다른 태그 — 건너뛴다(태그명 경계).
    final boundary = lt + 4 >= app.length || !_wordRe.hasMatch(app[lt + 4]);
    if (!boundary) {
      i = lt + 4;
      continue;
    }
    final gt = _tagEnd(app, lt); // 따옴표 안 `>`는 무시(attr 값 안전)
    if (gt < 0) break;
    final raw = app.substring(lt + 1, gt); // img src="…" alt="…"
    final sp = raw.indexOf(_wsRe);
    final attrs = <String, String>{};
    if (sp >= 0) _parseAttrs(raw.substring(sp + 1), attrs); // 쌍·단·무따옴표 3종
    i = gt + 1;
    final src = attrs['src'] ?? '';
    if (src.isEmpty) continue;
    n++;
    final alt = attrs['alt'] ?? '';
    final token = _uniqueToken(_camel('$slug-$n'), usedTokens);
    images.add(await _fetchOne(src, slug, n, token, alt, assetsDir, resolveBase: resolveBase));
  }
  return images;
}

/// 한 `<img>`의 src를 스킴별로 처리하고 manifest 엔트리를 만든다(fetch_images `_fetchOne` 국소 복제).
/// http(s)=다운로드(타임아웃 가드) / data:=인라인 디코드 / resolveBase 있음=로컬 파일 복사(상대경로)
/// / 그 외=skip. resolveBase: `.dc.html` 디렉터리의 절대 경로. 동적 `<img src={expr}>`는 skipped(fail-loud).
Future<Map<String, dynamic>> _fetchOne(
    String src, String slug, int n, String token, String alt, Directory assetsDir,
    {String? resolveBase}) async {
  String status;
  var ext = 'png';
  List<int>? bytes;

  if (src.startsWith('data:')) {
    final comma = src.indexOf(',');
    if (comma > 0) {
      final meta = src.substring(5, comma); // 예: image/png;base64
      final dataPart = src.substring(comma + 1);
      try {
        bytes = meta.contains('base64')
            ? base64.decode(dataPart.replaceAll(RegExp(r'\s'), '')) // 줄바꿈 낀 base64 허용
            : utf8.encode(Uri.decodeComponent(dataPart));
        ext = _extFromMime(meta) ?? _extFromMagic(bytes) ?? 'png';
        status = 'inline';
      } catch (_) {
        status = 'failed';
      }
    } else {
      status = 'failed';
    }
  } else if (src.startsWith('http://') || src.startsWith('https://')) {
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final req = await client.getUrl(Uri.parse(src)).timeout(_connectTimeout);
      final res = await req.close().timeout(_responseTimeout);
      if (res.statusCode == 200) {
        bytes = await _collect(res).timeout(_bodyTimeout);
        ext = _extFromMime(res.headers.contentType?.mimeType) ?? _extFromMagic(bytes) ?? 'png';
        status = 'ok';
      } else {
        status = 'failed';
      }
    } catch (_) {
      status = 'failed'; // 타임아웃(stall)·네트워크·파싱 — 전부 status로 표면화
    } finally {
      client.close(force: true);
    }
  } else if (resolveBase != null) {
    // 로컬 상대경로 — `.dc.html` 디렉터리 기준 해소(`--asset-base` 모드)
    if (src.startsWith('{')) {
      // 동적 표현식 `src={expr}`: 정적 해소 불가 → fail-loud(skipped)
      status = 'skipped';
    } else {
      try {
        // URI 해소: resolveBase/ + src (../ 정규화 자동)
        final resolvedPath = Uri.file('$resolveBase/').resolve(src).toFilePath();
        final localFile = File(resolvedPath);
        if (localFile.existsSync()) {
          bytes = localFile.readAsBytesSync();
          final dotIdx = resolvedPath.lastIndexOf('.');
          ext = _extFromMagic(bytes) ??
              (dotIdx >= 0 ? resolvedPath.substring(dotIdx + 1).toLowerCase() : 'png');
          status = 'ok';
        } else {
          status = 'failed'; // 파일 없음 → fail-loud
        }
      } catch (_) {
        status = 'failed';
      }
    }
  } else {
    status = 'skipped'; // 상대경로·file: 등 — 표면화(조용한 폴백 금지)
  }

  var localPath = '';
  if (bytes != null && (status == 'ok' || status == 'inline')) {
    final fname = '$slug-$n.$ext';
    localPath = 'assets/images/$fname';
    assetsDir.createSync(recursive: true);
    File('${assetsDir.path}/$fname').writeAsBytesSync(bytes);
  }

  return <String, dynamic>{
    'src': src,
    'alt': alt,
    'local_path': localPath,
    'token': token,
    'status': status,
  };
}

Future<List<int>> _collect(HttpClientResponse res) async {
  final b = <int>[];
  await for (final chunk in res) {
    b.addAll(chunk);
  }
  return b;
}

/// `<` 위치(lt)부터 짝 맞는 `>`까지 — 따옴표 안 `>`는 무시(fetch_images/extract_layout `_tagEnd` 동형).
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

/// 속성 파서 — 쌍·단·무따옴표 3종(fetch_images `_attrRe` 동형).
final _attrRe = RegExp('''([\\w:-]+)\\s*=\\s*("([^"]*)"|'([^']*)'|(\\S+))''');

void _parseAttrs(String s, Map<String, String> into) {
  for (final m in _attrRe.allMatches(s)) {
    into[m[1]!.toLowerCase()] = m[3] ?? m[4] ?? m[5] ?? '';
  }
}

/// 파일명 stem → camelCase Dart 식별자 (fetch_images `_camel` 동형).
String _camel(String s) {
  final words = s.split(RegExp(r'[^A-Za-z0-9]+')).where((String w) => w.isNotEmpty).toList();
  if (words.isEmpty) return 'a';
  final buf = StringBuffer();
  for (var i = 0; i < words.length; i++) {
    final w = words[i];
    buf.write(i == 0 ? w[0].toLowerCase() + w.substring(1) : w[0].toUpperCase() + w.substring(1));
  }
  final id = buf.toString();
  return RegExp(r'^[A-Za-z]').hasMatch(id) ? id : 'a$id'; // 숫자 시작 방어
}

/// 동일 token 충돌 시 `_<k>` suffix 점진 추가(fetch_images `_uniqueToken` 동형·결정론 dedup).
String _uniqueToken(String base, Set<String> used) {
  var t = base;
  var k = 2;
  while (used.contains(t)) {
    t = '${base}_$k';
    k++;
  }
  used.add(t);
  return t;
}

String? _extFromMime(String? mime) {
  if (mime == null) return null;
  final m = mime.toLowerCase();
  if (m.contains('png')) return 'png';
  if (m.contains('jpeg') || m.contains('jpg')) return 'jpg';
  if (m.contains('gif')) return 'gif';
  if (m.contains('webp')) return 'webp';
  if (m.contains('svg')) return 'svg';
  return null;
}

String? _extFromMagic(List<int> b) {
  if (b.length >= 4 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return 'png';
  if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return 'jpg';
  if (b.length >= 4 && b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) return 'gif';
  if (b.length >= 12 && b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) return 'webp';
  return null;
}

// ---- design-tokens.json RMW: icons[]·unmappedIcons만 주입(나머지 토큰군 보존) ----

/// design-tokens.json을 읽어 `icons`·`unmappedIcons`만 교체하고 다시 쓴다.
/// colors/spacing/typography/borderRadius/arbitraryValues/meta/negativeMargins는 입력 그대로 보존
/// (jsonDecode가 키 순서를 유지하므로 in-place 갱신). 부재·파싱실패·비객체면 fail-loud(exit 1).
void _rmwTokens(String tokensPath, List<Map<String, dynamic>> icons, List<String> unmapped) {
  final f = File(tokensPath);
  if (!f.existsSync()) {
    stderr.writeln('[extract-dc] design-tokens.json 부재: $tokensPath — extract_design 선행 누락(실행 순서 위반·MF-3).');
    exit(1);
  }
  dynamic doc;
  try {
    doc = jsonDecode(f.readAsStringSync());
  } catch (e) {
    stderr.writeln('[extract-dc] design-tokens.json 파싱 실패: $e — 동결본을 확인하라.');
    exit(1);
  }
  if (doc is! Map) {
    stderr.writeln('[extract-dc] design-tokens.json 최상위가 객체가 아니다 — 형태 오류.');
    exit(1);
  }
  final map = doc.cast<String, dynamic>();
  map['icons'] = icons; // 통째 덮어쓰기 금지 — icons/unmappedIcons만 교체
  map['unmappedIcons'] = unmapped;
  f.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(map)}\n');
}

// ---- icon_map(extract_design `_loadIconMap` 동형·읽기 전용) ----

Map<String, String> _loadIconMap(String? path) {
  if (path == null) return <String, String>{};
  final f = File(path);
  if (!f.existsSync()) {
    stderr.writeln('[extract-dc] icon-map 없음(매핑 생략): $path');
    return <String, String>{};
  }
  try {
    final doc = jsonDecode(f.readAsStringSync());
    final icons = doc is Map ? doc['icons'] : null;
    if (icons is Map) {
      return icons.map((dynamic k, dynamic v) => MapEntry(k.toString(), v.toString()));
    }
  } catch (e) {
    stderr.writeln('[extract-dc] icon-map 파싱 실패(매핑 생략): $e');
  }
  return <String, String>{};
}
