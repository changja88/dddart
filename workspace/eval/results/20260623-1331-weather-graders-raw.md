# grader 패널 raw verdict — weather 16차 (blind 증거 영속·EVAL §2.0 A3)

> 의미 레인 grader 6명(양판 각 3·각 1 적대) raw verdict. 조정자(메인 루프)와 별개 인격·결정 레인 결과 미수령. **전원 Claude 계열 — 비-Claude 오라클 미확보(⚠️ 독립성 한계)**. 산출물 X=claude·Y=codex(grader는 엔진 정체 미고지). 채점일 2026-06-23·코퍼스 `1fc7946`.

---

## 산출물 X (claude)

### X-g1 (일반)
- 의미 레인 **전 항목 PASS**(SD-1·SD-3·SD-4·SD-5·SD-7·VW-1·VW-2·VW-5·VW-6·ST-1·ST-2·DT-1·DT-2·FC-1·FC-3).
- SD-1: Y — `weekly_forecast.dart:19-23` 정렬 애그리거트 루트 거주·VM 변환만.
- FC-1: Y — 골든 ①~④ 일치(정렬·기온·탭 날짜·6종 distinct 매핑·한글 라벨).
- DT-2: Y — `safe_api_call.dart:18-28` fromJson 가드 `on Object`.
- **사각 신고**: 목록 행 상태가 텍스트 라벨 없이 아이콘+색만(한글 라벨은 상세에만)·rain `water_drop`이 상세 습도 카드 아이콘과 동일 심볼(FID-L4/A1)·FID-L1 bottomnav 부재(결정 레인 소관).

### X-g2 (일반)
- 의미 레인 **전 항목 PASS**(SD-1·SD-2➖·SD-8·SD-9·VW-3·VW-4·VW-5·VW-7·ST-2·ST-3·ST-5·ST-8·ST-9·DT-1·DT-3·DT-4·DT-5·FC-1·FC-3).
- FC-1: Y — 골든 4종 일치·detail 재조회 정상.
- 비치명 Q-7: `fromDate`·`fadeIn` 죽은 코드(WEAK)·**press는 `AnimatedScale`로 실구현**(화석 아님).
- **사각 신고**: FID-L1 bottomnav 시안 존재·코드 0(`Scaffold` bottomNavigationBar 없음·결정 레인 소관이나 자동 게이트 폴백이라 미포착).

### X-g3 (적대 — "통과시키지 마라")
- 집중 적발 8축 **전부 무혐의**(SD-1 빈 wrapper·DT-1 Left no-op·VW-6 우회 self-show·ST-2 침묵 폐기·VW-5/4 누수·SD-7 재export 사슬·FC 디코이·FC-1/3).
- **FC-2 vacuous 해소 확증**: M2 아이콘 swap→값핀 테스트 red(`Expected U+F0575 / Actual U+F05A2`)·no-sort→정렬 3건 red·fixture 뒤섞임(`[3,1,5,2,4]`)+값핀으로 비-vacuous.
- 유일 픽스처 흠: **FID-L1 bottomnav**(시안 HTML↔코드 수기 대조·design-ref `<nav fixed bottom-0>` vs 코드 bottomNavigationBar 0).
- 비치명: **VW-4 `forecast_tile_widget.dart:101 .copyWith(...fontSize:18)`** 토큰 밖 타이포 리터럴·**Q-6 `main.dart:30 runZonedGuarded(...{})`** 빈 에러 핸들러.
- **사각 신고**: runZonedGuarded 빈 핸들러는 현 57차원 catch 위생 사각·FID-L1 fid-gate 자동 도구 재실행 권고.
- ⚠️ **절차 일탈**: 이 grader가 결과지 파일(`20260623-1331-weather-claude.md`)을 자발 작성(EVAL §2.0 위반·결과지는 조정자 합성본)·조정자 정본으로 교체(blind 영향 없음 — 적대 단독·결정 레인 미수령).

---

## 산출물 Y (codex)

