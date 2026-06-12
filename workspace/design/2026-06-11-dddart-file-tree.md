# dddart 표준 파일트리 (제1 규약)

- 상태: **확정(2026-06-12) — 파이널 리뷰 반영 완료, 사용자 확정**
- 기준점: `HaffHaff-App` (2026-06-11, `lib/application/` 16개 BC 전수 조사)
- 지위: dddjango의 README 파일트리·`discipline-houserules`에 해당하는 **dddart의 제1 규약**. 이 문서가 확정되면 houserules 스킬·design-architect의 구조 결정·백스톱 스크립트·README가 모두 이 트리를 단일 근거로 삼는다.

---

## 1. 원칙

1. **기준은 이론이 아니라 HaffHaff-App이다.** 이 트리는 교과서에서 도출한 것이 아니라, 운영 중인 Flutter 앱의 실제 구조에서 의도를 추출해 정제한 것이다. 단, 사용자가 명시적으로 방언과 다르게 결정한 지점 — dddjango 정렬(도메인 계층의 애그리거트 1차), 철저한 MVVM(§9-7), 일반 MVVM 용어 정렬(§9-8) 등 §9의 확정 결정들 — 은 그 결정이 우선한다.
2. **간소화 DDD.** dddjango(서버)는 풀 DDD를 강제했지만 dddart(클라이언트)는 형식 장치를 줄인다 — repository 인터페이스 없음, DTO 없음, ACL 없음. 구조의 뼈대(컨테이너·4계층·개념 1차·종류 2차)는 유지한다.
3. **철저한 MVVM.** 지식은 View → VM → UseCase(Model 관문) → Repo 한 방향으로만 흐른다. Model(UseCase 이하)은 UI를 모른다 — 방언과 충돌하는 지점은 §9-7대로 교정한다.
4. **파일트리가 곧 규약이다.** 어떤 파일을 어디에 어떤 이름으로 만드는지가 dddart가 강제하는 핵심이며, 코드 내용 규율은 그다음이다.

---

## 2. 표준 트리 (전체)

```
lib/
├── main.dart                                # 엔트리포인트 최소형 — root_initializer 호출 + runApp 조립만 (§3.6)
├── firebase_options.dart                    # (Firebase 채택 시) flutterfire 생성물 — 도구 고정 위치·자동 생성, 백스톱 검사 제외 (2026-06-12 §10-2 확정)
├── root/                                    # 합성 루트 (§3.6) — 전체를 아는 유일한 곳, 계층 없음 (역할 4폴더)
│   ├── router/                              #   ① 내비 그래프
│   │   └── root_router.dart                 #     전 BC <bc>_router 합산
│   ├── scaffold/                            #   ② 루트 스캐폴드 (개념 폴더) — 탭 셸 + BC 어휘 없는 전역 게이트만
│   │   ├── view/                            #     root_view.dart — 탭 프레임, BC export view 임베드
│   │   ├── view_model/                      #     root_vm.dart — "거의 빈 VM" 규범 (§3.6)
│   │   └── state/                           #     root_state.dart
│   ├── handler/                             #   ③ 전 BC 배선 — 이벤트원당 1파일 (*_handler)
│   │   ├── root_destination_handler.dart    #     딥링크·푸시(딥링크로 정규화) → BC 디스패치
│   │   ├── root_lifecycle_handler.dart      #     전역 라이프사이클 → BC service
│   │   └── root_error_handler.dart          #     전역 에러 → 크래시리포트·표시
│   └── initializer/                         #   ④ 시동
│       └── root_initializer.dart            #     SDK 초기화 + BC hive 어댑터 조립 (§9-9)
├── application/                             # BC 컨테이너 — 직속은 BC 폴더만 (균일)
│   └── <bc>/                                # 바운디드 컨텍스트 (기능 영역) 1개
│       ├── <bc>_router.dart                 # go_router GoRoute 정의 — 라우트 path·name 단일 출처
│       ├── <bc>_navigator.dart              # 정적 push 헬퍼 — 라우트 이름만 참조, View import 금지 (§3.1)
│       │
│       ├── domain_layer/                    # 순수 Dart — package:flutter import 금지
│       │   └── <aggregate>/                 # 애그리거트(개념) 1차 — dddjango와 동일
│       │       ├── <aggregate>.dart         # 애그리거트 루트 — 일관성 경계
│       │       ├── entity/                  # 종속 엔티티 (freezed + json)
│       │       ├── value_object/            # 값 객체·도메인 분류 값
│       │       ├── enum/                    # 도메인 enum
│       │       ├── domain_service/          # stateless 도메인 로직
│       │       ├── specification/           # Specification
│       │       └── exception.dart           # 도메인 예외
│       │
│       ├── application_layer/
│       │   ├── use_case/                    # 유스케이스 (command+query 통합) — Model의 관문, Either 반환
│       │   ├── view_model/                  # @riverpod Notifier — 화면 1개의 상태 주인 (ViewModel)
│       │   ├── state/                       # 상태 모델 (freezed) — VM·SharedState·Service가 노출
│       │   ├── shared_state/                # 화면 간 공유 상태 (@riverpod) — VM의 공유 변종
│       │   └── service/                     # 헤드리스 ViewModel — 플랫폼 이벤트 구동 (keepAlive)
│       │
│       ├── infra_layer/
│       │   ├── data_source/                 # 데이터 출처 정의 — 원격(retrofit) + 로컬(hive 등)
│       │   ├── repository/                  # 구체 클래스 (인터페이스 없음) — 원격+로컬 조합, 단일 진실 원천
│       │   └── service/                     # 수동 SDK 어댑터 (호출당하는 쪽)
│       │
│       └── presentation_layer/
│           ├── view/                        # 화면 (ConsumerWidget, vmProvider watch)
│           ├── section/                     # 한 화면 전속 구획 (dumb — prop·콜백만)
│           ├── widget/                      # BC 내 재사용 부품 (dumb, 화면 비전속)
│           └── ui_extension/                # 도메인 enum·VO → UI 매핑 extension (색·아이콘·라벨)
│
├── common/                                  # 횡단 공통 — BC를 모른다 (application·root import 금지, @riverpod 금지, §6)
│   ├── enum/                                # 전역 enum (global key·env)
│   ├── network/                             # dio client·auth interceptor·safeApiCall·BadRequestResponse
│   ├── local_database/                      # 로컬 DB 엔진 + 전역 데이터 (토큰·앱 설정) — BC 데이터 캐시는 BC infra로
│   ├── service/                             # BC 무관 플랫폼 서비스 (애널리틱스·이미지·디바이스)
│   └── util/                                # 순수 유틸 (포맷터·계산기·확장)
│
└── design_system/                           # BC 어휘를 모르는 시각 요소 — 토큰 + 컴포넌트 (§6)
    ├── foundation/                          # 디자인 토큰 — 시각 값의 단일 출처
    │   ├── app_color.dart                   #   AppColor — 팔레트 + 시맨틱
    │   ├── app_typography.dart              #   AppTypography — TextStyle 세트
    │   ├── app_spacing.dart                 #   AppSpacing — 간격 스케일
    │   ├── app_radius.dart                  #   AppRadius — 곡률
    │   ├── app_shadow.dart                  #   AppShadow — 그림자(elevation)
    │   ├── app_duration.dart                #   AppDuration — 모션 시간·커브
    │   └── app_asset.dart                   #   AppAsset — 아이콘·이미지 경로
    ├── theme/
    │   └── app_theme.dart                   #   foundation → ThemeData 조립 (light/dark 확장점)
    ├── component/                           # 공용 위젯 — 부품군 1차, 직속 파일 금지
    │   ├── app_bar/ · button/ · dialog/ · bottom_sheet/
    │   └── input/ · loading/ · image/ · feedback/ · background/ …
    └── util/                                # 시각 동작 헬퍼 (스크롤 동작·미디어쿼리·TextStyle 빌더)
```

---

## 3. 계층·종류 카탈로그

각 종류의 역할, 명명, HaffHaff-App 실제 예시.

### 3.1 BC 루트 — 라우팅 짝

| 항목 | 규약 | 실예시 |
|---|---|---|
| 라우터 | `<bc>_router.dart` — `GoRoute` 정의를 export, `root_router.dart`가 조립. **라우트 path·name 상수의 단일 출처** | `channel_router.dart` → `final GoRoute channelRouter = GoRoute(...)` |
| 내비게이터 | `<bc>_navigator.dart` — 정적 push 메서드 + 화면 진입 애널리틱스. **라우트 이름만 참조(`pushNamed`), View import 금지** | `channel_navigator.dart` → `ChannelNavigator` |

> navigator를 계층 밖(BC 루트)에 두는 이유: HaffHaff처럼 presentation_layer에 두면 VM(application_layer)이 호출하는 순간 계층 역류가 되고, navigator가 View를 import하면 `VM→navigator→View→VM` import 순환이 생긴다. BC 루트 + 라우트 이름만 참조로 둘 다 해소된다(§8·§9-7).
>
> **라우트 상수 표기**: 라우트 path·name 문자열 리터럴은 `<bc>_router.dart` 안에서만 등장한다 (백스톱 검사 대상). 같은 파일의 `abstract final class <Bc>Routes`(static const)로 묶고, navigator·root_destination_handler는 이 상수만 참조한다. 탭 branch(`StatefulShellBranch`) 조립은 root_router 소유 — BC는 GoRoute만 export한다(§3.6).

### 3.2 domain_layer — 순수 Dart, 애그리거트(개념) 1차

`package:flutter` import 금지. freezed·json_annotation·dartz 등 순수 패키지만 허용.

**dddjango의 domain_layer 원형에서 `repository/`·`port/`만 뺀 구조다** (사용자 확정 2026-06-11). 애그리거트(개념) 폴더가 1차, 종류 폴더가 2차이며, 애그리거트 루트는 폴더 직속 파일이다. 단일 애그리거트 BC라도 애그리거트 폴더를 만든다:

```
member/domain_layer/
└── member/                          # 애그리거트 1차
    ├── member.dart                  #   애그리거트 루트 — class Member (일관성 경계)
    ├── entity/                      #   종속 엔티티: photo.dart · member_photo.dart
    ├── value_object/                #   값 객체
    ├── enum/                        #   도메인 enum
    ├── domain_service/              #   stateless 도메인 로직
    ├── specification/               #   Specification
    └── exception.dart               #   도메인 예외
```

