# dddart eval 메타 검증 — 채점자를 채점

> **무엇**: 양판 라이브런 채점(codex ⏸️ / claude ❌)의 ① 결과지↔코드 정확성(사실층) ② 채점 방식(EVAL-METHOD v3.1·RUBRIC) 타당성(방식층)을 검증. **채점 방법**: ultracode Workflow(8 에이전트·사실 재감사·N/A census·축편향·A1~A14 적대 검증·positive control) + 메인 루프 Phase B(codex FC-2 mutation 실제 실행) + 인간 오라클(디자인).
> **채점일**: 2026-06-14 21:59 · **대상 결과지**: `results/20260614-{0135-weather-codex,0151-weather-claude}.md` · **대상 코드**: `dddart-run/dddart-20260613-2310-{codex,claude}`(HEAD codex `1ef3f50`·claude `7ac4aa8`) · **코퍼스**: `676e317`+미커밋 피드백 교정.
> **⚠️ 정직 가드**: RUBRIC 재판정 안 함(인용 실재·뒷받침만 검사·순환 차단) / 디자인 충실도는 AI 동종 사각이라 인간 위임 / 교정안은 후보(실행 별도 승인) / N=1 인과금지.

---

## 0. 종합 한 줄

**두 결과지의 판정은 사실로 정확하다**(치명17+FC 전 행 코드 뒷받침). 그러나 **채점 *방식*에 HIGH 결함 3건**(A3 blind이 증거상 명목뿐·A12 positive control 미입증·A1 디자인 구조적 미측정)이 실재한다. 채점기는 **거짓-FAIL 기계가 아니다**(known-good 11/16 게이트 정상 PASS)지만 **단 한 번도 완전 PASS를 산출한 적이 없어** "PASS를 낼 수 있음"이 미입증이다. codex FC-2는 mutation 실행 결과 **테스트 비-vacuous 입증→PASS 방향**(내비 커버리지 공백 WEAK 단서).

---

## 1. 사실층 — 결과지↔코드 (정확하나 codex 인용 정밀도 흠)

**판정: 양판 결과지의 치명 17 + FC-1/2/3 전 행 `claimSupported=true`** — 인용된 코드가 결과지 주장을 실제로 뒷받침. 직접 재현: codex/claude `grep sort|compareTo|isBefore|reversed`=0(정렬 부재)·`find *_test.dart` codex=9·claude=0·ST-1 VM=UseCase만·DT-1/2 Either+단일출구 전부 코드 일치.

**단 codex 결과지 인용 정밀도 결함 4건**(판정은 안 뒤집으나 신뢰도 흠):
- Q-4 `forecast_list_view.dart:39-43` = **부재 행**(파일 39줄·promotion은 :35).
- §F-1 `forecast_list_content_section.dart:36` = **부재 행**(파일 31줄·직표시는 :23·25).
- FC-1 `kingdom-server forecast_data.py:22 range(7)` = **리터럴 불일치**(실제 `range(FORECAST_DAYS)`)·**채점 코드 루트 밖** 파일.
- ST-2 `view .when :29` = error가 아닌 **loading 분기** 지목.
- 부수: SD-7(8-21)·DT-1(15-24)·ST-3(8-14) 등 행범위가 파일 끝 2~6줄 **과대 인용** 반복.

claude 결과지 인용은 결함 0(깨끗). → **교정 후보**: 채점 방식에 "file:line 인용은 실재 행으로 해소 검증" 절 추가.

---

## 2. 방식층 — 축 편향 + 커버리지 상한

**축 단위 체계 비대칭 = TRUE**. 결정 가능 구조/계층축(SD·VW·ST·DT·HR·BG)은 backstop 51종·analyze·grep으로 "결정 닫힘"→인용 1줄로 ✅/❌ 확정(엄격). 동작축(FC-1·3)은 "의미(외부 오라클)"로 골든·사람 위임. **시각/디자인축은 측정 자체가 부재**(`grep RUBRIC 디자인충실|시안|레이아웃|픽셀`=0매치). 양판 자평 "리스크 전부 FC로 이동"은 채점 아키텍처가 닫을 수 있는 레인으로 리스크를 라우팅한 자기충족적 결과. *단* RUBRIC 헤더가 런타임/보안/디자인을 "명시적 비측정 후속 트랙"으로 선언 → "편향"보다 **결정 가능 영역만 엄격 게이트한 설계의 부작용**.

