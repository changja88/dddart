# weather-claude 채점 결과 [2차 · ❌ FAIL — 치명 2건(ST-2 plain Exception throw · FC-2 테스트 0) · 정렬 부재 · 단 설계·도메인 표현력 1차 대비 개선]

> **방법** EVAL-METHOD v3.1(결정∥의미 레인·사전식 집계·치명17·백스톱 매핑) · **채점일** 2026-06-15 01:06 KST · **산출물 루트** `/Users/hyun/Desktop/dddart-run/dddart-20260614-2304-claude`(HEAD `6d36fb2` "G2 승인") · **variant** claude **2차**(교정 코퍼스 재실행·단일·codex 결과 비회람·graders blind) · **baseline 커밋** `2633087`(순정 민낯 Flutter 3.44.1·dio·riverpod·common/network 미설치) · **코퍼스 커밋** `b7446e8`(피드백3 교정·plugin 0.1.1·산출 시점 `.dddart/20260614-2320-weather-forecast` = 2026-06-14 23:20) · **모델/effort** Claude(plugin 캐시·effort 미상) · **N_grader** 4(규칙 ruleA·ruleB + 적대 adv + FC 전담 · 정본 N≥3·적대 1 충족 · raw 영속 `20260615-0106-weather-claude2-graders.md`) · **태스크** SCENARIO-WEATHER §1 claude 프롬프트 verbatim · **게이트답** §4(풀모드·신규 `weather` BC·OpenAPI URL·Stitch MCP·G1 "가장 간단하게") · **범례** ✅PASS ❌FAIL 🟡WEAK ➖N/A
> **⚠️ 단서**: N=1·**인과 단정 금지**(이 산출물이 X를 어겼다까지·"플러그인이 항상 X" 금지) · **앵커=예시** · **소급 FAIL 금지**(산출 시점 코퍼스 `b7446e8` 기준) · **자기보고 불신**(조정자 직접 백스톱·analyze·grep·코드 정독 검증) · **시각/디자인 충실도 비측정**(인간 오라클 위임 — 구조·기능 PASS ≠ 시안 일치·A1) · **비-Claude 오라클 0 — 의미 레인 전원 동일 계열(독립성 미확보·A3)** · 단일 런(variant 마스킹 N/A).
> **코드젠 도구 환경(§6.2)**: **produced**(코더 핀·`git diff 2633087 pubspec.yaml`) = dio ^5.9.2·flutter_riverpod ^3.3.2·riverpod_annotation ^4.0.3·retrofit ^4.9.2·dartz ^0.10.1·go_router ^17.3.0·freezed_annotation ^3.1.0·**json_annotation ^4.12.0**(1차엔 명시 핀 없던 것 — 2차 명시 추가) + dev: build_runner ^2.15.0·riverpod_generator ^4.0.4·freezed ^3.2.6-dev.1·json_serializable ^6.14.0·retrofit_generator ^10.2.6 · **env** = flutter `/opt/homebrew/bin/flutter`·dart 3.x · **조정자 추가 0**(A7 — 코더 핀 버전 무변경) · **used** = codegen 5종 실사용(`.g.dart`·`.freezed.dart` 산출).
> **런-정지(§2.6.3)**: 소스 working tree 정지 · 최신 mtime `2026-06-15 00:50`은 전부 `android/.gradle`·`ios/Flutter/ephemeral` 빌드 부산물(사용자 G2 후 `flutter run` 디자인 육안 드라이브·소스 아님) · 채점 시작 01:06 · **소스 미래 mtime 0 = 표적 정지 확인**.
> **FC 골든 사전등록**: `tools/FC-GOLDEN-WEATHER.md`(작성 2026-06-14 01:13·코드 미열람·codex/claude 공통·시나리오 동일) · 골든 8·mutation 5·negative-gate 7.
> **positive control(§0-6·A12)**: `tools/positive-control/` 등록·검증됨(치명 17 PASS·analyze clean·mutation 3/3 red·2026-06-14) → 현행 코퍼스 기준 **거짓-FAIL 기계 아님 확정** → 아래 FAIL은 잠정 아님.

---

## 종합 판정 (사전식 집계)

