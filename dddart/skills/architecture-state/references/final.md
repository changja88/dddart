# 상태 아키텍처 — ViewModel 3변종·State 계약·생명주기

> **출처:** 제1 규약(dddart 표준 파일트리, 2026-06-11~12) §3.3·§3.6·§8·§9·§10-5 ① · dddart 파이프라인 본설계(2026-06-12) §8 · HaffHaff-App 실물 대조(2026-06-12).
> 본문 속 `(규약 §N)`·`(본설계 §N)`은 **출처 표기**(설계 문서의 절 번호)이며 로드 대상이 아니다 — 규칙 자체는 본문에 자족적으로 서술된다. 로드 가능한 위임은 "스킬명 + §번호(또는 주제)"와 공유 reference(`undecidable.md`)뿐.

---

## 목차

- §1. application_layer 지도 — Model 관문 1 + ViewModel 3변종
- §2. ViewModel — 화면 상태의 주인
- §3. State 계약 — 항상 freezed `*State`
- §4. 에러 2채널 — 조회는 throw, 액션은 error 필드 (정식 예제)
- §5. SharedState — 화면 간 공유 상태
- §6. Service — 헤드리스 ViewModel
- §7. 교차 BC 상태 — SharedState watch 금지·root 면제
- §8. refresh 채널 처방 — 폐지된 갱신 버스의 대체
- §9. keepAlive — 수명 결정 기준
- §10. 합성 루트의 상태 — root_vm·handler·initializer 동작 규율

---

## §1. application_layer 지도 — Model 관문 1 + ViewModel 3변종

application_layer는 **Model의 관문 하나(`use_case/`)와 ViewModel의 세 변종(`view_model/`·`shared_state/`·`service/`), 그리고 ViewModel이 노출하는 상태 모델(`state/`)**로 구성된다 (규약 §3.3). 세 변종을 가르는 축은 *상태의 수명*과 *구동원* 둘뿐이다:

| 종류 | MVVM 위치 | 상태 | 구동원 | 수명 |
|---|---|---|---|---|
| `use_case/` | Model 관문 | 무상태 | 호출당함 | — |
| `view_model/` | ViewModel | 화면 1개 | View 이벤트 | 화면 |
| `shared_state/` | ViewModel (공유) | 화면 N개 공유 | 여러 VM/View | 화면 그룹 |
| `service/` | ViewModel (헤드리스) | 앱 전역 | 플랫폼 이벤트 | 앱 전체 (keepAlive) |

의존은 단방향 하나로 고정된다: View → VM·SharedState(·플랫폼 이벤트 → Service) → UseCase → Repo·infra service. VM·SharedState·Service는 **Model 방향으로는 UseCase만 호출**한다 — Repo/DataSource/SDK 직접 호출 금지. 위임 한 줄짜리 UseCase도 정상이며, 관문의 일관성이 VM→Repo 지름길의 근거가 되지 않는다 (규약 §3.3). UseCase는 VM을 모른다(역방향 금지) — UseCase 자체의 규율(도메인 개념 명명·판정 소유·Either 통과)은 architecture-ddd §8 소유.

application_layer 안의 **수평 협력은 허용**: VM·View가 **같은 BC의** SharedState를 watch·호출하고, Service가 SharedState를 갱신할 수 있다(타 BC는 §7).

**이 스킬과 architecture-data의 경계** (본설계 §8 — 한 주제 한 소유자): data = 데이터가 앱 바깥(서버·디스크)과 어떻게 오가는가 / state(이 스킬) = 들어온 데이터가 앱 안에서 화면들 사이에 어떻게 살아 있는가. 판례 ① **캐싱**: hive 저장 = data, 메모리 keepAlive = state — 목적이 같아도 소유자가 다르다. ② **에러**: 서버 에러가 오는 모양(Either 계약·정규화) = data, 그 에러를 State에 담아 표시·소비하는 방식 = state(§4).

파일·폴더·명명·import 매트릭스 사실은 discipline-houserules §1·§4·§5 소유 — 이 문서는 각 종류의 **동작 계약과 결정 절차**를 소유한다.

## §2. ViewModel — 화면 상태의 주인

