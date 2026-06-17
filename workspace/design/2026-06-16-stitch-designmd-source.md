# dddart — 디자인 MCP(Stitch) designMd 출처 통합 설계

> 2026-06-16. feedback-007(Stitch 사용 스킬) 트랙. 대상 = `dddart/commands/dddart.md` Phase 0 + `codex-dddart/skills/dddart/SKILL.md` 미러 + `scripts/` + config 스키마 + 하니스 권한.
> **이 문서는 설계만이다 — 코퍼스 *적용*은 별도 사용자 승인(코퍼스 불변 방침).**

## 1. 배경 — 무엇이 사실이고 무엇이 미검증인가

- **6런 연속 Stitch 미사용은 코퍼스 버그가 아니었다**: 사용자 100% 확인 — 그 런들의 세션에 Stitch MCP가 **부재**했다(설정 미연결). 코퍼스는 스펙대로 "출처 없음 → 조용한 자체설계"로 흘렀다(`dddart.md:112`). 즉 근인은 코퍼스가 아니라 **런 절차(미연결)**였다.
- **2026-06-16 양엔진 연결 완료**(Claude Code user 스코프·Codex config.toml). 그러나 **연결된 경로(Stitch가 붙은 상태에서 Coordinator가 실제로 쓰는 거동)는 0회 테스트.**
- **실측으로 새로 안 사실**(읽기 전용 `list_projects` 호출):
  - 모든 Stitch 프로젝트는 **`designTheme.designMd`(디자인 시스템)를 항상** 가진다. **화면(screenInstances)은 있을 수도 없을 수도** 있다(`PROJECT_DESIGN` 타입은 화면 0, `TEXT_TO_UI_PRO`는 화면 보유).
  - designMd 안의 토큰(색·타이포·간격)은 **`designTheme.namedColors`·`typography`·`spacing`으로 이미 구조화 JSON**으로도 반환된다 → LLM/YAML 추출 없이 기계 절단 가능.
  - `list_projects` 한 번이 **모든 프로젝트의 designMd 전문을 인라인**으로 쏟는다(수천 토큰) → 컨텍스트 관리 필요.
  - Stitch 도구는 13종이고 그중 10종은 **사용자 계정에 쓰기/생성**(`generate_screen_from_text`·`create_project`·`edit_screens`·`update_design_system`·`upload_design_md` 등).
- **현 파이프라인의 사각**: `extract_design.dart`는 **HTML 전용**(`<script id="tailwind-config">` 파싱·HTML 없으면 exit 1). 화면 없는 design-only 프로젝트를 고르면 **추출 0 → `has_stitch_html=false` → 자체설계**. 정작 디자인 시스템(designMd)이 있는데 못 먹는다.

## 2. 목표 / 비목표

**목표**
1. **designMd(디자인 시스템)를 항상 읽어** 토큰으로 절단 — 화면 유무와 무관하게 디자인 출처를 활용.
2. **출처 해소를 명시적 G0 상호작용으로** — 0개/1개/2개+ 연결 상태별로 사용자에게 묻고, 자체설계도 *조용히* 빠지지 않고 배너에 표면화.
3. **내용은 매 실행 갱신** — 출처 주소만 저장하고, designMd 내용은 변경 시 로컬 사본 갱신(읽기 쪽 refresh).
4. **MCP는 무조건 읽기 전용** — 쓰기 도구 호출을 코퍼스 + 하니스 권한 두 겹으로 차단.

**비목표(이번 범위 아님 — 미룸)**
- Figma MCP의 *실제* 어댑터 구현(탐지·질문 흐름은 일반화하되, Figma 데이터 모양 대응은 실물 연결 시).
- designMd의 라인 단위 diff/additive-델타 엔진(변경 감지는 `updateTime` 비교로 충분 — 아래 4.4).
- 화면을 designMd로부터 *생성*하거나 Stitch에 *역기록*(읽기 전용 원칙과 정면 충돌).
- `lib/design_system/` Dart 코드의 자동 생성(coder 책무 유지 — 아래 3-C).

## 3. 핵심 결정

