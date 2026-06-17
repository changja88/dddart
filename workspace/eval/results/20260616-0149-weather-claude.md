# 채점 결과지 — 20260616-0149-weather-claude

> **방법** EVAL-METHOD v3.1 · **채점일** 2026-06-16 · **환경** claude 파이프라인(설치본 `dddart@dddart-dev` v0.1.1·소스 byte-identical `a8fb2e3`) · **variant** 단일(claude) · **산출물 루트** `~/Desktop/dddart-run/dddart-20260616-0149-claude`(HEAD `fc3fbab`·abee26d 대비 84파일 +11061) · **baseline** `abee26d`(순정 민낯·67파일) · **코퍼스** `a8fb2e3`(feedback-006) · **코드젠 도구 환경** freezed·json_serializable·riverpod_generator·retrofit_generator·build_runner(코더 핀·produced·`.g/.freezed` 커밋) · **task** SCENARIO-WEATHER §1 verbatim · **게이트 답** 페이지네이션·로컬캐시·당겨새로고침 안 함/정렬=날짜 오름차순(서버 순서 유지)/condition 6종 · **FC 골든** `tools/FC-GOLDEN-WEATHER.md` 동결 2026-06-14 01:13(코드 미열람·작성자⊥채점자) · **N_grader** 3(n1·n2·adv) · **구성** 전원 동일 계열 — **비-Claude 오라클 0(A3 독립성 미확보)** · **positive control** 통과(2026-06-14) · **런-정지** 산출물 동결·채점 중 변화 없음(/tmp 격리 사본 채점·런폴더 불변) · **외부진실(FC-1)** 실서버 `kingdom-h.com/api/v1/weather/` = 날짜 오름차순 7건(2026-06-16→06-22) 조정자 확인 · **⚠️** N=1·인과 단정 금지·앵커=예시·소급 FAIL 금지·자기보고 불신(조정자 직접: analyze·test·mutation 실행)·**시각/디자인 충실도 비측정(인간 오라클·A1)**·**E3 Stitch 미발동(design-ref 빈 폴더·MCP 미연결·자체설계·6런 연속)**

## 0. 빌드 게이트

| ID | 항목 | 판정 | 수확 근거 |
|---|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build` exit 0(/tmp 격리 사본·코더 핀 의존)·freezed abstract+const X._()+part 완비·valueOrNull 0 |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` → **"No issues found! (1.5s)"**(added 신규 0). always_specify_types 하 green |

> **테스트 실행 실측(FC-2 보조·자기보고 불신)**: `flutter test`(clean 빌드 후) = **+29 All tests passed**(exit 0). 셰이더 `ink_sparkle.frag`·Timer 실패 0 — §7 테스트 관용구(`splashFactory: NoSplash`·Completer+pumpAndSettle) 적용으로 3차 환경실패(+22/-5) 해소.

