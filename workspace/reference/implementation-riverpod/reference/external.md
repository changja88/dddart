# implementation-riverpod — 외부 조사 (riverpod 3.x 정식 기준)

> **[dddart 원료 메모] 외부 조사** — 공식 출처(pub.dev·riverpod.dev·GitHub rrousselGit/riverpod 저장소 CHANGELOG/README 원문) 기반, **확인일 2026-06-12**. 각 절 말미에 출처 URL 표기. 코드 예제는 riverpod 3.x 정식(코어 3.3.2 / annotation 4.0.3 / generator 4.0.4) 기준으로 작성했다. 기존 배포본과의 충돌·검증 결과는 §10에 모았다.

---

## 1. 버전 상태 — 3.0 정식 출시 확정·현행 버전·dev.17→정식 차이

**riverpod 3.0은 정식 출시됐다**: 3.0.0 안정판 2025-09-10 발행. 확인일(2026-06-12) 기준 현행 안정 버전 짝:

| 패키지 | 현행 안정판 | 비고 |
|---|---|---|
| flutter_riverpod / riverpod | **3.3.2** (2026-06-10 발행) | 코어는 3.x 라인 |
| riverpod_annotation | **4.0.3** | riverpod 3.3.2에 의존 — **annotation·generator는 4.x 라인이 현행** |
| riverpod_generator | **4.0.4** (4.0.0은 2025-12-26) | dev_dependency |
| riverpod_lint | **3.1.4** | riverpod 3.3.2 대상 |

- HaffHaff의 `^3.0.0-dev.17`(flutter_riverpod·riverpod_annotation·riverpod_generator, 2025-08-01 발행분)을 정식으로 올릴 때, annotation·generator는 3.x가 아니라 **4.x로 가는 것이 현행 조합**이다(4.0.3 ⇄ 코어 3.3.2 의존 관계를 pub.dev에서 확인).
- generator 4.0.0의 표기 관련 변경: "Generated providers are no-longer constant" — 생성된 provider가 더는 const가 아니다(const 문맥 사용 불가 외 사용 표기는 동일).

**dev.17 → 3.0.0 정식 사이의 변경 = 3.0.0-dev.18(2025-09-09) 하나뿐** (changelog 원문 확인):

- 재시도(retry) 중인 provider는 "loading"으로 플래그된다 — `ref.watch(provider.future)`가 중간 에러 상태를 건너뛴다.
- `FamilyNotifier`와 변종 제거(수동 작성 클래스용 — codegen 사용자는 영향 없음).
- `ProviderObserver`가 `base`로 마킹, persisted 상태가 throw 시 보존, `Mutation.call` 제네릭화.
- **→ codegen 기반 코드 표기에 닿는 dev.17→정식 차이는 사실상 없다.** 주요 파괴 변경(valueOrNull 제거·Ref 통합·자동 재시도 등)은 전부 dev.12(2025-04-30)·dev.16(2025-06-20)에 이미 들어가 있어 dev.17과 정식은 같은 표기 체계다.

**정식 이후(3.0.0→3.3.2) 표기에 닿는 추가분**: 3.1.0(2025-12-26) — provider 초기화 안에서 `AsyncValue.requireValue`로 비동기 provider를 동기 조합하는 패턴 공인. 3.2.0(2026-01-17) — `WidgetRef.listen/listenManual`에 `weak` 플래그 추가, `family.overrideWith` deprecated(→`overrideWith2`, 4.0.0에서 개명 예정), 의존성 변화 시 Notifier 상태 유실 regression 수정. 3.3.2-dev.1 — `Ref.onManualInvalidation()` 추가(수동 invalidate와 자동 재빌드 구분).

출처: https://pub.dev/packages/flutter_riverpod · https://pub.dev/packages/riverpod_annotation · https://pub.dev/packages/riverpod_generator · https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod/CHANGELOG.md (raw 원문 대조) · https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod_generator/CHANGELOG.md

## 2. @riverpod 변종 화이트리스트 — 6종 전부

공식 문서가 제시하는 codegen 변종은 **정확히 6종**이다(함수형 3 + 클래스형 3). 어느 변종이 생성되는지는 **선언의 반환형이 결정**한다 — 공식 지침: *"Don't think in terms of 'Which provider should I pick'. Instead, think in terms of 'What do I want to return'. The provider type will follow naturally."*

