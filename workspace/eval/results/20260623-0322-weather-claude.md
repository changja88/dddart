# 채점 결과지 — weather 15차 · claude (변종 X)

> **방법** EVAL-METHOD v3.2 · **채점일** 2026-06-23 · **환경** 라이브런=Claude Code(dddart 플러그인·생성 모델 세션 의존)·채점=Opus·effort high · **variant** 단일(양판 비교는 `-compare`) · **산출물 루트** `/Users/hyun/Desktop/dddart-run/dddart-20260623-0058-claude` · **baseline** `abee26d` · **코퍼스** `06a30ff` · **코드젠 도구** build_runner/freezed/json_serializable/retrofit_generator/riverpod_generator(pubspec dev_dependencies 핀·조정자 추가 0) · **task** SCENARIO-WEATHER §1 verbatim · **게이트 답** §4(풀모드·신규 BC weather·가장 간단·날짜 오름차순·6종 ui_extension) · **FC 골든** 사전등록 `FC-GOLDEN-WEATHER.md`(2026-06-14 동결·amend 06-20·코드 미열람 선언) · **N_grader** 3(X-g1·X-g2·X-g3 적대)·**구성 전원 Claude 계열 — 비-Claude 오라클 미확보(⚠️ 독립성 한계)** · **positive control** 통과(`tools/positive-control/` 현행 코퍼스 거짓-FAIL 기계 아님) · **런-정지** 코드 mtime 02:49 < 채점 시작 02:54(진행 중 런 아님) · **⚠️** N=1·인과 단정 금지·앵커=예시(임계값 아님)·소급 FAIL 금지·자기보고 불신(조정자 직접 검증)·시각 충실도: 구조(FID-L1·L2·L3) 측정 / 미관·아이콘 심볼(L4) 비측정(A1)·**FID 게이트 활성**(screenProbes 노출 확인) · **산출물 상태** lib/test/.dddart 일부 `A`(staged 미커밋·라이브런 종료 상태)·채점은 working tree 기준

## 0. 빌드 게이트

| ID | 판정 | 수확 근거 |
|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build` exit 0(51 inputs codegen·wrote 0 outputs=동결) · 후속 `flutter analyze` clean |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` → "No issues found! (ran in 1.3s)" · added 신규 이슈 0 |

> 빌드 게이트 PASS. (치명 게이트로 진행)

## 1. 치명 게이트 (18 + FID-L1·L2 활성 = 20 — 하나라도 ❌이면 픽스처 FAIL)

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 의미 만장일치 PASS — 정렬 불변식이 domain 애그리거트 `weekly_forecast.dart:19-24 WeeklyForecast.fromDays`(`..sort(compareTo)`)·VO `forecast_date.dart:24 compareTo`. VM은 `result.fold`/`map` 변환만. 빈 wrapper 아님 |
| S-DDD | SD-2 | 루트 경유 변경 | ➖ | 조회 전용 기능·전이 변경 메서드 0 → 미발화(N/A·FAIL 아님) |
| S-DDD | SD-7 | UseCase 관문(UI호출 금지) | ✅ | `weather_forecast_use_case.dart` UI(material/presentation) import 0·Either 통과(`map` Right만·Left 보존)·새 throw 0 |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | `weekly_forecast_view.dart:25-35` build=`state.when` 표시 분기+section/navigator 위임만. 정책 0 |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | design_system self-show static 0(grep). `back_app_bar.dart:44 maybePop()`은 view 자기 context |
| S-STATE | ST-1 | VM 책임 경계(직행 금지) | ✅ | VM이 `WeatherForecastUseCase` 인스턴스만(`vm:14`)·Repo/box/SDK/Dio import 0·BuildContext·컨트롤러 0 |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패=build `(error)=>throw error`(BadRequestResponse)→AsyncError(`vm:21`)·view `.when(error:)` 소비. 액션 채널 조회 전용 미발화. **단주의**: detail VM `fromApiString` 무가드(아래 잔여흠) |
| S-STATE | ST-4 | ref 규율(mounted 가드) | ➖ | 조회 build만·await 후 ref 접근 0 → 미발화(N/A) |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | repo `Future<Either<BadRequestResponse,T>>`(`repo:20-27`)·VM `fold` Left가 `throw error`(no-op 아님·전달) |
| S-DATA | DT-2 | 단일 출구·throw 금지 | ✅ | repo/infra throw 0·`safeApiCall`로 Either·**fromJson 가드 `on Object`**(`safe_api_call.dart:18-28`)·인터셉터 정규화 0. 14차 무가드 결함 치유(fix016 적중) |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | 백스톱 ST0·1·2·3 exit 0(58종 blocker 0) |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | 백스톱 IM 역류 ID exit 0 |
| S-HR | HR-5 | 교차 BC 4채널만 | ➖ | 단일 BC weather·교차 import 0 → 미발화(N/A) |
| BUILD | BG-1 | 컴파일 가능 | ✅ | (§0) |
| BUILD | BG-2 | analyze green 래칫 | ✅ | (§0) |
| FC | FC-1 | 골든 오라클 | ✅ | 의미 만장일치 — G-1~G-8 코드 정독 전부 일치(정렬 오름차순·기온 high/low·탭→날짜 일치·6종 distinct·3지표·한글 라벨) |
| FC | FC-2 | 테스트·메커니즘 비-vacuous | ❌ | **조정자 실측: M2(clear→thunderstorm 아이콘 swap) 주입 후 `flutter test` 17/17 green** — 색·아이콘 매핑(`condition_ui_extension.dart:12-49`)을 단언하는 테스트 0건(`.icon`/`.color`/`byIcon` grep 0). M1 정렬·M3 기온·M4 날짜·M5 지표는 red 정상이나 **필수 M2 red율 미달=vacuous FAIL**(적대 X-g3·일반 X-g2 일치) |
| FC | FC-3 | 도메인 정합(negative gate) | ✅ | N1~N7 도메인 오류 0(개수·순서·필드·매핑·기온·날짜·라벨) |

