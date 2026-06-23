# grader raw verdict 영속 — weather 15차 (EVAL §2.0·§2.2 blind 증거화)

> 워크플로우 `wf_10072605-a74`(6 grader·772k 토큰·452s·tool 406). 양판 X(claude)·Y(codex) 각 grader 3(g1·g2 일반·g3 적대). **blind 규율**: variant 라벨만 수령·엔진 추론 금지(경로 'claude/codex' 토큰 노출로 variant blind 부분 한계). **전원 Claude 계열 — 비-Claude 오라클 미확보(독립성 한계)**. raw JSON 전문 = `$CLAUDE_JOB_DIR/.../tasks/wsokpxq5h.output`(809줄). 아래는 채점 산입 verdict 요약.

## κ (차원별 일치율)

| 차원군 | X(claude) 3 grader | Y(codex) 3 grader | κ | 비고 |
|---|---|---|---|---|
| **FC-2** | (누락)·❌·❌ | ✅·✅·✅ | X 0.67(응답 2/2 FAIL 일치)·Y 1.0 | X-g1 FC-2 항목 누락(미판정)·응답 2명 만장 FAIL |
| 치명 8(SD-1·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·FC-1·FC-3) | ✅✅✅ | ✅✅✅ | 1.0 | 만장일치 PASS |
| 비치명 15(SD-3·4·6·9·VW-2·4·5·7·ST-3·5·6·DT-4·5·HR-7·8) | 만장일치(PASS/NA) | 만장일치 | 1.0 | drift 0 |

> 만장일치 보드가 아니라 **FC-2에서 양판이 갈림**(X FAIL·Y PASS) — blind 붕괴 적신호 아님(실제 변별). 조정자 결정 레인 실측(M2 주입)이 X-FAIL/Y-PASS 독립 확증.

---

## X-g1 (claude · 일반)
- **치명**: SD-1·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·FC-1·FC-3 = **PASS**. ⚠️ **FC-2 항목 누락**(critical 배열에 미포함·미판정).
- **비치명**: SD-3 NA·SD-4 PASS·SD-6 NA·SD-9 PASS·VW-2 PASS·VW-4 PASS·VW-5 PASS·VW-7 PASS·ST-3 PASS·ST-5 PASS·ST-6 NA·DT-4 PASS·DT-5 PASS·HR-7 PASS·HR-8 PASS.
- **fc1/fc3 위반**: 없음.
- **blindspots**: FID는 결정 도구(compare_layout) 소관·미측정. screenProbes 3건 fixture(d1·d2·d3)로 7건 미만 — 7행/이미지/섹션 대조는 결정레인. metrics 강수확률 아이콘이 습도와 동일 water_drop(FID-L4/A1). windSpeed double raw 표시(A1).

## X-g2 (claude · 일반)
- **치명**: SD-1·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·FC-1·FC-3 PASS · **FC-2 = FAIL**.
- **FC-2 근거**: "필수 M2(condition→아이콘/색 swap)의 seam(`condition_ui_extension.dart:12-49` icon/color getter)을 두드리는 테스트 부재 — 전 test/에서 `Icons.`·`.icon`·`.color`·byIcon 단언 0건(grep exit 1). 유일 condition 단언은 `daily_forecast_detail_view_test.dart:41 find.text(Condition.rain.label)`인데 M2는 라벨 미변경이라 green=vacuous. M1·M3·M4·M5는 red. 필수 M1~M4 중 M2 red율 미달=vacuous FAIL(전 스위트 17 green)."
- **비치명**: 전 PASS/NA(X-g1 동일).
- **blindspots**: M2 미보호가 FC-2로 잡히나 자동 결정 레인만 돌렸다면 17/17 green 통과 오판 위험. cloudy=cloud/overcast=cloud_queue 시각 구별력 A1. metrics 아이콘 중복.