| # | 선언 표기 | 생성 provider 상당 | 언제 |
|---|---|---|---|
| 1 | `@riverpod String foo(Ref ref) { ... }` | Provider (동기 읽기 전용) | 파생·조합 값 |
| 2 | `@riverpod Future<T> foo(Ref ref) async { ... }` | FutureProvider | 읽기 전용 비동기 |
| 3 | `@riverpod Stream<T> foo(Ref ref) async* { ... }` | StreamProvider | 읽기 전용 스트림 |
| 4 | `@riverpod class Foo extends _$Foo { @override T build() {...} }` | NotifierProvider | **외부에서 변경 메서드가 필요한 동기 상태** |
| 5 | `@riverpod class Foo extends _$Foo { @override FutureOr<T> build() {...} }` | AsyncNotifierProvider | **변경 메서드가 필요한 비동기 상태** |
| 6 | `@riverpod class Foo extends _$Foo { @override Stream<T> build() {...} }` | StreamNotifierProvider | 변경 메서드가 필요한 스트림 |

- **AsyncNotifier.build의 정식 시그니처는 `FutureOr<StateT> build()`다** (API 문서 원문: `@visibleForOverriding FutureOr<StateT> build();`) — `Future<T>`·`FutureOr<T>` 둘 다 변종 5로 판정된다. dddart VM 계약의 `FutureOr<State> build()` 표기는 정식과 정합. build가 throw하거나 실패 future를 반환하면 "the error will be caught and an AsyncError will be emitted."
- 함수형 vs 클래스형의 공식 구분: 함수형은 읽기 전용, 클래스형은 "public methods that enable external objects to modify the state" — UI가 `ref.read(fooProvider.notifier).method()`로 변경을 일으킬 때 클래스형.
- **레거시 3종(StateProvider·StateNotifierProvider·ChangeNotifierProvider)은 codegen 변종에 없다** — 3.0에서 본체 export에서도 빠져 `package:flutter_riverpod/legacy.dart`로 이동(§8). codegen만 쓰면 레거시는 표기상 진입 불가 = 화이트리스트가 곧 집행이다.

**생성되는 provider 이름 규칙** (generator README 원문 — build.yaml 기본값):

```yaml
provider_name_prefix: ""            # 기본
provider_name_suffix: "Provider"    # 기본
provider_name_strip_pattern: "Notifier$"  # 기본 — 끝의 'Notifier'를 떼고 명명
```

- 함수 `example` → `exampleProvider`. 클래스 `Example` → `exampleProvider`(선두 소문자화 + Provider 접미).
- **기본 strip 패턴 때문에 클래스명이 `Notifier`로 끝나면 그 부분이 떨어진다**: `CounterNotifier` → `counterProvider`. dddart의 `*VM` 접미는 패턴에 안 걸린다 — `ChannelSummaryVM` → `channelSummaryVMProvider` (state §4 예제의 명명과 일치 확인).
- 파생 파일은 `.g.dart`(part). `@Riverpod(name: ...)`으로 개별 이름 지정도 가능(§3 표 참조).

**family(매개변수) 표기**: 별도 modifier 없이 **매개변수를 그냥 추가**한다 — named·optional·기본값 전부 허용. 클래스형은 build의 매개변수가 family 인자가 된다:

```dart
@riverpod
class ChannelDetailVM extends _$ChannelDetailVM {
  @override
  FutureOr<ChannelDetailState> build(String channelId) async { ... }
}
// 사용: ref.watch(channelDetailVMProvider('ch-1'))
```

출처: https://riverpod.dev/docs/concepts/about_code_generation · https://riverpod.dev/docs/concepts2/providers · https://pub.dev/documentation/riverpod/latest/riverpod/AsyncNotifier/build.html · https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod_generator/README.md (raw 원문)

## 3. keepAlive 표기 — autoDispose 기본의 의미·수명

**codegen 기본은 autoDispose다.** 수명의 정확한 기계: listener는 `ref.watch`/`ref.listen`으로 추적되고, **listener 수가 0이 되면 `Ref.onCancel` 발화 → 한 프레임 뒤에도 미사용이면 상태 파기 + `Ref.onDispose` 발화**. 새 listener가 다시 붙으면 `Ref.onResume`.

**keepAlive 표기는 `@Riverpod(keepAlive: true)` 하나다** (대문자 R — 인자를 받는 어노테이션 생성자):

```dart
@Riverpod(keepAlive: true)
class PushTokenService extends _$PushTokenService { ... }
```

`@Riverpod` 어노테이션의 전체 매개변수 (riverpod_annotation 4.0.3 API 문서):

