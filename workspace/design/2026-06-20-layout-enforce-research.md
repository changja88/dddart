# 레이아웃 강제 메커니즘 — 심층 자료조사 v2 (2026-06-20)

> 목적: §2.6(위젯 매핑표) 제거 후, "레이아웃을 *어떤 식으로 강제*하나"의 구현 메커니즘을 1차출처로 확정. 6/19 조사(생태계·개념틀)의 후속 — **구현 실행 수준**.
> 방법: 4갈래 병렬 서브에이전트 웹 리서치(① 입력유도 주입형식 ② 강화 기법 ③ 출력게이트 자동교정 ④ Flutter 도메인). arxiv ID·URL 라이브 확인·날조 금지·신뢰도(高/中/低) 표기. ~247k 토큰.
> 선행: `2026-06-19-stitch-fidelity-research.md`(4축)·`2026-06-19-fidelity-generation-design.md`(입력유도+출력게이트 쌍). 입력 메모리 [[stitch-design-fidelity-gap]]·[[plugin-general-purpose-no-overfit]].
> 상태: **자료조사 완료 · 재계획 입력 대기**. 이 조사는 6/19 설계 §4(입력유도+출력게이트 쌍)를 *폐기가 아니라 확증·구체화*한다.

---

## §0. 핵심 수렴점 (4갈래가 한 점으로)

