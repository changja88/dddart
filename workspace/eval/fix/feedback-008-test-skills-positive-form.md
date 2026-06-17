# fix 008 — 테스트 스킬 신설 (positive FORM 가이드·비-vacuity/디코이) (사전등록형)

> 설계 문서: `workspace/design/2026-06-17-test-strategy-design.md`(검증 자료조사 + 적대 리뷰 2차 반영). **핵심 = 5차 양판 FC-2 vacuity·FC-1/3 색충돌을 positive FORM 가이드로 고치기 *전* 예상을 박고, 다음 라이브런으로 실측 대조.**
> ⚠️ **정직 표기**: 이 회차 비-vacuity floor는 *가이드+reviewer*(기계 보장 아님 — TG1 존재검사만 기계). FORM이 §7처럼 무시되면 다음 런이 1차 반증. 측정 dim 없는 항목(날짜 주입·스킬 신설)은 프로세스 관측/예방으로 표기. **새 백스톱 검사 0 → `_totalChecks` 55 불변.**

## 메타
- **회차**: 008
- **트리거**: 5차 양판(`results/20260616-2025-weather-{claude,codex}`)에서 양 엔진 FC-2(M1 순서·M3 위치·M4 탭날짜 vacuous)·FC-1/3(listColor clear=cloudy 충돌·codex는 디코이 테스트까지) FAIL. 근인 = 단언 FORM 부재 + §7 묻힘(coder 무시) + 비-vacuity 기계강제 부재. (연결·엔진 무관 — 양판 공통.)
- **베이스 코퍼스**: `d8de838`(feedback-007)
- **시술 커밋**: `<미커밋 — 코퍼스 작성 완료(2026-06-17)·사용자 커밋 대기>`
- **검증 런**: `<다음 라이브런(6차)·양판>`
- **상태**: **코퍼스 작성 완료(미커밋) — 6차 검증대기** (sync 11/11 in-sync·백스톱 픽스처 16/16 PASS·`_totalChecks` 55 불변)

## 교정 항목 (사전등록 — ①~④ 작성, 다음 런 후 ⑤~⑥)

| # | 우선 | ① 대상(거동·관측점) | ② 원인(뿌리) | ③ 처방(파일·미러) | ④ 예상효과(전→후·측정 dim) | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| 1 | 핵심 | FC-2 비-vacuity (M1 순서·M3 위치·M4 탭날짜 — mutation GREEN=헛) | FORM 부재 + §7 묻힘 + coder 선의 의존 | `discipline-test` 신설(§3 positive FORM: scrambled+`orderedEquals`+양끝 echo / keyed-slot+비대칭·음수 / `.at(2)`+날짜-echo+`descendant findsOneWidget`)·SKILL.md 본문 한 줄 게재·자가점검 의무·reviewer positive 감사 | 전: M1·M3·M4 mutation GREEN(헛) → 후: **시도** — M1·M3·M4 mutation RED(행위 포착). ⚠️*가이드라 기계 보장 아님·6차가 1차 반증* | ✅ `discipline-test` 신설(§3 4-FORM verbatim)·coder 산출 bullet에 FORM 직게재·reviewer 점검 #8 | 검증대기 |
| 2 | 핵심 | FC-1 G-7·FC-3 N4 (색 6 distinct) | 제한 팔레트 색 재사용 + 색 구별 단언 부재 + 판정단위 모호 | §3.1 `toSet().length==N` FORM + **색 *단독* N distinct로 단위 고정**(references) | 전: listColor 5/6(clear=cloudy) → 후: 색 단독 6 distinct. *toSet FORM은 색-단독 단위면 디코이-불가(작성 형태)·단 coder가 그 FORM을 **써야** 발동(가이드)* | ✅ discipline-test §3.1 `toSet().length==N` + "색 *단독* N-distinct 단위 고정" 명시 | 검증대기 |
| 3 | 권장 | 디코이 테스트(코더가 충돌·틀린 값을 "정답" 단언) | positive FORM 부재(coder 임의 형태) | positive FORM 기본값(예: 상세 subtree `findsOneWidget` → `findsWidgets`에 손 안 감)·reviewer positive 감사 | 전: codex M4 `findsWidgets` 흡수 디코이 → 후: 디코이 감소. *비기계(가이드+reviewer)·블랙리스트 안 씀(디코이 방법 열려있음·findsWidgets만의 문제 아님)* | ✅ positive FORM 기본값(§3.4 상세 subtree `findsOneWidget`)·reviewer #8 positive 감사 | 검증대기 |
| 4 | 프로세스 | 테스트 스킬 0 → 2종·§7 묻힘 | dddart 테스트 지식이 §7 한 조각뿐(implementation-flutter에 묻힘) | 스킬 2종 신설·§7 이전(인용 6사이트)·coder 로드·houserules test/ 규약·reviewer 렌즈 | 전: 테스트 지식 묻힘·미강제 → 후: **프로세스 관측**(전용 스킬 로드·test/ 미러 배치·discipline-test FORM 인용)·rubric dim 아님 | ✅ 스킬 2종 신설(각 3벌)·§7→포인터(6사이트)·coder/reviewer 로드·houserules §1/§3 test/·architecture-ui Key 짝 | 검증대기 |
| 5 | 예방 | 날짜 의존 테스트 flaky (수정 모드·pre-commit) | 도메인이 `DateTime.now()` 직호출 시 테스트 비결정 | 날짜 주입 규약(순수 함수·기준일 인자·테스트 고정 주입)·references 한 줄·**게이트 없음** | **측정 dim 0·반증 불가·예방적**(현 5차 코드 `DateTime.now()` 0회·정직 표기). 실제 now-쓰는 BC 런 등장 시 게이트 재고 | ✅ 날짜 주입 규약(discipline-test §1·implementation-test §5·architecture-ddd §5)·게이트 없음·clock 불필요 | 측정 dim 0(예방) |