| 매개변수 | 타입·기본값 | 의미 |
|---|---|---|
| `keepAlive` | `bool` = false | "Whether the state of the provider should be maintained if it is no-longer used." |
| `dependencies` | `List<Object>?` = null | 스코핑된 provider 의존 선언(§9 lint와 연동) |
| `retry` | `Duration? Function(int, Object)?` = null | provider별 재시도 정책(§8) |
| `name` | `String?` = null | 생성 provider 이름 지정 |

- keepAlive여도 **불멸이 아니다**: invalidate·refresh·의존성 변화로 재빌드는 일어난다. 막는 것은 "미사용 시 파기"뿐.
- 미세 제어가 필요하면 `ref.keepAlive()` — 예: 네트워크 성공 후에만 호출해 "성공 응답만 캐시 유지, 실패는 listener가 떠나면 파기"(공식 예제 서술 확인). dddart는 수명 결정을 변종(VM/SharedState/Service)으로 고정하므로(state §9 소유) 표기상 `@Riverpod(keepAlive: true)`만으로 충분하지만, 공식 API로 존재함은 기록한다.
- **3.0의 pause는 dispose와 별개 축이다**: 화면 밖(out-of-view) 위젯의 구독은 파기되지 않고 **일시정지**되며(TickerMode 기반), "A provider is now considered 'paused' if all of its listeners are also paused"(전이 전파). autoDispose 판정의 "listener 0"과 다르다 — pause된 listener는 여전히 listener다.

출처: https://riverpod.dev/docs/concepts2/auto_dispose · https://pub.dev/documentation/riverpod_annotation/latest/riverpod_annotation/Riverpod-class.html · https://riverpod.dev/docs/whats_new

## 4. ref.watch / ref.read / ref.listen 규율 — 공식 가이드

**ref.watch** — 기본값이자 "go-to choice". *"When you call `ref.watch(myProvider)`, your widget/provider subscribes to `myProvider`, and will rebuild whenever `myProvider` changes."* 허용 위치: provider 초기화(build)·notifier build·위젯 build·Consumer. 비동기 콜백·initState 등 생명주기 메서드에서는 호출 금지(그 자리는 read).

**ref.read** — 구독 없는 1회 읽기. 공식: *"You can safely call `Ref.read` button clicks to perform work."* — 이벤트 핸들러·Notifier 메서드 내부가 자리다. **공식 금지 패턴(원문)**: *"Do not use `Ref.read` as a mean to 'optimize' your code by avoiding `Ref.watch`. This will make your code more brittle."* — 리빌드 회피용 read는 동기화 버그를 만든다.

**ref.listen** — 상태 변화에 대한 **부수효과**(공식 예시: "showing a dialog, navigating to a new screen, logging a message") 전용. 위젯 **build 안에서 호출하는 것이 안전**하며 build 밖(initState 등)에서는 `listenManual`을 쓴다(§7). build 안 listen은 재빌드 시 재등록·해제가 자동 관리된다.

**공식 DO/DON'T 페이지의 추가 규율** (dddart에 닿는 것):

- **위젯에서 provider를 초기화하지 마라**: "Providers should initialize themselves. They should not be initialized by an external element such as a widget." — 초기화 로직은 provider 자신의 build에 (dddart: VM build가 UseCase로 직접 조회하는 구조와 정합).
- **ephemeral(위젯 국소) 상태에 provider를 쓰지 마라**: "Providers are designed to be for shared business state." — 폼 입력·애니메이션·컨트롤러류는 위젯 소유(dddart: 컨트롤러는 View 소유 규칙과 정합. 공식 문서는 대안으로 flutter_hooks를 권하지만 StatefulWidget도 같은 자리다).
- **provider 초기화 중 side effect(쓰기) 금지**: "Providers should generally be used to represent a 'read' operation." — 폼 제출류는 Notifier 메서드(또는 실험 단계인 Mutations §8)로.
- **정적으로 알려진 provider만 watch/read/listen하라**: provider를 생성자 인자로 넘기거나 인스턴스 변수에 담지 마라 — lint 집행 전제가 깨진다.
- **provider 동적 생성 금지**: "Providers should exclusively be top-level final variables."
- 부분 구독에는 `select()` 권장.

**비동기 간극(await) 뒤의 ref** — 3.0의 새 규율: dispose된 Ref/Notifier와의 상호작용은 **throw**다(changelog 원문: "**Breaking** All ref and notifier methods besides 'mounted' now throw if used after getting disposed."). await 뒤 상태 대입 전 `ref.mounted` 확인이 공식 패턴(BuildContext.mounted와 동형):

