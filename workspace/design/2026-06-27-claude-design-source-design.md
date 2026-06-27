# dddart 디자인 출처 전환 — claude=Claude Design / codex=Stitch 설계

> 2026-06-27. claude 판 dddart의 디자인 출처를 Google Stitch(MCP)에서 **Claude Design**(내장 `DesignSync` 읽기 도구)으로 전환한다. codex 판은 Stitch 유지. 양판에서 Figma(미실재 변종) 제거.
> **방법**: ultracode 워크플로우(조사 5 → 설계 → 5렌즈 적대적 리뷰 → 종합, 12 에이전트). 실측 근거: `DesignSync`로 사용자의 "브로콜리 Design System" 프로젝트를 직접 읽어 화면 JSX·토큰·`_ds_manifest.json` 형식 확인.

## 1. Goal

claude 판 dddart가 Flutter 기능을 빌드할 때, 디자인 출처를 **Claude Design에서 가져온다**. 사용자 목적은 **"Claude Design으로 디자인한 화면을 시각 충실하게 Flutter로 옮긴다"**(화면 통째 재현 — 토큰 일치로 축소하지 않음).

## 2. 사용자와 확정한 결정 (불가침)

| 항목 | 결정 |
|---|---|
| claude 디자인 출처 | **Claude Design** (내장 `DesignSync`, 읽기 전용) |
| codex 디자인 출처 | **Stitch 유지** (Claude Design은 표준 MCP 아님 → Codex 접근 불가) |
| Figma | 양판 모두 **제거** (`mcp__figma__*` 이름만 있는 미실재 변종) |
| 화면 충실도 최종 판단 | **육안** (claude.ai 캔버스 원본 ↔ `flutter run`). 기계 판단은 과거 성과 없음 → 스크린샷 동결 **불필요** |
| `layout-ir`(기계 구조 대조) | **보류** |
| 컴포넌트 범위 | 화면이 **실제 쓰는 것만**(YAGNI). 전체 라이브러리 일괄은 옵션 |

## 3. 핵심 설계 원칙 — 인입(ingest) 계층 한정

전환면은 전부 **디자인을 *획득*하는 인입 계층**에 갇힌다. design_system을 *쓰는* 규율(houserules 7토큰 골격·import 행렬·architecture-ui §7 foundation-only/`show()` 금지·ui_extension §5 `Icons.*`·discipline-reviewer)은 **엔진 무관**이라 양판 byte-identical 그대로 둔다.

> claude(Claude Design)와 codex(Stitch)는 토큰·화면·컴포넌트를 **"어떻게 획득하나"에서만 갈리고, "어떻게 쓰나"에서는 갈리지 않는다.** 화면 시각 충실도 게이트는 보존하되 비교 대상을 HTML→JSX로 재타깃한다(토큰 축소 금지).

## 4. Claude Design 실측 형식 (DesignSync로 확인)

- **접근**: 내장 도구 `DesignSync`(MCP 아님, claude.ai 로그인 + design scope). 읽기 메서드 `list_projects`/`get_project`/`list_files`/`get_file`. **읽기 전용** — `write_files`/`delete_files`/`create_project`/`finalize_plan`/`register_assets` 호출 절대 금지.
- **프로젝트 구조**: `tokens/*.css`(CSS 변수), `components/<group>/*.jsx`(React), `ui_kits/app/*Screen.jsx`(화면), `guidelines/*.card.html`, `_ds_manifest.json`(카탈로그).
- **`_ds_manifest.json`**: `tokens[]={name,value,kind(color|font|spacing|radius|shadow|other)}`(kind별 구조화 → 정규식 파싱 불요, **JSON 직독**), `components[]={name,sourcePath}`, `startingPoints[]`/`cards[]`(화면·viewport).
- **화면 JSX**: 인라인 flex/grid 스타일(절대좌표 아님), `var(--token)` 참조, `<Card><Badge>` DS 컴포넌트 조립, `window.BrkIcon` Material Symbols 아이콘명, `<img src>` 상대경로.

