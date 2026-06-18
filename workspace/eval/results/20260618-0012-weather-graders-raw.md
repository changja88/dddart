# grader 패널 raw verdict — 20260618-0012-weather (6차 양판·v3.2)

> **blind 증거 영속(EVAL-METHOD §2.0 A3)**: 의미 grader 3명(n1·n2 중립 / adv 적대)의 raw blind verdict. **전원 결정레인(백스톱·analyze·mutation·test) 결과·variant(claude/codex 엔진정체) 미수령** 상태로 채점. X=`/tmp/grade-0012-claude`(@ab99a82)·Y=`/tmp/grade-0012-codex`(@64bb27e)로 익명 제시. **구성 전원 Claude 계열 — 비-Claude 오라클 0(A3 독립성 미확보·헤더 ⚠️)**. 마스킹: 엔진정체 blind(X/Y)·결정결과 blind·적대 1명. *구조 익명화는 부분*(서브에이전트 기반·BC명 weather/weather_forecast는 노출되나 엔진정체와 무관) — A3 한계 명시.
> κ가 결과지(claude·codex·compare)와 함께 산출됨 → 단일저자 위장 아님(독립 3 verdict 영속).

---

## κ 요약 (차원별 일치·치명 중심)

| 차원 | n1 | n2 | adv | κ·split | 종합 |
|---|---|---|---|---|---|
| **ST-2**(Y 죽은 error필드) | ❌ | ❌ | ❌ | 1.0 만장 | **치명 FAIL**(보수 불필요·만장) |
| **FC-2/M1**(X·Y 정렬 死) | N/A론 | N/A론 | ❌ | 사실 1.0 / 판정 1:2 | **FC-2 FAIL**(동결룰·§2.2 보수·adv 줄인용 FAIL) |
| SD-1(X·Y) | 🟡PASS | 🟡PASS | lean-PASS | 1.0 | PASS(thin 정당) |
| SD-7·VW-1·VW-6·ST-1·DT-1·DT-2(X·Y) | ✅ | ✅ | ✅ | 1.0 | PASS |
| FC-1 G-8(Y "구름 많음") | ❌ | 🟡 | 무 | split | 보수 FAIL+인간큐(cosmetic) |
| SD-4/DT-4/ST-3(Y 비-@freezed 수기) | 무 | 🟡FAIL/WEAK | ❌FAIL | 2/3 flag | 🟡 WEAK(비치명) |
| DT-5(Y optional 주입) | 🟡WEAK | ✅PASS(seam) | 🟡FAIL→WEAK | split | 🟡 WEAK(비치명·seam) |

> **치명 split 규칙(§2.2)**: ST-2는 3:0 만장 FAIL. FC-2/M1은 *사실*(정렬코드 0·사전정렬 fixture=vacuous) 3명 만장확인, *판정*만 1:2(adv FAIL / n1·n2 "정당 위임 N/A론") — adv 줄인용 FAIL + 동결 FC-GOLDEN §2 "정렬코드 부재=FAIL" → 보수 FAIL. G-8은 n1 줄인용 FAIL → 보수 FAIL+인간큐.

---

## grader n1 (중립) — raw

**X(claude)**: 치명-의미 전부 PASS. SD-1 🟡borderline-PASS(`weather_forecast.dart:11-25`·도메인 판정 0이나 읽기전용이라 누수 아님·thin 정당). SD-7✅(`get_weekly_forecast_use_case.dart:15-17`). VW-1✅·VW-6✅·ST-1✅(`weather_list_vm.dart:18-28`). ST-2✅(`weather_list_state.dart:11` error 필드 의도적 부재·단일 조회채널). DT-1✅(`weather_list_vm.dart:24` Left→throw 전달). DT-2✅. FC-1: G-1 🟡서버의존(`weather_list_body_section.dart:29` 배열순)·G-2~G-8 ✅(G-8 `weather_condition_ui_extension.dart:47-62` 맑음·구름많음… 골든 정확일치). FC-3 ✅(N2만 서버의존). DI ✅ no-DI. **A13**: G-1 오름차순 미검증(`weather_list_vm_test.dart:48-52` 사전정렬 fixture=vacuous order test).

