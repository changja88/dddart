# feedback-030 — Claude Design 앱화면 출처: 디자인시스템(키트) → 앱 PROJECT(.dc.html) 인입 사전등록

> 2026-06-28. **사전등록형** — 시술 전 예상효과를 박고, 다음 라이브런 결과지로 실측을 채워 대조한다.
> 설계 SSOT: `workspace/design/2026-06-28-claude-design-project-source-design.md`(5렌즈 적대 리뷰 조건부합격·MF-1~4 반영본).
> 구현 계획: `workspace/design/2026-06-28-claude-design-project-source-plan.md`.
> feedback-029(Stitch→Claude Design 전환)의 **후속·확장** — 029는 *엔진*(어디서 그렸나)을, 030은 *출처 종류*(앱 화면 vs 디자인시스템 키트)를 고친다.

## 메타
- **회차**: 030
- **트리거**: broccoli 역할선택 충실도 실패 전면 ROC — claude 판 dddart가 디자인시스템 **키트의 예시 화면**(OnboardingScreen=학년선택)을 *조용히* 동결·각색 → feedback-015 공리상 "엉뚱한 화면의 충실 재현"이 됐다. 사용자 불만 6건 중 **5건이 이 *엉뚱한 시안 동결*에서 발원**(나머지 1건=이미지 256KiB 절단·별 strand). 4렌즈 ROC(워크플로우 `wmhzhv3lj`) + 설계 5렌즈 적대 리뷰(`wbdgmqr6d`·조건부적합 → MF-1~4 반영) + DesignSync 직접 실측(PROJECT `56758e97…` get_project/list_files/get_file 통과·`역할 선택.dc.html` 직독).
- **베이스 코퍼스**: `c023e6c` (v1.0.3)
- **시술 커밋**: `b8861e8`(설계·계획)~`5aa82a9`(에이전트) — 브랜치 `feat/claude-design-dc-source`. T1 `e277db7`(extract_dc+F21) · T2 `c10880f`(+후속 `dd726ce`·`d322285`) · T3 `5aa82a9` · T4 본 메모.
- **검증 런**: `results/<다음 라이브런 결과지>` — broccoli PROJECT `56758e97…`/`역할 선택.dc.html`로 재라이브런 후 채움.
- **상태**: 사전등록(구현 적용 완료·실측 대기)

---

## 배경 — 왜 이 설계인가 (설계 §2)

Claude Design은 **디자인시스템(키트)과 앱 화면을 별도 프로젝트**로 둔다(실측 확정):

| 프로젝트 | 타입 | 내용 | dddart 과거 동작 |
|---|---|---|---|
| 브로콜리 Design System | `DESIGN_SYSTEM`(키트) | `ui_kits/app/*Screen.jsx` = 키트 자체 예시 6화면(Home/학년선택/Quiz/Report/Tutor) | ← **여기 잘못 바인딩** |
| Broccoli 부모 앱 온보딩 | `PROJECT`(실제 앱) | `역할 선택.dc.html`·`로그인.dc.html` + `_ds/…/`(토큰 동봉) + `screenshots/role.png`(렌더) | ← **진짜 화면은 여기** |

- dddart의 `design_source`는 `DesignSync.list_projects`가 **design-system 타입만 열거**하기 때문에 DESIGN_SYSTEM(키트)만 가리킬 수 있었다. 사용자가 "역할 선택"을 요청하자 dddart는 키트 예시 중 가장 비슷한 OnboardingScreen(학년선택)을 *조용히* 시안으로 동결·각색했다.
- **근본**: 출처 모델이 **"앱 화면 = 디자인시스템 안"으로 잘못 가정**. 진짜는 "앱 화면 = 별도 PROJECT(키트를 *참조만*)".

> **결론**: feedback-015 공리("시안=형상 진실")는 **무죄** — 공리는 동결된 시안을 충실히 재현했을 뿐이다. 결함은 *시안-선택 경계*(엉뚱한 출처에서 엉뚱한 시안을 집음)에 있었다. 본 설계는 공리·L38을 **불변**으로 두고 *출처*와 *§7 확인 게이트*만 고친다(설계 §8).

---

