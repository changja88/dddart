# fix 018 — FC-2 매핑 정확성 FORM 신설 (M2 vacuous 종결)

> 사전등록형. 예상효과를 *고치기 전* 박고 16차 결과지로 실측 대조(EVAL §자기보고 불신).

## 메타
- **회차**: 018
- **트리거**: `results/20260623-0322-weather-claude.md`(FC-2 vacuous 치명 FAIL·M2 매핑 swap 주입 시 17/17 green) + `-compare.md` + `-graders-raw.md`(조정자 M2 실주입 green 확증)
- **베이스 코퍼스**: `06a30ff`
- **시술 커밋**: `7c28c13`(처방)·`615796a`(결과지)
- **검증 런**: 16차(`dddart-20260623-1331`·결과지 `20260623-1331`)
- **상태**: **검증됨**(✅ 적중 1/1 — claude M2 red·15차 vacuous 해소)

## RCA 요약 (본세션 4렌즈 적대검증)
- **회귀 판별**: FC-2 vacuous는 **12차 동형 재발**(13·14차 자발 PASS 후 15차 재발). git 증거로 13→15차 코퍼스 매핑 불변·feedback-014가 3회 "FC-2 미시술" 명시 → 13·14차 PASS = N=1 자발(처방 아님).
- **★직접 증거**(렌즈 B): 13·14차 산출물엔 `weather_condition_ui_extension_test.dart`에 case별 매핑 6종 전수 단언 실재 → M2 swap red. **15차엔 그 ui_extension 테스트 파일이 통째 누락**(매핑 단언 0·fromJson 파싱만) → M2 green=vacuous.
- **근본**: discipline-test §3에 M1(§3.2)·M3(§3.3)·M4(§3.4) 직격 FORM은 있으나 **M2(enum→아이콘/색 매핑 정확성) 직격 FORM만 부재**. §3.1 distinctness(집합 크기)는 두 case swap에 집합 크기 불변이라 M2를 *구조적*으로 미포착 → 매핑 단언이 엔진 자발에 노출돼 출렁임(회귀).
- **렌즈 A 정밀화**: G-7 골든 06-20 개정(구별=아이콘∨색 완화)으로 매핑 *정확성*이 FC 책임 공백 → 처방에 "FC-2 비-vacuity ≠ G-7 distinctness ≠ FID 미관" 3축 독립 명문화 포함.

## 교정 항목 (사전등록 — ①~④ 고치기 전 / ⑤~⑥ 16차 후)

| # | 우선 | ① 대상 결함(dim·FC골든) | ② 원인(뿌리·코퍼스 공백) | ③ 처방(파일·미러) | ④ **예상효과**(전→후) | ⑤ 시술커밋 | ⑥ 실측·판정 |
|---|---|---|---|---|---|---|---|
| 1 | ★치명 | FC-2 vacuous(M2 매핑 swap green·`.icon`/`.color`/`byIcon` 단언 0) | discipline-test §3에 매핑 정확성 직격 FORM 부재(§3.1 distinct는 swap에 불변) | discipline-test `final.md` §3.6 매핑 FORM 신설(case별 값 핀·getter 직접·seam A·전수) + line 38 가이드 범위 + `SKILL.md` 4형→5형. **미러**: final.md auto(`corpus_mirror_sync.py --write`) / SKILL.md 양판 수동 | 16차 M2(clear↔thunderstorm icon+color swap) 주입 시 ui_extension 테스트 **red** → FC-2 vacuous FAIL→**PASS** | | |
| 2 | 보강 | §3.1 distinctness N 오해(예제 `values.length`가 N=case 수로 읽혀 G-7 동색 디자인을 red로 오판 잠재) | §3.1 예제가 case 수=N으로 암시·G-7(06-20 cloudy=overcast 동색 4색 허용)과 잠복 충돌 | discipline-test `final.md` §3.1 line 53에 "N=골든 고유값 수≠case 수·값 묶이면 작아짐" 한 문장(범용·매핑은 §3.6 cross-ref). 미러 final.md auto | **측정 근거 없음(예방적·미발현 잠복)** — FC-1/3·distinctness 현 PASS 유지·G-7 오판 차단(claude 이미 length==4 적응) | | |

