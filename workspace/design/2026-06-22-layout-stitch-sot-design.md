# 레이아웃: Stitch 단일 진실원천 복원 — 설계 명세 (v1)

> **대체**: `2026-06-21-layout-enforcement-design.md`(Track B area-tree) — 이 명세가 그 메커니즘을 **철거·역전**한다.
> **트랙**: 생성측 레이아웃 형상 충실도 (값 운반·자산 트랙은 불가침).
> **측정**: 사용자 육안(A1). FID 자동 게이트는 이번 스코프 밖 — *intact-but-shelved*.
> **상태**: 설계 승인 대기(brainstorming 산출) → plan → 시술(별도 승인·다음 런 동결).

---

## 0. 한 줄

코퍼스가 소유하던 **레이아웃 형상 어휘**(`layout-ir`/area-tree)를 생성측에서 철거하고, 레이아웃 형상의 단일 진실원천을 **Stitch 시안 HTML**로 되돌린다. 코퍼스는 *분해*(아키텍처)와 *충실 재현 강제*만 갖고, **레이아웃 어휘는 0**이다.

## 1. 배경 — 무엇이 왜 깨졌나 (RCA 요약)

13차 라이브런에서 claude가 detail 메트릭 3카드를 **세로(시안 `grid-cols-1`) → 가로(`Row`)**로 뒤집었다(양 엔진 다발 회귀). 근본원인:

- `extract_layout.dart`가 시안 HTML을 `layout-ir.json`으로 절단하며 **축(flex-direction/grid)을 통째로 버린다**(스키마에 방향 필드 없음).
- Track B 시술(`480eb11`)이 이 **축맹 IR을 "화면 구조의 단일 근거"로 승격**(`design-architect.md:23` "눈대중 말고 IR을 박아라")하고, area-tree 어휘에서 **위젯명(Row/Column)을 금지**(`:39` "직교 보존")했다 — Flutter에서 축을 표현할 유일 통로를 막음.
- coder는 시안을 쥐고도(`coder.md:24` "시각 근거") **축맹 명세에 눌려 시안을 덜 봤다**. 강제 *이전*(11차)엔 시안 직접 재현으로 축이 맞았다.

**상세·적대검증**: `workspace/eval/results/20260622-0323-weather-graders-raw.md`, 메모리 `stitch-design-fidelity-gap`. 적대검증 정정 2건: (a) coder는 시안을 *받는다*(축 입력 부재가 아니라 *명세에 의한 주의 빼앗김*), (b) 뒤집힘은 *확률적·엔진분기*(claude=섹션·codex=카드/hero) = coder 변동성 잔여.

## 2. 공리 (HARD 제약 — 사용자 확정)

> **코퍼스는 레이아웃 어휘를 0개 소유한다.** Stitch 시안 HTML(무손실·텍스트라 codex 안전)이 레이아웃 형상의 유일 진실원천이며 coder에 무손실 도관으로 전달된다. 코퍼스의 역할은 아키텍처 규율(DDD/MVVM/state/data) + 시안 충실 *강제*이지, 레이아웃을 *재표현·결정*하는 게 아니다.

두 파생 원칙:

- **분리선 — 값 운반(유지) vs 형상 어휘(제거)**: 색·크기·아이콘·이미지는 Stitch에서 *점값*으로 무손실 추출돼 토큰으로 운반된다(`design-tokens`/size-link/`asset-manifest`) — 유지. 레이아웃 *형상*(축·배치·그룹핑·간격)은 유한 어휘로는 손실적이라(`layout-ir`/area-tree) 제거하고 시안에서 직접 가져온다. 점값은 무손실 추출 가능, 형상은 어휘가 곧 손실.
- **열린 예시 ≠ 닫힌 표**: 새 형상 규칙은 "시안 형상을 *전부* 충실 재현(예: `flex-col`→`Column` *한둘만 예시*)"의 **닫히지 않은** 형태여야 한다. CSS→Flutter 매핑을 *열거*하면 그 표가 곧 새 lossy 어휘(다음 미열거 속성에서 또 샘 = `layout-ir` 재발). coder의 일반 HTML→Flutter 역량이 롱테일을 처리한다.

## 3. 논제 — 분해 vs 형상, 올바른 소유

Track B의 "직교 보존" 직감은 **절반만** 맞았다 — 분해와 형상이 직교인 건 맞다. 틀린 건 **형상의 소유자**였다(코퍼스 어휘에 줬다).

