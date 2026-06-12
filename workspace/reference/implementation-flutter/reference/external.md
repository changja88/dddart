> **[dddart 원료 메모]** 외부 조사 — implementation-flutter 담당. 출처: 공식 문서·공식 저장소(pub.dev / api.flutter.dev / dart.dev / flutter·packages·cfug·IO-Design-Team GitHub) + 로컬 설치 Flutter SDK 3.44.1 stable 소스 직독(`/opt/homebrew/share/flutter`). **확인일 전부 2026-06-12** (WebFetch/WebSearch·GitHub API·SDK 소스로 실측 — 기억 서술 아님). 각 절 말미에 출처 표기.
> 버전 기준: HaffHaff-App pubspec.lock 실측(go_router 16.2.4 · dio 5.9.0 · retrofit 4.7.3 + retrofit_generator 10.0.0 · hive_ce 2.14.0 + hive_ce_flutter 2.3.2 + hive_ce_generator 1.9.3 · flutter_riverpod 3.0.1). 코드 예제는 이 라인에서 idiomatic·컴파일 정합하게 작성.
> **충돌 발견 2건**: §5.4(hive_ce `@GenerateAdapters` 패키지당 1파일 강제 — data §5 BC별 선언 규약과 충돌), §2.3(셸 위 단일 PrimaryScrollController 공급은 라우트별 PSC에 가려져 동작 불가 — 규약 §9-11 대체표의 소박한 독해 기각). 상세는 해당 절과 §7.

---

## 0. 버전 확정 (2026-06-12 pub.dev 실측)

| 패키지 | pub.dev 최신 | HaffHaff lock | 코퍼스 기준 |
|---|---|---|---|
| go_router | **17.3.0** (17.x 라인) | 16.2.4 | **16.x로 작성** — 17.0.0 breaking은 §1.7 메모 |
| dio | 5.9.2 | 5.9.0 | 5.x ✓ |
| retrofit / retrofit_generator | 4.9.2 / 10.x | 4.7.3 / 10.0.0 | 4.x / 10.x ✓ |
| hive_ce / hive_ce_flutter | 2.19.3 / 2.3.4 | 2.14.0 / 2.3.2 | 2.x ✓ |
| flutter_riverpod | **3.3.2 (정식 stable)** | 3.0.1 | **riverpod 3.0 정식 출시 확정** — 베이스라인의 "3.0.0-dev.17, 정식 여부 조사 확정" 질문에 대한 답. 표기는 implementation-riverpod 소유 |
| Flutter SDK | — | 로컬 3.44.1 stable (2026-05-29) | 프레임워크 소스 인용 기준 |

출처: https://pub.dev/packages/go_router · /dio · /retrofit · /hive_ce · /hive_ce_flutter · /flutter_riverpod (각 페이지 최신 버전 표기), HaffHaff-App pubspec.lock, `flutter --version`.

## 1. go_router 16.x — 라우트 정의·이동·셸·redirect·전환

### 1.1 GoRoute — path·name·builder·pageBuilder

```dart
GoRoute(
  path: '/users/:userId',          // ':' 접두 = path parameter
  name: 'user',                    // 이름 — goNamed/pushNamed의 키
  builder: (context, state) => UserView(id: state.pathParameters['userId']!),
  routes: [ /* 자식 라우트 — 위에 쌓이는 화면(push와 동일 동작) */ ],
),
```

- `state.pathParameters['userId']` — 경로 파라미터, `state.uri.queryParameters['filter']` — 쿼리 파라미터.
- 라우트당 `builder` **또는** `pageBuilder` 하나는 필수. `pageBuilder`는 Page 객체를 직접 반환해 전환 애니메이션을 제어한다(§1.5). 탭 화면처럼 전환 없는 라우트는 `pageBuilder: (c, s) => NoTransitionPage(child: ...)`.
- 라우트 수준 `redirect`도 있다 — "해당 라우트를 표시하려는 시점에" 호출(top-level과 별개, §1.4).

### 1.2 이동 — go vs push, goNamed/pushNamed

공식 의미론: **go = 현재 화면 스택을 그 목적지의 화면 구성으로 교체**("Navigating to a destination in GoRouter will replace the current stack of screens"), **push = 스택 위에 쌓기**.

```dart
context.go('/users/123');
context.push('/users/123');

// 이름 기반 — 경로 철자를 호출부가 모름 (dddart navigator의 채널)
context.goNamed('user', pathParameters: {'userId': '123'});
context.pushNamed('user', pathParameters: {'userId': '123'},
    queryParameters: {'filter': 'abc'});

// 이름 → location 문자열 해소 (redirect 등에서)
final location = context.namedLocation('user', pathParameters: {'userId': '123'});
```

### 1.3 StatefulShellRoute.indexedStack — 탭 셸

