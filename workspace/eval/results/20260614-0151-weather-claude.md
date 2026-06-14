# weather-claude 채점 결과 [❌ FAIL — FC-2 테스트 0개(치명·결정) · 구조·MVVM·데이터·품질은 청결 · 정렬 부재(미문서화)]

> **방법** EVAL-METHOD v3.1(결정∥의미 레인·사전식 집계·치명17·백스톱 매핑) · **채점일** 2026-06-14 01:51 · **산출물 루트** `/Users/hyun/Desktop/dddart-run/dddart-20260613-2310-claude`(HEAD `7ac4aa8` "G2 승인") · **variant** claude (단일·codex 결과 비회람 — graders blind) · **baseline 커밋** `abee26d`(순정 민낯 Flutter 3.44.1·dio·riverpod·common/network 미설치) · **코퍼스 커밋** `676e317`(claude `dddart@dddart-dev` user scope·캐시 `73e75ca` era·산출 시점 Jun 14 ~01:08; *오늘 codex SKILL 보강은 claude 무관*) · **모델/effort** Claude(plugin 캐시·effort 미상) · **N_grader** 5(의미 4축 + FC·적대 1 — 정본 N≥3·적대 1 충족) · **태스크** SCENARIO-WEATHER §1 claude 프롬프트 verbatim · **게이트답** §4(풀모드·신규 `weather` BC·OpenAPI URL·Stitch MCP·G1 "가장 간단하게") · **범례** ✅PASS ❌FAIL 🟡WEAK ⏸️보류 ➖N/A
> **⚠️ 단서**: N=1·**인과 단정 금지** · **앵커=예시** · **소급 FAIL 금지** · **자기보고 불신**(조정자 직접 백스톱·analyze·build_runner 검증; coder "완료" 불신) · 단일 런(변종 마스킹 N/A·graders는 결정 레인·codex 결과 미수령 독립 판정).
> **코드젠 도구 환경(§6.2)**: **produced**(코더 핀·`git diff abee26d`) = dio ^5.9.2·flutter_riverpod ^3.3.2·riverpod_annotation ^4.0.3·retrofit ^4.9.2·dartz ^0.10.1·go_router ^17.3.0·freezed_annotation ^3.1.0 + dev: build_runner ^2.15.0·freezed ^3.2.6-dev.1·retrofit_generator ^10.2.6·riverpod_generator ^4.0.4 (codex와 달리 json_serializable/json_annotation 명시 핀 없음 — 전이 의존으로 빌드 성공) · **env** = flutter 3.44.1/dart 3.12 · **조정자 추가 0** · **테스트 도구 핀 0**(mockito는 transitive). · **used** = codegen 4종 실사용.
> **런-정지(§2.6.3)**: 소스 working tree **clean**(HEAD `7ac4aa8`·`git status` 0) · `ios/Flutter/ephemeral`·`android/.gradle` 01:41 = 빌드 툴링 캐시(사용자 런타임 드라이브·소스 아님) · 채점 착수 01:43~01:51 · **미래 mtime 0(소스 기준) = 표적 정지 확인**.
> **FC 골든 사전등록**: `tools/FC-GOLDEN-WEATHER.md`(작성 2026-06-14 01:13·코드 미열람·codex/claude 공통 — 시나리오 동일) · 골든 8·mutation 5·negative-gate 7.

---

## 종합 판정 (사전식 집계)

| 단계 | 결과 |
|---|---|
| ① 빌드 게이트(BG-1·BG-2) | ✅ **PASS** — `build_runner build` 성공·codegen 진정(드리프트=provider hash 2줄뿐)·`flutter analyze` **No issues found!**·added 신규 이슈 0 |
| ② 치명 게이트(17) | ❌ **FAIL** — **FC-2 테스트 0개(치명·결정적·N/A 금지)**. 그 외 14개 ✅ PASS, SD-2 ➖(전이 부재). FC-1·FC-3(정렬)도 골든상 FAIL(코덱스와 공통 쟁점·아래 §F-2) |
| ②.5 실질성 관문 | ✅ degenerate 0 — 읽기-표시 도메인이라 판정 희박이 정당(enum 분류 `weather_condition.dart:9-23` 거주)·빈 골격 아님. 단 **FC-2 비-vacuous 입증 불가**(테스트 0) |
| ③ 비치명·의미변종 | ✅ 의미적 변종 **0**(적대 그레이더 12 치명 의미항목 **0/12 무력화**) · WEAK 0 |
| ④ TIER-Q 등급 | ✅ **상** (Q-1~9 전수 PASS) — *단 ②가 FAIL이라 픽스처 전체 FAIL(이하 결함 기록용·§3)* |

