# 레이아웃 Stitch SoT 복원 — 구현 plan

> **For agentic workers**: 코퍼스 편집 plan(코드 아님). "테스트 사이클" = **앵커 grep(편집 전 현존 확인) → 편집 → 앵커 grep(신규 present·구 absent) → 양판 대칭 → 댕글링 0 스윕**. 단계는 `- [ ]` 체크박스.

**Goal**: 생성측 코퍼스에서 레이아웃 형상 어휘(`layout-ir`/area-tree)를 철거하고 레이아웃 형상 SoT를 Stitch 시안 HTML로 되돌린다.

**Architecture**: 설계 명세 `2026-06-22-layout-stitch-sot-design.md` 집행. architect=분해(State)·coder=시안 HTML 충실 재현. 값 운반(색·크기·이미지)·`extract_layout.dart`·FID 측정 서브시스템은 불가침.

**Tech Stack**: 코퍼스 markdown(`agents/`·`commands/`·`skills/*/references/final.md`) + `workspace/tools/corpus_mirror_sync.py`.

## Global Constraints (모든 Task 암묵 포함)

- **공리**: 코퍼스 레이아웃 어휘 0. 새 형상 규칙은 **열린 예시**(CSS→Flutter 매핑 *열거 금지* — 닫힌 표는 lossy 어휘 재발).
- **불가침**: `dddart/scripts/extract_layout.dart`(미변경)·`design-tokens`/size-link/`asset-manifest`(값 운반)·FID 측정(`fid-gate.sh`·`compare_layout`·`dump_to_ir`·`layout-ir-schema.md`·`RUBRIC §H`·`EVAL-METHOD`·`positive-control/fid`).
- **미러**: `final.md` 2종(architecture-ui·implementation-flutter) = `corpus_mirror_sync.py --write`(배포→소스+codex 자동). `agents/`·`commands/` = **수동** codex 미러(`codex-dddart/skills/.../SKILL.md`).
- **앵커 기반**: 라인 번호 아닌 *문구*로 grep(드리프트 대비). 아래 라인 번호는 2026-06-22 기준 참고값.
- **다음 런 동결**·**시술은 별도 승인**·**커밋은 사용자 요청 시**.

## File Structure

| 파일 | 책임 | 변경 | 미러 |
|---|---|---|---|
| `dddart/commands/dddart.md` | 파이프라인 배선 | layout-ir 생성·전달 제거 | 수동→`codex-dddart/skills/dddart/SKILL.md` |
| `dddart/agents/design-architect.md` | 설계 명세 작성 | area-tree·layout-ir 입력·self-check 제거 + 형상 미규정 1줄 | 수동→`dddart-design-architect/SKILL.md` |
| `dddart/agents/design-review-ui.md` | 화면 리뷰 | layout-ir L1 대조 제거(design-ref 대조 유지) | 수동→`dddart-design-review-ui/SKILL.md` |
| `dddart/agents/coder.md` | 구현 | design-ref 형상 SoT 승격 + carve-out | 수동→`dddart-coder/SKILL.md` |
| `dddart/skills/implementation-flutter/references/final.md` | coder 표기 규율 | **§9 신설**(형상=HTML 재현) + 목차 | auto(`--write`) |
| `dddart/skills/architecture-ui/references/final.md` | 화면 설계 규율 | §8:116 재작성(layout-ir 참조 제거) | auto(`--write`) |

---

### Task 1: 생성 파이프라인에서 layout-ir un-wire (`commands/dddart.md`)

**Files**: Modify `dddart/commands/dddart.md` (4곳).