분기(branch)마다 **별도 Navigator**를 가진 상태 보존 중첩 내비게이션. `indexedStack` 생성자는 분기들을 IndexedStack으로 담는 기본 구현이며 표준 탭 UI에 권장.

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      RootView(navigationShell: navigationShell), // 셸 UI — dddart의 root_view
  branches: [
    StatefulShellBranch(
      navigatorKey: homeNavigatorKey, // 선택 — 다른 곳에서 필요할 때만
      routes: [GoRoute(path: '/home', pageBuilder: ...)],
    ),
    StatefulShellBranch(routes: [GoRoute(path: '/feed', pageBuilder: ...)]),
  ],
)

// 셸 위젯 — Scaffold body = navigationShell
Scaffold(
  body: navigationShell,
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: navigationShell.currentIndex,
    onTap: (index) => navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex, // §2.1
    ),
  ),
)
```

- `StatefulShellBranch` 파라미터: `routes`(필수)·`navigatorKey`·`initialLocation`·`observers`("이 분기의 옵저버" — §2.4 패턴 B의 발판)·`restorationScopeId`·`preload`(첫 진입 시 분기 미리 로드, 기본 false).
- `StatefulShellBranch.initialLocation` 미지정 시 "첫 자손 GoRoute의 location"이 기본(defaultRoute).
- 탭 인덱스 상태는 셸이 보유(`navigationShell.currentIndex`) — 별도 상태 보관 불필요.

### 1.4 top-level redirect

```dart
GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    // FutureOr<String?> — null 반환 = 리다이렉트 없음(그대로 표시)
    if (!isSignedIn) return '/signin';
    return null;
  },
  redirectLimit: 5, // 기본 5 — 초과 시 에러
  routes: [...],
)
```

- top-level redirect는 "**모든** 내비게이션 이벤트 전에" 호출 — 인증·강제업데이트 게이트의 표준 자리. 라우트 수준 redirect는 그 라우트 표시 직전에만.
- 시그니처가 `BuildContext`를 받지만, dddart처럼 redirect 안에서 상태를 UseCase 직접 호출로 얻는 방식은 context 비사용으로 성립(§1.6과 같은 축).

### 1.5 CustomTransitionPage — 공식 예제 그대로

```dart
GoRoute(
  path: 'details',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey, // 공식 예제 표기 — 페이지 동일성 키
    child: const DetailsView(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
      child: child,
    ),
  ),
),
```

### 1.6 GoRouter.of(context) vs 전역 라우터 인스턴스

- 공식 문서 명문: "`context.go()` is shorthand for calling `GoRouter.of(context).go('/users/123')`" — context 확장은 `GoRouter.of(context)` 조회의 단축일 뿐이다.
- 이동 API 전부가 **GoRouter 인스턴스 메서드**다: `go`·`goNamed`·`push`·`pushNamed`·`pop`·`replace`·`refresh`·`namedLocation`. 즉 라우터 인스턴스를 전역 변수로 보관하면 **BuildContext 없이 동일 API를 그대로 호출**할 수 있다 — dddart의 `rootRouter` plain 전역 변수 + `<bc>_navigator`가 이름으로 호출하는 구조는 공식 API 표면을 그대로 쓰는 것(state §10 "rootRouter는 plain 전역 변수" 정합 확인, 충돌 없음).
- `GoRouter.of(context)`는 위젯 트리에서 라우터를 찾으므로 라우터 아래 context가 필요(없으면 `maybeOf`가 null). VM·UseCase처럼 트리 밖 코드는 전역 인스턴스 경로가 자연스럽다.

### 1.7 16.x → 17.x 변경 메모 (코퍼스 기준 결정용)

- **17.0.0 breaking**: ShellRoute류의 내비게이션 변화가 **루트 GoRouter 옵저버에 기본 통지**되도록 변경 + 셸 라우트들에 `notifyRootObserver` 파라미터 추가. (§2.4 패턴 B의 옵저버 설계와 접점 — 17에선 루트 옵저버만으로 분기 내 push/pop을 관찰할 수 있게 됨.)
- 16.3.0: top-level `onEnter` 콜백 추가. 17.1.0+: TypedQueryParameter(타입 세이프 라우트 계열). 17.3.0: 최소 SDK Flutter 3.38/Dart 3.10.
- 본문 표기(GoRoute·goBranch·redirect·CustomTransitionPage)는 16↔17 동일 — 기준 승격해도 §1 예제는 그대로 유효.

출처: https://pub.dev/packages/go_router (17.3.0) · https://pub.dev/packages/go_router/changelog · 공식 doc(저장소 `packages/go_router/doc/`): https://raw.githubusercontent.com/flutter/packages/main/packages/go_router/doc/configuration.md · navigation.md · named-routes.md · redirection.md · transition-animations.md · API: https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html · StatefulShellRoute-class.html · StatefulShellBranch-class.html · 공식 예제: https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart — 전부 2026-06-12 확인.

## 2. 탭 재탭 스크롤톱 메커니즘 — §10-5 ④ 원료 (정밀 조사)

### 2.1 재탭 감지 — goBranch와 initialLocation 의미론 (공식)

`goBranch(int index, {bool initialLocation = false})` 공식 문서:

> "Navigate to the last location of the StatefulShellBranch at the provided index." / "If the branch has not been visited before, **or if initialLocation is true**, this method will navigate to initial location of the branch (see StatefulShellBranch.initialLocation)."

- `initialLocation: false`(기본) — 그 분기의 **마지막 위치** 복원(탭 전환의 기본 동작). 같은 탭 재탭이면 사실상 변화 없음.
- `initialLocation: true` — 분기의 **초기 위치로 리셋**: 분기 안에 쌓인 중첩 스택이 분기 루트로 돌아간다(pop-to-root 효과).
- **재탭 감지는 별도 API가 없고 `index == navigationShell.currentIndex` 비교가 공식 관용구다.** 공식 예제(stateful_shell_route.dart) 주석 원문: "A common pattern when using bottom navigation bars is to support navigating to the initial location when tapping the item that is already active." 코드:

```dart
onTap: (index) => navigationShell.goBranch(
  index,
  initialLocation: index == navigationShell.currentIndex,
),
```

- 중요: 이 관용구는 **스택 리셋**이지 스크롤톱이 아니다. IndexedStack 셸은 탭 상태(스크롤 위치 포함)를 보존하므로, 분기 루트 화면에서 재탭하면 화면도 스크롤도 그대로다. 스크롤톱은 별도 메커니즘(아래)이 필요하다.

### 2.2 PrimaryScrollController 동작 원리 (Flutter 3.44.1 SDK 소스·공식 API 문서 실측)

- **정의**: `PrimaryScrollController`(이하 PSC)는 ScrollController 하나를 서브트리에 연결하는 InheritedWidget. `PrimaryScrollController.of/maybeOf(context)`로 조회.
- **자동 상속**: controller도 primary도 지정하지 않은 ScrollView는 `shouldInherit` 판정으로 PSC를 자동 사용한다 — 기본값은 **모바일 플랫폼(android·iOS·fuchsia) + 수직(Axis.vertical)일 때 true** (SDK `primary_scroll_controller.dart` `_kMobilePlatforms`·`automaticallyInheritForPlatforms`). 데스크톱·웹은 자동 상속 없음. `primary: true` 명시 시 플랫폼 무관 PSC 사용(이때 controller 동시 지정 불가), `primary: false`는 상속 차단.
- **상속은 한 겹**: PSC를 상속한 ScrollView는 그 아래에 `PrimaryScrollController.none`을 삽입해 **자손 ScrollView의 추가 상속을 차단**한다(소스 doc 명문) — 한 라우트에서 PSC에 붙는 스크롤뷰는 사실상 최상위 수직 스크롤뷰 1개.
- **누가 공급하나 — 라우트마다다**: `ModalRoute`(모든 페이지 라우트의 조상)가 내부 `_ModalScopeState`에서 `final ScrollController primaryScrollController = ScrollController()`를 만들어 라우트 콘텐츠를 `PrimaryScrollController(controller: ...)`로 감싸고 dispose까지 책임진다(SDK `routes.dart` 1096·1199·1150행 실측). 공식 API 문서(ScrollView.primary) 명문: "By default, the PrimaryScrollController **that is injected by each ModalRoute** is configured to automatically be inherited on TargetPlatformVariant.mobile for ScrollViews in the Axis.vertical scroll direction." — **go_router의 모든 페이지(분기 Navigator 안의 각 화면 포함)는 자기만의 PSC를 가진다.**
- **iOS 상태바 탭**: `Scaffold(primary: true)`(기본)가 iOS·macOS에서 상태바 탭 시 `PrimaryScrollController.maybeOf(context)`를 찾아 `animateTo(0.0, 1000ms, easeOutCirc)` 한다(SDK `scaffold.dart` handleStatusBarTap 실측). 조회 기점이 **그 Scaffold의 context**라서, Scaffold가 어느 라우트에 있느냐가 어느 PSC를 움직일지를 결정한다.
- **ScrollController 다중 부착**: `animateTo`는 부착된 **모든** position을 함께 움직이고(`for (... _positions ...)`), `position` 단수 getter는 부착 1개를 assert한다(SDK `scroll_controller.dart` 210-214·171-173행).

### 2.3 셸 구조에서의 구조적 제약 — 왜 "root가 PSC 하나 공급"으로는 안 되나

- 셸(root_view의 Scaffold)은 **셸을 담은 라우트**(루트 Navigator의 라우트)에 살고, BC 화면들은 **분기 Navigator 속 자기 라우트**에 산다. 각자 자기 라우트의 PSC를 본다.
- 따라서 ① 셸 Scaffold의 iOS 상태바 탭은 셸 라우트의 PSC를 움직이는데 거기엔 아무 스크롤뷰도 붙지 않고, ② root가 셸 위에 PSC를 하나 공급해도 BC 스크롤뷰에겐 **자기 라우트의 PSC가 더 가까워서 가려진다(shadowing)** — 둘 다 불통. 공식 이슈 실증: flutter/flutter **#131829** "[go_router] iOS ONLY - scroll to top not working when using StatefulNavigationShell" (open·P2), **#149484** (#131829의 중복으로 closed) — Scaffold body가 navigationShell이면 상태바 탭 스크롤톱이 깨진다는 보고.
- root에서 활성 분기의 "현재 라우트 PSC"에 닿는 공개 API 경로는 있다: `ModalRoute.subtreeContext`(공개 getter, SDK routes.dart 1966행 — 라우트 콘텐츠의 context, PSC **아래**)에서 `PrimaryScrollController.maybeOf(subtreeContext)`. 현재 top 라우트의 추적은 `StatefulShellBranch.observers`에 root가 NavigatorObserver를 달아 didPush/didPop으로 유지한다(§1.3 — 전부 공개 파라미터).

### 2.4 통용 구현 패턴 — 장단점 (조사 종합)

**패턴 A — 공식 관용구: 재탭 = 분기 스택 리셋만** (`initialLocation: index == currentIndex`)
- 근거: 공식 예제·API 문서·codewithandrea 가이드(통용 확인).
- 장점: 코드 1줄·전부 공식 API·BC 무관여. 중첩 화면에 들어가 있을 때 재탭하면 탭 루트로 복귀 — 재탭 UX의 절반은 이걸로 해결.
- 단점: **분기 루트 화면에서의 재탭엔 무반응**(스크롤 유지). "재탭 시 스크롤 최상단" 요구는 못 채운다.

**패턴 B — root가 분기별 현재 라우트의 PSC를 직접 구동** (dddart 지향 정합)
- 구성: root가 분기마다 NavigatorObserver를 보유(`StatefulShellBranch.observers`)해 top `ModalRoute`를 추적 → 재탭 감지 시(A의 관용구로 분기 루트가 아니면 먼저 스택 리셋) `topRoute.subtreeContext`에서 `PrimaryScrollController.maybeOf(...)` 조회 → `hasClients`면 `animateTo(0)`.
- BC 쪽 전제: 화면 최상위 수직 스크롤뷰가 **controller·primary 미지정**(모바일 기본값으로 라우트 PSC에 자동 부착 — §2.2). 이는 "아무것도 하지 않기"라서 BC가 신호를 듣지도, 컨트롤러를 받지도 않는다 — state §8 "root_view가 직접 처리, BC는 신호를 듣지 않는다"와 정합하는 유일한 조사 결과 경로.
- 장점: BC 코드·결합 0(수동적 기본값 준수만), 전부 공개 API, 라우트별 PSC를 프레임워크가 생성·dispose(수명 관리 무료), 중첩 화면까지 자연 대응(top 라우트 기준).
- 단점/제약: ① BC 화면이 명시 ScrollController를 쓰면(무한스크롤 등) 자동 부착이 꺼져 그 화면만 무반응 — "최상위 스크롤뷰는 primary 기본값" 규약화 필요. ② NestedScrollView는 자체적으로 PSC를 내부 공급(SDK nested_scroll_view.dart 354행)해 별도 검토. ③ 자동 상속이 모바일 한정(데스크톱·웹 무반응). ④ 옵저버 추적 코드(작지만)가 root에 필요. ⑤ 실기기 스모크 전 — 합성 시 정식 예제로 승격하려면 검증 권장(§7 미결).
- 변형 B′(기각): root가 셸 위에 단일 PSC 공급 + BC `primary: true` — §2.3 shadowing으로 **동작 안 함**. 설령 라우트 PSC가 없더라도 IndexedStack은 전 분기를 살려두므로 모든 탭의 스크롤뷰가 한 컨트롤러에 다중 부착되어 `animateTo`가 비활성 탭까지 움직인다(§2.2) — 이중 기각.

**패턴 C — 재탭 신호 버스: root가 신호 발행, BC 화면이 listen해 자기 컨트롤러로 스크롤**
- 커뮤니티에 가장 흔한 형태(stream/ChangeNotifier/리액티브 상태로 "scrollToTop 이벤트"를 흘림). HaffHaff의 폐지된 `scroll_to_top_notifier`(needTo/complete 플래그)가 정확히 이 패턴.
- 장점: 화면별 세밀 제어(중첩 스크롤·커스텀 동작), 명시 컨트롤러와 공존.
- 단점: **BC가 전역 신호에 결합** — dddart 금지 채널(규약 §9-11에서 종류째 폐지)이고, 위장 이벤트(과거형 신호) 안티패턴의 재생산. dddart에선 채택 불가 — 음성 지식으로 기록.

보조 채널 — iOS 상태바 탭: Scaffold 내장 동작(§2.2)이지만 셸 구조에선 #131829로 깨져 있다. 패턴 B를 채택하면 같은 PSC 경로로 root가 상태바 탭도 스스로 복원할 수 있다(재탭 처리와 같은 함수 재사용).

출처: goBranch·initialLocation·StatefulShellBranch: https://pub.dev/documentation/go_router/latest/go_router/StatefulNavigationShell/goBranch.html · StatefulShellBranch/initialLocation.html · StatefulShellBranch-class.html · 공식 예제 stateful_shell_route.dart(위 §1 출처) · PSC·Scaffold·ScrollController·ModalRoute: 로컬 Flutter 3.44.1 SDK 소스(`widgets/primary_scroll_controller.dart` 전문, `material/scaffold.dart` 1958·2745-2775행, `widgets/routes.dart` 1096·1150·1199·1966행, `widgets/scroll_controller.dart` 155-214행, `widgets/nested_scroll_view.dart` 354행) + https://api.flutter.dev/flutter/widgets/ScrollView/primary.html · 이슈: https://github.com/flutter/flutter/issues/131829 · https://github.com/flutter/flutter/issues/149484 · 패턴 통용 확인: https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/ — 전부 2026-06-12 확인.

## 3. dio 5.x — DioException 열거·인터셉터 기본

### 3.1 DioExceptionType — 8종 전수 (공식 API 문서)

| 값 | 공식 의미 |
|---|---|
| `connectionTimeout` | 연결 타임아웃 (`BaseOptions.connectTimeout`) |
| `sendTimeout` | 요청 전송 타임아웃 (`sendTimeout`) |
| `receiveTimeout` | 수신 타임아웃 (`receiveTimeout`) |
| `badCertificate` | 인증서 검증 실패 (validateCertificate) |
| `badResponse` | **validateStatus 밖 상태코드** — 서버 4xx/5xx 응답. `e.response?.data`에 서버 에러 바디가 실리는 경로 |
| `cancel` | CancelToken으로 요청 취소됨 |
| `connectionError` | 소켓 연결류 실패 (SocketException·xhr.onError) |
| `unknown` | 기본값 — 그 외(원인은 `e.error`) |

- **data §2 검증 결과**: safeApiCall 골격의 타임아웃 3분기(`connectionTimeout`·`receiveTimeout`·`sendTimeout`) 철자·존재 모두 공식과 정합 ✓. `e.response?.data`가 Map이면 서버 바디(badResponse 경로) 처리도 정합 ✓ (dio 기본 ResponseType.json은 JSON 응답을 Map으로 파싱하며, 런타임에서 `Map<String, dynamic> is Map<String, Object?>`는 참).
- 설계 참고(충돌 아님): `cancel`·`connectionError`·`badCertificate`는 data §2 골격에서 `errorType: 'unknown', isShow: true`로 떨어진다. 특히 **CancelToken을 도입하면 의도된 취소가 사용자 노출 에러가 되므로**, 취소를 쓰는 설계라면 `e.type == DioExceptionType.cancel` 분기(무음 처리)가 필요해진다 — 현재 dddart 규약에 CancelToken 채택이 없으므로 골격 그대로 유효.

### 3.2 기본 옵션·인터셉터

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 5),   // 전부 Duration 타입 (dio 5.x)
  receiveTimeout: const Duration(seconds: 3),
));

dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    options.headers['Authorization'] = 'Bearer ...'; // 예: 토큰 부착
    return handler.next(options);   // 계속 진행
  },
  onResponse: (response, handler) => handler.next(response),
  onError: (DioException e, handler) => handler.next(e),
));
```

