# 시각 충실도 평가측 설계 (2026-06-19)

> 자료조사 근거: `2026-06-19-stitch-fidelity-research.md`(§3.5 전제검증 포함).
> 합의 경위(브레인스토밍): 평가측 먼저 → 결정 레인 주력=구조 diff → 추출=렌더 덤프 → 슬롯 식별=타입·배치·순서 → VLM grader 보류.
> **상태: 설계 합의 완료 · 사용자 리뷰 대기.** measure-first상 실제 구현·RUBRIC 반영·코퍼스(테스트 규약) 변경은 **다음 런 동결 절차**로만(소급 금지·EVAL-METHOD §0·§5).
> 범위: 이 문서는 **평가측(시각 충실도 측정)**만. 생성측(layout-ir을 coder 입력으로)은 후속 설계.

---

## 0. 목표·범위

- **문제**: Stitch 원본(=동결 `design-ref/*.html`)을 "그대로" 옮기는지 dddart가 자동 측정하지 못한다. 토큰(색·타이포·간격·아이콘)만 결정론 강제하고 레이아웃·이미지는 LLM 참고로 흘려, 같은 시안을 엔진마다 다르게 분해하고 이미지를 누락한다(8차 실증). 시각 충실도는 A1 인간 오라클(자동 비측정)이라 회귀를 놓친다.
- **목표**: 시안 대비 생성 코드의 **구조 충실도**를 결정론으로 측정·리포트하고 회귀를 게이트/신호화한다. "레이아웃 분기"·"이미지 누락"을 자동 포착하되, **의미·미관 최종 판정은 사용자 눈(A1)에 남긴다.**
- **비목표**: 픽셀 1:1 재현 강제(Anima 함정), HTML→위젯 직변환(코퍼스 금지), 미관의 자동 판정.

## 1. 평가측 3층 구조

| 층 | 누가 | 입도 | 역할 |
|---|---|---|---|
| **구조 덤프·대조 도구** | coordinator(결정 레인) | **말단(L3 슬롯)까지 추출·리포트** | 사용자 눈 검수의 *재료* |
| **rubric 게이트** | 자동 채점 | L1·L2=치명 게이트 / L3 말단=약신호 / L4 픽셀=비강제 | 결정론 회귀 게이트 |
| **최종 시각 판정** | **사용자 눈** | 전체·미관 포함 | A1 인간 오라클(유지) |

원칙: **자동은 결정론만, 의미·미관 판정은 가장 정확한 오라클(사용자)에게.** 정보는 말단까지 다 보여주되(추출), 자동 강제는 등가 표현을 죽이지 않는 강도(판정)로 분리.

## 2. 구조 추출 = 렌더 덤프 (정적 AST 아님)

생성 코드의 위젯 트리를 **flutter test로 오프스크린 렌더한 뒤 element 트리를 직렬화**한다(`debugDumpApp` 류). 정적 AST 미채택.

근거(8차 산출물 실측):
- dddart에 이미 위젯 펌프 인프라 완비(`test/.../view/_support.dart`: fake VM·GoRouter·`NoSplash` 결정성 테마·고정 뷰포트). 기존 테스트가 이미 `find.byType(ForecastTileWidget)→findsNWidgets(7)`로 렌더 트리에서 구조를 읽는다.
- element 트리가 view→section→widget 3단 분해를 **런타임에 자동 해소**(정적 AST는 클래스 3단 횡단 + `state.when` 분기 + `itemBuilder` 람다 해석 필요·반복 개수 불명).
- coordinator가 결정 레인에서 이미 flutter test를 돌린다 → 같은 레인 합류.
- **구조는 픽셀이 아니라** 폰트/플랫폼/GPU 비결정성과 무관 → 결정론(골든 픽셀 비교는 불필요·부적합. 자료조사 축2).

입력 두 갈래:
- **시안(기준)**: Stitch `design-ref/*.html` 파싱 → 구조 나무(=layout-ir). §3.5 검증대로 시맨틱·주석·`absolute=0`이라 **무의존 결정론 파싱 가능**(헤드리스 렌더 불요). `extract_design.dart`와 같은 방식 확장.
- **코드(대상)**: 생성 위젯 트리 → 렌더 덤프 → 구조 나무.

난점·해소: 화면 pump엔 VM override·라우터 배선이 필요하고 산출물마다 다르다(claude `_support.dart` vs codex 헬퍼). → **"구조 덤프용 표준 pump 진입점"을 테스트 규약화**(생성측 설계와 맞물림). 이게 없으면 coordinator가 산출물별 배선을 추론해야 함.

## 3. 비교 = 공통 어휘 번역 후 노드 대조

3단계: ①양쪽 나무 뽑기 → ②**공통 어휘로 번역** → ③노드 대조(일치/누락/추가/순서).

번역표(골격 예):

| Stitch HTML | Flutter 위젯 | 공통 어휘 |
|---|---|---|
| `<header>` | `AppBar`/`BackAppBar` | `appbar` |
| `<img>` | `Image`/`Image.asset` | `image` |
| `<section>` + 반복 `<div>` | `ListView` + 반복 위젯 | `list > card×N` |
| `<nav>` | `BottomNavigationBar`/`NavigationBar` | `bottomnav` |
| `<main>` | `Scaffold.body` 본문 컨테이너 | `main` |

