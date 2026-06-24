# grader 패널 raw verdict — weather 17차 (blind 증거 영속·EVAL §2.0 A3)

> 의미 레인 grader 6명(양판 각 3·각 1 적대) raw verdict. 조정자(메인 루프)와 별개 인격·결정 레인 결과·variant·엔진 미수령(익명 번들 X/Y·design-spec 제외). **전원 Claude 계열 — 비-Claude 오라클 미확보(⚠️ 독립성 한계)**. 산출물 X=claude·Y=codex(grader는 엔진 정체 미고지). 채점일 2026-06-24·코퍼스 `c6c4521`.

---

## 산출물 X (claude)

### X-g1 (일반)
- 의미 레인 **전 항목 PASS**·치명 18 전수 ✅(BG는 결정 레인 위임).
- SD-1: Y — `weekly_forecast.dart:22-26` 정렬 애그리거트 루트 거주·VM fold 변환만.
- FC-1: Y — G-1~G-8 일치(정렬 domain·기온 바인딩·탭→날짜 round-trip·6종 distinct·**한글 라벨 §0 정확 cloudy=구름많음·overcast=흐림**).
- DT-2: Y — `safe_api_call.dart` fromJson 가드 `on Object`. DT-3: Y — freezed 3필드 errorType/msg/isShow·snake @JsonKey.
- **사각 신고**: 목록 행 상태 텍스트 라벨 부재(아이콘+색만·한글 라벨은 domain enum/상세)·rain `water_drop`=습도 카드 심볼 중복(L4)·windSpeed raw double·FID-L1 bottomnav(결정 레인).

### X-g2 (일반)
- 치명 18 전수 PASS(의미)·**적대 우려 1건: `_support.dart` `overrideWith2` 비표준 API 의심**(생성 .g.dart 미정의 가능성→BG-2 FAIL 위험)→**조정자 결정 레인 `flutter test` +42 green으로 해소**(컴파일·통과 실측).
- VW-4: ✅ — copyWith 전부 `color:` 토큰·fontSize/height/letterSpacing 리터럴 0·`metricUnit`/`cardSecondaryTemp` 완결 토큰 승격(16차 fontSize:18 봉합). DT-3: ✅ snake 3필드. Q-6: ✅ runZonedGuarded 위임(빈 바디 0). Q-7: ✅ press AnimatedScale 실구현(죽은토큰 화석 해소).
- **사각 신고**: `overrideWith2` 결정 레인 확인 필요·FID-L1 bottomnav·DT-8 계약위험 표기 옅음.

### X-g3 (적대 — "통과시키지 마라")
- 집중 적발 8축 **전부 무혐의**(SD-1 빈 wrapper·DT-1 Left no-op·VW-6 우회 self-show·ST-2 침묵 폐기·VW-5/4 누수·SD-7 재export 사슬·FC 디코이·함수형 위장).
- FC-1 G-1~G-8 전수 PASS — **한글 라벨 §0 대응표 글자 일치**(16차 codex 역전·발명·누락 재발 없음). 6종 distinct·cloudy/snow 색 공유는 §0 경계상 합법(아이콘 distinct).
- **VW-4 copyWith fontSize 0**(16차 claude `fontSize:18` 결함 부재·완결 토큰 승격)·screenProbes 시그니처 정확(`Future<Finder>`·_support.dart:340).
- FC-2 비-vacuous: M1(정렬 뒤섞음 domain+seam C)·M2(ui_extension 전수 핀 swap 직격)·M3·M4·M5 골든 seam 두드림.
- **유일 신고**: FID-L1 bottomnav(시안 `<nav>` 2화면 존재·코드 0·`root_view.dart` §9.2 자백·결정 레인 compare_layout 소관).

---

## 산출물 Y (codex)

### Y-g1 (일반)
- **치명 18 전수 PASS**·FC-1 G-1~G-8 일치.
- FC-1: ✅ — `weather_condition_ui_extension.dart:9-14` 한글 라벨 §0 정확(clear=맑음·**cloudy=구름많음·overcast=흐림**·rain=비·snow=눈·thunderstorm=뇌우)·영문 enum 노출 0·라벨 거주=ui_extension verbatim.
- **DT-3: ❌🟡** — `bad_request_response.dart:11-15` 필드=`msg`/`isShow`/`statusCode?` — **errorType 누락**(timeout/parse/unknown 어휘 carrier 부재)·statusCode 대체. 비치명. Q-7: 🟡(EdgeInsets 매직넘버 12/4/3·State error 화석).
- **사각 신고**: FID-L1 bottomnav(시안 `<nav fixed bottom-0>`)·State error 필드 화석(읽기전용 미기입)·EdgeInsets 토큰 미경유.

