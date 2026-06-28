# dddart 앱 화면 출처 — Claude Design PROJECT(.dc.html) 인입 설계

> 2026-06-28. claude 판 dddart가 화면 시안을 **디자인시스템 프로젝트의 예시 화면**이 아니라 사용자의 **앱 PROJECT 타입 프로젝트**(`.dc.html` 화면)에서 가져오게 한다. feedback-029(Stitch→Claude Design 전환)의 후속·확장.
> **근거**: broccoli_app 역할선택 충실도 실패 전면 ROC + 4렌즈 적대 리뷰(워크플로우 wmhzhv3lj) + DesignSync 직접 실측(사용자 앱 프로젝트 `56758e97…` get_project/list_files/get_file 통과·`역할 선택.dc.html` 직독) + 설계 5렌즈 적대 리뷰(wbdgmqr6d·**조건부적합 → MF-1~4 반영**). SSOT 평가 메모: `workspace/eval/fix/feedback-030-*.md`(작성 예정).

## 1. Goal

claude 판 dddart가 기능을 빌드할 때, **사용자가 Claude Design에서 실제로 그린 앱 화면**(`.dc.html`, 별도 PROJECT)을 시안으로 가져와 시각 충실하게 Flutter로 옮긴다. 디자인시스템(키트)은 *토큰·컴포넌트 의도*의 출처로 계속 쓰되, **화면 형상의 출처는 앱 PROJECT의 `.dc.html`**이다.

## 2. 배경 — broccoli ROC (왜 이 설계가 필요한가)

Claude Design은 **디자인시스템과 앱 화면을 별도 프로젝트**로 둔다(실측 확정):

```
사용자 계정
├─ "브로콜리 Design System"  (type=DESIGN_SYSTEM·키트)   ← dddart가 잘못 바인딩
│    └─ ui_kits/app/*Screen.jsx  = 키트 자체 예시 6화면(Home/Onboarding=학년선택/Quiz/Report/Tutor)
└─ "Broccoli 부모 앱 온보딩" (type=PROJECT·실제 앱)       ← 진짜 화면은 여기
     ├─ 역할 선택.dc.html · 부모앱 온보딩 로그인.dc.html
     ├─ _ds/design-system-8f6f69b3…/  (디자인시스템 토큰 동봉·참조)
     └─ screenshots/role.png · login.png …
```

dddart의 `design_source`는 **DESIGN_SYSTEM 프로젝트**(키트)만 가리킬 수 있었다 — `DesignSync.list_projects`가 design-system 타입만 열거하기 때문. 사용자가 역할선택을 요청하자 dddart는 키트의 예시 화면 중 가장 비슷한 OnboardingScreen(학년선택)을 *조용히* 시안으로 동결·각색했고, feedback-015 공리(시안=형상 진실)상 그 결과는 학년선택 화면의 충실 재현이 됐다. **사용자 불만 6건 중 5건이 "엉뚱한 시안 동결"에서 발원**(나머지 1건=이미지 256KiB 절단·별개 strand).

→ 근본: **출처 모델이 "앱 화면 = 디자인시스템 안"으로 잘못 가정**. 진짜는 "앱 화면 = 별도 PROJECT(키트 참조)".

## 3. 사용자와 확정한 결정 (불가침)