```dart
Future<void> submit() async {
  final result = await SomeUseCase().run();
  if (!ref.mounted) return; // 화면 이탈로 VM이 dispose된 경우
  result.fold(...);
}
```

출처: https://riverpod.dev/docs/concepts2/refs · https://riverpod.dev/docs/root/do_dont · https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod/CHANGELOG.md (3.0.0-dev.12 원문)

## 5. AsyncValue API — state §4 예제의 v3 검증

3.x의 AsyncValue는 **sealed class**(AsyncData·AsyncError·AsyncLoading)이고 공식 문서는 switch 패턴매칭으로 서술을 전환했다(changelog: "Updated AsyncValue documentations to use pattern matching"). `when`/`maybeWhen`/`whenData`/`whenOrNull`도 3.x에 전부 잔존한다 — 두 표기 모두 유효.

**핵심 파괴 변경 (3.0.0-dev.12, changelog 원문)**:

- "**Breaking** `AsyncValue.value` now returns `null` during errors."
- "**Breaking** removed `AsyncValue.valueOrNull` (use `.value` instead)."

즉 **`valueOrNull`은 3.x에 존재하지 않는다**(deprecated가 아니라 제거 — 3.3.2 API 문서에서 부재 확인). 2.x의 valueOrNull 역할을 `value`가 흡수했고, `value`는 어떤 상태에서도 throw하지 않는다.

| 멤버 | 3.x 동작 (API 문서 원문 기준) |
|---|---|
| `value` → `T?` | "The value currently exposed." 없으면 null — **throw 안 함** |
| `requireValue` → `T` | "If hasValue is true, returns the value. Otherwise if hasError, rethrows the error. Finally if in loading state, throws AsyncValueIsLoadingException." |
| `hasValue` / `hasError` / `error` | 잔존 |
| `isLoading` / `isRefreshing` / `isReloading` | 잔존 |
| `progress` → `num?` | 3.0 신규 — 진행률 노출 |
| `isFromCache` | 3.0 신규 — offline persistence(실험) 유래 여부 |
| `retrying` | dev.17 신규 — "to check when a retry is scheduled or pending" (§8 자동 재시도와 짝) |
| `copyWithPrevious` | dev.17에서 **@internal화** ("This API was not meant to be public") — 사용 금지 |
| `unwrapPrevious()` | 잔존 |
| `AsyncValue.guard(future, [test])` | 잔존 — try/catch 대체 정적 헬퍼. 제2인자 test로 잡을 에러 선별 |
| `AsyncResult` | dev.16 신규 — AsyncData·AsyncError의 공통 인터페이스(AsyncLoading 제외) |

**state §4 정식 예제의 항목별 판정**:

- `state = AsyncData(state.requireValue.copyWith(error: error))` — **유효**. `AsyncData(...)` 생성자·`requireValue` 모두 3.x 존재. 3.1.0은 provider 초기화 내 requireValue 조합 패턴을 공인하기까지 했다. *전제 조건*: `requireValue`는 hasValue가 아니면 throw하므로, **액션 메서드는 build가 데이터를 만든 뒤에만 불린다는 전제**(View가 data 상태 UI에서만 액션을 노출)가 필요하다 — 빌드 로딩 중·빌드 에러 상태에서 액션이 호출되면 그 자리에서 터진다(規律로 명문화할 가치).
- `final error = next.valueOrNull?.error;` — **무효. 컴파일 불가**(제거된 API). 교정 표기는 `next.value?.error`. HaffHaff 고정 버전(dev.17)에도 valueOrNull은 이미 없으므로(dev.12 제거) 이는 "정식 전환 시" 문제가 아니라 현행 기준으로도 깨진 표기다. → §10 충돌 ①.
- 조회 throw → AsyncValue.error 경로 — **유효**: build의 throw는 잡혀 AsyncError로 방출되고, **AsyncValue.error에는 원 에러가 그대로 담긴다**(whats_new: "Only raw errors appear in `AsyncValue.error` and observer callbacks") — View error 빌더는 BadRequestResponse를 raw로 받는다. 단 **rethrow 경로는 래핑된다**: `ref.watch(...)`/`ref.read(...)`/`.future` await로 타 provider의 에러가 재던져질 때는 `ProviderException`(원 에러는 `.exception`에) — §8.

출처: https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html · https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue/guard.html · https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod/CHANGELOG.md (dev.12·dev.16·dev.17·3.1.0 원문) · https://riverpod.dev/docs/whats_new