VM은 화면 1개의 상태 주인이다 (규약 §3.3): `build()`가 `FutureOr<State>`를 반환하고, View 이벤트를 UseCase 호출로 **번역**하며, 도메인 결과를 화면 State로 **변환**한다. VM의 일은 번역과 변환이다 — 도메인 어휘로 진술되는 판정·계산은 1곳째부터 domain이 기본이며(판정 소유·강등 규칙은 architecture-ddd §5 소유), specification의 평가·조합도 Model(UseCase 이하)에서만 한다.

- **BuildContext 직접 보유 금지** (규약 §3.3·§9-7): 화면 전환은 `<bc>_navigator`(BC 루트) 경유 — navigator는 라우트 이름만 참조하므로 VM이 호출해도 계층 역류·import 순환이 없다. HaffHaff 실측: `_vm.dart` 77개 중 73개가 이미 준수.
- **컨트롤러는 View 소유** (규약 §3.3 — §10-5 ① 확정): TextEditingController·FocusNode 등 UI 컨트롤러는 View(StatefulWidget/hooks)가 보유하고, **값은 VM 메서드 인자로 전달**한다. HaffHaff 실측: 입력 컨트롤러의 VM 보유 0건 — 이미 관례다. (ScrollController·탭 재탭 스크롤톱은 §8 참조.)
- **DI 없음** (규약 §3.3·§9-13): UseCase는 VM 안에서 **직접 생성**한다(`ChannelUseCase()`). UseCase·Repo·DataSource는 무상태다 — 상태는 box·서버·State 모델에만 둔다. `@riverpod` provider가 허용되는 위치의 닫힌 열거는 discipline-houserules §4 소유 — 결정 절차는 단순하다: **상태를 보유하는 ViewModel 변종(VM·SharedState·Service, root에선 root_vm·handler)만 provider가 된다.**
- **base VM·공용 헬퍼 없음** (규약 §10-5 ① 확정): 에러 처리·listen 패턴을 상속·믹스인으로 공통화하지 않는다 — 상속은 전 VM을 한 몸으로 묶는 결합 표면이고, AI coder에겐 반복이 더 결정적이다. 패턴은 §4의 정식 예제를 그대로 반복한다(반복>상속 일반 규율은 discipline-cleancode §18 소유).

## §3. State 계약 — 항상 freezed `*State`

**VM은 도메인 엔티티·패키지 타입을 직노출하지 않고 항상 자기 freezed `*State`를 노출한다** (규약 §3.3 — §10-5 ① 확정).

- 무한스크롤 PagingState 같은 패키지 타입은 **State의 필드로** 감싼다.
- **액션 전용 VM도 최소 State를 갖는다** — error 필드 1개짜리 State가 최소형이다.
- *왜* — 직노출은 액션 에러를 담을 자리가 없어 전역 다이얼로그 직행을 유발한다(HaffHaff 실측: App 44개 중 36개가 ErrorDialog 직접 호출 — 그 오염 경로의 입구가 State 부재다).
- State는 `application_layer/state/`의 freezed 모델이고 노출 주체(화면·관심사·기능)와 같은 접두를 쓴다 — 명명·위치 사실은 discipline-houserules §1·§4.
- State에는 **액션 실패 표준 필드** `BadRequestResponse? error`를 둔다(§4). freezed 문법 상세는 implementation-dart 소유.

화면 상태 모델이 domain_layer가 아니라 application_layer에 사는 이유 (규약 §9-4·§9-7): state 파일은 VM·View만 import한다(HaffHaff 사용처 추적 — 도메인 코드 사용 0건) = 화면이 바뀔 때 같이 바뀌는 ViewModel 계층의 소유물이다.

## §4. 에러 2채널 — 조회는 throw, 액션은 error 필드 (정식 예제)

에러 표시는 두 채널뿐이다 (규약 §3.3 — §10-5 ① 확정). 서버 에러가 **오는 모양**(전 실패가 `Either<BadRequestResponse, T>`로 정규화되어 도착)은 architecture-data §2·§3 소유 — 이 절은 도착한 에러를 화면에 **전달하는** 방식이다.