- **비-과적합 가드**: FORM 규율 진술은 "분류 enum→표시값(아이콘·색·라벨) 매핑"으로 범용. weather/condition/6종은 예제 코드블록에만(§3.1~§3.4 작성 본받음). "6종"·"condition"을 *규율*로 박지 않음 → 어느 분류 enum이든 swap red.
- **G-7 정합**(렌즈 A): 매핑 FORM은 FC-2 비-vacuity(테스트가 매핑을 *두드리는가*)를 닫음 — distinctness(§3.1·G-7 아이콘∨색 구별)·FID 미관(인간 오라클)과 **독립 축**으로 명문화(서로 대체 불가).
- **짝 규약**: 불요(getter 직접 호출·위젯 미펌프). keyed-slot(§3.3)과 달리 생성측 Key 부착 없음 — ui_extension 거주가 architecture-ui §5·discipline-test §3.1 line 55로 이미 정당.
- **renumber 회피**: §3.1~§3.5 번호 무변(외부 참조 implementation-test 9·architecture-ui 2·SKILL 2 갱신 0). §3.6 비파괴 추가 + 본문 교차참조로 §3.1과 의미 연결.
- **#2 발견 경위**: 소비성 게이트 렌즈2(정합 적대)·RCA 렌즈A(G-7 정밀화)가 독립 **이중 지목**. §3.6은 자기완결로 게이트 통과했으나, G-7 완화 뿌리(매핑 정확성 모호)를 §3.1 예제 수준까지 닫음. measure-first상 미발현 잠복이라 예상효과는 예방적(겨냥 dim 없음·헛처방 조기경보 표기).

## 보완 시술 (적대 리뷰 후·2026-06-23)

사용자 요청 4렌즈 적대 리뷰: **A 전코퍼스 정합 COHERENT · B 실효성 ★WEAK · C 회귀안전 SAFE · D 소비일관 CONSISTENT**.

- **★렌즈 B 발견(강제력 갭)**: 15차 실패는 *약한 단언*이 아니라 **매핑 테스트 파일 통째 부재**였다. 그런데 1차 시술이 지식 본문(`discipline-test/{SKILL.md,final.md}`)만 5형으로 고치고, 강제력 길목 — `coder.md:35`(필수 산출)·`discipline-reviewer.md:92`(§8 감사)·backstop TG1(`*_test.dart` 임의 1개면 통과) — 은 **4형/존재만**이라 "반드시 써라"를 못 닫았다. → 매핑 테스트 작성이 여전히 엔진 자발(13·14차 자발 PASS 반복 위험). 메모리 ★교훈 "coder.md 로드 스킬 확인 필수"와 동형 함정.
- **보완 시술**: ① `coder.md`·`discipline-reviewer.md` FORM 열거에 **매핑 5형 추가**(양판·강제력 동급화) ② reviewer §8에 "분류 enum 매핑 테스트 *부재*(파일 누락)=vacuity·important" 감사 신호 ③ §3.1 **gate 경화**(N 낮추려면 골든 *명시* 필요·5차 미의도 충돌 묵인 차단·렌즈 C/D) ④ §4 "getter" **동음 분별**(매핑 getter=case→값 결정·§3.6 대상·렌즈 A).
- **backstop 기계 게이트(매핑 존재 강제)**: 오탐 위험 검토 필요로 **measure-first 보류** — coder 의무+reviewer 감사로 먼저 닫고 16차 실측 후 필요 시 승격.
- **잔여 선택 위생(미적용·충돌 아님)**: implementation-test §2 seam A 열거에 §3.6 상호참조 추가(렌즈 A).
- **미러 파일(8)**: `discipline-test/{final.md,SKILL.md}`×2(claude·codex)+소스 · `coder`(claude `agents/coder.md` ∥ codex `dddart-coder/SKILL.md`) · `discipline-reviewer`(claude `agents/` ∥ codex `dddart-discipline-reviewer/SKILL.md`). 양판 byte-diff IDENTICAL·mirror in-sync 검증.

## 회차 요약 (16차 후)
- 예상 적중 **1/1** · 무효 **0** · ⚠️역효과 **0**
- **한 줄 결론**: claude가 §3.6 매핑 정확성 FORM(B3·B4 case별 값핀 + distinct)을 채택(`weather_condition_ui_extension_test.dart`)·조정자 M2(clear↔thunderstorm 아이콘 swap) 주입→**매핑 테스트 red**(distinct 3건은 swap이라 green = §3.6 표적 정확: distinct 못 잡는 swap을 값핀이 잡음). **15차 vacuous(매핑 테스트 파일 부재)→16차 비-vacuous·claude FC-2 FAIL→PASS 역전.** 강제력 길목 보완(coder/reviewer FORM 5형)이 매핑 테스트 *파일 작성* 유도(15차 부재→16차 존재). codex도 case별 `_ExpectedConditionUi` 값핀·M2 red(양판 견고).
- ⚠️ N=1 인과 단정 금지 — "018이 M2 red를 *유발*"이 아니라 "018 적용 후 16차 M2 red 관찰(동시발생)". 자발 해소(13·14차)처럼 엔진 변동 가능성 상존. ★강제력 길목(coder:35/reviewer:92)까지 닫은 것이 15차 파일 부재 재발을 막은 핵심(렌즈 B 보완 적중).
