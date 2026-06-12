# riverpod 표기법 — 3.x codegen·AsyncValue·ref 규율

> **출처:** riverpod 3.x 공식 문서·API 레퍼런스·changelog 원문(2026-06-12 확인 — 절별 URL은 작업장 external.md) · 제1 규약 §9-13 · dddart 결정(2026-06-12): 자동 재시도 전역 OFF.
> 본문 속 `(규약 §N)`은 **출처 표기**이며 로드 대상이 아니다. 로드 가능한 위임은 "스킬명 + §번호(또는 주제)"뿐.

---

## 목차

- §1. 버전·전제 — 3.x 정식, annotation·generator는 4.x 짝
- §2. @riverpod 변종 — dddart 화이트리스트(클래스형 3종)
- §3. keepAlive 표기
- §4. ref 규율 — watch/read/listen·mounted 가드
- §5. AsyncValue 표기 — value·requireValue·전제 조건
- §6. 재조회 — invalidateSelf·asReload
- §7. View 측 표기 — ConsumerWidget·listen·listenManual
- §8. 재시도 정책 — 전역 OFF (dddart 확정)
- §9. 금지 표면 — legacy·실험 기능·내부 API
- §10. riverpod_lint 연동 — 기계 집행 확보

---

## §1. 버전·전제 — 3.x 정식, annotation·generator는 4.x 짝

riverpod 3.0은 정식이다(3.0.0 안정판 2025-09-10). 현행 안정 짝: **flutter_riverpod 3.x · riverpod_annotation 4.x · riverpod_generator 4.x**(dev) — annotation·generator는 3.x가 아니라 4.x 라인이 코어 3.x의 현행 짝이다(pub.dev 의존 관계 확인). riverpod_lint 3.1.x.

- 선언은 `package:riverpod_annotation/riverpod_annotation.dart` import + `part '<파일명>.g.dart'` — codegen은 build_runner(파이프라인의 codegen 규약은 본설계 소유).
- generator 4.0부터 생성된 provider는 **const가 아니다** — const 문맥에 provider를 쓰지 않는다.
- 기존 프로젝트가 3.0.0-dev.17 류 dev 핀이면 표기 체계는 정식과 동일(파괴 변경은 dev.12·16에 선행) — 버전 정리는 핀 해소 시점의 일.

## §2. @riverpod 변종 — dddart 화이트리스트(클래스형 3종)

공식 codegen 변종은 6종(함수형 3 + 클래스형 3)이고, **선언의 반환형이 변종을 결정**한다. dddart는 **클래스형 3종만 쓴다** — @riverpod의 자리가 ViewModel 변종(VM·SharedState·Service)과 root 2변종(root_vm·handler)뿐이고(허용 위치 닫힌 열거는 discipline-houserules §4), 전부 "외부에서 변경 메서드가 필요한 상태"라 클래스형이다:

| 표기 | 생성 provider 상당 | dddart의 자리 |
|---|---|---|
| `@riverpod class Foo extends _$Foo { @override T build() {...} }` | NotifierProvider (동기) | 동기 초기화 VM·SharedState (예: 인자 받아 즉시 State 구성) |
| `@riverpod class Foo extends _$Foo { @override FutureOr<T> build() async {...} }` | AsyncNotifierProvider | **표준 VM**(서버 조회 build — architecture-state §2) |
| `@riverpod class Foo extends _$Foo { @override Stream<T> build() {...} }` | StreamNotifierProvider | 서버 이벤트 구독 Service(WebSocket 류)가 생기면 — 현재 표준 예 없음 |

