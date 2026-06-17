# dddart feedback-008 — 테스트 전략 설계 (회귀 안전망 · positive FORM 가이드)

> **현재 상태(2026-06-17·compact 대비·재개 앵커)**: 설계 + 사전등록 원장 **완료**. **결정 I 확정 = positive FORM 가이드 강화**(백스톱/grep/lint 철회·reviewer positive 감사)·**결정 II 확정 = 날짜 주입**(시간 게이트·clock·`_totalChecks` 변경 철회). 검증 자료조사(A~J·출처)·자가검토·적대 리뷰 2차(5렌즈)·정정 전부 반영. 사전등록 원장 = `workspace/eval/fix/feedback-008-test-skills-positive-form.md`(+README 인덱스). **코퍼스 작성 완료(2026-06-17·사용자 승인 후·미커밋)** — worklist 0~8 실행: 신규 10파일(`discipline-test`·`implementation-test` 각 3벌) + 수정 22파일(§7→포인터·coder·reviewer·houserules test/·architecture-ui Key·architecture-ddd 날짜주입). 검증 = `corpus_mirror_sync.py` **11/11 in-sync** · `run_fixtures.sh` **16/16 PASS** · 백스톱 `_totalChecks` **55 불변** · 지식 스킬 SKILL.md 양판 byte-exact. **적대 리뷰 3차(작성 후·6렌즈·~607k)로 실제 결함 9건 교정** — 핵심: 테스트 격리 seam이 dddart no-DI(repo provider 없음·옛 §7 상속 버그)와 모순→**도메인 직접+VM override+Dio목** 모델로 재작성, §3.5 Either `Failure`→`BadRequestResponse`, contains→정확일치, fixture≥3, "디코이-불가" 과대선전→정직 라벨, cleancode stale 정합(상세=원장 008 시술기록). 재검증 11/11·16/16·55 불변. → **다음 = 사용자 커밋(미커밋 상태) + 6차 양판 라이브런 실측**(measure-first·원장 ⑥). *메모리 저장 보류*(프로젝트 밖 writing 금지·스코프 미확정). 외부 plan 파일 미사용.
> 브레인스토밍 설계문서(superpowers 기본 경로를 dddart 규약 `workspace/design/`로 override). 기반 = feedback-007 적용 커밋 `d8de838` + 5차 양판 라이브런 채점. **양엔진 무관 코퍼스 트랙.**
> ⚠️ 이 문서는 *설계*다. 실제 코퍼스(dddart/·codex-dddart/) 수정은 **별도 사용자 승인** 후 착수한다(코퍼스 불변 방침).

## Context — 왜 이 변경을 하나

5차 양판 라이브런(claude `94e0ea1`·codex `008cdb6`)에서 양 엔진이 같은 치명 게이트 3종을 FAIL했다:

- **FC-1 / FC-3 (색 구별)**: `listIconColor`에서 `clear == cloudy == secondaryContainer(#FEAE2C)` 색 충돌을 **양 엔진이 독립 산출**(2/2·같은 Stitch 제한 팔레트). codex는 이 충돌을 "정답"으로 *명시 단언*하는 **디코이 테스트**까지 냈다.
- **FC-2 (비-vacuity)**: 목록 *순서*(M1)·기온 *위치*(M3)·탭 *날짜*(M4) 단언이 vacuous(헛테스트) — 구현이 틀려도 green.

적대 리뷰(5렌즈)의 핵심 발견: **코퍼스에 이미 정답 지식이 있었다.** `implementation-flutter` references/final.md §7(L224–262)은 이미 ⓐ비-vacuity 자가점검("머릿속으로 깨봤을 때 red") ⓑ정확한 `scrambled → orderedEquals` 예시 ⓒ탭→상세 `findsOneWidget` 예시를 담고 있었는데도 coder가 디코이/헛테스트를 냈다. → **실패의 원인은 *커버리지(지식)*가 아니라 *단언 FORM*과 *강제*다.** "무엇을 테스트할지"를 더 가르치는 것만으로는 닫히지 않는다(스킬-only는 §7로 사실상 이미 실험·실패).

**목표**: dddart 테스트를 **회귀 안전망**(생성된 *명세-정확* 코드를 차후 수정으로부터 보호)으로 정의하고, **디코이를 *형태*로 막는 단언 FORM**을 스킬에 verbatim 탑재한다. mutation 같은 무거운 기계강제는 비용/미해결 문제로 009로 미루고, 이번 회차는 **자가집행 FORM**(`toSet().length == N` = 충돌 시 자동 red)과 **discipline-reviewer FORM-감사**로 floor를 올린다.

## 검증 자료조사 (출처 명기 · 2026-06-17 메인루프 라이브 재검증)

> **정석 순서**: 이 검증 자료가 `references/final.md`의 *토대*다. SKILL.md는 그 위 얇은 라우팅 레이어. (코퍼스 references는 승인 후 이 절에서 lift.) **휘발성 사실은 코퍼스 build 시점에 1회 더 재확인**(자기보고/세션기억 불신). 이번 재검증으로 세션 중 과장 2건을 **정정 확정**(아래 C·E 표시).