**Y(codex)**: SD-1 ✅(`weather_forecast.dart:10-17` requireSevenDays 도메인 판정·VO). SD-7✅. VW-1✅·VW-6✅·ST-1✅. **ST-2 ❌ FATAL**(`weather_forecast_list_state.dart:5-8` error 필드 + view `list_view.dart:40-50` isShow 분기인데 **VM이 한 번도 set 안 함**(`list_vm.dart:24` throw만)·consumeError 전무 → 죽은 vestigial 채널). DT-1✅·DT-2✅(requireSevenDays throw가 safeApiCall 안). FC-1: **G-8 ❌**(`weather_condition_ui_extension.dart:11` cloudy="구름 많음" 공백 vs 골든 "구름많음"·N7 strict 불일치·cosmetic 단서)·나머지 PASS(G-2는 requireSevenDays로 app-enforced). DT-5 🟡WEAK(전 계층 `{Dep?}` 주입). 도메인 풍부(정당). **A13**: 아이콘 distinct 미검증(`weather_condition_ui_extension_test.dart:55-61` 색 set-size만·아이콘 swap 우회=약화단위 디코이).

**n1 한줄**: X 전 치명 PASS·정규형·잠재 오름차순 미검증 / Y ST-2 죽은채널(FATAL)+G-8 라벨 = strict 동결 읽기로 치명 미통과.

---

## grader n2 (중립) — raw

**X(claude)**: SD-1 🟡borderline-PASS(판정 0이나 읽기전용 정당·VM `weather_list_vm.dart:23-27` fold만·누수 없음). SD-7✅·VW-1✅·VW-6✅·ST-1✅. ST-2 ✅(query-only·`weather_list_state.dart:15-17` error 필드 없음·throw payload=BadRequestResponse). DT-1✅·DT-2✅. BG-1/2 ✅✅(`flutter analyze lib test`→"No issues found!" 로컬 실행). FC-1: 🟡 G-1 서버의존·G-2~G-8 PASS(G-8 정확일치 cloudy=구름많음). **X=정규 dddart형**(@freezed+@JsonKey 직파싱·`weather_forecast.dart:11-25`·States @freezed).

**Y(codex)**: SD-1 🟡borderline-PASS(requireSevenDays 불변·VO). SD-7✅·VW-1✅·VW-6✅·ST-1✅. **ST-2 ❌ DEAD FIELD**(`weather_forecast_list_state.dart:5-8`+view 소비 `list_view.dart:40-50`·VM 미set·`isShow` 분기 unreachable 死코드·consumeError 전무 — "decision-PASS∧semantic-FAIL"·decisive ❌). DT-1✅·DT-2✅(requireSevenDays throw가 safeApiCall 안 정규화). FC-1: 🟡 G-1 서버의존 + **G-8 "구름 많음" 공백 drift**(soft·borderline N7). **SD-4/DT-4/ST-3 leaning FAIL/WEAK**: Y는 **@freezed·json_serializable 0**(전부 수기 `final class`+수동 `fromJson`·`_readString/_readInt/_readDouble`+`FormatException`·`daily_forecast.dart:15-73`·States 비-@freezed) → RUBRIC SD-4("@freezed+json 직파싱")·DT-4·ST-3 정면 위배(컴파일은 됨=의미 이탈). DI: Y `{Dep?}` = **정당 테스트 seam(PASS)**(추상 인터페이스·컨테이너 0·실사용)·X는 네트워크 seam(더 순수). **A13**: 수기 파서가 BG 통과로 백스톱 회피(codegen 거부 엔진이 백스톱 전체 탈출=게임가능 갭)·서버순서 의존 미명명·죽은 분기 smell.

**n2 한줄**: X=더 깨끗·정규형(freezed/codegen·죽은상태 0·최소-정확 도메인) / Y=야심차나 ST-2 죽은필드(치명 후보)+광범 SD-4/DT-4/ST-3 이탈(전 도메인+상태 수기). SORT는 양쪽 동일(미차별)·DI는 비치명.

---

## grader adv (적대) — raw

**X(claude)**: SD-1 contested→lean PASS(도메인 판정 0이나 task 유일판정=정렬이 *부재*·SD-1 누수 아님·FC에서 과금 / 실질성 관문 패널 확인 권고). **FC-2 M1 ❌**(`weather_list_vm_test.dart:48-52` orderedEquals가 **사전정렬** dates·fold만·"무정렬 코드도 green"·정렬코드 0·주입사이트 부재 → M1 비-vacuity 입증불가=FAIL). ST-2 PASS(error 필드 없음·깨끗). DT-1✅·VW-6✅·VW-7✅(`weather_list_body_section.dart:33` 인라인 직렬화 0)·DT-4✅. **X 테스트 정직**: M2/M3/M4 비대칭·anti-swap 단언(`weather_summary_card_widget_test.dart:96-98` `'7° / -3°'`+`findsNothing('-3° / 7°')`)·유일 디코이=M1 정렬 누락.

