# 다음 작업 (2026-06-12 갱신 #9 — §10-3 종결·compact 인계)

> **상태: §10-3(스킬 9종 코퍼스) 종결 — 스킬 9/9 배포·게이트 전부 통과. §10-4 착수 직전.** 살아있는 단일 근거 5개 = 제1 규약 + 본설계 + 백스톱 설계 + 코퍼스 설계안 v3.4(완결 기록) + 작업장 규약. §10-5는 ①②③④ 전부 확정(미결 0). 미반영 수정 없음(마지막 커밋 `3e237e7`).

## 즉시 할 일 — §10-4: 저장소 골격·파일 작성 (커맨드 1 + 에이전트 7종)

**착수 절차**: ① 원료 정독 — 본설계 §1(에이전트 구성·Coordinator가 직접 쓰는 것 목록)·§2(산출물·config)·§4~§7(게이트 절차 — 커맨드 본문의 뼈대)·§8(주입 프로필 표)·§10-4(제약 목록) ② dddjango 실물 정독(아래 매핑) ③ 커맨드→에이전트 순 이식·치환 ④ 검증.

**dddjango 실물 → dddart 매핑** (`/Users/hyun/Desktop/dddjango/dddjango/`):

| dddjango 실물 | 크기 | dddart 대응 |
|---|---|---|
| `commands/dddjango.md` | 31KB | `commands/dddart.md` — Coordinator. 게이트 절차는 본설계 §4~§7로 대체(트리비얼 모드·전제조건 검사·모드 삼분류 등 dddart 신설 다수 — 단순 치환 아님) |
| `agents/design-architect.md` | 27KB | design-architect — 판정 소유 라벨링·계약 위험 표기(본설계 §5-2) 추가 |
| `agents/design-review-ddd.md` | 4KB | design-review-ddd + **신설 ui·state**(동형 작성) |
| `agents/design-review-api.md` | 3KB | design-review-data(계약 스냅샷 대조 — data final §7 규율) |
| `agents/design-review-db.md` | 5KB | (소멸 — 클라 무DB) |
| `agents/coder.md` | 7KB | coder — bottom-up·codegen 규약·green 래칫(본설계 §6-2) |
| `agents/discipline-reviewer.md` | 40KB | discipline-reviewer — **~15KB 상한**(판례·변종은 references로), 판정 소유 대조 신설(본설계 §6-3) |
| `agents/acceptance-tester.md` | 4KB | (비채택 — 본설계 §1.3 흡수) |

본설계 §1·§10-4가 단일 근거. 제약·추가 사항:

1. **커맨드 1**(`commands/`): dddjango Coordinator 이식 — `argument-hint` 기존 문구, `$ARGUMENTS`에서 OpenAPI URL 추출 규칙 명시, openapi 취득은 Bash curl 기본, `.dddart/` 산출물 폴더 절차(ⓐ/ⓑ·재동결 질문), Coordinator 경계 문구는 본설계 §1의 "직접 쓰는 것" 목록으로(원문 그대로 이식 금지), `build-state.json` 스키마 정의(phase·완료 슬라이스·git 스냅샷 ref·G1 결정 로그·analyze 베이스라인).
2. **에이전트 7종**(`agents/`): design-architect / design-review-{ddd,ui,state,data} / coder / discipline-reviewer. frontmatter `skills:` 필드는 **dddjango 자구 그대로**(공식 문서화 범위 밖 — 작동 실증) + **주입 수신 스모크 1회를 작성 게이트로**. 주입 프로필은 본설계 §8 표. **17종 공유 reference 경로 주입**: §9 배정표의 1차 결정자·검증자 전 에이전트에 `${CLAUDE_PLUGIN_ROOT}/skills/discipline-houserules/references/undecidable.md`. discipline-reviewer 본문 ~15KB 상한(판례는 references로).
3. **main.dart 골격에 박을 확정 표기 2건**: `ProviderScope(retry: (c, e) => null)`(riverpod 전역 OFF — implementation-riverpod §8) · root_view 탭 재탭 2단 동작(implementation-flutter §3 — **패턴 B 실기기 스모크 1회를 이 단계에서**).
4. **codex 미러 축소표 1급 산출**(argument-hint 부재·MCP 감지 상이·이미지 입력 비보장 → 치수·색 토큰 텍스트 메모로 강등) — codex-dddart 미러·corpus_mirror_sync 포팅도 이 단계(절단 의미론: P1 절 제거·제목 서지 유지 반영 필수).
5. **검증**: ⓐ 로드 스모크 `claude --plugin-dir "$PWD/dddart" plugin details dddart` — **Agents (7)** 기대(Skills 9 유지) ⓑ **주입 수신 스모크**: 픽스처에서 Agent 도구로 에이전트 1종(coder 권장)을 호출해 "주입받은 스킬 이름과 적재 가능한 reference 경로를 나열하라" 과제 — `skills:` 필드·공유 reference 경로가 실제 도달하는지 확인 ⓒ 4렌즈(plugin-dev 중심 — frontmatter·구조) ⓓ 관통: 픽스처(tmp 휘발 시 재생성 — 절차는 코퍼스 설계안 §6-3, 기존 channel BC 픽스처 재구축은 git 없이도 coder 1회) 에서 커맨드 시뮬레이션은 §10-4 완료 후 2단계 실측이 담당.

