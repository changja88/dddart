# feedback-031 — application/<area>/<bc> opt-in 그루핑 + 접두 승격 질문

## 메타
- **회차**: 031
- **트리거**: 결과지 아님 — 사용자 지시(2026-07-08 세션). 관찰 근거: `~/Desktop/broccoli_app` — 9 BC 중 `parent_*` 3·`child_*` 2가 역할 축을 이름 접두로 인코딩, `root_router.dart:41-45`가 부모/자녀 셸 분기. 평면 트리가 표현 못 하는 차원을 접두가 짊어짐.
- **베이스 코퍼스**: `e66b08e` (v1.0.4)
- **시술 커밋**: `b746d02`
- **검증 런**: (다음 라이브런 결과지 — area 시나리오 포함 런)
- **상태**: 적용됨 / 검증대기 — 결정적 측정분(F22~F25 PASS·F1~F21 무회귀·미러 3면 11/11·양판 drift 0)은 시술 시점 확인, 라이브런 dim(HR-1 area·G0 질문)은 다음 런 대기

## 계약 (사용자 합의 — 2026-07-08 · 리뷰 반영판)

**area = 순전히 사람의 시각적 도움을 위한 네임스페이스**(사용자 표현 그대로). 이 한 문장에서 전 규칙이 도출된다:

1. **기본은 기존 평면**(`application/<bc>/`) — area는 opt-in. G0에서 사용자가 명시 판정할 때만. 에이전트가 자동 추론으로 만들지 않는다.
2. **area는 순수 그루핑 폴더**: 직속은 BC 폴더만(파일 금지·`analysis_options.yaml` 금지·빈 area 금지), 중첩 1단만(`application/<area>/<bc>/`가 최대 깊이). **area·BC 이름에 4계층명(`*_layer` 4종)·4컨테이너명(root·application·common·design_system) 금지**(판별 오염 차단 — ST7 deny 확장과 동형).
3. **BC 이름은 앱 전역 유일 유지**(접두 유지 — 예: `application/<area>/<area>_<개념>/`). area는 어떤 식별자·클래스명·라우트 name·파일명에도 등장하지 않는다. **test/는 lib/ 1:1 미러 유지 — area 경로 포함**(`test/application/<area>/<bc>/…`). **리트머스**: area 폴더를 지워 평면으로 되돌려도 바뀌는 것은 *경로*뿐이다 — lib·test 미러의 디렉터리 위치와 import 문. 식별자·클래스명·라우트 name·파일명·코드 동작은 불변. (근거: Dart는 패키지 네임스페이스가 없어 접두를 폴더로 대체하면 클래스·라우트가 전역 충돌 — area는 접두의 *대체*가 아니라 접두 *위의* 그루핑이다.)
4. **접두→area 승격은 "감지는 규칙·결정은 사람·이동은 명시 호출" 3분할**:
   - **감지(Coordinator 산문 절차의 기계 명세 — G0 한정)**: ⑴ 접두 = BC명의 첫 `_` 앞 토큰(`_` 없으면 BC명 전체). ⑵ G0 배너 직전(기존 `ls -d .dddart/*/` 조회와 동렬) `ls lib/application/`로 기존 BC 목록을 얻는다(기존 area 내부 BC 포함). ⑶ `.dddart/config.json`의 `area_prefixes`에 기판정 접두는 스킵. ⑷ 발화 조건: 이번 스코프가 신규 BC를 만들 수 있음(배치 질문 ①/③ 경로) ∧ 미판정 동일 접두 그룹(2개+) 존재. 신규 BC *이름*은 G1에서 architect가 정하므로 "기존 1개+신규가 2개째" 경로는 이번 런 불발 — **의도된 1런 지연**(다음 런 G0에서 감지·자기치유). 오탐(`chat`/`chat_request`류 개념 접두)은 기계가 아니라 사람 판정이 거른다. **백스톱 러너(전부 blocker·일괄 반송)에는 넣지 않는다.**
   - **질문(G0 배너 합류)**: 선택지 ⓐ area로 묶기(이후 이 접두 신규 BC는 `application/<접두>/` 안에 — 기존 BC는 이동 전까지 혼재 상태임을 문구에 명시) / ⓑ 평면 유지(이 접두는 도메인 어휘 — 재질문 안 함). 기존 BC 일괄 이동은 파이프라인 스코프 밖 — 별도 명시 요청 안내 1줄(식별자 무변경·경로만 변경이라 저위험). 이번 라운드는 이동 실행기를 만들지 않는다(YAGNI). **혼재 감지 시**(area 존재 ∧ 동일 접두 평면 BC 잔존) G0 배너에 비차단 advisory 1줄 재표면화.