## 1. 치명 게이트 (17 — 하나라도 ❌이면 FAIL)

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 유일 도메인 판정 `Forecast.isToday(now)` domain 거주(`forecast.dart:37`)·VM은 라벨 *선택* 변환만(`weather_list_vm.dart:53-60`)·spec import 0 (3/3) |
| S-DDD | SD-2 | 루트 경유 변경 | ➖N/A | 읽기전용·전이/Model밖 copyWith 분기 0 |
| S-DDD | SD-7 | UseCase 관문(UI호출) | ✅ | 무상태·Either 통과·flutter/presentation import 0·새 throw 0(`forecast_use_case.dart:14-20`) |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | build 표시·위임만(`weather_list_view.dart:18-36`) |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | design_system 전역 self-show static 0 |
| S-STATE | ST-1 | VM 책임 경계(직행) | ✅ | VM Model방향 호출 `ForecastUseCase`뿐·Repo/box/SDK/BuildContext 0(`weather_list_vm.dart:22`) |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패 build `throw badRequest`→AsyncError(`:24`)→view `.when(error)`·valueOrNull 0. 액션 채널 N/A(읽기전용) |
| S-STATE | ST-4 | ref 규율(mounted) | ➖N/A | build await 후 state 재접근 없음·핸들러 동기 navigator |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadReq,T>>`(`weather_repo.dart:17`)·Left를 throw로 상위전달(no-op 아님) |
| S-DATA | DT-2 | 단일 출구·throw 금지 | ✅ | safeApiCall 단일출구·Dio/Format/TypeError+catch-all·Repo throw 0 |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | backstop ST exit 0·`application/weather/` 4계층+직속2 |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | backstop IM exit 0·domain 순수 Dart |
| S-HR | HR-5 | 교차 BC 4채널만 | ➖N/A | 단일 BC |
| BUILD | BG-1 | 컴파일 가능 | ✅ | §0 |
| BUILD | BG-2 | analyze green 래칫 | ✅ | §0·backstop 55종 exit 0 |
| FC | FC-1 | 골든 오라클 | ✅ | G-1~G-8 일치(외부진실=서버 오름차순·앱 `List.map().toList()` 순서 보존·Map/Set 재정렬 0 `weather_list_vm.dart:28-36`). G-3/4 기온·G-5 탭→상세날짜·G-6 상세3지표·G-7 6종 distinct·G-8 한글 라벨 정확. **단 G-1은 서버 정렬 의존(코드 정렬 0)** |
| FC | FC-2 | 테스트·메커니즘 비-vacuous | ❌ | **M1(정렬) red 불가 = vacuous**: 정렬 코드 lib 전역 0(grep)·목록 *순서* 단언 테스트 0(전 목록테스트가 사전정렬 fake tile override·`weather_list_view_test.dart:38-93` findsOneWidget 존재만). M2(아이콘 swap)·M3(기온 라벨 `weather_label_transform_test`)·M4(내비 `70%`)·M5(상세지표)는 red 실증(2/3 FAIL·n2 PASS) |
| FC | FC-3 | 도메인 정합(negative) | ✅ | 외부진실(서버 오름차순) 하 N1~N7 명백오류 0·6종 distinct·cloudy≠overcast |

> **종합 = FC-2 ❌ → §3 집계 전체 FAIL.** 단 [결정·기능 PASS ∧ 테스트 사각] — *동작은 정확(FC-1·3 PASS)하나 정렬 행위를 두드리는 테스트만 부재*. 3차(더미스모크·전면 vacuous) 대비 **테스트 포괄성 급증**, 잔존 사각은 **정렬축 단독**.

## 2. 차원별 판정

### A. S-DDD
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | isToday domain·VM 변환만 (3/3) |
| SD-2 | 루트 경유 변경 | ➖N/A | 읽기전용 |
| SD-3 | 불변식 도메인 예외 검증 | ➖N/A | 전이·생성검증 없음·무검증 freezed 직파싱 |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `Forecast` @freezed+json·isToday 자기보유 |
| SD-5 | 애그리거트 경계·참조 | ✅ | 단일 루트·평면 직파싱 |
| SD-6 | 도메인서비스·spec 귀속 | ➖N/A | 교차 판정 없음 |
| SD-7 | UseCase 관문 | ✅ | 무상태·Either 통과·UI 0 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/port/dto/추상Repo/DI 0 |
| SD-9 | 유비쿼터스 언어 | ✅ | forecast/weather 계층 관통 동일 철자·enum 식별자=서버값 일치 |

### B. S-VIEW
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | 표시·위임만 |
| VW-2 | 3단 판별·과승격 | ✅ | section/widget ref·VM 0·prop/콜백 |
| VW-3 | dumb 조각 계약 | ✅ | section/widget ref·provider import 0 |
| VW-4 | 시각 토큰 단일출처 | ✅ | App* 토큰·foundation 밖 생 리터럴 0·VM 시각 getter 0 |
| VW-5 | ui_extension 매핑 유일자리 | ✅ | enum→아이콘/색/라벨 ui_extension 단독 |
| VW-6 | 표시 소유·show() 금지 | ✅ | 자기표시 static 0 |
| VW-7 | 라우트 단일출처·navigator | ✅ | `WeatherRoutes`만·pushNamed 상수·뷰 onTap 인라인 직렬화 0(VM `buildForecastDateKey`) |

### C. S-STATE
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | UseCase 단독·직행 0 |
| ST-2 | 에러 2채널 | ✅ | 조회 build throw→AsyncError·valueOrNull 0 |
| ST-3 | State 형태·노출 | ✅ | application/state @freezed·자기 State·error 필드 |
| ST-4 | ref 규율 | ➖N/A | await 후 state 접근 없음 |
| ST-5 | provider 형태 | ✅ | `@riverpod class extends _$X` 클래스형·family build 인자·legacy 0 |
| ST-6 | SharedState·교차 BC | ➖N/A | 교차 watch 없음 |
| ST-7 | root 합성 구조 | ✅ | root 정상 |
| ST-8 | 비채택(retry OFF 등) | ✅ | ProviderScope `retry:(_,_)=>null`·hooks/valueOrNull 0 |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | `_$VM`만 extends(라벨 변환은 top-level 함수·base VM 아님) |

### D. S-DATA
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | Repo Future<Either>·Left 전달 |
| DT-2 | 단일 출구·throw 금지 | ✅ | safeApiCall 단일출구 |
| DT-3 | BadRequestResponse 계약 | ✅ | 3필드·error_type/is_show·클라 isShow:true |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | DataSource 엔티티 직반환·dto 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | 구체 단일·무상태·직접생성 |
| DT-6 | retrofit DataSource 표기 | ✅ | @RestApi+factory+part+@GET/@Path |
| DT-7 | hive 로컬 캐시 | ➖N/A | 캐시 미사용 |
| DT-8 | 계약 스냅샷 운용 | ✅ | 엔드포인트 OpenAPI 일치 |
| DT-9 | infra service = 수동 어댑터 | ➖N/A | SDK 어댑터 미사용 |

### E. S-HR
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | 4계층·직속2 |
| HR-2 | 종류 폴더·접미사 | ✅ | 화이트리스트·지정 접미사 |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류폴더·.gitkeep·애그루트 |
| HR-4 | 계층 import 역류 금지 | ✅ | 역류 0 |
| HR-5 | 교차 BC 4채널만 | ➖N/A | 단일 BC |
| HR-6 | 파일·클래스 명명 | ✅ | 파일명=클래스·구접미사 0·App 접두 |
| HR-7 | root/common/design_system 경계 | ✅ | common BC어휘 0·design_system import 화이트리스트 |
| HR-8 | 화면 삼총사·접두 | ✅ | vm↔view↔state 동거·widget 화면명 미보유 |
| HR-9 | 개념1차·종류2차 | ✅ | 단일개념 직속 |

## 3. TIER-Q 등급 (기록용 — 치명 FAIL로 정식 등급 미산정)

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | analyze green·SCREAMING/헝가리안 0·지역변수 타입 명시 |
| Q-2 | freezed 표기 | ✅ | 소진 switch·`_` 0·when/map 0 |
| Q-3 | dartz Either 표면 | ✅ | Either/fold만·Left 첫인자 |
| Q-4 | null 안전 관용구 | ✅ | `??` 우선·`!` 연쇄 0 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey·@JsonValue+unknownEnumValue |
| Q-6 | catch 위생 | ✅ | safeApiCall on절 구체+catch-all |
| Q-7 | 잔여 구조 스멜 | 🟡경미 | 미사용 표준필드(`error`·`onRetry` 채움경로 0·주석 정당화)·아이콘 size 매직넘버(비-시각토큰) |
| Q-8 | import 정렬·주석 | ✅ | dart→package→상대·블록주석 0 |
| Q-9 | flutter 내비 표기 | ✅ | pushNamed·redirect 미사용 |

> Q-1~9 PASS 8·경미 WEAK 1(Q-7) — 치명 통과 시 "상" 상당이나 FC-2 FAIL로 정식 미산정.

## grader 패널 증거 (A3)

| grader | 계열 | 적대 | raw verdict |
|---|---|---|---|
| n1 | Claude | 아니오 | `20260616-0149-weather-graders-raw.md` (claude n1) |
| n2 | Claude | 아니오 | 〃 (claude n2) |
| adv | Claude | **예(적대)** | 〃 (claude adv) |

| 차원 | grader 판정(n1·n2·adv) | κ | split 방향·비고 |
|---|---|---|---|
| FC-2(치명) | ❌✅❌ | split 2:1 | **보수 FAIL** — n1·adv: M1 정렬 red 불가·순서 단언 0. n2: M2~M5 red로 비-vacuous 주장(정렬축 사각은 인정) |
| FC-1(치명) | ✅✅❌ | split 2:1 | adv: shuffled-D 적용 시 FAIL. **조정자 판정 = PASS**(외부진실 서버 오름차순+게이트 "서버 순서 유지"·앱 순서보존 확인·EVAL §2.4 외부행위 정확). adv 우려는 FC-2(미테스트)로 귀속 |
| SD-1·SD-7·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·HR-1·HR-4(치명) | ✅✅✅ | 1.0 | 전원 PASS·인용 동반 |
| HR-5·SD-2·ST-4(치명) | ➖➖➖ | 1.0 | 읽기전용 단일 BC 미발화 |

> 만장일치 보드(PASS 치명 10)인데 per-grader raw·κ 존재 → 단일저자 위장 아님. 비-Claude 오라클 0(A3·헤더 ⚠️).

**rubric 사각 신고 (A13)**

| grader | 내용 |
|---|---|
| n1·adv | 정렬 책임을 서버에 위임하면 "서버 순서 유지"가 곧 G-1이나, 라이브 서버가 우연히 오름차순일 때만 참 — 순서 보존을 고정하는 테스트가 0이라 서버 변경·재배열 회귀를 못 잡음(FC-2 사각의 본질) |
| n2 | `weather_detail_vm`이 `weather_list_vm.dart`의 top-level 자유함수를 import 공유 — base VM(ST-9)·삼총사(HR-8)는 통과하나 "VM 파일 간 표시함수 공유"의 거주 적법성 항목 부재 |

## 의미적 변종 / 백스톱-blind 메타

| 차원 | 결정 레인 | 의미 레인 | 종합 | 변종 유형 |
|---|---|---|---|---|
| FC-2 | M2/M3/M4/M5 red·테스트 29 green | 목록 *순서* 단언 0·정렬 사이트 부재로 M1 死 | ❌ 치명 FAIL | 핵심 골든(G-1 순서) vacuous |
| FC-1 | backstop 0·analyze green | 서버 오름차순 보존(동작 정확) | ✅ PASS | — (adv 이견 = FC-2 귀속) |

> 백스톱 55종 exit 0(구조 청결)인데 FC-2 정렬축 미테스트 — 결정 청결 ∧ 단일 기능검증 사각.

## 발견 로그

| # | 단계 | 도구 | 차원 | 내용 | 조기/말기 |
|---|---|---|---|---|---|
| 1 | 결정레인 | grep sort/compareTo | FC-1/2 | 정렬 코드 lib 전역 0(3차 claude는 `..sort` 보유→**4차 회귀 소실**) | 조기 |
| 2 | 결정레인 | flutter test(clean) | FC-2/BG | +29 All passed·셰이더/Timer 0(§7 효과) | 말기 |
| 3 | 결정레인 | mutation M2(/tmp) | FC-2 | clear 아이콘 교란→`weather_list_view_test` B2 red(비-vacuous 실증) | 말기 |
| 4 | 결정레인 | backstop 55종 | 구조 | exit 0 blocker 0 | 조기 |
| 5 | 외부진실 | curl 실서버 | FC-1 | weather 목록 날짜 오름차순 7건 확인(06-16→06-22) | 조기 |

## 잔여흠 원장

| 차원 | 흠 | 심각도 | 근거 |
|---|---|---|---|
| FC-2 | 목록 순서(G-1) 단언 테스트 부재·정렬 코드 0(서버 의존) | ❌치명 | grep·테스트 정독·n1/adv |
| (회귀) | 3차 `forecast_list_vm`의 `..sort(compareTo)`가 4차 소실 | 관찰 | 3차 `f5f2015` vs 4차 `fc3fbab` |
| Q-7 | 미사용 표준필드·아이콘 size 매직 | 🟡경미 | n1 |

## 한 줄 요지

**치명 게이트 ❌ FAIL(FC-2 단독 — 목록 날짜순서를 두드리는 테스트 부재·정렬 코드 0으로 필수 mutation M1 red 불가).** 그 외 치명 16 전부 PASS·FC-1/FC-3 동작 정확(실서버 오름차순 보존)·테스트 +29 green·셰이더/Timer 해소·구조 청결. **3차(더미스모크 전면 vacuous) 대비 테스트 포괄성 급증**했으나, ① 정렬 회귀(3차 `..sort` 소실) ② 정렬축 비-vacuity 미달이 단일 구멍. (단일 산출물·우열 단정 금지)
