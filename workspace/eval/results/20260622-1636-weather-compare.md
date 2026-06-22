# 비교 집계지 — weather(7일 예보) · codex ↔ claude · 14차

> `EVAL-METHOD.md §4`. 입력: `20260622-1636-weather-claude.md`·`20260622-1636-weather-codex.md`. **baseline** `abee26d` · **코퍼스** `e49b4fe`(레이아웃 형상 Stitch SoT 복원 — 14차 검증 대상) · **task** SCENARIO-WEATHER §1 verbatim 양 엔진 동일.
> ⚠️ **comparability**: 두 엔진 파이프라인이 달라 *절대값* 비교 무의미 → 같은 사건 종류의 차분·보조 신호로만. N=1·인과 단정 금지·in-family(전원 Claude grader).

## ★14차 한 눈 = DT-2 swap(13차 역전) + 형상 F 양 엔진 적중

| 축 | 13차 | 14차 | 변화 |
|---|---|---|---|
| **DT-2(단일출구)** | claude ✅ / codex ❌ | **claude ❌ / codex ✅** | **완전 역전(swap)** |
| **픽스처** | claude PASS / codex FAIL | **claude FAIL / codex PASS** | **역전** |
| **레이아웃 형상(F)** | 양 엔진 축 회귀(세로↔가로) | **양 엔진 전 컨테이너 시안 일치** | **양 적중**(14차 시술 표적) |
| **에셋(A)** | 양 엔진 실재 | claude 유지 / **codex 회귀** | codex만 끊김 |

## A. 산출물 품질 차분

| 항목 | claude | codex | 우세 | 비고 |
|---|---|---|---|---|
| **치명 게이트(18) PASS 수** | **17** (DT-2 ❌) | **18** | **codex** | claude DT-2 단독 FAIL → 픽스처 FAIL |
| **픽스처 종합** | **FAIL** | **PASS** | **codex** | 14차는 codex 우세(13차 정반대) |
| TIER-Q 등급 | 참고(사전식 종료) | **상**(WEAK 4·FAIL 0) | codex | claude는 픽스처 FAIL로 TIER-Q 미산정 |
| 차원별 ❌ 목록 | **DT-2**(safe_api_call fromJson 무가드 누수) | 없음 | codex | 양 엔진 swap의 결과 |
| 빌드/analyze | ✅ green·drift 0 | ✅ green·drift 0 | 동률 | 둘 다 wrote 0 outputs |
| 테스트 | 27 green(순정) | 37 green(순정·dart-define 흠 해소) | 동률(codex coverage 폭↑) | codex design_system 컴포넌트 테스트까지 |
| 백스톱 58종 | clean(blocker 0) | clean(blocker 0) | 동률 | 결정 레인 양 엔진 닫힘 |
| **레이아웃 형상(F·★시술 표적)** | 전 컨테이너 시안 일치 | 전 컨테이너 시안 일치 | **동률(둘 다 적중)** | g3 독립 대조표 6/6·6/6 모두 ✅ |
| **에셋 공급(A)** | 유지(Image.asset·실파일·manifest ok) | **회귀**(images:[]·Image.asset 0·실파일 없음) | **claude** | codex Phase 0 이미지 미추출(N=1) |
| FID 자동 | A1 폴백(exit 3) | A1 폴백(exit 3) | 동률 | screenProbes 미노출(9차부터·양 엔진) |
| 도메인 형태 | date=String | ForecastDate VO(Comparable) | codex(SD-4) | codex 도메인 모델링 우위 |
| 유비쿼터스 언어 | 계층관통 일치 | application↔domain 어휘 drift(SD-9 🟡) | claude | claude 어휘 일관성 우위 |

