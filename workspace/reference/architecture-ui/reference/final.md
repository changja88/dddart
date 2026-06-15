# 프레젠테이션 아키텍처 — 3단 규율·라우팅 짝·design_system 사용

## P1 Source Sufficiency

| field | value |
|---|---|
| purpose | dddart가 생성하는 Flutter 화면 코드의 단일 출처 — view/section/widget 3단 작성 규율, 승격·이동 규칙, ui_extension, BC 루트 라우팅 짝(router·navigator) 사용 절차, design_system 사용 규칙(전역 키 show() 금지 포함). |
| use when | 화면을 분해·작성·검수할 때, UI 조각의 단(view/section/widget)을 정하거나 승격할 때, 라우트·내비게이션을 만들 때, design_system 토큰·컴포넌트를 쓸 때. |
| exclude/handoff | 파일·폴더·명명·import 매트릭스 사실은 discipline-houserules, VM·State·listen 소비 패턴은 architecture-state, 화면 귀속 tie-break·경계 판별은 공유 reference undecidable.md, go_router·위젯 표기법은 implementation-flutter로 위임. |
| core criteria | 제1 규약 §3.5(3단·승격)·§3.1(라우팅 짝)·§6 중 design_system(§10-5 ① show() 금지 포함)·§9-10·§9-12. HaffHaff 실측(view 90% Consumer·block 93%·widget 98% dumb)의 명문화. |
| source priority | 1 제1 규약(2026-06-12) 2 본설계 §8(귀속 가이드) . |
| P1 classification | sufficient — 전 절이 규약 직접 슬라이스. 코드 예제 없이 규율 서술로 충분한 절들이라 발명 표면 없음. |

> **출처:** 제1 규약(dddart 표준 파일트리, 2026-06-11~12) §3.1·§3.5·§6·§9-10·§9-12·§10-5 ①.
> 본문 속 `(규약 §N)`은 **출처 표기**이며 로드 대상이 아니다 — 규칙 자체는 본문에 자족적으로 서술된다. 로드 가능한 위임은 "스킬명 + §번호(또는 주제)"와 공유 reference(`undecidable.md`)뿐.

---

## 목차

- §1. 3단의 정의 — 바인딩 1단 + 표현 2단
- §2. view 작성 규율 — VM과 1:1 바인딩 루트
- §3. section·widget 작성 규율 — dumb 표현 조각
- §4. 승격·이동 규칙 — 성장 시 단 이동
- §5. ui_extension — 도메인→UI 매핑의 유일한 자리
- §6. BC 루트 라우팅 짝 — router·navigator 작성·사용
- §7. design_system 사용 — 토큰·컴포넌트·show() 금지

---

## §1. 3단의 정의 — 바인딩 1단 + 표현 2단

presentation_layer의 3단은 크기가 아니라 **VM 보유 / 화면 전속 / 재사용**으로 가른다 (규약 §3.5·§9-10). VM을 watch하는 단은 view 하나뿐이고, section·widget은 VM·provider의 존재를 모르는 순수 표현 조각이다 — humble view를 구조로 보장한다(HaffHaff 실측: view 90%가 Consumer, block 93%·widget 98%가 dumb — 이 암묵 규율의 명문화).

**판별 절차** — 위에서부터 순서대로, 처음 해당하는 것이 답:

| # | 질문 | 답 |
|---|---|---|
| 1 | 자기 상태·로직(VM)이 필요한가? | **view** — 전체 화면이든 임베드 조각이든 삼총사(`_view`·`_vm`·`_state`)로 생성. 버튼 하나여도 동일(HaffHaff 선례: `chat_request_btn_view`+`_vm`) |
| 2 | 한 화면 전속인가 — 그 화면의 State나 맥락을 아는가? | **section** |
| 3 | BC의 도메인(엔티티·어휘)을 아는가? | 예 → **widget** / 아니오 → `design_system/`(BC 밖 — §7) |

- 갈리는 경계의 판별 신호(승격 신호 vs 불필요 VM 양산, "맥락"의 의미)는 공유 reference `undecidable.md`(`${CLAUDE_PLUGIN_ROOT}/skills/discipline-houserules/references/undecidable.md`) §1·§2 소유. 화면이 **어느 BC에 속하는지**(귀속 tie-break)는 `undecidable.md` §3.
- 3단 판별은 위젯 3종에만 적용되고 `ui_extension/`은 판별 밖의 보조 종류다(§5). 파일·클래스 명명 사실은 discipline-houserules §4.

## §2. view 작성 규율 — VM과 1:1 바인딩 루트

view는 VM과 1:1로 바인딩되는 루트다 — `ConsumerWidget`으로 `ref.watch(<화면>VMProvider)` 하고, section·widget·임베드 view를 조립한다 (규약 §3.5).