- handler 의미론(공식): `next` = 다음 단계 계속, `resolve(Response)` = 성공으로 단락(이후 인터셉터·요청 생략), `reject(DioException)` = 실패로 단락.
- dddart 소비처 메모: 에러의 **정규화**는 인터셉터가 아니라 safeApiCall(단일 출구 — data §2)의 일이다. 인터셉터는 헤더 부착·로깅 같은 횡단 관심사에 한정하는 편이 두 정규화 지점의 충돌을 막는다.

출처: https://pub.dev/documentation/dio/latest/dio/DioExceptionType.html (8값 전수·문구) · https://github.com/cfug/dio — dio/README.md(BaseOptions·InterceptorsWrapper·handler 의미론·DioException 필드) · https://pub.dev/packages/dio (5.9.2) — 2026-06-12 확인.

## 4. retrofit 4.x — @RestApi 표기

```yaml
dependencies:
  retrofit: ^4.7.0      # 어노테이션·런타임
  dio: ^5.7.0
dev_dependencies:
  retrofit_generator: ^10.0.0   # 코드 생성기 (10.x 라인)
  build_runner: ^2.6.0
```

```dart
// infra_layer/data_source/channel_data_source.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'channel_data_source.g.dart';  // 생성 파일 — part 표기 필수

@RestApi() // baseUrl은 Dio BaseOptions에 위임 가능 — @RestApi(baseUrl: '...')도 가능
abstract class ChannelDataSource {
  factory ChannelDataSource(Dio dio, {String? baseUrl}) = _ChannelDataSource;

  @GET('/channels')
  Future<List<Channel>> getChannels(@Query('page') int page);

  @GET('/channels/{id}')
  Future<Channel> getChannel(@Path('id') String id);

  @POST('/channels')
  Future<Channel> createChannel(@Body() Channel channel);

  @PUT('/channels/{id}')
  Future<Channel> updateChannel(@Path() String id, @Body() Channel channel);

  @DELETE('/channels/{id}')
  Future<void> deleteChannel(@Path() String id);
}
```

