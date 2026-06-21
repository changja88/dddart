# 레이아웃 강제 — 설계 명세 v2 (2026-06-21)

> **상태**: brainstorming 확정 + **4렌즈 적대 리뷰 반영(v2)**. 다음 = 사용자 스펙 리뷰 → 승인 시 writing-plans/시술(별도 승인·양판 미러·다음 런 동결).
> **근거**: 자료조사 보고서 `workspace/design/2026-06-21-layout-asset-research.md` + 적대 리뷰 `wf_293ad0a7`(4렌즈 concerns·메커니즘 정합 확인·blocking 4 교정).
> **불변 제약**: 양판 미러·과적합 금지(weather 픽셀·**런 번호 서사** 코퍼스 금지)·measure-first·HaffHaff 치수 강제 모방 경계·layout-ir 픽셀 미포함 불변 보존·brainstorming HARD-GATE.
> ⚠️ **모든 코퍼스 라인 번호는 리뷰 실측 시점 기준 — 시술 시 grep(앵커 문구)으로 재확인 필수**(Track B `480eb11` 이후 드리프트 가능).

---

## 1. 목적·범위

- **목적**: 12차 UI 크기 충실도 퇴행(hero 상태 아이콘 시안 120 → claude 32px) 회복. 근본 = 생성측에 "추출된 크기를 분해한 조각에 연결하는 size-link"가 없다.
- **핵심 진단(리뷰 정밀화)**: 12차에 claude가 area는 충실(area 토큰 19회)했고 크기는 흘렸다. 차이 = **area엔 "정형 출력 강제"(area 어휘 트리)가 있었고 크기엔 없었다**. 즉 흘림의 원인은 "산문 점검이라서"가 아니라 **"정형 출력 강제가 부재해서"**. → 크기에 같은 정형 강제(triage 블록)를 주면 area처럼 충실해질 것(결정 6=C의 근거).
- **범위(1차)**: 레이아웃 강제(크기 연결)만. 에셋(Track A)·크기 자동 게이트(린터 포함)는 **범위 밖**(§8 후속).
- **N=1 단일변수**: 레이아웃만 시술. 단 측정은 **2단 분리**(architect 출력 / coder 반영)로 어느 단계가 흘리는지 격리(결정 9).
- **성격**: 분해는 상태 축(VM 보유/전속/재사용) 그대로. 크기 연결을 **직교로 얹는다**.

## 2. 확정 결정 (brainstorming + 적대 리뷰 반영)

| # | 결정 | 값 |
|---|---|---|
| 1 | **단위** | **발명된 픽셀 금지·추출된 값 인용은 허용** — 단일 사용처 = 추출값 직접 인용(size prop), 여러 곳 재사용 = foundation 토큰 승격. (7 foundation 토큰에 size 전용 토큰 없음 — 명시) |
| 2+3 | **표적·형태** | **design-tokens.json의 arbitraryValues + 비도메인 typography 항목 전수 triage** — 시각 어휘("큰 요소")가 아니라 *기계 추출 트랙* 기준. 각 추출 토큰을 1건씩 "채택(어느 조각의 어느 prop)/기각(왜 안 씀)" 명시·빈칸 0 |
| 4 | **위치** | architecture-ui **§8 신설**(또는 §7 말미 신규 subsection) — 시술 시 final.md 목차 보고 확정. §7(design_system 사용)이 이미 비대하고, "크기→조각 연결"은 §1~§4 분해 규율 다음 단계라 신규 절이 응집적 |
| 5 | **area-tree** | 유지 + cross-link — layout-ir area 트리의 크기 없는 slot은 **IR(픽셀 금지)이 아니라 이 규율(토큰 트랙)에서** 크기를 메운다(IR 픽셀 미포함 불변 보존) |
| 6 | **강제 형태 (C)** | **정형 triage 블록 출력 강제** — architect가 design-spec에 triage 정형 블록을 출력(codex가 자발적으로 한 "HTML arbitrary value decisions" 블록을 규약화). 산문 자기점검은 보조. **결정론 린터는 후속**(다음 런 효과 측정 후·measure-first) |
| 7 | **coder 닫기 (9)** | **coder는 architecture-ui를 로드하지 않고 명세의 집행자**(coder.md skills = implementation-*·discipline-*). architect가 명세에 triage를 박으면 coder가 따른다(12차 codex 증거: codex *architect*가 spec:208에 박자 codex *coder*가 집행). → **강제는 생성측 한 곳**(N=1 순수·coder 미변경). 다음 런 **2단 측정**(명세 triage 출력 / 코드 size prop 반영)으로 격리 — coder가 명세를 무시하면(2차 흘림) 후속 iteration에 coder 강제 |

## 3. 컴포넌트별 변경 명세

> 예시 문구는 *초안*. 최종 문구·라인은 시술 시 grep(앵커 문구)으로 확정.

### 3.1 design-architect.md (agents · **수동 미러**)

