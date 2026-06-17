# grader 패널 raw verdict — 20260616-2025-weather-claude (A3 blind 증거 영속)

> EVAL §2.0·§2.2. 의미 grader 3명(n1·n2 표준 + adv 적대) 독립 blind 채점. 조정자 결정레인(백스톱·analyze·mutation) 결과 **미수령**·각자 코드 정독. **비-Claude 오라클 0 — 전원 동일 계열(A3 독립성 미확보·헤더 ⚠️).** 색 충돌 사실을 조정자가 grader에 *알리지 않음* → 3명이 독립 발견(아래). 아래는 각 grader 최종 verdict 요지(전문은 채점 세션 transcript).

## 산출물 (BC=weather · pkg `smaple`)

### n1 (표준)
- **치명 16 ✅ / FC-2 ⚠️(M1 미커버)·FC-1·FC-3 = 색충돌 신고하되 비FAIL(쌍 구별).** SD-1✅(읽기전용·판정 0건이 정합·VM 변환만 `weather_list_vm.dart:22-26`)·SD-7✅·ST-1✅·ST-2✅(build throw→AsyncError·valueOrNull 0)·DT-1✅(Left=throw 전달 no-op 아님)·DT-2✅(safeApiCall 단일출구)·HR-4✅·VW-1/6✅.
- **G-7**: 아이콘 6 distinct·**listColor 5 distinct(clear=cloudy=secondaryContainer)** — 문자 그대로면 색 6 distinct 미달이나 (아이콘,색) 쌍 6 distinct로 *구별됨* → FC-1 FAIL로 단정 안 함(미관은 비측정). cloudy↔overcast(N4 명시 케이스)는 색·아이콘 모두 별개.
- **FC-2**: M2/M3/M4/M5 red 가능 단언 존재하나 **M1(정렬 역전) 두드리는 단언 0개**·정렬 로직 부재로 주입 사이트도 死 → 목록 순서 차원 입증 공백.
- A13: ① G-7 "색 distinct" vs "(아이콘,색) 쌍" 기준 모호 ② 서버-순서 의존 정렬의 비-vacuity 구조적 미닫힘 ③ ST-8 retry가 `ProviderContainer`(ProviderScope 아님)·기능 동등·문구 회색지대.

### n2 (표준)
- **FC-2 ❌(M1·M3 vacuous)·FC-1 🟡(G-7 literal 위반)·FC-3 🟡(N4)·그 외 견실.** 치명 규칙면(SD/VW/ST/DT/HR) 전수 인용 PASS. ST-3✅(error 필드 부재는 액션 0건 도메인서 정당·죽은 필드 회피)·DT-3✅(신규 BadReq 정의)·DT-4✅(엔티티 직반환)·VW-7✅(date 서버 원형 String·인라인 직렬화 0).
- **G-7 색**: `listColor` 5 distinct(clear=cloudy=`secondaryContainer` `condition_ui_extension.dart:55·58`)·골든 "색 6 distinct" 위반 신고. design.md:102-103은 cloudy=Cool Grey 규정인데 구현 orange = design-ref와도 어긋남(N4).
- **FC-2 vacuity**: 목록 *순서* 단언 0·기온 *위치* 단언 0(`textContaining('28°')` findsWidgets = 존재만·M3 swap 시 `19°/28°`도 매칭) → M1·M3 red 불가 강한 우려. 아이콘/색(M2)·내비(M4)·지표(M5)는 red 가능.
- **BG-1 결정레인 확인 권고**: 테스트 `overrideWith2`(riverpod 3.x family override) API명 컴파일 확인(틀리면 테스트 컴파일 실패→FC-2 실행 불가). → *조정자 실측: build_runner+test green, API 실재 확인*.
- A13: ① G-7 판정단위(색 단독 vs 쌍) 명문 부재 ② design-ref 산문 색-의미 규칙 위반이 A1 비측정에 빠짐 ③ FC-2 주입사이트 부재(서버 의존) 케이스 처리.

