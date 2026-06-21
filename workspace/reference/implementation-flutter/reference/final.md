# Flutter 표기법 — go_router·dio/retrofit·hive_ce·위젯 수명

## P1 Source Sufficiency

| field | value |
|---|---|
| purpose | dddart가 생성하는 코드의 Flutter 스택 표기 단일 출처 — go_router(라우트·탭 셸·redirect·전환), 탭 재탭 2단 동작(§10-5 ④ 확정 메커니즘), dio/retrofit, hive_ce(@HiveType 방식), 위젯 수명·BuildContext 안전. |
| use when | 라우트·내비게이션 코드를 쓸 때, 탭 셸·재탭 동작을 만들 때, DataSource(retrofit)·dio 설정을 쓸 때, hive 캐시·어댑터를 쓸 때, StatefulWidget 컨트롤러·async 콜백을 다룰 때. |
| exclude/handoff | 라우팅 짝의 역할·규율은 architecture-ui §6, root 동작 규율은 architecture-state §10, safeApiCall·Either 계약은 architecture-data §2·§3, 로컬 2층·어댑터 노출 규약은 architecture-data §5, @riverpod·AsyncValue는 implementation-riverpod, Dart 언어·freezed는 implementation-dart로 위임. |
| use 기준 | go_router 16.x(HaffHaff lock — 17과 본문 표기 동일·차이는 §2 말미 메모)·dio 5.x·retrofit 4.x(generator 10.x)·hive_ce 2.x·Flutter SDK 소스 실측(2026-06-12 — 절별 URL·SDK 행 번호는 작업장 external.md). |
| core criteria | dddart 결정 2건 반영: §10-5 ④ 탭 재탭 2단 동작(2026-06-12 사용자 확정 — 중첩이면 스택 리셋·루트면 스크롤톱, 전부 root_view 소유·BC 무관여) · hive_ce @GenerateAdapters 비채택(패키지 1파일 강제가 BC 분산 선언과 충돌 — 생성기 소스 실측)·@HiveType per-class 방식 표준(HaffHaff 실물 — 별도 Box 모델이라 엔티티 무어노테이션 보존). |
| P1 classification | sufficient — ④ 패턴 B 메커니즘은 widget test 검증 완료(2026-06-13 — ModalRoute 캐스트 교정 포함·실기기 시각 확인만 골격 구현 시 1회). 잔여: typeId 전역 유일의 백스톱 검사는 향후 후보(§5 단서). |

> **출처:** pub.dev(go_router·dio·retrofit·hive_ce)·공식 문서 저장소·Flutter SDK 3.44.x 소스 직독·flutter/flutter#131829(셸 상태바 탭 이슈) — 2026-06-12 확인, 절별 URL은 작업장 external.md · 제1 규약 §9-11·§10-5 ④ · HaffHaff 실물(Box 모델 형태) · dddart 결정(2026-06-12): ④ 2단 동작.
> 본문 속 `(규약 §N)`은 **출처 표기**이며 로드 대상이 아니다. 로드 가능한 위임은 "스킬명 + §번호(또는 주제)"뿐.

---

## 목차

- §1. 버전·전제
- §2. go_router 표기 — GoRoute·이름 내비·탭 셸·redirect·전환
- §3. 탭 재탭 2단 동작 — 규약 §10-5 ④ 확정 (root_view 소유)
- §4. dio·retrofit 표기 — DioException 8종·@RestApi
- §5. hive_ce — @HiveType 방식·등록 함수·@GenerateAdapters 비채택
- §6. 위젯 수명·BuildContext 안전 — 컨트롤러 쌍·mounted
- §8. 정적 이미지 에셋 — Image.asset·pubspec assets

---

## §1. 버전·전제

go_router 16.x(17과 본문 표기 동일 — §2 말미) · dio 5.x · retrofit 4.x + retrofit_generator 10.x · hive_ce 2.x + hive_ce_flutter(원조 hive·hivedb.dev 문서와 **혼동 금지** — hive_ce는 v2 커뮤니티 포크). 기존 프로젝트의 lock 버전이 우선이고, 이 문서의 표기는 위 라인에서 컴파일 정합하다.

## §2. go_router 표기 — GoRoute·이름 내비·탭 셸·redirect·전환

**GoRoute** — 라우팅 짝의 역할·리터럴 단일 출처 규율은 architecture-ui §6 소유, 여기는 표기:

```dart
GoRoute(
  path: '/channels/:channelId',   // ':' 접두 = path parameter
  name: ChannelRoutes.detailName, // 이름 — pushNamed/goNamed의 키 (리터럴은 router 파일에만)
  builder: (context, state) => ChannelDetailView(id: state.pathParameters['channelId']!),
  routes: [ /* 자식 라우트 — 위에 쌓이는 화면 */ ],
),
```

- `state.pathParameters[...]`·`state.uri.queryParameters[...]`로 파라미터 접근. 라우트당 `builder` 또는 `pageBuilder` 필수.
- **이동 의미론**: `go` = 스택 교체, `push` = 위에 쌓기. 이름 기반이 dddart 채널이다 — `context.pushNamed('name', pathParameters: {...}, queryParameters: {...})`.
- **전역 인스턴스 호출**: 이동 API 전부가 GoRouter 인스턴스 메서드라(`context.go()`는 `GoRouter.of(context).go()`의 단축일 뿐) **`rootRouter.go(url)`처럼 BuildContext 없이 동일 API를 그대로 호출할 수 있다** — rootRouter plain 전역 변수·navigator의 전역 키 경유 호출(architecture-state §10·architecture-ui §6)의 공식 근거.
- **탭 셸** — `StatefulShellRoute.indexedStack`(분기마다 별도 Navigator·상태 보존):

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => RootView(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(
      observers: [homeBranchObserver],            // §3 — root가 분기 top 라우트 추적
      routes: [GoRoute(path: '/home', pageBuilder: (c, s) => NoTransitionPage(child: ...))],
    ),
    ...
  ],
)
// 셸 위젯: Scaffold(body: navigationShell, bottomNavigationBar: ...)
// 탭 인덱스는 navigationShell.currentIndex가 보유 — 별도 상태 불요(architecture-state §10 "거의 빈 VM")
```

- **top-level redirect** — 모든 내비게이션 이벤트 전에 호출(인증·강제업데이트 게이트의 자리): `redirect: (context, state) { if (!signedIn) return '/signin'; return null; }`. dddart는 redirect 안에서 UseCase 직접 호출로 상태를 얻는다(context 비사용 — architecture-state §10).
- **전환**: `pageBuilder: (c, s) => CustomTransitionPage(key: state.pageKey, child: ..., transitionsBuilder: ...)` — duration·curve 값은 design_system 토큰(architecture-ui §6·§7). 전환 없는 탭 화면은 `NoTransitionPage`.
- 17.x 차이 메모: 본문 표기는 16↔17 동일(GoRoute·goBranch·redirect·전환). 17.0의 변화는 셸 내비게이션의 루트 옵저버 기본 통지(+`notifyRootObserver`) — §3 옵저버 설계와 접점(StatefulShellBranch.observers의 17 변경 기록은 없음 — 승격 시 1회 확인).

## §3. 탭 재탭 2단 동작 — 규약 §10-5 ④ 확정 (root_view 소유)

**확정(2026-06-12 사용자 — 규약 §10-5 ④): 현재 탭을 재탭하면 ① 분기에 중첩 화면이 쌓여 있으면 분기 첫 화면으로 복귀(스택 리셋) ② 이미 첫 화면이면 스크롤 최상단.** 전부 root_view가 처리하고 **BC는 무관여**다 — 신호를 듣지도, 컨트롤러를 받지도 않는다(규약 §9-11).

**왜 이 메커니즘인가** — "root가 PrimaryScrollController(PSC)를 위에서 공급"하는 소박한 방법은 동작하지 않는다: 모든 페이지 라우트(ModalRoute)가 라우트마다 자기 PSC를 주입하므로 root 공급분은 BC 화면에서 가려진다(SDK 소스 실측 — 같은 이유로 셸 구조의 iOS 상태바 탭도 깨져 있다, flutter#131829). 실현 경로는 **라우트별 PSC를 root가 찾아가 구동**하는 것:

```dart
// root_view의 탭 onTap — ① 스택 리셋은 공식 관용구 한 줄
onTap: (index) {
  final isReTap = index == navigationShell.currentIndex;
  if (isReTap && _branchObservers[index].isAtBranchRoot == false) {
    navigationShell.goBranch(index, initialLocation: true); // ① 첫 화면 복귀
  } else if (isReTap) {
    _scrollCurrentBranchToTop(index);                       // ② 스크롤톱
  } else {
    navigationShell.goBranch(index);                        // 일반 탭 전환
  }
},