| 단계 | 결과 |
|---|---|
| ① 빌드 게이트(BG-1·BG-2) | ✅ **PASS** — `flutter analyze` **No issues found!**(exit 0)·codegen 산출 후 컴파일·added 신규 이슈 0 |
| ② 치명 게이트(17) | ❌ **FAIL** — **ST-2 plain Exception throw(만장 FAIL 3/3·치명)** + **FC-2 테스트 0개(결정적·N/A 금지)**. 정렬(FC-1/FC-3)도 데이터셋 D 기준 FAIL(라이브 관대 WEAK). 그 외 12 PASS·SD-2·HR-5 등 ➖NA |
| ②.5 실질성 관문 | ✅ degenerate 0 — 읽기-표시 도메인이라 판정 희박이 정당(Condition 분류·unknown 흡수 `condition.dart:16-34` 거주)·빈 골격 아님·설계 충실. 단 **FC-2 비-vacuous 입증 불가**(테스트 0) |
| ③ 비치명·의미변종 | 🟡 의미적 변종 ≥1(SD-4·Q-1·Q-4 WEAK) → "준수" 라벨 금지(상한 WEAK) · 적대 grader 치명 의미항목 **0건 무력화** |
| ④ TIER-Q 등급 | ✅ **상**(WEAK 2: Q-1·Q-4 / FAIL 0) — *단 ②가 FAIL이라 픽스처 전체 FAIL(이하 결함 기록용·§3)* |

**종합 = ❌ FAIL** — **치명 사유 2건**: (1) **ST-2** — 조회 실패 채널이 `BadRequestResponse`가 아닌 `throw Exception(failure.msg)`(plain·정보손실)로 AsyncError화(만장 FAIL). **명세-구현 불일치**: design-spec §3.2는 `"Left면 throw error"`(BadReq 직접)를 올바르게 명세했으나 coder가 격하 구현. (2) **FC-2** — `test/` 완전 비어(테스트 0개·`widget_test.dart` 삭제). 부수적으로 날짜 정렬 부재(FC-1/FC-3).

**한 줄 요지**: claude 2차는 **순정 민낯에서 dio·common/network·design_system·4계층 weather BC를 자력 빌드**(백스톱 51종 0위반·analyze clean·치명 12 PASS·적대 0 무력화)했고, **1차 대비 도메인 표현력(forecast_summary 엔티티·ForecastDate VO·Condition.unknown 폴백)과 설계 명세 충실도가 뚜렷이 개선**됐다. 그러나 **테스트를 한 개도 쓰지 않아 FC-2 치명 FAIL(1차와 동일·코퍼스 근본결함 재확인)** + **에러 채널이 BadRequestResponse를 plain Exception으로 격하해 ST-2 치명 FAIL(1차 대비 후퇴·명세는 옳았으나 구현이 어김)** → 종합 ❌ FAIL.

---

## 0. 빌드 게이트

| ID | 항목 | 결정 명령·근거 | 종합 | 치명 |
|---|---|---|---|---|
| **BG-1** 컴파일 가능 | `.g.dart`·`.freezed.dart` 산출 존재·`flutter analyze` error 0(codegen 후 컴파일 정상)·키워드/part/const X._() 정합·valueOrNull 0(grep) | ✅ | ✅ |
| **BG-2** analyze green 래칫 | `flutter analyze` → **No issues found! (ran in 1.2s)**·added 신규 0 | ✅ | ✅ |

> codegen 일치성: `.g.dart`/`.freezed.dart` 산출물 존재 + analyze green으로 컴파일 무결 확인. `build_runner build` 재생성 대조는 미실행(FC-2가 테스트 0으로 이미 결정적 FAIL·mutation 주입 무의미)이나, 손작성 codegen 숨김은 analyze 전체 컴파일이 1차 방어.

## 1. 치명 게이트 (17)

