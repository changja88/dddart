# 비교 집계지 — weather 17차 · 엔진 양판 (claude X ∥ codex Y)

> EVAL-METHOD §4(+§4.5 엔진 양판 축). 입력 = `20260624-0122-weather-claude.md`·`-codex.md`. baseline `abee26d`·코퍼스 `c6c4521`(fix021~026 누적)·채점일 2026-06-24. **⚠️ N=1·인과 단정 금지·절대값 비교 무의미(두 엔진 파이프라인 상이)·차분과 동률 시 보조 신호로만.**

## A. 산출물 품질 차분

| 항목 | claude (X) | codex (Y) | 우세 | 비고 |
|---|---|---|---|---|
| **픽스처 종합** | **PASS** | **PASS** | **동률** | ★**첫 양판 동시 PASS**(16차 claude PASS·codex FAIL에서) |
| 치명 게이트(18) FAIL 수 | **0** | **0** | 동률 | codex FC-1/FC-3 16차 치명 FAIL 역전(fix024) |
| 치명 PASS 수 | 15 + ➖3 | 15 + ➖3 | 동률 | |
| FID-L1·L2 자동 게이트 | ✅ 작동(fix025) | ✅ 작동(fix026) | 동률(★복원) | **16차 양판 A1 폴백에서 자동 측정 복원** |
| TIER-Q 등급 | 상 (WEAK 0) | 상 (WEAK 1·Q-7) | claude 미세 | |
| 차원별 ❌·🟡 | (없음·전 ✅) | DT-3 🟡·Q-7 🟡 | claude | 아래 갈림 |

### 갈린 차원 (차분의 본질)
| 차원 | claude | codex | 우세 | 해석 |
|---|---|---|---|---|
| **FC-1/FC-3** 한글 라벨 | ✅ §0 정확(cloudy=구름많음·overcast=흐림) | ✅ §0 정확(cloudy=구름많음·overcast=흐림·enum verbatim) | **동률(★codex 역전)** | ★**16차 결정적 갈림 해소** — codex fix024 적중으로 동률 PASS |
| **FC-2** 테스트 비-vacuous | ✅ M1·M2 red 실측 | ✅ M1·M2 red 실측 | 동률 | 양판 비-vacuous 유지 |
| **VW-4** 시각 토큰 | ✅ copyWith color-only(fix022 적중) | ✅ 누출 0·크기 토큰(fix020 유지) | 동률 | ★claude 16차 fontSize:18 흠 해소 |
| **Q-6** catch 위생 | ✅ RootErrorHandler 위임(fix021) | ✅ dumpErrorToConsole 비빈(fix021) | 동률 | 양판 16차 빈 핸들러 해소 |
| **DT-3** BadRequest 계약 | ✅ errorType/msg/isShow snake | 🟡 errorType 누락·statusCode·어휘 부재 | **claude** | codex 역할계약 별도 흠(fix023 케이싱 carve-out은 적용·camelCase 무감점) |
| **Q-7** 죽은 코드·press | ✅ AnimatedScale 구현·죽은토큰 0 | 🟡 fadeIn/interaction 죽은토큰·press 미구현 | **claude** | **엔진 비결정 N=3**(15·16·17차 press 출렁·codex 같은 코퍼스로 흔들림) |
| **FID 자동 게이트** | ✅ 작동·L1 누락=bottomnav만(L2 ✓) | ✅ 작동·appbar 도구 거짓-FAIL+섹션 병합+bottomnav | claude 미세 | 양판 자동 측정 복원·codex는 dump_to_ir 접미사 매칭에 걸림 |

## B. 과정 지표 차분 (차분만)

| 지표 | claude | codex | 비고 |
|---|---|---|---|
| coder 호출·토큰·반송·재시도 | (라이브런 비용 미기록·사용자 세션) | (동) | 양판 라이브런 transcript 미수집 → 차분 N/A |
| 산출물 규모(abee26d 대비) | 98 파일 변경 | 109 파일 변경 | |
| 테스트 수 | 11 | 11 | 동률 |
| baseline green | +42·병렬 3/3 green | +27·병렬 3/3 green | claude 테스트 케이스 더 많음(결정적 양판) |

> 과정 비용 원장은 양판 라이브런이 사용자 세션이라 미수집(절대값·인과 단정 금지). 산출물 규모·테스트 수만 정적 차분.

## 판정 (EVAL-METHOD §4.3)

- **산출물 품질 우열**: **양판 동률 PASS**(둘 다 치명 18 PASS). 단 N=1·인과 단정 금지 — "양 엔진이 17차 산출물에서 dddart 규약·기능 정확성을 모두 충족". 비치명 차분에서 claude가 미세 우위(DT-3·Q-7·TIER-Q WEAK 0 vs 1).
- **결함 성격 차분(보조 신호)**:
  - **claude 우위 축**: DT-3(errorType/msg/isShow 정석)·Q-7(press AnimatedScale 구현·죽은토큰 0).
  - **codex 우위 축**: (없음 — 16차 VW-4 우위는 claude fix022로 동률화).
  - **상보적**: 양판 모두 기능 정확성(FC-1~3)·규약(SD/VW/ST/HR) 충실. codex 잔여는 DT-3 역할계약·press 미구현(엔진 변동).