## X-g3 (claude · **적대**)
- **치명**: 치명 8 PASS · **FC-2 = FAIL**.
- **★FC-2 실측 근거**: "**/tmp 사본에서 M2(clear↔thunderstorm icon+color swap) 주입 후 `flutter test` 전 스위트 17/17 GREEN** — 골든 §2 M2가 요구한 RED 미발생. test/** 어디에도 `.icon`/`.color`/find.byIcon/widget<Icon> 단언 0. M2 필수 mutation red율 100% 미달=vacuous FAIL. 대조: M1 정렬역전→RED 2곳·M3 기온슬롯swap→RED·M4 toApiPath off-by-one→RED 3곳 정상."
- **위장 변종 점검(8종 전수 무혐의)**: ① 빈 wrapper SD-1 없음(fromDays 실 sort) ② Left fold no-op 없음(VM fold Left가 throw) ③ 우회명 self-show 없음 ④ ST-1 판정누수 없음 ⑤ 동형 신호버스 없음 ⑥ 함수형 provider 위장 없음 ⑦ 이름바꾼 변환계층 없음 ⑧ DT-2 fromJson 가드 작동(data_source.g.dart:44-47 rethrow→safeApiCall on FormatException/TypeError 포착).
- **blindspots**: FC-2 vacuous는 자동 결정 레인만으론 green 통과 오판(mutation 실행 필수 재확인). screenProbes 노출·render_smoke green(A1 폴백 아님). 상단 Image.asset·heroIcon 120·width 96 등 레이아웃 치수 FID-L4(육안).

---

## Y-g1 (codex · 일반)
- **치명**: SD-1·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·FC-1·**FC-2**·FC-3 = **전부 PASS**.
- **FC-2 근거**: "/tmp isolated copy: M1 reverse→`weather_forecast_test`+`weekly_forecast_vm_test` RED(2 fails). **M2 clear→thunderstorm icon→`weather_condition_ui_extension_test` RED**. M3 tempMin↔Max→`weekly_forecast_view_test` RED. M4 integration `widget_test:29-40` GoRouter round-trip. M5 detail metric. Full suite 30/30 green pre-mutation."
- **비치명**: 전 PASS/NA.
- **blindspots**: 라벨 '구름 많음' 공백 vs 골든 '구름많음'(의미동일·N7 비위반이나 grep 정확대조 시 거짓 FAIL). FID는 결정레인. metrics 아이콘 중복 A1.

## Y-g2 (codex · 일반)
- **치명**: 9 전부 PASS(FC-2 PASS·M2 `weather_condition_ui_extension_test` red).
- **비치명**: 전 PASS/NA.
- **blindspots**: G-8 '구름 많음' 공백 N7 경계(엄격 적용 시 경미 위반 소지·낮은 확률). FID-L1/L2 결정레인·screenProbes 정상. ST-2 액션채널 read-only 미발화.

## Y-g3 (codex · **적대**)
- **치명**: 9 전부 PASS.
- **위장 변종 점검(8종 전수 무혐의)**: ① 빈 wrapper 없음 ② Left no-op 없음 ③ 우회명 self-show 없음 ④ 판정누수 없음 ⑤ 동형 신호버스 없음 ⑥ 함수형 위장 없음 ⑦ 변환계층 없음 ⑧ M4 날짜 round-trip 통과(VO.toApiPath round-trip·`widget_test:35-38` integration 검증).
- **FC-2 정직 단서**: "라이브 mutation 주입이 read-only 정책으로 불가 → 테스트↔코드 결합 정적 분석으로 판정: M2(`weather_condition_ui_extension_test:46-64` 정확 icon+color+set distinct→swap RED)·M1·M3·M4·M5 모두 비-vacuous 구조 확인. **단 실주입 미실행이므로 FC-2는 결정 레인 최종 확정 권장**." → 조정자 실측(M2 red·exit 1)으로 확정.
- **blindspots**: ① 라벨 공백 차(57차원 미포착) ② **pubspec sdk ^3.12.1 vs RUBRIC BG-1 ^3.9 가정 어긋남**(코퍼스 SDK 핀 정합 필요) ③ FID 형상(Transform.translate·헤더 이미지)은 결정레인/L4 ④ metrics 아이콘 심볼 중복(A1).

---

## 조정자 결정 레인 실측 (의미 레인 독립 확증)
- **FC-2 M2 양판 실주입**(워크플로우 후·코드 race 없음): claude `condition_ui_extension` clear→thunderstorm → `flutter test` **17/17 green**(vacuous 확증) / codex `weather_condition_ui_extension` clear→thunderstorm → **exit 1·`ui_extension_test:48` red**(비-vacuous 확증). 양판 mutation 복원(clear→sunny 원상)·dirty 검증.
- **결론**: 의미 레인(X-g2·g3 FAIL / Y 만장 PASS)과 결정 레인 실측 **일치** — claude FC-2 vacuous FAIL·codex FC-2 PASS 확정.
