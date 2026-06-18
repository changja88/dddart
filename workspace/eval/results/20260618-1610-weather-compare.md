# 양판 비교 집계지 — 20260618-1610-weather (claude vs codex)

> **방법** EVAL-METHOD v3.2 §4(엔진 양판 비교·A9) · **채점일** 2026-06-18 · **task** SCENARIO-WEATHER §1 동일 verbatim 투입 · **baseline** `abee26d` · **코퍼스(산출)** `a27c357`(feedback-009·양엔진 byte-동일 코퍼스) · **채점 골든** `f3f2b3e`(A13-1 정합) · **⚠️** N=1·인과 단정 금지(엔진 내부 파이프라인 상이·절대값 비교 무의미·*같은 사건 종류 차분*과 *동률 시 보조*로만)·시각 충실도 비측정·비-Claude 오라클 미확보.

## 1. 산출물 품질 — 판정 차분

| | **claude** | **codex** |
|---|---|---|
| **픽스처 판정** | ❌ **보수 FAIL** + 인간 큐 | ✅ **준수(PASS)** |
| 치명 17 | 14 PASS·**FC-2 ❌**·FC-1 🟡인간큐·FC-3 🟡(N/A 3) | **17 전수 PASS** |
| 빌드 게이트 | BG-1·BG-2 ✅ | BG-1·BG-2 ✅ |
| backstop 57 | blocker 0 | blocker 0 |
| TIER-Q | 상(Q 전수)·ST-8 WEAK | 상·Q-1·SD-3 WEAK |
| FC 골든 G-1~G-8 | **G-7 미충족**(7/8) | **전수 일치**(8/8) |
| 적대 grader | "FC-2 FAIL" | **"통과 막을 근거 없음"** |

## 2. 갈림의 본질 — 두 결정적 차이

### ① G-7 (6종 아이콘 distinct) — **codex 우위**
- **claude**: cloudy=overcast=`Icons.cloud`(`weather_condition_ui_extension.dart:21,23`) → **아이콘 5 distinct**(색은 6). 골든 "아이콘 ∧ 색 6 distinct" 문언 미충족. *A1(아이콘 심볼=비측정) 경계라 인간 큐*.
- **codex**: cloudy=`cloud_queue`≠overcast=`cloud`(`:18-27`) → **아이콘 6 distinct**. 골든 충족.
- 두 엔진 모두 동일 design-tokens.json(`partly_cloudy_day→cloud_queue`)를 받았으나 codex만 채택. claude는 색-only 선택.

### ② FC-2 M4 (navigator 날짜 직렬화 검증) — **codex 우위**
- **claude**: navigator 날짜를 +1일로 변이해도 **테스트 green**(조정자 직접). 탭 핸들러는 section 콜백까지만·router는 initialLocation 직접 주입으로 navigator 우회 → G-5의 navigator 직렬화 버그 **미검출**(死검증).
- **codex**: `toApiPath` day를 +1로 변이하니 **list_vm·list_view navigate 테스트 4건 red**(조정자 직접). 탭→navigate end-to-end 검증.
- **같은 골든(G-5)을 codex는 통합 테스트로 두드리고 claude는 안 두드림** — 테스트 seam 설계 차이.

## 3. A13 정합 효과 (이번 런 측정 목표)

| 항목 | 결과 |
|---|---|
| **A13-1(정렬·프롬프트 2326dd0·골든 f3f2b3e)** | ✅ **양쪽 충족** — claude 애그리거트 메서드·codex domain_service+VO에 정렬 거주, 뒤섞은 입력 테스트로 **M1 red 양쪽**. 6차 claude의 "M1 정렬 死+vacuous FAIL"(서버순서 위임)이 **해소**. *정합이 의도대로 작동* — M1이 처음으로 공정한 치명 게이트로 기능. |
| **A13-2(아이콘 distinct 미검증)** | ⚠️ **claude에서 실발화** — `ui_extension` 테스트가 (아이콘,색)쌍만 단언해 아이콘 충돌 합법화(약화 단위형). codex는 아이콘 6 distinct라 미저촉. 다음 라운드 정본화 입력. |

## 4. 과정 산출물 차분 (절대값·인과 금지·차분만)

| | claude | codex | 차분 해석 |
|---|---|---|---|
| git 상태 | **staged 미커밋**(HEAD=baseline) | 7커밋 완료 | claude 파이프라인 커밋 단계 누락(또는 G2 전 종료) — 프로세스 차이(EVAL 비측정·발견 로그) |
| changeset | 92파일 +12755 | 106파일 +13827 | 규모 유사 |
| .dddart 노트 | build-state·design-spec·tokens·scope | **+ review-ddd/ui/state/data·discipline 6종** | codex가 리뷰/감사 노트를 파일로 남겨 **투명**(claude는 내부 처리) |
| 테스트 파일 | 8 | 11 | codex가 use_case·safe_api_call·VO·domain_service 단위테스트 추가 |

> coder 호출 수·토큰·반송 횟수는 라이브런 transcript(사용자 드라이브) 미수령이라 미측정. 위는 *산출물 형태* 차분만.

## 5. 공통 흠 (양쪽)
- **테스트 병렬 flaky** — 전역 싱글톤(claude DioClient.instance·codex rootRouter/rootNavigatorKey) 공유·테스트 간 reset 부재 → `flutter test` 기본 병렬서 비결정 실패(grader 관측)·`--concurrency=1`/단일 실행 green(조정자). **green 빌드 재현성 흠**·RUBRIC 차원 부재(A13 사각·다음 라운드 입력). FC-2 비-vacuity는 무손상.

## 6. 6차→7차 역전 (N=1·인과 단정 금지)
- **6차**: codex 심각(다수 FAIL)·claude는 M1 정렬 死만 잔여("역대 최청정").
- **7차**: **codex 준수 PASS**(치명 17 전수)·**claude 보수 FAIL**(navigator·아이콘 신쟁점). 역전.
- 단 **N=1·엔진 비결정·코퍼스 동일(a27c357 byte-동일)** — "codex가 claude보다 낫다"는 단정 금지. 같은 코퍼스에서 *이번 산출*의 차이일 뿐. A13-1 정합은 양쪽 공통 개선(측정 목표 달성).

## 7. 한 줄 요지
동일 코퍼스(`a27c357`·byte-동일)·동일 task에서 **codex=준수 PASS / claude=보수 FAIL**(navigator 직렬화 死검증 + 아이콘 5 distinct). **A13-1(정렬) 정합은 양쪽 충족**으로 6차 M1 vacuity 문제를 해소(측정 목표 달성). 갈림은 G-7 아이콘·FC-2 navigator seam 두 지점 — 둘 다 codex가 더 견고. 공통 흠은 테스트 병렬 flaky. *N=1·인과 단정 금지·시각 충실도 비측정.*
