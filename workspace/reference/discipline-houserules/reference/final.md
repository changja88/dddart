# dddart 표준 파일트리

## P1 Source Sufficiency

| field | value |
|---|---|
| purpose | dddart 플러그인이 생성하는 Flutter 코드의 파일트리·디렉터리 구조·명명·import 방향 규약의 단일 출처. |
| use when | 코드를 어느 디렉터리에 어떤 이름으로 만들지 결정·검수할 때, 신규 BC·애그리거트·화면의 골격을 깔 때, import 방향 적법성을 판단할 때. |
| exclude/handoff | 계층 설계 이론·판정 소유는 architecture-ddd, VM·State 동작 계약은 architecture-state, Either·계약 스냅샷은 architecture-data, 화면 분해 절차는 architecture-ui, 문법 표기는 implementation 3종으로 위임. |
| core criteria | HaffHaff-App 실측에서 도출·정제된 표준 트리; 골격 완비(선택 폴더 없음); 개념 1차·종류 2차; 명명 총괄표; 계층 import 매트릭스 + 교차 BC 4채널; 새 코드부터 적용(기존 코드 수정 불요구). |
| source priority | 1 제1 규약(확정 설계 문서, 2026-06-12) 2 HaffHaff-App 전수 조사(2026-06-11, 16 BC) 3 dddjango discipline-houserules(양식 전례) 4 백스톱 설계(연동 절). |
| P1 classification | sufficient |

> **출처:** 제1 규약(dddart 표준 파일트리 확정 설계, 2026-06-11) · HaffHaff-App `lib/application/` 16 BC 전수 조사 · dddjango discipline-houserules(양식) · 백스톱 설계(2026-06-12) §2·§3.
> 본문 속 `(규약 §N)`·`(백스톱 설계 §N)`·`(본설계 §N)`은 **출처 표기**(설계 문서의 절 번호)이며 로드 대상이 아니다 — 규칙 자체는 본문에 자족적으로 서술된다. 로드 가능한 위임은 두 가지뿐: 타 스킬은 "스킬명 + 주제", 동봉 파일은 `undecidable.md`.

---

## 목차

- §1. 표준 트리 (전문)
- §2. 성장 규칙 — 개념 1차·종류 2차
- §3. 골격 완비 규칙 — 비어 있어도 형태를 유지한다
- §4. 명명 규약 총괄표
- §5. import 방향 — 계층 매트릭스·교차 BC 4채널·root 방향 규칙
- §6. common·design_system 입장 판별
- §7. 표기 표준화 — drift와 교정
- §8. 백스톱 연동 — 러너·게이트

---

## §1. 표준 트리 (전문)

4원칙 (규약 §1): ① 기준은 이론이 아니라 운영 중인 실제 앱(HaffHaff-App)이다 — 단 사용자가 명시적으로 교정한 결정(dddjango 정렬·철저한 MVVM·통용 용어)이 우선한다 ② **간소화 DDD** — repository 인터페이스 없음·DTO 없음·ACL 없음, 뼈대(컨테이너·4계층·개념 1차·종류 2차)는 유지 ③ **철저한 MVVM** — 지식은 View → VM → UseCase(Model 관문) → Repo 한 방향 ④ **파일트리가 곧 규약이다** — 어떤 파일을 어디에 어떤 이름으로 만드는지가 핵심 강제다.