- **②원인 공통**: 5차 = 코퍼스 §7에 positive 예시(scrambled→`orderedEquals`·"머릿속으로 깨봤을 때 red"·tap→`findsOneWidget`)가 *있었는데도* coder 무시 = 지식 결손 아닌 묻힘+선의 의존. feedback-008 = 전용 task-scoped 스킬 + "예시가 아니라 요구 형태"로 격상 + reviewer positive 감사. **단 기계 보장 아님(정직).**
- **③미러**: SKILL·agents 수동 양판 · `references/final.md`은 `corpus_mirror_sync.py` 자동 발견(claude↔codex byte-exact) · `run_fixtures.sh`=claude 전용(codex 미러 없음=기존 비대칭). **두 결정 다 백스톱 무변경(`_totalChecks` 55 불변·"55종" 산문 동기 불필요).**
- **④정직 표기(헛처방 조기경보)**: 항목 1·3은 *가이드*라 기계 보장 없음(6차 실측이 1차 반증). 항목 2 `toSet`은 색-단독 단위 한정 작성-형태 보장(사용 강제는 가이드). 항목 4는 프로세스 관측(rubric 비측정). 항목 5는 측정 dim 없는 예방(반증 불가·feedback-007 식 명시).

## 적대 리뷰 2차 반영 (5렌즈·~390k subagent tokens·설계문서 `## 적대 리뷰 2차`)
floor 과대표상 정정(기계는 §3.1 한정·나머지 가이드) · §3.1 색 단위 고정 · **백스톱 디코이-grep 채택 안 함**(블랙리스트 불완전·오탐·기성 lint 없음·DCM=타입오용/유료) · **시간 가드 철회**(0회 관측·게이트가 test/ 못 막음·측정 dim 0) · worklist 타깃 정정(file-tree→houserules·positive-control→run_fixtures·인용 6사이트·codex skills 산문 self-load) · Key 짝 규약 · 사전등록 선행 의무화.

## 시술 기록 (코퍼스 작성 — 2026-06-17·미커밋)

worklist 0~8 실행 완료(코퍼스 불변 방침 → 별도 사용자 승인 후 작성). **신규 10파일**(`discipline-test`·`implementation-test` 각 deploy/source/codex 3벌 + SKILL.md 양판) + **수정 22파일**(impl-flutter §7→포인터·coder·discipline-reviewer·houserules §1/§3·architecture-ui §3 Key 짝·architecture-ddd §5 날짜주입 — 각 deploy/codex/source 미러).

