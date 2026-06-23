# 채점 결과지 — weather 16차 · claude (변종 X)

> **방법** EVAL-METHOD v3.2 · **채점일** 2026-06-23 · **환경** 라이브런=Claude Code(dddart 플러그인·생성 모델 세션 의존)·채점=Opus·effort high · **variant** 단일(양판 비교는 `-compare`) · **산출물 루트** `/Users/hyun/Desktop/dddart-run/dddart-20260623-1331-claude` · **baseline** `abee26d` · **코퍼스** `1fc7946`(fix018+019+020) · **코드젠 도구** build_runner/freezed/json_serializable/retrofit_generator/riverpod_generator(pubspec dev_dependencies 핀·조정자 추가 0·`build_runner build` wrote 0 outputs=동결) · **task** SCENARIO-WEATHER §1 verbatim · **게이트 답** §4(풀모드·신규 BC weather·가장 간단·날짜 오름차순·6종 ui_extension) · **FC 골든** 사전등록 `FC-GOLDEN-WEATHER.md`(2026-06-14 동결·amend 06-20·코드 미열람 선언) · **N_grader** 3(X-g1·X-g2·X-g3 적대)·**구성 전원 Claude 계열 — 비-Claude 오라클 미확보(⚠️ 독립성 한계)** · **positive control** 통과(`tools/positive-control/` 현행 코퍼스 거짓-FAIL 기계 아님) · **런-정지** 코드 mtime 15:33 < 채점 시작(진행 중 런 아님) · **⚠️** N=1·인과 단정 금지·앵커=예시(임계값 아님)·소급 FAIL 금지·자기보고 불신(조정자 직접 검증)·시각 충실도: 구조(FID-L1·L2·L3) 측정 / 미관·아이콘 심볼(L4) 비측정(A1)·**FID 게이트 활성이나 이 런은 A1 폴백**(자동 측정 불가 — §2.5·아래 사유) · **산출물 상태** lib/test/.dddart 미커밋(working tree 기준 채점·HEAD=abee26d)·**채점 중 mutation 실측 2건 주입 후 `cp` 원복**(`weekly_forecast.dart`·`weather_condition_ui_extension.dart`·byte-clean 복원 확인)

## 0. 빌드 게이트

| ID | 판정 | 수확 근거 |
|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build` exit 0(`wrote 0 outputs`=codegen 동결·손작성 0) · 후속 `flutter analyze` "No issues found! (ran in 1.0s)" |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` clean · added 신규 이슈 0 |

> 빌드 게이트 PASS. (치명 게이트로 진행)

