# grader raw verdict — 20260616-2025-weather-codex (A3 blind 증거 영속)

> EVAL §2.0/§2.2 — 의미 grader 3명(조정자와 별개 세션·결정레인 결과·variant 미수령)의 raw blind verdict. 단일저자 N목소리 위장 차단용 증거. **전원 Claude 계열 — 비-Claude 오라클 0(A3 독립성 미확보·결과지 헤더 ⚠️)**. 대상 = `/tmp/codex-grade-2025/lib`(+test)·엔진 blind(codex 미고지). 색 충돌은 조정자 미고지였으나 3명 독립 발견.

## n1 (엄격중립)

**치명 표**: SD-1 ✅(`weather_forecast.dart:15` containsDate·`:17-25` forecastFor 실판정·VO 검증 `forecast_date.dart:15,25`) / SD-2 ➖NA(조회전용·freezed 불변) / SD-7 ✅(`weather_forecast_use_case.dart:15-17` repo 위임·flutter import 0) / VW-1 ✅(`weekly_forecast_view.dart:44-61` switch 표시·`weekly_forecast_list_section.dart:23-40` 매핑만) / VW-6 ✅(show/showDialog/announce/popup/overlay 0·ErrorFeedback 렌더) / ST-1 ✅(`weekly_forecast_vm.dart:15,19` useCase뿐·Repo/dio/BuildContext 0) / ST-2 ✅(`:22-25` fold→throw→AsyncError·view `:56` 분기) / ST-4 ➖NA(`:29` requireValue await 전·`:34` navigator 마지막) / DT-1 ✅(`weather_forecast_repo.dart:24,33` Future<Either>·VM `:23` fold throw 전달) / DT-2 ✅(throw 0·`:25,35` safeApiCall·`safe_api_call.dart:10-50` 전경로 Left/Right) / HR-5 ✅(2 애그리거트 한 BC·공유 VO/enum 일관 경계).
**치명: FAIL 0 / NA 3 / PASS 8.**

**FC-1**: G-1 **FAIL**(클라 정렬 전무·`sort/compareTo/reversed` 0매치·`weather_forecast_repo.dart:26-29` 서버순 래핑·`weekly_forecast_state.dart:22` map 순서보존 → 서버순 100% 의존) / G-2 PASS(조건부·`weekly_forecast_list_section.dart:25 itemCount: days.length`·개수 비강제) / G-3·G-4 PASS(`daily_forecast.dart:24-25` temp_max/min·`weekly_forecast_day_display_state.dart:25-26` 슬롯·음수부호 int 보존·tracer `:59` -3 통과) / G-5 PASS(`weekly_forecast_list_section.dart:34 onForecastTap(day.date)`→VM `:34`→navigator `:18-20`→router→`daily_forecast_detail_vm.dart:18 parse`·치환 없음) / G-6 PASS(`daily_forecast_detail_metrics_section.dart:18,24,30` 습도·풍속·강수확률) / **G-7 부분 FAIL**(icon 6/6 distinct `:16-23` / **listIconColor 5/6 — clear=cloudy=secondaryContainer 0xFFFEAE2C `:26-27`** / detailHeroIconColor 6/6 `:34-41`) / G-8 PASS(`:7-14` 6종 한글).

**FC-3**: **N4 발화 FAIL**(clear·cloudy listIconColor 동일색 `:26-27`·목록 카드 `forecast_card_widget.dart:76` 사용). N2 잠재(서버순 의존)이나 미발현 처리. N1·N3·N5·N6·N7 미발화.

**종합**: **FAIL** — 치명 11 PASS/NA이나 FC-1 G-7(listColor 5/6)·FC-3 N4 FAIL.