### A. 디자인 출처 = "시스템(designMd)" + "화면 시안(HTML)" 두 종류, 둘 다 내용은 가변
- **designMd = 디자인 시스템**(색·타이포·간격·모서리·컴포넌트 규칙). 앱 전체가 공유 → 일관성의 뿌리. 모든 프로젝트에 항상 존재.
- **화면 HTML = 이 기능의 구체 레이아웃**. 기능별 선택. 있으면 충실도 게이트의 비교 대상, 없으면 토큰만.
- **"고정된 층"은 없다**: 저장하는 것은 *출처 주소*뿐이고, designMd·화면 내용은 **매 실행 다시 읽어 최신화**한다(사용자 지적 반영 — 디자인 시스템도 변할 수 있음).

### B. 저장하는 것은 "주소"뿐, "내용"이 아니다
- config.json에 **출처 포인터**만 저장(어느 MCP·어느 프로젝트). openapi_url을 한 번 정해두는 것과 동형.
- 내용(designMd·designTheme JSON·추출 토큰)은 **아티팩트 스냅샷**에 동결 — 매 실행 재-pull로 갱신.

### C. `lib/design_system/` Dart는 coder가 쓴다 (designMd를 코드로 직변환하지 않음)
- 이유: ⓐ 브라운필드(기존 앱에 design_system이 이미 있을 수 있음 — 덮어쓰기 위험) ⓑ coder 책무 중복 ⓒ 규율·백스톱 게이트 우회. designMd 토큰+의도는 *참고*로 architect/coder에 주고, 코드는 규약대로 생성.

### D. 읽기 전용 = 두 겹 잠금
- (소프트) 코퍼스가 읽기 5종만 호출하도록 명시.
- (하드) 하니스 권한에서 쓰기 도구 deny — LLM이 실수로도 못 부르게.

## 4. 상세 설계

### 4.1 디자인 MCP 탐지 (능동·일반화)
- **Phase 0 step 4 진입 시 가장 먼저**: Coordinator가 **자신의 사용 가능 도구 목록에서 알려진 디자인 MCP 네임스페이스**를 스캔: 현재 known-list = `mcp__stitch__*`, `mcp__figma__*`. (거대 레지스트리 불요 — 작은 목록 1개.) 카운트 → 0/1/2+ 분기(4.2)의 입력.
- 결과 = {0개·1개·2개+}. 이게 4.2 분기의 입력.
- **세션 시작 시 도구가 열거**되므로(라이브런은 새 세션) "설정 연결 = 세션 호출 가능"이 런 시점에 성립 — 별도 probe 불요(검증: 본 세션에서 도구 재열거로 `mcp__stitch__*` 노출 확인).

### 4.2 출처 해소 G0 흐름 (기존 G0 배너에 "디자인 출처" 항목 합류 — 새 게이트 신설 아님)

**(a) 첫 지정 (config에 출처 포인터 없음)**
| 연결 | 동작 |
|---|---|
| 0개 | G0 배너에 "디자인: 연결된 도구 없음 → 자체 설계로 진행할까요?"를 항목화. (로컬 이미지 경로 제공도 기존대로 허용.) |
| 1개 | 읽기 호출로 프로젝트 목록 취득 → **title·타입·화면수만** 후보로 제시(designMd 전문 인라인 금지) → "어느 프로젝트를 디자인 시스템 출처로? (또는 자체설계)" → 선택분 포인터를 config에 저장. |
| 2개+ | "어느 도구의 어느 프로젝트?"로 도구·프로젝트를 한 질문에 → 저장. |
- 선택 프로젝트에 **화면이 있으면** 이어서: "이 기능 화면으로 쓸 시안? (고르기 / 없이 진행)" — 화면 0이면 이 질문 생략.

**(b) 재사용 (config에 포인터 있음)** — 시스템 출처는 **안 묻는다**.
- 포인터의 프로젝트를 읽기 호출로 재-pull → `updateTime` 비교(4.4) → 변경 시 스냅샷 갱신.
- G0 배너 정보 1줄: `디자인 시스템: <title> (<MCP>) · 변경없음 | 변경 감지→갱신함`.
- 화면 시안만 이번 기능에 맞게 다시 가볍게 선택(프로젝트에 화면이 있을 때).
- "디자인 출처 변경"을 **항상 선택지로 열어둠**(강제 아님).

