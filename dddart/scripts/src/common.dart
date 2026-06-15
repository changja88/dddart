/// dddart 백스톱 공통 기반 (설계: workspace/design/2026-06-12-backstop-design.md §4)
///
/// 파일 수집·주석/문자열 마스킹·import 파서(lib/ 루트 클램핑)·git 게이트(added/touched/
/// added 줄/신규 단위)·발견 모델·리포트. 검사 패밀리 4개가 전부 이 모듈 하나를 공유한다.
///
/// 경로 규약: lib/ 내부 파일은 **lib-상대 posix 경로**('application/chat/…')가 정본.
/// 표시할 때만 'lib/' 접두를 붙인다.
library;

import 'dart:io';

// ---------------------------------------------------------------- 발견 모델

class Finding {
  final String checkId;
  final String path; // lib-상대 (rootRel=true면 프로젝트 루트-상대)
  final int? line;
  final String message; // 위반 요지
  final String rule; // 제1 규약 조항
  final String fix; // 교정 안내
  final bool rootRel; // path가 lib/ 밖(pubspec.yaml 등) — 'lib/' 접두 생략
  Finding(this.checkId, this.path, this.line, this.message, this.rule, this.fix,
      {this.rootRel = false});

  @override
  String toString() {
    final prefix = rootRel ? '' : 'lib/';
    final loc = line == null ? '$prefix$path' : '$prefix$path:$line';
    return '[$checkId] BLOCKER — $loc\n  위반: $message ($rule)\n  교정: $fix';
  }
}

// ------------------------------------------------------------ 마스킹 스캐너

/// 한 파일의 세 가지 뷰.
/// - [noComments]: 주석만 공백으로 마스킹(개행 보존) — directive 파서용.
/// - [tokensView]: 주석 + 문자열 *내용*을 마스킹(따옴표 문자는 보존 — NM13의
///   "첫 인자가 문자열 리터럴" 판별에 필요) — 토큰 검사용.
class MaskedSource {
  final String original;
  final String noComments;
  final String tokensView;
  final List<int> lineStarts;
  MaskedSource(this.original, this.noComments, this.tokensView, this.lineStarts);

  int lineOf(int offset) {
    var lo = 0, hi = lineStarts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (lineStarts[mid] <= offset) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo + 1; // 1-based
  }
}

