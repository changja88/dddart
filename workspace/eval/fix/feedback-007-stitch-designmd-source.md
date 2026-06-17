# fix 007 — Stitch designMd 디자인 출처 통합 (사전등록형)

> 설계 문서: `workspace/design/2026-06-16-stitch-designmd-source.md`(v2·적대리뷰 4렌즈 반영). **핵심 = 연결된 경로의 거동을 *고치기 전* 예상으로 박고, 연결 진단 라이브런으로 실측 대조.**
> **⚠️ 이 회차의 예상효과는 rubric 채점 dim이 아니다** — 디자인/시각 충실도는 rubric이 "비측정(인간 오라클·A1·`RUBRIC.md:6`·`EVAL-METHOD.md:149`)"으로 못박았다. 따라서 검증은 *프로세스 관측*(연결 진단 런의 산출물·도구호출 로그)으로 한다. rubric FAIL→PASS 아님 = "측정 근거 없는 예방적/프로세스" 처방으로 정직 표기.

## 메타
- **회차**: 007
- **트리거**: feedback-006 4차 실측(`results/20260616-0149-weather-*`)에서 **Stitch 6런 연속 미연결**로 E3(디자인 출처 활용) 발동 0 → 근인은 코퍼스 아닌 **런 절차(미연결)**로 확정(사용자 100% 확인). **2026-06-16 Stitch 양엔진 연결 완료**(상세 `stitch-mcp-connection` 메모) → **연결 경로의 코퍼스 거동이 0회 테스트**라 사용 스킬 개선.
- **베이스 코퍼스**: `a8fb2e3` (feedback-006)
- **시술 커밋**: `<미커밋 — 배포본(claude 캐시·codex skills) = working tree byte-identical 재동기 후 라이브런>`
- **검증 런**: `results/20260616-2025-weather-claude.md` + `results/20260616-2025-weather-codex.md` + `…-compare.md`(5차 연결 진단·**양판**·grader raw 각 `…-graders-raw.md`/`…-codex-graders-raw.md`)
- **상태**: 적용 완료(미커밋·green)·**연결 진단 검증 완료(양판 5/5·2026-06-17)**

## 교정 항목 (사전등록 — ①~④ 작성, 연결 진단 런 후 ⑤~⑥)

| # | 우선 | ① 대상(거동·관측점) | ② 원인(뿌리) | ③ 처방(파일·미러) | ④ 예상효과(전→후·*프로세스 관측*) | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| 1 | 권장 | designMd→토큰 추출이 결정적인가(추출 0→결정 토큰) | 화면 없는 design-only 프로젝트는 HTML 전용 `extract_design`이 못 먹음·추출 0 | `extract_design.dart --from-theme`(양판 cp) + `run_fixtures.sh` F12 | 전: design-only면 토큰 0·자체설계 / 후: `designtheme.json`→`design-tokens.json`(brandColors·colors·불일치 경고)·byte-identical 결정성. *fixture F12로 이미 green(연결 무관)* | `--from-theme`(배포 byte-identical) | ✅ **적중** — `design-ref/designtheme.json`→`design-tokens.json` 산출·`has_design_tokens=true`·foundation `AppColor`에 Stitch 색 실유입(`secondaryContainer=#FEAE2C`) = 결정성 추출 작동. *(부작용: 제한 팔레트→FC 색충돌·아래 회차요약)* |
| 2 | 권장 | 출처 해소가 능동·명시적인가(조용한 자체설계→배너 명시) | 코퍼스가 "연결 시" 단일 가정·0/1/2+ 미처리·자체설계 침묵·삭제/끊김 미분기 | `dddart.md`+`SKILL.md` Phase0 step4 재작성(탐지·0/1/2+·포인터 저장·3분기·명시 배너) | 전: 출처 없으면 조용히 자체설계 / 후: 연결 시 "어느 프로젝트?" 질문·G0 배너 "디자인 출처" 1줄 항상·삭제/끊김 구별 표면화 | Phase0 step4 재작성(양판) | ✅ **적중** — `config.json` `design_source` 핀(stitch·`projects/2284872291805682410`·updateTime `…09:25:39Z`)·`build-state.json` `has_stitch_html=true`·design-ref 채워짐(screen-list/detail.html+png+designtheme+design.md). **4차 빈 폴더·침묵 자체설계 → 5차 능동 해소 반전** |
| 3 | 권장 | MCP가 읽기 전용인가(쓰기 호출 0) | 중립 "탐색" 지시가 `generate_screen_from_text`로 샐 유인(쓰기 10/13종) | frontmatter allow 5종 + 코퍼스 화이트리스트+이유 + 경계 규율 | 전: 잠금 없음 / 후: 런 도구호출 로그에 Stitch *쓰기 도구 0회*·읽기 5종만 | frontmatter allow 5종+화이트리스트 | ✅ **적중** — transcript JSON 파싱: **Stitch 쓰기 0회·읽기 3회**(get_screen×2·list_projects×1). *주의: bare grep은 도구정의 등재로 "각2회" 거짓양성 → 실제 `tool_use` 블록 파싱으로 확정.* 읽기전용 소프트락 HELD |

