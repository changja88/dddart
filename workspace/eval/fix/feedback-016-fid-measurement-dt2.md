# fix 016 — DT-2 가드 + screenProbes green 강제 (FID 측정 봉합·사전등록형)

> 복사본. **핵심 = "예상효과"를 *고치기 전*에 박고, 다음 라이브런(15차) 결과지로 "실측"을 채워 대조.** image set-membership(작업 B)은 적대 검증 4결함 노출로 **별도 재설계 회차로 분리**(이 원장 밖).

## 메타
- **회차**: 016
- **트리거**: 14차 결과지 `results/20260622-1636-weather-{claude,codex,compare,graders-raw}.md` — ① DT-2 swap(claude 무가드 FAIL/codex 자발 가드 PASS·13차 역전·N=2) ② FID 게이트 6회 연속 미발동(screenProbes 미노출→A1 폴백→grep 거짓 PASS)
- **베이스 코퍼스**: `506e7ea` (시술 직전 HEAD)
- **시술 커밋**: `<미적용 — 사용자 승인 후 커밋>`
- **검증 런**: `results/<15차 라이브런>` (재라이브런 후 채움)
- **상태**: 적용·미커밋 (15차 검증대기)
- **선행 게이트**: 4렌즈 적대 검증 통과(작업 A 견고·Dart 시맨틱 실측 확증 / 작업 C render-smoke 위치 교정[`_support.dart`→별도 `render_smoke_test.dart`+isNotEmpty] / 작업 B 분리). plan `workspace/design/2026-06-22-fid-measurement-dt2-plan.md`.

## 교정 항목 (사전등록 표)

| # | 우선 | ① 대상 결함(dim) | ② 원인(뿌리·코퍼스 공백) | ③ 처방(파일·미러) | ④ **예상효과**(전→후) | ⑤ 시술커밋 | ⑥ 실측·판정 |
|---|---|---|---|---|---|---|---|
| 1 | 치명 | **DT-2** 단일출구 누수(14차 claude FAIL·codex PASS·N=2 swap) | safeApiCall 골든의 `on DioException` 절 *내부* `fromJson` throw를 형제 `on TypeError`·말미 catch-all이 못 잡고 `safeApiCall` 밖으로 샌다(Dart 시맨틱·실측 확증). 골든 자체 공백 + backstop은 `throw` 텍스트 검색뿐이라 무력(DT-2 검출 로직 0) | `architecture-data/references/final.md` :56 `fromJson` try/on Object 가드 + 산문 불변식(catch-all 근거) / `implementation-dart/references/final.md` :49 단서 1줄 / `corpus_mirror_sync.py --write`(소스+codex 3사본) | **DT-2: 15차 양 엔진 PASS**(claude FAIL→PASS·codex PASS 유지·404 봉투 불일치 누수 0·N=2 swap 종결) | (미적용) | (대기) |
| 2 | 치명(측정) | **FID 게이트 미발동** 6회(9~14차·screenProbes 미노출→A1 폴백→grep 대체 거짓 PASS) | coder가 screenProbes 미산출(**관측되지 않는 산출물은 강제 안 됨**). 원안 render-smoke를 헬퍼 `_support.dart`에 두면 `flutter test`가 `*_test.dart`만 수집해 미실행(적대 렌즈 3 BLOCKER) | `agents/coder.md`(+codex `dddart-coder/SKILL.md`) 필수산출: screenProbes + **별도 `render_smoke_test.dart`**(isNotEmpty + role별 `findsOneWidget`) / `implementation-test §7`(:135 산문 승격·:145 테스트 파일 예시·`--write` 3사본) / `implementation-test SKILL.md`(+codex) / `RUBRIC §H`(미노출=픽스처 흠) | **screenProbes: 15차 양 엔진 `_support.dart`+`render_smoke_test.dart` 노출·fid-gate exit≠3 실발동**(6회 A1 폴백 종결·FID-L1/L2 첫 자동 채점·빈 맵 도망 0) | (미적용) | (대기) |

- **②원인**: 둘 다 뿌리 = "결정적 체크가 green 경로에 없음". DT-2는 골든이 정규화기 2차 throw를 비워둠. screenProbes는 소비 단언이 *실행되는* 테스트 파일에 없음.
- **③처방·미러**: final.md 3종 = `--write` 자동(architecture-data·implementation-dart·implementation-test 3사본 in-sync 확인). `coder.md`·`SKILL.md` = 수동 codex 미러. `RUBRIC.md` = eval 단일.
- **④예상효과**: 측정 가능 dim 겨냥. DT-2 = safeApiCall 의미 레인(404 봉투 불일치 시뮬). screenProbes = `find render_smoke_test.dart`·`grep screenProbes`·`fid-gate.sh exit` 코드.

## 보류·분리 (이 원장 밖)
- **작업 B(image set-membership)**: 적대 렌즈 1이 패치 end-to-end로 4결함 재현(appbar/nav slot image 맹점=14차 동형·`extract._dominantType` Set dedup 비대칭[compare 1파일로 불가]·L2 image 제외+`_collapse` 은폐·repeat 형성 비대칭). 근본 = image가 area↔slot 레벨 비대칭 → screen `images:[]` 위치무관 정규화(4파일+스키마 동결변경) → **별도 brainstorming 회차**. image "측정" 보류 ≠ image "재현" 보류(육안 오라클[feedback-015]+생성측 feedback-016 담보).
- **fid-gate exit-3 *기계* BLOCKER 격상**(적대 렌즈 3 MAJOR): green 강제(1차 방어)가 작동하면 미노출 미발생 → RUBRIC 채점 정책 변경은 작업 B 측정 회차에서 검토. 이번엔 green 강제 + RUBRIC 산문(1·2차 방어)까지.

## 회차 요약 (다음 런 후)
- 예상 적중 **N/2** · 무효 **N** · ⚠️역효과/신규회귀 **N**
- **한 줄 결론**:
- ⚠️ N=1 인과 단정 금지 — "X 적용 후 Y 관찰(동시발생)"로 기록. DT-2 swap은 N=2라 양 엔진 PASS면 swap 종결로 판정 가능.
