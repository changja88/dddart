# Claude Design PROJECT(.dc.html) 인입 — 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:subagent-driven-development`(권장) 또는 `superpowers:executing-plans`로 태스크별 집행. 스텝은 체크박스(`- [ ]`)로 추적.
> **설계 SSOT**: `workspace/design/2026-06-28-claude-design-project-source-design.md`(5렌즈 적대 리뷰 조건부합격·MF-1~4 반영본). 이 계획은 그 설계를 **어떤 순서·게이트·커밋 단위로** 집행할지의 오케스트레이션이다 — 산문 변경의 라인별 내용은 설계가 단일 출처(DRY), 계획은 순서·검증·커밋을 소유한다.

**Goal:** claude 판 dddart가 앱 PROJECT의 `.dc.html` 화면을 시안 출처로 읽어 시각 충실하게 Flutter로 옮긴다(broccoli 역할선택 *엉뚱한 화면 동결* 근본 차단).

**Architecture:** 신규 claude 전용 `extract_dc.dart`(아이콘·이미지·게이트텍스트 결정론 추출·미러 게이트 밖) + `dddart.md` Phase 0(PROJECT 출처·확인 게이트·동결·추출 순서) + 에이전트 3종(`.dc.html` 소비·device-chrome 제외·렌더 오라클). **미러 3종·`icon_map`·codex 무수정.**

**Tech Stack:** Dart(`extract_dc.dart`·픽스처 `test/run_fixtures.sh` F21), Markdown(오케스트레이터·에이전트), backstop·Makefile·corpus_mirror_sync(검증 게이트).

## Global Constraints (모든 태스크 암묵 적용)

- **코덱스·미러 무수정**: `codex-dddart/**`·`AGENTS.md`·미러 3종(`extract_design`·`fetch_images`·`extract_layout`)·`icon_map.json`을 **한 글자도** 바꾸지 않는다. 최종 게이트가 `diff -q`로 검증(=feedback-029 미러 불변·"코덱스 변경 없음" 사용자 결정).
- **feedback-015 공리 불변**: 코퍼스 레이아웃 어휘 0·시안=형상 단일근거·**L38 해제 금지**.
- **결정론**: 텍스트·아이콘·이미지 추출은 `extract_dc.dart`(스크립트). 코디네이터 본문 손-추출(=LLM 추출)은 금지(dddart.md L120).
- **device-chrome 제외**: `.stage/.phone/.statusbar/.decor`는 폰 목업 — 추출·재현 대상 아님. 앱 콘텐츠 = `.screen/.body` 내부.
- **출력 스키마 키 불변**: `design-tokens.json`(RMW로 `icons[]`·`unmappedIcons`만 주입)·`asset-manifest.json`(`{src,alt,local_path,token,status}`). 신규 `screen-meta.json`만 추가.
- **한글 주석·문서**.

## File Structure

- **Create**: `dddart/scripts/extract_dc.dart` · `workspace/eval/fix/feedback-030-claude-design-project-source.md`
- **Modify**: `dddart/scripts/test/run_fixtures.sh`(F21 추가) · `dddart/commands/dddart.md` · `dddart/agents/design-architect.md` · `dddart/agents/coder.md` · `dddart/agents/design-review-ui.md`
- **무수정(최종 게이트로 확인)**: 미러 3종 · `icon_map.json` · `codex-dddart/**` · `AGENTS.md`

---

## Task 0 (선행): 작업 브랜치

- [ ] 현재 `main` → `git checkout -b feat/claude-design-dc-source`. 각 태스크 끝 커밋·최종 머지는 사용자 승인 시.

## Task 1: `extract_dc.dart` + 픽스처 F21 (결정론 추출 핵심 · TDD)

**Files:** Create `dddart/scripts/extract_dc.dart` · Modify `dddart/scripts/test/run_fixtures.sh`
**계약(설계 §5):**
```
dart run extract_dc.dart <dc_html> --tokens <design-tokens.json> \
  --asset-manifest <asset-manifest.json> --assets-root <root> --asset-base <dir> \
  --meta <screen-meta.json> [--icon-map <icon_map.json>]
```
*전제: `extract_design --from-ds-manifest`가 **먼저** design-tokens.json을 산출(icons[] 빈 채). extract_dc는 그 파일을 RMW.*