### A. Flutter 공식 테스트 정전 → `discipline-test §1` 무게중심
- 출처: [docs.flutter.dev/testing/overview](https://docs.flutter.dev/testing/overview)
- 정확 인용: "a well-tested app has **many unit and widget tests** ... plus **enough integration tests to cover all the important use cases**." → 무게중심 = unit/widget 두텁게·integration 핵심만(비율 수치는 비공식).
- 공식 트레이드오프 표: Confidence **Low/Higher/Highest** · Maintenance cost **Low/Higher/Highest** · Dependencies **Few/More/Most** · Speed **Quick/Quick/Slow**. → unit이 maintenance·speed 우위 = thick domain의 공식 근거.
- "test pyramid" 용어·golden/screenshot은 공식 overview에 **없음** → "pyramid" 인용 금지 · golden 제외는 dddart "시각=인간 오라클(A1·비측정)"과 합치(공식도 baseline 테스트 종류로 안 둠).

### B. flutter_test matcher → `discipline-test §3` FORM (디코이 차단 직결)
- 출처: [api.flutter.dev/flutter/flutter_test](https://api.flutter.dev/flutter/flutter_test/) (findsWidgets-constant 페이지 직접 확인)
- 개수 matcher(현행 정식 ↔ 구 별칭): `findsOne`↔`findsOneWidget`(정확히 1) · `findsExactly(n)`↔`findsNWidgets(n)`(정확히 N) · `findsAtLeast(n)`(≥N) · **`findsAny`↔`findsWidgets`** · `findsNothing`(0).
- **디코이 직결 확정**: `findsWidgets` = "Asserts that the FinderBase locates **at least one** widget"(정확 인용) ≡ `findsAny`. "적어도 1"이라 주변 잔존 위젯을 흡수 = **M4 codex 디코이의 정체**. → FORM은 `findsOne`/`findsOneWidget`·`findsExactly(n)`로 **정확 개수** 고정, **`findsWidgets`·`findsAny`·`findsAtLeast` 전부 금지**(≥ 계열).
- Finder: `find.byKey`·`find.byType`·`find.byIcon`·`find.descendant(of:, matching:)`·`find.byWidgetPredicate`. 수식 `.first`/`.last`/`.at(index)`(기존 §7도 `.first` 사용). → §3.3 슬롯=`byKey`, §3.4 비-edge=`.at(2)`+`descendant`.
- **package:matcher**(dart.dev 1st-party·DL **7.07M**·v0.12.20) 매처 어휘: 동등 `equals` · 컬렉션 `orderedEquals`(순서)·`unorderedEquals`·`containsAll`·`everyElement`·`hasLength` · 타입 `isA<T>()`+`.having((x)=>…, '필드명', 기대값)` · 예외/async `throwsA`·`returnsNormally`·`completion`·`completes` · 커스텀 `predicate`. → §3.2 순서=`orderedEquals` · **Either 양채널 단언 = `isA<Right>().having((r)=>r.value, 'value', expected)` / `isA<Left>()`**(architecture-data 계약과 합치·discipline-test references에 FORM으로 추가 후보).

### C. riverpod 3.x 테스트 → `implementation-test` 셋업
- 출처: [github.com/rrousselgit/riverpod](https://github.com/rrousselgit/riverpod) `whats_new.mdx`·`how_to/testing.mdx` (v3.0.2·context7 High rep)
- `ProviderContainer.test()` — 테스트 종료 시 **자동 dispose**, 정확 인용: "Replaces the custom createContainer utility from Riverpod 2.0."
- async provider 1차 패턴: `final f = container.read(p.future); final data = await f;` · 상태 전이는 `await container.pump();` 후 `.isLoading`/`.value` 단언. **⚠️정정 확정**: 세션 중 "listen+verifyInOrder가 표준"은 **과장** — 공식 1차 패턴은 `read(.future)`+`pump`(listen은 보조).
- override: `p.overrideWithValue(AsyncValue.data(x))`(Future/Stream) · `p.overrideWith((ref)=>x)`(초기값) · **`p.overrideWithBuild((ref, self)=>x)`**(3.x 신규 = build만 목·notifier 메서드 보존).
- (구형 `ProviderContainer()`+`addTearDown(container.dispose)`도 문서 병기 — 둘 다 유효·`.test()`가 3.x 권장.)

### D. mocktail → `implementation-test` 더블
- 출처: [github.com/felangel/mocktail](https://github.com/felangel/mocktail) (README·context7 benchmark 90)
- **지표(pub.dev 2026-06)**: likes **1.23k**·DL **2.53M**·v**1.0.5**·**코드젠 0**. ↔ **mockito** 5.7.0(likes 1.53k·DL 2.08M)는 null-safe에 **코드젠 필수**(공식 인용: "supports … null safety … primarily with **code generation**" → `@GenerateNiceMocks`+build_runner→`.mocks.dart`). → **mocktail 채택 근거(실증)**: dddart는 이미 build_runner를 riverpod/freezed/hive에 돌리므로, *테스트 목까지* 코드젠을 더하지 않는 mocktail이 생성 파이프라인 결정성 우위(인기 동급·DL은 mocktail 우위).
- `class MockX extends Mock implements X {}` — **코드젠 0**(mockito는 build_runner+`.mocks.dart` 필요 → 생성 파이프라인 결정성 우위).
- 클로저 형식(mockito와 다름): `when(() => x.m()).thenReturn(v)` / `.thenAnswer((_) => v)` · `verify(() => x.m()).called(1)`/`verifyNever` · getter `when(() => x.g).thenReturn(v)`.
- 매처: `any()`·`any(named: 'arg')`·`any(that: matcher)`. 커스텀 타입은 `setUpAll(() => registerFallbackValue(FakeX()))` (`class FakeX extends Fake implements X {}`).
- → FORM 헬퍼 `_FakeRepo`는 mocktail Mock 또는 손수 Fake 둘 다 가능 — 표준은 `implementation-test`에서 확정(검토 ⓓ).

### E. Dart mutation 도구 → **009 미룸 근거 확정**
- 출처: [pub.dev/packages/mutation_test](https://pub.dev/packages/mutation_test) · [dartmutant.dev](https://dartmutant.dev/)
- `mutation_test`: CLI·XML 규칙·언어 무관·기본 `dart test`+`lib/*.dart`.
- `dart_mutant`: tree-sitter AST·`*.g.dart`/`*.freezed.dart` 자동 제외·**연산자/비교/불리언/널안전** 변이·Rust 병렬·"zero false positives"·"minutes not hours"·표어 "find tests that **pass when they shouldn't**".
- **결정 근거(확정)**: 두 도구 다 *generic 연산자/불리언* 변이 → "두 enum case가 색을 공유" 같은 **의미 변이는 생성하지 않음**. 헛테스트(단언 0)는 잡아도 *색 distinctness* 같은 도메인 의미는 미적중 + 변이마다 테스트 1회 = 느림. → 이번 회차는 **자가집행 FORM**(`toSet().length==N`)으로 의미 보장, mutation은 **009 조건부 미룸**(의미 변이 저작 = 기능마다 비용). **⚠️정정 확정**: 세션 중 "mutation_test v1.8"은 미확인 — 버전 숫자 단정 철회(도구 *실재*만 확정).

### F. 테스트 철학 → `discipline-test §2·§4·§5`
- 출처: Martin Fowler([Eradicating Non-Determinism in Tests](https://martinfowler.com/articles/nonDeterminism.html)·test behaviors not implementation) · 업계 합의(SWE@Google·dcm.dev).
- 행위>구현: 행위 테스트라야 리팩터링에 안 깨지고 검증 역할을 한다(mockist는 구현 결합).
- **생략 근거(인용)**: "Many developers create a test class for every production class and a test method for every public method, but this is generally not good practice ... test only behavior and module public API." → §4 생략 목록(getter·자명 위임·private·위젯 트리 형태).
- **디코이 뿌리(합치)**: LLM 생성 테스트는 *구현 미러링* 경향(버그 코드면 디코이로 악화·codex 5차 실증) → §2 오라클을 **코드 아닌 명세에서**(2단계·see-it-fail).

### G. 시간·결정성 → `implementation-test` (★날짜 의존 코드에 영향)
- 출처: [pub.dev/fake_async](https://pub.dev/packages/fake_async)(dart.dev 1st-party·DL **5.43M**·v1.3.3) · clock(dart.dev 1st-party)
- `fakeAsync((async){ …; async.elapse(d); })` = Timer/microtask/Future 결정적 진행(현행 §7 'loading Timer 누수'의 정공법·`pumpAndSettle` 무한대기 회피와 병행).
- **★중대 함정(인용)**: "FakeAsync **can't control** the time reported by `DateTime.now()`" — *단*, 코드가 `clock.now()`(package:clock)로 만들면 FakeAsync가 자동 오버라이드. 고정 시각은 `withClock(Clock(() => fixedDate), () {…})`(검증된 형태).
- **함의 → ✅ 채택 (A·2026-06-17 결정)**: 시간 의존 테스트는 pre-commit에서 *무관한 날* 커밋을 깬다(결함). 그래서 시간을 **단일 주입 통로**로만 들인다 — ⓐ도메인 판정은 *순수*(기준일을 인자로) ⓑ '지금'이 진짜 필요한 edge는 `clock.now()`(운영=실시각·테스트=`withClock(Clock(() => 고정일), () {…})`로 고정·*검증된 형태*) ⓒ raw `DateTime.now()`/`DateTime.timestamp()`는 **백스톱이 금지**(게이트+스킬 짝). `clock`=tools.dart.dev·DL **5.83M**·v1.1.2(검증·`Clock.fixed`는 build 시 확인).

### H. golden 지형 → **제외 확정(출처)**
- 출처: [pub.dev/alchemist](https://pub.dev/packages/alchemist)(Betterment) · golden_toolkit **discontinued**(다수 출처 교차)
- 내장 `matchesGoldenFile`(저수준 1차) / `golden_toolkit` **폐기** / **`alchemist`(2025 표준)**: platform 테스트(가독 텍스트·로컬 전용)와 CI 테스트(텍스트→**색 블록**으로 폰트 flakiness 회피) 2종.
- → dddart **golden 제외**(시각=인간 오라클 A1·비측정). *도구 자체가 폰트/플랫폼 비결정을 인정*하는 점이 제외의 객관 근거(생성 파이프라인 결정성과 상충).

### I. 네트워크 이미지 함정 → `implementation-test` (조건부)
- 출처: [mocktail_image_network](https://pub.dev/packages/mocktail_image_network) · [network_image_mock](https://github.com/stelynx/network_image_mock) · [flutter/flutter#129532](https://github.com/flutter/flutter/issues/129532)
- **확정 함정(인용)**: 테스트(`TestWidgetsFlutterBinding`)에선 모든 HTTP가 **400** → `Image.network`가 `NetworkImageLoadException`로 위젯 테스트 크래시(앱 결함 아님).
- 해법: `mockNetworkImages(() async => tester.pumpWidget(…))`(mocktail_image_network·mocktail과 짝) 또는 `mockNetworkImagesFor(…)`(network_image_mock).
- → **조건부 채택**: view가 `Image.network`를 그리면 펌프를 `mockNetworkImages`로 감싼다. *weather 아이콘이 `IconData`면 미해당* — 어느 BC든 네트워크 이미지 view면 발동하는 일반 함정으로 references에 명시.

### J. integration/E2E 지형 → integration 얇게 근거
- 출처: [pub.dev/patrol](https://pub.dev/packages/patrol)(leancode) · 업계 비교(2025–26)
- `integration_test`(flutter.dev 1st-party·Flutter 런타임 내부·네이티브 다이얼로그/권한 **불가**·항상 유지) ↔ `patrol`(네이티브 러너 UIAutomator/XCUITest·강력하나 **CI 불안정**·"avoid unless willing to debug CI failures").
- → dddart: integration **얇게**(공식 정전 A와 합치)·필요 시 1st-party `integration_test`. patrol=네이티브 상호작용 필요 시 옵션(주석·CI 불안정으로 비채택).

### 패키지 생태계 요약 (신빙성 = pub.dev 지표·퍼블리셔·2026-06)
| 패키지 | 퍼블리셔 | 인기 | dddart |
|---|---|---|---|
| `flutter_test`·`package:test` | flutter.dev·dart.dev | 1st-party 번들 | **채택**(토대) |
| `package:matcher` | dart.dev | DL 7.07M | **채택**(matcher 어휘) |
| `flutter_riverpod` (테스트) | rrousselgit | v3.x·High | **채택**(VM/provider) |
| `mocktail` | felangel(VGV) | likes 1.23k·DL 2.53M·코드젠0 | **채택**(더블) |
| `mockito` | dart.dev | likes 1.53k·DL 2.08M·코드젠 | 주석-제외(코드젠 추가) |
| `fake_async`+`clock` | dart.dev·tools.dart.dev | DL 5.43M·5.83M | **채택(A)**(Timer·`clock.now()` 시간 통로·`DateTime.now()` 백스톱 금지) |
| `mocktail_image_network` | felangel | mocktail 짝 | 조건부(네트워크 이미지 view) |
| `alchemist`(golden) | Betterment | 2025 표준 | **제외**(시각=A1·비결정) |
| `integration_test` | flutter.dev | 1st-party | 얇게(필요 시) |
| `patrol` | leancode | 성장세·CI 불안정 | 주석-제외 |
| `mutation_test`·`dart_mutant` | 3rd-party | 실재 | 009 미룸 |

### 검증 → 코퍼스 매핑
- `discipline-test/references/final.md` ← A(무게중심)·B(FORM matcher 어휘·Either `isA().having`)·F(철학·오라클·생략).
- `implementation-test/references/final.md` ← C(riverpod 3.x)·D(mocktail·vs mockito 실증)·B(matcher)·**G(fake_async+clock·날짜 결정성)**·**I(네트워크 이미지 목·조건부)**·결정성(Fowler nonDeterminism + NoSplash/Completer).
- references에 "안 쓴다"로 명시(주석-제외) ← **H(golden=시각 A1)**·**J(patrol·integration 얇게)**·mockito.
- 009 트랙 ← E(mutation).
- **✅ 시간-결정성 가드(A·이번 회차 포함)** ← G: raw `DateTime.now()` 금지(백스톱 신규 검사·`_totalChecks` +1) + 규약(domain 순수·`clock.now()` 통로) + 테스트 `withClock` 고정. architecture-ddd/houserules + 백스톱 결합.

## 설계 결정 (확정)

- **목적/철학**: dddart 테스트 = 회귀 안전망(사후 *수정 모드*가 실사용처)·**개발 드라이버(TDD) 아님**(코드는 이미 생성됨). 핵심 = **옳은(명세) 상태를 가둠**(버그 상태를 가두면 디코이·빈 상태면 헛테스트).
- **스킬 2개(둘 다 coder 로드)**:
  - `discipline-test` = *무엇을/오라클/단언 FORM/반송 규율* (FORM이 오라클과 함께 여기 산다).
  - `implementation-test` = *Flutter 어떻게* (flutter_test + mocktail + riverpod3 `ProviderContainer.test` · 결정성 · §7 메커니즘 흡수).
  - 둘 다 **SKILL.md 짧게 + references TOC**(>300줄은 references로). 근거: `skills:` 프리로드 = SKILL.md 전문 주입(렌즈3).
- **무게중심 = thick domain**: domain 판정·UseCase·Either 양갈래 두텁게 > state/VM 전이·정렬/필터/매핑 > UI 핵심 행위만 얇게. 정렬·구별은 *도메인* 판정이라 도메인에서 두드린다(판정 소유 §3.3·VM 아님).
- **절차 — '테스트 먼저' 폐기**: bottom-up + codegen에서 구조적 실행 불가(VM/`.g.dart` 생기기 전 clean assertion-red = compile error·Phase3 soft-reset이 red 커밋 흔적 삭제)·같은 작성자 자기보고 = theater. 대신 **자가집행 FORM + discipline-reviewer FORM-사용 감사**.
- **파일트리**: `test/` = lib/ 루트 형제(Dart 공식 package-layout)·내부 1:1 미러·`<sut>_test.dart`·**sparse**(있는 자리만). TG1 BC-존재 검사 유지, **미러 배치는 reviewer 감사**(리지드 blocker 강등 — vacuity와 직교·nav/fixture/common/root/design_system/VM-unit에 '미러' 미정의·false-FAIL+게이밍). test/는 §5 '선택 폴더 없음'의 **명시적 예외**(빈 슬롯 = vacuity 유인이라 골격완비 비전이).
- **선수정 필수(안 하면 모순 → stall)**: `file-tree.md §9-5·§13·§15`의 '테스트 없음' 전제 제거 + houserules §3에 'test/ sparse = 골격완비 예외' 명시. (현재 file-tree §9-5 "테스트 디렉터리 규약 없음" + houserules §3 "선택 폴더 없음" 보편선언이 충돌 → houserules §2 "모순 보고"로 stall 위험.)
- **시간-결정성 = 날짜 주입 (2026-06-17 결정 II·게이트 철회)**: 시간 의존 테스트는 결함이나 — 5차 코드에 `DateTime.now()` 0회 + 백스톱이 test/ 못 봄 + 측정 dim 0 → **백스톱 게이트·clock 의존 철회**. 대신 **날짜 주입 규약**: 도메인 판정은 *순수 함수*(기준일을 인자로)·'지금'이 필요한 edge는 오버라이드 가능 provider/인자로 격리·테스트는 고정 날짜 주입(실시각 안 읽음). references 한 줄 규약(discipline-test/architecture-ddd)·게이트 없음·clock 불필요. (실제 'now' 쓰는 BC가 런에 등장하면 그때 게이트 재고.)
- **미룸/별도 트랙**: mutation 게이트(009 조건부)·`acceptance-tester` 에이전트(작성자 분리)·골든/RUBRIC "색 구별 판정단위"(grader A13·eval-side 명료화).

---

## (1) `dddart/skills/discipline-test/SKILL.md` (초안)

> + codex `codex-dddart/skills/discipline-test/SKILL.md` flat 미러(byte-identical). 기존 방언(houserules/cleancode/implementation-flutter SKILL.md) 실측에 맞춤.

```markdown
---
name: discipline-test
description: dddart가 생성한 코드의 회귀 안전망 테스트 규율 — 무엇을 테스트할지(무게중심)·오라클을 명세에서 끄는 법·헛테스트(vacuous)/디코이를 *형태*로 막는 단언 FORM·생략 목록·반송 규율. 테스트를 작성·검수할 때 로드한다. HOW(Flutter 메커니즘·결정성·더블)는 implementation-test로 위임.
user-invocable: false
---

# dddart 테스트 규율

dddart 테스트 = **회귀 안전망**(생성된 *명세-정확* 코드를 차후 수정으로부터 보호)이다 — 개발 드라이버(TDD)가 아니다(코드는 이미 생성됨). 핵심은 **옳은(명세) 상태를 가두는 것**: 버그 상태를 가두면 디코이, 아무것도 안 가두면 헛테스트다. **단언 FORM·생략의 *사실*은 `references/final.md`가 단일 출처**이고, 이 본문은 그 사실을 쓰는 결정 규율이다. Flutter 메커니즘·결정성·더블 표기는 implementation-test, 판정 소유(정렬·구별은 도메인)는 architecture-ddd, green 래칫·테스트 산출 의무는 coder.md, 파일트리(test/ 미러)는 discipline-houserules 소유.

## 언제 쓰나

coder가 슬라이스의 행위 검증 테스트를 쓸 때, 또는 discipline-reviewer가 그 테스트의 비-vacuity를 감사할 때 로드한다. 전문을 읽지 말고 아래 표로 필요한 절만 부분 적재한다. 경계:

- 위젯 펌프 결정성(NoSplash·Timer/Completer)·`ProviderContainer.test`·mocktail 더블 → `implementation-test`
- 정렬·구별 등 판정이 누구 것인가(도메인 vs VM) → `architecture-ddd`(판정 소유 §3.3)
- 테스트 파일 위치(test/=lib 미러·sparse) → `discipline-houserules`
- green 래칫·테스트 필수 산출 의무 → `coder.md`

## 핵심 운영 원칙

- **목적 = 회귀 안전망**: 명세-정확 행위를 가둬 *사후 수정*으로부터 지킨다 — 실사용처는 수정 모드다. 그래서 가두는 건 *현재 코드*가 아니라 *명세*다 (§1).
- **오라클은 코드가 아니라 명세에서**: 기대값을 구현에서 베끼지 않는다 — LLM 생성 테스트의 구현-미러링이 디코이의 뿌리다(코드가 틀리면 테스트도 같이 틀린다) (§2).
- **무게중심 = thick domain**: domain 판정·UseCase·Either 양갈래를 두텁게 → state/VM 상태전이·정렬/필터/매핑 → UI는 핵심 행위(탭→이동)만 얇게. 정렬·구별은 *도메인* 판정이라 도메인에서 두드린다(판정 소유 §3.3) (§1).
- **비-vacuity 자가점검**: "단언이 의존하는 로직을 한 곳 지웠다고 가정하면 red인가?" — '아니오'면 행위를 안 두드린 헛테스트다. §3 FORM으로 교체한다(존재만으론 FC-2를 못 닫는다) (§2).
- **디코이-불가 FORM을 골라 쓴다**(보장이 *형태*에서 나온다): 구별=집합 크기(`toSet().length==N`·충돌 시 자동 red) / 순서=뒤섞은 입력(≠기대)+`orderedEquals`+양끝 echo / 위치=keyed-slot finder+비대칭·음수 fixture / 탭=non-edge 탭+날짜-echo fake+subtree `findsOneWidget`(`findsWidgets`·`findsAny` 금지). 4형 verbatim은 §3 (§3).
- **생략한다**(테스트하지 않는다): getter·조건 없는 위임·private·위젯 트리 형태·시각 스타일·golden·프레임워크 내부 — 자명/구현-미러는 헛테스트를 부른다 (§4).
- **반송 규율**: 명세-고정(spec-anchored) 테스트가 red면 *코드가 틀린* 것 — 코드를 고친다. 테스트를 약화·삭제해 green 만들지 않는다(discipline-reviewer FORM-감사 대상). 시도 한도 내 green 불가면 보고한다 (§5).

## 상세 레퍼런스

| 질문 | 위치 |
|---|---|
| 왜 테스트하나·회귀 안전망·무게중심 | [`references/final.md`](references/final.md) §1 |
| 오라클을 명세에서 끄는 법·비-vacuity 자가점검 | final.md §2 |
| 단언 FORM 4형 verbatim(구별·순서·위치·탭) | final.md §3 |
| 무엇을 생략하나 | final.md §4 |
| red일 때 코드 vs 테스트·reviewer FORM-감사 | final.md §5 |
| 펌프 결정성·더블·ProviderContainer 셋업 | `implementation-test` |

각 절은 필요한 절만 읽는다(`## §N.` 헤더로 grep 가능 — 전체 로드 불필요).
```

---

## (2) `references/final.md` §3 — 단언 FORM 4형 verbatim

> 디코이-불가를 우선한다. 각 FORM은 5차 양판 실패 1건을 *형태로* 직격한다.

### §3.1 구별(distinctness) — 집합 크기 FORM  *(FC-1 G-7 · FC-3 N4 색 충돌 직격)*

충돌하면 집합이 줄어 **자동 red**. **디코이로 못 쓴다** — 충돌을 "정답"이라 단언하려면 길이를 N 미만으로 적어야 하는데 그건 명세 N과 어긋나 리뷰에서 드러난다(codex가 낸 `clear==cloudy==secondaryContainer`를 "distinct"로 단언한 디코이가 *이 형태에선 작성 불가*).

```dart
test('6개 condition의 listColor가 서로 다르다', () {
  final Set<Color> colors = WeatherCondition.values
      .map((WeatherCondition c) => c.listColor)
      .toSet();
  expect(colors.length, WeatherCondition.values.length); // 충돌 → 집합 축소 → 자동 red
});
```

판정단위(grader A13): 색 *단독* N-distinct면 위 형태. (아이콘,색) *쌍* 단위면 `(c.listIcon, c.listColor)` record의 Set. 명세/골든이 정한 단위를 그대로 쓴다(단위 *선택*은 별도 eval 트랙).

### §3.2 순서(order) — 뒤섞은 입력 ≠ 기대 + `orderedEquals` + 양끝 echo  *(FC-2 M1 정렬 직격)*

현행 §7도 scrambled→`orderedEquals`를 갖지만 M1이 여전히 vacuous였다. 두 가지를 *형태로* 못박는다 — ⓐ입력 순서 ≠ 기대(이미 정렬된 fixture면 무정렬 코드도 green) ⓑ양끝 echo(정렬'됨' 흉내가 아니라 *어느* 순서인지 고정). *(컨테이너/override 셋업 = implementation-test 소유 — 여기선 단언 형태가 초점.)*

```dart
test('정렬: 뒤섞인 입력을 날짜 오름차순으로', () async {
  final List<DateTime> scrambled = <DateTime>[d(3), d(1), d(2)]; // ≠ 기대(하드룰)
  final List<DateTime> expected  = <DateTime>[d(1), d(2), d(3)];
  final List<ForecastSummary> shown =
      await readListVM(_FakeRepo(scrambled)); // 셋업 헬퍼=implementation-test
  final List<DateTime> dates = shown.map((ForecastSummary f) => f.date).toList();
  expect(dates, orderedEquals(expected)); // 전체 순서
  expect(dates.first, expected.first);    // 양끝 echo — '정렬됨' 흉내 차단
  expect(dates.last,  expected.last);
});
```

### §3.3 위치(position) — keyed-slot finder + 비대칭·음수 fixture  *(FC-2 M3 기온 위치 직격)*

디코이 위험 = 대칭 fixture(high==low·둘 다 양수)면 슬롯 스왑·부호 누락이 통과한다. *비대칭 + 음수* + 슬롯 `Key`로 막는다.

```dart
testWidgets('기온: 최고/최저가 각자 슬롯에', (WidgetTester tester) async {
  await pumpDetail(tester, _FakeRepo(high: 7, low: -3)); // 펌프 결정성=implementation-test
  final Text high = tester.widget<Text>(find.byKey(const Key('temp-high')));
  final Text low  = tester.widget<Text>(find.byKey(const Key('temp-low')));
  expect(high.data, contains('7'));
  expect(low.data,  contains('-3')); // 음수: 슬롯 스왑·부호 누락 포착
});
```

주석: high≠low(비대칭)·하나는 음수. 대칭/양수 fixture는 스왑을 못 잡는다. 슬롯은 `Key`로 고정(텍스트 위치 추정 금지).

### §3.4 탭→상세 인자 전달 — non-edge 탭 + 날짜-echo fake + subtree `findsOneWidget`  *(FC-2 M4 탭날짜 직격 · codex 디코이의 정체)*

codex M4 디코이 = `.first` 탭 + 날짜 무관 하드코딩 상세 fake + `findsWidgets`(주간화면 잔존 날짜 텍스트 흡수). 셋을 형태로 막는다 — ⓐnon-edge 탭(`.at(2)`) ⓑ상세 fake가 *탭한 항목의 날짜*를 echo ⓒ상세 subtree 안에서 `findsOneWidget`으로 정확히 1 (**`findsWidgets`·`findsAny` = "≥1" 계열 전부 금지** — 검증 §B).

```dart
testWidgets('탭→상세: 탭한 항목의 날짜가 상세로 전달', (WidgetTester tester) async {
  await pumpList(tester, _FakeRepo(scrambledDates)); // 펌프=implementation-test
  final Finder target = find.byType(ForecastTile).at(2);      // non-edge(.first 금지)
  final DateTime tapped = tester.widget<ForecastTile>(target).summary.date;
  await tester.tap(target);
  await tester.pumpAndSettle();
  final Finder detail = find.byType(ForecastDetailView);
  expect(detail, findsOneWidget);
  expect(
    find.descendant(of: detail, matching: find.text(formatDate(tapped))),
    findsOneWidget, // 날짜-echo: 상세 fake가 탭한 날짜를 되울려야 통과·findsWidgets/findsAny(≥1) 금지
  );
});
```

---

## (3) `references/final.md` §1·§2·§4·§5 골자 (산문 — SKILL.md 불릿의 압축 원본)

- **§1 목적·무게중심**: 회귀 안전망 정의·*수정 모드*가 실사용처·계층 비중표(domain 판정/UseCase/Either 두텁게 > state·VM 전이/정렬·필터/매핑 > UI 핵심 행위만 얇게)·정렬·구별은 도메인 판정(§3.3 소유·VM 아님).
- **§2 오라클·자가점검**: 2단계(명세→기대값 추출, *코드 보지 않고*)·구현-미러링 금지(디코이 뿌리)·비-vacuity 자가점검("로직 한 곳 지우면 red?")·see-it-fail 정신(현행 §7 L226 "머릿속으로 깨봤을 때 red"를 FORM 선택 규율로 격상).
- **§4 생략 목록**: getter·조건 없는 위임·private·위젯 트리 *형태*·시각 스타일·golden·프레임워크 내부(현행 §7 "행위 검증" 정신 유지·정통 합의 — Fowler·SWE@Google·dcm.dev).
- **§5 반송**: spec-anchored red = 코드 수정(테스트 약화 금지)·discipline-reviewer **FORM-감사 렌즈**(핵심 행위가 §3 FORM을 썼나·오라클이 명세서 왔나·`findsWidgets`/대칭 fixture/`.first` 등 디코이 형태 적발)·green 불가면 보고.

## (4) 경계 — `implementation-test`로 가는 것 (§7 메커니즘 부분 흡수)

현행 `implementation-flutter §7`(L224–262)에서 *메커니즘*만 implementation-test로 흡수: `splashFactory: NoSplash`(잉크리플 셰이더 회피)·Timer/`Completer`(loading 누수 회피)·`ProviderContainer.test`/override 셋업·mocktail 더블(`class _FakeRepo extends Mock implements ForecastRepo {}`·codegen 0)·riverpod3 `container.read(p.future)`+`container.pump()`·위 FORM이 쓰는 헬퍼(`pumpList`/`pumpDetail`/`readListVM`/`d()`/`formatDate`). **discipline-test FORM은 *단언 형태*만** — 셋업/펌프/더블은 implementation-test가 소유. §7 절은 제거 → 포인터, 인용 4곳(coder.md·dddart-coder SKILL·implementation-flutter SKILL 표) 동시 갱신.

---

## 구현 worklist (최종 — 적대 리뷰 정정 반영 · 양엔진 미러)

> **0. 선행물(필수·measure-first)**: 코퍼스 수정 *전* `workspace/eval/fix/feedback-008-*.md` 사전등록(각 항목→측정 dim 매핑·예방/비측정 항목 정직 표기). **두 결정(I positive-guide·II 날짜주입) 다 새 기계검사 0 → 백스톱·`_totalChecks`(55)·"55종" 산문 전부 불변.**

1. **신규 스킬 `discipline-test`** (claude `dddart/skills/discipline-test/` + codex `codex-dddart/skills/discipline-test/` **flat**) — `SKILL.md`(짧게) + `references/final.md`(§1~§5·4-FORM verbatim). **SKILL.md 본문에 positive-FORM 한 줄 4종 직접 게재**(references 미열람·프리로드 의미론 미검증 대비 안전판).
2. **신규 스킬 `implementation-test`** (동일 2트리) — `SKILL.md` + `references/final.md`(flutter_test/mocktail/riverpod3 `ProviderContainer.test`·결정성·**날짜 주입 헬퍼·헬퍼 계약 단일 정의**·§7 메커니즘 흡수분).
3. **`implementation-flutter §7` 제거 → 포인터** + **인용 6사이트 동시 갱신**(적대 정정·"4곳"→6): claude `coder.md`(L32)·codex `dddart-coder` SKILL(L31)·claude `implementation-flutter` SKILL(**불릿 L30 + TOC 표 L42**)·codex `implementation-flutter` SKILL(**불릿+표**). + discipline-cleancode references "행위검증 테스트" 산문 정합 점검.
4. **`coder.md`(claude) / `dddart-coder` SKILL(codex)** — 스킬 로드에 2종 추가 + 산출/반송 규율(테스트 = §3 positive FORM 준수·자가점검 의무·spec-anchored red면 코드 수정). **frontmatter+본문 / 산문+산출절 양쪽**(claude=`skills:` L5–10 + 본문 L32·L41 / codex=로드목록 L10–12 + 산출절 L31).
5. **`discipline-houserules`**(트리 소유자·**`file-tree.md` 아님·적대 정정**) — `references/final.md` §1(표준 트리에 `test/`=lib/ 루트 형제)·§3(골격완비표에 *test/ sparse 예외*·"선택 폴더 없음"의 명시적 예외) + `SKILL.md` §1/§3. **+ Key 짝 규약**(architecture-ui와): keyed-slot 단언 위젯은 생성 시 안정 `Key` 부착·tile 공개 표면(관찰 가능 값) 계약 — §3.3/§3.4 FORM이 실코드와 맞물리게.
6. **`discipline-reviewer.md`**(claude agent) + **`dddart-discipline-reviewer` SKILL**(codex) — **positive FORM-사용 감사 렌즈**(§3 FORM 사용·오라클 명세 출처·구별 입력+정확·좁은 단언 확인 — 금지 적발 아닌 *올바른 모양 확인*). 백스톱 무변경.
7. **시간-결정성 = 날짜 주입 규약**(게이트 없음·결정 II) — `discipline-test`/`architecture-ddd` references 한 줄: "도메인 판정은 기준일을 *인자로 받는 순수 함수*·'지금'은 edge의 오버라이드 가능 provider/인자로 격리·테스트는 고정 날짜 주입". clock·백스톱·`_totalChecks` 변경 없음.
8. **§3.1 색 단위 고정**(적대 정정·positive-spec) — references에 "색 *단독* N distinct"로 명시(=(아이콘,색) 쌍 우회 차단). + **(선택·코퍼스 아님)** 설계 아카이브 `workspace/design/2026-06-11-dddart-file-tree.md` §9-5/13/15 '테스트 없음' 갱신(이력 정합·로드 대상 아님).

**빌드 전 휘발성 확인**: `skills:` 프리로드가 SKILL.md *전문* 주입인지 1차 출처 재확인(아니면 item 1의 SKILL.md 본문 positive-FORM 안전판 작동).
**미러**: SKILL/agents/commands = 수동 양판 · `references/final.md` = `corpus_mirror_sync.py`가 신규 스킬 자동 발견(claude↔codex byte-exact) · scripts = 수동 cp(단 `run_fixtures.sh`는 claude 전용 메인테이너 도구·codex 미러 없음=기존 비대칭). **코퍼스 수정 = 별도 사용자 승인 후.**

## 적대 리뷰 결과 (5렌즈 · 읽기전용 · 토큰 ~604k) — 반영분

- **헤드라인**: "무엇을 테스트" + 테스트먼저 + 배치강제로는 vacuity 안 닫힘 — §7에 이미 정답이 있었고 coder가 그래도 디코이를 냈다. 실패 = *FORM + 강제*.
- **결정급 변경 3건**: (a) 스킬에 구체 오라클 FORM verbatim 탑재 / (b) '테스트 먼저' 폐기(bottom-up+codegen 실행불가) / (c) mutation '~90% 기성'은 과장 → 009 조건부 미룸. 대신 자가집행 FORM + reviewer FORM-감사.
- **기타**: 미러 배치 blocker 강등(vacuity와 직교) · file-tree/houserules 모순 선수정 · 듀얼배포 6+사이트 체크리스트 · TG 패밀리 유지(`_totalChecks` 55 **불변** — 시간 가드 철회·결정 II·새 기계검사 0) · 스킬 경계 재절단(FORM=오라클과 함께 discipline-test·결정성/Dart=implementation-test) · SKILL.md 짧게+TOC.
- **렌즈3(공식문서)**: `skills:` 프리로드 = SKILL.md 전문 주입(references는 on-demand) → SKILL.md 진짜 짧게 + references TOC.

## 적대 리뷰 2차 — 설계문서 자체 (5렌즈 서브에이전트·읽기전용·2026-06-17·~390k subagent tokens)

5렌즈(skill-creator·이중배포·기술정확성·소비성·YAGNI)로 이 문서를 적대 검증. 핵심 질문 = "이 설계가 §7 실패를 *진짜* 다른가."

### 살아남은 강점 (적대 검증 후에도 견고)
- **핵심 진단 사실 확인**: §7(L224–262)에 자가점검·scrambled→`orderedEquals`·tap→`findsOneWidget`이 실재하는데 5차에서 무시됨 — "실패=커버리지 아닌 FORM+강제" 전제는 원문 대조로 사실.
- **기술 사실 정확**: matcher 표(`findsWidgets`≡`findsAny`="≥1"·`findsOneWidget` 非deprecated)·riverpod3(`ProviderContainer.test`·`read(.future)`+`pump`·`overrideWithBuild(ref,self)`)·mocktail·clock 전부 공식 문서 검증 일치. 세션 중 과장 2건 자진정정도 옳음.
- **survey 정당**: §I·§J·생태계표·golden 제외는 worklist를 안 늘리는 references 토대조사(scope creep 아님).

### 🔴 핵심 비판 — floor가 과대표상됐다 (소비성·YAGNI 렌즈 교차)
1. **기계 강제는 사실상 §3.1뿐, 그것도 조건부**: §3.2(순서)·§3.3(위치)·§3.4(탭)·§5(반송·자가점검)은 100% coder 선의 의존 = **§7의 양적 확대**(`.first`로·`findsWidgets`로·scrambled을 정렬입력으로 되돌리면 디코이 부활). 헤드라인 L15("자가집행 FORM으로 floor↑")가 L282(정직: "toSet은 G-7만 기계보장")와 불일치 — **FC-2(M1/M3/M4)는 기계 floor 0.**
2. **§3.1 toSet도 디코이 가능 — 판정단위 구멍**: 5차 claude 변호가 정확히 "(아이콘,색) *쌍*은 distinct". `(icon,color).toSet().length==6`은 색이 clear==cloudy 충돌해도 아이콘이 다르면 통과. **단위를 eval로 미뤘기 때문에 이번 회차 §3.1은 5차 색충돌(G-7/N4)을 보장 차단 못 함** → 검토포인트 ⓑ가 가장 약한 지점.
3. **discipline-reviewer FORM-감사 = LLM-on-LLM·5차 재판**: reviewer는 5차에 *이미 있었고* M1·M3 vacuous를 통과시켰다. "디코이 렌즈 산문"을 더하는 게 왜 이번엔 작동하는지 기계 근거 없음. 한편 `.first`/`findsWidgets`/`findsAny`/`unorderedEquals`는 **결정적 grep으로 100% 잡힌다** — LLM 판단에 맡길 이유가 없는 걸 맡김.

### 핵심 처방 (재평가 — 2026-06-17 사용자 결정 반영·grep 채택 안 함)
리뷰는 "test/ 디코이-form 백스톱 grep"을 유일한 기계 레버로 제시했으나 **채택하지 않는다**: ⓐ디코이 방법이 *열려 있어*(findsWidgets만의 문제 아님) 블랙리스트는 불완전 ⓑ findsWidgets/`.first`는 정당한 용도도 있어 단순 grep은 **오탐** ⓒ기성 lint 없음(DCM=타입 오용·유료). → **positive FORM 가이드 강화**로 전환("이렇게 해라"가 닫힌 처방·나쁜 패턴을 열거 없이 배제). reviewer는 **positive 감사**(올바른 FORM 사용·오라클 명세 출처). *정직: 이번 회차 비-vacuity floor = 가이드+reviewer(기계 아님)·§7 재판 위험 잔존을 감수하고 measure-first로 승격 판단(다음 런 디코이 재발 시 custom_lint/작성자분리).*

### 결정 진행 (2026-06-17 사용자 응답)
- **(결정 II) ✅ 확정 = 시간 가드 철회 · 날짜 주입 채택**: 백스톱 `DateTime.now()` 게이트·`clock` 의존·`_totalChecks` 변경 **전부 철회**. 대신 **날짜 주입 규약** — 도메인 판정은 *순수 함수*(기준일을 인자로 받음)·'지금' 읽기는 edge의 오버라이드 가능 provider/인자로 격리·테스트는 고정 날짜 주입. references 한 줄 규약(discipline-test/architecture-ddd)·**게이트 없음**·clock 패키지 불필요(더 깔끔). 실제 'now' 쓰는 BC가 런에 등장하면 그때 재고.
- **(결정 I) ✅ 확정 = positive FORM 가이드 강화 · 백스톱/grep/lint 철회**(사용자 2026-06-17). 근거: 디코이/헛테스트 방법은 *열려 있어*(findsWidgets만의 문제 아님) 블랙리스트는 두더지잡기·오탐(정당한 용도도 있음)·기성 lint 없음(DCM `avoid-misused-test-matchers`=타입 오용만·유료 pro+) → 기계적 금지는 실효 낮음. 대신 **"이렇게 해라" positive FORM을 기본값으로** — 나쁜 패턴은 *열거 없이* 배제(§3.4 "상세 subtree서 정확히 그 날짜 `findsOneWidget`"이면 `findsWidgets`에 손이 안 감). **자료조사 확정(왜 나쁜지)**: `findsWidgets`=`findsAny`="≥1"→주변/중복 위젯 흡수(M4 정체)·공식/업계 "정확 개수(`findsOne`/`findsExactly`)가 더 강함"·`.first`="byType 아무거나→의도 아닌 탭" 함정. **정직한 floor**: positive 가이드+reviewer는 *기계 보장 아님*(TG1 존재검사만 기계)→§7 재판 위험 잔존. §7보다 나은 점 = 전용 task-scoped 스킬(묻힘 해소)·"예시 아닌 *요구 형태*"·자가점검 의무화·reviewer positive 감사. → 다음 런 FC-2/3 실측·디코이 재발 시 custom_lint/작성자분리(acceptance-tester)로 승격(measure-first).

### 확정 정정 — 사실 오류 (결정과 무관·적용 예정)
- **worklist 6 타깃 오류**: `file-tree.md §9-5/§13/§15`는 **코퍼스에 없음**(workspace 설계 아카이브에만). 실제 트리 규약 = `discipline-houserules/references/final.md` §1~§8(§9-5 없음)·**houserules는 test/를 아예 안 다룸**. → 진짜 편집 = houserules final.md §1(트리에 test/=lib 형제)+§3(골격완비에 test/ sparse 예외). "모순→stall"은 약화(모순 텍스트가 코퍼스에 없음)·진짜 갭은 *test/ 규약 부재*.
- **positive-control 경로 오류**: `tools/positive-control` **없음**. 실제 = `scripts/test/run_fixtures.sh`(현 F1~F12·F13이 다음). 단 **run_fixtures.sh는 codex 미러 부재**(claude 전용 메인테이너 도구 가능성·"scripts=cp"의 예외로 결정·명시 필요).
- **"인용 4곳"→실제 6사이트**: claude `coder.md:32` · codex `dddart-coder` SKILL:31 · claude impl-flutter SKILL **불릿 L30+표 L42** · codex impl-flutter SKILL **불릿+표** + discipline-cleancode references "행위검증 테스트" 산문 정합 점검.
- **codex `skills:` 자동주입 없음**: codex는 frontmatter 프리로드가 아니라 `dddart-coder` SKILL **산문 "로드할 지식 스킬"** self-load(`codex-dddart/README.md:19`). → 신규 2스킬을 그 산문 목록에 명시 추가·codex FORM 전달은 self-load 의존(약한 고리)→reviewer/백스톱이 진짜 방어.
- **`skills:` 전문주입 가정 미검증**: SKILL.md가 전문 주입인지 name+desc만인지 출처 없음 → **build 시 1차 출처 확인**. 미열람 대비 SKILL.md 본문에 *디코이 금지 한 줄*(`.first`/`findsWidgets` 금지)을 올린다.
- **Key/.summary 짝 규약 부재**(§3.3/§3.4): 테스트가 `Key('temp-high')`/`.summary`를 단언하는데 *생성 코드가 그 Key를 단다*는 강제가 없음 → coder가 Key 누락 시 finder 실패→테스트 약화 유혹. → architecture-ui/houserules에 "keyed-slot 단언 위젯은 안정 Key 부착" 짝 규약 추가.
- **Clock.fixed 실재**: `Clock.fixed(DateTime)` 공식 실재 확인 → §G 헤지 제거·`Clock(()=>…)`(flaky 백도어) 대신 `Clock.fixed(DateTime(…))`. (시간 가드 유지 시만.)
- **`_totalChecks` family 미지정 + "55종" 산문 4곳**: 새 검사는 TG 아닌 NM/ST류 → family·ID 지정·주석 공식 갱신 필요. "검사 55종" 하드코딩 4곳(`discipline-reviewer.md`·`dddart.md`·codex `dddart` SKILL·codex `dddart-discipline-reviewer` SKILL) 동기. (검사 추가 시만.)
- **measure-first 절차**: `feedback-008-*.md` 사전등록을 **코퍼스 수정 *전* 필수 선행물**로·각 worklist→측정 dim 매핑(측정 없는 항목 정직 표기).

> **종합**: 본체(스킬 2종·FORM·§7 이전·인용 갱신·houserules/file-tree·reviewer = worklist 1–7 중 디코이 본체)는 응집·타당. 단 (1) "기계 floor" 주장을 **test/ 디코이-form 백스톱 grep**으로 실제 기계화해야 §7 재판을 면하고, (2) **시간 가드(8)는 분리/철회**가 measure-first에 맞으며, (3) §3.1 **단위 고정**과 다수 **타깃 정정**이 필요. 결정 I·II 확정 후 worklist 재작성.

## 검증 / 사전등록

- **결정적 부분**(백스톱 TG·신설 규칙)은 `dddart/scripts/test/run_fixtures.sh` fixture로 green 확인. 신설 백스톱 규칙은 `tools/positive-control`로 거짓-FAIL 반증 후 투입.
- **비-vacuity/디코이 실효**는 **다음 라이브런 FC-2(M1·M3·M4)·FC-3(G-7 색) 실측**(사용자 드라이브). 자가집행 `toSet` FORM은 G-7을 *기계 보장*.
- `workspace/eval/fix/feedback-008-*.md`에 **예상효과 사전등록**(고치기 전 "다음 런에서 어느 dim이 전→후로 바뀌어야 성공"을 박음). 부족 시 009 mutation.

## 검토 포인트 (사용자 확인 요청)

- **ⓐ** SKILL.md가 충분히 짧은가(프리로드 = 전문 주입·렌즈3) — 표만으로 FORM 위치를 찾는 구조가 맞나.
- **ⓑ** 4 FORM이 5차 실패(G-7·N4·M1·M3·M4)를 *형태로* 막나 — 특히 §3.1 `toSet().length==N`이 디코이-불가인 점.
- **ⓒ** FORM = discipline-test(오라클과 함께) / 셋업·펌프 = implementation-test 경계가 맞나.
- **ⓓ** helper 이름(`pumpList`·`readListVM`·`_FakeRepo`·slot `Key('temp-high')`)을 implementation-test 표준 관용구로 확정할지(implementation-test 초안 단계에서).
