# 테스트 표기법 — flutter_test·mocktail·riverpod 3.x·결정성

> **출처:** flutter_test/package:test(flutter.dev·dart.dev 번들)·package:matcher(dart.dev — `orderedEquals`·`isA().having`)·riverpod 3.x(github.com/rrousselgit/riverpod — `ProviderContainer.test`·`read(.future)`+`pump`·`overrideWithBuild`)·mocktail(github.com/felangel/mocktail — 코드젠 0)·fake_async+clock(dart.dev)·mocktail_image_network·alchemist/patrol(생태 비교) — 2026-06-17 확인, 지표·URL은 작업장 `2026-06-17-test-strategy-design.md` §검증 자료조사 C~J.
> 본문은 implementation-flutter §7(셰이더·Timer·provider override 가짜 주입)을 흡수해 riverpod 3.x·mocktail로 갱신한 것이다. 무엇을 테스트할지·단언 FORM은 discipline-test, 위젯 수명·async gap context는 implementation-flutter §6으로 위임한다.

---

## 목차

- §1. 패키지 라인 — 왜 mocktail인가
- §2. 격리 — ProviderContainer.test·async·override (riverpod 3.x)
- §3. 더블 — mocktail·matcher 어휘
- §4. 위젯 펌프 결정성 — NoSplash·Timer/Completer
- §5. 날짜·시간 결정성 — 주입
- §6. 네트워크 이미지 목 — 조건부
- §7. 헬퍼 계약 — 단일 정의
- §8. 안 쓰는 것 — golden·patrol·mockito·mutation

---

## §1. 패키지 라인 — 왜 mocktail인가

- `flutter_test`·`package:test`(SDK 번들)·`package:matcher`(matcher 어휘) — 토대.
- `flutter_riverpod` 3.x(VM/provider 격리 — `ProviderContainer.test`는 3.x).
- **`mocktail`**(더블 — `dev_dependencies`): **코드젠 0**이라 채택한다. dddart는 이미 build_runner를 riverpod/freezed/hive에 돌리므로 *목까지* 코드젠(`mockito`는 null-safe에 `@GenerateNiceMocks`+build_runner→`.mocks.dart` 필수)을 더하면 생성 파이프라인 결정성이 나빠진다. mocktail은 `extends Mock implements X`로 코드젠 없이 목을 만든다(§8 mockito 주석-제외).
- (조건부) `mocktail_image_network`(네트워크 이미지 view일 때 — §6).
- 버전 값은 훈련 기억으로 적지 않는다 — 무핀 설치(`flutter pub add dev:<pkg>`)로 resolve된 실버전을 `dev_dependencies`에 핀한다(coder 경계 규율과 동일). 테스트 의존은 전부 dev.

## §2. 격리 seam — dddart no-DI에서 가짜 주입

dddart는 **DI 없음**이다(architecture-state §10 "DI 없음"): UseCase·Repo·DataSource는 plain class라 VM이 `UseCase()`로 직접 생성하고, `@riverpod` provider는 **상태 보유 VM 변종만**(VM·SharedState·Service·root) 된다. → **`repoProvider`·`useCaseProvider`는 존재하지 않으므로 override할 수 없다**(백스톱 NM가 그런 provider를 차단). seam은 셋뿐이다:

- **(A) 순수 도메인 직접** — 판정(구별·정렬·도메인 양갈래·계산)은 도메인 단위(애그리거트 메서드·domain_service·specification·enum extension)라 입력을 인자로 받는다. 그것을 *직접 생성·호출*하고 단언한다(provider·위젯 불요). discipline-test §3.1·§3.2·§3.5가 이 seam — thick domain 무게중심이 여기다.
- **(B) VM provider override** — view 행위(렌더·탭)는 화면 VM을 *통제된 State로* 갈아끼워 검증한다. VM은 provider라 override 가능하다:

```dart
await tester.pumpWidget(ProviderScope(
  overrides: <Override>[
    forecastDetailVMProvider.overrideWith(() => _FakeDetailVM(detailState(high: 7, low: -3))),
  ],
  child: MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory), // §4
    home: const ForecastDetailView(),
  ),
));
await tester.pumpAndSettle();
```

