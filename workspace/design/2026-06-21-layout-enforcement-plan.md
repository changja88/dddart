# 레이아웃 강제 시술 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** dddart 코퍼스(설계측)에 "추출된 크기 토큰을 분해한 조각에 연결"하는 레이아웃 강제 규율을 추가해 12차 UI 크기 충실도 퇴행(hero 120→32px)을 막는다.

**Architecture:** 변경은 **생성측 2파일**뿐 — ① `design-architect.md`(에이전트): 크기 소비 지시 + arbitraryValues/비도메인 typography 전수 triage 정형 목록 출력 강제 + 자기점검 ② `architecture-ui/references/final.md`(스킬): §8 신설(크기 연결 규율) + §7 정합. coder는 architecture-ui 미로드·명세 집행자라 변경 없음(architect가 명세에 박은 triage를 따름·12차 codex 증거). layout-ir/area-tree는 불가침(픽셀 미포함 불변).

**Tech Stack:** dddart 코퍼스(마크다운 에이전트·스킬) · `corpus_mirror_sync.py`(양판 미러) · grep 앵커 검증.

## Global Constraints

- **양판 미러**: `architecture-ui/references/final.md`는 배포본(`dddart/skills/...`) 수정 후 `corpus_mirror_sync.py --write`로 소스·codex 자동 동기. `design-architect.md`는 미러 scope 밖 → **수동** 미러(claude `dddart/agents/design-architect.md` ↔ codex `codex-dddart/skills/dddart-design-architect/SKILL.md`).
- **앵커 문구로 편집**: 라인 번호는 드리프트 가능(Track B `480eb11` 이후) — 모든 편집 전 `grep -n "앵커"`로 위치 재확인. claude L38/L63 ↔ codex L37/L62(오프셋 -1 비대칭).
- **과적합 금지**: weather 구체값(120px·hero·7일·6종 enum) **및 런 번호·라이브런 사건 서사(N차…)**를 코퍼스 본문에 박지 않는다 — 일반 원리만.
- **musty MUSTs 금지**: ALL-CAPS ALWAYS/NEVER 대신 *왜* 설명. 기존 final.md 불릿 문체 유지.
- **measure-first**: 결정론 린터·크기 게이트는 범위 밖(다음 런 효과 측정 후). 이번은 정형 출력 강제까지.
- **커밋·동결**: 커밋은 사용자 지시 시(dddart 규칙). 시술 후 다음 런까지 코퍼스 동결.
- **layout-ir 불가침**: area-tree/layout-ir 스키마는 손대지 않는다(픽셀 미포함 불변).

---

### Task 1: design-architect 크기 소비·triage·자기점검 (claude + codex 수동 미러)

**Files:**
- Modify: `dddart/agents/design-architect.md` (claude — 화면(ui) 불릿·자기점검)
- Modify: `codex-dddart/skills/dddart-design-architect/SKILL.md` (codex — 동일 앵커, 오프셋 -1)

**앵커(편집 전 grep 확인):**
- 앵커 A(소비 지시): `design-tokens.json`이 있으면 그 색·spacing·아이콘을 명세 화면 절에 박는다
- 앵커 B(자기점검): `has_layout_ir`이면 화면 절이 layout-ir의 L1 골격

- [ ] **Step 1: 앵커 위치·드리프트 확인 (양판)**

```bash
grep -n "색·spacing·아이콘을 명세 화면 절에 박는다" dddart/agents/design-architect.md codex-dddart/skills/dddart-design-architect/SKILL.md
grep -n "area 어휘 트리로 반영했는지도 이 스캔에서" dddart/agents/design-architect.md codex-dddart/skills/dddart-design-architect/SKILL.md
```
Expected: claude(L38·L63 부근)·codex(L37·L62 부근) 각 1매치. 매치 없으면 STOP(드리프트 — 앵커 재탐색).

- [ ] **Step 2: claude 변경 1 — 소비 지시에 크기 추가**

