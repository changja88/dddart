# 레이아웃 강제 + 에셋 사용 — 자료조사 계획 (2026-06-21 · compact 후 실행)

> **상태**: 자료조사 대기(compact 후 ultracode workflow fan-out). 이 문서 = compact 후 첫 재개 근거.
> **방향**: A 확정(사용자 승인 2026-06-21). **목표** = 레이아웃 강제 + 에셋 사용 방법을 dddart 코퍼스에 추가하는 *설계 근거*를 자료조사로 수집(설계·시술은 그 다음·별도 승인).
> **불변 제약**: 코퍼스 변경 = 별도 승인·다음 런 동결·양판 미러(claude↔codex byte-identical)·과적합 금지(weather 특화 철거·범용)·measure-first(강제 방언은 다음 런 실측)·HaffHaff 모방 경계·brainstorming HARD-GATE(설계 승인 후 구현).

---

## 1. 배경 — 왜 이 작업인가 (12차 라이브런 사용자 평가)

12차(코퍼스 `480eb11`·Track B layout 입력유도) 후 **사용자 육안 평가**:
- **codex**: UI 시안 거의 완벽 구현 — 기존 약점(claude보다 덜 충실) **개선**.
- **claude**: UI 시안과 다름·**특히 크기** — 기존 강점(시안 충실) **퇴행**.
- 공통: 이미지(브로콜리) 자리만·실제 다운로드 안 함(= Track A 미시술·예상).
→ **UI 충실도 역전.**

### 원인 규명 (systematic-debugging·증거 확정)
hero 상태 아이콘 크기로 추적:
| | hero 아이콘 | 비고 |
|---|---|---|
| 시안(design-tokens `text-[120px]`) | 120px | 양판 동일 |
| 11차 claude (Track B 전) | 96px | 충실 — coder가 시안 직접 봄 |
| 12차 claude (Track B 후) | **32px** | 퇴행 |
| 12차 codex | 120px | 충실 — `design-spec:208` "text-120px=hero icon size" 명시 연결 |

- **주원인**: Track B area 트리(HTML 추상 어휘 `appbar/section/bottomnav` + "기하는 상대만·픽셀 절대 금지")가 claude의 **시안 직접 참조를 *대체*** → hero 아이콘이 크기 없는 "icon slot"으로 추상화·크기 소실. 11차엔 area 트리가 없어 coder가 시안 직접 보고 96px, 12차엔 area 트리가 "구조 답"을 줘 coder가 시안 덜 보고 32px.
- **증폭(코퍼스 갭)**: `design-architect.md`의 design-tokens 명세 지시가 "**색·spacing·아이콘**"만 열거 → `typography`·`arbitraryValues`(text-120px 등 크기) 누락. claude design-spec에 `text-[120px]` 0회.
- **근본**: **architecture-ui 7개 절(분해·매핑·토큰)에 "시각 레이아웃/크기 충실" 규율이 없다.** 색·아이콘은 `condition`(도메인)에 묶여 ui_extension(§5)이 매핑하지만, **크기는 묶일 도메인이 없어 명세에 연결될 자리가 없다** → 빈 칸. codex는 자율로 메우고(L208) claude는 흘림.

## 2. 확정 방향 — A (architect가 조각에 크기 연결)

- architecture-ui(**설계측**)에 "분해한 각 조각에 시안 크기·배치를 *연결*하라"는 레이아웃 강제 규율을 추가한다.
- **A-key**(부하·오류 관리): architect가 새 픽셀을 눈대중 발명하는 게 아니라, **design-tokens가 이미 추출한 크기(typography·arbitraryValues)를 dddart 위젯 조각에 *연결*만** 한다. 미세 간격은 `AppSpacing` 토큰.
- **분해는 상태 기준(dddart 원칙) 유지** — 그 위에 크기를 얹는다(직교). area 트리(layout-ir)는 "영역 누락 방지"용으로만 남길지 자료조사에서 판단.
- 근거: architect는 이미 화면 분해·색/아이콘 매핑을 architecture-ui로 한다 → 빠진 크기 연결을 *같은 자리*에 두는 게 응집적. B(구현측 coder 자율)는 양판 편차가 커 12차 사고를 엔진만 바꿔 반복할 위험.

## 3. 자료조사 갈래 (compact 후 fan-out)

### G1 — 내부 종단 분석 (버전별 "효과적이었던 방식")
- **질문**: 어느 코퍼스 버전·어느 방식이 UI 충실(특히 크기)했나? 충실을 만든 방식 vs 퇴행시킨 방식의 공통 인자?
- **재료**: `workspace/eval/results/` 8~12차 결과지·compare·`git log`(코퍼스 버전 ↔ 결과)·각 런 산출물 hero/대형 요소 크기 실측(`~/Desktop/dddart-run/dddart-*`).
- **단서**: 11차 claude(시안 직접·96px) / 12차 codex(크기 연결·L208) / 12차 claude(area 트리·32px) / 8차(영역 누락).
- **산출**: "충실 패턴" vs "퇴행 패턴" 대조표 + 재사용 가능한 효과적 방식 추출.

