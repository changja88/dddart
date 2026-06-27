# dddart 디자인 출처 전환 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:subagent-driven-development`(권장) 또는 `superpowers:executing-plans`로 태스크별 집행. 스텝은 체크박스(`- [ ]`)로 추적.
> **설계 SSOT**: `workspace/design/2026-06-27-claude-design-source-design.md`. 이 계획은 그 설계를 **어떤 순서로·어떤 검증 게이트로** 집행할지의 오케스트레이션이다 — 산문 변경의 라인별 내용은 설계 문서가 단일 출처이고(DRY), 계획은 순서·게이트·커밋 단위를 소유한다.

**Goal:** claude 판 dddart의 디자인 출처를 Stitch→Claude Design(내장 `DesignSync`)으로 전환하고, codex 판은 Stitch 유지, 양판에서 Figma(미실재)를 제거한다.

**Architecture:** 변경은 전부 **인입(ingest) 계층**에 한정 — design_system 소비 규율은 엔진 무관이라 불변. 추출 스크립트는 **ADD-A-MODE**(기존 모드 불변 + 신규 모드 추가 + codex 미러 복사). 화면 시각 충실도 게이트는 보존(비교 대상 HTML→JSX, 최종 판단 육안).

**Tech Stack:** Dart(스크립트 3종·픽스처 `test/run_fixtures.sh`), Markdown 코퍼스, `corpus_mirror_sync.py`(미러 전파), Makefile(release 게이트).

## Global Constraints

모든 태스크에 암묵 적용:

- **양판 미러 byte-identical**: claude `dddart/` ↔ codex `codex-dddart/`의 미러 파일은 `diff -q`로 동일해야 한다(스크립트 3종·`icon_map.json`·`architecture-ui/references/final.md` 등). `final.md`는 `corpus_mirror_sync.py` inv2가, 스크립트·`icon_map.json`은 Makefile release `[2/7]`의 `diff -q` 게이트가 강제한다(한쪽만 바뀌면 exit 2로 릴리즈 차단).
- **ADD-A-MODE**: `extract_design`·`fetch_images`·`extract_layout`의 기존 `main()` case·함수 시그니처·HTML/`--from-theme` 모드를 **절대 제거·재작성하지 않는다**. 신규 모드만 추가.
- **출력 스키마 키 불변**: `design-tokens.json`·`asset-manifest.json`·`layout-ir.json`의 키를 하나도 바꾸지 않는다(다운스트림 계약: design-architect·architecture-ui §5/§7/§8·implementation-flutter §8).
- **`has_stitch_html`→`has_design_screen` 7곳 원자 개명**: `dddart/commands/dddart.md` L54·55·56·123·124·137·161. 하나라도 누락 시 게이트 silent off.
- **DesignSync 읽기 전용**: `list_projects`·`get_project`·`list_files`·`get_file`만. `write_files`·`delete_files`·`create_project`·`finalize_plan`·`register_assets`는 어떤 경우에도 금지.
- **codex Stitch 무손상**: codex의 `has_stitch_html`·extract_design HTML/theme 모드·Stitch 읽기 5종·scripts는 전부 유지. codex는 Figma만 제거.
- **vacuous 치환 금지**: 단순 `Stitch`→`Claude Design` 텍스트 치환 시 Tailwind 어휘(`arbitraryValues`·`text-[..]`·hover:)의 referent가 dangling되어 충실도 검사가 always-pass가 된다 → CSS-var+inline-style 용어로 의미 교체.
- **한글 주석·문서**: dddart 코퍼스 언어 규율 유지.

> **선행(실행 시작 시 사용자와 확정):** 현재 `main` 브랜치이므로 작업 브랜치를 먼저 만든다(예: `git checkout -b feat/claude-design-source`). 각 태스크 끝 커밋·최종 머지는 사용자 승인 시 진행.

---

### Task 1: `extract_design.dart` — `--from-ds-manifest` 모드 추가

**Files:**
- Modify: `dddart/scripts/extract_design.dart` (main 파싱 L28-39에 case 추가, 신규 `_runDsManifestMode`)
- Mirror: `codex-dddart/skills/dddart/scripts/extract_design.dart` (복사로 byte-identical 복원)
- Test: `dddart/scripts/test/run_fixtures.sh` (신규 F-series 픽스처)