**커버리지 상한**: ➖(N/A) 거짓 0건(전부 정당)이나, **이 단일 read-only 시나리오로 검증 불가인 차원 = 6개**(SD-2·SD-6·ST-6·ST-7·DT-7·DT-9; claude는 +SD-3=7). 즉 57축 중 **~51축만 실측·약 11%는 단일 시나리오 구조상 사각**. 추가로 ST-2 액션채널·SD-4 VO(claude VO 폴더 빈)·SD-5 다중엔티티는 "얇은 발화"(read-only라 부분만). → **교정 후보**: S2(액션·교차BC)·S3(캐시·SDK) 시나리오로 나머지 축 실측.

---

## 3. Phase B — codex FC-2 mutation 실제 실행 (⏸️ 해소)

격리 /tmp 사본·baseline **26 green** 확정 후 주입:

| mutation | 적용 | 결과 | 해석 |
|---|---|---|---|
| **M2** 조건 라벨 swap(맑음→비) | ✓ | **RED** | `weather_condition_test`가 잡음 → 조건 매핑 비-vacuous |
| **M3** 기온 max↔min swap | ✓ | **RED** | 위젯 테스트가 잡음 → 기온 렌더 비-vacuous |
| **M4** 내비 날짜 param→상수 | ✓(sed 확인) | **GREEN** | 아무 테스트도 못 잡음 = **G-5 end-to-end 커버리지 공백**(헛테스트 아님) |
| M1 정렬 역전 | — | 주입 불가 | 정렬 코드 부재 |

**M4 GREEN 원인(코드 확정)**: `forecast_list_view_test.dart:107-109`가 `forecastDetailVMProvider.overrideWithBuild`로 상세를 고정 → 탭 param이 틀려도 상세 타이틀은 오버라이드된 VM(`forecast_detail_view.dart:33` `state.forecast`)에서 나와 변하지 않음 → 탭→param→상세조회 배선이 테스트로 실행 안 됨. 방법론 적대리뷰 C4 예측 적중.

**→ codex FC-2 확정**: M2·M3 RED가 "헛테스트" 혐의를 반증 → **테스트 진짜 비-vacuous → ⏸️에서 PASS 방향**. 단 **내비 param→상세조회 커버리지 공백을 WEAK 단서**로 명기(결과지 §F-4가 짚은 그 공백을 실증).

---

## 4. Positive Control — 거짓-FAIL 기계 아님 (단 완전 입증은 미완)

known-good = HaffHaff-App `store/inventory_status` 수직 슬라이스(view+vm+repo+ds+entity)를 치명 17 게이트로 채점.

**`wouldPass=false`** — 5개 FAIL: SD-7·VW-6·HR-4·ST-4·FC-2. **그러나 이것은 거짓-FAIL이 아니라 진짜-FAIL이다**:
- SD-7·VW-6·HR-4 3건은 모두 동일 원인 — HaffHaff App 계층이 `ErrorDialog.show()` 직접 호출(`inventory_app.dart:6,21`) — 이고, **dddart 표준이 *바로 이 HaffHaff drift*를 명시 교정 대상으로 지목**(architecture-ddd `final.md:165`·architecture-ui `final.md:99` "HaffHaff 실측 App 44중 36 ErrorDialog 직접 호출=Model→View 역류"). dddart는 HaffHaff 상위집합이 아니라 **의도적으로 더 엄격**(에러표시를 view ref.listen으로). 루브릭이 설계대로 위반을 정탐.
- ST-4(mounted 누락)·FC-2(테스트 0)도 HaffHaff 실태의 정직한 반영.

**무차별-FAIL 아님의 신호**: 11개 게이트(SD-1·2·ST-1·DT-1·2·HR-1·5·BG-1·VW-1·FC-1·3)가 known-good을 **정상 PASS**. DT-1 "Left=성공 방향 존중"·HR-5 "미발화 거짓FAIL 금지"·BG codegen 부재 근사가 방언 차이를 흡수해 불필요한 FAIL을 막음.

