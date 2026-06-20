# 채점 결과지 — weather(7일 예보) · claude · 11차

> **방법** EVAL-METHOD v3.2 · **채점일** 2026-06-20 · **채점 시작** 20260620-1405 · **환경** 라이브런=사용자 드라이브(Claude Code) / 채점 grader=Claude 계열 · **variant** 단일 · **산출물 루트** `/Users/hyun/Desktop/dddart-run/dddart-20260620-1206-claude` · **baseline** `abee26d` · **코퍼스** `60a63aa`(feedback-013 R6+R1~R4 시술·11차 검증 대상) · **코드젠 도구 환경** freezed 3.2.6-dev.1·json_serializable·build_runner·retrofit_generator·riverpod_generator(코더 핀·`dart pub get`→`build_runner build` 재생성 0 outputs=손작성 drift 0) · **task** SCENARIO-WEATHER §1(verbatim) · **게이트 답** G0 풀모드(화면2·BC weather)·G1 페이지네이션/캐시/당겨새로고침 미적용·정렬 날짜오름차순·6종 아이콘색라벨=ui_extension·G2 green · **FC 골든** 사전등록 동결(`FC-GOLDEN-WEATHER.md` 2026-06-14 01:13·amend 2026-06-18) · **N_grader** 3(의미2+적대1)·**구성** 전원 Claude 계열 — ⚠️ 비-Claude 오라클 미확보·독립성 한계 · **positive control** 통과(`tools/positive-control/` 치명18 PASS·거짓-FAIL 기계 아님) · **런-정지** 산출물 mtime(~13:21) < 채점 시작(14:05) ✅
>
> ⚠️ N=1·인과 단정 금지·앵커=예시(임계값 아님)·소급 FAIL 금지·자기보고 불신(조정자 직접 검증) · **시각 충실도**: 이 런은 `screenProbes` 미노출(implementation-test §7 표준 pump 규약 미준수)로 **FID 자동 게이트 미작동→A1 폴백**(L1·L2·L3 ➖·구조 충실도도 사용자 눈 위임·`fid-gate.sh` exit 3) / 미관·아이콘 심볼(L4) 비측정(A1). **구조·기능·FID-➖ ≠ 미관 시안 일치.**

## ⚠️ 정정 (2026-06-20 · 골든 개정 반영)

**이 결과지의 FC-1·FC-3 ❌·치명 FAIL 판정은 구판 골든 기준이며, 2026-06-20 `FC-GOLDEN-WEATHER.md` 개정으로 정정한다. 이 배너가 본문 판정을 governs.**