| 채널 | 실패 지점 | 경로 | 표시 |
|---|---|---|---|
| ① 조회(빌드) | `build()` | BadRequestResponse를 **throw** → `AsyncValue.error` | view의 error 빌더 — 화면 단위 에러·재시도 (riverpod 내장 메커니즘) |
| ② 액션 | 버튼·제출 등 메서드 | State의 표준 필드 `BadRequestResponse? error`에 담는다 | View가 `ref.listen`으로 감지·표시(`isShow` 존중) 후 **`consumeError()`로 명시 소비** |

UseCase는 Repo의 Either를 통과·조합하며 새 throw를 만들지 않는다 — 조회 실패를 AsyncValue.error로 넘기는 throw는 **VM의 일**이다 (규약 §3.4).

**정식 예제** — base VM·공용 헬퍼 없이 이 패턴을 그대로 반복한다 (HaffHaff "플래그→listen→표시→리셋" 33파일 관례의 에러 확장). freezed·@riverpod 표기법 상세는 implementation-dart·implementation-riverpod 소유:

```dart
// application_layer/state/channel_summary_state.dart (개념 1차 분할 전 평면 — 성장 규칙은 discipline-houserules §2)
@freezed
abstract class ChannelSummaryState with _$ChannelSummaryState {
  const factory ChannelSummaryState({
    @Default([]) List<Channel> channels,
    BadRequestResponse? error, // 액션 실패 표준 필드 — 철자는 HaffHaff 실물(errorType·msg·isShow)
  }) = _ChannelSummaryState;
}

// application_layer/view_model/channel_summary_vm.dart
@riverpod
class ChannelSummaryVM extends _$ChannelSummaryVM {
  @override
  FutureOr<ChannelSummaryState> build() async {
    final result = await ChannelUseCase().getChannels(); // 직접 생성 — DI 없음
    return result.fold(
      (error) => throw error, // ① 조회 실패 — AsyncValue.error로
      (channels) => ChannelSummaryState(channels: channels),
    );
  }

  Future<void> leaveChannel(String channelId) async {
    final result = await ChannelUseCase().leaveChannel(channelId);
    result.fold(
      (error) => state = AsyncData(state.requireValue.copyWith(error: error)), // ② 액션 실패
      (_) => ref.invalidateSelf(), // 성공 — 목록 재조회
    );
  }

  void consumeError() {
    state = AsyncData(state.requireValue.copyWith(error: null));
  }
}

// presentation_layer/view/channel_summary_view.dart — View 쪽 소비 (build 안)
ref.listen(channelSummaryVMProvider, (previous, next) {
  final error = next.valueOrNull?.error;
  if (error == null) return;
  if (error.isShow) {
    // 표시 — design_system 컴포넌트를 View가 context로 호출 (architecture-ui §7, 호출 표기는 implementation-flutter)
  }
  ref.read(channelSummaryVMProvider.notifier).consumeError(); // 명시 소비 — 재빌드 재표시 방지
});
```

- `isShow: false`인 에러도 **소비는 한다** — error 필드에 남겨두면 다음 액션 실패와 구별되지 않는다.
- 에러를 DateTime·카운터 핵으로 위장한 "이벤트 신호"로 바꾸지 않는다 — §5의 과거형 사건명 금지와 같은 축.

## §5. SharedState — 화면 간 공유 상태

한 화면의 변화(좋아요·댓글)를 다른 화면에 동기화하는 `@riverpod` Notifier다 (규약 §3.3). 같은 BC의 VM·View가 watch·호출하고 Service가 갱신할 수 있다(§1 수평 협력).

- **keepAlive로 둔다** — 화면 그룹보다 수명이 길어야 하는데 autoDispose면 보는 화면이 사라질 때 상태가 유실된다(HaffHaff `comment_added_bridge` 실측 위험). **+ 명시적 reset**(상태를 초기값으로 되돌리는 공개 메서드)을 둔다 — 규약은 reset의 존재까지 규정하며, 호출 시점은 소유 데이터의 수명을 따라 설계가 정한다.
- **과거형 사건명 금지** (규약 §3.3·§8): `*_added`·`*_completed`·`*_received` 류는 상태로 위장한 이벤트다 — 값이 DateTime·카운터 핵이 되고, 소비자가 값을 읽지 않고 변화 자체에만 반응하게 된다. 공유 **상태**는 명사 관심사로 짓는다(`<관심사>_shared_state`). 판별 절차·개명 가이드는 공유 reference `undecidable.md`(`${CLAUDE_PLUGIN_ROOT}/skills/discipline-houserules/references/undecidable.md`) §10 소유. 이벤트형 요구가 진짜면 설계 반송 — 도메인 이벤트는 dddart 비채택(규약 §9-15·§10-6 재논의 항목)이며, 그 전까지 shared_state로 위장하지 않는다.
- **일회성 소비가 필요한 상태**(표시 후 사라져야 하는 것)는 §4의 consumeError와 같은 패턴을 쓴다 — 값을 읽은 소비자가 명시적으로 리셋 메서드를 호출한다. 리셋 없이 "두 번 발화 방지"를 위해 DateTime 핵·센티널 초기값을 도입하기 시작하면 이벤트 위장의 신호다.