| 치명ID | 결정 | 의미 | 종합 | 근거(file:line) |
|---|---|---|---|---|
| **SD-1** 판정 소유 | ➖ | ✅ | ✅ | 유일 도메인 판정(6종 분류·미지 흡수) `condition.dart:16-34`(@JsonEnum unknownEnumValue·주석 30-33 "owned by this domain enum") 거주·VM은 fold 변환만 `forecast_list_vm.dart:21-24`. 정렬은 코드 부재(read-only 투영·억지 domain 투입 0)·기온은 표시 포맷. 만장 PASS |
| **SD-2** 루트 경유 변경 | ➖ | ➖ | ➖ | read-only 단일 BC·도메인 갱신 경로 0·Model copyWith 0(VM/UseCase/view) — 미발화 N/A(만장) |
| **SD-7** UseCase UI호출 | ✅ | ✅ | ✅ | `forecast_use_case.dart:11-23` 무상태·Either 통과·UI(material/presentation/design_system) import 0·새 throw 0(백스톱 IM12 0) |
| **VW-1** Fat Widget | ➖ | ✅ | ✅ | build `state.when`+표시·위임만 `forecast_list_view.dart:25-29`·탭 콜백 `:52` VM 위임뿐·정책 0(만장) |
| **VW-6** show() 금지 | ➖ | ✅ | ✅ | design_system/widget 자기표시 static 0·다이얼로그·시트 자체 없음(read-only) — 위반 0 일치(NA/PASS) |
| **ST-1** VM 직행 | ✅ | ✅ | ✅ | VM이 `ForecastUseCase()`만 `forecast_list_vm.dart:16`·Repo/box/SDK/BuildContext 0(백스톱 IM7·12 0)·자기 State만 노출(만장) |
| **ST-2** 에러 2채널 | ➖ | ❌ | ❌ | **`forecast_list_vm.dart:22`·`forecast_detail_vm.dart:23` `(failure)=>throw Exception(failure.msg)` — BadRequestResponse 폐기·plain Exception 격하**(RUBRIC "throw 대상 plain Exception/문자열=FAIL"). 조회 채널이 typed carrier 손실(isShow·errorType 버림). valueOrNull 0(grep)·액션 채널 NA(read-only). **만장 FAIL 3/3·치명** |
| **ST-4** mounted 가드 | ✅ | ✅ | ✅ | await 직후 `result.fold(...)` 즉시 return·state 재접근 0 → 가드 불요(누락 아님)·requireValue 0(grep). 만장 PASS |
| **DT-1** Either 실패 계약 | ✅ | ✅ | ✅ | Repo `forecast_repo.dart:20,24` `Future<Either<BadRequestResponse,T>>`·UseCase 통과·VM fold Left가 no-op/삼킴 아님(상위 throw 전달). (carrier 격하는 ST-2 소관·DT-1 Left전달 계약은 충족) 만장 PASS |
| **DT-2** 단일 출구 | ✅ | ✅ | ✅ | `safe_api_call.dart:13-46`(Dio·Format·Type 개별+catch-all → Left)·Repo/infra throw 0·인터셉터 onError 0(만장 PASS) |
| **HR-1** 4계층·BC | ✅ | — | ✅ | 백스톱 ST0-3 0위반·`application/weather/` 4계층·직속 2파일 |
| **HR-4** import 역류 | ✅ | — | ✅ | 백스톱 IM 0위반·매트릭스 위반 0 |
| **HR-5** 교차 BC 4채널 | ✅ | ➖ | ✅ | 백스톱 IM5·CY1 0위반·단일 BC·타 BC import 0(채널④ 미발화 NA·만장) |
| **BG-1** 컴파일 | ✅ | — | ✅ | (§0) |
| **BG-2** analyze green | ✅ | — | ✅ | (§0) |
| **FC-1** 골든 오라클 | — | 🟡/❌ | ❌ | **G-1(날짜 오름차순) FAIL** — 정렬 비교자 0(grep)·서버 배열순 직표시 `forecast_list_view.dart:47`. 데이터셋 D(비오름차순)서 FAIL·라이브 오름차순 서버선 PASS(sortInCode=false). G-2~G-8 7건 PASS. **데이터셋 D 기준 치명 FAIL / 라이브 관대 시 WEAK**(정렬 쟁점=codex 공통·§G-3) |
| **FC-2** 비-vacuous | ❌ | — | ❌ | **테스트 0개**(`find *_test.dart` 0건·`test/` 빈 폴더·`widget_test.dart` 삭제·`integration_test/` 없음). EVAL §2.5 "순수 0=즉시 FAIL·N/A 금지" → **결정적 치명 FAIL** |
| **FC-3** 도메인 정합 | — | ❌ | ❌ | **N2(날짜 순서)** — 데이터셋 D 비오름차순서 정렬 부재 관측(라이브 오름차순 송신 시 미관측). N1·N3~N7 무관측. FC-1 G-1과 동근원 |

> **치명 종합**: ❌ **FAIL** — **ST-2(만장 plain Exception)·FC-2(테스트 0) 2건이 독립 결정적**. FC-1·FC-3(정렬)은 데이터셋 D 기준 FAIL·라이브 관대 시 WEAK(어느 쪽이든 종합 영향 없음 — ST-2·FC-2가 이미 FAIL).