```
lib/
├── main.dart                                # 엔트리포인트 최소형 — root_initializer 호출 + runApp 조립만
├── firebase_options.dart                    # (Firebase 채택 시) flutterfire 생성물 — 도구 고정 위치·자동 생성, 백스톱 검사 제외
├── root/                                    # 합성 루트 — 전체를 아는 유일한 곳, 계층 없음 (역할 4폴더)
│   ├── router/                              #   ① 내비 그래프
│   │   └── root_router.dart                 #     전 BC <bc>_router 합산 (GoRouter plain 전역 변수)
│   ├── scaffold/                            #   ② 루트 스캐폴드 (개념 폴더) — 탭 셸 + BC 어휘 없는 전역 게이트만
│   │   ├── view/                            #     root_view.dart — 탭 프레임, BC export view 임베드
│   │   ├── view_model/                      #     root_vm.dart — "거의 빈 VM" 규범
│   │   └── state/                           #     root_state.dart
│   ├── handler/                             #   ③ 전 BC 배선 — 이벤트원당 1파일 (*_handler)
│   │   ├── root_destination_handler.dart    #     딥링크·푸시(딥링크로 정규화) → BC 디스패치
│   │   ├── root_lifecycle_handler.dart      #     전역 라이프사이클 → BC service
│   │   └── root_error_handler.dart          #     전역 에러 → 크래시리포트·표시
│   └── initializer/                         #   ④ 시동
│       └── root_initializer.dart            #     SDK 초기화 + BC hive 어댑터 조립
├── application/                             # BC 컨테이너 — 직속은 BC 폴더(또는 area 폴더)만 (균일)
│   ├── <area>/                              # (선택) BC 그루핑 — 순수 시각 네임스페이스 (아래 area 핵심 사실)
│   │   └── <bc>/                            #   area 하위 BC — 내부 구조는 아래 <bc>/와 완전 동일
│   └── <bc>/                                # 바운디드 컨텍스트 (기능 영역) 1개
│       ├── <bc>_router.dart                 # go_router GoRoute 정의 — 라우트 path·name 단일 출처
│       ├── <bc>_navigator.dart              # 정적 push 헬퍼 — 라우트 이름만 참조, View import 금지
│       │
│       ├── domain_layer/                    # 순수 Dart — package:flutter import 금지
│       │   └── <aggregate>/                 # 애그리거트(개념) 1차
│       │       ├── <aggregate>.dart         # 애그리거트 루트 — 일관성 경계
│       │       ├── entity/                  # 종속 엔티티 (freezed + json)
│       │       ├── value_object/            # 값 객체·도메인 분류 값
│       │       ├── enum/                    # 도메인 enum
│       │       ├── domain_service/          # stateless 도메인 로직
│       │       ├── specification/           # Specification
│       │       └── exception.dart           # 도메인 예외 (첫 예외 때 생성 — 골격 대상 아님)
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
├── common/                                  # 횡단 공통 — BC를 모른다 (application·root import 금지, @riverpod 금지)
│   ├── enum/                                # 전역 enum (global key·env)
│   ├── network/                             # dio client·auth interceptor·safeApiCall·BadRequestResponse
│   ├── local_database/                      # 로컬 DB 엔진 + 전역 데이터 (토큰·앱 설정) — BC 데이터 캐시는 BC infra로
│   ├── service/                             # BC 무관 플랫폼 서비스 (애널리틱스·이미지·디바이스)
│   └── util/                                # 순수 유틸 (포맷터·계산기·확장)
│
└── design_system/                           # BC 어휘를 모르는 시각 요소 — 토큰 + 컴포넌트
    ├── foundation/                          # 디자인 토큰 — 시각 값의 단일 출처 (표준 7파일)
    │   ├── app_color.dart · app_typography.dart · app_spacing.dart · app_radius.dart
    │   └── app_shadow.dart · app_duration.dart · app_asset.dart
    ├── theme/
    │   └── app_theme.dart                   #   foundation → ThemeData 조립 (light/dark 확장점)
    ├── component/                           # 공용 위젯 — 부품군 1차, 직속 파일 금지
    │   ├── app_bar/ · button/ · dialog/ · bottom_sheet/
    │   └── input/ · loading/ · image/ · feedback/ · background/ …
    └── util/                                # 시각 동작 헬퍼 (스크롤 동작·미디어쿼리·TextStyle 빌더)
```

계층·종류의 동작 규율(각 폴더에 담기는 코드의 내용 규칙)은 lens 스킬 소유다: domain_layer 내부 → architecture-ddd(전술 패턴 §3·§4·판정 소유 §5) / application_layer 내부 → architecture-state(VM 3변종 §1·State 계약 §3·에러 2채널 §4) / infra_layer 내부 → architecture-data(safeApiCall §2·Either §3·로컬 2층 §5) / presentation_layer 내부·design_system 사용 → architecture-ui(3단 판별 §1·승격 규칙 §4). 이 문서는 **어떤 폴더·파일·이름이 존재해야 하는가(사실)** 를 소유한다.

**root/ 핵심 사실** (규약 §3.6 — 동작 규율은 architecture-state §10, view 작성 규율은 architecture-ui §2 위임): root는 application·common·design_system 세 컨테이너를 전부 아는 유일한 곳이라 `application/` 밖, `main.dart` 옆이 정위치다. 내부는 계층 없이 역할 4폴더(`router/`·`scaffold/`·`handler/`·`initializer/`)이고 scaffold만 종류 2차(view·view_model·state)를 갖는다. root/ 이하 모든 파일은 `root_` 접두를 유지한다 — BC 코드의 `import '…root_…'` 한 줄로 위반이 즉시 식별된다. 다수 BC 투영 화면(예: 피드 `home_view`)은 root가 아니라 자기 이름의 **일반 BC**다.

**area 핵심 사실** (feedback-031 — opt-in 그루핑): `application/` 직속에는 BC 폴더 외에 **area 폴더**(BC 그루핑 — `application/<area>/<bc>/`)를 둘 수 있다. area는 **순전히 사람의 시각적 도움을 위한 네임스페이스**다: ⓐ **기본은 평면** — area는 G0에서 사용자가 명시 판정할 때만 쓴다(에이전트 자동 추론 금지 — 판별 배정은 `undecidable.md` §13) ⓑ area 직속은 BC 폴더만(파일·`analysis_options.yaml`·`.gitkeep` 금지)·중첩 1단만·빈 area 금지 ⓒ **BC 이름은 앱 전역 유일 유지(접두 유지)** — area는 어떤 식별자·클래스명·라우트 name·파일명에도 등장하지 않는다. Dart는 패키지 네임스페이스가 없어 접두를 폴더로 대체하면 클래스·라우트가 전역 충돌한다 — area는 접두의 *대체*가 아니라 접두 *위의* 그루핑이다 ⓓ area·BC 이름에 계층명(`*_layer` 4종)·컨테이너명(root·application·common·design_system) 금지 ⓔ **리트머스** — area 폴더를 지워 평면으로 되돌려도 바뀌는 것은 경로(lib·test 미러의 디렉터리 위치와 import 문)뿐, 식별자·클래스명·라우트 name·파일명·코드 동작은 불변이어야 한다. 러너는 area를 적극 증명될 때만 인정(직속 파일 0·직속 전부 BC꼴)하고 그 외 전부 기존대로 BC 취급한다(보수 폴백 — 레거시·drift 형상의 분류 불변).