- **공통 복원(★측정 인프라)**: **FID 자동 게이트 양판 작동 복원** — claude=fix025(내용 기반 _support 선택·head-1 버그 해소)·codex=fix026(ScreenProbe/Future<Finder> 시그니처·ScreenPump/void 해소). 16차 양판 A1 폴백에서 자동 측정 복원.

## 17차 검증 대비 — 사전 처방·fix 실측 결과 (★전건)

| 처방 | 표적 | 17차 실측 | 판정 |
|---|---|---|---|
| **★fix021 Q-6 빈 onError** | 양판 runZonedGuarded 빈 `(e,s){}` | claude `RootErrorHandler.onZoneError` 위임·codex `dumpErrorToConsole` 비빈 관찰 | ✅ **적중** — 양판 16차 빈 핸들러 🟡 해소 |
| **★fix022 VW-4 typography copyWith** | claude `forecast_tile:101 fontSize:18` | claude copyWith 전부 `color:` 토큰·fontSize/height/letterSpacing 리터럴 0(g1·g2·g3 만장일치·κ 0.67→1.0) | ✅ **적중** — claude 16차 흠 해소 |
| **fix023 DT-3 케이싱 화해** | codex camelCase 무감점 | codex 봉투 미규정→케이싱 비대상(camelCase 무감점)·역할계약 errorType 누락은 별도 🟡 | ✅ **적용** — 케이싱 carve-out 작동·역할계약 흠은 엔진 변동(16차 camel과 다른 형태) |
| **★fix024 FC-1 한글 라벨 verbatim** | codex cloudy=구름많음·overcast=흐림·enum verbatim | codex 한글 라벨 §0 정확·`mostlyCloudy` 발명 소멸·"구름많음" 정위치(만장일치 κ 1.0) | ✅ **적중(HEADLINE)** — 16차 치명 FC-1/FC-3 FAIL 역전 |
| **★fix025 fid-gate head-1 도구버그** | claude 내용 기반 _support 선택 | claude `fid_dump_test` 컴파일·실행·자동 게이트 작동 | ✅ **적중** — 16차 head-1 A1 폴백 해소 |
| **★fix026 screenProbes 시그니처** | codex ScreenProbe/Future<Finder> | codex `fid_dump_test` 컴파일·실행·자동 게이트 작동 | ✅ **적중** — 16차 ScreenPump/void A1 해소 |

> **6 처방 전건 적중/적용** — fix021·022·024·025·026 적중, fix023 carve-out 적용. **claude 비치명 흠(VW-4·Q-6)·codex 치명 흠(FC-1/FC-3)·양판 FID A1 폴백이 모두 17차에 해소.**

## 다음 동결 입력 (A13 사각 신고·채점 미반영)
- **★NEW: dump_to_ir 접미사 매칭 취약성(거짓-FAIL 도구)**: `_isAppbar=endsWith('AppBar')`이 codex의 관례 준수 커스텀 앱바(`WeatherTopAppBarWidget`·`…Widget` 접미사)를 미인식 → FID-L1 appbar "누락" 거짓-FAIL. **처방 후보**: fid-gate가 Scaffold.appBar 슬롯 위치·PreferredSizeWidget도 appbar로 인식하도록 dump_to_ir/dump_probe 보강(거짓-FAIL 0 재확인·positive-control/fid 등가 재구성 추가).
- **codex DT-3 errorType 부재(🟡·비치명·엔진 변동)**: statusCode 대체·어휘 timeout/parse/unknown 부재. N=1·16차 camelCase와 다른 형태(엔진 자유변수). 재발 N=2 시 architecture-data §2 BadRequest 역할계약 강제력 길목 검토.
- **codex Q-7 press 미구현·죽은 토큰(엔진 비결정 N=3)**: 15차 인용→16차 죽은토큰→17차 미구현. claude는 17차 AnimatedScale 구현. 같은 코퍼스 출렁=엔진 자유변수 재확증(feedback-019/021 보류 정당).
- **FID-L1 bottomnav(양판·사용자 무시 정책·N=3+ 반복)**: 입력 프롬프트 탭 셸 미요구.
- **State error 필드 화석(양판·읽기전용 BC)**: ST-3 보유 PASS vs Q-7 죽은 필드 경계 미정의.

## 한 줄 요지

17차 양판 **★첫 동시 픽스처 PASS — claude·codex 둘 다 치명 18 전부 PASS**(16차 claude PASS·codex FC-1 FAIL에서 codex 역전). **6 사전 처방 전건 적중/적용**: fix024(codex 한글 라벨 verbatim·치명 역전)·fix022(claude VW-4 fontSize)·fix021(양판 Q-6 빈 onError)·fix025+026(양판 FID 자동 게이트 복원)·fix023(DT-3 케이싱 carve-out). 잔여 차분은 codex 비치명 DT-3(errorType 역할계약)·Q-7(press 미구현·엔진 비결정 N=3)으로 claude 미세 우위(TIER-Q WEAK 0 vs 1). **NEW 측정 인프라 발견 = dump_to_ir 접미사 매칭 취약성**(커스텀 appbar 거짓-FAIL·도구 보강 처방 후보). *N=1·우열 단정 금지·동률 PASS는 이 산출물 사실이지 엔진 우열 아님.*