| 종류 | 역할 | 파일 | 클래스 | 예시 |
|---|---|---|---|---|
| 애그리거트 루트 | 일관성 경계. 폴더 직속 단일 파일 | `<aggregate>.dart` | 애그리거트명 | `member/member.dart` → `Member` |
| `entity/` | **종속 엔티티** — 루트가 아닌 엔티티. 서버 JSON 직접 파싱(DTO 없음) | `<개념>.dart` | 개념명 | `member/entity/photo.dart` → `Photo` |
| `value_object/` | 값 객체·도메인 분류 값 | `<개념>.dart` | 개념명 | `chat_request_status.dart` |
| `enum/` | 도메인 enum | `<개념>.dart` | 개념명 | `channel_type.dart` → `ChannelType` |
| `domain_service/` | **그 애그리거트 중심의** stateless 도메인 로직. 여러 애그리거트에 걸치는 **순수 판정**은 판정 대상(주어) 애그리거트에 귀속, **흐름 조율**은 UseCase의 일 — 공용 위치 없음 (2026-06-12 확정, specification 동일 규칙) | `<행위>_service.dart` | `<행위>Service` | `pricing_service.dart` → `PricingService` |
| `specification/` | Specification 패턴 — 재사용·조합되는 판정 규칙. **풀네임, `_spec` 축약 금지** | `<규칙>_specification.dart` | `<규칙>Specification` | `visible_lounge_post_specification.dart` → `VisibleLoungePostSpecification` |
| 도메인 예외 | 폴더 직속 단일 파일 | `exception.dart` | `*Exception` 모음 | — |

**종류 폴더 생성 규칙**: 애그리거트를 만들 때 **표준 종류 폴더 5개 전부를 항상 생성한다 — 비어도 둔다** (선택 폴더 없음, 사용자 확정). 코드는 필요할 때만 쓴다. 도메인 개념이 아직 불명확한 BC는 **BC와 동명의 애그리거트**를 기본값으로 만든다. 애그리거트 루트 `<aggregate>.dart`는 항상 생성하고, `exception.dart`는 첫 도메인 예외가 생길 때 만든다(골격 대상 아님 — §5).

> HaffHaff-App 현재는 domain_layer가 평면(종류 폴더만)이지만, dddart 표준은 dddjango 정렬을 따른다 — 새로 만드는 기능부터 적용하며 기존 코드 수정을 요구하지 않는다. `enum/`은 dddjango 원형에 없던 HaffHaff 고유 종류로 유지한다.
>
> HaffHaff가 `domain_layer/<aggregate>/state/`에 두던 화면 상태 모델은 **`application_layer/state/`로 옮겼다** (§3.3, 철저한 MVVM — §9-7). 화면 상태는 화면이 바뀔 때 같이 바뀌는 ViewModel 계층의 소유물이고, domain_layer에는 도메인 이유로만 바뀌는 코드를 남긴다.
>
> dddjango의 `repository/`(추상 인터페이스)·`port/`(외부 컨텍스트 협력 포트)·`event/`(도메인 이벤트)는 **만들지 않는다**. repository·port는 간소화 결정, event는 실측·통설 근거(§9-15) — 클라는 도메인 이벤트를 생성하지 않고 구독하며(서버 이벤트 구독은 `service/` 담당), 교차 BC 통지는 4채널(§9-3)로 충분하다.

### 3.3 application_layer — MVVM의 ViewModel 계층 + Model의 관문

철저한 MVVM(§9-7) 기준으로 이 계층은 **Model의 관문 하나(`use_case/`)와 ViewModel의 세 변종(`view_model/`·`shared_state/`·`service/`), 그리고 ViewModel이 노출하는 상태 모델(`state/`)**로 구성된다. 세 변종을 가르는 축은 *상태의 수명*과 *구동원* 둘뿐이다:

| 종류 | MVVM 위치 | 상태 | 구동원 | 수명 |
|---|---|---|---|---|
| `use_case/` | Model 관문 | 무상태 | 호출당함 | — |
| `view_model/` | ViewModel | 화면 1개 | View 이벤트 | 화면 |
| `shared_state/` | ViewModel (공유) | 화면 N개 공유 | 여러 VM/View | 화면 그룹 |
| `service/` | ViewModel (헤드리스) | 앱 전역 | 플랫폼 이벤트 | 앱 전체 (keepAlive) |

| 종류 | 역할 | 파일 | 클래스 | 실예시 (HaffHaff 대응) |
|---|---|---|---|---|
| `use_case/` | 유스케이스 — dddjango의 command+query 통합. Repo·infra service 호출, `Either` 반환(Right=성공 — §3.4). **UI 호출 금지** — `package:flutter/material`·presentation·design_system import 금지(백스톱 검사 대상), 에러 표시는 VM 담당(§9-7) | `<개념>_use_case.dart` | `<개념>UseCase` | `channel_use_case.dart` ← HaffHaff `channel_app.dart`(`ChannelApp`) |
| `view_model/` | 화면 1개의 상태 주인. `build()`가 `FutureOr<State>` 반환, View 이벤트를 UseCase 호출로 번역, 도메인 결과를 화면 State로 변환. 화면 전환은 navigator 헬퍼(BC 루트, §3.1) 경유 — **BuildContext 직접 보유 금지**(§9-7) | `<화면>_vm.dart` | `<화면>VM` | `channel_summary_vm.dart` → `ChannelSummaryVM` |
| `state/` | 상태 모델 (freezed) — VM·SharedState·Service가 노출하는 단위 | `<화면·관심사·기능>_state.dart` | `…State` | `channel_summary_state.dart` → `ChannelSummaryState` |
| `shared_state/` | 화면 간 공유 상태. 한 화면의 변화(좋아요·댓글)를 다른 화면에 동기화하는 `@riverpod` Notifier — **keepAlive**(autoDispose 유실 방지, §8 `comment_added_bridge` 실측) + 명시적 reset. 과거형 사건명(`*_added` 류) 금지 — 이벤트 위장(§8), 이벤트형 요구는 §10-6 | `<관심사>_shared_state.dart` | `<관심사>SharedState` | ← HaffHaff `lounge_post_interaction_bridge.dart` |
| `service/` | 헤드리스 ViewModel — View 이벤트가 아닌 **플랫폼 이벤트**(FCM 수신·토큰 갱신·앱 라이프사이클)를 받아 UseCase를 호출하는 `@Riverpod(keepAlive: true)` Notifier | `<기능>_service.dart` | `<기능>Service` | `firebase_messaging_service.dart` (push) |

의존은 단방향 하나로 고정된다 (백스톱 검사 대상):

```
View ─→ VM·SharedState ────┐
플랫폼 이벤트 ─→ Service ────┴→ UseCase → Repo·infra service → DataSource·SDK
```

- VM·SharedState·Service는 **Model 방향으로는 UseCase만 호출**한다 — Repo/DataSource/SDK 직접 호출 금지. 위임 한 줄짜리 UseCase도 정상이며, 관문의 일관성이 VM→Repo 지름길의 근거가 되지 않는다.
- application_layer 안의 **수평 협력은 허용**: VM·View가 **같은 BC의** SharedState를 watch·호출하고, Service가 SharedState를 갱신할 수 있다 (타 BC SharedState watch는 금지 — §9-3, root만 면제 — §3.6).
- UseCase는 VM을 모른다 (역방향 금지). 같은 UseCase를 여러 VM이 재사용한다.
- 화면 전환은 VM → `<bc>_navigator`(BC 루트, §3.1) — 라우트 이름만 참조하므로 계층 역류가 아니다.
- **DI 없음**(§9-13): UseCase는 VM 안에서, Repo는 UseCase 안에서, DataSource는 Repo 안에서 **직접 생성**한다. `@riverpod` provider는 VM·SharedState·Service 3종뿐이다. UseCase·Repo·DataSource는 **무상태**다 — 상태는 box·서버·State 모델에만 둔다 (호출처마다 새 인스턴스가 생겨도 동작이 같아야 "직접 생성"과 "단일 진실 원천"이 양립한다).
- `service/`(application) vs `service/`(infra) 구분: **능동이면 application** — 이벤트를 받아 유스케이스를 구동(UseCase 호출). **수동이면 infra** — 호출당하는 SDK 어댑터(§3.4).
- **판정 소유(2026-06-12 적대 리뷰 개정)**: **도메인 어휘로 진술되는 판정은 1곳째부터 domain이 기본**이다 — 설계 명세가 행위 목록의 모든 수치·비교·자격 판정에 소유자(domain vs VM 변환)를 항목별로 라벨링하고, VM 소유를 주장하려면 *왜*를 적는다(신규 기능의 판정은 항상 소비처 1곳이라 복제 규칙만으론 빈혈에 집행자가 없다). 같은 도메인 판정이 **Model 밖 2곳**(VM·view·section·ui_extension·State getter 포함 — "VM 2곳"에서 확장)에 복제되면 `domain_service/`·`specification/`으로 강등한다 — VM의 일은 변환이지 판정이 아니다 (코드 규율 상세는 §10-5 ③).
- **State 계약(2026-06-12 §10-5 ① 확정)**: VM은 도메인 엔티티·패키지 타입을 직노출하지 않고 **항상 자기 freezed `*State`를 노출**한다 — 무한스크롤 PagingState는 State의 필드로, 액션 전용 VM도 최소 State(error 필드 1개). *왜* — 직노출은 액션 에러를 담을 자리가 없어 전역 다이얼로그 직행(HaffHaff App 36/44 오염 경로)을 유발한다. 백스톱 NM4(삼총사)와 한 몸.
- **에러 표시 2채널(2026-06-12 §10-5 ① 확정)**: ① 조회(빌드) 실패 — VM `build()`가 BadRequestResponse를 throw → `AsyncValue.error` → view의 error 빌더(화면 단위 에러·재시도, riverpod 내장 메커니즘) ② 액션 실패 — State의 표준 필드 `BadRequestResponse? error`에 담고, View가 `ref.listen`으로 감지·표시(`isShow` 존중) 후 **`consumeError()`를 호출해 명시 소비**(null 리셋 — 재빌드 재표시 방지). HaffHaff의 "플래그→listen→표시→리셋" 33파일 관례의 에러 확장이며, 과거형 사건명·DateTime 핵 위장 이벤트 금지는 유지. **base VM·공용 헬퍼는 만들지 않는다** — 패턴 3줄은 스킬 코퍼스의 정식 예제로 주입(상속은 전 VM을 한 몸으로 묶는 결합 표면, AI coder에겐 반복이 더 결정적).
- **컨트롤러는 View 소유(2026-06-12 §10-5 ① 확정)**: TextEditingController·FocusNode 등 UI 컨트롤러는 View(StatefulWidget/hooks)가 보유하고 값은 VM 메서드 인자로 전달한다(HaffHaff 실측: 입력 컨트롤러의 VM 보유 0건 — 이미 관례. ScrollController 3건은 스크롤톱 메커니즘으로 별도 처방 §10-5 ④). 백스톱 IM12(application flutter 전면 금지)와 한 몸.