- [ ] **S1: 픽스처 F21 먼저 작성(실패 확인)** — `run_fixtures.sh`에 F21 추가. 임시로 design-tokens.json(colors 1개·icons[] 빈)을 두고, 아래 `.dc.html`을 만들어 extract_dc 실행:
   ```html
   <x-dc><helmet><style>.title{}.subtitle{}.rtitle{}</style></helmet>
   <div class="stage"><div class="phone">
     <div class="decor"><span class="blob"></span></div>
     <div class="statusbar">
       <span class="material-symbols-rounded">signal_cellular_alt</span>
       <span class="material-symbols-rounded">wifi</span>
       <span class="material-symbols-rounded">battery_full</span></div>
     <div class="screen"><div class="body">
       <div class="brandtop"><img src="assets/icon.png" alt="Logo"></div>
       <div class="head"><div class="title">누가 사용하나요?</div>
         <div class="subtitle">사용자에 맞게 시작할 화면을 안내해드릴게요.</div></div>
       <div class="cards">
         <a class="rolecard" href="login.dc.html"><span class="ricon">
           <span class="material-symbols-rounded">manage_accounts</span></span>
           <span class="rtitle">부모입니다</span>
           <span class="material-symbols-rounded">chevron_right</span></a>
         <button class="rolecard"><span class="ricon">
           <span class="material-symbols-rounded">school</span></span>
           <span class="rtitle">자녀입니다</span>
           <span class="material-symbols-rounded">chevron_right</span></button>
       </div></div></div>
   </div></div></x-dc>
   ```
   **단언(grep)**: design-tokens.json `icons[]`에 `manage_accounts`·`school`·`chevron_right` **有** / `signal_cellular_alt`·`wifi`·`battery_full` **無**(device-chrome 제외·MF-4) / 기존 `colors` **보존**(RMW·MF-3) / `screen-meta.json` `"title":"누가 사용하나요?"`·`subtitle` 有·`cards`에 `부모입니다`·`자녀입니다`(MF-1) / `asset-manifest.json` `"status":"ok"`·`"local_path":"assets/images/`(icon.png 해소·복사) / icons[] 스키마 키(`name`·`fill`·`flutter`·`screens`).
   - [ ] 실행 → `extract_dc.dart` 부재로 FAIL 확인.
- [ ] **S2: `extract_dc.dart` 구현**(설계 §5 — 함수 골격, 인용 템플릿 명시):
   - `_appContent(html)`: `.screen` 서브트리만 반환(balanced `<div>` 깊이추적 — `extract_design.dart` `_balanced` 패턴을 태그로 적응). `.statusbar`·`.decor`·프레임(`.stage/.phone`)은 `.screen` 밖이라 자동 제외.
   - `_collectMsIcons(app, iconMap)`: `material-symbols-(rounded|outlined|sharp)` span 리거처 텍스트 수집 → `icon_map.json` 룩업(읽기)·미수록 `unmappedIcons`. `_IconAgg`/`_emitIcons` 출력 모양은 `extract_design.dart`와 동일.
   - `_collectImages(app, assetBase, assetsDir)`: `<img src>` 상대경로 해소·바이트 복사 → asset-manifest. `fetch_images.dart`의 `_fetchOne(resolveBase:)`·`_tagEnd`·`_parseAttrs`·`_camel`·`_uniqueToken` 로직을 **국소 복제**(미러 미변경·설계 §5 "약 50줄 대가").
   - `_gateText(app)`: `.head .title`·`.subtitle`·각 카드 `.rtitle` 텍스트 → `screen-meta.json`(`{title,subtitle,cards[]}`).
   - `_rmwTokens(tokensPath, icons, unmapped)`: design-tokens.json read → `icons`·`unmappedIcons`만 교체 → write(`colors`/`spacing`/`typography`/`borderRadius`/`arbitraryValues` 보존). **부재 시 fail-loud**(extract_design 선행 누락 신호).
   - fail-loud: 동적 `<img src={}>`·파일 부재는 `status` 표면화(fetch_images 동형). `.screen` 부재면 exit 1(동결 누락).
- [ ] **S3: F21 green + 무회귀** — `bash dddart/scripts/test/run_fixtures.sh` → F21 PASS·**F1~F20 전 PASS**(특히 F10/F12/F19/F20 extract_design·fetch_images 무회귀 = 미러 미변경 방증).
- [ ] **S4: 커밋** `feat(extract_dc): .dc.html 아이콘·이미지·게이트텍스트 결정론 추출 + 픽스처 F21`

## Task 2: `dddart.md` Phase 0 — PROJECT 출처·동결·추출 순서·확인 게이트

**Files:** Modify `dddart/commands/dddart.md` · **내용 SSOT**: 설계 §6-A(L36·step4.1~4.5·step5·L128) + §7(확인 게이트).
- [ ] **S1**: step4.1 — DesignSync 가용 시 **PROJECT URL/ID 직접 지목** 경로 추가(`/p/<projectId>`+`?file=<screen>.dc.html` 파싱·list_projects 비열거 고지)(설계 §6-A).
- [ ] **S2**: step4.2 — `updatedAt` 자동감지 제거·동결 스냅샷 재사용·**"다시 적용" 명시 요청 시만 재동결**(설계 §3·§6-A).
- [ ] **S3**: step4.3~4.5 — 후보에 PROJECT 루트 `*.dc.html` 포함 · **§7 확인 게이트**(screen-meta 인용·렌더 1:1·이름매핑 금지·목록 폴백) · 동결 범위(+`tokens/*.css`·`styles.css`·매칭 렌더) · **추출 순서 고정**(① extract_design → ② extract_dc RMW)(설계 §6-A·§7).
- [ ] **S4**: step5 G0 배너(`이번 화면:<시안>(확인됨)`)·L128 경계(`.dc.html` 합류)(설계 §6-A).
- [ ] **S5: 검증** — `dart run dddart/scripts/backstop.dart <임의 fixture> --diff-base <base>`(self-동작 무관 확인) + dddart.md 변경부가 미러 파일을 *재작성하지 않음* 인스펙션. 설계 §6-A/§7와 라인 대조.
- [ ] **S6: 커밋** `feat(dddart.md): PROJECT(.dc.html) 출처·확인 게이트·추출 순서·재사용 단순화`

