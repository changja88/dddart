# 에셋(Track A) brainstorming 준비 — compact 후 재개

> **상태**: ✅4결정 합의(①별도스크립트 fetch_images·②직행 assets/images[design-ref/images 폐기]·③디렉터리 선언·④분담)·✅설계 명세 **v2 완성**(4렌즈 적대 리뷰 치명3건 교정·진실원천 `2026-06-21-asset-track-a-design.md`)·**다음 = plan(writing-plans) → inline 시술**(레이아웃과 동시 커밋·동결·13차 라이브런). ★핵심: layout-ir 에셋매핑서 분리·manifest 단일SSOT(중첩이미지 전수)·architect=src의미/coder=manifest token직접·implementation-flutter SKILL.md 라우팅갱신·has_design_images gate 3곳·scripts cmp검증.
> **재개 방식**: 이 문서 읽고 → **§4 핵심 결정을 결정 1부터 *하나씩 자세히***(사용자 명시 요청) → 설계 → 4렌즈 적대 리뷰 → plan → 시술. (레이아웃 강제와 동일 흐름.)
> **불변 제약**: 양판 미러(claude↔codex·final.md 자동 --write·agents/SKILL.md/commands 수동·앵커 문구)·과적합 금지(weather·런 번호 서사 코퍼스 금지)·measure-first·HaffHaff 치수 강제 모방 경계·조용한 폴백 금지·layout-ir 픽셀 미포함 불변·brainstorming HARD-GATE(설계 승인 전 시술 없음).

---

## 1. 배경·사용자 의도

- **레이아웃 강제 시술 완료**(메모리 진입점 21·5파일·양판 미러·green) 후, 사용자: "UI에 이미지가 있어서 asset도 처리해야 **더 정확하게 확인** 가능" → **레이아웃 + 에셋 둘 다** 채택.
- 내가 제안한 "레이아웃 먼저·에셋 후속(N=1 단일변수)"을 **사용자가 거부** — *이미지 자리가 비면 레이아웃 충실도도 온전히 확인 불가*가 우선(UI 온전 재현). 측정은 둘을 grep 구분 관측으로 분리.
- **"하나씩 자세히"** 진행 요청 → §4 결정을 한 개씩 깊이.

## 2. 근거 (자료조사 G4)

- 보고서 `workspace/design/2026-06-21-layout-asset-research.md` **§4**(에셋 사용 방법) — 공급 사슬·Flutter 공식 모범·Phase 0 후보·HaffHaff 가드 규명 완료.
- **공급 사슬**: `Stitch HTML <img src>` → [다운로드] → `design-ref/images/` → [번들·등록] `assets/images/` → [토큰화] `AppAsset` const → [표시] `Image.asset`.
- **현 코퍼스 갭(grep 실증 2026-06-21)**: AppAsset 토큰·사용 규칙(`architecture-ui §7 L104` "여기는 *사용 절차*만 정한다")만 존재. 공급 사슬 전부 빔 — `extract_design` image 로직 **0**·Phase 0(commands) `<img>` 다운로드 **0**·coder/implementation-flutter pubspec `assets:` 지침 **0**.
- 입력은 준비됨: `extract_layout.dart:209-210`이 이미 `<img>`의 src·alt를 layout-ir image 노드로 추출 중 → 다운로드할 URL 목록 기계 추출됨.

## 3. 이미 확정된 것 (자료조사·이전 사용자 결정 — 재론 불요)

- **빌드타임 `Image.asset`** — Stitch CDN URL 다운로드 가능하나 수명 보장 없음 → 런타임 `Image.network` 직참조 회피 ([[stitch-image-asset-bundling]]).
- **`assets/` 복수 디렉터리** — HaffHaff `asset/` 단수 모방 교정 완료(진입점 16).
- **치수 강제 모방 금지** — `Image.asset`에 width/height 항상 박기 금지·시안 명시값만(진입점 16·HaffHaff 가드).
- **라이선스 = 고려 없음·코퍼스에 안 박음** — 속도 우선(사용자 기결정·진입점 10 D-License).

## 4. 핵심 결정 (하나씩 자세히 — 각 권장안·세부 옵션)