- [ ] **Step 1**: 앵커 현존 확인 — `grep -nE 'has_layout_ir|레이아웃 IR도 추출|layout-ir.json' dddart/commands/dddart.md` → 4 매치 기대(L56·124·137·138).
- [ ] **Step 2**: `has_layout_ir` 플래그 정의 줄(L56) 삭제. 앵커: `"has_layout_ir": "<bool — 화면 HTML에서 layout-ir.json`. (build-state schema에서 그 JSON 줄 통째 제거.)
- [ ] **Step 3**: extract_layout 호출(L124) 제거. 앵커 시작 `**이어서 같은 동결 HTML에서 레이아웃 IR도 추출**한다` ~ 끝 `**exit 1**(HTML 없음·body 없음)이면 \`has_layout_ir=false\`로 두고 진행한다(layout 강제 없이 산문 분해 폴백 — 정상).` 까지의 문장 삭제. **주의**: 바로 다음 `**이어서 같은 동결 HTML의 이미지도 다운로드**`(fetch_images)는 유지. 연결어 자연스럽게 봉합.
- [ ] **Step 4**: architect 입력(L137)에서 `· \`layout-ir.json\` 경로(\`has_layout_ir\`이면 — 화면 area 골격 L1[appbar/image/section/bottomnav 존재·종류·순서]·L2 섹션 구성의 결정론 구조 입력)` 절 삭제(앞뒤 `·` 구분 봉합).
- [ ] **Step 5**: review-ui 입력(L138)에서 `\`has_layout_ir\`이면 \`layout-ir.json\` 경로를 ui에` 절 삭제.
- [ ] **Step 6**: 검증 — `grep -cE 'has_layout_ir|레이아웃 IR도 추출|layout-ir' dddart/commands/dddart.md` → **0**. `grep -c 'fetch_images\|asset-manifest\|extract_design' dddart/commands/dddart.md` → 유지(>0·값 운반 불변).

### Task 2: design-architect area-tree 제거 (`agents/design-architect.md`)

**Files**: Modify `dddart/agents/design-architect.md` (3곳: L23·L39·L64).

- [ ] **Step 1**: 앵커 확인 — `grep -nE 'layout-ir|area 어휘 트리|위젯 클래스명|has_layout_ir' dddart/agents/design-architect.md`.
- [ ] **Step 2**: L23 layout-ir 입력 bullet 삭제. 앵커 시작 `- (있으면) \`layout-ir.json\` 경로 — Coordinator가 같은 동결 HTML에서 기계 절단한 화면 *구조* IR` ~ bullet 끝 `명세엔 area 어휘 트리(아래 화면 절)로 옮긴다.`
- [ ] **Step 3**: L39 area-tree 절 삭제. 앵커 시작 `**\`layout-ir.json\`이 있으면(\`has_layout_ir\`) 화면 골격을 명세 화면 절에 *강제로* 박는다**` ~ 끝 `(layout-ir는 읽는 입력·area 트리는 산문 명세 — format tax 회피).` **유지**: 같은 bullet의 크기 정형목록(`arbitraryValues`·`typography`)·이미지 정형목록(`asset-manifest`) 부분은 보존(값 운반).
- [ ] **Step 4**: L39 삭제 자리에 ㉤ 추가:
  > 레이아웃 형상(배치·축)은 명세에 적지 않는다 — coder가 design-ref에서 재현한다(architecture-ui §8·implementation-flutter §9). 너는 분해·토큰·이미지·내비까지.
- [ ] **Step 5**: L64 self-check 삭제. 앵커 `**\`has_layout_ir\`이면** 화면 절이 layout-ir의 L1 골격(area 존재·종류·순서)을 area 어휘 트리로 반영했는지도 이 스캔에서 함께 대조한다 — 빠뜨리면 강제가 죽은 지침이 된다.` (design-tokens·has_design_images 자기점검은 유지.)
- [ ] **Step 6**: 검증 — `grep -cE 'layout-ir|area 어휘|위젯 클래스명.*박지|직교 보존' dddart/agents/design-architect.md` → **0**. `grep -c 'arbitraryValues\|asset-manifest\|화면 분해' dddart/agents/design-architect.md` → 유지(>0). ㉤ 앵커 `coder가 design-ref에서 재현` present.

### Task 3: design-review-ui L1 대조 제거 (`agents/design-review-ui.md`)

**Files**: Modify `dddart/agents/design-review-ui.md` (L13·L32).