**종합 = ❌ FAIL** — **결정적 사유 = FC-2 테스트 0개**(`test/` 디렉토리 완전 비어 있음·기본 widget_test.dart 삭제·EVAL-METHOD §2.5 "테스트 0개면 즉시 FAIL·N/A 금지"). 이는 정렬 판단과 **무관한 독립 치명 FAIL**이다. 부수적으로 FC-1·FC-3 날짜 정렬도 부재(§F-2).

**한 줄 요지**: claude도 **순정 민낯에서 dio·common/network·design_system·4계층 weather BC를 자력 빌드**(백스톱 51종 0위반·analyze clean·구조/MVVM/데이터/품질 전 축 청결·적대 0/12 무력화)했으나, **테스트를 한 개도 쓰지 않아(test/ 공백·widget_test 삭제) FC-2 치명 FAIL → 전체 FAIL**. 날짜 오름차순 정렬도 부재하며 codex와 달리 **설계 문서에 정렬 언급조차 0**(미문서화 누락).

---

## 0. 빌드 게이트

| ID | 항목 | 결정 명령·근거 | 종합 | 치명 |
|---|---|---|---|---|
| **BG-1** 컴파일 가능 | `dart run build_runner build` 성공·재생성 드리프트=`weather_detail_vm.g.dart`·`weather_list_vm.g.dart` provider hash 2줄(benign·손작성 0)·`flutter analyze` error 0 | ✅ | ✅ |
| **BG-2** analyze green 래칫 | `flutter analyze` → **No issues found! (ran in 1.2s)**·added 신규 0 | ✅ | ✅ |

## 1. 치명 게이트 (17)

| 치명ID | 결정 | 의미 | 종합 | 근거(file:line) |
|---|---|---|---|---|
| **SD-1** 판정 소유 | ➖ | ✅ | ✅ | 유일 판정(condition 분류) enum 거주 `weather_condition.dart:9-23`(@JsonValue+unknownEnumValue)·VM fold 변환만 `weather_list_vm.dart:17-22`. 누수·빈 wrapper·과잉투입 0(적대 무력화 실패) |
| **SD-2** 루트 경유 변경 | ➖ | ➖ | ➖ | 전이·갱신 부재(읽기전용) `daily_forecast.dart:15`·Model 밖 copyWith 0 — 미발화 N/A |
| **SD-7** UseCase UI호출 | ✅ | ✅ | ✅ | `daily_forecast_use_case.dart:13-24` 무상태·Either 통과·UI(material/presentation/design_system) import 0·새 throw 0 |
| **VW-1** Fat Widget | ➖ | ✅ | ✅ | build `.when`+표시·위임만 `weather_list_view.dart:29-53`·정책 0 |
| **VW-6** show() 금지 | ➖ | ✅ | ✅ | 자기표시 static 0·에러는 View 자기 context 인라인 `_ErrorBody` `weather_list_view.dart:31-32` |
| **ST-1** VM 직행 | ✅ | ✅ | ✅ | VM이 `DailyForecastUseCase()`만 `weather_list_vm.dart:13-14`·Repo/box/SDK/BuildContext 0 |
| **ST-2** 에러 2채널 | ✅ | ✅ | ✅ | 조회 build `fold((error)=>throw error)`→`BadRequestResponse` throw→AsyncError `weather_list_vm.dart:17-22`·valueOrNull 0·액션 채널 N/A(읽기전용) |
| **ST-4** mounted 가드 | ✅ | ✅ | ✅ | await가 build 내만·직후 fold 반환·state 재접근 0 → 가드 불요(누락 아님) |
| **DT-1** Either 실패 계약 | ✅ | ✅ | ✅ | Repo `weather_repo.dart:20,25` `Future<Either<BadRequestResponse,T>>`·소비처 fold Left throw 전달(no-op 아님) |
| **DT-2** 단일 출구 | ✅ | ✅ | ✅ | `safe_api_call.dart:12-49`(Dio·Format·Type 개별+catch-all)·Repo/UseCase throw 0·인터셉터 정규화 0 |
| **HR-1** 4계층·BC | ✅ | — | ✅ | 백스톱 ST0-3 0위반·`application/weather/` 4계층·직속 2파일 |
| **HR-4** import 역류 | ✅ | — | ✅ | 백스톱 IM 0위반·매트릭스 위반 0 |
| **HR-5** 교차 BC 4채널 | ✅ | ➖ | ✅ | 백스톱 IM5·CY1 0위반·단일 BC·교차 0·순환 0(`0f71729` VM 단방향 복원) |
| **BG-1** 컴파일 | ✅ | — | ✅ | (§0) |
| **BG-2** analyze green | ✅ | — | ✅ | (§0) |
| **FC-1** 골든 오라클 | — | ❌ | ❌ | **G-1(날짜 오름차순) FAIL** — 정렬 grep 0·서버 배열순 직표시 `weather_list_view.dart:36-42`. G-2~G-8 7건 PASS. (정렬 쟁점=§F-2·codex와 공통) |
| **FC-2** 비-vacuous | ❌ | — | ❌ | **테스트 0개**(`test/` 완전 비어·`find *_test.dart` 0건·기본 widget_test.dart 삭제). EVAL-METHOD §2.5 "테스트 0개=즉시 FAIL·N/A 금지" → **결정적 치명 FAIL** |
| **FC-3** 도메인 정합 | — | ❌ | ❌ | **N2(날짜 순서)** 위반(정렬 부재)·N1·N3~N7 통과. FC-1 G-1과 동일 근원 |