다섯 종류 폴더(`use_case/`·`view_model/`·`state/`·`shared_state/`·`service/`) 전부 BC 생성 시 비어도 항상 만든다(§5).

### 3.4 infra_layer

| 종류 | 역할 | 파일 | 클래스 | 실예시 |
|---|---|---|---|---|
| `data_source/` — 원격 | retrofit `@RestApi` 추상 클래스 — 엔드포인트 정의, **도메인 엔티티 직접 반환** | `<개념>_data_source.dart` | `<개념>DataSource` | `channel_data_source.dart` |
| `data_source/` — 로컬 | BC 도메인 데이터의 로컬 저장 접근자 — hive box 정의·읽기/쓰기 | `<개념>_local_data_source.dart` | `<개념>LocalDataSource` | ← HaffHaff `common/local_database/hive/member/member_hive.dart`(`MemberHive`) |
| `repository/` | **구체 클래스 (인터페이스 없음)**. 원격·로컬 DataSource를 조합하는 **단일 진실 원천** — `safeApiCall`로 감싸 `Either<BadRequestResponse, T>` 반환 (**Right=성공** — 통용 관례, 2026-06-12 확정. 기존 프로젝트에 확립된 Either 방향이 있으면 그것 우선) | `<개념>_repo.dart` | `<개념>Repo` | `channel_repo.dart` → `ChannelRepo` |
| `service/` | **수동 SDK 어댑터** — 호출당하는 쪽, 상태 없음, UseCase를 모름. Repo의 자매(서버 API 대신 플랫폼 SDK를 감쌈) | `<기능>_service.dart` | `<기능>Service` | `inapp_purchase_service.dart` (store) |

> 폴더명은 `repository/`(전체 표기), 파일 접미사는 `_repo.dart`(축약) — HaffHaff 다수 관례를 표준으로 고정.
>
> **실패의 단일 출구(2026-06-12 §10-5 ① 확정)**: `safeApiCall`은 DioException만이 아니라 **모든 예외**(타임아웃·JSON 파싱·타입 캐스트)를 잡아 `BadRequestResponse`로 정규화한다(`errorType`으로 기인 구분 — `timeout`·`parse`·`unknown`). Repo·infra service는 어떤 실패도 throw로 탈출시키지 않는다 — **전 실패 = Either**. UseCase는 Repo의 Either를 통과·조합하며 새 throw를 만들지 않는다(조회 실패를 AsyncValue.error로 넘기는 throw는 VM의 일 — §3.3 에러 2채널). *왜* — HaffHaff 실측: 파싱 실패는 그물 밖으로 탈출해 미정의 동작(크래시·무한 로딩), 타임아웃은 `isShow:false`로 무음, 좋아요류 에러는 Either 통째 폐기 — 실패의 절반이 사용자에게 도달하지 못했다.
>
> infra `service/`는 무상태 plain class다. 상태를 보유하고 플랫폼 이벤트에 반응하며 UseCase를 호출하는 **능동** service는 `application_layer/service/` 소속이다(§3.3). HaffHaff의 `permission_service.dart`(keepAlive Notifier·App 호출·상태 노출)는 infra에 있지만 성격상 application_layer 물건 — drift로 분류(§8).
>
> BC 도메인 데이터의 로컬 캐시는 여기(`_local_data_source.dart`) 소속이다 — `common/local_database/`는 엔진·전역 데이터(토큰·앱 설정) 전용(§6·§9-9). 다른 BC가 이 데이터를 원하면 이 BC의 UseCase를 호출한다(§9-3) — box 직접 접근 금지.
>
> BC 엔티티의 hive 어댑터 등록 함수는 `data_source/<bc>_hive_adapters.dart` 한 파일에 모아 노출한다 — `root_initializer`가 import할 수 있는 유일한 BC infra 파일(§3.6 예외). 어댑터 선언(`@GenerateAdapters` 류)도 이 파일 소속이다 — 도메인 엔티티에 storage 어노테이션을 붙이지 않는다.
>
> 세 종류 폴더(`data_source/`·`repository/`·`service/`) 전부 BC 생성 시 비어도 항상 만든다(§5).

### 3.5 presentation_layer — 바인딩 1단 + 표현 2단

3단은 크기가 아니라 **VM 보유 / 화면 전속 / 재사용**으로 가른다. VM을 watch하는 단은 view 하나뿐이고, section·widget은 VM·provider의 존재를 모르는 순수 표현 조각이다. (HaffHaff 실측: view 90%가 Consumer, block 93%·widget 98%가 dumb — 이 암묵 규율의 명문화이며, humble view를 구조로 보장한다.)

화면(삼총사)이 **어느 BC에 속하는지**는 import로 판별한다 — §3.6의 화면 귀속 규칙.

**판별 절차** — 위에서부터 순서대로, 처음 해당하는 것이 답:

| # | 질문 | 답 |
|---|---|---|
| 1 | 자기 상태·로직(VM)이 필요한가? | **view** — 전체 화면이든 임베드 조각이든 삼총사(`_view`·`_vm`·`_state`)로 생성. (HaffHaff 선례: `chat_request_btn_view`+`chat_request_btn_vm`) |
| 2 | 한 화면 전속인가? — 그 화면의 State나 맥락을 아는가 | **section** |
| 3 | BC의 도메인(엔티티·어휘)을 아는가? | 예 → **widget** / 아니오 → `design_system/` (BC 밖) |

| 종류 | 역할 | 허용·금지 | 파일 | 클래스 | 실예시 |
|---|---|---|---|---|---|
| `view/` | VM과 1:1 바인딩 루트 — `ConsumerWidget`, `ref.watch(<화면>VMProvider)`. section·widget·임베드 view를 조립 | **VM watch는 여기만 허용** — view는 자기 VM(+필요한 SharedState)만 watch, 그 외 provider watch 금지 | `<화면>_view.dart` | `<화면>View` | `channel_summary_view.dart` |
| `section/` | 한 화면 **전속** 구획 | `ref`·provider import 금지 — 화면 State·엔티티·콜백을 생성자 prop으로 받는다 | `<화면>…_section.dart` — **소속 화면 접두 필수** | `<화면>…Section` | ← HaffHaff `channel_summary_block.dart` |
| `widget/` | BC 내 **재사용** 부품 (화면 비전속) | `ref`·provider import 금지, **화면 State 받기 금지**(엔티티·원시값·콜백만), 파일명에 화면 이름 금지 | `<부품>_widget.dart` | `<부품>Widget` | `channel_intro_widget.dart` |
| `ui_extension/` | 도메인 enum·VO → UI 매핑 (색·아이콘·라벨). 도메인은 flutter 금지·design_system은 BC 어휘 금지라 여기가 유일한 자리 | extension만 — 위젯·상태 금지 | `<개념>_ui_extension.dart` | `extension <개념>UiExtension` | — (HaffHaff에는 자리 없어 산재) |

**승격·이동 규칙** (성장 시):

- section이 두 번째 화면에서 필요해지면 → 화면 State 의존을 벗겨 **widget으로 이동**.
- section·widget에 자기 상태·로직이 생기면 → **view+vm 쌍으로 승격**(삼총사 생성). section에 `ref`가 필요해지는 것은 승격 신호이지 예외가 아니다.
- BC 어휘 없이도 성립하는 순수 시각 부품이 되면 → `design_system/component/`로.

표준 종류는 view·section·widget 3종 + 보조 `ui_extension/`이며 전부 BC 생성 시 비어도 항상 만든다(§5). 3단 판별(위)은 위젯 3종에만 적용되고 ui_extension은 판별 밖의 보조 종류다. (`container/`는 1곳에서만 발견된 비표준 변형으로 표준에서 제외.)

### 3.6 합성 루트 — `lib/root/`

**합성 루트(composition root)는 앱 "전체"를 아는 유일한 자리다.** BC들은 서로를 4채널(§9-3)로만 좁게 알고, 전체 그림 — 어떤 BC가 있고, 탭이 몇 개이며, 앱이 어떻게 시동하는지 — 은 합성 루트만 안다. 위치는 **`lib/root/`**, 내부는 계층 없이 **역할 4폴더** — `router/`·`scaffold/`·`handler/`·`initializer/` — 가 아래 역할 표와 1:1 대응한다. **뎁스 규칙: 뎁스 한 칸은 정보 한 조각** — 종류 셋(view·vm·state)이 섞이는 `scaffold/`만 개념 폴더로서 종류 2차(§4 문법)를 갖고, 나머지는 단일 종류 평면 폴더다(infra_layer 평면 유지와 동형). 어떤 이벤트원이 두 번째 파일을 낳으면 그때 §4 성장 규칙대로 분할한다 — 미리 파지 않는다. root/ 이하 모든 파일은 `root_` 접두를 유지한다 — BC 코드에서 `import '…root_…'` 한 줄로 위반이 즉시 식별된다(§7.2).

`application/` 밖에 두는 이유: root는 application(BC 조립)뿐 아니라 common(DB 엔진 시동)·design_system(테마)까지 **세 컨테이너를 전부 아는 유일한 곳**이므로, 셋 중 하나의 안이 아니라 엔트리포인트(main.dart) 옆이 정위치다. 덕분에 `application/` 직속은 BC 폴더만 남아 균일해진다 (백스톱: `lib/application/*/` glob = BC 목록). Compass(`lib/` 루트의 `config/`·`routing/`)·Android `:app`(feature의 형제 모듈)·Django(앱 컨테이너 밖 config 패키지)와 동형.

