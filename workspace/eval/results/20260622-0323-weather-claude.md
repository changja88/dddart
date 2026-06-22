# 채점 결과지 — weather(7일 예보) · claude · 13차

> **방법** EVAL-METHOD v3.2 · **채점일** 2026-06-22 · **채점 시작** 20260622-0323 · **환경** 라이브런=사용자 드라이브(Claude Code·Opus 4.8 xhigh) / 채점 grader=Claude 계열 · **variant** 단일 · **산출물 루트** `/Users/hyun/Desktop/dddart-run/dddart-20260621-2231-claude` · **baseline** `abee26d` · **코퍼스** `8fe3800`(레이아웃 크기연결[design-architect triage 정형목록+architecture-ui §8] + 에셋 공급 파이프라인[fetch_images·manifest SSOT·Image.asset] v4 — 13차 검증 대상) · **HEAD** `7a9b871`(weather 마무리·갭원장 103 files·13596+) · **코드젠 도구 환경** Flutter 3.44.1·freezed·json_serializable·build_runner·retrofit_generator·riverpod_generator·hive_ce(코더 핀·재생성 손작성 drift 0) · **task** SCENARIO-WEATHER §1(verbatim) · **게이트 답** G0 풀모드(화면2·BC weather)·G1 페이지네이션/캐시/당겨새로고침 미적용·정렬 날짜오름차순·6종 아이콘색라벨=ui_extension·G2 green · **FC 골든** 사전등록 동결(`FC-GOLDEN-WEATHER.md` 2026-06-14 01:13·amend 2026-06-18·2026-06-20) · **N_grader** 3(의미2[영역분담 g1 DDD·State / g2 View·Data·HR]+적대1)·**구성** 전원 Claude 계열 — ⚠️ 비-Claude 오라클 미확보·독립성 한계 · **positive control** `tools/positive-control/` 통과(치명18 PASS·기계결함 아님) · **런-정지** 라이브런 정지 mtime 02:25 < 채점 시작 02:27~03:23(채점 중 조정자 build_runner/FC-2 mutation/HEAD 복원으로 mtime 03:25 갱신·코드 내용 HEAD `7a9b871` 원상 검증)
>
> ⚠️ N=1·인과 단정 금지·앵커=예시(임계값 아님)·소급 FAIL 금지·자기보고 불신(조정자 직접 검증·FC-2 mutation 실주입) · **시각 충실도**: 이 런은 `screenProbes` 미노출(implementation-test §7 표준 pump 규약 미준수)로 **FID 자동 게이트 미작동→A1 폴백**(L1·L2·L3 ➖·구조 충실도도 사용자 눈 위임·`fid-gate.sh` exit 3·시안 layout-ir는 `design-ref/../ref-layout.json` 보존) / 미관·아이콘 심볼(L4) 비측정(A1). **구조·기능·FID-➖ ≠ 미관 시안 일치.**

## 0. 빌드 게이트

| ID | 판정 | 수확 근거 |
|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build`→exit 0(재생성 일치=손작성 codegen drift 0)·`flutter analyze`→"No issues found!" |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` exit 0·added 신규 이슈 0 |

## 1. 치명 게이트 (18 — 하나라도 ❌이면 픽스처 FAIL)