claude 앵커 = "**design-tokens.json이 있으면 그 색·spacing·아이콘을 명세 화면 절에 박는다**"(L38·area 트리 지시와 *같은* 화면(ui) 불릿). codex 대응 = `codex-dddart/skills/dddart-design-architect/SKILL.md`(L37). **L44 아님**(L44는 파일목록 불릿·앞선 보고서 오류 정정).

- **변경 A — 소비 지시에 크기 추가**: "그 색·spacing·아이콘을 박는다" → "**색·spacing·크기(typography·arbitraryValues)·아이콘**을 박는다". (입력 설명 L22엔 이미 '타이포·임의값' 있음 → 유지.)
- **변경 B — triage 정형 블록 출력 강제 (결정 6=C의 핵심)** (초안):
  > "design-tokens.json의 arbitraryValues와 비도메인 typography 항목을 **빠짐없이 1건씩 훑어**, 각각을 *어느 화면 조각의 어느 크기 prop에 연결*했는지(또는 *왜 안 쓰는지*)를 design-spec에 **정형 목록으로** 출력한다. 추출 토큰 수만큼 항목이 있어야 한다 — 누락하면 coder가 그 크기를 흘린다."
  - 형태 참조(codex 자발 사례): "`text-[120px]`: detail hero 아이콘 크기로 채택, 해당 위젯 size prop으로 연결 / `shadow-[...]`: 카드 그림자로 채택 / `scale-[0.98]`: 미채택(상호작용 효과)" 식의 1줄 결정 목록.
- **변경 C — 자기점검 보강(보조)**: 기존 자기점검(claude L63·codex L62 "has_layout_ir이면 L1 골격 반영 스캔")에 "triage 정형 목록이 추출 토큰을 빠짐없이 덮었나" 1항. *정형 목록이 있어 빈칸이 구조적으로 드러남* — 산문 점검은 그 확인일 뿐(12차 산문 단독 공회전 회피).

### 3.2 architecture-ui/references/final.md — §8 신설 + 기존 §7 불릿 정합 (**자동 미러** `--write`)

기존 §7 불릿 문체(표제 + 하위 행 + *왜* 한 줄)를 따른다. 초안 골격:
- **표제 불릿 "분해한 조각에 추출된 크기를 연결"**:
  - ① **표적 = 추출 트랙**: design-tokens.json의 arbitraryValues + 비도메인 typography 항목(도메인 typography[예: 기온 텍스트]는 ui_extension/토큰이 이미 담당). 시각 눈대중("큰 요소")이 아니라 *추출된 토큰 목록*을 1건씩.
  - ② **연결·단위**: 각 추출 토큰을 해당 조각의 size/fontSize prop에 인용. **발명된 픽셀만 금지·추출값 인용은 허용** — 단일 사용처는 직접 인용, 재사용은 foundation 토큰 승격. (7 토큰에 size 전용 토큰 없음.)
  - ③ **전수·빈칸 0**: 추출 토큰을 빠짐없이 채택/기각. 빈칸을 남기면 coder가 흘린다.
  - ④ **cross-link**: layout-ir area 트리의 크기 없는 slot은 IR(픽셀 미포함)이 아니라 *이 규율이 토큰 트랙에서* 메운다.
  - *왜* 한 줄: "분해 3단은 상태로 가르므로 추출된 크기가 묶일 도메인이 없다 — 명세에서 조각에 직접 잇지 않으면 coder가 흘린다." (★런 번호·hero·weather 등 사건 서사 **금지** — 일반 원리만.)