**(c) 명시 원칙 — 자체설계·끊김도 침묵 금지**
- 모든 경우 G0 배너에 "디자인 출처" 한 줄 필수:
  - `디자인: 자체 설계 (연결된 도구 없음)`
  - `디자인 시스템: 심플 주간 날씨 예보 (Stitch·변경없음) · 이번 화면: 시안2`
  - `디자인 출처 해소 실패 — 포인터 MCP가 이번 세션에 없음 → 보관 스냅샷 사용 / 자체설계` (연결 휘발·미연결을 자체설계와 구별)

### 4.3 토큰 추출 (v2 — 결정적 토큰 + LLM-해석 의도, *정직하게 분리*)

> v2 정정(적대리뷰 실측): 구조화 JSON ≠ 사용자 브랜드 색이고, 충실도 핵심 규칙은 산문 전용이라 "LLM 추출 0"이 designMd엔 성립 안 한다. 두 부분을 솔직히 가른다.

**경로 1 — designMd(시스템)**: `get_project`(포인터 1개) 응답을 동결 후 처리.
- **동결**: `designTheme`(구조화)를 `designtheme.json`으로, `designMd`(산문 포함 전문)를 `design.md`로 그대로 파일에 떨군다. *왜 동결* — context에서 손으로 값 베끼기 = LLM 추출(feedback-005가 제거). 큰 응답을 파일로 떨궈 컨텍스트 오염도 함께 차단(skill-creator 지적 — "인라인 금지"가 아니라 "파일로 동결 후 메타만 사용").
- **결정적 토큰**(스크립트 — `extract_design.dart`에 `--from-theme` JSON 모드 추가로 머지/정렬/출력 코드 재사용):
  - **색은 `overridePrimaryColor`·`overrideSecondaryColor`·`overrideTertiaryColor`·`customColor`(=사용자 지정 브랜드 색)를 1순위**로 뽑는다. `namedColors`(Material 톤 파생 50여 토큰·snake_case)는 **그대로 `colors`로 흘리지 않는다** — 핵심(primary/secondary/tertiary/surface/background/error)만 화이트리스트, 나머지 fixed/container 변종은 `extendedColors`로 분리하거나 생략(아니면 review-ui 충실도가 50개 미매핑 잡음). **브랜드 색 ↔ namedColors ↔ 산문 색 불일치는 경고로 표면화**(extract_design 기존 "값 불일치 경고" 패턴 재사용). 화면 HTML(경로2)이 있으면 그게 색의 최종 결정자.
  - `typography` → `typography`, `spacing` → `spacing`(이건 구조화가 신뢰 가능).
  - 모서리: 구조화엔 `roundness`(enum) + granular `rounded:`(sm/md/lg/full)는 designMd YAML 머리말에만 → enum 1차, granular 필요 시 머리말 `rounded:` 블록만 표적 파싱.
- **LLM-해석 의도**(결정성 주장 *철회*): 산문(`## Components` — 카드 98% 축소·그림자 Blur20/Y4/4%·리스트 12px·2pt 라인아트·무테두리 입력·weight 위계)은 토큰화 불가 → architect에 **"설계 의도 메모"로 전달**(참고 입력·결정적 아님). 목표1을 "토큰은 결정적, 컴포넌트 의도는 참고"로 정정.

**경로 2 — 화면 HTML(레이아웃)**: 기존 `extract_design.dart` HTML 모드 그대로(`get_screen` htmlCode 동결 → 색·타이포·간격·아이콘·임의값). **변경 없음.** 화면이 있으면 색·레이아웃의 최종 진실.

**합성**: 시스템 토큰(경로1)은 architect에 항상 전달. 화면 시안(경로2)이 있으면 그 색/아이콘/레이아웃이 *우선*하고 충실도 시각대조 발동. 화면 없으면 시스템 토큰 + 산문 의도만(시각대조 대상 부재 → 게이트는 토큰 일치만, 4.4 플래그 분리 참조).

