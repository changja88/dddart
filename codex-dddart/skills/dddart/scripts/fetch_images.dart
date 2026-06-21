#!/usr/bin/env dart
/// fetch_images — Phase 0 동결 HTML의 모든 `<img>`를 빌드타임 다운로드 → assets/images + asset-manifest.json.
///
/// extract_design이 *토큰*(색·아이콘)을, extract_layout이 *구조*(area)를 절단하듯, 이 도구는 시안의
/// *이미지 바이트*를 앱 소스 `assets/images/`로 동결하고 src→local_path→token 매핑을
/// `asset-manifest.json`(단일 SSOT)으로 절단한다. **모든 `<img>` 전수** — area 일러스트뿐 아니라
/// section/slot 중첩 이미지(카드 썸네일·리스트 아바타)도 포함(layout-ir이 아니라 원본 HTML을 본다).
///
/// HTML 파싱은 **extract_layout과 동형인 따옴표 인식 토크나이저**(`_tagEnd`·`_attrRe`)를 쓴다 — 같은
/// `design-ref/*.html`을 보는 형제 도구와 동일한 `<img>` 집합을 보장한다(attr 값 안의 `>`·단따옴표 src도 안 흘림).
/// 토큰은 여기서 결정론 부여한다(coder는 매니페스트의 token을 베끼기만 — 파일명↔토큰 불일치 구조적 불가).
///
/// 사용: dart run fetch_images.dart <design-ref-dir> --assets-root <project-root> --out <asset-manifest.json>
/// 종료: 0=성공(부분 실패 허용 — status로 표면화) / 1=사용법·design-ref 부재.
library;

import 'dart:convert';
import 'dart:io';

const _connectTimeout = Duration(seconds: 15);
const _responseTimeout = Duration(seconds: 20);
const _bodyTimeout = Duration(seconds: 30);

Future<void> main(List<String> argv) async {
  String? dir;
  String? assetsRoot;
  String? outFile;
  for (var i = 0; i < argv.length; i++) {
    switch (argv[i]) {
      case '--assets-root':
        assetsRoot = argv[++i];
      case '--out':
        outFile = argv[++i];
      default:
        dir = argv[i];
    }
  }
  if (dir == null || assetsRoot == null || outFile == null) {
    stderr.writeln('사용: dart run fetch_images.dart <design-ref-dir> --assets-root <project-root> --out <asset-manifest.json>');
    exit(1);
  }
  final d = Directory(dir);
  if (!d.existsSync()) {
    stderr.writeln('[fetch-images] design-ref 디렉터리 없음: $dir');
    exit(1);
  }

  // design-ref/*.html을 파일명 정렬(결정론) — 같은 입력 → 같은 파일명·token.
  final htmls = d
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.toLowerCase().endsWith('.html'))
      .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));

  final images = <Map<String, dynamic>>[];
  final usedTokens = <String>{};
  final assetsDir = Directory('$assetsRoot/assets/images');

  for (final f in htmls) {
    final slug = f.uri.pathSegments.last.replaceAll(RegExp(r'\.html?$', caseSensitive: false), '');
    final html = f.readAsStringSync();
    final lower = html.toLowerCase();
    var n = 0;
    var i = 0;
    while (true) {
      final lt = lower.indexOf('<img', i);
      if (lt < 0) break;
      // `<img` 뒤가 단어문자면 `<image`·`<imgfoo` 등 다른 태그 — 건너뛴다(태그명 경계).
      final boundary = lt + 4 >= html.length || !RegExp(r'[A-Za-z0-9]').hasMatch(html[lt + 4]);
      if (!boundary) {
        i = lt + 4;
        continue;
      }
      final gt = _tagEnd(html, lt); // 따옴표 안 `>`는 무시(attr 값 안전)
      if (gt < 0) break;
      final raw = html.substring(lt + 1, gt); // 예: img src="…" alt="…"
      final sp = raw.indexOf(RegExp(r'\s'));
      final attrs = <String, String>{};
      if (sp >= 0) _parseAttrs(raw.substring(sp + 1), attrs); // 쌍·단·무따옴표 3종
      i = gt + 1;
      final src = attrs['src'] ?? '';
      if (src.isEmpty) continue;
      n++;
      final alt = attrs['alt'] ?? '';
      final token = _uniqueToken(_camel('$slug-$n'), usedTokens);
      images.add(await _fetchOne(src, slug, n, token, alt, assetsDir));
    }
  }

  File(outFile).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(<String, dynamic>{'images': images})}\n');

  int count(String s) => images.where((e) => e['status'] == s).length;
  stdout.writeln('[fetch-images] 이미지 ${images.length} '
      '(ok ${count('ok')}·failed ${count('failed')}·inline ${count('inline')}·skipped ${count('skipped')}) → $outFile');
}

/// 한 `<img>`의 src를 스킴별로 처리하고 manifest 엔트리를 만든다.
/// http(s)=다운로드(타임아웃 가드) / data:=인라인 디코드 / 그 외=skip(상대·file: — 다운로드 대상 아님).
Future<Map<String, dynamic>> _fetchOne(
    String src, String slug, int n, String token, String alt, Directory assetsDir) async {
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
      status = 'failed'; // 타임아웃(stall)·네트워크·파싱 — 전부 status로 표면화(§7 fail-fast)
    } finally {
      client.close(force: true);
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

/// `<` 위치(lt)부터 짝 맞는 `>`까지 — 따옴표 안 `>`는 무시(extract_layout `_tagEnd` 동형).
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

/// 속성 파서 — 쌍·단·무따옴표 3종(extract_layout `_attrRe` 동형).
final _attrRe = RegExp('''([\\w:-]+)\\s*=\\s*("([^"]*)"|'([^']*)'|(\\S+))''');

void _parseAttrs(String s, Map<String, String> into) {
  for (final m in _attrRe.allMatches(s)) {
    into[m[1]!.toLowerCase()] = m[3] ?? m[4] ?? m[5] ?? '';
  }
}

/// 파일명 stem → camelCase Dart 식별자 (flutter_gen 변환 동형·무의존 정규식).
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

/// 동일 token 충돌 시 `_<k>` suffix 점진 추가(결정론 dedup).
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
