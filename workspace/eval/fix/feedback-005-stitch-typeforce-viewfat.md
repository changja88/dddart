# feedback-005 — Stitch 100%·Dart 타입 전면 강제·view 위젯 직접빌드 차단 (v2·적대리뷰 반영·E 수정 전)

> **상태: E·F·F' 완료·전 커밋** — E1(view NM17)·E2a~d(타입 전면·analysis_options 국소·fixture 실증)·E3(Stitch 100%)·F(4렌즈 적대리뷰)·F-fix(블로커 봉쇄)·F'(재적대 재검 통과). 커밋 `d397ad6`·`9ba2bb5`·`863690a`·`47e9f68`·`7314d53`·`140d237`. · 베이스 `17100a9` · 원칙 = **기계 강제**
>
> **F·F' 결과(2026-06-15)**: 4렌즈 적대리뷰(skill-creator·plugin-dev·정합·쟁점깨기)가 목표2·3의 기계 *게이트* 구멍을 실증 → **F-fix로 봉쇄**: ① NM17 강화(멀티라인 extends·`List<Widget>`/`Widget?`/`PreferredSizeWidget`/구체위젯 반환 함수 차단·`WidgetRef`류 거짓양성 제외·F11 픽스처) ② 타입lint **생성 게이트**(백스톱 ST4가 새 생성영역 루트에 analysis_options.yaml 누락 차단 — lint 존재를 기계 강제·LLM 판단 제거) ③ G0 정정(실위협=호스트 루트 `analyzer:exclude`가 생성폴더 덮음·`omit_*`는 무해 실측) ④ extract_design fail-loud(따옴표 인지 정규화·빈토큰 exit 1). **F' 재적대**(2 에이전트 실증): NM17 6벡터 재봉쇄·정상 view 거짓양성 0·ST4 게이트 완전·extract_design 10종 악성입력 무손상·명세 정합 — blocker 0. **잔존(설계상 기지·라이브런)**: 비위젯 클래스 인스턴스메서드 위젯빌더·`implements Widget`=discipline-reviewer 의미감사 분업 / always_specify_types green=라이브런 재확인 / run_fixtures.sh codex 미러=pre-existing.
>
> **E3 완료 요약(2026-06-15)**: ① `scripts/extract_design.dart`+`icon_map.json` 신규 — 동결 HTML의 tailwind-config(JS→JSON 정규화: 무인용 상위키·trailing comma)에서 색·타이포·spacing·아이콘(`data-icon`+`FILL`·텍스트 폴백)·임의값(shadow `rgba`·음수마진)을 `design-tokens.json`으로 **결정론 절단**(실제 동결 HTML로 검증·2회 byte-identical·픽스처 F10 추가 14/14). ② **아이콘 분기 해소**: HaffHaff 방언(`Icons.` 12·`Symbols.` 0·`material_symbols_icons` 없음)+4개 런 전부 `Icons.*` → `Icons.*` 유지(Symbols 도입=방언 이탈). 1:1 한계는 design-tokens가 정확 Material Symbol명+FILL 원천 보존·review-ui/인간 판정으로 흡수. ③ command Phase 0(HTML 의무화·extract_design 호출·`has_stitch_html`)·architect(입력+화면 절 토큰 소비)·review-ui(충실도 4종 게이트)·architecture-ui §5(아이콘=plain extension·`Icons.*`·FILL→`_outlined`·NM14) 명세. ④ 양판 미러 전부(final.md sync 9/9·scripts cp byte-identical·codex SKILL/agents 수동)·stale "검사 51종" 4곳 정합 교정(상수 52와 일치).
> **v1→v2**: 적대리뷰 4개(skill-creator·plugin-dev·쟁점깨기·정합)가 v1의 약한 고리를 깸 → 본 v2가 보강.
> **사용자 결정**: ① 타입 강제 = **B 전면(클로저 파라미터 포함)** ② analysis_options = **A BC폴더 국소 + G0 승인**

## D 적대리뷰 핵심 (무너뜨린 것)
- **[쟁점깨기·실측]** 호스트 루트 analysis_options 주입 → 정상본 codex에 **146 issues·exit 1**(green 래칫 파괴). → BC 국소로 전환.
- **[skill-creator]** Stitch 추출을 LLM 명세에 맡기면 피드백3 재현 → 스크립트화.
- **[쟁점깨기]** view `^class _` **우회 3종**(언더스코어 없는 이름·top-level `Widget` 함수·private 위젯 section 이동) → 패턴 확장 필요.
- **[정합]** backstop ID/카운트·NM14(ui_extension은 plain extension만→아이콘 const class 금지)·기존 예제 자가모순·error 소유권(state §4)·codex 경로 비대칭.