**Interfaces:**
- Produces: CLI `dart run extract_design.dart --from-ds-manifest <_ds_manifest.json> [<screen-jsx-dir>] --out <design-tokens.json> [--icon-map <icon_map.json>]`. 출력 `design-tokens.json`은 **기존 스키마 그대로**(colors·typography·spacing·borderRadius·arbitraryValues·icons{name,fill,flutter}). Task 3의 커맨드 호출이 이 시그니처를 소비.

- [ ] **Step 1: 신규 모드 픽스처를 먼저 작성(실패 확인)** — `_ds_manifest.json` 입력 + 기대 `design-tokens.json`(기존 키만) 픽스처를 `run_fixtures.sh` 체계에 추가. 설계 §5 kind 매핑(color→colors·font→typography·spacing→spacing·radius→borderRadius·shadow→arbitraryValues·other→drop)과 `var(--x)` 자기참조 해소, screen-jsx-dir의 `window.BrkIcon` Material Symbol명→icons[] 룩업을 검증하는 케이스.
- [ ] **Step 2: 픽스처 실행 → 실패 확인.** Run: `bash dddart/scripts/test/run_fixtures.sh` · Expected: 신규 케이스 FAIL(모드 미구현), **기존 케이스는 전부 PASS 유지**.
- [ ] **Step 3: `main()`에 `--from-ds-manifest` case 추가 + `_runDsManifestMode` 구현.** `--from-theme`(L34-35 파싱 / L46-50 분기 / `_runThemeMode`)를 **미러**로 삼아 작성 — 기존 출력 헬퍼·`_sorted`·`_emitIcons`·exit 규율 재사용. HTML 모드·`--from-theme` 모드·기존 시그니처 **불변**.
- [ ] **Step 4: 픽스처 재실행 → 신규 PASS + 기존 PASS.** Run: `bash dddart/scripts/test/run_fixtures.sh` · Expected: 전체 PASS.
- [ ] **Step 5: codex 미러 복원 + 검증.** `cp dddart/scripts/extract_design.dart codex-dddart/skills/dddart/scripts/extract_design.dart` · Run: `diff -q dddart/scripts/extract_design.dart codex-dddart/skills/dddart/scripts/extract_design.dart` · Expected: 동일(출력 없음).
- [ ] **Step 6: 커밋.** `git add dddart/scripts/extract_design.dart codex-dddart/skills/dddart/scripts/extract_design.dart dddart/scripts/test/` · 메시지: `feat(extract_design): add --from-ds-manifest mode (Claude Design tokens)`

---

### Task 2: `fetch_images.dart` — `.jsx` 글롭 + `--asset-base`

**Files:**
- Modify: `dddart/scripts/fetch_images.dart` (글롭 L49-54, `_fetchOne` 상대경로 분기)
- Mirror: `codex-dddart/skills/dddart/scripts/fetch_images.dart`
- Test: `dddart/scripts/test/run_fixtures.sh`

**Interfaces:**
- Produces: CLI에 `--asset-base <design-ref>` 인자 추가. 출력 `asset-manifest.json`은 **기존 스키마 그대로**(`{src,alt,local_path,token,status}`). Task 3 커맨드 호출이 소비.

- [ ] **Step 1: 픽스처 작성(실패 확인)** — `.jsx` 안의 `<img src="../../assets/x.png">`(상대경로)가 `--asset-base`로 해소돼 `local_path`로 복사되고 `status` != skipped인 케이스. 현재는 상대경로가 전부 `skipped`로 떨어짐.
- [ ] **Step 2: 픽스처 실행 → 실패 확인.** Run: `bash dddart/scripts/test/run_fixtures.sh` · Expected: 신규 FAIL, 기존 PASS.
- [ ] **Step 3: 구현.** `.html` 글롭을 `.jsx` 포함으로 확장 + `--asset-base` 인자로 non-http/non-data src 해소 분기 추가. `_camel`·`_uniqueToken`·매니페스트 라이터·data:/http(s) 경로·`{src,alt,local_path,token,status}` 스키마 **재사용**. 동적 `<img src={expr}>`는 정적 해소 불가 → `skipped`/`failed`로 fail-loud.
- [ ] **Step 4: 픽스처 재실행 → 전체 PASS.** Run: `bash dddart/scripts/test/run_fixtures.sh`
- [ ] **Step 5: codex 미러 복원 + 검증.** `cp` 후 `diff -q ...` · Expected: 동일.
- [ ] **Step 6: 커밋.** `feat(fetch_images): add --asset-base + jsx glob for Claude Design assets`