dddart 유리점: **양쪽 다 Material 어휘**(Stitch는 M3 색 롤·`material-symbols`·시맨틱 태그, dddart는 Material 위젯) → 매핑이 결정론적으로 성립(자료조사 축3 "컴포넌트→코드 매핑은 통제된 디자인 시스템 안에서만 결정적").

## 4. 슬롯 식별 원칙 (말단)

**의미 추론 금지** — "날짜칸/기온칸" 같은 의미 라벨은 내용 추론이 필요해 fragile·비결정(자료조사 축3 composite ~77%). 대신 양쪽에서 결정론적으로 읽히는 3축만:

- **시각 타입**: `text` / `icon` / `image` / `button` (HTML 태그·Flutter 위젯 타입에서 직접; `<span material-symbols>`=icon, `Icon`=icon).
- **배치 추상**: `고정폭`(`w-24` ↔ `SizedBox(width:)`) / `유연`(`flex-1` ↔ `Expanded`) / 정렬(`text-right` ↔ `textAlign:right`). **구체 위젯 타입은 무시**(SizedBox vs Container 등가를 거짓 탈락 안 시킴 — 축2 "기능 등가 맹점" 회피).
- **순서**: DOM=시각 순서 확증(§3.5)이라 그대로.

의미("이게 날짜다")는 **사용자 눈 + 기능 게이트(FC-2가 이미 날짜·기온 슬롯 단언)**가 담당. 슬롯 대조는 **순서보존 시퀀스 매칭**(누락/추가/순서변경 구분), 불일치는 L3 약신호(⚠).

## 5. rubric 강도 (L1~L4)

| 계층 | 예 | 추출 | 판정 |
|---|---|---|---|
| **L1 골격** | 화면 영역: appbar·**image**·섹션·bottomnav 존재·종류·순서 | ✓ | **치명 게이트(❌)** |
| **L2 섹션 구성** | 섹션 안 의미 노드 순서·존재·반복(`card×N`) | ✓ | **치명 게이트(❌·평탄화 비교)** |
| **L3 말단 슬롯** | card 안 슬롯 타입·배치·순서 | ✓ | **약신호(⚠)** → 사용자 눈 |
| **L4 픽셀·미관** | 패딩·정렬·그림자 정확값 | (design-tokens가 값 강제) | **A1 인간** |

**L1·L2 = 게이트 / L3 = 신호 / L4 = 인간** (생성측 강제 강도와 대칭: L1·L2 강제 / L3 유도 / L4 눈). 사용자 결정 2026-06-19.

### 5.1 L2 게이트의 false regression 통제
L2는 "섹션 안 의미 노드의 **순서·존재·반복**"만 정확 일치 요구하고, **의미 없는 묶음 깊이는 평탄화로 흡수**한다:
- 코드가 `[날짜,아이콘,상태,기온]`을 `[날짜,(아이콘+상태),기온]`으로 묶어도 → 평탄화 `[날짜,아이콘,상태,기온]` = 시안 → **PASS**(등가 흡수).
- 상태 누락·순서 뒤집힘 등 진짜 차이는 평탄화 후에도 불일치 → **FAIL**.
- 반복은 `card ×N` 단위로 압축 비교(card 내부는 L3). **반복 횟수는 데이터(fixture) 의존이라 강제 제외**, "반복 그룹 존재"만 본다.

**3겹 통제**(L2 게이트의 거짓 빨강 관리):
1. **평탄화 비교** — 등가 재구성을 구조적으로 흡수(위).
2. **measure-first 보정** — 라이브런에서 "등가인데 빨강" 패턴 발견 시 등가 규칙 추가(fix 원장: 예상효과 먼저·실측 대조).
3. **positive-control** — 게이트 투입 *전* 등가 재구성으로 거짓 FAIL 반증, 나면 보정 후 투입(dddart 신설 백스톱 표준 절차).

비용(정직): L2 강제는 L1보다 architect 자유도를 더 줄이고, 라이브런 초기에 false regression 보정이 몇 회 필요하다. 위 3겹이 그 비용을 관리한다.

## 6. VLM grader 보류 (의미 레인)

지금 도입하지 않음. 재투입 트리거를 명시해 보류:
- **보류 근거**: ①사용자 눈이 의미·미관 최종 판정을 함(A1) → VLM과 중복, VLM은 전문가에 15~20%p 미달(WebDevJudge). ②"왜 다르게 그렸나"의 골격은 결정 레인이 이미 결정론 포착. ③VLM 비결정·자기보고(위치/자기선호 편향) → dddart 자기보고 불신상 게이트 불가. ④매 채점 스크린샷 생성+N≥3 멀티모달 호출+편향 통제 비용 대비 ROI 낮음. ⑤measure-first·YAGNI.
- **재투입 트리거**: 라이브런에서 "**구조 diff는 PASS인데 사용자 눈에 반복적으로 걸리는 미관 회귀**"가 패턴화되면, 그때 의미 레인 grader를 보강(코드+스크린샷+시안 함께·pairwise·blind N≥3·생성≠채점, 게이트 아닌 신호로).