## 5. 스크립트 전략 — ADD-A-MODE (양판 미러 불변)

`extract_design`·`extract_layout`·`fetch_images` 3종은 claude(`dddart/scripts`)와 codex(`codex-dddart/skills/dddart/scripts`)에 **byte-identical 미러**다. 호출처는 오케스트레이터 단 1곳(claude=`dddart.md` L123-125 / codex=`SKILL.md` L137-138)이고, 에이전트는 산출물만 소비한다.

> **유일하게 안전한 방식 = ADD-A-MODE.** 기존 HTML/`--from-theme` 모드와 `main()` case·함수 시그니처를 **불변**으로 두고 신규 모드만 추가한 뒤, 동일 파일을 codex 미러에 복사해 byte-identical 복원. codex는 신규 모드를 **호출만 안 한다.** 출력 스키마(`design-tokens.json`·`asset-manifest.json`·`layout-ir.json`)는 다운스트림 계약이라 **키를 하나도 바꾸지 않는다.**

- **`extract_design.dart`** [저난도]: 신규 `--from-ds-manifest <manifest> [screen-jsx-dir]`. `--from-theme`(구조화 JSON→토큰 버킷)의 미러. `tokens[]`를 kind로 버킷(color→colors·font→typography·spacing→spacing·radius→borderRadius·shadow→arbitraryValues·other→drop), `var(--x)` 자기참조 해소, screen-jsx-dir 있으면 `window.BrkIcon` 이름을 스캔해 `icons[]`를 `icon_map` 룩업으로 채움.
- **`fetch_images.dart`** [중저난도]: `.html` 글롭을 `.jsx` 포함으로 확장 + `--asset-base`로 상대경로 src를 `design-ref`에 해소해 바이트 복사(현재는 상대경로가 전부 `skipped`). 동적 `<img src={expr}>`는 `fail-loud`(skipped/failed).
- **`icon_map.json`** [무수정]: Claude Design `BrkIcon`명 = Material Symbols명 = Stitch `data-icon`과 동일 키 공간 → 룩업표 그대로 재사용. 미수록은 `unmappedIcons`로 graceful.

## 6. 변경 명세

### 6-A. claude — `dddart/commands/dddart.md` (12 지점)

| 위치 | 변경 |
|---|---|
| L6 frontmatter | `mcp__stitch__*` 5종 삭제. (게이트 시) DesignSync 읽기 4종 등재, 부작용 메서드는 어떤 경우에도 미등재 |
| L16·L24 | `design-ref/` 입력 형식 교체: HTML 시안→화면 JSX, `designtheme.json`→`_ds_manifest.json`+`tokens/*.css`, `design.md`→`*.prompt.md`/`*.card.html`. `design-tokens.json` 출력명은 계약이라 유지 |
| L36 | `design_source` 포인터: `mcp` 키→`engine:"claude-design"`. `updateTime`→DesignSync staleness 신호(구현 시 확인) |
| **L54-56 (+123·124·137·161, 총 7곳)** | **`has_stitch_html`→`has_design_screen` 개명, 7참조 원자적 동시 갱신.** 발동 조건 '화면 HTML 동결'→'화면 JSX(`*Screen.jsx`) 동결'. 의미 보존. ⚠️ 하나라도 누락 시 게이트 silent off |
| L114-120 | 탐지: `·mcp__figma__*` 삭제(figma 제거 완결), `mcp__stitch__*` 스캔→DesignSync 가용성 확인. 읽기전용 규율을 DesignSync 4종으로 재명시. 재사용 3분기 골격 보존. `2개+`(다중 도구) 분기 삭제(단일 내장 엔진) |
| L121 | 시스템 출처 동결: `get_project` designTheme/designMd→`get_file`(`_ds_manifest.json`·`tokens/*.css`·`*.prompt.md`). '파일로 동결' 규율 보존 |
| **L122-125 (최대 규모)** | 화면 동결 `get_screen` htmlCode→`get_file`(`*Screen.jsx`). extract_design HTML 모드 호출→`--from-ds-manifest` 모드. fetch_images에 `--asset-base` 추가. theme 모드 소스→`_ds_manifest.json tokens[]`. 색 이원성(brandColors/colors) 분기 제거 |
| L128-129 | 해소 실패 표면화 어휘 교체 + **'JSX 직수입 금지' 명시 강화**(DesignSync 산출물이 React라 직수입 유혹↑ → JSX는 IR/토큰만 추출) |
| L130 | G0 배너: `<mcp>`→'Claude Design' 라벨, '연결 도구 없음'→'DesignSync 미가용' |
| L136-137 | architect 입력 토큰 서술 교체, 리뷰어 디스패치 `has_design_screen` 전파 |
| **L161 (불가침 G2 게이트)** | `has_design_screen` 전파, 시안 HTML→JSX. **G2 픽셀/육안 대조·`flutter run` 인간 오라클 절차 그대로 유지**(토큰 축소 금지) |
| L207 | 경계 절: '디자인 MCP 읽기 전용'→'디자인 엔진(DesignSync 내장) 읽기 전용' |