## §6. Service — 헤드리스 ViewModel

View 이벤트가 아닌 **플랫폼 이벤트**(FCM 수신·토큰 갱신·앱 라이프사이클)를 받아 UseCase를 호출하는 `@Riverpod(keepAlive: true)` Notifier다 (규약 §3.3). 화면이 없을 뿐 ViewModel 변종이므로 Model 방향 규율(UseCase만 호출)이 동일 적용된다.

- **능동이면 application, 수동이면 infra** (규약 §3.3·§3.4): 이벤트를 받아 유스케이스를 구동하면 `application_layer/service/`, 호출당하는 SDK 어댑터(무상태)면 `infra_layer/service/`(architecture-data §6). HaffHaff drift 실례: `permission_service.dart`가 keepAlive Notifier·App 호출·상태 노출인데 infra에 있었다 — 성격상 application_layer 물건.
- **푸시의 분업** (규약 §3.6): 같은 푸시라도 탭(목적지 분배)은 root_destination_handler(§10), 수신 처리(토큰 갱신·메시지 저장)는 push BC의 service다. BC service에서 `go(`·navigator 호출 금지 — 입장 판별 절차는 공유 reference `undecidable.md` §5.

## §7. 교차 BC 상태 — SharedState watch 금지·root 면제

교차 BC 통신 4채널의 전체 목록(닫힌 열거)은 discipline-houserules §5 소유다. 이 절은 그중 **상태 측면**의 규율만 다룬다 (규약 §9-3):

- **타 BC SharedState watch 금지·타 BC VM watch 금지.** 다른 BC의 데이터·행위가 필요하면 **그 BC의 UseCase를 호출**한다(단발). 반응형으로 "살아 있는" 타 BC 상태가 필요해 보이면 설계를 다시 본다 — 대부분은 ① 그 화면을 view 임베드로 가져오거나(view는 자기 VM을 스스로 watch하므로 배치만으로 충분) ② 변화 시점에 자기 BC의 SharedState를 갱신하는 것으로 충분하다.
- **root만 면제** (규약 §3.6): root_vm·root_view·handler는 BC SharedState를 watch할 수 있다 — 뱃지처럼 BC에서 발원하는 반응형 전역 표시 상태의 표준 공급 채널이다(UseCase는 단발 호출이라 반응성이 없다). 면제는 root/ 안에서만이다 — BC끼리는 불가.
- HaffHaff 실측: 교차 BC import 321건이 전부 4채널과 그 위반으로 분류됐고 이벤트형 통지는 0건 — 교차 BC에 이벤트 버스는 필요하지 않았다.

## §8. refresh 채널 처방 — 폐지된 갱신 버스의 대체

HaffHaff의 `refresh_notifier`(8개 BC의 VM 12개를 import해 `ref.refresh`를 조작하는 교차 갱신 버스)와 `scroll_to_top_notifier`(BC 어휘+needTo/complete 플래그의 위장 이벤트)는 **종류째 폐지**됐다 (규약 §8·§9-11). 같은 요구가 오면 처방은 3분기다:

| 요구 | 처방 |
|---|---|
| 데이터가 바뀌어서 다른 화면도 갱신돼야 한다 | **그 BC의 SharedState**(§5) — 변화를 일으킨 쪽이 SharedState를 갱신하고, 갱신이 필요한 화면의 VM·View가 watch한다 |
| 앱 라이프사이클(복귀 등)발 갱신 | **root_lifecycle_handler → BC service**(§6·§10) — 전역 이벤트의 분배는 root, 도메인 반응은 BC |
| 탭 재탭 스크롤톱 | **root_view가 직접 처리** — BC는 신호를 듣지 않는다. 메커니즘 상세(PrimaryScrollController 등)는 implementation-flutter 소유(규약 §10-5 ④ — 그 스킬 작성 시 결정될 **미결** 항목) |

