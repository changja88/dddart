# 양판 비교 집계지 — 20260616-2025-weather (claude vs codex · 5차 feedback-007 연결진단)

> EVAL-METHOD §4(두 안 비교 = RUBRIC 적용 사례) + §4.5(과정지표 차분·엔진 양판). **동일 SCENARIO-WEATHER §1·동일 baseline `abee26d`·동일 동결 RUBRIC/FC-GOLDEN·동일 조정자 결정레인·각 3 blind grader.** 결과지: `20260616-2025-weather-claude.md`(@`94e0ea1`)·`20260616-2025-weather-codex.md`(@`008cdb6`).
> **⚠️ comparability 단서**: 두 엔진은 내부 파이프라인(Coordinator 루프·게이트 형태·커밋 관용구)이 달라 **절대값 비교 무의미** — *같은 사건 종류의 차분*과 *동률 시 보조*로만 읽는다. **N=1·인과/우열 단정 금지·시각 충실도 비측정(A1)·소급 FAIL 금지.**

## 1. 산출물 품질 (동일 RUBLIC 57차원)

| | claude(@94e0ea1) | codex(@008cdb6) |
|---|---|---|
| **종합** | **❌ FAIL** | **❌ FAIL** |
| 빌드게이트 BG-1/2 | ✅✅ | ✅✅ |
| 백스톱 55종 | exit 0·blocker 0 | exit 0·blocker 0 |
| flutter test(clean) | +36 green(9파일) | +18 green(4파일) |
| 치명 17 | 13 PASS·**FC-1/2/3 ❌**(SD-2·ST-4·HR-5 ➖N/A) | 13 PASS·**FC-1/2/3 ❌**(SD-2·ST-4 ➖N/A·HR-5 ✅2:1) |
| **FC-1 골든** | ❌ G-7 색 5-distinct(**2:1**·n1 "쌍 구별" 변호) | ❌ G-7 색 5-distinct(**3/3 만장일치**) |
| **FC-2 비-vacuous** | ❌ **M1·M3 vacuous**(M2·M4 RED) | ❌ **M1·M3·M4 vacuous**(M2·M5 RED) |
| **FC-3 negative** | ❌ N4 색 공유(2:1) | ❌ N4 색 공유(3/3) |
| TIER-Q(기록용) | 8 PASS·1 WEAK(Q-7)="상" 상당 | 8 PASS·1 WEAK(Q-7)="상" 상당 |