**미완**: HaffHaff 방언 전체가 App에서 Either를 throw로 접어(전역 132 ErrorDialog.show) dddart 규약과 구조 충돌 → dddart·HaffHaff 양쪽 만족하는 완전 슬라이스가 HaffHaff에 부재. **"루브릭이 진짜 known-good을 PASS시키는가"는 미입증**. → **교정 후보(A12)**: dddart 규약을 *준수하도록 작성된* 합성 known-good(에러=view ref.listen·UseCase Either 통과·mounted 가드)으로 재검, 치명 17 전수 PASS 확인 전엔 모든 FAIL에 "기계 결함 가능성 미배제" 단서.

> **함의(주목)**: 코퍼스의 기준점 방언(HaffHaff)이 그로부터 도출된 루브릭의 치명 게이트를 통과 못 한다 — *의도된 것*(dddart>HaffHaff 엄격)이나 "기준점 ≠ 루브릭 준수"임을 명시 이해 필요.

---

## 5. 방식 결함 원장 (A1~A14 · 적대 steelman 통과분)

| ID | 실재 | 심각도 | 핵심 | 교정 후보 |
|---|---|---|---|---|
| **A3** grader blind 증거 부재 | ✅ | **HIGH** | 설계는 채점/합성 분리하나 산출물에 **per-grader 노트 0·raw blind verdict 0·κ 0**(§2.2가 κ 의무인데). 만장일치+적대 0/12+κ 부재 = 단일 저자가 5목소리 작성과 정합. 게다가 전원 동일 모델 계열 | per-grader raw verdict 영속·커밋 / κ 차원별 출력 / **의미 레인에 비-Claude 오라클 1+ 의무** |
| **A12** positive control 부재 | ✅ | **HIGH** | 기계가 **단 한 번도 PASS 산출 0**(양판 FAIL/보류). §4 입증: 거짓-FAIL은 아니나 PASS 능력 미검 | 합성 dddart-준수 known-good fixture 사전등록·치명17 PASS 확인 게이트 |
| **A1** 디자인 충실도 미측정 | ✅ | **HIGH** | AI가 렌더를 못 봐 구조적 폐쇄 불가(문서 자인 RUNBOOK:54). VW-4/5/7=토큰 거주 위치·FC G=값 의미지 픽셀/레이아웃 아님. RUBRIC 57차원 시각 충실도 0 | RUBRIC §명시적 비측정에 "디자인=인간 위임" 명문 / (선택)스크린샷-diff·멀티모달 보조 grader / 결과지 헤더 ⚠️ "시각 충실도 비측정" |
| **A11** 단일런·variance | ✅ | MED | 선언된 N=1 한계. κ=채점자 일치도지 실행 분산 아님 | 치명 게이트 라벨만 K회(≥3) 재구동 분산 보고 |
| **A13** grader가 rubric 비평 안 함 | ✅ | MED | A1류 차원-부재 사각이 채점 중 안 드러나고 사후 적대리뷰 의존 | grader에 "현 rubric으로 안 잡히는 위반" 자유서술 1칸(채점 미반영·다음 동결 입력) |
| **A5** 코퍼스 편향(디자인축 부재) | ✅ | MED | A1 root cause(종속). 코드 규율 코퍼스라 시각축 구조적 부재 | A1과 단일 작업·디자인 충실도 별도 도출 라운드 필요 |
| **A9** FC 과정지표 미측정 | ✅ | MED | 과정지표가 "두 PLAN 비교"에만 게이트·weather는 codex vs claude 비교인데 비용 원장 0 | 과정지표(coder 호출·토큰·반송)를 codex-vs-claude 축에 확장(차분-only) |
| **축 편향** | ✅ | MED | 구조 엄격·동작/시각 관대(부분 선언된 범위) | A1·S2/S3로 동작·시각 축 보강 |
| **A2** 0테스트=즉시FAIL | ✅ | LOW | 대체로 정당(게이밍 차단). 좁은 흠: 순수 정적 BC | "FC 골든 mutation 대상 0인 BC는 FC-2 N/A 가능" + "widget test 0 vs 총 0" 구분(E2E 인정) |
| **A6** HR-5 디코이 | ✅ | LOW | 결정 못 잡음(의도)·의미 grader 의존 | 적대 grader가 HR-5 필수 커버 명문 + 후보 보조 스크립트 |
| **A7** produced/env | ✅ | LOW | 추가 축은 명확·조정자 *핀 업그레이드* 미규정 | "조정자는 코더 핀 버전 변경 안 함" 1줄 |
| **A8** 2:1 split 가중 | ✅ | LOW | 무가중 의도·split *방향*·1:1 동률 미명시 | split→라벨 사상 방향·동률까지 결정화 |
| ~~A4~~ lexicographic 정보손실 | ❌ | — | **기각**: 종합만 단락·정보는 전량 보고(양판 TIER-Q·57차원 그대로) | 불필요 |
| ~~A10~~ 완료시각 미기록 | ❌ | — | **기각**: 결과지에 착수 범위+mtime로 종료시각 사실상 기록 | (선택)범위 상한을 "채점 종료"로 명명 |
| ~~A14~~ 양판 트리거 비대칭 교란 | ❌ | — | **기각**: 비대칭 실재하나 이 런에서 미발동(양판 동일 verbatim 명시 호출)·codex⏸️/claude❌ 차이는 100% 테스트 수(invocation 하류) | 결과지에 "호출=명시 프롬프트·자동트리거 미발동" 1줄(오귀인 방지) |