## 2. 차원별 판정 (TIER-S 척추)

### A. S-DDD

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| SD-1 판정 소유 | 6종 분류·미지 흡수 `condition.dart:16-34` 거주·VM 변환만 | ➖ | ✅ | ✅ | ✅ |
| SD-2 루트 경유 변경 | read-only·갱신 0 | ➖ | ➖ | ➖ | ✅ |
| SD-3 불변식 도메인 예외 | 전이 부재·VO 생성검증 의도적 미강제(`forecast_date.dart:6-16` §1.2 직파싱) | ➖ | ➖ | ➖ | — |
| SD-4 VO·엔티티 형태 | `forecast.dart:16`·`forecast_summary.dart:17` freezed+json 직파싱·**`forecast_date.dart:11` VO는 수기 class(freezed 아님)·==/hashCode 직구현(`:26-31`)** | ✅ | 🟡 | 🟡 | — |
| SD-5 애그리거트 경계 | 단일 루트 `forecast.dart:8-11`+종속 엔티티 `forecast_summary`(nullable 합집합 회피 근거)·교차참조 0 | ✅ | ✅ | ✅ | — |
| SD-6 도메인서비스·spec | `domain_service/`·`specification/` 빈 골격·교차 판정 부재 | ➖ | ➖ | ➖ | — |
| SD-7 UseCase 관문 | `forecast_use_case.dart:11-23` 무상태·Either 통과·UI import 0 | ✅ | ✅ | ✅ | ✅ |
| SD-8 비채택 패턴 | event/port/acl/dto 0·Repo 추상 0·DI 0(백스톱) | ✅ | ✅ | ✅ | — |
| SD-9 유비쿼터스 언어 | `forecast`/`Forecast`/`forecast_summary`/`ForecastDate`/`Condition` 계층 관통 일관(design-spec §1.6) | ✅ | ✅ | ✅ | — |

### B. S-VIEW

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| VW-1 Fat Widget | build `state.when`+위임만 `forecast_list_view.dart:25-29` | ➖ | ✅ | ✅ | ✅ |
| VW-2 3단 판별·과승격 | `_ForecastList`는 ref.read(openDetail) 실사용 정당 승격·`_ErrorBody`/`_DetailBody` Stateless | ➖ | ✅ | ✅ | — |
| VW-3 dumb 조각 | section/widget ref·provider import 0·prop+콜백(`forecast_list_item_section`·`condition_chip_widget`) | ✅ | ✅ | ✅ | — |
| VW-4 시각 토큰 단일 출처 | App* 토큰(`app_color.dart`)·design_system 밖 시각 리터럴 0(grep)·VM/State 시각 getter 0 | ✅ | ✅ | ✅ | — |
| VW-5 ui_extension 매핑 | enum→아이콘/색/라벨 `condition_ui_extension.dart:14-48`·날짜/기온 포맷 `forecast_format_ui_extension.dart:17-40`만·VM/State 누수 0 | ➖ | ✅ | ✅ | — |
| VW-6 show() 금지 | 자기표시 static 0·다이얼로그 없음 | ➖ | ✅ | ✅ | ✅ |
| VW-7 라우트 단일 출처·내비 인자 | 리터럴 `weather_router.dart:13-21` `WeatherRoutes`만·navigator pushNamed 상수·**내비 path-param 직렬화 `ForecastDate.pathValue`를 VM 소유(`forecast_list_vm.dart:32-33`)·view onTap 인라인 직렬화 0** | ✅ | ✅ | ✅ | — |

