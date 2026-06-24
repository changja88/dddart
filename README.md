# dddart

**Flutter 프로젝트에 간소화 DDD + 철저한 MVVM을 제대로 입히는 Claude Code · Codex 플러그인.**

`/dddart <기능>` 한 줄이면, 한 기능을 **요구 정리 → 설계 → 구현**까지 전문 에이전트들이 협업해 깔끔한 4계층 구조로 완성한다. 매 단계 당신의 승인을 받고 진행한다.

---

## 왜 dddart인가

Flutter는 빠르게 화면을 그리기 좋지만, 기능이 커질수록 비즈니스 규칙이 흩어진다.

- 도메인 규칙이 위젯의 `setState`·`build()`와 콜백 안에 뒤섞이고,
- 서버 응답 모델이 곧 화면 모델·도메인 모델이라 한 덩어리가 되며,
- 결국 "한 줄 고치면 어디가 깨지는지 모르는" 위젯 트리가 된다.

**dddart는 한 기능을 추가할 때마다 이걸 4계층으로 정돈한다:**

| 계층 | 책임 | 예 |
|---|---|---|
| **domain** | 순수 비즈니스 규칙·불변식 (`package:flutter` 무관) | `WeatherForecast` 애그리거트, `ForecastDate` 값 객체 |
| **application** | 화면 상태와 유스케이스 흐름 (ViewModel·State·UseCase) | `WeeklyForecastVM`(@riverpod), `WeatherForecastUseCase` |
| **infra** | 서버·로컬 저장 등 세부 구현 | `WeatherForecastRepo`, retrofit DataSource, hive |
| **presentation** | 화면·구획·부품 (view/section/widget) | `WeeklyForecastView`(ConsumerWidget) |

핵심은 **철저한 MVVM** — 지식이 `View → ViewModel → UseCase(Model 관문) → Repo` 한 방향으로만 흐른다. View는 수동(watch·바인딩)이고, 판정·가공은 아래 계층이 소유한다. 그리고 **간소화 DDD** — repository 인터페이스·DTO·ACL 같은 무거운 장치는 빼되, 뼈대(BC 컨테이너·4계층·개념 1차·종류 2차 폴더)는 지킨다.

> 이건 프로젝트를 새로 만드는 도구가 아니라, **이미 있는 Flutter 프로젝트에 한 기능을 DDD/MVVM으로 더하는** 도구다.

---

## 설치

**Claude Code** — 슬래시 커맨드로:

```
/plugin marketplace add changja88/dddart
/plugin install dddart@changja88
```

**Codex** — CLI로:

```
codex plugin marketplace add changja88/dddart --ref main
codex plugin add dddart@changja88
```

> 두 마켓 모두 같은 GitHub 레포(`changja88/dddart`)에서 받습니다. 설치 후 세션을 재시작하세요.

---

## 빠른 시작

기존 Flutter 프로젝트 루트에서 Claude Code를 실행하고:

```
/dddart 도시별 7일 날씨 예보 화면 — 목록·상세, 서버 스키마 https://api.example.com/openapi.json
```

기능 설명 한 줄이면 시작된다. (선택) OpenAPI URL을 같이 주면 서버 계약을 동결해 데이터 계층의 근거로 쓰고, 디자인 출처(Stitch design-ref 등)는 G0에서 정한다. 요구 정리부터 구현·테스트까지 단계별로 진행되며, 각 단계마다 당신이 승인한다.

---

## 어떻게 동작하나

### 전문가 팀처럼 일한다

`/dddart`를 실행하면 **Coordinator**(프로젝트 매니저 역할)가 붙어, 각 전문 에이전트에게 일을 나눠 주고 결과를 모은다. 당신은 코드를 직접 받아쓰는 게 아니라, **팀을 지휘하며 단계마다 승인**한다.

| 역할 | 하는 일 |
|---|---|
| **Coordinator** | 전체 진행·게이트·산출물 통합·검증 보고 (직접 코드는 안 씀) |
| **design-architect** | 4관점(ddd·ui·state·data)을 통합한 설계 명세 작성 (계층 배치·design-ref 토큰까지) |
| **design-review-ddd / ui / state / data** | 설계를 각자의 관점에서 **병렬 독립 리뷰** |
| **coder** | bottom-up 구현 + 행위 테스트 작성, 층별 `flutter analyze`/`flutter test` green 래칫 |
| **discipline-reviewer** | 클린코드·하우스룰 규율 감수 — 백스톱이 못 보는 의미 변종 전담 |