## 이후 — 2단계 실측 (§10-3·4 완료 후 마지막 큰 결정)

같은 기능을 안 1(규모 적응형 Model/View 2분할 — 잠정 확정)과 안 2(행위 세로+결정적 묶기)로 비교 빌드(dddjango `workspace/eval/` 방식·`2026-06-12-slice-simulation.md`가 준비물). 지표: 토큰·호출 수 / 반송·복구 비용 / 발견 수·G2 통과율. 이것으로 본설계 §6 분할이 최종 확정된다.

## 코퍼스 유지보수 메모 (완결 후 — 발견 시 수정 경로)

- 수정은 **작업장 final → awk 절단 → 배포 미러 diff** 경로만(직접 배포본 수정 금지). 절단 명령은 코퍼스 설계안 §5.
- 잔여 미확정(P1 표 등재): riverpod_lint 최소 SDK(도입 시 1회 확인) / 패턴 B 실기기 스모크(§10-4에서) / typeId 전역 유일 백스톱 후보 / 도메인 예외 최종 처분 경로(실전 발생 시 결정 — ddd review E-5).
- **확립 양식·충실도 계명(전 Wave 누적 — §10-4에도 적용)**: ① 러너·구현·실물 서술은 직접 확인 후 쓴다(dddjango 원문도 — 추정 금지) ② HaffHaff 실물 추종은 규약이 고장으로 진단한 지점에서 면책 아님 ③ 예제·주석에 원료 없는 규칙 발명 금지(공백은 review/보고로) ④ SKILL·문서의 §인용은 실문면 공증 ⑤ frontmatter description에 화살괄호 금지 ⑥ 스킬명 위임은 풀네임+§번호 ⑦ 검증 발견도 검증 후 수용(렌즈 오류 전례 있음).

## 운영 방침 (사용자 지시 — 메모리 등재)

- **ultracode 상시 승인**: fan-out 실익 지점 자율 사용 — 고지+토큰 비용 보고. 합성은 메인 루프.
- **검수 기준 = AI 소비성**: 4렌즈(이식·조사형은 충실도 분할 5렌즈)+재검 1회+관통 테스트.

## 문서 지도

| 문서 | 지위 |
|---|---|
| `2026-06-11-dddart-file-tree.md` | **확정** — 제1 규약(§10-5 ①②③④ 전부 확정) |
| `2026-06-12-pipeline-design.md` | **확정** — 본설계(§10-4가 다음 집행 대상) |
| `2026-06-12-backstop-design.md` | **확정·구현 완료** |
| `2026-06-12-skill-corpus-plan.md` | **v3.4 — §10-3 종결 기록** |
| `workspace/reference/spec.md` | 작업장 규약 |
| `2026-06-12-file-tree-final-review.md` | 기록 — **삭제 후보(사용자 확인 후)** |
| `2026-06-12-slice-simulation.md` | 2단계 실측 준비물 |

**배포 현황(9/9)**: houserules(6.7K+30K+11K) / state(4.0K+19K) / data(3.7K+13K) / ui(3.4K+10K) / ddd(3.9K+23K) / cleancode(3.6K+94K) / **dart(3.9K+13K)** / **flutter(3.9K+14K)** / **riverpod(4.0K+13K)**. 전부 작업장 P1 보유판 미러 OK·validate 통과·로드 스모크 Skills (9)·placeholder 0. 관통 테스트 픽스처(/tmp/dddart-w2-fixture)는 3 Wave 누적(골격→판정 소유→표기법 analyze green)·백스톱 0건.