### C. S-STATE

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| ST-1 VM 책임 경계 | VM이 `ForecastUseCase()`만·BuildContext 0 | ✅ | ✅ | ✅ | ✅ |
| ST-2 에러 2채널 | **build throw가 `Exception(failure.msg)` plain 격하**(`forecast_list_vm.dart:22`·`forecast_detail_vm.dart:23`)·BadReq carrier 손실 | ➖ | ❌ | ❌ | ✅ |
| ST-3 State 형태·노출 | `forecast_list_state.dart`·`forecast_detail_state.dart` @freezed·자기 State·액션0이라 error 필드 부재 정당 | ✅ | ✅ | ✅ | — |
| ST-4 ref 규율(mounted) | await 후 fold 즉시 반환·재접근 0 → 가드 불요 | ✅ | ✅ | ✅ | ✅ |
| ST-5 provider 형태 | `@riverpod class extends _$X`·detail family build 인자(`forecast_detail_vm.dart:19`)·legacy 0 | ✅ | ✅ | ✅ | — |
| ST-6 SharedState·교차 BC | 단일 BC·타 BC watch 0 — 미발화 | ➖ | ➖ | ➖ | — |
| ST-7 root 합성 | root handler 3종 keepAlive Notifier 골격·rootRouter plain 전역 | ✅ | ➖ | ✅ | — |
| ST-8 비채택(retry OFF) | `main.dart:23` `retry:(retryCount,error)=>null`·hooks/valueOrNull/copyWithPrevious 0(grep) | ✅ | ✅ | ✅ | — |
| ST-9 base VM 금지 | 각 VM `_$X`만 extends·공용 mixin 0 | ✅ | ✅ | ✅ | — |

### D. S-DATA

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| DT-1 Either 실패 계약 | `forecast_repo.dart:20,24` Either·fold Left 전달(no-op 아님) | ✅ | ✅ | ✅ | ✅ |
| DT-2 단일 출구 | `safe_api_call.dart:13-46`·throw 0·인터셉터 정규화 0 | ✅ | ✅ | ✅ | ✅ |
| DT-3 BadRequestResponse 계약 | `bad_request_response.dart:10-14` 3필드 error_type/msg/is_show·freezed·클라생성 isShow:true·서버바디 fromJson 보존 | ✅ | ✅ | ✅ | — |
| DT-4 DTO 없음·엔티티 직반환 | `forecast_data_source.dart:18,22` 엔티티 직반환·dto/Mapper 0 | ✅ | ✅ | ✅ | — |
| DT-5 Repo/DataSource 형태 | `forecast_repo.dart:14` 단일 구체·무상태·직접 생성·DI 0 | ✅ | ✅ | ✅ | — |
| DT-6 retrofit 표기 | `forecast_data_source.dart:12-22` @RestApi+factory+part·@GET/@Path·Future<엔티티> | ✅ | — | ✅ | — |
| DT-7 hive 로컬 캐시 | hive·@HiveType 0 — 미발화 | ➖ | ➖ | ➖ | — |
| DT-8 계약 스냅샷 운용 | 인용 path `/api/v1/weather/`·`/{forecast_date}/`·design-spec §7 계약위험 3건 표기(미지 enum·404 바디·date round-trip) | ✅ | ✅ | ✅ | — |
| DT-9 infra service 어댑터 | SDK 어댑터 0 — 미발화 | ➖ | ➖ | ➖ | — |

### E. S-HR

| ID | Result(file:line) | 결정 | 의미 | 종합 | 치명 |
|---|---|---|---|---|---|
| HR-1 4계층·BC 컨테이너 | 백스톱 ST0-3 0위반 | ✅ | — | ✅ | ✅ |
| HR-2 종류 폴더·접미사 | `_vm`·`_repo`·`_state`·`_data_source` 화이트리스트+접미사 일치(백스톱 NM·ST) | ✅ | — | ✅ | — |
| HR-3 신규 골격 완비 | 종류 폴더 .gitkeep(domain_service·specification·service·shared_state)·애그루트 | ✅ | — | ✅ | — |
| HR-4 계층 import 역류 | 백스톱 IM 0위반 | ✅ | — | ✅ | ✅ |
| HR-5 교차 BC 4채널 | 백스톱 IM5·CY1 0위반·단일 BC | ✅ | ➖ | ✅ | ✅ |
| HR-6 파일·클래스 명명 | 파일명=클래스 1 public·구접미사 0·foundation App접두(백스톱 NM) | ✅ | — | ✅ | — |
| HR-7 root/common/design_system 경계 | common 5폴더·design_system→application/root import 0·root import=main.dart만(백스톱) | ✅ | ✅ | ✅ | — |
| HR-8 화면 삼총사·접두 | `forecast_list_*`·`forecast_detail_*` vm·view·state 동거·section 화면 접두·widget `condition_chip`(화면명 아님) | ✅ | ✅ | ✅ | — |
| HR-9 개념 1차·종류 2차 성장 | 단일 개념 `forecast/` 직속·infra 미분할 | ✅ | ✅ | ✅ | — |

