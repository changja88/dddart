# 프레젠테이션 아키텍처 — 3단 규율·라우팅 짝·design_system 사용

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
- §8. 크기 연결 — 추출된 크기 토큰을 조각에 잇기

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
- **테스트가 집는 표면은 안정적으로 노출한다 — Key 짝 규약**: discipline-test §3.3/§3.4 FORM이 슬롯을 `find.byKey(const Key('temp-high'))`로 집고 tile을 `tester.widget<ForecastTile>(target).summary`로 읽는다 — 그러므로 *그 위젯을 생성하는 view/section/widget이* ⓐ 구별돼야 하는 슬롯(최고/최저 기온 등)에 **안정 `Key`**(리터럴·`const`·텍스트 내용이 아니라 *역할*을 가리킴)를 부착하고 ⓑ tile은 자신이 받은 도메인 요약(관찰 가능 값)을 **공개 필드로 노출**한다. Key가 없으면 테스트가 텍스트 위치를 추정하다 디코이가 되거나 약화되므로, 슬롯 Key 부착은 view 작성의 일부다(테스트 FORM은 discipline-test 소유).

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

도메인 enum·VO를 UI 값(색·아이콘·라벨)으로 매핑하는 extension의 자리다 (규약 §3.5): 도메인은 flutter 금지·design_system은 BC 어휘 금지라 **여기가 유일한 자리**다. 단 라벨 *텍스트*는 도메인 유비쿼터스 언어다(architecture-ddd §2) — task가 표시 라벨을 열거하면 그 정본 문자열을 verbatim 따르고(왕복 번역·발명·누락 금지), 도메인 enum이 표시명을 소유하면 여기선 인용한다; 이 extension이 신규로 결정하는 시각값은 색·아이콘이다.

- extension만 — 위젯·상태 금지. `<개념>_ui_extension.dart` → `extension <개념>UiExtension`.
- 시각 토큰 매핑이 VM·State getter로 새면 이 "유일한 자리" 규칙이 무너진다 — application_layer의 design_system import 금지(사실은 discipline-houserules §5)와 한 몸.
- HaffHaff에는 이 자리가 없어 매핑이 산재했다 — dddart 신설 종류.
- **아이콘 매핑**은 이 extension의 switch다 — 도메인 enum→`IconData`. Flutter 내장 `Icons.*`를 쓴다(HaffHaff 방언 — `material_symbols_icons` 같은 패키지 도입은 방언 이탈). `const` 클래스·별도 enum으로 빼지 않는다(plain extension만 — NM14). 시안이 FILL축을 쓰면 채움(FILL 1)→`Icons.<name>`·윤곽(FILL 0)→가능하면 `Icons.<name>_outlined`. **글리프 아이콘 vs 정적 래스터 경계**: 폰트 글리프(`IconData`·`Icons.*`)는 이 extension의 switch가 매핑하지만, 로고·일러스트 같은 정적 래스터(PNG 등)는 글리프가 아니라 `AppAsset` const 경로(§7)로 간다 — 둘은 다른 트랙이다(ui_extension은 `IconData` 전용·래스터 경로는 foundation 토큰).
- **design-tokens.json 소비**(디자인 출처 동결 시 Coordinator가 `extract_design`로 생성): 아이콘 항목의 `name`=시안의 정확한 Material Symbol·`fill`=채움축·`flutter`=`Icons.*` 후보다. **`flutter`는 채움형 후보**이므로 `fill:0`이면 코더가 `_outlined` 변형을 적용한다 — extract_design은 채움/윤곽을 합치지 않고 `fill`을 별도 필드로 넘기고, 최종 선택은 이 §5 규칙으로 코더·review-ui가 정한다(기계→인간 핸드오프 명시). 후보가 있으면 그대로 쓰고, `unmappedIcons`(Flutter에 정확 대응 부재)는 가장 가까운 `Icons.*`로 매핑한 뒤 design-ref 이미지로 충실도를 확인한다 — 완전 1:1은 방언 한계라 design-review-ui·인간 오라클이 판정한다. 색 매핑도 여기서 `app_color` foundation 토큰으로 한다(생 `Color(0x…)` 금지 §7) — design-tokens.json `colors`의 신규 색은 architect가 foundation 토큰 추가로 결정한다.

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
- **navigator 정적 push 메서드·GoRoute builder가 넘기는 인자는 String path-param이다** — 도메인 VO를 *인자 타입*으로 받지 않는다. VO를 받으면 navigator/router 파일이 domain을 import해 백스톱 IM21(navigator)·IM22(router) 위반이다. VM이 `vo.toApiPath()`로 String을 만들어 넘기고, 수신 view가 `VO.fromApiPath(String)`로 복원한다(carrier 경계·*왜*는 architecture-ddd §3).
- GoRoute pageBuilder의 전환 효과에는 design_system foundation의 duration 토큰(`AppDuration`)을 쓴다 — router의 design_system import는 이 실전 수요 때문에 허용된 것이다(§7. 허용 위치 닫힌 열거는 discipline-houserules §5).