> **치명 종합**: ❌ **FAIL** — FC-2(0 테스트·결정적·정렬 무관)·FC-1·FC-3(정렬). 그 외 14 PASS + SD-2 정당 N/A. **FC-2 단독으로 픽스처 FAIL 확정**(§3 사전식 step 2).

## 2. 차원별 판정 (TIER-S 척추)

### A. S-DDD (SD-1~9)

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| SD-1 판정 소유 | condition 분류 enum 거주 `weather_condition.dart:9-23`·VM 변환만 | ➖ | ✅ | ✅ | ✅ |
| SD-2 루트 경유 변경 | 전이·갱신 부재(읽기전용) `daily_forecast.dart:15` | ➖ | ➖ | ➖ | ✅ |
| SD-3 불변식 도메인 예외 | exception·전이 메서드 부재·생성검증 직파싱차단 0 `daily_forecast.dart:31` | ➖ | ➖ | ➖ | — |
| SD-4 VO·엔티티 형태 | `daily_forecast.dart:16-33` @freezed+json 직파싱·VO 폴더 빈(읽기전용 불요)·`_windSpeedFromJson:35-39` num→double 방어 | ✅ | ✅ | ✅ | — |
| SD-5 애그리거트 경계 | 단일 애그루트 `daily_forecast.dart:17`·독립 엔티티 0 | ✅ | ✅ | ✅ | — |
| SD-6 도메인서비스·spec | `domain_service/`·`specification/` .gitkeep 빈·교차 판정 부재 | ➖ | ➖ | ➖ | — |
| SD-7 UseCase 관문 | `daily_forecast_use_case.dart:13-24` 무상태·Either 통과·UI import 0 | ✅ | ✅ | ✅ | ✅ |
| SD-8 비채택 패턴 | event/port/acl/dto 0·Repo 추상 0(`weather_repo.dart:14` 단일 구체)·DI 0 | ✅ | ✅ | ✅ | — |
| SD-9 유비쿼터스 언어 | `daily_forecast` 철자 domain/infra/state/presentation 관통 일관 | ✅ | ✅ | ✅ | — |

### B. S-VIEW (VW-1~7)

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| VW-1 Fat Widget | build `.when`+위임만 `weather_list_view.dart:29-53` | ➖ | ✅ | ✅ | ✅ |
| VW-2 3단 판별·과승격 | section 2·widget=StatelessWidget(prop+콜백)·view=ConsumerWidget | ➖ | ✅ | ✅ | — |
| VW-3 dumb 조각 | section/widget ref·provider import 0·prop/콜백 | ✅ | ✅ | ✅ | — |
| VW-4 시각 토큰 단일 출처 | App* 토큰(`app_color.dart:13-34`)·생리터럴 0·VM/State 시각 getter 0 | ✅ | ✅ | ✅ | — |
| VW-5 ui_extension 매핑 | enum→아이콘/색/라벨 `weather_condition_ui_extension.dart:11-54`만·VM/State 누수 0 | ➖ | ✅ | ✅ | — |
| VW-6 show() 금지 | 자기표시 static 0·View context 인라인 `_ErrorBody` | ➖ | ✅ | ✅ | ✅ |
| VW-7 라우트 단일 출처 | 리터럴 `weather_router.dart:7-16` `WeatherRoutes`만·navigator pushNamed·view import 0 | ✅ | ✅ | ✅ | — |

