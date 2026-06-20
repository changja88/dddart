# 시술 계획 v3 — 생성측 시각 충실도(layout 강제 + 이미지 번들) 코퍼스 구현 (2026-06-20)

> **상태**: 초안 v3 = v2(8렌즈 적대 리뷰) + **§2.6 조립설명서 제거** + **레이아웃 강제 메커니즘 자료조사 반영**(`2026-06-20-layout-enforce-research.md`·4갈래 ~247k). **승인 게이트**: 코퍼스 변경이라 *별도 사용자 승인 + 다음 런 동결 + 양판 미러* 필수.
> **입력**: 7갈래 이해 맵(`wf_6a153414-bb4`) + 8렌즈 적대 리뷰 + **레이아웃 강제 자료조사 v2**(`2026-06-20-layout-enforce-research.md`). 설계 = `2026-06-19-fidelity-generation-design.md`·스키마 동결본 = `workspace/eval/tools/layout-ir-schema.md`.
> **관통 원칙**: ① "무엇을(layout-ir)/어떻게(dddart 규약)" 직교 ② "입력 유도 + 출력 게이트 쌍" ③ **산문 무효·기계 floor**(11차 screenProbes 회귀 실증) ④ **입력 IR은 *읽는 컨텍스트*·design-architect가 JSON으로 추론/출력 금지**(format tax −10~30%·CRANE decoupling 정합) ⑤ **근거 = DeclarUI Flutter 실측**(웹 외삽 아님).

---

## 적대 리뷰 반영 — v1→v2 주요 변경 (changelog)

8렌즈가 합의한 **구조적 재구성 5건 + 죽은 이음매 3건 + 사실정정 다수**:

1. **【중심 전제 교정】 "FID 게이트 deferred"는 틀림 — 게이트는 이미 active.** FID-L1·L2 치명 게이트는 2026-06-19 활성(RUBRIC §H·치명 18→20). 막힌 건 **screenProbes 코퍼스 노출 1건**(implementation-test §7 *산문*뿐·백스톱 0)뿐이다. → 측정을 A1로 후퇴시킬 필요가 없다. (렌즈 4·8 critical)
2. **【D4 내부 모순 해소】** v1은 F1("extract_design 확장 불필요")과 §2.1(b)("extract_design에 images[] 추가")가 모순. → **extract_design 건드리지 않음.** 이미지 src는 extract_layout이 산출하는 **layout-ir.json image 노드**(`extract_layout.dart:209-210`)를 SSOT로 사용(이중출처·미러패치·fixture 회귀 동시 소거). (렌즈 6)
3. **【죽은 이음매 봉합】** agent 입력 절에 layout-ir 선언만으론 무기억 서브에이전트에 안 닿는다 — **Coordinator spawn-input 배선**(architect `dddart.md:135`·**review-ui `:136`**·codex `SKILL.md:150/151`)을 시술 목록에 포함. coder는 layout-ir를 못 받으므로 **명세만 읽는다**(§7 판별 근거를 "명세 화면 절의 image 항목"으로). (렌즈 2·7 critical)
4. **【Track 분리】** 이미지(로드맵 3단계)와 layout(2단계)을 한 런에 합치면 A1/게이트 신호 귀속 불가. → **Track B(layout) 먼저, Track A(image) 다음** 분리 iteration 권장. (렌즈 5·6)
5. **【floor 재프레이밍】** 정적 NM floor ≠ 런타임 FID 게이트(다른 레이어). 사용자의 "자동게이트 후순위"는 *런타임 채점*이지 정적 floor가 아니다. floor는 NM13 복붙이라 cheap. (렌즈 4)
6. **사실정정**: AssetImage 0→**6건**·검사수 58→**57**(코퍼스 선언)·`:105`/`step 4.8`/houserules `:196/:258` 오인용 정정·gitStatus "M상태" stale 제거·3-file 미러(source 포함)·codex 절번호 offset.

---

## 확정 결정 (2026-06-20 · 사용자) — 가벼운 경로

