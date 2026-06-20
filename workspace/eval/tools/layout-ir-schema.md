# layout-ir 스키마 (동결본·SSOT) — 시각 충실도 평가·생성 공유 토대

> **상태: 동결(2026-06-19·feedback-011 시술) — 단, §6 4파라미터(section fallback·repeat 임계·button 분기·평탄화 깊이)는 *잠정*(positive-control 반증 후 확정)**. 노드 트리(§1)·번역표(§2)·평탄화(§3)는 SSOT로 동결, 4파라미터만 미확정이다. 이 문서가 layout-ir의 **단일 출처(SSOT)**다 — 시안 파서(`extract_design` 확장: Stitch HTML → `layout-ir.json`)와 렌더 덤프(평가 도구: Flutter 위젯 트리 → 같은 형식)가 **이 스키마를 산출**해야 대조 가능. **시안 파서·대조·렌더 덤프 전부 구현·8차 실증(step 2a·2b)** + 표준 pump 진입점 규약 `screenProbes`(코퍼스 §7·2026-06-19) — RUBRIC `FID-L1·L2·L3`·EVAL-METHOD `§2.3 FID`·`§2.5`가 이 문서를 판정 기준으로 참조. **FID-L1·L2 치명 게이트 활성(`RUBRIC §H`·치명 20·9차가 `screenProbes` 자동 경로 첫 운용).**
> **설계 경위·검산**: `workspace/design/2026-06-19-layout-ir-schema.md`(노드 합의 과정)·`2026-06-19-fidelity-eval-design.md`(§8 list/detail 실물 검산)·`2026-06-19-stitch-fidelity-research.md`(§3.5 전제검증). 이 동결본은 *사양*, design 문서는 *근거*.
> **measure-first(소급 금지)**: 동결 후 채점 결과를 보고 스키마를 바꾸지 않는다 — 바꿀 발견은 다음 동결 라운드(fix 원장)로. §6 열린 점 4개만 구현 시 positive-control로 *확정*(동결 시점에 잠정값 명시).

---

## 0. 목적·불변

- **목적**: 화면의 시각 구조를 결정론·언어중립(공통 어휘) JSON으로 표현. 의미 라벨(날짜/기온) 없이 **시각 타입+배치+순서**만(§4 슬롯 원칙).
- **불변**:
  1. 배열 순서 = 시각 순서(DOM=시각 확증 — 자료조사 §3.5).
  2. 투명 래퍼 미집계(§2 마지막 행).
  3. 픽셀 값 미포함(L4는 `design-tokens.json`·사용자 눈 소관).
  4. 양쪽(파서·덤프) 정규화는 태그/위젯 타입·클래스/속성에서 **직접 도출** → 결정론(헤드리스 렌더·VLM 불요).

## 1. 노드 트리 (스키마)

```
layout-ir (한 화면)
├ screen : string                       // 식별자(파일/타이틀)
└ areas  : [ Area ]                     // ── L1 (순서=시각 순서)

Area:
├ role     : "appbar" | "image" | "section" | "bottomnav"   // 공통 어휘(번역표 §2)
├ label?   : string                     // section 제목/주석 (참고용·비교 키 아님)
├ src?,alt?: string                     // image 전용 (이미지 트랙·3단계)
├ slots?   : [ Slot ]                   // appbar/bottomnav 직속 슬롯
└ children?: [ Block ]                  // ── L2 (section 내부)

Block:
├ kind  : "block" | "repeat-group"
├ slots? : [ Slot ]                     // kind=block (비반복 적층; group 중첩 가능)
└ unit?  : { slots: [ Slot ] }          // kind=repeat-group (반복 단위 템플릿 — 횟수는 비강제)

Slot:                                   // ── L3
├ type  : "text" | "icon" | "image" | "button" | "group"
├ width?: "fixed" | "flex" | "auto"     // 배치 추상
├ align?: "left" | "center" | "right"
└ slots?: [ Slot ]                      // type=group (평탄화 대상 중첩, §3)
```

- **repeat-group**: 반복 단위(card)를 `unit` 템플릿 하나로 표현. **반복 횟수는 데이터(fixture) 의존이라 비교에서 제외**, "반복 그룹 존재 + unit 구조"만 본다.
- **group**: 의미 없는 중간 묶음(예: 기온 `[28°,/19°]`을 한 덩어리로 묶은 것). 추출엔 보존(리포트=사용자 눈 재료), **L2 비교 시 평탄화**(§3).

## 2. 번역표 (정규화 규칙)