| | 소유자 | 내용 |
|---|---|---|
| **분해(decomposition)** | dddart 코퍼스 | 화면을 *State 기준*으로 view/section/widget 분할·design_system 토큰·내비. 부품 목록(완전성). |
| **레이아웃 형상(layout shape)** | Stitch 시안(HTML) | 축·배치·그룹핑·정렬·간격. coder가 직접 충실 재현. **코퍼스 어휘 0.** |

architect는 "이 화면 = 이 부품들 + 토큰 + 내비"까지만 말하고, **그것들을 어떻게 배치하는지는 한 글자도 적지 않는다.** 배치는 coder가 HTML에서 읽는다.

## 4. 스코프

- **In(이번 설계)**: 생성측 코퍼스 — 형상 어휘 제거 + HTML=형상 SoT + architect 분해 전담 + coder 충실 재현. 양 엔진.
- **Out(측정)**: 충실도 측정 = **사용자 육안(A1)**. FID 자동 게이트·`screenProbes`는 안 건드린다 — *intact-but-shelved*(§8 참조).
- **비목표**: 측정 서브시스템 재작성·FID 삭제·layout-ir 어휘에 축 토큰 추가(공리가 기각). §12.

## 5. 변경 설계 (file-by-file · 양판)

### 5.1 제거 — 생성측 형상 어휘

| 파일 | 제거 | codex 미러 |
|---|---|---|
| `commands/dddart.md:56` | `has_layout_ir` 플래그 정의 | 수동(`codex-dddart/skills/dddart/SKILL.md`) |
| `commands/dddart.md:124` | `extract_layout` 호출 줄(생성 파이프라인) | 수동 |
| `commands/dddart.md:137` | architect 입력 `layout-ir.json` | 수동 |
| `commands/dddart.md:138` | review-ui 입력 `layout-ir.json` | 수동 |
| `agents/design-architect.md:23` | layout-ir 1급 입력 서술("구조 단일근거·눈대중 금지") | 수동(`dddart-design-architect/SKILL.md`) |
| `agents/design-architect.md:39` | area-tree 절(닫힌 어휘·위젯명 금지·직교) — *분해·크기(§8)·이미지 정형목록은 유지* | 수동 |
| `agents/design-architect.md:64` | `has_layout_ir` self-check | 수동 |
| `agents/design-review-ui.md:13` | `has_layout_ir` 입력 서술 | 수동(`dddart-design-review-ui/SKILL.md`) |
| `agents/design-review-ui.md:32` | layout-ir L1 골격 대조 점검(L30 design-ref 대조는 유지) | 수동 |
| `architecture-ui/references/final.md:116` | §8 "layout-ir와 직교" — 재작성(§6.2 ㉣) | **auto(`corpus_mirror_sync --write`)** |

### 5.2 신설/재작성 — HTML=형상 SoT

| 파일 | 변경 | codex 미러 |
|---|---|---|
| `implementation-flutter/references/final.md` | **신설 절 "레이아웃 형상 — 시안 HTML 충실 재현"**(스크롤 §3·자산 §8과 같은 coder 시각 규율 계열) | **auto** |
| `agents/coder.md:24` | design-ref **시각 근거 → 형상 단일 근거** 승격 | 수동 |
| `agents/coder.md:15·39` | "명세 단일근거"·"구조 결정"에 **형상 carve-out** | 수동 |
| `agents/design-architect.md:39` | area-tree 제거 자리에 "형상은 명세 안 함" 1줄 | 수동 |

### 5.3 유지 — 불가침

- **값 운반**: `extract_design.dart`/`design-tokens.json`(색·크기·아이콘)·architecture-ui §8 size-link(본문)·`fetch_images`/`asset-manifest`/§7 `app_asset`. 형상이 아니라 점값이라 공리 무관.
- **측정 서브시스템(intact-but-shelved)**: `extract_layout.dart`(보존 — FID 게이트가 자가호출)·`fid-gate.sh`·`compare_layout.dart`·`dump_to_ir.dart`·`layout-ir-schema.md`·`RUBRIC §H`·`EVAL-METHOD §2.3/§2.5`·`positive-control/fid/`. 이번 스코프 밖. §8.
- **완전성 장치**: `design-review-ui.md:30` design-ref 대조(부품 누락 점검). §7.

## 6. 새 규칙 문구 (정본)

