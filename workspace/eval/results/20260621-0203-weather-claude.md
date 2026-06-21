# 채점 결과지 — weather(7일 예보) · claude · 12차

> **방법** EVAL-METHOD v3.2 · **채점일** 2026-06-21 · **채점 시작** 20260621-0203 · **환경** 라이브런=사용자 드라이브(Claude Code) / 채점 grader=Claude 계열 · **variant** 단일 · **산출물 루트** `/Users/hyun/Desktop/dddart-run/dddart-20260620-2323-claude` · **baseline** `abee26d` · **코퍼스** `480eb11`(Track B layout 강제·입력 유도 시술 — design-architect area 어휘 트리·architecture-ui AppAsset·dddart 커맨드 layout-ir 배선·12차 검증 대상) · **코드젠 도구 환경** freezed 3.2.6-dev.1·json_serializable·build_runner·retrofit_generator·riverpod_generator(코더 핀·`dart pub get`→`build_runner build` 재생성 0 outputs=손작성 drift 0) · **task** SCENARIO-WEATHER §1(verbatim) · **게이트 답** G0 풀모드(화면2·BC weather)·G1 페이지네이션/캐시/당겨새로고침 미적용·정렬 날짜오름차순·6종 아이콘색라벨=ui_extension·G2 green · **FC 골든** 사전등록 동결(`FC-GOLDEN-WEATHER.md` 2026-06-14 01:13·amend 2026-06-18·2026-06-20) · **N_grader** 3(의미2[lens1 DDD·View·Data / lens2 State·HR·Q]+적대1)·**구성** 전원 Claude 계열 — ⚠️ 비-Claude 오라클 미확보·독립성 한계 · **positive control** 11차(`60a63aa`)에서 통과(`tools/positive-control/` 치명18 PASS)·12차 코퍼스 `480eb11`는 Track B(설계측)만 변경·치명 게이트 정의 불변이라 거짓-FAIL 기계 아님 유효 추정(재검 생략) · **런-정지** 산출물 채점착수전 mtime(claude ~01:04) < 채점 시작(02:03) ✅
>
> ⚠️ N=1·인과 단정 금지·앵커=예시(임계값 아님)·소급 FAIL 금지·자기보고 불신(조정자 직접 검증·FC-2 mutation 실주입) · **시각 충실도**: 이 런은 `screenProbes` 미노출(implementation-test §7 표준 pump 규약 미준수)로 **FID 자동 게이트 미작동→A1 폴백**(L1·L2·L3 ➖·구조 충실도도 사용자 눈 위임·`fid-gate.sh` exit 3·시안 layout-ir는 `design-ref/../ref-layout.json` 보존) / 미관·아이콘 심볼(L4) 비측정(A1). **구조·기능·FID-➖ ≠ 미관 시안 일치.**

## 0. 빌드 게이트

| ID | 판정 | 수확 근거 |
|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build`→exit 0(재생성 일치=손작성 codegen drift 0)·`flutter analyze`→"No issues found! (ran in 1.3s)" |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` exit 0·added 신규 이슈 0 |

## 1. 치명 게이트 (18 — 하나라도 ❌이면 픽스처 FAIL)

