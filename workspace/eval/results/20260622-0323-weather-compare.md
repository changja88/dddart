# 양판 비교 집계지 — weather(7일 예보) · claude vs codex · 13차

> **방법** EVAL-METHOD v3.2 §4(양판 비교·§4.5 과정지표) · **채점일** 2026-06-22 0323 · **baseline** `abee26d` · **코퍼스** `8fe3800`(레이아웃 크기연결 + 에셋 공급 v4·feedback-014) · **FC 골든** `FC-GOLDEN-WEATHER.md` · 결과지 `…-weather-{claude,codex}.md` · grader raw `…-graders-raw.md`
>
> ⚠️ N=1·인과 단정 금지 · comparability(두 엔진 내부 파이프라인 상이·절대값 무의미·*같은 사건 종류* 차분·동률시 보조) · **전원 Claude 계열 grader(in-family·비-Claude 오라클 미확보)** · FID 양판 A1 폴백(screenProbes 미노출)

## 1. 산출물 품질 차분 (핵심)
| 축 | claude | codex | 갈림 |
|---|---|---|---|
| 빌드 게이트(BG-1·2) | ✅ ✅ | ✅ ✅(단 순정 test red·dart-define env) | claude ▲(환경무관) |
| **치명 게이트 18** | **18 PASS** | **17 PASS · DT-2 ❌** | **claude ▲** |
| **픽스처 종합** | **PASS** | **FAIL**(DT-2 치명·사전식 종료) | **claude ▲** |
| **DT-2 단일출구** | ✅ fromJson try/catch 가드(`_normalizeDioException`) | ❌ fromJson `on DioException` 내부 무가드→스키마 불일치 4xx 시 누수 | **claude ▲** |
| **FC-2 비-vacuous** | ✅ M1~M4 red(**12차 vacuous 자발 해소**) | ✅ M1~M4 red(풀스택 인터셉터) | =(양판 비-vacuous) |
| FC-1 골든 | ✅ G-1~G-8 전수 | ✅ G-1~G-8 전수 | = |
| State 군더더기 | error 필드 부재(깨끗) | **error 빈사 필드**(미배선 죽은 채널)·isEmpty VM | claude ▲ |
| 설계 모델링 | DailyForecast 단일엔티티(상세 nullable)·정렬 Repo | DailyForecast/Detail 2엔티티(상세 required)·정렬 UseCase·HR-9 2개념 | ≈(둘 다 적법 갈림) |
| baseUrl | 🟡 placeholder `kingdom.example.com`(런타임 미작동·A1) | 🟡 dart-define `API_BASE_URL`(주입 전제·미주입 취약) | ≈(양쪽 baseUrl 흠·성격차) |
| TIER-Q 등급 | 상(WEAK 1: Q-7) | 상 잠정(치명FAIL·WEAK Q-7·dart-define) | claude ▲ |
| **FID 구조** | ➖ A1 폴백 | ➖ A1 폴백 | =(screenProbes 미노출) |

## 2. 판정
**치명 게이트 기준 = claude 우위**(픽스처 PASS vs codex DT-2 치명 FAIL). **12차(codex 우위·claude FC-2 vacuous) 완전 역전.**

- **claude**: 치명 18 전부 통과. **12차 FC-2 매핑 vacuous(치명 FAIL)를 13차 비-vacuous로 자발 해소**(M2 swap red). DT-2 가드 견고. 잔여=baseUrl placeholder(런타임 A1).
- **codex**: **DT-2 단일출구 누수**(safe_api_call fromJson 무가드)로 치명 FAIL. 나머지 치명 PASS·FC-2 견고하나 error 빈사 필드·dart-define 환경 결합·Column 死분기.

→ **13차 갈림의 본질 = *데이터 계약 견고성*(DT-2 단일출구 완전성)이 갈랐다.** 12차는 *테스트 비-vacuity*(FC-2)가 갈랐는데, 13차엔 양판 FC-2 모두 비-vacuous로 수렴(claude 자발 개선)하고 새 변별자로 DT-2가 부상.

> ⚠️ **N=1 단정 금지**: "claude가 항상 DT-2 견고·codex 항상 누수"가 아니라 *이 산출물*에서 그랬다. claude FC-2 자발 개선·codex DT-2 누수 모두 *이 산출물* 한정. ⚠️ **in-family 한계**: 적대 grader(grader-3)가 codex DT-2를 ✅로 봐 grader-2와 split — 조정자 코드정독으로 누수 확정했으나 동종 grader 관대 가능성 배제 못 함.