**Y(codex)**: **ST-2 ❌(critical)**(죽은 error 필드·view 분기 死·consumeError 0·`states:5-8`·`views:40-50/46-60`·`vms:24/25`). **DT-5 ❌→WEAK**(전 계층 optional 주입 DI seam·4사이트). **SD-4 ❌**(엔티티 비-@freezed 수기 `fromJson`+`_readInt/_readDouble`·`daily_forecast.dart:15-73`·`daily_forecast_summary.dart:12-49`=도메인 내 변환계층). SD-3 contested→lean PASS+flag(requireSevenDays 생성검증). **FC-2 M1 ❌**(X와 동일·정렬 0·`weather_forecast_test.dart:28-40`·`list_view_test:73-81` 사전정렬·렌더순서 미단언). **BG-1/overrideWith2 flag**: `overrideWith2` 비표준 우려 → **결정레인이 해소**(codex test +45 컴파일·통과 = 유효). **Y 디코이**: M1 정렬 누락 + 죽은 error 분기 미검증(테스트가 AsyncError 경로만 침).

**adv Sort 판정**: 양쪽 정렬 0(grep 0)·서버순서 의존·G-1 런타임 luck·**FC-GOLDEN §2 M1 + EVAL §2.5 "뒤섞은 입력 필수·이미 정렬된 fixture는 무정렬도 green"** → **M1 FC-2 FAIL 양쪽**(룰이 이 게이밍을 명시 예견). **adv A13**: 서버순서 의존이 spec-sanctioned일 때 57차원 미포착·죽은-but-read 상태필드·수기파서 백스톱 탈출·실질성 관문(X 도메인 0행위) 확인 권고.

---

## A13 사각 신고 종합 (채점 미산입·차기 동결 입력)

| # | 출처 | 내용 |
|---|---|---|
| **A13-1** | n1·n2·adv 수렴 | **"서버순서 위임"의 FC-2/M1 구조적 미닫힘(6런 연속)** — gate "서버순서 유지"가 정렬코드 부재를 *정당화*하는지, 아니면 *비-vacuity 갭*인지 골든이 명시 안 함. **차기 동결 1순위 결정**: M1을 (a) 死=FAIL 유지 (b) 서버계약 보장 시 N/A (c) "뒤섞은 fake 주입 위젯테스트 강제"로 비-vacuous 살리기 중 택. |
| **A13-2** | n1·adv | **아이콘 distinct 미검증(Y)** — `weather_condition_ui_extension_test`가 색 set-size만·아이콘 set 미단언 → 아이콘 swap/collapse 우회(약화단위 디코이·코퍼스 discipline-test §3.1 정합). |
| **A13-3** | n2·adv | **수기 비-@freezed 모델이 BG 통과로 백스톱 전체 탈출** — codegen 거부 엔진이 결정레인 무사통과·SD-4/DT-4/ST-3 의미레인만 잡음. "도메인/상태가 @freezed인가"를 보는 결정 검사 부재=게임가능 갭. |
| **A13-4** | n1·n2 | **G-8 라벨 공백 drift("구름 많음" vs "구름많음")** — FC G-8/N7이 이진 문자열 일치라 공백·시각등가 한글 허용대역 없음 → FC-GOLDEN에 "정규화 후 비교" 단서 필요. |
| **A13-5** | n2·adv | **죽은-but-read 상태필드 패턴**(Y) — view가 *절대 set 안 되는* state 필드에 분기(死 분기). ST-2가 "죽은필드"로 잡으나 "view가 phantom state에 분기" 일반 smell은 전용 차원 없음(Q-7 死코드는 결정레인이라 null-guard 분기 못 봄). |
| **A13-6** | adv | **실질성 관문(§3 step 2.5)** — X 도메인 행위 0(순수 데이터홀더). 읽기전용 BC라 degenerate 아님(HR-3 정당)으로 판정했으나 패널 확인 권고. |