**test/ 핵심 사실** (Dart 공식 package-layout — `lib/`의 루트 형제·`main.dart`·`lib/`와 같은 패키지 최상위): 테스트는 `test/`에 두고 **`lib/` 구조를 1:1 미러**한다 — `lib/application/<bc>/<계층>/<sut>.dart` → `test/application/<bc>/<계층>/<sut>_test.dart` (area 그루핑 시에도 그대로 — `lib/application/<area>/<bc>/…` → `test/application/<area>/<bc>/…`). 단 **test/는 sparse다 — SUT가 있는 자리에만 테스트 파일을 두고 빈 미러 폴더·빈 테스트 파일을 만들지 않는다**(골격 완비의 명시적 예외 — §3). 무엇을 테스트할지·단언 FORM은 discipline-test, Flutter 메커니즘·결정성은 implementation-test 소유다. 백스톱 TG1은 신규 BC의 행위 테스트 *존재*만 검사하고(부재 차단), 미러 배치·FORM은 discipline-reviewer가 감사한다.

## §2. 성장 규칙 — 개념 1차·종류 2차

계층별로 개념 분할 시점이 다르다 (규약 §4):

- **domain_layer — 항상 애그리거트(개념) 1차.** BC가 작아도 애그리거트 폴더부터 만든다. 도메인 개념이 불명확한 BC는 **BC와 동명의 애그리거트**가 기본값.
- **application_layer·presentation_layer — 두 번째 개념이 등장하는 시점에 개념 1차로 분할**하고 그 안에 종류 폴더를 둔다. 분할은 새 코드부터 적용하며 기존 파일 이동을 요구하지 않는다:

```
chat/application_layer/
├── chat/                                # 개념 1차
│   └── use_case/ · view_model/ · state/ · shared_state/ · service/   # 종류 2차 — 완비(§3)
└── chat_request/
    └── use_case/ · view_model/ · state/ · shared_state/ · service/
```

- **infra_layer — 평면 유지.** 개념 분할 없이 종류 폴더만 (HaffHaff 16 BC 전수에서 동일).
- 분할 후 기존 직속 종류 폴더는 **동결** — 신규 파일 금지, 새 코드는 개념 폴더로.
- `root/`의 성장도 같은 문법: 한 이벤트원이 두 번째 파일을 낳으면 `handler/<이벤트원>/` 개념 폴더로 분할. 미리 파지 않는다.
- **같은 개념은 계층이 달라도 같은 철자** — `lounge_post_manage` ↔ `manage_lounge_post` 같은 어순 불일치 금지. ("두 번째 개념" 식별·철자 일치의 판별 배정은 `undecidable.md` §9.)

## §3. 골격 완비 규칙 — 비어 있어도 형태를 유지한다

BC를 만들면 **4계층 폴더와 모든 표준 종류 폴더를 항상 생성한다 — 비어 있어도 둔다. 선택 폴더는 없다** (규약 §5, 사용자 확정). 트리의 형태 자체가 규약이므로 빈 폴더가 "이런 종류가 올 자리"라는 안내 역할을 한다. 폴더는 무조건, 코드는 필요할 때만.

| 계층 | 항상 생성하는 종류 폴더 (전부) |
|---|---|
| `domain_layer` | `<aggregate>/` + 애그리거트 루트 `<aggregate>.dart`(항상 생성) + `entity/`·`value_object/`·`enum/`·`domain_service/`·`specification/` — `exception.dart`는 첫 예외 때(골격 대상 아님) |
| `application_layer` | `use_case/`·`view_model/`·`state/`·`shared_state/`·`service/` |
| `infra_layer` | `data_source/`·`repository/`·`service/` |
| `presentation_layer` | `view/`·`section/`·`widget/`·`ui_extension/` |