| 항목 | 결정 |
|---|---|
| 앱 화면 출처 | 사용자의 Claude Design **PROJECT 타입 프로젝트**(`.dc.html` 앱 화면) |
| 출처 지정·재사용 | G0에서 **프로젝트 URL/ID 입력** → `config.design_source`에 저장 → 2회차부터 재사용 (Stitch와 동일·한 번만) |
| **화면 확인 게이트** | **무조건** — 이름으로 찾기 → 렌더+핵심문구로 "이 화면 맞나요?" 확인 → 승인 전 진행 금지 → 못 찾으면 목록/자체설계 |
| 코덱스 | **변경 없음** — claude-side + 새 스크립트만 |
| 미러 파일(`extract_design`·`fetch_images`·`extract_layout`·`icon_map.json`) | **무수정** — release `[2/7]` byte-동일 게이트 보존 |
| 결정론 | 유지 — `.dc.html` 파싱은 **새 claude 전용 스크립트**(LLM 추출 아님·feedback-005 정신) |
| feedback-015 공리 | **유지** — 코퍼스 레이아웃 어휘 0·시안=형상 단일근거·값 운반. **레버분리/L38 해제 금지**(코퍼스 모순) |
| 변경 감지 | **불필요(YAGNI)** — 시안 한 번 동결·재사용. 디자인 변경 시 **사용자가 "다시 적용" 명시 요청할 때만 재동결**. `updatedAt` 자동감지 제거(PROJECT는 미반환이기도 하고, 자동감지 자체가 불요 — 사용자 결정) |
| 토큰 | 기존 `--from-ds-manifest` 그대로 — 앱 프로젝트 동봉 `_ds/…/_ds_manifest.json` 사용 |
| 화면 충실도 최종 판단 | **육안 유지**(feedback-029 불가침·G2 `flutter run` ↔ 캔버스) |
| 이미지 256KiB 캡 | **이 설계 범위 밖** — 별도 이미지 strand(완전한 broccoli 재빌드엔 병행 필요) |

## 4. Claude Design 실측 형식 (PROJECT + .dc.html · DesignSync로 확인)

- **읽기 가능성**: `get_project`/`list_files`/`get_file`가 **PROJECT 타입도 projectId로 읽힘**(테스트 통과). `list_projects`만 design-system 타입으로 필터 → PROJECT는 목록 비열거(=사용자가 URL/ID 제공해야 하는 이유). `get_project`는 `{name,type,ownerDisplayName}` 반환·`updatedAt` 없음.
- **프로젝트 구조**(PROJECT 타입): 루트에 `<화면>.dc.html`, `assets/*.png`, `screenshots/*.png`(렌더), `_ds/design-system-<id>/`(참조 디자인시스템 동봉: `_ds_manifest.json`·`tokens/*.css`·`styles.css`·`_ds_bundle.js`), `support.js`, `uploads/`.
- **`.dc.html` 형식**: `<x-dc>` 래퍼 + `<helmet>`(`_ds/…/tokens/*.css`·`styles.css` `<link>` + Material Symbols 폰트). 본문은 **인라인 `<style>`의 CSS 클래스 + `var(--token)`**(예: `background:var(--cream)`·`color:var(--green-brand)`·`box-shadow:var(--shadow-md)`), 시맨틱 HTML(`<a href>`·`<button>`·`<div class>`), `<img src="assets/…">` 상대경로, 아이콘 `<span class="material-symbols-rounded">manage_accounts</span>`(리거처 텍스트).
- **JSX와의 차이 3축**: 출처(PROJECT vs DESIGN_SYSTEM) · 아이콘(`material-symbols` 리거처 vs `window.BrkIcon name=`) · 이미지(상대경로 — 현재 `.html` 글롭 경로는 resolveBase 없어 `skipped`).
- **토큰 동일성**: 앱 프로젝트의 `_ds/…/_ds_manifest.json`은 디자인시스템(8f6f69b3)의 그것 — 기존 `--from-ds-manifest` 추출이 무수정 작동.

## 5. 스크립트 전략 — 새 claude 전용 스크립트 (미러 불변)

미러 3종(`extract_design`·`fetch_images`·`extract_layout`)+`icon_map.json`은 release `[2/7] diff -q` 게이트가 codex와 byte-동일 강제. **코덱스 무변경 결정** → 이 파일들을 한 글자도 바꾸지 않는다.

> **전략 = 새 claude 전용 스크립트 `extract_dc.dart`.** `.dc.html` 전용 파싱(아이콘·이미지)을 **미러 게이트 목록 밖의 새 파일**에 둔다. 결정론(스크립트)·코덱스 무변경·미러 무관을 동시 충족. 토큰은 기존 `extract_design --from-ds-manifest`가 처리하므로 중복 없음.