## 7. measure-first 정합·적용 절차

- 이 평가측 도입 = **eval 변경**(RUBRIC 항목 추가 + 구조 덤프/대조 도구 + 테스트 "표준 pump 진입점" 규약). RUBRIC·도구는 eval 단일 출처라 다음 런 채점 착수 전 동결, "표준 pump 진입점"은 코퍼스(테스트 규약) 변경이라 양판 미러 동기 대상.
- 도입 순서 권장: ①구조 덤프/대조 도구 + RUBRIC L1·L2 게이트·L3 신호 항목을 **다음 런 동결**로 추가 → ②그 런에서 L1·L2 게이트·L3 신호의 작동·false regression을 실측 → ③강도/번역표/평탄화 등가 규칙을 fix 원장(예상효과 먼저·실측 대조)으로 보정. **positive-control 거짓-FAIL 반증 후 게이트 투입**(특히 L2).

## 8. 실물 검산 (8차 weekly-list · claude)

```
            Stitch 원본              8차 claude              대조
            ───────────              ──────────              ────
L1 appbar   <header>                 BackAppBar              ✓
L1 image    <img aida-public>          —                    ❌ 치명(누락 = 사용자 지적 ②)
L1 main     <main>                    Scaffold.body          ✓
L2 list     <section>+카드×7          ListView+tile×7        ✓
L1 bottomnav<nav>                       —                    ❌ 치명(누락)
L3 card     [text(고정),icon(유연,중앙),text(고정,우)]
                                     [text(고정),icon(유연,중앙),text(고정,우)]  ✓
```
→ 구조 diff 하나로 **이미지·하단내비 누락이 결정론적으로 FAIL**, 말단 슬롯은 일치 확인. (codex가 기온을 `Column[text,text]`로 그렸다면 L3 ⚠로 *표시*만 하고 사용자 눈이 등가 판정.)

### 8.1 detail 검산 (8차 daily-detail · claude) — 일반화 확인 ✅

detail은 list보다 복잡(비반복 hero 적층 + 반복 metrics)하나 **원리 전부 적용**:
```
            Stitch 원본                  8차 claude                     대조
L1 appbar   <header>                     BackAppBar                     ✓
L1 main     <main>                       SingleChildScrollView          ✓
L1 hero     <section>(적층)              WeatherDetailHeroSection       ✓
L1 metrics  <section grid>(카드×3)       WeatherDetailMetricsSection    ✓
L1 bottomnav<nav>                          —                            ❌ 치명(누락·list와 동일)
L2 hero     [text,icon,text,{text,text}] [Text,Icon,Text,Row[Text,Text]] ✓
L2 metrics  card×3                       _MetricCard×3                  ✓ 반복 일치
L3 metric   [icon,text(라벨),text(값)]   Column[Row[Icon,Text],Text.rich] ✓
```
추가 발견:
- **반복 그룹 개념이 list(card×7)·detail(metric×3) 공통** — 단일 원리로 양 화면 커버(시안도 `<section grid>`로 반복).
- **hero 같은 비반복 섹션도 슬롯 적층(타입+순서)으로 표현** — 반복 아닌 구조도 동일 원리.
- **bottomnav 누락이 양 화면 공통** — L1 게이트가 일관 포착(일관 회귀).
- **아이콘 심볼 차이는 구조 레인 밖(경계 작동 확인)**: 시안 `humidity_percentage`·`rainy` vs 코드 `Icons.water_drop`(습도·강수확률 둘 다 동일 아이콘) — 구조는 "icon 슬롯" 일치(L3 통과)하되 **심볼 불일치는 아이콘 매핑(`design-tokens.icons`)·사용자 눈 영역**. L3(구조)↔아이콘 매핑 게이트↔A1(눈)의 경계가 깔끔히 갈림.

## 9. 열린 질문 · 다음 단계

- ~~번역표 detail 일반화~~ **✅ 검증 완료(§8.1)**: detail(히어로 적층 + 메트릭 반복×3)에 번역표·슬롯 원리 전부 적용. 반복 그룹이 list/detail 공통, hero 비반복 섹션도 슬롯 적층으로 커버. 아이콘 심볼 차이는 구조 레인 밖(경계 작동).
- **"표준 pump 진입점" 규약의 구체 형태**: 생성측 테스트 규약 설계에서 확정(시그니처·반환). 평가·생성 공유 토대.
- **슬롯 시퀀스 매칭 알고리즘**: 순서보존 정렬(LCS류) 세부 — 누락/추가/순서변경 분류 규칙.
- ~~layout-ir 직렬화 형식~~ **✅ 정의됨**: `2026-06-19-layout-ir-schema.md`(노드 트리·번역표·평탄화·실물 검산). 남은 세부 4건은 그 문서 §6.
- **다음 설계(생성측)**: 이 layout-ir을 coder 입력으로 줘 분기 자체를 줄이기(ScreenCoder식 planning↔generation 분리). 평가측이 먼저라 oracle/도구는 여기서 재사용.