- **검증**: `corpus_mirror_sync.py` **11/11 in-sync**(신규 2종 포함·소스 본문 splice) · `run_fixtures.sh` **16/16 PASS**(백스톱 회귀 무손상) · 백스톱 `_totalChecks` **55 불변**(ST12+IM22+NM17+CY1+TG1+PJ2 — 새 기계검사 0) · 11개 지식 스킬 SKILL.md claude↔codex **byte-exact**.
- **미러 경로**: deploy 편집 → `--write`(소스·codex 동기) · SKILL.md/agents 수동 양판 · 신규 스킬은 deploy·source·codex 수동 생성 후 `--write`가 소스 본문 splice(자동 *발견*은 되나 자동 *생성*은 안 됨 — 설계 가정 실측 정정).
- **정직 표기(헛처방 경보)**: 이 회차는 *가이드+reviewer* floor(기계 보장은 §3.1 색-단독 toSet뿐). 6차 라이브런이 FORM 실효의 1차 반증.
- **휘발성 미검증 잔존**: `skills:` 프리로드가 SKILL.md 전문 주입인지 1차 출처 미확인 → **SKILL.md 본문에 FORM 4종 한 줄 직게재**로 헤지(coder 산출 bullet에도 FORM verbatim). codex는 frontmatter 자동주입 없음 → `dddart-coder`/`dddart-discipline-reviewer` 산문 "로드할 지식 스킬"에 2종 추가(self-load 의존 — 약한 고리는 reviewer/백스톱이 방어).
- **적대 리뷰 3차(코퍼스 작성 후·6렌즈·~607k subagent tokens)**: 미러/기술정확성/결정 I·II/4-FORM 충실도는 적대 검증 후에도 견고. **실제 결함 수정 9건** — 🔴(1) *테스트 격리 seam이 dddart no-DI와 모순* — `forecastRepoProvider.overrideWithValue`는 존재 불가(Repo·UseCase 직접생성·provider는 VM만·옛 §7 상속 버그)라 FORM이 컴파일 불가→coder가 못 따라 vacuity로 후퇴할 잠재 뿌리. **도메인 직접(§3.1/§3.2/§3.5) + VM provider override(§3.3/§3.4) + Dio 목(통합)** 모델로 재작성(impl-test §2/§3/§7 헬퍼 전면 교체). 🔴(2) §3.5 Either `Failure`→`BadRequestResponse`(코퍼스 표준 Left)·도메인 양갈래 직접으로 재구성. 🟡(3) §3.3 `contains('7')`→`formatTemp(7)` 정확 일치(부분문자열 오통과). (4) §3.4 fixture **≥3** 하드룰(`.at(2)` 전제). (5) "디코이-불가 4형" 과대선전→"§3.1만 형태-보장·나머지 가이드" 정직 라벨(SKILL 본문·§3 헤더·coder). (6) discipline-cleancode §17.1 "자동 테스트 비작성" stale 정합. 🟢(7) coder TG→TG1. (8) reviewer #8 test/-한정 1차 스캔 힌트(실효 강화·백스톱 아님). (9) §3.1 색-ui_extension 거주 reviewer 오판 방지 주. **재검증: 11/11·16/16·55 불변·구 seam 잔재 0.** (렌즈4 "차단력 불합격"은 *이미 정직 표기한 floor*의 재확인 — 결정 I이 §7-재판 위험 감수·6차 측정 후 승격을 선택.)

## 회차 요약 (검증 런 후 — 6차)
*(검증대기 — 다음 라이브런 후 작성)*

## 미해결 (검증·후속)
- **비-vacuity *기계* floor 부재(M1/M3/M4)** — 6차에서 디코이/vacuity 재발 시 custom_lint(AST·맥락 인식) 또는 작성자분리(`acceptance-tester`)로 승격(009 후보). mutation은 색엔 무용이나 M계열(정렬 비교·인덱스)엔 유효할 수 있어 009에서 "색 제외·M계열 한정" 재검토.
- `skills:` 프리로드 의미론(SKILL.md 전문 주입 여부) build 시 1차 출처 확인.
- 색 판정단위 골든/RUBRIC 명문화(grader A13·eval-side·테스트 스킬과 별도 트랙).