// ② — 분기 옵저버(StatefulShellBranch.observers에 등록)가 추적해 둔 top 라우트의 PSC를 구동.
//      옵저버는 topRoute를 ModalRoute<dynamic>?로 보관한다(didPush에서 `is ModalRoute`로 걸러 저장)
//      — subtreeContext는 ModalRoute의 getter라 Route 타입으로 들면 컴파일되지 않는다.
void _scrollCurrentBranchToTop(int index) {
  final route = _branchObservers[index].topRoute;           // ModalRoute<dynamic>? — didPush/didPop으로 유지
  final context = route?.subtreeContext;                    // 라우트 콘텐츠 context (PSC 아래)
  if (context == null) return;
  final psc = PrimaryScrollController.maybeOf(context);
  if (psc != null && psc.hasClients) {
    psc.animateTo(0, duration: AppDuration.scrollToTop, curve: Curves.easeOutCirc);
  }
}
```

- **BC 화면의 전제(유일한 접점 — "아무것도 하지 않기")**: 화면 최상위 수직 스크롤뷰가 **controller·primary를 지정하지 않으면** 모바일 기본값으로 그 라우트의 PSC에 자동 부착된다 — 이 기본값을 지키는 것이 전부다. 무한스크롤 등으로 명시 ScrollController를 쓰는 화면은 그 화면만 스크롤톱이 무반응이 된다(의도된 트레이드오프 — BC에 결합을 만들지 않는 것이 우선). NestedScrollView는 자체 PSC를 내부 공급하므로 별도 검토 대상.
- **재탭 신호 버스(과거 HaffHaff `scroll_to_top_notifier` — BC가 전역 신호를 listen)는 비채택**이다: 금지 채널의 재생산(architecture-state §8). 
- iOS 상태바 탭도 같은 함수를 재사용해 root가 복원할 수 있다(셸 구조에서 내장 동작이 깨져 있으므로).
- 자동 상속은 모바일 한정(데스크톱·웹 무반응). 메커니즘 전체(옵저버 추적→subtreeContext→PSC→animateTo·goBranch 리셋)는 widget test로 검증 완료(2026-06-13 — topRoute의 ModalRoute 캐스트 결함도 이 스모크가 발견·교정), 실기기 시각 확인은 골격 구현 시 1회.

## §4. dio·retrofit 표기 — DioException 8종·@RestApi

**DioExceptionType 8종**(safeApiCall 분기의 공식 근거 — 계약 자체는 architecture-data §2 소유): `connectionTimeout`·`sendTimeout`·`receiveTimeout`(타임아웃 3종) / `badResponse`(validateStatus 밖 4xx·5xx — `e.response?.data`에 서버 에러 바디) / `badCertificate`·`cancel`·`connectionError`·`unknown`(`e.error`에 원인). CancelToken을 도입하는 설계가 생기면 `cancel`의 무음 분기가 필요해진다 — 현재 비채택이라 safeApiCall 골격 그대로 유효.

**dio 설정·인터셉터**:

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 5), // 5.x는 전부 Duration
  receiveTimeout: const Duration(seconds: 3),
));
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) { options.headers['Authorization'] = 'Bearer ...'; return handler.next(options); },
  onError: (e, handler) => handler.next(e),
));
```

- **인터셉터는 헤더 부착·로깅 같은 횡단 관심사에 한정한다** — 에러의 정규화는 safeApiCall(단일 출구 — architecture-data §2)의 일이다. 정규화 지점이 둘이 되면 충돌한다.

**retrofit** — DataSource의 표기(직반환 계약은 architecture-data §4 소유):

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'channel_data_source.g.dart';

@RestApi() // baseUrl은 Dio BaseOptions에 위임
abstract class ChannelDataSource {
  factory ChannelDataSource(Dio dio, {String? baseUrl}) = _ChannelDataSource;

  @GET('/channels')
  Future<List<Channel>> getChannels(@Query('page') int page);

  @GET('/channels/{id}')
  Future<Channel> getChannel(@Path('id') String id);

