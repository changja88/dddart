# 채점 결과지 — weather(7일 예보) · claude · 14차

> **방법** EVAL-METHOD v3.2 · **채점일** 2026-06-22 · **채점 시작** 20260622-1636 · **환경** 라이브런=사용자 드라이브(Claude Code·Opus 4.8) / 채점 grader=Claude 계열 · **variant** 단일 · **산출물 루트** `/Users/hyun/Desktop/dddart-run/dddart-20260622-1341-claude` · **baseline** `abee26d` · **코퍼스** `e49b4fe`(**레이아웃 형상 Stitch SoT 복원** — 형상 어휘[layout-ir/area-tree] 철거·Stitch HTML 시안=형상 단일근거·impl-flutter §9·coder design-ref 승격·architect 분해전담 — **14차 검증 대상**) · **HEAD** `abee26d`(라이브런이 커밋 안 함·작업트리 dirty 114·갭은 `git diff abee26d`=114 files·13077+) · **코드젠 도구 환경** Flutter 3.44.1·freezed·json_serializable·build_runner·retrofit 미사용(plain Dio)·riverpod_generator(코더 핀·재생성 `wrote 0 outputs`=손작성 drift 0) · **task** SCENARIO-WEATHER §1(verbatim) · **게이트 답** G0 풀모드(화면2·BC weather)·G1 페이지네이션/캐시/당겨새로고침 미적용·정렬 날짜오름차순·6종 아이콘색라벨=ui_extension·G2 green · **FC 골든** 사전등록 동결(`FC-GOLDEN-WEATHER.md` 2026-06-14·amend 06-18·06-20) · **N_grader** 3(의미2[g1 DDD·State / g2 View·Data·HR]+적대1)·**구성** 전원 Claude 계열 — ⚠️ 비-Claude 오라클 미확보·독립성 한계 · **positive control** FC-2 mutation red 실증(M1·M2)으로 기계 floor 작동 확인(`tools/positive-control/` 디렉터리 13차 통과 유효) · **런-정지** 라이브런 코드 mtime ≤15:31 < 채점 시작 16:36(채점 중 조정자 build_runner/FC-2 mutation/FID로 mtime 16:35 갱신·핵심 lib 라인 복원 무결 검증·HEAD 코드 원상·+1 dirty=FID 산출 `ref-layout.json` 부산물)
>
> ⚠️ N=1·인과 단정 금지·앵커=예시(임계값 아님)·소급 FAIL 금지·자기보고 불신(조정자 직접 검증·FC-2 mutation 실주입) · **시각 충실도**: 이 런은 `screenProbes` 미노출(implementation-test §7 표준 pump 규약 미준수)로 **FID 자동 게이트 미작동→A1 폴백**(L1·L2·L3 ➖·구조 충실도도 사용자 눈 위임·`fid-gate.sh` exit 3·시안 layout-ir는 `design-ref/../ref-layout.json` 보존) / 미관·아이콘 심볼(L4) 비측정(A1). **★측정 오라클 = 사용자 육안(feedback-015·형상 F)·구조 grep 보조.**

## 0. 빌드 게이트

| ID | 판정 | 수확 근거 |
|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build`→exit 0·"Built with build_runner/aot in 5s; wrote **0 outputs**"(재생성 일치=손작성 codegen drift 0)·`flutter analyze`→"No issues found!" |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` exit 0·added 신규 이슈 0. `flutter clean && flutter test`→**27 tests All passed**(순정·dart-define 무관) |

## 1. 치명 게이트 (18 — 하나라도 ❌이면 픽스처 FAIL)