---

### Task 3: `dddart/commands/dddart.md` — 인입 계층 재작성 (claude)

**Files:**
- Modify: `dddart/commands/dddart.md` (설계 §6-A의 12 지점)

**Interfaces:**
- Consumes: Task 1·2의 신규 CLI 시그니처(`--from-ds-manifest`·`--asset-base`)를 추출 호출 라인(L122-125)에 사용.

- [ ] **Step 1: frontmatter + 동결 형식 + 포인터 스키마.** §6-A: L6(`mcp__stitch__*` 5종 삭제, 게이트 시 DesignSync 읽기 4종), L24/L16(동결 입력 HTML→JSX·manifest), L36(`design_source` `mcp`→`engine:"claude-design"`).
- [ ] **Step 2: 플래그 7곳 원자 개명.** L54·55·56·123·124·137·161의 `has_stitch_html`→`has_design_screen`. 발동 조건 '화면 HTML 동결'→'화면 JSX(`*Screen.jsx`) 동결'.
- [ ] **Step 3: 개명 검증 게이트.** Run: `grep -n 'has_stitch_html' dddart/commands/dddart.md` → Expected: **0건**. `grep -c 'has_design_screen' dddart/commands/dddart.md` → Expected: **7** 이상(정의+참조).
- [ ] **Step 4: 탐지·읽기전용·재사용·첫지정(L114-120).** §6-A: `·mcp__figma__*` 삭제, 스캔→DesignSync 가용성, 읽기 4종/금지 부작용 5종 재명시, 재사용 3분기 골격 보존, `2개+` 분기 삭제.
- [ ] **Step 5: 동결·추출 호출(L121-125) — Task 1·2 시그니처 사용.** §6-A: `get_file`로 `*Screen.jsx`·`_ds_manifest.json`·`tokens/*.css` 동결, `extract_design --from-ds-manifest <design-ref>/_ds_manifest.json <design-ref>/screens --out design-tokens.json`, `fetch_images ... --asset-base <design-ref>`, 색 이원성 분기 제거.
- [ ] **Step 6: 배너·architect·리뷰어·경계·실패표면화(L128·129·130·136·137·161·207).** §6-A: G0/G2 배너 'Claude Design' 라벨, JSX 직수입 금지 강화, architect 토큰 서술, G2 육안 대조 절차 보존(토큰 축소 금지), 경계 절 'DesignSync 읽기 전용'.
- [ ] **Step 7: claude 잔여 검증 게이트.** Run: `grep -in 'stitch\|figma' dddart/commands/dddart.md` → Expected: **0건**(전부 제거). Run: `grep -n 'write_files\|create_project\|finalize_plan\|register_assets\|delete_files' dddart/commands/dddart.md` → Expected: 등재가 아니라 **금지 목록 맥락에서만** 등장.
- [ ] **Step 8: 커밋.** `feat(dddart.md): switch claude design source Stitch→Claude Design (ingest layer)`

---

### Task 4: claude 에이전트 3종 — coder·design-review-ui·design-architect

**Files:**
- Modify: `dddart/agents/coder.md`, `dddart/agents/design-review-ui.md`, `dddart/agents/design-architect.md` (설계 §6-B)
- Reference(무변경 확인): codex 동명 파일

**Interfaces:**
- Consumes: Task 3의 `has_design_screen` 플래그·design-ref JSX 형식.