- [ ] **Step 1**: L13에서 `**\`has_layout_ir\`이면 \`layout-ir.json\`(동결 HTML에서 기계 절단한 area 골격·섹션 구성) 경로도 받는다** — 화면 구조 충실도 대조의 기계 근거다.` 삭제(has_stitch_html 토큰 문장은 유지).
- [ ] **Step 2**: L32 `**레이아웃 골격 대조**(\`has_layout_ir\`이면 발동...)` bullet 통째 삭제. **유지**: L30 `**design-ref 대조**(이미지가 있으면): 명세의 화면 분해·요소 목록이 디자인 이미지와 정합...` (완전성 점검 — §7 흡수처).
- [ ] **Step 3**: 검증 — `grep -cE 'has_layout_ir|레이아웃 골격 대조|layout-ir' dddart/agents/design-review-ui.md` → **0**. `grep -c 'design-ref 대조\|요소 목록이 디자인 이미지와 정합' dddart/agents/design-review-ui.md` → 유지(>0).

### Task 4: coder design-ref 형상 SoT 승격 + carve-out (`agents/coder.md`)

**Files**: Modify `dddart/agents/coder.md` (L15·L24·L39).

- [ ] **Step 1**: L24 교체. old `- (있으면) \`design-ref/\` — 화면 구현 시 시각 근거.` → ㉡:
  > - (있으면) `design-ref/` — **화면 레이아웃 형상의 단일 근거.** 배치·축(세로/가로)·그룹핑·정렬·간격은 명세가 아니라 이 시안 HTML이 정하고 너는 충실 재현한다(implementation-flutter §9). *시각 근거*에 그치지 않는다.
- [ ] **Step 2**: L15 carve-out. 앵커 `너는 명세의 집행자다 — 구조·계약·메커니즘을 새로 결정하지 않는다.` 뒤에 추가:
  > 단 **레이아웃 형상(배치·축)은 예외 — design-ref 시안이 근거다**(implementation-flutter §9). 형상 부재는 반송 사유가 아니다.
- [ ] **Step 3**: L39 disambiguation. 앵커 `구조를 새로 결정하지 않고 명세를 집행한다. 명세에 구조 결정이 없으면 임의로 정하지 말고 보고한다(설계로 반송).` 뒤에 추가:
  > **'구조 결정'은 *분해*(view/section/widget·파일 배치)이지 *레이아웃 형상*이 아니다** — 명세가 축·배치를 안 적은 것은 정상이며(코퍼스는 형상 미규정) 반송 사유가 아니다. 형상은 design-ref에서 가져와 재현한다.
- [ ] **Step 4**: 검증 — `grep -cE '레이아웃 형상의 단일 근거|형상은 design-ref|형상.*예외' dddart/agents/coder.md` → 3. `grep -c '시각 근거' dddart/agents/coder.md` → 0(승격 완료).

### Task 5: implementation-flutter §9 신설 (`references/final.md`)

**Files**: Modify `dddart/skills/implementation-flutter/references/final.md`(배포본·`--write`로 미러).

- [ ] **Step 1**: §8(`## §8. 정적 이미지 에셋`) 마지막 내용 뒤(EOF)에 신설 절 ㉠ 추가:
  > ## §9. 레이아웃 형상 — 시안 HTML 충실 재현
  >
  > 화면의 *형상*(요소가 세로로 쌓이나/가로로 놓이나·그룹핑·정렬·간격)은 코퍼스가 규정하지 않는다. `design-ref/`의 동결 HTML 시안이 형상의 단일 근거이며 너는 그것을 **빠짐없이** dddart 위젯으로 재현한다. 명세는 *무엇을*(분해·토큰·이미지)을 정하고 *어떻게 배치*는 정하지 않는다 — 배치는 시안에 있다.
  >
  > - **형상 근거는 HTML(텍스트)**: PNG가 아니라 `design-ref/*.html`의 컨테이너 구조를 읽는다(예: `flex-col`→`Column`. *이건 예시이지 닫힌 목록이 아니다* — 시안의 모든 배치 단서를 충실히 옮긴다). 이미지 비보장 엔진에서도 HTML은 텍스트라 동일하게 읽힌다.
  > - **재현이지 직수입이 아니다**: HTML에서 *형상*을 읽어 dddart 위젯으로 짠다 — HTML/CSS를 그대로 복붙하거나 디자인툴 생성 코드를 직수입하지 않는다(기존 경계 유지).
  > - **형상은 명세가 아니라 시안 소관**: 명세 화면 절에 축·배치가 없는 것은 정상이다(architecture-ui §8) — 반송하지 말고 시안에서 형상을 가져온다.
