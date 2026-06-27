# feedback-029 — Claude Design 출처 전환 사전등록: claude=Claude Design / codex=Stitch 비대칭

> 2026-06-27. **사전등록형** — 시술 전 예상효과를 박고, 다음 라이브런 결과지로 실측을 채워 대조한다.
> 설계 SSOT: `workspace/design/2026-06-27-claude-design-source-design.md`.

## 메타
- **회차**: 029
- **트리거**: 사용자 결정 "Claude Design으로 디자인한 화면을 시각 충실하게 Flutter로 옮긴다" — DesignSync 직접 실측(`브로콜리 Design System` 프로젝트 확인) 후 전환 확정.
- **베이스 코퍼스**: `4600fba` (v1.0.2)
- **시술 커밋**: `b491061`~(이 브랜치, 진행 중)
- **검증 런**: `results/<다음 라이브런 결과지>` (재라이브런 후 채움)
- **상태**: 적용됨

---

## 비대칭의 왜 (설계 §2)

| 판 | 디자인 엔진 | 근거 |
|---|---|---|
| **claude** | **Claude Design** (내장 `DesignSync`) | claude.ai 로그인 + design scope로 직접 접근 가능. 읽기 메서드 4종(`list_projects`·`get_project`·`list_files`·`get_file`). **표준 MCP 아님** — claude.ai 전속 내장 도구 |
| **codex** | **Stitch 유지** | Claude Design은 OpenAI Codex에서 접근 불가(claude.ai 전속). Stitch는 표준 MCP(`mcp__stitch__*`)라 Codex도 동일 프로토콜로 접근 가능. **codex Stitch 무손상 정책** |
| 양판 | Figma **제거** | `mcp__figma__*` 이름만 있는 미실재 변종 — 양판 동시 제거 |

> **결론**: 비대칭은 버그가 아니라 **의도된 설계**(AGENTS.md에 명시). claude=Claude Design / codex=Stitch가 정상 상태.

---

## 변경 표면 — 인입(ingest) 계층 한정 (설계 §3)

전환면은 전부 **디자인을 획득하는 인입 계층**에 갇힌다. design_system을 *소비*하는 규율(houserules 7토큰 골격·arch-ui §7 foundation-only/`show()` 금지·discipline-reviewer)은 **엔진 무관**이라 양판 byte-identical 불변.

| 범위 | 파일 | 핵심 변경 |
|---|---|---|
| **claude 전용** | `commands/dddart.md` (12 지점) | Stitch MCP → Claude Design `DesignSync`. `has_stitch_html`→`has_design_screen` 7참조 원자적 개명. G2 육안 게이트 보존. JSX 직수입 금지 명시 강화 |
| **claude 전용** | `agents/design-review-ui.md` | Tailwind 어휘(`text-[..]`·hover:)→CSS-var+inline-style 재표현(naive 치환 시 referent dangling → 충실도 검사 always-pass 위험 차단). `tokens[]` 직독 |
| **claude 전용** | `agents/design-architect.md` | `_ds_manifest.json tokens[]` 직독 + kind→foundation 5토큰 매핑. components[]+JSX→design_system 위젯 명시 매핑 |
| **claude 전용** | `agents/coder.md` | HTML 가정→동결 JSX 소비(숨은 HTML 결합 제거) |
| **shared 미러** | `skills/architecture-ui/references/final.md` | 'Stitch'/Tailwind 예시→엔진중립. `corpus_mirror_sync --write` 3사본 전파 |
| **shared 미러** | `skills/implementation-flutter/references/final.md` | §8·§9 화면 HTML 결합 중립화. 3사본 전파 |
| **shared 미러** | `scripts/extract_design.dart` | `--from-ds-manifest <manifest> [screen-jsx-dir]` 모드 추가(ADD-A-MODE — 기존 `--from-theme` 모드·시그니처 불변). codex byte-identical 복사 |
| **shared 미러** | `scripts/fetch_images.dart` | `.jsx` 글롭 확장 + `--asset-base`로 상대경로 src→`design-ref` 해소. codex 복사 |
| **shared 미러** | `scripts/icon_map.json` | 주석만 엔진중립화(룩업표 `icons` 객체 무수정). codex 복사 |
| **codex 전용** | `codex-dddart/skills/dddart/SKILL.md` (2 지점) | Figma 제거. 'MCP 연결 상이'→'의도된 엔진 비대칭' 격상 + '왜' 앵커 |
| **공용** | `README.md`·`AGENTS.md` | 엔진별 출처 명시. 비대칭 '왜' 앵커 |

**§7 보류**: `extract_layout.dart --from-jsx` 모드 — JSX 파서 신설 최난도 + SSOT 외부(`workspace/eval/tools/`) → 보류. 시각 충실도는 'JSX 충실 재현 + 육안 대조'로 우선 달성.

---

## 시각 충실도 게이트 보존 방침 (불가침, 설계 §2)

- **게이트 G2 원칙 불변**: `flutter run` + claude.ai 캔버스 원본 **육안 대조**. 기계 판단(토큰 일치) 축소 금지.
- **비교 대상만 재타깃**: 화면 HTML → 화면 JSX(`*Screen.jsx`). 게이트 판단 절차·인간 오라클 동일.
- **`has_stitch_html`→`has_design_screen`**: 동결 조건 '화면 HTML'→'화면 JSX 동결'. 7참조 원자적 개명 필수 — 누락 1곳이라도 게이트 silent off(항상 통과·항상 차단).
- **JSX 직수입 절대 금지**: DesignSync 산출물이 React JSX라 직수입 유혹↑ → JSX는 IR·토큰 추출 전용. Flutter 코드에 React 코드 혼입 차단.

