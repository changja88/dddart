# Stitch 디자인 충실도 — 심층 자료조사 (2026-06-19)

> 목적: "Stitch 디자인을 **그대로** Flutter로 옮기려면, 현재 dddart가 **토큰만 결정론 강제**하고 레이아웃·이미지는 **LLM 참고로 흘리는 분담**을 어떻게 바꿀 것인가."
> 방법: 4축 병렬 서브에이전트 웹 리서치(design-to-code 생태계 / 시각충실도 자동검증 / 디자인토큰 표준 / Stitch 설계의도). 1차 출처·2025~2026 우선, 출처 URL·신뢰도(高/中/低) 표기.
> 입력 메모리: [[stitch-design-fidelity-gap]] · [[stitch-image-asset-bundling]]. 관련 기존 설계: `workspace/design/2026-06-16-stitch-designmd-source.md`(이미 "토큰=결정적 / 컴포넌트의도=산문 참고" 분리를 실측).
> 상태: **자료조사 완료 · 전제검증 완료(§3.5) · 브레인스토밍 대기**. measure-first상 코퍼스 변경은 다음 런 동결 대상(소급 금지).

---

## 1. 핵심 수렴점 (네 축이 한 점으로)

1. **"레이아웃을 토큰화하지 않는다"는 dddart의 현재 선택은 한계가 아니라 업계 전 표준과 일치한다.** W3C DTCG 표준(v2025.10 stable, 토큰 13종)·Google 자신의 DESIGN.md(레이아웃은 *prose*, 토큰은 colors·typography·rounded·spacing·components)·Stitch `designTheme` JSON·FlutterFlow(색·폰트만 임포트, 화면 플로우 제외) — **전부 레이아웃을 토큰에 안 넣는다.** 레이아웃은 일관되게 "토큰 *옆* 별도 트리 모델"로 다뤄짐.

2. **충실도 레버는 두 갈래뿐 — "생성측 구조 IR" 과 "평가측 시각 검증" — 이고, "HTML 직변환"은 정답이 아니다.** 직변환은 절대좌표 함정(Anima: 픽셀충실 최고지만 유지보수·반응형·접근성 파괴)·비유지보수 스파게티(FlutterFlow 생성코드)·이미지/벡터 미구현(FigmaToCode 결정론 변환기조차 Images/Vectors 미구현)으로 업계가 기피. **dddart 코퍼스의 "디자인 도구 생성코드 직수입 금지" 정책은 이 기피 이유와 정확히 일치.**

3. **[생성측] IR-first가 LLM 직재현보다 레이아웃 충실도가 높다는 게 학술적으로 입증됨(효과는 보통).** ScreenCoder(Layout Dictionary + Hierarchical Layout Tree IR): Position Alignment 0.840 vs GPT-4o end-to-end 0.811(**+3.6%p**), Block Match +3.4%p. GameUIAgent(Design Spec JSON IR): "구조화 IR이 이미지→코드 직생성보다 신뢰성·시각충실도 높음". 단 효과크기 보통(+2~4%p)이고 HTML/웹 도메인 측정 → Flutter 외삽 미검증.

4. **[평가측] VLM-as-judge는 게이트가 아니라 회귀 신호로만 써야 한다.** VLM이 CLIP보다 인간 선호에 부합(UI2Code^N)하나, **전문가에 15~20%p 못 미침**(WebDevJudge: 최고 Claude-4-Sonnet pairwise 66% vs 인간 85%). **결정적 모달리티 발견: judge는 코드에 닻을 내린다** — code+screenshot ≈ code-only인데 **image-only는 −4.9~−8.7%p 하락**. → grader에게 *렌더 스크린샷만* 주지 말고 **코드+스크린샷(+시안)**을 함께.