## §7. design_system 사용 — 토큰·컴포넌트·show() 금지

design_system은 **BC 어휘도 도메인 어휘도 모르는 시각 요소**의 자리다 (규약 §6·§9-12 — 폴더 구조·입장 판별·import 가능 위치의 닫힌 열거 사실은 discipline-houserules §1·§5·§6). BC 코드가 그것을 **쓰는** 규율이 이 절이다:

- **시각 값은 foundation 토큰만**: BC presentation·root scaffold·component에서 `Color(0x…)`·생 `TextStyle(…)` 리터럴 금지 — `app_color`·`app_typography` 등 표준 7토큰이 시각 값의 단일 출처다. 매직 넘버 duration도 동일(`AppDuration` — §6) — 전환·애니메이션·press 등 *상호작용 연출* 시간은 `AppDuration` 토큰이며, 시안에 명시값이 없어 연출 시간을 코더가 정해야 해도 생 `Duration(...)`을 위젯에 직접 박지 않고 토큰에 의미값을 두고 인용한다(발명이 아니라 경유). 단 *비시각* duration(네트워크 timeout·디바운스 등 화면 연출과 무관한 시간)은 이 규율 밖이고(토큰 강제 아님), 구조적 명명 상수(`Colors.transparent` 같은 리플 호스트 배경 등 브랜드 시각값이 아닌 것)도 토큰화 대상이 아니다(무의미 토큰 양산 방지). 크기(`fontSize`·아이콘 size 등)도 눈대중 픽셀 상수가 아니라 `design-tokens.json`이 추출한 값을 인용한다(§8 — `TextStyle`의 `fontSize`는 위 생 `TextStyle` 금지에 이미 포함이다).
- **정적 이미지·아이콘 경로도 foundation 토큰**: 앱 번들 정적 래스터(로고·일러스트·아이콘 PNG 등)의 에셋 경로는 `app_asset`(class `AppAsset`)의 static const에서 온다 — `Image.asset('assets/logo.png')`처럼 raw 경로 문자열을 위젯에 직접 박지 않는다(`Color(0x…)`→`AppColor`와 같은 평행: 경로도 리터럴이 아니라 토큰을 가리킨다). 표준 7토큰의 7번째가 `app_asset`이며 경로 리터럴의 단일 출처다(7토큰 닫힌 열거 자체는 discipline-houserules 소관 — 여기는 *사용 절차*만 정한다). 토큰의 경로 *값*은 공급 파이프라인(`fetch_images`→`asset-manifest.json`→coder가 src 조인→`app_asset.dart`)이 채운다 — 이 절은 *사용*이고 *획득*은 design-architect 명세·implementation-flutter §8 소관이다.
- **컴포넌트 표시는 View가 context로 호출한다** — 컴포넌트는 **전역 navigator 키로 스스로를 표시하는 static `show()` 경로를 갖지 않는다** (규약 §6 — §10-5 ① 확정). *왜* — 이 문이 열려 있으면 UseCase·VM의 UI 직행(HaffHaff 실측: App 44개 중 36개가 ErrorDialog 직접 호출)이 재발한다. 에러 다이얼로그도 view의 `ref.listen`에서 context로 띄운다(architecture-state §4 정식 예제의 표시 지점 — `showDialog` 류 호출 표기는 implementation-flutter §6 소유).
- **승격 절차**(§4와 연결): BC 어휘를 벗은 부품은 `component/<부품군>/`으로 — 부품군 폴더=파일 접미사=클래스 접미사, 클래스는 무접두(`ErrorDialog` — 종류 접미사가 구별자). 분류 안 되는 부품이 생기면 정크드로어(`widget/`·`etc/`)가 아니라 새 부품군 폴더를 만든다.
- 도메인 어휘가 필요한 시각 매핑은 design_system이 아니라 그 BC의 ui_extension(§5)이다 — 방향을 헷갈리면 design_system에 BC 어휘가 스민다.

