# 채점 결과지 — 20260615-2319-weather-claude

> **방법** EVAL-METHOD v3.1 · **채점일** 2026-06-15 · **환경** claude 파이프라인(설치본 `dddart@dddart-dev` v0.1.1·소스 byte-identical) · **variant** 단일(claude) · **산출물 루트** `~/Desktop/dddart-run/dddart-20260615-1938-claude`(HEAD `10dad68`·abee26d 대비 75파일 +10757) · **baseline** `abee26d`(순정 민낯·67파일) · **코퍼스** `cddfd12`(feedback-005) · **코드젠 도구 환경** freezed·json_serializable·riverpod_generator·retrofit_generator·build_runner(코더 핀·produced)·`.g.dart`/`.freezed.dart` 커밋 · **task** SCENARIO-WEATHER §1 verbatim · **게이트 답** 페이지네이션·로컬캐시·당겨새로고침 안 함/정렬=날짜 오름차순/condition 6종 아이콘·색·한글 · **FC 골든** `tools/FC-GOLDEN-WEATHER.md` 동결 2026-06-14 01:13(코드 미열람·작성자⊥채점자) · **N_grader** 3(n1·n2·adv) · **구성** 전원 동일 계열 — **비-Claude 오라클 0(A3 독립성 미확보)** · **positive control** 통과(2026-06-14·기계결함 아님) · **런-정지** 산출물 동결·채점 중 변화 없음 · **⚠️** N=1·인과 단정 금지·앵커=예시·소급 FAIL 금지·자기보고 불신(조정자 직접검증)·**시각/디자인 충실도 비측정(인간 오라클 — 구조·기능 PASS ≠ 시안 일치·A1)**·**E3 Stitch 미발동(design-ref 0파일·MCP 미연결·자체 설계)**

## 0. 빌드 게이트 (먼저 — FAIL이면 전체 FAIL)

| ID | 항목 | 판정 | 수확 근거 |
|---|---|---|---|
| BG-1 | 컴파일 가능 | ✅ | freezed `abstract`·part·GoRoute builder 완비·`valueOrNull` 0. 커밋 codegen으로 `flutter analyze` 의존 resolve 후 green. *build_runner 독립 재생성 미실행 — codegen 커밋본·analyze green 기반.* |
| BG-2 | analyze green 래칫 | ✅ | 조정자 `flutter analyze` → **"No issues found! (exit 0)"**. always_specify_types(E2) 켜진 BC국소 `analysis_options.yaml` 하 green = 타입 전면명시 |

> 빌드 게이트 PASS → 치명·차원 채점 진행.

## 1. 치명 게이트 (17 — 하나라도 ❌이면 픽스처 FAIL)