## 6. invalidateSelf · ref.invalidate — 재조회 표기

**`Ref.invalidateSelf({bool asReload = false})`** (3.x API 문서):

- 호출 즉시 현재 상태를 무효화하되 **재빌드는 비동기**("the rebuild is not immediate and is instead delayed by an undefined amount of time" — 통상 다음 이벤트 루프 틱). listener가 없으면 다음 관찰 시점까지 지연.
- **중복 호출은 1회 재빌드로 합쳐진다.** 미초기화·이미 dispose된 provider에는 무효과.
- `asReload: false`(기본) — 비동기 provider의 새 loading이 **이전 값을 유지**(isRefreshing 류). `asReload: true` — 이전 상태를 비우고 loading부터 시작하는 "hard refresh".
- 짝 API: `ref.invalidate(provider, {asReload})`(타 provider 무효화), `ref.refresh(provider)` = "invalidate + read 설탕"(즉시 재평가·새 값 반환). WidgetRef에도 동형으로 존재.
- 3.3.2-dev.1 신규 `Ref.onManualInvalidation()` — 수동 무효화(refresh/invalidate/invalidateSelf)와 의존성發 자동 재빌드를 구분해 듣는 lifecycle(연쇄 무효화 전달 패턴 공식 예제 있음).

**state §4의 `(_) => ref.invalidateSelf()`(액션 성공 후 서버 재조회) — 유효.** 참고로 v2 공식 문서(side effects)는 갱신 전략으로 ① invalidateSelf(서버가 진실원천·loading 자동 반영·추가 통신 1회) ② 수동 상태 갱신(통신 절약·서버 불일치 위험)을 견줬는데, v3 문서 트리에서 해당 페이지는 제거되고 실험 기능 Mutations 페이지로 대체됐다(§8 — 전략 논의 전문은 v2 문서에만 잔존, 미확인 항목).

출처: https://pub.dev/documentation/riverpod/latest/riverpod/Ref/invalidateSelf.html · https://riverpod.dev/docs/concepts2/refs · https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod/CHANGELOG.md (3.3.2-dev.1)

## 7. View 측 표기 — ConsumerWidget·ref.listen(build 안)·ConsumerStatefulWidget (hooks 없음)

**ConsumerWidget** — StatelessWidget 대체. build가 `WidgetRef`를 추가로 받는다:

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

**ConsumerStatefulWidget / ConsumerState** — 컨트롤러 등 위젯 상태가 필요할 때. `ref`는 ConsumerState의 프로퍼티로 **전 생명주기에서 가용**(initState에서 `ref.read` 가능). 단 **watch·listen은 build 안에서만** — build 밖 구독은 `listenManual`:

- `WidgetRef.listen` 3.x 시그니처: `listen<T>(provider, void Function(T? previous, T next) listener, {onError, bool weak = false})` — **fireImmediately 매개변수가 없다**(2.x와 차이). 반환 없음, 해제 자동.
- `WidgetRef.listenManual`: `{onError, bool fireImmediately, bool weak = false}` + **`ProviderSubscription` 반환**(수동 해제 — `close()`). initState 등 build 밖 자리.
- `weak` 플래그(3.2.0에서 WidgetRef에 추가): listener가 provider를 초기화·연명시키지 않음.
- **Consumer**(빌더 위젯)도 잔존 — 서브클래싱 없이 국소 구독.
- 공식 주의: "WidgetRef should not leave the widget layer" — WidgetRef를 위젯 밖(VM·service)으로 넘기는 구조 금지(dddart의 "handler는 plain class가 아니라 Notifier" 처방과 정합 — WidgetRef 필드 보유가 바로 이 위반).
- riverpod이 StatelessWidget+context.watch 식 접근을 제공하지 않는 이유(공식): autoDispose를 신뢰성 있게 구현하기 위해 명시적 Consumer 변종이 필요 — hooks 없이 ConsumerWidget·ConsumerStatefulWidget 둘로 전 화면이 커버된다(공식 문서도 hooks를 선택지로만 둔다).

출처: https://riverpod.dev/docs/concepts2/consumers · https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/WidgetRef-class.html · https://riverpod.dev/docs/concepts2/refs

## 8. v2→v3 차이 중 dddart에 닿는 것

**(a) 레거시 provider 이동** — `StateProvider`·`StateNotifierProvider`(·ChangeNotifierProvider)는 본체 export에서 빠져 `package:flutter_riverpod/legacy.dart` 별도 import로만 산다(changelog 원문 확인). dddart는 비채택이므로 **`/legacy.dart` import 자체를 위반 신호로 쓸 수 있다.**

