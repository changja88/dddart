# feedback-006 — coder 행위검증 테스트 게이트 + 의존성 토대 핀 (트랙1·기계강제·v2 적대리뷰 반영)

> **상태: ✅ 적용 완료·미커밋·4차 라이브런 검증 대기** · 적대리뷰 **3회 통과**(RCA 6+3렌즈 · 계획 4렌즈[블로커5 교정] · 적용 3렌즈[전원 sound·matches_plan/determinism/parity/no_regression/honest_scope 전부 true]) · **코퍼스 교정 사용자 승인**(2026-06-16) · 커밋은 사용자 요청 시.
>
> **적용 실측(조정자 직접 실행)**: claude런→백스톱 `TG1` 발화(blocker1·weather 무테스트) · codex런→`PJ1`+`PJ2`(blocker2·riverpod2.6.1·annotation/generator 부재) · claude런+weather테스트→blocker0(거짓-FAIL 없음·A12) · `--only tg/pj` 격리 · 무-base 퇴화 무crash · `dart analyze` "No issues found!" · 기존 52검사 무회귀 · 양판 backstop 4파일 byte-identical · `mirror_sync` 9/9 in-sync · corpus stale "52" 0건(7곳 교정: 헤더·_totalChecks·usage 2·discipline-reviewer·command·houserules usage + 보너스 mirror_sync). **적용 후 적대리뷰 minor 교정 반영**: green=flutter test를 "테스트 존재 시에만(0개는 analyze-only·삭제로 비우기 금지)"으로 정밀화 / PJ ④를 "토대 강제는 결정적·@riverpod 전환은 coder 행위 조건부"로 정직화 / usage 헬프 tg,pj 추가.
> **트리거** 3차 양판 — `results/20260615-2319-weather-claude.md`(FC-2 단독) · `-codex.md`(FC-1·2·3 정렬+ST-5) · `-compare.md`
> **베이스 코퍼스** `cddfd12`(feedback-005) · **원칙 = 기계강제**(003 명세-only 실패·005 기계강제 성공 계승)
> **방향(사용자 ①)** = codex 정렬은 입력계약/런 절차로 분리(트랙2·feedback-007). feedback-006 = *기계강제로 닫히는 결정적 승리*(claude 테스트축 + 양판 토대축).

---

## §RCA — 원인 규명 (RCA 6렌즈 + 적대리뷰 3렌즈 통과·파일:줄 검증·self-contained)

**최심 공통 프레임**: 구조(backstop 52)·타입(BC국소 always_specify_types lint)은 기계강제라 양판 둘 다 green. 그러나 *행위 정확성·검증* 두 책무가 코퍼스에 **정의조차 안 됨** → 엔진 기본 성향이 빈자리를 채움. "LLM이 흘린 게 아니라 애초에 요구받은 적이 없다."

**확정 뿌리 3 (직교)**
- **A. coder에 행위검증 테스트 산출 책무 0 — claude FC-2 [존재축]**: `coder.md:30`(산출=코드)·`:37`(green=analyze 신규0). 코퍼스가 "테스트 없음"을 **적극 선언**(architecture-ddd final.md:196·discipline-cleancode final.md:2542·2681·SKILL.md:28) → claude 무테스트=규율 준수·골든 FC-2와 **내부 모순**. → 기계강제 가능(존재축).
- **B. 요청 행위(정렬) 미운반 — codex FC-1/2/3 [행위축]**: 정렬 claude 있음(`forecast_list_vm.dart:53-54`)·codex 0건. Phase0 미전사 → architect 행위목록 자유재도출(닫힘규칙 0) → 정렬은 "VM 변환"이라 유일 양성강제(판정 라벨링) 구조 면제 → §1④↔§4 양가성. → **코퍼스 partial**(아래 적대리뷰 정정).
- **C. 의존성 토대를 pub add resolve에 위임 — codex ST-5/ST-8/DT-6 [토대축]**: `coder.md:56`(버전값 기억 금지·무핀 설치). 닫힌 매니페스트 부재 → codex 보수성향이 riverpod 2.6.1 수동 침몰. claude에도 적용 → claude 적중도 운(회귀면). → 기계강제 가능.

**적대 크럭스(RCA 적대 3렌즈)**: 제안 게이트를 codex 정렬에 대입하면 전부 통과(못 막음) — codex 일차근원은 비결정 상류. **결정적으로 닫히는 건 claude(존재축)·토대(양판). codex 정렬 의미는 트랙2.** 두 "하지 마라": codex 게이트 실행 실제 증명됨(재처방 금지)·오케스트레이터 본문 verbatim 동일(표현강도 아니라 공유 backstop에 게이트).

---

## §계획 적대리뷰 반영 (v1→v2·블로커 5 교정·`wf_f88e5c66-43e` 4렌즈)