5. **dddart의 결정 레인 ∥ 의미 레인 이분 구조에 시각 충실도가 깔끔히 매핑된다.** 결정 레인 = 결정론 시각 메트릭(블록매칭/SSIM·CW-SSIM, 핀 고정, **회귀 델타로만**·절대 합격선 금지) + (선택)layout-ir 구조 diff. 의미 레인 = rubric VLM grader(코드+스크린샷+시안, **pairwise**가 single보다 ~8%p 우수, blind N≥3, **생성≠채점** crab-engine). dddart 기존 통제(blind·N≥3·다수결·자기보고 불신)가 표준 편향 완화책과 정확히 일치.

6. **Stitch→Flutter 공식 1급 경로는 없다 — dddart는 Stitch가 안 주는 빈칸을 메우는 제3자 도구다.** Stitch 공식 export는 HTML+Tailwind가 1차(React/Vue/Flutter는 LLM 변환층), 공식 Codelab도 React+Tailwind 타깃, MCP/SDK는 `getHtml()`·`getImage()` 둘뿐(레이아웃/컴포넌트 트리 미노출). **"더 충실한 입력"을 Stitch에서 받을 여지는 없다** → HTML 파싱 충실도 + 스크린샷 검증을 높이는 게 유일한 레버. Stitch의 공식 충실도 단위(Design DNA / DESIGN.md)도 **토큰**이지 레이아웃 픽셀이 아님 → dddart 토큰 추출 방향은 공식 워크플로우와 같은 결.

7. **이미지는 Stitch가 공식 번들 경로를 안 주므로 dddart 자체 다운로드+번들이 정답 — 단 URL 만료/라이선스 미확인이 최대 리스크.** 이미지는 `lh3.googleusercontent.com/aida-public/...` CDN URL로 박혀 나옴(dddart 관측 일치). 결정론 변환기 공통 사각지대(FigmaToCode도 Images 미구현). [[stitch-image-asset-bundling]] 트랙과 합류.

---

## 2. 축별 발견 (출처·신뢰도)

### 축1 — design-to-code 생태계 (시안→Flutter 충실도)
- **Builder.io Visual Copilot = 하이브리드**: 전용모델이 "flat design→code hierarchy" 트리 추론 → 오픈소스 컴파일러 **Mitosis가 결정론 컴파일** → fine-tuned LLM은 프레임워크/스타일 적응만. **레이아웃 계층 결정을 LLM 바깥(결정론 IR)에 둠.** 컴포넌트 매핑은 "deterministic guarantees" 명시. 단 ~75%까지·Flutter 타깃 문서상 미확인. 高 — builder.io/blog/figma-to-code-visual-copilot, builder.io/blog/best-figma-to-code-plugin, github.com/BuilderIO/mitosis
- **Anima = 절대좌표 직변환**(top:42px 식, flat HTML): 픽셀충실 최고·유지보수 최악. dddart가 원치 않는 극단. 高 — pixelperfecthtml.com/figma-to-code-plugins-anima-vs-locofy-vs-hand-coding
- **Locofy = 사람이 레이아웃 명시 라벨링 요구**(Classic): "플러그인이 Figma 데이터만으로 레이아웃 의도 신뢰성 있게 추론 못 함." 업계도 "시안만으로 의도 추론 불안정" 인정. 高 — locofy.ai/docs, sixtythirtyten.co/blog/from-figma-to-code-ai-design-to-dev-workflows-in-2026
- **FlutterFlow = 토큰(색·폰트)만 임포트, UI 페이지 플로우 미임포트** — **dddart 현재 분업과 동일.** 高 — rapidevelopers.com/flutterflow-integrations/figma
- **Figma Dev Mode codegen = Flutter 네이티브 미지원**(CSS/SwiftUI/Compose/XML만, 서드파티 플러그인 필요). 高 — developers.figma.com/docs/plugins/codegen-plugins
- **학술 IR-first 우위**: ScreenCoder(arxiv 2507.22827, +3.6%p Position Alignment) · GameUIAgent(arxiv 2603.14724, 2단계>직변환) · Athena(arxiv 2508.20263, IR이 LLM+개발자 비계). 高
- **직변환 결정론기 FigmaToCode**: 자체 IR(AltNodes)·완전 결정론이나 **Vectors/Images 미구현** = dddart 래스터 갭과 일치. 高 — github.com/bernaferrari/FigmaToCode
- **LLM 비결정성**: 코드생성 런간 정확도 변동 ≤15%, best-worst ≤70%(arxiv 2408.04667, ACM TOSEM 3697010). 완화: **구조화 생성·few-shot 앵커링이 분산 실측 감소**(huggingface.co/blog/evaluation-structured-outputs). 高

