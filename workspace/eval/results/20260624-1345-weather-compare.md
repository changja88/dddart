# 비교 집계지 — weather 18차 · 엔진 양판 (claude X ∥ codex Y)

> EVAL-METHOD §4(+§4.5 엔진 양판 축). 입력 = `20260624-1345-weather-claude.md`·`-codex.md`. baseline `abee26d`·코퍼스 `75dac05`+**fix027(미커밋 working tree)**·채점일 2026-06-24. **⚠️ N=1·인과 단정 금지·절대값 비교 무의미(두 엔진 파이프라인 상이)·차분과 동률 시 보조 신호로만.**

## A. 산출물 품질 차분

| 항목 | claude (X) | codex (Y) | 우세 | 비고 |
|---|---|---|---|---|
| **픽스처 종합** | **PASS** | **PASS** | **동률** | 17차 동시 PASS 유지(2회 연속) |
| 치명 게이트(18) FAIL 수 | **0** | **0** | 동률 | 의미 FAIL 0(양판 만장)·FC-2 실측 red |
| 치명 PASS 수 | 15 + ➖3 | 15 + ➖3 | 동률 | SD-2·ST-4·HR-5 조회전용·단일 BC 미발화 |
| **FID-L1·L2** | ⚠️ 잠정 FAIL(**진짜 1섹션 회귀**) | ⚠️ 잠정 FAIL(**도구 거짓-FAIL**) | **codex 미세**(구조 실태) | 양판 치명 미적용(아래 갈림) |
| TIER-Q 등급 | **상 (WEAK 0)** | 상 (WEAK 1·Q-7) | **claude** | |
| 차원별 🟡 | (없음·전 ✅) | ST-5·HR-6·Q-7 🟡 | **claude** | 아래 갈림 |

### 갈린 차원 (차분의 본질)
| 차원 | claude | codex | 우세 | 해석 |
|---|---|---|---|---|
| **DT-3** BadRequest 계약 | ✅ errorType/msg/isShow snake | ✅ **errorType 회복(17차 🟡→)** | **동률(★codex 역전)** | ★**fix027 적중** — architect design-spec §3.3 "역할계약 3필드 열거" 발현·17차 누락 해소·만장 κ 1.0 |
| **FID 구조 충실도** | ⚠️ **detail 1섹션 회귀**(17차 2→1·hero를 private로) | ⚠️ **실제 2섹션 보유**(도구가 못 봄) | **codex(구조 실태)** | ★**역설** — codex가 시안 2섹션·커스텀 appbar를 실제로 갖췄으나 dump_to_ir이 미인식(거짓-FAIL)·claude는 도구 변명 없이 진짜 1섹션. *구조 충실도는 codex 우위·둘 다 도구상 잠정 FAIL* |
| **ST-5** provider 형태 | ✅ VM이 UseCase 직접 생성(DI 0) | 🟡 **수기 함수형 `Provider<UseCase>`**(legacy DI seam) | **claude** | codex Y-g3 적대 발견·과거 codex 회차 동형 재발(엔진 변동) |
| **Q-7** 죽은코드·press | ✅ AnimatedScale press 구현·named const·죽은토큰 0 | 🟡 press 미구현·`AppDuration.press` 죽은토큰·매직넘버(fix020 회귀) | **claude** | **엔진 비결정 N=4**(15·16·17·18차 press 출렁·claude 구현/codex 미구현·코퍼스 단독 원인 아님) |
| **크기 토큰** | ✅ named const(`_columnWidth=96`+시안 §8.1 주석) | 🟡 인라인 매직넘버(96/112/36/120·**fix020 토큰 후퇴**) | **claude** | codex 17차 `forecastSlotWidth` 토큰 승격에서 raw 회귀(§8/Q-7 경계) |
| **HR-6** 파일명 | ✅ | 🟡(Y-g2 단독·2:1) | claude 미세 | 경미·파일명-클래스 경계 |
| FC-1 한글 라벨 | ✅ domain enum label("구름많음") | ✅ ui_ext koreanLabel("구름 많음"·공백 cosmetic) | 동률 | 양판 §0 정확·fix024 유지·페어링 정확 |
| FC-2 비-vacuous | ✅ M1·M2 red 실측 | ✅ M1·M2 red 실측 | 동률 | 양판 뒤섞은 입력·전수 핀 |
| VW-4 typography | ✅ copyWith color-only(fix022 유지) | ✅ 누출 0 | 동률 | |

## B. 과정 지표 차분 (차분만)

| 지표 | claude | codex | 비고 |
|---|---|---|---|
| coder 호출·토큰·반송·재시도 | (라이브런 사용자 세션·미기록) | (동) | 차분 N/A |
| 산출물 규모(abee26d 대비) | 103 파일·lib 56 .dart | 132 파일·lib 64 .dart | codex 더 큼(섹션 분해 다수) |
| 테스트 수 | 10 파일·+30 green | 11 파일·+26 green | claude 케이스 더 많음 |

> 과정 비용 원장은 양판 라이브런이 사용자 세션이라 미수집(절대값·인과 단정 금지).

## 판정 (EVAL-METHOD §4.3)