---

## 교정 항목 (사전등록 표 — 다음 런 전 ①~④ 작성 완료, ⑤~⑥ 런 후 채움)

| # | 우선 | ① 대상 결함(dim) | ② 원인(뿌리) | ③ 처방(파일·미러경로) | ④ **예상효과**(전→후) | ⑤ 시술커밋 | ⑥ 실측·판정 |
|---|---|---|---|---|---|---|---|
| 1 | 높음 | claude 판 디자인 인입이 Stitch MCP 전용 — Claude Design 화면 직접 획득 불가 | `dddart.md` 전체가 Stitch 흐름(탐지·`get_screen`·`--from-theme`) | `commands/dddart.md` 12지점(Stitch→DesignSync 전환) | claude 판이 `_ds_manifest.json`·`*Screen.jsx` 직독으로 화면 JSX·토큰 획득 가능 → 인입 전환 완결 | `1e37b5f`~ | (런 후) |
| 2 | 높음 | `has_stitch_html` 7참조 중 1개라도 미개명 시 G2 게이트 silent off | 참조 7곳 중 일부 누락 가능성 | `dddart.md` 7참조 동시 `has_stitch_html`→`has_design_screen` 원자적 개명 | G2 게이트가 '화면 JSX 동결' 조건으로 정상 발동(silent off 제거) | `1e37b5f` | (런 후) |
| 3 | 높음 | `design-review-ui` 충실도 검사가 Tailwind 어휘 기준 → Claude Design JSX 문맥에서 referent dangling → always-pass | `design-review-ui.md` L31이 Tailwind 어휘(`text-[..]`·hover:)로 검사 기준 정의 | `agents/design-review-ui.md` L31 Tailwind→CSS-var+inline-style 재표현 | 충실도 검사가 `var(--token)`·inline-style 실제 어휘로 검사 → always-pass 위험 제거 | `049ec7c` | (런 후) |
| 4 | 높음 | `coder.md`·`implementation-flutter/final.md`에 HTML 가정 잔존 → 에이전트가 Stitch HTML 산출물 기대(숨은 결합) | shared 미러 파일·coder 에이전트에 'HTML 시안' 어휘 하드코딩 | `agents/coder.md` + `skills/implementation-flutter/references/final.md` 엔진중립화 + 3사본 전파 | 에이전트가 JSX/manifest 소비로 전환, HTML 결합 0 | `049ec7c`·`1a6c7e5` | (런 후) |
| 5 | 중간 | codex 판에서 비대칭 '왜' 미명시 → 향후 codex Stitch 과잉 제거 압력 위험 | `SKILL.md`가 'MCP 연결 상이' 수준 기술 — 의도 근거 없음 | `codex-dddart/skills/dddart/SKILL.md` L24 비대칭 '왜' 앵커 + `AGENTS.md` 설명 | codex 판이 의도된 비대칭을 인지·유지 → 과잉 제거 위험 제거 | `abd2884`·`58a4dda` | (런 후) |
| 6 | 낮음 | `icon_map.json` 주석이 'Stitch data-icon' 전용 기술 → Claude Design `BrkIcon` 키 공간 동일성 불투명 | 주석이 단일 엔진(Stitch) 관점으로만 작성됨 | `scripts/icon_map.json` `_comment` 엔진중립화(룩업표 `icons` 객체 무수정). codex 미러 | 주석이 양 엔진 키 공간 동일성 명시 → 혼란·중복 맵핑 방지 | (이번 태스크) | (런 후) |

- **④예상효과**: 모든 항목이 인입 계층 한정 — design_system 소비 규율 dim(FC-1·FC-2 등 기존 골든) 변동 없음. 새로 측정이 필요한 dim은 아래.
- **`layout-ir` 보류**: `extract_layout.dart --from-jsx` 미처방. §7 보류 결정(최난도 + SSOT 외부). 측정 제외.

---

## 다음 라이브런 측정 dim

| dim | 측정 방법 | 목표 |
|---|---|---|
| **claude 인입 전환** | 라이브런 transcript에서 `DesignSync`(`list_projects`·`get_file`) 호출 흔적 + `_ds_manifest.json` 직독 확인 | Stitch 0호출·DesignSync 사용 확인 |
| **codex Stitch 무손상** | codex 판 라이브런에서 `mcp__stitch__*` 정상 호출 + `has_stitch_html` 잔존 확인(미개명 = 정상) | Stitch 과잉 제거 없음 |
| **G2 게이트 원자성** | claude 판 G2 지점에서 `has_design_screen` 조건 평가 흔적(7참조 중 발동하는 곳 수) | 7참조 전부 `has_design_screen` 발동 |
| **충실도 검사 어휘** | `design-review-ui` 에이전트가 `var(--token)`·inline-style 어휘로 검사 — Tailwind 어휘 출현 0 | always-pass 위험 없음 |
| **byte-identical 미러** | `diff -q dddart/scripts/extract_design.dart codex-dddart/.../extract_design.dart` 외 2종 | divergence 0 |
| **시각 충실도 G2** | `flutter run` + claude.ai 캔버스 육안 대조 수행 여부 | 게이트 절차 불변 확인(토큰 일치로 대체 안 됨) |

---

## 회차 요약 (다음 런 후)
- 예상 적중 **N/M** · 무효 **N** · ⚠️역효과/신규회귀 **N**
- **한 줄 결론**:
- ⚠️ N=1 인과 단정 금지 — "처방 X가 회귀 Y를 *유발*"이 아니라 "X 적용 후 Y 관찰(동시발생)"로 기록.