- **D-SP = 눈으로 확인**(screenProbes 자동게이트 **미포함**). 측정 = 사용자 A1 육안(이미지 떴나·레이아웃 맞나). §2.5 screenProbes 봉합·§4 active 게이트 활용은 **보류**.
- **D-License = 고려 일절 없음**(D-License 결정·§7 라이선스 잔여·"Track A 보류" 분기 **전부 삭제**). 이미지 즉시 다운로드·번들. **라이선스 고려 코퍼스 추가 절대 금지(속도 우선·사용자 명시).**
- **D-Floor = 대기**(induce 우선 → 육안 확인 → 미달이면 그때 floor). 속도·육안과 정합. ⚠️ 적대 리뷰 경고: 산문 induce는 screenProbes가 런별 실패 N=2 입증 → 첫 런 미달 가능·육안 포착 후 floor 추가.
- **D-Split = Track B(layout) 먼저·A(image) 다음** 권장(육안이라 동시도 무방 — 사용자 눈이 둘을 분별).
- **D1=assets/(Flutter 표준·HaffHaff 모방 회피) · D4=layout-ir 노드 SSOT(extract_design 무수정) · D7=도구가 구조위치 키 산출 · D-Own=architecture-ui · 나머지 = 추천대로.**

> 위 확정으로 이번 iteration은 **순수 induce + 육안**(자동게이트·floor·라이선스 로직 0). 죽은 이음매 봉합(§2.1d Coordinator 배선·§2.3 coder 명세참조·AppAsset const 등재)과 양판 미러는 그대로 필수(이건 "느림"이 아니라 작동 전제).

---

## §0. 무엇을·왜·범위

**두 트랙**(분리 시술 권장):
- **Track B — layout-ir L1·L2 강제**(로드맵 2단계): L1(골격 appbar/image/section/bottomnav 존재·종류·순서)·L2(섹션 내부 구성)를 design-architect 명세에 강제.
- **Track A — 이미지 번들**(로드맵 3단계): 시안 정적 이미지를 빌드타임 다운로드 → `Image.asset` + pubspec 번들.

**범위 IN**: Phase 0 배선(extract_layout 호출·layout-ir image 노드 소비) · design-architect/review-ui(layout-ir 소비·**Coordinator 배선 포함**) · coder/implementation-flutter(Image.asset·pubspec·복사·**AppAsset const 등재**) · architecture-ui(AppAsset 규약·**2종으로 절단**) · **screenProbes 노출 봉합**(결정 D-SP) · 양판 미러.

**범위 결정 보류(사용자 확인)**: D-SP(screenProbes 포함 여부) · D-Split(Track 분리/동시) · D-Floor(AppAsset floor 즉시/대기) — §3.

**범위 OUT**: 이미지 재배포 라이선스(법무·D-License 분기) · codex `check_riverpod.dart` 부재(57/58 드리프트·별건) · stock/placeholder 판별.

---

## §1. 핵심 발견 (맵 + 적대 검증 정정)

