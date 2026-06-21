# 레이아웃 강제 + 에셋 사용 — 자료조사 보고서 (2026-06-21)

> **상태**: 근거 수집 완료(6갈래 ultracode fan-out + skill-creator G5b + 적대 검증). 다음 = **brainstorming 재개**(이 보고서를 입력으로 방향 A 위에서 구체 설계). 설계 결정은 사용자와.
> **방향**: A 확정(2026-06-21). architecture-ui(설계측)에 "분해한 각 조각에 시안 크기·배치를 *연결*하라" 규율 추가 + 에셋 공급 파이프라인.
> **불변 제약**: 양판 미러(claude↔codex)·과적합 금지(weather 픽셀 코퍼스 금지)·measure-first(강제 방언은 다음 런 실측)·HaffHaff 치수 강제 모방 경계·layout-ir 픽셀 미포함 불변 보존·brainstorming HARD-GATE.
> **선행**: 계획서 `2026-06-21-layout-asset-enforcement-research-plan.md`(진실원천)·어제 자료조사 `2026-06-19-stitch-fidelity-research.md`·`2026-06-20-layout-enforce-research.md`.

---

## TL;DR (한 눈)

| 질문 | 답 (근거 갈래) |
|---|---|
| **퇴행 원인은?** | **size-link(크기연결) 줄의 부재**. area-tree는 *충분조건 아님* — codex 12차가 area-tree(크기 없는 icon slot)와 size-link를 *둘 다* 갖고 120px 충실. area-tree는 claude에서 시안 직접참조를 대체하는 engine-differential 맥락 요인일 뿐 (G1·적대검증) |
| **갭은 어디?** | **생성측**(architect). design-architect 소비 지시가 "색·spacing·아이콘"만 열거(typography·arbitraryValues 누락) + architecture-ui에 "크기→조각 연결" 절 부재. 추출·검수는 이미 크기 다룸 (G2) |
| **방향 A는 외부에서 정당한가?** | 예. design-token **component 계층**(global→alias→component)의 생성시점 구현 = "발명 아닌 연결". DeclarUI(SOTA)도 안 한 grounding 빈칸 (G3) |
| **layout-ir 손대나?** | **아니오.** 픽셀 미포함은 스키마 불변·업계 일관(Anima 절대좌표 함정). 상대기하 ⊥ 절대크기 = 직교. design-tokens 트랙에서만 크기 소비 강제 (G2·G3) |
| **에셋은?** | 소비측(AppAsset) 있음·**공급측**(URL→번들→pubspec) 빈 사슬. layout-ir이 이미 `<img>` src 추출 → Phase 0 Coordinator curl 후보 (G4) |
| **코퍼스 반영 방식은?** | **절 확장**(신설 아님). SKILL.md·agents는 미러 밖·final.md만 미러. design-architect·architecture-ui·implementation-flutter 3분담 (G5·G5b) |
| **측정은?** | 크기 자동 게이트 **현재 없음**(FID는 구조만·9차+ 미작동). measure-first 보류·positive-control 반증·비율 불변량 후보·weather 픽셀 금지 (G6) |

**핵심 한 줄**: 처방은 *새 픽셀 발명*이 아니라, 이미 기계 추출된 크기 토큰(typography·arbitraryValues)을 **architect가 분해한 조각에 연결**하도록 생성측 소비 지시를 닫는 것. 12차 codex가 자율로 한 행위를 규약으로 끌어올린다.

---

## §1. 원인 확정 (G1·G2·G6 — 내부 종단)

### 1.1 hero 상태 아이콘 크기 종단 실측표

