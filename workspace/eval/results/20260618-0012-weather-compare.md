# 양판 비교 집계지 — 20260618-0012-weather (claude vs codex · 6차·v3.2 첫 적용)

> EVAL-METHOD §4(두 안 비교 = RUBRIC 적용 사례) + §4.5(과정지표 차분·엔진 양판). **동일 SCENARIO-WEATHER §1·동일 baseline `abee26d`·동일 동결 RUBRIC v3.2/FC-GOLDEN(2026-06-14)·동일 조정자 결정레인(mutation·backstop·curl)·각 3 blind grader(n1·n2·adv).** 결과지: `20260618-0012-weather-claude.md`(@`ab99a82`)·`20260618-0012-weather-codex.md`(@`64bb27e`)·grader raw `20260618-0012-weather-graders-raw.md`.
> **⚠️ comparability 단서**: 두 엔진은 내부 파이프라인(Coordinator 루프·게이트·커밋 관용구·finalize-collapse 발화 여부)이 달라 **절대값 비교 무의미** — *같은 사건 종류의 차분*·*동률 시 보조*로만. **N=1·인과/우열 단정 금지·시각 충실도 비측정(A1)·소급 FAIL 금지.** **v3.2(FC-2 seam 일반화) 첫 라이브 적용 런.**

## 1. 산출물 품질 (동일 RUBRIC 57차원·v3.2)

| | claude(@ab99a82) | codex(@64bb27e) |
|---|---|---|
| **종합** | **❌ FAIL** | **❌ FAIL** |
| 빌드게이트 BG-1/2 | ✅✅ | ✅✅ |
| 백스톱 55종(--diff-base abee26d) | exit 0·blocker 0 | exit 0·blocker 0 |
| flutter test(clean·build_runner 선행) | +23 green(9파일) | +45 green(12파일·도메인·ui_ext·view·widget) |
| 치명 17 | **16 PASS·FC-2 ❌**(SD-2·ST-4·HR-5 ➖N/A) | **14 PASS·ST-2 ❌·FC-2 ❌·FC-1 ❌보수**(SD-2·ST-4·HR-5 ➖N/A) |
| **FC-1 골든** | ✅ G-1~G-8 런타임 일치(색 6 distinct) | ❌**보수**(G-8 "구름 많음"≠"구름많음"·cosmetic·인간큐)·그 외 PASS(G-2 app-enforced) |
| **FC-2 비-vacuous** | ❌ **M1만 死**(M3·M4·M5 RED·M2 GREEN) | ❌ **M1만 死**(M2·M3·M4·M5 전 RED) |
| **FC-3 negative** | ✅(N2 서버의존) | 🟡(N7 라벨 drift·N1 app-enforced) |
| **ST-2 에러채널** | ✅ 단일채널·error 필드 부재(읽기전용 정당) | ❌ **죽은 State.error 필드·view 死분기(3:0 만장)** |
| 도메인 형태 | ✅ @freezed+json 직파싱(정규형) | 🟡 **전 모델 수기 비-@freezed**(SD-4/DT-4/ST-3 WEAK) |
| DI | ✅ 직접생성 no-DI | 🟡 전 계층 optional 주입 seam(DT-5 WEAK) |
| TIER-Q(기록용) | 8 PASS·1 WEAK="상" 상당 | 6 PASS·1 N/A·~3 WEAK="중" 상당 |

### 품질 차분 해석 (우열 단정 아님·N=1)