1. **dddart의 현 아키텍처 — "입력 유도(자연어 명세) + 출력 게이트(결정론 백스톱)" 쌍 — 이 학술적 정답임이 3중 확증.**
   - **CRANE**(2502.09061): 무제약 생성 ↔ 사후 결정론 검증을 *분리*하면 순수 제약 디코딩 대비 **+7~9%p·구문타당 100%**(GSM-Symbolic Qwen 29→38 등).
   - **"Let Me Speak Freely?"**(2408.02442·EMNLP'24): 출력을 JSON/grammar로 하드 강제 시 추론 **−10~30%**(format tax·GSM8K GPT-3.5 76.6→49.25). → 구조를 *디코딩 제약*으로 박으면 코드 품질이 깎인다.
   - **Kamoi 서베이**(2406.01297·TACL): prompted-LLM 자기피드백만으론 자기교정 성공 사례 없음. **"reliable external feedback"(executor·구조 metric)일 때만 작동.** → dddart layout-ir 게이트가 바로 그 신뢰 신호.
   - ⟹ **새 메커니즘 발명 불필요. 이미 옳은 길.** 무거운 하드 제약·VLM 채점 루프 유혹을 명시 기각.

2. **"웹 외삽 미검증"이라는 최대 불확실성이 DeclarUI로 해소 — 근거를 ScreenCoder(웹)→DeclarUI(Flutter 실측)로 격상.**
   - **DeclarUI**(2409.11667·FSE 2025·ACM TOSEM): "구조 IR 주입(컴포넌트 분할 + Page Transition Graph)→선언형 codegen"을 **Flutter에서 직접** 측정 → CLIP 0.85·SSIM 0.68·컴파일 92%·PTG 커버리지 99.4%, **베이스 모델 Claude-3.5**. dddart와 동일 패턴·동일 엔진 계열.
   - ⟹ 입력 유도는 "웹 외삽 도박"이 아니라 **"Flutter 검증 선례 답습"**.

3. **입력 유도 형식: raw JSON 붙이기 ✗ → Flutter 관용구 골격(pseudocode) ○.**
   - 큰 레버는 "구조 있음 vs 없음"(GameUIAgent schema vs no-schema **+3.1/10·≈+65%**·Δp<0.001), 형식 A vs B는 작은 레버(같은 IR의 JSON/prose/DSL 직접 A/B 벤치는 *부재*).
   - 승리 레시피(9개 시스템 수렴): **닫힌 타입 어휘 + 순서·중첩 명시 + 반복 construct + 상대 기하(픽셀 ✗), 생성 언어 관용구로 직렬화.** ScreenCoder=HTML/CSS 골격, Athena=SwiftUI pseudocode — *코드에 가까운 형태일수록 충실*.
   - 단 출력 형식 제약은 함정(§0-1) — design-architect가 *JSON으로 추론·출력*하게 하지 말 것. **IR은 읽는 컨텍스트, 명세는 자연어.**

4. **자동 render-in-the-loop는 보류가 ROI상 옳다.**
   - 이득 **76~95%가 1~2 재시도에서**(How Many Tries 2604.10508), 대가는 토큰 6~9배·코드품질 소폭 하락·과교정(CITL 2604.05839 +17.8%는 best-of-cycles·토큰 ~9-18배). 수용 규칙 없는 반복은 **2~3라운드 후 열화**(ReLook 2510.11498·Self-Refine 3회 plateau).
   - 얹는다면 단 한 형태: **결정적 layout-ir FAIL 신호 + max-iter 2 + 비개선 중단**. VLM image-only 채점은 **금지**(스크린샷 유사도는 절대좌표 떡칠로 게임됨·UI2Code^N 2511.08195).

5. **Flutter 고유 — 출력 게이트 2축.** Flutter는 제약 기반 레이아웃("constraints down, sizes up")이라 충실 실패가 "픽셀 오차"가 아닌 **제약 위반(RenderFlex overflow·Expanded 오용)으로 빌드/런타임 깨짐**. → 게이트 = (a)시각 충실(SSIM/구조 우선) + (b)**제약 정합(`flutter analyze`+위젯테스트)**. (b)는 웹 벤치에 대응물이 약함(DeclarUI가 CSR=컴파일률을 별도 지표로 둔 이유).

6. **위계(hierarchy) 명시 IR이 Flutter 트리 본성과 정합.** DesignCoder(2506.13663): 위계 명시(UI Grouping Chains) → 코드구조 유사도 **+30%**(RN). Flutter 위젯트리(Column/Row/Stack/Expanded)는 곧 위계 트리 → **"중첩 그룹 IR"이 "평면 좌표 IR"보다 유리.**

---

## §1. 갈래별 발견 (압축 · 출처·수치·신뢰도)

### 갈래① 입력 유도의 주입 형식 (9개 시스템 확인)
- **ScreenCoder**(2507.22827·高): layout dictionary `(bbox,label)` → hierarchical layout tree(DOM-like, `is_grid` flag) → **HTML/CSS 골격으로 주입**(JSON·prose 아님). v2: 골격(layout)과 CSS(style) 분리 생성. ScreenBench Position **0.725→0.755(+3.0pp)**, SFT→RL **+3.7pp**.
- **LayoutCoder**(2506.10376·ISSTA'25·高): 노드 스키마 `{type: row|column|atomic, position, children, portion(flex)}`. **+10.14% BLEU·+3.95% CLIP** vs Self-Refine. → L2 노드 문법 거의 그대로 차용 가능.
- **GameUIAgent**(2603.14724·高): recursive node-tree JSON(geometry·style·children). **format ablation = 구조의 결정적 근거**: no-schema 4.8/10 vs schema 8.0/10.
- **Athena**(2508.20263·Apple IUI'26·高): IR 3종을 *각 단계 관용구*로(storyboard=JSON graph·data=Swift struct·GUI=**SwiftUI pseudocode**). 단일 메가-JSON 아님. 75% 선호·navigation 100%. ⚠️ 버그는 더 많음(IR은 구조/커버리지를 사지 정확성은 공짜 아님).
- **VSA**(2512.20034·高): rooted ordered tree·**닫힌 어휘 {frame,stack,row,tile,text,media,control,link}**·bbox는 *옵션·정규화 [0,1]⁴*. Tree Edit Distance −15%.
- **MLS**(2512.18996·高): "coarse DOM tree → 정규화 → **repeat construct**(중복 미전개)". = dddart L2 반복그룹.
- **DeclarUI**(2409.11667·高·**Flutter 실측**): 분할+PTG를 JSON 주입. 갈래④ 참조.
- **DCGen**(2406.16386·高): IR 없는 분할정복 대조군(+14% 시각). explicit-IR가 더 강함의 baseline.
- **"Let Me Speak Freely?"**(2408.02442·高) + **UI Grammar**(2310.15455): *출력* JSON 강제는 −, *입력* JSON 컨텍스트는 in-distribution이라 +. → IR을 *주는* 건 무해, design-architect가 JSON으로 *답하게* 하면 해롭다.

### 갈래② 입력 유도 강화 기법
- **decoupling/CRANE**(2502.09061·高): §0-1. dddart 아키텍처와 동형. **+7~9%p·구문 100%.**
- **self-planning**(2303.06689·TOSEM·高): plan 고정 후 코드 **Pass@1 +11.9~25.4%**. → coder가 생성 직전 구조 plan echo.
- **few-shot/POSIX**(2410.02185·EMNLP'24·高): 예시 **1개로 민감도 대부분↓**·instruction tuning은 안정적 효과 없음. over-prompting(2509.13196): 5~20 초과 역효과. → 소형 예시 1~2개만.
- **비결정성**(2408.04667·高): 온도0·few-shot도 런간 **±15%p·갭 70%p**. → 유도는 줄일 뿐, 게이트가 없앤다.
- **AST 구조거리**(2508.14288): 코드 AST를 기대구조와 JSD 측정 → 백스톱 *보완* 지표 후보(시각 아님·간접).
- format tax 회피(2408.02442) = §0-1.

### 갈래③ 출력 게이트 자동 교정 (render-in-the-loop)
- **Kamoi 서베이**(2406.01297·TACL·**가장 결정적**): 신뢰 가능 외부피드백(executor·task-metric)일 때만 자기교정 작동. → **layout-ir 게이트 = 정당한 유일 루프 신호. VLM 채점 루프는 학술 근거 약함.**
- **CITL/Vision-Guided**(2604.05839·Amazon·高): +17.8%(best-of-cycles)·토큰 ~9-18배·**코드품질 약간 하락**. LoRA가 이득 25%를 런타임 루프 없이.
- **ReLook**(2510.11498·Tencent·高): 수용규칙(strict acceptance) 없으면 2~3R 후 열화·렌더실패=0점 앵커. 외부 critic 제거 시 6.8배 가속.
- **Self-Refine**(2303.17651·高): ~20% 평균(편차 큼)·3회 plateau·**피드백 구체성 > 반복횟수**(layout-ir는 구체적 신호).
- **UI2Code^N**(2511.08195·中高): 스크린샷 유사도는 **절대좌표 떡칠로 게임됨** → 구조 게이트가 옳다.
- **Anthropic 공식**(code.claude.com/best-practices·高): 스크린샷 대조 루프 권장 + **채점자≠작성자** + Stop-hook 결정 게이트 + 무한루프 override(8연속).
- **How Many Tries**(2604.10508·中高): **2라운드면 76~95% 이득·3R 상한**·error thrashing 실패모드.

### 갈래④ Flutter 도메인
- **DeclarUI**(2409.11667·高·★): §0-2. **Flutter 실측**(CLIP 0.85·SSIM 0.68·CSR 92%·Claude-3.5). 입력 grounding→선언형 codegen이 Flutter에서 작동 확증.
- **DesignCoder**(2506.13663·中·RN): 위계 명시 → 코드구조 유사도 **+30%**(Flutter 미측정).
- 상용(Builder.io Mitosis IR·FlutterFlow·DhiWise "80% 천장"·中): 입력 구조화가 충실도 좌우·산출은 "스캐폴드"·정량 근거 약함.
- **Flutter 전용 벤치마크 부재**(웹은 Design2Code·Widget2Code 多, Flutter 표준 0) → dddart 자체 FID 게이트 구축 **합리적·불가피**.
- **"+3.6%p" 출처 보정 필요**: 실측 ScreenCoder Position +14.2%p·Design2Code +7.7%p로 더 큼. +3.6%p는 SFT→RL 한 셀 추정 — *재계획에서 "IR-first 효과 = +3~14%p, 지표마다 상이"*로 표기.
- 골든: **alchemist**(golden_toolkit 폐기 후계)·Linux 단일환경 고정·diff 육안 후 갱신. 선례 **VGV "Figma-to-Flutter Claude Skill"**(단 IR 미사용·골든=회귀가드) → dddart 차별 = **구조 IR 명시 주입 + 골든 게이트 승격**.

---

## §2. 재계획 입력 — 레이아웃 강제 메커니즘 확정안

§2.6(위젯 매핑표) 없이, 두 레버로:

### A. 입력 유도 (design-architect 명세에 layout-ir 주입)
- **형식**: layout-ir.json을 raw로 붙이지 않는다. 받은 L1·L2를 **area 어휘 트리 골격**(코드 근접 pseudocode·ScreenCoder/Athena 패턴)으로 명세에 박는다 — 예: `screen → [ appbar(slots: icon,text), image(src,alt), section "Featured"(repeat-group: unit[...]), section "Categories"(...), bottomnav(slots: button×N) ]`. ⚠️**위젯 클래스명(AppBar·BottomNavigationBar 등) 금지** — "관용구"=*어휘를 코드 근접 트리로 직렬화*이지 위젯 지정 아님(위젯 선택은 coder 자율·직교 보존). **형식 A/B(골격 vs raw JSON)는 작은 레버·직접 벤치 부재(中·§3)** — 큰 레버는 *구조 주입 유무*(layout-ir 주입 자체가 확보).
- **어휘**: 닫힌 어휘 = **dddart layout-ir-schema 실제 토큰**(area role `appbar/image/section/bottomnav`·block kind `block/repeat-group`·slot `text/icon/image/button/group`·width `fixed/flex/auto`). **입력 유도·출력 게이트·extract_layout 파서가 이 한 어휘 공유 — 가장 중요한 구조 결정**(schema 1:1). ⚠️LayoutCoder류 *방향* 어휘(row/column/atomic)는 dddart 스키마에 없음(block에 방향축 미부여)·보강은 스키마 별건(동결).
- **반복**: enumeration 금지·construct로(`repeat: <Unit> ×N`) → 단일 재사용 위젯+builder 강제(dddart "상속보다 반복" 정합·MLS).
- **기하**: 상대만(순서·중첩·flex/portion). 픽셀좌표 절대 금지(Anima 함정·Flutter엔 HTML-ism).
- **강화(self-planning)**: coder가 코드 생성 직전 구조를 자기 말로 1회 재진술(plan echo) → 구조 충실 *그럴듯*(self-planning 2303.06689은 **코드 Pass@1 +11.9~25.4%**·*시각 충실* 효과크기는 미측정·메커니즘 차용). **선결**: plan echo 입력 = design-architect가 명세 화면 절에 박은 골격(coder는 명세만 받음). 명세/프롬프트 한 줄.
- **few-shot**: 소형 예시 1~2개만(1개로 민감도 대부분↓·5~20 초과 역효과).
- **금지**: design-architect가 JSON으로 추론/출력(format tax −10~30%)·하드 grammar 제약 디코딩.

### B. 출력 게이트 (결정론·이미 active FID 활용)
- **2축**: (a)시각 충실 = layout-ir L1·L2 구조 비교(누락 FAIL·이미 active)·구조 우선(SSIM은 DeclarUI 논문 지표·dddart 미계산·픽셀은 A1) (b)**제약 정합**(RenderFlex overflow·Expanded 오용 차단·Flutter 고유·웹 무대응) — ⚠️**dddart 미구현**: 정적 `flutter analyze`는 overflow를 못 잡고(런타임 레이아웃 에러), 위젯테스트 규율 신설 필요(범위 밖).
- **신뢰 신호**: VLM 채점 아닌 결정적 layout-ir(Kamoi "reliable external feedback"). VLM은 회귀 diff로만(게이트 금지·기존 메모리 일치).
- **screenProbes 봉합**: L1·L2 게이트 작동의 전제(위젯 렌더 덤프 진입점) = 레이아웃 강제 폐곱의 *빠진 고리*.
- **자동 루프**: 보류 유지가 ROI상 옳음(상시 자동화 음의 ROI). 얹어도 max-iter 2 + 결정적 신호 + 비개선 중단.

### C. 근거 서사 교체
- **명제 정당화(高) = DeclarUI(Flutter·Claude 실측)**: "구조 IR 주입→선언형 codegen이 Flutter서 작동"을 직접 입증. ScreenCoder/Design2Code(웹)는 보조. "+3.6%p"는 "+3~14%p·지표마다 상이"로 정정.
- ⚠️**효과크기는 명제와 분리(中-低)**: DeclarUI ablation은 RN subset(13앱)만·dddart식 입력유도의 *Flutter marginal 효과는 세계적 미측정*(§3). 명제 高가 효과크기까지 번지지 않게.
- **효과크기 약속 금지** → dddart FID 게이트가 자체 Flutter 코퍼스에서 **주입 ON/OFF A/B 실측**(OFF arm=layout-ir 없이·동일 시안·각 ≥2런·게이트 활성 후·DeclarUI도 안 한 Flutter ablation = dddart 신규 기여).

---

## §3. 미확인·한계
- **같은 IR의 형식 A/B(JSON vs prose vs DSL) 직접 벤치 부재** — "관용구 골격 > raw JSON"은 잘 동기화됐으나 head-to-head 미측정(中). 형식 *schema*는 확인, *직렬화 문자열*은 대부분 미공개(논문들이 prompt 원문 비공개).
- **Flutter 전용 IR-주입 ablation 부재** — DeclarUI 절제는 RN subset(13앱)만. "구조 IR 주입의 Flutter marginal 시각 효과"는 세계적으로 미측정 → dddart 자체 A/B가 신규 기여.
- **최신 프리프린트 다수**(2510~2604: ReLook·CITL·GameUIAgent·How Many Tries·VSA·MLS) — ID·수치 라이브 확인했으나 동료심사 최종본 미확정(中).
- **고수치 혼동 주의**: UI2Code^N 88.6% 등은 *RL 학습 포함* 모델 성능·"추론측 루프 단독"이 아님.
- **PDF 미파싱**: MLS(2512.18996)·structural entropy(2508.14288) 본문 수치 일부 미확인(arxiv HTML/abstract 의존). 날조 없음.
- **WebFetch가 arxiv PDF 바이너리 미파싱** — HTML판/abstract/검색 스니펫 기반. PDF-only 정밀 수치는 미확인 표기.

---

## §4. 1차출처 (재확인용)
**입력 유도·형식**: ScreenCoder 2507.22827 · LayoutCoder 2506.10376 · GameUIAgent 2603.14724 · Athena 2508.20263 · VSA 2512.20034 · MLS 2512.18996 · DCGen 2406.16386 · UI Grammar 2310.15455
**강화 기법**: CRANE 2502.09061 · self-planning 2303.06689 · POSIX 2410.02185 · over-prompting 2509.13196 · 비결정성 2408.04667 · structural entropy 2508.14288 · format tax 2408.02442
**출력 게이트**: Kamoi(자기교정 한계) 2406.01297 · CITL/Vision-Guided 2604.05839 · ReLook 2510.11498 · Self-Refine 2303.17651 · UI2Code^N 2511.08195 · How Many Tries 2604.10508 · Anthropic best-practices(code.claude.com/en/best-practices)
**Flutter 도메인**: DeclarUI 2409.11667 · DesignCoder 2506.13663 · Widget2Code 2512.19918 · LaySPA 2509.16891 · Flutter constraints(docs.flutter.dev/ui/layout/constraints) · alchemist(github.com/Betterment/alchemist) · VGV Figma-to-Flutter(verygood.ventures/blog/figma-to-flutter-claude-code-skill-golden-tests)