> FID-L1·L2는 이 런 `screenProbes` 미노출로 ➖(A1 폴백·치명 집계 제외·§0-6·RUBRIC §H). 따라서 이 런 치명 집계 = 18.
> **결과: FC-2 ❌ → 치명 게이트 FAIL → 픽스처 전체 FAIL**(나머지 17 PASS는 결함 기록용).

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 의미 3/3 PASS — 정렬 정규화가 애그리거트 루트 `weekly_forecast.dart:20-23 WeeklyForecast.fromDays(..sort((a,b)=>a.date.compareTo(b.date)))`. enum→아이콘/색/라벨은 시각변환(VW-5)이라 도메인 판정 아님. VM `weekly_forecast_vm.dart:21-24`·view에 `.sort/compareTo/where` 0·specification import 0·빈 wrapper 아님 |
| S-DDD | SD-2 | 루트 경유 변경 | ✅ | 의미 3/3 PASS — 조회전용·전이 0. Model 밖 copyWith는 전부 `TextStyle.copyWith`(분기·전이 0) |
| S-DDD | SD-7 | UseCase UI호출 금지 | ✅ | `weather_use_case.dart` material/presentation/design_system import 0·무상태 plain·`result.map` Right만·Left 통과(`:17-19`)·새 throw 0 |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | build가 `.when` 표시 분기 + `onTap→WeatherNavigator`·`onRetry→ref.invalidate` 위임만(`weekly_forecast_view.dart:23-55`·`daily_forecast_detail_view.dart:29-130`)·정책 0 |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | design_system 전역키/context self-show static 0·showDialog/ScaffoldMessenger 전역 0(grep)·다이얼로그 미사용(조회전용) |
| S-STATE | ST-1 | VM 책임 경계·직행 금지 | ✅ | VM Model 방향 호출이 `WeatherUseCase()`뿐(`weekly_forecast_vm.dart:20`)·Repo/box/SDK/BuildContext 0(grep) |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패 build() `throw error`(=`BadRequestResponse`)→AsyncError·view `.when` error(`view:33`)·`valueOrNull` 0·액션 채널 조회전용 미발화 |
| S-STATE | ST-4 | ref mounted 가드 | ✅ | 두 VM build()-only async·`await` 뒤 `state =` 접근 0·mounted 발화조건 미충족(거짓 FAIL 금지)·무전제 requireValue 0 |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadRequestResponse,T>>`(`weather_repo.dart:20-28`)·소비처 fold Left `throw error`(상위 전달·no-op 아님)·UseCase `.map` Right만 |
| S-DATA | DT-2 | 단일 출구·safeApiCall | ✅ | Repo throw/rethrow 0·`safeApiCall(()=>_remote..)`·DioException/FormatException/TypeError 개별+catch-all(`safe_api_call.dart:16-47`)·인터셉터 정규화 0 |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | 결정(backstop ST0·1·2·3 exit 0)·`application/weather/{domain,application,infra,presentation}_layer`+BC직속 2파일(router·navigator) |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | 결정(backstop IM1·11·12·17·18·19 exit 0)·domain 순수 Dart·application→presentation 0·infra→상위 0(grep) |
| S-HR | HR-5 | 교차 BC 4채널 | ✅ | 결정(backstop IM5+CY1 exit 0)·단일 BC 교차 import 0·신규 순환 0·채널④ 디코이 미발화 |
| BUILD | BG-1 | 컴파일 가능 | ✅ | (§0) |
| BUILD | BG-2 | analyze green 래칫 | ✅ | (§0) |
| FC | FC-1 | 골든 오라클 | ✅ | 적대 grader G-1~G-8 전수 일치 — 정렬 `weekly_forecast.dart:21-22`·탭↔상세 날짜 round-trip·6종 아이콘 distinct+라벨 정확("구름많음"·"흐림" 등 task 정합)·상세 3지표·기온 슬롯·음수 부호 |
| FC | **FC-2** | **비-vacuous** | **❌** | **결정(조정자 mutation 실주입)** — M1 정렬 역전 → `weekly_forecast_test.dart` red ✅. **M2 condition→아이콘/색 매핑 swap(clear↔thunderstorm 아이콘) → 전체 26 tests "All tests passed!"(green) = vacuous**. `condition_ui_extension_test.dart`는 아이콘 distinct(Set 크기·`:9-13`)·라벨 전수(`:30-36`)만이고 **아이콘/색 *매핑 정확성*(어느 condition→어느 아이콘/색) 단언 부재** → 맑음에 뇌우 아이콘이 떠도 red 0. EVAL §2.5 "필수 red율 100% 미달 = FC-2 FAIL". (M3·M4·M5는 적대 grader 분석상 red 가능하나 M2 vacuous로 이미 필수율 미달) |
| FC | FC-3 | 도메인 정합 | ✅ | 적대 N1~N7 무관측 — 개수 7·오름차순·필드 완비·6종 구별·기온 부호·상세 날짜 일치·한글 라벨 정확 |

> **치명 종합: 17 PASS · 1 FAIL(FC-2) → 픽스처 FAIL.** FC-2는 *코드 결함이 아니라 테스트 비-vacuity 결함* — claude의 아이콘/색 매핑 *코드*는 정확(clear→sunny 등)하나 그 정확성을 검증하는 테스트가 vacuous(회귀 방어 불가). dddart 철학(테스트 약하면 codegen 산출물 신뢰 불가)상 치명.

## 2. 차원별 판정

### A. S-DDD (도메인 충실도)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | (치명) 정렬=루트 팩토리 거주 |
| SD-2 | 루트 경유 변경 | ✅ | (치명) 조회전용·전이 0 |
| SD-3 | 불변식 도메인 예외 | ✅ | 전이 미발화·생성자 정상값 차단 0·parse-throw는 safeApiCall 정규화(SD-3 경계 면제) |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `daily_forecast.dart`·`condition.dart` @freezed+직파싱·@JsonValue 6종+unknown |
| SD-5 | 애그리거트 경계·참조 | ✅ | DailyForecast가 weekly_forecast 종속 엔티티·생성 규칙 `fromDays` 팩토리 |
| SD-6 | 도메인서비스·specification | ➖ | 교차 애그 판정 미발화(단일 애그)·`domain_service/`·`specification/` .gitkeep |
| SD-7 | UseCase 관문 | ✅ | (치명) UI import 0·Either 통과 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/·port/·acl/·dto/·Repo 추상·DI 0·개명 DTO 0 |
| SD-9 | 유비쿼터스 언어 | ✅ | `weekly_forecast`/`daily_forecast`/`condition` 계층 관통 동일 철자 |

### B. S-VIEW (뷰 계층·표현 분리)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | (치명) build 표시·위임만 |
| VW-2 | 3단 판별·과승격 금지 | ✅ | view 삼총사 ref 실재·widget prop/콜백만·`_pressed`는 로컬 UI 애니(ref 아님) |
| VW-3 | dumb 조각 계약 | ✅ | widget/에 riverpod/ref import 0(grep) |
| VW-4 | 시각 토큰 단일 출처 | 🟡 | `forecast_tile_widget.dart:67`·`detail_metric_widget.dart:37` 카드 배경 `color: Colors.white`(토큰 `AppColor` 흰색 있는데 우회·VW-4 FAIL 절 `Colors.*` 명시) — 협소(그 외 색·타이포·duration 전부 토큰·VM/State 시각 getter 0) → WEAK |
| VW-5 | ui_extension 매핑 유일 자리 | ✅ | enum→아이콘/색/라벨이 `*_ui_extension.dart`에만·VM/State/design_system 누수 0 |
| VW-6 | 표시 소유·show() 금지 | ✅ | (치명) self-show static 0 |
| VW-7 | 라우트 단일 출처·navigator 분업 | ✅ | path/name 리터럴 `WeatherRoutes`에만·navigator pushNamed 상수·내비 인자 `date` String 그대로(포맷 변환 0) |

### C. S-STATE (상태·뷰모델)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | (치명) UseCase만·직행 0 |
| ST-2 | 에러 2채널 | ✅ | (치명) 조회 채널 정확·액션 미발화 |
| ST-3 | State 형태·노출 계약 | ✅ | `application_layer/state/` @freezed·자기 State 반환·엔티티 필드 래핑·error 필드 유지 |
| ST-4 | ref 규율(mounted) | ✅ | (치명) 발화조건 미충족·거짓 FAIL 금지 |
| ST-5 | provider 형태·표기 | ✅ | 3 @riverpod 클래스형(`extends _$X`)·family build 인자·legacy/함수형 0 |
| ST-6 | SharedState·교차 BC | ➖ | 단일 BC·전파 없음·타 BC watch 0(발화조건 미충족) |
| ST-7 | root 합성 구조 | ✅ | root_vm 빈 프레임·rootRouter plain·root_initializer 부수효과만 |
| ST-8 | 비채택(retry OFF 등) | ✅ | `main.dart:22 retry:(_,_)=>null`·hooks/copyWithPrevious/valueOrNull/신호버스 0 |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | 각 VM `_$VM`만 extends·base/mixin 0 |

### D. S-DATA (데이터·계약)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | (치명) Left 비폐기 |
| DT-2 | 단일 출구·throw 금지 | ✅ | (치명) safeApiCall |
| DT-3 | BadRequestResponse 계약 | ✅ | `bad_request_response.dart:13-20` **freezed 3필드 errorType/msg/isShow**(@JsonKey error_type·is_show)·어휘 timeout/parse/unknown·클라생성 isShow:true·서버바디 fromJson 보존 — **표준 계약 준수**(codex 대비 차별점) |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | DataSource `Future<List<DailyForecast>>`·dto/Mapper 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | 단일 구체·무상태·직접 생성·DI 0 |
| DT-6 | retrofit DataSource 표기 | ✅ | `@RestApi()` abstract+factory+part·@GET/@Path·엔티티 직반환 |
| DT-7 | hive 로컬 캐시 | ➖ | 로컬 캐시 미도입(네트워크 전용)·@HiveType 0 |
| DT-8 | 계약 스냅샷 운용 | ✅ | 인용 path `/api/v1/weather/`·`/{forecast_date}/` 계약 정합·condition 밖 CR-1 "계약 위험" 표기·unknown 폴백 일치 |
| DT-9 | infra service 수동 어댑터 | ➖ | SDK 어댑터 미도입(네트워크 전용) |

### E. S-HR (하우스룰·구조)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | (치명) backstop ST0~3 |
| HR-2 | 종류 폴더·접미사 | ✅ | view_model→_vm·repository→_repo·state→_state 일치·화이트리스트 내 |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류 폴더 .gitkeep·애그리거트 루트 |
| HR-4 | 계층 import 역류 금지 | ✅ | (치명) backstop IM 역류 0 |
| HR-5 | 교차 BC 4채널 | ✅ | (치명) 단일 BC·순환 0 |
| HR-6 | 파일·클래스 명명 | ✅ | 파일명=클래스 snake_case·구접미사 0·foundation App 접두 |
| HR-7 | root/common/design_system 경계 | ✅ | common BC 어휘 0·@riverpod 0·design_system application import 0 |
| HR-8 | 화면 삼총사·접두 | ✅ | weekly_forecast/daily_forecast_detail 삼총사 동거·widget 화면명 미보유 |
| HR-9 | 개념 1차·종류 2차 성장 | ➖ | 단일 개념·종류 폴더 직속 정상 |

## 4.5 FID 시각 충실도 (구조)

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| FID-L1 | 구조 골격 | ➖ | `screenProbes` 미노출 → 렌더 덤프 불가·A1 폴백(`fid-gate.sh` exit 3). 시안 layout-ir(화면 2·영역 8) → `ref-layout.json` 보존(사용자 눈) |
| FID-L2 | 섹션 구성 | ➖ | 동(A1 폴백) |
| FID-L3 | 말단 슬롯 | ➖ | 동(약신호·A1) |
| FID-L4 | 픽셀·미관 | ➖ | 자동 비측정(A1·사용자 눈) — BrandHeaderWidget이 시안 로고를 `Icons.eco` placeholder로 대체(image area·발견 로그) |

> **Track B 1차 신호(입력 유도)는 ✅ 작동**: design-spec.md §2.2/§2.3에 area 어휘 트리 박힘(`appbar(slots: icon[뒤로], text[flex,center])`·`section(L2: repeat-group: unit[...])`·닫힌 어휘 area/block/slot/width 인용·area 토큰 19회·has_layout_ir=true·layout-ir.json 생성). **출력 게이트(FID 자동 대조)만 screenProbes 미봉합으로 A1 폴백**(코더 규약·Track B 범위 밖).

## 5. TIER-Q 등급

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | SCREAMING_CAPS/헝가리안/공개_ 0·지역변수 타입 명시 |
| Q-2 | freezed 표기 | ✅ | 새 리터럴 합성+copyWith·소진 switch `_` 0 |
| Q-3 | dartz Either 표면 | ✅ | fold/map만·Left 첫인자 |
| Q-4 | null 안전 관용구 | ✅ | promotion·??·패턴 우선·`!` 연쇄 0 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey 서버키·enum @JsonValue+unknownEnumValue |
| Q-6 | catch 위생 | ✅ | safeApiCall 단일출구 면제·on절 구체·빈 catch 0 |
| Q-7 | 잔여 구조 스멜 | 🟡 | 생 치수 매직넘버 3건(`forecast_tile_widget.dart:72 width:72`·`detail_metric_widget.dart:46 size:18`·`daily_forecast_detail_view.dart:71 size:32`)·죽은코드/플래그인자 0 |
| Q-8 | import 정렬·주석 형식 | 🟡 | `daily_forecast_ui_extension.dart:12` 80자 초과 1줄·블록주석 0·import 순서 정상 |
| Q-9 | flutter 내비 표기 | ✅ | pushNamed 상수·plain GoRouter·매직 duration 0 |

> **TIER-Q 등급: 상** (WEAK 2·FAIL 0 — Q-7·Q-8 둘 다 시각 치수/형식 경미). *단 픽스처는 FC-2 치명 FAIL로 사전식 종료 — TIER-Q는 결함 기록용 참고.*

## 5.5 grader 패널 증거 (per-grader·κ·A3/A13)

- **lens1 (DDD·View·Data)**: 치명 7/7 PASS·VW-4 🟡·DT-3 ✅·나머지 ✅/➖. raw: `results/20260621-0203-weather-graders-raw.md`
- **lens2 (State·HR·Q)**: 치명 6/6 PASS·Q-7·Q-8 🟡·나머지 ✅/➖. TIER-Q 상.
- **적대**: 치명 16(BG 제외) 전수 ✅생존·FC-1 G1~G8 ✅·FC-3 무관측·§2.0 필수커버(빈wrapper·채널④·Left no-op·우회self-show·동형버스·함수형provider) 전무.
- **차원별 κ(치명·담당+적대 2명)**: 만장일치 — 단 **적대 grader가 FC-2 M2 vacuity를 "Set 크기"로 보고 PASS 줬으나, 조정자 mutation 실주입(green on swap)이 이를 뒤집음**(EVAL §2.6 자기보고 불신·조정자 직접 검증의 정신·κ 만장일치가 vacuity를 가린 사례 — 5.5 사각 신고로 영속).
- **구성**: 전원 Claude 계열 — ⚠️ 비-Claude 오라클 미확보(독립성 한계).
- **rubric 사각 신고(채점 미산입·다음 동결 입력)**: ① VW-4가 색/타이포/duration만 열거·생 *치수*(icon size/width)는 어느 차원도 미커버(FID-L4=A1) — 시각 치수 토큰화 비대칭. ② **FC-2 M2 seam이 "구별(distinct)"만 검증하고 "매핑 정확성"을 안 보면 vacuous** — RUBRIC FC-2가 distinct≠매핑정확 구분을 명문화하면 적대 grader 놓침 방지(이번 핵심 사각). ③ ST-4 조회전용 vacuous PASS(위반 기회 부재).

## 6. 의미적 변종 / 백스톱-blind 메타

- 백스톱 58종 gated(`--diff-base abee26d`) blocker 0 — HR-1/4/5·NM·IM·ST·CY 결정 닫힘.
- [결정 PASS ∧ 의미 FAIL] 의미 변종: **없음**(치명 17 결정·의미 양레인 일치). FC-2는 결정 레인(mutation 실주입) 단독 FAIL — 의미 grader가 못 보는 *테스트 비-vacuity*를 조정자 결정 레인이 잡은 정상 분업.

## 7. 발견 로그

1. **[치명·FC-2] 아이콘/색 매핑 테스트 vacuous** — `condition_ui_extension_test.dart`가 아이콘 distinct(Set)·라벨 전수만 검증, condition→아이콘/색 *매핑 정확성* 단언 부재. clear↔thunderstorm 아이콘 swap 실주입 시 전체 26 tests green(measure-first). 코드는 정확하나 회귀 방어 불가 → 치명. (codex는 6종 전수 매핑 단언으로 비-vacuous — 대조군.)
2. **[VW-4·🟡] Colors.white 카드 배경 2곳** — `forecast_tile_widget.dart:67`·`detail_metric_widget.dart:37`.
3. **[FID-L4·A1] BrandHeaderWidget 시안 로고 placeholder** — `brand_header_widget.dart` `Icons.eco`+텍스트로 시안 image 영역(로고) 대체. design-spec §103 AppAsset 번들 미적용(Track A 미시술 영역·사용자 눈).
4. **[Q-7·🟡] 생 치수 매직넘버 3건**·**[Q-8·🟡] 1줄 길이**.
5. **[정보] 패키지명 `smaple` 오타** — pubspec name·전 import 일관(`package:smaple/...`)이라 컴파일 정합(BG 무저촉)·미관 흠.

## 8. 잔여흠 원장

- **FC-2 M2 vacuity = 12차 claude 결정 결함** — 테스트 보강(아이콘/색 매핑 전수 expect) 필요. 코퍼스 `implementation-test`/`discipline-test`가 "매핑 검증은 distinct가 아니라 전수 expect"를 명시하는지 점검(다음 fix 후보).
- screenProbes 미노출 = FID 자동 게이트 미발동(Track B 범위 밖·별도 미해결·9차부터 반복).

## 9. 한 줄 요지

**claude 12차** — 규칙 척추 견고(치명 17 PASS·DT-3 표준 freezed 3필드·라벨 정확·SharedState 미신설 단순)·Track B area 트리 입력 유도 ✅. **그러나 FC-2 M2(condition→아이콘/색 매핑) 테스트가 vacuous(distinct·라벨만 검증)로 measure-first 실주입에서 green → 치명 FC-2 FAIL → 픽스처 FAIL.** FID는 screenProbes 미노출로 A1 폴백. *코드는 맞으나 테스트가 매핑 회귀를 못 막는다.*