- **실행 순서 (MF-3·고정)**: ① `extract_design --from-ds-manifest`가 먼저 `design-tokens.json`을 통째 기록(icons[] 빈 채·`writeAsStringSync`) → ② `extract_dc.dart`가 그 파일을 **read-modify-write**로 열어 `icons[]`·`unmappedIcons`만 주입(colors/spacing/typography 보존). **순서 역전·통째 덮어쓰기 금지**(역전 시 icons 소실·통째 시 colors 소실). architect 자기점검(L63 회계)에 `icons[] = extract_dc 수집 수` 대조 추가.
- **`extract_dc.dart`** [신규·claude 전용]: 동결 `.dc.html` 파싱 — **대상은 앱 콘텐츠(`.screen`/`.body` 내부)만**(MF-4: `.stage`/`.phone`/`.statusbar`/`.decor` device-chrome=폰 목업 제외):
  - **아이콘**: `material-symbols-(rounded|outlined|sharp)` span 리거처(`manage_accounts`·`school`…) 수집. **device-chrome(`.statusbar` 등) 하위 아이콘[`signal_cellular_alt`·`wifi`·`battery_full`]은 제외**(MF-4). `icon_map.json` 룩업(읽기만)·미수록 `unmappedIcons` → `design-tokens.json` `icons[]`에 RMW 주입.
  - **이미지**: `<img src>` 상대경로를 `.dc.html` 디렉터리 기준 해소(fetch_images `--asset-base` 동형)·바이트 복사 → `asset-manifest.json`(기존 스키마 그대로). 토크나이저(`_tagEnd`/`_attrRe`)는 fetch_images 동형 로직 국소 복제(~50줄·결정론 보존 대가).
  - **게이트 텍스트 (MF-1)**: `.head .title`·`.subtitle`·카드 `.rtitle` 텍스트를 `screen-meta.json`(`{title,subtitle,cards[]}`)으로 **결정론 추출** — §7 게이트가 *이 파일만* 인용(코디네이터 본문 손-추출=LLM 추출 금지·dddart.md L120). (`.dc.html`엔 `<title>`이 없어 기존 `_titleRe`로는 못 잡음 — `.title` 클래스를 본다.)
  - 출력: `design-tokens.json`(RMW)·`asset-manifest.json` 스키마 무변경 + 신규 `screen-meta.json`.
- **`extract_design.dart` --from-ds-manifest** [무수정]: 동봉 `_ds/…/_ds_manifest.json`으로 토큰 추출(위 ①). `.dc.html`엔 `window.BrkIcon` 부재라 icons[]는 빈 채로 나오고 `extract_dc.dart`가 RMW로 채운다.
- **`fetch_images.dart`·`extract_layout.dart`·`icon_map.json`** [무수정]: 미러 보존.

## 6. 변경 명세

### 6-A. claude — `dddart/commands/dddart.md` (Phase 0 화면 출처 해소)

| 위치 | 변경 |
|---|---|
| L36 config `design_source` | `project`가 DESIGN_SYSTEM뿐 아니라 **PROJECT 타입**도 담을 수 있게(타입 필드 추가 가능). 앱 단위 저장·재사용 규율 보존 |
| step4.1 가용성 | DesignSync 가용 시, **사용자 제공 URL/ID로 PROJECT 직접 지목 경로 추가**(list_projects 비열거 → URL 파싱: `/p/<projectId>` + `?file=<screen>.dc.html`) |
| step4.2 재사용 | **자동 staleness 감지(`updatedAt` 폴링) 제거** — 동결 스냅샷을 그대로 재사용. 재동결은 **사용자 명시 요청("다시 적용") 시에만**(Phase 0 폴더 재사용 절의 기존 "재동결?" 질문을 그 경로로 사용). (DESIGN_SYSTEM 기존 경로의 updatedAt 동작은 본 설계 범위 밖·무변경) |
| step4.3 후보 제시 | 화면 후보를 `ui_kits/app/*Screen.jsx` 외 **PROJECT 루트 `*.dc.html`**도 포함. **화면 수만이 아니라 화면 목적(이름·제목)** 신호 보강 |
| **step4.5 화면 선택** | **화면 확인 게이트(§7)로 교체** — 후보 매칭 → 렌더+문구 확인 → 동결. 동결 범위(MF-4): `.dc.html` + `assets/` + 동봉 `_ds_manifest` + **`_ds/…/tokens/*.css`·`styles.css`**(`.dc.html`이 `<link>`하는 토큰/베이스 CSS) + **매칭 `screenshots/<render>.png`**(시각 오라클) |
| step4.5 추출 호출 | **순서 고정(§5)**: ① `extract_design --from-ds-manifest <동봉 _ds_manifest>` → ② `dart run extract_dc.dart <동결 .dc.html> …`(아이콘·이미지 RMW + `screen-meta.json` 산출). `has_design_screen=true`(시안=`.dc.html`) |
| step5 G0 배너 | 디자인 출처 줄에 `이번 화면: <시안> (확인됨)` — §7 게이트 결과 명시 |
| L128 경계 | "JSX 직수입 금지"에 `.dc.html` 합류("`.dc.html`·JSX 모두 토큰·IR·아이콘·이미지만 추출, 위젯은 Flutter 신작") |