- 핵심 표기: `@RestApi` 추상 클래스 + `factory ... = _생성클래스` + `part`. 메서드는 `@GET/@POST/@PUT/@DELETE('/path/{param}')`, 인자는 `@Path`(중괄호 치환 — 인자명과 같으면 이름 생략 가)·`@Query`(쿼리스트링)·`@Body`(요청 바디, toJson 직렬화)·`@Queries`(Map 일괄).
- **반환 타입 = `Future<T>`·`Future<List<T>>`·`Future<void>` 직반환** — T가 `fromJson`을 가지면(json_serializable·freezed 호환) 생성기가 역직렬화 코드를 만든다. data §4 "도메인 엔티티 직접 반환(DTO 없음)" 표기가 공식 사용법 그대로 ✓. 원시 응답이 필요하면 `Future<HttpResponse<T>>`(상태코드 접근)도 지원 — dddart 소비처에선 비표준.
- 생성: `dart run build_runner build` (개발 중 `watch`).

출처: https://pub.dev/packages/retrofit (4.9.2·README 예제) · https://github.com/trevorwang/retrofit.dart — README.md(어노테이션·pubspec·반환 타입·생성 명령) — 2026-06-12 확인.

## 5. hive_ce 2.x — 초기화·box·TypeAdapter·@GenerateAdapters