> FID-L1·L2는 이 런 `screenProbes` 미노출로 ➖(A1 폴백·치명 집계 제외·§0-6·RUBRIC §H). 이 런 치명 집계 = 18.
> **결과: 18 전부 PASS → 치명 게이트 통과 → 픽스처 PASS.**

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 의미 g1·g3 — 정렬 정규화가 애그리거트 루트 `weekly_forecast.dart:20-24 ..sort((a,b)=>a.date.compareTo(b.date))`. enum→아이콘/색/라벨은 시각변환(VW-5). VM·view에 정렬/판정 0·빈 wrapper 아님 |
| S-DDD | SD-2 | 루트 경유 변경 | ➖ | 조회전용·전이 미발화(Model 밖 copyWith 분기 0) |
| S-DDD | SD-7 | UseCase UI호출 금지 | ✅ | `weather_use_case.dart:1-6` material/presentation import 0·무상태·Either 통과·새 throw 0 |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | build가 `.when` 표시분기 + `_openDetail` 위임만(`weekly_forecast_view.dart:46`)·정책 0 |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | `navigator_key.dart`·`weather_navigator.dart:13` 전역키=내비 전용·self-show static 0 |
| S-STATE | ST-1 | VM 책임 경계·직행 금지 | ✅ | VM Model 방향 호출이 `WeatherUseCase()`뿐(`weekly_forecast_vm.dart:18`)·Repo/box/SDK/BuildContext 0 |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패 build `throw`(=BadRequestResponse)→AsyncError·view `.when` error·valueOrNull 0·액션 채널 미발화 |
| S-STATE | ST-4 | ref mounted 가드 | ➖ | build-only async·`await` 뒤 `state =` 접근 0·발화조건 미충족(거짓 FAIL 금지) |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadReq,T>>`(`weather_repo.dart:20`)·소비처 fold Left `throw`(no-op 아님) |
| S-DATA | DT-2 | 단일 출구·safeApiCall | ✅ | `safe_api_call.dart:28-36` fromJson을 `_normalizeDioException` **try/catch 가드**→`_parseFailure()` 흡수·Repo throw 0·누수 0 |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | 결정(backstop ST0·1·2·3 exit 0)·`application/weather/{domain,application,infra,presentation}_layer`+BC직속 2 |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | 결정(backstop IM 역류 exit 0)·domain 순수 Dart·application→presentation 0 |
| S-HR | HR-5 | 교차 BC 4채널 | ➖ | 단일 BC 교차 import 0·신규 순환 0·채널④ 미발화 |
| BUILD | BG-1 | 컴파일 가능 | ✅ | (§0) |
| BUILD | BG-2 | analyze green 래칫 | ✅ | (§0) |
| FC | FC-1 | 골든 오라클 | ✅ | 적대 grader G-1~G-8 전수 일치 — 정렬·탭↔상세 날짜·6종 아이콘 distinct+라벨 정확·상세 3지표·기온 슬롯·음수 부호 |
| FC | **FC-2** | **비-vacuous** | **✅** | **결정(조정자 mutation 실주입)** — M1 정렬역전→`weekly_forecast_test` red·**M2 매핑 swap(clear↔thunderstorm icon+color)→ui_extension_test red**(매핑 정확성 검증·12차 vacuous 자발 해소)·M3 기온swap→tile_test red·M4 날짜직렬화 고정→forecast_date_test red. 필수 M1~M4 전부 red |
| FC | FC-3 | 도메인 정합 | ✅ | 적대 N1~N7 무관측 — 개수7·오름차순·필드완비·6종 구별·기온부호·상세 날짜·한글 라벨 정확 |

> **치명 종합: 18 PASS → 픽스처 PASS.** 12차 FC-2 M2 vacuous(치명 FAIL)를 13차에 **자발 해소**(미시술·N=1 변동). [결정PASS∧의미FAIL] 변종 0.

## 2. 차원별 판정

### A. S-DDD (도메인 충실도)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | (치명) 정렬=루트 팩토리 거주 |
| SD-2 | 루트 경유 변경 | ➖ | 조회전용·전이 0 |
| SD-3 | 불변식 도메인 예외 | ➖ | 전이 미발화·`daily_forecast.dart:18-26` 직파싱·생성자 검증 0(정상값 유입) |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `forecast_date.dart:9-31` @freezed+toApiPath/fromDate |
| SD-5 | 애그리거트 경계·참조 | ✅ | `weekly_forecast.dart:14-17` DailyForecast 종속·`fromDays` 팩토리·중첩 직파싱 |
| SD-6 | 도메인서비스·specification | ➖ | 교차 애그 판정 미발화·domain_service/specification 부재 |
| SD-7 | UseCase 관문 | ✅ | (치명) UI import 0·Either 통과 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/·port/·acl/·dto/·Repo 추상·DI 0·개명 DTO 0 |
| SD-9 | 유비쿼터스 언어 | ✅ | weekly_forecast/daily_forecast 계층 관통 동일 철자 |

### B. S-VIEW (뷰 계층·표현 분리)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | (치명) build 표시·위임만 |
| VW-2 | 3단 판별·과승격 금지 | ✅ | `weekly_forecast_list_section.dart:13` section prop·widget ref 0 |
| VW-3 | dumb 조각 계약 | ✅ | `forecast_day_tile_widget.dart:1-8` riverpod/ref import 0·prop/콜백 |
| VW-4 | 시각 토큰 단일 출처 | ✅ | `weather_condition_ui_extension.dart:33-45` AppColor·생 Color/TextStyle/Duration 0·VM/State 시각 getter 0 (레이아웃 수치 `size`/`width`는 VW-4 밖) |
| VW-5 | ui_extension 매핑 유일 자리 | ✅ | enum→아이콘/색/라벨이 `*_ui_extension.dart`에만·VM/State/design_system 누수 0 |
| VW-6 | 표시 소유·show() 금지 | ✅ | (치명) self-show static 0 |
| VW-7 | 라우트 단일 출처·navigator 분업 | ✅ | path/name 리터럴 `WeatherRoutes`에만·navigator pushNamed 상수·carrier 직렬화 VO(`forecast_date.dart:18`) |

### C. S-STATE (상태·뷰모델)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | (치명) UseCase만·직행 0 |
| ST-2 | 에러 2채널 | ✅ | (치명) 조회 채널 정확·액션 미발화 |
| ST-3 | State 형태·노출 계약 | ✅ | `weekly_forecast_state.dart:12-15` @freezed·엔티티 래핑·error 필드 의도적 부재(조회전용·설계 정합) |
| ST-4 | ref 규율(mounted) | ➖ | 발화조건 미충족·거짓 FAIL 금지 |
| ST-5 | provider 형태·표기 | ✅ | @riverpod 클래스형(`extends _$X`)·family build 인자·legacy/함수형 0 |
| ST-6 | SharedState·교차 BC | ➖ | 단일 BC·타 BC watch 0 |
| ST-7 | root 합성 구조 | ✅ | root_vm/initializer/router에 weather 도메인 누수 0 |
| ST-8 | 비채택(retry OFF 등) | ✅ | `main.dart` retry OFF·hooks/copyWithPrevious/valueOrNull/신호버스 0(view만 hooks·VM/State 미사용) |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | 각 VM `_$VM`만 extends·base/mixin 0 |

### D. S-DATA (데이터·계약)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | (치명) Left 비폐기 |
| DT-2 | 단일 출구·throw 금지 | ✅ | (치명) safeApiCall·fromJson try/catch 가드 |
| DT-3 | BadRequestResponse 계약 | ✅ | `bad_request_response.dart:13-15` freezed 3필드 errorType/msg/isShow(@JsonKey error_type·is_show)·`safe_api_call.dart:39-48` parse/unknown·클라생성 isShow:true |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | `weather_data_source.dart:17,20` 도메인 엔티티 직반환·dto/Mapper 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | 단일 구체·무상태·직접 생성·DI 0 |
| DT-6 | retrofit DataSource 표기 | ✅ | `@RestApi()` abstract+factory+part·@GET/@Path·엔티티 직반환 |
| DT-7 | hive 로컬 캐시 | ➖ | `weather_hive_adapters.dart:7` 등록 어댑터 0(네트워크 전용) |
| DT-8 | 계약 스냅샷 운용 | ✅ | 인용 path `/api/v1/weather/`·`/{forecast_date}/` 동결본 정합 |
| DT-9 | infra service 수동 어댑터 | ➖ | SDK 어댑터 미도입(네트워크 전용) |

### E. S-HR (하우스룰·구조)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | (치명) backstop ST0~3 |
| HR-2 | 종류 폴더·접미사 | ✅ | view_model→_vm·repository→_repo·state→_state 화이트리스트 내 |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류 폴더·애그리거트 루트 |
| HR-4 | 계층 import 역류 금지 | ✅ | (치명) backstop IM 역류 0 |
| HR-5 | 교차 BC 4채널 | ➖ | 단일 BC·순환 0 |
| HR-6 | 파일·클래스 명명 | ✅ | 파일명=클래스 snake_case·구접미사 0·foundation App 접두 |
| HR-7 | root/common/design_system 경계 | ✅ | common 전역키 BC 어휘 0·design_system application import 0 |
| HR-8 | 화면 삼총사·접두 | ✅ | weekly_forecast/daily_forecast_detail 삼총사 동거·widget 화면명 미보유 |
| HR-9 | 개념 1차·종류 2차 성장 | ✅ | domain `weekly_forecast/` 단일개념 1차·entity/enum/value_object 2차 |

## 4.5 FID 시각 충실도 (구조)

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| FID-L1 | 구조 골격 | ➖ | `screenProbes` 미노출 → 렌더 덤프 불가·A1 폴백(`fid-gate.sh` exit 3)·시안 layout-ir → `ref-layout.json` 보존(사용자 눈) |
| FID-L2 | 섹션 구성 | ➖ | 동(A1 폴백) |
| FID-L3 | 말단 슬롯 | ➖ | 동(약신호·A1) |
| FID-L4 | 픽셀·미관 | ➖ | 자동 비측정(A1·사용자 눈) |

> **13차 시술 1차 신호(육안+grep·design §6 정직격하·FID 자동 아님)**: ① **레이아웃 크기연결 ✅** — design-spec triage 정형목록 11회·hero 상태아이콘 `iconSize=120`(`daily_forecast_detail_hero_section.dart:24,50`·시안 `text-[120px]` 직접인용)=**12차 32px 퇴행 회복**(feedback-014 L 적중). ② **에셋 공급 ✅** — `Image.asset(AppAsset.weatherList1)`(`weekly_forecast_view.dart:52`)→`assets/images/weather-list-1.png` 실재·manifest token=배선 1=1(흘림0)·pubspec 선언·has_design_images true=**12차 "이미지 자리만·다운로드 안함" 해소**(feedback-014 A 적중). **출력 게이트(FID 자동 대조)만 screenProbes 미봉합으로 A1 폴백**(코더측·9차부터 미해결).

## 5. TIER-Q 등급

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | analyze green·SCREAMING_CAPS/헝가리안 0 |
| Q-2 | freezed 표기 | ✅ | @freezed·const _()·part 완비·소진 switch |
| Q-3 | dartz Either 표면 | ✅ | fold/map만·Left 첫인자 |
| Q-4 | null 안전 관용구 | ✅ | promotion·??·requireValue 정상 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey·enum @JsonValue |
| Q-6 | catch 위생 | ✅ | safeApiCall 단일출구 면제·on절 구체 |
| Q-7 | 잔여 구조 스멜 | 🟡 | `AppDuration.transition` 토큰을 router plain builder가 미사용(죽은 토큰)·생 치수 매직넘버 일부 |
| Q-8 | import 정렬·주석 형식 | ✅ | analyze green·import 순서 정상 |
| Q-9 | flutter 내비 표기 | ✅ | go_router name 상수·carrier String·매직 duration 0 |

> **TIER-Q 등급: 상** (WEAK 1·FAIL 0 — Q-7 죽은 토큰/치수 경미). 픽스처 PASS이므로 등급 정상 산정.

## 5.5 grader 패널 증거 (per-grader·κ·A3/A13)

- **g1 (DDD·State)**: SD-1~9·ST-1~9 치명 전부 PASS/➖N/A·줄인용 동반. raw: `results/20260622-0323-weather-graders-raw.md`
- **g2 (View·Data·HR)**: VW-1~7·DT-1~9·HR-1~9 전부 ✅·DT-2 try/catch 가드 확인.
- **적대 g3**: 치명 16(BG 제외) 전수 ✅생존·FC-1 G-1~G-8 ✅·FC-3 무관측·§2.0 필수커버(빈wrapper·채널④·Left no-op·우회self-show·동형버스·함수형provider) 전무·**FC-2 12차 vacuous 해소 확인**·13차 북극성(에셋·hero 120·main 배선) 전항목 충실.
- **차원별 κ**: 치명 만장일치(PASS)·split 0.
- **구성**: 전원 Claude 계열 — ⚠️ 비-Claude 오라클 미확보(독립성 한계·in-family).
- **rubric 사각 신고(채점 미산입·다음 동결 입력)**: ① (g1) claude error 필드 부재=깨끗(codex 빈사필드 대조군)·에러채널 reload-path 도달성 견고(`skipLoadingOnReload`). ② (g2) 레이아웃 수치 리터럴(`size:`/`width:`)이 VW-4(색·타이포만)·FID(구조만) 사이 거주 차원 부재. ③ (g3) Image.asset 배치 화면 area 정합 미측정(token=배선 grep과 별개).

## 6. 의미적 변종 / 백스톱-blind 메타

- 백스톱 58종 gated(`--diff-base abee26d`) blocker 0 — HR-1/4/5·NM·IM·ST·CY 결정 닫힘.
- [결정 PASS ∧ 의미 FAIL] 의미 변종: **없음**. FC-2는 결정 레인(mutation 실주입)으로 비-vacuous 확인(M1~M4 red)·의미 grader ✅와 정합.

## 7. 발견 로그

1. **[FC-2·자발개선] 12차 vacuous→13차 비-vacuous** — `weather_condition_ui_extension_test`가 매핑 정확성을 검증(M2 clear↔thunderstorm swap에 red). feedback-014는 FC-2 미시술이라 N=1 산출 변동(인과 단정 금지·12차 codex 대조군 반대로).
2. **[레이아웃·feedback-014 L 적중] hero 크기 회복** — architect triage 11→coder `iconSize=120`·12차 32px 퇴행 회복.
3. **[에셋·feedback-014 A 적중] 공급 사슬 작동** — 다운로드 ok·Image.asset 배선·token=배선(흘림0)·12차 "이미지 자리만" 해소.
4. **[FID·A1] screenProbes 미노출 지속** — 자동 게이트 미발동(9차부터·코더측 미시술).
5. **[정보] 패키지명 `smaple` 오타** — baseline 유래·전 import 일관·BG 무저촉.

## 8. 잔여흠 원장

- **baseUrl placeholder** — `dio_client.dart:23` `'https://kingdom.example.com'`(실제 kingdom-h.com 아님). test/analyze 무관(mock·green)이나 **런타임 실제 API 호출 미작동**(A1·사용자 `flutter run` 검증). codex(dart-define 주입)와 대조되는 환경 결합 방식차.
- **Q-7 죽은 토큰** — AppDuration `transition` 미사용(router plain builder).
- screenProbes 미노출 = FID 자동 게이트 미발동(코더측·9차부터 반복).

## 9. 한 줄 요지

**claude 13차** — 치명 18 전부 PASS·픽스처 PASS·TIER-Q 상. **12차 FC-2 M2(매핑) vacuous(치명 FAIL)를 13차에 자발 해소**(매핑 정확성 검증). 13차 생성측 북극성 충실 — 에셋 실배선(token=배선)·hero 크기 120 회복·main 배선. 잔여=baseUrl placeholder(런타임 A1). FID는 screenProbes 미노출로 A1 폴백. ⚠️ N=1·in-family.