**(b) Ref 통합** — "Removed all `Ref` subclasses (such `FutureProviderRef`). Use `Ref` directly instead." 함수형 표기는 `foo(Ref ref)` 하나로 통일(생성되던 `FooRef` 타입 소멸). 클래스형은 원래 `ref` 프로퍼티라 무변.

**(c) Notifier 인스턴스 수명 — 재생성 아님(주의: 중간에 뒤집힌 항목)** — dev.12가 "Notifier and variants are now recreated whenever the provider rebuilds"로 바꿨다가 **dev.16이 revert**: "Revert Notifier life-cycle change. They are once again preserved across rebuilds." 정식 3.x의 확정 동작은 **재빌드 간 인스턴스 보존**(2.x와 동일 — AsyncNotifier.build API 문서도 "the AsyncNotifier will **not** be recreated" 명시). 3.2.0에서 "의존성 변화 시 Notifier 상태 유실" regression까지 수정됐다. 단 dispose되면 끝 — (d)로 이어진다.

**(d) dispose 후 상호작용 = throw + `Ref.mounted`** — "All ref and notifier methods besides 'mounted' now throw if used after getting disposed." autoDispose VM의 액션 메서드가 await 중 화면이 닫히면, 복귀 후 `state = ...` 대입이 **런타임 에러**가 된다(2.x에선 조용한 무시/경고 수준이던 경로). 공식 가드는 `if (!ref.mounted) return;`(§4 예제). 추가로 "When a provider is rebuilt, a new `Ref` is now created" — 옛 빌드의 잔존 작업이 새 상태를 오염시키지 않는 격리 장치.

**(e) 자동 재시도 기본 ON — 행동 변화 중 최대 항목** (concepts2/retry 문서):

- 실패한 provider는 기본으로 **최대 10회, 200ms에서 시작해 2배씩 6.4s 상한의 지수 백오프**로 재시도된다.
- **제외 대상은 둘뿐**: `Error` 서브타입(코드 버그 — "Retrying in those cases would just pollute the logs with useless retry attempts")과 `ProviderException`(의존 provider의 실패). → **Exception 계열·일반 객체 throw는 재시도된다.** dddart의 조회 채널 ①(build에서 `BadRequestResponse` throw — Error도 ProviderException도 아님)은 **기본값에서 최대 10회 재호출**된다 = 실패한 UseCase→Repo→서버 호출이 백그라운드에서 반복된다. §10 충돌 ② — 정책 결정 필요.
- 재시도 중 상태: AsyncValue에 `retrying` 플래그(dev.17), provider는 "loading"으로 플래그되어 `ref.watch(provider.future)`가 중간 에러를 건너뛴다(dev.18). 기본 구현은 `ProviderContainer.defaultRetry`로 공개.
- 표기 — 전역: `ProviderScope(retry: (retryCount, error) => null, child: ...)`(null 반환 = 중단). provider별(codegen): 

```dart
Duration? noRetry(int retryCount, Object error) => null;

@Riverpod(retry: noRetry)
class ChannelSummaryVM extends _$ChannelSummaryVM { ... }
```

**(f) ProviderException 래핑** (dev.16) — "When a `ref.watch`/`ref.read` rethrows an error, the error is now wrapped in a `ProviderException`." 원 에러는 `.exception`으로 꺼낸다. AsyncValue.error 안은 raw 유지(§5) — dddart처럼 AsyncValue로 소비하면 무영향, `.future`를 await해 타 provider 에러를 catch하는 코드만 닿는다.

**(g) updateShouldNotify == 통일** — 알림 필터가 identical에서 `==`로 통일. dddart State가 freezed(구조 동등 ==)이므로 **같은 내용의 copyWith 재대입은 알림을 만들지 않는다** — 불필요 리빌드 감소와 동시에, "같은 에러를 두 번 연속 대입"이 listener에 안 보이는 동작이 된다(consumeError로 null 거쳐가는 dddart 패턴은 이 함정을 자연 회피 — error→null→error로 항상 변화가 생긴다).

**(h) pause 체계** — 화면 밖 위젯의 구독은 TickerMode 기반으로 일시정지, "If a provider is only used by paused providers, it is paused too." 항상 보이는 root_view→root_vm 사슬에는 무영향이나, 탭 전환으로 가려진 화면의 VM이 잠시 멈추는 동작이 기본이 됐다(파기 아님 — §3).

