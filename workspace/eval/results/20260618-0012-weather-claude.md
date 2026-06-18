# 채점 결과지 — 20260618-0012-weather-claude

> **방법** EVAL-METHOD v3.2 · **채점일** 2026-06-18 · **환경** claude 파이프라인(설치본 `dddart@dddart-dev` v0.1.1·캐시 재동기) · **variant** 단일(claude 엔진) · **산출물 루트** `~/Desktop/dddart-run/dddart-20260618-0012-claude` **@`ab99a82`**(파이프라인 최종 커밋·green 완료·소스 mtime 02:17 동결) · **채점 사본** `/tmp/grade-0012-claude`(cp -r·finalize-collapse 작업트리이나 ab99a82 핀으로 채점) · **baseline** `abee26d`(순정 민낯·changeset 98파일 +12527/-141) · **코퍼스** `d18f2d1`(feedback-008·테스트 스킬 2종)·repo HEAD `8f58166`(v3.2 eval) · **코드젠** freezed·json_serializable·riverpod_generator(4.x)·retrofit_generator·build_runner(코더 핀·produced) · **task** SCENARIO-WEATHER §1 verbatim · **게이트 답** 페이지네이션·로컬캐시·당겨새로고침 안 함/정렬=날짜 오름차순(서버 순서 유지)/condition 6종 ui_extension · **FC 골든** `tools/FC-GOLDEN-WEATHER.md` 동결 2026-06-14 01:13(코드 미열람·작성자⊥채점자) · **N_grader** 3(n1·n2·adv)·**구성 전원 Claude 계열 — 비-Claude 오라클 0(A3 독립성 미확보)** · **positive control** 2026-06-14 검증 인용(백스톱 55 byte-불변·§0.6 재검조건 미충족·README 17 PASS·mutation 3/3 red) · **런-정지** 소스 02:17 동결·검수 중 관측 변화는 finalize-collapse(HEAD 포인터·소스 무변)·build-state 08:24 이후 안정 · **외부진실(FC-1)** 실서버 `kingdom-h.com/api/v1/weather/` curl = 7건·날짜 오름차순(06-18→06-24)·6 condition 전부 등장(조정자 확인) · **⚠️** N=1·인과 단정 금지·앵커=예시·소급 FAIL 금지·자기보고 불신(조정자 직접 build_runner·analyze·test·mutation 실행)·**시각/디자인 충실도 비측정(인간 오라클·A1)**
>
> **post-collapse 드리프트 제외**: 원본 작업트리는 finalize-collapse(`git reset --soft`)로 미커밋이고 ab99a82 이후 `root_initializer.dart`+`build-state.json` 미세 변동 관측 → 파이프라인 green 산출(ab99a82) 밖이라 채점 제외(설계문서 `2026-06-17-finalize-uncommit-collapse.md` §7·5차 "채점 후 modify 제외" 선례 정합).

## 0. 빌드 게이트

| ID | 항목 | 판정 | 수확 근거 |
|---|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build` exit 0("Built…wrote 17 outputs"·/tmp 격리)·freezed/json/retrofit/riverpod codegen 성공·valueOrNull 0 |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` → **"No issues found! (1.3s)"**(added 신규 0)·per-BC strict-types 하 green |

> **테스트 실측(FC-2 보조·자기보고 불신)**: `flutter test`(clean 후 build_runner 선행) = **+23 All tests passed**(exit 0·9 test 파일). **backstop 55종**(`--diff-base abee26d`) = **blocker 0건**(exit 0·구조·명명·import·순환·TG·PJ 청결).

