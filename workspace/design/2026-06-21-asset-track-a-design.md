# 에셋(Track A) 공급 파이프라인 — 설계 명세 (2026-06-21·v2 4렌즈 교정)

> **목적**: Stitch 시안의 `<img>` 이미지를 **빌드타임 다운로드 → 번들 → `AppAsset` 토큰화 → `Image.asset` 배선**하는 공급 사슬을 코퍼스에 닫는다. 소비측(AppAsset 토큰·사용 규칙)은 Track B(`480eb11`)로 이미 완비, **공급측이 빈 사슬**(다운로드·번들·pubspec 소유자 0)이라 12차 "이미지 자리만·실제 다운로드 안 함" 증상 발생.
> **상태**: brainstorming 4결정 합의 완료 + **4렌즈 적대 리뷰 교정 완료(v2)**. 다음 = **plan(writing-plans) → inline 시술**. 레이아웃 강제와 **동시 커밋·동결·13차 라이브런**.
> **불변 제약**: 양판 미러(claude↔codex·final.md 자동 `--write`·SKILL.md/commands/agents/scripts 수동+cmp·앵커 문구)·과적합 금지(weather·런 번호 서사 코퍼스 금지)·**layout-ir 픽셀 미포함 불변**(에셋 매핑은 layout-ir과 완전 분리)·HaffHaff 치수 강제 모방 경계(`Image.asset` width/height 강제 금지)·measure-first(효과는 13차 실측)·조용한 폴백 금지·brainstorming HARD-GATE(이 명세 승인 전 시술 없음).
> **근거(진실원천)**: 자료조사 2회 fan-out 6갈래 + 4렌즈 적대 리뷰(과적합·정합·견고성·소비성). 보고서 `2026-06-21-layout-asset-research.md §4`·어제 `2026-06-19-stitch-fidelity-research.md`.

---

## §0. 4렌즈 교정 요약 (v1→v2)

| 치명/중 | v1 결함 | v2 교정 |
|---|---|---|
| 치명 | **fetch 입력 모순**(raw HTML vs layout-ir src) + 중첩 이미지 silent-drop | **fetch = raw HTML 전수**(모든 `<img>`)·**manifest = 단일 SSOT**·layout-ir 에셋 매핑에서 완전 분리(§2·§3) |
| 치명 | §2/§3 모순(architect가 token 문자열 박음) | **architect = src 의미 매핑만·coder = manifest에서 token 직접**(§2·§3·§5-C) |
| 치명 | §5-D 발견불가(SKILL.md 라우팅 미갱신) | **SKILL.md 라우팅 3장치 갱신 명시**(§5-D) |
| 중 | `has_design_images` gate 부재 | **3곳 동형 gate**(Coordinator·architect·coder)+`commands:153` 호출입력(§5-B·E) |
| 중 | scripts 수동 미러 이미 drift(codex backstop stale) | **corpus_mirror_sync 스코프 확장 검토 + cmp 검증 의무**(§5 미러) |
| 중 | 에셋만 결정적 floor 0 | **13차 후 후속 1순위 floor 명시**(§5·§8) |
| 중 | §7 fail-fast 표면화 경로 추상 | **G0 배너 스키마+문구 구체화**(`dddart.md:128` 동형)(§7) |
| 경미 | 비-http src·codex 경로 오기·인용 과장·측정 배선판정 | 일괄 정정(§3·§5·§6·§8) |

---

## §1. 4개 결정 (brainstorming 합의)