  @POST('/channels')
  Future<Channel> createChannel(@Body() Channel channel);
}
```

- 어노테이션: `@GET/@POST/@PUT/@DELETE('/path/{param}')` + `@Path`(인자명이 같으면 이름 생략 가)·`@Query`·`@Body`(toJson 직렬화). 반환은 `Future<T>`·`Future<List<T>>`·`Future<void>` — T에 fromJson이 있으면(freezed) 역직렬화 생성. `HttpResponse<T>`(원시 응답)는 dddart 비표준.

## §5. hive_ce — @HiveType 방식·등록 함수·@GenerateAdapters 비채택

**@GenerateAdapters는 비채택이다**: 생성기가 패키지 전체에서 **정확히 1파일·1회**만 허용한다(2파일째부터 `HiveError: GenerateAdapters annotation found in more than one file` — 빌드 실패, 생성기 소스 실측). BC별 `<bc>_hive_adapters.dart` 분산 선언(architecture-data §5)과 양립 불가다.

**표준은 @HiveType per-class 방식**(HaffHaff 실물 — hive_ce가 그대로 지원): **저장 전용 Box 모델**에 어노테이션을 붙인다 — 도메인 엔티티에는 붙지 않으므로(별도 클래스) "엔티티 무어노테이션"(architecture-data §4)이 보존된다:

```dart
// infra_layer/data_source/<bc>_hive_adapters.dart — BC의 어댑터 선언+등록 함수 한 파일
// typeId 대역: channel = 20~29 (앱 전역 유일 — BC별 대역을 이 주석으로 조정)
import 'package:hive_ce/hive.dart';
import '../../domain_layer/channel/channel.dart';

part 'channel_hive_adapters.g.dart';

@HiveType(typeId: 20)
class ChannelBox { // 저장 전용 모델 — 도메인 Channel과 분리 (HaffHaff 실물: plain class·const 생성자·final 필드)
  const ChannelBox({required this.id, required this.name});

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  Channel toDomain() => Channel(id: id, name: name);
  static ChannelBox from(Channel c) => ChannelBox(id: c.id, name: c.name);
}

void registerChannelHiveAdapters() { // root_initializer가 호출하는 유일한 노출면
  if (!Hive.isAdapterRegistered(20)) Hive.registerAdapter(ChannelBoxAdapter());
}
```

- **typeId는 앱 전역 유일**이다 — 중복 등록은 런타임 `HiveError`. 파일 머리의 **BC별 typeId 대역 주석**으로 조정한다(전역 유일성의 결정적 검사는 백스톱 향후 후보).
- **초기화·box** (시동은 root_initializer 소유 — architecture-state §10):

```dart
await Hive.initFlutter();          // hive_ce_flutter — 경로 설정 불요
registerChannelHiveAdapters();     // BC 등록 함수들을 root_initializer가 조립 — openBox 전에
await Hive.openBox<ChannelBox>('channel_cache');

final box = Hive.box<ChannelBox>('channel_cache'); // 맵 인터페이스 — put/get은 await 불요
```

- box 정의·읽기/쓰기는 `<개념>_local_data_source.dart`의 일(architecture-data §5), Box 모델↔도메인 변환(toDomain/from)은 그 경계의 표기다.
- box 변화 감시(`box.listenable()`)는 쓰지 않는다 — 상태 반응은 riverpod 소관(architecture-state).

## §6. 위젯 수명·BuildContext 안전 — 컨트롤러 쌍·mounted

**위젯 생성자 키 — `super.key`**: 위젯 생성자는 `const View({super.key})` 형태를 쓴다(레거시 `Key? key` + `super(key: key)` 지양 — `use_super_parameters` lint가 평범한 forward를 기계 적발한다). *계산 기본키*가 필요하면(목록 항목 식별 등) 생성자에 `Key? key` fallback을 두지 말고 **호출부에서 `ValueKey`로 주입**하거나 static 팩토리로 만든다 — 키 계산이 위젯 밖에 있어야 super.key가 일관되고, 테스트가 집는 안정 키 부착과도 양립한다.

**컨트롤러 생성-해제 쌍** — "컨트롤러는 View 소유"(architecture-state §2)의 프레임워크 근거: initState는 정확히 1회 호출되고, dispose가 보유 리소스 해제의 자리다. 컨트롤러를 VM에 두면 위젯 수명과 분리되어 이 쌍이 깨진다:

```dart
class _SearchViewState extends ConsumerState<SearchView> {
  final _controller = TextEditingController(); // View(State)가 생성·보유

