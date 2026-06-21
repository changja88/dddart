# 에셋(Track A) 공급 파이프라인 — 시술 Plan

> **For agentic workers:** 대상은 *코드가 아니라 코퍼스*(dddart 스킬·에이전트·커맨드·스크립트). 각 Task는 독립 검증(grep 앵커·`cmp` 양판·`dart analyze`) 가능한 deliverable이다. 체크박스로 추적.

**Goal:** Stitch 시안의 모든 `<img>`를 빌드타임 다운로드→`assets/images/` 번들→`AppAsset` 토큰화→`Image.asset` 배선하는 공급 사슬을 코퍼스에 닫는다(12차 "이미지 자리만·다운로드 안 함" 해소).

**Architecture:** Phase 0 `fetch_images.dart`가 `design-ref/*.html` raw 전수에서 이미지를 다운로드하고 `asset-manifest.json`(단일 SSOT·src=조인 키)을 산출 → architect가 manifest를 읽어 "src=X 이미지 → 화면 Y 조각" 의미 연결을 정형 목록으로 명세에 박음(token 미기재) → coder가 manifest에서 src로 조인해 token·local_path를 직접 읽어 `app_asset.dart`·pubspec·`Image.asset` 작성. **layout-ir은 에셋 매핑에서 완전 분리.**

**Tech Stack:** 무의존 dart 스크립트(`dart:io` `HttpClient`·`dart:convert`)·코퍼스 markdown 산문.

**진실원천:** `workspace/design/2026-06-21-asset-track-a-design.md`(v2·4렌즈 교정).

## Global Constraints

- **양판 미러**: claude(`dddart/`) ↔ codex(`codex-dddart/skills/`). final.md = `corpus_mirror_sync.py --write` 자동·**SKILL.md·commands·agents·scripts = 수동 + `cmp` byte-exact 검증**(codex backstop이 이미 stale인 실증 — 수동 채널 무게이트).
- **앵커 grep 우선**: 모든 코퍼스 Edit은 라인 번호가 아니라 **앵커 문구로 grep 재확인** 후 적용(드리프트 대비).
- **과적합 금지**: weather 픽셀·파일명을 코퍼스 산문에 박지 않는다 — 예시는 중립(`assets/logo.png`·`AppAsset.heroIllustration`).
- **layout-ir 불변**: `extract_layout.dart` 변경 0·에셋 매핑은 manifest 전담.
- **치수 강제 모방 경계**: `Image.asset` width/height 항상 박기 금지(시안 명시값만).
- **measure-first**: 결정적 floor(check_pubspec)는 13차 후 후속 — 이번 시술 범위 아님.
- **다음 런 동결**: 코퍼스 변경은 13차 라이브런 동결 대상(소급 금지).

---

## File Structure

| 파일 | 책임 | 미러 |
|---|---|---|
| `dddart/scripts/fetch_images.dart` (신규) | raw HTML→다운로드→assets/images·manifest·token·status | 수동+cmp |
| `dddart/commands/dddart.md` | Phase 0 fetch 호출·`has_design_images`·G0 배너·closed-list·coder 호출입력 | 수동 |
| `dddart/agents/design-architect.md` | manifest 입력·src 의미연결 정형목록·자기점검 | 수동 |
| `dddart/skills/implementation-flutter/{references/final.md,SKILL.md}` | §8 `Image.asset`·pubspec 표기 + 라우팅 3장치 | final.md 자동·SKILL.md 수동 |
| `dddart/agents/coder.md` | manifest 입력 슬롯·src 조인·배선·gate | 수동 |
| `dddart/skills/architecture-ui/references/final.md` | §7 AppAsset *획득* cross-ref 1줄 | 자동 |

codex 미러 경로: `codex-dddart/skills/dddart/scripts/fetch_images.dart` · `codex-dddart/skills/dddart/SKILL.md` · `codex-dddart/skills/dddart-design-architect/SKILL.md` · `codex-dddart/skills/implementation-flutter/{references/final.md,SKILL.md}` · `codex-dddart/skills/dddart-coder/SKILL.md` · `codex-dddart/skills/architecture-ui/references/final.md`.

---

## Task 1: `fetch_images.dart` 신규 (다운로드·manifest·token)

**Files:**
- Create: `dddart/scripts/fetch_images.dart`
- Mirror: `codex-dddart/skills/dddart/scripts/fetch_images.dart` (cmp byte-exact)

