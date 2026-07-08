/// TG — 행위검증 테스트 산출 1종 (feedback-006 Fix 1a). 게이트: 신규 BC(lib-side isAddedDir).
///
/// *왜 결정적 백스톱인가*: coder 산출이 green=analyze 신규0으로만 정의돼 행위검증 테스트가
/// 창발에 맡겨진다(claude=무테스트→FC-2·codex=정렬 사이트 부재로 vacuous). 신규 BC가 대응
/// `test/`에 행위 테스트를 *갖는가*는 골든 무관·입력 불변의 기계 사실이다.
/// 신규 BC 판별은 lib-side isAddedDir(유효 게이트)·test/ 검사는 File I/O(ST4 _skeleton과 동일
/// 기법 — lib-상대 정본 불변식 불침해). test/ 파일엔 NM/import 규약을 적용하지 않는다.
/// 한계(정직): 테스트 *존재*는 결정적이나 *비-vacuity*(행위를 진짜 두드림)는 미보장 —
/// 그건 coder 책무(행위당 깨지면-red 테스트)+discipline-reviewer 의미감사의 분업이다.
library;

import 'dart:io';

import 'common.dart';

const _ruleTg = 'feedback-006 §A — coder 행위검증 테스트 산출(green=flutter test)';

List<Finding> runTests(BackstopContext ctx) {
  final out = <Finding>[];
  if (!ctx.canDetectNewUnits) {
    ctx.notices.add('[info] TG(행위테스트) 생략 — git 기준점 없음(신규 BC 판별 불가, §3)');
    return out;
  }
  final testRoot = '${ctx.root.path}/test';

  for (final d in ctx.allDirs) {
    final s = segsOf(d);
    // BC = `application/<bc>` 또는 `application/<area>/<bc>`(feedback-031) —
    // test/는 lib/ 1:1 미러라 area 경로를 그대로 따른다.
    final isBc = s[0] == 'application' &&
        ((s.length == 2 && !ctx.areas.contains(s[1])) ||
            (s.length == 3 && ctx.areas.contains(s[1])));
    if (!(isBc && ctx.isAddedDir(d))) continue;
    final bc = s.last;
    final bcTestDir = Directory('$testRoot/$d');
    final hasBehaviorTest = bcTestDir.existsSync() &&
        bcTestDir
            .listSync(recursive: true, followLinks: false)
            .any((e) => e is File && e.path.endsWith('_test.dart'));
    if (!hasBehaviorTest) {
      out.add(Finding('TG1', d, null,
          '신규 BC `$bc` 행위검증 테스트 부재 — `test/$d/`에 `*_test.dart` 0건. green 빌드가 비-vacuous 검증으로 안 이어진다(FC-2).',
          _ruleTg,
          '명세 행위목록 각 항목마다 그 행위를 두드리는(깨지면 red) widget/unit test를 `test/$d/<계층>/`에 산출한다(루트 widget_test.dart 스모크는 불충분).'));
    }
  }
  return out;
}
