# 비교 집계지 — weather 16차 · 엔진 양판 (claude X ∥ codex Y)

> EVAL-METHOD §4(+§4.5 엔진 양판 축). 입력 = `20260623-1331-weather-claude.md`·`-codex.md`. baseline `abee26d`·코퍼스 `1fc7946`(fix018+019+020)·채점일 2026-06-23. **⚠️ N=1·인과 단정 금지·절대값 비교 무의미(두 엔진 파이프라인 상이)·차분과 동률 시 보조 신호로만.**

## A. 산출물 품질 차분

| 항목 | claude (X) | codex (Y) | 우세 | 비고 |
|---|---|---|---|---|
| **픽스처 종합** | **PASS** | **FAIL** | **claude** | ★15차 동률 FAIL에서 역전 |
| 치명 게이트(18) FAIL 수 | **0** | **2**(FC-1·FC-3) | claude | codex 한글 라벨 역전 |
| 치명 PASS 수 | 15 + ➖3 | 13 + ➖3 + ❌2 | claude | |
| FID-L1·L2 | ➖ A1 폴백(도구 head-1 버그) | ➖ A1 폴백(screenProbes 시그니처 위반) | 공통 폴백 | 사유 상이(아래) |
| TIER-Q 등급 | 상 (WEAK 2) | (치명 FAIL·비확정·WEAK 2) | — | |
| 차원별 ❌ | (없음·VW-4 🟡) | FC-1·FC-3 | — | 아래 갈림 |

### 갈린 차원 (차분의 본질)
| 차원 | claude | codex | 우세 | 해석 |
|---|---|---|---|---|
| **FC-1/FC-3** 한글 라벨 | ✅ §0 대응표 정확(cloudy=구름많음·overcast=흐림) | ❌ 역전(cloudy=흐림·overcast=대체로흐림·구름많음 부재) | **claude** | ★**16차 결정적 갈림** — 같은 task·다른 한글 매핑 |
| **FC-2** 테스트 비-vacuous | ✅ M2 red(15차 vacuous→해소·fix018) | ✅ M2 red(15차 PASS 유지) | 동률 | claude 15차 헛테스트 종결 |
| **Q-7** press 효과 | ✅ AnimatedScale 실구현(죽은토큰 해소) | 🟡 interaction 죽은토큰·press 미구현(15차 인용에서 퇴행) | claude | **엔진 비결정 N=2**(15차와 역전) |
| **크기**(fix020) | ✅ 직독 96/36 | ✅ AppSpacing 토큰 96/36(15차 104/40 승격) | 동률(★codex 적중) | 양판 design-tokens 치수 합류 |
| **DT-2** | ✅ on Object 가드 | ✅ 자기정규화기 on Object 가드 | 동률 | swap 경로 양판 봉합 |
| **VW-4** 시각 토큰 | 🟡 `fontSize:18` 리터럴 오버라이드 | ✅ 누출 0 | codex | claude text-[18px] 미토큰화 |
| **FID 자동 게이트** | ➖ 도구 head-1 버그(코더 무죄·시그니처 정확) | ➖ 코더 시그니처 위반(ScreenPump·void) | — | 폴백 사유 상이 |

## B. 과정 지표 차분 (차분만)

| 지표 | claude | codex | 비고 |
|---|---|---|---|
| coder 호출·토큰·반송·재시도 | (라이브런 비용 미기록·사용자 세션) | (동) | 양판 라이브런 transcript 미수집 → 차분 N/A |
| 산출물 규모(abee26d 대비) | 115 파일 변경 | 109 파일 변경 | |
| 테스트 수 | 13 | 10 | claude +3(ui_extension·forecast_tile_widget·detail_view 등) |
| 크기 표현 | 직접 리터럴(width:96·size:36) | AppSpacing 토큰 경유(forecastSlotWidth=96·forecastConditionIcon=36) | codex 토큰 승격이 더 규율적(VW-4 무누출) |

> 과정 비용 원장은 양판 라이브런이 사용자 세션이라 미수집(절대값·인과 단정 금지). 산출물 규모·테스트 수만 정적 차분.

## 판정 (EVAL-METHOD §4.3)

- **산출물 품질 우열**: **claude 우세**(claude 픽스처 PASS·codex FC-1 치명 FAIL). 단 N=1·인과 단정 금지 — "claude 엔진 우위"가 아니라 "이 산출물에서 codex가 한글 라벨 §0 대응표를 어겼다".
- **결함 성격 차분(보조 신호)**:
  - **claude 우위 축**: FC-1(한글 라벨 정확)·FC-2(15차 vacuous 해소)·Q-7(press 구현)·테스트 수.
  - **codex 우위 축**: VW-4(시각 토큰 무누출·크기 토큰 승격)·크기 표현 규율(AppSpacing 경유).
  - **상보적**: claude는 *기능 정확성·테스트 종결*, codex는 *시각 토큰 규율*에서 각각 강점.