**㉠ implementation-flutter 신설 절 (수정의 심장):**
> **레이아웃 형상 — 시안 HTML을 충실히 재현한다.** 화면의 *형상*(요소가 세로로 쌓이나/가로로 놓이나·그룹핑·정렬·간격)은 코퍼스가 규정하지 않는다. `design-ref/`의 동결 HTML 시안이 형상의 단일 근거이며 너는 그것을 **빠짐없이** dddart 위젯으로 재현한다. 명세는 *무엇을*(분해·토큰·이미지)을 정하고 *어떻게 배치*는 정하지 않는다 — 배치는 시안에 있다.
> - **형상 근거는 HTML(텍스트)**: PNG가 아니라 `design-ref/*.html`의 컨테이너 구조를 읽는다(예: `flex-col`→`Column`. *이건 예시이지 닫힌 목록이 아니다* — 시안의 모든 배치 단서를 충실히 옮긴다). 이미지 비보장 엔진(codex)에서도 HTML은 텍스트라 동일하게 읽힌다.
> - **재현이지 직수입이 아니다**: HTML에서 *형상*을 읽어 dddart 위젯으로 짠다 — HTML/CSS를 그대로 복붙하거나 디자인툴 생성 코드를 직수입하지 않는다(기존 경계 유지).

**㉡ coder.md:24 (승격):**
> (있으면) `design-ref/` — **화면 레이아웃 형상의 단일 근거.** 배치·축(세로/가로)·그룹핑·정렬·간격은 명세가 아니라 이 시안 HTML이 정하고 너는 충실 재현한다(implementation-flutter). *시각 근거*에 그치지 않는다.

**㉢ coder.md:15·39 (carve-out — 충돌 방지):**
> (:15 보강) 승인된 설계 명세를 *분해·계약·메커니즘*의 단일 근거로 구현한다. **단 레이아웃 형상(배치·축)은 예외 — design-ref 시안이 근거다**(implementation-flutter).
> (:39 보강) '구조 결정'은 *분해*(view/section/widget·파일 배치)이지 *레이아웃 형상*이 아니다 — 명세가 축·배치를 안 적은 것은 정상이며(코퍼스는 형상 미규정) **반송 사유가 아니다.** 형상은 design-ref에서 가져온다. 반송하는 '구조 결정 부재'는 *분해/파일 목록*의 공백뿐이다.

**㉣ architecture-ui §8:116 (재작성):**
> **형상과 직교**: 이 규율은 *절대 크기*만 다룬다. 요소의 *배치·축*은 코퍼스가 규정하지 않는다 — design-ref 시안이 형상 근거이고 coder가 재현한다(implementation-flutter). 크기='얼마나 큰가', 형상='어떻게 놓이나' — 둘은 직교하며 후자는 코퍼스 밖(시안)이 소유한다.

**㉤ design-architect.md:39 (area-tree 제거 자리):**
> 레이아웃 형상(배치·축)은 명세에 적지 않는다 — coder가 design-ref에서 재현한다(architecture-ui §8·implementation-flutter). 너는 분해·토큰·이미지·내비까지.

**㉥ codex 미러 특수(형상엔 HTML, notes.md 아님):**
> codex coder/architect 규칙에 — 형상 근거는 `notes.md`(치수·색·요소목록·축 없음)가 아니라 **HTML 시안**이다(텍스트라 codex가 직접 읽음). notes.md는 값 보조, HTML이 형상 SoT.

## 7. 완전성 — 새 게이트 없이

nav·장식이미지 누락 방지(IR이 하던 부수 이득)는 세 장치가 흡수한다:

1. **HTML 충실 재현**: `<nav>`·`<img>`가 HTML에 있으므로 충실 재현하면 안 빠진다. PRE가 빠뜨린 건 IR 부재가 아니라 *HTML이 "시각 근거"로 격하*돼서였다 — 형상 SoT로 승격하면 누락이 사라진다.
2. **review-ui design-ref 대조**(`design-review-ui.md:30`, *이미 존재*): "디자인에 있는 요소가 분해에서 빠졌나" — 설계 시점 부품 완전성 점검.
3. **사용자 육안**: 최종 확인.

→ 새 게이트 0. IR의 완전성 역할은 기존 장치로 대체된다.

## 8. 정합성 점검 결과 (왜 이렇게 — 2026-06-22 전수 grep)