`dddart/agents/design-architect.md` 화면(ui) 불릿:
```
old: **`design-tokens.json`이 있으면 그 색·spacing·아이콘을 명세 화면 절에 박는다**
new: **`design-tokens.json`이 있으면 그 색·spacing·크기(`typography`·`arbitraryValues`)·아이콘을 명세 화면 절에 박는다**
```

- [ ] **Step 3: claude 변경 2 — triage 정형 목록 출력 강제**

같은 화면(ui) 불릿, 아이콘 매핑 문장 끝(`unmappedIcons`는 가장 가까운 `Icons.*` + design-ref 충실도 확인). 바로 뒤에 한 문장 삽입:
```
old: ...`unmappedIcons`는 가장 가까운 `Icons.*` + design-ref 충실도 확인). **`layout-ir.json`이 있으면
new: ...`unmappedIcons`는 가장 가까운 `Icons.*` + design-ref 충실도 확인). **크기는 `arbitraryValues`·비도메인 `typography` 항목을 빠짐없이 1건씩 — 어느 조각의 어느 size/fontSize prop에 연결했는지(또는 왜 안 쓰는지) — 정형 목록으로 박는다**(추출 토큰 수만큼 항목·빈칸이면 coder가 그 크기를 흘린다): 발명한 픽셀이 아니라 추출값 인용이며 단일 사용처는 직접 인용·여러 조각 공유는 foundation 토큰 승격, 도메인 `typography`(본문·강조 텍스트 등)는 ui_extension 담당이라 제외다(architecture-ui §8). **`layout-ir.json`이 있으면
```

- [ ] **Step 4: claude 변경 3 — 자기점검에 크기 대조 추가**

자기점검 문장 끝(area 어휘 트리로 반영했는지도 이 스캔에서 함께 대조한다 — 빠뜨리면 강제가 죽은 지침이 된다.) 뒤에 삽입:
```
old: area 어휘 트리로 반영했는지도 이 스캔에서 함께 대조한다 — 빠뜨리면 강제가 죽은 지침이 된다.
new: area 어휘 트리로 반영했는지도 이 스캔에서 함께 대조한다 — 빠뜨리면 강제가 죽은 지침이 된다. **`design-tokens.json`이 있으면** `arbitraryValues`·비도메인 `typography` 항목이 크기 정형 목록에 빠짐없이 들어갔는지도 대조한다(추출 토큰 수 = 목록 항목 수) — 빈칸은 coder가 흘릴 자리다.
```

- [ ] **Step 5: codex 동일 3변경 (앵커 문구 동일)**

`codex-dddart/skills/dddart-design-architect/SKILL.md`에 Step 2·3·4와 **동일 old→new**를 적용(앵커 문구가 byte-동일·라인만 -1).

- [ ] **Step 6: grep cross-check — claude ↔ codex 동일**

```bash
grep -c "크기(`typography`·`arbitraryValues`)·아이콘" dddart/agents/design-architect.md codex-dddart/skills/dddart-design-architect/SKILL.md
grep -c "정형 목록으로 박는다" dddart/agents/design-architect.md codex-dddart/skills/dddart-design-architect/SKILL.md
grep -c "크기 정형 목록에 빠짐없이" dddart/agents/design-architect.md codex-dddart/skills/dddart-design-architect/SKILL.md
```
Expected: 각 명령이 양 파일 모두 `1`. 불일치면 누락 측 보완.

- [ ] **Step 7: 커밋 (사용자 지시 시에만)**

```bash
git add dddart/agents/design-architect.md codex-dddart/skills/dddart-design-architect/SKILL.md
git commit  # 사용자가 커밋 지시한 경우에만 — 메시지·footer는 세션 규약
```

---

### Task 2: architecture-ui §8 신설 + §7 정합 (배포본 → `--write` 자동 미러)

**Files:**
- Modify: `dddart/skills/architecture-ui/references/final.md` (배포본 — 목차·§7·§8)
- Auto-mirror: `workspace/reference/architecture-ui/reference/final.md`(소스) + `codex-dddart/skills/architecture-ui/references/final.md`(codex) ← `--write`