**Interfaces:**
- **Consumes**: `design-ref/*.html`(raw HTML)·출력 디렉터리 루트(프로젝트 루트 — `assets/images/` 기록)·manifest 출력 경로.
- **Produces**: `assets/images/<screen-slug>-<n>.<ext>` 파일들 + `asset-manifest.json` `{images:[{src,alt,local_path,token,status,sha256}]}`. exit 0=성공(부분 실패 허용)·1=사용법·design-ref 부재.

**CLI** (extract_design/extract_layout 동형):
```
dart run fetch_images.dart <design-ref-dir> --assets-root <project-root> --out <asset-manifest.json>
```

- [ ] **Step 1: 골격·CLI 파싱** — `#!/usr/bin/env dart`·`library;`·`import 'dart:convert'; import 'dart:io';`. argv switch로 `--assets-root`·`--out`·positional `<design-ref-dir>`. 누락·디렉터리 부재 시 `stderr`+`exit(1)`(extract_design.dart:23-56 패턴).

- [ ] **Step 2: 모든 `<img src>` 전수 추출(화면별·순서)** — `design-ref/*.html` 각 파일에서 정규식 `RegExp(r'<img\b[^>]*\bsrc\s*=\s*"([^"]*)"[^>]*>', caseSensitive:false)`로 **모든 `<img>`**(area·중첩 무차별) 매치. 같은 정규식으로 `alt="..."`도 추출(없으면 ''). 화면 slug = HTML 파일명 stem(`p.basename(f.path).replaceAll(RegExp(r'\.html?$'), '')` — extract_layout.dart:63 동일 출처). 파일 내 매치 순서 = `<n>` 인덱스(1부터). **정렬**: 파일명 정렬 후 처리(결정론).

- [ ] **Step 3: src 스킴 분기(§7)** — 각 src에 대해:
  - `http(s)://` → 다운로드 대상(Step 4).
  - `data:` URI → base64 디코드·저장·`status:"inline"`.
  - 그 외(상대·`file:`) → 다운로드 안 함·`status:"skipped"`(표면화).

- [ ] **Step 4: 다운로드(HttpClient)** — `HttpClient`로 `getUrl(Uri.parse(src))`→`close()`→`response`. 200이면 바이트 수집(`await consolidateHttpClientResponseBytes` 대신 `response.fold`/`toList`)·`assets/images/<slug>-<n>.<ext>` 저장·`status:"ok"`·`sha256`(`crypto` 없이 — `dart:io`엔 sha 없음 → **sha256은 선택이라 생략 가능**, 또는 간이 무결성은 바이트 길이만). 비-200·예외 → `status:"failed"`·파일 미저장·계속(부분 성공). ext = Content-Type(`image/png`→png·`image/jpeg`→jpg) 또는 매직바이트(PNG `\x89PNG`·JPEG `\xFF\xD8`) 판정·기본 png.

- [ ] **Step 5: token 결정론 부여(§4)** — 파일명 stem(`<slug>-<n>`)을 `[^A-Za-z0-9]`로 분해→camelCase(`home-1`→`home1`). 문자 미시작 시 `a` prepend. 동일 token 충돌 시 `_<k>` suffix. (flutter_gen 4정규식 동형.)

- [ ] **Step 6: manifest 산출·동결** — `{images:[...]}`를 `JsonEncoder.withIndent('  ')`로 `--out` 경로에 기록(extract_layout.dart:71 패턴). `stdout`에 `[fetch-images] 이미지 N (ok M·failed F·inline I·skipped S) → <out>` 보고.

- [ ] **Step 7: 검증** — `dart analyze dddart/scripts/fetch_images.dart` → 신규 이슈 0. 임시 design-ref(`<img src="data:image/png;base64,...">` 1건·`<img src="https://...">` 1건·`<img src="./x.png">` 1건)로 smoke run → manifest에 status `inline`·(네트워크 가능 시 ok/failed)·`skipped` 각 1건·token camelCase 확인.

- [ ] **Step 8: 양판 미러 + cmp** — claude→codex 복사 후 `cmp dddart/scripts/fetch_images.dart codex-dddart/skills/dddart/scripts/fetch_images.dart` → 무출력(동일).

- [ ] **Step 9: Commit** (레이아웃과 동시 커밋이므로 이 plan 전체 완료 후 일괄 — Task 7).

---

## Task 2: Coordinator — Phase 0 fetch·플래그·배너·경계·coder입력

**Files:**
- Modify: `dddart/commands/dddart.md`
- Mirror: `codex-dddart/skills/dddart/SKILL.md` (수동·앵커 grep)

**Interfaces:**
- **Consumes**: Task 1의 `fetch_images.dart` CLI·`asset-manifest.json`.
- **Produces**: `has_design_images` 플래그·coder 호출입력에 manifest 경로.

