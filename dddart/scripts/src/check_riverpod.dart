/// dddart 백스톱 — riverpod 정책 검사 (RV family)
///
/// RV1: 앱 루트 합성(main.dart류)에 **전역 자동재시도 OFF**가 있는가 —
///   `ProviderScope(...)` 또는 `ProviderContainer(...)` 호출 인자에 `retry:` 존재.
///   riverpod 3.x는 실패 provider를 기본 자동재시도(최대 10회)하므로 dddart는 전역 OFF가
///   확정 결정이다(implementation-riverpod §8). 7차 claude가 재구조화 중 이 1줄을 드롭(회귀)했고
///   산문만으로는 못 막았다 → 기계 floor.
///
/// 설계 근거·적대 2차 정정: workspace/eval/fix/feedback-010-navseam-weaksweep-determinism.md 항목 2.
///   - 새 family `RV`(검사ID `ST8`은 check_structure가 점유 — 충돌 회피).
///   - 거짓-FAIL 반증: `ProviderScope(retry:)`뿐 아니라 **`ProviderContainer(retry:)`
///     + `UncontrolledProviderScope` 변종**(5차 claude 실표본)도 통과해야 한다 → retry: 인자를
///     ProviderScope·ProviderContainer *양쪽* 호출 span에서 본다(positive-control: test/run_fixtures.sh F14).
library;

import 'common.dart';

final _composerRe = RegExp(r'\b(ProviderScope|ProviderContainer)\s*\(');
final _retryArgRe = RegExp(r'\bretry\s*:');

/// 호출 여는 괄호 다음부터 짝 괄호까지의 인자 텍스트(균형 스캔).
String _balancedArgs(String text, int openParenEnd) {
  var depth = 0;
  final buf = StringBuffer();
  for (var i = openParenEnd; i < text.length; i++) {
    final c = text[i];
    if (c == '(' || c == '[' || c == '{') {
      depth++;
    } else if (c == ')' || c == ']' || c == '}') {
      if (depth == 0) break;
      depth--;
    }
    buf.write(c);
  }
  return buf.toString();
}

/// 합성 소스에 전역 retry-OFF가 있는가 — ProviderScope/ProviderContainer 호출 인자에
/// `retry:` 가 있으면 true. **순수 함수**(positive-control 단위검증·재사용용).
/// `UncontrolledProviderScope`는 자체로 합성 트리거가 아니나, 그 짝 `ProviderContainer(retry:)`가
/// 매치되므로 5차 변종도 true가 된다.
bool sourceHasGlobalRetryOff(String source) {
  final src = maskSource(source).noComments;
  for (final m in _composerRe.allMatches(src)) {
    if (_retryArgRe.hasMatch(_balancedArgs(src, m.end))) return true;
  }
  return false;
}

/// 합성 호출(ProviderScope/ProviderContainer)이 하나라도 있는가 — N/A 판별(순수).
bool sourceHasComposition(String source) =>
    _composerRe.hasMatch(maskSource(source).noComments);

/// RV family 러너 — RV1.
List<Finding> runRiverpod(BackstopContext ctx) {
  final out = <Finding>[];

  // 루트 합성을 가진 touched 파일을 찾는다(보통 main.dart). 합성이 0개면 N/A —
  // 앱 루트 합성이 없는 변경(BC 단독 슬라이스 등)은 발화하지 않는다(positive-control notice BC).
  (String, int)? firstComposer;
  var anyRetry = false;
  for (final f in ctx.dartFiles) {
    if (!ctx.isTouched(f)) continue;
    final src = ctx.maskOf(f).noComments;
    for (final m in _composerRe.allMatches(src)) {
      firstComposer ??= (f, ctx.maskOf(f).lineOf(m.start));
      if (_retryArgRe.hasMatch(_balancedArgs(src, m.end))) anyRetry = true;
    }
  }
  if (firstComposer == null) return out; // N/A — 루트 합성 없음
  if (anyRetry) return out; // 전역 OFF 존재(ProviderScope·Container·Uncontrolled 변종 무관)

  final (file, line) = firstComposer;
  out.add(Finding(
    'RV1',
    file,
    line,
    '루트 합성에 전역 자동재시도 OFF 부재 — ProviderScope/ProviderContainer에 retry: 인자 없음',
    'riverpod §8 — 자동 재시도 전역 OFF(확정 실패는 즉시 에러 채널·서버 반복호출 차단)',
    'runApp의 ProviderScope(또는 ProviderContainer)에 retry: (_, __) => null 추가. 특수 화면만 @Riverpod(retry:)로 opt-in.',
  ));
  return out;
}
