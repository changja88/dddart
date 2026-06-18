# 채점 결과지 — 20260618-1610-weather-claude

> **방법** EVAL-METHOD v3.2 · **채점일** 2026-06-18(시작 ~13:12 백스톱·완료 16:10) · **variant** 단일(claude 엔진) · **산출물 루트** `~/Desktop/dddart-run/dddart-20260618-1312-claude`(HEAD `abee26d`·산출물 **staged 미커밋**·lib 48·test 8) · **baseline** `abee26d`(순정 민낯·changeset 92파일 +12755/-187) · **코퍼스(산출)** `a27c357`(feedback-009)·repo HEAD `299fd09` · **채점 골든** `f3f2b3e`(FC-GOLDEN-WEATHER A13-1 정합 amend 2026-06-18 12:48) · **환경** Dart 3.12.1·Flutter 3.44.1 · **코드젠** freezed·json_serializable·riverpod_generator·retrofit_generator·build_runner(코더 핀·produced) · **task** SCENARIO-WEATHER §1 verbatim · **게이트답** 페이지네이션·로컬캐시·당겨새로고침 안 함 / **정렬=날짜 오름차순(앱 책임·서버순서 의존 금지·A13-1)** / condition 6종 ui_extension · **FC 골든** 동결 2026-06-14 01:13 + amend 2026-06-18 12:48(코드 미열람·작성자⊥채점자) · **N_grader** 3(n1·n2·adv)·**전원 Claude — 비-Claude 오라클 0(A3 독립성 미확보)** · **positive control** 2026-06-14 검증 + feedback-009 MD 백스톱 반증 인용(거짓-FAIL 기계 아님) · **런-정지** 산출물 staged·소스 mtime은 채점 중 조정자 FC-2 mutation(M1·M4) 주입·복원 반영·`git diff` empty 확인(산출물 내용 무변) · **⚠️** N=1·인과 단정 금지·앵커=예시·소급 FAIL 금지·자기보고 불신(조정자 직접 backstop·analyze·test·M1/M4 실행)·**시각/디자인 충실도 비측정(인간 오라클·A1)**

## 0. 빌드 게이트

| ID | 항목 | 판정 | 근거(조정자 직접 실행) |
|---|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build` exit 0(json/freezed/retrofit/riverpod codegen 성공)·`valueOrNull`·3.10+ dot-shorthand 0(grep·Dart 3.12지만 ^3.9 상한 내) |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` → **"No issues found! (0.9s)"**(added 신규 0) |

> **결정 레인 실측**: `backstop.dart --diff-base abee26d` = **57종·blocker 0·exit 0**. `flutter clean && flutter test` = **+23 All passed**(8 test 파일·내 단일 실행 기준). *단 병렬 실행 시 flaky*(§6 발견 1).

## 1. 치명 게이트 (17 — 하나라도 ❌이면 픽스처 FAIL)