### 5.1 원조 hive와의 차이 (Community Edition)

hive_ce는 hive v2의 커뮤니티 포크다(원조 hive v4/Isar 방향과 별개 — **원조 hive 문서·hivedb.dev와 혼동 금지**). 추가분: `@GenerateAdapters`에 의한 어댑터 자동 생성(필드 어노테이션 불요·**freezed 클래스 지원**), typeId 한도 223 → 65,439 확장, IsolatedHive, WASM 지원, Duration·Set 내장 어댑터, DevTools 인스펙터. import는 `package:hive_ce/hive.dart`(원조 호환 경로 — HaffHaff 실사용 철자) 또는 `package:hive_ce/hive_ce.dart`, Flutter 확장은 `package:hive_ce_flutter/hive_flutter.dart`(HaffHaff는 `package:hive_ce_flutter/adapters.dart` 사용 — 두 entry 모두 공식).

### 5.2 초기화·box (hive_ce_flutter)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();      // hive_ce_flutter 확장 — 경로 설정 불요
  Hive.registerAdapters();       // 생성된 registrar 확장 (§5.3) — openBox 전에
  await Hive.openBox<Channel>('channel_cache');
  runApp(const App());
}

// 사용 — box는 맵 인터페이스, 표준 연산은 await 불요
final box = Hive.box<Channel>('channel_cache');
box.put('ch1', channel);
final cached = box.get('ch1');
```

- 등록 순서 공식 가이드: `initFlutter` 직후·`openBox` 등 다른 Hive 연산 전에 어댑터 등록.

### 5.3 @GenerateAdapters 메커니즘 (생성기 소스 실측)

공식 컨벤션 — **`lib/hive/hive_adapters.dart` 한 파일**에 라이브러리 어노테이션으로 선언:

```dart
// lib/hive/hive_adapters.dart
import 'package:hive_ce/hive_ce.dart';
import '../domain_layer/channel/channel.dart';