**exit 의미(정정)**: HTML 모드의 exit 1 = "HTML 없음 = 시안 미반영(발견)"은 *유지*. `--from-theme` 모드는 exit 1 의미가 다르다(theme JSON 비었거나 파싱 실패만 실패 — "화면 HTML 없음"은 정상). **모드별 exit 의미를 스크립트 주석·코퍼스에 명시**(같은 바이너리지만 모드 분기로 의미 분리, extract_design.dart `:11~12` 주석을 모드-한정으로 수정).

### 4.4 저장 구조 · 변경 감지 (v2 — 공유 스냅샷 폐기·기능 폴더 동결)

> v2 정정(정합+YAGNI 수렴): `.dddart/design-system/` 공유 폴더는 폐기한다. ① `ls -d .dddart/*/`(`dddart.md:115`)가 그걸 가짜 기능 폴더로 잡아 폴더 타임라인 모델 오염 ② 매-실행 재-pull 갱신본이 Phase 2 진입 커밋(`:131`)·중단복구(`:139`)의 git 앵커 밖에 떠서 어느 커밋에 묶이는지 불명 ③ **일관성은 "config 핀(같은 프로젝트)"이 보장하지 별도 공유 파일이 보장하는 게 아니다.**

- **config.json**(Coordinator 전속·`:34~36` 규율 유지) 스키마 확장 — **저장은 *주소*뿐**:
  ```json
  { "openapi_url": "...",
    "design_source": { "mcp": "stitch", "project": "projects/2284872291805682410",
                       "title": "심플 주간 날씨 예보", "updateTime": "2026-06-16T09:25:39Z" } }
  ```
  - `:34`("키는 openapi_url 하나")·`:114`("디자인 출처는 config에 저장 안 함")·인자 절 `:16`을 **함께 개정**: "designMd(시스템)는 앱 공유라 *포인터*만 config 저장 / 화면 시안은 기능별이라 비저장" — 근거까지 바꿔 코퍼스의 '왜'가 끊기지 않게.
- **내용은 기능 폴더에 동결**(화면 시안과 같은 자리): `<산출물 폴더>/design-ref/`에 `designtheme.json`·`design.md`·`design-tokens.json`. 매 실행 재-pull이므로 기능 폴더마다 그 빌드 시점의 사본이 자기완결적으로 남는다("한 기능=한 폴더" 불변식 유지). 일관성은 모든 기능이 *같은 핀*에서 pull → 같은 토큰.
- **재-pull 실패 3분기**(v2 신설 — 삭제/휘발 happy-path 붕괴 방지. 실측: 삭제된 포인터에 `get_project` → 에러 `"Requested entity was not found."`):
  1. **프로젝트 not-found**(출처에서 삭제됨) → 배너 "포인터 프로젝트가 출처에서 사라짐 → 재선택 또는 자체설계" + 사용자 확인. (조용히 stale 사본으로 진행 금지.)
  2. **MCP 미연결**(이번 세션에 도구 없음) → 배너 "핀된 MCP 부재 → 보관 사본 사용 / 자체설계"(4.2c). not-found와 구별.
  3. **정상** → `updateTime` 비교로 진행.
- **변경 감지·표기 = 2단**(v2 정정): `updateTime`은 **재추출 트리거**로만(프로젝트 메타 변경에도 갱신될 수 있어 거짓양성 가능). 배너의 "변경됨" 표기는 **재추출한 `design-tokens.json`이 실제로 diff 날 때만**(추출이 결정적이라 비교 1회·byte-identical이면 "변경없음"). diff 엔진 불요.

### 4.5 읽기 전용 — 두 겹 잠금 (v2 — 소프트가 배포 보장·하드는 설치 안내로 강등)

> v2 정정(plugin-dev 실측·공식문서): **플러그인은 `permissions`를 배포물로 실을 수 없다**(plugin.json 스키마에 permissions 키 없음·플러그인 settings는 user/project보다 하위라 deny를 강제 못함). 따라서 하드 잠금은 *자동 배포 불가* → "사용자 수동 설치 단계"로 강등. **배포로 보장되는 건 소프트 잠금뿐** → 코퍼스 문구를 "금지"가 아니라 "유인 차단"으로 강화한다.