/// Dart 소스 상태 머신: 라인/블록 주석(중첩 지원 — Dart는 블록 주석 중첩 합법),
/// 문자열(단/이중/triple/raw)·보간(`${ … }` 안의 코드, 중첩 문자열 포함)을 추적한다.
/// 블록 주석 안의 `import '…';` 줄이 directive로 오인되는 것(적대 점검 P1),
/// 교정 주석 속 `BuildContext` 토큰이 재차 blocker가 되는 루프를 여기서 차단한다.
MaskedSource maskSource(String src) {
  final n = src.length;
  final isComment = List<bool>.filled(n, false);
  final isStrContent = List<bool>.filled(n, false);

  // 모드 스택 프레임: code(보간 깊이 추적) | string
  final frames = <_Frame>[_Frame.code()];
  var i = 0;
  while (i < n) {
    final f = frames.last;
    final c = src[i];
    if (f.kind == _FKind.code) {
      if (c == '/' && i + 1 < n && src[i + 1] == '/') {
        final start = i;
        while (i < n && src[i] != '\n') {
          i++;
        }
        for (var k = start; k < i; k++) {
          isComment[k] = true;
        }
        continue;
      }
      if (c == '/' && i + 1 < n && src[i + 1] == '*') {
        var depth = 1;
        final start = i;
        i += 2;
        while (i < n && depth > 0) {
          if (src[i] == '/' && i + 1 < n && src[i + 1] == '*') {
            depth++;
            i += 2;
          } else if (src[i] == '*' && i + 1 < n && src[i + 1] == '/') {
            depth--;
            i += 2;
          } else {
            i++;
          }
        }
        for (var k = start; k < i; k++) {
          isComment[k] = true;
        }
        continue;
      }
      if (c == "'" || c == '"') {
        final raw = i > 0 &&
            src[i - 1] == 'r' &&
            (i < 2 || !_isIdent(src.codeUnitAt(i - 2)));
        final triple = i + 2 < n && src[i + 1] == c && src[i + 2] == c;
        frames.add(_Frame.string(c, raw: raw, triple: triple));
        i += triple ? 3 : 1;
        continue;
      }
      if (f.inInterpolation) {
        if (c == '{') f.braceDepth++;
        if (c == '}') {
          if (f.braceDepth == 0) {
            frames.removeLast(); // 보간 종료 → 바깥 string으로 복귀
            i++;
            continue;
          }
          f.braceDepth--;
        }
      }
      i++;
      continue;
    }
    // string 모드
    final q = f.quote!;
    if (!f.raw && c == r'\' && i + 1 < n) {
      isStrContent[i] = true;
      isStrContent[i + 1] = true;
      i += 2;
      continue;
    }
    if (!f.raw && c == r'$' && i + 1 < n && src[i + 1] == '{') {
      isStrContent[i] = true;
      isStrContent[i + 1] = true;
      i += 2;
      frames.add(_Frame.code(inInterpolation: true));
      continue;
    }
    if (c == q) {
      if (f.triple) {
        if (i + 2 < n && src[i + 1] == q && src[i + 2] == q) {
          frames.removeLast();
          i += 3;
          continue;
        }
      } else {
        frames.removeLast();
        i++;
        continue;
      }
    }
    if (!f.triple && c == '\n') {
      // 비종결 문자열(문법 오류) 방어 — 줄 끝에서 강제 종료
      frames.removeLast();
      i++;
      continue;
    }
    isStrContent[i] = true;
    i++;
  }

  final noComments = StringBuffer();
  final tokensView = StringBuffer();
  final lineStarts = <int>[0];
  for (var k = 0; k < n; k++) {
    final c = src[k];
    if (c == '\n') lineStarts.add(k + 1);
    final keepNl = c == '\n' ? '\n' : ' ';
    noComments.write(isComment[k] ? keepNl : c);
    tokensView.write(isComment[k] || isStrContent[k] ? keepNl : c);
  }
  return MaskedSource(src, noComments.toString(), tokensView.toString(), lineStarts);
}

enum _FKind { code, string }

class _Frame {
  final _FKind kind;
  final String? quote;
  final bool raw;
  final bool triple;
  final bool inInterpolation;
  int braceDepth = 0;
  _Frame.code({this.inInterpolation = false})
      : kind = _FKind.code,
        quote = null,
        raw = false,
        triple = false;
  _Frame.string(this.quote, {required this.raw, required this.triple})
      : kind = _FKind.string,
        inInterpolation = false;
}

bool _isIdent(int cu) =>
    (cu >= 0x30 && cu <= 0x39) ||
    (cu >= 0x41 && cu <= 0x5a) ||
    (cu >= 0x61 && cu <= 0x7a) ||
    cu == 0x5f || // _
    cu == 0x24; // $

// ------------------------------------------------------------ import 파서

enum TargetType { internal, external, dartCore }

class ImportEdge {
  final String uri; // 원문 URI
  final TargetType type;
  final String? target; // internal일 때 lib-상대 정규화 경로
  final int line;
  ImportEdge(this.uri, this.type, this.target, this.line);
}

final _directiveRe = RegExp(r'(^|\n)[ \t]*(import|export|part)\b');
final _uriRe = RegExp('''r?['"]([^'"\\n]*)['"]''');

/// noComments 본문에서 import/export directive의 URI를 전부 수집한다.
/// part는 간선 비취급(§4-3 — `part of <라이브러리명>;`은 URI 0개로 무해).
/// 조건부 import(`if (…) '…'`)의 다중 URI는 각각 독립 간선.
List<ImportEdge> parseImports(MaskedSource ms, String importerLibRel, String pkg) {
  final edges = <ImportEdge>[];
  for (final m in _directiveRe.allMatches(ms.noComments)) {
    final kind = m.group(2)!;
    if (kind == 'part') continue;
    final end = ms.noComments.indexOf(';', m.end);
    if (end < 0) continue;
    final body = ms.noComments.substring(m.end, end);
    final line = ms.lineOf(m.start + (m.group(1)!.length));
    for (final um in _uriRe.allMatches(body)) {
      final uri = um.group(1)!;
      if (uri.isEmpty) continue;
      edges.add(_normalize(uri, importerLibRel, pkg, line));
    }
  }
  return edges;
}

