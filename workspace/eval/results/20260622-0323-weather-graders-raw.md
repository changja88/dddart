# grader 패널 raw verdict — weather 13차 (blind 증거 영속·§2.0 A3)

> 3 grader(영역분담 2 + 적대 1)·variant 마스킹(X=claude·Y=codex·grader 미인지)·결정레인 비수령·줄인용 필수. ⚠️ **전원 Claude 계열(in-family)**. X/Y 매핑은 조정자만 보유(여기선 합성 후 공개). **채점일 2026-06-22 0323·코퍼스 `8fe3800`·baseline `abee26d`.**

---

## 조정자 결정 레인 (봉인 → 합성)

- **갭 원장** `git diff abee26d --stat`: X(claude) 103파일 +13596(lib 소스 42·test 12·HEAD `7a9b871`) / Y(codex) 117파일 +14018(lib 50·test 10·HEAD `5399e54`)
- **백스톱** `backstop.dart --diff-base abee26d`: 양판 58종 gated **blocker 0**
- **BG-1·BG-2** `build_runner build`(exit 0·재생성 손작성 0)→`flutter analyze`: 양판 **"No issues found!"** (단 Y는 dart-define `API_BASE_URL` env·순정 test는 `dio_client_test` red)
- **flutter test**(전 스위트): X 37 green / Y 22 green(dart-define 주입)
- **FID** `fid-gate.sh`: 양판 **exit 3 (A1 폴백)** — screenProbes 미노출·시안 layout-ir → ref-layout.json 보존
- **FC-2 mutation 실주입**(결정 레인 정본·자기보고/grader 불신):
  - **M1 정렬 역전**: X `weekly_forecast_test` red ✅ / Y `weather_forecast_test` red ✅
  - **M2 매핑 swap(clear↔thunderstorm icon+color)**: **X `weather_condition_ui_extension_test` red ✅(매핑 정확성 검증·12차 vacuous 자발 해소)** / **Y 재확인 red ✅**(첫 묶음 sed에서 green은 *조정자 sed 미적용*·swap 명시확인[icon20=thunderstorm] 후 red)
  - **M3 기온 swap**: X tile_test red ✅ / Y 전달부·compact(line 21) red ✅(첫 30/31 Column swap green은 *死줄 주입*·list/detail은 compact 경로)
  - **M4 내비 날짜**: X forecast_date_test red ✅ / Y list_view red ✅
  - → **양판 FC-2 비-vacuous PASS**(필수 M1~M4 전부 red)
- **DT-2 조정자 정독(grader split 해소)**: Y `safe_api_call.dart:15` `BadRequestResponse.fromJson(data)`가 `on DioException` catch 내부 무가드·BadReq 3필드 required→4xx 스키마불일치 시 fromJson throw가 catch절 내부라 safeApiCall 밖 탈출(누수 실현가능). X는 `_normalizeDioException` try/catch 가드. → **Y DT-2 ❌ 치명**(g2 ❌·g3 ✅ split을 조정자 코드정독으로 FAIL 확정)
- **13차 북극성**: 양판 에셋 token=배선 1=1(X `weather-list-1.png`·Y `list-1.png`·has_design_images true)·hero 120(X `iconSize=120`·Y `detailWeatherIconSize=120`)·main `MaterialApp.router` 배선·triage 정형목록(X 11·Y 7)
- **채점 메타(부작용 복원)**: X HEAD가 채점도구 parallel-gate `reset:abee26d`로 밀림→reflog `7a9b871` 복원(main.dart "미커밋" 오판 철회·X 정상커밋 확인)·양판 mutation 후 working tree 원상

---

## grader-1 (S-DDD·S-STATE)
**공통**: X·Y 조회전용 2화면. 도메인 변경/전이·액션 에러채널·copyWith 분기·await후 mutation 없음 → SD-2·SD-3·ST-2(액션)·ST-4 ➖N/A(vacuous PASS 금지).

**X(claude)**: SD-1✅(정렬 `weekly_forecast.dart:20-24`·매핑 ui_ext)·SD-4✅(`forecast_date.dart:9-31`)·SD-7✅·ST-1✅(`weekly_forecast_vm.dart:18` UseCase만)·ST-2✅조회/N/A액션·ST-3✅(error 필드 의도적 부재)·ST-5✅(@riverpod)·ST-8✅(valueOrNull/hooks 0)·나머지 ✅/N/A. **치명 SD-1·2·7·ST-1·2·4 전부 PASS/N/A.**

**Y(codex)**: SD-1✅(`weather_forecast.dart:14-22` fromUnorderedDays·`isEmpty` borderline PASS)·SD-4✅(freezed+Comparable)·SD-7✅(`.map` Right변환)·ST-1✅·ST-2✅조회/N/A(⚠️error 필드 미배선)·ST-3✅(⚠️error·isEmpty 군더더기)·나머지 ✅/N/A. **치명 전부 PASS/N/A.**