역할은 4개이며 폴더와 1:1로 대응한다 — 공통점은 "전 BC를 import해야만 가능한 일"이라는 것:

| # | 역할 | 파일 | HaffHaff에서 흩어져 있던 실물 |
|---|---|---|---|
| ① | **내비 그래프 소유** — 전 BC `<bc>_router` 합산. "어떤 화면들이 있는가"는 전체에 대한 사실 | `router/root_router.dart` | `application/root_router.dart` (역할 동일 — 위치만 `lib/root/`로) |
| ② | **루트 스캐폴드** — 탭 프레임 + 각 탭에 BC export view 임베드(§9-3 채널 ④). 어느 BC의 소유도 아닌 프레임 | `scaffold/` — `view/root_view.dart`·`view_model/root_vm.dart`·`state/root_state.dart` (삼총사 §7.1-3) | `home/.../home_navigation_bar_widget.dart`+`_vm` — widget으로 위장된 채 chat·push VM watch(§9-10 위반의 원인이 곧 "자리 부재") |
| ③ | **전 BC 배선** — 앱에 도착하는 전역 이벤트를 BC로 분배 | `handler/` — `root_destination_handler.dart`(딥링크·푸시)·`root_lifecycle_handler.dart`(라이프사이클)·`root_error_handler.dart`(전역 에러) | `common/service/root_lifecycle_handler.dart`(이름은 이미 `root_*`, 자리만 common)·`destination_handler`(BC 7곳 navigator import)·에러 배선은 main의 `runZonedGuarded` 빈 핸들러 + initializer의 crashlytics로 산재 |
| ④ | **시동** — SDK 초기화 + BC가 노출한 hive 어댑터 등록 함수 조립(§9-9) + 부트스트랩(자동로그인 등은 BC UseCase 호출) | `initializer/root_initializer.dart` | `lib/system_initializer.dart`·`lib/member_data_initializer.dart` (떠돌이 파일 2개) |

**root가 아닌 것 (경계):**

- **root_vm은 "거의 빈 VM"이어야 한다** — 탭·뱃지·강제업데이트 같은 앱 전역 표시 상태만 갖는다. 탭 인덱스 자체는 go_router의 `StatefulNavigationShell`이 보유하므로 그보다도 가볍다. 특정 도메인 기능이 자라기 시작하면 그 화면은 root가 아니다(아래 귀속 규칙). — Prism 공식 RI의 ShellViewModel 규범("있되 거의 비어 있게")과 동형.
- **root_view는 콘텐츠를 그리지 않는다** — 탭 프레임과 임베드까지만. 콘텐츠 화면은 전부 BC 소속이다.
- **scaffold/에 오는 화면은 BC 어휘 없는 앱 전역 게이트뿐이다** (강제업데이트·점검 모드 등). 도메인 어휘가 보이는 화면은 BC로 — 아니면 home 정크드로어가 scaffold라는 이름으로 재발한다.
- **handler/ 입장 판별**: 이벤트가 둘 이상의 BC(또는 라우터 전체)로 분배되면 root handler(`root_<이벤트원>_handler`), 한 BC의 도메인 반응이면 그 BC의 application service다 — 같은 푸시라도 탭(목적지 분배)은 `root_destination_handler`, 수신(토큰 갱신·메시지 처리)은 push BC의 service. 푸시 탭의 **청취(`onMessageOpenedApp`·콜드스타트 `getInitialMessage`)와 payload→딥링크 URL 정규화는 root_destination_handler 소유**다 — "어떤 payload가 어느 화면인가"는 전 BC 목적지 지식이기 때문. push BC service에서 `go`·navigator 호출 금지(백스톱 검사 대상).
- **다수 BC 투영 화면은 root가 아니라 자기 이름의 일반 BC다** (예: 통합검색 → `search` BC). 도메인이 비어도 §5 골격 그대로 정상이다 (Android `:feature:home` 동형). HaffHaff의 `home_view`(피드 화면 — pin_post·story·advertisement·permission 4개 BC 투영)가 실물.

**화면 귀속 규칙** (import 기반 — 에이전트와 백스톱이 같은 답을 낸다): 화면 삼총사는 그 VM이 호출하는 UseCase의 소속 BC를 따른다.

1. UseCase가 **한 BC** → 그 BC (예: `chat_home_view`는 chat UseCase만 호출 → chat BC)
2. UseCase가 **둘 이상의 BC** → 그 화면(기능) 이름의 **일반 BC** (예: `home_view` → `home` BC)
3. UseCase **0개**(정적 화면) → import하는 도메인 어휘의 BC, 그것도 없으면 진입 라우트를 소유한 BC
4. 루트 스캐폴드·전 BC 배선·시동 → `root_*` 파일

**방향 규칙:**

- **`root/`를 import하는 곳은 `main.dart`뿐** (백스톱 검사 대상) — BC가 root를 알면 전체를 알게 되어 격리가 무너지고(home↔lounge형 순환 차단), common·design_system은 BC조차 모르는 곳이므로 root는 더더욱 모른다. "BC→root import 금지"의 강화판이며 경로 한 줄로 검사된다. root/ 내부의 상호 import는 자유다 — 이 규칙은 root/ 밖에서의 import 기준.
- **root → BC는 자유** — 전부 아는 것이 존재 이유이므로 교차 BC 4채널(§9-3) 제약을 받지 않는다. 단 **Model 방향 규율은 동일 적용**: root도 BC의 UseCase만 호출한다(Repo·box 직행 금지 — HaffHaff `root_router` redirect의 `TokenManager` 직접 접근은 drift, §8). 단 하나의 예외: `root_initializer` → `<bc>_hive_adapters.dart`(§3.4·§9-9)는 데이터 접근이 아니라 시동 배선이므로 허용 — root가 import할 수 있는 유일한 BC infra 파일.
- **푸시 탭은 딥링크 URL로 정규화**해 `root_destination_handler` 단일 경로로 디스패치한다 (iOS 관례와 동형 — 디스패치 경로가 하나면 백스톱·디버깅 모두 단순해진다). 디스패치 수단은 `rootRouter.go(url)` 하나다 — 타 BC navigator를 부르지 않는다.
- **main.dart는 엔트리포인트 최소형** — `runZonedGuarded` + `root_initializer` 시동 + `runApp(ProviderScope(...))`. 테마는 `app_theme`(§9-12), 라우터는 `root_router` 한 줄 참조 (HaffHaff main.dart의 테마 조립·초기 라우트 분기 비대는 drift). 백스톱: main.dart의 import는 root/·flutter·riverpod 화이트리스트만, 역방향으로 `application/`·`common/`·`design_system/`의 `main.dart` import 금지 (HaffHaff 실측: BC 4파일이 main의 logger·routeObserver를 import — 그런 BC 무관 전역 인스턴스는 common 소속, §6).

**root 내부 협력 규칙** (2026-06-12 파이널 리뷰 확정 — 정적 트리만으로 결정되지 않던 동적 배선):

- **handler 3종은 ViewModel의 Service 변종이다** — `@Riverpod(keepAlive: true)` Notifier로 작성하고, root_vm이 `build()`에서 활성화(ref.watch)한다. root에서 `@riverpod`가 허용되는 곳은 `scaffold/view_model/`과 `handler/` 둘뿐(§9-13). plain class로 두면 ref가 없어 HaffHaff `RootLifecycleHandler`의 WidgetRef 필드 보유 안티패턴이 재발한다.
- **root_initializer는 부수효과만 책임진다** (SDK 초기화·hive 엔진·어댑터 조립) — 결과 객체를 반환하지 않는다. 자동로그인 성패·강제업데이트 여부 같은 시동 질문은 root_vm이 `build()`에서 UseCase를 호출해 직접 획득한다 — ProviderScope 이전/이후 간극을 전달이 아니라 재조회로 해소한다(이미 열린 로컬 box 조회라 사실상 무비용).
- **rootRouter는 plain 전역 변수다** — `final GoRouter rootRouter = GoRouter(...)`. BC 라우터와 동일 문법(라우터는 전부 plain 전역, provider 아님). redirect의 상태 확인은 UseCase를 직접 생성·호출한다 — DI 없음(§9-13) 덕분에 ref가 필요 없다(HaffHaff redirect의 TokenManager 직행 교정).
- **root_vm·root_view·handler는 BC SharedState를 watch할 수 있다** — 4채널 면제의 명시적 일부. 뱃지처럼 BC에서 발원하는 반응형 전역 표시 상태의 표준 공급 채널이다(UseCase는 단발 호출이라 반응성이 없다).
- **게이트의 상태 주인**: 게이트 표시 여부는 root_vm이, 게이트 화면 내부 상태는 게이트 자신의 VM(`root_<게이트>_vm`)이 갖는다. 차단 메커니즘은 root_router 최상위 redirect + scaffold의 게이트 라우트 — 탭 프레임 밖 라우트까지 덮는다.

> **연구 근거** (2026-06-12, MVVM 4개 생태계 조사): MVVM 자체는 이 자리에 무답이며, 모든 생태계가 V-VM-M 바깥에 같은 자리를 둔다 — .NET/WPF Prism의 **Bootstrapper+Shell**, Flutter 공식 Compass의 `main_*`+`config/dependencies`+`routing/router`, Android **`:app` 모듈**(Now in Android의 `NiaApp`+`NiaAppState`), iOS MVVM-C의 **AppCoordinator**. 방향 불변식도 만장일치: "Composition Root는 객체 그래프 구조를 아는 유일한 곳"(Mark Seemann), "모듈은 서로도 셸도 직접 참조하지 않는다"(Prism), feature→`:app` 의존 불가(Android). 루트 스캐폴드의 VM은 원조 WPF만 두되 "거의 비어 있게"가 규범이고, Flutter·Android·iOS는 plain state holder를 쓴다 — riverpod에서는 plain holder도 결국 provider라 구분이 무의미하므로, dddart는 삼총사 문법(§7)을 유지하되 "거의 빈 VM" 규범을 채택한다.

**HaffHaff 검증 — home BC 분해**: 이 규칙을 적용하면 home BC는 소멸한다. 탭 셸·내비바 → `root_*`, `chat_home_*` → chat, `setting_home_*` → setting, 업로드 로딩 화면 → 각 도메인 BC, 피드 화면(`home_view`) → 자기 이름의 일반 BC. 남는 것 없음.

### 3.7 계층 import 매트릭스