## 1. 치명 게이트 (17 — 하나라도 ❌이면 FAIL)

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 읽기전용 조회 BC — 도메인 어휘 판정 0건이 정합(누수 아님). VM은 `result.fold`로 Either→State 변환만(`weather_list_vm.dart:23-27`)·spec import 0·빈 wrapper 아님. condition→UI는 ui_extension 거주(SD 아님·VW-5). (3/3·실질성 관문 미저촉=읽기전용 의무 thin·HR-3 정당) |
| S-DDD | SD-2 | 루트 경유 변경 | ➖N/A | 읽기전용·전이 0·Model 밖 copyWith 0 |
| S-DDD | SD-7 | UseCase 관문(UI호출) | ✅ | 무상태 plain·Either 통과(`get_weekly_forecast_use_case.dart:15-16`)·flutter/presentation/design_system import 0·새 throw 0·직접생성 |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | build `.when` 3분기+section/Loading/error 위임만(`weather_list_view.dart:26-36`·`weather_detail_view.dart:36-47`)·정책 0 |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | ErrorFeedback/Loading 수동 위젯·전역 self-show static 0·navigator pushNamed(`weather_navigator.dart:13-24`) |
| S-STATE | ST-1 | VM 책임 경계(직행) | ✅ | VM Model방향 호출 UseCase뿐(`weather_list_vm.dart:21`·`weather_detail_vm.dart:23`)·Repo/box/SDK/BuildContext/컨트롤러 0 |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패 build `throw failure`(BadRequestResponse)→AsyncError(`weather_list_vm.dart:24`)→view `.when(error)`+invalidate. **액션 채널 의도적 부재**(`weather_list_state.dart:11` error 필드 없음·읽기전용 정당·죽은 필드 0)·valueOrNull 0 (3/3) |
| S-STATE | ST-4 | ref 규율(mounted) | ➖N/A | build await 후 state 재접근 없음(fold 결과 즉시 반환)·requireValue 0 |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadRequestResponse,T>>`(`weather_repo.dart:19-28`)·Left를 `throw failure`로 상위 전달(no-op 아님·adv 반증) |
| S-DATA | DT-2 | 단일 출구·throw 금지 | ✅ | safeApiCall 단일출구(`weather_repo.dart:20-21`)·Dio/Format/TypeError+catch-all·Repo throw 0(수기 infra)·`.g.dart` rethrow 면제 |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | backstop ST exit 0·`application/weather/` 4계층+직속2(router·navigator) |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | backstop IM exit 0·domain 순수(freezed/json만)·application→design_system 0·presentation→infra 0 |
| S-HR | HR-5 | 교차 BC 4채널만 | ➖N/A | 단일 신규 BC·타 BC import 0·채널④ 불성립 |
| BUILD | BG-1 | 컴파일 가능 | ✅ | §0 |
| BUILD | BG-2 | analyze green 래칫 | ✅ | §0·backstop 55종 exit 0 |
| FC | FC-1 | 골든 오라클 | ✅ | **G-1~G-8 런타임 일치**(외부진실 서버 오름차순 7건+앱 순서보존). G-7 색 6 distinct(`condition_ui_extension.dart:29-44` `0xFBBF24/94A3B8/64748B/3B82F6/90A4D4/6366F1`·**5차 충돌 해소**)·아이콘 6·라벨 6 정확(G-8 cloudy=구름많음 정확). G-3/4 기온 바인딩·G-5 탭→날짜·G-6 상세3지표 정합(mutation M3/M4/M5 RED). **G-1 서버의존 단서**: 앱 정렬코드 0·서버 오름차순에 의존(FC-2로 귀속) (3/3) |
| FC | FC-2 | 테스트·메커니즘 비-vacuous | ❌ | **M1(정렬) 死+vacuous**: lib 전역 정렬코드 0(grep)·`weather_list_vm_test.dart:48-52`가 **사전정렬 fixture**에 `orderedEquals`(무정렬도 green·"순서보존"만 단언) → 주입사이트 부재=비-vacuity 입증불가. **동결 FC-GOLDEN §2 M1·EVAL §2.5 "정렬코드/주입사이트 부재=FAIL·뒤섞은 입력 필수" 적용**. M2(색)=GREEN(테스트가 `toSet().length==6` distinctness만·swap 미포착)·**M3·M4·M5=RED**(기온위치 `'7°/-3°'`+`findsNothing('-3°/7°')`·탭 날짜·상세지표 비-vacuous·5차 M3 회복). 필수 M1 미충족 → FC-2 FAIL |
| FC | FC-3 | 도메인 정합(negative) | ✅ | 런타임 명백오류 0(N1 7건·N3 필드완비·N4 색충돌 0·N5 기온/부호·N6 탭날짜·N7 라벨 정확). N2(순서)는 서버 오름차순이라 미발현(FC-2 귀속) (3/3) |

> **종합 = FC-2 ❌ → §3 집계 전체 FAIL.** 치명 16 PASS(SD-2·ST-4·HR-5 ➖N/A) + **FC-2 단독 FAIL**. **5차(FC-1 색·FC-2 M1+M3·FC-3 색 3종 FAIL) 대비 대폭 개선** — 색 충돌 해소(FC-1·FC-3 회복)·M3 기온위치 회복 → **유일 잔여 = M1 정렬 死(서버순서 위임·6런 연속 동일 아키텍처 쟁점·A13-1)**. **역대 최청정 런**.

## 2. 차원별 판정

### A. S-DDD
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | 읽기전용 판정 0 정합·VM 변환만·누수 0 (3/3) |
| SD-2 | 루트 경유 변경 | ➖N/A | 읽기전용·전이 0 |
| SD-3 | 불변식 도메인 예외 검증 | ➖N/A | 생성검증 없음·freezed 직파싱(서버 데이터 정상 유입) |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `WeatherSummary`·`WeatherForecast` @freezed+@JsonKey 직파싱(`weather_forecast.dart:11-25`)·읽기전용이라 도메인 연산 0 정당 |
| SD-5 | 애그리거트 경계·참조 | ✅ | 단일 루트·상세=목록 상위집합·평면 직파싱 |
| SD-6 | 도메인서비스·spec 귀속 | ➖N/A | 교차 판정 없음 |
| SD-7 | UseCase 관문 | ✅ | 무상태·Either 통과·UI 0 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/port/acl/dto/추상Repo/DI 0·이름우회 0 |
| SD-9 | 유비쿼터스 언어 | ✅ | weather/condition/forecastDate 계층 관통 동일 철자·enum=서버값 |

### B. S-VIEW
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | 표시·위임만 |
| VW-2 | 3단 판별·과승격 | ✅ | section/widget ref·VM 0·view 삼총사 watch 사유 실재 |
| VW-3 | dumb 조각 계약 | ✅ | section/widget에 ref·provider import 0(prop·콜백) |
| VW-4 | 시각 토큰 단일출처 | ✅ | App* 토큰·foundation 밖 생 Color/TextStyle/Duration 0·VM/State 시각 getter 0 |
| VW-5 | ui_extension 매핑 유일자리 | ✅ | condition→아이콘/색/라벨 `WeatherConditionUiExtension` 단독·VM/State 누수 0 |
| VW-6 | 표시 소유·show() 금지 | ✅ | 자기표시 static 0 |
| VW-7 | 라우트 단일출처·navigator | ✅ | `WeatherRoutes` 리터럴 단독(`weather_router.dart:10-19`)·pushNamed 상수·view import 0·onTap이 VO `date` 위임(인라인 직렬화 0) |

### C. S-STATE
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | UseCase 단독·직행 0 |
| ST-2 | 에러 2채널 | ✅ | 조회 build throw→AsyncError·error 필드 의도적 부재(읽기전용)·죽은 필드 0·valueOrNull 0 |
| ST-3 | State 형태·노출 | ✅ | application/state @freezed(`weather_list_state.dart:13-18`)·자기 State·엔티티 필드 래핑·error 필드 없음 정합 |
| ST-4 | ref 규율 | ➖N/A | await 후 state 접근 없음 |
| ST-5 | provider 형태 | ✅ | `@riverpod class extends _$X` 클래스형·family(detail build 인자)·legacy 0 |
| ST-6 | SharedState·교차 BC | ➖N/A | 교차 watch 없음 |
| ST-7 | root 합성 구조 | ✅ | root_router plain 전역·weather BC GoRoute 조립·initializer 결과반환 0 |
| ST-8 | 비채택(retry OFF 등) | ✅ | main.dart `retry:(int,Object)=>null`(`main.dart:19`)·hooks/valueOrNull/copyWithPrevious 0 |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | `_$VM`만 extends·mixin/추출 헬퍼 0 |

### D. S-DATA
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | Repo Future<Either>·Left throw 전달 |
| DT-2 | 단일 출구·throw 금지 | ✅ | safeApiCall 단일출구 |
| DT-3 | BadRequestResponse 계약 | ✅ | 신규 정의·3필드 errorType/msg/isShow(@JsonKey error_type/is_show)·클라 생성 isShow:true·`bad_request_response.dart:8-18` |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | DataSource `WeatherSummary`/`WeatherForecast` 직반환(`weather_data_source.dart:17-23`)·dto/Mapper 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | 구체 단일·무상태·**직접 생성(no-DI)**(`weather_repo.dart:15`·`get_weekly_forecast_use_case.dart:11`)·테스트는 네트워크 seam(Dio fake) |
| DT-6 | retrofit DataSource 표기 | ✅ | @RestApi+factory+part+@GET/@Path·엔티티 직반환 |
| DT-7 | hive 로컬 캐시 | ➖N/A | 캐시 미사용(네트워크 전용) |
| DT-8 | 계약 스냅샷 운용 | ✅ | 엔드포인트 OpenAPI 실재·forecast_date YYYY-MM-DD path 왕복 tracer 실증(`weather_data_source_test.dart`) |
| DT-9 | infra service = 수동 어댑터 | ➖N/A | SDK 어댑터 미사용 |

### E. S-HR
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | backstop ST exit 0·4계층+직속2 |
| HR-2 | 종류 폴더·접미사 | ✅ | 화이트리스트·지정 접미사(_vm·_repo·_state) |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류폴더·.gitkeep·애그루트(backstop ST4) |
| HR-4 | 계층 import 역류 금지 | ✅ | 역류 0 |
| HR-5 | 교차 BC 4채널만 | ➖N/A | 단일 BC |
| HR-6 | 파일·클래스 명명 | ✅ | 파일명=클래스 snake_case·구접미사 0·App 접두 |
| HR-7 | root/common/design_system 경계 | ✅ | common BC어휘 0·design_system import 화이트리스트·root import main만 |
| HR-8 | 화면 삼총사·접두 | ✅ | vm↔view↔state 동거·section 화면접두 |
| HR-9 | 개념1차·종류2차 | ✅ | 단일개념 직속 |

## 3. TIER-Q 등급 (기록용 — 치명 FAIL로 정식 등급 미산정)

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | analyze green·SCREAMING/헝가리안 0·지역변수 타입 명시 |
| Q-2 | freezed 표기 | ✅ | 소진 switch(condition)·when/map 0(AsyncValue `.when` 면제) |
| Q-3 | dartz Either 표면 | ✅ | Either/fold만·Left 첫인자 |
| Q-4 | null 안전 관용구 | ✅ | `?? ` 폴백·`!` 연쇄 0 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey·@JsonValue |
| Q-6 | catch 위생 | ✅ | safeApiCall on절 구체+의도 catch-all(면제) |
| Q-7 | 잔여 구조 스멜 | 🟡경미 | 상세 지표 아이콘 중복 가능성(습도·강수확률 — 5차 관찰·재확인 시 경미)·매직넘버 일부 |
| Q-8 | import 정렬·주석 | ✅ | dart→package→상대 |
| Q-9 | flutter 내비 표기 | ✅ | pushNamed·context.pop·CustomTransition 토큰 |

> Q-1~9 PASS 8·경미 WEAK ≤1 — 치명 통과 시 "상" 상당이나 FC-2 FAIL로 정식 미산정.

## grader 패널 증거 (A3)

| grader | 계열 | 적대 | raw verdict |
|---|---|---|---|
| n1 | Claude | 아니오 | `20260618-0012-weather-graders-raw.md` (n1) |
| n2 | Claude | 아니오 | 〃 (n2) |
| adv | Claude | **예(적대)** | 〃 (adv) |

| 차원 | grader 판정(n1·n2·adv) | κ | split 방향·비고 |
|---|---|---|---|
| FC-2(치명) | M1 N/A론·N/A론·❌ | 사실 1.0/판정 1:2 | **❌ FAIL** — 정렬코드 0·vacuous order test 3명 만장확인. adv 줄인용 FAIL+동결 FC-GOLDEN §2 → 보수 FAIL. n1·n2 "정당 위임"은 A13-1 |
| SD-1·SD-7·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2(치명) | ✅✅✅ | 1.0 | 전원 PASS·줄인용 동반·adv 디코이 전수 반증·ST-2 error 필드 부재=정당 |
| FC-1·FC-3(치명) | ✅✅✅ | 1.0 | 런타임 골든 일치·색 6 distinct·G-8 정확(구름많음) |
| SD-2·ST-4·HR-5(치명) | ➖➖➖ | 1.0 | 읽기전용 단일 BC 미발화 |

> **만장 PASS(치명 16)인데 per-grader raw·κ 존재**(단일저자 위장 아님). 비-Claude 오라클 0(A3·헤더 ⚠️).

**rubric 사각 신고 (A13 — 채점 미산입·다음 동결 입력)**

| grader | 내용 |
|---|---|
| n1·adv | **"서버순서 위임"의 FC-2/M1 미닫힘(6런 연속·A13-1)** — gate "서버순서 유지"가 정렬코드 부재를 정당화하는지 골든 미명시 |
| adv | 실질성 관문(§3 step 2.5) — X 도메인 행위 0(읽기전용 정당 판정했으나 패널 확인 권고) |
| n1 | G-1 오름차순 미검증(사전정렬 fixture=vacuous order test) |

## 의미적 변종 / 백스톱-blind 메타 (측정의 주 산출물)

| 차원 | 결정 레인 | 의미 레인 | 종합 | 변종 유형 |
|---|---|---|---|---|
| FC-2 | M2 GREEN·M3·M4·M5 RED·테스트 23 green·**M1 死(정렬코드 0)·vacuous order test** | 정렬 판정 부재(서버 위임) | ❌ 치명 FAIL | 핵심 골든(G-1 순서) 비-vacuity 미입증 |
| FC-1 G-1 | grep sort 0·서버 오름차순(curl) | 앱 순서보존(런타임 정확) | ✅(G-1·서버의존) | 코드 보증 아닌 서버 의존 = FC-2 사각 귀속 |
| (그 외 치명 16) | 백스톱 55 exit 0·analyze green | 3 grader 만장 PASS·줄인용 | ✅ | 의미 변종 0(빈 wrapper·Left no-op·죽은필드·디코이 전수 반증) |

> 백스톱 55종 exit 0(구조 청결)·치명 16 PASS·**FC-2 단독 FAIL = 정렬 비-vacuity 사각(서버 위임)**. 색·기온·내비·상세는 6차에 비-vacuous 회복(M3/M4/M5 RED).

## 발견 로그

| # | 단계 | 도구 | 차원 | 내용 | 조기/말기 |
|---|---|---|---|---|---|
| 1 | 결정레인 | grep sort/compareTo | FC-1/2 | 정렬 코드 lib 전역 0(5차 동일·서버 의존) | 조기 |
| 2 | 결정레인 | mutation M1 | FC-2 | 정렬 死(주입사이트 부재)·order test vacuous(사전정렬 fixture) | 말기 |
| 3 | 결정레인 | mutation M3·M4·M5 | FC-2 | 기온위치·탭날짜·상세지표 RED(비-vacuous·**5차 M3 회복**) | 말기 |
| 4 | 결정레인 | mutation M2 | FC-2 | 색 swap GREEN(테스트가 set-size distinctness만) | 말기 |
| 5 | 결정레인 | app_color 직독 | FC-1/3 | condition 6색 distinct(**5차 clear=cloudy 충돌 해소**) | 조기 |
| 6 | 결정레인 | curl 실서버 | FC-1 | 7건 날짜 오름차순(06-18→06-24)·6 condition 전부 | 조기 |
| 7 | 결정레인 | backstop 55종 | 구조 | exit 0·blocker 0(TG·PJ 포함) | 조기 |
| 8 | 의미레인(3명) | grader 정독 | 치명16 | 만장 PASS·error 필드 부재=정당·디코이 전수 반증 | 말기 |

## 잔여흠 원장

| 차원 | 흠 | 심각도 | 근거 |
|---|---|---|---|
| FC-2 | 정렬 M1 死·order test vacuous(사전정렬 fixture)·정렬코드 0 | ❌치명 | mutation 실측·grader 3·동결 FC-GOLDEN §2 |
| (A13-1) | "서버순서 위임"이 정당 N/A인지 비-vacuity 갭인지 골든 미명시(6런 연속) | 차기동결 | n1·n2 "정당"·adv "FAIL"·룰설계 결정 필요 |
| Q-7 | 상세 지표 아이콘 중복 가능성·매직넘버 일부 | 🟡경미 | 5차 관찰·재확인 시 |

## 한 줄 요지

**치명 게이트 ❌ FAIL — FC-2/M1(정렬 死=서버순서 위임·order test가 사전정렬 fixture라 vacuous·정렬코드 0) 단독.** 그 외 **치명 16 전부 PASS**(구조·타입·계층·에러 단일채널·Either 계약·정규 dddart형 @freezed/json/codegen·clean no-DI)·BG green·테스트 +23·backstop 55 청결. **5차 양판 공통 FAIL이던 색 충돌(FC-1/FC-3)·M3 기온 vacuity가 6차에 해소** → 유일 잔여가 6런 연속 동일한 정렬-위임 쟁점(A13-1). **역대 최청정 런** — M1을 정당 위임으로 보면 전 치명 통과에 해당(차기 동결 결정 의존). (단일 산출물·우열 단정은 비교지에서·시각 충실도 비측정)