## 1. 치명 게이트 (18 + FID-L1·L2 — 이 런은 A1 폴백으로 18 집계)

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 의미 만장일치(g1·g2·g3) — 정렬 불변식이 애그리거트 루트 팩토리 `weekly_forecast.dart:19-23 fromDays`(`..sort((a,b)=>a.date.compareTo(b.date))`)·VO `forecast_date.dart:41 compareTo`. VM은 `fold`/`map` 변환만. 빈 wrapper 아님 |
| S-DDD | SD-2 | 루트 경유 변경 | ➖ | 조회 전용·전이 변경 메서드 0 → 미발화(N/A) |
| S-DDD | SD-7 | UseCase 관문(UI호출 금지) | ✅ | `weather_use_case.dart:15` 무상태·UI import 0(dartz+domain+repo)·`map`으로 Either 통과(Left 보존)·새 throw 0·침묵 폐기 0 |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | `daily_forecast_list_view.dart:32` build=`.when` 표시 분기+section/navigator 위임. 정책 0 |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | design_system self-show static 0(g1·g3 grep)·`error_feedback`/`loading_feedback` plain Widget·View가 `.when` 직접 렌더 |
| S-STATE | ST-1 | VM 책임 경계(직행 금지) | ✅ | `daily_forecast_list_vm.dart:21` `WeatherUseCase()`만·Repo/box/SDK/Dio import 0·BuildContext·컨트롤러 0 |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패=build `(failure)=>throw failure`(BadRequestResponse)→AsyncError·view `.when(error:)` 소비. 액션 채널 조회 전용 미발화·valueOrNull 0 |
| S-STATE | ST-4 | ref 규율(mounted 가드) | ➖ | build 단일 await 후 state 접근 0 → 미발화(N/A) |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | repo `Future<Either<BadRequestResponse,T>>`(`weather_repo.dart:22`)·VM `fold` Left→throw(no-op 아님·전달)·UseCase `map` Left 통과 |
| S-DATA | DT-2 | 단일 출구·throw 금지 | ✅ | repo/infra throw 0·`safeApiCall`로 Either·**fromJson 가드 `on Object`**(`safe_api_call.dart:19-29` 중첩 try 정규화기 자체 throw도 Left 수렴)·인터셉터 정규화 0 |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | 백스톱 58종 blocker 0(ST0·1·2·3 exit 0) |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | 백스톱 IM 역류 ID exit 0·domain 순수 Dart |
| S-HR | HR-5 | 교차 BC 4채널만 | ➖ | 단일 BC weather·교차 import 0 → 미발화(N/A) |
| BUILD | BG-1 | 컴파일 가능 | ✅ | (§0) |
| BUILD | BG-2 | analyze green 래칫 | ✅ | (§0) |
| FC | FC-1 | 골든 오라클 | ✅ | 의미 만장일치 — G-1~G-8 일치. **한글 라벨 §0 대응표 정확**(`weather_condition.dart:25-35` clear=맑음·cloudy=구름많음·overcast=흐림·rain=비·snow=눈·thunderstorm=뇌우)·정렬 오름차순·탭→날짜 일치·6종 distinct·3지표 |
| FC | FC-2 | 테스트·메커니즘 비-vacuous | ✅ | **조정자 mutation 실측: M2(clear↔thunderstorm 아이콘 swap)→`weather_condition_ui_extension_test.dart:12` B3 매핑 red**(distinct 3건은 swap이라 green=fix018 §3.6 값핀 정확 표적)·M1(정렬 역전)→`weekly_forecast_test` 2건 red(뒤섞은 입력). M3·M4·M5 골든 두드림(baseline test "탭 날짜 전달 B5"·"상세 상태 B6")+15차 red 실적. **★15차 vacuous FAIL→16차 PASS 역전(fix018 적중)** |
| FC | FC-3 | 도메인 정합(negative gate) | ✅ | N1~N7 도메인 오류 0(개수·순서·필드·매핑·기온·날짜·라벨) |

> **치명 게이트 18 전부 PASS → 픽스처 PASS.** ➖ 3건(SD-2·ST-4·HR-5)은 조회 전용·단일 BC 미발화. **FID-L1·L2는 이 런 A1 폴백**(자동 측정 불가·§2.5)이라 치명 집계 제외(❌ 도장 금지·RUBRIC §H). **★15차 2 치명 FAIL(FC-2·FID-L1)에서 16차 첫 픽스처 PASS로 역전.**

## 2. 차원별 판정

### A. S-DDD
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | (§1) 정렬 domain 거주·VM 변환만 |
| SD-2 | 루트 경유 변경 | ➖ | 조회 전용·전이 0 |
| SD-3 | 불변식 도메인 예외 검증 | ➖ | 전이 메서드 0. `fromApiPath` parse-throw는 컨버터 경계(§SD-3 면제·정상값 미차단·safeApiCall 수렴) |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `forecast_date.dart:11` @freezed VO+`compareTo`/`toApiPath` 거주·엔티티 freezed 직파싱 |
| SD-5 | 애그리거트 경계·참조 | ✅ | `WeeklyForecast`(루트)·`DailyForecast`(종속)·`fromDays` 팩토리 |
| SD-6 | 도메인서비스·specification 귀속 | ➖ | 단일 애그리거트·교차 판정 0(폴더 .gitkeep) |
| SD-7 | UseCase 관문 | ✅ | (§1) UI import 0·Either 통과 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/·port/·acl/·dto/·DI 컨테이너 0(g2 grep) |
| SD-9 | 유비쿼터스 언어 철자 | ✅ | `weekly_forecast`·`forecast_date` 계층 관통 동일 철자·어순 |

### B. S-VIEW
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | (§1) |
| VW-2 | 3단 판별·과승격 금지 | ✅ | section/widget이 prop·콜백만(ref 0)·view 삼총사 ref 사유 실재 |
| VW-3 | dumb 조각 계약 | ✅ | `daily_forecast_list_body_section`·`forecast_tile_widget` ref·provider import 0 |
| VW-4 | 시각 토큰 단일 출처 | 🟡 | 생 Color/Colors./TextStyle 0이나 **`forecast_tile_widget.dart:101` `AppTypography.headlineLgMobile.copyWith(...fontSize: 18)`** — 토큰 위 fontSize 리터럴 오버라이드(시안 `text-[18px]`를 토큰화 안 함·X-g3 적대 적발). 비치명 흠 |
| VW-5 | ui_extension 매핑 유일 자리 | ✅ | enum→UI(icon·color) 매핑이 `weather_condition_ui_extension.dart`에만·VM/State 누수 0. 한글 라벨은 domain enum displayName(올바른 분리) |
| VW-6 | 표시 소유·show() 금지 | ✅ | (§1) |
| VW-7 | 라우트 단일 출처·navigator 분업 | ✅ | path/name 리터럴 `weather_router.dart WeatherRoutes`에만·navigator pushNamed 상수·view import 0·직렬화 VO `toApiPath` 소유(인라인 포맷 0) |