| 차수 | 코퍼스 | claude hero 아이콘 | codex hero 아이콘 | claude spec 크기연결 |
|---|---|---|---|---|
| 8차 | (Track B 전) | **120** (`_heroIconSize = 120`) | (상세 hero 구조 상이) | ✅ §5.4-A 적층 |
| 9차 | FID 도입 | **120** (`size: 120`) | — | ✅ |
| 11차 | — | **96** (시안 120 근사·coder 직접 추정) | **120** | ❌ (없음·coder fallback이 96으로 구제) |
| 12차 | `480eb11` Track B | **32** (퇴행) | **120** | ❌ (text-[120px] 0회) |
| 시안 진실원천 | — | `text-[120px]` = **120** (design-tokens.json arbitraryValues 블록·양판 동일·★파일 전체는 HTML명 19곳 상이) | | |

- **퇴행은 12차 단일 사건.** claude는 8·9차 충실(spec에 크기연결 有) → 11차 96(연결 無·coder 직접 추정으로 구제) → 12차 32(연결 無 + area-tree가 fallback 차단).
- **갭은 "도메인에 안 묶인 크기"에 국한**: 대형 기온 텍스트(`displayTemp` 80px)는 *도메인 typography 토큰*이라 claude도 9·11·12차 내내 충실. 퇴행한 건 아이콘처럼 도메인 개념에 안 묶인 크기뿐.

### 1.2 진짜 차별자 = `size-link(크기연결) 줄의 유무` (area-tree는 충분조건 아님 — 핵심)

| 차수·엔진 | 크기연결(spec) | area-tree | 결과 |
|---|---|---|---|
| 11 claude | 없음 | **없음** | 96px (coder가 시안 직접 보고 근사 구제) |
| 12 claude | 없음 | **있음** | **32px 퇴행** (area-tree가 "구조 답"을 줘 coder의 시안 직접참조 fallback 차단) |
| 12 codex | **있음**(spec:208) | **있음**(area 트리 블록) | **120px 충실** (둘 공존 가능) |

→ **area-tree 자체는 퇴행 원인이 아니다**(충분조건 아님). codex 12차는 claude 퇴행 원인으로 지목된 바로 그 추상화(`block[icon,text]` 크기 없는 icon slot·codex design-spec L222)를 *동일하게* 갖고도, **size-link 한 줄**(L208 `text-[120px]`→size prop) 덕에 120px 충실. **진짜 차별자는 area-tree 유무가 아니라 size-link 줄의 유무.** area-tree는 원인이 아니라 "구조 답을 줘 coder가 시안 직접 참조를 덜 보게 만드는" **engine-differential 맥락 요인**(claude만 대체당하고 codex는 size-link로 자력 방어). **따라서 area-tree 제거가 아니라 빈칸 봉쇄(size-link 규율)가 정답.**

> ⚠️ **곱셈 독법 주의**(적대검증 시정): "area-tree × 크기연결 누락"을 *area-tree를 기계적 공동원인*으로 읽으면 codex 반례(공존+충실)로 깨진다. 인과는 **엔진조건부** — area-tree가 *claude 엔진에서* 시안 직접참조를 대체할 때 + size-link 부재가 겹치면 퇴행. "area-tree 자체가 크기를 소실시킨다"는 무조건 독법은 배제. 근본 처방(architecture-ui size-link 규율)은 이 반례와 정합 — codex가 자율로 메운 L208을 규약이 강제하면 claude도 메운다.

### 1.3 갭의 정확한 기제 (G2 — 줄 인용)

- **추출은 됨**: `extract_design.dart:126` `typography`·`:128` `arbitraryValues`(text-[120px] 등) 산출. 양판 동일.
- **검수도 됨**: `design-review-ui.md:31` 이미 text-[..] 검수.
- **소비만 빔**(생성측): `design-architect.md:38·44`(area 트리 + 화면 절 '명세에 담는 것') 둘 다 "design-tokens.json이 있으면 그 **색·spacing·아이콘**을 박는다" — typography·arbitraryValues 미언급. 입력 *설명*(L22)엔 '타이포·임의값'이 있으나 *박으라는 행동*(L38·L44)에서 사라짐 = **설명↔행동 불일치**가 흘림의 직접 통로(적대검증이 L44도 확인).
- **연결 자리 자체가 없음**: `architecture-ui/references/final.md:22` "3단은 **크기가 아니라** VM 보유/전속/재사용으로 가른다" — 크기를 분해 기준에서 명시 배제. 색·아이콘은 `condition`(도메인)에 묶여 §5 ui_extension이 매핑하지만 크기는 묶일 도메인이 없어 명세에 연결될 절이 없다.

