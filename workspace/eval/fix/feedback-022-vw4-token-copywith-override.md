# fix 022 — VW-4 typography 토큰 위 copyWith 오버라이드 (RUBRIC 귀속 + §7↔§8 모순 + 생성 길목)

> 사전등록형. 예상효과를 *고치기 전* 박고 17차 결과지로 실측 대조(EVAL §자기보고 불신).

## 메타
- **회차**: 022
- **트리거**: `results/20260623-1331-weather-{claude,compare}.md`(VW-4 🟡 `forecast_tile_widget.dart:101` `AppTypography.headlineLgMobile.copyWith(fontSize:18)`·g3 적발·2:1·κ=0.67) + 본세션 1차 ROC 4렌즈 적대 검증(`wf_bbd15fed`·324k) + 2차 처방 4렌즈 적대 검증(`wf_568c52e4`·416k)
- **베이스 코퍼스**: `1fc7946`
- **시술 커밋**: (미커밋·사용자 지시 대기)
- **검증 런**: 17차
- **상태**: **시술완료**(소비성/적대 검증 게이트 통과·17차 검증대기·미커밋)

## RCA 요약 (1차 4렌즈 — `wf_bbd15fed`·324k·내 가설 교정)
- **증상**: 16차 claude `forecast_tile_widget.dart:101` = `AppTypography.headlineLgMobile.copyWith(fontSize:18)` — 토큰 참조 후 fontSize만 리터럴 18 오버라이드(시안 `text-[18px]`를 새 토큰 정의 안 함). g3 VW-4 🟡(g1·g2 PASS·2:1·κ=0.67). codex 16차 무누출(fix020 크기 토큰 승격).
- **회귀 아니라 만성 다형**: 색(12 claude `Colors.white`)·duration(14 claude 생 `Duration`)·fontSize(16 claude copyWith·**11 codex `displayTemp` 80→48 copyWith 동형**)·radius(12 codex). 양엔진 출렁·16차 N=1.
- **가설 교정**(내 "생성측 3중 사각" → 실제):
  - **[1차·지배] RUBRIC 채점축 경계 미정의** — `토큰.copyWith(fontSize:N)` 토큰-위-덮기 + size prop 직접인용을 VW-4(거주) vs FID-L4(미관·비측정) 귀속 규칙 부재. 11차 `displayTemp` copyWith=3 grader 전원 FID-L4 흘림(`20260620-1405-graders-raw.md:158·196·241`) ↔ 16차 동형=g3만 VW-4 적발. κ=0.67.
  - **[2차·구조적 모순] §7(생 TextStyle 금지) ↔ §8:115(추출값 size prop 직접 인용 허용)** — fontSize는 `TextStyle` 안이라 "직접 인용" 경로가 copyWith뿐인데 그게 VW-4 회색지대.
  - **[3차·확증] 강제 길목 사각** — NM10(`check_naming.dart:231` `Color(0x|TextStyle(` 만)·`discipline-reviewer` VW-4 감사 부재.
  - **[배경] 엔진 자유변수 지배**(Q-7 동형·N=1·codex 11차 동형 누출). 단 copyWith=**양성 리터럴**이라 Q-7 죽은토큰과 달리 재발 시 결정적 측정 가능.
  - ★**§7:103 이미 "fontSize는 생 TextStyle 금지에 포함" 문언 포섭** → 가설의 "규율 부재"는 반증(규율은 있고 강제 길목·RUBRIC 귀속이 빔).
  - ★**결정적 비대칭**: 16차 claude가 생 96/36을 width/icon size prop 직접인용 = VW-4 **무적발** vs 생 18을 typography 토큰 copyWith 덮기 = **적발**. 차이는 typography 토큰 위 덮기 vs 비-typography size prop뿐 → 처방의 정확한 표적.

## 2차 처방 검증 (`wf_568c52e4`·416k — BLOCKER 0·CONCERN 3·PASS 1[회귀])
- **교정 4건 반영**:
  - ★★**architect 4단 필수 승격** — `coder.md`가 `architecture-ui §8`을 **로드 안 함**(grep 실측·implementation-*+discipline-*만). §8만 고치면 coder가 못 읽어 무효 → `design-architect.md:38`이 생성 1차 판정자 유일 경로([[feedback-018]]·[[feedback-021]] ★교훈 동형).
  - ★**§113 `text-[Npx]` 예시 ↔ 새 §115 충돌** — §113이 `text-[Npx]`를 arbitraryValues 대표 예시로 두는데 새 §115는 "fontSize 직접 인용 아님" → coder 이중귀속. §113에 carve-out 필수.
  - **height 동음** — `Container(height:)` 박스 높이(비-typography·면제) vs `TextStyle.height` 행간(typography·표적) disambiguation 1구절.
  - **프레이밍 정정** — "Q-9 codex.md:132 carve-out 충돌"은 사실오류(`codex.md:132`는 코퍼스 아닌 결과지 채점노트) → "11차 grader 3/3 FID-L4 흘림 역전".