| # | 결정 | 핵심 근거 |
|---|---|---|
| **1. 다운로드 주체** | **결정론 스크립트 `fetch_images.dart`**(별도·LLM curl 아님) | stitch-sdk `download-handler`가 하는 그 방식(Cheerio로 `<img src>` 추출→fetch→저장)과 동형 = **SDK 공식 패턴**. MCP 바이트 직접 제공은 host(Claude Code)가 디스크에 못 떨궈 무용(claude-code #9152·MCP #199) |
| **2. 저장 위치** | **직행 = `assets/images/` 1곳**(`design-ref/images/` 폐기) | 이미지는 색과 달리 PNG→PNG라 복사가 순수 중복(색은 JSON→Dart). `assets/images/` **git 커밋이 동결**을 흡수(CDN 24h 무관) |
| **3. pubspec 등록** | **디렉터리 선언 `- assets/images/`**(평면·멱등·배수 안 씀) | 이미지 수 무관 1줄·멱등. 평면이라 "직속만 포함" 함정 회피. resolution-aware 배수는 치수 강제 경계 (context7 `/flutter/website`) |
| **4. 분담** | **Phase 0 다운로드 / architect 의미연결 / coder 정확배선** + manifest SSOT + token 결정론 | 아래 §2~§7 |

---

## §2. 재구성 파이프라인 (분담·데이터 흐름)

```
[Phase 0 — Coordinator]
  extract_layout.dart → layout-ir.json   (구조 IR — ★에셋 매핑에서 완전 분리·불변)
  fetch_images.dart   ← design-ref/*.html (raw HTML 전수 — area `<img>` + section/slot 중첩 `<img>` 모두)
                      → assets/images/*.png                     (앱 소스·번들·git 커밋이 동결)
                      + .dddart/<폴더>/asset-manifest.json        (★단일 SSOT — 모든 <img> 전수)
                      + has_design_images 플래그(has_stitch_html 종속) · G0 배너(다운로드 실패 표면화)

[Phase 1 — design-architect]
  ← asset-manifest.json  (★layout-ir 아님 — 에셋 식별은 manifest 전담)
  → 설계 명세에 "src=<URL> 이미지 → 화면 <X>의 <조각>" 의미 매핑을 정형 목록으로 박음
    (§8 크기연결과 *구조 동형*: 추출 항목 수만큼·빈칸 0·★token/경로 문자열은 안 박음 — src가 조인 키)

[Phase 2 — coder]
  ← 명세(의미 연결) + asset-manifest.json  (★src로 조인 → token·local_path 직접 읽음)
  → app_asset.dart (AppAsset.<token> = 'assets/images/…')   (app_color 수동 작성과 동형·token은 manifest가 줘 환각 차단)
  → pubspec.yaml  flutter: assets: [- assets/images/]        (멱등 — 이미 있으면 스킵)
  → Image.asset(AppAsset.<token>) 배선                       (implementation-flutter §8 표기·architecture-ui §7 사용 규율)
```

**왜 이 분담인가**(자료조사 G3 — dddart 내부 정합):
- **architect의 manifest 소비 ≈ design-tokens 소비**: 기존 패턴은 "원본은 architect만 읽고 명세에 박음, coder는 명세를 봄". 단 **에셋은 token·local_path 정확 문자열 N개라 server-contract 패턴**(architect=의미·coder=정확값)을 따른다 — manifest를 coder도 직접 읽는다(§3).
- **coder의 app_asset 수동 ≈ app_color 수동**: design-tokens→`app_color.dart`조차 전용 스크립트 없이 "architect 명세 + houserules 골격 + coder 수동 작성"이 유일 경로(검증: app_color 생성 스크립트 부재·백스톱 checker만 참조). AppAsset도 동형이나 **token은 manifest가 줘 환각 차단**.
- **다운로드는 Phase 0**: coder 다운로드는 "coder는 명세 집행자·입력 계약만"(coder 경계)과 충돌. 동결 주체는 일관되게 Coordinator.

---

## §3. asset-manifest.json — 단일 SSOT (src=조인 키)

자료조사 G2: in-place rewrite는 SSOT를 가변 IR에 묻어 역추적·검증 불가. Flutter 자체가 manifest 모델. → **별도 manifest**가 design-tokens·layout-ir·server-contract와 **같은 계열 동결 산출물**이며 **모든 `<img>`의 단일 진실원천**.

```jsonc
// .dddart/<폴더>/asset-manifest.json (fetch_images.dart 산출·동결)
{
  "images": [
    {
      "src":        "https://lh3.googleusercontent.com/aida-public/…",  // ★조인 키(명세↔manifest)·원격 원본 보존(역추적)
      "alt":        "weather illustration",
      "local_path": "assets/images/home-1.png",                         // 번들 경로
      "token":      "home1",                                            // AppAsset.<token> — 결정론(§4)
      "status":     "ok"                   // ok | failed | inline | skipped (§7) — 위 5필드가 coder 소비분
      // sha256(무결성·재다운로드 탐지)은 무의존 dart에 crypto가 없어 1차 미구현 — 선택·후속(coder 비소비)
    }
  ]
}
```

- **입력 = `design-ref/*.html` raw 파싱**(extract_layout과 동일 디렉터리). **모든 `<img>` 전수** — area-level(상단 일러스트)뿐 아니라 **section/slot 중첩 이미지**(카드 썸네일·리스트 아바타)도 포함. `extract_layout:210`은 area-level만 src를 싣지만, fetch_images는 layout-ir이 아니라 **원본 HTML을 보므로** 중첩 누락이 없다.
- **layout-ir은 안 건드린다** — 에셋 매핑은 manifest 전담, layout-ir은 area 골격 전담(픽셀 미포함 불변과 동렬·FID 게이트 무영향).
- **src = 조인 키**: 명세(architect)는 image를 `src`로 가리키고, coder는 manifest에서 **같은 src 행**의 `token`·`local_path`를 읽는다 — 한 화면에 이미지가 여럿이어도 src로 결정적 조인(alt·순서 추정 금지).
- **architect·coder 둘 다 읽는다**(`has_design_images` 게이트로 경로 전달). 역할: **architect=src 의미 매핑**(어느 이미지가 어느 조각에)·**coder=src 조인해 token·path 정확 값**. 정확 문자열 N개를 명세로 *옮기다* 틀리느니 manifest가 coder 단일 근거(server-contract 동형). manifest는 작아 절단 불필요.

---

## §4. token 결정론 규칙 (fetch_images 부여 — coder 환각 차단)

자료조사 G1: flutter_gen 식별자 변환은 4개 정규식 순수 함수 — **무의존 dart로 복제 가능**(extract_design 패턴). fetch_images가 token을 부여하면 coder는 베끼기만 → 파일명↔토큰 불일치 구조적 불가.

- **입력 전제**: fetch_images = `design-ref/*.html`(extract_layout과 동일 디렉터리). 화면 식별자 = HTML 파일명 stem(`extract_layout:63`이 쓰는 그 값과 동일 출처).
1. **파일명**: `<screen-slug>-<n>.<ext>` — 파일명 stem + 화면 내 `<img>` 순서 인덱스. ext는 Content-Type/매직바이트 판정(Stitch 보통 PNG).
2. **token(camelCase)**: 파일명 stem을 `[^A-Za-z0-9]`로 단어 분해 → 첫 단어 소문자·이후 첫 글자 대문자(`home-1` → `home1`).
3. **숫자 시작 방어**: 식별자가 문자로 시작 안 하면 `a` prepend(규칙으로 보유).
4. **충돌 dedup**: 동일 token 발생 시 `_<n>` suffix 점진 추가(결정론).
5. **입력 정렬**: 파일/노드 목록을 명시 정렬한 뒤 인덱스 부여(동일 입력→동일 출력).

---

## §5. 시술 지점 (양판 미러)

| # | 변경 | claude | codex | 미러 |
|---|---|---|---|---|
| A | **신규 `fetch_images.dart`** — `design-ref/*.html` raw 전수 다운로드→assets/images·manifest 산출·token 부여·status | `dddart/scripts/fetch_images.dart` | `codex-dddart/skills/dddart/scripts/fetch_images.dart` | **수동 + `cmp` 검증** |
| B | **Coordinator** — Phase 0에 `fetch_images` 호출(`has_stitch_html` 시·extract 단계)·`has_design_images` 플래그·**G0 배너 스키마+문구**(실패 N/M)·**closed-list(line 9·204)에 `assets/images/` 추가**·**coder 호출입력(line 153)에 manifest 경로 추가** | `dddart/commands/dddart.md` | `codex-dddart/skills/dddart/SKILL.md` | **수동**(앵커) |
| C | **design-architect** — manifest 소비·**src 의미 매핑 정형 목록**(§8 동형·전수·빈칸0·token 안 박음)·`has_design_images` 입력 | `dddart/agents/design-architect.md` | `codex-dddart/skills/dddart-design-architect/SKILL.md` | **수동**(앵커) |
| D | **implementation-flutter** — `Image.asset`·pubspec `assets:` **표기 신설(final.md §8) + SKILL.md 라우팅 3장치 갱신**(핵심 운영 원칙 불릿·상세 레퍼런스 표 행·언제 쓰나) | `dddart/skills/implementation-flutter/references/final.md` + `SKILL.md` | `codex-dddart/skills/implementation-flutter/references/final.md` + `SKILL.md` | final.md **자동 `--write`**·SKILL.md **수동** |
| E | **coder** — manifest **입력 슬롯 추가**·src 조인→app_asset.dart·pubspec 멱등·Image.asset 배선·`has_design_images` gate | `dddart/agents/coder.md` | `codex-dddart/skills/dddart-coder/SKILL.md` | **수동**(앵커) |
| F | **architecture-ui §7**(권장·선택 아님) — AppAsset 토큰 경로의 *획득* cross-ref 1줄(공급 사슬↔사용 규율 폐곱) | `…/architecture-ui/references/final.md` | 동 경로(`--write` 미러) | 자동 `--write` |

- **`extract_layout.dart` 변경 없음**(layout-ir 불변·에셋과 분리).
- **discipline-houserules 변경 없음**(app_asset 이미 7번째 토큰·신규 토큰 아님). AppAsset *사용 규율*은 명세(C)·implementation-flutter(D)로 coder 도달.
- **scripts 미러 무결성**(4렌즈 F2): codex `backstop.dart`가 이미 stale(claude 58체크 vs codex 57). `corpus_mirror_sync.py`는 scripts를 미러 스코프 밖에 둠. → **시술 시 fetch_images를 `cmp`로 양판 byte-exact 검증**하고, **corpus_mirror_sync 스코프를 `scripts/*.dart`로 확장**(불변식2 동형)을 별도 검토(backstop drift도 동반 해소·plan에서 결정).
- **후속 1순위 floor**(4렌즈 F1·measure-first): 13차 라이브런 후, `check_pubspec.dart`에 "`Image.asset(` 리터럴이 lib/에 있는데 pubspec `flutter: assets:` 미선언이면 발화"(거짓양성 가드: Image.asset 사용 시만) 결정적 백스톱 추가 검토. backstop이 lib/만 봐도 가능(pubspec은 이미 읽음).

---

## §6. 기존 패턴 정합·사각·경계 예외 (4렌즈 검증)

**정합(코퍼스 직독 성립·4렌즈 F3~F6)**: ① architect manifest 소비 = design-tokens/server-contract 소비 동형 ② app_asset 수동 = app_color 수동(생성 스크립트 부재 확인) ③ pubspec은 coder가 deps 핀으로 *건드리는* 선례 있음(`coder.md:60` — 단 `assets:` 블록 멱등 등록은 **시술 D로 신설**, deps 핀과 별개) ④ `has_design_images`는 `has_layout_ir`/`has_design_tokens`(build-state JSON·architect·review-ui 전달) 패턴과 동형 ⑤ layout-ir 불변(fetch는 manifest만 산출·FID 무영향).

**메울 사각(시술 D·E로)**: coder가 architecture-ui를 **안 본다**(로드 스킬 7개: implementation-*·discipline-* — frontmatter 확인). AppAsset/Image.asset 규율이 ui §5·§7에만 있어 coder 사정권 밖 → `Image.asset`·pubspec 표기를 **implementation-flutter final.md §8 + SKILL.md 라우팅에 신설**(D·라우팅 미갱신 시 coder가 §8 발견 못 해 raw 경로 도망 = 12차 변종) + 사용 규율은 **명세가 박음**(C→E).

**경계 예외(시술 B로 명문화)**: 기존 "Phase 0는 `.dddart/design-ref`에만 동결"(Coordinator closed-list `commands:9·204`)을 직행이 깸 → **closed-list 자체에 `assets/images/` 추가** + 예외 조문: *"외부 진실 동결처는 design-ref가 기본이나, 이미지는 입력=출력이라 동결처가 곧 번들처(`assets/images/`)다."* (검증: backstop은 `toLibRel`로 lib/ 밖을 버려 무관심·soft-reset은 `--soft`라 무손상·중단복구 무충돌 — 4렌즈 F3 확인).

> **줄 인용 정정(4렌즈 F7)**: v1 §2가 "`design-architect.md:38`에 image 박는 자리 이미 존재"라 했으나, :38의 `image(src,alt)`는 layout-ir **area-tree 예시 토큰**일 뿐 에셋 매핑이 아니다 — **시술 C는 신규 지시**(기존 자리 확장 아님).

---

## §7. 실패 처리 — fail-fast (조용한 폴백 금지·4렌즈 교정)

- **다운로드 부분 성공 허용** + 실패를 manifest `status:"failed"`로 기록(성공분 진행).
- **비-http src 분기**(4렌즈 M2): src가 `http(s)`가 아니면 — `data:` URI는 디코드→저장(`status:"inline"`), 상대/`file:` 등은 `status:"skipped"`로 표면화. weather(전부 CDN) morphology에 묶이지 않게 fetch_images에 "src 스킴 분기"를 박는다.
- **G0 배너 구체화**(4렌즈 #4): `dddart.md:128` "디자인 출처 해소 실패 — 조용히 폴백 금지" **동형**으로 — 배너 JSON 스키마(line 55-56 근처)에 `has_design_images`, 배너 문구(line 130)에 "이미지 N/M 다운로드 실패·placeholder 금지" 1줄. **둘 다** 시술 B.
- **architect**: `status:failed` 노드는 명세에 "미해결 에셋"으로 표기(조용히 placeholder 금지).
- **빌드타임 asset은 fail-fast**(런타임 graceful degradation 아님): 미해결 failed가 남으면 표면화.

---

## §8. 측정 (measure-first·13차 라이브런)

- **에셋 1차 성공 기준**: 12차 "이미지 자리만·다운로드 안 함" 해소.
- **grep 구분 관측**:
  - 다운로드: `ls assets/images/*.png` + manifest `status:"ok"` 수.
  - pubspec: `grep 'assets/images' pubspec.yaml`.
  - 배선: `grep 'Image.asset(AppAsset.' lib/` — **단 존재만으론 부족**. **manifest token 수 = 배선 `Image.asset(AppAsset.X)` 수 대조**(다운로드 N개 중 배선 M개 차 = 흘린 이미지·중첩 누락 검출·4렌즈 #6).
- **레이아웃과 동시 측정·분리 관측**: 크기(hero size↔시안)와 이미지(다운로드·경로·배선)를 각각 grep으로 구분.
- **결정적 floor 후속**(§5): 13차 후 효과 실측 → check_pubspec floor 도입 판단(measure-first). 효과는 다음 런 전 미확정(in-family 한계).

---

## §9. 과적합·HaffHaff 가드

- **weather 픽셀·파일명을 코퍼스에 박지 않는다**: 규율은 "추출 이미지를 다운로드·번들·토큰화·배선"이라는 범용 절차. `home-1`·`weatherDetail1` 등은 *예시*(SCENARIO 자산·문서에 격리·코퍼스 산문엔 중립 예시 `assets/logo.png`·`AppAsset.heroIllustration`만).
- **중첩 이미지 morphology**(4렌즈 M1): weather는 hero `<img>` 1개라 단순. **카드/리스트 화면의 section 내부 이미지**가 진짜 시험대 — fetch가 raw HTML 전수라 포섭(설계가 weather 1종에 과적합 안 되게 manifest·정형목록이 N개·중첩 모두 다룸).
- **치수 강제 모방 금지**: `Image.asset`에 width/height를 항상 박지 않는다 — 시안 명시값만(글리프 vs 래스터 직교는 architecture-ui §5·§7이 코드로 집행 — 4렌즈 무혐의). 이미지 *크기*는 레이아웃 강제(§8) 트랙·*경로*는 에셋 트랙으로 직교.
- **라이선스**: 사용자 기결정(고려 없음·코퍼스 미반영). 자료조사 진전(상업적 사용 공식 허용·단 AI 이미지 저작권 보호불가·SynthID·스톡 혼입 미분해)은 **보고만**.

---

## §10. 자료조사·리뷰 근거

- **결정 1 fan-out**: G1 Figma(REST export curl·localhost asset 앱 의존)·G2 MCP 프로토콜(ImageContent base64 가능하나 host 디스크 미저장·#9152·#199)·G3 Stitch SDK(download-handler 직독·공식 14툴 바이트 0·get_image는 써드파티 프록시).
- **결정 4 fan-out**: G1 flutter_gen(식별자 4정규식·무의존 복제·소스 직독)·G2 멀티스테이지(manifest SSOT=Flutter 자체·fail-fast·content-hash)·G3 dddart 내부(코퍼스 줄 인용·정합/사각/예외).
- **4렌즈 적대 리뷰**: 과적합·HaffHaff(무혐의)·기존 정합(F1~F7)·실효성/견고성(CRITICAL 중첩 이미지·gate)·AI 소비성(F1~F5 산문 결정성/발견성). 치명 3건 v2 교정.
- ⚠️ 전원 Claude 계열(in-family). 핵심은 1차 견고(manifest=Flutter 메커니즘·flutter_gen=소스 직독·dddart=코퍼스 직독·scripts drift=cmp 실증).