> 리뷰어는 기능에 따라 활성화된다 — **ddd는 항상**, 화면이 생기면 **ui**, ViewModel·상태가 걸리면 **state**, 서버·저장이 걸리면 **data**가 붙는다.

### 세 개의 승인 게이트 — 운전석은 당신

진행은 **3개의 게이트**로 끊긴다. 각 게이트에서 요약을 보고 "승인 / 수정 요청"을 고른다. 승인 전에는 절대 다음으로 넘어가지 않는다.

- **G0 · 요구·경계** — 무엇을 만들지, 어디에 둘지(새 BC vs 기존 확장), 어떤 리뷰 관점을 켤지, 디자인·서버 계약 출처(design-ref·OpenAPI 동결)를 확정한다.
- **G1 · 설계** — architect의 설계 명세 + 리뷰 반영 결과를 승인한다. 이 명세가 이후 코드·테스트의 **단일 근거**가 된다.
- **G2 · 구현** — 구현 코드 + 테스트 통과 결과 + 감수 리포트 + **58종 결정적 백스톱** 통과를 승인한다.

> G2 직전에는 **58종의 결정적 백스톱**(Dart 검사 스크립트)이 자동으로 돌아 구조·계약 회귀를 차단한다 — 컨테이너 위치, 4계층 골격, import 방향, 명명 규약, freezed 모델, @riverpod provider 위치 등을 고정밀로 검사해, 에이전트의 의미 감수가 놓칠 수 있는 위반을 마지막 안전망으로 잡는다.

### 디자인을 그대로 — design-ref → 토큰

디자인 시안(Stitch design-ref HTML 등)을 G0에서 연결하면, 시안의 색·spacing·크기·아이콘이 `design-tokens.json`으로 추출돼 설계 명세에 박힌다. architect는 이 추출값을 design_system foundation 토큰으로 잇고, coder는 매직 넘버가 아니라 토큰을 인용해 화면을 재현한다 — 시안 충실도를 구조로 강제한다.

### 워크스루: "7일 날씨 예보" 기능

```
/dddart 도시별 7일 날씨 예보 화면 — 목록·상세
```

**1) G0 — 요구·경계 확정**
Coordinator가 스코프를 정리해 보여준다: "주간 예보 목록 + 일자 상세, 서버에서 예보 조회." 그리고 묻는다 — *새 `weather` BC*로 둘까, 기존 영역 확장일까? 리뷰는 ddd + ui(화면) + state(VM) + data(서버 조회)로 켤까? 디자인 출처와 OpenAPI는? → 당신이 승인.

**2) 설계 → G1**
design-architect가 설계 명세를 쓴다 — `WeatherForecast` 애그리거트, 화면 분해(view/section/widget), `WeeklyForecastVM`과 State, `WeatherForecastUseCase`→`WeatherForecastRepo`, design-ref 토큰 매핑까지. 동시에 ddd·ui·state·data 리뷰어가 **병렬로** 독립 비평하고, architect가 이를 반영·중재한다. → 최종 설계 명세를 당신이 승인.

**3) 구현 → G2**
coder가 domain부터 presentation까지 bottom-up으로 슬라이스를 구현하고, 각 계층 끝에서 `flutter analyze`·`flutter test`로 green을 확인한다(행위 테스트 포함). discipline-reviewer가 구조·규율을 감수하고, 58종 백스톱이 G2 직전에 자동으로 돈다. → 코드·테스트·감수·백스톱 결과를 당신이 승인.

**4) 마무리**
실제로 돌린 검증만 보고한다 — `flutter analyze`, `flutter test`, 백스톱 통과 종수.

---

## 무엇이 만들어지나

dddart는 한 기능을 BC(바운디드 컨텍스트) 1개로 정돈해 `application/<bc>/` 아래 4계층으로 만든다:

```
lib/
├── application/                  # 모든 기능(BC)의 컨테이너 — 직속은 BC 폴더만
│   └── weather/                  #   한 기능 = 한 BC
│       ├── weather_router.dart           # GoRoute 정의 (라우트 path·name 단일 출처)
│       ├── weather_navigator.dart        # 정적 push 헬퍼 (View import 금지)
│       ├── domain_layer/                 # 순수 Dart — package:flutter 금지
│       │   └── weather_forecast/         #   애그리거트(개념) 1차
│       │       ├── weather_forecast.dart #     애그리거트 루트
│       │       ├── entity/ value_object/ enum/   # 종속 (종류 2차 폴더)
│       │       ├── domain_service/ specification/
│       │       └── exception.dart
│       ├── application_layer/            # ViewModel 계층
│       │   ├── use_case/                 #   Model 관문 (무상태·Either 반환)
│       │   ├── view_model/               #   @riverpod VM — 화면 상태의 주인
│       │   ├── state/                    #   freezed *State
│       │   └── shared_state/ service/    #   공유·헤드리스 변종
│       ├── infra_layer/                  # 세부 구현 (평면)
│       │   ├── data_source/ repository/ service/
│       └── presentation_layer/           # 화면
│           ├── view/ section/ widget/ ui_extension/
├── common/                       # 횡단 공통 — BC를 모른다 (network·local_database·service·enum·util)
├── design_system/                # 시각 요소 — foundation 토큰 + component
└── root/                         # 합성 루트 — router·scaffold·handler·initializer
```

핵심 규약이 일관되게 강제된다 — `application/` BC 컨테이너, 4계층 물리 분리, **개념 1차·종류 2차** 폴더, 도메인은 순수 Dart, ViewModel은 `@riverpod` 클래스형(UseCase·Repo는 plain class·DI 없음), State는 freezed, 시각 값은 design_system 토큰 단일 출처, View는 수동(watch·바인딩). **이 규약들은 58종의 결정적 백스톱이 구현 게이트(G2) 직전에 자동 검증**한다.

> 대상 프로젝트에 **이미 확립된 구조 규약이 있으면 그것을 우선**한다. 위 표준은 미조직 프로젝트의 기본값이다.

진행 메모와 설계 명세는 `.dddart/<날짜>-<기능-slug>/`(`scope.md`, `design-spec.md`, 동결한 `design-ref`·`openapi`)에 남는다 — 한 기능 = 한 폴더이고, 코드와 함께 커밋해 설계 결정 기록으로 남긴다.

---

## 신규 기능 vs 부분 수정

dddart는 작업 규모를 보고 알맞게 움직인다.

- **신규 기능** — 풀 파이프라인(요구 → 설계 → 구현)을 모두 거친다.
- **부분 수정** — 전체를 다시 돌지 않는다. 영향 범위만 확인하고, 바뀐 설계 부분과 영향받는 테스트만 재실행한다. 설계 변경이 없으면 설계 게이트를 건너뛴다.

---

## 요구 사항

- **Claude Code** 또는 **Codex**
- **기존 Flutter 프로젝트** — 이 플러그인은 한 기능을 빌드하는 도구이지, 프로젝트를 새로 부트스트랩하지 않는다.
- **스택**: 상태 관리는 **riverpod**(`@riverpod` 코드젠 클래스형), 모델은 **freezed**, 네트워크는 **dio/retrofit**, 로컬은 **hive**, 라우팅은 **go_router**, 테스트는 **flutter_test**가 기본이다 — 프로젝트에 다른 관례가 확립돼 있으면 설계자가 그것을 존중한다.

---

## 구성 요소

- **커맨드 1개**: `/dddart`
- **에이전트 7개**: `design-architect`, `design-review-ddd`, `design-review-ui`, `design-review-state`, `design-review-data`, `coder`, `discipline-reviewer`
- **스킬 11개**: 아키텍처(`architecture-ddd`/`-ui`/`-state`/`-data`), 규율(`discipline-houserules`/`-cleancode`/`-test`), 구현(`implementation-dart`/`-flutter`/`-riverpod`/`-test`)
- **결정적 백스톱 58종**: 구조·계약 회귀를 G2 직전에 자동 차단하는 Dart 검사 스크립트

> Claude Code(`dddart/`)와 Codex(`codex-dddart/`) 양 런타임을 지원한다. 정본은 `dddart/`이고 `codex-dddart/`는 동기 미러다.

---

## 라이선스

[MIT](LICENSE)