| 축 | ID | 항목 | 종합 | 근거(레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | **정렬 판정이 애그리거트 루트 거주** `forecast.dart:24-28`(`sortedByDateAscending()` `..sort(a.date.compareTo(b.date))`·새 인스턴스 반환), VM은 `.days` 추출·적재만 `forecast_list_vm.dart:26-28`. 빈 wrapper 아님(M1 red 실증). condition→UI는 ui_extension 거주(VW-5) |
| S-DDD | SD-2 | 루트 경유 변경 | ➖N/A | 읽기전용·전이 0·Model 밖 copyWith=TextStyle만 |
| S-DDD | SD-7 | UseCase 관문(UI호출) | ✅ | `forecast_use_case.dart` 무상태 plain·Either 통과(`:19-28`)·flutter/presentation import 0·새 throw 0·직접생성(`:14`) |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | build `.when` 분기·section 조립만 `forecast_list_view.dart:23-41`·정책 0 |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | ErrorFeedback/LoadingFeedback 수동 위젯·전역 self-show static 0(`error_feedback.dart:7-8` 주석 명시)·navigator pushNamed |
| S-STATE | ST-1 | VM 책임 경계(직행) | ✅ | VM Model방향 호출 UseCase뿐 `forecast_list_vm.dart:21-22`·`forecast_detail_vm.dart:19-20`·Repo/box/SDK/BuildContext 0(backstop IM7/12 clean) |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패 build `throw error`(BadRequestResponse)→AsyncError `forecast_list_vm.dart:23`→view `.when(error)`. **액션 채널 의도적 부재**(`forecast_list_state.dart:13-14` 死분기 회피 명시·읽기전용 정당)·`valueOrNull` 0 |
| S-STATE | ST-4 | ref 규율(mounted) | ➖N/A | build await 후 state 재접근 0(fold 즉시 반환)·`requireValue` 0 |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadRequestResponse,T>>` `weather_repo.dart:28,39`·Left를 `throw error`로 상위 전달(no-op 아님) |
| S-DATA | DT-2 | 단일 출구·throw 금지 | ✅ | safeApiCall 단일출구 `weather_repo.dart:30,43`·Dio/Format/TypeError+catch-all `safe_api_call.dart:18-44`·수기 throw 0·인터셉터 없음 |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | backstop ST0-3 exit 0·`application/weather/` 4계층+직속2 |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | backstop IM 역류 exit 0·domain 순수·presentation→infra 0 |
| S-HR | HR-5 | 교차 BC 4채널만 | ➖N/A | 단일 신규 BC·타 BC import 0 |
| BUILD | BG-1 | 컴파일 가능 | ✅ | §0 |
| BUILD | BG-2 | analyze green 래칫 | ✅ | §0·backstop 57종 exit 0 |
| FC | FC-1 | 골든 오라클 | 🟡 **G-7 인간 큐** | G-1~G-6·G-8 일치. **G-7 아이콘 5 distinct**(cloudy=overcast=`Icons.cloud` `weather_condition_ui_extension.dart:21,23`)·색은 6 distinct(`app_color.dart:69-75`). 골든 "아이콘 6 distinct ∧ 색 6 distinct" 문언 미충족이나 **A1(아이콘 심볼=비측정) 경계** → 인간 오라클 큐(조정자 권장 A=미충족) |
| FC | FC-2 | 테스트·메커니즘 비-vacuous | ❌ **FAIL** | **M4(navigator 날짜)=green-on-mutation**(조정자 직접: `weather_navigator.dart:22` `_dateFormat.format(date)`→`+1일`로 변이해도 **+8 All passed**) → G-5(탭→상세 날짜 일치)의 **navigator 직렬화 구간을 두드리는 테스트 부재**(탭 section 콜백·router 파싱까지만). 정본 사이트(탭 핸들러·route 파라미터 전달부) 중 navigator 직렬화 死검증. M1(정렬)=red ✅·M3(기온)·M5(지표)=red·M2(색쌍)=red·**M2b(아이콘only)=green**(테스트가 (아이콘,색)쌍만 단언). 필수 M4 미충족 → FC-2 FAIL |
| FC | FC-3 | 도메인 정합(negative) | 🟡 **N4** | N1~N3·N5~N7 오류 0. **N4 부분 저촉**: cloudy↔overcast 아이콘 공유(`ui_extension:21,23`)가 N4 문언("같은 아이콘 공유·특히 cloudy↔overcast")에 해당. 단 색 구별로 화면 6종 식별은 성립(G-7 인간 큐 연동) |

> **종합 = FC-2 ❌ → §3 집계 픽스처 FAIL.** 치명 14 PASS(SD-2·ST-4·HR-5 ➖N/A) + **FC-2 단독 FAIL** + FC-1 G-7 인간 큐 + FC-3 N4. **6차(M1 정렬 死+vacuous FAIL) 대비 M1 해소**(정렬 애그리거트 거주·뒤섞은 입력 테스트로 M1 red)되었으나 **navigator 직렬화(M4)·아이콘 distinct(G-7) 신쟁점**으로 전환.

## 2. 차원별 판정 (57차원 전수)

### A. S-DDD
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | `forecast.dart:24-28`(정렬 애그리거트 거주) |
| SD-2 | 루트 경유 변경 | ➖N/A | 읽기전용·전이 부재 |
| SD-3 | 불변식 도메인 예외 검증 | ➖N/A | VO 빈 골격(`value_object/.gitkeep`)·생성 검증 없음 |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `daily_forecast.dart:12-23`·`forecast_detail.dart:12-26` @freezed+직파싱 |
| SD-5 | 애그리거트 경계·참조 | ✅ | `Forecast` 루트가 `List<DailyForecast>` 보유(`forecast.dart:16-18`) |
| SD-6 | 도메인서비스·spec 귀속 | ➖N/A | 교차 애그 판정 미발화(단일 애그) |
| SD-7 | UseCase 관문 | ✅ | (치명표) |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/port/acl/dto·Repo추상·DI 0 |
| SD-9 | 유비쿼터스 언어 | ✅ | `forecast`·`WeatherCondition` 계층 관통 동일 철자 |

### B. S-VIEW
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | (치명표) |
| VW-2 | 3단 판별·과승격 | ✅ | view만 ref(`forecast_list_view.dart:19,25`)·section/widget prop+콜백·`_pressed`는 시각 지역 State |
| VW-3 | dumb 조각 계약 | ✅ | section/widget ref·provider import 0(backstop IM8/9 clean) |
| VW-4 | 시각 토큰 단일 출처 | ✅ | 생 Color/TextStyle 리터럴 foundation 밖 0·VM/State 시각 getter 0 |
| VW-5 | ui_extension 매핑 유일 자리 | ✅ | enum→아이콘/색/라벨이 `weather_condition_ui_extension.dart`에만·metric 고정아이콘은 section 상수(정당) |
| VW-6 | 표시 소유·show() 금지 | ✅ | (치명표) |
| VW-7 | 라우트 단일 출처·navigator 분업 | ✅ | 리터럴 `WeatherRoutes`에만(`weather_router.dart:9-27`)·navigator pushNamed 상수·view import 0·뷰 onTap 인라인 직렬화 없음(VM/navigator 위임) |

### C. S-STATE
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | (치명표) |
| ST-2 | 에러 2채널 | ✅ | (치명표) |
| ST-3 | State 형태·노출 계약 | ✅ | `application_layer/state/` @freezed·자기 State 반환·엔티티 필드 래핑 |
| ST-4 | ref 규율 | ✅ | (치명표·미발화 자리) |
| ST-5 | provider 형태·표기 | ✅ | 두 VM 클래스형 `class extends _$X`·family build 인자·legacy 0 |
| ST-6 | SharedState·교차 BC | ➖N/A | 단일 BC·전파 미발생 |
| ST-7 | root 합성 구조 | ➖N/A | 탭 셸 없음·rootRouter plain 전역·root_vm/handler 미발화 |
| ST-8 | 비채택(retry OFF 등) | 🟡 **WEAK** | **main.dart ProviderScope `retry:(_,__)=>null` 부재**(`main.dart:14`·grep 0건). 비채택 표면(hooks/copyWithPrevious/valueOrNull) 사용은 0이나 전역 retry OFF 1줄 누락(명세 §4.2는 OFF인데 코드 미반영) |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | 각 VM `_$VM`만 extends·base/mixin 0 |

### D. S-DATA
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | (치명표) |
| DT-2 | 단일 출구·throw 금지 | ✅ | (치명표) |
| DT-3 | BadRequestResponse 계약 | ✅(신규 도입) | baseline 순정 민낯 → 산출물 신규 정의: 3필드 errorType/msg/isShow·JSON error_type/is_show(`bad_request_response.dart:12-16`)·어휘 timeout/format/type/unknown·클라 isShow:true(`safe_api_call.dart`) |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | DataSource 도메인 엔티티 직반환·dto/Mapper 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | Repo 인터페이스 없는 단일 구체·무상태·직접생성(`weather_repo.dart:17-18`) |
| DT-6 | retrofit DataSource 표기 | ✅ | @RestApi+factory+part(`weather_data_source.dart:16-18`)·@GET/@Path·엔티티 반환 |
| DT-7 | hive 로컬 캐시 | ➖N/A | hive 미채택 |
| DT-8 | 계약 스냅샷 운용 | ✅ | 인용 path가 동결본 server-contract.json·openapi-full.json에 실재 |
| DT-9 | infra service 수동 어댑터 | ➖N/A | SDK 어댑터 미채택 |

### E. S-HR
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | (치명표·backstop ST0-3) |
| HR-2 | 종류 폴더·접미사 | ✅ | backstop ST6/NM1 clean·지정 접미사 일치 |
| HR-3 | 신규 골격 완비 | ✅ | backstop ST4 clean·4계층·종류폴더·애그루트·.gitkeep |
| HR-4 | 계층 import 역류 | ✅ | (치명표) |
| HR-5 | 교차 BC 4채널 | ➖N/A | 단일 BC |
| HR-6 | 파일·클래스 명명 | ✅ | backstop NM2/3/11/15 clean·파일명=클래스·구접미사 0 |
| HR-7 | root/common/design_system 경계 | ✅ | common 직속 5종·BC어휘 0·design_system→application/root import 0 |
| HR-8 | 화면 삼총사·접두 | ✅ | `_vm`↔`_view`↔`_state` 동거·section 화면 접두·widget 화면명 없음 |
| HR-9 | 개념 1차·종류 2차 성장 | ✅ | 단일 개념 BC·종류 폴더 직속 정상 |

## 3. TIER-Q 등급
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | 지역변수 타입 명시·SCREAMING_CAPS/헝가리안/부정형bool 0 |
| Q-2 | freezed 표기 | ✅ | 새 리터럴+copyWith·`_` 디폴트 switch 0 |
| Q-3 | dartz Either 표면 | ✅ | Either/Left/Right/fold/map만·fold Left 첫인자 |
| Q-4 | null 안전 관용구 | ✅ | promotion·??·`!` 연쇄 0 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey 생성자 부착·@JsonValue |
| Q-6 | catch 위생 | ✅ | safeApiCall on절 구체+catch-all(면제)·무차별 catch 0 |
| Q-7 | 잔여 구조 스멜 | ✅ | 죽은코드 0·매직넘버 토큰화·플래그인자 named 회피 |
| Q-8 | import 정렬·주석 | ✅ | dart→package→상대·블록주석 0·/// |
| Q-9 | flutter 내비 표기 | ✅ | pushNamed·GoRoute builder·redirect 없음 |

> **TIER-Q = 상**(Q WEAK 0·FAIL 0). 단 §3 사전식 집계상 치명(FC-2) FAIL이라 픽스처 등급은 FAIL 우선.

## 4. grader 패널 증거 (§5.5)
- **N_grader 3**(n1·n2 중립·adv 적대)·**전원 Claude 계열 — 비-Claude 오라클 0(A3 독립성 미확보·헤더 ⚠️)**.
- **차원별 κ(일치율)**: 치명 14(➖N/A 3 제외) 만장 PASS. **FC-1 G-7**: n1 "인간 큐"·n2 "약-FAIL 소지"·adv "FC-2로 종속·아이콘 5 distinct" → 3/3 아이콘 미충족 인지(판정은 A1 경계라 인간 큐). **FC-2**: n1 "PASS(M1~M5 red 주장)"·n2 "잠정(flaky)"·**adv "FAIL(M2b·M4 green)"** → 조정자 직접 M4 green 재현으로 **adv 확정**. ST-8: n1·n2 WEAK·adv FAIL(결정).
- **per-grader raw verdict**: `20260618-1610-weather-graders-raw.md` 영속.
- **사각 신고칸(A13·미산입)**: ① G-7 아이콘 distinct vs A1 비측정 긴장(정본화 필요) ② ui_extension 테스트가 (아이콘,색)쌍만 단언해 아이콘 충돌 합법화 ③ navigator 직렬화 seam 테스트 공백 ④ 테스트 병렬 flaky(차원 부재).

## 5. 의미적 변종 / 백스톱-blind 메타
- **[결정 PASS ∧ 의미 FAIL]**: 없음(치명 결정·의미 정합). FC-2는 결정 레인(mutation 실행)에서 직접 FAIL.
- **약화 단위형 디코이 관측(EVAL §2.5)**: `ui_extension_test.dart`가 아이콘 단독 distinct 대신 (아이콘,색)쌍 distinct만 단언 → cloudy/overcast 아이콘 충돌을 의도적으로 통과(코드 주석 자인). 새 게이트 신설 아님·A13 사각칸 기록(코퍼스 `discipline-test §3.1` 정합).

## 6. 발견 로그
1. **(핵심) navigator 직렬화 死검증** — `weather_navigator.dart:22` pushDetail 날짜 직렬화를 두드리는 통합 테스트 부재(M4 green 직접 확인). 탭 핸들러는 section 콜백까지만·router는 initialLocation 직접 주입으로 navigator 우회. G-5 골든의 실제 버그(날짜 오배송)를 못 잡음.
2. **G-7 아이콘 5 distinct** — cloudy=overcast=`Icons.cloud`. design-tokens.json에 `cloud_queue`(partly_cloudy_day) 실재해 구분 가능했으나 색-only 선택(codex는 구분).
3. **테스트 병렬 flaky** — 전역 싱글톤(DioClient.instance) 오염으로 `flutter test`(기본 병렬) 시 정렬 테스트 비결정 실패(grader 관측)·`--concurrency=1`/단일 실행은 green(조정자). green 빌드 재현성 흠.
4. **ST-8 retry OFF 누락** — `main.dart:14` 전역 `retry:(_,__)=>null` 부재(명세 §4.2와 코드 불일치).

## 7. 잔여 흠 원장
- **치명**: FC-2(navigator 직렬화 비-vacuity 실패) → 픽스처 FAIL.
- **인간 큐**: FC-1 G-7(아이콘 distinct·A1 경계 — 사용자 시안 대조).
- **비치명**: ST-8 retry OFF(WEAK)·FC-3 N4(아이콘 공유·G-7 연동).
- **사각(미산입)**: 테스트 병렬 flaky·아이콘 distinct 정본화·navigator seam.

## 8. 한 줄 요지
아키텍처·하우스룰·관용구는 **모범**(치명 14 PASS·backstop 57 clean·analyze green·정렬을 애그리거트에 거주시켜 **6차 M1 정렬 死 → 7차 M1 red 해소**) — 그러나 **FC-2 보수 FAIL**(navigator 날짜 직렬화를 두드리는 테스트 부재·M4 green 직접 확인 → "탭→상세 날짜 일치" 버그 미검출) → **픽스처 FAIL**. 추가 **FC-1 G-7 인간 큐**(cloudy=overcast=`Icons.cloud`·아이콘 5 distinct·색은 6·A1 경계)·ST-8 retry OFF WEAK. *N=1·인과 단정 금지·시각 충실도 비측정·비-Claude 오라클 미확보.*