**앵커:**
- 목차 끝: `- §7. design_system 사용 — 토큰·컴포넌트·show() 금지`
- §7 시각값 불릿: `매직 넘버 duration도 동일(`AppDuration` — §6).`
- final.md 끝: `방향을 헷갈리면 design_system에 BC 어휘가 스민다.`

- [ ] **Step 1: 앵커 확인**

```bash
grep -n "§7. design_system 사용 — 토큰·컴포넌트·show() 금지" dddart/skills/architecture-ui/references/final.md
grep -n "매직 넘버 duration도 동일" dddart/skills/architecture-ui/references/final.md
grep -n "방향을 헷갈리면 design_system에 BC 어휘가 스민다" dddart/skills/architecture-ui/references/final.md
```
Expected: 목차(L16)·§7(L102)·끝(L106) 각 1매치.

- [ ] **Step 2: 목차에 §8 추가**

```
old: - §7. design_system 사용 — 토큰·컴포넌트·show() 금지
new: - §7. design_system 사용 — 토큰·컴포넌트·show() 금지
- §8. 크기 연결 — 추출된 크기 토큰을 조각에 잇기
```

- [ ] **Step 3: §7 시각값 불릿에 크기 차원 정합**

```
old: 매직 넘버 duration도 동일(`AppDuration` — §6).
new: 매직 넘버 duration도 동일(`AppDuration` — §6). 크기(`fontSize`·아이콘 size 등)도 눈대중 픽셀 상수가 아니라 `design-tokens.json`이 추출한 값을 인용한다(§8 — `TextStyle`의 `fontSize`는 위 생 `TextStyle` 금지에 이미 포함이다).
```

- [ ] **Step 4: §8 신설 (final.md 끝에 추가)**

```
old: 도메인 어휘가 필요한 시각 매핑은 design_system이 아니라 그 BC의 ui_extension(§5)이다 — 방향을 헷갈리면 design_system에 BC 어휘가 스민다.
new: 도메인 어휘가 필요한 시각 매핑은 design_system이 아니라 그 BC의 ui_extension(§5)이다 — 방향을 헷갈리면 design_system에 BC 어휘가 스민다.

## §8. 크기 연결 — 추출된 크기 토큰을 조각에 잇기

화면을 3단(§1)으로 분해하는 축은 *상태*다 — 크기가 아니다. 그래서 추출된 시각 크기(아이콘·대형 요소 등)는 묶일 도메인이 없어, 명세에서 각 조각에 직접 잇지 않으면 사라진다. design-architect가 이 연결을 명세에 박고 coder는 그 명세를 집행한다 — 강제는 설계 명세 한 곳에서 닫힌다.

- **표적은 추출 트랙**: `design-tokens.json`의 `arbitraryValues`(예 `text-[Npx]`)와 비도메인 `typography` 항목이다. 도메인에 묶인 typography(본문·강조 텍스트 등)는 ui_extension(§5)·토큰이 이미 담당하니 제외 — 시각 눈대중("큰 요소")이 아니라 *기계 추출된 토큰 목록*을 1건씩 본다.
- **전수·빈칸 0**: 추출 토큰을 빠짐없이 채택(어느 조각의 어느 size/fontSize prop에 연결)/기각(왜 안 씀)한다. 추출 토큰 수만큼 항목이 있어야 한다 — 빈칸을 남기면 coder가 그 크기를 흘린다.
- **발명이 아니라 인용**: 새 픽셀을 눈대중으로 만들지 않는다. 단일 사용처는 추출값을 size prop에 직접 인용하고, 여러 조각이 공유하는 크기는 foundation 토큰으로 승격해 참조한다(7토큰에 크기 전용 토큰은 없다 — `app_typography`의 size이거나 직접 인용이다). 미세 간격은 §7 `app_spacing`.
- **layout-ir와 직교**: area 트리(design-architect)의 크기 없는 slot은 layout-ir(픽셀 미포함)이 아니라 *이 규율이* 토큰 트랙에서 메운다 — 상대 기하는 IR이 가지고, 절대 크기는 토큰이 가진다(픽셀은 IR에 들어가지 않는다).
```