v1 계획을 4렌즈가 압박해 잡은 블로커 — v2가 교정:
1. **[블로커·v1 Fix1a 불가] 백스톱은 lib/ 전용**(common.dart:362·401 `toLibRel`가 비-lib/ null)이라 "check_structure 확장으로 test/ 검사"는 vacuous. → **v2: ST4 `_skeleton` 패턴 차용** — 신규 BC 판별은 lib-side `ctx.isAddedDir`(유효 게이트)·test/ 검사는 `Directory('${ctx.root.path}/test/...').existsSync()` **File I/O**(ST4가 lib skeleton에 이미 쓰는 동일 기법). context 불변식 불침해.
2. **[블로커·claude 전제] `test/widget_test.dart`=baseline scaffold**(M not A·test/ 안 비었음). → **v2: 발화조건을 "신규 lib BC에 대응 `test/application/<bc>/` 하위 실테스트 0건"으로 정정**("빈 test/" 표현 폐기).
3. **[블로커·환경 플레이크 오진→희소식] 셰이더 실패는 환경 아님**: codex 런폴더 `flutter clean && flutter test` → +22/-5가 +24/-3(ink_sparkle 2실패 결정적 소멸·3/3 재현). RUNBOOK clone+clean -fdx 잔존 build/ 산출물. → **v2: green=flutter test가 결정적으로 성립**(LLM 환경분류=003 경로 제거). 채점은 RUNBOOK에 `flutter clean` 선행(eval).
4. **[블로커·VM-only 자가모순] M4(탭→상세)·G-5는 view onForecastSelected 거주→위젯펌프 불가피**. → **v2: 위젯펌프 허용 + `splashFactory: NoSplash` 테스트테마로 ink_sparkle 경로 회피**(VM-only 회피책 폐기).
5. **[major·PJ 거짓양성] riverpod 미선언 정상본 차단 위험**. → **v2: "flutter_riverpod이 dependencies에 선언된 경우에 한해" 가드 명문**.
+ 배선 5점(import·dispatch·familyOn·_totalChecks·헤더), stale "52종" 6곳 전수, final.md 미러 방향(deployed 먼저→--write), positive-control PJ 호스트 — 전부 v2 처방에 반영.

**전제 정정(렌즈3)**: codex 정렬은 mechanizable=**partial**(no 아님) — 오름차순 *요구*는 SCENARIO §1④(:25)·§4(:43)·G1 답(RUNBOOK:72)으로 **파이프라인 가시**, blind는 골든 데이터셋/단언뿐. architect 닫힘규칙(scope 요청행위↔명세 행위 수대조)은 명세-only 아니라 **수대조 기계 teeth** 있음 → **feedback-007 핵심으로 분리**(트랙1 깨끗한 N=1 측정 후·효과귀속 보호). "오름차순 정확성" 보장만 골든(입력계약) 영역.

---

## 사전등록 표 (트랙1 — v2)

| # | 우선 | ① 대상 결함 | ② 원인(뿌리) | ③ 처방(파일·미러) | ④ **예상효과**(전→후) | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| **1a** | 최우선 | claude FC-2(신규 BC weather에 행위테스트 0·스모크만) | coder 산출=코드만(`coder.md:30`)·green=analyze만(`:37`) | **신규 `scripts/src/check_tests.dart`(TG1)** — ST4 `_skeleton` 패턴: `ctx.allDirs`+`isAddedDir`로 신규 BC 식별 → 각 BC `test/application/<bc>/` 하위 `*_test.dart`≥1 File I/O 검사·0건 blocker. 백스톱 src **수동 cp 양판**(claude `dddart/scripts/`·codex `codex-dddart/skills/dddart/scripts/`) | **claude FC-2: FAIL→PASS** (조건부: 존재는 결정적·*비-vacuity*는 1b+discipline-reviewer 의존) | | |
| **1b** | 최우선 | 〃(테스트 통과 강제) | green 경로(`:37`)가 flutter test 미포함(단일 차단점) | **coder.md** 산출(:30) += "명세 외부관찰 행위목록 각 항목마다 깨지면 red 되는 widget/unit test 1+" · green(:37) "+`flutter test` exit0". **결정적 테스트 패턴**(implementation-flutter/riverpod final.md 신규 절): 탭=`splashFactory:NoSplash` 테마(셰이더 회피)·loading=완료+pumpAndSettle 또는 VM.future(Timer 회피). coder.md **수동 양판**(codex `dddart-coder/SKILL.md`)·패턴 final.md **mirror_sync** | claude FC-2 PASS **선행조건** | | |
| **1c** | 최우선 | 코퍼스 내부 모순(테스트 강제↔"없음 결정") | architecture-ddd·discipline-cleancode "테스트 없음" 적극선언 | **배포본 먼저 손편집** `architecture-ddd/references/final.md:196`·`discipline-cleancode/references/final.md:2542,2681` "테스트 없음 결정"→"행위검증 테스트 산출(구조 단위테스트·DI 비강제)" → `corpus_mirror_sync.py --write`(소스·codex)→`--check` 0 drift. `discipline-cleancode/SKILL.md:28` **수동 양판**. **보존**: WELC 원전 인용(final.md:2546/2548/2614 "레거시=테스트 없는 코드") | 1a/1b 자가모순 제거 | | |
| **2a** | 토대·claude회귀보험 | codex ST-5(@riverpod 미사용·riverpod 2.6.1·generator 부재)·ST-8 | `coder.md:56`이 의존성 집합·메이저를 pub add resolve에 위임 | **신규 `scripts/src/check_pubspec.dart`(PJ1·PJ2)** — `${root}/pubspec.yaml` 직접 파싱. **flutter_riverpod 선언 시에 한해**: PJ1 메이저<3 blocker / PJ2 riverpod_annotation·riverpod_generator·build_runner 중 부재 blocker. 미선언=0발화(거짓양성 가드). 버전 파서(캐럿·범위·고정·any) 결정적. `common.dart` Finding `{rootRel}` 추가(pubspec 경로 표시). + `coder.md:56`에 "필수 코어 집합·메이저 하한=매니페스트 고정(값만 resolve)". 백스톱 src **수동 cp 양판** | **codex 토대 강제(결정적): riverpod≥3+codegen 핀 → ST-5 해소 *조건*(실제 @riverpod 클래스형 전환은 다음 런 coder 행위·PJ는 토대만 연다) · ST-8 WEAK→정합 · claude 2.x 회귀 차단(보험)** | | |