BC 내부의 허용 import 방향 (행=from, 열=to — 백스톱 검사 대상). `common/`은 전 계층에서 import 가능하되 domain_layer만 예외(순수 Dart, §3.2). **`design_system/`은 presentation·BC 루트(scaffold·router)에서만** — domain은 순수 Dart라 불가이고, **application_layer(VM·SharedState·UseCase·State)도 금지**다(2026-06-12 적대 리뷰 개정: 시각 토큰 매핑이 VM으로 새면 ui_extension "유일한 자리" 규칙(§3.5)이 무너진다 — 백스톱 검사 대상, `BuildContext`·material import 금지와 동일 축). router 허용은 2026-06-12 §10-2 확정 — GoRoute pageBuilder의 전환 토큰(AppDuration 등)이 실전 수요라, 금지하면 매직 넘버(`Duration(milliseconds: 300)`)를 유도해 "시각 값 단일 출처"가 오히려 깨진다:

| from \ to | domain | application | infra | presentation | BC 루트 |
|---|---|---|---|---|---|
| domain | ✓ | ✗ | ✗ | ✗ | ✗ |
| application | ✓ | ✓ | ✓ — UseCase→Repo·infra service만(§3.3) | ✗ | ✓ — **VM만**→navigator(§3.1 — service는 금지: 푸시 등 플랫폼 이벤트의 내비는 root_destination_handler 소유 §3.6, 백스톱 검사 대상) |
| infra | ✓ | ✗ | ✓ | ✗ | ✗ |
| presentation | ✓ | ✓ — view→VM·State·SharedState만(§3.5) | ✗ | ✓ | ✓ — navigator |
| BC 루트 | ✗ | ✗ | ✗ | router→view만(GoRoute builder) — navigator는 금지(§3.1) | ✓ |

---

## 4. 성장 규칙 — 개념 1차·종류 2차

계층별로 개념 분할 시점이 다르다:

- **`domain_layer` — 항상 애그리거트(개념) 1차** (§3.2, dddjango와 동일). BC가 작아도 애그리거트 폴더부터 만든다.
- **`application_layer`·`presentation_layer` — 두 번째 개념이 등장하는 시점에 개념 1차로 분할**하고 그 안에 종류 폴더를 둔다. 분할은 새 코드부터 적용하며 기존 파일 이동을 요구하지 않는다(§8과 동일 원칙):

```
chat/application_layer/
├── chat/                                # 개념 1차
│   └── use_case/ · view_model/ · state/ · shared_state/ · service/   # 종류 2차 — 완비(§5)
└── chat_request/
    └── use_case/ · view_model/ · state/ · shared_state/ · service/

store/presentation_layer/
├── store/ · inventory_status/ · transaction/    # 각 개념 아래 view·section·widget·ui_extension
```

- **`infra_layer` — 평면 유지**. HaffHaff 16개 BC 모두에서 infra는 개념 분할 없이 종류 폴더만 가진다 (chat·lounge·store처럼 큰 BC도 동일).
- 분할 후 기존 직속 종류 폴더는 **동결**한다 — 신규 파일 금지, 새 코드는 개념 폴더로 (기존 파일 이동은 §8 원칙대로 요구하지 않는다).
- `root/`의 성장도 같은 문법이다: 한 이벤트원이 두 번째 파일을 낳으면 `handler/<이벤트원>/` 개념 폴더로 분할한다(§3.6).

같은 개념은 계층이 달라도 **같은 철자**를 쓴다 (application_layer의 `lounge_post_manage` ↔ presentation_layer의 `manage_lounge_post` 같은 어순 불일치 금지).

---

## 5. 골격 완비 규칙 — 비어 있어도 형태를 유지한다

BC를 만들면 **4계층 폴더와 모든 표준 종류 폴더를 항상 생성한다 — 비어 있어도 둔다. 선택 폴더는 없다** (사용자 확정 2026-06-11). 트리의 형태 자체가 규약이므로, 빈 폴더의 존재가 "이런 종류가 올 자리"라는 안내 역할을 한다. 폴더는 무조건, 코드는 필요할 때만.

| 계층 | 항상 생성하는 종류 폴더 (전부) |
|---|---|
| `domain_layer` | `<aggregate>/` + 애그리거트 루트 `<aggregate>.dart`(항상 생성) + `entity/`·`value_object/`·`enum/`·`domain_service/`·`specification/` — `exception.dart`는 첫 예외 때(골격 대상 아님) |
| `application_layer` | `use_case/`·`view_model/`·`state/`·`shared_state/`·`service/` |
| `infra_layer` | `data_source/`·`repository/`·`service/` |
| `presentation_layer` | `view/`·`section/`·`widget/`·`ui_extension/` |

- git은 빈 디렉터리를 추적하지 않으므로 빈 폴더에는 `.gitkeep`을 둔다.
- HaffHaff-App 현재는 생략 사례가 있으나(`home`: infra 없음, `evaluation`: application·presentation 없음) dddart 표준은 완비다 — 새로 만드는 BC부터 적용하며 기존 BC 수정을 요구하지 않는다.
- 개념 1차로 분할된 경우(§4) 표준 종류 폴더는 각 개념 폴더 안에 완비한다.
- `lib/root/`(§3.6)는 BC 골격 비적용 — 대신 **자체 골격**(역할 4폴더 `router/`·`scaffold/`·`handler/`·`initializer/` + scaffold 하위 `view/`·`view_model/`·`state/`)을 비어 있어도 항상 생성한다(.gitkeep). 다수 BC 투영 화면이 자기 이름의 일반 BC가 되는 경우(§3.6)는 도메인이 비어도 일반 골격을 그대로 적용한다.

---

## 6. 공통 영역 — `common/` 과 `design_system/`

**common은 모든 BC가 의존하는 곳이다 — 따라서 어떤 BC도 알면 안 된다.** 의존은 BC·root → common 한 방향뿐이며, **`common/`은 `application/`·`root/`를 import하지 않는다** (백스톱 검사 대상). common은 "어느 BC에도 속하지 않는 것"의 자리이지 편의 버킷이 아니다.

**입장 판별** — 위에서부터 순서대로, 처음 해당하는 것이 답:

| # | 질문 | 답 |
|---|---|---|
| 1 | BC의 도메인 어휘를 아는가? | common 금지 → 그 BC로 (enum은 `domain_layer/.../enum/`, 공유 상태는 `shared_state/`, 데이터 캐시는 `data_source/` §9-9) |
| 2 | 모든 BC를 알아야 하는 **조립 코드·조립 화면**인가? (라우터 조립·딥링크 디스패치·전역 라이프사이클·시동·루트 스캐폴드) | 합성 루트 `lib/root/`(§3.6). 단 루트 스캐폴드가 아닌 다수 BC 투영 화면은 자기 이름의 일반 BC |
| 3 | 시각 UI 부품인가? | `design_system/` |
| 4 | 그 외 — BC 무관 횡단 기반 | **common** |

> 헷갈리면 **import 방향**으로 가른다: `application/`을 import하면 조립 코드라 root(§3.6), BC들이 이것을 import하면 common — **root는 모두를 아는 곳, common은 모두가 아는 곳**이다. 또한 **common은 살아있는 상태를 갖지 않는다 — `common/`에서 `@riverpod` 금지** (백스톱 검사 대상): common은 호출당하는 도구이지 행위자가 아니다. 상태·신호가 필요한 코드는 정체를 따져 제자리로 — BC 어휘가 있으면 그 BC의 shared_state, 전 BC 배선이면 root(§3.6). `@riverpod` 금지는 이 규범의 백스톱 proxy다 — proxy가 잡지 못하는 가변 싱글턴(TokenManager 류)은 에이전트 판단 영역이며, 반응형 신호·구독을 노출하기 시작하면 common 실격. 내비게이터 전역 키·routeObserver·logger 같은 BC 무관 전역 인스턴스는 common 소속이다 — `main.dart`에 두지 않는다(§3.6 백스톱).

**common 종류 폴더 카탈로그:**

| 폴더 | 역할 | HaffHaff 실예 |
|---|---|---|
| `network/` | dio client·인터셉터·`safeApiCall`·`BadRequestResponse`·네트워크 예외. BC 일이 필요하면(401 처리 등) 직접 import 대신 콜백 주입 | `dio_client.dart` |
| `local_database/` | 로컬 DB **엔진**(hive 초기화)과 **전역 데이터**(토큰·앱 설정)만 (§9-9). BC 엔티티의 hive 어댑터 등록 함수는 그 BC infra가 노출하고 `root_initializer`(§3.6)가 조립 — common은 BC 엔티티를 모른다 | `token_manager.dart` |
| `service/` | BC 무관 플랫폼 서비스 — 애널리틱스·이미지 처리·디바이스. BC 데이터가 필요하면 직접 읽지 않는다 — common은 콜백·추상만 정의하고 구현 연결은 `root_initializer`(§3.6, 조립)가 담당 | `mixpanel_service.dart`·`image_crop_service.dart` |
| `enum/` | 전역 enum — 단 전 화면 라우트 enum은 실격(전체 지식 + §3.1 단일 출처와 중복, §8) | `global_key.dart`·`env_loader.dart` |
| `util/` | 순수 유틸 — 포맷터·계산기·확장 함수 | `time_calculator.dart` (`show_snackbar`는 시각 동작 — `design_system/util/` 소속, §8) |

**design_system/ — BC 어휘도 도메인 어휘도 모르는 시각 요소.** `design_system/`은 `application/`·`root/`를 import하지 않는다(백스톱 검사 대상). 컴포넌트는 **전역 navigator 키로 스스로를 표시하는 static `show()` 경로를 갖지 않는다**(2026-06-12 §10-5 ① 확정) — 표시는 View가 context로 호출한다. *왜* — 이 문이 열려 있으면 UseCase의 UI 직행(§8 drift — ErrorDialog 직접 호출 36/44)이 재발한다. §3.5 판별 3에서 "BC 어휘를 모르는 조각"이 내려오는 자리다. 구성은 업계 표준 구조(토큰 + 컴포넌트 + 규칙)를 따른다:

| 폴더 | 역할 | 규칙 |
|---|---|---|
| `foundation/` | 디자인 토큰 — 시각 값의 **단일 출처**. 표준 7파일: `app_color`·`app_typography`·`app_spacing`·`app_radius`·`app_shadow`·`app_duration`·`app_asset` (클래스 `App<토큰>`) | BC presentation·root scaffold·component에서 `Color(0x…)`·생 `TextStyle(…)` 리터럴 금지 — foundation 토큰만 (백스톱 검사 대상). 토큰 상수는 lowerCamelCase |
| `theme/` | foundation → `ThemeData` 조립 (`app_theme.dart`) — light/dark 확장점 | — |
| `component/` | 공용 위젯 — 부품군 1차 (`button/`·`dialog/`·`input/`·`feedback/` 등) | **부품군 폴더 = 파일 접미사 = 클래스 접미사** (`button/` 안은 `*_button.dart` → `*Button`). 축약(btn)·component 직속 파일·정크드로어 군(`widget/`·`etc/`) 금지. 클래스는 무접두 (`ErrorDialog` — 종류 접미사가 구별자) |
| `util/` | 시각 동작 헬퍼 — 스크롤 동작·미디어쿼리·TextStyle 빌더 | — |

design_system 골격(4폴더 + foundation 7파일 자리)은 §5 정신대로 항상 생성한다. 분류 안 되는 부품이 생기면 정크드로어가 아니라 새 부품군 폴더를 만든다.

---

## 7. 명명 규약 총괄표

### 7.1 공통 원칙

1. **파일명 = 주 클래스명의 snake_case.** 한 파일에 주 클래스 하나 (codegen part 파일 `.g.dart`·`.freezed.dart`와 도메인 `exception.dart`(예외 모음)는 예외).
2. **종류는 폴더가 결정하고, 접미사가 그것을 재확인한다.** 접미사 판별은 긴 것 우선 — `_shared_state.dart`는 shared_state 종류이지 state 종류가 아니다.
3. **화면 삼총사는 같은 접두를 쓴다**: `<화면>_view.dart` ↔ `<화면>_vm.dart` ↔ `<화면>_state.dart`가 1:1:1로 대응한다 (백스톱 검사 대상). 위젯 단위 VM도 동일 — `chat_request_btn_view` ↔ `chat_request_btn_vm`. 검사 방향은 **VM 기준** — VM이 존재하면 같은 접두의 view·state가 대응해야 하며, VM이 필요 없는 정적 view(약관·안내)는 VM·State 없이 허용된다.
4. **UseCase는 화면이 아니라 도메인 개념 단위로 짓는다** — 여러 VM이 하나의 UseCase를 공유한다 (HaffHaff 실증: `channel_app`·`member_app`·`firebase_token_app` 등 App 명명이 화면이 아니라 개념 단위).
5. **도메인 종류 명명은 dddjango 원형과 동일** — 명세는 풀네임 `_specification`(`_spec` 축약 금지), 도메인 서비스는 `_service`. specification의 평가·조합은 UseCase 이하(Model)에서만 한다 — VM이 도메인 판정을 직접 수행하지 않는다.
6. **`@riverpod` provider는 ViewModel 3변종(VM·SharedState·Service)과 root의 2변종(root_vm·root handler — §3.6)에만 쓴다.** UseCase·Repo·DataSource는 plain class — 사용처에서 직접 생성한다(§9-13).

### 7.2 총괄표

| 위치 | 이름 기준 (접두) | 파일명 | 클래스명 |
|---|---|---|---|
| BC 루트 라우터 | BC명 | `<bc>_router.dart` | (GoRoute 변수 `<bc>Router`) |
| BC 루트 내비게이터 | BC명 | `<bc>_navigator.dart` | `<bc>Navigator` |
| root `router/` (§3.6) | 고정 | `root_router.dart` | (GoRouter **전역 변수** `rootRouter` — plain, provider 아님 §3.6) |
| root `scaffold/` — view·view_model·state (§3.6) | 고정 접두 `root` — 삼총사 §7.1-3 | `root_view.dart`·`root_vm.dart`·`root_state.dart` (게이트 화면은 `root_<게이트>_view` 등) | `RootView`·`RootVM`·`RootState` |
| root `handler/` (§3.6) | 이벤트원 | `root_<이벤트원>_handler.dart` | `Root<이벤트원>Handler` |
| root `initializer/` (§3.6) | 고정 | `root_initializer.dart` | `RootInitializer` |
| 애그리거트 루트 | 애그리거트명 | `<aggregate>.dart` (폴더 직속) | 애그리거트명 |
| domain `entity/` | 개념명 (단수 명사) | `<개념>.dart` | 개념명 |
| domain `value_object/` | 개념명 | `<개념>.dart` | 개념명 |
| domain `enum/` | 개념명 | `<개념>.dart` | 개념명 |
| domain `domain_service/` | 행위·정책 | `<행위>_service.dart` | `<행위>Service` |
| domain `specification/` | 규칙 풀네임 | `<규칙>_specification.dart` | `<규칙>Specification` |
| 도메인 예외 | 고정 | `exception.dart` (폴더 직속) | `*Exception` 모음 |
| app `use_case/` | **도메인 개념** (화면 금지) | `<개념>_use_case.dart` | `<개념>UseCase` |
| app `view_model/` | **화면** — view와 동일 접두 | `<화면>_vm.dart` | `<화면>VM` |
| app `state/` | 노출 주체와 동일 접두 (화면·관심사·기능) | `<화면·관심사·기능>_state.dart` | `…State` |
| app `shared_state/` | 공유 관심사 | `<관심사>_shared_state.dart` | `<관심사>SharedState` |
| app `service/` | 플랫폼 기능 | `<기능>_service.dart` | `<기능>Service` |
| infra `data_source/` (원격) | 개념 — repo와 동일 접두 | `<개념>_data_source.dart` | `<개념>DataSource` |
| infra `data_source/` (로컬) | 개념 | `<개념>_local_data_source.dart` | `<개념>LocalDataSource` |
| infra `repository/` | 개념 | `<개념>_repo.dart` | `<개념>Repo` |
| infra `service/` | SDK·기능 | `<기능>_service.dart` | `<기능>Service` |
| pres `view/` | 화면 (VM 보유 단위) | `<화면>_view.dart` | `<화면>View` |
| pres `section/` | **소속 화면 접두 필수** | `<화면>…_section.dart` | `<화면>…Section` |
| pres `widget/` | 부품 — 화면 이름 금지 | `<부품>_widget.dart` | `<부품>Widget` |
| pres `ui_extension/` | 도메인 개념 | `<개념>_ui_extension.dart` | `extension <개념>UiExtension` |
| ds `foundation/` | 토큰 종류 | `app_<토큰>.dart` | `App<토큰>` |
| ds `component/<군>/` | 수식·변형 | `<수식>_<군>.dart` | `<수식><군>` (무접두) |
| ds `theme/` | 고정 | `app_theme.dart` | `AppTheme` |
| common 5종·ds `util/` | 기능·도구 | 파일명 = 주 선언명 snake_case (`service/`는 `<기능>_service.dart`) | 주 선언명 (`<기능>Service` 등) |

---

## 8. 표기 표준화 — 전수 조사에서 발견된 drift와 교정

HaffHaff-App 안에서 발견된 변형들. dddart는 새로 만드는 코드에서 아래 **표준**만 쓰며, 백스톱이 변형을 잡는다 (기존 코드 수정을 요구하지 않는다):