- **②원인 공통**: 6런 미사용은 LLM 흘림 아니라 *연결 부재(런 절차)* + 연결 시 거동이 코퍼스에 *능동·명시로 정의 안 됨*. (feedback-005가 골격[extract_design·플래그·게이트]은 배포했으나 "연결 활성화 트랙"은 미비.)
- **③미러**: SKILL·commands·scripts = 수동 양판(완료·byte-identical 확인) / `run_fixtures.sh`·rubric = 단일 출처. `corpus_mirror_sync.py`는 `final.md` 전용이라 이번 미해당.
- **④정직 표기**: 1번만 fixture로 *기계 검증 완료*(연결 무관). 2·3번은 **연결 진단 라이브런에서만 관측 가능**(rubric dim 아님·프로세스 관측). 측정 근거 없는 예방적임을 명시 — 헛처방 조기경보.

## 적대 리뷰 반영 (적용 전 4렌즈 — skill-creator·plugin-dev·정합·YAGNI)
설계 v2 §8에 상세. blocker 정정 반영분: 구조화색≠브랜드색(둘 다 산출+경고)·산문 충실도규칙은 LLM참고(결정성 철회)·삭제/끊김 3분기·공유 스냅샷 폐기(기능폴더 동결)·플래그 분리(`has_stitch_html`/`has_design_tokens`)·하드잠금 배포불가(소프트 1차·settings deny는 설치단계).

