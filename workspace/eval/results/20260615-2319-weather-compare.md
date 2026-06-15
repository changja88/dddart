# 부록 — 양판 비교 집계지 (20260615-2319-weather · claude vs codex)

> EVAL-METHOD v3.1 §4 · §4.5 **엔진 양판 축(A9)** — plan-a/b 칼럼을 `claude`/`codex`로 치환. **작성** 2026-06-15 23:19 · **baseline** `abee26d`(2벌 IDENTICAL) · **코퍼스** `cddfd12`(feedback-005) · **SCENARIO** weather §1 verbatim(양판 동일) · **FC-GOLDEN** `tools/FC-GOLDEN-WEATHER.md`(공통).
> **comparability 단서**: 두 엔진 파이프라인 상이 → *절대값 비교 무의미*·**차분·동률 시 보조 신호로만**. **⚠️** N=1·인과 단정 금지·비-Claude 오라클 0(A3)·디자인 충실도 비측정·E3 미발동. 개별 결과지: `20260615-2319-weather-claude.md`·`-codex.md`·grader raw `-graders-raw.json`.

## A. 산출물 품질 차분

| 항목 | claude | codex | 우세 | 비고 |
|---|---|---|---|---|
| **종합 판정** | ❌ FAIL | ❌ FAIL | 동률(둘 다 FAIL) | 하나라도 치명 FAIL이면 그 안 FAIL |
| **치명 게이트(17) PASS 수** | 16 PASS / 1 FAIL(FC-2) | 14 PASS / 3 FAIL(FC-1·2·3) | **claude**(치명 결함 1<3) | NA 제외 실판정 기준 |
| TIER-Q 등급 | 기록용(치명FAIL·미도달·Q전수 PASS) | 기록용(치명FAIL·미도달·Q전수 PASS) | 동률 | §3 step4 |
| **차원별 ❌ 목록** | FC-2 / (VW-4 🟡 1grader) | FC-1·FC-2·FC-3 / ST-5❌ / SD-9·SD-3·ST-8·DT-6 🟡 | claude(비치명 흠도 적음) | 어느 축에서 갈렸나 ↓ |

**갈림의 축(대칭 결함·2차 패턴 반복)**:
- **claude**: FC-1 골든 8/8·구조·ST-2·@riverpod 코드젠 청결 / **테스트가 더미 스모크 1개(FC-2)**. "잘 짜는데 검증을 안 짠다."
- **codex**: 백스톱 0·테스트 27개·도메인 풍부 / **날짜 오름차순 정렬 전면 누락(FC-1·2·3)** + 수동 riverpod 2.x(ST-5)·enum 역전(SD-9). "많이 짜는데 핵심 행위 1개를 빠뜨린다."

## B. 과정 지표 차분 (차분만 — 절대값 아님·부분 측정)

| 지표 | claude | codex | 차분(claude−codex) | 비고 |
|---|---|---|---|---|
| 변경 파일(lib) | 64 | 85 | −21 | codex section 8개 등 더 세분 |
| abee26d 대비 커밋 | 8 | 12 | −4 | |
| 테스트 파일 | 1(스모크) | 10(+widget_test=11) | −10 | 단 codex 5 red=환경/하니스 |
| provider 형태 | @riverpod 코드젠 | 수동 riverpod 2.x | — | claude 표준 정합 |

> coder 호출·토큰·반송·재방문 상세는 이번 회차 transcript 미추출(부분 측정). architect·리뷰어·tracer 차분 미산정. **둘 다 FAIL이라 과정 지표는 판정 보조 아님**(품질 동률 시만 의미·여기선 품질이 FAIL로 동률이나 치명 *수*가 claude 우세라 과정 미적용).

## 판정 (EVAL-METHOD §4.3)

- **산출물 품질 우열**: **양판 모두 ❌ FAIL** — 우열 단정 아님(N=1). 단 *치명 결함 수*는 claude 1 < codex 3, *비치명 흠*도 claude<codex로 **claude가 덜 무너짐**(인과 아닌 관측). 둘 다 종합 무가치 판정은 동일.
- **동률 시 과정 지표**: 품질이 FAIL 동률이나 치명 수 차이로 질적 해석 — claude=검증(테스트) 단일 공백, codex=핵심 행위(정렬)+토대(riverpod 2.x) 복합. 과정지표는 보조 미적용.
- **N=1**: 인과 단정 금지(codex 1차 PASS→2·3차 FAIL이 코퍼스 부작용인지 런 비결정성인지 단정 불가). 보조 S2·반복 런으로 보강.

## feedback-005 검증 결론 (본설계 §6 대체 — 엔진 양판이라 슬라이스 분할 N/A)

| 목표 | 예상효과(사전등록) | 3차 실측 | 판정 |
|---|---|---|---|
| 목표2 타입강제(E2) | BC국소 analysis_options+always_specify_types로 생략 0 | 양판 analyze "No issues found!"·타입 전면명시 | ✅ **검증됨** |
| 목표3 view 차단 | backstop NM17이 view 위젯·top-level Widget 함수 차단 | 양판 NM17 0 발화 | ✅ **검증됨** |
| 목표1 Stitch(E3) | design-ref 동결→extract_design→design-tokens 소비 | 양판 design-ref 0파일·미연결·자체 설계 | ❌ **미발동(4런 연속)** |

**1차→2차→3차 추세**: claude FAIL(FC-2)→FAIL(FC-2+ST-2)→**FAIL(FC-2 단독·ST-2 교정)** / codex PASS→FAIL(G-8라벨+백스톱5)→**FAIL(FC-1·2·3 정렬·백스톱0·G-8교정)**. → **양판 직전 치명은 해소**(claude ST-2·codex 백스톱5→0·G-8 한글)되나, **feedback-005가 안 겨냥한 치명**(claude 테스트·codex 정렬)이 종합 FAIL을 유지.

**커맨드/코퍼스 결함 발견분(후속 교정·006 후보)**:
1. coder 골든-두드림 테스트 산출 게이트(claude FC-2 1·2·3차 지속·feedback-004 미구현).
2. 정렬/핵심행위 책임 명시 + FC-2 순서 단언(codex FC-1·N2·0214부터 미해결).
3. codex `@riverpod` 코드젠 강제(ST-5·riverpod 2.x 토대).
4. E3는 코퍼스 아니라 **런 절차(Stitch 연결)**가 선결 — 4차 라이브런.

## 한 줄 요지

feedback-005 후 3차 양판 = **둘 다 ❌ FAIL**(2차 비대칭 패턴 반복). **겨냥축(타입 E2·view NM17) 검증됨** + 직전 치명 해소(claude ST-2·codex 백스톱5→0·G-8)했으나 **겨냥 밖 치명 잔존**: claude=골든 테스트 부재(FC-2 단독·구조/기능은 견고), codex=날짜 오름차순 정렬 전면 누락(FC-1·2·3)+수동 riverpod(ST-5). **목표1 Stitch(E3) 4런 연속 미연결로 미발동**. 코퍼스가 green을 *테스트·핵심행위 정확성*으로 잇는 게이트가 여전히 부족.