- **개정 사유**: 구판 골든의 'G-7 6종 색 distinct·동일 색=자동 FAIL'은 **디자인 소스(`projects/2284872291805682410` design_md Colors)를 미열람 작성**돼, 디자인이 명시한 **기능 4색 팔레트(cloudy=overcast=#9B9B9B 동일·"to reduce visual vibration")**와 모순. 구별 = 아이콘 ∨ 색으로 교정(§68).
- **claude 실측**: ui_extension 색 = `weatherClear #F5A623`·`weatherCloud #9B9B9B`(cloudy=overcast)·`weatherRain #356091`·`weatherDefault #4A90E2` = **디자인 4색을 헥스 그대로 사용(완전 충실)**. 아이콘 6종 distinct → 6종 전수 매핑·아이콘으로 전수 구별 = **G-7/N4 PASS**.
- **개정 후 판정**: **FC-1·FC-3 → ✅** · 치명 18 전부 PASS · 사전식 종료 해제 · **TIER-Q 산정** · 비교지 **무승부**(EVAL-METHOD '올바른 적용 교정=소급 아님').
- 아래 본문의 '색 6→4 붕괴·역-오라클·치명 FAIL' 서술은 **구판 기준 기록**으로 보존하되 판정은 이 배너가 우선. *색 팔레트의 디자인 일치*는 본래 **FID/A1 충실도** 소관(claude 충실·codex 이탈)이지 FC 결함이 아니었다.

## 0. 빌드 게이트

| ID | 판정 | 수확 근거 |
|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build`→`wrote 0 outputs`(재생성 일치=손작성 codegen drift 0)·`flutter analyze`→"No issues found!" |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze`(exit 0)·added 신규 이슈 0 |

## 1. 치명 게이트 (18 — 하나라도 ❌이면 픽스처 FAIL)

> FID-L1·L2는 이 런 `screenProbes` 미노출로 ➖(A1 폴백·치명 집계 제외·§0-6·RUBRIC §H). 따라서 이 런 치명 집계 = 18.

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 의미 3/3 PASS — 정렬 정규화가 애그리거트 루트 `weekly_forecast.dart:19-23 WeeklyForecast.fromDays(..sort(a.date.compareTo(b.date)))`·path 직렬화 VO `forecast_date.dart:21-25`·enum 매핑 `weather_condition.dart`. application/presentation에 `.sort/compareTo/where` 0(grep) |
| S-DDD | SD-2 | 루트 경유 변경 | ✅ | 의미 3/3 PASS(읽기전용이라 전이 부재·유일 정규화=루트 팩토리 거주). Model 밖 copyWith는 TextStyle 스타일링뿐(분기·전이 0) |
| S-DDD | SD-7 | UseCase 관문(UI호출 금지) | ✅ | `forecast_use_case.dart:17-24` arrow `=> _repo.get…()` Either 통과·새 throw 0·침묵 폐기 0·flutter/presentation import 0(IM12 결정 0) |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | `weekly_forecast_view.dart:21-44`·`daily_forecast_detail_view.dart:25-44` build=`.when` 디스패치·onTap=Navigator 위임만·정책 0 |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | 결정 grep static show/present/display·GlobalKey 0(`displayTemp` 토큰 false-positive만)·component 자기표시 static 0·ErrorFeedback=onRetry 콜백 prop |
| S-STATE | ST-1 | VM 책임 경계(직행 금지) | ✅ | 결정 IM7·IM12 exit 0 · 의미 VM Model호출=UseCase 인스턴스뿐·Repo/box/SDK/BuildContext 0(grep) |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회채널: VM fold Left `=>throw failure`(BadRequestResponse)→AsyncError→view `.when(error:ErrorFeedback)`. 액션채널 부재(읽기전용)·State에 死 error 필드 미보유 |
| S-STATE | ST-4 | ref 규율(mounted 가드) | ➖N/A | await→state 접근 경로 부재(build가 awaited fold 결과를 반환·state 재참조 0)·액션 메서드 0 |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | `weather_repo.dart:19·26 Future<Either<BadRequestResponse,T>>`·소비처 전부 Left 전달(UseCase 통과·VM fold Left→throw=AsyncError·no-op 아님) |
| S-DATA | DT-2 | 단일 출구·throw 금지 | ✅ | `safe_api_call.dart:14-47` 단일출구(DioException·FormatException·TypeError·catch-all 각 Left)·infra/repo throw·rethrow 0(grep, codegen 제외) |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | 백스톱 ST0·1·2·3 exit 0(blocker 0) |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | 백스톱 IM1·11·12·17·18·19 exit 0 |
| S-HR | HR-5 | 교차 BC 4채널만 | ✅ | 백스톱 IM5·CY1 exit 0(단일 BC·교차 0) |
| BUILD | BG-1 | 컴파일 가능 | ✅ | §0 |
| BUILD | BG-2 | analyze green 래칫 | ✅ | §0 |
| FC | FC-1 | 골든 오라클 | ✅ *(정정)* | **개정 골든 PASS** — 6종 전수 매핑·아이콘 6 distinct로 전수 구별. `weather_condition_ui_extension.dart:32-44` 색 = **디자인 4색 헥스 그대로**(`weatherCloud #9B9B9B`=cloudy=overcast=design Cool Grey·`weatherClear #F5A623`·`weatherRain #356091`·`weatherDefault #4A90E2`). cloudy=overcast 색 동일은 design_md 명시 충실(§68). 〔구판: 6색 distinct 위반으로 만장일치 FAIL — 골든 개정으로 무효〕 |
| FC | FC-2 | 테스트·메커니즘 비-vacuous | ✅ | 결정(조정자 주입): M1 정렬역전·M2 색swap·M3 기온슬롯swap·M4 날짜path 각 주입 시 전체 스위트 **RED**(4/4)·`.fcbak` 복원 검증 |
| FC | FC-3 | 도메인 정합(negative gate) | ✅ *(정정)* | **개정 N4 미관측** — 색 공유 2쌍(cloudy↔overcast·snow↔thunderstorm)은 아이콘이 distinct라 완전 미구별 아님(개정 N4: 아이콘 ∧ 색 *둘 다* 동일만 FAIL). 디자인이 묶은 색이라 위반 아님. N1~N7 전부 미관측 |

> **§3 사전식 집계 (정정)**: BG ✅ → **치명 18 전부 PASS**(FC-1·FC-3 개정 PASS) → 실질성 관문(SD-1 실판정 거주) 통과 → **TIER-Q 산정**. 〔구판: FC-1·FC-3 ❌로 픽스처 FAIL·종료 — 골든 개정으로 무효〕

## 2. 차원별 판정

### A. S-DDD (SD-1~9)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | §1 |
| SD-2 | 루트 경유 변경 | ✅ | §1(읽기전용·루트 팩토리 정규화 거주) |
| SD-3 | 불변식 도메인 예외 검증 | ➖N/A | VO 얇음(ForecastDate=직렬화 전용)·검증 발화 기능 부재 |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `ForecastDate`(직렬화 VO)·`DailyForecast`(엔티티) 도메인 형태·표시 누수 0 |
| SD-5 | 애그리거트 경계·참조 | ✅ | `WeeklyForecast`(루트)→`DailyForecast` 단일 경계·교차 참조 0 |
| SD-6 | 도메인서비스·specification 귀속 | ➖N/A | 교차 판정·도메인서비스 미발생(단일 정규화=루트) |
| SD-7 | UseCase 관문 | ✅ | §1 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/·port/·acl/·dto/ 폴더 0(백스톱 SD8/ST7) |
| SD-9 | 유비쿼터스 언어 철자 | ✅ | forecast·weather 일관(계층 관통 drift 0) |

### B. S-VIEW (VW-1~7)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | §1 |
| VW-2 | 3단 판별·과승격 금지 | ✅ | view→section→widget 3단·과승격 0(grader 3/3) |
| VW-3 | dumb 조각 계약 | ✅ | `forecast_tile_widget.dart` WidgetRef 미보유·prop(forecast·onTap)만(IM8·9 0) |
| VW-4 | 시각 토큰 단일 출처 | ✅ | `app_color`·`app_typography` 등 foundation 토큰 참조·시각 리터럴 누수 0(NM10·ST10) |
| VW-5 | ui_extension=매핑 유일 자리 | ✅ | enum→아이콘·색·라벨=`weather_condition_ui_extension.dart` 단독·dateLabel=`daily_forecast_ui_extension.dart`(표시 포맷)·VM/State 매핑 누수 0. ※거주는 적법(distinct는 FC-1 G-7 소관) |
| VW-6 | 표시 소유·show() 금지 | ✅ | §1 |
| VW-7 | 라우트 단일 출처·navigator 분업 | ✅ | path/name 리터럴=`weather_router.dart` WeatherRoutes·`WeatherNavigator`는 String만 운반·View import 0(IM10·20·21·22·NM13 0) |

### C. S-STATE (ST-1~9)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | §1 |
| ST-2 | 에러 2채널 | ✅ | §1(조회채널 정합·액션채널 N/A) |
| ST-3 | State 형태·노출 계약 | ✅ | application_layer @freezed State가 domain 래핑(`weekly_forecast_state`·`daily_forecast_detail_state`) |
| ST-4 | ref 규율 | ➖N/A | §1(await→state 경로 부재) |
| ST-5 | provider 형태·표기 | ✅ | class-form @riverpod·family build(String)(NM7·8 0) |
| ST-6 | SharedState·교차 BC | ➖N/A | 단일 BC(SCENARIO §4)·교차 watch 미발생 |
| ST-7 | root 합성 구조 | ➖N/A | root 합성 미발생(단일 BC) |
| ST-8 | 비채택(retry OFF·hooks·valueOrNull) | ✅ | hooks_riverpod·valueOrNull·copyWithPrevious 0(grep) |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | base/mixin VM 0 |

### D. S-DATA (DT-1~9)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | §1 |
| DT-2 | 단일 출구·throw 금지 | ✅ | §1 |
| DT-3 | BadRequestResponse 계약 | ➖N/A | baseline이 BadRequestResponse 제공·산출물 새 정의·확장 0(계약=baseline 소유) |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | `weather_data_source.dart` `Future<List<DailyForecast>>`·`Future<DailyForecast>` 직반환·DTO/매퍼 0(grader 3/3) |
| DT-5 | Repo/DataSource 형태 | ✅ | Repo 추상+impl·DataSource @RestApi(NM16·DI 정합) |
| DT-6 | retrofit DataSource 표기 | ✅ | `@RestApi`·`part`·factory 정합 |
| DT-7 | hive 로컬 캐시 | ➖N/A | 캐시 미사용(SCENARIO §4) |
| DT-8 | 계약 스냅샷 운용 | ✅ | 인용 path가 `server-contract.json` 동결본 실재(extract_contract) |
| DT-9 | infra service=수동 어댑터 | ➖N/A | SDK 어댑터 미사용(네트워크 전용) |

### E. S-HR (HR-1~9)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | 백스톱 ST0·1·2·3 |
| HR-2 | 종류 폴더·접미사 | ✅ | 백스톱 NM1·ST6 |
| HR-3 | 신규 골격 완비 | ✅ | 백스톱 ST4·실판정 거주(SD-1 PASS=빈혈 아님) |
| HR-4 | 계층 import 역류 금지 | ✅ | §1 |
| HR-5 | 교차 BC 4채널만 | ✅ | §1 |
| HR-6 | 파일·클래스 명명 | ✅ | 백스톱 NM2·3·11·15 |
| HR-7 | root/common/design_system 경계 | ✅ | 백스톱 IM2·3·4·6·13·15·16·ST7·8·10·11·NM12 |
| HR-8 | 화면 삼총사·section/widget 접두 | ✅ | 백스톱 NM4·5·6·실질 삼총사(view·vm·state) 거주 |
| HR-9 | 개념 1차·종류 2차 성장 | ✅ | 단일 개념 BC 종류 폴더 직속(정상) |

## 2.5 FID 시각 충실도 (구조) — ➖ A1 폴백

> ⚠️ **이 런 FID 자동 게이트 미작동**: 산출물 `_support.dart`/`screenProbes` 미노출(implementation-test §7 표준 pump 규약 미준수) → `fid-gate.sh` exit 3 → 렌더 덤프 불가. **L1~L3 ➖·구조 충실도도 A1(사용자 눈) 폴백**(coordinator 수기 게이트 흉내 금지·❌ 도장 금지). 시안 layout-ir(화면2·영역8)는 `ref-layout.json`에 보존(사용자 대조 재료). **9차 claude는 screenProbes 보유 → 11차 규약 회귀**(발견 로그).

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| FID-L1 | 구조 골격 충실도 | ➖ | screenProbes 미노출·A1 폴백 |
| FID-L2 | 섹션 구성 충실도 | ➖ | 동상 |
| FID-L3 | 말단 슬롯 정합 | ➖ | 동상(약신호) |
| FID-L4 | 픽셀·미관(아이콘 심볼) | ➖ | A1·사용자 눈(RUNBOOK `flutter run`·스크린샷) |

## 3. TIER-Q 등급 — **산정 자격 확보(치명 18 PASS)** *(정정)*

> 골든 개정으로 사전식 종료가 해제돼 등급 산정 가능. `flutter analyze` "No issues found!"·결정 게이트 clean·잔여흠 3건 모두 🟡(`ForecastDate.fromApiPath` 死표면·`state.forecast!` bang 역참조·`daily_forecast_ui_extension` 명세 외 신규) → **상~중 범위**. 정밀 Q-1~9 전개는 원채점이 사전식 FAIL로 종료해 미수행 — **무승부 판정(양 치명 18 PASS)엔 무영향**. 〔구판: 치명 FAIL로 미산정〕

## grader 패널 증거 (A3)

| grader | 계열 | 적대 여부 | raw verdict |
|---|---|---|---|
| X-semantic-1 | Claude | — | `20260620-1405-weather-graders-raw.md` |
| X-semantic-2 | Claude | — | 〃 |
| X-adversarial-3 | Claude | ✔ 적대 | 〃 |

| 차원 | grader 판정(3) | κ | split·비고 |
|---|---|---|---|
| 치명 의미 10(SD/VW/ST/DT) | ✅✅✅ (전부 PASS/NA) | 1.0 | 만장일치 |
| **FC-1 G-7** | ❌❌❌ | **1.0** | 만장일치 FAIL(색 6→4) |
| **FC-3 N4** | 관측❌·관측❌·관측❌ | **1.0** | 만장일치 위반 관측 |
| G-1~G-6·G-8 | ✅✅✅ | 1.0 | 정렬·7건·필드·탭내비·라벨 정합 |

> ⚠️ 비-Claude 오라클 미확보(전원 Claude 계열·동종 증언). 단 per-grader raw 영속 + κ 출력으로 blind 붕괴 적신호는 아님(만장일치+증거 동반).

### rubric 사각 신고 (A13 — 채점 미반영·다음 동결 입력)
| grader | 사각 신고 |
|---|---|
| X-sem-1 | RUBRIC에 ui_extension 색 매핑 **per-enum distinct** 강제 차원 부재(VW-5는 *거주*만·distinct는 FC골든만 보유). design-spec §4가 4색을 *의도 결정*으로 정당화 |
| X-sem-2 | **테스트가 골든 위반을 못박음** — `weather_condition_ui_extension_test.dart:44-49 expect(colors.length, 4)`가 6→4 붕괴를 정답으로 단언(green인데 골든 FAIL). RUBRIC 테스트품질 차원이 '외부 골든 위반 박제' 안티패턴 미포착 |
| X-adv-3 | 동(M2 색 swap mutation에도 4색군 구조 생존=역-오라클)·색 매핑 게으름 VW-5 비측정·명세-구현 파일 drift(daily_forecast_ui_extension 추가) HR 비포착 |

## 의미적 변종 / 백스톱-blind 메타 (측정의 주 산출물)

| 차원 | 결정 레인 | 의미 레인 | 종합 | 변종 유형 |
|---|---|---|---|---|
| FC-1/FC-3 | FC-2 비-vacuous PASS(M2 색 swap red) | **G-7/N4 FAIL**(6→4 색) | **치명 FAIL** | 골든 위반을 테스트가 green 박제(역-오라클·Goodhart) |
| SD-1 | 백스톱 전무 | domain 실판정 거주 PASS | ✅ | 빈 wrapper·누수 0 |

> **핵심**: 결정 레인(백스톱 0·analyze clean·FC-2 red)만 보면 통과로 오독될 수 있으나, **외부 골든 의미 레인이 색 6→4 붕괴를 잡아 치명 FAIL**. 게다가 산출물 자체 테스트가 그 위반을 불변식으로 고정 → 결정 게이트로는 영구 미포착(외부 골든 필수성 실증).

## 발견 로그
| # | 단계 | 도구 | 차원 | 내용 | 조기/말기 |
|---|---|---|---|---|---|
| 1 | G2후 채점 | grader×3 | FC-1·FC-3 | 색 6종→4(cloudy=overcast·snow=thunderstorm) 만장일치 FAIL | 말기 |
| 2 | G2후 채점 | grader(적대) | 테스트품질(A13) | ui_ext 테스트가 `colors.length==4` 단언=골든 위반 박제 | 말기 |
| 3 | FID 게이트 | fid-gate.sh | FID 규약 | screenProbes 미노출→A1 폴백(9차 대비 규약 회귀) | 말기 |
| 4 | 채점(긍정) | 코드 정독 | R1+R6 | 컬렉션 루트 `WeeklyForecast` @freezed+`fromDays` named factory(plain 탈출 0) | — |

## 잔여흠 원장 (치명 FAIL이라 등급 외·기록용)
| 차원 | 흠 | 심각도 | 근거 |
|---|---|---|---|
| DT/VO | `ForecastDate.fromApiPath` production 死표면(view는 toApiPath만·fromApiPath는 test에서만) | 🟡 | `forecast_date.dart:17-18`·grep |
| ST-3 | `DailyForecastDetailState.forecast` nullable + view `state.forecast!` bang 강제 역참조 | 🟡 | `daily_forecast_detail_view.dart:41` |
| 명세정합 | `daily_forecast_ui_extension.dart` 명세 §1.5 파일목록 외 신규(거주 적법·표시 포맷 단일출처) | 🟡 | grader 3/3 |

## 한 줄 요지

**claude 11차 = 치명 18 전부 PASS *(2026-06-20 골든 개정 정정)*** — 아키텍처 의미 10치명·골든 8/8·FC-2 비-vacuity 전부 PASS이고 **R6+R1~R4 검증 목표(컬렉션 루트 @freezed `WeeklyForecast.fromDays`+named factory·plain 탈출 0·백스톱 최종 0) 충족**. **색 6종→4는 결함이 아니라 디자인 4색 팔레트(#F5A623·#9B9B9B·#356091·#4A90E2) 정확 사용(완전 충실)**이며 cloudy=overcast 회색 동일은 design_md 명시 — 구판 골든이 디자인 미열람으로 FAIL 오판한 것을 개정·PASS. codex와 **무승부**(양 치명 18 PASS). 색 팔레트 디자인 충실도는 오히려 **claude 우위**(codex는 디자인 4색 미사용·임의 6색). 〔claude 테스트 `colors.length==4`는 역-오라클이 아니라 디자인 4색을 올바로 핀하는 정상 단언으로 재평가〕 (N=1·인과 단정 금지·FID 구조 A1 폴백)