## 목표1: Stitch 100% 반영 (v2)
**원인**: design-ref PNG 수렴·HTML 의무 없음·LLM 추출·미연결 비발동.
**처방**:
1. **[기계 의무]** `commands/dddart.md` Phase 0: design-ref 3종 동결(`design-system.json`·`<screen>.html`·`<screen>.png`). HTML 누락 시 G0 차단. `build-state.json`에 `has_stitch_html:true` 기록.
2. **[스크립트·신규]** `scripts/extract_design.dart`: 동결 HTML/JSON 파싱 → 색·타이포·spacing·아이콘(`data-icon`+`FILL`)·레이아웃을 `design-tokens.json`으로 **결정론 출력**. `icon_map.json`(Material Symbols→Flutter 상수) 고정 테이블. **Coordinator가 실행**·architect는 산출물만 소비(LLM 추출 제거).
3. **[명세]** `agents/design-architect.md` 기존 "화면(ui)" 절 **인라인 보강**(별도 절 신설 안 함·progressive disclosure): "`design-tokens.json`이 있으면 그 색·spacing·아이콘을 명세 화면 절에 박는다. 신규 색=foundation 토큰 추가 결정."
4. **[명세]** `architecture-ui §5`: 아이콘 매핑 = **도메인 enum 위 plain extension**(const class·별도 enum 금지·NM14 정합)·Material Symbols 이름·`fill:1`.
5. **[게이트]** `agents/design-review-ui.md`: `has_stitch_html` 플래그로 발동. 충실도 4종 — ①`namedColors` 미매핑 색 ②spacing·임의값(shadow `rgba` 수치) 대조 ③아이콘 이름·`FILL` ④음수마진·인터랙션·부재요소 Flutter 대안. HTML 대조 명시.
**한계(인정)**: 임의값 CSS·인터랙션·부재요소는 완전 기계화 불가 → `design-tokens.json`이 색·타이포·spacing·아이콘을 기계화, 레이아웃 미세는 review+인간 오라클 보조.

## 목표2: Dart 타입 전면 강제 (v2 · 결정 B+A)
**원인**: 문구만·lint 0·측정 dim 0.
**처방**:
1. **[결정B 전면]** `always_specify_types` + `always_declare_return_types` → 지역변수·반환·필드·제네릭·**클로저 파라미터 전부**. `itemBuilder: (BuildContext context, int index)`·`when(error: (Object e, StackTrace s))`·`GoRoute(builder: (BuildContext c, GoRouterState s))`·`sort((Notice a, Notice b))` 명시. (Flutter 표준 마찰 감수 — 사용자 확정)
2. **[결정A 국소]** `analysis_options.yaml`을 **BC 생성 폴더에 국소 생성**(호스트 루트 무손상). analyzer 하위 "대체" 의미론 → 국소 파일에 `include`(flutter_lints)·`exclude`(`**/*.g.dart`·`**/*.freezed.dart`)·rules 전부 명시. G0 배너에 "생성 폴더 타입 강제 lint 추가" 고지·승인.
   - **생성 위치 범위(E에서 확정)**: BC = `lib/application/<bc>/`. common·design_system 등 공유 폴더 커버 방식(국소 파일 위치·여러 폴더 대응).
   - **G0 기계검사**: 호스트 기존 `analysis_options`·`omit_local_variable_types` 감지(충돌 경고).
3. **[명세]** `implementation-dart §2` + `SKILL.md`: "초기화 지역변수 추론" → "지역변수·클로저 파라미터 포함 전면 명시(codegen 제외)". 의도적 일탈 2→3 정합.
4. **[정합·필수]** 기존 코퍼스 예제 **동시 교체**(자가모순 방지): `§3` freezed 관용구(`final error = next.value?.error`)·`architecture-state §4` 정식 예제·positive-control fixture 전수 → 타입 명시.
5. **[fixture]** positive-control에 BC 국소 `analysis_options` 복제 + `dart analyze` green 확인(기계 검증).

## 목표3: view 위젯 직접빌드 차단 (v2)
**원인**: 미겨냥·"조립" 느슨·backstop 0.
**처방**:
1. **[기계·backstop 신규 NM17]** `scripts/src/check_naming.dart`: `*_view.dart`에서 — (a)`class \w+ extends (Stateless|Stateful|Consumer)Widget`(언더스코어 무관·우회 차단) (b)top-level `Widget`-반환 함수(`Widget _build...`) 탐지 → BLOCKER. `_totalChecks` 51→52. NM3 주석 정합("view는 NM17 추가 게이트").
2. **[명세·positive]** `architecture-ui §2`: positive 지시 "view body=section/widget 인스턴스 조립 + error/loading 표준 컴포넌트 직접 반환만". 금지는 "NM17 기계 차단" 참조(negative 예제 대신·backstop 권위).
3. **[명세]** section private class 기준: 위젯 클래스 정의는 `widget/` 폴더 소속(section은 조립)·section fat 전이 차단.
4. **[정합]** error/loading: `architecture-state §4` 소유 고정. §4에 design_system(`ErrorFeedback`·`Loading`) 직접 반환 보강. `architecture-ui §2`엔 "§4 따른다" 한 줄.
5. **[양판]** backstop 경로 비대칭: claude `dddart/scripts/src/`·codex `codex-dddart/skills/dddart/scripts/src/`. `corpus_mirror_sync.py`에 `src/*.dart` 동기 포함. added 파일 검사 의미론 유지.