- **VM watch는 view에서만 허용**되며, view는 **자기 VM(+필요한 같은 BC SharedState)만** watch한다 — 그 외 provider watch 금지. 타 BC view를 임베드할 수는 있다(임베드된 view가 자기 VM을 스스로 watch하므로 배치만으로 충분).
- 조회 실패의 error 빌더 처리·액션 에러의 `ref.listen` 소비 패턴(consumeError)은 architecture-state §4 소유 — view 작성 시 그 정식 예제를 그대로 쓴다.
- TextEditingController·FocusNode 등 UI 컨트롤러는 view가 보유한다 — 값은 VM 메서드 인자로(architecture-state §2).
- VM 없는 정적 view(약관·안내)는 VM·State 없이 허용된다 — 삼총사 대응 검사는 VM 기준이다(사실은 discipline-houserules §4).
- **view body가 직접 반환하는 것은 section·widget·임베드 view 인스턴스의 조립과, error/loading 분기의 표준 컴포넌트(§4·design_system)뿐이다** — view 파일 안에 위젯 클래스를 새로 정의하거나(`_ErrorBody`·`_DetailBody` 류 private 포함) top-level `Widget` 함수로 트리를 빌드하지 않는다. 분기 화면(목록·상세·빈 상태)은 section으로, 재사용 조각은 widget으로 분리한다 — backstop **NM17**이 view 내 추가 위젯 클래스·top-level `Widget` 함수를 기계 차단한다.

## §3. section·widget 작성 규율 — dumb 표현 조각

둘 다 `ref`·provider import 금지 — 데이터는 생성자 prop으로, 행위는 콜백으로 받는다 (규약 §3.5).

| 단 | 받아도 되는 것 | 금지 | 명명 |
|---|---|---|---|
| `section/` — 한 화면 **전속** 구획 | 그 화면의 State·엔티티·콜백 | `ref`·provider | **소속 화면 접두 필수** (`<화면>…_section.dart`) |
| `widget/` — BC 내 **재사용** 부품 | 엔티티·원시값·콜백 | `ref`·provider + **화면 State 받기 금지** | 파일명에 화면 이름 금지 (`<부품>_widget.dart`) |

- section이 화면 State를 받는 것은 정상(전속이니까)이고, widget이 화면 State를 받기 시작하면 section으로 오배치된 것이다(`undecidable.md` §2 신호).
- 접두 규칙의 의미: section의 화면 접두는 "전속"의 선언이고, widget의 화면 이름 금지는 "재사용"의 선언이다 — 이름이 곧 단의 계약을 드러낸다.

## §4. 승격·이동 규칙 — 성장 시 단 이동

성장하면 단을 옮긴다 — 단의 정의를 깨면서 제자리에 머무르지 않는다 (규약 §3.5):

| 신호 | 이동 |
|---|---|
| section이 **두 번째 화면**에서 필요해짐 | 화면 State 의존을 벗겨 **widget으로** |
| section·widget에 자기 상태·로직이 생김 — `ref`가 필요해짐 | **view+vm 쌍으로 승격**(삼총사 생성). section에 ref가 필요해지는 것은 승격 신호이지 예외가 아니다 |
| BC 어휘 없이도 성립하는 순수 시각 부품이 됨 | **`design_system/component/`로** (§7) |

- 반대 방향 절제: prop·콜백만으로 성립하면 view로 승격하지 않는다 — 불필요한 VM 양산 금지(`undecidable.md` §1).
- 타 BC가 section·widget을 직접 import하는 것은 금지 — 부품 재사용은 design_system 승격 경유다(4채널 닫힌 열거는 discipline-houserules §5).

## §5. ui_extension — 도메인→UI 매핑의 유일한 자리

도메인 enum·VO를 UI 값(색·아이콘·라벨)으로 매핑하는 extension의 자리다 (규약 §3.5): 도메인은 flutter 금지·design_system은 BC 어휘 금지라 **여기가 유일한 자리**다.

- extension만 — 위젯·상태 금지. `<개념>_ui_extension.dart` → `extension <개념>UiExtension`.
- 시각 토큰 매핑이 VM·State getter로 새면 이 "유일한 자리" 규칙이 무너진다 — application_layer의 design_system import 금지(사실은 discipline-houserules §5)와 한 몸.
- HaffHaff에는 이 자리가 없어 매핑이 산재했다 — dddart 신설 종류.
- **아이콘 매핑**은 이 extension의 switch다 — 도메인 enum→`IconData`. Flutter 내장 `Icons.*`를 쓴다(HaffHaff 방언 — `material_symbols_icons` 같은 패키지 도입은 방언 이탈). `const` 클래스·별도 enum으로 빼지 않는다(plain extension만 — NM14). 시안이 FILL축을 쓰면 채움(FILL 1)→`Icons.<name>`·윤곽(FILL 0)→가능하면 `Icons.<name>_outlined`.
- **design-tokens.json 소비**(Stitch HTML 동결 시 Coordinator가 `extract_design`로 생성): 아이콘 항목의 `name`=시안의 정확한 Material Symbol·`fill`=채움축·`flutter`=`Icons.*` 후보다. **`flutter`는 채움형 후보**이므로 `fill:0`이면 코더가 `_outlined` 변형을 적용한다 — extract_design은 채움/윤곽을 합치지 않고 `fill`을 별도 필드로 넘기고, 최종 선택은 이 §5 규칙으로 코더·review-ui가 정한다(기계→인간 핸드오프 명시). 후보가 있으면 그대로 쓰고, `unmappedIcons`(Flutter에 정확 대응 부재)는 가장 가까운 `Icons.*`로 매핑한 뒤 design-ref 이미지로 충실도를 확인한다 — 완전 1:1은 방언 한계라 design-review-ui·인간 오라클이 판정한다. 색 매핑도 여기서 `app_color` foundation 토큰으로 한다(생 `Color(0x…)` 금지 §7) — design-tokens.json `colors`의 신규 색은 architect가 foundation 토큰 추가로 결정한다.