### adv (적대)
- **FC-1 ❌ + FC-2 ❌ + FC-3 ❌ (치명 FC 3종 동시 FAIL) / 그 외 치명 PASS.**
- **FC-1**: G-1❌(정렬 코드 전무·서버 우연 의존·shuffled 입력 시 첫 항목 D2)·**G-7❌(색 5 distinct·clear==cloudy==secondaryContainer `condition_ui_extension.dart:55-58`·`app_color.dart` `Color(0xFFFEAE2C)`)**·G-2~6·G-8 ✅.
- **FC-2**: M1 살릴 사이트 부재(`grep sort|compareTo|sorted` exit 1)+G-1 두드리는 widget test 0개(`_sample` 이미 오름차순·순서 미단언) → EVAL §2.3 "골든 두드리는 widget test 0개=즉시 FAIL".
- **FC-3**: N2❌(정렬 미보증)·N4❌(clear/cloudy 동색)·나머지 ✅.
- **자백 테스트 지적**: `condition_ui_extension_test.dart:16-23`가 구별성 척도를 "색 단독"→"(아이콘,색) 쌍"으로 재정의(`combos.length==6`)해 골든 통과시킴 = Goodhart.
- **디코이 음성 확인**: Left no-op·빈혈 wrapper·신호버스·함수형 provider 위장·show() 우회명 전부 **무혐의**(정직 PASS 인정). SD-1·ST-1·ST-2·DT-1·DT-2·HR-1·HR-4·HR-5·VW-1·VW-6·SD-7 인용 동반 진짜 PASS.
- A13: ① "서버 순서 유지" 게이트 양면성(코드 보증 vs 서버 보증) ② 색 구별성의 측정 레인 경계(코드상 토큰 동일성은 결정 가능·A1과 별개) ③ RootView 死진입점.

## κ·split 요약

| 차원 | n1·n2·adv | 조정자 판정 | 근거 |
|---|---|---|---|
| **FC-2**(치명) | ⚠️❌❌ | **❌ FAIL** | 결정레인 mutation: **M1 GREEN(vacuous)·M3 GREEN(vacuous)** — 필수 2종 헛 / M2·M4 RED. 만장일치 방향(M1 입증 공백). |
| **FC-1**(치명) | ✅🟡❌ | **❌ 보수 FAIL+인간큐** | G-7 색 5-distinct(clear=cloudy). adv 줄인용 FAIL·literal golden·task "색으로 구분" 위반·design.md cloudy=grey 의도와도 어긋남. **n1 변호=아이콘 6-distinct·쌍 구별(소수 PASS)**. G-1은 PASS(런타임 서버 오름차순·게이트 "서버 순서 유지"). |
| **FC-3**(치명) | ✅🟡❌ | **❌ 보수 FAIL+인간큐** | N4 색 공유(clear=cloudy)·N2는 FC-2 귀속(서버 오름차순이라 런타임 미발현). 동일 색충돌 근거. |
| 치명 PASS 13(SD-1·SD-7·VW-1·VW-6·ST-1·ST-2·ST-4➖·DT-1·DT-2·HR-1·HR-4·HR-5➖·BG-1·BG-2) | ✅✅✅(인용 동반) | PASS | adv 디코이 전수 반증·만장일치. SD-2·ST-4·HR-5 ➖N/A. |
| SD-1 빈혈/디코이 | ✅✅✅ | PASS | 읽기전용 판정 0건 정합·VM 변환만·빈 wrapper 아님. |

> **만장일치 아님(FC-1/FC-3 2:1 split·FC-2 방향 일치)** — per-grader 산출 동반(단일저자 위장 아님). 비-Claude 오라클 0(A3·헤더 ⚠️). **색 충돌은 조정자 미고지였음에도 3명 전원 독립 발견** = blind 건전성 방증.

## rubric 사각 신고 (A13 — 채점 미산입·다음 동결 입력)

| grader | 내용 |
|---|---|
| n1·n2·adv | **G-7 색 distinct 판정단위 명문 부재** — "색 집합 6 distinct"(골든 문언) vs "(아이콘,색) 쌍 6 distinct"(산출물 채택) 중 무엇이 바인지 RUBRIC/golden에 미명시. 차기 동결서 명확화(→ feedback-008 후보). |
| n2·adv | **design-ref 산문의 명시적 색-의미 규칙 위반이 A1(시각충실 비측정)에 빠짐** — design.md가 cloudy=Cool Grey로 규정한 *코드 대조 가능한* 규칙을 구현이 어김(orange). "산문 색-의미 규칙 준수"를 측정 차원으로 둘지 검토. |
| n1·adv | **"서버 순서 유지" 게이트의 비-vacuity 구조적 미닫힘** — 정렬을 서버에 위임하면 코드에 주입 사이트가 없어 FC-2가 순서 회귀를 구조적으로 못 잡음(4·5차 반복). |