- git은 빈 디렉터리를 추적하지 않으므로 빈 폴더에는 `.gitkeep`을 둔다.
- 개념 1차로 분할된 경우(§2) 표준 종류 폴더는 **각 개념 폴더 안에** 완비한다.
- `lib/root/`는 BC 골격 비적용 — 자체 골격(역할 4폴더 + scaffold 하위 `view/`·`view_model/`·`state/`)을 비어 있어도 항상 생성한다.
- design_system 골격(foundation·theme·component·util 4폴더 + foundation 7파일 자리)도 같은 정신으로 항상 생성한다.
- BC 루트 직속에는 `<bc>_router.dart`·`<bc>_navigator.dart` 둘만 온다 — `application/` 직속은 BC(또는 area) 폴더만(조립 파일 금지). area 폴더 자체는 골격 비대상이다(§1 area 핵심 사실 — 직속은 BC 폴더만·빈 area 금지) — BC 골격은 area 유무 무관 동일하게 완비한다.
- **`test/`는 골격 완비의 명시적 예외 — sparse다.** "선택 폴더 없음"은 `lib/` 한정이다: `lib/`는 빈 폴더로 자리를 안내하지만 `test/`는 *빈 미러 폴더·빈 테스트 파일을 만들지 않는다* — 테스트는 SUT가 생긴 자리에만 둔다(§1 test/ 핵심 사실). 빈 슬롯을 채우려는 유혹이 헛테스트(vacuous)를 부르기 때문이다(테스트 규율은 discipline-test). 미러 배치 자체는 리지드 골격 검사가 아니라 discipline-reviewer 감사 대상이다(nav·fixture·common·VM-unit 등 '미러'가 자명하지 않은 자리가 있어 false-FAIL·게이밍을 피한다).
- **타입 강제 국소 lint** — 골격을 만들 때 dddart 생성 영역 루트(BC `application/<bc>/` 또는 `application/<area>/<bc>/`·`common/`·`design_system/`·`root/`)마다 `analysis_options.yaml`을 생성해 타입 전면 명시(implementation-dart §2 일탈3)를 *그 폴더에 국소* 강제한다. **호스트 루트 `analysis_options.yaml`은 절대 수정하지 않는다** — analyzer는 가장 가까운 상위 옵션을 쓰고 하위가 부모를 *대체*하므로(병합 아님) 템플릿에 `include`·`exclude`·rules를 전부 명시한다(plugin 경계 — 호스트 기존 lint 정책 무파괴). codegen(`*.g.dart`·`*.freezed.dart`)은 `exclude`:

```yaml
# dddart 생성 폴더 국소 — 호스트 루트 미수정. flutter_lints와 always_specify_types는 충돌하지 않으니 include 유지(실측 — flutter_lints는 omit류 비활성·국소가 부모 룰셋 대체). 주의: 호스트 루트가 이 폴더를 analyzer: exclude:로 덮으면 루트 analyze에서 국소 lint가 침묵 무력화된다(G0 전제조건 검사에서 확인).
include: package:flutter_lints/flutter.yaml
analyzer:
  language:
    strict-raw-types: true
    strict-inference: true
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
linter:
  rules:
    always_specify_types: true
    always_declare_return_types: true
```

## §4. 명명 규약 총괄표

공통 원칙 (규약 §7.1):

1. **파일명 = 주 클래스명의 snake_case.** 한 파일에 주 클래스 하나 (codegen part 파일 `.g.dart`·`.freezed.dart`와 도메인 `exception.dart`는 예외).
2. **종류는 폴더가 결정하고, 접미사가 그것을 재확인한다.** 접미사 판별은 긴 것 우선 — `_shared_state.dart`는 shared_state 종류이지 state 종류가 아니다.
3. **화면 삼총사는 같은 접두**: `<화면>_view.dart` ↔ `<화면>_vm.dart` ↔ `<화면>_state.dart` 1:1:1 대응. 위젯 단위 VM도 동일(`chat_request_btn_view` ↔ `chat_request_btn_vm`). 검사 방향은 **VM 기준** — VM이 존재하면 같은 접두의 view·state가 대응해야 하며, VM이 필요 없는 정적 view(약관·안내)는 VM·State 없이 허용. **접두 `<화면>`은 view 파일 stem에서 `_view`를 뗀 것이다** — view=`weekly_forecast_view.dart`면 접두는 `weekly_forecast`이고 VM·State는 `weekly_forecast_vm.dart`·`weekly_forecast_state.dart`(클래스 `WeeklyForecastVM`·`WeeklyForecastState`)다. 접두에 `_view`를 끼운 `weekly_forecast_view_vm.dart`·`weekly_forecast_view_state.dart`(클래스 `…ViewVM`·`…ViewState`)는 **금지** — `_view_state.dart`는 백스톱 NM2 deny 접미사이고 `…_view_vm`은 짝 view 부재로 NM4가 발화한다.
4. **UseCase는 화면이 아니라 도메인 개념 단위로 짓는다** — 여러 VM이 하나의 UseCase를 공유한다 (판별 배정은 `undecidable.md` §8).
5. **도메인 종류 명명은 dddjango 원형과 동일** — specification은 풀네임 `_specification`(`_spec` 축약 금지), 도메인 서비스는 `_service`. specification의 평가·조합은 Model(UseCase 이하)에서만 — VM이 도메인 판정을 직접 수행하지 않는다(판정 소유 상세는 architecture-ddd §5·`undecidable.md` §8).
6. **`@riverpod` provider는 ViewModel 3변종(VM·SharedState·Service)과 root의 2변종(root_vm·root handler)에만.** UseCase·Repo·DataSource는 plain class — 사용처에서 직접 생성(DI 없음, 규약 §9-13).

총괄표 (규약 §7.2):