### 6-B. claude — 에이전트 (3개, codex 동명 파일은 무변경 = 엔진 비대칭)

| 파일 | 변경 |
|---|---|
| `agents/design-review-ui.md` | L13 플래그 개명+`design-tokens.json` shape를 `tokens[]` 직독으로. **L31: Tailwind 어휘(arbitraryValues·`text-[..]`·hover:)→CSS-var+inline-style 재표현** (naive 치환 시 referent dangling → 충실도 검사 헛통과 위험). L27: 화면 JSX의 DS 컴포넌트 재사용 점검 추가 |
| `agents/design-architect.md` | L22 `_ds_manifest.json tokens[]` 직독+kind→foundation 5토큰 매핑. L38 Tailwind 산물 재표현. **신규: components[]+화면 JSX 조립 근거로 '화면→design_system 위젯' 명시 매핑**(기본 YAGNI) |
| **`agents/coder.md`** ⭐ | (리뷰가 추가 발견) HTML 가정→동결 JSX 소비로. claude 전용 |

### 6-C. shared — 미러/공용 (codex 복사 또는 엔진중립화)

| 파일 | 변경 |
|---|---|
| `skills/architecture-ui/references/final.md` | L80·L113의 유일 'Stitch'/Tailwind 예시를 **엔진중립**화(byte-exact 미러라 한쪽만 바꾸면 릴리즈 차단). 3사본 `corpus_mirror_sync --write` 전파 |
| **`skills/implementation-flutter/references/final.md`** ⭐ | (리뷰가 추가 발견) §8·§9의 화면 HTML 결합 중립화. 미러 3사본 |
| `scripts/extract_design.dart` | `--from-ds-manifest` 모드 추가 + codex 복사 |
| `scripts/fetch_images.dart` | `.jsx` 글롭 + `--asset-base` + codex 복사 |
| `scripts/extract_layout.dart` | `--from-jsx` 모드 — **§7 보류에 종속** |
| `README.md` | L60·L92 디자인 출처를 엔진별 1줄로 분리(claude=Claude Design / codex=Stitch) |
| `AGENTS.md` | **의도된 엔진 비대칭 + '왜' 명시**(claude=Claude Design 내장→Codex 접근 불가→codex=Stitch). L37-38 미러 규칙 정정(스크립트는 '모드 추가'라 미러 유지) |
| `icon_map.json` | 주석만 선택적 일반화(룩업표 무수정) |
| `workspace/eval/fix/feedback-029-claude-design-source.md` | (create) 평가 폐곱 사전등록 메모 — 비대칭의 왜·변경 표면·게이트 보존 방침 |