### 축2 — 시각 충실도 자동 검증
- **다축 분해가 표준**(합산 안 함): Design2Code(NAACL 2025)= CLIP(고수준) + 블록매칭(텍스트·위치·색 CIEDE2000·면적가중). 高 — arxiv 2403.03163, salt-nlp.github.io/Design2Code
- **VLM judge > CLIP(인간선호)** but **전문가에 15~20%p 미달**: WebDevJudge Claude-4-Sonnet pairwise 66% vs 인간 85%. 高 — arxiv 2511.08195, arxiv 2510.18560
- **모달리티(직접적용)**: judge는 **코드에 닻**. image-only −4.9~−8.7%p. 高 — arxiv 2510.18560
- **pairwise > single ~8%p**, rubric 채점이 신뢰도↑(WebVR 96%, 단 교차도메인). 高/中 — arxiv 2510.18560, arxiv 2603.13391
- **편향 실증**: 위치편향(arxiv 2410.21819)·자기선호편향(GPT-4, 강한모델이 자동으로 덜 편향되지 않음 arxiv 2604.22891)·**기능등가 맹점**(다른 구현이 같은 요구 만족해도 기각 — dddart "등가 레이아웃 허용" 목표와 충돌 위험). 高/中
- **golden test = 환경 재현성이지 UI 품질 아님**: `matchesGoldenFile` 폰트·플랫폼·버전 의존, Flutter Gold가 AA "비결정성" 인정. **픽셀 동일 강제는 LLM 산출 평가에 부적합.** 현 표준 = **alchemist**(Ahem 폰트로 플랫폼 무관), golden_toolkit은 discontinued. 高 — api.flutter.dev/.../matchesGoldenFile, github.com/Betterment/alchemist
- **시각 메트릭 결정성·실패모드**: SSIM/CW-SSIM 완전 결정론(CW-SSIM은 이동/스케일에 견고), LPIPS/CLIP은 핀 고정 시 결정론이나 LPIPS 이동 비불변·CLIP 공간 맹목(다른 배치인데 cos>0.95). **양방향 실패** → 회귀 델타로만. 高 — arxiv 1801.03924, arxiv 2503.08723, arxiv 2306.09344(DreamSim)
- **render-in-the-loop 가속**: Self-Refine→ReLook(arxiv 2510.11498)→Amazon CITL(arxiv 2604.05839, 3사이클 +17.8%). **Anthropic 공식: 스크린샷 비교 루프 권장 + "작업한 에이전트가 채점하지 말라"**(code.claude.com/docs/en/best-practices). 高
- **헤드리스 캡처**: Flutter는 `flutter test` 위젯 골든(오프스크린, 디바이스 불요)이 최경량. 高