### C. S-STATE (ST-1~9)

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| ST-1 VM 책임 경계 | VM이 `DailyForecastUseCase()`만 `weather_list_vm.dart:13-14`·BuildContext 0 | ✅ | ✅ | ✅ | ✅ |
| ST-2 에러 2채널 | build throw `BadRequestResponse`→AsyncError `:17-22`·valueOrNull 0·액션 채널 N/A | ✅ | ✅ | ✅ | ✅ |
| ST-3 State 형태·노출 | `weather_list_state.dart:12-18` @freezed·자기 State 반환·error 필드 | ✅ | — | ✅ | — |
| ST-4 ref 규율(mounted) | await build 내만·fold 즉시 반환·state 재접근 0 → 가드 불요 | ✅ | ✅ | ✅ | ✅ |
| ST-5 provider 형태 | `@riverpod class extends _$X`·detail family build 인자·legacy 0 | ✅ | ✅ | ✅ | — |
| ST-6 SharedState·교차 BC | 단일 BC·`shared_state/.gitkeep`·타 BC watch 0 — 미발화 | ➖ | ➖ | ➖ | — |
| ST-7 root 합성 | `root/scaffold/**` .gitkeep 미변경·`root_router.dart:9` plain 전역 | ➖ | ➖ | ➖ | — |
| ST-8 비채택(retry OFF) | `main.dart:17` `retry:(retryCount,error)=>null`·hooks/valueOrNull 0 | ✅ | ✅ | ✅ | — |
| ST-9 base VM 금지 | 각 VM `_$X`만 extends·공용 mixin 0 | ✅ | ✅ | ✅ | — |

### D. S-DATA (DT-1~9)

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| DT-1 Either 실패 계약 | `weather_repo.dart:20,25` `Future<Either<BadRequestResponse,T>>`·fold Left throw 전달 | ✅ | ✅ | ✅ | ✅ |
| DT-2 단일 출구 | `safe_api_call.dart:12-49`·Repo/UseCase throw 0·인터셉터 정규화 0 | ✅ | ✅ | ✅ | ✅ |
| DT-3 BadRequestResponse 계약 | `bad_request_response.dart:11-15` 신규 정의·3필드·JSON error_type/is_show·클라생성 isShow:true | ✅ | ✅ | ✅ | — |
| DT-4 DTO 없음·엔티티 직반환 | `weather_data_source.dart:16,21` 엔티티 직반환·dto/Mapper 0 | ✅ | ✅ | ✅ | — |
| DT-5 Repo/DataSource 형태 | `weather_repo.dart:14` 단일 구체·무상태·직접 생성·DI 0 | ✅ | ✅ | ✅ | — |
| DT-6 retrofit 표기 | `weather_data_source.dart:11-13` @RestApi+factory+part·@GET/@Path·Future<엔티티> | ✅ | — | ✅ | — |
| DT-7 hive 로컬 캐시 | hive·@HiveType 0 — 미발화 | ➖ | ➖ | ➖ | — |
| DT-8 계약 스냅샷 운용 | 인용 path `/api/v1/weather/`·`/{forecast_date}/` `data_source.dart:15,20`·코드 "위험-1~5" 주석 가정 정합 (extract_contract 정식 미실행) | ✅ | 🟡 | 🟡 | — |
| DT-9 infra service 어댑터 | `service/.gitkeep`·SDK 어댑터 0 — 미발화 | ➖ | ➖ | ➖ | — |