### 6-B. claude — 새 스크립트

| 파일 | 내용 |
|---|---|
| **`dddart/scripts/extract_dc.dart`** ⭐신규 | `.dc.html` 아이콘(material-symbols 리거처)+이미지(상대경로 해소) 추출. claude 전용·미러 게이트 밖 |

### 6-C. claude — 에이전트 (codex 동명 스킬은 무변경 = 엔진 비대칭)

| 파일 | 변경 |
|---|---|
| `agents/design-architect.md` | 동결 시안이 `.dc.html`일 수 있음 명시. **L38 형상-SoT 규율 불변**(feedback-015) — 형상 출처가 `.jsx`+`.dc.html`. **재현 대상 = `.screen/.body` 앱 콘텐츠만**(MF-4: `.phone`/`.statusbar`/`.blob` device-chrome은 폰 목업이지 앱 아님). `.dc.html` 화면 고유 px 리터럴(인라인 `<style>`·매니페스트 밖)은 class→규칙 조인으로 직접 인용(토큰 매핑이 *완전 직접은 아님* — class→CSS indirection) |
| `agents/coder.md` | 동결 시안 소비에 `.dc.html` 포함. 형상은 동결 `.dc.html`의 **`.screen/.body` 내부**에서 재현(device-chrome 제외). **시각 오라클 = 동결 `screenshots/<render>.png`**(렌더↔시안 육안·visual-fidelity-eye) |
| `agents/design-review-ui.md` | 충실도 대조 대상에 `.dc.html` 포함. **이미 CSS-var+inline-style 어휘(feedback-029 L31)라 `.dc.html`과 정합** — 어휘 변경 거의 없음 |

### 6-D. 미러·codex — 무변경

| 파일 | |
|---|---|
| `scripts/extract_design.dart`·`fetch_images.dart`·`extract_layout.dart`·`icon_map.json` | **무수정**(미러 byte-동일 보존) |
| `codex-dddart/**`·`AGENTS.md` 비대칭 절 | **무수정** — 코덱스=Stitch 무손상 |

## 7. 화면 확인 게이트 (핵심 — 무조건)

broccoli 참사의 직접 원인(엉뚱한 시안 *조용히* 동결)을 막는 G0 필수 게이트. **건너뛸 수 없다.**

1. 사용자가 프롬프트에 화면 이름(예: "역할 선택")을 적거나 URL `?file=`로 지정 →
2. dddart가 PROJECT의 `*.dc.html` 목록에서 **후보를 찾음**(`?file=`는 정확 일치·이름은 파일명 대조). **확정 못 하면 목록 제시**(휴리스틱 단정 금지) →
3. **`screen-meta.json`(extract_dc 결정론 추출)의 제목·문구 + 동결 렌더를 나란히 보여주며 확인**:
   ```
   찾은 화면: 역할 선택.dc.html
     제목(자동추출): "누가 사용하나요?"   서브: "사용자에 맞게 시작할 화면을…"
     카드(자동추출): 부모입니다 / 자녀입니다
     렌더: screenshots/role.png  (열어서 본문과 *같은 화면인지* 교차확인)
   이 화면이 맞나요?   [네 / 아니오·다른 화면 / 목록 보기]
   ```
   - **MF-1**: 제목·문구는 **extract_dc가 `screen-meta.json`으로 결정론 산출** — 코디네이터 본문 손-추출 금지(=LLM 추출·dddart.md L120). "핵심 요소" 같은 의미 선택 라벨 제거.
   - **MF-2**: 렌더는 **이름 매핑 금지**(`역할 선택`→`role` 같은 한↔영 사상은 비결정) — `?file=`/사용자 지목으로 1:1 확정, 모호·다대일이면 `screenshots/` 목록을 사용자가 직접 지목(step5 폴백을 렌더에도 적용).