- **코퍼스(소프트·배포 보장·1차 방어선)**: Phase 0·경계 절에 **화이트리스트 + 이유**로 — "Stitch는 호출 가능 도구가 읽기 5종뿐(`list_projects`·`get_project`·`list_screens`·`get_screen`·`list_design_systems`). 쓰기·생성 도구는 *사용자 계정에 부작용*이라 dddart는 절대 호출하지 않는다. **화면이 없으면 *만들지 말고* 자체설계로 폴백**(generate_screen_from_text로 새는 유인 차단)." skill-creator 지적대로 올캡스 금지문 대신 *왜*로 설명·화이트리스트로 표현.
- **하니스(하드·사용자 설치 단계·2차 방어선)**:
  - Claude Code: 사용자 settings `permissions.deny`에 쓰기 10종(또는 `mcp__stitch__*` 와일드카드 deny + 읽기 5종 미적용)을 **설치 안내로 제공**. *검증됨*(공식문서): deny>ask>allow 순 평가·`mcp__stitch__*` 와일드카드·개별 도구명 모두 지원 → 미등록 신규 쓰기도구는 `ask`로 떨어져 노출.
  - **커맨드 frontmatter**: `dddart.md:6` `allowed-tools`에 현재 `mcp__stitch__*` 미등재 → 읽기 5종을 명시 추가(없으면 호출마다 ask). 두 겹 잠금의 'allow 쪽' 소관을 frontmatter로 확정.
  - Codex: `~/.codex/config.toml` per-tool 제어(playwright는 `approval_mode="approve"`). **완전 차단(disable/deny) 키는 공식문서 미확인** → 적용 전 OpenAI 문서 검증 또는 approve(승인 프롬프트)로 차선. 양엔진 *대칭* 하드 잠금은 이 검증에 달림.
- **결론(2026-06-16 갱신)**: settings deny 경로는 사용자 수동 단계지만, **플러그인이 `PreToolUse` hook(`hooks/hooks.json` matcher `mcp__stitch__.*`→`permissionDecision:"deny"`·fail-closed)을 번들하면 사용자 설정 0으로 자동 강제 가능**(공식문서 확인 — `hooks-guide`·`plugins`·`permissions`). hook deny는 allow보다 우선·플러그인 enable 시 자동 등록. **→ 하드 잠금은 "사용자 단계"가 아니라 "플러그인 번들 hook"으로 격상 가능.** 단 **사용자 결정으로 1차는 소프트락만 시도·hook 구현은 미룸**(codex hook 대칭·번들 자동등록 포맷 미검증). 소프트락 = 코퍼스 화이트리스트 + frontmatter가 쓰기 미등재(호출 시 프롬프트).

### 4.6 양엔진 미러 (v2 — 비대칭 명시·체크리스트)
- 변경 파일: claude `commands/dddart.md`(Phase 0 step 4·플래그 스키마·경계·frontmatter) / codex `skills/dddart/SKILL.md`(Phase 0 미러) — **수동 양판**.
- 신규/확장 스크립트(`extract_design.dart` `--from-theme` 모드)는 `dddart/scripts/`·`codex-dddart/skills/dddart/scripts/` **양쪽 복사**(1개로 확정 — 별도 스크립트 신설 안 함, YAGNI).
- **탐지 절은 엔진별 비대칭이라 *대칭 복사 금지***: claude=`mcp__stitch__*` 네임스페이스 스캔 / codex=`config.toml` 도구 가용성. 각 엔진 방언으로 표현.
- **codex 고유 조항과 정렬**: codex는 `notes.md` 우선·이미지 판독 보조(`SKILL.md:127·129`) 보유 → designMd *시스템 토큰*(기계추출) vs `notes.md`/화면(시각 근거) 우선순위를 양판에서 명시 분리(역할 다름 — 충돌 아님).
- **양판 체크리스트**(적용 시): ① Phase 0 step4 의도 동일 ② frontmatter 읽기 5종 동일 ③ 스크립트 경로·동작 동일 ④ 플래그 의미 동일. config 스키마·플래그는 런타임 산출이라 파일 미러 불요. settings deny-list는 엔진별 별도(4.5).