## Task 3: 에이전트 — `.dc.html` 소비·device-chrome·렌더 오라클

**Files:** Modify `dddart/agents/{design-architect,coder,design-review-ui}.md` · **내용 SSOT**: 설계 §6-C.
- [ ] **S1**: `design-architect.md` — 동결 시안 `.dc.html` 가능 명시·**L38 불변**·재현 대상=`.screen/.body`·화면 고유 px 리터럴은 class→규칙 조인 인용·`icons[]=extract_dc 수집 수` 회계(L63)(설계 §5·§6-C).
- [ ] **S2**: `coder.md` — `.dc.html` 소비·`.screen/.body` 내부 재현·device-chrome 제외·**시각 오라클=동결 `screenshots/<render>.png`**(설계 §6-C).
- [ ] **S3**: `design-review-ui.md` — 충실도 대조에 `.dc.html` 포함(이미 CSS-var 어휘·소폭)(설계 §6-C).
- [ ] **S4: 검증** — 설계 §6-C와 대조 인스펙션 + `codex-dddart/skills/dddart-*` 동명 스킬 `git diff` 빈 출력(코덱스 무수정).
- [ ] **S5: 커밋** `feat(agents): .dc.html 형상-SoT 소비·device-chrome 제외·렌더 오라클`

## Task 4: feedback-030 사전등록 (코퍼스 measure-first)

**Files:** Create `workspace/eval/fix/feedback-030-claude-design-project-source.md`
- [ ] **S1**: 기존 feedback 메모 형식으로 사전등록 — 표(①대상 결함 ②원인 ③처방·파일 ④예상효과)·measure dim(**육안 오라클**: 역할선택 렌더↔시안 일치·device-chrome 미재현·아이콘 정확·게이트 작동 / **과적합 가드**: weather(Stitch) 무회귀·임의 `.dc.html` 일반성 / **이미지 strand 미해결 잔존 라벨**)·⑤⑥은 라이브런 후.
- [ ] **S2: 커밋** `docs(eval): feedback-030 claude-design PROJECT 출처 사전등록`

---

## 최종 게이트 (전 태스크 후 · 머지 전)

- [ ] **픽스처 전수**: `bash dddart/scripts/test/run_fixtures.sh` → **F1~F21 전 PASS**(F10/F12/F19/F20 무회귀).
- [ ] **코덱스·미러 무변경 검증(핵심)**:
   ```
   for f in extract_design fetch_images extract_layout; do
     diff -q dddart/scripts/$f.dart codex-dddart/skills/dddart/scripts/$f.dart; done
   diff -q dddart/scripts/icon_map.json codex-dddart/skills/dddart/scripts/icon_map.json
   git diff --stat codex-dddart/ AGENTS.md     # 빈 출력이어야 함
   ```
   전부 일치/빈 출력 = 미러 보존·codex 무변경. `extract_dc.dart`는 claude 단독(codex에 없음=정상).
- [ ] **corpus_mirror_sync**: `python3 workspace/tools/corpus_mirror_sync.py --check`(final.md 미러 — 본 작업 미참조라 통과).
- [ ] **설계 충실 인스펙션**: 변경 5파일이 설계 §5/§6/§7과 일치.
- [ ] **(검증 런·feedback-030 ⑤⑥)**: broccoli `56758e97`/`역할 선택.dc.html`로 라이브런 → **육안 렌더↔시안 대조**·device-chrome 미재현·아이콘·게이트 작동 확인 → feedback-030 실측 기록. *브랜드 로고 이미지 깨짐은 별도 strand라 예상된 잔존(불만 ① 미해결 라벨 확인).*

## Self-Review (작성자)

- **스펙 커버리지**: 설계 §5→T1 · §6-A+§7→T2 · §6-C→T3 · §10→T4 · MF-1~4 전부 태스크에 귀속(MF-1 screen-meta=T1 S2·T2 S3 / MF-2 렌더매칭=T2 S3 / MF-3 RMW순서=T1 S2·S1단언 / MF-4 device-chrome·CSS동결=T1 S2·T2 S3·T3 S1-S2) ✓
- **미러 불변·codex 무변경**: 최종 게이트 `diff -q`+`git diff --stat`로 강제 ✓
- **과적합 가드**: feedback-030이 weather 무회귀+일반성 측정 ✓
- **타입 일관성**: 출력 스키마 키 불변·`screen-meta.json` 신규만 ✓
- **플레이스홀더 0**: F21 단언·계약·함수 골격·인용 템플릿 구체 ✓

## 집행 핸드오프

구현 옵션:
1. **Subagent-Driven (권장)** — 태스크별 fresh implementer + 리뷰 게이트. `superpowers:subagent-driven-development`.
2. **Inline** — 이 세션 배치 집행. `superpowers:executing-plans`.

어느 쪽으로 집행할까요?