## 3. TIER-Q 등급 (카운트)

| ID | 종합 | 근거(file:line) |
|---|---|---|
| Q-1 명명·타입 표기 | 🟡 | 명명 청결(SCREAMING_CAPS·헝가리안 0)이나 **`forecast_list_vm.dart:21`·`forecast_detail_vm.dart:21` `final result = await ...` 타입 미명시**(Either 추론·뷰 ref/리터럴 예외 밖) → 만장 WEAK |
| Q-2 freezed 표기 | ✅ | `@Default(<ForecastSummary>[])` 새 리터럴·`condition_ui_extension` 소진 switch(7멤버·default 없음)·`.when`은 AsyncValue 표준 API |
| Q-3 dartz Either 표면 | ✅ | Right/Left·fold Left 첫인자·fpdart 0 |
| Q-4 null 안전 관용구 | 🟡 | `!` 연쇄 0이나 단발 `!` 2건(`weather_navigator.dart:17` currentContext!·`weather_router.dart:36` pathParameters!) — go_router 관용이나 promotion 우선 변종 → WEAK(2:1·adv는 PASS) |
| Q-5 직렬화 표기 | ✅ | @JsonKey 생성자 부착·enum @JsonValue+unknownEnumValue |
| Q-6 catch 위생 | ✅ | safeApiCall on절 구체+catch-all(의도 폴백 면제)·무차별 catch 0 |
| Q-7 잔여 구조 스멜 | ✅ | 죽은 코드 0·치수 리터럴은 위젯(VW-4 밖)·플래그 인자 `showLabel`은 호출처 결정 표시값(정당) |
| Q-8 import 정렬·주석 | ✅ | dart→package→상대 구획·/// 양식·블록주석 0 |
| Q-9 flutter 내비 표기 | ✅ | pushNamed 상수·GoRoute builder·redirect 미사용 |

**TIER-Q = 상** (PASS 7 / WEAK 2 / FAIL 0). *단 ②FAIL이라 픽스처 전체 FAIL(이 등급은 결함 기록용).*

## 4. grader 패널 증거 (§5.5)

- **N_grader=4**(규칙 ruleA·ruleB + 적대 adv + FC 전담) · raw verdict 영속 `20260615-0106-weather-claude2-graders.md`(커밋 대상).
- **κ(규칙 3): 완전일치 23/25 = 0.92.** 2:1 분기 = SD-4·Q-4(비치명·PASS vs WEAK). **치명 ST-2 = 만장 FAIL 3/3**(보수 판정 불요).
- **적대 grader 무력화 0건** — 치명 의미항목 전부 ruleA·ruleB와 동일(ST-2만 FAIL 합의·빈혈/디코이/Left no-op/show 우회/동형버스 부재 확인).
- **⚠️ 비-Claude 오라클 0**(전원 동일 계열·독립성 미확보·A3 동종 사각) — 디자인 충실도는 인간 오라클 위임(미측정).
- **rubric 사각 신고(A13·채점 미산입·다음 RUBRIC 입력)**: ①`globalNavigatorKey.currentContext!` 무가드 내비 런타임 위험(VW-6/ST-4 미포착) ②`int.tryParse ?? 0` silent-degrade ③ST-2 파급 `error.toString()` 날것 노출·isShow/errorType 손실 ④정렬 서버 외주 검증 차원 부재 ⑤baseUrl 하드코딩(→ §G·잔여흠).

## 5. 의미적 변종 / 백스톱-blind 메타 (§2.4)

- **`[결정✅ ∧ 의미❌]` 치명 변종 = 0건.** ST-2 FAIL은 의미 전담 항목(결정 grep 보조)·결정 PASS 위장 아님. 적대 grader 치명 12 무력화 0/12.
- **비치명 의미 변종 = SD-4(VO freezed 미사용)·Q-4(currentContext! 강제언랩)·Q-1(result 타입 미명시)** — 전부 WEAK 상한(준수 라벨 차단).
- 실질 리스크가 결정/실행 레인으로 이동: FC-2 테스트 0·정렬 서버의존·navigator 전역키 무가드.

## 6. 발견 로그