## 변경 표면 — claude 단독·인입 계층 한정 (설계 §6·§11)

전환면은 전부 **앱 화면을 획득하는 인입(ingest) 계층**에 갇힌다. design_system을 *소비*하는 규율(houserules·arch-ui·feedback-015 공리·`design-architect L38`)은 **엔진·출처 무관이라 불변**. 미러 3종·codex·AGENTS는 **무수정**(release `[2/7] diff -q` 게이트 보존).

| 범위 | 파일 | 핵심 변경 |
|---|---|---|
| **claude 신규** ⭐ | `scripts/extract_dc.dart` | `.dc.html` 아이콘(material-symbols 리거처)+이미지(상대경로 해소)+게이트텍스트(`screen-meta.json`) **결정론 추출**. **미러 게이트 목록 밖**(claude 전용·codex에 없음=정상) |
| **claude 전용** | `commands/dddart.md` (Phase 0) | PROJECT URL/ID 직접 지목·`updatedAt` 자동감지 제거·후보에 `*.dc.html` 포함·**§7 확인 게이트**·동결 범위 확장(`tokens/*.css`·`styles.css`·매칭 렌더)·추출 순서 고정(①extract_design → ②extract_dc RMW)·L128 `.dc.html` 합류 |
| **claude 전용** | `agents/design-architect.md` | 동결 시안 `.dc.html` 가능·**L38 불변**·재현 대상=`.screen/.body`·화면 고유 px는 class→규칙 조인 인용·`icons[]=extract_dc 수집 수` 회계(L63) |
| **claude 전용** | `agents/coder.md` | `.dc.html` 소비·`.screen/.body` 내부 재현·device-chrome 제외·**시각 오라클=동결 `screenshots/<render>.png`** |
| **claude 전용** | `agents/design-review-ui.md` | 충실도 대조에 `.dc.html` 포함(이미 CSS-var+inline-style 어휘·feedback-029 L31과 정합 → 소폭) |
| **claude 검증** | `scripts/test/run_fixtures.sh` | 픽스처 **F21** 추가(extract_dc 결정론·device-chrome 제외·RMW 보존 단언) |
| **미러·codex** | `extract_design`·`fetch_images`·`extract_layout`·`icon_map.json`·`codex-dddart/**`·`AGENTS.md` | **무수정 = 0** — 최종 게이트 `diff -q`+`git diff --stat`로 강제 |

**§9 보류(범위 밖)**: 이미지 256KiB 캡-안전 동결 + 무결성 게이트 = **별도 이미지 strand**. 브랜드 로고(`assets/broccoli-icon.png` 등) 절단은 본 설계가 닫지 않는다 — *엉뚱한 화면* 문제만 닫고, *깨진 아이콘* 문제는 이미지 strand 소관. **완전한 broccoli 재빌드엔 두 strand 모두 필요.**

---

## 시각 충실도·결정론·공리 보존 방침 (불가침)

- **육안 최종 판단 불변**(feedback-029 G2): `flutter run` ↔ claude.ai 캔버스/동결 렌더 **육안 대조**. 토큰 일치 기계판단으로 대체 금지(visual-fidelity-eye).
- **feedback-015 공리·L38 불변**: 코퍼스 레이아웃 어휘 0·시안=형상 단일근거. 결함은 *시안-선택 경계*에서만 교정(설계 §8).
- **결정론 보존**: 텍스트·아이콘·이미지 추출은 스크립트(`extract_dc.dart`)가 수행 — 코디네이터 본문 손-추출(=LLM 추출·dddart.md L120) 금지(MF-1).
- **device-chrome 제외**(MF-4): `.stage/.phone/.statusbar/.decor/.blob`는 폰 목업이지 앱 아님 — 추출·재현 대상 = `.screen/.body` 내부만.
- **출력 스키마 키 불변**(MF-3): `design-tokens.json`은 RMW로 `icons[]`·`unmappedIcons`만 주입(colors/spacing/typography 보존)·`asset-manifest.json` 무변경. 신규는 `screen-meta.json`만.

---

## 교정 항목 (사전등록 표 — ①~④ 박음 · ⑤~⑥ 런 후)