| 위치 | 이름 기준 (접두) | 파일명 | 클래스명 |
|---|---|---|---|
| BC 루트 라우터 | BC명 | `<bc>_router.dart` | GoRoute 변수 `<bc>Router` + `abstract final class <Bc>Routes` |
| BC 루트 내비게이터 | BC명 | `<bc>_navigator.dart` | `<bc>Navigator` |
| root `router/` | 고정 | `root_router.dart` | GoRouter **전역 변수** `rootRouter` (plain, provider 아님) |
| root `scaffold/` — 삼총사 | 고정 접두 `root` | `root_view.dart`·`root_vm.dart`·`root_state.dart` (게이트 화면은 `root_<게이트>_view` 등) | `RootView`·`RootVM`·`RootState` |
| root `handler/` | 이벤트원 | `root_<이벤트원>_handler.dart` | `Root<이벤트원>Handler` |
| root `initializer/` | 고정 | `root_initializer.dart` | `RootInitializer` |
| 애그리거트 루트 | 애그리거트명 | `<aggregate>.dart` (폴더 직속) | 애그리거트명 |
| domain `entity/` | 개념명 (단수 명사) | `<개념>.dart` | 개념명 |
| domain `value_object/` | 개념명 | `<개념>.dart` | 개념명 |
| domain `enum/` | 개념명 | `<개념>.dart` | 개념명 |
| domain `domain_service/` | 행위·정책 | `<행위>_service.dart` | `<행위>Service` |
| domain `specification/` | 규칙 풀네임 | `<규칙>_specification.dart` | `<규칙>Specification` |
| 도메인 예외 | 고정 | `exception.dart` (폴더 직속) | `*Exception` 모음 |
| app `use_case/` | **도메인 개념** (화면 금지) | `<개념>_use_case.dart` | `<개념>UseCase` |
| app `view_model/` | **화면** — view와 동일 접두 | `<화면>_vm.dart` | `<화면>VM` |
| app `state/` | 노출 주체와 동일 접두 | `<화면·관심사·기능>_state.dart` | `…State` |
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
| ds `foundation/` | 토큰 종류 | `app_<토큰>.dart` | `App<토큰>` (토큰 상수는 lowerCamelCase) |
| ds `component/<군>/` | 수식·변형 | `<수식>_<군>.dart` | `<수식><군>` (무접두 — 종류 접미사가 구별자) |
| ds `theme/` | 고정 | `app_theme.dart` | `AppTheme` |
| common 5종·ds `util/` | 기능·도구 | 파일명 = 주 선언명 snake_case (`service/`는 `<기능>_service.dart`) | 주 선언명 |

- 폴더명은 `repository/`(전체 표기), 파일 접미사는 `_repo.dart`(축약) — 혼동 주의.
- 라우트 path·name 문자열 리터럴은 `<bc>_router.dart` 안에서만 등장한다 — `abstract final class <Bc>Routes`(static const)로 묶고 navigator·root_destination_handler는 이 상수만 참조.

## §5. import 방향 — 계층 매트릭스·교차 BC 4채널·root 방향 규칙

**BC 내부 계층 매트릭스** (규약 §3.7 — 행=from, 열=to). `common/`은 전 계층에서 import 가능하되 **domain_layer만 예외**(순수 Dart — `package:flutter`·common 포함 비순수 import 금지). **`design_system/` import 허용 위치는 닫힌 열거**(러너와 동일): presentation_layer 전체 · `<bc>_router.dart` · `root/scaffold/` · `root/router/root_router.dart` · `main.dart` · design_system 내부 — **그 외 전부 금지**(navigator·handler·initializer·application_layer(VM·SharedState·UseCase·State)·infra·domain·common — 시각 토큰 매핑이 VM으로 새면 ui_extension "유일한 자리" 규칙이 무너진다). router 허용은 GoRoute pageBuilder의 전환 토큰(AppDuration 등) 실수요 때문 — 금지하면 매직 넘버를 유도해 "시각 값 단일 출처"가 오히려 깨진다:

| from \ to | domain | application | infra | presentation | BC 루트 |
|---|---|---|---|---|---|
| domain | ✓ | ✗ | ✗ | ✗ | ✗ |
| application | ✓ | ✓ | ✓ — UseCase→Repo·infra service만 | ✗ | ✓ — **VM만**→navigator (service는 금지: 플랫폼 이벤트의 내비는 root_destination_handler 소유) |
| infra | ✓ | ✗ | ✓ | ✗ | ✗ |
| presentation | ✓ | ✓ — view→VM·State·SharedState만 | ✗ | ✓ | ✓ — navigator |
| BC 루트 | ✗ | ✗ | ✗ | router→view만(GoRoute builder) — navigator는 View import 금지 | ✓ |

셀 규칙의 동작 의미(왜 VM만 navigator를 부르나, view는 무엇을 watch하나)는 architecture-state §2(VM 규율)·architecture-ui §2·§3(presentation 규율) 소유다.

**교차 BC 통신 — 4채널만 허용** (규약 §9-3, 백스톱 검사 대상):

| # | 채널 | 비고 |
|---|---|---|
| ① | 도메인 타입 import | 엔티티·VO·enum (예: channel이 member의 `Candidate` 사용) |
| ② | 타 BC UseCase 호출 | 행위·데이터 접근의 단일 관문 |
| ③ | 타 BC navigator 호출 | 라우트 이름만 |
| ④ | 타 BC view 임베드 | `view/`는 전부 임베드 가능 — view는 자기 VM을 스스로 watch하므로 임베드는 배치만 |

