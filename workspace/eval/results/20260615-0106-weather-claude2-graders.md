# 2차 claude 의미 레인 grader raw verdict (blind 증거·EVAL §2.0·§2.2 A3·A13)

> **대상**: `20260615-0106-weather-claude.md`(2차 claude 날씨) 의미 레인. **산출물**: `dddart-20260614-2304-claude` HEAD `6d36fb2`(baseline `2633087`·코퍼스 `b7446e8`).
> **집행**: workflow `wf_3b254b2c-eac`(4 grader 병렬·각 코드 직접 Read·**결정 레인 결과 미수령**·variant 미수령). N_grader=4(규칙 ruleA·ruleB + 적대 adv + FC 전담). **⚠️ 비-Claude 오라클 0 — 전원 동일 계열(독립성 미확보·A3 동종 사각)**.
> **blind 증거 영속 목적**(A3): "N명이 채점했다"를 *주장*이 아니라 *per-grader 산출*로 남긴다. raw JSON 원본 = transcript `tasks/w2o2yzphe.output`.

## κ — 차원별 일치율 (규칙 grader 3: ruleA·ruleB·adv)

| 차원 | ruleA | ruleB | adv | 일치 |
|---|---|---|---|---|
| SD-1 | PASS | PASS | PASS | ✅ 만장 |
| SD-2 | NA | NA | NA | ✅ 만장 |
| SD-3 | NA | NA | NA | ✅ 만장 |
| SD-4 | WEAK | WEAK | PASS | 2:1 → WEAK |
| SD-5 | PASS | PASS | PASS | ✅ 만장 |
| VW-1 | PASS | PASS | PASS | ✅ 만장 |
| VW-2 | PASS | PASS | PASS | ✅ 만장 |
| VW-3 | PASS | PASS | PASS | ✅ 만장 |
| VW-5 | PASS | PASS | PASS | ✅ 만장 |
| VW-6 | NA | PASS | PASS | ✅ (위반 0 일치) |
| VW-7 | PASS | PASS | PASS | ✅ 만장 |
| **ST-2** | **FAIL** | **FAIL** | **FAIL** | ✅ **만장 FAIL(치명)** |
| ST-1 | PASS | PASS | PASS | ✅ 만장 |
| ST-3 | PASS | PASS | PASS | ✅ 만장 |
| ST-4 | PASS | PASS | PASS | ✅ 만장 |
| ST-5 | PASS | PASS | PASS | ✅ 만장 |
| DT-1 | PASS | PASS | PASS | ✅ 만장 |
| DT-2 | PASS | PASS | PASS | ✅ 만장 |
| DT-4 | PASS | PASS | PASS | ✅ 만장 |
| DT-5 | PASS | PASS | PASS | ✅ 만장 |
| HR-5 | NA | NA | NA | ✅ 만장 |
| HR-8 | PASS | PASS | PASS | ✅ 만장 |
| Q-1 | WEAK | WEAK | WEAK | ✅ 만장 WEAK |
| Q-2 | PASS | PASS | PASS | ✅ 만장 |
| Q-4 | WEAK | WEAK | PASS | 2:1 → WEAK |

- **완전일치 23/25 = 0.92.** 2:1 분기 = SD-4·Q-4(둘 다 비치명·PASS vs WEAK — adv가 VO 수기 equality·go_router `!` 관용을 정당으로 봄). **치명 ST-2는 3/3 만장 FAIL**(보수 판정 불요). 적대 grader 치명 의미항목 무력화 **0건**(ST-2 외 전부 ruleA·ruleB와 동일 PASS).

## FC grader (전담 인격·골든 행위표 코드 미열람 사전등록본 대조)