### 6-D. codex — `codex-dddart/skills/dddart/SKILL.md` (2 지점, Stitch는 무수정)

| 위치 | 변경 |
|---|---|
| L131 | `(Stitch·Figma)`→`(Stitch)` (figma 제거) + 'claude의 `mcp__*` 네임스페이스와 다르다…동일 프로토콜' 정정(claude는 이제 Claude Design 내장 엔진). 탐지 골격·읽기전용 규율 유지 |
| L24 | 'MCP 연결 상이' 패리티 주장→'의도된 엔진 비대칭'으로 격상. **codex측 비대칭 '왜' 앵커** |

> codex의 Stitch 자산(`has_stitch_html`·extract_design HTML/theme 모드·읽기도구 5종·scripts)은 **전부 무수정** — 과잉 제거 금지.

## 7. 보류 — `layout-ir`(기계 구조 대조)

`extract_layout.dart`의 `--from-jsx` 모드는 최난도(JSX-subset 파서 신설 + DS컴포넌트/role→area/slot 번역표 + `.map()`→repeat-group)이고, 출력 `layout-ir` 스키마 SSOT가 **이 저장소 밖**(생성 프로젝트 `workspace/eval/tools/`)에 있어 단독 검증 불가. 게다가 사용자가 "기계 판단은 과거 성과 없음 → 육안"을 명시. **→ 보류.** 화면 충실도는 'JSX 충실 재현 + 육안 대조'로 우선 달성. 라이브 게이트 차단요인 아님.

## 8. 적대적 리뷰가 잡은 핵심 (5렌즈 전부 수용)

- **목적 충실**: `agents/coder.md`·`implementation-flutter/final.md`의 **숨은 HTML 결합** 추가 발견 → 빠뜨리면 화면 충실도 미달.
- **정확성/vacuous**: naive `Stitch→Claude Design` 치환은 Tailwind 어휘(`text-[..]` 등)의 referent를 dangling시켜 **충실도 검사가 조용히 헛통과(always-pass)**. → CSS-var+inline-style로 재표현 강제.
- **양판 대칭**: `architecture-ui/final.md`·스크립트는 byte-exact 미러(`corpus_mirror_sync` inv2 + Makefile release step) → 한쪽만 바꾸면 **릴리즈 exit 2 차단**. 엔진중립화 + 3사본 전파 / 스크립트 ADD-A-MODE로 해소.
- **회귀**: `has_stitch_html` 7참조 동시 개명(누락 시 게이트 silent off), DesignSync 읽기전용 규율, codex Stitch 무손상.

## 9. 구현 시 확인할 기술 세부 (사용자 결정 불필요)

1. DesignSync staleness 신호 필드 (`list_projects.updatedAt` 확인됨, `get_project`/`get_file` 레벨은 구현 시).
2. `allowed-tools` 게이트 방식 (DesignSync 내장 도구의 frontmatter 등재 여부).
3. `_ds_manifest.json` 색 value 별칭 해소 (리터럴 `#RRGGBB` + 별칭 `var(--x)` 혼합 확인됨 → 자기참조 해소).
4. Stitch 색 이원성(brandColors/colors) 분기를 Claude Design 단일 출처로 단순화.

## 10. 변경 규모 요약

- **claude 단독**: `dddart.md`(12 지점) + 에이전트 3개(`coder`·`design-review-ui`·`design-architect`)
- **shared**(미러/공용): `architecture-ui/final.md`·`implementation-flutter/final.md`·스크립트 3종(2 즉시 + 1 보류)·`README.md`·`AGENTS.md`·`icon_map.json`·신규 feedback 메모
- **codex 단독**: `SKILL.md` 2 지점(Figma 제거 + 비대칭 명시)

> 모든 변경이 **인입 계층**에 한정. design_system 소비 규율은 양판 byte-identical 불변.