---

## 6. 교정 후보 (실행 별도 승인)

**HIGH(우선)**: ①A3 — per-grader blind verdict 영속+κ 출력+**비-Claude 오라클** 의무(동종 사각 차단). ②A12 — 합성 dddart-준수 known-good fixture로 "기계가 PASS를 낼 수 있음" 입증 게이트. ③A1 — 디자인 충실도를 RUBRIC에 "인간 위임·비측정" 명문 + 결과지 헤더 ⚠️(구조/기능 PASS≠시안 일치).
**MED**: A13 grader 사각 신고칸 · A9 과정지표 codex-vs-claude 확장 · S2/S3 시나리오(커버리지 ~11% 사각) · 인용 정밀도 검증 절(codex 부재 행 2건).
**LOW**: A2/A6/A7/A8 좁은 단서.
**확정 갱신**: codex FC-2 ⏸️→PASS+WEAK(내비 커버리지 공백) — 결과지 갱신 대상.
**기각**: A4·A10·A14(steelman 승).

> **반영 이력**: ✅ **HIGH 3**(A3·A12·A1) — EVAL-METHOD §0-6·§2.0·§2.2·§2.5·§3-8·§6.1-2 + RUBRIC §명시적 비측정 + rubric-metrix(2026-06-14·이전 세션). ✅ **A12 fixture 실효화** — `tools/positive-control/`(치명17 PASS·mutation 3/3 red). ✅ **확정 갱신**(codex FC-2/정렬) — `results/20260614-0135-weather-codex.md` 갱신 완료(헤더 🔄·§F-1·§F-4). ✅ **MED 4**(A13 사각 신고칸·A9 양판 과정지표·인용 정밀도 검증절·S2/S3 커버리지 census) — EVAL-METHOD §2.2·§2.6·§4.5·§5 + rubric-metrix(2026-06-14). ✅ **LOW 4**(A2 FC-2 정적BC/E2E 예외·A6 적대 grader 필수 커버·A7 조정자 핀 업그레이드 금지·A8 split 방향/동률 결정화) — EVAL-METHOD §1.5·§2.0·§2.2·§2.5(2026-06-14). ⬜ **S2·S3 시나리오 *작성***(FC-GOLDEN 사전등록)만 미착수(별도 작업·라이브런은 사용자 드라이브).

---

## 7. 인간 오라클 필요 (A1·사용자)

디자인 충실도는 AI 채점자가 닫지 못한다(확정). 양판 산출 스크린샷↔Stitch 시안 **구조 대조는 사용자 육안**이 유일한 오라클 — 이미 사용자가 #1 피드백에서 수행(아이콘만→칩/라벨·중앙히어로→좌측·날짜포맷·팔레트 어긋남). 메타검증은 "eval이 이걸 *구조적으로 못 본다*"를 확증할 뿐, 대체하지 못함.

---

## 부록 — 검증 도구
- Workflow `wf_6946f161-fa2`(8 에이전트·785K 토큰): 사실 재감사 2·N/A census·축편향·A1~A14 3·positive control.
- Phase B mutation: `/tmp/codex-fc2`(격리)·baseline 26 green·M2/M3 red·M4 green·복원 확인.
- 코퍼스·런 폴더 불변(mutation은 /tmp 사본만).