### 1.4 측정 사각 (G6)

- 12차 크기 퇴행(32px)·충실(120px) 판정은 **전부 사용자 육안**이었다. grader 결과지·FID 게이트는 크기를 안 본다.
- FID 게이트는 **구조만**(L1 골격·L2 섹션·L3 슬롯). 코드 렌더 덤프(`dump_probe`)는 type/text/icon/img/tap만·width/height/px **0개** 캡처. 크기는 설계상 L4=A1(육안).
- 게다가 FID 자동 게이트는 **9차 이후 산출물에서 한 번도 작동 못함**(screenProbes 미노출·exit 3 A1 폴백). 12차 양판 모두 폴백.

---

## §2. 외부 정당화 (G3 — 디자인→코드 충실)

### 2.1 방향 A = design-token "component 계층"의 생성시점 구현

업계 표준 토큰 3계층: **Global**(원시 px·hex) → **Alias/Semantic**(의도) → **Component**(특정 요소에 스코프). Component 토큰은 "의미 의도를 *특정 요소·그 부분*에 매핑"하며 항상 semantic을 참조하고 primitive를 직접 안 본다.

→ 방향 A("추출된 크기를 위젯 조각에 연결만, 발명 금지")는 이 **component 계층을 생성 시점에 명세로 구현**하는 것. A-key("발명 아닌 연결")가 component-token 규칙("primitive 직참조 금지·semantic만")과 **1:1 대응**. 외부 검증된 메커니즘이라 부하·환각 위험 낮고 HaffHaff식 치수 강제 모방과 구분됨. (출처: Contentful design-token-system·M3 type-scale.)

### 2.2 상대기하 ⊥ 절대크기 = 충돌 아닌 직교 (다른 레이어)

- W3C DTCG(2025.10 안정판): dimension·typography 토큰은 있으나 **레이아웃/배치 타입은 없음** → 크기는 토큰화·배치는 토큰화 안 함이 표준.
- 픽셀 좌표를 *구조*에 박는 Anima 절대좌표 모드 = "픽셀충실 최고·유지보수 최악"으로 업계가 명시 기피. Anima는 fidelity(Design mode)와 maintainability(Dev mode)를 **모드 분리**로 양립.
- dddart `layout-ir-schema.md:15` "픽셀 미포함(L4는 design-tokens·눈 소관)"도 **같은 이유로 옳다**. → 방향 A는 layout-ir를 **건드리지 않고**(픽셀 계속 배제) 크기 충실을 *토큰 연결 레이어*에서 회복. 두 강제가 같은 산출물에 충돌 없이 공존(IR=어디에·순서 / 토큰연결=각 조각 몇 px).

### 2.3 DeclarUI(Flutter SOTA)도 크기 grounding을 안 한다 — 12차 실패모드를 외부가 예고