## 회차 요약 (연결 진단 런 후 — 5차 `20260616-2025-weather-{claude,codex}` 양판)
- 예상 적중 **3/3**(프로세스 관측·**양판 공히**) · 무효 **0** · ⚠️역효과/신규회귀 **1**(색 충돌 — 연결 부수효과·**N=1×2 양엔진 동시발생**)
- **🟢 양판 교차 확정(codex 채점 2026-06-17)**: codex도 feedback-007 **5/5 프로세스 관측 성공**(design_source 핀[claude와 동일 프로젝트]·design-ref 채움·has_design_tokens/has_stitch_html=true·**Stitch 쓰기 0회·읽기 3회**[list_projects·get_project·list_screens]=읽기전용 소프트락 HELD·foundation 렌더색 #FEAE2C·#005DA7 실유입). **결정적 교차 발견 = 양 엔진이 *동일* clear=cloudy=secondaryContainer(#FEAE2C) 색충돌을 독립 산출**(2/2 연결런·같은 Stitch 제한팔레트) → 색 구별 회귀의 원천이 *엔진 아닌 코퍼스/팔레트* 시사(인과 단정 금지·동시발생). codex rubric 종합도 FC-1/FC-3(색)·FC-2(M1·M3·**M4까지** vacuous+디코이 테스트)로 FAIL(claude보다 FC-2 더 악화·FC-1/3은 만장일치).
- **한 줄 결론**: **Stitch 연결 경로 첫 발동·5/5 프로세스 관측 성공** — ①design_source 핀 ②design-ref 채움(screen HTML/PNG+designtheme+design.md) ③`has_design_tokens=true`·`has_stitch_html=true` ④G0 배너/config 출처 명시 ⑤**Stitch 쓰기 0회**(읽기 3·읽기전용 소프트락 HELD). 디자인시스템 실소비(foundation `AppColor`에 Stitch `#FEAE2C`). **단 부작용**: *제한된 실팔레트*(브랜드 색 6슬롯 미만)가 coder의 색 재사용을 유도 → **clear=cloudy 동일 `listColor`**(목록 5-distinct) = **FC-1 G-7·FC-3 N4 보수 FAIL**(4차 자체설계는 6색 distinct·G-7 PASS였음 — N=1 동시발생·인과 단정 금지). **rubric 종합은 연결과 무관하게 FC-2 vacuity로 여전히 FAIL**(M1 정렬·M3 기온위치 mutation GREEN·feedback-008 미적용).
- **결론 분리(중요)**: feedback-007의 *프로세스 목표*(연결·읽기전용·토큰 추출)는 **달성**. rubric FAIL의 원인(FC-2 vacuity·색 충돌)은 **feedback-007 처방 밖**(테스트 비-vacuity=feedback-008·색 구별=신규). 디자인 *시각* 충실도는 인간 오라클(비측정).
- ⚠️ N=1 인과 단정 금지(색 충돌은 "연결이 유발"이 아니라 "연결+제한팔레트와 동시 관찰") · 자기보고 불신(산출물·도구로그 직접 확인) · 시각 충실도는 인간 오라클(rubric 비측정).

## 미해결 (검증·후속)
- ~~연결 경로 0회 테스트~~ → **5차에서 발동·검증 완료**(1·2·3번 전부 ✅적중·5/5 프로세스 관측).
- **신규 발견(→ feedback-008/009 후보·rubric 트랙)**: ① **FC-2 비-vacuity**(목록 순서 M1·기온 위치 M3 mutation GREEN — 4·5차 반복·테스트가 값/위치 미단언) ② **색 구별 판정단위 명문화**(골든 G-7 "색 6 distinct" vs 산출물 "(아이콘,색) 쌍 distinct" — RUBRIC/golden 미명시·grader 3명 A13 만장 신고) ③ **제한 팔레트 색 충돌**(연결 디자인시스템의 의미색 슬롯 부족이 coder 색 재사용 유도 — design-ref 산문 색-의미 규칙[design.md cloudy=grey]을 coder가 어김·A1 비측정과 경계 모호) ④ M3 기온위치 4차 RED→5차 GREEN 회귀(테스트 구조 변화).
- **신규 발견은 양판 교차 확정(2026-06-17)**: ①②③④ 전부 **양 엔진 공통**(색충돌=2/2 동일·FC-2 vacuity=양쪽 M1·M3[codex는 M4까지]) → feedback-008은 *엔진 무관 코퍼스 트랙*. codex 추가: **디코이 테스트**(coder 테스트가 색 충돌을 "정답"으로 단언·TG가 색 distinct 미강제) = feedback-008 색 판정단위 명문화의 직접 근거.
- **하드 잠금** = 플러그인 `PreToolUse` hook(실현 가능 확인·미구현)·**소프트락은 5차 양판에서 HELD 입증**(claude·codex 둘 다 쓰기 0회). Codex per-tool 완전차단 키 미확인(단 실측 쓰기 0).
- 미룸: 멀티-MCP 레지스트리·Figma 어댑터 실구현·designMd 산문 의도의 기계화(불가·인간 오라클).