### E. S-HR (HR-1~9)

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| HR-1 4계층·BC 컨테이너 | 백스톱 ST0-3 0위반·`application/weather/` 4계층·직속 2파일 | ✅ | — | ✅ | ✅ |
| HR-2 종류 폴더·접미사 | `_vm`·`_repo`·`_state`·`_data_source` 화이트리스트+접미사 일치 | ✅ | — | ✅ | — |
| HR-3 신규 골격 완비 | 종류 폴더 .gitkeep(domain_service·entity·value_object·specification·service·shared_state)·애그루트 | ✅ | — | ✅ | — |
| HR-4 계층 import 역류 | 백스톱 IM 0위반·매트릭스 위반 0 | ✅ | — | ✅ | ✅ |
| HR-5 교차 BC 4채널 | 백스톱 IM5·CY1 0위반·단일 BC·교차 0·순환 0 | ✅ | ➖ | ✅ | ✅ |
| HR-6 파일·클래스 명명 | 파일명=클래스 1 public·구접미사 0·foundation App접두 | ✅ | — | ✅ | — |
| HR-7 root/common/design_system 경계 | common 5폴더·`date_format_util.dart`는 plain(`:13` `forecast_date`는 doc 주석뿐·결합 0)·design_system→application/root import 0·root import=main.dart만 | ✅ | ✅ | ✅ | — |
| HR-8 화면 삼총사·접두 | `weather_list_vm`↔`view`+`state` 동거·section 화면 접두·widget `daily_forecast_row`(애그명·화면명 아님) | ✅ | ✅ | ✅ | — |
| HR-9 개념 1차·종류 2차 성장 | 단일 개념 `daily_forecast/` 직속·infra 미분할 | ✅ | ✅ | ✅ | — |

## 3. TIER-Q 등급 (카운트)

| ID | 종합 | 근거(file:line) |
|---|---|---|
| Q-1 명명 케이싱 | ✅ | SCREAMING_CAPS 0·enum lowerCamel·bool 긍정형(`isShow`·`isInteger`) |
| Q-2 freezed 표기 | ✅ | `.when`은 AsyncValue.when(표준 API)·State 단일생성자(union 아님)·when/map 금지대상 무관 |
| Q-3 dartz Either 표면 | ✅ | Right/Left·fold Left 첫인자 `weather_list_vm.dart:17`·fpdart 0 |
| Q-4 null 안전 관용구 | ✅ | promotion·null 가드·`!`는 라우트 보장 단발 `weather_router.dart:31` |
| Q-5 직렬화 표기 | ✅ | @JsonKey 생성자 부착 `daily_forecast.dart:23-28`·enum @JsonValue+unknownEnumValue·custom top-level |
| Q-6 catch 위생 | ✅ | on절 구체+catch-all=safeApiCall 의도 폴백(면제)·무차별 catch 0 |
| Q-7 잔여 구조 스멜 | ✅ | 죽은 코드 0·잔여 리터럴(`size:96`·`width:72`)는 위젯 치수(VW-4 소관 밖)·플래그 인자 0 |
| Q-8 import 정렬·주석 | ✅ | dart→package→상대 구획·알파벳·`/* */` 0·/// 양식 |
| Q-9 flutter 내비 표기 | ✅ | pushNamed 상수·GoRoute builder·redirect 미사용 |

**TIER-Q = 상** (PASS 9 / WEAK 0 / FAIL 0). *단 ②FAIL이라 픽스처 전체 FAIL(이 등급은 결함 기록용).*

## 의미적 변종 / 백스톱-blind 메타 (EVAL-METHOD §2.4)

- **의미적 변종 `[결정✅ ∧ 의미❌]` = 0건.** 적대 그레이더가 치명 12 의미항목 무력화 시도 → **0/12 성공**(빈혈·디코이·Left no-op·침묵 폐기·show() 우회·fat build·정렬역전·최고최저 뒤바뀜·탭날짜 불일치 전부 부재). 실질 리스크가 전부 **결정/실행 레인**(FC-2 테스트 0·정렬 서버의존·DioClient 하드코딩)으로 이동.

## 갭 원장 (민낯 측정 — `git diff abee26d` 전량)

- **규모**: 72 파일 / +10,167 / −142. lib/ 실코드 .dart **33**(codex 30 + α 유사)·**테스트 0**(codex 9).
- **자력 부트스트랩**: dio·flutter_riverpod·retrofit·dartz·go_router·freezed + dev codegen 자력 추가(codex와 동등 — 단 json_serializable/json_annotation 명시 핀 없이 전이 의존). common/network(dio_client·safe_api_call·bad_request_response)·design_system foundation 7+theme 자력 생성.
- **weather BC**: domain(애그리거트 `daily_forecast`+enum `weather_condition` **2개만** — codex의 `forecast_date` VO·`daily_forecast_summary` 엔티티 **부재**·더 얇은 도메인)·infra(data_source·repo)·application(state 2·use_case·VM 2)·presentation(view 2·section 2·widget 1·ui_extension 2)·router/navigator. 날짜 포맷은 `common/util/date_format_util.dart`(codex는 VO 내장).
- **테스트 0**: `test/` 완전 비어 있음·기본 widget_test.dart 삭제 → **FC-2 결정적 치명 FAIL의 직접 원인**.