- [ ] **Step 2**: 목차(`## 목차`, L8~) 갱신 — `§9. 레이아웃 형상 — 시안 HTML 충실 재현` 항목 추가(기존 목차 형식 따라).
- [ ] **Step 3**: 검증 — `grep -nE '§9. 레이아웃 형상|형상 근거는 HTML|재현이지 직수입' dddart/skills/implementation-flutter/references/final.md` → present. **닫힌 표 금지 확인**: 새 절에 CSS→Flutter 매핑이 1개 예시(`flex-col→Column`)만 있고 열거 표 없는지 육안 확인.

### Task 6: architecture-ui §8:116 재작성 (`references/final.md`)

**Files**: Modify `dddart/skills/architecture-ui/references/final.md`(배포본).

- [ ] **Step 1**: L116 bullet 교체. old `- **layout-ir와 직교**: area 트리(design-architect)의 크기 없는 slot은 layout-ir(픽셀 미포함)이 아니라 *이 규율이* 토큰 트랙에서 메운다 — 상대 기하는 IR이 가지고, 절대 크기는 토큰이 가진다(픽셀은 IR에 들어가지 않는다).` → ㉣:
  > - **형상과 직교**: 이 규율은 *절대 크기*만 다룬다. 요소의 *배치·축*은 코퍼스가 규정하지 않는다 — design-ref 시안이 형상 근거이고 coder가 재현한다(implementation-flutter §9). 크기='얼마나 큰가', 형상='어떻게 놓이나' — 둘은 직교하며 후자는 코퍼스 밖(시안)이 소유한다.
- [ ] **Step 2**: 검증 — `grep -c 'layout-ir와 직교\|area 트리(design-architect)' dddart/skills/architecture-ui/references/final.md` → **0**. `grep -c '형상과 직교' dddart/skills/architecture-ui/references/final.md` → 1. §8 본문(size-link L111~115)·§7(app_asset) 유지 확인.

### Task 7: final.md 양판 동기 (`corpus_mirror_sync.py --write`)

**Files**: 자동 — `workspace/reference/{architecture-ui,implementation-flutter}/reference/final.md`(소스) + `codex-dddart/skills/{architecture-ui,implementation-flutter}/references/final.md`(codex).

- [ ] **Step 1**: 동기 실행 — `python3 workspace/tools/corpus_mirror_sync.py --write`.
- [ ] **Step 2**: 검사 — `python3 workspace/tools/corpus_mirror_sync.py --check` → exit **0**(drift 0).
- [ ] **Step 3**: 3사본 앵커 확인 — `grep -rl '§9. 레이아웃 형상' dddart/ codex-dddart/ workspace/reference/` → 3 파일(impl-flutter 배포·codex·소스). `grep -rl '형상과 직교' dddart/ codex-dddart/ workspace/reference/` → 3 파일(architecture-ui). **설계 §9 "세 번째 사본" 우려 해소 확인**(소스 = `workspace/reference` = `--write` 자동 처리).

### Task 8: codex 수동 미러 — agents·commands (`codex-dddart/skills/`)

**Files**: Modify `codex-dddart/skills/dddart/SKILL.md`·`dddart-design-architect/SKILL.md`·`dddart-design-review-ui/SKILL.md`·`dddart-coder/SKILL.md`. (`agents/`·`commands/`는 `--write` 비대상 → 수동.)