### C. S-STATE
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | (§1) UseCase만 |
| ST-2 | 에러 2채널 | ✅ | (§1) 조회 build throw→AsyncError. 액션 미발화 |
| ST-3 | State 형태·노출 계약 | ✅ | `application_layer/state/` @freezed·자기 State 반환·엔티티 필드 래핑·조회 전용 error 필드 생략 정합 |
| ST-4 | ref 규율 | ➖ | await 후 state 접근 0 미발화 |
| ST-5 | provider 형태·표기 | ✅ | `class …VM extends _$…` 클래스형·family(build 인자)·legacy 0 |
| ST-6 | SharedState·교차 BC | ➖ | 단일 BC 미발화 |
| ST-7 | root 합성 구조 | ✅ | root_vm/handler/initializer/rootRouter 규약(백스톱) |
| ST-8 | 비채택(retry OFF·valueOrNull 등) | ✅ | `main.dart:22` retry OFF·valueOrNull 0·hooks 0·신호버스 0 |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | 각 VM `_$VM`만 extends·공용 mixin 0 |

### D. S-DATA
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | (§1) |
| DT-2 | 단일 출구·throw 금지 | ✅ | (§1) fromJson 가드 `on Object` |
| DT-3 | BadRequestResponse 계약 | ✅ | 3필드 errorType/msg/isShow·어휘 timeout/parse/unknown·클라 생성 isShow:true |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | DataSource `Future<List<DailyForecast>>`·dto/Mapper/Response 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | 인터페이스 없는 단일 구체·직접 생성(DI 0)·무상태 |
| DT-6 | retrofit DataSource 표기 | ✅ | @RestApi abstract+factory+part·@GET·엔티티 반환 |
| DT-7 | hive 로컬 캐시 | ➖ | 로컬 캐시 미사용(게이트 §4) |
| DT-8 | 계약 스냅샷 운용 | ✅ | server-contract 동결본 대조·인용 path 실재 |
| DT-9 | infra service = 수동 어댑터 | ➖ | SDK 어댑터 미사용(네트워크 전용) |

### E. S-HR
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | 백스톱 ST exit 0 |
| HR-2 | 종류 폴더·접미사 | ✅ | 화이트리스트·지정 접미사(`_vm`·`_repo`) |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류 폴더·.gitkeep |
| HR-4 | 계층 import 역류 금지 | ✅ | 백스톱 IM exit 0 |
| HR-5 | 교차 BC 4채널만 | ➖ | 단일 BC 미발화 |
| HR-6 | 파일·클래스 명명 | ✅ | 파일명=클래스·구접미사 0·foundation App 접두 |
| HR-7 | root/common/design_system 경계 | ✅ | common 5폴더·BC 어휘 0·design_system import 화이트리스트 |
| HR-8 | 화면 삼총사·접두 | ✅ | vm↔view↔state 동거·section 화면 접두·widget 화면명 미보유 |
| HR-9 | 개념 1차·종류 2차 성장 | ✅ | 단일 개념 BC 종류 폴더 직속 정상 |

## 2.5 FID 시각 충실도 (구조) — **게이트 활성이나 이 런 A1 폴백**

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| FID-L1 | 구조 골격(영역 존재·종류·순서) | ➖ | **A1 폴백**(자동 측정 불가) — `fid-gate.sh`의 `find _support.dart \| head -1`이 `application_layer/_support.dart`(screenProbes 0)를 알파벳순 선택해 "screenProbes 미노출" 오판(claude는 `presentation_layer/_support.dart`에 정확한 `typedef ScreenProbe=Future<Finder> Function(WidgetTester)` 노출 — **도구 head-1 버그·코더 무죄**). 수동 우회 측정 시도해도 dump_to_ir가 claude 섹션 children 파싱 실패(코드=[])+fid_dump pending timer. **❌ 도장 금지·시안 bottomnav 갭은 X-g3 시안↔코드 수기 대조에서 관찰(아래 사각신고)** |
| FID-L2 | 섹션 구성(평탄화 시퀀스·repeat) | ➖ | A1 폴백(동상) |
| FID-L3 | 말단 슬롯(type·width·align) | ➖ | A1 폴백·약신호 |
| FID-L4 | 픽셀·미관(아이콘 심볼) | ➖ | A1 사용자 육안(자동 비측정) |