- [ ] **Step 1: `coder.md`** — HTML 화면 가정→동결 JSX 소비(§6-B). claude 전용.
- [ ] **Step 2: `design-review-ui.md`** — L13 플래그 개명+`design-tokens.json` shape를 `_ds_manifest.json tokens[]` 직독으로, **L31 Tailwind 어휘→CSS-var+inline-style 재표현**(vacuous 금지), L27 DS 컴포넌트 재사용 점검.
- [ ] **Step 3: `design-architect.md`** — L22 manifest 직독+kind→foundation 5토큰, L38 Tailwind 산물 재표현+화면→design_system 위젯 매핑(YAGNI 기본). **크기 강제(§8 전수·빈칸0)는 출처만 JSX로 바꾸고 규율 유지.**
- [ ] **Step 4: vacuous·잔여 검증.** Run: `grep -in 'stitch\|tailwind\|arbitraryValues\|text-\[' dddart/agents/design-review-ui.md dddart/agents/design-architect.md` → 잔여가 '엔진중립 출력 필드명'이 아닌 Stitch/Tailwind 결합이면 교체 누락. Run: `diff -q dddart/agents/design-review-ui.md codex-dddart/skills/dddart-design-review-ui/SKILL.md` → **다름**(의도된 비대칭 — codex는 Stitch 유지).
- [ ] **Step 5: 커밋.** `feat(agents): retarget claude design consumers to Claude Design JSX/manifest`

---

### Task 5: shared 미러 문서 — architecture-ui + implementation-flutter final.md

**Files:**
- Modify(소스): `dddart/skills/architecture-ui/references/final.md`(§5 L80·§8 L113), `dddart/skills/implementation-flutter/references/final.md`(§8·§9 HTML 결합)
- Propagate: `corpus_mirror_sync.py --write`로 3사본(workspace reference 소스 + claude 배포 + codex 배포)

- [ ] **Step 1: 엔진중립화.** §6-C: `architecture-ui/final.md` L80 'Stitch HTML 동결 시'→'디자인 출처 동결 시', L113 Tailwind 예시→'정규화된 치수 토큰'. `implementation-flutter/final.md` §8·§9 화면 HTML 결합 중립화. **출력 필드명(arbitraryValues 등)·§8 크기 강제 규율은 불변.**
- [ ] **Step 2: 미러 전파.** Run: `python3 workspace/tools/corpus_mirror_sync.py --write`.
- [ ] **Step 3: 미러 일관 검증.** Run: `diff -q dddart/skills/architecture-ui/references/final.md codex-dddart/skills/architecture-ui/references/final.md` → 동일. `grep -in 'stitch' dddart/skills/architecture-ui/references/final.md codex-dddart/skills/architecture-ui/references/final.md` → **0건**(양판 동시).
- [ ] **Step 4: 커밋.** `refactor(arch-ui,impl-flutter): engine-neutralize design-source coupling (3-copy mirror)`

---

### Task 6: README.md + AGENTS.md — 엔진 비대칭 명시

**Files:**
- Modify: `README.md`(L60·L92 엔진 분리), `AGENTS.md`(비대칭+왜, L37-38 미러 규칙 정정)

- [ ] **Step 1: README** — §6-C: L60·L92 디자인 출처를 claude=Claude Design / codex=Stitch 1줄씩.
- [ ] **Step 2: AGENTS.md** — 의도된 비대칭 + 왜(Claude Design은 claude.ai 내장→Codex 접근 불가) 명시. L37-38: 스크립트는 '모드 추가'라 byte-identical 미러 유지됨을 명시.
- [ ] **Step 3: 검증.** Run: `grep -in 'claude design\|claude.ai' AGENTS.md README.md` → 비대칭 '왜'가 존재.
- [ ] **Step 4: 커밋.** `docs(AGENTS,README): document intended claude=Claude Design / codex=Stitch asymmetry`

---

### Task 7: codex `SKILL.md` — Figma 제거 + 비대칭 (Stitch 무손상)

**Files:**
- Modify: `codex-dddart/skills/dddart/SKILL.md` (§6-D: L131·L24)

- [ ] **Step 1: L131** — `(Stitch·Figma)`→`(Stitch)`, 'claude의 mcp__* …동일 프로토콜' 정정→'엔진 자체가 다름(claude=Claude Design 내장·Codex 접근 불가)'. 탐지 골격·L132 읽기전용 유지.
- [ ] **Step 2: L24** — 'MCP 연결 상이' 패리티→'의도된 엔진 비대칭' 격상(codex측 왜 앵커).
- [ ] **Step 3: 검증 게이트.** Run: `grep -in 'figma' codex-dddart/skills/dddart/SKILL.md` → **0건**. Run: `grep -c 'stitch\|has_stitch_html' codex-dddart/skills/dddart/SKILL.md` → **유지**(Stitch 자산 무손상). Run: `grep -in 'figma' codex-dddart/ dddart/` → **양판 0건**(Figma 완전 제거).
- [ ] **Step 4: 커밋.** `refactor(codex): drop Figma, mark intended engine asymmetry (Stitch kept)`