## 코퍼스 변경 지점·미러 (E 대상)
| 대상 | 경로 | 미러 |
|---|---|---|
| 타입·view 명세 | `implementation-dart §2·§3`·`architecture-ui §2·§5`·`architecture-state §4` final.md | mirror_sync |
| SKILL·agents·commands | implementation-dart SKILL·design-architect·design-review-ui·dddart.md | 수동 양판 |
| backstop | `dddart/scripts/src/check_naming.dart`+러너 / `codex-dddart/skills/dddart/scripts/src/` | mirror_sync에 src 추가 |
| 신규 스크립트 | `extract_design.dart`·`icon_map.json` | 양판 |
| analysis_options 국소 | command/coder 생성 지시 | 명세 |
| fixture | `workspace/eval/tools/positive-control/` | eval 단일출처 |

## 예상효과 (사전등록·다음 Stitch 연결 라이브런)
- **Stitch**: 색·타이포·spacing·아이콘이 `design-tokens.json` 경유 시안 일치(기계)·레이아웃 review+인간.
- **타입**: BC 국소 lint `dart analyze`가 클로저 포함 전 생략 차단(측정 dim).
- **view**: backstop NM17이 위젯 클래스·top-level Widget 함수 차단(우회 포함).

## 검증런 실측 (3차 라이브런 `dddart-20260615-1938`·채점 `20260615-2319`·결과지 `results/20260615-2319-weather-*`)

> **예상효과 대조** (사전등록 dim vs 3차 실측·grader 6명 만장일치+조정자 결정 레인):
> - **타입(E2)** ✅ **적중** — 양판 `flutter analyze` "No issues found!"·always_specify_types 켜진 BC국소 `analysis_options.yaml` 하 green(클로저·컬렉션 전면 타입 명시). 생략 0.
> - **view(목표3)** ✅ **적중** — 양판 backstop NM17 0 발화·view=section/컴포넌트 조립만.
> - **Stitch(E3)** ❌ **미발동** — 양판 design-ref 0파일·`design-tokens.json` 없음·Stitch MCP 미연결(자체 설계). **4개 런 연속 미연결로 E3 메커니즘 검증 불가**. `extract_design.dart`·`icon_map.json`은 설치됐으나 런이 미실행.
> - 부수: 백스톱 52종·BC국소 analysis_options 생성(ST4) 양판 정상. F-fix 강화분(NM17·extract_design fail-loud)은 런이 안 건드려 직접 미검증(회귀 0).
>
> **종합**: 양판 둘 다 ❌ FAIL. 단 **겨냥한 축(타입·view) 검증** + 직전 치명 다수 해소(claude ST-2 격하 교정·codex 백스톱 5→0·G-8 영문라벨→한글). **그러나 feedback-005가 *안 겨냥한* 치명이 종합 PASS를 막음**: claude=**FC-2 골든 두드리는 테스트 부재**(더미 스모크 1개·1·2·3차 지속), codex=**날짜 오름차순 정렬 전면 누락**(FC-1·2·3 근원)+수동 riverpod 2.x(ST-5).
>
> **교훈**: feedback-005는 *기계 강제 가능한 축(타입·view)에서 성공*했으나, 라이브런 종합 PASS를 막은 건 **그 3목표 밖의 치명**(테스트 산출·정렬 정확성)이었다 — **겨냥점이 실제 실패 지점과 어긋남**. 다음(006 후보): ①coder 골든-두드림 테스트 게이트(claude FC-2 근본·feedback-004 미구현) ②정렬/핵심행위 책임 명시+FC 순서 단언(codex FC-1·N2) ③codex `@riverpod` 코드젠 강제(ST-5) ④E3는 **코퍼스 아니라 *런 절차*(Stitch 연결)가 막음** → 4차 라이브런 Stitch 연결 선결.

## F 적대리뷰 (E 후)
수정이 v2 계획대로인가·우회 잔존·양판 대칭·fixture green·backstop self-check를 서브에이전트로 검증.