- [ ] **Step 1: fetch 호출 줄 추가** — 앵커 grep `extract_layout.dart <산출물 폴더>/design-ref`. 그 `has_layout_ir=true` 문장 **직후**에 1문장: *"이어서 **같은 동결 HTML에서 이미지도 다운로드**한다: `dart run ${CLAUDE_PLUGIN_ROOT}/scripts/fetch_images.dart <산출물 폴더>/design-ref --assets-root <프로젝트 루트> --out <산출물 폴더>/asset-manifest.json` → 다운로드된 `<img>`가 있으면 `has_design_images=true`. extract_layout이 *구조*를, extract_design이 *토큰*을 절단하듯 fetch_images는 *이미지 바이트*를 `assets/images/`로 동결하고 src→local_path→token 매핑을 `asset-manifest.json`(SSOT)으로 절단한다(모든 `<img>` 전수·중첩 포함). **이미지를 앱 소스 `assets/`에 직접 쓰는 건 외부 진실 동결의 예외다 — 이미지는 입력=출력이라 동결처가 곧 번들처다**(아래 닫힌 목록에 명시)."*

- [ ] **Step 2: has_design_images 플래그 스키마** — 앵커 grep `"has_layout_ir":`. build-state JSON 스키마의 그 항목 직후에 `"has_design_images": "<bool — fetch_images가 design-ref HTML의 <img>를 assets/images로 1건 이상 다운로드했으면 true(architect·coder에 asset-manifest 경로 전달 신호). has_stitch_html이면서 다운로드 성공 시 true·HTML 없음/이미지 0/전부 실패면 false>"` 추가.

- [ ] **Step 3: 경계 closed-list 갱신** — 앵커 grep `네가 직접 쓰는 것은 다음뿐이다`(2곳 — 본문·경계). 두 closed-list의 `design-ref` 뒤에 `· **시안 이미지 번들(`assets/images/` — 외부 진실 동결의 명시적 예외: 이미지는 입력=출력)**` 추가.

- [ ] **Step 4: G0 배너 실패 표면화** — 앵커 grep `디자인 출처 해소 실패 — 경로/연결 확인`. 그 "조용히 폴백 금지" 문장 인근에 1줄: *"**이미지 다운로드 부분 실패**(`asset-manifest` status:failed)도 G0 배너에 `이미지 M/N 다운로드 실패 — placeholder로 조용히 가지 않는다`로 표면화한다(다운로드 안 함과 placeholder를 가른다)."*

- [ ] **Step 5: coder 호출입력에 manifest 추가** — 앵커 grep `server-contract.json`(coder 입력 목록 줄). 그 목록에 `· (has_design_images이면) asset-manifest.json 경로(이미지 src→token·local_path 정확 매핑 — coder가 app_asset.dart·Image.asset 배선에 직접 인용)` 추가.

- [ ] **Step 6: 양판 미러** — `codex-dddart/skills/dddart/SKILL.md`에 동일 앵커로 5개 변경 반영(codex 어휘·구조 차이 흡수)·grep으로 양쪽 동일 의미 확인.

---

## Task 3: design-architect — manifest 의미연결 정형목록

**Files:**
- Modify: `dddart/agents/design-architect.md`
- Mirror: `codex-dddart/skills/dddart-design-architect/SKILL.md` (수동·앵커)

- [ ] **Step 1: manifest 입력 추가** — 앵커 grep `layout-ir.json` 경로 — Coordinator가 같은 동결 HTML`(입력 절). 그 layout-ir 입력 항목 **직후**에 1항목: *"- (있으면) `asset-manifest.json` 경로(`has_design_images`) — 시안 `<img>`의 src→다운로드 `local_path`→`AppAsset.<token>` 매핑(SSOT). **너는 이 manifest를 읽어 *어느 이미지(src)가 어느 화면 조각에* 들어가는지 의미를 연결한다 — `token`·경로 문자열은 박지 않는다**(coder가 manifest에서 src로 직접 조인). design-tokens가 '무슨 색', layout-ir가 '무슨 영역'이면 asset-manifest는 '어느 자리에 어느 이미지'다."*

- [ ] **Step 2: 화면 절에 에셋 연결 정형목록** — 앵커 grep `크기는 \`arbitraryValues\`·비도메인 \`typography\` 항목을 빠짐없이 1건씩`(레이아웃 §8 크기 정형목록). 그 문장 **직후**에 동형 문장: *"**이미지도 같은 형식으로 — `asset-manifest.json`이 있으면(`has_design_images`) 각 `images` 항목(src 기준)을 빠짐없이 1건씩 — 어느 화면의 어느 조각이 그 이미지를 렌더하는지(또는 왜 안 쓰는지) — `src`로 가리켜 정형 목록으로 박는다**(manifest 항목 수만큼·빈칸이면 coder가 흘린다). `AppAsset.<token>`·`assets/…` 문자열은 박지 않는다 — coder가 manifest에서 src로 조인해 정확 값을 가져온다(architecture-ui §7 사용·§8 동형: 도메인 없는 추출값을 명세에서 조각에 잇기)."*