| # | 우선 | ① 대상 결함(dim) | ② 원인(뿌리) | ③ 처방(파일·MF) | ④ **예상효과**(전→후) | ⑤ 시술커밋 | ⑥ 실측·판정 |
|---|---|---|---|---|---|---|---|
| 1 | 높음 | 앱 화면 요청 시 디자인시스템 키트의 *예시 화면*(학년선택)을 시안으로 동결 → *엉뚱한 화면* 재현 | 출처 모델이 "앱 화면 = 디자인시스템 안"으로 가정 | `dddart.md` step4.1 PROJECT URL/ID 직접 지목 경로 + `config.design_source`에 PROJECT 타입 수용 | 사용자 앱 PROJECT의 `역할 선택.dc.html`이 시안으로 동결 → **역할선택 화면 자체**가 충실 재현 | `c10880f` | (런 후) |
| 2 | 높음 | `list_projects`가 PROJECT를 비열거 → 앱 화면 자동 후보화 불가 | `DesignSync.list_projects`가 design-system 타입만 필터 | `dddart.md` URL 파싱(`/p/<projectId>`+`?file=<screen>.dc.html`)·비열거 사실 고지·후보에 PROJECT 루트 `*.dc.html` 포함 | URL/ID 1회 입력으로 PROJECT 직접 지목·재사용(Stitch 동형·한 번만) | `c10880f` | (런 후) |
| 3 | 높음(핵심) | 화면을 못 찾거나 애매할 때 *비슷한 화면을 조용히 집음* → broccoli 참사 직접 원인 | 확인 게이트 부재(휴리스틱 단정 허용) | `dddart.md` §7 **화면 확인 게이트(무조건)**: screen-meta 제목·문구 + 동결 렌더 제시 → "이 화면 맞나요?" 승인 전 진행 금지·못 찾으면 목록/자체설계(MF-1·MF-2) | 잘못된 시안이 *조용히* 통과하지 못함 — 사용자가 올바른 시안 동결을 확인 → 공리가 올바른 화면 산출 | `c10880f` | (런 후) |
| 4 | 높음 | `.dc.html`의 아이콘(material-symbols 리거처)·이미지(상대경로)·게이트텍스트를 결정론 추출할 경로 없음 | claude 인입이 JSX(`BrkIcon`)·HTML 가정 — `.dc.html` 형식 미지원 | 신규 `scripts/extract_dc.dart`(claude 전용·미러 밖) + 픽스처 F21. ①extract_design → ②extract_dc **RMW 순서 고정**(MF-3) | `manage_accounts`·`school` 등 본문 아이콘 정확 매핑·이미지 해소·`screen-meta.json` 산출. colors 보존 | `e277db7` | (런 후) |
| 5 | 중간 | 폰 목업(상태바 `signal_cellular_alt`·`wifi`·`battery_full`·blob 장식)을 앱 화면으로 오인·재현 위험 | `.dc.html`이 device-chrome을 본문과 한 트리에 둠 | `extract_dc` `.screen` 서브트리만 추출 + 에이전트 3종 `.screen/.body` 한정·device-chrome 제외(MF-4) | 폰 프레임·상태바·blob **미재현** — 앱 콘텐츠만 Flutter화 | `e277db7`·`5aa82a9` | (런 후) |
| 6 | 중간 | 확인 게이트 텍스트를 코디네이터가 본문에서 손-추출(=LLM 추출) → 비결정·`?file` 한↔영 이름매핑 비결정 | 게이트용 제목·문구 출처 미규정 | `extract_dc`가 `.head .title`·`.subtitle`·카드 `.rtitle`을 `screen-meta.json`으로 결정론 산출·게이트는 *이 파일만* 인용·렌더는 `?file`/지목 1:1(MF-1·MF-2) | 게이트 제목·문구·렌더가 결정론·재현가능 — "핵심 요소" 류 의미선택 라벨 0 | `e277db7`·`c10880f` | (런 후) |
| 7 | 낮음(잔존) | `.dc.html`의 `<img src="assets/…">`가 `get_file` 256KiB 캡에 절단 → 브랜드 로고 깨짐(broccoli 불만 ①) | DesignSync `get_file` 256KiB 캡 | **본 설계 범위 밖** — 별도 이미지 strand(설계 §9). 라벨만 명시(은폐 금지) | (미해결·**예상된 잔존**) 완전한 broccoli 재빌드엔 이미지 strand 병행 필요 | (해당 없음·별 strand) | (잔존·런서 확인) |