- **과적합 무혐의**(typography↔비-typography 구분 = `TextStyle`이 타이포 운반체라는 Flutter 구조 + 7토큰 중 typographic size 거처는 `app_typography`뿐이라는 코퍼스 사실 — 범용·시나리오 어휘 0)·**회귀 LOW**(extract 불가침·레이아웃/에셋 0교차·width 직접인용 보존).

## 교정 항목 (사전등록 — ①~④ 고치기 전 / ⑤~⑥ 17차 후)

| # | 우선 | ① 대상 결함 | ② 원인(뿌리) | ③ 처방(파일·미러) | ④ **예상효과**(전→후) | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| 1 | ★선결 | RUBRIC 채점축 귀속 미정(11↔16 진동·κ=0.67) | VW-4(거주)↔FID-L4(미관) 경계 미정의 | RUBRIC `:6` 마스트헤드·`:42` VW-4 FAIL절·`:187` 직교에 "기존 App* 토큰 위 copyWith로 typography 시각값(fontSize·height(행간)·letterSpacing) 리터럴 덮기=VW-4(거주 우회) / 비-typography size prop(width·박스 height·아이콘 size) 직접인용=§8 정식·임의 미관=FID-L4" 명문화. **단일 출처**(미러X) | 17차 grader가 copyWith fontSize 덮기를 VW-4로 일관 적발(11차식 FID-L4 흘림 차단·κ 수렴) | | |
| 2 | 모순해소 | §7↔§8 모순·§113 예시 충돌 | §8:115 "직접 인용"이 typography↔비-typography 미구분·§113 text-[Npx] 예시 | architecture-ui §8 `:115` 명료화(typography=app_typography 토큰 정의·비-typography=직접인용/승격·height 동음 구분·"공유 시 승격 우위·둘 다 무위반") + `:113` text-[Npx] carve-out. **미러 auto**(`--write`) | coder가 §8 읽으면 typography fontSize는 토큰 정의로 인지·§113↔§115 이중귀속 해소 | | |
| 3 | ★생성길목 | coder가 §8 미로드 → 명세부터 "직접 인용"이라 copyWith로 흐름 | architect triage(`:38`)가 "단일 사용처 직접 인용"을 명세에 박음·typography 비구분 | `design-architect.md:38` 크기 정형목록에 "비-도메인 추출 typography 크기(arbitraryValues fontSize)는 app_typography 토큰 정의·참조로 명세(copyWith 덮기 명세 금지)·비-typography만 직접 인용" 추가. **미러 수동 양판** | architect 명세부터 typography 크기를 토큰 정의로 박아 coder copyWith 집행 차단 | | |
| 4 | 감사길목 | NM10 사각(copyWith 미검출) | reviewer VW-4 감사 부재 | `discipline-reviewer.md` §6에 "App* 토큰 copyWith의 typography 수치 prop 리터럴 덮기=VW-4 위반(important)·NM10 사각" 1줄 + 면제절(color 토큰·fontWeight·비-typography size·SD-2 도메인 copyWith). **미러 수동 양판** | 재발 시 reviewer 감사 발화(생성+감사 길목 동급화) | | |

- **NM10 정규식 확장**: **measure-first 보류** — `copyWith(color:AppColor.x)`·`fontWeight`·§8 직접인용 오탐 폭발·마스킹 난도(2차 렌즈 4·feedback-018 선례). reviewer 의미 판정으로 먼저 닫고 17차 실측 후 필요 시 승격.

## 비-과적합 가드 (plugin-general-purpose)
- typography↔비-typography 구분은 **범용 원리**: `fontSize`는 `TextStyle` 안에 산다(§7:103이 "fontSize는 생 TextStyle 금지에 포함"으로 이미 박음) + 7토큰 중 typographic size 거처는 `app_typography`뿐(§8:115). 임의 `width`/아이콘 size는 토큰 타입이 없어 직접 인용/`app_spacing` 승격이 유일한 비-발명 경로 — `Color`(→`app_color` 항상) vs `Colors.transparent`(구조 상수·미토큰화) 동형 논리.
- 처방 문언에 `weather`/`fontSize:18`/`forecast_tile`/`text-[18px]` **어휘 0**(2차 렌즈 2 무혐의). `displayTemp`/`headlineLg`는 RCA 예시일 뿐 규율 어휘 아님.
- 단일 사용처 fontSize의 `app_typography` 토큰 정의는 무의미 토큰 양산 아님(§7 "무의미 토큰 양산 방지"는 `Colors.transparent` 류 비-브랜드 구조 상수 겨냥 — `app_typography`는 모든 타이포의 강제 단일 출처).

## 강제력 길목 ([[feedback-018]]·[[feedback-021]] ★교훈)
- **생성 길목**(`design-architect.md:38` — coder가 §8 미로드라 architect 명세가 유일 경로·2차 렌즈4 grep 실측) + **감사 길목**(`discipline-reviewer` §6 종심) + **채점 축**(RUBRIC) 3중. 지식(§8)만 고치는 동형 함정 회피 — §8은 coder 미로드라 단독으론 死문구가 될 뻔(feedback-021 `:292` 동형).