- **[치명·교정] `extract_layout.dart` 삭제 금지**: `fid-gate.sh:14,33`이 직접 호출해 자기 `ref-layout.json`을 만들고 측정 서브시스템 전체가 layout-ir 스키마에 묶임. **생성측만 un-wire**(FID 게이트는 생성 파이프라인 `layout-ir.json`과 독립·자가생성)하면 게이트 무손상. → 스크립트·서브시스템 보존.
- **[경계·해소] "디자인툴 코드 직수입 금지"**(`design-architect.md:21`·codex `dddart/SKILL.md:145`): ㉠에 carve-out 명시로 충돌 제거(형상 재현 ≠ 코드 복붙).
- **[carve-out·해소] "명세가 단일 근거"**(`coder.md:15`): ㉢로 "형상만 예외" 명시.
- **[무해] codex 정합**: codex는 이미 HTML 텍스트 우선(`dddart/SKILL.md:23·142`·architect `:20`) — 새 규칙이 강화. ㉥로 "형상엔 HTML"만 못박음.
- **[무해] "골격" 중의성**: 제거 대상은 *layout L1 골격*(design-architect·review-ui·commands)만. discipline-houserules의 *"골격 완비"(4계층 폴더)*·coder의 *"구조 결정"(분해)*은 다른 개념 — 불가침.
- **[future-flag] 측정 서브시스템**: 같은 축맹 layout-ir 스키마라 *축을 못 잼*. 9차부터 한 번도 발동 못 함(`screenProbes` 미노출). 운명(축 보강 vs 영구 폐기)은 **별도 측정 설계**. 이번엔 육안이라 보류.

## 9. 양판 미러 계획

- **auto(`corpus_mirror_sync.py --write`)**: `architecture-ui/references/final.md`·`implementation-flutter/references/final.md`(소스→codex 동기).
- **수동**: `agents/{coder,design-architect,design-review-ui}.md` → `codex-dddart/skills/{dddart-coder,dddart-design-architect,dddart-design-review-ui}/SKILL.md` / `commands/dddart.md` → `codex-dddart/skills/dddart/SKILL.md`.
- **불변**: `scripts/extract_layout.dart`(미변경·미러 불필요).
- **세 번째 사본 확인**: `architecture-ui §8` 문구는 `workspace/reference/architecture-ui/reference/final.md:127`에도 존재(`480eb11`이 함께 수정). `corpus_mirror_sync` 적용 범위인지 plan에서 확인 — 아니면 수동 동기 대상에 추가.
- **재확인**: 시술 후 앵커 문구 grep으로 양판 대칭 + 잔존 `layout-ir`/area-tree 생성측 참조 0 확인(eval 측·`workspace/reference` 참조 처리는 위 확인 결과대로).

## 10. measure-first — 육안 체크리스트 (feedback-015 사전등록)

다음 라이브런 *후* 사용자 눈이 대조할 예상 효과(시술 *전* 사전등록):

| 항목 | 13차(전) | 14차 기대(후) |
|---|---|---|
| claude detail 메트릭 섹션 | 가로 `Row` ✗ | **세로(시안 grid-cols-1)** |
| codex 메트릭 카드 내부 | 가로 `Row` ✗ | **세로(시안 flex-col)** |
| codex hero 기온(최고/최저) | 세로 `Column` ✗ | **가로 baseline** |
| codex 앱바 | 슬라이버 스크롤 이탈 ✗ | **고정(시안 sticky)** |
| 프레임 이득(nav·이미지·maxWidth·아이콘120) | 있음 ✓ | **유지(회귀 없음)** |
| 신규 축 뒤집힘 | — | **0(coder가 HTML 재현)** |

겨냥 안 한 dim 실측: 분해·토큰·자산·치명18은 불변 기대(생성측 형상만 손댐).

## 11. 리스크·잔여

- **coder 변동성 잔여**(적대검증): 형상 SoT를 HTML로 되돌려도 LLM이 가끔 틀릴 수 있다. 자동 게이트가 없으므로(육안) — 육안 체크리스트(§10)가 안전망. 재발 시 measure-first 폐곱으로 다음 처방.
- **codex HTML 판독**: 이미지 비보장이나 HTML은 텍스트라 안전 — 단 codex coder가 design-ref/HTML을 *실제로 읽는지* 14차 육안으로 확인(notes.md만 보고 형상 흘리면 ㉥ 미흡 신호).
- **측정 부재**: 이번 라운드 자동 회귀 포착 없음(육안 의존). FID 서브시스템 운명은 별도 설계로 미룸.

## 12. 비목표 (out of scope)

- 측정 서브시스템(FID 게이트·`screenProbes`) 재작성·삭제 — 별도 설계.
- `layout-ir` 어휘에 축 토큰 추가 — **공리가 기각**(어휘 확장도 코퍼스 형상 소유·다음 미토큰에서 또 샘).
- 값 운반(색·크기·아이콘·이미지) 변경 — 작동 중·형상과 직교.
