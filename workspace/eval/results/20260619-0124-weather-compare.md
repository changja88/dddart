# 8차 비교 집계 — weather 양판 (claude vs codex)

> EVAL-METHOD §4·§4.5. 채점일 2026-06-19 01:24. 코퍼스 `cda1950`(feedback-010 v2). baseline `abee26d`. 런 `dddart-20260618-2228-{claude,codex}`. 결과지 `…-weather-{claude,codex}.md`·grader raw `…-graders-raw.md`. **N=1·인과 단정 금지·동률 시 보조 신호.**

## 종합 판정
| 엔진 | 빌드 | 치명 17 | 전체 | TIER-Q | 한 줄 |
|---|---|---|---|---|---|
| **claude** | BG-1·2 ✅ | **FC-2 ❌**(1/17 FAIL) | **❌ FAIL** | (중·기록) | 목록 타일 최고/최저 기온 슬롯 무단언 → M3 green 생존(vacuous) |
| **codex** | BG-1·2 ✅ | ✅ 17/17 | **✅ PASS** | **상** | 직렬화 VO 단일거주·기온 슬롯 양쪽 비-vacuous·super.key 복구 |

## 차원 차분 (claude → codex)
| 차원 | claude | codex | 비고 |
|---|---|---|---|
| FC-2(치명) | ❌ FAIL(M3 목록기온 vacuous) | ✅ PASS(M1-M4 4/4 RED) | **결정 갈림** — codex 목록 카드 keyed slot 단언 |
| VW-7 | 🟡 WEAK(직렬화 view 인라인) | ✅ PASS(직렬화 VO `toRouteParam`) | **⑥① 핵심** — claude 7차 navigator→8차 view(N=1 진동)·codex 6/7/8차 VO 일관 |
| SD-3 | ➖N/A(VO parse 없음) | ✅ PASS(parse 경계 적법) | ⑥③ 측정 명확화 적중 |
| ST-8/retry | ✅(복구) | ✅ | ⑥② claude 7차 회귀 복구·RV1 무발화 |
| Q-1 super.key | ✅(10/0) | ✅(11/0·복구) | ⑥④ codex 7차 회귀 복구 |
| 결정성 | ✅ 병렬5/5 | ✅ 병렬5/5 | ⑥⑤ 둘 다 결정적(7차 flaky 미재현) |
| 치명 16(FC-2 외) | ✅ 전수 | ✅ 전수 | SD-1·SD-7·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·HR-1/4/5·BG·FC-1·FC-3 |
| 테스트 규모 | 5파일/19 | 13파일/31 | codex 도메인 단위테스트(VO·chronology) + 위젯 폭넓음 |

## 과정 지표 (차분만·절대값/인과 금지·§4.5)
- 산출 규모: claude 92파일·12.7K행 / codex 117파일·13.9K행(vs abee26d). codex가 도메인 단위테스트·VO 분해로 파일 多.
- 두 엔진 내부 파이프라인 상이 → 절대 비교 무의미. *동률 아님(품질 갈림)이라 과정 지표는 판정 부차*.

## 갈림의 본질
- **codex 우위 축 = 테스트 seam 정합·직렬화 거주**: 판정을 맞는 seam(도메인 단위·VO)에 두고 그 seam을 비-vacuous 테스트로 두드림. 목록 기온까지 keyed slot 단언 → FC-2 견고. 직렬화 VO 단일거주(VW-7 모범)는 6→7→8차 일관(엔진 안정 성향).
- **claude 약점 축 = 커버리지 진동·표시변환 거주 흔들림**: 7차 M4 직렬화 vacuity를 (measure-first 골든 M4로) 고쳤으나 8차 M3 목록기온 vacuity가 새로 노출(테스트 커버리지가 회차마다 다른 구멍). 직렬화도 navigator(7차)→view(8차)로 misplacement 위치만 이동(guide 취약).
- **measure-first 측정망은 양 엔진 모두에 정확 작동**: VW-7 FAIL문언(claude 적발)·골든 M4 seam(M4 red화)·SD-3 경계(codex PASS 합의)·러너 게이트(둘 다 결정적 확정·게이트 버그 적발) — 측정 보강이 7차 사각을 닫음.

## measure-first / 코퍼스 처방 평가 (feedback-010 ⑥ 요지·상세는 fix 원장)
- **측정 보강(eval 단일출처) = 전건 작동**: ①골든 M4·VW-7 ②RV1 백스톱 ③SD-3 경계 ④(보류) ⑤러너 게이트(+버그 수정). 8차가 1차 검증.
- **코퍼스 산문(미러) = claude 거동 미교정**: architecture-ddd §3 직렬화 거주 규칙이 claude misplacement(view)을 막지 못함 → guide 취약 thesis 재확인(N=1). 단 *측정이 잡음*. 기계화(custom_lint/AST/grep floor) 승격 재검 입력.
- **신규 발견**: claude FC-2 실패 원인이 7차(M4)와 8차(M3)에서 다름 — "FC-2 vacuity"가 단일 사이트가 아니라 *커버리지 전반의 진동*. 골든 mutation 전수(M1~M4)를 매 채점 실증 주입하는 결정 레인이 이를 포착(7차는 M4 집중이라 M3 사각 잠재).

## ⚠️ 한계
- N=1 — "codex가 항상 우수·claude가 항상 FC-2 취약" 단정 금지. 6차 claude는 PASS·codex finalize-collapse 등 회차별 진동 존재.
- 의미 레인 전원 Claude 계열(비-Claude 오라클 미확보).
- 시각/디자인 충실도 비측정(A1·인간 오라클) — 구조·기능 PASS ≠ 시안 일치.