| 골든 | verdict | 근거 |
|---|---|---|
| G-1 날짜 오름차순 | ❌ FAIL | 정렬 비교자 0건(sort/compareTo/reversed)·`forecast_list_view.dart:47` 배열순 직렌더. 데이터셋 D(비오름차순) 첫 행 D2·끝 D4 → FAIL. 라이브 오름차순 서버에선만 PASS. |
| G-2 항목 7 | ✅ PASS | `forecast_list_view.dart:46` itemCount: forecasts.length |
| G-3 기온 자리 | ✅ PASS | `forecast_list_item_section.dart:56-57` tempMax→tempMin 순·`forecast_summary.dart:21-22` @JsonKey 바인딩 |
| G-4 음수 부호 | ✅ PASS | `forecast_format_ui_extension.dart:39` `'$this°'` 보간(abs 0건) |
| G-5 내비 날짜 | ✅ PASS | `forecast_list_view.dart:52`→VM `ForecastDate.pathValue`→navigator→`forecast_detail_vm.dart:20` fromPath. 탭=상세 일치 |
| G-6 상세 3지표 | ✅ PASS | `forecast_detail_metric_section.dart:31-45` 습도·풍속·강수확률 3셀 |
| G-7 6종 distinct | ✅ PASS | 아이콘 6 distinct(cloudy=cloud≠overcast=cloud_queue)·색 6 distinct(`weatherCloudy 0xFF9E9E9E`≠`weatherOvercast 0xFF607D8B`) |
| G-8 한글 라벨 | ✅ PASS | `condition_ui_extension.dart:16-24` 6종 오라클 정확 일치 |

- **sortResponsibilityInCode = false** · **fc1 = 🟡 WEAK**(라이브 PASS / 코드 정렬책임 부재 취약성) · **fc3 = ❌ FAIL**(N2 — 데이터셋 D 비오름차순에서 정렬 부재 관측·라이브 서버 오름차순 송신 시 미관측). N1·N3~N7 전부 무관측(개수·필드·6종 distinct·기온 바인딩·내비·enum 라벨 정상).

## rubric 사각 신고칸 (A13 — 채점 미산입·다음 동결 라운드 RUBRIC 입력)

1. **`globalNavigatorKey.currentContext!` 무가드 내비**(ruleA·ruleB·adv 공통): `weather_navigator.dart:17`이 BuildContext-less VM 내비를 위해 전역키 currentContext를 무가드 역참조 → currentContext null 프레임(미마운트·연타 후 pop)에 런타임 null-assert/`GoRouter.of` Router-not-found 크래시 표면. VW-6(컴포넌트 self-show)·ST-4(ref.mounted)는 *전역 navigator context의 생존성 가드*를 직접 안 묻는다. VW-7(라우트 키 직렬화 VO/VM 소유)은 PASS인데 내비 *실행부* 안전성만 빈 구멍.
2. **`int.tryParse(parts[1]) ?? 0` silent-degrade**(ruleA): `forecast_format_ui_extension.dart:30` 날짜 파싱 실패 시 `0월 0일`로 조용히 표시. VO가 §1.2 근거로 생성검증을 일부러 안 해 방어선이 ui_extension로 떠넘겨진 결과 — 도메인 판정도 Either도 아니라 57차원 미포착.
3. **ST-2 사용자 노출 파급**(ruleB·adv): `forecast_list_view.dart:27`·`forecast_detail_view.dart:32`가 `error.toString()`을 화면에 직출력 → 던진 게 `Exception(msg)`라 `Exception:` 접두 날것 노출 + `BadRequestResponse.isShow`/`errorType` 손실. 타입 계약(ST-2)과 별개로 사용자 노출 문구 품질·관측성 차원 부재.
4. **정렬 서버 외주 검증 부재**(adv): 표시 순서가 전적으로 서버 응답 순서 의존인데, RUBRIC은 "정렬이 코드에 없어도 되는가"는 묻되 "서버 계약이 그 순서를 실제 보장하는가"는 검증 차원이 없어 회색지대.
5. **baseUrl 하드코딩**(ruleA): `dio_client.dart:10` 환경/빌드구성 분리 차원 RUBRIC 부재(1차 §F-3 동일).
