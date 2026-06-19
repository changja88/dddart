# layout-ir 스키마 (2026-06-19) — 평가·생성 공유 토대 [설계 경위]

> **⚠️ 동결본(SSOT) = `workspace/eval/tools/layout-ir-schema.md`** (2026-06-19·feedback-011 시술로 동결). 이 문서는 *설계 경위·검산*이고, 채점·도구가 따르는 *사양*은 동결본이다. 사양 변경은 동결본에서(소급 금지).
> **공유**: 시안 파서(`extract_design` 확장: Stitch HTML → layout-ir.json)와 렌더 덤프(평가 도구: Flutter 위젯 트리 → 같은 형식)가 **동일 스키마**를 산출해야 대조 가능.
> 짝 문서: `2026-06-19-fidelity-eval-design.md`(§2~5 추출·비교·강도) · `2026-06-19-fidelity-generation-design.md`(소비).
> 상태: 스키마 합의 초안 · list/detail 실물 검산 완료 → **동결본으로 이관 완료**(eval 단일출처). 구현(Dart 파서·덤프)은 step 2 코퍼스 승인 절차.

---

## 0. 목적·불변

- **목적**: 화면의 시각 구조를 결정론적·언어중립(공통 어휘) JSON으로 표현. 의미 라벨(날짜/기온) 없이 **시각 타입+배치+순서**만(§4 슬롯 원칙).
- **불변**: (1) 배열 순서 = 시각 순서(DOM=시각 확증, §3.5). (2) 투명 래퍼 미집계. (3) 픽셀 값 미포함(L4는 design-tokens·눈). (4) 양쪽(파서·덤프) 정규화는 태그/위젯 타입·클래스/속성에서 직접 도출 → 결정론.

## 1. 노드 트리 (스키마)

```
layout-ir (한 화면)
├ screen : string                       // 식별자(파일/타이틀)
└ areas  : [ Area ]                     // ── L1 (순서=시각 순서)

Area:
├ role     : "appbar" | "image" | "section" | "bottomnav"   // 공통 어휘(번역표 §2)
├ label?   : string                     // section 제목/주석 (참고용·비교 키 아님)
├ src?,alt?: string                     // image 전용 (이미지 트랙)
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

- `section` 식별은 dddart `*Section` 명명 규약 의존(architecture-ui 강제) → §6 열린 점.
- `InkWell`은 탭 콜백이 있으면 `button` 신호, 순수 래퍼면 투명 — 역할로 분기.

## 3. 평탄화 규칙 (L2 비교)

L2 게이트 비교 시:
- `type:"group"`·투명 노드를 **펼쳐 부모 슬롯 시퀀스에 인라인**.
- **`area`·`repeat-group` 경계는 보존**(펼치지 않음) — 영역/반복 단위는 의미 경계.
- 결과 시퀀스를 순서보존 대조(누락/추가/순서변경 검출).

예: `[날짜, group[아이콘,상태], 기온]` → 평탄화 `[날짜, 아이콘, 상태, 기온]`. (묶음 흡수·순서 보존)

## 4. 실물 예시 — weekly-list layout-ir

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
(daily-detail은 `areas`=[appbar, section"히어로"(children: block.slots=[text,icon,text,group[text,text]]), section"지표"(children: repeat-group unit.slots=[icon,text,text]), bottomnav]. §8.1 검산과 일치.)

## 5. 대조 예시 — 8차 claude 렌더 덤프 vs 위 시안

```
area appbar     ✓ (BackAppBar → [icon,text])
area image      ❌ L1 게이트 — 코드에 Image 노드 없음 (사용자 지적 ②)
area section    ✓ (WeatherListForecastSection → ListView = repeat-group)
  unit slots    ✓ L2 [text(fixed,left),icon(flex,center),text(fixed,right)] 일치(평탄화 후)
area bottomnav  ❌ L1 게이트 — 코드에 BottomNav 노드 없음
```
→ 스키마가 **image·bottomnav 누락을 L1으로, 카드 슬롯 일치를 L2/L3로** 정확히 표현.

## 6. 결정성 · 열린 점

- **결정성**: 시안=무의존 파싱(§3.5)·코드=렌더 덤프, 양쪽 정규화가 타입/클래스에서 직접 → byte 재현 가능(기존 §7 결정성 검증 패턴 호환).
- **열린 점**:
  1. `section` 식별의 명명 규약 의존(`*Section`) — section 위젯 없이 body 직속 그룹으로 그린 산출물의 fallback 규칙.
  2. `repeat-group`의 near-isomorphic 임계(시안 파서) — 형제 몇 개부터 반복으로 볼지(≥2 잠정).
  3. `button` vs 투명 `InkWell` 분기(탭 콜백 유무)의 렌더 덤프 검출 방법.
  4. group 평탄화의 깊이 한계(무한 중첩 방어).
  - 이 4개는 구현 시 positive-control(등가 산출물)로 거짓 FAIL 반증하며 확정.