**금지**: 타 BC의 Repo·DataSource·box 직접 호출, 타 BC VM watch, 타 BC SharedState watch(root만 면제), 타 BC section·widget·ui_extension import(부품 재사용은 design_system 승격 경유). 채널 *선택* 절차(어느 채널이 적정한가)는 architecture-ddd §2·architecture-state §7 소유.

**root·common·전역 방향 규칙**:

- **`root/`를 import하는 곳은 `main.dart`뿐.** BC가 root를 알면 전체를 알게 되어 격리가 무너진다. root/ 내부의 상호 import는 자유.
- **root → BC는 자유**(전부 아는 것이 존재 이유 — 4채널 면제). 단 Model 방향 규율은 동일: root도 BC의 **UseCase만** 호출(Repo·box 직행 금지). 유일 예외: `root_initializer` → `<bc>_hive_adapters.dart`(데이터 접근이 아니라 시동 배선 — root가 import할 수 있는 유일한 BC infra 파일).
- **`common/`은 `application/`·`root/`를 import하지 않는다.** common은 모두가 아는 곳, root는 모두를 아는 곳.
- **`design_system/`은 `application/`·`root/`를 import하지 않는다.**
- **main.dart는 엔트리포인트 최소형** — `runZonedGuarded`(onError는 `root_error_handler`로 위임 — 빈 `(e, s){}` 바디로 전역 에러를 침묵 삼키지 않는다; `root_error_handler`도 받은 에러를 침묵 삼키지 않고 최소한 관찰 가능하게 둔다 — 외부 크래시리포트 SDK 연결은 앱 소관·§7 반송표) + `root_initializer` 시동 + `runApp(ProviderScope(...))`. 테마는 `app_theme` 한 줄, 라우터는 `root_router` 한 줄 참조. import 화이트리스트: root/·flutter·riverpod 계열·`design_system/theme/app_theme.dart`(+`dart:`·l10n 산출물) — 정확한 경계는 러너가 단일 출처(§8). 역방향(`application/`·`common/`·`design_system/`이 main.dart를 import) 금지 — BC 무관 전역 인스턴스(logger·routeObserver·내비게이터 전역 키)는 common 소속이다.
- domain_layer는 `package:flutter` import 금지 — freezed·json_annotation·dartz 등 순수 패키지만.
- BC 엔티티의 hive 어댑터 등록 함수는 `data_source/<bc>_hive_adapters.dart` 한 파일에 모은다 — 도메인 엔티티에 storage 어노테이션을 붙이지 않는다.

## §6. common·design_system 입장 판별

**common은 모든 BC가 의존하는 곳이다 — 따라서 어떤 BC도 알면 안 된다.** 편의 버킷이 아니다. 입장 판별 — 위에서부터, 처음 해당하는 것이 답 (규약 §6):

| # | 질문 | 답 |
|---|---|---|
| 1 | BC의 도메인 어휘를 아는가? | common 금지 → 그 BC로 (enum은 `domain_layer/.../enum/`, 공유 상태는 `shared_state/`, 데이터 캐시는 `data_source/`) |
| 2 | 모든 BC를 알아야 하는 조립 코드·조립 화면인가? (라우터 조립·딥링크 디스패치·전역 라이프사이클·시동·루트 스캐폴드) | 합성 루트 `lib/root/`. 단 루트 스캐폴드가 아닌 다수 BC 투영 화면은 자기 이름의 일반 BC |
| 3 | 시각 UI 부품인가? | `design_system/` |
| 4 | 그 외 — BC 무관 횡단 기반 | **common** |

- 헷갈리면 import 방향으로 가른다: `application/`을 import하면 조립 코드라 root, BC들이 이것을 import하면 common.
- **common은 살아있는 상태를 갖지 않는다 — `common/`에서 `@riverpod` 금지**(백스톱 proxy). proxy가 못 잡는 가변 싱글턴(TokenManager 류)도 반응형 신호·구독을 노출하기 시작하면 common 실격 — 정체를 따져 제자리로(BC 어휘 있으면 그 BC shared_state, 전 BC 배선이면 root). 판별 배정은 `undecidable.md` §7.
- common 종류는 **5종 고정**: `network/`·`local_database/`·`service/`·`enum/`·`util/`. `provider/` 같은 비표준 종류 금지.
- `local_database/`는 로컬 DB **엔진**과 **전역 데이터**(토큰·앱 설정)만 — BC 도메인 데이터의 캐시는 그 BC `infra_layer/data_source/`의 `_local_data_source.dart`(로컬 2층 상세는 architecture-data §5).
- common이 BC 일을 필요로 하면(401 처리 등) 직접 import 대신 **콜백 주입** — 콜백·추상만 정의하고 구현 연결은 `root_initializer`(조립)가 담당.

**design_system — BC 어휘도 도메인 어휘도 모르는 시각 요소**:

- `foundation/` 7토큰이 시각 값의 **단일 출처** — BC presentation·root scaffold·component에서 `Color(0x…)`·생 `TextStyle(…)`·연출 `Duration(…)`(전환·애니메이션·press 피드백은 `AppDuration` 토큰) 리터럴 금지. *비시각* duration(네트워크 timeout·디바운스)·구조 명명 상수(`Colors.transparent` 같은 리플 호스트 배경 등 브랜드 시각값 아닌 것)는 제외 — 상세 경계는 architecture-ui §7.
- `component/`는 부품군 1차 — **부품군 폴더 = 파일 접미사 = 클래스 접미사**(`button/` 안은 `*_button.dart` → `*Button`). 축약(btn)·직속 파일·정크드로어 군(`widget/`·`etc/`) 금지. 분류 안 되는 부품이 생기면 새 부품군 폴더를 만든다.
- 컴포넌트 표시 경로 규율(전역 navigator 키 static `show()` 금지 포함)은 architecture-ui §7 소유 — 규칙 본문은 그 스킬에만 둔다.

## §7. 표기 표준화 — drift와 교정

HaffHaff-App 전수 조사에서 발견된 변형들. dddart는 **새로 만드는 코드에서 아래 표준만 쓰며**, 백스톱이 변형을 잡는다. 기존 코드 수정을 요구하지 않는다 (규약 §8).

**적용 경계 — 표기는 파일, 구조는 단위**: ⓐ **새로 만드는 파일은 어느 폴더에 두든 표준 표기**(파일명·접미사·클래스)만 쓴다 — 아래 표의 변형 표기(`_app.dart`·`_bridge.dart` 류)로 새 파일을 만들지 않는다. 백스톱 명명 검사는 added 파일 기준으로 폴더와 무관하게 발화한다. ⓑ **폴더 구조의 표준 강제는 신규 단위**(BC·개념 폴더·화면 삼총사)**부터** — 레거시 단위 내부에 파일을 추가할 때 표준 폴더 신설을 강제하지 않으며(구조 검사는 added 디렉터리 기준), 기존 파일의 개명·이동도 요구하지 않는다(규약 §8 문면 그대로 — "새로 만드는 코드에서 표준만"):

| 발견된 변형 | 표준 |
|---|---|
| `viewmodel/` | `view_model/` |
| `repo/` (폴더명) | `repository/` |
| `presentation_later/` 류 오타 | `presentation_layer/` — 계층 철자 정확히 |
| `my_louge_post/` 류 개념 폴더 오타 | 개념 철자 통일 |
| 계층 간 어순 불일치 (`lounge_post_manage` ↔ `manage_lounge_post`) | 같은 개념 같은 철자 |
| `container/` (presentation 비표준 종류) | view/section/widget 3종으로 정리 |
| 능동 service가 infra에 (keepAlive Notifier·UseCase 호출·상태 노출) | 이벤트 구동·UseCase 호출 service는 `application_layer/service/` |
| `<화면>_view_state.dart` 변형 | `<화면>_state.dart` — `view`를 끼우지 않는다 |
| state 폴더 파일의 `_state` 접미사 누락 | `_state.dart` 필수 |
| BC 도메인 데이터 캐시가 common에 | BC `infra_layer/data_source/`의 `_local_data_source.dart` |
| `*_box_repo` 변형 | Repo 하나가 원격+로컬 DataSource를 조합 |
| section·widget의 VM watch | dumb 유지 — 상태가 필요하면 view+vm 쌍으로 승격 |
| navigator가 presentation_layer에 | BC 루트 `<bc>_navigator.dart` — 라우트 이름만 참조, View import 금지 |
| BC 어휘 enum이 common에 | 그 BC의 `domain_layer/.../enum/` |
| 전 화면 라우트 enum이 common에 | `<bc>_router.dart`로 해체 — 라우트 path·name의 단일 출처 |
| BC 공유 상태가 common에 | 해당 BC의 `application_layer/shared_state/` |
| 교차 BC 화면 갱신 버스 (`refresh_notifier` 류) | 종류 폐지 — 데이터 변화는 그 BC SharedState로, 라이프사이클발 갱신은 `root_lifecycle_handler`→BC service (처방 상세는 architecture-state §8) |
| 위장 이벤트 신호 (`scroll_to_top_notifier` 류) | 종류 폐지 — 탭 재탭 스크롤톱은 root_view가 직접 처리, BC는 신호를 듣지 않는다 |
| 조립 코드가 common/service에 | 합성 루트 `root/handler/`의 `root_<이벤트원>_handler.dart` |
| 시동 코드가 lib 루트 떠돌이 파일 | `root_initializer.dart` — 부트스트랩도 BC UseCase 호출로 |
| 조립 코드의 box 직접 접근 (router redirect 등) | root도 Model 규율 적용 — UseCase 경유 |
| 조립 파일이 `application/` 직속에 | `lib/root/` — application/ 직속은 BC(또는 area) 폴더만 |
| 동일 접두 BC군이 평면에 나열 (`driver_*`·`rider_*` 류 역할·서브도메인 축) | (선택) `application/<area>/<bc>/` 그루핑 — area는 순수 시각 네임스페이스(§1 area 핵심 사실)·G0 사용자 판정으로만 도입 |
| 전역 에러 배선 산재 (빈 `runZonedGuarded` 핸들러 등) | `root/handler/root_error_handler.dart` |
| 전 BC 목적지 enum (push BC에 전 BC 목적지 어휘) | 푸시 탭의 딥링크 URL 정규화로 소멸 — 목적지 어휘는 각 BC 라우트 path |
| 파일명 오타 (`certificcation`·`servcie` 류) | 철자 교정 |
| 타이포 토큰이 enum 파일에 (TextStyle 전역 변수) | `foundation/app_typography.dart` |
| component 정크드로어·직속 파일 (`widget/`·`etc/`) | 부품군 폴더로 해체 (input·feedback 등) |
| `btn/` 축약·`_btn`/`_button` 혼재·`ds_` 접두 | `button/`·`_button.dart`·무접두 통일 |
| design_system 오타·토큰 표기 혼재 (`WHITE`/`GRAY_50` 류) | 철자 교정 · 토큰 상수 lowerCamelCase |
| state로 위장한 이벤트 (`*_added` 과거형 사건명·DateTime 핵·센티널 초기값) | 과거형 사건명 shared_state 금지 (판별 배정은 `undecidable.md` §10) |
| 셸이 타 BC 화면을 흡수 | 화면 귀속 규칙 — UseCase 소속 BC로. 탭 셸은 `root_*`, 다수 BC 투영 화면은 자기 이름 BC |
| 교차 BC VM watch·화면 삼총사 분할 | 4채널만(§5) — 삼총사는 한 BC에 |
| `app/`·`_app.dart`·`*App` | `use_case/`·`_use_case.dart`·`*UseCase` |
| `bridge/`·`_bridge.dart`·`*Bridge` | `shared_state/`·`_shared_state.dart`·`*SharedState` |
| `block/`·`_block.dart`·`*Block` | `section/`·`_section.dart`·`*Section` |
| UseCase의 UI 직접 호출 (ErrorDialog 등) | UseCase는 Either만 반환 — 에러 표시 채널은 architecture-state §4(에러 2채널) |
| VM의 BuildContext 보유 | navigator 헬퍼 경유 — BuildContext 보유 금지 |
| 화면 state가 `domain_layer/<agg>/state/`에 | `application_layer/state/` |
| domain_layer 평면 (애그리거트 폴더 없음) | 애그리거트(개념) 1차 |
| main.dart 비대 (테마 조립·초기 라우트 분기·전역 인스턴스) | 엔트리포인트 최소형 — 테마는 app_theme, 초기 분기는 root_router redirect, 전역 인스턴스는 common |
| BC 어휘 service가 common에 | 그 BC `application_layer/service/` |
| common 비표준 종류 폴더 | 5종 외 금지(§6) — 내용물은 입장 판별대로 재배치 |
| `appbar/` | `app_bar/` |