- [ ] **Step 5: 양판 자동 미러 (`--write`)**

```bash
python3 workspace/tools/corpus_mirror_sync.py --write
```
Expected: architecture-ui에 대해 `불변식1 소스 본문 ← 배포 본문`·`불변식2 codex ← 배포` 동작 출력. (배포본만 수정했으므로 drift→해소.)

- [ ] **Step 6: 미러 동기 검증**

```bash
python3 workspace/tools/corpus_mirror_sync.py
```
Expected: `architecture-ui ... inv1=in_sync inv2=in_sync` + 전체 `N/N in-sync` exit 0.

- [ ] **Step 7: 커밋 (사용자 지시 시에만)**

```bash
git add dddart/skills/architecture-ui/references/final.md workspace/reference/architecture-ui/reference/final.md codex-dddart/skills/architecture-ui/references/final.md
git commit  # 사용자가 커밋 지시한 경우에만
```

---

### Task 3: 전체 정합 검증·라이브런 준비 (동결)

**Files:** (검증만 — 편집 없음)

- [ ] **Step 1: 코퍼스 미러 전체 검증**

```bash
python3 workspace/tools/corpus_mirror_sync.py --format json
```
Expected: `"exit": 0` (전 스킬 in-sync). architecture-ui inv1/inv2 in_sync.

- [ ] **Step 2: design-architect 양판 동일성 (수동 미러 확인)**

```bash
diff <(grep -A2 "색·spacing·크기" dddart/agents/design-architect.md) <(grep -A2 "색·spacing·크기" codex-dddart/skills/dddart-design-architect/SKILL.md)
```
Expected: 차이 없음(앵커 주변 동일 텍스트). 차이 있으면 누락 측 보완.

- [ ] **Step 3: 과적합·musty 자가 점검 (grep red-flag)**

```bash
grep -nE "120px|hero|7일|broccoli|12차|11차|N차" dddart/skills/architecture-ui/references/final.md dddart/agents/design-architect.md
grep -nE "ALWAYS|NEVER|반드시.*반드시" dddart/skills/architecture-ui/references/final.md
```
Expected: weather 구체값·런 번호·musty 0매치(있으면 일반 원리로 교정).

- [ ] **Step 4: 라이브런 준비 — 플러그인 재동기 (사용자 드라이브)**

> 코퍼스 변경을 다음 런이 적재하려면 플러그인 재설치(claude)·codex 파일 동기가 필요. 이는 **사용자 드라이브**(RUNBOOK §2 재동기) — 에이전트는 명령 후보만 제시:
> - claude: 플러그인 재설치(install) 후 design-architect·architecture-ui 마커 적재 확인
> - codex: 변경 파일 cp(또는 동기 스크립트) 후 적재 확인

- [ ] **Step 5: 동결 선언**

시술 후 다음 라이브런까지 코퍼스 동결(단일 변수 보존). 측정 = §6 2단(명세 triage 출력 / 코드 size prop 반영·grep 사전등록).

---

## 측정 프로토콜 (다음 런·plan 외 실행)

- **1차(architect 출력)**: 산출물 design-spec에 크기 triage 정형 목록이 나왔나 + `arbitraryValues` 토큰 수 = 목록 항목 수(빈칸 0). `grep`으로 design-tokens.json arbitraryValues 수 ↔ design-spec triage 항목 수 대조.
- **2차(coder 반영)**: 산출물 hero 상태 아이콘 등 큰 요소의 size 리터럴을 grep해 시안값과 대조(12차 실측 120/96/32가 기준·사전 지정 위젯).
- **분기**: 1차 빈칸/2차 흘림 → 다음 iteration에 결정론 린터(§8 후속) 또는 coder측 강제.