### 축3 — 디자인 토큰 표준의 경계
- **DTCG v2025.10 stable, 토큰 13종** — 레이아웃/배치/계층 타입 없음. token="indivisible pieces". 비표준 데이터는 `$extensions`(단 "값에 비필수 메타로 제한" 권고). 高 — designtokens.org/tr/2025.10/format
- **Google DESIGN.md(google-labs-code/design.md)**: YAML 토큰 = colors·typography·rounded·spacing·components 5종, **Layout은 prose**. "tokens are normative, prose provides context" → **Google이 "레이아웃은 토큰화 안 함"을 포맷으로 선언.** components도 *스타일 값*만(구조/자식트리 아님). 高 — github.com/google-labs-code/design.md
- **레이아웃은 별도 트리**: Figma node tree + **Auto Layout(flexbox 1:1**: layoutMode·primaryAxisAlign·itemSpacing·layoutGrow·HUG/FILL). 단 Auto Layout(의미적) vs absolute(좌표만) 공존. 高 — developers.figma.com/docs/plugins/api/properties/nodes-layoutmode
- **HTML→IR은 결정적이나 기하 인식 필요**: DOM 순서 ≠ 시각 순서(CSS order/absolute 함정), accessibility tree는 div-soup에 너무 공격적(styling div→generic 붕괴). VIPS(MS Research 시각 기반 분할) 류 필요. 高 — VIPS tr-2003-79, playwright.dev/docs/aria-snapshots
- **반복패턴(리스트/카드) 검출**: MDR류 near-isomorphic 형제(arxiv 2505.17125). **composite 컴포넌트 인식은 ML로도 ~77% F1 = 본질적 비결정.** 高/中
- **컴포넌트→코드 매핑은 통제된 DS 안에서만 결정적**: Figma Code Connect(identity 바인딩, 단 **Flutter 미지원**·사람 작성). **Material 3 ↔ Flutter 위젯 거의 1:1**(Card→Card, ListTile 등, 단 공식 테이블 미확인). 高
- **prior art IR**: Mitosis(JSON AST, Flutter 타깃 미확인) · Locofy LDM(arxiv 2507.16208, "identical inputs→identical outputs" 결정론 주장) · flutter_widget_from_html `BuildTree`(렌더 IR이지 의도 IR 아님). 高/中

### 축4 — Google Stitch의 설계 의도
- **Stitch = 개발자 핸드오프 출발점**(production-ready 아님), Gemini 기반(2.5 Pro→3.x). 高/中 — blog.google/.../stitch-ai-ui-design, developers.googleblog.com/stitch-a-new-way-to-design-uis
- **공식 export = HTML+Tailwind 1차**(React/Vue/Flutter는 LLM 변환층). Figma paste 있으나 "not always exactly the same". 高/中 — blog.logrocket.com/google-stitch-tutorial, html.to.design/blog/from-google-stitch-to-figma
- **이미지 = lh3.googleusercontent.com/aida-public/ CDN URL** 그대로, 공식 다운로드/번들 경로 없음, **만료/라이선스 확인 못 함**. 高/中
- **Stitch→Flutter 공식 1급 경로 없음**(공식 Codelab도 React+Tailwind). Flutter는 전부 제3자 재현(Antigravity+MCP도 에이전트 자유생성). 高 — codelabs.developers.google.com/design-to-code-with-antigravity-stitch, github.com/google-labs-code/stitch-sdk
- **MCP/SDK 노출 = getHtml()·getImage() 둘뿐**, 레이아웃/컴포넌트 트리 미노출. 원격 MCP는 `stitch.googleapis.com`(공식). 高
- **DESIGN.md(Design DNA) = 공식 충실도 단위 = 토큰**(색·타이포·spacing·컴포넌트 규칙). 高 — 공식 Codelab
- **Stitch 자신도 정렬·반응형 약점 인정**("doesn't understand center positioning"). 中/高

---

## 3. dddart 결정 포인트 (브레인스토밍 입력)