### 품질 차분 해석 (우열 단정 아님)
- **공통 치명 FAIL = FC-1·FC-2·FC-3 (양엔진 동일 3게이트).** 둘 다 구조·타입·계층·에러 2채널·Either 계약은 견실(치명 13 PASS).
- **🔴 동일 색 충돌(핵심 교차 발견)**: **양 엔진 모두 `listIconColor`에서 clear=cloudy=`secondaryContainer`(#FEAE2C) 동일** → G-7/N4 FAIL. 서로 다른 엔진이 **같은 결함을 독립 산출**. 둘 다 같은 Stitch 프로젝트(`2284872291805682410`)의 제한 팔레트(렌더 색)에 연결됨. → **결함의 원천이 엔진이 아니라 코퍼스/팔레트 쪽임을 시사**(feedback-008·아래 §4).
- **FC-2: codex가 더 vacuous** — claude는 M4(내비 날짜) RED(포착)였으나 codex는 M4도 GREEN(헛). codex의 "탭→상세" 테스트가 상세 날짜를 `findsWidgets`로 단언 + detail fake가 날짜 무관 하드코딩 → 주간화면 잔존 날짜텍스트에 흡수돼 오검출. **양엔진 공통: M1(정렬)·M3(기온 위치) vacuous.**
- **FC-1/FC-3: codex가 더 명확한 FAIL** — codex 테스트가 색 충돌을 *명시 단언*(`clear.listIconColor==secondaryContainer` AND `cloudy…==secondaryContainer`·테스트명은 "distinct")=**디코이 테스트** → grader 3/3 FAIL. claude는 2:1(n1이 (아이콘,색) 쌍 구별로 PASS 변호).
- **isShow 처리 = claude 우위(비치명)**: claude는 G2 규율감사에서 **isShow 소비**를 반영(DT-3·에러 표시 정책). codex는 view `_errorMessage`가 isShow 미검사·msg 무조건 표시(adv 변종③). claude의 discipline 감사 리듬이 이 의미 흠을 잡아 고침.
- **구조 차이**: claude=단일 BC 단일 애그리거트(HR-5 N/A). codex=단일 BC **2 애그리거트**(weekly 집계·daily 단건 read-model·HR-5 2:1·adv가 daily 빈혈 이견·실질성 관문 PASS).

## 2. 과정 지표 (§4.5 차분·절대값 아님·comparability 단서)

| 지표 | claude | codex | 차분 해석 |
|---|---|---|---|
| 슬라이스 | 3(tracer+토대 / 목록 / 상세) | 3(tracer / model / view) | **동률** — 둘 다 tracer 선행 3분할 |
| 교정 사이클(G2) | 1 = **규율 감사**(isShow 소비·죽은 토큰) | 1 = **백스톱 blocker**(구조) | 동수(1)·**종류 다름**: claude=의미감사(discipline-reviewer)·codex=결정백스톱 |
| 커밋 입자 | 1커밋/슬라이스 | 2커밋/슬라이스(Implement+Mark)+plan/remediation 별도 | 엔진 관용구 차이(품질 신호 아님) |
| 파일/라인(abee26d 대비·as-graded 근사) | 93파일 +12593 | ~102파일 +14251 | codex 약간 큼(2 애그리거트·세분 파일·section 3개) |
| 산출 테스트 | 9 파일 +36 | 4 파일 +18 | claude 테스트 파일/케이스 多(단 FC-2 vacuity는 양쪽·수≠비-vacuity) |

> **동률 시 보조 신호**: 산출물 품질이 *양쪽 FAIL로 동률*이라 과정지표로 우열을 가르지 않는다. 다만 **claude의 규율 감사 1회가 isShow 의미 흠을 잡았고(codex는 미포착)**, codex의 교정은 백스톱 구조 blocker였다 — 같은 "1 교정"이라도 *포착 계층*이 달랐다(의미 vs 결정). 인과 단정 금지.
> *(claude 런폴더엔 채점 후 modify 2커밋[요일 월/일 표시·시안 충실]이 추가됨 — 5차 채점 대상 밖·비교 제외.)*

## 3. feedback-007 연결 진단 (프로세스 관측·양판 모두 5/5 성공)

| 관측점 | claude | codex |
|---|---|---|
| ① 출처 해소·핀 | ✅ `design_source` 핀 | ✅ 동일 프로젝트 핀 |
| ② design-ref 산출 | ✅ designtheme+화면HTML/png+design.md+tokens | ✅ +notes.md(codex 이미지 보조) |
| ③ has_design_tokens/has_stitch_html | ✅ true/true | ✅ true/true |
| ④ foundation 실유입 | ✅ secondaryContainer=#FEAE2C | ✅ primary=#005DA7·secondaryContainer=#FEAE2C(**렌더 색**·브랜드seed 아님) |
| ⑤ Stitch **쓰기 0회** | ✅ 읽기 3(get_screen×2·list_projects×1) | ✅ 읽기 3(list_projects·get_project·list_screens) |

> **양 엔진 모두 읽기전용 소프트락 HELD(쓰기 0)**·디자인시스템 실소비. 읽기 *도구 구성*만 차이(claude=get_screen·codex=list_screens/get_project) — 둘 다 화면 HTML 확보·쓰기 0. **연결 목표는 양판 공히 달성.**

## 4. 교차 결론 (양판이 가리키는 것)

1. **색 구별 회귀 = 엔진 무관·코퍼스/팔레트 기인 시사** — 2/2 연결런이 **동일** clear=cloudy=#FEAE2C 충돌. 제한된 Stitch 의미색 슬롯(6 미만)이 양 엔진 coder 모두에서 색 재사용을 유도(N=1×2·인과 단정 금지·동시발생). → **feedback-008**: 골든/RUBRIC에 *색 구별 판정단위 명문화*("색 단독 6 distinct" vs "(아이콘,색) 쌍")·design-ref 산문 색-의미 규칙 준수를 측정 차원으로 둘지 결정.
2. **FC-2 비-vacuity = 양엔진 공통 미닫힘** — M1(정렬 순서)·M3(기온 위치)이 양쪽 vacuous, codex는 M4(탭 날짜)까지. 행위검증 게이트(TG·feedback-006)가 *값/위치/순서 단언*을 강제하지 못함. codex는 **디코이 테스트**(충돌을 정답 단언)로 더 악화. → **feedback-008**: 골든을 두드리는 단언 형태(순서·위치·날짜 echo)를 coder 테스트 게이트에 명문화.
3. **연결 목표(feedback-007) = 양판 달성** — 쓰기 0·토큰 추출·design_source 핀·실소비 전부 ✅. rubric FAIL의 원인(FC-2 vacuity·색 충돌)은 **feedback-007 처방 밖**(테스트 비-vacuity·색 판정단위 = feedback-008 트랙·연결 무관).
4. **시각 충실도는 비측정(A1)** — claude의 채점 후 modify("요일 월/일 표시")는 *시안 충실* 개선이나 rubric 비측정. 양판 시각 일치는 인간 오라클(사용자 `flutter run`).

## 5. 한 줄 요지

**양판 공히 ❌ FAIL — 동일 3 FC 게이트(FC-1 색충돌·FC-2 vacuity·FC-3 N4)**, 치명 13은 양쪽 PASS(구조·계약 견실). **결정적 교차 발견 = 양 엔진이 같은 Stitch 제한팔레트에서 *동일* clear=cloudy 색충돌을 독립 산출** → 결함 원천이 엔진 아닌 코퍼스/팔레트(feedback-008). 과정은 둘 다 3슬라이스+1교정(claude=규율감사[isShow 포착]·codex=백스톱blocker·codex M4까지 vacuous+디코이 테스트로 FC-2 더 악화). **feedback-007 연결 목표는 양판 모두 5/5 달성**(쓰기 0·실소비). 우열 단정 금지·N=1·시각충실도 비측정.