- **산출물 품질 우열**: **양판 동률 PASS**(둘 다 치명 18 PASS·2회 연속 동시 PASS). 비치명 차분에서 **claude 미세 우위**(TIER-Q WEAK 0 vs 1·ST-5·HR-6·크기 토큰).
- **결함 성격 차분(보조 신호)**:
  - **claude 우위 축**: TIER-Q WEAK 0·ST-5(DI 0)·Q-7(press 구현·named const)·크기 토큰.
  - **codex 우위 축**: **FID 구조 실태**(실제 2섹션·커스텀 appbar 보유 — claude는 1섹션 회귀)·DT-3 fix027 회복(동률화).
  - **★역설**: *규약·비치명 청결도는 claude 우위*이나 *FID 구조 충실도는 codex가 실제로 더 나음*(claude 17차 2섹션 회귀·codex 실제 2섹션을 도구가 못 봄). 둘 다 도구상 FID 잠정 FAIL·치명 미적용.
- **fix027 적중(★헤드라인)**: codex DT-3 17차 errorType 누락(🟡)→18차 errorType/msg/isShow 회복(✅·만장 κ 1.0)·architect spec §3.3 역할계약 열거 발현. claude는 17차 유지.

## fix 실측 결과 (★전건)

| 처방 | 표적 | 18차 실측 | 판정 |
|---|---|---|---|
| **★fix027 DT-3 errorType 역할계약** | codex BadRequest errorType 누락 | codex errorType/msg/isShow 3필드·timeout/parse/unknown 어휘 회복(만장 PASS)·design-spec §3.3 "역할계약 열거" 발현 | ✅ **적중(HEADLINE)** — 17차 🟡 역전·길목 강제(architect spec) 작동 |
| fix021 Q-6 빈 onError | 양판 onError 비빈 | 양판 onError 위임·빈 바디 0 | ✅ 유지 |
| fix022 VW-4 typography | claude fontSize 리터럴 | claude copyWith color-only·fontSize 0(g1·g2·g3) | ✅ 유지 |
| fix024 FC-1 한글 라벨 | codex 라벨 verbatim | 양판 §0 정확·enum verbatim·발명/누락 0 | ✅ 유지 |
| fix025/026 FID 자동 게이트 | 양판 screenProbes | 양판 `fid_dump_test` 컴파일·실행·자동 측정 | ✅ 유지(게이트 실측 작동) |

> **fix027 적중·fix021·022·024·025·026 유지.** 단 fix020(codex 크기 토큰 승격)은 **18차 raw 리터럴 회귀**(엔진 변동·Q-7 경계).

## 다음 동결 입력 (A13 사각·채점 미반영)

- **★NEW: dump_to_ir 비재귀 + appbar 명명 (도구 거짓-FAIL 2종)**: ① `_isAppbar=endsWith('AppBar')`가 codex 커스텀 `WeatherTopAppBarWidget`(body Column 배치) 미인식 ② walk가 외곽 `*Section`에서 멈춰 중첩 `*Section`(codex `BodySection`>Hero+Metrics) 붕괴. **처방 후보**: Scaffold.appBar 슬롯·PreferredSizeWidget 인식 + `*Section` 재귀 walk + positive-control/fid 등가 재구성 추가.
- **★NEW: positive-control/fid 섹션 병합 변종 미커버 (measure-first)**: claude detail "내용보존 섹션 병합"(2섹션→1*Section·hero를 private로)이 거짓-FAIL인지 정탐인지 positive-control이 반증 안 함(§6-1 section fallback 잠정). **처방 후보**: positive-control/fid에 섹션 병합 변종 추가 → 거짓-FAIL 0 반증 후 FID-L2 섹션수 게이트 확정/치명화.
- **claude FID detail 섹션 회귀(17차 2→18차 1)**: hero를 `_DetailHero` private로 흡수(엔진 변동·N=1)·육안 권장.
- **codex ST-5 함수형 provider(NEW·과거 동형 재발)**: 수기 `Provider<UseCase>` legacy DI seam. 재발 N=2 시 architecture-state §2 강제력 길목(coder 로드·design-architect 명세) 검토.
- **codex Q-7 press 미구현(엔진 N=4)·크기 raw 회귀(fix020 후퇴)**: claude 구현/codex 미구현 출렁=코퍼스 단독 원인 아님(feedback-019/021 보류 정당).
- **FID-L1 bottomnav(양판·사용자 무시 정책)**·G-8 라벨 공백 정규화 기준·상세 카드 water_drop 중복(L4)·ST-2 조회전용 채널② NA 근거.

## 한 줄 요지

18차 양판 **동시 픽스처 PASS 2회 연속 — claude·codex 둘 다 치명 18 전부 PASS**. **★헤드라인 = fix027 적중**(codex DT-3 errorType 역할계약 회복·17차 🟡 역전·architect spec 길목 강제 작동). 비치명 차분 **claude 미세 우위**(TIER-Q WEAK 0 vs 1·ST-5·크기 토큰). **★역설 — FID 구조 충실도는 codex 우위**(codex 실제 2섹션·커스텀 appbar 보유·claude는 17차 2섹션→18차 1섹션 회귀)이나 둘 다 도구상 FID 잠정 FAIL·치명 미적용. **NEW 측정 인프라 = dump_to_ir 비재귀+appbar 명명 거짓-FAIL·positive-control/fid 섹션 병합 미커버(measure-first 처방 후보)**. *N=1·우열 단정 금지·동률 PASS는 이 산출물 사실이지 엔진 우열 아님.*
