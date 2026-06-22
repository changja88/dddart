# grader 패널 raw verdict — weather 14차 (codex·claude 양판)

> `EVAL-METHOD §2.0·§2.2` blind 검증가능화. per-grader raw verdict 영속(주장 아닌 증거). **채점일** 2026-06-22 · **N_grader** 3(의미2+적대1) · **구성** 전원 Claude 계열(Opus) — ⚠️ **비-Claude 오라클 미확보·in-family 독립성 한계**. 각 grader는 blind(타 grader·과거 회차 결과 미참조)·근거 `파일:줄` 인용.

## 패널 구성

| grader | 계열 | 적대 | 담당 축 | subagent_id |
|---|---|---|---|---|
| g1 | Claude(Opus) | 아니오 | SD-1~9·ST-1~9 (DDD·State) | a351b80df6704b832 |
| g2 | Claude(Opus) | 아니오 | VW-1~7·DT-1~9·HR-1~9 (View·Data·HR) | af94e14ca9434d285 |
| g3 | Claude(Opus) | **예(적대)** | 치명16 반증·FC-1/2/3·형상 축 | ab7d45d462fc3d0df |

## ★차원별 κ (일치율) — DT-2 3중 합의가 핵심

| 차원 | g1 | g2 | g3 | 조정자 정독 | κ | 비고 |
|---|---|---|---|---|---|---|
| **DT-2 claude** | — | ❌FAIL | ❌FAIL(반증성공) | ❌FAIL | **만장일치 FAIL** | safe_api_call.dart:20 fromJson 무가드 |
| **DT-2 codex** | — | ✅PASS | ✅PASS(생존) | ✅PASS | **만장일치 PASS** | safe_api_call.dart:60-64 try/on-Object 가드 |
| 나머지 치명(양 엔진) | ✅(SD·ST) | ✅(VW·HR) | ✅생존 | ✅ | 만장일치 | split 0 |
| 형상 축(6컨테이너 양 엔진) | — | — | 전 ✅일치 | 전 ✅일치 | 일치 | g3 시안 HTML 독립 대조 |

> **blind 붕괴 적신호 없음**: DT-2 만장일치가 per-grader 줄인용으로 뒷받침됨(g2·g3 독립 도출·조정자 코드 정독). split 0.

---

## g1 — DDD·State (raw 요지)

**claude**: SD-1~9·ST-1~9 **전 PASS/➖N/A**. 정렬=`weekly_forecast.dart:23` 루트 거주(SD-1)·VM이 UseCase만(ST-1)·build throw→AsyncError(ST-2)·각 VM `_$VM`만 extends(ST-9). 어휘 계층관통 일치(SD-9 PASS).
**codex**: SD·ST 치명 전 PASS. **SD-9 🟡WEAK** — application prefix(`weather_forecast_list`/`_detail`)↔domain 루트(`weekly_forecast`/`daily_forecast_detail`)↔UseCase/Repo(`forecast_*`) 개념 어휘 혼재(약변종·`manage_lounge_post↔lounge_post_manage` 류). **SD-4 우위** — `ForecastDate` @Freezed VO+Comparable(claude는 date=String). retry()=invalidateSelf→채널① 재경유(죽은 채널 아님·view 실배선 `:40-42`).
**의미 변종**: 빈혈 VM 0(양 엔진)·codex retry 정상·ui_extension switch=VW-5(도메인 판정 아님).
**사각 신고**: ① SD-9 화면 prefix↔domain 루트 drift carve-out 미명시(WEAK 판정 분산 우려). ② re-fetch invalidateSelf의 채널① 귀속 ST-2 미명문. ③ query-only VM에서 error 필드 부재=정상을 ST-2/ST-3에도 명시 권고.

## g2 — View·Data·HR (raw 요지)

**claude**: VW-1~7·DT-1~9·HR-1~9 — **DT-2 ❌FAIL** 외 전 PASS/N/A. VW-4 🟡(생 `Duration(200ms)` press 2건). retrofit 미사용(DT-6 ➖·plain Dio).
**codex**: **DT-2 ✅PASS** 포함 전 PASS/N/A. VW-4 🟡(`Colors.transparent` 리플 1건)·HR-7 🟡(전역 navigatorKey). retrofit @RestApi(DT-6 ✅).