DeclarUI(arXiv 2409.11667·FSE'25·SSIM 0.68)는 구조·내비게이션·컴파일을 사지만 **폰트/아이콘/요소 치수를 추출·보존하는 메커니즘이 전혀 없다** — 치수는 MLLM이 시각 컨텍스트(이미지)에서 추론하는 데 의존. 이것이 dddart 12차 RCA와 정확히 맞물린다: **area 트리(크기 없는 'icon slot' 추상)가 coder의 시안 직접 시각 참조를 대체하면, 크기 추론의 시각 앵커를 잃어 120→32px 붕괴**(11차 area-tree 부재 시 96px=직접 추론). → 구조 IR 위에 *별도 크기 연결*을 얹는 것은 SOTA의 빈칸을 메우는 신규 기여.

---

## §3. 처방 후보 — 레이아웃 강제 (방향 A 구체화·결정 아님)

> 아래는 brainstorming 입력 *후보*. 최종 문구·경계는 사용자와.

### 3.1 생성측 소비 지시 닫기 (1순위·표적 명확)
- **design-architect.md L22·L38**: "박는다" 대상에 `typography`·`arbitraryValues`(크기) **추가**. "색·spacing·아이콘" → "색·spacing·**크기(typography·arbitraryValues)**·아이콘".
- 효과: claude가 arbitraryValues에서 shadow만 쓰고 text-[120px]를 흘린 누락을 막음. codex 12차 행위(spec:208 명시 연결)를 규약화. 12차 실측이 이 라인이 표적임을 입증.

### 3.2 architecture-ui에 "크기→조각 연결" 규율 (방향 A 본체)
- **architecture-ui/references/final.md**에 "분해한 각 시각 조각(특히 hero/대형 지배 요소)에 design-tokens가 추출한 크기를 *연결*하라" 규율. 미세 간격은 `AppSpacing`, 큰 요소는 arbitraryValues/typography size를 size/fontSize prop에 연결.
- **형태 = 전수성(triage)**: codex 패턴(arbitrary value를 1건씩 채택/기각 + 연결 위젯 명시·11차는 list 40px·hero 120px·metric 24px 전수 매핑)이 "빈칸 없음"을 만들어 coder가 흘릴 자리를 제거. 단발 hero만 다루면 다른 요소 재발.
- **분해는 상태 기준 유지** — 크기 연결은 직교 별도 규율(§1 "크기가 아니라"와 충돌 안 함).

### 3.3 layout-ir / area-tree는 불가침
- 픽셀 미포함은 스키마 불변·HaffHaff 치수 강제 모방 경계. area-tree는 유지하되 "크기 없는 slot의 크기는 §크기연결에서 메운다"는 cross-link 명문화 검토(빈칸 봉쇄).

### 3.4 범위 정밀화
- 갭은 **"도메인에 안 묶인 크기"**(아이콘 등). 도메인 typography(기온 displayTemp)는 이미 충실 → 규율은 그 빈칸만 표적.
- 연결 대상을 "모든 요소"가 아니라 **"시각적으로 큰/지배적 요소" 우선**으로 좁히는 안 검토(전 요소 px 강제 = Anima 함정 근접·over-prompting 위험).

---

## §4. 처방 후보 — 에셋 사용 방법 (G4)

### 4.1 갭 = 공급측 빈 사슬 (소비측은 이미 있음)
- **있음**(Track B 산물): AppAsset(7번째 foundation 토큰) 경로 토큰화·`Image.asset` 사용 규칙·글리프/래스터 트랙 분리.
- **없음**: 원격 시안 `<img src>` URL → 로컬 번들 다운로드 → pubspec `assets:` 선언의 **획득 파이프라인**(소유자 0). 12차 "이미지 자리만·실제 다운로드 안 함" 증상과 정확히 일치.

### 4.2 입력은 이미 준비됨
- `extract_layout.dart:209-210`이 `<img>`의 src·alt를 layout-ir image 노드로 이미 절단 → **다운로드할 URL 목록은 기계 추출 중**. curl 단계만 추가하면 사슬이 닫힘.

### 4.3 후보 설계 (결정 아님)
- **다운로드 주체 = Phase 0 Coordinator**: 이미 design-ref·openapi를 G0 승인 후 `curl -fsSL`로 동결하는 주체. `<img>` src 다운로드를 design-ref 동결에 결정론 curl로 추가(`design-ref/images/`+`has_design_images` 플래그). "LLM 추출 금지·결정론 동결" 원칙과 응집적. **결정론 강화 안**: LLM이 curl 직접 호출 vs 스크립트가 src 목록 일괄 다운로드(후자가 더 재현 가능).
- **pubspec 선언 = implementation-flutter/coder**: Flutter 공식 모범 — `flutter: assets:`에 trailing-slash 디렉터리(`assets/images/`) 선언. **함정 명시**: 디렉터리 선언은 *직속 파일만* 포함(하위디렉터리 별 엔트리). 빌드타임 번들 = `Image.asset`(Stitch CDN 수명 미보장이라 런타임 `Image.network` 직참조 회피).
- **HaffHaff 가드**: 에셋 규율은 "경로·다운로드·pubspec"에 한정·이미지 표시 *크기*는 레이아웃 강제(§3) 트랙에 둠 → 에셋(경로)과 크기 직교 유지로 치수 강제 모방 재발 차단.
- **조용한 폴백 금지**: 다운로드 실패·placeholder 구분을 G0 배너로 표면화. **라이선스 미확인 잔존**(Stitch 삽입 이미지) = brainstorming 사용자 결정 항목.

---

## §5. 코퍼스 반영 방식 (G5 claude-code-guide + G5b skill-creator)

### 5.1 절 확장 권고 (신설 아님)
| 기준 | 절 확장(권고) | 새 스킬 신설 |
|---|---|---|
| 응집도 | ✅ architecture-ui가 이미 분해·색/아이콘 매핑·토큰 사용 담음·크기는 같은 축 | ❌ 새 축 불필요 |
| design-architect 입력 경로 | ✅ 이미 architecture-ui 로드 | ❌ 새 스킬 추가 변경 |
| 코퍼스 비대화 | ✅ 한 스킬 내 세로 성장 | ❌ SKILL.md+references 관리 부담 |
| 양판 미러 | ✅ 영향 최소 | ❌ codex 쪽 대칭 신설 |

- **skill-creator 방법론(G5b)이 지지**: progressive disclosure(SKILL.md <500줄·큰 규율은 references/로) → 레이아웃 강제는 `architecture-ui/references/final.md` 절 확장이 깔끔. domain organization도 references 분리 형태.

### 5.2 양판 미러 — 시술 지점별 경로 (중요)
- **`corpus_mirror_sync.py`는 final.md만 미러**(소스 `workspace/reference/<skill>/final.md` ↔ 배포 `dddart/skills/<skill>/references/final.md` ↔ codex byte-exact).
- **SKILL.md·agents/*.md·commands/*.md는 미러 scope 밖**(단일 파일·미러 경로 없음 — 코드 라인17). → design-architect.md(agents)·SKILL.md 변경은 **수동** 양판 미러, final.md 변경은 `--write` 자동 동기.
- codex 경로는 평탄 구조(`codex-dddart/skills/…`·`codex-dddart/agents/…`).

### 5.3 3 컴포넌트 분담
| 컴포넌트 | 변경 | 미러 |
|---|---|---|
| **design-architect.md** (agents) | L22·L38 소비 지시에 크기 토큰 추가 + 명세↔layout-ir 자기점검 명시 | 수동 |
| **architecture-ui/references/final.md** | "크기→조각 연결" 절 확장(전수 triage) | `corpus_mirror_sync --write` |
| **implementation-flutter** | 영향 최소(이미 "시각 값은 foundation 토큰만" §7) + 에셋 pubspec 선언 지침 추가 검토 | SKILL.md 수동 / final.md 자동 |
- **검수측 추가 불요**: design-review-ui가 이미 검수(L31). 갭은 생성측 단일 지점 → 최소 시술.

### 5.4 writing-style 가드 (skill-creator)
- "musty MUSTs"·ALL-CAPS ALWAYS/NEVER = yellow flag. **why를 설명**하라. "예시에만 작동하는 스킬은 쓸모없다"(L298) → weather 픽셀 금지·일반 원리로. (dddart 범용 제약·G6 과적합 가드와 동일 방향.)

---

## §6. 측정·과적합 경계 (G6)

### 6.1 크기 자동 측정은 현재 없음 — measure-first 보류
- FID 게이트는 구조만·코드 덤프는 크기 0개 캡처·9차+ 미작동(screenProbes 미노출).
- 크기 게이트는 원리상 자동화 가능(`tester.getSize` RenderBox geometry로 렌더 크기 결정론 관측·screenProbes 진입점 재사용)하나 **measure-first·N=1 장벽**. 절대 픽셀 일치는 폰트 메트릭·플랫폼 차로 거짓-FAIL 양산.
- **권고**: ① 크기 게이트는 **비율/순위 불변량**(hero가 본문보다 N배·요소 간 크기 순서)으로 후보 설계(절대 px 아님). ② 게이트 신설은 보류하고 먼저 **screenProbes 미노출 근본**을 풀어 기존 구조 게이트부터 1회 작동시킨 뒤 effect-size 실측. ③ 방향 A의 *효과 자체*도 다음 런 measure-first A/B(크기 연결 ON/OFF·동일 시안·양엔진·hero 실측 px 대조)로 검증 — DeclarUI도 안 한 "Flutter 크기-grounding ablation"이라 dddart 신규 기여.

### 6.2 과적합 가드 (확립된 선례 적용)
- **weather 픽셀을 코퍼스에 박지 말 것**: 규율은 "추출 크기를 조각에 연결"이라는 범용 절차. 특정 px(120·96·6종 enum·7일)는 *증거*이지 규약 어휘 아님. 예시 px는 SCENARIO-*·positive-control 자산에 **격리**.
- **positive-control 반증**: 크기 게이트 도입 시 "등가 크기 표현(같은 비율 다른 절대값) PASS·진짜 크기 이탈 FAIL"을 사전등록형 반증 통과 전 치명화 금지(FID-L1·L2가 3선결 후 치명화된 동형 규율).
- **표본 다양성**: weather 1종 morphology 한계 명시 → 2번째 실시나리오 산출물로 false-regression 반증(이론 표본 창작 금지).

---

## §7. brainstorming 입력 — 열린 결정 항목 (사용자와)

설계 결정으로 가져갈 항목:

1. **크기 표현 단위**: 절대 px(`text-[120px]` 그대로) vs 상대 토큰명(`AppTypography.heroIcon` 같은 alias 신설)? component-token 정설은 alias이나 hero용 토큰이 없으면 신설(미러·동결 영향).
2. **연결 범위**: "모든 시각 요소" vs "큰/지배 요소만"(hero·대형 타이틀·대형 이미지). 후자가 Anima 함정·over-prompting 회피.
3. **절 위치**: architecture-ui §7(design_system 사용) subsection vs 병렬 신설 절(§8 크기 토큰 규칙)? (§5는 도메인 enum→UI 매핑 자리라 도메인 무관 크기와 의미상 안 맞을 수 있음.)
4. **에셋 다운로드 주체·결정론**: Phase 0 Coordinator curl(LLM 직접) vs 스크립트 일괄 다운로드. pubspec 디렉터리 vs 파일별 선언.
5. **에셋 라이선스**: Stitch 삽입 이미지 자동 다운로드·번들의 법적 안전성(사용자 결정 필요).
6. **측정 깊이**: 크기 게이트를 이번에 설계할지 vs measure-first로 다음 런 실측 후 결정. screenProbes 미노출 선결 의존.
7. **`text-[120px]` 의미**: 상한(max) vs 정확값(exact)? codex 표현은 "최대 크기로 채택·size prop으로 제한". 시안 px의 의미가 토큰만으로 결정 불가할 수 있음.

---

## §8. 적대 검증 결과 (3대 기둥 독립 재실측 — 완료)

적대 검증 agent가 6런 산출물·코퍼스를 직접 grep해 재실측(19 tool uses).

| 검증 | verdict | 핵심 |
|---|---|---|
| **기둥1** hero 크기 종단표 | ✅ 확정 | 6런 전수 재실측(claude 8/9/11/12차=120/120/96/32·codex 11/12차=120/120). 12 claude 32는 명확히 hero condition 아이콘(타 size는 brand_header 40·detail_metric 18). **'8차=120 vs 영역누락' 모순 아님** — hero 크기 축과 영역 구성 축은 직교(8차 hero는 충실·영역은 별개 결함) |
| **기둥2** text-[120px] 출처·소비 | ⚠️ 교정 | arbitraryValues 블록(L213-225) 양판 byte-identical(diff 0)이나 **design-tokens 파일 *전체*는 아님**(HTML 파일명 19곳 상이·sha 불일치). codex L208 연결·claude 0회는 확정. → 본문 "byte-identical"을 *arbitraryValues 블록 한정*으로 교정(§1.1 반영) |
| **기둥3** 생성측 갭 | ✅ 확정 | design-architect L22 설명(타이포·임의값 有)↔**L38·L44** 행동('색·spacing·아이콘'만) 불일치. architecture-ui 7절 크기연결 부재·§5는 색·아이콘·라벨만·L22 "크기가 아니라" 축어 일치. **design-review-ui:31 이미 text-[..] 검수 → 갭 생성측 한정 입증**(검수측 무갭) |
| **과적합** | ✅ 무혐의 | 코퍼스 권고는 "추출 크기를 조각에 연결" 범용 절차·권고에 120/hero/weather **0회**(진단 증거에만 등장). 시술계획도 "치수=시안 명시값만·HaffHaff 비채택" |
| **인과 견고성** | ❌ 부분 반증 → 시정 | **codex 12차가 area-tree(L222 `block[icon,text]` 크기 없는 icon slot — claude 퇴행 원인으로 지목된 그 추상화)와 size-link(L208)를 공존하고도 120px 충실** → area-tree는 퇴행의 **충분조건 아님**. "곱셈" framing을 **엔진조건부로 시정**(§1.2 반영). **단 근본 처방(방향 A·size-link 규율)은 반례와 정합**(codex가 자율로 메운 L208을 규약이 강제하면 claude도 메움) |

**종합**: 3대 기둥의 *실측 근간*은 확정(크기표·소비 비대칭·생성측 갭). 교정 2건은 모두 **인과 진술의 정밀화**지 처방 변경 아님 — **방향 A(architect가 조각에 크기 연결)는 codex 반례를 견디는 올바른 처방으로 재확인**. ⚠️ 전원 Claude 계열(in-family) 한계 유지.

---

## 부록: 출처 (갈래별)

- **G1 내부 종단**: 산출물 `dddart-run/dddart-{20260618-2228,20260619-1435,20260620-1206,20260620-2323}-{claude,codex}`·결과지 `workspace/eval/results/`·`git log`.
- **G2 코퍼스 정밀**: `extract_design.dart:126·128`·`design-architect.md:22·38`·`architecture-ui/references/final.md:22·71-79·103`·`design-review-ui.md:31`·`layout-ir-schema.md:15`·`app_asset.dart`.
- **G3 외부 레이아웃**: DeclarUI(arXiv 2409.11667)·W3C DTCG 2025.10·Contentful design-token-system·M3 type-scale·Anima(Design/Dev 모드)·Locofy·어제 자료조사 2건.
- **G4 외부 에셋**: Flutter 공식(`docs.flutter.dev/ui/assets/assets-and-images`·context7 /flutter/website)·`extract_layout.dart:209-210`·`commands/dddart.md` Phase 0·메모리 `stitch-image-asset-bundling`.
- **G5 메타**: `platform.claude.com/docs` agent-skills best-practices·`corpus_mirror_sync.py:8·17`·`design-architect.md:6`·skill-creator SKILL.md(G5b·progressive disclosure·writing-style).
- **G6 측정**: `RUBRIC.md:6·138·145`·`EVAL-METHOD.md:162`·`fid-gate.sh:53-58`·`dump_probe.dart.txt`·`dump_to_ir.dart`·`positive-control/fid/README.md`·메모리 `plugin-general-purpose-no-overfit`.

> ⚠️ 전원 Claude 계열 조사자(in-family). 외부 출처는 일부만 직접 fetch 확인. effect-size는 measure-first 다음 런 실측 전까지 미확정.