- **결정 A — 어느 레버부터?** 평가측(VLM grader/메트릭: 회귀를 *잡음*) vs 생성측(layout-ir/few-shot 앵커링: *덜 흔들리게*). 독립·보완. measure-first 철학상 평가측 먼저가 자연(생성 개선의 효과를 측정하려면 측정망부터).
- **결정 B — A1 인간 오라클 경계 재정의?** 현재 "시각충실도=자동 비측정". 자료조사: VLM은 전문가 15%+p 미달 → 완전 자동화 부적합, 그러나 회귀 신호로는 유효. 옵션: **인간 오라클 유지 + 결정론 회귀 메트릭(결정 레인) + rubric VLM grader(의미 레인) 보조**.
- **결정 C — layout-ir.json(구조 힌트) 도입? 범위?** 근거 있음(+3.6%p)·리스크 있음(div-soup·composite 비결정·렌더 의존). 권장 범위: **섹션 계층 + 반복그룹 + 컴포넌트 라벨**(픽셀좌표 강제 금지 — Anima 함정 회피). design-tokens.json *옆* 별도 파일(`design-ref/layout-ir.json`)이 표준 정합.
  - **전제 검증(즉시·무비용)**: Stitch HTML 실물이 얼마나 시맨틱한가(div-soup 정도)가 "순수 DOM 파싱 vs 렌더 필수"를 가름. dddart는 이미 샘플 보유(`design-ref/*.html`, `extract_design.dart`가 먹는 것).
- **결정 D — 이미지 번들 트랙 합류?** [[stitch-image-asset-bundling]]. IR에서 `<img>`를 placeholder 노드로 보존 + 빌드타임 다운로드+번들. **선결: URL 만료/라이선스 실측**(런타임 직참조 vs 빌드타임 번들 안전성).
- **결정 E — measure-first 정합.** 무엇이든 코퍼스 변경이면 다음 런 동결. 측정망(eval 단일출처 메트릭/grader)은 코퍼스 산문보다 먼저·기계적이라 우선순위↑.

---

## 3.5 전제 검증 결과 (2026-06-19 실측 · 코퍼스 파서 + 9개 런 시안)

결정 C의 전제("Stitch HTML이 div-soup면 렌더 필수→무의존 원칙 충돌")를 dddart 보유 샘플로 즉시 검증 — **결과는 결정 C에 매우 유리하게 해소.**

1. **입력 시안은 byte-identical.** 8차 claude/codex의 `weekly-list.html`이 271줄 완전 동일(`diff -q`). 같은 Stitch 화면을 동결한다 → **엔진 간 레이아웃 분기는 입력 차이가 아니라 100% LLM 재현 단계에서 발생**(같은 입력→다른 출력 = 레이아웃 미강제의 직접 증거). "왜 다르게 그렸나"의 확증.
2. **Stitch HTML은 div-soup가 아니다(자료조사 최대 우려 해소).** 9개 런 전 회차 시안 통계가 균일:
   - 시맨틱 태그: list=`header×1·main×1·section×1·nav×1`, detail=`section×2`. 전부 `<button aria-label>`·`<h1>`·`<img alt>` 사용.
   - **HTML 주석으로 컴포넌트 의도 명시**: list 13개·detail 8개(`<!-- TopAppBar -->`·`<!-- 7-Day Forecast List -->`·`<!-- Day N -->`·`<!-- BottomNavBar -->`).
   - **`absolute`=0·`order-`=0 전 회차** → DOM 순서 = 시각 순서. **기하 인식·헤드리스 렌더 불필요.**
   - Material 어휘: 색 토큰이 M3 롤 이름(`on-surface`·`surface-bright`·`primary-container`), `data-icon`=Material Symbols, 반복 카드는 near-isomorphic 형제(7일).
   - 까닭: Stitch가 "개발자 핸드오프용"(축4)이라 시맨틱·접근성 마크업을 냄(div-soup는 v0/Lovable류 다른 도구 문제).
3. **정보는 HTML에 있는데 파서가 버린다(RCA 코드 확증).** `extract_design.dart`(무의존 정규식 파서)는 `<script id="tailwind-config">` 토큰 + `material-symbols` 아이콘 + arbitrary/neg-margin class만 추출하고 **header/main/section/nav 구조·주석·`<img src>`를 코드에서 명시적으로 무시**. "처리 경로 0"이 아니라 "경로를 안 만든 것" → 같은 무의존 파서 방식으로 `layout-ir.json` 확장이 자연스럽다.