**(i) 실험 기능 2종 — 채택 보류 근거** — Mutations(부수효과의 idle/pending/error/success 상태 분리: `final addTodo = Mutation<Todo>();` → `addTodo.run(ref, (tsx) async {...})`)와 Offline persistence(`isFromCache`). 공식 경고 원문: "Mutations are experimental, and the API may change in a breaking way without a major version bump." — dddart의 액션 에러 채널(state §4)·hive 캐시(data §5)와 겹치는 자리지만 실험 단계이므로 비채택이 안전하다(사실 보고 — 채택 여부는 메인 루프 결정).

출처: https://riverpod.dev/docs/3.0_migration · https://riverpod.dev/docs/whats_new · https://riverpod.dev/docs/concepts2/retry · https://riverpod.dev/docs/concepts2/mutations · https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod/CHANGELOG.md (dev.12·dev.16·dev.18 원문 대조)

## 9. riverpod_lint — dddart 규약과 겹치는 규칙

riverpod_lint 3.1.4의 규칙 전체(15종)와 dddart 매핑. **설정 방식 주의**: 3.1.0(2025-12-26)부터 custom_lint가 아니라 **Dart analyzer 네이티브 플러그인**(analysis_server_plugin)으로 구현 — `analysis_options.yaml`의 `plugins:` 항목에 등록한다(changelog 원문: "riverpod_lint is no-longer implemented using custom_lint, but instead analysis_server_plugin").

**dddart 규약과 직접 겹침(기계 집행 확보)**:

| 규칙 | 원문 요지 | dddart 대응 |
|---|---|---|
| `avoid_build_context_in_providers` | "Providers should not interact with `BuildContext`." | state §2 — VM의 BuildContext 보유 금지 |
| `avoid_public_notifier_properties` | "The `Notifier`/`AsyncNotifier` classes should not have a public state outside of the `state` property." | state §3 — 상태는 freezed `*State`(=state 프로퍼티)로만 노출 |
| `protected_notifier_properties` | "Notifiers should not access the state of other notifiers. This includes `.state`, `.future`, and `.ref`." | state §7·§8 — VM을 바깥에서 조작 금지·타 VM 접근 금지(같은 BC 안에서도 기계 차단) |
| `avoid_keep_alive_dependency_inside_auto_dispose` | "Warn when a `keepAlive` provider tries to use a non-`keepAlive` provider." | state §9 수명표 — keepAlive(SharedState·Service)가 autoDispose(VM)를 watch하는 역방향을 차단(dddart 규약상 원래 금지 — lint가 잡아준다) |
| `unsupported_provider_value` | StateNotifier·ChangeNotifier 류 반환 경고 | 레거시 비채택(§8a)의 집행 |

**codegen 표기 자체를 강제(implementation-riverpod 본문 소재)**: `functional_ref`(함수형의 Ref 매개변수 형식) · `notifier_extends`(`extends _$ClassName` 강제) · `notifier_build`(build 메서드 필수) · `riverpod_syntax_error`(generator가 탐지한 문법 오류 표면화).

**조건부로 닿는 것**: `provider_parameters`(family 인자의 == 일관성 — freezed/원시값 인자면 자동 충족) · `missing_provider_scope`(main의 ProviderScope) · `async_value_nullable_pattern`(`AsyncValue(:final value?)` 패턴이 nullable 데이터에서 위험 — null이 "값 없음"과 "값이 null"을 겹침) · `avoid_ref_inside_state_dispose`(ConsumerState.dispose에서 ref 금지). 스코핑 계열(`provider_dependencies`·`scoped_providers_should_specify_dependencies`)은 dddart가 중첩 ProviderScope·override를 안 쓰는 한 발화하지 않는다.

**제거된 규칙**: `avoid_manual_providers_as_generated_provider_dependency` — 3.0.0-dev.18에서 삭제(기술 제약 해소). 또한 ref-after-await를 잡는 lint(`use_ref_read_synchronously` 류)는 **존재하지 않는다** — §4의 `ref.mounted` 가드는 lint가 안 잡아주므로 규약 텍스트로 강제해야 한다.

출처: https://pub.dev/packages/riverpod_lint · https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod_lint/README.md (raw 원문) · https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod_lint/CHANGELOG.md

## 10. 기존 배포본 대조 — 충돌·검증 결과 종합

