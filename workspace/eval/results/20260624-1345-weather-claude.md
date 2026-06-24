# 채점 결과지 — weather 18차 · claude (변종 X)

> **방법** EVAL-METHOD v3.2 · **채점일** 2026-06-24 · **환경** 라이브런=Claude Code(dddart 플러그인·생성 모델 세션)·채점=Opus·effort max · **variant** 단일(양판 비교는 `-compare`) · **산출물 루트** `/Users/hyun/Desktop/dddart-run/dddart-20260624-1345-claude`(working tree·HEAD `abee26d` 미커밋) · **baseline** `abee26d` · **코퍼스** `75dac05` **+ fix027 미커밋**(working tree — `dddart/agents/{design-architect,discipline-reviewer}.md`·codex 트윈 2 + feedback-027·산출물은 이 상태로 생성) · **코드젠** build_runner^2.15.0·freezed^3.2.6-dev.1·json_serializable^6.14.0·riverpod_generator^4.0.4·retrofit_generator^10.2.7(조정자 추가 0·`build_runner build` exit 0·git diff codegen 일치·손작성 0) · **task** SCENARIO-WEATHER §1 verbatim · **게이트 답** §4(풀모드·신규 BC weather·가장 간단·날짜 오름차순·6종 ui_extension) · **FC 골든** 사전등록 `FC-GOLDEN-WEATHER.md`(2026-06-14 동결·amend 06-20·코드 미열람) · **N_grader** 3(X-g1·g2·g3 적대)·**전원 Claude 계열·비-Claude 오라클 미확보(⚠️ 독립성 한계)** · **positive control** 통과(`tools/positive-control/`·단 **FID 섹션 병합 변종 미커버**·아래 §2.5) · **mutation 실측** M1·M2 주입→red 후 byte-clean 복원(`cp`) · **⚠️** N=1·인과 단정 금지·앵커=예시·소급 FAIL 금지·자기보고 불신(조정자 직접 검증)·**FID 게이트 활성**·시각 충실도: 구조(FID-L1·L2·L3) 측정 / 미관·아이콘 심볼(L4) 비측정(A1)·**구조·기능·FID-PASS ≠ 미관 시안 일치**

## 0. 빌드 게이트

| ID | 판정 | 수확 근거 |
|---|---|---|
| **BG-1** 컴파일 가능 | ✅ | `dart run build_runner build` exit 0 · 후속 `flutter analyze` "No issues found!" |
| **BG-2** analyze green 래칫 | ✅ | `flutter analyze` clean(added 신규 이슈 0) · `flutter test` 전 스위트 **+30 All tests passed** |

> 빌드 게이트 PASS → 치명 게이트로 진행.