| 축 | ID | 항목 | 종합 | 수확 근거 (레인·인용) |
|---|---|---|---|---|
| S-DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 판정 domain·정렬은 표시변환(VM 합법)·VM spec import 0 (의미 3/3) |
| S-DDD | SD-2 | 루트 경유 변경 | ➖NA | 읽기전용·전이 갱신 없음 |
| S-DDD | SD-7 | UseCase 관문(UI호출 금지) | ✅ | `forecast_use_case.dart` 무상태·Either 통과·UI import 0 |
| S-VIEW | VW-1 | Fat Widget 금지 | ✅ | build 분기·표시·위임만 (3/3) |
| S-VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | design_system 자기표시 static 0 |
| S-STATE | ST-1 | VM 책임 경계(직행 금지) | ✅ | VM=UseCase 단독·Repo/Dio import 0·BuildContext 미보유 |
| S-STATE | ST-2 | 에러 2채널 | ✅ | build `throw BadRequestResponse`(`forecast_list_vm.dart:26`)→AsyncError(**0214 plain Exception 격하 교정**) |
| S-STATE | ST-4 | ref 규율(mounted 가드) | ✅ | await후 state 재접근 없음(가드 불요)·무전제 requireValue 0 |
| S-DATA | DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadRequestResponse,T>>`·Left 상위 전달 |
| S-DATA | DT-2 | 단일 출구·throw 금지 | ✅ | `safe_api_call.dart` Dio/Format/Type+catch-all→Either·repo throw 0 |
| S-HR | HR-1 | 4계층·BC 컨테이너 | ✅ | `application/weather/` 4계층·직속 2파일(router·navigator) |
| S-HR | HR-4 | 계층 import 역류 금지 | ✅ | backstop IM 0·domain 순수 Dart |
| S-HR | HR-5 | 교차 BC 4채널만 | ➖NA | 단일 신규 BC |
| BUILD | BG-1 | 컴파일 가능 | ✅ | §0 |
| BUILD | BG-2 | analyze green 래칫 | ✅ | §0 "No issues found!" |
| FC | FC-1 | 골든 오라클 | ✅ | 골든 G-1~G-8 8/8 PASS (3/3) |
| FC | FC-2 | 테스트·메커니즘 비-vacuous | ❌ | `test/widget_test.dart` 더미 스모크 1개·골든 미두드림·M1~4 영원히 green (3/3 FAIL) |
| FC | FC-3 | 도메인 정합(negative gate) | ✅ | N1~N7 청결 |

> **종합 = FC-2 ❌ → §3 집계 전체 FAIL.** [결정 PASS ∧ 의미 FAIL] 변종 없음 — FC-2는 결정(테스트 열거 1·스모크)∥의미(vacuous) 양 레인 일치.

## 2. 차원별 판정 (TIER-S 척추 + 비치명)

### A. S-DDD (SD-1~9)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유·빈혈 차단 | ✅ | 도메인 판정 적음·정렬=표시변환(VM)·spec import 0 (3/3) |
| SD-2 | 루트 경유 변경 | ➖NA | 읽기전용·Model 밖 분기 copyWith 0 |
| SD-3 | 불변식 도메인 예외 검증 | ➖NA | 전이 없는 읽기·VO 얇음(미발화) |
| SD-4 | VO·엔티티 도메인 형태 | ✅ | `@freezed`+json 직파싱(`forecast.dart`·`forecast_summary.dart`) |
| SD-5 | 애그리거트 경계·참조 | ✅ | 엔티티 애그 소속·중첩 직파싱 |
| SD-6 | 도메인서비스·specification 귀속 | ➖NA | 교차 애그 판정 없음 |
| SD-7 | UseCase 관문 | ✅ | 무상태·Either 통과·UI import 0 |
| SD-8 | 비채택 패턴 미도입 | ✅ | event/·port/·acl/·dto/·Repo 추상 0 |
| SD-9 | 유비쿼터스 언어 — 계층 관통 철자 | ✅ | forecast 개념 계층 관통 일관 (3/3) |

### B. S-VIEW (VW-1~7)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget 금지 | ✅ | build 표시·위임만 |
| VW-2 | 3단 판별·과승격 금지 | ✅ | section/widget prop·콜백·view 삼총사만 ref |
| VW-3 | dumb 조각 계약 | ✅ | section/widget ref·provider import 0 |
| VW-4 | 시각 토큰 단일 출처 | 🟡WEAK | 대체로 준수·n1 경미 nit(n2·adv PASS) |
| VW-5 | ui_extension = 도메인→UI 매핑 유일 자리 | ✅ | enum→UI 매핑 `weather_condition_ui_extension.dart` 단독 |
| VW-6 | 표시 소유·show() 금지 | ✅ | 자기표시 static 0 |
| VW-7 | 라우트 단일 출처·navigator 분업 | ✅ | 리터럴 `WeatherRoutes`만·navigator 상수 |

### C. S-STATE (ST-1~9)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 책임 경계 | ✅ | VM=UseCase 단독·BuildContext 미보유 |
| ST-2 | 에러 2채널 | ✅ | 조회 실패 build throw `BadRequestResponse`→AsyncError·valueOrNull 0 |
| ST-3 | State 형태·노출 계약 | ✅ | `application_layer/state/` @freezed·자기 State만 |
| ST-4 | ref 규율 | ✅ | await후 state 접근 없음·무전제 requireValue 0 |
| ST-5 | provider 형태·표기 | ✅ | **`@riverpod` 코드젠 클래스형**(`class extends _$ForecastListVM`·`.g.dart`)·수동/legacy 0 (3/3) |
| ST-6 | SharedState·교차 BC | ➖NA | 교차 BC watch·SharedState 미발생 |
| ST-7 | root 합성 구조 | ✅ | root_vm 표시상태만·rootRouter plain |
| ST-8 | 비채택 (retry OFF·hooks 등) | ✅ | 전역 retry OFF·hooks/valueOrNull 0 |
| ST-9 | base VM·공용 헬퍼 금지 | ✅ | base/추출 VM 0 |

### D. S-DATA (DT-1~9)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadReq,T>>`·Left 비폐기 |
| DT-2 | 단일 출구·throw 금지 | ✅ | safeApiCall 단일출구·throw 0 |
| DT-3 | BadRequestResponse 계약 | ✅ | 3필드·어휘(baseline 제공·정합) |
| DT-4 | DTO 없음·엔티티 직반환 | ✅ | DataSource 엔티티 직반환·DTO 0 |
| DT-5 | Repo/DataSource 형태 | ✅ | 구체 Repo·무상태·직접 생성 |
| DT-6 | retrofit DataSource 표기 | ✅ | `@RestApi`·factory·part·엔티티 반환 |
| DT-7 | hive 로컬 캐시 | ➖NA | 로컬 캐시 미사용 |
| DT-8 | 계약 스냅샷 운용 | ✅ | `server-contract.json` 동결본 대조 |
| DT-9 | infra service = 수동 어댑터 | ➖NA | SDK 어댑터 미사용(네트워크 전용) |