### Y-g2 (일반)
- 치명 18 전수 PASS·FC-1/G-8 한글 라벨 §0 정확.
- **DT-3: 🟡** — 3필드 역할계약 errorType→statusCode 치환·어휘 부재. **VW-4: 🟡경계** — copyWith는 `color:`만(typography 리터럴 0·VW-4 비대상)·박스 패딩 `bottom:12`/`left:4,bottom:3`은 §8/FID-L4 경계.
- Q-7: 🟡 — `AppDuration.fadeIn` 죽은 토큰(시안 animate-fadeIn 화석)·press 미구현(`active:scale-98` 미반영·`AnimatedScale(scale:1)` 고정).
- **사각 신고**: FID-L1 bottomnav(결정 레인 산입 시 치명 가능·의미 grader 권한 밖·미도장)·습도/강수 `water_drop` 심볼 중복·DT-3 어휘 강제 수위 회차 흔들림.

### Y-g3 (적대 — "통과시키지 마라")
- 집중 적발 8축 **전부 무혐의**(빈 wrapper·Left no-op·우회 self-show·침묵 폐기·누수·재export·FC 디코이·함수형 위장).
- FC-1 G-1~G-8 전수 PASS — **한글 라벨 verbatim·역전/발명/누락 0**(cloudy=구름많음·overcast=흐림·"대체로 흐림" 발명 없음)·**enum 식별자 `clear/cloudy/overcast/rain/snow/thunderstorm` 서버 계약값 verbatim·@JsonValue 동일·의미 재명명 0**.
- DT-2: 자기정규화기 `fromUnknown`/`fromDioException` 순수 생성자·`safeApiCall`이 FormatException/Object 전부 정규화(parse-throw 누수 0·repo 테스트 bad JSON→Left 실증). **DT-3: 🟡**(errorType 부재·statusCode·비치명·8축 밖).
- **사각 신고**: FID-L1 bottomnav(결정 레인)·State error 필드 화석·M3 list-card seam 값 미핀(상세 hero는 값핀 red)·M4 "non-edge" 명명 부정합(단언값은 first와 distinct=비-vacuous 유지).

---

## 조정자 종합 (κ·split·blind 메타)

| 차원 | X(claude) 3 grader | Y(codex) 3 grader | 비고 |
|---|---|---|---|
| FC-1 | ✅✅✅ (κ 1.0) | ✅✅✅ (κ 1.0) | **★양판 동률 PASS** — 16차 codex 0.67(역전)에서 fix024로 만장일치 |
| FC-2 | ✅(조정자 실측)·✅·✅ | ✅(실측)·✅·✅ | M1·M2 mutation 실측 red·양판 비-vacuous |
| FC-3 | ✅✅✅ | ✅✅✅ | 양판 N7 정합(codex 16차 라벨 오배치 해소) |
| 치명 의미 13(SD·VW·ST·DT·HR) | ✅✅✅ (κ 1.0) | ✅✅✅ (κ 1.0) | 양판 만장일치 PASS |
| VW-4 | ✅✅✅ (κ 1.0) | ✅✅🟡(g2 경계) | claude 16차 g3 단독 fontSize:18→fix022 만장일치·codex 박스패딩 경계 |
| DT-3 | ✅✅✅ | 🟡🟡🟡 (κ 1.0) | codex errorType 누락 만장일치 WEAK(비치명) |
| Q-6 | ✅✅✅ | ✅✅✅ | 양판 runZonedGuarded 비빈(fix021) |
| Q-7 | ✅✅✅ | 🟡🟡🟡 | claude press 구현·codex 미구현(엔진 비결정 N=3) |

> **치명 보수 판정**(EVAL §2.2): 양판 치명 18 의미 레인 만장일치 PASS·줄인용 동반 FAIL 0. **codex FC-1은 16차 g1·g2 줄인용 N(치명 FAIL)에서 17차 만장일치 Y로 역전(fix024 적중)**. 비치명 차분(DT-3·Q-7) codex 🟡 만장일치.
> **blind 한계**: 전원 Claude 계열(비-Claude 미확보). FC-2는 조정자 mutation 실측(M1·M2 주입→red)으로 독립 확증·FC-1은 §0 대응표(사전등록·동결) 대조라 grader 재량 최소. X-g2 `overrideWith2` BG 우려는 결정 레인 +42 green으로 해소(blind grader가 못 닫는 결정 항목을 조정자가 봉인 결과로 해소한 정상 사례).
> **적대 grader 절차**: 양판 g3 모두 결과지 파일 자발 작성 없음(16차 X-g3 위반 재발 0)·반환값으로만 보고(EVAL §2.0 정합).