## §6. BC 루트 라우팅 짝 — router·navigator 작성·사용

BC 루트의 두 파일이 라우팅을 분업한다 (규약 §3.1 — 위치·명명 사실은 discipline-houserules §1·§4):

| 파일 | 역할 | 규율 |
|---|---|---|
| `<bc>_router.dart` | `GoRoute` 정의를 export — root_router가 조립 | **라우트 path·name 문자열 리터럴은 이 파일 안에서만**. 같은 파일의 `abstract final class <Bc>Routes`(static const)로 묶는다 |
| `<bc>_navigator.dart` | 정적 push 메서드 + 화면 진입 애널리틱스 | **라우트 이름만 참조**(`pushNamed`) — **View import 금지** |

- navigator가 BC 루트(계층 밖)에 있는 이유: presentation에 두면 VM이 호출하는 순간 계층 역류, navigator가 View를 import하면 `VM→navigator→View→VM` import 순환 — BC 루트 + 이름만 참조로 둘 다 해소된다.
- navigator·root_destination_handler는 `<Bc>Routes` 상수만 참조한다. 탭 branch(`StatefulShellBranch`) 조립은 root_router 소유 — BC는 GoRoute만 export한다.
- **정적 push 메서드의 context 수단**: common의 전역 내비게이터 키로 context를 얻어 `pushNamed`한다 — `GoRouter.of(<전역 키>.currentContext!).pushNamed(<Bc>Routes.<name>)` (HaffHaff 실물 관례). 키는 BC 무관 전역 인스턴스로 common 소속이다(discipline-houserules §6) — 덕분에 BuildContext 없는 VM도 navigator를 부를 수 있다(architecture-state §2).
- navigator→router(상수 참조)→view(GoRoute builder)는 **같은 BC 안의 합법 import 사슬**이다 — 순환 래칫(CY)은 BC 간 그래프만 보고, Dart는 라이브러리 순환 import를 허용한다. `<Bc>Routes`를 별도 파일로 빼지 않는다(라우트 리터럴의 단일 출처가 우선 — 사슬을 끊겠다고 상수 파일을 신설하는 것은 표준 이탈).
- VM이 화면 전환할 때 navigator 헬퍼를 부르는 것은 계층 역류가 아니다(architecture-state §2). go_router 표기법은 implementation-flutter §2 소유.
- GoRoute pageBuilder의 전환 효과에는 design_system foundation의 duration 토큰(`AppDuration`)을 쓴다 — router의 design_system import는 이 실전 수요 때문에 허용된 것이다(§7. 허용 위치 닫힌 열거는 discipline-houserules §5).

## §7. design_system 사용 — 토큰·컴포넌트·show() 금지

design_system은 **BC 어휘도 도메인 어휘도 모르는 시각 요소**의 자리다 (규약 §6·§9-12 — 폴더 구조·입장 판별·import 가능 위치의 닫힌 열거 사실은 discipline-houserules §1·§5·§6). BC 코드가 그것을 **쓰는** 규율이 이 절이다:

- **시각 값은 foundation 토큰만**: BC presentation·root scaffold·component에서 `Color(0x…)`·생 `TextStyle(…)` 리터럴 금지 — `app_color`·`app_typography` 등 표준 7토큰이 시각 값의 단일 출처다. 매직 넘버 duration도 동일(`AppDuration` — §6).
- **컴포넌트 표시는 View가 context로 호출한다** — 컴포넌트는 **전역 navigator 키로 스스로를 표시하는 static `show()` 경로를 갖지 않는다** (규약 §6 — §10-5 ① 확정). *왜* — 이 문이 열려 있으면 UseCase·VM의 UI 직행(HaffHaff 실측: App 44개 중 36개가 ErrorDialog 직접 호출)이 재발한다. 에러 다이얼로그도 view의 `ref.listen`에서 context로 띄운다(architecture-state §4 정식 예제의 표시 지점 — `showDialog` 류 호출 표기는 implementation-flutter §6 소유).
- **승격 절차**(§4와 연결): BC 어휘를 벗은 부품은 `component/<부품군>/`으로 — 부품군 폴더=파일 접미사=클래스 접미사, 클래스는 무접두(`ErrorDialog` — 종류 접미사가 구별자). 분류 안 되는 부품이 생기면 정크드로어(`widget/`·`etc/`)가 아니라 새 부품군 폴더를 만든다.
- 도메인 어휘가 필요한 시각 매핑은 design_system이 아니라 그 BC의 ui_extension(§5)이다 — 방향을 헷갈리면 design_system에 BC 어휘가 스민다.