/// 상대 URI 해소는 **lib/ 루트 클램핑** — Dart package URI 의미론과 동일하게
/// 잉여 `../`는 lib/에서 멈춘다(적대 점검 P0: 나이브 join은 lib/ 밖 경로를 만들어
/// IM 전 검사가 침묵하고, `../` 하나가 우회 벡터가 된다).
ImportEdge _normalize(String uri, String importerLibRel, String pkg, int line) {
  if (uri.startsWith('dart:')) return ImportEdge(uri, TargetType.dartCore, null, line);
  if (uri.startsWith('package:')) {
    final rest = uri.substring('package:'.length);
    final slash = rest.indexOf('/');
    if (slash <= 0) return ImportEdge(uri, TargetType.external, null, line);
    final name = rest.substring(0, slash);
    if (name == pkg) {
      return ImportEdge(uri, TargetType.internal, _clampSegs(rest.substring(slash + 1).split('/'), const []), line);
    }
    return ImportEdge(uri, TargetType.external, null, line);
  }
  final base = importerLibRel.split('/')..removeLast();
  return ImportEdge(uri, TargetType.internal, _clampSegs(uri.split('/'), base), line);
}

String _clampSegs(List<String> segs, List<String> base) {
  final out = List<String>.from(base);
  for (final s in segs) {
    if (s == '' || s == '.') continue;
    if (s == '..') {
      if (out.isNotEmpty) out.removeLast(); // lib/ 루트에서 클램핑
    } else {
      out.add(s);
    }
  }
  return out.join('/');
}

// ------------------------------------------------------------ 경로 술어

List<String> segsOf(String libRel) => libRel.split('/');

String baseNameOf(String libRel) => libRel.substring(libRel.lastIndexOf('/') + 1);

/// 세그먼트 정확 일치 — `/view/`가 `view_model/`·`overview/`에 비매칭(§4-5).
bool hasSeg(String libRel, String seg) => segsOf(libRel).contains(seg);

/// BC 판별 — `lib/application/` 다음 경로 성분 비교(접두 문자열 비교 금지:
/// `chat`이 `chat_request`를 자기 BC로 오인 — §4-5).
String? bcOf(String libRel) {
  final s = segsOf(libRel);
  return (s.length > 1 && s.first == 'application') ? s[1] : null;
}

/// 직계 부모 디렉터리명.
String parentDirOf(String libRel) {
  final s = segsOf(libRel);
  return s.length >= 2 ? s[s.length - 2] : '';
}

String casefold(String s) => s.toLowerCase().replaceAll('_', '');

// 종류 폴더 화이트리스트 (제1 규약 §5)
const appKinds = {'use_case', 'view_model', 'state', 'shared_state', 'service'};
const infraKinds = {'data_source', 'repository', 'service'};
const presKinds = {'view', 'section', 'widget', 'ui_extension'};
const domainKinds = {'entity', 'value_object', 'enum', 'domain_service', 'specification'};
const layerNames = {'domain_layer', 'application_layer', 'infra_layer', 'presentation_layer'};

// ------------------------------------------------------------ 컨텍스트(게이트)

class BackstopContext {
  final Directory root; // 대상 프로젝트 루트
  final String packageName;
  final bool gitRepo;
  final String? diffBase;
  final bool allMode;
  final List<String> dartFiles; // lib-상대, 제외 규칙 적용 후
  final Set<String> allDirs; // lib-상대 디렉터리 전체
  final Set<String> touched;
  final Set<String> added;
  final Set<String> baseFiles; // diff-base 시점의 lib-상대 파일 (ls-tree)
  final Map<String, List<(int, int)>> _addedSpans; // 수정 파일의 + 줄 범위
  final List<String> notices = [];
  final Map<String, MaskedSource> _maskCache = {};
  final Map<String, List<ImportEdge>> _edgeCache = {};

  BackstopContext._(this.root, this.packageName, this.gitRepo, this.diffBase,
      this.allMode, this.dartFiles, this.allDirs, this.touched, this.added,
      this.baseFiles, this._addedSpans);

