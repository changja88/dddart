# 양판 비교 집계지 — weather(7일 예보) · claude vs codex · 12차

> **방법** EVAL-METHOD v3.2 §4(양판 비교·§4.5 과정 지표 일반화) · **채점일** 2026-06-21 0203 · **baseline** `abee26d` · **코퍼스** `480eb11`(Track B layout 강제·입력 유도 시술) · **FC 골든** `FC-GOLDEN-WEATHER.md`(2026-06-14·amend 2026-06-18·2026-06-20) · 결과지 `20260621-0203-weather-{claude,codex}.md` · grader raw `…-graders-raw.md`
>
> ⚠️ N=1·인과 단정 금지·comparability 단서(두 엔진 내부 파이프라인 상이·절대값 비교 무의미·*같은 사건 종류 차분*·동률시 보조만) · 전원 Claude 계열 grader(비-Claude 오라클 미확보) · FID 양판 A1 폴백(screenProbes 미노출·구조 충실도 사용자 눈)

## 1. 산출물 품질 차분 (핵심)

| 축 | claude | codex | 갈림 |
|---|---|---|---|
| 빌드 게이트(BG-1·2) | ✅ ✅ | ✅ ✅ | = |
| **치명 게이트 18** | **17 PASS · FC-2 ❌** | **18 PASS** | **codex ▲** |
| **픽스처 종합** | **FAIL**(FC-2 치명·사전식 종료) | **치명 게이트 통과** | **codex ▲** |
| 비치명 FAIL | **0** | **DT-3 ❌** | **claude ▲** |
| FC-1 골든 | ✅ (라벨 "구름많음" task 정확) | ✅ (G-8 라벨 "대체로 흐림" drift·충실도 흠) | claude ▲(충실도) |
| **FC-2 매핑 검증** | **vacuous**(아이콘/색 distinct·라벨만·매핑 정확성 미검증) | **비-vacuous**(6종 전수 매핑 expect) | **codex ▲** |
| DT-3 BadReq 계약 | ✅ freezed 3필드 errorType/msg/isShow | ❌ plain class 2필드(message/statusCode·isShow 0) | **claude ▲** |
| 설계 단순성 | SharedState 미신설(route 독립조회) | SelectionSharedState YAGNI 신설·stale-reset 댄스 2곳 | claude ▲ |
| VW-4 시각 토큰 | 🟡 Colors.white 카드 2곳 | 🟡 타이포수치·Radius(999) | ≈(둘 다 경미) |
| TIER-Q 등급 | 상(WEAK 2: Q-7·Q-8) | 상(WEAK 1행 Q-7·3실례) | ≈ |
| FID 구조 | ➖ A1 폴백 | ➖ A1 폴백 | =(둘 다 screenProbes 미노출) |
| **Track B area 트리(입력유도)** | ✅(area 토큰 19·§2.2/2.3 골격) | ✅(area 토큰 14·L216-224 tree·L416) | =(양판 작동) |

## 2. 판정

**치명 게이트 기준 = codex 우위**(픽스처 통과 vs claude FC-2 치명 FAIL). 단 이는 *단순 우열이 아니라 결함 성격의 trade-off*다:

- **claude**: *코드는 정확*(아이콘 매핑 clear→sunny 등 옳음·DT-3 표준·라벨 task 정확·설계 단순)하나 **테스트가 매핑 회귀를 못 막는다**(FC-2 M2 vacuous — measure-first 실주입에서 맑음↔뇌우 아이콘 swap에 전체 green). dddart 철학(테스트 약하면 codegen 신뢰 불가)상 치명.
- **codex**: *테스트가 강하다*(6종 전수 매핑 단언 → M2 red·FC-2 비-vacuous)하나 **데이터 계약(DT-3 plain BadReq)·task 라벨 충실도("대체로 흐림")·설계 단순성(SharedState YAGNI)에 흠**.

→ **11차 무승부에서 12차 갈림.** 갈림의 본질 = *measure-first FC-2 mutation 실주입*이 양판 **테스트 비-vacuity 격차**를 드러낸 것(적대 grader는 양판 모두 FC-2 PASS로 봤으나 조정자 실주입이 claude vacuity를 격파 — EVAL §2.6 자기보고 불신의 실효 사례).

> ⚠️ **N=1 인과 단정 금지**: "claude가 항상 매핑 테스트 vacuous"가 아니라 *이 산출물*에서 그랬다. codex DT-3·라벨도 *이 산출물* 한정. 신뢰도는 S2·S3·반복 런으로 보강.

## 3. Track B(layout 강제·입력 유도) 시술 효과 — 12차 1차 실측