## 1. 치명 게이트 (18 + FID-L1·L2)

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 의미 만장(g1·g2·g3): 정렬 불변식이 애그리거트 루트 팩토리 `weekly_forecast.dart:20-24 fromDays`(`..sort((a,b)=>a.date.date.compareTo(b.date.date))`)·한글 라벨 판정 domain enum `weather_condition.dart:22-37 label`. VM은 fold/변환만·specification import 0(g3 적대 무혐의) |
| S-DDD | SD-2 | 루트 경유 변경 | ➖ | 조회 전용·전이 메서드 0 → 미발화(NA) |
| S-DDD | SD-7 | UseCase 관문(UI호출 금지) | ✅ | `weather_use_case.dart:11-28` 무상태 plain·UI import 0(dartz/domain/repo만)·`map`으로 Either 통과(Left 보존)·새 throw 0·재export 사슬 무혐의(g3) |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | `weekly_forecast_view.dart:38-46` build=`state.when` 표시·위임만·정책 0 |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | design_system self-show static 0(g3 grep)·다이얼로그=view `context.pop()` 직접 호출·우회명(announce/popup) 0 |
| S-STATE | ST-1 | VM 책임 경계(직행 금지) | ✅ | `weekly_forecast_vm.dart:16` `WeatherUseCase()`만·Repo/box/SDK/Dio import 0·BuildContext·컨트롤러 0 |
| S-STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패=build `throw`(BadRequestResponse)→AsyncError·`vm_test.dart:45-53 throwsA(isA<BadRequestResponse>())` 검증·view `.when(error:)` 소비. 액션 채널 조회 전용 미발화·valueOrNull 0·침묵 폐기 0(g3) |
| S-STATE | ST-4 | ref 규율(mounted 가드) | ➖ | build 단일 await 후 state 재접근 0 → 미발화(NA) |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | repo `Future<Either<BadRequestResponse,T>>`·UseCase `map` Left 통과·VM `fold` Left→throw(no-op 아님·g3) |
| S-DATA | DT-2 | 단일 출구·throw 금지 | ✅ | repo/infra throw 0·`safeApiCall`로 Either·**fromJson 가드 `on Object`**·인터셉터 `handler.next(e)` 통과(정규화 0) |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | 백스톱 58종 blocker 0(ST0·1·2·3 exit 0) |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | 백스톱 IM 역류 ID exit 0·domain 순수 Dart |
| S-HR | HR-5 | 교차 BC 4채널만 | ➖ | 단일 BC weather·교차 import 0 → 미발화(NA) |
| BUILD | BG-1 | 컴파일 가능 | ✅ | (§0) |
| BUILD | BG-2 | analyze green 래칫 | ✅ | (§0) |
| FC | FC-1 | 골든 오라클 | ✅ | 의미 만장 — G-1~G-8 일치. 날짜 오름차순·탭→날짜 일치·기온 high/low·음수 부호·6종 distinct·**한글 라벨 §0 정확**(domain enum label clear=맑음·cloudy=구름많음·overcast=흐림·rain=비·snow=눈·thunderstorm=뇌우) |
| FC | FC-2 | 테스트·메커니즘 비-vacuous | ✅ | **조정자 mutation 실측: M1 정렬 역전→`weekly_forecast_test.dart` `-2 Some tests failed`(뒤섞은 입력)·M2 아이콘 swap→`weather_condition_ui_extension_test.dart` `+2 -2`(case별 전수 핀+distinct red)**. byte-clean 복원 |
| FC | FC-3 | 도메인 정합(negative gate) | ✅ | N1~N7 도메인 오류 0 |
| **FID** | **FID-L1** | **구조 골격** | **⚠️ 잠정 FAIL·치명 미적용** | 아래 §2.5 — detail 섹션 17차 2→18차 1 회귀이나 **positive-control 미커버 영역(섹션 병합)·measure-first 잠정** |
| **FID** | **FID-L2** | **섹션 구성** | **⚠️ 잠정 FAIL·치명 미적용** | 동상(§2.5) |

> **치명 18 전부 PASS → 픽스처 PASS.** ➖ 3건(SD-2·ST-4·HR-5) 조회 전용·단일 BC 미발화. **FID-L1·L2는 잠정 FAIL이나 치명 미적용**(positive-control 섹션 병합 변종 미반증·§2.5)·집계 18 불변. **16차 흠 VW-4·Q-6은 17차 해소 유지·fix021·022·024·025·026 적중 유지.**

## 2. 차원별 판정

### A. S-DDD
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | (§1) 정렬·라벨 domain 거주·VM 변환만 |
| SD-2 | 루트 경유 변경 | ➖ | 조회 전용·전이 0 |
| SD-3 | 불변식 도메인 예외 검증 | ➖ | 전이 메서드 0·`fromApiPath` parse-throw는 컨버터 경계 면제(safeApiCall 수렴) |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `forecast_date.dart` @freezed VO+`compareTo`/`toApiPath`·엔티티 freezed 직파싱 |
| SD-5 | 애그리거트 경계·참조 | ✅ | `WeeklyForecast`(루트)·`DailyForecast`(종속)·`fromDays` 팩토리 |
| SD-6 | 도메인서비스·specification 귀속 | ➖ | 단일 애그·교차 판정 0 |
| SD-7 | UseCase 관문 | ✅ | (§1) UI import 0·Either 통과 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/·port/·acl/·dto/·DI 컨테이너 0 |
| SD-9 | 유비쿼터스 언어 철자 | ✅ | `weekly_forecast`·`forecast_date` 계층 관통 동일 |