**충돌 ① (컴파일 불가 — 즉시 교정 필요)**: `dddart/skills/architecture-state/references/final.md` §4 정식 예제(행 113) — `final error = next.valueOrNull?.error;`. `AsyncValue.valueOrNull`은 3.0.0-dev.12(2025-04-30)에서 **제거**됐다("removed AsyncValue.valueOrNull (use .value instead)"). 정식뿐 아니라 HaffHaff 고정 버전(dev.17)에서도 컴파일되지 않는 표기다. 교정: `next.value?.error` (3.x의 `value`는 어떤 상태에서도 throw하지 않음 — §5).

**충돌 ② (행동 변화 — 정책 결정 필요)**: 같은 파일 §4 채널 ①(행 69 — "BadRequestResponse를 throw → AsyncValue.error"). riverpod 3.0의 자동 재시도 기본값에서 `BadRequestResponse` throw는 재시도 제외 대상(Error·ProviderException)이 아니므로 **기본 최대 10회(200ms→6.4s 백오프) build 재실행 = 실패한 서버 호출 반복**이 된다. 채널 ① 서술에는 재시도 정책이 없다. 선택지: ⓐ 전역 `ProviderScope(retry: ...)`로 끄거나 BadRequestResponse만 제외 ⓑ VM별 `@Riverpod(retry:)` ⓒ 기본 수용(서버 일시 장애 자동 복구로 활용 — 단 4xx류 무의미 반복 비용). — 메인 루프 결정 사항.

**충돌 ③ (런타임 위험 — 예제 보강 후보)**: 같은 파일 §4 정식 예제(행 98~104 `leaveChannel`) — await 뒤 `state = ...` 대입에 `ref.mounted` 가드가 없다. 3.0부터 dispose된 Notifier와의 상호작용은 throw이므로(§8d), autoDispose VM + 액션 중 화면 이탈 시나리오에서 런타임 에러가 된다. 공식 가드 표기는 `if (!ref.mounted) return;`.

**검증 통과(3.x 정식 기준 유효 확인)**: `@riverpod class ChannelSummaryVM extends _$ChannelSummaryVM`(변종 5) · 생성명 `channelSummaryVMProvider`(strip 패턴 "Notifier$"는 VM 접미 무영향) · `FutureOr<ChannelSummaryState> build()`(AsyncNotifier.build 정식 시그니처) · `state = AsyncData(state.requireValue.copyWith(...))`(단 hasValue 전제 — §5) · `ref.invalidateSelf()` · build 안 `ref.listen(provider, (previous, next) {...})` · `ref.read(provider.notifier).method()` · `@Riverpod(keepAlive: true)`(state §6·§9 표기) · 에러 raw 보존(View error 빌더가 BadRequestResponse를 그대로 받음). `architecture-ddd` final.md §4의 `ref.invalidateSelf` 언급, `architecture-data` final.md에는 riverpod 표면 없음 — 충돌 없음.

출처: §1~§9의 각 출처 + /Users/hyun/Desktop/dddart/dddart/skills/architecture-state/references/final.md (2026-06-12 대조)

---

## 미확정 (unresolved)

1. **재시도 중 위젯에 보이는 AsyncValue의 정확한 상태**: dev.18 원문은 "provider가 loading으로 플래그되어 `provider.future`가 중간 에러를 스킵"까지만 명시. error 빌더(`when`의 error 분기)가 재시도 완료 전에 호출되는지(AsyncError 즉시 방출 + retrying 플래그로 추정)는 공식 문서에 위젯 관점 서술이 없다 — 채널 ① UX 설계 전 실측 1회 필요.
2. **riverpod_lint 3.1.x(analysis_server_plugin 방식)의 최소 Dart SDK**: changelog에 "analyzer 12 support"만 — Dart ^3.9(HaffHaff 기준) 환경 호환 여부 미확인. pub.dev SDK 제약 직접 확인 필요.
3. **riverpod_annotation 3.x 라인의 말미 버전**: HaffHaff의 `^3.0.0-dev.17` 제약이 정식 해소 시 정확히 어느 3.x에 멈추는지 미확인 — 현행 권장이 4.x(코어 3.3.2와 짝)라 실익 낮음.
4. **v2 side-effects 문서의 갱신 3전략 전문**: invalidateSelf vs 수동 갱신 비교 논의의 원문은 v3 문서 트리에서 제거됨(essentials/side_effects 404) — docs-v2.riverpod.dev에 잔존 추정, 본 조사에서는 미인용.
5. **generator 4.0.0 "Generated providers are no-longer constant"의 영향 전수**: const 문맥 사용 불가 외 추가 영향(예: switch case 상수 매칭) 미조사.
