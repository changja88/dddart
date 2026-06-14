# 양판 비교 집계지 — 날씨 7일 예보 2차 라이브런 (claude vs codex · 1차 대비 회귀 검증)

> **방법** EVAL-METHOD v3.1 §4(양판 비교·A9 과정지표) · **작성** 2026-06-15 02:14 KST · **baseline** `2633087`(순정 민낯·2벌 IDENTICAL) · **코퍼스** `b7446e8`(피드백3 교정) · **SCENARIO** weather §1 verbatim(양판 동일·디자인=Stitch MCP 미연결→자체설계) · **FC-GOLDEN** `tools/FC-GOLDEN-WEATHER.md`(동결·양판 공통).
> **⚠️** N=1·**인과 단정 금지**·**앵커=예시**·**소급 FAIL 금지**·**비-Claude 오라클 0(양판 grader 동일 계열·A3)**·디자인 충실도=인간 오라클 미측정. 절대값 비교 무의미(엔진 내부 파이프라인 상이) — *차분*·*동률 시 보조*로만 읽음(§4.5 comparability).
> **개별 결과지**: claude `20260615-0106-weather-claude.md` · codex `20260615-0214-weather-codex.md`. grader 영속 각 `*-graders.md`.

## 1. 종합 — 1차 → 2차 (★핵심)

| | 1차 (코퍼스 `676e317`) | 2차 (코퍼스 `b7446e8`·피드백3 교정 후) | 변화 |
|---|---|---|---|
| **claude** | ❌ FAIL (FC-2 테스트 0) | ❌ FAIL (FC-2 테스트 0 + **ST-2 plain Exception**) | = FAIL 유지·치명 1→2 |
| **codex** | ✅ PASS (WEAK 2) | ❌ **FAIL** (FC-1 G-8 영문라벨 + 백스톱 5 blocker) | ⬇⬇ **PASS→FAIL 회귀** |

**→ 피드백3 코퍼스 교정 후 양판 재실행 = 둘 다 2차 FAIL.** 1차에 유일하게 PASS였던 codex마저 2차에 FAIL로 떨어짐.

## 2. 치명 게이트 양판 대조 (2차)

| 치명 | claude 2차 | codex 2차 |
|---|---|---|
| SD-1·2·7 / VW-1·6 / ST-1·4 / DT-1·2 / HR-1·4·5 | ✅ PASS/NA | ✅ PASS/NA |
| **ST-2** 에러 채널 | ❌ **FAIL**(`throw Exception(msg)` 격하) | ✅ PASS(`throw error` BadReq 정석) |
| **FC-1** 골든 | 🟡/❌(정렬·G-7 PASS) | ❌ **FAIL**(G-8 영문라벨 + G-1 정렬) |
| **FC-2** 비-vacuous | ❌ **FAIL**(테스트 0) | ✅ PASS(테스트 22·1차 mutation 실증) |
| **FC-3** 도메인 정합 | ❌(N2 정렬) | ❌(N2 정렬·G-8 밀림) |
| BG-1·2 | ✅ | ✅ |
| 백스톱 51종 | ✅ 0 blocker | ❌ **5 blocker**(HR-2·3·6 비치명·구조 회귀) |

**대칭 결함**: 양판이 **서로 다른 치명에서** FAIL — claude는 **테스트·에러채널**(FC-2·ST-2), codex는 **라벨·구조**(FC-1·백스톱). 한쪽이 잘한 걸 다른 쪽이 못함:
- claude: 라벨 한글 정석·구조 백스톱 0 / **테스트 0·ST-2 격하**
- codex: ST-2 정석·테스트 22 / **라벨 영문회귀·백스톱 5·legacy provider**

## 3. 과정 지표 차분 (A9 — 동률 시 보조·절대값 아님)

| 지표 | claude 2차 | codex 2차 | 차분 |
|---|---|---|---|
| 러닝타임 | ~1h 4m | **~1h 51m** | codex **+80%** |
| 슬라이스 | 3 | 4 | codex +1 |
| discipline 감사 | 1(holistic) | **3**(model-boundary·final·final-rerun) | codex +2 |
| 감사 반영 coder 재호출 | 1 | **3**(반영2·radius1) | codex +2 |
| 커밋 수 | 7 | **14** | codex +7 |
| 백스톱 실행 | ✅ 실행 | ❌ **미실행(경로 소실)** | codex 자기검증 누락 |