---

### Task 8: feedback 메모 생성 + icon_map 주석

**Files:**
- Create: `workspace/eval/fix/feedback-NNN-claude-design-source.md` (NNN = `ls workspace/eval/fix/`로 다음 가용 번호 확인)
- Modify: `dddart/scripts/icon_map.json`(L2 주석 일반화) + codex 미러

- [ ] **Step 1: 다음 번호 확인.** Run: `ls workspace/eval/fix/` → 기존 번호 확인 후 다음 NNN 결정.
- [ ] **Step 2: feedback 메모 작성.** §6-C: 비대칭의 왜·변경 표면(인입 계층 한정)·시각 충실도 게이트 보존·`has_stitch_html`→`has_design_screen`·스크립트 모드 추가·다음 라이브런 측정 dim. 이력 문서(workspace/design의 stitch 메모)는 **편집하지 않고** 신규 기록.
- [ ] **Step 3: icon_map 주석 일반화 + 미러.** `dddart/scripts/icon_map.json` L2 주석을 엔진중립화, `cp`로 codex 미러, `diff -q` 동일 확인(룩업표 무수정).
- [ ] **Step 4: 커밋.** `docs(eval): pre-register feedback-NNN for Claude Design source switch`

---

### Task 9: 최종 통합 검증 게이트

**Files:** 없음(검증만)

- [ ] **Step 1: 전수 grep 게이트.**
  - `grep -rin 'stitch' dddart/commands dddart/agents` → **claude 인입 계층 0건**(소비 규율 final.md의 엔진중립 출력 필드는 별개).
  - `grep -rin 'figma' dddart/ codex-dddart/` → **양판 0건**.
  - `grep -rc 'stitch' codex-dddart/skills/dddart/SKILL.md` → **유지**(codex Stitch 무손상).
- [ ] **Step 2: 미러 일관 게이트.** Run: `for f in extract_design fetch_images extract_layout; do diff -q dddart/scripts/$f.dart codex-dddart/skills/dddart/scripts/$f.dart; done` → 전부 동일. Run: `python3 workspace/tools/corpus_mirror_sync.py --check` → inv2 통과(Makefile release `[2/7]`와 동일 게이트 — 한쪽만 바뀌면 exit≠0으로 릴리스 차단).
- [ ] **Step 3: 플래그 일관 게이트.** `grep -rn 'has_stitch_html' dddart/` → **0건**(claude). `grep -rn 'has_stitch_html' codex-dddart/` → **유지**(codex).
- [ ] **Step 4: 빌드·lint·픽스처.** Run: `bash dddart/scripts/test/run_fixtures.sh`(전체 PASS) + Makefile release dry 검사(미러 inv2 통과) + 가능한 lint.
- [ ] **Step 5: 최종 커밋·머지 준비.** 검증 전부 통과 시 사용자에게 머지/PR 승인 요청.

---

## 보류 (이 계획 범위 밖)

- **`extract_layout.dart --from-jsx` 모드 + layout-ir 배선**: 사용자 결정으로 **보류**. layout-ir 스키마 SSOT가 이 저장소 밖(생성 프로젝트)이라 단독 검증 불가 + 최난도 JSX-subset 파서. 화면 충실도는 ①크기 강제(§8 유지) + ②coder의 JSX 시안 충실 재현 + 육안 대조로 달성. 자동 채점(③)만 보류.

## 의존성 순서

```
Task1 (extract_design) ─┐
Task2 (fetch_images) ───┼─→ Task3 (dddart.md, 스크립트 호출) ─→ Task4 (에이전트)
                        │
Task5·6·7·8 (문서·codex, T3와 약결합·병렬 가능) ─→ Task9 (최종 검증 게이트)
```