> **이 런 FID 자동 게이트 작동 실패 → 치명 집계 제외(18 유지).** 사용자 "FID-L1 bottomnav 무시" 결정(입력 프롬프트로 생성 유도 한계)과 정합 — bottomnav 갭은 ❌ 치명으로 박지 않고 A1·사각신고로 기록. fid-gate 도구 흠(head-1)은 다음 fix 후보.

## 3. TIER-Q 등급

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | analyze green·lowerCamel/UpperCamel·지역 변수 타입 명시 |
| Q-2 | freezed 표기 | ✅ | 새 리터럴+copyWith·소진 switch |
| Q-3 | dartz Either 표면 | ✅ | Either/Left/Right/fold/map만·fold Left 첫인자 |
| Q-4 | null 안전 관용구 | ✅ | analyze green·`!` 연쇄 0 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey·@JsonValue·unknownEnumValue |
| Q-6 | catch 위생 | 🟡 | `main.dart:30` `runZonedGuarded(...,(e,s){})` 빈 에러 핸들러 — uncaught zone 에러 침묵(g3·g2 사각신고·top-level zone guard라 논쟁적이나 빈 catch 위생 흠) |
| Q-7 | 잔여 구조 스멜 | 🟡 | **죽은 코드 2건** — `forecast_date.dart fromDate`(호출 0·`fromApiPath`만 사용)·`app_duration.dart fadeIn`(인용 0·`press`만). **단 press 죽은토큰은 해소**(15차와 달리 `forecast_tile_widget.dart:52 AnimatedScale(scale:_pressed?0.98:1, duration:AppDuration.press)` 실구현·화석 아님·Q-7 press 우려 종결) |
| Q-8 | import 정렬·주석 형식 | ✅ | analyze green·구획 정렬 |
| Q-9 | flutter 내비 표기 | ✅ | pushNamed·go 규약 |

> **TIER-Q 등급 = 상** (WEAK 2[Q-6·Q-7]·FAIL 0). VW-4 🟡은 VW축(차원별 표).

## grader 패널 증거 (raw verdict = `-graders-raw.md` 영속)

| grader | 계열 | 적대 | 비고 |
|---|---|---|---|
| X-g1 | Claude | – | 의미 전 항목 PASS·사각: 목록 행 상태 텍스트 라벨 부재(아이콘만)·아이콘 심볼 중복(rain water_drop=습도 카드) |
| X-g2 | Claude | – | 의미 전 항목 PASS·사각: FID-L1 bottomnav 누락·죽은 토큰 2건·press 효과는 구현 |
| X-g3 | Claude | ✅ | 픽스처 FID-L1만 흠(시안 수기 대조)·**FC-2 vacuous 해소 확증**(mutation 실측 red)·적대 8축 무혐의·VW-4 fontSize:18·Q-6 빈 zone 적발. ⚠️ grader가 결과지 파일 자발 작성(조정자 정본으로 교체·발견 로그) |

| 차원 | grader 판정(3) | κ | split 방향·비고 |
|---|---|---|---|
| 치명 의미 13(SD-1·SD-7·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·FC-1·FC-3 등) | ✅✅✅ | 1.0 | 만장일치 PASS |
| FC-2 | ✅(조정자 실측)·✅·✅ | 1.0 | mutation 실측 red(M1·M2)·만장일치 비-vacuous |
| VW-4 | ✅·✅·🟡(g3) | 0.67 | g3만 fontSize:18 적발(2:1)→비치명 WEAK |
| 비치명 나머지 | ✅/➖ 만장일치 | 1.0 | drift 0 |

> **비-Claude 오라클 미확보** — 의미 레인 전원 Claude 계열(독립성 한계·헤더 ⚠️). FC-2는 조정자 결정 레인 실측(M1·M2 주입→red)으로 의미 판정 독립 확증.