## 3. 13차 시술 효과 — feedback-014 실측 (measure-first 대조)
| 항목 | 예상효과(사전등록) | claude 실측 | codex 실측 | 판정 |
|---|---|---|---|---|
| **L 레이아웃 크기** | architect triage 출력→coder hero size 시안값·claude 32→120 회복·codex 무변 | triage 11회·**`iconSize=120`**(32→120 회복) | triage 7회·**`detailWeatherIconSize=120`**(유지) | ✅ **적중** |
| **A 에셋 공급** | 다운로드 ok·Image.asset 배선·token=배선·pubspec·has_design_images | weather-list-1.png·배선1·token=배선1·✅·true | list-1.png·배선1·token=배선1·✅·true | ✅ **적중** |

**두 시술 모두 양판 작동 확정.** 12차 "이미지 자리만·hero 크기 퇴행" 해소. 레이아웃 2단(architect triage 출력 / coder size 반영)·에셋 사슬(fetch→manifest→배선) 양 엔진 집행.

## 4. 과정 지표 차분 (§4.5·절대값 아님·보조)
| 지표 | claude | codex | 비고 |
|---|---|---|---|
| 갭원장(+삽입) | 13596 | 14018 | codex 큼 |
| 산출 파일(lib 소스) | 42 | 50 | codex 많음(2엔티티 분리·section 세분) |
| 테스트 케이스 | 37(12파일) | 22(10파일) | claude 많음·**양판 FC-2 비-vacuous**(12차와 달리 개수≠품질 함정 해소) |
| 백스톱 blocker | 0 | 0 | = |
| 마지막 커밋 | 7a9b871(마무리·main 배선 커밋) | 5399e54(finalize·main 배선 커밋) | 양판 main 커밋 정상 |

> 13차는 *동률 아님*(치명 갈림)이라 과정지표 보조. 12차 "테스트 26 vs 20 함정"(개수≠비-vacuity)은 13차엔 양판 모두 비-vacuous라 해소 — claude 37·codex 22 모두 매핑·정렬·내비 두드림.

## 5. 종합 한 줄
**13차 = claude 치명 우위(픽스처 PASS)·codex DT-2 치명 FAIL(단일출구 누수).** **12차(codex 우위·claude FC-2 vacuous) 역전** — claude가 FC-2 vacuous를 자발 해소했고, codex는 safe_api_call fromJson 무가드 누수로 데이터계약 견고성에서 갈렸다. **13차 생성측 시술(feedback-014 L·A)은 양 엔진 모두 작동**(hero 크기 120 회복·에셋 실배선·token=배선). 갈림의 본질 이동: 12차=테스트 비-vacuity → 13차=데이터계약 단일출구 완전성. ⚠️ N=1·in-family·DT-2 split 조정자 확정.

## 부록: 다음 라운드 입력 (사각·fix 후보)
1. **codex DT-2 fix**: safe_api_call의 `BadRequestResponse.fromJson(data)`를 try/catch 가드(claude `_normalizeDioException` 패턴)·`architecture-data`/`implementation-dart` safeApiCall 골든이 "에러바디 파싱도 가드"를 명문화하는지 점검.
2. **screenProbes 봉합**(양판·9차부터 미해결): 코더가 `_support.dart`에 screenProbes 노출 → FID 자동게이트 발동 전제. 13차도 양판 미노출·A1 폴백.
3. **RUBRIC DT-2 사각**: "정규화기 자신(fromJson)이 throw하면 single-exit 깨짐" 명문화(결정 grep throw0이 누수 못 봄·grader-3도 놓침 — 적대 grader 필수커버에 추가).
4. **State 빈사 필드 음성신호**(grader-1 신고): 조회VM의 미배선 error 필드(죽은 액션채널 스캐폴딩) 검출.
5. **레이아웃 상수 거주 갭**(grader-2 신고): bare `size:`/`width:` 매직넘버가 VW-4(색·타이포만)·FID(구조만) 사이 사각 — hero 외 카드 폭 토큰화 미검.
6. **claude baseUrl placeholder·codex dart-define**: 양쪽 baseUrl 흠 — 환경 결합 방식 골든(`implementation-flutter`/data) 점검.