## 발견 로그

- **§F-1 [치명·결정적] 테스트 0개.** `test/` 디렉토리 완전 비어 있음(`find *_test.dart` 0건·기본 `widget_test.dart` `deleted file mode`). EVAL-METHOD §2.5/RUBRIC FC-2: "테스트 0개=비-vacuous 입증 불가=즉시 치명 FAIL(N/A 금지)". **정렬 판단과 무관한 독립 치명 FAIL** → 픽스처 FAIL 확정. *민낯 핵심 수확: claude 코퍼스/파이프라인이 G2에서 테스트를 강제하지 못했다(코드는 green·구조 완비인데 테스트 산출 0).* → 코퍼스 교정 후보(G2 테스트 산출 게이트 강화).
- **§F-2 [치명·codex 공통] 날짜 오름차순 정렬 부재 + 미문서화.** 정렬 grep 0(`sort/compareTo/isBefore/reversed`)·서버 배열순 직표시 `weather_list_view.dart:36-42`. 실서버(`kingdom-server forecast_data.py:22` `range(7)`)는 결정적 오름차순이라 런타임 정확하나, 계약에 ordering 보증 없음. **codex와 달리 claude는 design-spec·scope에 정렬 언급이 0**(codex는 "server-owned / 계약 위험" 명시) — 설계 단계 누락. 정렬 판정(엄격 FAIL / 관대 PASS+WEAK)은 codex와 동일 쟁점이나, **FC-2가 이미 결정적 FAIL이라 claude 종합 판정에는 영향 없음**.
- **§F-3 [비치명] DioClient baseUrl 하드코딩.** `dio_client.dart:11` `baseUrl: 'https://kingdom-h.com'` 하드코딩(환경 분리 0). codex는 `String.fromEnvironment`+default 사용. Q/HR-7 잡음(비치명).
- **§F-4 [구조 관찰] 도메인이 codex보다 얇음.** claude domain = 애그리거트+enum 2개. codex는 `forecast_date` VO(검증 거주)+`daily_forecast_summary` 엔티티(목록/상세 분리) 보유. 둘 다 SD-1 PASS(읽기전용이라 판정 희박 정당)이나 모델 표현력에서 codex가 더 풍부.

## 잔여흠 원장 (FAIL이지만 기록)

| 흠 | 위치 | 심각도 | 비고 |
|---|---|---|---|
| **테스트 0개** | `test/` | **치명** | FC-2 FAIL 직접 원인 — 전체 FAIL 결정 |
| 정렬 부재·미문서화 | weather BC 전역 | 중 | 서버 오름차순 의존·design-spec 무언급(codex보다 악화) |
| DioClient baseUrl 하드코딩 | `dio_client.dart:11` | 경미 | 환경 분리 0 |
| extract_contract 정식 미실행 | DT-8 | 경미 | path 실재·시나리오 정합 확인·정식 exit 미실행 |

## 한 줄 요지

❌ **claude FAIL** — 구조·MVVM·데이터계약·하우스룰·품질은 codex와 동급으로 청결(백스톱 0·analyze clean·치명 14 PASS·적대 0/12 무력화·TIER-Q 상)하나, **테스트를 한 개도 산출하지 않아 FC-2 치명 FAIL(결정적·정렬 무관)** → 픽스처 전체 FAIL. 추가로 날짜 정렬 부재(codex 공통·단 claude는 설계 문서 무언급).

---

> **codex 대비(예비 — 정식 비교 집계지는 정렬 판정 후)**: codex=테스트 9파일/26개(FC-2 방어)·도메인 풍부(VO+summary)·정렬 "계약 위험" 표기 → 종합 ⏸️보류(정렬 판정 대기). claude=테스트 0(FC-2 치명 FAIL)·도메인 얇음·정렬 미문서화 → 종합 ❌FAIL. **핵심 갈림 = 테스트 산출 여부**(codex 작성·claude 미작성). 정렬 쟁점은 양판 공통.
> **미완(채점 재개 시)**: ① 정렬 판정(§F-2) — codex FC-1/3 확정용(claude는 FC-2로 이미 FAIL) ② codex FC-2 mutation 실행 ③ 두 안 비교 집계지(`20260614-XXXX-weather-compare.md`) ④ 코퍼스 교정 후보: claude G2 테스트 산출 게이트.