### E. S-HR (HR-1~9)
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | 4계층·BC 직속 2파일 |
| HR-2 | 종류 폴더·접미사 | ✅ | 화이트리스트·지정 접미사(_vm·_repo·_state 등) |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류 폴더·.gitkeep |
| HR-4 | 계층 import 역류 금지 | ✅ | 역류 매트릭스 위반 0(backstop IM) |
| HR-5 | 교차 BC 4채널만 | ➖NA | 단일 신규 BC |
| HR-6 | 파일·클래스 명명 | ✅ | 파일명=클래스·구접미사 0·foundation App 접두 |
| HR-7 | root/common/design_system 경계 | ✅ | common BC어휘 0·design_system import 화이트리스트 |
| HR-8 | 화면 삼총사·section/widget 접두 | ✅ | 삼총사 동거·section 접두 |
| HR-9 | 개념 1차·종류 2차 성장 | ✅ | 단일 개념 종류 폴더 직속(정상) |

## 3. TIER-Q 등급 (카운트 기반)

| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 표기 | ✅ | analyze green·SCREAMING/헝가리안 0·지역변수 타입 명시 |
| Q-2 | freezed 표기(비컴파일부) | ✅ | copyWith·소진 switch(when/map 0) |
| Q-3 | dartz Either 표면 | ✅ | Either/Left/Right/fold만 |
| Q-4 | null 안전 관용구 | ✅ | promotion·??·`!` 연쇄 0 (adv 확인) |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey 생성자·enum @JsonValue |
| Q-6 | catch 위생 | ✅ | safeApiCall on절 구체·빈 catch 0 |
| Q-7 | 잔여 구조 스멜 | ✅ | 죽은 코드·매직넘버·플래그 인자 0 |
| Q-8 | import 정렬·주석 형식 | ✅ | dart→package→상대·블록주석 0 |
| Q-9 | flutter 내비 표기 | ✅ | go/push·pushNamed·CustomTransition |

> **등급 = 기록용(치명 FC-2 FAIL로 §3 step4 정식 등급 미도달)**. Q-1~9 자체는 PASS 전수(등급 산정 시 "상")이나 치명 게이트 FAIL이라 정식 등급 산정 안 함. 거짓 FAIL 함정 면제 확인.

## grader 패널 증거 (A3 — blind 검증가능화)

| grader | 계열 | 적대 여부 | raw verdict 파일 |
|---|---|---|---|
| X:n1 | Claude | 아니오 | `20260615-2319-weather-graders-raw.json` (run X·lens n1) |
| X:n2 | Claude | 아니오 | 〃 (run X·lens n2) |
| X:adv | Claude | **예(적대)** | 〃 (run X·lens adv) |