### 결정 1 — 누가/어떻게 다운로드 (★설계 성격 가름)
- ① Coordinator(LLM)가 직접 `curl`
- ② **결정론 스크립트 (권장)** — `extract_layout`이 뽑는 src 목록을 받아 일괄 다운로드(별도 스크립트 or extract_layout 확장)
- **세부 논점**: src 입력(layout-ir image 노드 src)·저장 위치(design-ref/images/)·파일명 규칙(`<screen>-<n>.png`?)·다운로드 실패 처리·LLM 추출 금지 원칙 정합.
- **권장 이유**: dddart 철학 "LLM 추출 금지·결정론 동결" — 스크립트가 런마다 동일·재현 가능.

### 결정 2 — 어디에 저장·경로 규칙 (★)
- **design-ref/images/**(다운로드 원본·동결·진실원천) → coder가 **assets/images/**로 번들 → `AppAsset` const가 경로 토큰화 *(권장: 2곳 분리)*
- **세부 논점**: AppAsset const 네이밍·경로 매핑 규칙(design-ref/images/X → assets/images/X → AppAsset.x)·소유(AppAsset 토큰=discipline-houserules 7토큰 닫힌 열거 / 획득 절차=Phase 0+coder).
- **권장 이유**: design-ref=눈대중 방지 진실원천·assets=앱 빌드 번들 — 역할 분리가 기존 동결 패턴 정합.

### 결정 3 — pubspec 등록 방식
- **디렉터리 선언 `flutter: assets: [assets/images/]` (권장)** vs 파일별 나열
- **세부 논점**: "직속 파일만 포함·하위디렉터리 별 엔트리" 함정(context7 검증)·의도치 않은 번들 위험.

### 결정 4 — 분담 (3 Phase)
- **Phase 0 Coordinator**: src 다운로드 → `design-ref/images/` + `has_design_images` 플래그·G0 배너(다운로드 실패·placeholder 구분·조용한 폴백 금지)
- **design-architect**: 명세에 "어느 이미지가 어느 화면 조각에" + `AppAsset` 경로 박기 — layout-ir image 노드(src,alt)를 소비. 소비 지시(L38 화면 ui 불릿)에 이미지 추가? (레이아웃 시술처럼 design-architect 확장)
- **coder**: `assets/images/` 번들 복사·pubspec 선언·`Image.asset` 배선
- **세부 논점**: design-architect 소비 지시 확장 형태(layout-ir image src → 명세 AppAsset)·coder 배선 규율 위치(implementation-flutter? 명세 집행으로 충분?).

## 5. 시술 지점 후보 (G2·G4·코퍼스 grep)

| Phase | 파일 | 변경 | 미러 |
|---|---|---|---|
| 0 다운로드 | `dddart/commands/dddart.md` ↔ codex `dddart-*/SKILL.md` | `<img>` src curl·design-ref/images/·has_design_images·G0 배너 | **수동** |
| 0 추출 | `dddart/scripts/extract_layout.dart`(or 신규 다운로드 스크립트) | src 목록 일괄 다운로드(결정 1=②면) | (scripts 미러 규약 확인) |
| 1 설계 | `dddart/agents/design-architect.md` ↔ codex SKILL.md | 소비 지시에 이미지(AppAsset 경로) 박기 | **수동** |
| 1·2 규율 | `dddart/skills/architecture-ui/references/final.md §7`(AppAsset 사용)·`implementation-flutter` | 획득→토큰화→배선 절차 | final.md **자동** --write |
| 토큰 | `dddart/skills/discipline-houserules`(AppAsset 7토큰 정의) | 획득 절차 추가? | final.md 자동 |

## 6. 재개 후 흐름 (compact 후)

1. 이 문서 + G4 보고서 §4 읽기.
2. **결정 1부터 하나씩 자세히** brainstorming(분석+권장 후 자유 응답·AskUserQuestion 금지).
3. 합의 → 설계 명세(`2026-06-21-asset-track-a-design.md`) → 4렌즈 적대 리뷰(과적합·모순·실효성·소비성) → plan → inline 시술(별도 승인·양판 미러).
4. **측정**(다음 런·레이아웃과 함께): 크기(hero size)·이미지(`Image.asset` 존재·경로·실제 다운로드됐나) 각각 grep 구분 관측. 12차 "이미지 자리만·다운로드 안 함"이 해소됐나가 에셋 1차 성공 기준.
