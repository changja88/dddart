# grader 패널 raw verdict — weather 12차 (EVAL §2.0 blind 증거 영속)

> 6 grader(양판 각 3 = 의미 lens1 DDD·View·Data / 의미 lens2 State·HR·Q / 적대) blind 독립 채점 + 조정자 결정 레인. 전원 Claude 계열(⚠️ 비-Claude 오라클 미확보). 각 grader는 결정 레인 결과·타 grader 노트 미수령·코드 직접 정독·줄 인용 의무. **채점일 2026-06-21 0203 · 코퍼스 480eb11 · baseline abee26d.** 원문 전량은 세션 transcript에 보존·아래는 판정·핵심 인용·사각 신고 정리.

---

## 조정자 결정 레인 (봉인 → 합성)

- **갭 원장**: claude 110파일 +12865(lib 83·test 9) / codex 99파일 +13709(lib 71·test 10) — `git diff abee26d --stat`
- **백스톱** `backstop.dart --diff-base abee26d`: 양판 58종 gated **blocker 0**
- **BG-1·BG-2** `build_runner build`(exit 0)→`flutter analyze`: 양판 **"No issues found!"**
- **flutter clean && flutter test**(전 스위트): claude 26 green·codex green(exit 0)
- **FID** `fid-gate.sh`: 양판 **exit 3 (A1 폴백)** — screenProbes 미노출·시안 layout-ir(화면2·영역8) → ref-layout.json 보존
- **FC-2 mutation 실주입**(결정 레인 정본·자기보고/grader 불신):
  - **M1 정렬 역전**: claude `weekly_forecast_test.dart` red ✅ / codex `weather_forecast_test.dart` red ✅ (둘 다 비-vacuous)
  - **M2 아이콘/색 매핑 swap(clear↔thunderstorm)**: **claude 전체 26 green = vacuous ❌** / **codex `weather_condition_ui_extension_test.dart` red ✅ 비-vacuous** — 양판 byte-identical 복원 확인
  - → **claude FC-2 FAIL(M2 vacuous)·codex FC-2 PASS**. 적대 grader 양판 모두 FC-2 PASS로 봤으나(claude 적대 "Set 크기"·codex 적대 전수단언 확인) 조정자 실주입이 claude vacuity 격파.
- **Track B**: 양판 has_layout_ir=true·design-spec area 트리 박힘(claude 19토큰·codex 14토큰)

---

## [claude] lens1 (DDD·View·Data)
- **치명 7/7 PASS**: SD-1(정렬=`weekly_forecast.dart:20-24` 루트팩토리)·SD-2(전이0)·SD-7(`weather_use_case.dart` UI import0)·VW-1(build 표시·위임만)·VW-6(self-show static0)·DT-1(`weather_repo.dart:20-28` Either·fold Left throw)·DT-2(safeApiCall)
- **비치명**: VW-4 🟡(`forecast_tile_widget.dart:67`·`detail_metric_widget.dart:37` Colors.white)·DT-3 ✅(freezed 3필드)·나머지 ✅·SD-6/DT-7/DT-9 ➖
- **사각**: icon size 토큰화 비대칭(VW-4 색만 강제·치수 자유)·BrandHeaderWidget 시안 로고 placeholder(FID image 위임)

## [claude] lens2 (State·HR·Quality)
- **치명 6/6 PASS**: ST-1(`weekly_forecast_vm.dart:20` UseCase만)·ST-2(throw BadRequestResponse→AsyncError)·ST-4(build-only·발화조건 미충족)·HR-1·HR-4·HR-5(단일BC·역류0)
- **비치명**: Q-7 🟡(생 치수 매직 3건 width:72·size:18·size:32)·Q-8 🟡(1줄 길이)·나머지 ✅·ST-6/HR-9 ➖. TIER-Q 상.
- **사각**: VW-4↔Q-7 시각 치수 경계(Colors.white가 VW-4 트리거인지)·ST-4 조회전용 vacuous PASS(위반 기회 부재)

## [claude] 적대
- **치명 16(BG 제외) 전수 ✅생존**: SD-1 빈wrapper 아님·DT-1 Left no-op 아님·VW-6 우회명 self-show 0·ST-8 동형버스 0·함수형provider 0(3개 클래스형)·HR-5 단일BC 채널④ 미발화
- **FC-1 G-1~G-8 전수 ✅**: 정렬 `weekly_forecast.dart:21-22`·탭↔상세 round-trip·6종 아이콘 distinct·색 디자인 충실(3색·design.md:103-104 근거)·**G-8 라벨 정확("구름많음"·"흐림")**·기온 슬롯·음수 부호·상세 3지표
- **FC-3 N1~N7 무관측**
- **FC-2 "생존" 판정(M2=Set 크기로 분석)** ← ⚠️ **조정자 실주입이 격파**(아이콘 swap green=vacuous)
- **사각**: 패키지명 `smaple` 오타(컴파일 정합)·error_feedback 버튼텍스트