- **공통 치명 FAIL = FC-2/M1**(양 엔진 정렬코드 0·order test가 사전정렬 fixture라 vacuous·서버순서 위임). **6런 연속 동일 아키텍처 쟁점**(A13-1) — gate "서버순서 유지"가 정렬 부재를 정당화하는지(N/A) vs 비-vacuity 갭(FAIL)인지 골든 미명시. n1·n2 "정당 위임"·adv "FAIL"·동결룰 적용 = FAIL.
- **🟢 5차 공통 FAIL의 해소(핵심 진전)**: 5차 양판 공통이던 **색 충돌(clear=cloudy=#FEAE2C·FC-1/FC-3 FAIL)이 양쪽 6색 distinct로 해소**·5차 **M3 기온위치 vacuity가 양쪽 RED로 회복**·codex의 **5차 M4 vacuity+디코이 테스트가 6차에 RED+제거**. → **feedback-008 테스트 스킬(discipline-test·implementation-test)의 효과 시사**(FC-2 메커니즘 커버리지 급상승·인과 단정 금지).
- **claude 우위(이번 런)**: ① **치명 16 PASS·유일 FC-2/M1**(codex는 ST-2·FC-1까지 3 게이트). ② **정규 dddart형**(@freezed/json_serializable/codegen·clean 단일 에러채널·죽은 상태 0·no-DI). codex는 ST-2 phantom 채널·전 모델 수기 codegen 포기.
- **codex 우위(국소)**: ① **도메인 풍부**(requireSevenDays 7일 불변·VO ForecastDate/TemperatureRange) → **G-2 app-enforced**(claude는 서버의존). ② **FC-2 seam 충실**(M2~M5 전 RED·per-condition (icon,color,label) 쌍 테스트·기온 슬롯키·도메인 단위테스트 — v3.2 "맞는 seam"에 정확히 안착). claude는 M2 GREEN(색 테스트가 set-size distinctness만).
- **codex 고유 흠**: ST-2 죽은 채널(읽기전용에 액션채널 과적)·전 모델 수기 비-@freezed(SD-4/DT-4/ST-3·결정레인 탈출 A13-3)·G-8 라벨 공백·optional 주입 seam.
- **claude 고유 흠**: M2 색 swap 미포착(테스트가 distinctness만)·정렬 미검증(서버 의존).

> **종합**: 양판 공히 FAIL이나 **이번 런은 claude가 더 청정**(치명 1 게이트·idiom 충실·codegen 포기 0). codex는 seam 충실도·도메인 풍부에서 앞서나 ST-2 죽은채널(만장 치명)·codegen 전면 포기가 더 큰 마이너스. **N=1·우열 단정 금지** — 보조 시나리오·반복런으로 신뢰도 상승 필요.

## 2. 과정 지표 (§4.5 차분·절대값 아님·comparability 단서)

| 지표 | claude | codex | 차분 해석 |
|---|---|---|---|
| 슬라이스 | 4(tracer+토대 / application / presentation목록+배선 / presentation상세) | 3(domain foundation / model flow / list+detail UI) | 분할 입자 차이(엔진 관용구·품질 신호 아님) |
| finalize-collapse | **발화**(`git reset --soft`→미커밋 98 staged) | **미발화**(7커밋 유지) | **비대칭** — claude 파이프라인이 마무리 합치기 실행·codex 미실행(설계 `2026-06-17-finalize-uncommit-collapse.md` 양판 미러이나 codex측 가드 미충족 또는 미발화·후속 관측 대상) |
| 커밋 입자 | 6커밋(설계+4슬라이스+discipline) → collapse로 미커밋 | 7커밋(설계+6) | — |
| 파일/라인(abee26d 대비) | 98파일 +12527/-141 | 108파일 +12465/-130 | codex 파일 多(2 애그리거트·section 4·widget 4·도메인 VO) |
| 산출 테스트 | 9파일 +23 | 12파일 +45 | **codex 테스트 多**(도메인 단위·ui_ext·view·widget 전 seam) — v3.2 seam 충실의 표현이나 수≠전 비-vacuity(M1 양쪽 死) |

> **동률 시 보조 신호**: 산출물 품질이 *양쪽 FAIL*이나 **claude가 치명 게이트 수에서 우위**(1 vs 3). codex의 테스트 多·seam 충실(M2~M5 RED)은 강점이나, 그 도메인을 **수기 codegen 포기**로 지어 SD-4/DT-4/ST-3·ST-2 죽은채널을 동반. **finalize-collapse 양판 비대칭**(claude 발화·codex 미발화)은 새 코퍼스 기능의 양판 거동 차이 — 인과 단정 금지·후속 관측.

## 3. v3.2(FC-2 seam 일반화) 첫 적용 관측

| 관측점 | 결과 |
|---|---|
| seam 인지 채점 발화 | **codex에서 결정적** — 도메인 단위테스트·ui_extension 직접호출 테스트가 "맞는 seam"에 존재(M2 색 RED·M3 기온 RED) → v3.1(위젯테스트 가정)이면 놓쳤을 비-vacuity를 v3.2가 정확히 포착·인정 |
| claude M2 GREEN 처리 | 색 테스트가 set-size distinctness만(swap 미포착) → v3.2 seam(ui_extension 단위)에선 "테스트 존재하나 vacuous for swap"으로 정확 판정(아이콘 distinct 미검증 A13-2와 연결) |
| M1(정렬) seam-무관 | 정렬코드 0 = 어느 seam에도 정렬 테스트 없음 → seam 일반화와 무관하게 死(v3.2 §2.5 "주입사이트 死=FAIL" 그대로) |
| 불변 3조 보존 확인 | ① floor 골든 행위별(M1 단독으로 FC-2 FAIL) ② 주입사이트 死=FAIL ③ 치명·이진 — 전부 적용됨 |

> **v3.2 유효화 확인**: codex의 도메인·ui_extension 테스트가 v3.1이면 "위젯테스트 아님=미검증"으로 오인됐을 것을 v3.2가 "맞는 seam의 비-vacuous 테스트"로 정확 인정(M2·M3 RED). 동시에 M1 死·claude M2 vacuous는 그대로 잡음 → **기준 완화 아닌 유효화**(설계 의도 실증).

## 4. 교차 결론 (양판이 가리키는 것)

1. **테스트 스킬(feedback-008) 효과 시사** — 5차 양판 공통이던 FC-2 vacuity(M1·M3)·디코이·색 충돌이 6차에 대폭 해소(claude M3/M4/M5 RED·codex M2~M5 RED·색 6 distinct). FC-2 메커니즘 커버리지가 양 엔진에서 급상승(N=1×2·인과 단정 금지·동시 관측).
2. **유일 잔여 공통 치명 = FC-2/M1(서버순서 위임)** — 6런 연속. **차기 동결 1순위 결정(A13-1)**: M1을 (a) 死=FAIL 유지 (b) 서버계약 보장 시 N/A (c) "뒤섞은 fake 주입 위젯/단위테스트 강제"로 비-vacuous 살리기 중 택. n1·n2 다수가 "정당 위임" 견해 → 골든 재설계 강한 후보.
3. **codex 고유 패턴 = ST-2 죽은채널 + 수기 codegen 포기** — 읽기전용에 액션 에러채널을 과적(죽은 필드)했고, 전 모델을 @freezed 없이 수기로 지어 결정레인(백스톱)을 통째로 탈출(A13-3). claude는 둘 다 회피(정규형). → **차기 동결: "도메인/상태가 @freezed인가"를 보는 결정 검사 추가 검토**(codegen 거부 엔진의 백스톱 탈출 차단).
4. **claude finalize-collapse 발화·codex 미발화** — 새 코퍼스 기능의 양판 거동 비대칭. 채점은 양쪽 baseline 대비 changeset으로 정상 수행(claude는 ab99a82 핀·cp -r). codex측 collapse 미발화 원인(가드 미충족 vs 미러 미반영)은 후속 관측.
5. **시각 충실도 비측정(A1)** — 양판 화면 일치는 인간 오라클(사용자 `flutter run`). 결과지의 구조·기능 PASS는 시안 일치 아님.

## 5. 한 줄 요지

**양판 공히 ❌ FAIL이나 이번 런은 claude가 더 청정**(치명 **1 게이트=FC-2/M1** vs codex **3=FC-2/M1·ST-2·FC-1 보수**). **공통 잔여 = FC-2/M1(정렬 死=서버순서 위임·6런 연속·차기 동결 1순위 A13-1)**. **5차 양판 공통 FAIL이던 색 충돌·M3 vacuity·codex 디코이가 6차에 해소**(feedback-008 테스트 스킬 효과 시사·인과 단정 금지) → **역대 최청정 양판**. claude=정규 dddart형(@freezed·clean 단일채널·no-DI)·codex=seam 충실+도메인 풍부(G-2 app-enforced)하나 ST-2 죽은채널(만장 치명)·전 모델 수기 codegen 포기(결정레인 탈출)가 더 큰 마이너스. **v3.2 seam 일반화 첫 적용이 codex 도메인·ui_extension 테스트를 정확 인정**(기준 완화 아닌 유효화 실증). 우열 단정 금지·N=1·시각 충실도 비측정.