> **치명 FAIL 2건: FC-2(vacuous)·FID-L1(아래 §2.5). lexicographic상 픽스처 전체 FAIL.** ➖ 3건(SD-2·ST-4·HR-5)은 조회 전용·단일 BC 미발화(FAIL 아님).

## 2. 차원별 판정

### A. S-DDD
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | (§1) 정렬 domain 거주·VM 변환만 |
| SD-2 | 루트 경유 변경 | ➖ | 조회 전용·전이 0 |
| SD-3 | 불변식 도메인 예외 검증 | ➖ | 전이 변경 메서드 0. `fromApiString` parseStrict FormatException은 컨버터 parse 경계(SD-3 §30 면제·정상값 미차단) |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `forecast_date.dart` @freezed VO+`compareTo`/`toApiPath` 거주·엔티티 freezed 직파싱 |
| SD-5 | 애그리거트 경계·참조 | ✅ | `WeeklyForecast`(루트)·`DailyForecast`(종속)·`fromDays` 팩토리 |
| SD-6 | 도메인서비스·specification 귀속 | ➖ | 단일 애그리거트·교차 판정 0(폴더 .gitkeep) |
| SD-7 | UseCase 관문 | ✅ | (§1) UI import 0·Either 통과 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/·port/·acl/·dto/·DI 컨테이너 0 |
| SD-9 | 유비쿼터스 언어 철자 | ✅ | `weekly_forecast` 계층 관통 동일 철자·어순(NM3 해소 통일) |