`overrideWith(() => notifier)`(notifier 교체) · `overrideWithBuild((ref, self) => x)`(3.x — build만 목·메서드 보존). VM이 family(예: 날짜 키)면 override가 그 family 인자를 *echo*하게 만들어 "전달된 인자"를 검증한다(discipline-test §3.4 탭 FORM의 날짜-echo).

- **(C) Dio 목 (seam C·통합·드물게)** — *실제* VM/UseCase 스택을 통제된 서버 데이터로 끝까지 돌릴 때만. Repo가 `DataSource(DioClient.instance)`를 직접 생성하므로 seam은 **Dio 계층**이다: 테스트가 `DioClient`에 목 `Dio`(dio `MockAdapter` 또는 mocktail §3)를 꽂는다. 무게중심이 아니다(공식 정전 = unit/widget 두텁게) — 판정은 (A), view는 (B)로 덮고 (C)는 정말 필요한 통합 1~2건에 한정한다.

VM의 async 상태를 *단위*로 볼 땐 `ProviderContainer.test()`(riverpod 3.x — 종료 시 자동 dispose·구형 `ProviderContainer()`+`addTearDown(container.dispose)`도 유효)로 격리해 `await container.read(vm.future)` 후 `.value`, 상태 전이는 `await container.pump()` 후 `.isLoading`/`.value`를 단언한다 — 단 *통제된 입력*이 필요하면 위 (B) override나 (C) Dio 목을 함께 쓴다(repo override는 불가).

## §3. 더블 — mocktail·matcher 어휘

순수 도메인 테스트(seam A)는 *값*을 넣지 더블이 거의 없다. 더블이 필요한 곳은 (C) Dio 목과, (B)에서 호출을 검증하는 fake VM 정도다. **mocktail**(코드젠 0 — 이미 도는 build_runner에 목 코드젠을 더하지 않는다):

```dart
class _MockDio extends Mock implements Dio {}                  // (C) Dio 계층 목 — DioClient에 주입
class _FakeForecast extends Fake implements Forecast {}        // any()용 fallback 타입

setUpAll(() => registerFallbackValue(_FakeForecast()));        // 커스텀 타입을 any()로 쓸 때 1회
// ...
when(() => dio.get(any())).thenAnswer((_) async => Response<dynamic>(/* … */)); // 클로저 형식(mockito와 다름)
verify(() => dio.get('/forecast')).called(1);                  // 호출 검증 · verifyNever(() => ...)
```

- `class X extends Mock implements Y {}`(상호작용 검증) · `class X extends Fake implements Y {}`(고정 반환). 매처 `any()`·`any(named: 'arg')`·`any(that: matcher)`. (mockito와 달리 클로저 형식·코드젠 0.)
- **package:matcher 어휘**(단언 FORM의 도구 — 형태 규율은 discipline-test §3): 동등 `equals` · 순서 있는 컬렉션 `orderedEquals` · 길이 `hasLength` · 타입+필드 `isA<T>().having((T x) => x.field, 'field', expected)` · 예외 `throwsA`·정상 종료 `returnsNormally`. Either 양갈래는 `isA<Right<BadRequestResponse, T>>().having((Right<BadRequestResponse, T> r) => r.value, 'value', expected)` / `isA<Left<BadRequestResponse, T>>()`(discipline-test §3.5 — Left=`BadRequestResponse`는 네트워크 실패라 (C) seam과 함께).

## §4. 위젯 펌프 결정성 — NoSplash·Timer/Completer

**잉크리플 셰이더 회피**: 탭/리플을 그리는 위젯을 펌프하면 테스트 환경에 `ink_sparkle.frag` 셰이더가 없어 실패할 수 있다(앱 결함 아님). 테스트 테마에 `splashFactory: NoSplash.splashFactory`를 주면 그 경로를 안 탄다(앱 동작 불변·결정성 확보):

```dart
await tester.pumpWidget(ProviderScope(
  overrides: <Override>[forecastListVMProvider.overrideWith(() => _FakeListVM(listState(week)))], // VM override(§2 seam B)
  child: MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory), // ink_sparkle 회피
    home: const ForecastListView(),
  ),
));
await tester.pumpAndSettle();
```