## 5. 기존 코퍼스 변경점 (v2)
- **본문은 결정만·상세는 참조 파일로**(skill-creator 비대 지적): Phase 0 step 4엔 "0/1/2+ 탐지 → 포인터 저장 → 매 실행 재-pull, 절차·토큰매핑·읽기전용 목록은 `references/design-source.md` 참조"만. 토큰 매핑·스키마·도구 목록은 **단일** 참조 파일로 이전(MCP별 분할 금지 — figma 변종 미실재라 과분리). dddart의 `scripts/` 분리 선례와 동형.
- `dddart.md:109–113`(Phase 0 step 4): "디자인 MCP 연결 시" 단일 가정 → **0/1/2+ 탐지·질문·명시 배너**로 확장. 화면 없는 design-only도 designMd로 흡수. 4.2(c) 배너·해소실패는 *신규 절이 아니라* 기존 `:73~80` 배너·`:113` 문장의 **델타**로(세션 휘발 케이스를 `:113`에 추가, 새 형식 신설 금지).
- `dddart.md:16·:34·:114` **함께 개정**: "디자인 출처 비저장" → "시스템 포인터는 config / 화면 시안은 기능별"(근거까지·4.4).
- **플래그 분리**(과적재 해소·정합+skill-creator 수렴): `has_stitch_html`(화면 HTML 존재 = *시각 충실도 게이트* 발동 신호) ↔ `has_design_tokens`(시스템 토큰 존재). designMd-only면 후자만 true → 게이트는 토큰 일치만, 시각대조 생략. `build-state.json`은 런타임 산출(미러 불요)이라 개명 비용 낮음 → **개명 진행**(미루지 않음).
- config 스키마: `design_source` 포인터 키 추가(Coordinator 전속·`:36` 하위에이전트 비접근 유지).
- 스크립트: **`extract_design.dart`에 `--from-theme` JSON 모드 추가로 확정**(새 파일 신설 안 함 — 출력 스키마 동일·중복 회피). 모드별 exit 의미 주석 명시(4.3).
- `screenInstances` 화면수 계산 시 `type==DESIGN_SYSTEM_INSTANCE`·`sourceAsset` 제외, `sourceScreen` 있는 것만(실측 오염 방지).

## 6. 미해결 · 위험 (적대 리뷰 표적)
1. **읽기 전용 강제 위치**: 플러그인이 settings 권한을 배포 가능한가? 불가면 "설치 안내"로 강등되어 *하드 잠금이 사용자 수동 단계*가 됨(소프트 잠금만 보장). Codex per-tool deny 가능 여부 미확인.
2. **`has_stitch_html` 의미 과적재**: HTML/designMd 두 경로를 한 플래그가 표현 → 충실도 게이트 발동 조건이 흐려질 수 있음(화면 없는데 토큰만 있을 때 게이트가 무엇을 비교하나).
3. **구조화 JSON vs YAML `rounded`**: granular 모서리 스케일이 충실도에 필요하면 결국 머리말 파싱 — zero-dependency 원칙과 충돌 가능.
4. **공유 스냅샷 위치**: `.dddart/design-system/`이 기능 폴더 모델·재개 앵커·중단 복구(미추적 일괄 삭제)와 어긋나지 않는가.
5. **`list_projects` 컨텍스트 폭발**: 후보 제시 시 designMd 전문 인라인을 정말 막는가(Coordinator 규율로 충분한가, 도구 응답 자체가 큰데).
6. **연결 경로 0회 테스트**: 위 전부 미검증 가정 위에 섰다 — 연결 진단 런 1회가 선행돼야.
7. **단일 프로젝트 포인터 가정**: 앱이 여러 Stitch 프로젝트를 섞어 쓰면? (openapi 단일 출처 가정과 동형 — 1차 범위 밖으로 둘지.)

## 7. 검증 방법
- **연결 진단 런 1회**(권장 선행): Stitch 붙은 새 세션에서 `/dddart`로 weather 기능 → 관찰 ① 출처 질문이 뜨나 ② `.dddart/design-system/` 채워지나 ③ 토큰 추출되나 ④ 자체설계 폴백이 명시되나.
- **읽기 전용 잠금 반증**: deny 적용 후 쓰기 도구 호출이 실제 차단되는지(positive-control류로 "차단도 되고 읽기는 통과"를 양방 확인).
- **변경 감지**: `updateTime` 갱신 전/후 재-pull로 "변경없음→재사용 / 변경→갱신" 분기 실측.
- **결정성**: 같은 `designtheme.json`에 추출 스크립트 2회 → byte-identical `design-tokens.json`.