5. **판정 영속화**: `.dddart/config.json`에 `area_prefixes: {"<접두>": "area" | "not-area"}`. **`area` 판정도 기록한다**(승인 런에 해당 접두 BC가 안 생기면 폴더가 없어 기록이 증발하므로 — 폴더 존재에 의존하지 않는다). `not-area`는 *자동 감지의 재질문만* 억제 — 사용자 명시 선언은 항상 우선.

## 러너 판별 규칙 (리뷰 반영 확정판)

**area는 적극 증명될 때만 인정 — 그 외 전부 보수 폴백(현행 동작).**

- `application/` 직속 `<x>`가 **area인 조건**: `<x>` 직속 항목이 전부 디렉터리이고, **그 각각이** `layerNames`(정확 4개 집합 — 글롭 아님) 중 하나 이상을 직속 보유(=BC꼴).
- 그 외 전부(4계층 0개 레거시 drift BC·`application/` 직속 파일·비정상 깊이·비존재 import 타깃)는 **기존과 동일하게 `s[1]`=BC**. 레거시·브라운필드·무게이트 검사(CY1 전역·베이스라인 BC명 키, IM 분류)가 전부 현행 동작으로 수렴 — F1~F20 무회귀가 구조적으로 보장된다.
- 신규 골격은 ST4가 4계층 완비를 강제하므로 신규 기준 항상 결정 가능.

## 교정 항목 (사전등록 표 — 고치기 전 ①~④, 다음 런 후 ⑤~⑥)