- **기존 "시각 값은 foundation 토큰만" 불릿(앵커 "Color(0x…)·생 TextStyle(…) 리터럴 금지")에 크기 차원 정합**: 생 `fontSize`·발명 픽셀 상수 금지. 단 `TextStyle` 금지가 fontSize를 이미 포괄하므로 *중복 진술 회피*(시술 시 확인) — 추출값 인용 허용임을 한 문장으로 명확화(decision#1 모순 해소).
- 미세 간격 = AppSpacing은 기존 시각값 불릿에 흡수(중복 회피).

### 3.3 implementation-flutter — 변경 없음 (coder는 명세 집행자)

- **coder는 `architecture-ui`를 로드하지 않는다**(coder.md skills = implementation-dart/flutter/riverpod/test·discipline-cleancode/houserules/test). coder는 "명세의 집행자"(coder.md L15)라 architect가 명세에 박은 크기 triage를 그대로 구현한다. implementation-flutter는 Flutter 메커니즘(라우팅·dio·hive)이라 시각 크기와 무관 → **변경 없음**.
- *근거 정정*: 12차 codex 충실 = codex *architect*가 자발적으로 spec:208에 크기를 박고 codex *coder*가 그 명세를 집행한 것(codex 코퍼스도 크기 미지시). claude도 architect가 (코퍼스 강제로) 박으면 coder가 따른다 — 차이는 **architect 단계**(박았나)지 coder가 아니다. 즉 강제는 생성측 한 곳(N=1 순수). coder가 명세를 무시하는지(2차 흘림)는 다음 런 2차 측정으로 확인하고, 그때만 coder측(discipline 또는 명세 형식) 강제(후속).

## 4. 데이터 흐름

```
시안 HTML
  → extract_design (typography·arbitraryValues 추출·기존)
  → design-tokens.json
  → design-architect (★추출 토큰 전수 triage 정형 블록 출력 + 소비 지시에 크기)
  → design-spec 명세 (triage 목록 + area 트리)
  → coder (triage 목록 따라 size prop에 박음·bottom-up·기존+1줄 보강)
```

## 5. 에러 처리·가드

- **빈칸 검출**: 정형 triage 블록이 빈칸을 *구조적으로 노출*(추출 토큰 수 = 항목 수). 자기점검이 보조 확인. (린터 기계 검출은 §8 후속.)
- **과적합 — 범용 표현**: weather 구체값(120px·hero·7일·6종 enum) **및 런 번호·라이브런 사건 서사(N차 …)**를 코퍼스 본문에 박지 않는다 — 증거는 자료조사 보고서에만. 예시 px 필요 시 SCENARIO-*·positive-control 격리.
- **musty MUSTs 금지**: ALL-CAPS ALWAYS/NEVER 대신 *왜* 설명. "눈대중 금지"는 §8 규율 1곳(원리)에만 두고 자기점검은 동작만 진술(3중복 회피).
- **area-tree 불가침**: layout-ir 픽셀 미포함 불변 보존. 크기는 design-tokens 트랙에서만.
- **HaffHaff 모방 경계**: "항상 width/height" 재발 금지 — 시안 명시 크기만.

## 6. 측정·검증 (2단·grep 사전등록·정직 격하)

- **자동 게이트 안 박음**(measure-first). 현 FID 게이트는 구조만·9차+ screenProbes 미노출로 미작동·크기 0개 캡처.
- ⚠️ **"A/B 자동 측정" 아님 — "육안 + grep 대조"로 정직 격하**(자동 게이트 부재).
- **2단 사전등록 측정**(다음 런):
  - **1차(architect 출력)**: design-spec에 triage 정형 블록이 나왔나 + 추출 토큰 빠짐 없나(grep 항목 수 대 토큰 수).
  - **2차(coder 반영)**: 산출물 특정 위젯의 size 리터럴을 grep해 시안값과 대조(사전 지정: 예 `daily_forecast_detail` hero `Icon` size). 12차 실측(120/96/32)이 비교 기준.
- **분기 사전 적시**: 1차 빈칸/2차 흘림이면 → 다음 iteration에 결정론 린터(§8) 또는 coder측 강제 강화.
- **N=1 단일변수**: 레이아웃만(에셋 미시술).

## 7. 양판 미러 계획 (경로 교정)

| 파일 | 미러 방식 | 경로(★시술 시 재확인) |
|---|---|---|
| architecture-ui `final.md` | **자동** `--write` | 배포본 `dddart/skills/architecture-ui/references/final.md` 직접 수정 → `corpus_mirror_sync.py --write`(소스 `workspace/reference/architecture-ui/reference/final.md`[★이중 reference] + codex 동기) |
| `design-architect.md` | **수동** | claude `dddart/agents/design-architect.md` ↔ codex `codex-dddart/skills/dddart-design-architect/SKILL.md`(★codex엔 `agents/` 없음·SKILL.md). **앵커 문구**로 미러(라인 오프셋 비대칭: claude L38/L63 ↔ codex L37/L62) |
| ~~implementation-flutter~~ | — | **변경 없음**(coder 명세 집행자·§3.3) |

시술 후 **다음 런까지 코퍼스 동결**. grep cross-check는 라인이 아니라 앵커 문구로.

## 8. 범위 밖 (후속·별도)

- **결정론 린터(R5형)**: triage 빈칸 기계 검출. 다음 런 effect 측정 후 도입 판단(보류 중 `backstop R5` 부활). measure-first.
- **에셋(Track A)**: Phase 0 다운로드 → AppAsset → pubspec → Image.asset. 레이아웃 효과 측정 후 별도 iteration.
- **크기 게이트**: 비율/순위 불변량·positive-control 반증·screenProbes 봉합 후.

## 9. 미해결·리스크

- **결정 6(C)의 베팅**: 린터 없이 정형 블록만 강제 — architect가 빈칸으로 출력하면 검출 못 함. "area처럼 충실히 낼 것"에 한 런 베팅(12차 area 성공이 근거). 빈칸 도망이 다음 런에 보이면 → 린터(§8).
- **codex 무변 확인**: 규율 추가가 이미 자율로 하는 codex 산출물을 바꾸지 않는지 측정.
- **위치 §7 vs §8**: §8 신설 권장이나 시술 시 final.md 목차 보고 확정.
- **in-family 한계**: 전원 Claude 계열 조사·리뷰자.
