# 8차 grader 패널 raw 증거 — weather (X=claude · Y=codex)

> EVAL-METHOD §2.0/§2.2 (A3 blind 증거 영속). 채점일 2026-06-19 01:24. 코퍼스 `cda1950`. baseline `abee26d`. 런 `dddart-20260618-2228-{claude,codex}`.
> **blind 집행**: grader 3명 전원 (1) 결정 레인 결과 미수령 (2) 익명 X/Y(`/tmp/grade-{X,Y}`·엔진정체·경로 스크럽·`.g/.freezed` 제거) 수령. 매핑(X=claude·Y=codex)은 조정자만 보유.
> ⚠️ **비-Claude 오라클 미확보(§2.0)**: grader 3명 전원 Claude 계열 — 의미 레인 독립성 in-family attestation 한계. 다음 라운드 비-Claude/인간 grader 1명 확보 과제.
> **조정자 정정 1건**: grader 3명 공통 "Y VW-6 FAIL(전역키 내비)" → 조정자가 코퍼스 architecture-ui §6:92(전역키 `currentContext` pushNamed = HaffHaff 처방 관용구)·RUBRIC VW-6(design_system *컴포넌트* 한정)·Q-9주의(전역 내비 합법)로 **PASS 정정**. 적대 grader가 이 seam을 false-positive 자기점검에 명시(조정자 재량 위임)했고 코퍼스로 확정. *자기보고 불신이 grader에도 적용된 사례.*

## grader-1 (표준·구조 치명) — agentId ae56daa9551d13e7b

치명(X|Y): SD-1 PASS|PASS · SD-7 PASS|PASS · VW-1 PASS|PASS · **VW-6 PASS**|~~FAIL~~**→PASS(조정자 정정)** · ST-1 PASS|PASS(주의) · ST-2 PASS|PASS · DT-1 PASS|PASS · DT-2 PASS|PASS · HR-5 N/A|N/A(단일BC) · FC-3 PASS|PASS.
- **VW-7**: **X FAIL** (`weather_list_view.dart:41-45 _serializeDate` 다필드 조립 view 거주·VO 부재) | **Y PASS** (`forecast_date.dart:27-33 toRouteParam` VO 거주).
- **SD-3**: X PASS(미저촉) | Y PASS(미저촉·`forecast_date.dart:16 DateTime.parse`는 safeApiCall 정규화·정상값 미차단).
- **FC-1 골든**: X[G1-G8 ✓] Y[G1-G8 ✓]. 6색 distinct 양쪽 hex 확인(X 전용 weather 토큰·Y 일반 토큰 매핑 둘 다 6고유).
- **FC-2 mutation 실측**(grader 자체 주입): **X FAIL** — 정본 M2(색 swap)·정본 M3(목록 high/low slot) GREEN(색 테스트=집합 cardinality만·목록 타일 기온 슬롯 미단언·상세 hero로만 커버) | **Y PASS** — M1~M4 전부 RED(per-condition orderedEquals·keyed slot 단언).
- TIER-Q: **X 중**(WEAK 2 — Q-7 표시포맷 자유함수·Q-8 import순서) | **Y 상**(WEAK 1 — detail view build 내 재파싱).
- 사각: ①Y 테스트가 전역키 내비를 회귀-고정(기능 PASS·VW-6는 코퍼스상 합법으로 정정) ②X 표시 변환 거주 두 곳(extension+widget 함수) 스멜 ③Y `WeatherDetailState.forecast` non-null이 X의 nullable+`!`보다 타입안전 ④계약 path 차이(최종 URL 동일).

## grader-2 (표준·FC골든/테스트품질) — agentId ad09053c0862c4756

- **FC-1**: X[G1-G8 ✓] Y[G1-G8 ✓] (전건 줄인용). Y `unknown` 7번째 enum은 골든 데이터 D 미발화·6실값 distinct → G7/G8/N7 무저촉.
- **FC-3**: X N1-N7 관측 0 | Y N1-N7 관측 0.
- **테스트품질(FC-2 vacuity 의미)**:
  - 정렬-뒤섞음: X ✓(`forecast_test.dart:21-39` 입력≠기대 양끝echo) | Y ✓(`forecast_chronology_service_test.dart:8-27`+중복날짜 안정성).
  - 탭-echo: X ✓(`weather_list_view_test.dart:64-90` non-edge.at(2)·실GoRouter·`forecastDate==serializeDate(tapped)`) | Y ✓(`forecast_list_view_test.dart:43-61` keyed card·`toRouteParam()=='2026-06-15'`).
  - **목록기온단언**: **X ✗** — 목록 타일 high/low 슬롯 단언 없음(최고/최저는 detail hero `weather_detail_view_test.dart:14-21`에만) | **Y ✓** — `forecast_day_card_widget_test.dart:41-52` keyed slot temp-max='7°'·temp-min='-3°'(비대칭·음수).
  - 색집합: X ✓ | Y ✓ (둘 다 Set 크기 강제).
- **SD-3**: X 미저촉 | Y 미저촉(경계 적용). VW-7 직렬화 거주: **X view 인라인(FAIL)** | **Y VO(PASS)**.
- 사각: Y 전역키 내비(조정자 정정)·Y detail build 내 `fromRouteParam` 재파싱·X 상세 metrics 습도/강수확률 아이콘 중복(라벨 distinct·A1 비측정).

## grader-3 (적대) — agentId a0ec12f7cc3f71f94

- **X 적발**: VW-7 FAIL(`weather_list_view.dart:41-45`·`_support.dart:71-75`가 동일 직렬화 복제→VO 미소유 확정) + **FC-2 목록 기온슬롯 부분공백**(M3 목록 swap 시 목록 테스트 green 생존·상세 seam은 별개 위젯).
- **Y 적발**: ~~VW-6 FAIL 후보(전역키 내비)~~ → **오탐 자기점검에서 seam 명시·조정자 코퍼스로 PASS 정정**. `unknown` enum은 "검토 후 기각"(골든 무저촉·방어적 정당).
- **치명 위협**: X = 치명17 중 FAIL 없음(VW-7 비치명·FC-2는 grader 관점 WEAK이나 **조정자 실측 정본 M3 GREEN=FC-2 치명 FAIL**) | Y = 치명17 청정(VW-6 정정 후).
- 오탐 자기점검: Y/VW-6 앵커 해석 seam(design_system 한정 vs 전역키 일반)·X/VW-7(명세 §3.5가 view 합법화 안 함→위반 유지)·X/FC-2(상세·목록 별개 위젯→부분공백 유지).

## 차원별 일치율(κ) — 의미 레인

| 차원 | grader 합치 | κ |
|---|---|---|
| FC-1(G1-G8) X·Y | 3/3 전건 PASS | 1.0 |
| FC-3 X·Y | 3/3 관측 0 | 1.0 |
| VW-7 X=FAIL·Y=PASS | 3/3 | 1.0 |
| SD-3 Y=PASS(미저촉) | 3/3(경계 적용) | 1.0 |
| **VW-6 Y** | grader 3/3 FAIL → **조정자 1/3 정정(코퍼스)** | — (해석 seam·인간 큐 종결) |
| FC-2 X=FAIL·Y=PASS | 3/3(grader2·3 목록기온 공백·1 실측) + 조정자 실측 일치 | 1.0 |
| SD-1·SD-7·ST-1·ST-2·DT-1·DT-2 X·Y | 3/3 PASS | 1.0 |

> 만장일치 보드 아님(VW-6 정정 1건) → 단일저자 위장 적신호 아님(per-grader 산출 3종 영속·κ 출력).