**rubric 사각 신고**:
1. **Y `error: BadRequestResponse?` 빈사 필드**(`weather_forecast_list_state.dart:13`·`_detail_state.dart:12`)— 선언만·쓰기/읽기/listen 0(전수 grep). 조회전용인데 절반 깐 액션채널 흔적. ST-3 "최소 State"가 액션VM 기준이라 조회VM 불필요 error 필드를 거짓 PASS. **죽은 채널 스캐폴딩 음성신호 필요**(X는 부재=대조군).
2. **Y `isEmpty: forecast.days.isEmpty`(VM 계산·State 저장)**: 컬렉션 술어라 SD-1 FAIL은 약하나 거주 회색지대. RUBRIC이 trivial-derivation 무죄 임계 명문화 필요.
3. **에러채널 reload-path 도달성**(X `skipLoadingOnReload:true`+주석·Y 생 `.when`): invalidate 재조회 시 build throw가 AsyncLoading으로 전이→기본 `.when` loading 분기로 에러 미표시 가능. ST-2가 reload 도달성 미측정(X 견고).

## grader-2 (S-VIEW·S-DATA·S-HR)
**X(claude)**: VW-1~7 전부 ✅(생 Color/TextStyle/Duration 0·`weather_condition_ui_extension.dart:33-45`)·DT-1✅·**DT-2✅**(`safe_api_call.dart:28-36` fromJson try/catch 가드)·DT-3✅(3필드)·DT-6✅(@RestApi+factory+part)·HR-1~9 전부 ✅. DT-7·9 N/A.

**Y(codex)**: VW-1~7 ✅·DT-1✅·**DT-2 ❌**(`safe_api_call.dart:15` `BadRequestResponse.fromJson(data)`가 `on DioException` 핸들러[외부 try 밖] 무가드→4xx 바디 결손/타입불일치 시 fromJson throw→safeApiCall 밖 탈출. X는 동일 호출 try/catch 가드. ⚠️in-family 보수판정)·DT-3✅·HR-1~9 ✅(HR-9 2개념 폴더분할). DT-7·9 N/A.

**rubric 사각 신고**:
1. **Y DT-2 판정이 DT-3 컨버터 면제와 경계 회색** — fromJson parse-throw가 safeApiCall로 정규화되면 면제이나, *여기선 throw 주체가 정규화기 자신*이라 자기를 못 감쌈(X와 실질차). "정적 누수 가능 vs 실측 무해(4xx 항상 정형)" 평가정책 RUBRIC 미명시. 결정 grep(throw 0)은 통과시켜 **의미 단독 사각**.
2. **레이아웃 수치 리터럴 거주 차원 부재**: X `size:28`·`width:56`, Y `width:96/128`·`size:40` bare 매직넘버 산재. VW-4(색·타이포·duration만)·FID(구조만) 사이 **레이아웃 상수 토큰 거주** 갭(Y는 hero만 토큰·카드폭 raw).
3. **Y `AppDuration.fadeIn` 단일토큰 다목적**(페이드인↔press-scale 동일값). 시맨틱 토큰 빈약을 거주차원이 못 봄(X는 3토큰 분리·단 transition 죽은토큰).

## grader-3 (적대 — 치명18 의미·FC골든·13차 북극성)
**치명 18 의미변종 색출**: X·Y **양판 변종 0**. 빈 wrapper·Left no-op·우회 self-show·동형 신호버스·fat widget·view 디코이 **한 건도 없음**.
- X FC-2: 기온 keyed-slot 비대칭음수·탭 carrier 실라우트 단언으로 **12차 vacuous 해소 확인**.
- Y FC-2: 풀스택 인터셉터 라이브 대조로 비-vacuity 견고.
- ⚠️ **Y DT-2를 ✅로 판정**(safeApiCall 래핑·throw 0만 보고 내부 fromJson 누수 미포착) → grader-2와 split(조정자 정독으로 grader-2 확정).

**FC 골든 대조**: X·Y 모두 G-1~G-8·N1~N7 **전수 ✅**(정렬 오름차순·7개·기온 바인딩·음수·탭↔상세 날짜·상세3지표·6종 구별매핑·한글라벨).

**13차 북극성 실태**: X·Y 모두 **전 항목 충실** — 에셋 실배선(`Image.asset(AppAsset.X)`·assets/images PNG 실재·manifest token=배선·흘림0)·hero size 120 정합(X `iconSize=120`·Y `detailWeatherIconSize=120`)·design-spec triage 정형목록·main `MaterialApp.router` 배선.

**적대 종합**: **치명 변종 0·통과 막을 결정타 X·Y 양쪽 없음**(단 DT-2는 grader-2가 의미정독으로 포착·grader-3 미포착).

**rubric 사각 신고**: `Image.asset` 배선이 *어느 화면 area에* 놓였는지 결정레인 미측정 — token=배선 grep 통과시키며 엉뚱한 화면 배치 가능. manifest alt↔렌더 area 대조 약신호 권고(현 라운드 양판 목록배치 정합·무해).

## 조정자 메타 (κ·split 처리)
- **치명 항목 κ**: 대부분 만장일치 PASS. **DT-2 = grader-2 ❌ vs grader-3 ✅(1:1 split)** → §2.2 치명 보수 FAIL + 조정자 코드정독 확정(fromJson required throw·catch절 내부 전파 = safeApiCall 밖 탈출 실현가능).
- **⚠️ blind 한계**: 전원 Claude 계열(in-family attestation·비-Claude 오라클 미확보). grader-3(적대)가 동종 codex 산출물 DT-2에 관대했을 가능성 배제 못 함 — 조정자 결정레인(코드 구조)으로 보강.
- **per-grader 산출 영속**: 본 파일이 3 grader raw verdict(단일저자 위장 차단 증거).
