# 비교 집계지 — weather 15차 · 엔진 양판 (claude X ∥ codex Y)

> EVAL-METHOD §4(+§4.5 엔진 양판 축). 입력 = `20260623-0322-weather-claude.md`·`-codex.md`. baseline `abee26d`·코퍼스 `06a30ff`·채점일 2026-06-23. **⚠️ N=1·인과 단정 금지·절대값 비교 무의미(두 엔진 파이프라인 상이)·차분과 동률 시 보조 신호로만.**

## A. 산출물 품질 차분

| 항목 | claude (X) | codex (Y) | 우세 | 비고 |
|---|---|---|---|---|
| **픽스처 종합** | **FAIL** | **FAIL** | **동률** | 양판 FID 치명으로 전체 FAIL |
| 치명 게이트(20) FAIL 수 | **2** (FC-2 · FID-L1) | **2** (FID-L1 · FID-L2) | 동률(2:2) | 공통 = FID-L1 |
| 치명 PASS 수 | 14 + ➖3 | 15 + ➖3 | codex +1 | codex는 FC-2 PASS |
| TIER-Q 등급 | 상 (WEAK 1·Q-7) | 상 (WEAK 0) | codex | claude press 죽은 토큰 |
| 차원별 ❌ | FC-2·FID-L1 | FID-L1·FID-L2 | — | 아래 갈림 |

### 갈린 차원 (차분의 본질)
| 차원 | claude | codex | 우세 | 해석 |
|---|---|---|---|---|
| **FC-2** 테스트 비-vacuous | ❌ M2(색·아이콘) seam 테스트 부재·17/17 green | ✅ `ui_extension_test` M2 red | **codex** | claude는 매핑 깨져도 red 안 남 |
| **FID-L2** 섹션 구성 | ✅ 충실 | ❌ weekly-list 2섹션 분리·repeat→image | **claude** | claude 레이아웃 형상 덜 이탈 |
| **VW-4** 시각 토큰 | 🟡 press 토큰 죽은 코드 | ✅ `AppDuration.pressFeedback` 3곳 인용 | codex | 묶음2 codex 적중 |
| **DT-2** route 파싱 | ⚠ `fromApiString` 무가드(단서) | ✅ `_parseRouteDate` 정규화 | codex | swap이 route 파싱으로 이동 |
| **FID-L1** bottomnav | ❌ 누락 | ❌ 누락 | **공통 약점** | 양판 N=2 |

## B. 과정 지표 차분 (차분만)

| 지표 | claude | codex | 비고 |
|---|---|---|---|
| coder 호출·토큰·반송·재시도 | (라이브런 비용 미기록·사용자 세션) | (동) | 양판 라이브런 transcript 미수집 → 차분 N/A |
| 산출물 규모(abee26d 대비) | 100 파일·lib 57 dart | 112 파일·lib 58 dart | codex +12 파일(widget 4분해: condition_icon·temperature_pair·tile·metric_card vs claude tile 단일) |
| 테스트 수 | 8 | 11 | codex +3(ui_extension_test·repo_test·dio_client_test 보유 — FC-2 차이의 직접 원인) |

> 과정 비용 원장은 양판 라이브런이 사용자 세션이라 미수집(절대값·인과 단정 금지). 산출물 규모·테스트 수만 정적 차분.

## 판정 (EVAL-METHOD §4.3)

- **산출물 품질 우열**: **동률**(양판 픽스처 FAIL·치명 2:2). 우열 단정 금지(N=1).
- **결함 성격 차분(보조 신호)**:
  - **codex 우위 축**: FC-2(매핑 테스트 보유)·VW-4(토큰 인용)·DT-2(route 가드)·TIER-Q — **테스트 커버리지·가드·시각 규율**에서 일관 우위.
  - **claude 우위 축**: FID-L2(레이아웃 섹션 구성 충실) — codex가 weekly-list 목록을 image 영역으로 대체·2섹션 분리한 반면 claude는 시안 섹션 구성 유지.
- **공통 치명(★최우선 처방 후보)**: **FID-L1 bottomnav 누락 양판 = N=2** — 9차 dry-run 포착 이후 자동 게이트가 재확인. 플러그인이 시안 하단 네비게이션 영역을 코드로 유도하지 못함(단일 BC라 기능 탭 대상 부재여도 시안 충실도상 영역 누락).

## 15차 검증 대비 — 사전 처방·fix 실측 결과

| 처방 | 표적 | 15차 실측 | 판정 |
|---|---|---|---|
| **fix016 screenProbes** | 자동 측정 경로(exit≠3) | 양판 `_support.dart` screenProbes 노출·fid-gate exit 2(A1 폴백 아님) | ✅ **자동 게이트 작동** — bottomnav 갭을 결정론 포착(육안 대체) |
| **fix016 DT-2 가드** | safe_api_call fromJson 무가드 | 양판 fromJson 가드 완비(claude `on Object`·codex `catch(_)`) | ✅ **safe_api_call 종결**(14차 claude 결함 치유). 단 claude route 파싱 무가드 잔존 → **swap 경로 이동**(codex 우위) |
| **묶음2 시각토큰** | press 생 Duration | codex `AppDuration.pressFeedback` 인용(적중)·claude 토큰 정의만(죽은 코드) | 🟡 **codex만 적중** — claude는 press 효과 미구현으로 리터럴 회피 |
| **묶음1 navigator carve-out** | codex 전역키 거짓 감점 | codex 전역키(VW-6/7/HR-7) grader 감점 0 | ✅ **거짓 감점 차단 작동** |
| **fix017 image** | image 거짓 FID FAIL | image area L1/L2 비측정(2026-06-22)·거짓 FAIL 0(FID FAIL은 bottomnav·codex weekly 섹션 구조지 image 아님) | ✅ **image 거짓 FAIL 0** |
| **★신규 발견 FID-L1 bottomnav** | (미처방) | 양판 누락·N=2 | 🔴 **다음 처방 1순위 후보** |
| **★신규 발견 FC-2 매핑 seam** | (미처방) | claude 색·아이콘 매핑 테스트 부재→vacuous | 🔴 **claude 측 헛 테스트 사각** |

## 다음 동결 입력 (A13 사각 신고·채점 미반영)
- **pubspec SDK ^3.12.1 vs RUBRIC BG-1 ^3.9 가정 불일치**(Y-g3) — 코퍼스 SDK 핀 정합 필요.
- 라벨 공백 변종('구름 많음' vs '구름많음') — N7이 철자 공백 미명시(codex).
- metrics 습도·강수확률 아이콘 심볼 중복(water_drop)·windSpeed double raw 표시 — FID-L4/A1.

## 한 줄 요지

15차 양판 **동률 픽스처 FAIL**(공통 FID-L1 bottomnav 누락·N=2). 갈림은 상보적 — **codex가 테스트·가드·토큰 규율(FC-2·DT-2·VW-4) 우위**, **claude가 레이아웃 섹션 구성(FID-L2) 우위**. fix016(screenProbes 자동측정·safe_api_call DT-2 가드)·묶음1(navigator)·fix017(image)은 작동 확인. **신규 처방 1순위 = FID-L1 bottomnav 양판 유도** + claude FC-2 매핑 seam. *N=1·우열 단정 금지.*