- **MF 귀속**: MF-1(screen-meta 결정론)=③⑥행 · MF-2(렌더 1:1 매핑)=③⑥행 · MF-3(RMW 순서)=④행 · MF-4(device-chrome·CSS동결)=⑤행. 전부 처방에 반영.
- **④예상효과**: 모든 항목이 인입 계층 한정 — design_system 소비 규율 dim(FC-1·FC-2 등 기존 골든)·feedback-015 공리 변동 없음.
- **⚠️ 7번은 처방이 아니라 *범위 경계***. 정직 고지: 본 설계로 *깨진 아이콘*은 해결되지 않으며, 라이브런에서 잔존이 관찰되어도 회귀가 아니라 **예상된 미해결**이다.

---

## 다음 라이브런 측정 dim (육안 오라클)

| dim | 측정 방법 | 목표 | 분류 |
|---|---|---|---|
| **역할선택 충실 재현** | broccoli `56758e97…`/`역할 선택.dc.html` 라이브런 → `flutter run` 렌더 ↔ 동결 `screenshots/role.png`/캔버스 **육안 대조** | 역할선택 화면 자체가 충실 재현(≠학년선택) | 핵심 |
| **device-chrome 미재현** | 렌더에 폰 프레임·상태바(signal/wifi/battery)·blob 장식 **부재** 확인 | device-chrome 0 재현(MF-4) | 핵심 |
| **아이콘 정확** | 본문 `manage_accounts`·`school`이 정확 매핑·상태바 아이콘 누락 | 본문 아이콘 정확·device-chrome 아이콘 제외 | 핵심 |
| **확인 게이트 작동** | transcript에서 §7 게이트 발동(screen-meta 제목·문구+렌더 제시 → 사용자 승인) 흔적·조용한 동결 0 | 게이트 무조건 발동·승인 전 진행 0 | 핵심 |
| **weather 무회귀**(과적합 가드) | 기존 weather 픽스처(Stitch 경로) 재실행 — `.dc.html` 변경이 Stitch 인입에 무영향 | weather 무회귀(Stitch 경로 불변) | 가드 |
| **임의 `.dc.html` 일반성**(과적합 가드) | 역할선택 외 다른 `.dc.html`(예: 로그인)에도 게이트·추출 성립 — 역할선택 특수처리 0 | 임의 PROJECT/`.dc.html` 일반 성립 | 가드 |
| **이미지 strand 잔존**(정직 라벨) | 브랜드 로고(`assets/*.png`) 256KiB 절단/깨짐이 **여전히** 관찰되는지 | *예상된 잔존* — 별 strand 미해결 확인(은폐 금지) | 잔존 |
| **미러 byte-identical** | `diff -q` 미러 3종+`icon_map` · `git diff --stat codex-dddart/ AGENTS.md` | divergence 0·빈 출력 | 게이트 |
| **픽스처 전수** | `bash dddart/scripts/test/run_fixtures.sh` | F1~F21 전 PASS(F10/F12/F19/F20 무회귀) | 게이트 |

> **자동 게이트 부재 정직 고지**: 핵심 4 dim은 *육안 오라클*(FID-L1/L2 → A1 폴백) — 기계 통과 기준이 없다. 라이브런 판정자가 렌더↔시안을 직접 본다.

---

## 회차 요약 (다음 런 후)
- 예상 적중 **N/M** · 무효 **N** · ⚠️역효과/신규회귀 **N**
- **한 줄 결론**:
- **이미지 strand**: (잔존 확인 — 본 설계 범위 밖·별 strand로 추적)
- ⚠️ **N=1 인과 단정 금지** — "처방 X가 충실재현 Y를 *유발*"이 아니라 "X 적용 후 Y 관찰(동시발생)"로 기록. 단일 라이브런은 존재증명이지 일반화 근거가 아니다.