- **함수형 3종(읽기 전용 — `@riverpod T foo(Ref ref)` 류)은 쓰지 않는다**: dddart의 상태 보유자 어휘에 대응하는 자리가 없다. 파생·조합 값은 State의 필드나 freezed getter로 해소한다(architecture-state §3).
- `FutureOr<State> build()`가 AsyncNotifier.build의 정식 시그니처다 — build의 throw는 잡혀 `AsyncError`로 방출된다(에러 2채널 ①의 메커니즘 — architecture-state §4).
- **생성 이름 규칙**: 클래스 `ChannelSummaryVM` → `channelSummaryVMProvider`(선두 소문자화+`Provider` 접미). 기본 strip 패턴 `Notifier$` 때문에 클래스명이 `Notifier`로 끝나면 그 부분이 떨어진다 — dddart 접미(`VM`·`SharedState`·`Service`·`Handler`)는 안 걸린다.
- **family(매개변수)는 build에 매개변수를 그냥 추가**한다(별도 modifier 없음): `FutureOr<ChannelDetailState> build(String channelId)` → `ref.watch(channelDetailVMProvider('ch-1'))`. named·optional·기본값 허용.

## §3. keepAlive 표기

**`@Riverpod(keepAlive: true)`** 하나다(대문자 R — 인자 받는 생성자). 기본은 autoDispose: listener가 0이 되면 onCancel이 발화하고, **한 프레임 뒤에도 미사용이면** 상태 파기(새 listener가 그 사이 붙으면 유지).

```dart
@Riverpod(keepAlive: true)
class PushTokenService extends _$PushTokenService { ... }
```

- 어느 변종이 keepAlive인가(SharedState·Service·handler=예, VM=아니오)는 **architecture-state §9가 소유** — 이 스킬은 표기만 소유한다.
- keepAlive여도 invalidate·refresh·의존성 변화로 재빌드는 일어난다 — 막는 것은 "미사용 시 파기"뿐.
- 3.x의 pause는 별개 축이다: 화면 밖 위젯의 구독은 파기가 아니라 **일시정지**된다(탭 전환으로 가려진 화면의 VM이 잠시 멈추는 것이 기본 동작 — 버그가 아니다).

## §4. ref 규율 — watch/read/listen·mounted 가드

| API | 자리 | 규율 |
|---|---|---|
| `ref.watch` | build(provider·위젯) 안 | 기본값. 구독+재빌드. 비동기 콜백·생명주기 메서드에서 호출 금지 |
| `ref.read` | 이벤트 핸들러·Notifier 메서드 안 | 구독 없는 1회 읽기. **리빌드 회피용 read 금지**(공식: "Do not use Ref.read as a mean to 'optimize'… This will make your code more brittle") |
| `ref.listen` | 위젯 build 안 | 부수효과(다이얼로그·내비·로깅) 전용 — 에러 표시 채널 ②의 자리(architecture-state §4). 재등록·해제 자동 |

- **await 뒤에는 `ref.mounted` 가드**가 의무다 — 3.x에서 dispose된 Ref/Notifier와의 상호작용은 mounted 외 전부 **throw**: `if (!ref.mounted) return;` (architecture-state §4 정식 예제에 포함). **이 가드를 잡는 lint는 존재하지 않는다** — 표기 규율로만 강제된다.
- 공식 DO/DON'T 중 dddart에 닿는 것: 위젯이 provider를 초기화하지 않는다(초기화는 build 자신의 일 — VM build가 UseCase로 직접 조회하는 구조와 정합) / ephemeral 상태(폼 입력·컨트롤러)에 provider 금지(컨트롤러는 View 소유 — architecture-state §2) / provider 초기화 중 쓰기(side effect) 금지 / provider는 top-level final로만(동적 생성·인자 전달 금지) / 부분 구독은 `select()`.

## §5. AsyncValue 표기 — value·requireValue·전제 조건

3.x의 AsyncValue는 sealed class(AsyncData·AsyncError·AsyncLoading)다. `when` 류와 switch 패턴매칭 둘 다 유효 표기다.