## 8. 적대 리뷰 반영 (4렌즈 — 2026-06-16)

skill-creator · plugin-dev(claude-code-guide) · 정합/통합 · YAGNI/적대 4렌즈 병렬 리뷰. 합성은 메인 루프.

**verdict 종합**: 골격(주소만 핀·매 실행 refresh·읽기 전용 방향·두 층)은 4렌즈 모두 정당 판정. 그러나 **실측 기반 blocker가 설계 핵심 가정을 깸** → v2로 정정.

**반영(folded) — blocker·수렴 major**:
1. **구조화 색 ≠ 브랜드 색**(YAGNI 실측: `namedColors.primary`#005da7 ≠ `overridePrimaryColor`#4a90e2 ≠ 산문 Sky Blue) → 4.3: override/customColor 1순위·namedColors 화이트리스트·불일치 경고·화면HTML이 최종 결정자.
2. **충실도 규칙 전부 산문 전용 → "LLM 추출 0" designMd엔 불성립**(YAGNI 실측) → 4.3: 토큰=결정적 / 컴포넌트 의도=LLM-해석 참고로 정직 분리, 목표1 정정.
3. **삭제/휘발 포인터 happy-path 붕괴**(YAGNI 실측: 삭제 프로젝트 `get_project`→`"Requested entity was not found."`) → 4.4: 재-pull 실패 3분기(not-found/미연결/정상) 신설.
4. **`.dddart/design-system/` 공유 스냅샷 폐기**(정합 blocker 2건 ∧ YAGNI major 수렴: 폴더모델 오염·git앵커 불명·일관성은 핀이 보장) → 4.4: 기능 폴더 `design-ref/` 동결로 환원.
5. **`has_stitch_html` 과적재 → 플래그 분리**(정합 major ∧ skill-creator minor) → 5: `has_stitch_html`(화면=시각게이트) ↔ `has_design_tokens`(토큰). 개명 진행.
6. **하드 잠금 배포 불가**(plugin-dev 공식문서: plugin.json permissions 미지원) → 4.5: 소프트(코퍼스 유인차단)가 배포 보장·1차 방어선, 하드(settings deny)는 설치 안내. deny>ask>allow·와일드카드는 검증됨.
7. **본문 비대**(skill-creator) → 5: 상세를 `references/design-source.md` 단일 파일로, 본문은 결정만. 배너는 기존 라인 델타로.
8. **추출기 중복**(YAGNI) → 5: 새 파일 대신 `extract_design.dart --from-theme` 모드로 확정.
9. minor: 화면수에서 `DESIGN_SYSTEM_INSTANCE` 제외 · namedColors 50토큰 화이트리스트 · updateTime은 트리거만(배너 "변경됨"은 실제 토큰 diff 시) · 4.1 step-귀속 · frontmatter 읽기5종 명시.

**정당(방어)**: 주소만 config 저장+매 실행 refresh(openapi 동형) · 읽기 전용 *방향*(쓰기 10/13종·"없으니 만들자" 유인 실재) · 단일 포인터·diff엔진 미룸(YAGNI 정답).

**잔존 미해결(적용/검증 전 필수)**:
- **연결 경로 0회 테스트** — 위 정정 전부 미검증 가정. 연결 진단 런 1회가 선행(§7).
- **Codex per-tool 완전 차단 키 미확인** — 양엔진 대칭 하드 잠금은 이 검증에 달림.
- **산문 의도의 LLM 해석 폭** — feedback-005가 줄인 LLM 재량이 산문 경로로 일부 복귀. 화면 HTML 있을 때만 결정적이라, designMd-only 기능의 충실도는 본질적으로 인간 오라클 보조(E3 비측정 방침과 일관).
- **트리비얼 채널은 디자인 출처 해소 미적용**(정합 minor) — 직접 편집 채널이라 designMd 갱신 반영은 수정/풀 모드에서만(한계로 명기).