### B. S-VIEW
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | (§1) |
| VW-2 | 3단 판별·과승격 금지 | ✅ | section/widget prop·콜백만(ref 0)·view 삼총사 ref 사유 실재 |
| VW-3 | dumb 조각 계약 | ✅ | section/widget ref·provider import 0 |
| VW-4 | 시각 토큰 단일 출처 | ✅ | copyWith 전부 `color:` 토큰 오버라이드·fontSize/height/letterSpacing 리터럴 0(g1·g2·g3 만장·grep 실증)·**16차 `fontSize:18`→`tempSecondary` 토큰 승격(fix022 유지)**. width 96·icon size 36 등은 비-typography size prop 직접 인용(§8 정식·named const `_columnWidth`/`_iconSize`) |
| VW-5 | ui_extension 매핑 유일 자리 | ✅ | enum→UI(icon·color) `weather_condition_ui_extension.dart`에만·라벨은 domain enum(올바른 분리) |
| VW-6 | 표시 소유·show() 금지 | ✅ | (§1) |
| VW-7 | 라우트 단일 출처·navigator 분업 | ✅ | path/name 리터럴 `WeatherRoutes`에만·navigator 전역키 pushNamed 상수·view import 0·직렬화 VO `toApiPath` 소유 |

### C. S-STATE
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | (§1) UseCase만 |
| ST-2 | 에러 2채널 | ✅ | (§1) 조회 build throw→AsyncError·액션 미발화 |
| ST-3 | State 형태·노출 계약 | ✅ | `application_layer/state/` @freezed·자기 State·엔티티 필드 래핑·조회 전용 error 필드 생략 정합 |
| ST-4 | ref 규율 | ➖ | await 후 state 접근 0 미발화 |
| ST-5 | provider 형태·표기 | ✅ | `class …VM extends _$…` 클래스형·family build 인자·legacy 0(VM이 UseCase 직접 생성·함수형 provider 0·g3 무혐의) |
| ST-6 | SharedState·교차 BC | ➖ | 단일 BC 미발화 |
| ST-7 | root 합성 구조 | ✅ | root_vm/handler/initializer/rootRouter 규약 |
| ST-8 | 비채택(retry OFF·valueOrNull) | ✅ | `main.dart` retry OFF·valueOrNull 0·hooks 0 |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | 각 VM `_$VM`만 extends·공용 mixin 0 |

### D. S-DATA
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | (§1) |
| DT-2 | 단일 출구·throw 금지 | ✅ | (§1) fromJson 가드 `on Object` |
| DT-3 | BadRequestResponse 계약 | ✅ | `bad_request_response.dart` @freezed 3필드 errorType/msg/isShow·`@JsonKey('error_type'/'is_show')` snake·어휘 timeout/parse/unknown(safe_api_call)·클라 isShow:true(교과서 정석) |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | DataSource `Future<List<DailyForecast>>`·dto/Mapper 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | 인터페이스 없는 단일 구체·직접 생성(DI 0)·무상태 |
| DT-6 | retrofit DataSource 표기 | ✅ | @RestApi abstract+factory+part·@GET·엔티티 반환 |
| DT-7 | hive 로컬 캐시 | ➖ | 미사용(게이트 §4) |
| DT-8 | 계약 스냅샷 운용 | ✅ | server-contract 동결본 대조·404 계약위험 표기 |
| DT-9 | infra service = 수동 어댑터 | ➖ | SDK 어댑터 미사용 |

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
| HR-8 | 화면 삼총사·접두 | ✅ | vm↔view↔state 동거·section 화면 접두 |
| HR-9 | 개념 1차·종류 2차 성장 | ✅ | 단일 개념 BC 종류 폴더 직속 정상 |