| 멤버 | 3.x 동작 |
|---|---|
| `value` → `T?` | 값 없으면 null — **어떤 상태에서도 throw 안 함**. (2.x의 `valueOrNull`은 **제거됨** — 그 역할을 value가 흡수. `valueOrNull`을 쓰면 컴파일 불가) |
| `requireValue` → `T` | hasValue면 값, 에러면 rethrow, 로딩이면 throw |
| `hasValue`·`hasError`·`error`·`isLoading`·`isRefreshing` | 잔존 |
| `AsyncValue.guard(...)` | 잔존 — try/catch 대체 정적 헬퍼 |

- 액션 패턴 `state = AsyncData(state.requireValue.copyWith(error: error))`의 **전제 조건**: requireValue는 hasValue가 아니면 throw하므로, **액션 메서드는 build가 데이터를 만든 뒤에만 불린다** — View는 data 상태 UI에서만 액션을 노출한다(로딩·에러 빌더에 액션 버튼을 두지 않는다). 이 전제가 깨지는 화면이면 액션 진입을 View에서 막는 것이 먼저다.
- listen 콜백의 표준 읽기: `next.value?.error` (무throw).
- build의 throw는 **raw로** AsyncValue.error에 담긴다 — View error 빌더는 BadRequestResponse를 그대로 받는다. 단 `ref.watch`/`.future`로 **타 provider의 에러가 재던져질 때는 `ProviderException`으로 래핑**된다(원 에러는 `.exception`) — AsyncValue로 소비하는 dddart 표준 경로에는 무영향.
- freezed State + 3.x의 `updateShouldNotify`(== 기준) 조합: **같은 내용의 copyWith 재대입은 알림을 만들지 않는다** — consumeError가 error→null→error로 항상 변화를 만들기 때문에 dddart 에러 채널은 이 함정을 자연 회피한다(architecture-state §4의 명시 소비가 중요한 또 하나의 이유).

## §6. 재조회 — invalidateSelf·asReload

- `ref.invalidateSelf()` — 자기 무효화(액션 성공 후 서버 재조회의 표준 표기 — architecture-state §4). 재빌드는 비동기이고 중복 호출은 1회로 합쳐진다.
- `asReload: false`(기본) — 재로딩 중 **이전 값 유지**(isRefreshing — 화면이 깜빡이지 않는다). `asReload: true` — 이전 상태를 비우고 loading부터(hard refresh).
- `ref.invalidate(provider)` — 타 provider 무효화(단 타 VM 조작 금지는 architecture-state §7·§8 소유 — 표기가 있다고 채널이 열리는 게 아니다). `ref.refresh` = invalidate+read 설탕.

## §7. View 측 표기 — ConsumerWidget·listen·listenManual

```dart
class ChannelSummaryView extends ConsumerWidget {
  const ChannelSummaryView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(channelSummaryVMProvider, (previous, next) { ... }); // build 안 — 공식 안전 위치
    final state = ref.watch(channelSummaryVMProvider);
    ...
  }
}
```

- 컨트롤러 등 위젯 상태가 필요하면 **ConsumerStatefulWidget/ConsumerState** — `ref`는 전 생명주기 가용(initState에서 read 가능), 단 **watch·listen은 build 안에서만**.
- build 밖(initState 등) 구독은 `ref.listenManual(...)` — `ProviderSubscription` 반환(수동 `close()`), `fireImmediately` 지원. `WidgetRef.listen`(build 안)에는 3.x에서 fireImmediately가 **없다**(2.x과 차이).
- **WidgetRef를 위젯 밖으로 반출하지 않는다**(공식: "WidgetRef should not leave the widget layer") — plain class가 WidgetRef 필드를 보유하는 구조가 그 위반이다(root handler가 plain class가 아니라 Notifier여야 하는 이유 — architecture-state §10).
- hooks는 쓰지 않는다 — ConsumerWidget·ConsumerStatefulWidget 둘로 전 화면이 커버된다.

## §8. 재시도 정책 — 전역 OFF (dddart 확정)

