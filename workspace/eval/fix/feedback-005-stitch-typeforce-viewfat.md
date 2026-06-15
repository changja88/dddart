# feedback-005 — Stitch 100%·Dart 타입 전면 강제·view 위젯 직접빌드 차단 (v2·적대리뷰 반영·E 수정 전)

> **상태: 설계 v2 (D 적대리뷰 4개 반영·사용자 결정 2개 확정 · E 수정 승인 대기)** · 베이스 `17100a9` · 원칙 = **기계 강제**
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

## F 적대리뷰 (E 후)
수정이 v2 계획대로인가·우회 잔존·양판 대칭·fixture green·backstop self-check를 서브에이전트로 검증.