**시술 목표**(코퍼스 `480eb11` plan v3 §6): design-architect가 layout-ir.json을 읽어 **design-spec 화면 절에 area 어휘 트리를 강제 반영**(입력 유도). 출력 게이트(FID 자동 대조)는 별도(screenProbes 전제).

| 측정 | 결과 |
|---|---|
| **has_layout_ir 플래그** | 양판 `true`(build-state.json) |
| **layout-ir.json 생성** | 양판 ✅(extract_layout → 화면 2·영역 8) |
| **design-spec area 트리(입력 유도)** | **양판 ✅** — claude §2.2/§2.3 골격(`appbar(slots:...)`·`section(L2: repeat-group:...)`·`bottomnav`·닫힌 어휘 area/block/slot/width 인용)·codex L216-224 tree+L416 "L1 area 순서·L2 repeat 반영" |
| 8차 누락(image·bottomnav) 인입 | ✅ 양판 명세에 area로 등장(claude §2.4 bottomnav "장식 비채택"·image area 유지·§104 / codex bottomnav "비활성 slot"·image "weather glyph 대체") |
| **FID 출력 게이트(자동 대조)** | ⚠️ **양판 A1 폴백**(`fid-gate.sh` exit 3·screenProbes 미노출·코더 표준 pump 규약 미준수) |

**결론**: **Track B 입력 유도 = 성공**(양 엔진 design-architect가 layout-ir → area 트리 명세화·8차 갭 인입). **출력 게이트 = 미발동**(screenProbes 봉합은 Track B 범위 밖·코더측·9차부터 반복 미해결). 즉 *시술한 부분(설계측 입력 강제)은 작동, 미시술 부분(코더측 출력 규약)은 여전히 갭*. 12차 FC-2/DT-3/라벨 갈림은 **Track B와 무관한 코더 테스트/데이터 품질 차이**(별도 수확).

## 4. 과정 지표 차분 (§4.5·절대값 아님·동률 아니라 보조)

| 지표 | claude | codex | 비고 |
|---|---|---|---|
| 산출 파일(lib) | 83 | 71 | codex가 적은 파일(단 SelectionSharedState 등 추가 구조) |
| 산출 파일(test) | 9 | 9 | = |
| 테스트 케이스 | 26(전 스위트 green) | 20(자체 보고·green) | claude가 더 많으나 *매핑 검증 vacuous*(개수≠품질) |
| 갭 원장(+삽입) | +12865 | +13709 | codex가 큼 |
| 백스톱 blocker | 0 | 0 | = |

> 12차는 *동률 아님*(치명 갈림)이라 과정 지표는 보조 기록만. **테스트 26 vs 20**은 claude 우위로 보이나 FC-2 vacuity가 *개수≠비-vacuity*를 실증(claude 26개 중 매핑 정확성 두드리는 비-vacuous 테스트 0) — 과정 지표의 함정.

## 5. 종합 한 줄

**12차 = codex 치명 우위(픽스처 통과)·claude 치명 FAIL(FC-2 매핑 테스트 vacuous).** 단 codex는 비치명 DT-3·라벨 drift·SharedState YAGNI, claude는 비치명 견고·코드 정확하나 테스트 약함 — **결함 성격의 trade-off**(codex=강한 테스트·약한 데이터계약 / claude=정확한 코드·약한 테스트). **Track B(layout 입력 유도)는 양 엔진 모두 작동**(design-spec area 트리·8차 갭 인입)·FID 출력 게이트만 screenProbes 미봉합으로 A1 폴백. *측정 수확: measure-first FC-2 실주입이 양판 테스트 비-vacuity 격차를 드러냄(적대 grader 만장일치 PASS를 조정자 실주입이 격파).*

## 부록: 다음 라운드 입력 (사각·fix 후보)

1. **claude FC-2 fix**: condition→아이콘/색 매핑 검증을 distinct가 아니라 *6종 전수 expect*로(codex 패턴). `implementation-test`/`discipline-test`가 "매핑 검증=전수 expect·distinct는 불충분"을 명문화하는지 점검.
2. **codex DT-3 fix**: BadRequestResponse를 표준 freezed 3필드(errorType/msg/isShow)로. `architecture-data` 계약 강제가 코더에 닿는지.
3. **codex 라벨 fix**: task 정본 6라벨("구름많음") 충실. FC 골든 N7 "verbatim vs 의미오배치 경계" 명문화(다음 동결 라운드).
4. **screenProbes 봉합**(양판·Track A와 별개): 코더가 `_support.dart`에 screenProbes 노출하도록 — FID 자동 게이트 발동 전제(9차부터 반복 미해결).
5. **RUBRIC FC-2 사각**: "distinct ≠ 매핑 정확성" 구분 명문화(적대 grader가 Set 크기를 비-vacuity로 오인한 이번 사각 차단).