**판정**: layout-ir 결정론 추출은 (a)기술 실현 가능성 高(시맨틱·주석·DOM=시각순서·무의존 파싱) (b)결정성 高(입력 byte-identical·구조 회차 균일·absolute 0) (c)신규 의존 불필요. 자료조사가 우려한 "렌더 필수" 리스크는 **이 도메인(Stitch HTML)에선 해당 없음**. 남는 판단은 *효과 크기*(자체 eval 측정)와 *IR 강제 범위*(브레인스토밍).

---

## 4. 권장 방향 (잠정 · 브레인스토밍에서 확정)

1. ~~먼저 전제 1건 즉시 실증~~ **✅ 완료(§3.5)** — layout-ir 무의존 결정론 추출 가능 확인, 결정 C에 유리.
2. **평가측 우선 설계(결정 A·B)**: 시각 충실도를 ① 결정 레인 = 결정론 시각 메트릭(블록매칭/CW-SSIM, 핀 고정, **회귀 델타**) ② 의미 레인 = rubric VLM grader(코드+스크린샷+시안, pairwise, blind N≥3, crab-engine) 로 이중화. A1을 "비측정"→"회귀 게이트+인간 표본 검수"로 강등. dddart 기존 레인·자기보고 불신과 정합.
3. **생성측은 그다음(결정 C)**: 1의 결과로 layout-ir 범위 결정. 도입 시 ScreenCoder식 "planning(구조 고정) vs generation(규약 변환)" 분리로 **충실도와 MVVM/section/widget 규약을 단계 분리**.
4. **이미지(결정 D)**: URL 만료 실측 후 번들 파이프라인. IR placeholder 노드와 연결.

---

## 5. 미해결 · 추가조사 (확인 못 함)
- Flutter 특화 design-to-code 충실도 벤치마크(현 벤치는 HTML/웹 위주 → Flutter 외삽 미검증).
- ~~Stitch HTML 실제 마크업 시맨틱성(div-soup 정도)~~ — **✅ §3.5 해소: div-soup 아님·시맨틱·주석·DOM=시각순서·무의존 파싱 가능**.
- Stitch가 Material 어휘를 쓰는지(컴포넌트→Flutter 위젯 매핑 결정성의 전제).
- ~~`lh3.googleusercontent.com/aida-public/` URL 만료~~ **✅ 실측(2026-06-19)**: 다운로드 가능(200·핫링크OK·CORS)·수명 보장 없음(max-age 24h·서명만료 헤더 없음) → 빌드타임 번들 확정(생성측 §5). **라이선스는 여전히 미확인**.
- 자동 메트릭↔인간 상관의 UI 도메인 직접 수치(임계값 보정용·dddart 자체 보정셋 ROI).
- dddart MCP 구현체의 `get_screen` 정확한 반환 스키마(inline htmlCode vs download URL).

---

## 6. 종합 1차 출처 (재확인용)
- 표준: designtokens.org/tr/2025.10/format · github.com/google-labs-code/design.md · developers.figma.com/docs (REST/plugin/code-connect)
- 학술: arxiv 2403.03163(Design2Code) · 2507.22827(ScreenCoder) · 2603.14724(GameUIAgent) · 2510.18560(WebDevJudge) · 2511.08195(UI2Code^N) · 2410.21819(self-preference) · 2306.09344(DreamSim) · 1801.03924(LPIPS) · 2408.04667(LLM 비결정성)
- 도구: github.com/BuilderIO/mitosis · github.com/bernaferrari/FigmaToCode · github.com/Betterment/alchemist · github.com/mapbox/pixelmatch
- Stitch: blog.google/.../stitch-ai-ui-design · developers.googleblog.com/stitch-a-new-way-to-design-uis · codelabs.developers.google.com/design-to-code-with-antigravity-stitch · github.com/google-labs-code/stitch-sdk · stitch.googleapis.com(MCP)
- 공식 가이드: code.claude.com/docs/en/best-practices(스크린샷 비교 루프·자기채점 금지)