## 미러
- RUBRIC: **단일 출처**(eval·미러 없음).
- architecture-ui **§8**: `corpus_mirror_sync.py --write`(소스←배포·codex←배포·스코프=final.md 9종).
- **design-architect**: 수동 양판(claude `agents/design-architect.md` ∥ codex `skills/dddart-design-architect/SKILL.md`·본문 IDENTICAL·frontmatter/경로만 상이·스코프 밖).
- **discipline-reviewer**: 수동 양판(claude `agents/discipline-reviewer.md` ∥ codex `skills/dddart-discipline-reviewer/SKILL.md`·본문 IDENTICAL).

## 측정 (★정직 단서 — 2차 렌즈 4)
- **N=1·엔진 비결정**이라 17차에 claude가 copyWith를 안 쓰면 측정 불능(Q-7 측정 빈곤 **부분 상속**). 단 copyWith=**양성 리터럴**이라 재발 시 결정적 검출(Q-7 화석 grep불능보다 **우위**·Q-6 빈 runZonedGuarded 양판 자동 grep보다 **열위**).
- 처방 목표는 *검출*(이미 16차 2:1 🟡)이 아니라 **grader 수렴**(3/3) — RUBRIC 경계의 수렴 효과는 16차 FC-1 §0표 κ=1.0 만장으로 입증.
- 17차 측정 = ① grader가 copyWith fontSize 덮기를 VW-4로 일관 적발(κ 출력 의무)·② g3 적대 정독 지속(`feedback-021:52` 동형). 자동 grep(`AppTypography.*copyWith.*fontSize`)은 오탐으로 비권고(reviewer 반자동).

## 시술 후 리뷰 게이트 (3렌즈 — 2026-06-23·general-purpose 병렬·실제 박힌 텍스트 기준)
**전 렌즈 통과·교정 불요**:
- **소비성 CONSUMABLE**: 5단 양판 byte-identical·소비 주체별 실행 가능. ★coder가 architecture-ui **미로드 실측 확정**(`coder.md:5-12`·codex SKILL.md:11 — implementation-*+discipline-*만) → §8 단독은 死문구, **architect 명세(`design-architect.md:38`·loaded)가 생성 1차 판정자 유일 길목**·coder는 집행자(`coder.md:15·40`)·구조 성립. architect 3분기(도메인 typography→ui_extension 제외 / 비-도메인 추출 fontSize→app_typography 정의 / 비-typography→직접인용) 명확·기존 문언 충돌 0. reviewer 면제절 4종 정당 케이스 가름. RUBRIC :6/:42/:187 3중 경계로 grader FID-L4 흘림 봉합.
- **정합·회귀 SAFE+COHERENT·회귀 LOW**: 5곳 내부 정합(RUBRIC 3중 동일 경계·§113↔§115 이중귀속 해소). ★**height 동음 robust disambiguation**(위반=`AppTypography`+`copyWith`+typography prop 3조건·면제=박스 height verbatim 열거 → `Container(height:)` 오탐 경로 0). 기존 코퍼스 모순 0(§7:103 strict consequence·SD-2 면제절 분리·FID-L4 직교 재확인). ★**fix020/레이아웃/에셋 0교차**(`extract_design.dart` `_arbitrary`/`_sizingDim`/`_sizingFont` **git diff empty**·prose-only·비-typography 직접인용+AppSpacing 승격 양경로 verbatim 보존 → 16차 codex 96/36 토큰승격 무회귀·레이아웃/에셋 기계 0교차). §8 3-tier IDENTICAL.
- **실효성·과적합 EFFECTIVE·과적합 무혐의**: `text-[Npx]`·`headlineX`는 placeholder 예시(규율 어휘 아님)·weather/18 누수 0. typography↔비-typography = `TextStyle` 구조 + 7토큰 사실 근거 범용. 실효성 정확(fontSize+height+letterSpacing 전수 → 11차 `displayTemp` `fontSize:48·height:1.1` 이중오버라이드도 커버·과/부족 없음). 측정 정직(모범적·Q-6~Q-7 사이 자가 위치). **처방이 옳다**(Q-7 화석 측정불능 defer 근거 비해당·RUBRIC 귀속 절반은 measure-first-free 수렴작업·κ=0.67 진동은 엔진 비결정 무관하게 결정론 봉합).
- **비차단 관찰 2건**: ① 강제력은 architect 명세 품질 의존(reviewer:78·RUBRIC:42 백스톱 2중·처방 의도대로·[[feedback-018]] 동형 정상) ② 커밋 시 VW-4(feedback-022)는 Q-6(feedback-021)과 **별도 커밋**(016/017 분리 선례·ledger 라인 청결).

## 회차 요약 (17차 후)
- (비움 — 17차 실측 후 기입)