| # | 발견 | 근거(검증) | 함의 |
|---|---|---|---|
| F1 | **`extract_layout.dart` 고아 도구** — 존재·양판 byte-identical·`<img>`→image 노드(`:209-210`)인데 미배선(eval `fid-gate.sh:14`만). | 맵2·렌즈 전원 확인 | 배선만·**통합 금지**(SSOT/미러/eval 깨짐). 이미지 src도 여기서 옴(F-img). |
| F2 | **7번째 토큰 `app_asset`(class `AppAsset`) 슬롯 예약** — 백스톱 ST10 foundation7(`check_structure.dart:172-174`)·ST4 필수(`:323`). **단 의미·규율은 미문서**(houserules는 `:85` 트리 파일명만·의미는 설계원장 `2026-06-11-dddart-file-tree.md:85,372`·architecture-ui 0건). | 렌즈1·4·6·7 정정 | architecture-ui 문서화 = **첫 의미 정의**(가정보다 무거움). 의미 소유 결정 = D-Own. |
| F3 | **신규 백스톱 불필요(정합성용)** — 이미지 4산출물이 57검사 비매치. **단 에셋은 lib 밖 project-root**(lib 안이면 ST 디렉터리 화이트리스트 거짓 FAIL). | 맵6·렌즈3·6 확인 | 동전 뒷면 = asset-presence 검사도 부재 = missing-asset 안전망 공백(F-net). |
| F4 | **AppAsset floor 부재** — NM10(`check_naming.dart:231`)은 `Color(0x`·생 `TextStyle(`만, `common.dart:175`가 문자열 *내용* 마스킹 → Image.asset 경로 리터럴 불검출. | 렌즈 전원 확인 | 산문만으론 raw 리터럴 도망(HaffHaff 216 Image.asset+6 AssetImage 전부 raw·named const 0). D-Floor. |
| **F5(정정)** | HaffHaff 실측: `asset/`(단수)·`asset/img/{icon,logo,lottie}`·pubspec **디렉터리 등록**(`- asset/img/`)·`Image.asset('asset/img/...', width:, height:)` 216건·**AssetImage 6건**(둘 다 raw·named const 부재). 서버 이미지는 `Image.network` 아니라 **cached_img 컴포넌트군**. | 렌즈1·4·6 정정 | **HaffHaff 실측 *인용*일 뿐 dddart 기준 아님**(dddart 디렉터리=Flutter 표준 `assets/`·D1·모방 회피). named const(AppAsset)는 dddart foundation 토큰 규약(HaffHaff엔 없음=반면교사). §7 정적 번들 한정(서버=cached_img·범위 밖). |
| **F-FID(신규)** | **FID-L1·L2 게이트는 이미 active**(RUBRIC §H·치명 20·2026-06-19). dump_probe가 *렌더된* Image만 `img:true`→`role:image`, compare_layout L1이 누락 FAIL. **막힌 건 screenProbes 노출뿐**. | 렌즈8 critical | "deferred"는 신규 게이트 신설에 적용·이미 active한 게이트 작동까지 미루면 측정 자해. |
| **F-net(신규)** | **missing-asset 안전망 증발** — 백스톱 asset 미검사 + `flutter build`는 환경 조건부(`dddart.md:158`·sub user-driven). **미채택(0건)은 grep이 잡음**(11차 D-2 실증)·build는 "선언+파일누락"만. | 렌즈6·8 정정 | 채택 판정 = grep + L1 image role(결정론)·A1은 L4 미관만. |
| **F-arch(자료조사)** | dddart "입력 유도(자연어 명세) + 출력 게이트(결정론 백스톱)" 아키텍처가 **학술 정답 3중 확증**: CRANE(2502.09061·decoupling **+7~9%p**·구문100%)·"Let Me Speak Freely"(2408.02442·출력 JSON강제 **−10~30%** format tax)·Kamoi(2406.01297·자기교정은 *reliable external feedback*일 때만). | 자료조사 4갈래 | **새 메커니즘 발명 불필요**·하드 제약/VLM 채점 루프 명시 기각. layout-ir 게이트 = Kamoi "신뢰 외부 신호". |
| **F-flutter(자료조사)** | **DeclarUI**(2409.11667·FSE'25): 구조 IR 주입→선언형 codegen을 **Flutter에서 직접·Claude-3.5로** 측정(CLIP0.85·SSIM0.68·컴파일92%). | 자료조사 갈래4 | **명제 高**(구조 IR→Flutter codegen 작동·웹 외삽 해소). 단 **dddart 입력유도 marginal 효과크기는 中-低**(DeclarUI ablation RN 13앱뿐·Flutter ablation 세계적 부재) → 효과크기 자체 A/B(약속 금지). |

---

## §2. 시술 지점 (claude 앵커 → codex 미러)

> **미러 3부류**(`corpus_mirror_sync.py`): **[자동]** `references/final.md`만 — claude **배포본**(`dddart/skills/.../references/final.md`) 편집 → `python3 workspace/tools/corpus_mirror_sync.py --write`가 **source(`workspace/reference/...`)+codex 둘 다** 동기(불변식1·2). source/codex 직접 편집 금지(다음 --write가 소실). **[수동]** SKILL.md·agents·commands는 양쪽 동시 편집(절 *제목/키워드*로 앵커·codex는 frontmatter↔'로드할 지식 스킬'로 ~1행 offset). **[스크립트]** byte-identical 관례·`corpus_mirror_sync` 미검사 → 수동 `diff -q`.

### 2.1 Phase 0 — `commands/dddart.md` ↔ codex `dddart/SKILL.md` (수동)

- **(a) layout-ir 배선** [Track B]: extract_design HTML 모드(`dddart.md:122`) 직후 extract_layout 1줄 — `dart run ${CLAUDE_PLUGIN_ROOT}/scripts/extract_layout.dart <산출물>/design-ref --out <산출물>/layout-ir.json`(has_stitch_html일 때). codex `SKILL.md:136`은 `<스킬 디렉터리>` 경로. **extract_layout 무수정**. build-state(`:42-57`)에 `has_layout_ir` 플래그(`:55` 뒤).
- **(b) 이미지 src** [Track A]: **extract_design 안 건드림**(v1 §2.1b 철회). 다운로드 입력 = **layout-ir.json의 image 노드 src**(SSOT). build-state에 `has_design_images` 플래그.
- **(c) 다운로드** [Track A]: layout-ir image 노드 src를 curl → `<산출물>/design-ref/images/`. **결정론 래퍼 권장**(작은 dart/sh: curl+매니페스트(성공/실패/부분)+`has_design_images` 산출·offline fail-soft exit 0) → Coordinator는 매니페스트를 *읽어* G0 배너만. (LLM 재량 최소화·산문 무효 회피). 단순화 대안: "전부 성공 아니면 `has_design_images=false`".
- **(d) Coordinator 전달 배선** [죽은 이음매 봉합·렌즈7]: architect 입력(`dddart.md:135`)·**review-ui 입력(`:136`)**에 `layout-ir.json 경로(has_layout_ir이면)` 추가. codex `SKILL.md:150/151`. **이 줄이 없으면 §2.2 agent 지침은 죽은 지침**(architect의 :135는 이미 목록에 있었으나 reviewer :136은 v1 누락).
- **앵커 정정**: 실패 폴백 = `dddart.md:127`(step 4 substep 8) / 로컬 이미지 cp 관용 = `:125`(substep 6).

### 2.2 design-architect (+ design-review-ui) ↔ codex `dddart-design-architect`/`dddart-design-review-ui` (수동·절 제목 앵커)

- **design-architect 입력 절**(design-ref 불릿 부근): layout-ir.json 1급 입력(has_layout_ir).
- **화면(ui) 절**(design-tokens 박는 문장 옆): L1 골격(존재·종류·순서)·L2 섹션 구성을 명세에 *강제* 박음 + **image 노드(src/alt)를 명세에 박아** coder가 Image.asset. "어떻게"(view/section/widget·MVVM·NM17)는 직교(layout-ir이 위젯 분해 강제 안 함). architect는 **"무엇을"만**(L1 골격 존재·종류·순서·image src·section 분해·ui_extension 산출물) 명세에 박고, **위젯 선택("어떻게")은 명세에 박지 않는다**(직교 보존 — 위젯 선택은 coder가 implementation-flutter 현행 규범으로 자율; 엔진이 dddart 규약대로 이미 산출).
- **입력 유도 *형식*(자료조사 §2-A·신규)**: L1·L2를 **raw JSON으로 명세에 붙이지 않는다** — **area 어휘 트리 골격**(코드 근접 pseudocode·ScreenCoder/Athena 패턴)으로 박는다. 예: `screen → [ appbar(slots: icon,text), image(src,alt), section "Featured"(repeat-group: unit[...]), section "Categories"(...), bottomnav(slots: button×N) ]`. ⚠️**위젯 클래스명(AppBar·BottomNavigationBar 등) 금지** — "관용구"=*어휘를 코드 근접 트리로 직렬화*이지 위젯 지정 아님(위젯 선택은 coder 자율·위 직교 원칙 보존). ⓐ**닫힌 어휘 = layout-ir-schema 실제 토큰**(area `appbar/image/section/bottomnav`·block `block/repeat-group`·slot `text/icon/image/button/group`·width `fixed/flex/auto`) — **입력 유도·출력 게이트·extract_layout 파서가 이 한 어휘 공유**(가장 중요한 구조 결정·schema 1:1). ⚠️LayoutCoder류 방향 어휘(row/column/atomic)는 스키마에 없음·보강 별건(동결) ⓑ**반복은 construct**(`repeat-group: unit`·enumeration 금지 → 단일 위젯+builder·MLS·"상속보다 반복") ⓒ**기하는 상대만**(순서·중첩·flex)·픽셀 금지(Anima 함정) ⓓ**소형 예시 1~2개**만(POSIX: 1개로 민감도↓·5~20 초과 역효과) ⓔ⚠️**design-architect가 JSON 추론/출력 금지**(format tax·관통원칙④) ⓕ**형식 A/B(골격 vs JSON)는 작은 레버·직접 벤치 부재(中·§7)** — 큰 레버는 *구조 주입 유무*(layout-ir 주입 자체가 확보).
- **백스톱 정합/자기점검 스캔**(claude `:62`자기모순/`:64`백스톱정합 ↔ codex `:61/:63` — *제목으로 앵커*): "layout-ir L1·L2 명세 반영·image 노드 박힘" 대조 1항.
- **design-review-ui**: 입력 절에 layout-ir.json(§2.1d Coordinator 전달과 *쌍*) + 점검 항목에 **L1 누락만 발견**(L2는 미도입 — false regression·deferral 정합). ⚠️ review-ui는 Read/Grep 리뷰어라 산문 대조 = 약함(진짜 닫힘은 active FID 게이트).

### 2.3 coder + implementation-flutter ↔ codex (수동/자동)

- **implementation-flutter/references/final.md** [자동 미러·배포본 편집]: 신규 §7 "이미지 — Image.asset 번들"(현 §7 테스트→§8·**TOC `:10-15`에 §7+§8 둘 다 정비**·codex SKILL.md `:30/42` §7→§8 참조도 동반):
  - 판별 = **출처**: design-ref/images 번들 → `Image.asset(AppAsset.x)` (정적·Track A 범위). **치수(width/height)는 시안 명시값 있을 때만 부여**(없으면 레이아웃 제약 Expanded/AspectRatio에 맡김 — 자료조사 §2-A "상대 기하·픽셀 절대 금지[Anima 함정]" 정합·**HaffHaff "Image.asset에 항상 width/height" 습관 비채택**). 서버 콘텐츠는 **HaffHaff cached_img 컴포넌트군 처리·범위 밖**(Image.network 직참조는 방언 아님).
  - **errorBuilder는 비-Image 폴백(Icon/Container)** 권장(다른 Image 반환 시 FID 게이트 `img:true` 우회=거짓양성·렌즈8).
  - mockNetworkImages 함정은 **implementation-test 소유**(cross-ref·이 파일 §6은 위젯수명).
- **coder.md** [수동]:
  - 스킬 라우팅 불릿(`:43`): Image/asset → implementation-flutter.
  - **pubspec `assets:` 선언 + project-root `assets/` 복사 = presentation 슬라이스 정상 산물**(계층-밖 반송 예외·`:41` 긴장 해소·둘 다 묶어 면책·"빌드 자원이라 계층 트리 밖"). 의존성 핀(`:60`)과 구분.
  - **AppAsset const 등재 단계**(렌즈5 누수 봉합): 명세 image 항목의 경로를 `foundation/app_asset.dart` AppAsset static const로 등재 → 위젯은 `Image.asset(AppAsset.x)`. raw 경로 리터럴 금지(D-Floor 시 기계 강제).
  - **복사 순서**: 명세 image 항목 → `cp design-ref/images/<f>` → 프로젝트 `assets/...` → AppAsset const → Image.asset → pubspec assets:(**파일 개별 등록**·디렉터리 통째 등록 금지=앱 크기·D6·D7 평면 파일명 정합·**HaffHaff 디렉터리 등록 비답습**). Image.asset 직후 `test -f assets/...`로 cp 성공 검증(missing-asset 안전망·F-net).
  - **§7 판별 근거 = "명세 화면 절의 image 항목"**(layout-ir 직참 아님 — coder는 명세만 받음·렌즈7 critical).
  - **구조 plan echo(자료조사 §2-A·self-planning)**: coder가 presentation 슬라이스 생성 *직전* 명세 L1·L2 골격(§2.2가 명세 화면 절에 박은 area 트리·coder는 명세만 받음)을 한 번 자기 말로 재진술하고 그에 맞춰 view/section 분해. 앵커 = coder.md **"작업 방식" 절 bottom-up 순서 불릿 앞**(키워드 앵커·줄번호 X·미러 규약 §2). self-planning 2303.06689는 **코드 Pass@1 +11.9~25.4%**(*시각 충실* 효과크기 미측정·메커니즘 차용·효과 약속 아님).

### 2.4 architecture-ui — references/final.md(자동) + SKILL.md(수동) — **2종으로 절단**(렌즈5)

- **①§7 토큰 절**(`:102` "표준 7토큰" 뒤 새 불릿): **7번째 = `app_asset`(class `AppAsset`)** — 정적 이미지/아이콘 경로는 AppAsset const에서(Color→AppColor 평행)·**raw 경로 Image.asset 직접 금지**. (7토큰 *닫힌 열거*는 houserules 소관·불변 / 여기는 *사용 절차*만 — 의미 정의 소유는 D-Own).
- **②§5 아이콘 경계**(`:78` 끝): 아이콘=`Icons.x`(IconData·ui_extension) vs 정적 래스터(PNG·로고)=AppAsset const — 두 트랙 분리.
- **절단(deferred)**: 호출 계층 규칙은 §3 dumb 규율(`:47-52` ref 금지)이 이미 강제 → 중복·생략. 배치 규칙(D8·BC어휘 일러스트)은 기존 `component/image/` 부품군(houserules `:90`·NM12 명명) 재사용으로 갈음 → 첫 iteration 불요.

### 2.5 screenProbes 노출 봉합 [결정 D-SP·렌즈8] — implementation-test ↔ codex (수동) + 선택 백스톱

현재 screenProbes 규약은 implementation-test/SKILL.md `:29` *산문*뿐(coder.md·discipline-test·check_*.dart 0건 = 11차 양 엔진 회귀 직접 원인). **포함 시**: coder.md에 "신규 화면은 screenProbes 노출"을 의무로 + (선택) 백스톱 기계 강제. 이 1건이 **Track A·B 둘 다를 open-loop→closed-loop**로 바꾼다(active FID 게이트 작동). **사용자의 "자동게이트 후순위"와의 관계 = D-SP.**

---

## §3. 결정점

### 신규 결정(적대 리뷰 발):
| ID | 결정 | 권장 | 근거 |
|---|---|---|---|
| **D-SP** | screenProbes 노출 봉합을 이번에 포함? | **포함**(최소형: coder 의무 1줄) | 게이트는 이미 active·이 한 줄이 측정을 닫음·어차피 코퍼스 건드림. 단 사용자가 deferred한 "자동게이트"의 일부라 **사용자 확인 필요**(런타임 채점 신설 ≠ 이미 active한 게이트 작동). |
| **D-Split** | Track A·B 분리 vs 동시? | **Track B 먼저·A 다음**(분리) | measure-first 단일변수(로드맵도 2/3단계 분리). 동시면 §4에 "효과 분리 불가" 명시 + 트랙별 grep/게이트 신호 분해. |
| **D-Floor** | AppAsset 경로 floor 즉시 vs 대기? | **최소 floor 동시 권장**(induce만은 screenProbes가 이미 산문 induce 런별 실패 N=2 실증) | floor=정적 NM(런타임 게이트와 별 레이어·사용자 후순위 무관)·NM13 복붙. **added 줄만 발화**(`lineIsAdded`·브라운필드 면책)·**Image.asset + AssetImage(named arg 중첩) 둘 다**·app_asset.dart 자체는 합법. **선결**: positive-control `fid/` fixture에 이미지 변종(현 notice=Image.asset 0). |
| **D-Own** | AppAsset *의미* 소유 = houserules vs architecture-ui? | **architecture-ui(사용 절차)·houserules는 트리만 유지** | houserules에 의미 미정의(F2 정정)·소유 떠넘김 방지. |
| **D-License** | 라이선스 미확정 시? | ~~Track A 보류~~ → **고려 일절 없음**(상단 확정 결정·사용자 명시) | (구판 분기·상단 확정 결정이 지배) |
| **D-Image** | `image` 산출 자리(AppAsset 빈 클래스) | Track A가 AppAsset const 등재+Image.asset 배선해야 작동(현 산출물 래스터 0) | D-2 실증(grep) |

> **자동 render-in-the-loop ≠ D-SP(게이트 작동)**(자료조사 §2-B): screenProbes 봉합은 L1·L2 게이트(=Kamoi "신뢰 외부 신호")를 *작동시키는 렌더 덤프 진입점*이다(그 자체가 신호는 아님). 게이트 FAIL시 *자동 재생성* 반복(ReLook 2510.11498·CITL 2604.05839류·**프리프린트 中신뢰**)은 **별개·보류가 ROI 옳음** — 이득 76~95%가 1~2회(How Many Tries)·토큰 6~9배(반복) 또는 CITL 9-18배(**best-of-cycles** 기준)·코드품질 하락·과교정·LoRA가 루프 없이 이득 25%. 얹어도 max-iter 2 + 결정 신호 + 비개선 중단(VLM image-only 채점 금지·절대좌표 게임).

### 기존 결정(정정):
| ID | 결정 | 권장 |
|---|---|---|
| **D1** 에셋 루트 | `assets/`(Flutter 표준) vs `asset/`(HaffHaff 단수=**모방**·기각) | **`assets/`** — dddart 규약은 AppAsset *클래스*(foundation 토큰)만 정하고 디렉터리명 미정·산출물 표본 0 → Flutter 표준 따름([[haffhaff-reference-app]] 모방 회피) |
| **D4** 이미지 src 출처 | ~~extract_design images[]~~ → **layout-ir image 노드 SSOT**(extract_design 무수정·D4 모순 해소) | 확정 |
| **D5** 다운로드 실패 | **결정론 래퍼+매니페스트**(LLM 재량 최소) 또는 "전부 성공 아니면 false" | — |
| **D6** stock/placeholder | 첫 iteration 무차별+L4 눈(단 디렉터리 등록이라 폴더 통째 번들=앱 크기 비용 명시) | — |
| **D7** src→파일명 | **도구가 구조위치 키 산출**(screen+area-index·예 `weekly-list_img0.png`·alt 의존 금지[빈/중복])·**실표본 1벌 동결 후 확정**(현재 design-ref HTML 0건·미검증) | Track A 포함 시 **착수 전 필수** |
| **D8** 배치 | 기존 `component/image/` 군 재사용·NM12 명명·BC어휘 일러스트는 deferred | — |

---

## §4. 측정 (게이트는 active[능력] ≠ 이번 사용[배치] — 이번 iteration은 A1 육안 1차·D-SP 승격 시 게이트)

- **채택(미채택 0건) = grep**(`Image.asset lib`·`pubspec assets:`)이 결정론으로 잡음(11차 D-2 실증) — A1 아님.
- **렌더(거짓양성 "코드 있는데 안 뜸") = active FID 게이트**(D-SP 포함 시): dump_probe가 *렌더된* Image만 `img:true`→compare_layout L1이 누락 FAIL. grep('박았나')과 L1 image role('떴나')의 차이가 거짓양성을 가른다.
- **layout 충실(Track B)**: 이번 iteration(D-SP 보류·확정)은 **A1 육안이 1차**(이미지 떴나·레이아웃 맞나). active FID L1·L2 게이트 폐곱은 **D-SP를 사용자가 승격하면** 작동(현재는 review-ui 산문 L1 대조만·약함). ⚠️게이트를 주축으로 적지 말 것 — 확정 경로는 육안.
- **A1 = L4 미관만**(아이콘 심볼·픽셀).
- **제약 정합(Flutter 고유·자료조사 §2-B)**: Flutter는 제약 기반 레이아웃이라 충실 실패가 픽셀 오차 아닌 **RenderFlex overflow·Expanded 오용 = 런타임 깨짐**으로 난다. ⚠️**현 dddart 미구현** — 정적 `flutter analyze`(BG-2 green 래칫)는 overflow를 *못 잡고*(런타임 레이아웃 에러), dump_probe는 analyze 배제. overflow 차단엔 **위젯테스트 규율 신설 필요 → 이번 범위 밖**(D-SP 보류 정합·§7). 시각 충실 축의 SSIM도 **dddart 미계산**(DeclarUI 논문 지표·픽셀은 RUBRIC §H상 A1 위임). 신뢰 신호 = 결정적 layout-ir(Kamoi)·VLM은 회귀 diff만.
- **귀속 주의**: 같은 런에 다른 변수(골든·백스톱) 교란 + N=1 → induce 미달이 노이즈인지 산문무효인지 단일 런 A1로 못 가름. **L1 게이트(결정론·골든과 직교)로 귀속**하거나, D-Floor 투입 판단을 **≥2런 + 게이트 실측** 선결로(positive-control "확정 ≥2런" 규율).
- **build 안전망(`dddart.md:158`)**: "선언+파일누락"만·환경 조건부(미실행 가능)·미채택 못 잡음 — 보조.

---

## §5. 양판 미러 절차 (정정)

- **[자동]** 배포본 final.md만 편집 → `--write`(source+codex 동기). codex/source 직접 편집 금지(소실). 시술 전 `corpus_mirror_sync.py`로 기존 drift(arch-ui source inv1 등) baseline 캡처(노이즈 구분).
- **[수동]** SKILL/agents/commands 양쪽 동시 편집 — **절 제목/키워드 앵커**(줄번호 X·codex offset). 검증 = `corpus_mirror_sync` 사각이라 *추가한 행 텍스트가 양쪽 존재* grep 교차확인.
- **[스크립트]** extract_design 무수정(D4)·extract_layout 무수정 → .dart 패치 0(이중출처 소거의 부수 이득). 만약 .dart 손대면 `diff -q claude codex` 0 + claude `run_fixtures.sh`를 codex 사본에도(codex엔 fixtures 부재) 1회.
- **드리프트 주의**: codex `check_riverpod.dart` 부재(57/58)·SKILL.md byte-identity는 기계 미검출.

---

## §6. 시술 순서 (measure-first·MVP·Track 분리 가정)

**선결**: D-SP·D-Split·D-Floor·D-License 사용자 확정 + (Track A면) D7 실표본 동결.

**Track B 먼저** → 1. architecture-ui §7/§5 AppAsset 2종(자동) → 2. Phase 0 layout-ir 배선+Coordinator 전달(수동) → 3. design-architect/review-ui L1 강제(수동·관용구 area 골격 형식·§2.2) → 4. (D-SP) screenProbes 봉합 → 5. 미러 검증(`--write`+수동 grep+.dart diff 0) → **라이브런 → A1 육안으로 layout 효과 확인**(확정 경로·D-SP 승격 시 active FID L1 폐곱). **효과크기 확정은 후속** = layout-ir 주입 **ON vs OFF** 양 arm 동일 시안 비교(각 ≥2런·게이트 활성 후·자체 Flutter ablation).

**Track A 다음**(B 측정 후) → Phase 0 이미지 다운로드(래퍼)·implementation-flutter §7·coder Image.asset+AppAsset+복사·(D-Floor) → 라이브런 → grep+L1 image role 측정.

---

## §7. 리스크·잔여

- **산문 무효(관통)** — screenProbes 자체가 산문(미floor)이라 회귀 원인. D-SP/D-Floor가 floor화. review-ui L1 대조도 산문(약함) → active 게이트가 진짜 닫힘.
- **양판 비대칭 재생산** — 수동분 기계 가드 0. 한쪽만 시술=이 작업이 줄이려는 분기를 코퍼스가 재생산. grep 교차+diff 0.
- **이미지 잔여**: 라이선스(D-License hard) · 손상/0바이트/콘텐츠타입 위장(curl -f는 HTTP만·무결성 미검증·런타임 깨짐) · git 운명(assets/ 신규파일 coder가 git add 안 하면 미커밋 합치기 누락) · pubspec 멱등(디렉터리 중복 등록 방지).
- **이미지 방언 HaffHaff 의존(measure-first·[[haffhaff-reference-app]])** — dddart 산출물 앱 이미지 표본 0이라 이미지 규약(복사·에셋 구조)을 HaffHaff 관찰로 *임시 참조*. **강제 방언으로 굳히지 않음** — Track A 첫 라이브런 산출물로 확정(진실원천=dddart·HaffHaff 모방 금지). **모방 회피 확정**: 디렉터리=Flutter 표준 `assets/`(D1) · 치수=시안 명시값만(HaffHaff "항상 width/height" 비채택·§2.3) · pubspec=파일 개별 등록(HaffHaff 디렉터리 등록 비답습) · AppAsset=dddart foundation 토큰. ⚠️ **시술 PR에서 이 자기억제가 코드로 지켜지는지가 다음 게이트**(코퍼스는 현재 이미지 영역 미시술이라 깨끗).
- **AppAsset 골격 vs 내용** — ST4가 app_asset.dart 존재는 강제하나 빈 클래스도 통과(Image.asset 참조 시 컴파일 실패) → coder가 const 등재 필수(§2.3).
- **효과크기(자료조사 갱신)** — ScreenCoder +3.6%p 웹 외삽 우려는 **DeclarUI(2409.11667)로 Flutter+Claude 실측**(CLIP0.85·웹 외삽 해소). "+3.6%p"는 실측 **+3~14%p**로 정정(지표마다 상이·`2026-06-20-layout-enforce-research.md` 갈래4). **효과크기 약속 금지 → dddart FID 게이트가 자체 Flutter 코퍼스에서 주입 ON/OFF A/B 실측**(DeclarUI도 안 한 Flutter ablation = dddart 신규 기여). ⚠️ 같은 IR의 *형식* A/B(JSON vs 관용구골격) 직접 벤치는 부재(中신뢰·9시스템 수렴 추론).
- **compare_layout L2 hard-gate(D-SP 승격 시만)** — `--gate` 시 L2 불일치=치명(exit 2)·review-ui "L2 약신호"와 비대칭. **D-SP 보류 동안엔 게이트 미발화**(review-ui 산문 L1 대조만)·승격 시 첫 iteration L1만.
- **Flutter 제약 위반 미포착(자료조사 §2-B)** — RenderFlex overflow·Expanded 오용은 시각 충실 게이트(L1·L2 구조)·정적 `flutter analyze` 둘 다 못 잡음(런타임 레이아웃 에러). 위젯테스트 규율 신설은 이번 범위 밖 → 첫 iteration은 A1 육안이 이 축 겸함(제약정합 축은 향후).

---

## §8. 승인 게이트

코퍼스 불변 — **승인 전 입력**. 착수 전: ① 사용자 승인 ② D-SP·D-Split·D-Floor·D-License·D1·D7 확정 ③ 다음 런 동결 ④ 양판 미러 동시. **이 v2 → 사용자 검토 → 승인 시 §6 순서.**