| 발견된 변형 (위치) | 표준 |
|---|---|
| `viewmodel/` (curation) | `view_model/` |
| `repo/` (register, 폴더명) | `repository/` |
| `presentation_later/` (permission — 오타) | `presentation_layer/` |
| `my_louge_post/` (lounge — 오타) | 개념 철자 통일 |
| `lounge_post_manage` ↔ `manage_lounge_post` (계층 간 어순 불일치) | 같은 개념 같은 이름 |
| `container/` (lounge_manage 1곳) | view/section/widget 3종으로 정리 |
| 능동 service가 infra에 (permission — keepAlive Notifier·App 호출·상태 노출) | 이벤트 구동·UseCase 호출 service는 `application_layer/service/` |
| `<화면>_view_state.dart` 변형 (carrousel·chat_room_list·lounge_post_reply 등 4곳) | `<화면>_state.dart` — `view`를 끼우지 않는다 |
| state 접미사 누락 (`chat_request_form.dart`·`in_app_transaction.dart`) | state 폴더 파일은 `_state.dart` 필수 |
| BC 도메인 데이터 캐시가 common에 (`hive/member/`·`hive/notice/` — common→BC 역의존, 직접 접근 10곳+) | BC `infra_layer/data_source/`의 `_local_data_source.dart` |
| 로컬 자리 부재로 생긴 `*_box_repo` 변형 (member_box_repo·rank_box_repo) | Repo 하나가 원격+로컬 DataSource를 조합 |
| block·widget의 VM watch (block 3곳·widget 4곳) | dumb 유지 — 상태가 필요하면 view+vm 쌍으로 승격(§3.5) |
| navigator가 presentation_layer에 (전 BC) | BC 루트 `<bc>_navigator.dart` — 라우트 이름만 참조, View import 금지(§3.1) |
| BC 어휘 enum이 common에 (`channel_filter_choice`·`chat_room`) | 그 BC의 `domain_layer/.../enum/` |
| 전 화면 라우트 enum이 common에 (`screen_name.dart` — 전 BC 화면 목록 = 전체 지식) | `<bc>_router.dart`로 해체 — 라우트 path·name의 단일 출처(§3.1) |
| BC 공유 상태가 common/provider에 (`post_upload_notifier` — lounge 어휘) | 해당 BC의 `application_layer/shared_state/` |
| 교차 BC 화면 갱신 버스 (`refresh_notifier` — 8개 BC의 VM 12개를 import해 `ref.refresh` 조작, 금지 채널(타 BC VM 접근)의 common 경유 우회) | 종류 폐지(§9-11) — 데이터 변화는 그 BC SharedState로, 라이프사이클발 갱신은 `root_lifecycle_handler`→BC service, 이벤트형 잔여 요구는 §10-6 |
| 위장 이벤트 신호 (`scroll_to_top_notifier` — `doHomeScrollToTop` 등 BC 어휘 + needTo/complete 플래그) | 종류 폐지(§9-11) — 탭 재탭 스크롤톱은 root_view가 PrimaryScrollController 등으로 직접 처리(§10-5), BC는 신호를 듣지 않는다 |
| 조립 코드가 common/service에 (`destination_handler` — BC 7곳 navigator import·`root_lifecycle_handler`) | 합성 루트 — `root_destination_handler.dart`·`root_lifecycle_handler.dart` (§3.6) |
| 시동 코드가 lib 루트 떠돌이 파일 (`system_initializer`·`member_data_initializer` — Repo 직접 호출) | `root_initializer.dart` (§3.6) — 부트스트랩도 BC UseCase 호출로 |
| 조립 코드의 box 직접 접근 (`root_router` redirect가 `TokenManager` 직접 호출) | root도 Model 규율 적용 — UseCase 경유 (§3.6) |
| 조립 파일이 BC 컨테이너 직속에 (`application/root_router.dart`) | `lib/root/` — application/ 직속은 BC 폴더만 (§3.6) |
| 전역 에러 배선 산재 (main의 `runZonedGuarded((_,__){})` — 에러 무음 폐기, crashlytics 설정은 system_initializer에) | `root/handler/root_error_handler.dart` (§3.6) |
| 전 BC 목적지 enum (`DestinationType` — push BC 도메인에 전 BC 목적지 어휘) | 푸시 탭의 딥링크 URL 정규화(§3.6)로 소멸 — 목적지 어휘는 각 BC 라우트 path |
| 파일명 오타 (`dio_client_for_certificcation`·`go_route_servcie`) | 철자 교정 (`certification`·`service`) |
| 타이포 토큰이 `style_enum.dart`에 (enum 아님 — TextStyle 전역 변수들) | `foundation/app_typography.dart` |
| component 정크드로어·직속 파일 (`widget/` 12개·`etc/`·`webview.dart`) | 부품군 폴더로 해체 (input·feedback 등) |
| `btn/` 축약·`_btn`/`_button` 혼재·`ds_` 접두 2건 | `button/`·`_button.dart`·무접두 통일 |
| design_system 오타·토큰 표기 혼재 (`heart_animnation`·`bahavior`·`WHITE`/`GRAY_50`/`Semantic_Green000`) | 철자 교정 · 토큰 상수 lowerCamelCase |
| state로 위장한 이벤트 (`comment_added_bridge` — `DateTime.now()` 핵·센티널 초기값·autoDispose 유실 위험) | 과거형 사건명 shared_state 금지 — 이벤트형 요구는 §10-6 회부 |
| 셸이 타 BC 화면을 흡수 (`home/domain_layer/state/`에 lounge·chat 화면 state, `setting_home_*`이 home에) | 화면 귀속 규칙(§3.6) — UseCase 소속 BC로. 탭 셸은 `root_*`, 다수 BC 투영 화면은 자기 이름 BC |
| 교차 BC VM watch·화면 삼총사 분할 (`home_view`→advertisement VM read, `chat_home` 삼총사가 home·chat에 쪼개짐) | 4채널(§9-3)만 — VM watch 금지, 삼총사는 한 BC에 |
| `app/`·`_app.dart`·`*App` (전 BC) | `use_case/`·`_use_case.dart`·`*UseCase` (§9-8) |
| `bridge/`·`_bridge.dart`·`*Bridge` | `shared_state/`·`_shared_state.dart`·`*SharedState` (§9-8) |
| `block/`·`_block.dart`·`*Block` | `section/`·`_section.dart`·`*Section` (§9-8) |
| UseCase(App)의 UI 직접 호출 (`*_app.dart` 44개 중 36개가 `ErrorDialog` 호출) | UseCase는 Either만 반환 — 에러 표시는 View `ref.listen` (§9-7) |
| VM의 BuildContext 보유 (`*_vm.dart` 77개 중 4개) | navigator 헬퍼 경유 — BuildContext 보유 금지 (§9-7) |
| 화면 state가 `domain_layer/<agg>/state/`에 (전 BC) | `application_layer/state/` (§9-7) |
| domain_layer 평면 — 애그리거트 폴더 없음 (전 BC) | 애그리거트(개념) 1차 (§3.2) |
| main.dart 비대 (테마 조립·초기 라우트 분기·전역 인스턴스 보유) | 엔트리포인트 최소형(§3.6) — 테마는 app_theme, 초기 분기는 root_router redirect, 전역 인스턴스는 common(§6) |
| BC 어휘 service가 common에 (`status_handler` — member VO·MemberHive·ConfirmDialog) | member BC `application_layer/service/` |
| common 비표준 종류 폴더 (`service/value_object/`·`provider/state/`) | 5종 외 금지(§6) — 내용물은 입장 판별대로 재배치 |
| `appbar/` (component 부품군) | `app_bar/` |

---

## 9. 트리에 내장된 주요 결정

이 트리 자체가 다음 결정을 담고 있다:

0. **도메인 계층은 dddjango 원형 − repository − port − event** (사용자 확정 2026-06-11) — 애그리거트(개념) 1차·종류 2차, 애그리거트 루트 파일(`<aggregate>.dart`) 폴더 직속, 종속 엔티티는 `entity/`, `domain_service/`·`specification/` 포함 모든 종류 폴더(5종)는 비어도 항상 생성, `exception.dart` 보유. 제외 셋 — `repository/`(추상)·`port/`는 간소화 결정, `event/`는 실측·통설 근거(§9-15). HaffHaff 고유 종류 중 `enum/`은 유지, `state/`는 철저한 MVVM 결정(§9-7)에 따라 application_layer로 이동. 평면 domain은 표준에서 제외되며 새 코드부터 적용.
1. **repository 인터페이스 없음** — `repository/`에 구체 클래스 하나. 추상/구현 분리 폴더 없음. (사용자 확정)
2. **DTO 계층 없음** — `dto/` 폴더가 없다. retrofit DataSource가 도메인 엔티티를 직접 반환.
3. **ACL 없음, 교차 BC 통신은 4채널** — `acl/` 폴더가 없다. 교차 BC 통신은 다음 4채널만 허용한다 (백스톱 검사 대상): ① **도메인 타입 import** (엔티티·VO·enum — 예: channel이 member의 `Candidate` 사용) ② **타 BC UseCase 호출** (행위·데이터 접근의 단일 관문) ③ **타 BC navigator 호출** (라우트 이름만) ④ **타 BC view 임베드** — `view/`는 전부 임베드 가능, 별도 export 표식 없음 (view는 자기 VM을 스스로 watch하므로 임베드는 배치만 — 탭 셸의 표준 수단). **금지**: 타 BC의 Repo·DataSource·box 직접 호출, 타 BC VM watch, 타 BC SharedState watch(root만 면제 — §3.6), 타 BC section·widget·ui_extension import(부품 재사용은 design_system 승격 경유) — 필요하면 그 화면 view를 임베드하거나 UseCase를 호출한다. 실측 근거: HaffHaff 교차 BC import 321건이 전부 이 4채널과 그 위반으로 분류됨(이벤트형 통지 0건).
4. **화면 상태는 `application_layer/state/`** — VM이 노출하는 화면 상태 모델은 ViewModel 계층의 소유물 (HaffHaff는 domain_layer/state/ — 의식적 분기, §9-7 참조).
5. **테스트 디렉터리 규약 없음** — 테스트 없이 가는 결정에 따라 `test/` 구조는 규약에 포함하지 않는다.
6. **골격 완비, 선택 폴더 없음** — 4계층 폴더와 모든 표준 종류 폴더는 비어 있어도 항상 생성한다 (§5, 사용자 확정 2026-06-11). 빈 폴더는 `.gitkeep`으로 유지.
7. **철저한 MVVM** (사용자 확정 2026-06-11) — HaffHaff 방언에서 세 곳을 의식적으로 교정한다:
   - **UseCase는 `Either`만 반환(Right=성공 — §3.4), UI 호출 금지** — HaffHaff는 App(=dddart의 UseCase) 파일 44개 중 36개가 `ErrorDialog`를 직접 호출하지만(Model→View 역류), dddart의 UseCase는 결과만 반환하고 에러 표시는 VM이 맡는다. 전달 채널은 **View가 `ref.listen`으로 State의 에러를 감지해 표시**하는 방향이며(BuildContext 금지와 양립), 공용 헬퍼·base VM의 상세는 §10-5에서 확정.
   - **화면 state는 `application_layer/state/`** — 사용처 추적 결과 state 파일은 VM·View만 import(도메인 코드 사용 0건) = ViewModel 계층 소유물.
   - **VM은 BuildContext 직접 보유 금지** — 화면 전환은 정적 navigator 헬퍼 경유(NavigationService와 동형). navigator는 **BC 루트 소속·라우트 이름만 참조·View import 금지**(§3.1) — VM이 호출해도 계층 역류·import 순환이 없다. HaffHaff `_vm.dart` 77개 중 73개가 이미 준수, 4개가 BuildContext 보유 drift.