### B. S-VIEW
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | (§1) |
| VW-2 | 3단 판별·과승격 금지 | ✅ | section/widget이 prop·콜백만(ref 0)·view 삼총사 ref 사유 실재 |
| VW-3 | dumb 조각 계약 | ✅ | `weekly_forecast_list_section`·`forecast_tile_widget` ref·provider import 0 |
| VW-4 | 시각 토큰 단일 출처 | ✅ | App* 토큰 참조·생 Color(0x/Colors./TextStyle 0(`Colors.transparent` 구조상수 면제)·VM/State 시각 getter 0 |
| VW-5 | ui_extension 매핑 유일 자리 | ✅ | 의미 만장일치 — enum→UI 매핑이 `condition_ui_extension.dart`에만. 표시용 `formatDate(DateFormat)`은 presentation 거주·매핑 누수 아님(grader 판정) |
| VW-6 | 표시 소유·show() 금지 | ✅ | (§1) |
| VW-7 | 라우트 단일 출처·navigator 분업 | ✅ | path/name 리터럴 `weather_router.dart WeatherRoutes`에만·navigator pushNamed 상수·view import 0·직렬화 VO `toApiPath` 소유 |

### C. S-STATE
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | (§1) UseCase만 |
| ST-2 | 에러 2채널 | ✅ | (§1) 조회 build throw→AsyncError. 액션 미발화 |
| ST-3 | State 형태·노출 계약 | ✅ | `application_layer/state/` @freezed·자기 State 반환·엔티티 필드 래핑. 조회 전용 error 필드 생략 정합 |
| ST-4 | ref 규율 | ➖ | await 후 ref 접근 0 미발화 |
| ST-5 | provider 형태·표기 | ✅ | `class WeeklyForecastVM extends _$…` 클래스형·family(build 인자)·legacy 0 |
| ST-6 | SharedState·교차 BC | ➖ | 단일 BC 미발화 |
| ST-7 | root 합성 구조 | ✅ | root_vm/handler/initializer/rootRouter 규약(백스톱) |
| ST-8 | 비채택(retry OFF·valueOrNull 등) | ✅ | valueOrNull 0·hooks 0·신호버스 0 |
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
| HR-2 | 종류 폴더·접미사 | ✅ | 화이트리스트·지정 접미사(`_vm`·`_repo`·`_shared_state`) |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류 폴더·.gitkeep |
| HR-4 | 계층 import 역류 금지 | ✅ | 백스톱 IM exit 0 |
| HR-5 | 교차 BC 4채널만 | ➖ | 단일 BC 미발화 |
| HR-6 | 파일·클래스 명명 | ✅ | 파일명=클래스·구접미사 0·foundation App 접두 |
| HR-7 | root/common/design_system 경계 | ✅ | common 5폴더·BC 어휘 0·design_system import 화이트리스트 |
| HR-8 | 화면 삼총사·접두 | ✅ | vm↔view↔state 동거·section 화면 접두·widget 화면명 미보유 |
| HR-9 | 개념 1차·종류 2차 성장 | ✅ | 단일 개념 BC 종류 폴더 직속 정상 |

## 2.5 FID 시각 충실도 (구조) — **게이트 활성**(screenProbes 노출·`_support.dart`)

| ID | 항목 | 판정 | 근거(대조 리포트) |
|---|---|---|---|
| FID-L1 | 구조 골격(영역 존재·종류·순서) | ❌ | **양 화면 bottomnav 누락** — screen-detail 시안=[appbar,section,section,**bottomnav**] 코드=[appbar,section,section] · screen-list 시안=[appbar,section,**bottomnav**] 코드=[appbar,section]. `fid-gate.sh` exit 2 |
| FID-L2 | 섹션 구성(평탄화 시퀀스·repeat) | ✅ | detail 섹션#1 `[text,icon,text]`·#2 `[repeat{icon,text}]` 일치·list `[repeat{text,icon,text}]` 일치 |
| FID-L3 | 말단 슬롯(type·width·align) | ⚠ | 약신호 — list 코드에 image 슬롯 추가([image,text,icon,text,text] vs 시안 [text,icon,text])·사용자 눈 |
| FID-L4 | 픽셀·미관(아이콘 심볼) | ➖ | A1 사용자 육안(자동 비측정) |

> **FID-L1 치명 FAIL**(bottomnav 누락·양 화면). 9차 dry-run에 이어 N=2 — 자동 게이트가 14차 육안이 놓친 시안 bottomnav 갭 포착. L2는 PASS(섹션 구성 충실).

## 3. TIER-Q 등급

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | analyze green·lowerCamel/UpperCamel·지역 변수 타입 명시 |
| Q-2 | freezed 표기 | ✅ | 새 리터럴+copyWith·소진 switch |
| Q-3 | dartz Either 표면 | ✅ | Either/Left/Right/fold/map만·fold Left 첫인자 |
| Q-4 | null 안전 관용구 | ✅ | analyze green·`!` 연쇄 0 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey·@JsonValue·unknownEnumValue(Condition.unknown 폴백) |
| Q-6 | catch 위생 | ✅ | safeApiCall on절 구체 타입+catch-all |
| Q-7 | 잔여 구조 스멜 | 🟡 | **죽은 코드** — `AppDuration.press`·`.transition` 토큰 정의했으나 위젯 인용 0(grep)·press 효과 미구현(InkWell 기본) |
| Q-8 | import 정렬·주석 형식 | ✅ | analyze green·구획 정렬 |
| Q-9 | flutter 내비 표기 | ✅ | pushNamed·go 규약 |

> **TIER-Q 등급 = 상** (WEAK 1[Q-7]·FAIL 0). 단 치명 게이트 FAIL이라 등급은 참고치.

## grader 패널 증거 (raw verdict = `-graders-raw.md` 영속)

| grader | 계열 | 적대 | 비고 |
|---|---|---|---|
| X-g1 | Claude | – | 치명 8 PASS(FC-2 항목 **누락**·미판정) |
| X-g2 | Claude | – | **FC-2 FAIL**(M2 seam 부재)·나머지 PASS |
| X-g3 | Claude | ✅ | **FC-2 FAIL**(/tmp M2 주입 17/17 green 실측)·위장변종 8종 무혐의 |

| 차원 | grader 판정(3) | κ | split 방향·비고 |
|---|---|---|---|
| FC-2 | (누락)·❌·❌ | 0.67(2/2 응답 일치) | **치명 FAIL** — 응답한 2명 만장일치 FAIL·조정자 실측 확정 |
| 치명 8(SD-1·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·FC-1·FC-3) | ✅✅✅ | 1.0 | 만장일치 PASS |
| 비치명 15 | ✅/➖ 만장일치 | 1.0 | drift 0 |

> **비-Claude 오라클 미확보** — 의미 레인 전원 Claude 계열(독립성 한계·헤더 ⚠️). FC-2는 조정자 결정 레인 실측(M2 주입→green)으로 의미 판정을 독립 확증.

### rubric 사각 신고 (A13 — 채점 미반영·다음 동결 입력)
| grader | 사각 신고 |
|---|---|
| X-g1 | metrics 습도·강수확률 둘 다 `water_drop` 아이콘 심볼 중복(FID-L4/A1)·windSpeed double raw 표시 |
| X-g2 | G-7 cloudy/overcast 아이콘 *시각적* 구별력은 A1(IconData 심볼 상이만 확인) |
| X-g3 | FC-2 vacuous는 자동 결정 레인만 돌렸다면 17/17 green으로 통과 오판될 뻔(mutation 실행 필수 재확인) |

## 의미적 변종 / 백스톱-blind 메타 (측정의 주 산출물)

| 차원 | 결정 레인 | 의미 레인 | 종합 | 변종 유형 |
|---|---|---|---|---|
| **FC-2** | M1·M3·M4·M5 red / **M2 green(실측)** | M2 매핑 미보호 vacuous | ❌ 치명 | **헛 테스트**(색·아이콘 매핑이 깨져도 red 안 남·`.icon`/`.color` 단언 0) |
| DT-2 | repo throw 0·safeApiCall | fromJson 가드 `on Object` 작동 | ✅ | (14차 무가드 변종 해소) |

## 발견 로그

| # | 단계 | 도구 | 차원 | 내용 | 조기/말기 |
|---|---|---|---|---|---|
| 1 | G2직전 | fid-gate.sh | FID-L1 | bottomnav 양화면 누락(exit 2) | 말기 |
| 2 | G2직전 | grader 실측/조정자 실측 | FC-2 | M2(색·아이콘) seam 테스트 부재·17/17 green=vacuous | 말기 |
| 3 | 정독 | Read | Q-7 | `AppDuration.press`/`transition` 죽은 토큰(정의·미인용) | 말기 |
| 4 | 정독 | Read | ST-2 잔여 | detail VM `fromApiString` 무가드(엣지 route 입력 시 FormatException 채널① 노출 — 정상흐름 미발화) | 말기 |

## 잔여흠 원장 (치명 외 비치명 흠)

| 차원 | 흠 | 심각도 | 근거 |
|---|---|---|---|
| Q-7 | press/transition 토큰 죽은 코드 | 🟡 | `app_duration.dart` 정의·인용 0 |
| ST-2(경계) | detail VM route 파싱 `fromApiString` 무가드 | 단서 | `daily_forecast_detail_vm.dart:22`·codex는 `_parseRouteDate`로 정규화(상대 약점)·정상 흐름 미발화라 치명 아님 |
| FID-L3 | list 코드 image 슬롯 추가 | ⚠ | 사용자 눈 |

## 한 줄 요지

claude 산출물은 **빌드·구조·도메인 규율(치명 14 + 비치명)을 만장일치 PASS**하고 DT-2 fromJson 가드를 fix016대로 치유했으나, **FID-L1(시안 bottomnav 미구현)과 FC-2(색·아이콘 매핑 테스트 부재로 M2 vacuous)의 두 치명 게이트에서 FAIL → 픽스처 전체 FAIL**. TIER-Q는 상(press 죽은 토큰 WEAK 1). *N=1·우열 단정 금지(양판 비교는 `-compare`).*