4. **승인 전 동결·진행 금지.**
5. **못 찾거나 애매하면 — 비슷한 화면 *조용히* 집기 절대 금지**: PROJECT의 `.dc.html` 목록을 전부 보여주고 고르게 하거나, 적합 화면이 없으면 "자체설계+토큰차용으로 갈까요?"를 물음(has_design_screen=false).

> 이 게이트가 feedback-015 공리("시안=형상 진실")의 안전장치다 — 시안이 형상을 결정하므로, *올바른 시안이 동결됐음을 사용자가 확인*해야 공리가 올바른 화면을 산출한다.

## 8. feedback-015 공리 정합 (코퍼스 모순 회피)

ROC 워크플로우는 "레버 분리·`design-architect.md L38`(형상=동결 시안 재현) 해제·architect가 의도 화면 명세"를 권고했으나 — 이는 feedback-015 **사용자확정 공리**(과거 architect 산문 레이아웃 기술 → coder 축 뒤집힘 회귀 → 어휘 철거·시안=형상 단일근거)와 **정면 모순**이다. 본 설계는 L38·공리를 **불변**으로 두고, 결함을 **시안-선택 경계**(올바른 시안을 올바른 출처에서 가져오기 + §7 확인 게이트)에서만 고친다. 올바른 `.dc.html` 시안이 동결되면 공리가 올바른 화면을 산출한다.

## 9. 범위 경계 — 이미지 strand는 별개

`.dc.html`의 `<img src="assets/broccoli-icon.png">`도 DesignSync `get_file` 256KiB 캡에 절단될 수 있다(broccoli 불만 ①). 그 캡-안전 동결 + 무결성 게이트는 **별도 이미지 strand**다(이 설계 범위 밖). **완전한 broccoli 재빌드엔 두 strand 모두 필요** — 본 설계(화면)는 *엉뚱한 화면* 문제를, 이미지 strand는 *깨진 아이콘* 문제를 각각 닫는다.

## 10. 코퍼스 규율 — feedback-030 사전등록

코퍼스 measure-first 규율: 본 설계를 `workspace/eval/fix/feedback-030-claude-design-project-source.md`로 **사전등록**(예상효과 박기) → 라이브런(육안 오라클)으로 실측. **과적합 금지**: 역할선택 특수처리 0·임의 PROJECT/`.dc.html`에 일반 성립·기존 weather 픽스처(Stitch 경로) 무회귀 확인.

## 11. 변경 규모 요약

- **claude 단독**: `dddart.md`(Phase 0 화면 출처 절) + 에이전트 3(`design-architect`·`coder`·`design-review-ui`) + **신규 `scripts/extract_dc.dart`**
- **미러·codex**: **0** (3 스크립트·`icon_map`·codex·AGENTS 전부 무수정)
- **이미지 strand**: 별도(범위 밖)
- **레이아웃 강제축**: 본 설계 = *출처 교정 단독* · 레이아웃 충실도 **신장치 0**(feedback-029 §7 layout-ir 보류 유지·충실도 판단=육안). `.dc.html` flexbox 축(Row/Column/Spacer) 재현 신뢰도는 feedback-030 라이브런으로 측정. 화면 고유 px 리터럴 미추출은 feedback-029 **공유 한계**(JSX도 동일·본 설계 회귀 아님).

> 모든 변경이 **인입 계층 + claude-side**에 한정. 미러 불변·코덱스 무변경. feedback-015 공리·design_system 소비 규율 불변.

## 12. 비조건 (niceToHave · 판정자 minor · 구현 시 반영)

- PROJECT 재사용 분기 ⓑ(not-found)/ⓒ(미가용) 재명세(step4.2가 ⓐ 중심).
- §10 측정에 FID-L1/L2→A1 폴백 명기(자동 게이트 부재 정직 고지).
- 게이트 텍스트(`screen-meta.json`)→architect 비유입 방화벽 1줄(게이트용 텍스트가 명세 행위로 새지 않게).
- extract_dc fail-loud 확장: `background-image`/인라인 SVG/아이콘 광학변종(outlined·sharp)/매니페스트 부재.
- broccoli 이미지 절단 1회 실측(이미지 strand 전제 확인).