## 2.5 FID 시각 충실도 (구조) — **게이트 활성·자동 측정 작동·잠정 FAIL·치명 미적용**

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| FID-L1 | 구조 골격(영역 존재·종류·순서) | ⚠️ **잠정 FAIL·치명 미적용** | 자동 게이트 작동(`screenProbes=Future<Finder>` 정상·`fid_dump_test` 컴파일·실행). 대조: list 시안=[appbar,section,bottomnav] 코드=[appbar,section]·누락=**bottomnav만**(사용자 무시 정책)·**detail 시안=[appbar,section,section,bottomnav] 코드=[appbar,section]·누락=section+bottomnav** — ★**detail 섹션 1개 누락**(hero를 `_DetailHero` private 위젯으로 흡수·`metrics_section.dart:128`·BackTitleAppBar는 정상 인식·**도구 거짓-FAIL 아님**). **17차 detail=2 *Section(HeroSection+MetricsSection)→18차 1 *Section 회귀**. 단 hero 콘텐츠 전부 실재(내용 손실 0)·**positive-control/fid가 "내용보존 섹션 병합" 변종을 거짓-FAIL 0으로 반증한 적 없음**(§6-1 section fallback *잠정*·EVAL §0-6 선결 미충족 영역) → §3.8/A12 "기계결함 미배제" 잠정 FAIL·치명 도장 보류 |
| FID-L2 | 섹션 구성(평탄화 시퀀스·repeat) | ⚠️ **잠정 FAIL·치명 미적용** | detail 섹션 수 코드1≠시안2(동상)·list 섹션#1 ✓ [repeat{text,icon,text}] |
| FID-L3 | 말단 슬롯(type·width·align) | ⚠️ | 슬롯 배치 차이(약신호·사용자 눈) |
| FID-L4 | 픽셀·미관(아이콘 심볼) | ➖ | A1 육안·**상세 카드 습도·강수확률 둘 다 `water_drop` 심볼 중복**(g1·g3 신고·혼동 가능)·실색 매핑 |

> **★중대(사용자 핵심 관심)**: claude는 17차 detail 2섹션(PASS)에서 **18차 1섹션으로 회귀**(hero를 별도 `*Section` 대신 `_DetailHero` private 위젯으로 통합). **픽스처 PASS는 "FID 게이트가 섹션 병합 변종을 아직 확정 못 함(positive-control 미커버·measure-first)"이지 "시안대로 그렸다"가 아니다** — 구조 충실도는 17차보다 후퇴. **육안 확인 권장.** 다음 동결 입력: positive-control/fid에 "내용보존 섹션 병합" 변종 추가 → 거짓-FAIL인지 정탐인지 확정 후 치명화 여부 결정.

## 3. TIER-Q 등급

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | analyze green·lowerCamel/UpperCamel |
| Q-2 | freezed 표기 | ✅ | 새 리터럴+copyWith·소진 switch |
| Q-3 | dartz Either 표면 | ✅ | Either/Left/Right/fold/map만 |
| Q-4 | null 안전 관용구 | ✅ | analyze green·`!` 연쇄 0 |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey·@JsonValue |
| Q-6 | catch 위생 | ✅ | runZonedGuarded onError 위임(fix021 유지)·빈 catch 0 |
| Q-7 | 잔여 구조 스멜 | ✅ | 죽은 코드 0·매직넘버 named const화(`_columnWidth`·`_heroIconSize` 등 시안 §8.1 주석)·**press 효과 `AnimatedScale scale:0.98`(`_MetricCard:263`) + fadeIn 실구현**(죽은토큰 0·g2·g3) |
| Q-8 | import 정렬·주석 형식 | ✅ | analyze green |
| Q-9 | flutter 내비 표기 | ✅ | pushNamed·go 규약 |

> **TIER-Q 등급 = 상** (WEAK 0·FAIL 0·17차 유지). 적대 X-g3 8축 전부 무혐의.

## grader 패널 증거 (raw = `-graders-raw.md`)

| grader | 계열 | 적대 | 비고 |
|---|---|---|---|
| X-g1 | Claude | – | 치명 11 PASS·비치명 전 PASS/NA·사각: water_drop 중복·ST-2 채널② NA 근거 |
| X-g2 | Claude | – | 치명 11 PASS·VW-4 fix022 적중 grep 실증·FC-1 라벨 domain 거주 |
| X-g3 | Claude | ✅ | **8축 전부 무혐의**(빈wrapper·Left no-op·우회 self-show·침묵폐기·판정누수·재export·FC디코이·함수형위장)·FID 의미 밖 |