### Y-g1 (일반)
- **FC-1: N** — 골든 ④ 한글 라벨 불일치: 서버 `cloudy`→"흐림"·`overcast`(enum mostlyCloudy)→"대체로 흐림"·**"구름많음" 부재**(`weather_condition_ui_extension.dart:9-15`). ①②③ 일치.
- 나머지(SD-1·SD-3·4·5·SD-7·VW-1·2·5·6·ST-1·2·DT-1·2·FC-3): PASS.
- **사각 신고**: FC-1 한글 라벨 SSOT 부재 — 시안에 한글 라벨 없고 골든이 task 어구에만 의존, 서버 enum↔한글 매핑 명세 미결정·grader 재량 흔들림. **FC-GOLDEN enum코드↔한글 1:1 핀 사전등록 권고**.

### Y-g2 (일반)
- **FC-1: N·FC-3: N** — cloudy↔overcast 의미 역전(`weather_condition_ui_extension.dart:11-12`·enum `weather_condition.dart:6-7 @JsonValue('overcast') mostlyCloudy`)·"구름많음" 전역 부재. 6종 distinct 아이콘·색·라벨은 부여되나 라벨 *의미* 2건 어긋남.
- 나머지(SD-1·SD-2➖·SD-8·9·VW-3·4·5·7·ST-2·3·5·8·9·DT-1·4·5): PASS.
- DT-3: 🟡 — `bad_request_response.dart:9-11` fromJson camelCase 키(`errorType`)·루브릭 snake_case 예시 불일치(비치명).
- **사각 신고**: ⓐ FC-1 한글 라벨 enum↔한글 1:1 핀 부재(grader 재량) ⓑ DT-3 camelCase·404→'unknown' ⓒ ST-2 액션 채널 전면 미발화(조회전용·절반 미실증·조건부 발화 명문화 권고).

### Y-g3 (적대 — "통과시키지 마라")
- 집중 적발 8축 무혐의(SD-1·DT-1·VW-6·ST-2·VW-5/4·SD-7·FC 디코이·VW-7).
- 치명 게이트 실측 PASS 주장(`flutter analyze` green·`flutter test` 16/16·mutation 3종 red).
- **유일 실질 적발 = FC-3 한글 라벨 "구름많음"→"대체로 흐림" 일탈** — **비치명 라벨 일탈로 정상참작**(근거: ⓐ 서버 계약 overcast만·mostly_cloudy 없음 ⓑ architect `design-spec.md:30` "계약 위험" 투명 표기 ⓒ Stitch 시안 한글 라벨 없음 ⓓ 의미 근사). "치명 FC-3 도장은 과함" 주장하나 프롬프트가 라벨 verbatim 못박음은 인정.
- DT-2: 자기정규화기 `_normalizeDioException try{}on Object{}` 가드 확증(404 폴백·15차 claude swap 경로 codex 봉합).
- **사각 신고**: FC-3 정상참작(서버 overcast 한글 의도 사용자 확정 필요)·`main.dart:20` 빈 zone 핸들러·windSpeed double raw 표시(L4).

---

## 조정자 종합 (κ·split·blind 메타)

| 차원 | X(claude) 3 grader | Y(codex) 3 grader | 비고 |
|---|---|---|---|
| FC-1 | ✅✅✅ (κ 1.0) | ❌·❌·🟡(g3 정상참작) (κ 0.67) | **양판 결정적 갈림** — claude §0 대응표 일치·codex 역전 |
| FC-2 | ✅(조정자 실측)·✅·✅ | ✅(실측)·✅·✅ | mutation 실측 red·양판 비-vacuous |
| FC-3 | ✅✅✅ | ⚠·❌·🟡 | codex FC-1 동일 결함(N7) |
| 치명 의미 13(SD·VW·ST·DT·HR) | ✅✅✅ (κ 1.0) | ✅✅✅ (κ 1.0) | 양판 만장일치 PASS |
| VW-4 | ✅·✅·🟡(g3) | ✅✅✅ | claude만 fontSize:18 흠 |

> **치명 보수 판정**(EVAL §2.2): codex FC-1은 g1·g2 줄인용 동반 N → 1명이라도 줄인용 FAIL이면 치명 FAIL(g3 정상참작은 심각도 이견이지 대응표 위반 부정 아님). **codex FC-1·FC-3 치명 FAIL 확정 + 사용자 한글 의도 확정 권고**(다음 동결 FC-GOLDEN 1:1 핀).
> **blind 한계**: 전원 Claude 계열(비-Claude 미확보). FC-2는 조정자 mutation 실측으로 독립 확증. FC-1은 §0 대응표(사전등록·동결) 대조라 grader 재량 최소.