**A13**: ①테스트가 색 충돌을 정답 박제(`weather_forecast_screen_test.dart:243-254` clear·cloudy 둘 다 secondaryContainer expect·테스트명 "distinct"인데 비-distinct 검증) ②detailHero는 6 distinct인데 listColor만 5(비대칭·한쪽만 수정 흔적) ③G-1/N2 서버 오름차순 100% 의존·클라 방어 0 ④개수 7 비강제 ⑤thunderstorm/overcast 회색계열 명도차 작음(지각 구별성·distinct 집합은 PASS) ⑥습도·강수확률 동일 아이콘 ⑦windSpeed double 미정규화 ⑧상세 AppBar "주간 날씨" 고정.

## n2 (중립)

**치명 표**: SD-1 PASS(`weather_forecast.dart:15-25`·VM `weekly_forecast_vm.dart:30` 소비) / SD-2 NA(조회전용·copyWith는 TextStyle/ColorScheme만) / SD-7 PASS(`weather_forecast_use_case.dart:13,15-17` 무상태·Either 통과·flutter 0) / VW-1 PASS(`weekly_forecast_view.dart:18-67` watch→switch 표시·`:51-53` 위임) / VW-6 PASS(View static 0·VM→Navigator 경유) / ST-1 PASS(`weekly_forecast_vm.dart:15,19` useCase만·BuildContext/mounted/ref 0) / ST-2 PASS(`:22-25` fold throw→AsyncError·detail 동일) / ST-4 NA(`:18-26` build await 후 return·`:28-35` requireValue await 전) / DT-1 PASS(`weather_forecast_repo.dart:24` Future<Either>·VM `:23` throw 실소비) / DT-2 PASS(infra throw 0·`:25,35` safeApiCall·`_normalizeDetailNotFound:41-47` 반환형) / HR-5 PASS(경합·2 read-model 루트 vs 서버 엔드포인트 2종 1:1·경계 깨짐 없음).

**FC-1**: G-1 **FAIL(서버순 의존·sort 0·`weekly_forecast_state.dart:22-24`)** / G-2 PASS(개수 비강제·`:25`) / G-3 PASS(`:25` high 슬롯) / G-4 PASS(`:26` low·int 음수보존·model_test `:74` -4) / G-5 PASS(탭→pathParam→parse 동일 날짜·hero `:38` dateLabel) / G-6 PASS(`:16-32` 3카드) / **G-7 FAIL**(icon 6 distinct·detailHero 6 distinct·**listIconColor 5: clear=cloudy=secondaryContainer 0xFFFEAE2C `:26-27`**·카드 `forecast_card_widget.dart:76` 사용) / G-8 PASS(`:7-14`).

**FC-3**: **N4 발화(치명)**(clear·cloudy 목록색 충돌). N2 발화(클라 순서보증 없음·사각). N1·N3·N5·N6·N7 미발화.

**종합**: 아키텍처/데이터/상태/도메인 치명 전부 PASS/NA이나 **G-7·N4 위배(목록 색 6 distinct 실패)** — FAIL.

**A13**: ①테스트가 결함 동결(`:243,248` clear·cloudy 둘 다 secondaryContainer expect) ②detailHero 6 vs list 5 비대칭 ③G-1/N2 서버 오름차순 의존(정적 정독만 보임) ④개수 7 비강제(클라 불변식 부재).

## adv (적대)

**치명 표**: SD-1 PASS(경계·`weather_forecast.dart:10` `._()`+`:15-25` 판정·단 변종① 정렬부재) / SD-2 **FAIL(약)**(날짜 정렬 코드 전무·grep NO SORT·서버순 무비판) / SD-7 **FAIL**(daily_forecast_detail 애그리거트 `._()`·메서드 0·순수 홀더 — 빈혈) / VW-1 PASS(`_errorMessage` 표시매핑만) / VW-6 PASS(`weather_forecast_navigator.dart:16` pushNamed만) / ST-1 PASS(state getter 위장 0·useCase Either 전달) / ST-2 NA/PASS(read-only·`ref.invalidate` 재시도) / ST-4 PASS(함수형 위장 0·`@riverpod class`) / DT-1 PASS(Left→AsyncError·fold 삼킴 0·단 변종③) / DT-2 PASS(`safe_api_call.dart:12-50` 정규화·404 body 무신뢰) / HR-5 **FAIL**(daily_forecast_detail 하위 entity/enum/spec/vo/domain_service 5개 전부 .gitkeep·루트 메서드 0 vs weather_forecast 실코드 — 경계 디코이).

