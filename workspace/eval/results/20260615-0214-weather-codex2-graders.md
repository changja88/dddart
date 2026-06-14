# 2차 codex 의미 레인 grader raw verdict (blind 증거·EVAL §2.0·§2.2 A3·A13)

> **대상**: `20260615-0214-weather-codex.md`(2차 codex 날씨) 의미 레인. **산출물**: `dddart-20260614-2304-codex` HEAD `db00464`(baseline `2633087`·코퍼스 `b7446e8`).
> **집행**: workflow `wf_3952c213-9da`(4 grader 병렬·각 코드 직접 Read·**결정 레인 결과 미수령**·variant 미수령). N_grader=4(규칙 ruleA·ruleB + 적대 adv + FC 전담). **⚠️ 비-Claude 오라클 0 — 전원 동일 계열(독립성 미확보·A3)**.
> raw JSON 원본 = transcript `tasks/wl22aqgnz.output`.

## κ — 차원별 일치율 (규칙 grader 3: ruleA·ruleB·adv)

| 차원 | ruleA | ruleB | adv | 일치 |
|---|---|---|---|---|
| SD-1 | PASS | PASS | PASS | ✅ 만장 |
| SD-2 | NA | NA | NA | ✅ 만장 |
| SD-3 | WEAK | WEAK | PASS | 2:1 → WEAK |
| SD-4 | WEAK | WEAK | WEAK | ✅ 만장 WEAK |
| SD-5 | PASS | PASS | PASS | ✅ 만장 |
| VW-1·2·3·5·6·7 | PASS | PASS | PASS | ✅ 만장 |
| **ST-2** | **PASS** | **PASS** | **PASS** | ✅ **만장 PASS**(BadReq throw 정석) |
| ST-1·4 | PASS | PASS | PASS | ✅ 만장 |
| ST-3 | WEAK | WEAK | PASS | 2:1 → WEAK |
| ST-5 | WEAK | WEAK | WEAK | ✅ 만장 WEAK(legacy Provider) |
| DT-1·2·4·5 | PASS | PASS | PASS | ✅ 만장 |
| HR-5 | NA | NA | NA | ✅ 만장 |
| HR-8 | PASS | PASS | PASS | ✅ 만장 |
| Q-1·4 | PASS | PASS | PASS | ✅ 만장 |
| Q-2 | WEAK | PASS | PASS | 2:1 → WEAK |

- **완전일치 22/25 = 0.88.** 2:1 분기 = SD-3·ST-3·Q-2(전부 비치명·adv가 관대). **치명 의미 10개(SD-1·2·VW-1·6·ST-1·2·4·DT-1·2·HR-5) 전부 만장 PASS/NA** — codex는 의미 레인 척추가 청결(특히 ST-2가 claude와 정반대로 BadRequestResponse throw 정석). 적대 grader 치명 무력화 0건.

## FC grader (전담·골든 행위표 사전등록본 대조)

| 골든 | verdict | 근거 |
|---|---|---|
| G-1 날짜 오름차순 | ❌ FAIL | 정렬 비교자 0(grep sort/compareTo/reversed)·`weather_forecast_list_vm.dart:30` 서버 배열순 보존. 데이터셋 D 첫 행 D2 → FAIL. 라이브 오름차순 서버선 PASS. |
| G-2 항목 7 | ✅ PASS | `list_vm.dart:28-32` 1:1 매핑·필터 0 |
| G-3 기온 자리 | ✅ PASS | `list_vm.dart:39-40` max/min 정확·`temperature_range.dart:8-13` min<=max 불변식 |
| G-4 음수 부호 | ✅ PASS | int 그대로·`forecast_row_widget.dart:84` 보간 |
| G-5 내비 날짜 | ✅ PASS | `content_section.dart:40` onOpenDetail(item.routeDate)→navigator→`detail_vm.dart:15` 일치 |
| G-6 상세 3지표 | ✅ PASS | `detail_metrics_section.dart:26-40` 습도·풍속·강수확률 |
| G-7 6종 distinct | ✅ PASS | 아이콘 6 distinct·색 6 distinct(cloudy≠overcast) |
| **G-8 한글 라벨** | ❌ **FAIL** | `weather_condition_ui_extension.dart:9-15` 라벨 **영문**: clear→'sunny'·cloudy→'partly cloudy'·overcast→'cloudy'·rain·snow·thunderstorm. SCENARIO §1 한글(맑음·구름많음·흐림…) 불일치 + **의미 밀림**(overcast=흐림인데 'cloudy'로). |

- **sortResponsibilityInCode = false** · **fc1 = ❌ FAIL**(G-1·G-8 2건) · **fc3 = ❌ FAIL**(N2 정렬). N7은 grader가 "영문 라벨이지 raw enum 노출 아님"으로 미관측 처리(조정자 주: G-8 의미 밀림은 N7 *정신*에 인접 — §결과지 FC-3 논의).

## rubric 사각 신고칸 (A13 — 채점 미산입·다음 RUBRIC 입력)

1. **정렬 기능 누락을 RUBRIC이 직접 못 처벌**(ruleB·adv 공통): SD-1은 "판정 *오배치*"를 보므로 정렬이 *통째로 없으면* PASS로 샌다. 도메인 완전성("있어야 할 날짜 오름차순 보장 specification이 weather_forecast 루트에 없음")은 어느 레인도 직접 안 잡음.
2. **UI 라벨 의미 밀림**(ruleA): `cloudy→partly cloudy·overcast→cloudy`로 도메인 어휘와 표시가 한 칸씩 어긋남 — 아키텍처(ui_extension 격리)는 정상이나 도메인-표시 의미 정합성 결함. FC-1 G-8로 잡히나 "한글 미충족"과 "의미 오배치"는 별개 사각.
3. **`_requiredString/_requiredInt` 파일 간 복제**(adv): `weather_forecast.dart:31-45`·`weather_forecast_detail.dart:37-62` 동일 파싱 헬퍼 중복(전역지침 06) — SD-5/DT-4 미포착.
4. **전역 NavigatorKey 무음 실패**(ruleB·adv): `weather_navigator.dart`가 전역 키 currentContext 의존 → null이면 push 조용히 소실. claude와 동형 사각(VW-6/ST-4 미포착).
5. **미사용 `error` 필드**(adv): `list_state.dart:15`·`detail_state.dart:18` `BadRequestResponse? error` 선언만·영영 null(액션 채널 0). 1차 §F-3 재현.
6. **route 파싱 실패를 BadRequestResponse(errorType:parse)로 application에서 합성**(ruleB): 도메인 실패↔전송 실패 어휘 혼용. `use_case.dart:22-33`.