riverpod 3.x는 **실패한 provider를 기본으로 자동 재시도한다**(최대 10회·200ms→6.4s 지수 백오프). 제외는 `Error` 서브타입과 `ProviderException`뿐 — **조회 채널 ①의 BadRequestResponse throw는 재시도 대상**이라, 기본값에서는 확정 실패(safeApiCall이 정규화한 타임아웃 포함)가 서버에 최대 10회 반복되고 에러 표면화가 백오프만큼 지연된다(재시도 중 위젯에 보이는 정확한 상태는 공식 문서 미서술 — OFF 결정으로 논점 소멸).

**dddart 결정(2026-06-12 사용자 확정): 전역 OFF.** main.dart의 ProviderScope에 1줄:

```dart
runApp(ProviderScope(
  retry: (retryCount, error) => null, // 자동 재시도 전역 OFF — 실패는 즉시 에러 채널로
  child: ...,
));
```

- 실패는 즉시 AsyncValue.error → error 빌더(채널 ①)로 표면화하고, 재시도는 사용자의 명시 행동(재시도 버튼 → invalidateSelf)이다.
- 자동 재시도가 정말 어울리는 특수 화면만 **provider별로 켠다**: `Duration? customRetry(int retryCount, Object error) => ...;` + `@Riverpod(retry: customRetry)`.

## §9. 금지 표면 — legacy·실험 기능·내부 API

- **legacy provider**(StateProvider·StateNotifierProvider·ChangeNotifierProvider): 3.x에서 `package:flutter_riverpod/legacy.dart`로 격리됐다 — dddart 비채택. **`/legacy.dart` import 자체가 위반 신호다.**
- **실험 기능 비채택**: Mutations(액션 상태 분리 — 공식이 "may change in a breaking way without a major version bump"로 경고)·Offline persistence(`isFromCache` — 동급 실험 단계). dddart의 같은 자리는 확정 설계가 있다 — 액션 에러는 State error 필드(architecture-state §4), 디스크 캐시는 hive(architecture-data §5). 안정화되면 재평가.
- `copyWithPrevious` — @internal화("This API was not meant to be public") — 사용 금지.
- 함수형 provider 3종 — §2(화이트리스트 밖).
- **hooks_riverpod(HookConsumerWidget) 비사용** — 공식 문서 예제에 자주 등장하지만 dddart는 ConsumerWidget·ConsumerStatefulWidget 둘로 전 화면을 커버한다(§7).

## §10. riverpod_lint 연동 — 기계 집행 확보

riverpod_lint 3.1.x는 custom_lint가 아니라 **analyzer 네이티브 플러그인**이다 — `analysis_options.yaml`의 `plugins:`에 등록한다(최소 Dart SDK 제약은 도입 시 pub.dev에서 1회 확인 — 미확정 항목).

dddart 규약과 직접 겹치는 규칙(켜 두면 규약이 기계 집행된다):

| lint 규칙 | dddart 규약 |
|---|---|
| `avoid_build_context_in_providers` | VM의 BuildContext 보유 금지 (architecture-state §2) |
| `avoid_public_notifier_properties` | 상태는 freezed State(=state 프로퍼티)로만 노출 (architecture-state §3) |
| `protected_notifier_properties` | 타 notifier의 state·ref 접근 금지 (architecture-state §7·§8) |
| `avoid_keep_alive_dependency_inside_auto_dispose` | keepAlive가 autoDispose를 watch하는 역방향 차단 (architecture-state §9 수명표) |
| `unsupported_provider_value` | legacy 비채택의 집행 (§9) |

- codegen 표기 강제 계열(`functional_ref`·`notifier_extends`·`notifier_build`·`riverpod_syntax_error`)은 이 스킬 본문의 표기를 기계 검증한다.
- **ref-after-await(mounted 가드)를 잡는 lint는 없다** — §4의 가드는 정식 예제 반복으로만 강제된다.