**Timer 누수 회피**: 영원히 안 끝나는 future를 펌프한 채 두면 `Timer still pending`으로 dispose가 실패한다(테스트 하니스 결함·환경 아님). loading은 (a) 완료되는 `Completer`를 만들어 완료시킨 뒤 `pumpAndSettle`로 검증하거나 (b) VM의 `AsyncLoading` 상태를 단위로 검증한다 — *미완료 future를 펌프한 채 두지 않는다*. Timer/microtask 진행 자체가 필요하면 `fakeAsync((async) { …; async.elapse(d); })`로 결정적으로 진행한다(`pumpAndSettle` 무한대기 회피와 병행).

## §5. 날짜·시간 결정성 — 주입

시간 의존 테스트는 pre-commit에서 *무관한 날*에 깨진다(테스트 수행 시각에 통과 여부가 달라지면 결함이다). dddart는 시간을 **주입**으로만 들인다(게이트 없음·`clock` 패키지 불필요):

- **도메인 판정은 순수 함수** — '오늘'·'기준일'을 *인자로 받는다*(`bool isStale(DateTime now)` 식). 도메인 안에서 `DateTime.now()`를 직접 부르지 않는다.
- **'지금'이 실제로 필요한 edge**(부팅 시각 등)는 오버라이드 가능한 provider/인자로 격리한다 — 테스트는 그 provider를 고정 값으로 override한다.
- **테스트는 고정 `DateTime`을 주입한다**: `final DateTime base = DateTime(2026, 6, 17); ...` — 실시각을 읽지 않으므로 어느 날 돌려도 결과가 같다.

```dart
test('만료 판정: 기준일로부터 7일 경과면 stale', () {
  final DateTime base = DateTime(2026, 6, 17);          // 고정 주입 — 실시각 무관
  expect(forecast(updatedAt: base).isStale(base.add(const Duration(days: 8))), isTrue);
  expect(forecast(updatedAt: base).isStale(base.add(const Duration(days: 6))), isFalse);
});
```

(`fake_async`는 `DateTime.now()`를 제어하지 못한다 — 코드가 `clock.now()`를 써야만 오버라이드된다. dddart는 그 결합을 만들지 않고 *인자 주입*으로 푼다. 실제 `clock.now()`를 쓰는 BC가 등장하면 그때 재고한다.)

## §6. 네트워크 이미지 목 — 조건부

테스트 바인딩(`TestWidgetsFlutterBinding`)에선 모든 HTTP가 **400**으로 떨어져 `Image.network`가 `NetworkImageLoadException`으로 위젯 테스트를 크래시낸다(앱 결함 아님). view가 네트워크 이미지를 그리면 펌프를 감싼다:

```dart
await mockNetworkImages(() async {
  await tester.pumpWidget(/* … Image.network 포함 화면 … */);
  await tester.pumpAndSettle();
});
```

- weather 아이콘이 `IconData`(폰트 아이콘)면 미해당이다 — 네트워크 이미지를 *그리는* view에서만 발동하는 일반 함정이다. `mocktail_image_network`(mocktail과 짝).

## §7. 헬퍼 계약 — 단일 정의

discipline-test §3 FORM이 쓰는 헬퍼의 *계약*을 여기서 정의한다(이름은 weather 예시 — BC에 맞춰 환언하되 계약은 유지). 같은 헬퍼를 테스트 파일마다 재정의하지 말고 `test/<bc>/_support.dart` 식 한 곳에 둔다:

| 헬퍼 | 계약(반환·역할) |
|---|---|
| `DateTime d(int dayOffset)` | 고정 기준일 + dayOffset일 — 정렬 fixture를 *뒤섞어* 만든다(§3.2·실시각 무관 §5). |
| `ForecastSummary fc(DateTime date)` | 도메인 요약 값 빌더 — 순수 도메인 테스트(seam A)의 입력. 더블 아님(값). |
| `ForecastDetailState detailState({required int high, required int low})` · `ForecastListState listState(List<ForecastSummary> week)` | 통제된 State 빌더 — VM override(seam B)가 yield할 State. |
| `_FakeListVM` · `_FakeDetailVM` | 화면 VM의 Notifier 하위 — 고정 State를 build에서 반환(seam B). detail fake는 *받은(navigated) 날짜를 echo*하도록 만든다(§3.4 날짜-echo). |
| `Future<void> pumpList(WidgetTester t, List<ForecastSummary> week)` | 목록 화면을 NoSplash 테마(§4)로 펌프 + 목록 VM override(week) + 상세 VM override(날짜 echo). week는 **≥3**(§3.4 `.at(2)` 전제). |
| `Future<void> pumpDetail(WidgetTester t, ForecastDetailState state)` | 상세 화면 펌프 + 상세 VM override(state) — 위치 FORM(§3.3). |
| `String formatDate(DateTime d)` · `String formatTemp(int celsius)` | 화면 표기와 *동일한* 포맷 — §3.4 날짜-echo·§3.3 기온 정확 일치. **SUT 포맷터를 재사용**한다(별도 포맷을 만들면 디코이). |
| `final Map<String, ScreenProbe> screenProbes` (`typedef ScreenProbe = Future<Finder> Function(WidgetTester)`) | **FID 렌더 덤프 진입점**(eval 평가측이 소비). role 문자열(`'list'`·`'detail'`…)→그 화면을 *대표 fixture로* 펌프하고 루트 finder를 반환하는 함수. view 클래스명·헬퍼명·fixture명을 전부 *맵 값 안에* 가둬 외부 덤프 프로브가 BC 이름에 의존하지 않게 한다 — 화면마다 한 항목, 화면 추가 시 여기 등록. 기존 `pumpList`/`pumpDetail`·`detailState` 위에 얇게 얹는다(중복 펌프 정의 금지). |

`screenProbes`는 §7에서 **유일하게 discipline-test FORM이 직접 소비하지 않는** 헬퍼다(테스트 단언이 부르지 않음) — eval FID 평가측 렌더 덤프가 이 한 맵만 상대 import해 산출물의 모든 화면을 *배선 추론 0*으로 일관 덤프한다. "모든 화면이 대표 데이터로 펌프된다"는 render-smoke 시드를 겸한다. 키는 화면 role로 고정하고, 값에서 BC별 view·헬퍼 이름을 환언한다(그 이름들이 밖으로 새지 않는 게 핵심):

```dart
typedef ScreenProbe = Future<Finder> Function(WidgetTester tester);

/// role → 대표 fixture로 그 화면을 펌프하고 루트 finder를 반환. 화면 추가 시 여기 등록.
final Map<String, ScreenProbe> screenProbes = <String, ScreenProbe>{
  'list':   (WidgetTester t) async { await pumpList(t, fixtureWeek());                return find.byType(ForecastListView); },
  'detail': (WidgetTester t) async { await pumpDetail(t, detailState(high: 28, low: 19)); return find.byType(ForecastDetailView); },
};
```

`_FakeRepo`·`readListVM`(구 repo-seam 헬퍼)은 폐기한다 — dddart엔 repo provider가 없다(§2). 정렬은 도메인 단위를 직접 호출하므로(§3.2) VM 격리 헬퍼가 불요하다.

## §8. 안 쓰는 것 — golden·patrol·mockito·mutation

- **golden/스크린샷**(`matchesGoldenFile`·`alchemist`) — **비채택**. 시각 충실도는 인간 오라클이 본다(G2 배너). 골든 도구 자체가 폰트/플랫폼 비결정을 인정(alchemist가 텍스트를 색 블록으로 치환)하는 점이 생성 파이프라인 결정성과 상충한다.
- **patrol**(네이티브 러너) — 주석-제외. 네이티브 다이얼로그/권한이 필요할 때만 옵션이나 **CI 불안정**("avoid unless willing to debug CI failures"). integration은 필요 시 1st-party `integration_test`로 *얇게*(공식 정전 = unit/widget 두텁게).
- **mockito** — 주석-제외. null-safe에 코드젠 필수(§1) — mocktail이 그 코드젠을 없앤다.
- **mutation**(`mutation_test`·`dart_mutant`) — 이번 회차 비채택(009 조건부). generic 연산자/불리언 변이라 "두 enum case가 색을 공유" 같은 *도메인 의미* 변이는 생성하지 않고 변이마다 테스트 1회라 느리다 — 색 distinctness는 §3.1 집합-크기 FORM이 직접 보장한다.