- [ ] **Step 3: 자기점검 추가** — 앵커 grep `arbitraryValues\`·비도메인 \`typography\` 항목이 크기 정형 목록에 빠짐없이`(L63 자기점검). 그 문장 인근에 1줄: *"**`has_design_images`이면** `asset-manifest` 항목이 이미지 연결 정형 목록에 빠짐없이 들어갔는지도 대조한다(manifest 항목 수 = 목록 항목 수) — 빈칸은 coder가 흘릴 이미지다."*

- [ ] **Step 4: 양판 미러** — `codex-dddart/skills/dddart-design-architect/SKILL.md`에 3개 변경 반영·grep 확인.

---

## Task 4: implementation-flutter — §8 표기 + 라우팅 3장치

**Files:**
- Modify: `dddart/skills/implementation-flutter/references/final.md` (자동 `--write`)
- Modify: `dddart/skills/implementation-flutter/SKILL.md` (수동 — 라우팅 3장치)
- Mirror: codex 동 경로

- [ ] **Step 1: final.md §8 신설** — `references/final.md` 끝(마지막 `## §7` 절 뒤)에 `## §8. 정적 이미지 에셋 — Image.asset·pubspec assets` 신설. 내용: (a) 정적 래스터는 `Image.asset(AppAsset.<token>)` — raw 경로 문자열 금지(architecture-ui §7 사용 규율 cross-ref). (b) 토큰·경로는 `asset-manifest.json`이 SSOT — coder는 명세가 가리킨 `src`로 manifest 행을 조인해 `token`·`local_path`를 가져와 `app_asset.dart`에 `static const String <token> = '<local_path>';` 추가. (c) pubspec 멱등 선언: `flutter: assets:`에 `- assets/images/`(디렉터리·평면)가 없으면 추가·있으면 스킵(기존 항목 보존). (d) 치수: `Image.asset`에 width/height를 항상 박지 않는다 — 시안 명시값만(글리프 vs 래스터 직교). **중립 예시만**(weather 금지).

- [ ] **Step 2: SKILL.md 라우팅 ①핵심 운영 원칙** — 앵커 grep `컨트롤러는 State가 생성·dispose가 해제`(마지막 운영 원칙 불릿). 그 인근에 불릿: `- 정적 이미지 에셋은 Image.asset(AppAsset.<token>) — raw 경로 금지·경로는 asset-manifest(src 조인)·pubspec assets 디렉터리 선언 (§8)`.

- [ ] **Step 3: SKILL.md 라우팅 ②상세 레퍼런스 표** — 앵커 grep `테스트 표기는 어디로 이전했나`(표 마지막 행). 그 뒤에 행: `| 정적 이미지 에셋·Image.asset·pubspec assets 표기 | final.md §8 |`.

- [ ] **Step 4: SKILL.md 라우팅 ③언제 쓰나** — 앵커 grep `hive 캐시·어댑터를 쓸 때, StatefulWidget`(언제 쓰나 문장). 그 나열에 `, 정적 이미지(Image.asset)를 배선할 때` 추가.

- [ ] **Step 5: final.md 자동 미러** — `dart run workspace/reference/corpus_mirror_sync.py --write`(또는 해당 경로) 후 architecture-ui처럼 implementation-flutter final.md만 동기 확인(타 stale 소스는 `git restore`). SKILL.md codex(`codex-dddart/skills/implementation-flutter/SKILL.md`)는 **수동** 3장치 반영.

- [ ] **Step 6: 검증** — `grep -n 'Image.asset' codex-dddart/skills/implementation-flutter/references/final.md` → §8 존재(자동 미러 확인). SKILL.md 양판 §8 라우팅 3장치 grep.

---

## Task 5: coder — manifest 입력·src 조인·배선

**Files:**
- Modify: `dddart/agents/coder.md`
- Mirror: `codex-dddart/skills/dddart-coder/SKILL.md` (수동·앵커)