> **둘 다 FAIL인데 codex가 80% 더 소모** = codex 과정 비효율. 그 시간이 **토끼굴**에 빨림(아래).

### 토끼굴 대조
| | claude (1h4m) | codex (1h51m) |
|---|---|---|
| 최대 토끼굴 | **unknown enum 폴백**(계약상 안 오는 값 — 설계 7절·G1 Z 사용자 상신·codegen 소스 추적·감사 nit 왕복) | **lint resolver 충돌**(SCENARIO 무관 — pub add·outdated×2·/tmp 다운그레이드×2·architect 재호출·결국 미채택) |
| 환경 마찰 | (적음) | **SDK 캐시 쓰기**로 거의 모든 flutter/dart 명령 sandbox 1차 실패→승인 재실행(×2) |
| 결정적 필수검증 누락 | **테스트 0·정렬 인지 0** | **백스톱 미실행**(→의미 재감사가 구조 5 blocker를 "satisfied"로 오판) |
| 공통 | "흥미로운/막힌 곳"에 시간 쓰고 **결정적 필수(claude=테스트·정렬 / codex=백스톱·라벨)를 건너뜀** | |

## 4. 회귀 검증 결론

1. **피드백3는 1차 *비치명 품질*(타입·내비·구조 충실도)을 겨냥했고 그건 일부 개선됐으나, 1차 *치명*(claude 테스트 0)은 안 건드렸다** → claude 종합 FAIL 불변. 게다가 claude ST-2가 후퇴, codex는 G-8 라벨·구조가 회귀.
2. **양판 공통 = 결정적 필수 검증을 강제하는 게이트 부재**: 파이프라인이 "테스트가 산출됐나"(claude)·"백스톱이 실행됐나"(codex)·"task 표시 어휘(한글)가 보존됐나"(codex G-8)를 강제하지 못함.
3. **N=1 한계**: codex 1차 PASS→2차 FAIL이 "피드백3 부작용"인지 "런 비결정성"인지 단정 불가. 단 **2차 양판 동시 FAIL은 코퍼스가 green 산출물의 *정확성·구조*를 보장하지 못함을 시사**(빌드·백스톱·analyze는 green인데 기능/구조 결함).

## 5. 코퍼스 교정 후보 (우선순위)

> **→ 처방·예상효과 사전등록·검증 추적은 [`fix/feedback-004`](../fix/feedback-004-test-backstop-label-gates.md)로 승격**(measurement지/prescription지 분리). 아래는 측정 직후 raw 후보(요약).

**공통·최우선**
1. **coder 테스트 산출 게이트** (claude 1·2차 테스트 0의 근본·`coder.md` 책무 0). codex는 자발 생성했으나 보장 안 됨 → 게이트로 강제.
2. **G2 전 백스톱 exit 0 강제** (codex 미실행을 "통과"로 처리한 공백). 경로 소실 시 폴백.

**claude 계열**
3. **ST-2 명세-구현 일치**: design-spec §3.2 "throw error"(BadReq) 옳은데 coder가 plain Exception 격하·감수 미포착 → 미니게이트/백스톱에 "build throw=BadRequestResponse" 검증.

**codex 계열**
4. **task 표시 어휘 보존**: SCENARIO 한글 라벨을 G1에서 영문으로 바꿔 제시하는 경로 차단(coder/architecture-ui가 task 어휘 보존·FC-GOLDEN 한글 대조).
5. **애그리거트 직속 규약**: 추가 투영(detail)은 `entity/`로·골격 완비(codex ST4·ST5). use_case provider legacy 금지(@riverpod 클래스형).

**공통·차순위**
6. **정렬 책임 명시**: "오름차순=제품 보증 vs 서버 위임" SCENARIO 확정 + FC-GOLDEN 정렬 단언(양판 공통 G-1/N2).

## 6. 한 줄 요지

피드백3 교정 후 양판 2차 재실행 = **claude·codex 둘 다 FAIL**(1차 PASS였던 codex도 회귀). 서로 다른 치명에서 무너짐(claude=테스트0·ST-2 / codex=영문라벨·구조 백스톱5). **빌드·analyze·백스톱(claude)·치명 의미 척추는 양판 청결**한데 *기능 정확성(FC)·테스트·구조 규약*에서 갈림 → 코퍼스가 green을 정확성·구조로 잇는 게이트가 부족. codex는 80% 더 썼으나 토끼굴(lint·환경·과분할·백스톱 미실행)에 소모돼 1차보다 나빠짐.