## [codex] lens1 (DDD·View·Data)
- **치명 7/7 PASS**: SD-1(정렬 `weather_forecast.dart:18-25`·VO compareTo·isForDate entity)·SD-2·SD-7·VW-1·VW-6·DT-1(`.map`/`.flatMap` Left 전파·VM fold throw)·DT-2(safeApiCall)
- **비치명**: **DT-3 ❌**(`bad_request_response.dart` plain class 2필드 message/statusCode·freezed 3필드 errorType/msg/isShow 미준수·isShow 부재)·VW-4 🟡(타이포 fontSize/height·Radius 999)·SD-9 🟡(엔티티명↔화면명 비대응)·DT-8 🟡·DT-6/DT-7/DT-9/SD-6 ➖
- **사각**: DT-3 isShow 부재가 ST-2 파급(lens2 소관)·VW-4 레이아웃 치수 귀속 모호

## [codex] lens2 (State·HR·Quality)
- **치명 6/6 PASS**: ST-1(`weekly_forecast_vm.dart:17` UseCase만·SharedState 같은BC)·ST-2(throw BadRequestResponse·`:54` view error)·ST-4(`:24`·`:40` await 후 reset mounted 가드)·HR-1·HR-4·HR-5(단일BC)
- **비치명**: Q-7 🟡(CQS 위반 `selectForecastForDetail` mutate+return·중복 요일포맷 헬퍼·테스트전용 `selectForecast`)·나머지 ✅·ST-6/ST-7 ➖. TIER-Q 상.
- **사각**: SharedState YAGNI(단일 BC 2화면에 신설·stale-reset 댄스·ST-6는 교차watch만 FAIL)·ST-2 액션채널 영구 vacuous·요일포맷 VW-5 vs Q-7 경계

## [codex] 적대
- **치명 16 전수 ✅생존**: SD-1 실판정·DT-1 Left 전파·VW-6 0·ST-8 0(SelectionSharedState는 명사·keepAlive·reset·과거형/카운터 아님)·함수형provider 0
- **FC-1 G-1~G-7 ✅**: 정렬·탭↔상세 round-trip(`weather_navigator`→`weather_router:27-29`)·6종 아이콘 distinct+색 distinct(전수 매핑)·상세 3지표
- **G-8/N7 cloudy 라벨 drift 적대 신고**: `weather_condition_ui_extension.dart:10` cloudy→mostlyCloudy→"대체로 흐림"(골든 §0 "구름많음" verbatim 불일치) — **본인 양론 병기**: "verbatim drift이지 의미 오배치(overcast를 구름많음으로 류) 아님·영문노출 아님·reconciliation 위임"
- **FC-3 N1~N6 무관측·N7 경계 신고**
- **사각**: SharedState YAGNI(IM22 carrier 동류·codex)·VW-4 매직값·N7 verbatim 경계

---

## 조정자 reconciliation (적대 신고 처리)

1. **claude FC-2 (적대 PASS → 조정자 FAIL)**: 적대가 M2를 "Set 크기"로 보고 PASS. 조정자 mutation 실주입(clear↔thunderstorm 아이콘 swap → 전체 green) → **vacuous 확정·FC-2 FAIL**. EVAL §2.6 자기보고/grader 불신·조정자 직접 검증의 정신. (κ 만장일치가 vacuity를 가린 사례 → RUBRIC FC-2 "distinct≠매핑정확" 명문화 사각 신고.)
2. **codex G-8/N7 (적대 신고 → 조정자 PASS·충실도 흠)**: FC-1 G-8·FC-3 N7의 FAIL 조건은 "영문 enum 노출·라벨 *오배치*"로 명시. codex "대체로 흐림"은 cloudy(mostly cloudy) 의미 충실·overcast("흐림")와 구별·오배치/영문노출 미해당 → **FC-1/FC-3 게이트 PASS**. 단 task 정본 라벨("구름많음") 이탈은 **충실도 흠(A1·claude 대비 열위)**으로 기록. 11차 색 조항 개정("의미 충실을 verbatim 엄격으로 FAIL 주지 마라")의 동형 적용. 다음 골든 라운드 "N7 verbatim 경계 명문화" 입력.

## 차원별 κ (치명·담당 의미 grader + 적대 2명)
- **claude**: 치명 만장일치 PASS(lens·적대) — 단 FC-2는 조정자 실주입이 grader 합의를 정정(결정 레인 권위).
- **codex**: 치명 만장일치 PASS·DT-3은 lens1 단독 발화(비치명·데이터 담당)·G-8은 적대 신고→조정자 PASS.
- ⚠️ 전원 Claude 계열 — 동종 증언(in-family)·독립성 한계. 비-Claude 오라클 미확보.