| 차원 | grader 판정(n1·n2·adv) | κ | split 방향·비고 |
|---|---|---|---|
| FC-2(치명) | ❌❌❌ | 1.0 만장일치 | 스모크 1개·골든 미두드림 |
| FC-1(치명) | ✅✅✅ | 1.0 | G-1~8 8/8 |
| FC-3(치명) | ✅✅✅ | 1.0 | N1~7 청결 |
| SD-1·SD-7·VW-1·VW-6·ST-1·ST-2·ST-4·DT-1·DT-2·HR-1·HR-4(치명) | ✅✅✅ | 1.0 | 전원 PASS |
| SD-2·HR-5(치명) | ➖➖➖ | 1.0 | 읽기전용·단일BC NA |
| ST-5 | ✅✅✅ | 1.0 | @riverpod 코드젠 확인 |
| VW-4 | 🟡✅✅ | split | n1만 WEAK(경미)·비치명 |
| BG-2 | ✅➖➖ | split | n2·adv "실행 봉인→형태만 NA"·**조정자 결정레인 analyze green=PASS 확정** |

> **만장일치 보드인데 per-grader raw·κ 둘 다 존재 → 단일저자 위장 아님.** 비-Claude 오라클 0(전원 동일 계열·A3) — 헤더 ⚠️.

**rubric 사각 신고 (A13 — 채점 미반영·다음 동결 입력)**

| grader | 사각 신고 내용 |
|---|---|
| n1 | 정렬 거주처가 표시변환↔도메인판정인지 경계가 SD-1↔FC-1 사이에서 미끄러짐(condition 우선순위 같은 도메인 순위면 SD-1이어야) |
| n2 | DioClient baseUrl `https://kingdom-h.com` 하드코딩 — 실호스트 정합은 코드만으론 검증 불가(라이브 호출 봉인) |
| adv | baseUrl 하드코딩 + 데이터셋 D fake 주입 없이 라이브 서버 의존 — FC 골든이 요구한 widget test fake 미사용 |

## 의미적 변종 / 백스톱-blind 메타 (측정의 주 산출물)

| 차원 | 결정 레인 | 의미 레인 | 종합 | 변종 유형 |
|---|---|---|---|---|
| FC-2 | 테스트 열거=스모크 1개(`find`) | 골든 미두드림·M1~4 green(vacuous) | ❌ 치명 FAIL | 헛 테스트(비-vacuous 입증 부재) |
| 백스톱 52종 exit 0 | added 게이트 청결 | (못 보는 *테스트 부재*를 FC-2가 포착) | 상보 정상 | — |

> [결정 PASS ∧ 의미 FAIL] 치명 변종 없음 — claude는 결정·의미 레인이 FC-2에서 일치.

## 발견 로그 (단계별)

| # | 단계 | 도구 | 차원 | 내용 | 조기/말기 |
|---|---|---|---|---|---|
| 1 | G2직전 | `find *_test.dart` | FC-2 | 테스트 1개·더미 스모크(`widget_test.dart:11-29`)·골든 0 | 말기 |
| 2 | 결정레인 | backstop 52종 | HR/IM/NM | exit 0 blocker 0 | 조기 |
| 3 | 결정레인 | flutter analyze | BG-2·E2 | "No issues found!"·타입강제 green | 조기 |
| 4 | 의미레인 | grader 3 | ST-2 | `throw BadRequestResponse`(0214 격하 교정) | 말기 |
| 5 | 의미레인 | grader 3 | FC-1 | 골든 8/8(정렬 VM 오름차순·6종 매핑·한글) | 말기 |

## 잔여흠 원장 (치명 PASS 후 비치명 흠)

| 차원 | 흠 | 심각도 | 근거 |
|---|---|---|---|
| VW-4 | 시각 토큰 경미 nit | 🟡(1 grader) | n1 verdict·확정 아님 |
| (메타) | DioClient baseUrl 하드코딩 | 사각 신고(미산입) | n2·adv — 코퍼스에 baseUrl 주입 규약 부재 신호 |

## 한 줄 요지

**치명 게이트 ❌ FAIL(FC-2 단독) · TIER-Q 미도달.** 골든 두드리는 widget test가 더미 스모크 1개뿐(1·2·3차 지속)이라 비-vacuous 입증 실패. 그 외 치명 16 전부 PASS·FC-1 골든 8/8·ST-2 교정·@riverpod 코드젠·타입 전면강제·구조 청결 — *구조·규칙·기능정확성은 견고하나 검증 테스트 부재* 단일 구멍. (단일 산출물·우열 단정 금지)