| # | 우선 | ① 대상 결함(dim·FC골든) | ② 원인(뿌리·코퍼스 어느 책무 공백) | ③ 처방(어느 코퍼스 파일·미러경로) | ④ **예상효과**(전→후) | ⑤ 시술커밋 | ⑥ 실측·판정 |
|---|---|---|---|---|---|---|---|
| 1 | P1 | 표준 트리에 BC 그루핑 차원이 없어 다중 역할 앱(broccoli류 아키타입 — 부모/자녀·구매자/판매자·기사/승객)에서 역할 축이 이름 접두로만 존재 — 측정 dim 없음(기능 확장·예방적) | final.md §1이 `application/` 직속=BC만을 유일 형태로 고정 — "여러 BC를 사람 눈에 묶어 보여줄 자리" 책무 부재 | **배포본 먼저 손편집**(feedback-006 확립 절차): `dddart/skills/discipline-houserules/references/final.md` §1·§2·§3·§7·**§8(17종→18종)** → `corpus_mirror_sync.py --write`(배포→소스·codex 동기) → `--check` 0 drift | 다음 런에서 area 선언 시 HR-1이 `application/<area>/<bc>/`를 표준으로 인정. 평면 프로젝트 무영향(opt-in) | `b746d02` — §2는 무변경(정합 감사: BC 내부 성장 규칙이라 area 무관·정당 no-op) | (라이브런 대기) |
| 2 | P1 | 러너가 area 경로를 위반으로 오발화(ST1·ST2·ST3·ST4·TG1 깊이 고정) — 결정적 측정: 신규 픽스처 F22~F25 | `common.dart bcOf()`가 `s[1]` 고정 — BC 식별에 "경로 구조" 개념 부재 | `dddart/scripts/src/common.dart`(bcOf 보수 폴백 판별)·`check_structure.dart`·`check_tests.dart`(TG1 — test/ area 미러)·`check_imports.dart`·`check_naming.dart`·`check_models.dart`·**`check_cycles.dart`**(bcOf 호출부) → **codex `scripts/src/`(+`backstop.dart` 변경 시) 기계적 cp 동기**(byte-identical 미러 실측 확인) | F22(area BC 골격·TG1)·F23(area 교차 import 4채널)·F24(area 위반 — 직속 파일·중첩·빈 area·이름 deny)·F25(레거시 drift BC 보수 폴백 — canonical 층 0개 + CY 베이스라인) PASS + F1~F21 무회귀 | `b746d02`+감사 보강 커밋 — `check_models.dart`·`backstop.dart`는 무변경(정합 감사: 끝-상대 판별·경로 무의존이라 정당 no-op) | 시술 시점 실측: 픽스처 46/46 PASS·F1~F21 무회귀 ✓ |
| 3 | P1 | 접두 그룹이 생겨도 파이프라인이 감지·질문하지 않아 area가 사실상 도달 불가 — 측정 dim 없음(기능 확장) | `commands/dddart.md` G0에 BC *배치* 질문은 있으나 BC *그루핑* 질문 부재 · config.json에 판정 기록 자리 부재 | `dddart/commands/dddart.md` G0 배너(§Phase 0 step 5 — 계약 4의 기계 명세 그대로)·config.json 절(키 2→3 — "출처 주소만 저장" 불변식 문장 동반 개작) — claude 전용 | 다음 런(신규 BC 가능 + 기존 동일 접두 존재)에서 G0 배너에 그루핑 질문 표면화·config에 판정 기록·재런 시 재질문 없음 | `b746d02` | (라이브런 대기) |
| 4 | P2 | "접두가 area인가 도메인 어휘인가" 판별의 소유자 미배정 — 오탐(개념 접두) 방어 부재 | undecidable.md 17종에 BC 그루핑 판별 부재 | `dddart/skills/discipline-houserules/references/undecidable.md` §13 신설 + 배정표 1행 + **1·5행 "17종"→18종** — 양판 미러(codex 동일 파일 cp, byte-identical 실측) | 판별 절차·신호·반례(`chat_request`)가 문서화되어 Coordinator·architect·reviewer가 같은 기준 참조 | `b746d02` | (라이브런 대기) |
| 5 | P2 | SKILL.md §1·§3이 area를 모름(배치 결정 순서·레드 플래그·**25·65행 "17종"**) + architect/coder/reviewer가 area 경로 취급 규칙 없음 | 산문 규약이 트리 사실(final.md)만 따라가는 구조 — 신규 사실 미반영 | `dddart/skills/discipline-houserules/SKILL.md`(양판 미러 cp) + `agents/design-architect.md`·`agents/coder.md`·`agents/discipline-reviewer.md`(claude 전용 — codex agents 산문은 의도 분기·별도 라운드) | coder가 명세의 area 경로를 그대로 생성(자의 해석 0)·reviewer가 area 규칙 감사 가능 | `b746d02` | (라이브런 대기) |
| 6 | P2 | **architecture-ddd final.md 4곳(:30·:45·:222·:230)이 "BC = `application/<bc>/`"로 물리 형태 고정** — houserules만 고치면 design-review-ddd가 area 경로를 배치 위반으로 지적하는 스킬 간 모순(코퍼스 리뷰 F-2) | 선조사가 houserules final.md만 보고 멈춤 — BC 물리 형태 서술이 두 스킬에 분산 | **배포본 먼저 손편집**: `dddart/skills/architecture-ddd/references/final.md` 4곳에 "(area 그루핑 시 `application/<area>/<bc>/` — houserules 소유)" 병기 → #1과 같은 `--write` 1회에 합류 | area 선언 런에서 design-review-ddd가 area 경로를 위반으로 오지적하지 않음 | `b746d02` | (라이브런 대기) |
| 7 | P3 | eval 루브릭 HR-1이 area 경로를 위반으로 채점할 위험 | RUBRIC.md:95 "신규 BC가 `application/<bc>/` 하위" 고정 문구 | `workspace/eval/rubric/RUBRIC.md` HR-1 — 단일 출처(미러 불필요) | area 선언 런에서 HR-1 거짓-FAIL 방지. 평면 런 채점 불변 | `b746d02` | (라이브런 대기) |