**★DT-2 상세 결론(g2 줄인용)**:
> 공통 전제 — 봉투 3필드 전부 `required`(claude `bad_request_response.dart:15-17`·codex `:9-11`). 4xx 바디가 봉투와 다르면(DRF `{"detail":...}`) `_$…FromJson`이 누락 키 non-null 캐스트하다 throw.
> **claude ❌**: `safe_api_call.dart:17-20` `on DioException` 절 **내부**에서 `BadRequestResponse.fromJson(data)` **무가드** → throw가 형제 `on TypeError`(:36)에 안 잡히고 safeApiCall 밖 탈출(단일출구 누수). grep throw 0이라 결정 PASS·의미 FAIL.
> **codex ✅**: `safe_api_call.dart:60-64` `_tryServerResponse`가 `try { fromJson } on Object { return null }`로 가드 → null 경로(`:40`)→timeout/unknown Left(`:48-52`) 강등·탈출 0.
**사각 신고**: VW-4 "생 Duration" 비례성(press 미세값)·전역 navigatorKey VW-6/VW-7 귀속 미정의·**DT-2 결정 grep 구조적 무력(양 엔진 throw 키워드 0·의미 정독 필수)**·DT-8 계약 동결본 대조 범위 밖.

## g3 — 적대(반증) (raw 요지)

**claude 반증 1건 성공 — DT-2 치명 FAIL**(코드 경로 입증):
> `safe_api_call.dart:17-21` fromJson 무가드 + `bad_request_response.g.dart:11-13` 무가드 `as` 캐스트. **도달성**: 상세 `GET /api/v1/weather/{date}/` OpenAPI 404 정의 → 실서버 404 바디 `{"detail":...}`=Map → `data is Map` 참 → `fromJson` → `null as String` → TypeError → 형제 on절 미포착 → 탈출. **false green 입증**: `weather_repo_test`의 404 테스트가 **바디 없이**(data=null) Response 생성 → `data is Map` 거짓 → 위험 경로 미경유 → green(실서버 바디와 불일치).
**codex 반증 0 — 전 치명 생존**(DT-2 `_tryServerResponse` 가드 확인).
**FC-1/FC-3**: 양 엔진 **PASS**(G-1~G-8 일치·N1~N7 무관측). claude rain=`Icons.umbrella`(precip water_drop과 글리프 분리)·codex 6종 distinct.
**FC-2 vacuity 후보(mutation 지목)**: claude G-4 음수기온 fixture 0·목록 타일 기온 슬롯 단언 0(M3 변종 green 탈출) / codex G-2 "정확히 7" 미강제. M1 정렬은 양 엔진 shuffled 입력=비-vacuous.

**★형상 축 신고표(g3 코드 vs 시안 HTML 독립 대조)**:

| 컨테이너 | claude 코드 | codex 코드 | 시안(design-ref HTML) | 일치 |
|---|---|---|---|---|
| 상세 hero 기온 | Row+baseline(detail_section:87) | Row+baseline(hero_section:46) | `flex items-baseline` | ✅✅ |
| 상세 metric 묶음 | Column(detail_section:40) | Column stretch(metrics_section:19) | `grid grid-cols-1` | ✅✅ |
| metric 카드 내부 | Column>Row(card:49) | Column>Row(card:37) | `flex flex-col`>`items-center` | ✅✅ |
| 앱바 | Row center | PrimaryAppBar(detail_view:24) | `items-center justify-between` | ✅✅ |
| 목록 타일 | Row 3열(tile:74) | Row 3열(tile:46) | `items-center justify-between` | ✅✅ |
| 목록 리스트 | Column(section:47) | Column(content_section) | `flex flex-col` | ✅✅ |

> **형상 = 양 엔진 6/6 시안 일치**(13차 축 회귀 전면 회복). ★최종 측정=사용자 육안이나 g3 grep 보조로 명백한 일치 확인.

**형상 보조 신고(이탈)**: ① **codex image-area 누락**(시안 `<img>` 브로콜리를 claude는 `Image.asset` 렌더·codex 미렌더 = 에셋 회귀). ② bottomnav 미렌더(양 엔진 공통·단일 화면 흐름). FID 셸브드(육안 측정)라 보조 신고.
**사각 신고**: DT-2 codegen `.g.dart` 무가드 캐스트의 catch 내부 2차 throw=백스톱 결정 레인 구조적 불가시(13차 codex·14차 claude 동일 구멍)·G-2 negative-gate 코드 미차단·codex image-area 번들 차이 FID-L1 분기.

---

## 종합 (조정자 합성)

- **DT-2 3중 합의(만장일치)**: claude ❌FAIL / codex ✅PASS — **13차와 완전 swap**. 코퍼스 미규정의 N=1 비결정(엔진 실력차 아님).
- **형상 F**: 양 엔진 6/6 시안 일치(g3 독립 대조 + 조정자 정독) — **14차 시술 표적 양판 동시 적중**.
- **에셋 A**: claude 유지 / codex 회귀(g3 image-area 신고).
- **in-family 한계**: 전원 Claude grader — 비-Claude/인간 오라클 미확보(독립성 구조적 한계·다음 라운드 확보 가치).
