# 채점 결과지 — 20260616-2025-weather-claude

> **방법** EVAL-METHOD v3.1 · **채점일** 2026-06-16 · **환경** claude 파이프라인(설치본 `dddart@dddart-dev` v0.1.1·캐시 feedback-007 재동기 byte-identical) · **variant** 단일(claude) · **산출물 루트** `~/Desktop/dddart-run/dddart-20260616-2025-claude`(HEAD `94e0ea1`·abee26d 대비 93파일 +12593) · **baseline** `abee26d`(순정 민낯·67파일) · **코퍼스** `a8fb2e3`(feedback-006) **+ feedback-007 미커밋 working tree**(배포본=working tree byte-identical 검증) · **코드젠 도구 환경** freezed·json_serializable·riverpod_generator(4.x)·retrofit_generator·build_runner(코더 핀·produced·`.g/.freezed` 커밋) · **task** SCENARIO-WEATHER §1 verbatim · **게이트 답** 페이지네이션·로컬캐시·당겨새로고침 안 함/정렬=날짜 오름차순(서버 순서 유지)/condition 6종 ui_extension · **FC 골든** `tools/FC-GOLDEN-WEATHER.md` 동결 2026-06-14 01:13(코드 미열람·작성자⊥채점자) · **N_grader** 3(n1·n2·adv)·**구성** 전원 동일 계열 — **비-Claude 오라클 0(A3 독립성 미확보)** · **positive control** 통과(2026-06-14) · **런-정지** /tmp 격리 사본 채점·런폴더 불변·산출물 동결 · **외부진실(FC-1)** 실서버 `kingdom-h.com/api/v1/weather/` = 날짜 오름차순 7건(2026-06-16→06-22) 조정자 curl 확인 · **⚠️** N=1·인과 단정 금지·앵커=예시·소급 FAIL 금지·자기보고 불신(조정자 직접 analyze·test·mutation 실행)·**시각/디자인 충실도 비측정(인간 오라클·A1)**
>
> **🟢 feedback-007 연결 진단(프로세스 관측·rubric 비측정)**: **Stitch 연결 경로 첫 발동·성공** — `.dddart/.../design-ref/`에 `designtheme.json`+`screen-list/detail.html/png`+`design.md`+`design-tokens.json` 채워짐 / `config.json` `design_source` 핀(stitch·`projects/2284872291805682410`·updateTime `2026-06-16T09:25:39Z`) / `build-state.json` `has_stitch_html=true`·`has_design_tokens=true` / **Stitch 도구호출 읽기 3회(get_screen×2·list_projects×1)·쓰기 0회**(읽기전용 소프트락 HELD·transcript JSON 파싱). foundation `AppColor` 토큰이 Stitch 색(`secondaryContainer=#FEAE2C`)으로 실유입 = 디자인 시스템 실소비. **단 6런 자체설계와 달리 *제한된 실팔레트*가 FC 색-구별 회귀를 유발(아래 FC-1/FC-3·N=1 동시발생).**

## 0. 빌드 게이트

| ID | 항목 | 판정 | 수확 근거 |
|---|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build` exit 0("Built…wrote 23 outputs"·/tmp 격리 사본·코더 핀 의존)·freezed `abstract … with _$X`+part 완비·valueOrNull 0·`overrideWith2`(riverpod 3.x family override) 실재 컴파일 OK |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` → **"No issues found! (1.4s)"**(added 신규 0)·per-BC `analysis_options.yaml` strict-types 하 green |

> **테스트 실행 실측(FC-2 보조·자기보고 불신)**: `flutter test`(clean 후) = **+36 All tests passed**(exit 0·9 test 파일). 셰이더 `ink_sparkle.frag`(NoSplash)·Timer(Completer+pumpAndSettle) 실패 0 — §7 관용구 유지. 4차 +29 → 5차 +36(테스트 증가).
> **backstop**: `55종(gated diff-base abee26d) — blocker 0건`(exit 0·구조·명명·import·순환 청결).

