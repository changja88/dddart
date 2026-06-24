# grader 패널 raw verdict — weather 18차 (X=claude · Y=codex · blind)

> EVAL-METHOD §2.0·§2.2·A3 영속 증거(주장 아닌 증거). 의미 레인 grader 6명(X·Y 각 3·g3 적대)이 **결정 레인 결과·엔진 정체·기존 결과지 미수령(blind)**으로 RUBRIC 의미 차원만 판정. **⚠️ 비-Claude 오라클 미확보(전원 Claude 계열·독립성 한계)**. 채점일 2026-06-24 · 코퍼스 `75dac05`+fix027(미커밋) · 워크플로우 `wf_70d980cd-d64`(6 에이전트·805k).

## verdict 매트릭스 (치명 11 의미 + 비치명·NA=조건부 미발화)

| 차원 | X-g1 | X-g2 | X-g3(적대) | Y-g1 | Y-g2 | Y-g3(적대) |
|---|---|---|---|---|---|---|
| **치명 11**(SD-1·7·VW-1·6·ST-1·2·DT-1·2·FC-1·3) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| ST-4(mounted) | ➖NA | ➖NA | ➖NA | ➖NA | ➖NA | ➖NA |
| SD-2·3·6 | NA/PASS | PASS | NA/PASS | NA | NA | NA |
| SD-4·5·8·9 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| VW-2·3·**4**·5·7 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| ST-3·**5**·7·8·9 | ✅ | ✅ | ✅ | ✅ | ✅ | **ST-5🟡** |
| ST-6 | ➖NA | ➖NA | ➖NA | ➖NA | ➖NA | ➖NA |
| **DT-3** | ✅ | ✅ | ✅ | **✅** | **✅** | **✅** |
| DT-4·5·6·8 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| DT-7·9 | ➖NA | ➖NA | ➖NA | ➖NA | ➖NA | ➖NA |
| HR-2·3·**6**·7·8·9 | ✅ | ✅ | ✅ | ✅ | **HR-6🟡** | ✅ |
| Q-1~6·8·9 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Q-7** | ✅ | ✅ | ✅ | **🟡** | **🟡** | **🟡** |

## κ (차원별 일치율) — 만장일치 보드는 per-grader 매트릭스로 증거화(blind 붕괴 아님)

| 차원 | 판정(6) | κ | split |
|---|---|---|---|
| 치명 11 의미 | ✅✅✅ / ✅✅✅ | 1.0 | 양판 만장 PASS |
| DT-3 | ✅✅✅ / ✅✅✅ | 1.0 | **★codex 17차 🟡→18차 만장 PASS(fix027)** |
| VW-4 | ✅✅✅ / ✅✅✅ | 1.0 | 양판 만장(claude fix022·codex 토큰) |
| Q-7 | X ✅✅✅ / Y 🟡🟡🟡 | variant 내 1.0 | claude PASS·codex WEAK 만장 |
| ST-5 | Y ✅✅🟡 | 0.33(2:1) | Y-g3 적대만 함수형 provider 발견 |
| HR-6 | Y ✅🟡✅ | 0.33(2:1) | Y-g2만 파일명 경계 |

## 적대 grader findings (X-g3 · Y-g3 — 결정 레인이 못 보는 의미 변종 전수)

- **X-g3(claude)**: 8축 **전부 무혐의** — 빈 wrapper(fromDays 실로직)·Left no-op(fold throw 재방출)·우회 self-show(static 0)·침묵 폐기(safeApiCall Left·main onError debugPrint)·판정 누수(VM fold만·application 정렬/spec 0건)·재export 사슬(UI import 0)·FC 디코이(M1 뒤섞은 입력·M2 case별 전수 핀)·함수형 provider 위장(VM 전부 class extends _$X).
- **Y-g3(codex)**: 7축 무혐의 + **★1축 발견 — 함수형 provider**: `weather_forecast_use_case.dart:12-17` 수기 `Provider<WeatherForecastUseCase>((Ref ref)=>…)` = @riverpod 클래스형 아닌 함수형 DI seam(architecture-state §2 DI 없음·implementation-riverpod §2 클래스형만 위반) → ST-5 🟡 귀속(읽기전용 파생값 위장 아니나 화이트리스트 밖·과거 codex 회차 동형 재발).

## rubric 사각 신고 (A13 — 채점 미반영·다음 동결 입력)

- **X-g1·Y-g1·Y-g2**: G-8 codex 라벨 `구름 많음`(공백) vs 골든 §0 `구름많음` — 공백 정규화 기준 RUBRIC/골든 미명시(15차 cosmetic 선례·페어링 정확이라 PASS). 동결 입력.
- **X-g1·claude-g3**: 상세 카드 아이콘 중복(습도·강수확률 둘 다 `water_drop`) — FID-L4/A1 육안 신고.
- **Y-g2·Y-g1**: codex 크기 raw 리터럴(96/112/36/120/480) 귀속이 VW-4(§8 정식)↔Q-7(매직넘버)↔FID-L4 사이 모호 — fix020 토큰 승격 후 raw 재등장은 회귀 신호이나 채점 경계 미규정(size prop 토큰화 규율 명문화 후보).
- **Y-g3**: codex FID bottomnav `design-spec:123,234` 의도적 scope 제외 명기 필요·ST-5 함수형 provider 강제력 길목(coder architecture-state 로드) 동결 입력·DT-3 케이싱 carve-out은 server-contract error 스키마 추가 시 판정 뒤집힘(입력 의존).
- **X-g1**: ST-2 조회 전용 시 채널② NA 처리 공식 근거가 ST 주의에 부분만 — PASS 문언 명시 후보.

> **만장일치 보드 + per-grader 매트릭스 + κ 동시 존재 → blind 정상**(단일 저자 위장 적신호 아님). FID-L1·L2·FC-2는 결정 레인이라 의미 grader 미판정(별도 §2.5·조정자 실측).