| 차원 | 판정(3) | κ | 비고 |
|---|---|---|---|
| 치명 11 의미 | ✅✅✅ | 1.0 | 만장 PASS |
| FC-2 | ✅(실측)·✅·✅ | 1.0 | M1·M2 red 실측 |
| VW-4 | ✅✅✅ | 1.0 | fix022 유지·fontSize 리터럴 0 |
| Q-7 | ✅✅✅ | 1.0 | press 구현·죽은토큰 0 |
| 비치명 나머지 | ✅/➖ 만장 | 1.0 | WEAK 0 |

> **비-Claude 오라클 미확보**(헤더 ⚠️). FC-2는 조정자 결정 레인 실측(M1·M2 red)으로 독립 확증.

## 의미적 변종 / 백스톱-blind 메타

| 차원 | 결정 레인 | 의미 레인 | 종합 | 변종 유형 |
|---|---|---|---|---|
| VW-4 | grep 생 리터럴 0·copyWith color-only | g1·g2·g3 fontSize/height/letterSpacing 0 | ✅ | fix022 유지(16차 fontSize:18 해소) |
| FC-2 | M1·M2 red 실측 | case별 전수 핀+distinct | ✅ | 비-vacuous |
| **FID-L1·L2** | fid-gate exit 2(섹션 1≠2) | (결정 전담·의미 밖) | ⚠️잠정 | **섹션 병합 회귀(17차 2→1)·positive-control 미커버 영역·치명 미적용** |

## 발견 로그

| # | 단계 | 도구 | 차원 | 내용 |
|---|---|---|---|---|
| 1 | G2직전 | build_runner·analyze | BG | exit 0·No issues·flutter test +30 green |
| 2 | G2직전 | 백스톱 58종 | HR·ST·IM·NM·CY | exit 0·blocker 0 |
| 3 | G2직전 | fid-gate.sh | FID | exit 2·**detail 섹션 1≠2(17차 2섹션 회귀)**·list bottomnav만·자동 게이트 작동 |
| 4 | G2직전 | 조정자 mutation 실측 | FC-2 | M1 `-2`·M2 `+2-2` red(byte-clean 복원) |
| 5 | 정독 | FID 적대 4렌즈(`wf_9b5feecb`) | FID | claude detail=진짜 1섹션(도구 변명 0)·positive-control 미커버→잠정 FAIL·치명 미적용 |
| 6 | 정독 | grader g1·g2·g3 | 전 차원 | 치명 11 PASS·비치명 WEAK 0·적대 8축 무혐의 |

## 잔여흠 원장 (치명 PASS 후)

| 차원 | 흠 | 심각도 | 근거 |
|---|---|---|---|
| **FID-L1·L2** | **detail 섹션 17차 2→18차 1 병합 회귀**(hero를 _DetailHero private로) | ⚠️ 잠정·치명 미적용 | positive-control 미커버 영역·measure-first·**육안 권장**·구조 17차 후퇴 |
| FID-L4 | 상세 카드 습도·강수확률 `water_drop` 심볼 중복 | ➖A1 | 사용자 육안(혼동 가능) |

## 한 줄 요지

claude 산출물은 **치명 게이트 18 전부 PASS → 픽스처 PASS**(치명 의미 FAIL 0·적대 8축 무혐의)·**TIER-Q 상(WEAK 0)**·fix021·022·024·025·026 적중 유지. **★단 FID-L1·L2 잠정 FAIL** — detail을 17차 2섹션(hero+metrics)에서 **18차 1섹션으로 병합 회귀**(hero를 `_DetailHero` private 위젯으로). positive-control이 "내용보존 섹션 병합" 변종을 미반증한 영역(§0-6·measure-first)이라 치명 미적용·잠정이나, **픽스처 PASS는 "게이트 미확정"이지 "시안대로"가 아니다 — 구조 충실도 17차 후퇴·육안 확인 권장.** *N=1·우열 단정 금지(양판 비교는 `-compare`).*