- **공통 폴백(★측정 인프라)**: **FID 자동 게이트 양판 A1 폴백** — claude=fid-gate `head -1` 도구 버그(여러 _support.dart 중 screenProbes 없는 것 오선택·코더 무죄), codex=screenProbes 시그니처 위반(ScreenPump·void·코더 흠). 15차(claude screenProbes 작동·exit 2)에서 양판 미작동으로 퇴행 = **fix016 자동 경로 회귀/미달**.

## 16차 검증 대비 — 사전 처방·fix 실측 결과

| 처방 | 표적 | 16차 실측 | 판정 |
|---|---|---|---|
| **★fix018 FC-2 매핑 FORM** | claude M2 매핑 swap red(15차 vacuous) | claude `weather_condition_ui_extension_test.dart` §3.6 값핀 채택·조정자 M2 swap 주입→매핑 red(distinct는 green) | ✅ **적중** — 15차 헛테스트 종결·claude FC-2 FAIL→PASS 역전 |
| **★fix020 extract 치수** | codex 열폭 96·아이콘 36(15차 104/40) | codex AppSpacing `forecastSlotWidth=96`·`forecastConditionIcon=36`(매직넘버→토큰 승격)·design-tokens `w-[96px]`·`text-[36px]` 양판 합류 | ✅ **적중** — 결정론 채널 복원(육안 FID-L4·N=1) |
| **fix019 Q-7 press(보류)** | press 죽은토큰 N=2 재발 트리거 | claude 구현(해소)·codex 죽은토큰(재발) — **엔진 비결정 자유변수 확증**(15차와 역전·codex 같은 코퍼스로 출렁) | ✅ **보류 정당** — N=2가 "공백 아닌 엔진 비결정" 입증(feedback-019 예측 적중) |
| **fix016 screenProbes 자동측정** | exit≠3 자동 게이트 | **양판 A1 폴백**(claude 도구 head-1 버그·codex ScreenPump 시그니처 위반) | ⚠️ **회귀/미달** — 자동 경로 양판 실패(다음 처방 후보) |
| **★신규 발견 codex FC-1 한글 라벨** | (미처방) | cloudy↔overcast 역전·구름많음 부재 | 🔴 **처방 후보**(FC-GOLDEN enum↔한글 1:1 핀 강화·사용자 의도 확정) |
| **★신규 발견 fid-gate head-1 도구버그** | (미처방) | 여러 _support.dart 중 screenProbes 없는 것 오선택 | 🔴 **도구 처방 후보**(grep screenProbes로 선택) |

## 다음 동결 입력 (A13 사각 신고·채점 미반영)
- **FC-GOLDEN enum↔한글 1:1 핀 부재**(Y-g1·g2): 시안에 한글 라벨 없고 서버 enum(cloudy/overcast)↔한글 매핑이 명세 미결정 → grader 재량. FC-GOLDEN §0 대응표를 *서버 enum 코드* 기준으로 명문 고정 권고.
- **fid-gate.sh `head -1` 도구 버그**: `find _support.dart | head -1`이 screenProbes 없는 _support를 알파벳순 선택 → `grep -rl screenProbes`로 선택 변경 권고.
- **screenProbes 시그니처 규약 강제력**: codex가 `ScreenProbe=Future<Finder>` 대신 `ScreenPump=Future<void>`로 일탈 — coder.md/implementation-test §7에 *반환 타입(Finder)* 명문 강제 + render_smoke가 시그니처 검증.
- DT-3 camelCase 키(codex)·windSpeed double raw 표시(L4)·main.dart 빈 zone 핸들러(양판).

## 한 줄 요지

16차 양판 **역전 — claude 픽스처 PASS·codex FC-1 한글 라벨로 FAIL**(15차 동률 FAIL에서). ★**fix018(claude FC-2 vacuous 해소)·fix020(codex 96/36 토큰 승격) 둘 다 적중**. fix019(Q-7) 보류는 엔진 비결정 N=2로 정당. 갈림은 **codex 한글 라벨 §0 대응표 역전**(cloudy=흐림·overcast=대체로흐림·구름많음 부재) — 단 명세 미결정 사각이라 FC-GOLDEN 1:1 핀 강화 권고. **공통 회귀 = FID 자동 게이트 양판 A1 폴백**(claude 도구 head-1 버그·codex 시그니처 위반). *N=1·우열 단정 금지·claude 우세는 이 산출물 사실이지 엔진 우위 아님.*