  /// 게이트가 살아 있는가 (비git·--all이면 전역 퇴화).
  bool get gated => gitRepo && diffBase != null && !allMode;

  /// 신규 단위 판별 가능 여부 (ls-tree 기준점 필요 — §3).
  bool get canDetectNewUnits => gitRepo && diffBase != null;

  bool isAdded(String f) => !gated || added.contains(f);
  bool isTouched(String f) => !gated || touched.contains(f);

  /// added 디렉터리 = diff-base에 그 경로 하위 파일이 0개(§3 — added 파일 포함
  /// 여부가 아님: 레거시 폴더에 새 파일을 넣어도 그 폴더는 added가 아니다).
  bool isAddedDir(String dir) {
    if (!gated) return true;
    final prefix = '$dir/';
    return !baseFiles.any((f) => f.startsWith(prefix));
  }

  /// IM 게이트 — touched 파일의 added 줄(§3). 미추적/신규 파일은 전 줄.
  bool lineIsAdded(String f, int line) {
    if (!gated) return true;
    if (added.contains(f)) return true;
    final spans = _addedSpans[f];
    if (spans == null) return false;
    return spans.any((s) => line >= s.$1 && line <= s.$2);
  }

  MaskedSource maskOf(String f) =>
      _maskCache[f] ??= maskSource(File('${root.path}/lib/$f').readAsStringSync());

  List<ImportEdge> edgesOf(String f) =>
      _edgeCache[f] ??= parseImports(maskOf(f), f, packageName);