> **품질 우열**: 픽스처 종합 = **codex 우세**(claude DT-2 치명 FAIL). 단 우열의 결정 인자(DT-2)는 코퍼스가 fromJson 가드를 명시 안 한 영역의 **N=1 비결정 swap**이라 *엔진 실력차가 아니라 코퍼스 미규정의 비결정성*으로 해석(13차엔 정확히 반대로 갈렸음). **14차 시술 표적(레이아웃 형상)은 양 엔진 동률 적중** — 시술 효과는 엔진 무관하게 발현.

## B. 과정 지표 차분 (차분만·절대값 아님)

| 지표 | claude | codex | 차분 | 우세 |
|---|---|---|---|---|
| 갭 규모(files / +insert) | 114 / 13077 | 119 / 14604 | codex +5 / +1527 | (절대값 비교 무의미·기록만) |
| 커밋 운용 | 미커밋(작업트리 dirty·HEAD abee26d) | 8커밋(HEAD 52741f2) | — | codex가 슬라이스별 커밋 |
| 테스트 수 | 27 | 37 | codex +10 | codex coverage 폭(design_system 포함) |
| 도메인 폴더 | daily_forecast/weekly_forecast | weekly_forecast/daily_forecast_detail | — | 분할 방식 차 |

> architect·리뷰어·tracer는 두 엔진 공통 파이프라인 → 차분 0(상쇄·기록만). **엔진 양판 축 일반화(A9)**: 위는 같은 SCENARIO verbatim의 사건 차분이며, 절대값(예: 토큰·반송 수)은 파이프라인 상이로 비교 안 함.

## 판정 (EVAL-METHOD §4.3)

- **산출물 품질 우열**: 14차는 **codex 우세**(픽스처 PASS vs claude DT-2 치명 FAIL). 단 **결정 인자 DT-2는 양 엔진 swap의 N=1 비결정**(13차 claude PASS·codex FAIL → 14차 완전 반전). 코퍼스 `architecture-data`/`implementation-dart` safeApiCall 골든이 "fromJson 자기 정규화기 throw 가드"를 **미규정**한 영역에서 회차마다 한쪽이 샌다 → **엔진 실력 우열이 아니라 코퍼스 미규정의 증거**(feedback-014/015 "DT-2 가드 골든 1순위"의 N=2 입증).
- **★14차 시술 표적(레이아웃 형상) 판정 = 양 엔진 동률 적중**: feedback-015 F(형상 Stitch SoT 복원)가 양 엔진 전 컨테이너에서 13차 축 회귀를 회복(claude 메트릭 섹션 세로·카드 헤더 가로 / codex 카드 flex-col·hero baseline·앱바 고정). **시술 효과는 엔진 무관·N=1이나 양판 2/2 동시 발현이라 신호 강함**. ★최종 판정 = **사용자 육안**(자동 FID A1 폴백·design §10 체크리스트).
- **N=1**: 인과 단정 금지. DT-2 swap·에셋 회귀는 "처방 후 동시 관찰"로 기록(유발 단정 아님).

## 다음 라운드 입력 (우선순위)

1. **🔑 DT-2 가드 골든**(1순위·feedback-014/015 예고·**N=2 입증 완료**): safeApiCall이 `BadRequestResponse.fromJson`(또는 임의 정규화기)을 try/catch로 가드해 "정규화기 자신의 throw"도 단일출구로 수렴하도록 `architecture-data`/`implementation-dart` 골든 명시. **양 엔진 swap의 근절책**(claude 14차·codex 13차가 같은 구멍).
2. **에셋 공급 비결정**(codex 14차 회귀): fetch_images/asset-manifest 단계가 회차마다 0건/N건으로 갈리는지 점검(형상 시술 무관·has_design_images gate 작동 확인).
3. **screenProbes 미노출**(9차부터·FID 자동 봉합): implementation-test §7 표준 pump 규약을 코더 산출물이 따르게(측정 진입점).
4. **형상 F 자동 측정화**: 현재 육안. screenProbes 봉합 시 FID 게이트가 형상 축까지 자동 포착 가능(feedback-015 측정 설계 후속).