## §8. 백스톱 연동 — 러너·게이트

dddart 파이프라인은 이 하우스룰의 기계 판별 가능 부분을 **결정적 러너**가 게이트에서 검사한다 (백스톱 설계 §2·§3이 단일 근거 — 개별 검사의 열거·모사는 금지, 검사 의미가 바뀌면 러너가 단일 출처):

```
dart run "${CLAUDE_PLUGIN_ROOT}"/scripts/backstop.dart <대상 프로젝트 루트> \
  [--diff-base <commit>] [--all] [--only st,im,nm,cy,tg,pj] [--update-baseline]
```

(파이프라인에서는 Coordinator가 플러그인 루트를 해소해 호출한다 — 에이전트가 경로를 추측하지 않는다.)

- 검사 패밀리 4종: **구조(ST)·import(IM)·명명(NM)·순환(CY)**. 발견은 전부 blocker — 일괄 반송.
- **게이트 의미론**: 구조·명명은 **added**(새로 만든 파일·디렉터리)만, import는 touched 파일의 **added 줄**만, 골격 완비는 **신규 단위**(새 BC·애그리거트·개념 폴더)만, 순환은 전역+베이스라인 래칫. → **레거시(기존 drift)에는 불발화한다** — "새 코드부터 표준" 원칙의 기계 집행이며, 기존 코드 수정을 요구하지 않는 §7과 정합.
- `--all`은 게이트 무시 전역 감사용 — 레거시 프로젝트에서 발견 폭주가 정상이며 파이프라인 게이트 용도가 아니다.
- 비git 폴백은 전역 검사로 퇴화 — 파이프라인 전제조건(G0)이 `git init`+초기 커밋을 제안하는 이유.
- **반송 패밀리 → 교정 절 백링크**: ST(구조) → §1 트리·§2 성장·§3 골격·§7 변형 / IM(import) → §5 / NM(명명) → §4 / CY(순환) → §5 교차 BC 4채널(신규 순환은 import 경로 재설계 — 채널 선택 절차는 architecture-ddd §2·architecture-state §7).
- **에이전트 분업**: 러너가 잡는 것(경로·import·명명·순환)은 흉내내지 말고 이 문서대로 만들면 통과한다. 러너가 못 보는 **의미 판별 18종**(view/section, BC 어휘, 판정·계산의 귀속, 살아있는 상태, 접두↔area 등)은 `undecidable.md`가 판별 절차·배정의 단일 출처다.