> FID-L1·L2는 이 런 `screenProbes` 미노출로 ➖(A1 폴백·치명 집계 제외·RUBRIC §H). 이 런 치명 집계 = 18.
> **결과: DT-2 ❌ → 치명 게이트 FAIL → 픽스처 전체 FAIL**(나머지 17 PASS는 결함 기록용). **★13차 PASS에서 회귀**(13차 claude DT-2 가드 PASS·14차 무가드 FAIL — codex와 swap).

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 의미 g1·g3 — 정렬 정규화가 애그리거트 루트 `weekly_forecast.dart:23 ..sort((a,b)=>a.date.compareTo(b.date))`. VM/view/State/ui_extension 새 판정 0(빈혈 wrapper 아님) |
| S-DDD | SD-2 | 루트 경유 변경 | ✅ | Model 밖 copyWith=전부 `TextStyle.copyWith`(표시용)·도메인 갱신 `fromDays` 1곳 |
| S-DDD | SD-7 | UseCase UI호출 금지 | ✅ | `daily_forecast_use_case.dart:12-24` material/presentation import 0·Repo 위임·Either 통과·새 throw 0 |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | build가 `.when` 표시분기 + section 위임만(`weekly_forecast_view.dart:38-48`)·정책 0 |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | claude design_system 컴포넌트 미생성(foundation+theme만)·self-show static 0·전역키 자기표시 0 |
| S-STATE | ST-1 | VM 책임 경계·직행 금지 | ✅ | VM Model 방향 호출이 `DailyForecastUseCase`뿐(`weekly_forecast_vm.dart:17`)·Repo/box/SDK/BuildContext 0 |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패 build `throw BadRequestResponse`(`weekly_forecast_vm.dart:24`)→AsyncError·view `.when` error·valueOrNull 0·액션 채널 미발화 |
| S-STATE | ST-4 | ref mounted 가드 | ✅ | build-only·`fold` 동기 후 즉시 return·`await` 뒤 `state =` 접근 0·위험 패턴 부재 |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadReq,T>>`(`weather_repo.dart:21`)·소비처 fold Left `throw`(no-op 아님) |
| S-DATA | **DT-2** | **단일 출구·safeApiCall** | **❌** | **의미(g2·g3·조정자 정독 3중 합의)** — `safe_api_call.dart:20` `BadRequestResponse.fromJson(data)`가 `on DioException` catch **내부 무가드** 호출. 봉투 3필드 전부 `required`(`bad_request_response.dart:15-17`)→서버 4xx 바디 스키마 불일치(상세 404 = FastAPI `{"detail":...}`=non-null Map→`data is Map` 참→fromJson throw `TypeError`)면 **형제 `on TypeError`(:36)가 못 잡음**(이미 `on DioException` 내부)→**safeApiCall 밖 throw 탈출**(단일출구 누수). **false green**: `weather_repo_test` 404 테스트가 **바디 없이**(data=null) Response 생성→`data is Map` 거짓→위험 경로 미경유. **13차 codex와 동형·[결정PASS∧의미FAIL]** |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | 결정(backstop 58종 gated exit 0)·`application/weather/{domain,application,infra,presentation}_layer`+BC직속 2 |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | 결정(backstop IM 역류 exit 0)·domain 순수 Dart·application→presentation 0 |
| S-HR | HR-5 | 교차 BC 4채널 | ➖ | 단일 BC 교차 import 0·신규 순환 0·채널④ 미발화 |
| BUILD | BG-1 | 컴파일 가능 | ✅ | (§0) |
| BUILD | BG-2 | analyze green 래칫 | ✅ | (§0) |
| FC | FC-1 | 골든 오라클 | ✅ | 적대 g3 G-1~G-8 전수 일치 — 정렬·탭↔상세 날짜·6종 아이콘 distinct(rain=umbrella·precip water_drop 분리)+라벨·상세 3지표·기온 슬롯·음수 부호 |
| FC | FC-2 | 비-vacuous | ✅(부분구멍) | **결정(조정자 mutation 실주입)** — M1 정렬역전→`weekly_forecast_test` red(`+1 -2`)·M2 매핑 swap(sunny→cloud)→`ui_extension_test` red(`+3 -1`). **단 g3 지목 미핀**: G-4 음수기온 fixture 0·목록 타일 기온 슬롯 단언 0(M3 변종 green 탈출 가능)=FC-2 부분 vacuous(소스는 정상·테스트 coverage 구멍) |
| FC | FC-3 | 도메인 정합 | ✅ | 적대 N1~N7 무관측 — 개수7·오름차순·필드완비·6종 구별·기온부호·상세 날짜·한글 라벨 정확 |

> **치명 종합: 17 PASS · 1 FAIL(DT-2) → 픽스처 FAIL.** DT-2는 결정 레인(grep throw 0·safeApiCall 래핑)이 PASS시키나 의미 정독(fromJson 무가드 누수)으로 FAIL — §2.4 Goodhart. **★12·13차 claude PASS에서 14차 회귀**(codex와 DT-2 swap·코퍼스 미규정 N=1 비결정성).

## 2. 차원별 판정

### A. S-DDD (도메인 충실도)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | (치명) 정렬=루트 팩토리 거주 |
| SD-2 | 루트 경유 변경 | ✅ | copyWith=TextStyle 표시용·도메인 갱신 fromDays 1곳 |
| SD-3 | 불변식 도메인 예외 | ➖ | date=raw String 보유(`daily_forecast.dart:16`)·VO 파싱 경계 미발화·정상값 직파싱 |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `weather_detail.dart`·`daily_forecast.dart` @freezed 직파싱(별도 VO 미도입·date=String 설계) |
| SD-5 | 애그리거트 경계·참조 | ✅ | `weekly_forecast.dart` List<DailyForecast> 컬렉션 루트·중첩 직파싱 |
| SD-6 | 도메인서비스·specification | ➖ | 교차 애그 판정 미발화·domain_service/specification 부재 |
| SD-7 | UseCase 관문 | ✅ | (치명) UI import 0·Either 통과 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/·port/·acl/·dto/·Repo 추상·DI 0 |
| SD-9 | 유비쿼터스 언어 | ✅ | weekly_forecast/daily_forecast 계층 관통 동일 철자(codex 대비 우위) |

### B. S-VIEW (뷰 계층·표현 분리)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | (치명) build 표시·위임만 |
| VW-2 | 3단 판별·과승격 금지 | ✅ | section/widget prop·ref 0 |
| VW-3 | dumb 조각 계약 | ✅ | `forecast_day_tile_widget`·`forecast_metric_card_widget` riverpod/ref import 0·prop/콜백 |
| VW-4 | 시각 토큰 단일 출처 | 🟡 | VM/State 시각 getter 0·**그러나** 생 `Duration(milliseconds:200)`(`forecast_day_tile_widget.dart:66`·`forecast_metric_card_widget.dart:41` press) 토큰 밖 2건(비치명·press 미세값·AppDuration는 fadeIn만) |
| VW-5 | ui_extension 매핑 유일 자리 | ✅ | enum→아이콘/색/라벨이 `weather_condition_ui_extension.dart:11-68`에만·VM/State/design_system 누수 0 |
| VW-6 | 표시 소유·show() 금지 | ✅ | (치명) self-show static 0 |
| VW-7 | 라우트 단일 출처·navigator 분업 | ✅ | 리터럴 `WeatherRoutes`에만·navigator pushNamed 상수·view가 context 명시 주입(`pushDetail(context,…)`)·carrier String 직전달 |

### C. S-STATE (상태·뷰모델)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | (치명) UseCase만·직행 0 |
| ST-2 | 에러 2채널 | ✅ | (치명) 조회 채널 정확·액션 미발화 |
| ST-3 | State 형태·노출 계약 | ✅ | `weekly_forecast_state.dart:11` @freezed·엔티티 래핑·error 필드 의도적 부재(조회전용 정합) |
| ST-4 | ref 규율(mounted) | ✅ | (치명) 위험 패턴 부재 |
| ST-5 | provider 형태·표기 | ✅ | @riverpod 클래스형(`extends _$X`)·family build 인자·legacy/함수형 0 |
| ST-6 | SharedState·교차 BC | ➖ | 단일 BC·타 BC watch 0 |
| ST-7 | root 합성 구조 | ✅ | root_router에 weather export 짝만·도메인 누수 0 |
| ST-8 | 비채택(retry OFF 등) | ✅ | valueOrNull/copyWithPrevious/hooks/신호버스 0(VM/State) |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | 각 VM `_$VM`만 extends·base/mixin/consumeError 0 |

### D. S-DATA (데이터·계약)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | (치명) Left 비폐기 |
| DT-2 | 단일 출구·throw 금지 | ❌ | (치명) `safe_api_call.dart:20` fromJson `on DioException` 내부 무가드→4xx 스키마불일치 throw 탈출(§1 근거·g2/g3 합의) |
| DT-3 | BadRequestResponse 계약 | ✅ | `bad_request_response.dart:14-18` freezed 3필드(@JsonKey error_type·is_show)·클라생성 isShow:true |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | `weather_data_source.dart:18-36` 도메인 엔티티 직반환·dto/Mapper 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | 단일 구체·무상태·직접 생성·DI 0 |
| DT-6 | retrofit DataSource 표기 | ➖ | retrofit 미사용·plain Dio class(array→fromDays 래핑 의도) |
| DT-7 | hive 로컬 캐시 | ➖ | 미채택(네트워크 전용) |
| DT-8 | 계약 스냅샷 운용 | ✅ | 인용 path `/api/v1/weather/`·`/{forecast_date}/` 동결본 정합 |
| DT-9 | infra service 수동 어댑터 | ➖ | SDK 어댑터 미도입 |

### E. S-HR (하우스룰·구조)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | (치명) backstop 58종 |
| HR-2 | 종류 폴더·접미사 | ✅ | _vm·_repo·_state·_use_case·_section·_view·_widget 화이트리스트 내 |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류 폴더·애그리거트 루트 |
| HR-4 | 계층 import 역류 금지 | ✅ | (치명) backstop IM 역류 0 |
| HR-5 | 교차 BC 4채널 | ➖ | 단일 BC·순환 0 |
| HR-6 | 파일·클래스 명명 | ✅ | 파일명=클래스 snake_case·구접미사 0·foundation App 접두 |
| HR-7 | root/common/design_system 경계 | ✅ | common/network BC 어휘 0·design_system→application/root import 0 |
| HR-8 | 화면 삼총사·접두 | ✅ | weekly_forecast/forecast_detail 삼총사 동거·widget 화면명 미보유 |
| HR-9 | 개념 1차·종류 2차 성장 | ✅ | domain 개념 2폴더(daily_forecast/weekly_forecast) 분할 |

## 4.5 FID 시각 충실도 (구조)

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| FID-L1 | 구조 골격 | ➖ | `screenProbes` 미노출 → 렌더 덤프 불가·A1 폴백(`fid-gate.sh` exit 3)·시안 layout-ir → `ref-layout.json` 보존(사용자 눈) |
| FID-L2 | 섹션 구성 | ➖ | 동(A1 폴백) |
| FID-L3 | 말단 슬롯 | ➖ | 동(약신호·A1) |
| FID-L4 | 픽셀·미관 | ➖ | 자동 비측정(A1·사용자 눈) |

> **★14차 시술 1차 신호(육안 보조 grep·design §10·feedback-015 F·FID 자동 아님)**: **레이아웃 형상 — 전 컨테이너 시안 일치**(g3 독립 대조 + 조정자 정독 2중 확인). **13차 형상 회귀(축 세로↔가로)가 14차에 전면 회복**:
> | 컨테이너 | 13차(전) | 14차(후) | 시안 | 적중 |
> |---|---|---|---|---|
> | 상세 메트릭 섹션 | `Row(Expanded×3)` 가로 | **`Column` 세로**(`forecast_detail_section.dart:40-60`) | `grid grid-cols-1`(screen-detail.html) | ✅ |
> | 메트릭 카드 헤더 | icon+label 세로스택 | **`Row` 가로**(`forecast_metric_card_widget.dart:52`) | `flex items-center`(detail.html) | ✅ |
> | 상세 hero 기온 | (유지) | **`Row`+baseline 가로**(`:87-91`) | `flex items-baseline` | ✅ |
> | 목록 타일/리스트 | (유지) | Row 3열 / Column(`:40-57`) | items-center / flex-col | ✅ |
>
> **에셋 공급 — 유지(feedback-014 A 회귀 가드 OK)**: `Image.asset(AppAsset.screenList1)`(`weekly_forecast_section.dart:33`)→`assets/images/screen-list-1.png` 실재·manifest token=배선 1=1·status ok·pubspec 선언. **출력 게이트(FID 자동 대조)만 screenProbes 미봉합으로 A1 폴백**(코더측·9차부터 미해결). **bottomnav 미렌더**(시안 `<nav>`·단일 화면 흐름·A1 보조신고).

## 5. TIER-Q 등급

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | analyze green·SCREAMING_CAPS/헝가리안 0 |
| Q-2 | freezed 표기 | ✅ | @freezed·const _()·part 완비·소진 switch |
| Q-3 | dartz Either 표면 | ✅ | fold/map만·Left 첫인자 |
| Q-4 | null 안전 관용구 | ✅ | promotion·??·정상 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey·enum @JsonValue |
| Q-6 | catch 위생 | 🟡 | safeApiCall 다단 catch(단 DT-2 누수=치명·Q아님)·on절 구체 |
| Q-7 | 잔여 구조 스멜 | 🟡 | 생 `Duration(200ms)` press 토큰 밖 2건·생 치수 매직넘버 일부 |
| Q-8 | import 정렬·주석 형식 | ✅ | analyze green |
| Q-9 | flutter 내비 표기 | ✅ | name 상수·carrier String·매직 duration 0(전환) |

> **TIER-Q: 픽스처 DT-2 치명 FAIL로 사전식 종료 — TIER-Q는 결함 기록용 참고**(WEAK 2: Q-6 catch/Q-7 press값).

## 5.5 grader 패널 증거 (per-grader·κ·A3/A13)

- **g1 (DDD·State)**: SD-1~9·ST-1~9 치명 전부 PASS/➖N/A·줄인용 동반. claude 전 PASS(어휘 일관성 우위). raw: `results/20260622-1636-weather-graders-raw.md`
- **g2 (View·Data·HR)**: **DT-2 ❌**(`safe_api_call.dart:20` fromJson 무가드·required 봉투 throw 탈출 실현·줄인용)·VW-4 🟡(생 Duration 2)·그 외 VW/DT/HR 전 ✅/N/A.
- **적대 g3**: **claude DT-2 치명 반증 성공**(코드 경로+false green `weather_repo_test` 404 바디 부재 입증)·FC-1 G-1~G-8 ✅·FC-3 무관측·**형상 6컨테이너 전 시안 일치**·FC-2 vacuity 후보(음수기온·타일 기온 미핀).
- **차원별 κ**: DT-2 만장일치 FAIL(g2·g3·조정자 3중)·나머지 치명 만장일치 PASS·split 0.
- **구성**: 전원 Claude 계열 — ⚠️ 비-Claude 오라클 미확보(독립성 한계·in-family).
- **rubric 사각 신고(채점 미산입·다음 동결 입력)**: ① (g2·g3) DT-2 누수는 `.g.dart` 무가드 `as` 캐스트가 catch 절 내부 2차 throw라 **백스톱 결정 레인 구조적 불가시**(throw 키워드 0)·의미 정독 필수. ② (g1) 화면 prefix↔domain 루트명 drift의 SD-9/HR-6 경계. ③ VW-4 "생 Duration"의 press 미세값 비례성(토큰 가치 사각).

## 6. 의미적 변종 / 백스톱-blind 메타

| 차원 | 결정 레인 | 의미 레인 | 종합 | 변종 유형 |
|---|---|---|---|---|
| **DT-2** | PASS(grep throw 0·safeApiCall 래핑) | **FAIL**(fromJson `on DioException` 내부 무가드·required 봉투 4xx throw 탈출) | **❌치명 FAIL** | 단일출구 누수(정규화기 자신이 throw·§2.4 Goodhart) |

- 백스톱 58종 gated(`--diff-base abee26d`) blocker 0 — HR-1/4/5·NM·IM·ST·CY 결정 닫힘.
- [결정 PASS ∧ 의미 FAIL] = **DT-2**(13차 codex와 동형 변종이 14차 claude에 재현). 의미 grader 정독으로만 포착.

## 7. 발견 로그

1. **[치명·DT-2·★13차 역전] 단일출구 누수 회귀** — `safe_api_call.dart:20` fromJson `on DioException` 내부 무가드(13차 claude `_normalize try/catch 가드`였으나 14차 무가드로 회귀). codex와 정확히 swap(13차 claude PASS·codex FAIL → 14차 claude FAIL·codex PASS). 코퍼스 safeApiCall 골든이 fromJson 가드 미명시→N=1 비결정. false green(repo_test 404 바디 부재).
2. **[형상·★feedback-015 F 적중] 레이아웃 축 전면 회복** — 13차 회귀(메트릭 섹션 세로→가로 등)가 14차에 전 컨테이너 시안 일치(메트릭 섹션 Column·카드 헤더 Row·hero baseline). 14차 코퍼스(형상 Stitch SoT) 시술 검증 신호(★측정=사용자 육안·grep 보조·g3 독립대조 일치).
3. **[에셋·feedback-014 A 유지] 공급 사슬 작동** — Image.asset 배선·token=배선(흘림0)·실파일·12차 회귀 가드 유지.
4. **[FID·A1] screenProbes 미노출 지속** — 자동 게이트 미발동(9차부터·코더측 미시술).
5. **[정보] 패키지명 `smaple` 오타** — baseline 유래·전 import 일관·BG 무저촉.

## 8. 잔여흠 원장

- **DT-2 fromJson 무가드 누수** = 14차 claude 치명 결함(13차 codex와 동형). 코퍼스 `architecture-data`/`implementation-dart` safeApiCall 골든이 "에러바디 파싱도 가드(자기 정규화기 throw 차단)"를 명시해야 양 엔진 swap 종결(다음 fix 1순위·feedback-014/015 예고분).
- **VW-4 생 Duration** — press 200ms 토큰 밖 2건(AppDuration는 fadeIn만).
- **FC-2 부분 vacuous** — 음수기온·목록 타일 기온 슬롯 미핀(테스트 coverage 구멍·소스 정상).
- screenProbes 미노출 = FID 자동 게이트 미발동(코더측·9차부터 반복).

## 9. 한 줄 요지

**claude 14차 = DT-2 치명 FAIL·픽스처 FAIL** — safe_api_call의 fromJson `on DioException` 내부 무가드가 서버 4xx 스키마 불일치 시 safeApiCall 밖 throw 탈출(13차 codex와 동형·**12·13차 PASS에서 회귀·codex와 swap**). **★단 14차 코퍼스 시술 표적인 레이아웃 형상은 전 컨테이너 시안 일치(13차 축 회귀 전면 회복·feedback-015 F 적중·측정=육안)**. 나머지 치명 17 PASS·에셋 유지·테스트 27 green. FID는 screenProbes 미노출로 A1 폴백. ⚠️ N=1·in-family.