| 공통 어휘 | 시안 파서 (Stitch HTML) | 렌더 덤프 (Flutter) |
|---|---|---|
| `appbar` | `<header>` | `AppBar`/`BackAppBar`(+서브클래스) |
| `image` | `<img src>` | `Image`/`Image.asset`/`Image.network` |
| `section` | `<section>` | `*Section` 위젯(dddart 명명 규약) |
| `bottomnav` | `<nav>` | `BottomNavigationBar`/`NavigationBar` |
| `text` | 텍스트 함유 인라인/블록 | `Text`/`Text.rich`/`RichText` |
| `icon` | `<span class=material-symbols>` | `Icon` |
| `button` | `<button>`/`<a role=button>` | `*Button`/`IconButton`/`InkWell`(탭 콜백) |
| `repeat-group` | near-isomorphic 형제 ≥2 / `grid` | `ListView`/`GridView`/`.map()` 반복 |
| width `fixed` | `w-<n>` | `SizedBox(width:)`/고정 제약 |
| width `flex` | `flex-1`/`flex-grow` | `Expanded`/`Flexible` |
| `align` | `text-*`/`justify-*`/`items-*` | `textAlign`/`Center`/`Align`/`MainAxisAlignment` |
| **(투명·미집계)** | 레이아웃 전용 `<div>`·내용없는 spacer | `Column`/`Row`/`Padding`/`Center`/`Material`/`Ink`/`InkWell`(컨테이너로서)/`SizedBox`(spacer)/`SingleChildScrollView` |

- `section` 식별은 dddart `*Section` 명명 규약 의존(architecture-ui 강제) → §6 열린 점 1.
- `InkWell`은 탭 콜백이 있으면 `button` 신호, 순수 래퍼면 투명 — 역할로 분기(§6 열린 점 3).
- **표 미정의 위젯 fallback**: 단일 자식 래퍼(`Card`·`Container`·`DecoratedBox`류)=투명·자식 승계 / 다자식 레이아웃(`Stack`·`Wrap`·`Flex`류)=투명 컨테이너·자식 순서 보존 / 콘텐츠 복합 위젯(`ListTile`류)=positive-control 확정 전까지 *리포트에 「미정」 명기*(임의 text/button 분류 금지). 미정의 위젯 조우 시 **투명 추정 + 리포트 표기**(채점자 임의 분류로 L2/L3 갈리는 것 차단).
- **수기 단정 금지**: onTap 유무(InkWell button 분기)·width(fixed/flex)처럼 *렌더 덤프가 자동 검출하는 속성*은 수기로 단정하지 않는다 — 도구(`dump_to_ir`)가 판정하고, 산출물이 `screenProbes` 미노출이라 덤프 불가한 런만 A1 위임(`EVAL §2.3 FID 주의 ①`).

## 3. 평탄화 규칙 (L2 비교)

L2 게이트 비교 시:
- `type:"group"`·투명 노드를 **펼쳐 부모 슬롯 시퀀스에 인라인**.
- **`area`·`repeat-group` 경계는 보존**(펼치지 않음) — 영역/반복 단위는 의미 경계.
- **연속 동종 slot 축약(collapse·measure-first 보정·step 2b 2026-06-19)**: 인접 같은 type을 1로(`text,text→text`). 시안 div 흡수(여러 text가 한 컨테이너) vs 코드 위젯 분리(`Text`×2)의 비대칭을 해소한다. **양쪽 대칭 적용**·진짜 차이(누락·순서·종류·repeat 경계 토큰)는 그대로 검출. `compare_layout.dart _collapse`.
- 결과 시퀀스를 순서보존 대조(누락/추가/순서변경 검출).

예: `[날짜, group[아이콘,상태], 기온]` → 평탄화 `[날짜, 아이콘, 상태, 기온]`. (묶음 흡수·순서 보존)
예2(collapse): 코드 hero `[text,icon,text,text,text]`(기온 `Text`×2) vs 시안 `[text,icon,text,text]`(기온 div→text1) → 양쪽 collapse `[text,icon,text]` → PASS(8차 hero false regression 차단·실측 확인).

## 4. 실물 예시 — weekly-list layout-ir (사양 검증용)

```json
{
  "screen": "weekly-list",
  "areas": [
    { "role": "appbar", "slots": [
        { "type": "icon", "align": "left" },
        { "type": "text", "align": "center" }
    ]},
    { "role": "image", "src": "lh3…/aida-public/…", "alt": "Broccoli Icon" },
    { "role": "section", "label": "7-Day Forecast List", "children": [
        { "kind": "repeat-group", "unit": { "slots": [
            { "type": "text", "width": "fixed", "align": "left" },
            { "type": "icon", "width": "flex", "align": "center" },
            { "type": "text", "width": "fixed", "align": "right" }
        ]}}
    ]},
    { "role": "bottomnav", "slots": [
        { "type": "button" }, { "type": "button" }
    ]}
  ]
}
```
(daily-detail = `areas`=[appbar, section"히어로"(children: block.slots=[text,icon,text,group[text,text]]), section"지표"(children: repeat-group unit.slots=[icon,text,text]), bottomnav]. 검산 = `fidelity-eval-design.md §8.1`.)