## 시술 순서 (의존 순)

0. **공통 규율**: 코퍼스·픽스처의 area 예시는 **중립 가상 어휘**(broccoli 어휘 `parent`/`child` 금지 — 예: `driver_*`/`rider_*` 류 아키타입 어휘)를 쓴다(과적합 리뷰 F-3 — 예시 층위 침투 차단).
1. **러너** (#2): `common.dart`에 보수 폴백 판별 도입 → 각 check 깊이 가정 제거(check_cycles 호출부 포함) → `run_fixtures.sh`에 F22~F25 추가 → 전체 픽스처 PASS 확인 → codex `scripts/src/`(+`backstop.dart` 변경 시) cp 동기.
2. **final.md 2종** (#1·#6): **배포본(claude) 먼저 손편집** — houserules(§1·§2·§3·§7·§8)·architecture-ddd(4곳) → `corpus_mirror_sync.py --write` 1회 → `--check` 0 drift 확인.
3. **undecidable.md §13 + SKILL.md** (#4·#5 일부): claude 편집 → codex 동일 파일 cp(양판 미러 유지).
4. **commands/dddart.md + agents 3종** (#3·#5 나머지): claude 전용.
5. **RUBRIC.md HR-1** (#7).
6. **검증**: `run_fixtures.sh` 전체 PASS → `corpus_mirror_sync.py --check` → `diff -rq dddart/scripts codex-.../scripts`(잔여 drift 0 — extract_dc·test 제외) → `make release DRY=1`([2/7] 시뮬레이션) → git diff 리뷰.

## 수정 3대 가드 자기 점검 (사전 · 리뷰 검증 완료)

- **과적합 금지**: 리뷰 판정 "과적합 아님" — 커머스 12 BC·화이트라벨·소형 5 BC 3유형 사고실험에서 소음 상한 = 접두 그룹당 평생 1질문(advisory-only·발화 조건 한정·G0 합류·영속화 4중 감쇠). 규칙 층위 하드코딩 0(예시 층위는 시술 순서 0으로 차단). 기본 평면 무회귀는 보수 폴백으로 *구조적* 보장 + F25(drift 픽스처)로 기계 검증.
- **코퍼스 모순 금지 (선조사 — 리뷰로 재검증)**: feedback-005(analysis_options BC 국소 생성 위치)·feedback-006(TG1 발화 조건)은 "그루핑 금지"가 아님 — 원문 재확인(코퍼스 리뷰 F-4). 전 회차 grep 수색에서 평면 깊이를 금지 규범으로 확립한 회차 없음. 스킬 간 모순 후보였던 architecture-ddd 4곳은 #6으로 동반 교정. FC-GOLDEN·positive-control·타 루브릭 항목은 평면 고정 0건(F-6).
- **코덱스 미러 경계**: ⓐ final.md — **배포본 먼저** 편집 후 `--write`(소스·codex 동기 — 도구 방향 실측: 배포→소스). ⓑ 러너 `scripts/src/` — 게이트 밖이나 byte-identical 미러 실측 → cp 동기(codex final.md가 area를 허용하는데 codex 러너가 거부하는 자기모순 방지). ⓒ SKILL.md·undecidable.md — byte-identical 실측 → 양판 cp 유지. ⓓ **코덱스 오케스트레이터(`codex-dddart/skills/dddart/SKILL.md`)의 G0 질문·config 절은 이번 라운드 제외** — 오케스트레이션 산문은 의도 분기(feedback-029). codex는 area를 스스로 제안하지 않을 뿐, 규약·러너가 허용하므로 opt-in 정합 유지. **알려진 위험(코퍼스 리뷰 F-3)**: codex SKILL.md:46 "키는 둘이다" 폐쇄 열거 — codex 런이 공유 `.dddart/config.json`을 갱신하면 claude가 기록한 `area_prefixes`(특히 not-area 거절)가 소실될 수 있다. 이번 라운드는 위험 인지만 기록하고 codex :46 한 줄 완화("그 외 키는 보존")는 **다음 codex 라운드 이관 항목**으로 남긴다. ⓔ `scripts/test/`·`extract_dc.dart`는 claude 전용(미러 밖 실측) — F22~F25 추가는 claude만.

## 리뷰 반영 기록 (3종 독립 리뷰 — 2026-07-08)

| 리뷰 | 판정 | 블로커 → 반영 | 권고 → 반영 |
|---|---|---|---|
| 코퍼스 모순 | 선조사 유효·블로커 2 | `--write` 방향 역전(배포본 먼저 — 표 #1·#6·시술 2) · architecture-ddd 4곳 동반 교정(표 #6 신설) | codex config 키 충돌 위험 — 가드 ⓓ에 인지 기록·다음 라운드 이관 |
| 과적합 | 과적합 아님·블로커 1 | bcOf 비결정 폴백 → 보수 폴백 확정(러너 판별 규칙 절) + drift 픽스처 F25 | 접두 토큰 기계 정의(계약 4) · 예시 중립 어휘(시술 0) · 17종→18종 4곳(표 #1·#4·#5) · F21 충돌 → F22~(표 #2) · 리트머스 문구 교정(계약 3) |
| 실효성 | 조건부 진행 가능 | 판별 기본값 역전 — area 적극 증명 + 보수 폴백(러너 판별 규칙 절, 과적합 블로커와 동일 처방) | test/ 1:1 미러 방침 확정(계약 3) · check_cycles 목록 추가(표 #2) · 이름 deny(계약 2) · G0 감지 기계 명세·1런 지연 문서화(계약 4) · config 문구 2건·area 판정도 기록(계약 5·표 #3) · 혼재 advisory(계약 4) · 구조 판별 > config 선언 대안 판정(채택 유지) · 이동기 YAGNI 유지 |

## 정합 감사 기록 (2026-07-08 — 시술 직후 독립 서브에이전트 감사)

계획 문면 ↔ 커밋 `b746d02` diff 전수 대조. **판정: 중대 편차 0 · 경미 편차 4건(전부 "처방보다 덜 한" 방향) — 전건 처리 완료**:

1. final.md **§2 무변경** — 실측상 BC 내부 성장 규칙이라 area 무관(정당 no-op) → 표 #1 ⑤에 사유 기재.
2. **check_models.dart 무변경** — 끝-상대 판별(`di == s.length-3`)이라 area 깊이 불변(정당 no-op) → 표 #2 ⑤에 사유 기재.
3. F24 커버리지 갭(직속 파일·빈 area 미검증) → 보수 폴백 경유 ST2·ST4 발화 픽스처 보강(46/46 PASS).
4. F23 커버리지 갭(이번에 판별 코드가 바뀐 IM5 애그리거트 루트 상대 인덱싱·navigator `isBcRootPath` 경로 미커버) → 도메인 타입·애그리거트 루트·navigator 채널 통과 픽스처 보강.

계약 5조항 세부 9건(ⓐ~ⓘ)·리뷰 블로커 3건·미러 경계(코덱스 오케스트레이터 제외 포함)·중립 어휘 규율은 전량 반영 실측 확인. 감사 관찰 1건(편차 아님): 러너의 area 판별은 dart 파일만 보므로 비-dart 직속 파일(area 직속 `analysis_options.yaml` 류)은 러너 비가시 — 기존 ST1/ST2도 동일한 한계라 회귀 아님, 규약(final.md §1 ⓑ)+discipline-reviewer 감사 소유로 정리.

## 회차 요약 (다음 런 후)
- (대기)