@GenerateAdapters([AdapterSpec<Channel>(), AdapterSpec<ChannelType>()])
part 'hive_adapters.g.dart';
```

- 생성물 3종: ① `hive_adapters.g.dart`(어댑터 클래스들 — 어노테이션 파일의 part), ② `hive_adapters.g.yaml`(**스키마 — 필드 인덱스·typeId의 증분 갱신 근거, VCS 체크인 필수**), ③ `lib/hive_registrar.g.dart`(`Hive.registerAdapters()` 확장 — 패키지 전체 어댑터 일괄 등록).
- `GenerateAdapters(specs, {firstTypeId = 0, reservedTypeIds = {}})` — typeId는 스키마 yaml 기준 자동 증가(어노테이션 파일별 스키마: 생성기가 `inputId.changeExtension('.g.yaml')`로 어노테이션 파일 옆에 만든다).
- 스키마 진화 규칙(공식 문서): 필드 추가는 안전(구 어댑터가 쓴 데이터를 신 어댑터가 읽음), 필드 개명은 스키마 yaml 수동 수정 필요, 타입 변경은 미지원(새 필드로).
- 레거시 호환: `@HiveType/@HiveField` 수동 어노테이션 방식도 그대로 지원되며, registrar는 **GenerateAdapters 산출물 + 패키지 안 모든 @HiveType 클래스**를 함께 집계한다(registrar_intermediate_builder 소스 실측).

### 5.4 단일 파일 강제 — data §5 정합 검증 결과: **충돌 발견**

생성기 소스(hive_ce_generator) 실측 — 두 겹의 강제:

- `RegistrarBuilder`(hive_registrar.g.dart 생성, 패키지당 1개·`$lib$` 출력): GenerateAdapters 어노테이션이 발견된 파일이 2개 이상이면 **`throw HiveError('GenerateAdapters annotation found in more than one file: ...')`** — 빌드 실패.
- `RegistrarIntermediateBuilder`: 한 파일 안의 다중 어노테이션도 **`throw HiveError('Multiple GenerateAdapters annotations found in file: ...')`**.

즉 **`@GenerateAdapters`는 패키지 전체에서 정확히 한 파일·한 번**이다. 따라서 배포본 data final.md §5(112행) "어댑터 선언(`@GenerateAdapters` 류)도 이 파일[`data_source/<bc>_hive_adapters.dart`] 소속"은 BC가 2개 이상 hive 캐시를 갖는 순간 **빌드가 깨지는 규약**이다(conflictFlags 보고).

공식 사실 기준으로 가능한 구성(판단은 합성 몫 — 사실만 나열):

| 구성 | 공식 정합 | dddart 규약과의 관계 |
|---|---|---|
| (a) 앱 전역 1파일 `@GenerateAdapters`(공식 컨벤션) | ✓ | 그 파일이 전 BC 엔티티를 import — "BC infra는 BC 안" 원칙과 긴장. registrar import 1회는 시동 배선과는 정합 |
| (b) BC별 **수동 `TypeAdapter<T>` 구현 클래스** + BC별 등록 함수(`Hive.registerAdapter(ChannelAdapter())`) | ✓ | `<bc>_hive_adapters.dart` 한 파일 규약 유지 가능. 단 typeId는 수동·**앱 전역 유일** 필요 — 중복 시 런타임 `HiveError('There is already a TypeAdapter for typeId X.')`(type_registry_impl.dart 실측, `override: false` 기본). BC별 typeId 대역 할당 같은 전역 조정 규칙 필요 |
| (c) BC별 `@HiveType/@HiveField` 어노테이션(파일 제약 없음 — registrar 자동 집계) | ✓ | **도메인 엔티티에 storage 어노테이션 금지(data §4)와 충돌** — 엔티티에 직접 붙여야 해서 dddart에선 결격 |

출처: https://pub.dev/packages/hive_ce (2.19.3·기능 목록) · https://pub.dev/packages/hive_ce_flutter (2.3.4) · 공식 문서 저장소: https://github.com/IO-Design-Team/hive_ce_docs/blob/master/custom-objects/generate_adapters.md (컨벤션·생성물·스키마 규칙·registrar 사용) · 소스 실측(GitHub API, IO-Design-Team/hive_ce@main): `hive_generator/build.yaml`, `hive_generator/lib/src/builder/registrar_builder.dart`(단일 파일 강제), `registrar_intermediate_builder.dart`(파일 내 단일·@HiveType 집계), `generator/adapters_generator.dart`(파일별 스키마·typeId 할당), `hive/lib/src/annotations/generate_adapters.dart`(firstTypeId·reservedTypeIds), `hive/lib/src/registry/type_registry_impl.dart`(중복 typeId HiveError) — 2026-06-12 확인.

## 6. 프레임워크 코어 최소 — StatefulWidget 수명·BuildContext 안전

### 6.1 initState / dispose — 컨트롤러 보유 규약의 근거

공식 doc(State, Flutter 3.44.1 소스 인용):

- `initState` — "The framework will call this method **exactly once** for each State object it creates." 구독·리소스 보유 규칙: "In initState, subscribe to the object. … **In dispose, unsubscribe from the object.**"
- `dispose` — "Called when this object is removed from the tree permanently. … Subclasses should override this method to **release any resources retained by this object**." dispose 이후 mounted=false이며 setState는 에러.
- TextEditingController 공식 doc: "**Remember to dispose of the TextEditingController when it is no longer needed.** This will ensure we discard any resources used by the object."

```dart
class SearchView extends StatefulWidget { ... }

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController(); // View(State)가 생성·보유

  @override
  void dispose() {
    _controller.dispose(); // 보유자가 해제 — 쌍 규율
    super.dispose();       // 공식: dispose 구현은 super.dispose()로 끝난다
  }
  ...
}
```

- dddart 정합: "컨트롤러는 View 소유"(규약 §10-5 ① — state §2)의 프레임워크 측 근거가 이 생성-해제 쌍이다. 컨트롤러를 VM(riverpod Notifier)에 두면 위젯 수명과 분리되어 dispose 쌍이 깨진다 — 보유 주체는 StatefulWidget의 State(또는 동등한 hooks).

### 6.2 BuildContext 안전 — mounted와 async gap

- `BuildContext.mounted` 공식 doc: "Whether the Widget this context is associated with is currently mounted in the widget tree. … **If a BuildContext is used across an asynchronous gap (i.e. after performing an asynchronous operation), consider checking mounted** to determine whether the context is still valid before interacting with it."
- lint `use_build_context_synchronously`(Flutter lint set 포함, stable): "Do not use BuildContext across asynchronous gaps." — await 뒤 context 사용 전 **State 안이면 `mounted`(this), 인자로 받은 context면 `context.mounted`** 체크.

```dart
onPressed: () async {
  await ref.read(channelSummaryVMProvider.notifier).leaveChannel(id);
  if (!context.mounted) return; // async gap 뒤 — 체크 없으면 lint 위반·런타임 위험
  Navigator.of(context).pop();
},
```

- dddart 소비처 메모: VM의 BuildContext 보유 금지(state §2)가 지켜지면 이 위험의 대부분이 구조적으로 사라진다 — mounted 체크가 필요한 자리는 View의 async 콜백뿐이며, View가 `ref.listen`으로 상태 변화를 소비하는 정식 패턴(state §4)은 build 안 동기 실행이라 gap 자체가 없다.

출처: 로컬 Flutter 3.44.1 SDK `widgets/framework.dart`(initState 1190행대·dispose 1286-1298행·BuildContext.mounted 2283-2324행 doc 주석 원문) · https://api.flutter.dev/flutter/widgets/TextEditingController-class.html (dispose 문구) · https://dart.dev/tools/linter-rules/use_build_context_synchronously (규칙·예제·flutter set 포함) — 2026-06-12 확인.

## 7. 충돌·미결 요약 (합성 시 처리 목록)

**충돌(conflictFlags 동반 보고)**

1. **hive_ce @GenerateAdapters 단일 파일 강제 vs data §5 BC별 선언** — `dddart/skills/architecture-data/references/final.md` 112행 "어댑터 선언(`@GenerateAdapters` 류)도 이 파일 소속"(BC별 `<bc>_hive_adapters.dart`)은 BC 2개부터 `HiveError: GenerateAdapters annotation found in more than one file`로 빌드 실패. 공식 정합 대안은 §5.4 표 (a)/(b).
2. **"root가 PrimaryScrollController로 직접 처리"의 소박한 독해 불성립** — 제1 규약 §9-11 대체표(452행) "탭 재탭 스크롤톱은 root_view가 PrimaryScrollController 등으로 직접 처리"를 "root가 PSC 하나 공급"으로 읽으면 ModalRoute의 라우트별 PSC에 가려져 동작하지 않는다(§2.3, flutter#131829·#149484). 배포본 state §8은 메커니즘을 "미결·implementation-flutter 소유"로 두었으므로 배포본 충돌은 아니나, 규약 문구의 구현 경로는 §2.4 패턴 B(라우트별 PSC 추적)로 구체화돼야 한다.

**미결(unresolved)**

- go_router 코퍼스 기준선: 최신은 17.3.0(17.x), HaffHaff lock은 16.2.4. 본문 표기는 16↔17 동일하나(§1.7) 기준 승격 여부는 메인 루프 결정.
- §10-5 ④ 재탭 UX 사양: 스택 리셋(패턴 A)과 스크롤톱(패턴 B)의 결합 순서(예: 중첩 화면이면 리셋만, 루트면 스크롤톱) — 설계 결정 필요.
- 패턴 B의 정식 예제 승격 전 실기기 스모크 권장 — API 경로는 전부 공개·소스 정합 확인됐으나 동작 검증은 미수행.
- dio QueuedInterceptor(토큰 갱신 직렬화) 등 인터셉터 고급은 미조사 — 소비처 확정 시 추가.
- hive_ce `box.listenable()`(ValueListenable 감시)는 미확인 — dddart 소비처(상태는 riverpod 소관) 불명으로 보류.