**백스톱 배선(양판 byte-identical)**: `backstop.dart` import 2(check_tests·check_pubspec)·dispatch 2(`if(familyOn('tg'))…`·`if(familyOn('pj'))…`)·`_totalChecks` 52→**55**(ST12+IM22+NM17+CY1+TG1+PJ2)·헤더주석(:2,:22). familyOn/idOn 제네릭(tg/pj 자동·변경 불요·검증). **coordinator G2**(`commands/dddart.md`+codex SKILL G2): "flutter test exit0 확인"(자기보고 불신·수동 양판). **stale "52종"→"55종" 6곳**: claude backstop.dart(헤더 주석·`_totalChecks` 줄·`--only` usage 2곳)·discipline-reviewer.md:12·commands/dddart.md:143 / codex scripts/backstop.dart(동일·byte-identical)·SKILL.md:161·dddart-discipline-reviewer/SKILL.md:14 + (보너스) `workspace/tools/corpus_mirror_sync.py` 도크스트링 → grep `52종|_totalChecks = 52` 0건 게이트.

## 범위 밖(트랙2·별트랙)
- **codex 정렬 FC-1/2/3 = partial** → feedback-007 핵심(architect 닫힘규칙+Phase0 전사·기계 수대조 teeth)·"오름차순 정확성"만 입력계약.
- SD-9 enum(의미)·hooks 비우회(후순위)·riverpod_lint(PJ로 대체)·retrofit(설계결정·수동 dio 합법·DT-6 WEAK·옵션① 절제) — 전부 별도.

## 알려진 위험 (적대리뷰 반영)
1. **TG teeth=존재성**(비-vacuity 미보장)·claude가 vacuous 테스트 1개 넣으면 통과 → ④ 조건부 명시. 비-vacuity는 1b(행위 두드림 산출)+discipline-reviewer 의미감사.
2. **claude 정렬 적중 회귀**(정렬 자체)는 트랙1 비차단(트랙2)·PJ는 toolchain 회귀만 차단.
3. 셰이더=환경 아니라 stale build → RUNBOOK `flutter clean` 선행으로 결정적 차단(green=flutter test의 LLM 환경분류 제거).

## 적용 순서 (사용자 승인 완료)
1. **common.dart Finding rootRel** → **check_pubspec.dart(PJ)** → **check_tests.dart(TG)** → backstop.dart 배선(claude).
2. **positive-control 검증**: /tmp 사본에 — (a)claude 런폴더→TG가 weather 무테스트 차단 (b)codex 런폴더→PJ가 riverpod2.6.1 차단 (c)notice fixture-in-host→TG·PJ PASS(거짓-FAIL 반증). 코퍼스·런폴더 불변(mutation /tmp).
3. coder.md·final.md(패턴·모순제거)·command G2·stale 6곳(claude).
4. **codex 미러 전부** + byte-identical·정합 확인(grep 게이트).
5. **적용분 적대리뷰**.

## 회차 요약 (다음 런 후 채움)
- 예상 적중 _/N · 무효 _ · ⚠️회귀 _
- **한 줄 결론**: _
- ⚠️ N=1 인과단정 금지. 정직한 기대: **claude FC-2·codex ST-5 움직여야·codex 정렬 FC-1/2/3은 코퍼스만으론 불변**(트랙2 필요).