### G2 — 현재 코퍼스 정밀 (어디에 무엇을 추가)
- **질문**: 레이아웃 강제·에셋을 어느 스킬·어느 절에 어떻게 넣나? 크기 추출→소비 경로의 정확한 갭?
- **재료**: `architecture-ui`(레이아웃 절 부재 확인)·`design-architect.md`(색·spacing·아이콘만)·`implementation-flutter`·`extract_design.dart`·`extract_layout.dart`(크기 추출하나 *요소 연결* 없음)·`app_asset.dart`(AppAsset stub)·foundation(`app_typography`·`app_spacing`·`app_radius`).
- **산출**: 추가 지점 후보 + 현 갭 지도(크기가 도메인에 안 묶여 연결 자리 없는 구조 확인).

### G3 — 외부: 레이아웃/크기 충실 (디자인→코드)
- **질문**: 디자인 토큰/크기를 코드 *요소*에 충실히 연결하는 검증된 방식? Figma/Stitch→Flutter 크기·배치 충실 모범? "상대 기하 강제"와 "절대 크기 충실"의 양립?
- **재료**: 어제 자료조사(`2026-06-19-stitch-fidelity-research.md`·`2026-06-20-layout-enforce-research.md`) 재활용+갱신·DeclarUI(2409.11667)·ScreenCoder·Design Tokens W3C·Style Dictionary·Anima 절대좌표 함정·CRANE/format-tax. 외부는 WebSearch/WebFetch·context7.
- **산출**: 크기 연결 모범 + dddart 적용 가능성/한계.

### G4 — 외부: 에셋 번들링 (Flutter)
- **질문**: 원격 시안 이미지 → 로컬 번들 → 토큰화(AppAsset) → `Image.asset`의 검증된 파이프라인? pubspec `assets:` 모범? 다운로드 단계는 누가(Phase 0 Coordinator)?
- **재료**: Flutter asset 공식 문서(context7)·메모리 [[stitch-image-asset-bundling]](URL 다운로드가능·수명보장X)·[[stitch-design-fidelity-gap]] 진입점 16(HaffHaff 치수 강제 모방 경계)·`extract_design`의 image 노드.
- **산출**: 에셋 사용 방법 설계 근거 + HaffHaff 모방 가드(치수 강제 재발 금지).

### G5 — 메타: 코퍼스 반영 방식 (skill-creator 참여)
- **질문**: 레이아웃 강제 규율을 architecture-ui *절 확장* vs *새 스킬*? 스킬 설계 모범? 양판 미러 영향? design-architect 지시 갱신 형태?
- **재료**: `skill-creator` skill(스킬 설계·평가·description 최적화)·`claude-code-guide` 에이전트(**plugin-creator는 available skill 아님 → 대체**·Claude Code 스킬/플러그인/구조 전문)·dddart 양판 미러 규약·`workspace/tools/corpus_mirror_sync.py`.
- **산출**: 반영 형태 권고(절 확장 vs 신설·design-architect+architecture-ui+implementation-flutter 분담) + 양판 미러 계획.

### G6 — 측정·과적합 경계
- **질문**: 크기 충실을 어떻게 측정(FID 게이트는 L1·L2 구조만·크기는 육안 A1)? 크기 검증 게이트가 가능한가? weather 특화 금지·일반화?
- **재료**: `fid-gate.sh`·screenProbes 규약·`RUBRIC.md §H`·[[plugin-general-purpose-no-overfit]]·measure-first·[[live-test-user-driven]].
- **산출**: 측정 방법(자동 가능 범위 vs 육안) + 과적합 가드.

### G+ — 에이전트 재량 추가 조사
- 위 갈래 수행 중 **필요한 추가 자료가 드러나면 자율 조사**(사용자 명시 허가). 완료 보고에 무엇을 왜 추가했는지 기록.

## 4. 산출물·흐름

자료조사 보고서(`workspace/design/2026-06-21-layout-asset-research.md`) → **brainstorming 재개**(방향 A 위에서 구체 설계) → 설계 명세 → 코퍼스 시술(별도 승인·양판 미러·다음 런 동결).

## 5. 실행 방식 (compact 후)

- **ultracode workflow** fan-out(사용자 허가): G1~G6 갈래별 병렬 에이전트 → 메인 루프 합성. 외부(G3·G4)는 WebSearch/WebFetch·context7. G5는 skill-creator skill + claude-code-guide 에이전트.
- 합성 후 **적대 검증**(ai-consumability-review 표준 게이트) → 보고서.
- 보고서는 *근거 수집*까지 — 설계 결정은 brainstorming 재개에서 사용자와.