공통 원칙: **VM을 바깥에서 조작하지 않는다.** `ref.refresh`를 타 BC·common이 호출하는 구조는 어떤 명분이든 금지 채널(타 BC VM 접근)의 우회다.

## §9. keepAlive — 수명 결정 기준

이 스킬은 **수명 결정**(어느 변종을 쓰고 언제 keepAlive인가)을 소유하고, `@Riverpod(keepAlive: true)` **표기법**은 implementation-riverpod이 소유한다.

| 대상 | 수명 | keepAlive |
|---|---|---|
| VM | 화면 | **아니오** — 화면과 함께 사라진다(autoDispose 기본) |
| SharedState | 화면 그룹 | **예** + 명시적 reset(§5) — 보는 화면이 사라져도 상태 유지 |
| Service | 앱 전체 | **예** — 플랫폼 이벤트는 화면과 무관하게 도착한다 |
| root handler | 앱 전체 | **예**(Service 변종 — §10) |

- 결정 절차: "이 상태를 보는 화면이 전부 사라졌을 때 상태가 살아 있어야 하는가?" — 아니오면 VM(기본), 화면 그룹 사이에서 예면 SharedState, 화면과 무관하게 항상이면 Service.
- root_vm의 keepAlive는 규약이 명시하지 않는다 — handler와 달리 명시 결정이 없는 항목이며, 동작 규율은 §10.
- **keepAlive를 캐싱 수단으로 쓰는 것은 이 스킬 소관이다**(메모리 수명) — 디스크 캐시(hive)는 architecture-data §5 소관. 목적이 같아도 소유자가 다르다(§1 경계).

## §10. 합성 루트의 상태 — root_vm·handler·initializer 동작 규율

root의 위치·폴더 구조·`root_` 접두 사실은 discipline-houserules §1 소유다. 이 절은 root 구성물의 **상태 동작 규율**이다 (규약 §3.6 "root 내부 협력 규칙"):

- **root_vm은 "거의 빈 VM"이다** — 탭·뱃지·강제업데이트 같은 앱 전역 표시 상태만 갖는다. 탭 인덱스 자체는 go_router의 `StatefulNavigationShell`이 보유하므로 그보다도 가볍다. 특정 도메인 기능이 자라기 시작하면 그 화면은 root가 아니다 — 판별은 공유 reference `undecidable.md` §6.
- **handler 3종은 ViewModel의 Service 변종이다** — `@Riverpod(keepAlive: true)` Notifier로 작성하고, **root_vm이 `build()`에서 ref.watch로 활성화**한다. plain class로 두면 ref가 없어 WidgetRef 필드 보유 안티패턴(HaffHaff `RootLifecycleHandler` 실측)이 재발한다.
- **root_initializer는 부수효과만 책임진다**(SDK 초기화·hive 엔진·어댑터 조립) — 결과 객체를 반환하지 않는다. 자동로그인 성패·강제업데이트 여부 같은 **시동 질문은 root_vm이 `build()`에서 UseCase를 호출해 직접 획득**한다 — ProviderScope 이전/이후 간극을 전달이 아니라 재조회로 해소한다(이미 열린 로컬 box 조회라 사실상 무비용).
- **rootRouter는 plain 전역 변수다**(provider 아님) — redirect의 상태 확인은 UseCase를 직접 생성·호출한다. DI 없음 덕분에 ref가 필요 없다(HaffHaff redirect의 TokenManager 직행 교정).
- **게이트의 상태 주인**: 게이트 표시 여부는 root_vm이, 게이트 화면 내부 상태는 게이트 자신의 VM(`root_<게이트>_vm`)이 갖는다. 차단 메커니즘은 root_router 최상위 redirect + scaffold의 게이트 라우트 — 탭 프레임 밖 라우트까지 덮는다.
- root도 Model 규율 동일 적용: **UseCase만 호출**(Repo·box 직행 금지). BC SharedState watch 면제는 §7.