8. **일반 MVVM 용어 정렬** (사용자 확정 2026-06-11) — HaffHaff 방언 중 일반 명칭이 아닌 폴더 3개를 통용 용어로 교체한다 (Flutter 공식 아키텍처 가이드 대조 검증): `app/`→`use_case/`(`*App`→`*UseCase`, 공식 가이드의 domain use-cases 용어), `bridge/`→`shared_state/`(`*Bridge`→`*SharedState`), `block/`→`section/`(`*Block`→`*Section`, BLoC와의 발음 충돌 회피). 나머지 종류 폴더(view_model·view·widget·repository·service·data_source·state·entity)는 공식·통용 명칭과 일치 확인 완료. 폴더 단수형 표기는 내부 일관 컨벤션으로 유지(공식은 복수형). 백스톱은 새 코드에서 구명칭(`app/`·`bridge/`·`block/`, `_app.dart`·`_bridge.dart`·`_block.dart`)을 잡는다.
9. **로컬 데이터 2층 구분** (사용자 확정 2026-06-11) — `common/local_database/`는 **엔진과 전역 데이터만**: hive 초기화·어댑터 등록, 토큰, 앱 설정. BC 도메인 데이터의 로컬 캐시는 그 BC의 `infra_layer/data_source/`에 `<개념>_local_data_source.dart`로 두고, Repo가 원격+로컬을 조합해 단일 진실 원천 역할을 한다. 다른 BC·전역 서비스가 그 데이터를 원하면 해당 BC의 Repo/UseCase를 호출한다(box 직접 접근 금지). 근거: HaffHaff에서 member·notice 캐시가 common에 가면서 역의존(common이 BC 엔티티 import)과 문 없는 직접 접근(enum·타 BC 도메인 엔티티·전역 서비스가 MemberBox 직접 조작, 10곳+)이 실측됨. hive 어댑터 등록: 엔진 초기화는 common, BC 엔티티의 어댑터 등록 함수는 각 BC infra가 노출하고 `root_initializer`(§3.6)가 조립한다.
10. **presentation 3단 엄격 판별** (사용자 확정 2026-06-11) — 3단은 크기가 아니라 **VM 보유(view) / 화면 전속(section) / 재사용(widget)**으로 가른다. VM watch는 view 단 하나(바인딩 1단 + 표현 2단), section·widget은 `ref`·provider 금지(prop·콜백만), section은 소속 화면 접두 필수, widget은 화면 State·화면 이름 금지. 승격 규칙: 상태가 생기면 view+vm 쌍으로, 두 화면에서 쓰이면 widget으로, BC 어휘를 벗으면 design_system으로. 근거: HaffHaff 실측 — view 90% Consumer, block 93%·widget 98% dumb, `chat_request_btn`의 view 승격 선례.
11. **common 입장 규칙** (사용자 확정 2026-06-11) — common은 모든 BC가 의존하므로 어떤 BC도 모른다: **`common/`은 `application/`·`root/`를 import하지 않는다** (백스톱 검사 대상). 입장 판별(§6): ① BC 어휘를 알면 그 BC로(enum→domain enum, 공유 상태→shared_state, 캐시→data_source) ② 전 BC를 아는 조립 코드(딥링크 디스패치·전역 라이프사이클·시동)는 합성 루트 `lib/root/`(§3.6) ③ 시각 부품은 design_system ④ 그 외 횡단 기반만 common. 종류 **5종**: network·local_database·service·enum·util — `provider/`는 폐지(2026-06-12: 실물 3개 전수 실격 — `post_upload`는 lounge 어휘, `scroll_to_top`은 BC 어휘+위장 이벤트, `refresh_notifier`는 8개 BC의 VM 12개를 import하는 교차 갱신 버스). **common은 살아있는 상태를 갖지 않는다 — common에서 `@riverpod` 금지**(백스톱 검사 대상). 근거: HaffHaff 실측 — common 55파일 중 11파일이 application을 역import (측정식: import문의 절대·상대 `application/` 경로. BC enum 1·BC 공유 상태 2·갱신 버스 1·BC 캐시 hive/member 4·조립 코드 2·BC 어휘 service 1(`status_handler`)).
12. **design_system 표준 구조** (사용자 확정 2026-06-11) — 업계 표준(토큰+컴포넌트+규칙) 정렬: `foundation/`(토큰 7파일 — color·typography·spacing·radius·shadow·duration·asset, 클래스 `App<토큰>`) + `theme/`(`app_theme.dart` — ThemeData 조립, light/dark 확장점) + `component/`(부품군 1차 — 군 폴더=파일 접미사=클래스 접미사, 직속 파일·정크드로어 금지) + `util/`(시각 동작 헬퍼). 규율: BC presentation·component에서 `Color(0x…)`·생 `TextStyle` 리터럴 금지 — foundation이 시각 값의 단일 출처(백스톱 검사 대상). 컴포넌트 클래스는 무접두 — 종류 접미사가 구별자(HaffHaff 다수 관례, `ds_` 접두 2건은 drift). HaffHaff 대비 신설: foundation 분리(루트 산재 해소)·theme(다크모드 확장점).
13. **DI 없음 — 직접 생성** (사용자 확정 2026-06-11) — UseCase·Repo·DataSource는 plain class이며 사용처가 직접 생성한다(생성자 주입·DI 컨테이너 없음 — HaffHaff 방언, 간소화 DDD·테스트 없음 결정과 정합). `@riverpod` provider는 ViewModel 3변종(VM·SharedState·Service)에만 쓴다 — common 포함 그 외 모든 위치에서 `@riverpod` 금지(§9-11, 백스톱 검사 대상). 합성 루트에서는 `root_vm`(VM 변종)과 `handler/` 3종(Service 변종)만 허용 범위다(§3.6 root 내부 협력 규칙). `rootRouter`는 provider가 아니라 plain 전역 변수(§3.6).
14. **전면 리뷰 반영** (2026-06-11) — navigator는 BC 루트(§3.1, 역류·순환 해소), state/는 노출 주체별(화면·관심사·기능), 교차 BC 접근은 타 BC UseCase 경유 단일화(§9-3), 애그리거트 기본값=BC 동명(§3.2), 개념 분할 트리거=두 번째 개념 등장 시(§4), `ui_extension/` 신설(도메인→UI 매핑, §3.5), hive 어댑터 조립 규칙(§9-9), application_layer 수평 협력 허용(§3.3).
15. **합성 루트 · event 제거 · 순환 래칫** (사용자 확정 2026-06-11, 합성 루트는 2026-06-12 개정 확정 — 적대적 리뷰·업계 리서치 경유) —
    - **합성 루트 `root_*` 파일**(§3.6): 셸은 모듈이 아니라 composition root다 — "전체를 아는 코드"(내비 그래프·루트 스캐폴드·전 BC 배선·시동)의 유일한 자리이며, **`lib/root/`**에 역할 4폴더(`router/`·`scaffold/`·`handler/`·`initializer/` — scaffold만 종류 2차, 뎁스 1칸=정보 1조각 원칙, 2026-06-12 구조 확정)로 둔다 (2026-06-12 위치 확정 — root는 application·common·design_system 세 컨테이너를 전부 아는 유일한 곳이므로 application/ 안이 아니라 main.dart 옆이 정위치, application/ 직속은 BC 폴더만 남아 균일; Compass `config/`·`routing/`·Android `:app`·Django config 패키지 동형). `root_vm`은 "거의 빈 VM" 규범(Prism ShellViewModel 동형). 루트 스캐폴드 외의 다수 BC 투영 화면은 자기 이름의 **일반 BC**. **`root/`를 import하는 곳은 main.dart뿐**(방향 불변식 — BC→root 금지의 강화판), root→BC는 4채널 면제·Model 규율(UseCase만)은 적용. 근거: HaffHaff `home`이 규칙 없는 조립 BC의 실패 실측(타 BC 화면 10여 개 흡수) + 합성 루트 실물이 7곳에 산재한 실측(main·system_initializer·member_data_initializer·common/service의 root_lifecycle_handler·root_router·home 탭 셸), "주 의도" 같은 비계산 판별은 규약 실격, MVVM 4개 생태계 만장일치 동형(§3.6 연구 근거). 원안 "shell 폴더"(계층 2개 보유)는 같은 계층 폴더가 셸·BC 양쪽에 생기는 어색함으로 폐지. 동적 배선 — handler=Service 변종, initializer=부수효과만(시동 질문은 root_vm이 UseCase 재조회), rootRouter=plain 전역 변수, 푸시 탭 청취·정규화=root_destination_handler 소유, BC SharedState watch 허용, hive 어댑터 import 예외 — 는 2026-06-12 파이널 리뷰로 확정(§3.6 "root 내부 협력 규칙").
    - **`event/` 제거** (도메인 5종): HaffHaff 실물 0건, 클라엔 트랜잭션·프로세스 경계 없음, 통설 "클라는 도메인 이벤트를 생성하지 않고 구독"(구독은 `service/` 담당), 모듈 간 이벤트 버스를 권장하는 공식 가이드 0건. state로 위장한 이벤트(`comment_added` 류)는 drift(§8) — 이벤트형 요구 발생 시 §10-6에서 재논의.
    - **순환 래칫**: BC import 그래프의 **신규 순환 금지** — 기존 프로젝트는 발견 시점 베이스라인을 동결하고 신규만 실패시킨다 (HaffHaff 실측 12쌍, 테스트 없는 코드베이스에서 순환의 가장 싼 해소 시점은 규약 제정 시점이므로 불변식은 지금 도입).

## 10. 후속 작업 — 문서 확정 후 순서대로

1. 파이프라인 — Coordinator 커맨드·에이전트 7종(architect, 리뷰어 ddd·ui·state·data, coder, discipline-reviewer)·게이트(G0/G1/G2) 구성
2. 백스톱 스크립트 초기 세트 — 이 트리의 어떤 불변식을 결정적으로 검사할지 (예: 계층 폴더 표기, domain_layer의 flutter import, 종류-접미사 일치)
3. 스킬 9종 코퍼스 — dddjango 이식 3종(architecture-ddd·discipline-cleancode·discipline-houserules)과 신규 6종의 작성 순서
4. 저장소 골격 생성 — `dddart/`·`codex-dddart/`·`workspace/` + 매니페스트 + sync 도구 이식
5. 코드 규율 디테일 (2026-06-11 이연) — ① Model 출구 에러 계약 — **확정(2026-06-12, 결정 5건 전부 권장 채택·본문 승격: §3.3 State 계약·에러 2채널·컨트롤러 / §3.4 실패의 단일 출구 / §6 전역 키 show 금지)**: safeApiCall 전 예외 정규화(throw 탈출 금지) · 조회 실패=AsyncValue.error·액션 실패=State `error` 필드+`consumeError()` 명시 소비 · 전 VM freezed State 직노출 금지(백스톱 NM4 최종 확정) · 컨트롤러 View 소유(IM12 최종 확정) · base VM·공용 헬퍼 없음 ② ~~Either 방향~~ — **Right=성공으로 확정**(2026-06-12, §3.4 — 기존 프로젝트 관례 우선 단서만 유지) ③ 애그리거트 "일관성 경계"의 코드 규율(루트 경유 변경 원칙 등 — freezed 불변+직파싱 하에서의 최소 규칙, VM 판정 강등 규칙(§3.3)의 상세 포함) ④ root 탭 재탭 스크롤톱 상세 — root_view의 PrimaryScrollController 처리(§8). discipline-cleancode·implementation 스킬 작성 시 결정(귀속 확정 2026-06-12 — 코드 내용 규율은 cleancode, 파일트리는 houserules).
6. 도메인 이벤트 — `event/`는 제거됨(§9-15, 2026-06-11). 교차 BC 비동기 통지 요구가 실제로 발생하면 이 항목에서 재논의한다 — 그 전까지 shared_state로 위장하지 않는다(§8).