  static BackstopContext build({
    required Directory root,
    required String? diffBase,
    required bool allMode,
  }) {
    final pubspec = File('${root.path}/pubspec.yaml');
    final libDir = Directory('${root.path}/lib');
    if (!pubspec.existsSync() || !libDir.existsSync()) {
      stderr.writeln('[backstop] 사용 오류: pubspec.yaml 또는 lib/ 없음 — ${root.path}');
      exit(1);
    }
    final nameMatch = RegExp(r'^name:\s*(\S+)', multiLine: true)
        .firstMatch(pubspec.readAsStringSync());
    final pkg = nameMatch?.group(1) ?? '';

    // lib 순회
    final files = <String>[];
    final dirs = <String>{};
    final prefixLen = libDir.path.length + 1;
    for (final e in libDir.listSync(recursive: true, followLinks: false)) {
      final rel = e.path.substring(prefixLen).replaceAll(r'\', '/');
      if (e is Directory) {
        dirs.add(rel);
      } else if (e is File && rel.endsWith('.dart')) {
        if (rel.endsWith('.g.dart') || rel.endsWith('.freezed.dart')) continue;
        if (rel == 'firebase_options.dart') continue; // flutterfire 생성물(§4-1)
        files.add(rel);
      }
    }
    files.sort();

    final gitRepo = _git(root, ['rev-parse', '--is-inside-work-tree']) == 'true';
    var touched = <String>{};
    var added = <String>{};
    var baseFiles = <String>{};
    final addedSpans = <String, List<(int, int)>>{};

    if (gitRepo) {
      final repoTop = _git(root, ['rev-parse', '--show-toplevel'])!;
      final rootAbs = root.resolveSymbolicLinksSync();
      var repoPrefix = rootAbs == repoTop ? '' : rootAbs.substring(repoTop.length + 1).replaceAll(r'\', '/');
      if (repoPrefix.isNotEmpty) repoPrefix = '$repoPrefix/';
      String? toLibRel(String repoPath) {
        if (!repoPath.startsWith(repoPrefix)) return null;
        final p = repoPath.substring(repoPrefix.length);
        return p.startsWith('lib/') ? p.substring(4) : null;
      }

      if (diffBase != null) {
        // 1) diff: 작업 트리 vs 기준점 (미커밋 포함, -z NUL 구분 — §3)
        final diffOut = _gitRaw(root, ['diff', '--name-status', '-z', diffBase]);
        if (diffOut == null) {
          stderr.writeln('[backstop] 사용 오류: --diff-base $diffBase 해석 불가');
          exit(1);
        }
        final tok = diffOut.split('\x00');
        for (var i = 0; i < tok.length - 1;) {
          final st = tok[i];
          if (st.isEmpty) {
            i++;
            continue;
          }
          if (st.startsWith('R') || st.startsWith('C')) {
            // old, new 두 필드 — 새 경로만 added/touched(old는 비현존 취급)
            final newPath = i + 2 < tok.length ? tok[i + 2] : null;
            final lr = newPath == null ? null : toLibRel(newPath);
            if (lr != null) {
              touched.add(lr);
              added.add(lr);
            }
            i += 3;
            continue;
          }
          final path = i + 1 < tok.length ? tok[i + 1] : null;
          final lr = path == null ? null : toLibRel(path);
          if (lr != null && st[0] != 'D') {
            touched.add(lr);
            if (st[0] == 'A') added.add(lr);
          }
          i += 2;
        }
        // 2) porcelain — 미추적 파일(-uall 필수: 기본값은 신규 디렉터리를 한 줄로 접어
        //    신규 BC 전체가 누락된다 — 적대 점검 P0)
        final pOut = _gitRaw(root, ['status', '--porcelain', '-z', '--untracked-files=all']) ?? '';
        final pt = pOut.split('\x00');
        for (var i = 0; i < pt.length;) {
          final entry = pt[i];
          if (entry.length < 4) {
            i++;
            continue;
          }
          final xy = entry.substring(0, 2);
          final path = entry.substring(3);
          final lr = toLibRel(path);
          final isRename = xy[0] == 'R' || xy[0] == 'C';
          if (lr != null && !xy.contains('D')) {
            touched.add(lr);
            if (xy == '??' || xy[0] == 'A' || isRename) added.add(lr);
          }
          i += isRename ? 2 : 1; // 리네임은 다음 필드가 old 경로
        }
        // 3) 기준점 트리 (added 디렉터리·신규 단위 판별)
        final ls = _gitRaw(root, ['ls-tree', '-r', '--name-only', '-z', diffBase]) ?? '';
        for (final p in ls.split('\x00')) {
          final lr = toLibRel(p);
          if (lr != null) baseFiles.add(lr);
        }
        // 4) 수정 파일의 added 줄 범위 (IM 게이트 — §3)
        for (final f in touched.where((f) => !added.contains(f))) {
          // pathspec은 -C(=대상 루트) 기준 — repo 접두를 붙이지 않는다
          final d = _gitRaw(root, ['diff', '-U0', diffBase, '--', 'lib/$f']) ?? '';
          final spans = <(int, int)>[];
          for (final m in RegExp(r'^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@', multiLine: true).allMatches(d)) {
            final start = int.parse(m.group(1)!);
            final len = m.group(2) == null ? 1 : int.parse(m.group(2)!);
            if (len > 0) spans.add((start, start + len - 1));
          }
          addedSpans[f] = spans;
        }
      }
    }

    return BackstopContext._(root, pkg, gitRepo, diffBase, allMode, files, dirs,
        touched, added, baseFiles, addedSpans);
  }
}

String? _git(Directory root, List<String> args) => _gitRaw(root, args)?.trim();

String? _gitRaw(Directory root, List<String> args) {
  final r = Process.runSync('git', ['-C', root.path, ...args]);
  if (r.exitCode != 0) return null;
  return r.stdout as String;
}

// ------------------------------------------------------------ 토큰 스캔 보조

/// tokensView에서 정규식 매치를 찾아 (line, 매치 끝 오프셋) 목록 반환.
List<(int line, int end)> scanTokens(MaskedSource ms, RegExp re) =>
    [for (final m in re.allMatches(ms.tokensView)) (ms.lineOf(m.start), m.end)];

/// 호출 괄호의 첫 인자를 균형 스캔으로 추출(§4-6 — 멀티라인 호출 대응).
/// [openParenEnd]는 여는 괄호 *다음* 오프셋.
String firstArgOf(String text, int openParenEnd) {
  var depth = 0;
  final buf = StringBuffer();
  for (var i = openParenEnd; i < text.length && buf.length < 400; i++) {
    final c = text[i];
    if (c == '(' || c == '[' || c == '{') depth++;
    if (c == ')' || c == ']' || c == '}') {
      if (depth == 0) break;
      depth--;
    }
    if (c == ',' && depth == 0) break;
    buf.write(c);
  }
  return buf.toString().trim();
}