- [ ] **Step 1: manifest 입력 슬롯** — 앵커 grep coder 입력 목록의 `server-contract.json`(또는 `경량본`). 그 인근에 1항목: *"- (있으면) `asset-manifest.json` — 시안 이미지의 `src`→`local_path`→`token` 매핑(SSOT). 명세가 `src`로 가리킨 이미지를 이 manifest에서 **같은 src 행으로 조인**해 `token`·`local_path`를 정확히 가져온다(server-contract를 경량본에서 인용하듯 — 추정·눈대중 금지)."*

- [ ] **Step 2: 배선 지시 + gate** — Step 1 항목에 이어: *"각 조인된 이미지마다 `app_asset.dart`에 `static const String <token> = '<local_path>';`를 추가하고(app_color 등 foundation 토큰과 동형), pubspec `flutter: assets:`에 `- assets/images/`를 멱등 선언하며(없으면 추가·있으면 스킵), 위젯에 `Image.asset(AppAsset.<token>)`로 배선한다(raw 경로 금지 — implementation-flutter §8). **`has_design_images`가 없으면 이 단계 전체를 건너뛴다**(manifest 부재 시 에셋 배선 없음 — 조용한 placeholder 금지)."*

- [ ] **Step 3: 양판 미러** — `codex-dddart/skills/dddart-coder/SKILL.md` 반영·grep 확인.

---

## Task 6: architecture-ui §7 — AppAsset 획득 cross-ref

**Files:**
- Modify: `dddart/skills/architecture-ui/references/final.md` (자동 `--write`)

- [ ] **Step 1: §7 AppAsset 불릿에 cross-ref** — 앵커 grep `표준 7토큰의 7번째가 \`app_asset\``(§7 L104). 그 문장 끝에 1구: *"— 토큰의 경로 *값*은 공급 파이프라인(`fetch_images`→`asset-manifest`→coder가 src 조인→`app_asset.dart`)이 채운다(이 절은 *사용*, 획득은 design-architect 명세·implementation-flutter §8 소관)."*

- [ ] **Step 2: 자동 미러** — `corpus_mirror_sync.py --write`로 architecture-ui final.md 동기(소스·codex)·타 stale 소스 `git restore`로 격리(레이아웃 시술 패턴).

---

## Task 7: 정합 검증·동결·커밋

- [ ] **Step 1: 양판 일관 grep** — 각 시술 지점의 앵커 문구를 claude·codex 양쪽에서 grep해 동일 의미 확인. `cmp dddart/scripts/fetch_images.dart codex-dddart/skills/dddart/scripts/fetch_images.dart` 무출력.
- [ ] **Step 2: corpus_mirror_sync 정합** — `corpus_mirror_sync.py`(검증 모드)로 final.md 9종 in_sync 확인(architecture-ui·implementation-flutter는 이번 변경분 sync·나머지는 기존 상태 보존).
- [ ] **Step 3: 과적합 스캔** — 시술된 코퍼스 산문에 `grep -rn 'weather\|forecast\|weatherDetail' <변경 파일들>` → 규약 어휘 0(중립 예시만). `Image.asset` 치수 강제 문구 0.
- [ ] **Step 4: 레이아웃 + 에셋 동시 커밋** — 워킹트리의 레이아웃 5파일(미커밋) + 이번 에셋 변경을 **한 커밋**으로. 메시지: `dddart 생성측 강제 v4 — 레이아웃 크기연결 + 에셋 공급 파이프라인(fetch_images·manifest SSOT·implementation-flutter §8)`. footer: `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>` + `Claude-Session: …`.
- [ ] **Step 5: 동결 선언** — 13차 라이브런까지 코퍼스 동결(소급 변경 금지). 측정 항목(§8): hero size·`Image.asset` 다운로드·manifest token 수=배선 수.

---

## Self-Review (writing-plans)

1. **Spec coverage**: 설계 §5 A~F → Task 1(A)·2(B)·3(C)·4(D)·5(E)·6(F)·7(검증·동시커밋). 모든 시술 지점 커버 ✔.
2. **Placeholder scan**: fetch_images 완전 dart는 Task 1 Step별 로직으로 분해(정규식·다운로드·token·manifest 구체)·sha256은 dart:io 한계로 선택/생략 명시 — TODO 없음 ✔.
3. **Type/이름 일관**: manifest 필드(`src·alt·local_path·token·status`)·`has_design_images`·`AppAsset.<token>`·`assets/images/`가 Task 1~6 전반 동일 ✔. status 열거(`ok|failed|inline|skipped`) §7과 Task1 Step3·4 일치 ✔.
4. **앵커 grep**: 모든 코퍼스 Edit이 라인 아님 앵커 문구 기반 ✔. 양판·cmp 명시 ✔.