> **표본 일반성(2026-06-20)**: §4 예시(weekly-list·daily-detail)는 **weather 1종 실표본**이다. 노드 트리(§1)·번역표(§2)·평탄화(§3)는 *언어중립*(§0 불변)이라 시나리오 무관이나, **§6 4파라미터의 거짓-FAIL 반증(positive-control)은 현재 이 weather morphology 1종으로만 수행**됐다 — 폼/그리드/탭 셸 등 다른 화면류 교차 검산은 **2번째 실시나리오 라이브런 산출물로 보강한다**(measure-first·이론 표본 창작 금지). 어휘·평탄화 규칙 자체는 화면류 무관이나, 4파라미터 *확정*은 표본 다양성 위에서다.

## 5. 대조 예시 — 8차 claude *수기 구조 대조* vs 위 시안 (스키마 **설계 예시**·도구 구현 전 작성)

> ⚠️ 아래는 **사람이 수기로 짠 예시**다(스키마 설계 시 작성). 이후 도구(`extract_layout`·`dump_probe`+`dump_to_ir`·`compare_layout`)가 구현돼 8차 실물로 자동 실증됐고 **FID 게이트는 활성(2026-06-19·`§7`·`RUBRIC §H`)**. 이 절은 "스키마가 무엇을 잡는가"의 *설계 의도*로 보존한다.

```
area appbar     ✓ (BackAppBar → [icon,text])
area image      ❌ FID-L1 대상 — 코드에 Image 노드 없음 (사용자 지적 ②·도구 후 게이트)
area section    ✓ (WeatherListForecastSection → ListView = repeat-group)
  unit slots    ✓ FID-L2 [text(fixed,left),icon(flex,center),text(fixed,right)] 일치(평탄화 후)
area bottomnav  ❌ FID-L1 대상 — 코드에 BottomNav 노드 없음 (도구 후 게이트)
```
→ (도구 구현 시) 스키마가 **image·bottomnav 누락을 L1으로, 카드 슬롯 일치를 L2/L3로** 표현할 수 있음을 보인 *설계 예시*(수기 대조·자동 실증 아님).

## 6. 결정성 · 열린 점 (구현 시 positive-control 확정)

- **결정성**: 시안=무의존 파싱(§3.5)·코드=렌더 덤프, 양쪽 정규화가 타입/클래스에서 직접 도출 → byte 재현 가능(기존 백스톱 결정성 검증 패턴 호환).
- **열린 점(동결 시점 잠정값 — `tools/positive-control/fid/`로 거짓-FAIL 반증 후 확정)**:
  1. **section fallback**: `section` 식별의 `*Section` 명명 규약 의존 — section 위젯 없이 body 직속 그룹으로 그린 산출물의 fallback 규칙. *잠정*: `*Section` 부재 시 Scaffold.body 직속 비투명 그룹을 단일 section으로 본다.
  2. **repeat 임계**: `repeat-group`의 near-isomorphic 형제 임계(시안 파서) — 형제 몇 개부터 반복으로 볼지. *잠정*: **≥2**.
  3. **button 분기**: `button` vs 투명 `InkWell`(탭 콜백 유무)의 렌더 덤프 검출 방법. *잠정*: `onTap`/`onPressed` 비-null 콜백 보유 시 `button`, 아니면 투명.
  4. **평탄화 깊이**: group 평탄화의 깊이 한계(무한 중첩 방어). *잠정*: 깊이 상한 없이 `area`·`repeat-group` 경계까지 재귀 평탄화(순환 없음 — 트리 보장).
  - 이 4개의 잠정값은 positive-control(등가 산출물)이 거짓 FAIL을 내지 않음을 확인한 뒤 동결 확정한다(FID-L2 게이트 투입 선결).

## 7. eval 정합 (참조 지도)

- **RUBRIC**: `FID-L1`(areas role·종류·순서)·`FID-L2`(section children 평탄화 시퀀스·repeat-group 존재)·`FID-L3`(slot type·width·align)이 이 스키마의 계층을 1:1로 판정.
- **EVAL-METHOD**: `§2.3 FID 결정-판정 표`(판정원=시안 layout-ir vs 렌더 덤프 대조)·`§2.5`(L1·L2 자동 게이트 / L3 약신호 / L4 A1)·`§0`(FID positive-control·게이트 활성 조건).
- **도구(전부 구현·8차 실증)**: 시안 파서 `dddart/scripts/extract_layout.dart`(HTML→layout-ir·코퍼스·양판 미러·토큰은 `extract_design.dart` 별도) + 대조 `tools/compare_layout.dart`(L1/L2/L3·평탄화·eval) + 코드 렌더 덤프 `tools/dump_probe.dart.txt`(산출물 flutter test 템플릿)+`tools/dump_to_ir.dart`(위젯 트리→layout-ir·eval). 8차 실측: L1 image/bottomnav 갭 포착·repeat 등가 흡수 입증. **게이트 활성(2026-06-19)**: 표준 pump 진입점 규약 `screenProbes`(코퍼스 §7·양판 미러) 충족 → FID-L1·L2 치명(20)·9차 자동 경로 첫 운용. (hero 인접 text 흡수는 §3 collapse 보정.)