- **§G-1 [치명·만장 FAIL·1차 대비 후퇴] ST-2 plain Exception throw + 명세-구현 불일치.** `forecast_list_vm.dart:22`·`forecast_detail_vm.dart:23` `throw Exception(failure.msg)` — BadRequestResponse를 plain Exception으로 격하(isShow·errorType 손실). **1차는 `throw error`(BadReq 직접)로 ST-2 PASS였으나 2차는 후퇴.** 핵심: **design-spec §3.2는 `"Left면 throw error"`(BadReq 직접 throw)를 올바르게 명세**했으므로 *설계 결함이 아니라 Phase 2 구현(coder)이 명세를 어긴 것* — discipline-reviewer·미니게이트(가정계약)가 명세-구현 throw 대상 불일치를 미포착. → **코퍼스 교정 후보**(coder가 명세 throw 대상 준수·또는 미니게이트/백스톱이 build throw 대상=BadReq 검증).
- **§G-2 [치명·1차 동일·회귀 없음] 테스트 0개(FC-2).** `find *_test.dart` 0건·`test/` 빈 폴더·`widget_test.dart` 삭제·`integration_test/` 없음. **1차와 동일** → coder.md 테스트 작성 책무 **명시 0**(grep 무출력·전 세션 확인)이 코퍼스 근본 원인임을 **2차가 재확인**. *민낯 수확: 설계·구조·도메인은 개선됐는데 테스트 산출은 여전히 0 — 교정이 닿지 않은 결함.* → **coder 테스트 게이트 추가 확정 후보**(2차 재확인으로 결함 확정).
- **§G-3 [치명·codex 공통] 날짜 오름차순 정렬 부재.** 정렬 비교자 0(grep sort/compareTo/reversed)·`forecast_list_view.dart:47` 배열순 직표시·sortInCode=false. 실서버는 결정적 오름차순 발행(라이브 PASS)이나 계약에 ordering 보증 없음·데이터셋 D(비오름차순) 주입 시 G-1·N2 FAIL. design-spec §5-10 "클라이언트 날짜 계산 없음"은 1차의 완전 무언급보다 인접하나 *정렬 순서 책임* 자체는 여전히 미명시. 정렬 판정(엄격 FAIL/관대 WEAK)은 codex 공통 쟁점·**ST-2·FC-2가 이미 결정적이라 종합 영향 없음**.
- **§G-4 [rubric 사각·A13] navigator 전역키 무가드.** `weather_navigator.dart:17` `globalNavigatorKey.currentContext!` — VM BuildContext 우회의 생존성 가드 0(미마운트·연타 pop 프레임서 null-assert/Router-not-found 크래시 표면). VW-6·ST-4 어느 차원도 직접 안 잡음(grader 3 공통 신고). → RUBRIC 개정 입력.
- **§G-5 [비치명·1차 동일] DioClient baseUrl 하드코딩.** `dio_client.dart:10` `'https://kingdom-h.com'`(환경 분리 0·1차 §F-3 동일). 단 connect/receiveTimeout 추가는 소폭 개선.
- **§G-6 [개선·1차 대비] 도메인 표현력·설계 명세 충실도 상승.** 1차(애그+enum 2개·정렬 미문서화) → 2차(forecast 루트+forecast_summary 엔티티+ForecastDate VO+Condition.unknown 폴백·계약위험 3건·판정소유표·자기모순스캔). 피드백3 교정의 가시적 효과.

## 7. 잔여흠 원장 (FAIL이지만 기록)

| 흠 | 위치 | 심각도 | 비고 |
|---|---|---|---|
| **ST-2 plain Exception throw** | `forecast_list_vm.dart:22`·`forecast_detail_vm.dart:23` | **치명** | 명세(§3.2 throw error)는 옳음·구현이 어김 — 1차 대비 후퇴 |
| **테스트 0개** | `test/` | **치명** | FC-2 FAIL·1차 동일·coder 테스트 책무 0 근본결함 재확인 |
| 정렬 부재 | weather BC 전역 | 중 | 서버 오름차순 의존·정렬 순서 책임 미명시(codex 공통) |
| navigator 전역키 무가드 | `weather_navigator.dart:17` | 중 | currentContext! null-assert 크래시 표면(rubric 사각) |
| VO freezed 미사용 | `forecast_date.dart:11` | 경미 | SD-4 WEAK·수기 ==/hashCode |
| `final result` 타입 미명시 | VM 2곳 | 경미 | Q-1 WEAK |
| baseUrl 하드코딩 | `dio_client.dart:10` | 경미 | 1차 동일·환경 분리 0 |