## §8. 크기 연결 — 추출된 크기 토큰을 조각에 잇기

화면을 3단(§1)으로 분해하는 축은 *상태*다 — 크기가 아니다. 그래서 추출된 시각 크기(아이콘·대형 요소 등)는 묶일 도메인이 없어, 명세에서 각 조각에 직접 잇지 않으면 사라진다. design-architect가 이 연결을 명세에 박고 coder는 그 명세를 집행한다 — 강제는 설계 명세 한 곳에서 닫힌다.

- **표적은 추출 트랙**: `design-tokens.json`의 `arbitraryValues` 등 추출 치수 토큰과 비도메인 `typography` 항목이다. 추출기(extract_design)가 정규화한 치수 토큰을 전수한다 — 특정 형식이나 버킷 이름으로 표적을 좁히지 않는다(미세 간격 `gap-`·`p-`·`m-`은 §7 `app_spacing` 소관이라 추출되지 않는다 — 표적 아님). 도메인에 묶인 typography(본문·강조 텍스트 등)는 ui_extension(§5)·토큰이 이미 담당하니 제외 — 시각 눈대중("큰 요소")이 아니라 *기계 추출된 토큰 목록*을 1건씩 본다. 추출된 *typography* 크기 토큰도 전수 표적이되 그 *적용*은 직접 인용이 아니라 `app_typography` 토큰 정의다(아래 '발명이 아니라 인용').
- **전수·빈칸 0**: 추출 토큰을 빠짐없이 채택(어느 조각의 어느 size/fontSize prop에 연결)/기각(왜 안 씀)한다. 추출 토큰 수만큼 항목이 있어야 한다 — 빈칸을 남기면 coder가 그 크기를 흘린다.
- **발명이 아니라 인용**: 새 픽셀을 눈대중으로 만들지 않는다. *비-typography 크기*(`width`·박스 `height`·아이콘 `size`)는 단일 사용처면 추출값을 size prop에 직접 인용하고, 여러 조각이 공유하면 foundation 토큰으로 승격해 참조한다(공유 시 토큰 승격이 더 규율적이나 직접 인용도 위반은 아니다). *typography 크기*(`TextStyle`의 `fontSize`·`height`(행간)·`letterSpacing`)는 단일 사용처여도 `app_typography` 토큰으로 정의해 참조한다 — 기존 토큰 위에 `copyWith(fontSize: N)`로 덮는 것은 '직접 인용'이 아니다(생 `TextStyle`이 §7 금지이듯, 토큰 위 typography 리터럴도 값의 단일 출처를 우회한다). 7토큰에 크기 전용 토큰은 없다 — typography는 `app_typography`, 그 밖 크기는 직접 인용/`app_spacing` 승격이다. 미세 간격은 §7 `app_spacing`.
- **형상과 직교**: 이 규율은 *절대 크기*만 다룬다. 요소의 *배치·축*은 코퍼스가 규정하지 않는다 — design-ref 시안이 형상 근거이고 coder가 재현한다(implementation-flutter §9). 크기='얼마나 큰가', 형상='어떻게 놓이나' — 둘은 직교하며 후자는 코퍼스 밖(시안)이 소유한다.