- [ ] **Step 1**: Task 1 등가 — `codex-dddart/skills/dddart/SKILL.md`에서 layout-ir 생성·전달 제거(앵커 L138·152의 `layout-ir.json`·`has_layout_ir`·`레이아웃 IR도 추출`). fetch_images/extract_design 유지.
- [ ] **Step 2**: Task 2 등가 — `dddart-design-architect/SKILL.md`(L22·38·44·48·63)에서 area-tree·layout-ir 제거 + ㉤ 추가. codex 특수: design-ref 입력 서술에서 layout-ir만 제거.
- [ ] **Step 3**: Task 3 등가 — `dddart-design-review-ui/SKILL.md`(L16·35)에서 layout-ir L1 제거(design-ref 대조 유지).
- [ ] **Step 4**: Task 4 등가 + **㉥** — `dddart-coder/SKILL.md`(L21·24)에서 design-ref 형상 SoT 승격. **codex 특수 문구**: 형상 근거는 `notes.md`(축 없음)가 아니라 **HTML 시안**(텍스트라 codex가 직접 읽음). old `- (있으면) \`design-ref/\` — 화면 구현 시 시각 근거(Codex에서는 \`notes.md\` 메모가 우선, 이미지는 보조).` → 형상 SoT 승격 + "형상엔 HTML, notes.md는 값 보조".
- [ ] **Step 5**: 검증(양판 대칭) — `grep -cE 'layout-ir|area 어휘|위젯 클래스명.*박지' codex-dddart/skills/dddart-design-architect/SKILL.md codex-dddart/skills/dddart/SKILL.md` → **0**. coder 승격 앵커(`형상의 단일 근거` 류) codex에도 present. claude↔codex 개념 대칭(문구는 엔진별 상이 허용).

### Task 9: 최종 정합성 스윕 (양 엔진)

**Files**: 읽기 전용 검증.

- [ ] **Step 1**: 생성측 layout-ir 잔존 0 — `grep -rnE 'layout-ir|area 어휘 트리|has_layout_ir|위젯 클래스명.*박지|직교 보존' dddart/agents dddart/commands dddart/skills/architecture-ui dddart/skills/implementation-flutter codex-dddart/skills/dddart codex-dddart/skills/dddart-design-architect codex-dddart/skills/dddart-design-review-ui codex-dddart/skills/dddart-coder codex-dddart/skills/architecture-ui codex-dddart/skills/implementation-flutter` → **0 매치**.
- [ ] **Step 2**: 불가침 무변경 — `git diff --stat`에 `dddart/scripts/extract_layout.dart`·`codex-dddart/skills/dddart/scripts/extract_layout.dart`·`workspace/eval/` **없음** 확인. `git status workspace/eval/tools/fid-gate.sh workspace/eval/rubric/RUBRIC.md` clean.
- [ ] **Step 3**: 값 운반 무변경 — design-tokens/size-link/asset 앵커 양판 존속(`grep -c 'arbitraryValues\|asset-manifest\|app_asset' …` 변동 없음).
- [ ] **Step 4**: 미러 최종 — `python3 workspace/tools/corpus_mirror_sync.py --check` → 0. agents/commands 양판 개념 대칭 육안.
- [ ] **Step 5**: 보고 — 변경 파일 목록(diff stat) + 앵커 검증 결과 + "extract_layout/FID/값운반 불변" 1줄 + measure-first 육안 체크리스트(설계 §10) 첨부. **커밋은 사용자 요청 시.**

---

## Self-Review (작성자 점검)

- **Spec 커버리지**: 설계 §5 변경 7파일 전부 Task 매핑(commands=T1·architect=T2·review-ui=T3·coder=T4·impl-flutter=T5·architecture-ui=T6·codex=T8). §6 문구 ㉠~㉥ 전부 Task에 인라인. §8 정합성 교정(extract_layout 보존) = Global Constraint·T9 Step2. §9 미러(3사본) = T7. §10 육안 체크리스트 = T9 Step5.
- **Placeholder**: 없음 — 각 편집에 앵커 + 신규 문구 인라인.
- **타입/앵커 일관**: §9 참조를 impl-flutter "§9"로 통일(㉡·㉣·㉤·design-architect 전부 §9). architecture-ui "§8"(size-link) 미변경 유지.
- **순서**: claude 편집(T1~6) → final.md 자동미러(T7) → codex 수동미러(T8) → 스윕(T9). 의존 정합.
- **불가침 가드**: extract_layout·FID·값운반 = Global Constraint + T9 Step2~3 명시 검증.