  @override
  void dispose() {
    _controller.dispose(); // 보유자가 해제 — 쌍 규율
    super.dispose();       // dispose 구현은 super.dispose()로 끝난다
  }
}
```

**다이얼로그·시트의 표시 호출** — View가 자기 context로 호출한다(컴포넌트의 static show() 금지는 architecture-ui §7 소유):

```dart
showDialog(context: context, builder: (_) => ErrorDialog(msg: error.msg));
showModalBottomSheet(context: context, builder: (_) => const FilterSheet());
```

**BuildContext의 async gap** — await 뒤 context 사용 전 mounted 체크(lint `use_build_context_synchronously`가 집행):

```dart
onPressed: () async {
  await ref.read(channelSummaryVMProvider.notifier).leaveChannel(id);
  if (!context.mounted) return; // State 안이면 mounted, 인자 context면 context.mounted
  Navigator.of(context).pop();
},
```

- VM의 BuildContext 보유 금지(architecture-state §2)가 지켜지면 이 위험 대부분이 구조적으로 사라진다 — mounted 체크가 필요한 자리는 View의 async 콜백뿐이고, `ref.listen` 정식 패턴(architecture-state §4)은 build 안 동기 실행이라 gap 자체가 없다. (VM 쪽 await 뒤 가드는 `ref.mounted` — implementation-riverpod §4.)

## §7. 테스트 표기 → discipline-test·implementation-test로 이전

테스트 표기는 전용 스킬 2종으로 이전했다(2026-06-17 — feedback-008). **무엇을 테스트할지·오라클·비-vacuity·단언 FORM(구별·순서·위치·탭)은 `discipline-test`**, **Flutter 메커니즘(provider override 가짜 주입·`ProviderContainer.test`·셰이더(NoSplash)/Timer 회피·mocktail 더블·날짜 주입·네트워크 이미지 목)은 `implementation-test`** 소유다. coder는 행위 검증 테스트를 쓸 때 이 두 스킬을 로드한다(green 래칫·신규 BC TG1 차단은 coder 산출 규율). 위젯 수명·async gap의 context는 §6.

## §8. 정적 이미지 에셋 — Image.asset·pubspec assets

시안의 `<img>`(로고·일러스트 등 정적 래스터)는 Phase 0 `fetch_images`가 `assets/images/`로 다운로드하고 `asset-manifest.json`(src→`local_path`→`token` 매핑·단일 SSOT)으로 절단한다. coder는 명세가 가리킨 이미지를 manifest의 **같은 `src` 행**으로 조인해 정확 값을 가져온다(추정·눈대중 금지 — server-contract를 경량본에서 인용하듯).

- **토큰화**: 정적 래스터 경로는 `AppAsset`(foundation 7토큰의 7번째) static const에서 온다 — `app_asset.dart`에 `static const String <token> = '<local_path>';`를 추가한다(manifest의 `token`·`local_path`를 그대로 — 발명 금지). raw 경로 문자열을 위젯에 직접 박지 않는다(`Image.asset('assets/logo.png')` 금지 — architecture-ui §7 사용 규율·`Color(0x…)`→`AppColor`와 평행).
- **pubspec 멱등 선언**: `pubspec.yaml`의 `flutter: assets:`에 `- assets/images/`(디렉터리·평면)가 없으면 추가하고 있으면 그대로 둔다(기존 항목 보존). 디렉터리 1줄이면 이미지가 늘어도 pubspec을 다시 고치지 않는다(파일별 나열 불요). 하위 디렉터리는 만들지 않는다(평면 — "직속 파일만 포함" 함정 회피).
- **배선**: `Image.asset(AppAsset.<token>)`로 쓴다. **치수는 강제하지 않는다** — `width`·`height`는 시안이 명시한 경우에만 박는다(글리프 아이콘 `Icons.*`[architecture-ui §5]와 정적 래스터는 다른 트랙·이미지 *크기*는 크기연결 트랙[architecture-ui §8]이지 에셋 *경로* 트랙이 아니다).
- `has_design_images`가 없으면(manifest 부재) 이 절은 적용되지 않는다 — 없는 이미지를 placeholder로 조용히 채우지 않는다.