## 1. 치명 게이트 (17 — 하나라도 ❌이면 FAIL)

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 읽기전용 조회 BC — 도메인 어휘 판정·계산 0건이 정합. VM은 `result.fold`로 Either→State 변환만(`weather_list_vm.dart:22-26`)·spec import 0·빈 wrapper 아님. condition→UI는 ui_extension 거주(SD 아님·VW-5). (3/3 만장일치) |
| S-DDD | SD-2 | 루트 경유 변경 | ➖N/A | 읽기전용·전이 0·Model 밖 copyWith는 `TextStyle.copyWith`(styling)·codegen만 |
| S-DDD | SD-7 | UseCase 관문(UI호출) | ✅ | 무상태·Either 통과·flutter/presentation/design_system import 0·새 throw 0(`weather_use_case.dart:10-24`) |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | build `.when` 6상태 매핑+section/error/loading 위임만(`weather_list_view.dart:32-45`)·isShow는 표시정책 소비(판정 아님) |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | design_system 전역 self-show static 0(grep)·우회명 0·view가 자기 context로 컴포넌트 직반환 |
| S-STATE | ST-1 | VM 책임 경계(직행) | ✅ | VM Model방향 호출 `WeatherUseCase()`뿐·Repo/box/SDK/BuildContext/컨트롤러 0(`weather_list_vm.dart:21`·`weather_detail_vm.dart:20`) |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패 build `throw failure`(BadRequestResponse)→AsyncError(`weather_list_vm.dart:23`)→view `.when(error)`+invalidate 재시도·valueOrNull 0. 액션 채널 N/A(읽기전용·죽은 error 필드 회피=정당) |
| S-STATE | ST-4 | ref 규율(mounted) | ➖N/A | build await 후 state 재접근 없음(fold 결과 즉시 반환)·핸들러 동기 navigator·requireValue 0 |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadRequestResponse,T>>`(`weather_repo.dart:20-26`)·Left를 `throw failure`로 상위 전달(no-op 아님·adv 반증) |
| S-DATA | DT-2 | 단일 출구·throw 금지 | ✅ | safeApiCall 단일출구(`weather_repo.dart:21·26`)·Dio/Format/TypeError+catch-all·Repo throw 0·인터셉터 정규화 0 |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | backstop ST exit 0·`application/weather/` 4계층+직속2(router·navigator) |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | backstop IM exit 0·domain 순수 Dart(freezed/json만)·application→design_system 0 |
| S-HR | HR-5 | 교차 BC 4채널만 | ➖N/A | 단일 신규 BC·타 BC import 0·채널④ 디코이 불성립 |
| BUILD | BG-1 | 컴파일 가능 | ✅ | §0 |
| BUILD | BG-2 | analyze green 래칫 | ✅ | §0·backstop 55종 exit 0 |
| FC | FC-1 | 골든 오라클 | ❌ | **G-7 색 5-distinct**(목록 `listColor` clear=cloudy=`secondaryContainer` `condition_ui_extension.dart:53-68`)·골든 "색 집합 6 distinct" 위반·task "상태마다 …색으로 구분" 위반·design.md cloudy=grey 의도와도 어긋남. **보수 FAIL+인간큐**(adv 줄인용 FAIL·n2 위반신고·n1 변호=아이콘 6-distinct·쌍 구별). G-1~6·G-8 ✅(런타임 서버 오름차순·앱 순서보존·기온 바인딩·탭→상세 날짜·상세3지표·한글라벨) |
| FC | FC-2 | 테스트·메커니즘 비-vacuous | ❌ | **결정레인 mutation 실측: M1(정렬 역전 `.reversed`)·M3(기온 max↔min swap) 둘 다 GREEN=vacuous**(필수 2종). M2(아이콘 swap)·M4(내비 날짜)는 RED. 목록 *순서* 단언 0(`weather_list_view_test.dart` `_sample` 사전정렬·findsN/존재만)·기온 *위치* 단언 0(`textContaining('28°')` findsWidgets — swap해도 `19°/28°` 매칭). 정렬 코드 lib 전역 0(grep) |
| FC | FC-3 | 도메인 정합(negative) | ❌ | **N4 색 공유**(clear=cloudy 동일 `listColor`·`condition_ui_extension.dart:55-58`). **보수 FAIL+인간큐**(adv·n2). N2(순서)는 런타임 서버 오름차순이라 미발현(FC-2 귀속). N1·N3·N5·N6·N7 ✅ |

> **종합 = FC-1·FC-2·FC-3 ❌ → §3 집계 전체 FAIL.** 치명 13 PASS(SD-2·ST-4·HR-5 ➖N/A). **FC-2가 결정적·만장일치 방향(M1·M3 mutation GREEN 실증)**. FC-1/FC-3은 *색 충돌* 보수 FAIL(2:1·n1 PASS·쌍 구별 변호·인간큐). **4차(FC-2 단독 FAIL) 대비 악화** — 신규 원인 = 색 충돌(아래 발견 로그).

## 2. 차원별 판정

### A. S-DDD
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | 읽기전용 판정 0건 정합·VM 변환만(3/3) |
| SD-2 | 루트 경유 변경 | ➖N/A | 읽기전용·전이 0 |
| SD-3 | 불변식 도메인 예외 검증 | ➖N/A | 전이·생성검증 없음·무검증 freezed 직파싱 |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `Weather` @freezed+json 직파싱(`weather.dart:14-27`)·읽기전용이라 도메인 연산 0 정당·value_object 빈 폴더(미사용) |
| SD-5 | 애그리거트 경계·참조 | ✅ | 단일 루트·목록=상세 상위집합 단일 엔티티·평면 직파싱 |
| SD-6 | 도메인서비스·spec 귀속 | ➖N/A | 교차 판정 없음 |
| SD-7 | UseCase 관문 | ✅ | 무상태·Either 통과·UI 0 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/port/acl/dto/추상Repo/DI 0·이름우회 0 |
| SD-9 | 유비쿼터스 언어 | ✅ | weather/condition/forecastDate 계층 관통 동일 철자·enum 식별자=서버값 |

### B. S-VIEW
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | 표시·위임만 |
| VW-2 | 3단 판별·과승격 | ✅ | section/widget ref·VM 0·prop/콜백·view 삼총사 watch 사유 실재 |
| VW-3 | dumb 조각 계약 | ✅ | section/widget에 ref·provider import 0 |
| VW-4 | 시각 토큰 단일출처 | ✅ | App* 토큰(Stitch 유입)·foundation 밖 생 Color/TextStyle/Duration 0·VM/State 시각 getter 0 |
| VW-5 | ui_extension 매핑 유일자리 | ✅ | enum→아이콘/색/라벨 `ConditionUiExtension` 단독·VM/State 누수 0 |
| VW-6 | 표시 소유·show() 금지 | ✅ | 자기표시 static 0 |
| VW-7 | 라우트 단일출처·navigator | ✅ | `WeatherRoutes`만·pushNamed 상수·view import 0·뷰 onTap이 서버원형 String 위임(인라인 직렬화 0) |

### C. S-STATE
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | UseCase 단독·직행 0 |
| ST-2 | 에러 2채널 | ✅ | 조회 build throw→AsyncError·valueOrNull 0·죽은 액션필드 회피 |
| ST-3 | State 형태·노출 | ✅ | application/state @freezed·자기 State·엔티티 필드 래핑 |
| ST-4 | ref 규율 | ➖N/A | await 후 state 접근 없음 |
| ST-5 | provider 형태 | ✅ | `@riverpod class extends _$X` 클래스형·family build 인자·legacy 0 |
| ST-6 | SharedState·교차 BC | ➖N/A | 교차 watch 없음 |
| ST-7 | root 합성 구조 | ✅ | root_router plain 전역·handler 3종 keepAlive·initializer 결과반환 0·root_vm watch 활성화 |
| ST-8 | 비채택(retry OFF 등) | 🟡경미 | 전역 retry OFF 존재하나 `ProviderContainer(retry:…)`+`UncontrolledProviderScope`(`main.dart:14-24`)·RUBRIC 문구 "ProviderScope retry"와 *형태* 차이(기능 동등)·hooks/valueOrNull/copyWithPrevious 0 |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | `_$VM`만 extends·mixin/추출 헬퍼 0 |

### D. S-DATA
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | Repo Future<Either>·Left throw 전달 |
| DT-2 | 단일 출구·throw 금지 | ✅ | safeApiCall 단일출구 |
| DT-3 | BadRequestResponse 계약 | ✅ | 신규 정의·3필드 errorType/msg/isShow(error_type/is_show)·어휘 timeout/parse/unknown·클라 isShow:false·서버바디 보존 |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | DataSource `Weather` 직반환·dto/Mapper 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | 구체 단일·무상태·직접생성·DI 0 |
| DT-6 | retrofit DataSource 표기 | ✅ | @RestApi+factory+part+@GET/@Path·엔티티 직반환 |
| DT-7 | hive 로컬 캐시 | ➖N/A | 캐시 미사용(네트워크 전용) |
| DT-8 | 계약 스냅샷 운용 | ✅ | 엔드포인트 OpenAPI 실재·date↔path/BadReq "계약 위험" 성실 표기·tracer 실증 |
| DT-9 | infra service = 수동 어댑터 | ➖N/A | SDK 어댑터 미사용 |

### E. S-HR
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | 4계층·직속2 |
| HR-2 | 종류 폴더·접미사 | ✅ | 화이트리스트·지정 접미사(_vm·_repo·_state) |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류폴더·.gitkeep(domain_service·spec·VO·entity·service·shared_state)·애그루트 |
| HR-4 | 계층 import 역류 금지 | ✅ | 역류 0 |
| HR-5 | 교차 BC 4채널만 | ➖N/A | 단일 BC |
| HR-6 | 파일·클래스 명명 | ✅ | 파일명=클래스 snake_case·구접미사 0·App 접두·private `_App`(main)은 규칙 무관 |
| HR-7 | root/common/design_system 경계 | ✅ | common BC어휘 0·design_system import 화이트리스트·root import main만 |
| HR-8 | 화면 삼총사·접두 | ✅ | vm↔view↔state 동거·section 화면접두·widget 화면명 미보유 |
| HR-9 | 개념1차·종류2차 | ✅ | 단일개념 직속 |

## 3. TIER-Q 등급 (기록용 — 치명 FAIL로 정식 등급 미산정)

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | analyze green·SCREAMING/헝가리안 0·지역변수 타입 명시(strict 강제) |
| Q-2 | freezed 표기 | ✅ | 소진 switch(condition)·`_` 0·when/map 0(AsyncValue `.when`은 면제) |
| Q-3 | dartz Either 표면 | ✅ | Either/fold만·Left 첫인자 |
| Q-4 | null 안전 관용구 | ✅ | `?.toString() ?? '-'`·`!` 연쇄 0 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey·@JsonValue |
| Q-6 | catch 위생 | ✅ | safeApiCall on절 구체+의도 catch-all(면제) |
| Q-7 | 잔여 구조 스멜 | 🟡경미 | ①습도·강수확률이 둘 다 `Icons.water_drop`(지표 *아이콘* 중복·라벨은 구별) ②아이콘 size 매직넘버(36·120)·카드폭 96(비-시각토큰) |
| Q-8 | import 정렬·주석 | ✅ | dart→package→상대·블록주석 0 |
| Q-9 | flutter 내비 표기 | ✅ | pushNamed·CustomTransition 토큰 duration |

> Q-1~9 PASS 8·경미 WEAK 1(Q-7) — 치명 통과 시 "상" 상당이나 FC 3종 FAIL로 정식 미산정.

## grader 패널 증거 (A3)

| grader | 계열 | 적대 | raw verdict |
|---|---|---|---|
| n1 | Claude | 아니오 | `20260616-2025-weather-graders-raw.md` (n1) |
| n2 | Claude | 아니오 | 〃 (n2) |
| adv | Claude | **예(적대)** | 〃 (adv) |

| 차원 | grader 판정(n1·n2·adv) | κ | split 방향·비고 |
|---|---|---|---|
| FC-2(치명) | ⚠️❌❌ | 방향 일치 | **❌ FAIL** — 결정레인 M1·M3 mutation GREEN(vacuous) 실증. n1도 M1 미커버 인정 |
| FC-1(치명) | ✅🟡❌ | split 2:1 | **보수 FAIL+인간큐** — G-7 색 5-distinct. n1 PASS(쌍 구별)·n2 위반신고·adv 줄인용 FAIL. G-1은 PASS(외부진실 오름차순) |
| FC-3(치명) | ✅🟡❌ | split 2:1 | **보수 FAIL+인간큐** — N4 색 공유. 동일 근거 |
| SD-1·SD-7·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·HR-1·HR-4(치명) | ✅✅✅ | 1.0 | 전원 PASS·인용 동반·adv 디코이 전수 반증 |
| SD-2·ST-4·HR-5(치명) | ➖➖➖ | 1.0 | 읽기전용 단일 BC 미발화 |

> **FC-1/FC-3 2:1 split(n1 PASS)** — per-grader raw·κ 존재(단일저자 위장 아님). **색 충돌은 조정자 미고지였음에도 3명 전원 독립 발견**(blind 건전성 방증). 비-Claude 오라클 0(A3·헤더 ⚠️).

**rubric 사각 신고 (A13 — 채점 미산입·다음 동결 입력)**

| grader | 내용 |
|---|---|
| n1·n2·adv | **G-7 색 distinct 판정단위 모호**("색 집합 6 distinct" vs "(아이콘,색) 쌍 6 distinct") — RUBRIC/golden 미명시(→feedback-008 후보) |
| n2·adv | **design-ref 산문의 명시적 색-의미 규칙 위반(cloudy=grey→구현 orange)이 A1 비측정에 빠짐** — 코드 대조 가능한 규칙을 측정 차원으로 둘지 검토 |
| n1·adv | **"서버 순서 유지" 게이트의 FC-2 비-vacuity 구조적 미닫힘**(4·5차 반복) |

## 의미적 변종 / 백스톱-blind 메타 (측정의 주 산출물)

| 차원 | 결정 레인 | 의미 레인 | 종합 | 변종 유형 |
|---|---|---|---|---|
| FC-2 | M2·M4 RED·테스트 36 green·**M1·M3 GREEN(vacuous)** | 목록 *순서*·기온 *위치* 단언 0 | ❌ 치명 FAIL | 핵심 골든(G-1 순서·G-3/4 위치) vacuous |
| FC-1/FC-3 | 백스톱 0·analyze green(색 토큰은 결정 미커버) | clear=cloudy 동일 색 토큰(5 distinct) | ❌ 보수 FAIL | 골든 G-7/N4 위반(코드상 토큰 동일성·미관 아님) |
| FC-1 G-1 | grep sort 0·서버 오름차순(curl) | 앱 순서보존(런타임 정확) | ✅(G-1) | — (코드 보증 아닌 서버 의존 = FC-2 사각으로 귀속) |

> 백스톱 55종 exit 0(구조 청결)인데 FC 3종 FAIL — **결정 청결 ∧ 기능검증 사각(정렬·기온 위치 미테스트) + 색 구별 회귀**. 색 토큰 동일성은 백스톱·analyze가 안 보는 *의미/FC* 영역.

## 발견 로그

| # | 단계 | 도구 | 차원 | 내용 | 조기/말기 |
|---|---|---|---|---|---|
| 1 | 결정레인 | grep sort/compareTo | FC-1/2 | 정렬 코드 lib 전역 0(4차 동일·서버 의존) | 조기 |
| 2 | 결정레인 | mutation M1(.reversed) | FC-2 | 목록 순서 역전→테스트 GREEN(vacuous 실증) | 말기 |
| 3 | 결정레인 | mutation M3(기온 swap) | FC-2 | max/min swap→GREEN(**4차 RED→5차 회귀**·위치 단언 부재) | 말기 |
| 4 | 결정레인 | mutation M2·M4 | FC-2 | 아이콘 swap·내비 날짜→RED(부분 비-vacuous 실증) | 말기 |
| 5 | 의미레인(3명 독립) | grader 정독 | FC-1/3 | **clear=cloudy=secondaryContainer 색 충돌**(5 distinct·신규 발견) | 말기 |
| 6 | 결정레인 | curl 실서버 | FC-1 | weather 목록 날짜 오름차순 7건(06-16→06-22) | 조기 |
| 7 | 결정레인 | transcript JSON 파싱 | feedback-007 | Stitch 쓰기 0회·읽기 3회(읽기전용 소프트락 HELD) | 조기 |
| 8 | 결정레인 | backstop 55종 | 구조 | exit 0·blocker 0 | 조기 |

## 잔여흠 원장

| 차원 | 흠 | 심각도 | 근거 |
|---|---|---|---|
| FC-2 | 목록 순서(M1)·기온 위치(M3) 단언 부재·정렬 코드 0 | ❌치명 | mutation GREEN 실측·grader 3 |
| FC-1/FC-3 | clear=cloudy 동일 색(목록 5-distinct)·골든 G-7/N4·task "색으로 구분" 위반 | ❌치명(보수·인간큐) | `condition_ui_extension.dart:55-58`·grader adv/n2 |
| (회귀) | M3 기온 위치 4차 RED→5차 GREEN(테스트 구조 변화·widget 인라인·존재만 단언) | 관찰 | 4차 `weather_label_transform_test` vs 5차 부재 |
| (동시발생) | 제한된 Stitch 실팔레트 유입과 색 충돌 동시 관찰(6런 자체설계는 6색 distinct) | 관찰(N=1·인과 단정 금지) | 4차 G-7 PASS vs 5차 G-7 FAIL |
| ST-8 | retry가 ProviderContainer(ProviderScope 아님)·기능 동등 | 🟡경미 | `main.dart:14-24`·n1 |
| Q-7 | 습도·강수확률 동일 아이콘·아이콘 size 매직넘버 | 🟡경미 | n2 |

## 한 줄 요지

**치명 게이트 ❌ FAIL — FC-2(목록 순서 M1·기온 위치 M3 mutation 둘 다 GREEN=vacuous·필수 2종) + FC-1/FC-3(목록 색 clear=cloudy 충돌·5 distinct·보수 FAIL·인간큐).** 그 외 치명 13 전부 PASS(구조·타입·계층·에러 2채널·Either 계약 견실·adv 디코이 전수 반증)·BG green·테스트 +36·backstop 55종 청결. **feedback-007 연결 진단은 5/5 프로세스 관측 성공**(design-ref 채움·design_source 핀·has_design_tokens=true·Stitch 쓰기 0회 = 읽기전용 소프트락 HELD)이나, **연결의 부수효과로 제한된 실팔레트가 색-구별 회귀를 동반**(4차 자체설계 G-7 PASS→5차 G-7 FAIL·N=1 동시발생). 4차(FC-2 단독) 대비 **악화 = FC 3종 + M3 회귀**. (단일 산출물·우열 단정 금지·시각 충실도 비측정)