## 8. 1차 대비 차분 (회귀 검증 — 피드백3 교정 효과)

> 1차 `20260614-0151-weather-claude.md`(baseline `abee26d`·코퍼스 `676e317`) → 2차(baseline `2633087`·코퍼스 `b7446e8`). **동일 SCENARIO·동일 FC-GOLDEN**.

| 축 | 1차 claude | 2차 claude | 변화 |
|---|---|---|---|
| **종합** | ❌ FAIL | ❌ FAIL | = 동일 |
| **결정적 치명** | FC-2 테스트0 (1건) | FC-2 테스트0 + **ST-2 plain Exception** (2건) | ⬇ **후퇴**(치명 1→2) |
| **도메인 표현력** | 애그+enum 2개(얇음·흠) | +forecast_summary 엔티티·ForecastDate VO·unknown 폴백 | ⬆ **개선** |
| **설계 명세** | 정렬 미문서화·얇음 | 계약위험3·판정소유표·자기모순스캔·상세 | ⬆ **대폭 개선** |
| **내비 인자(VW-7)** | PASS | forecast_date VO·pathValue·VM 소유 | ⬆ 강화 |
| **ST-2 throw** | `throw error`(BadReq·PASS) | `throw Exception(msg)`(plain·FAIL) | ⬇ **후퇴** |
| **테스트(FC-2)** | 0개·FAIL | 0개·FAIL | = **동일(회귀 없음·코퍼스 결함)** |
| **정렬** | 부재·미문서화 | 부재·문서 약간 인접 | ≈ 본질 동일 |
| **TIER-Q** | 상(WEAK0) | 상(WEAK2: Q-1·Q-4) | ⬇ 소폭 흠 증가 |
| **baseUrl** | 하드코딩 | 하드코딩 | = 동일 |
| 적대 무력화 | 0/12 | 0(치명 의미) | = 동일(견고) |

**회귀 관찰 4포인트 답**:
1. **지역변수 타입 명시** → Q-1 WEAK(`final result` 2곳·미개선·경미).
2. **내비 인자 VO/VM 소유** → ✅ **개선**(ForecastDate VO 도입·VW-7 강화).
3. **디자인 구조 충실도** → ✅ **대폭 개선**(설계 명세 상세·도메인 풍부). *단 시각 충실도는 인간 오라클·미측정.*
4. **claude 테스트 생성** → ❌ **여전히 0**(회귀 없음·코퍼스 근본결함 재확인).

**해석(인과 단정 금지·N=1)**: 피드백3 코퍼스 교정은 **설계 충실도·도메인 표현력을 가시적으로 개선**시켰으나, **FC-2 테스트 0(coder 테스트 책무 0)이라는 핵심 결함은 닿지 못했고**, **ST-2는 오히려 후퇴**(명세는 옳았으나 coder 구현이 어김 → 구현/감수 게이트 공백). 종합 FAIL은 1차와 동일하나 *원인 구성*이 바뀜(테스트0 → 테스트0 + ST-2).

## 9. 한 줄 요지

❌ **claude 2차 FAIL** — 구조·MVVM·하우스룰·데이터계약은 1차와 동급 청결(백스톱 51종 0·analyze clean·치명 12 PASS·적대 0 무력화)에 더해 **도메인 표현력·설계 명세가 뚜렷이 개선**(VO·엔티티·unknown 폴백·계약위험 표기)됐으나, **① 테스트 0개(FC-2·1차 동일·coder 책무 0)** + **② 에러 채널 plain Exception 격하(ST-2·1차 대비 후퇴·명세는 옳고 구현이 어김)** 2건의 치명으로 종합 FAIL. **교정 후보 2건**: coder 테스트 게이트(확정) · ST-2 명세-구현 일치 게이트(신규).

---

> **코퍼스 교정 후보(후속·이 채점 미반영)**: ① **coder 테스트 책무 0**(`coder.md`에 test/golden 작성 명시 0 — 1·2차 연속 테스트 0의 근본) → 테스트 산출 게이트. ② **ST-2 명세-구현 불일치**(design-spec §3.2 "throw error" 옳음·coder가 plain Exception 격하·감수 미포착) → coder가 build throw 대상=BadReq 준수, 미니게이트/백스톱에 "build throw가 BadRequestResponse인가" 검증 추가. ③ (선택·rubric 사각) navigator 전역키 생존성·RUBRIC 차원 부재(A13 누적).