**FC-1**: G-7 **FAIL**(icon 6·**listIconColor 5: clear≡cloudy=secondaryContainer 0xFFFEAE2C `:26-27`**·detailHero 6) / G-8(오름차순) **FAIL**(정렬 부재). 나머지 골든 PASS.

**FC-3**: **N4 발화**(listIconColor clear/cloudy 동일 상수 재사용). N1~N3·N5~N7 미발화.

**발굴 변종**: ①정렬 책임 완전 공백(G-8/SD-2·서버순 100% 의존·`weekly_forecast_state.dart:22-24`) ②**디코이 테스트(최치명)**(`weather_forecast_screen_test.dart:241` 이름 "distinct slot colors"·`:243`+`:248-250` 중복을 정답 단언·TG green으로 은폐) ③isShow 무시(`bad_request_response.dart:11` 존재·view `_errorMessage` isShow 미검사 무조건 표시·약) ④daily_forecast_detail 빈혈(HR-5 디코이·gitkeep 골격) ⑤tracer 무검증 값 통과(`daily_forecast_detail_tracer_test.dart:30-33` humidity=135·precip=240 범위초과 raw 보존 단언=domain spec 부재 정당화).

**종합**: 통과 금지 — 치명 FAIL G-7·G-8·HR-5·SD-7(빈혈), 약 FAIL SD-2·변종③.

**A13**: 결정레인 원리 blind — (a)색상 *값* 동일성(다른 enum 같은 `AppColor.secondaryContainer` 심볼) (b)테스트명↔단언 불일치 (c)정렬 부재="없는 코드"라 패턴매칭 침묵.

---

## 조정자 종합 노트 (raw 대조·EVAL §2.2 적용)

- **FC-1 G-7 / FC-3 N4 = 3/3 만장일치 FAIL**(κ=1.0) — listIconColor clear=cloudy=secondaryContainer(#FEAE2C). claude 5차는 2:1(n1 "쌍 구별" 변호)이었으나 codex는 **테스트가 충돌을 명시 단언(디코이)**해 n1도 FAIL. 색-distinct 판정단위 모호(A13)는 양엔진 공통 → feedback-008.
- **adv의 SD-7/HR-5 FAIL은 동일 사안(daily_forecast_detail 빈혈)의 중복 라벨** — EVAL §2.5/§3 실질성 관문 = *네트워크 read-model의 의무 빈 골격은 degenerate 아님* + weather_forecast 애그리거트가 실판정 보유 → BC 빈 골격 아님. n1·n2 PASS가 RUBRIC 예외의 정확한 적용. **조정자 판정: HR-5 ✅(2:1 보수 PASS·인간 큐)·SD-7 ✅(use_case 자체는 무상태·Either·UI 0)**. adv 빈혈 우려는 잔여흠 원장·인간 검토로 보존(소급 FAIL 아님).
- **adv의 SD-2 FAIL은 정렬 부재** — SD-2(Model 밖 copyWith 분기)와 무관·정렬은 FC-1 G-1/FC-2 M1 귀속. 조정자 판정: SD-2 ➖NA(n1·n2)·정렬은 FC로 계상(이중계상 방지·§3.6).
- **G-1(FC-1) = PASS** — 외부진실 서버 오름차순(curl 06-17→06-23) + 앱 순서보존 → *관측* 오름차순. 클라 정렬 부재는 **FC-2 M1 vacuity + A13 robustness**로 귀속(grader 3명의 "G-1 FAIL"은 코드보증 부재를 지목한 것·관측 행위는 PASS).
- **변종②(디코이 테스트) = FC-2 게이밍 신호** — 3명 독립 신고. 행위검증 게이트(TG·feedback-006)가 "색 6 distinct"를 단언하지 않고 충돌을 정답화 → feedback-008 색 판정단위 명문화의 직접 근거.