### rubric 사각 신고 (A13 — 채점 미반영·다음 동결 입력)
| grader | 사각 신고 |
|---|---|
| X-g1 | 목록 행 상태가 텍스트 라벨 없이 아이콘+색만(한글 라벨은 상세에만)·rain `water_drop`이 상세 습도 카드 아이콘과 동일 심볼(FID-L4/A1) |
| X-g2 | FID-L1 bottomnav 시안 존재·코드 0(`Scaffold` bottomNavigationBar 없음) — 결정 레인 소관이나 자동 게이트 폴백이라 미포착 |
| X-g3 | `main.dart:30` runZonedGuarded 빈 핸들러는 현 57차원 catch 위생 사각·FID-L1 fid-gate 자동 도구 재실행 권고(수기 대조 한계) |

## 의미적 변종 / 백스톱-blind 메타 (측정의 주 산출물)

| 차원 | 결정 레인 | 의미 레인 | 종합 | 변종 유형 |
|---|---|---|---|---|
| **FC-2** | M1 red·**M2 red**(실측)·M3/M4/M5 골든 두드림 | 매핑 case별 값핀+distinct(§3.6) | ✅ | **15차 vacuous(헛 테스트) 해소** — fix018 §3.6 매핑 정확성 FORM 착지 |
| DT-2 | repo throw 0·safeApiCall | fromJson 가드 `on Object` 작동 | ✅ | (14차 무가드·15차 route 무가드 변종 봉합) |
| VW-4 | grep 생 리터럴 0 | `forecast_tile:101 fontSize:18` copyWith 오버라이드 | 🟡 | 토큰 부분 오버라이드(비치명) |

## 발견 로그

| # | 단계 | 도구 | 차원 | 내용 | 조기/말기 |
|---|---|---|---|---|---|
| 1 | G2직전 | build_runner·analyze | BG-1·2 | wrote 0 outputs·No issues found(green) | 말기 |
| 2 | G2직전 | fid-gate.sh | FID | `find\|head -1`이 application_layer _support 오선택→A1 폴백(도구 head-1 버그·claude 시그니처 정확) | 말기 |
| 3 | G2직전 | 조정자 mutation 실측 | FC-2 | M2 아이콘 swap→매핑 테스트 red(★fix018 vacuous 해소)·M1 정렬 역전→red(뒤섞은 입력) | 말기 |
| 4 | 정독 | grader g3 | VW-4 | `forecast_tile:101 fontSize:18` 토큰 밖 리터럴 | 말기 |
| 5 | 정독 | grader g2·g3 | Q-7 | 죽은 토큰 `fromDate`·`fadeIn`(미사용)·단 press는 구현(해소) | 말기 |
| 6 | 정독 | grader g3 | Q-6 | `main.dart:30` runZonedGuarded 빈 핸들러 | 말기 |
| 7 | 합성 | 조정자 | (메타) | X-g3 적대 grader가 결과지 파일 자발 작성(EVAL §2.0 위반·조정자 정본으로 교체·blind 영향 없음[적대 단독·결정 레인 미수령]) | 말기 |

## 잔여흠 원장 (치명 PASS 후 비치명 흠)

| 차원 | 흠 | 심각도 | 근거 |
|---|---|---|---|
| VW-4 | `forecast_tile:101` fontSize:18 토큰 밖 리터럴(시안 text-[18px] 미토큰화) | 🟡 | copyWith 오버라이드·design-tokens엔 추출됨(arbitraryValues text-[18px]) |
| Q-6 | `main.dart:30` runZonedGuarded 빈 에러 핸들러 | 🟡 | uncaught zone 침묵(논쟁적·top-level) |
| Q-7 | 죽은 토큰 `fromDate`·`fadeIn` | 🟡 | 정의·인용 0 |
| FID-L1 | 시안 bottomnav 양 화면 존재·코드 0(A1·사용자 무시 정책) | ➖A1 | `daily_forecast_list_view.dart` Scaffold bottomNavigationBar 부재(수기 대조·자동 게이트 폴백) |

## 한 줄 요지

claude 산출물은 **치명 게이트 18 전부 PASS → 픽스처 PASS**(15차 FC-2 vacuous·FID-L1 두 FAIL에서 **첫 픽스처 PASS로 역전**). **★fix018 적중** — 15차 헛 테스트(매핑 0)가 §3.6 값핀 FORM 착지로 종결(조정자 M2 swap 주입→매핑 테스트 red 실측). Q-7 press 죽은토큰도 AnimatedScale 실구현으로 해소. 비치명 흠 VW-4(fontSize:18)·Q-6(빈 zone)·Q-7(죽은 토큰 2건)으로 TIER-Q 상. FID는 도구 head-1 버그로 A1 폴백(bottomnav 갭은 사용자 무시 정책·A1). *N=1·우열 단정 금지(양판 비교는 `-compare`).*
