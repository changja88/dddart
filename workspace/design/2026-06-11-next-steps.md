# 다음 작업 (2026-06-13 갱신 #10 — §10-4 종결)

> **상태: §10-4(저장소 골격 — 커맨드 1 + 에이전트 7종 + codex 미러) 종결.** 검증 게이트 전부 통과: 로드 스모크 Agents (7)·Skills (10, 코퍼스 9+커맨드) / **주입 수신 스모크**(coder가 frontmatter `skills:` 5종 나열 + `${CLAUDE_PLUGIN_ROOT}` 해석·undecidable.md 실 Read — dddjango 자구의 작동 실증) / **패턴 B widget test 3/3**(재탭 ① 스택 리셋·② 스크롤톱·일반 전환 — implementation-flutter §3 메커니즘 검증, `route?.subtreeContext`의 ModalRoute 캐스트 결함 발견·코퍼스 교정 전파) / **5렌즈 적대 리뷰 39건 전부 검증·교정**(P1 1: 수정 모드 무명세 경로 — G1' 강제 조건으로 해소) + 재검 1회(잔여 4건 교정·신규 모순 0) / corpus_mirror_sync 9/9 in-sync. **산출물 품질 채점 시스템 `workspace/eval/` 완비(2026-06-13 — RUBRIC 57차원(코퍼스 18에이전트+6축 적대·drop 0)·치명 17·빌드 게이트 + EVAL-METHOD v3.1 일관 채점 집행 레이어(백스톱 러너 매핑·blind 역할·항목별 결정-판정 표·FC-GOLDEN — 7렌즈 적대 리뷰 32건 전수 교정·거짓양성 0)).** 살아있는 단일 근거 5개 = 제1 규약 + 본설계 + 백스톱 설계 + 코퍼스 설계안 v3.4 + 작업장 규약.

## 즉시 할 일 — 2단계 실측 (마지막 큰 결정)

같은 기능을 **안 1**(규모 적응형 Model/View 2분할 — 본설계 §6 잠정 확정·현 커맨드 구현)과 **안 2**(행위 세로+결정적 묶기)로 비교 빌드해 본설계 §6 슬라이스 분할을 최종 확정한다. **실측 인프라 `workspace/eval/` 완비(2026-06-13)** — 착수는 그 경유.

- **인프라**: `eval/rubric/RUBRIC.md`(품질 채점 57차원 — S-DDD·S-VIEW·S-STATE·S-DATA·S-HR·BUILD·FC·TIER-Q·치명 17)·`eval/rubric/EVAL-METHOD.md` v3.1(빌드·blind 역할·결정∥의미 레인·항목별 결정-판정 표·백스톱 러너 매핑·치명 게이트·결정성 가드·§4 두 안 비교)·`eval/tools/SCENARIO-S1.md`(task verbatim·baseline·게이트 답)·`eval/tools/FC-GOLDEN.md`(공지 골든 행위표 G1~G6·mutation 3종·실행 어댑터)·`eval/rubric/rubric-metrix.md`(채점 결과지). 배경 = `2026-06-12-slice-simulation.md`(§3 두 안).
- **착수 절차**(EVAL-METHOD §0~§4): SCENARIO 동결 확인 → baseline 복제 2벌 → 안 1(원본 커맨드)·안 2(슬라이스 절 치환 사본·원본 불변)를 독립 컨텍스트로 구동 → 조정자 직접 수확(자기보고 불신) → 결과지 2장 + 비교 집계지 → 본설계 §6 확정.
- **실측 대상 = S1(신규 BC 공지·announcement BC·~13파일)**: 두 안의 갈림은 *중대형*에서만 발동(§3 — 소형·수정 모드는 1호출 축퇴 동치). S2(7+3)·S3(5+2)는 보조(형제 SCENARIO 파일).
- **두 축**: ① 산출물 품질(치명 게이트 17 PASS·TIER-Q 등급·차원 ✅❌ 차분 — 같은 RUBRIC) ② 과정 지표(coder 호출·토큰·반송·재방문 — **차분만 신호**·절대값은 환경 의존). architect·리뷰어 호출은 두 안 공통 → 차분 0.
- **픽스처**: `/tmp/dddart-w2-fixture`(channel BC green·baseline `01838bd`+Wave 누적 uncommitted → 착수 시 단일 커밋으로 굳혀 결과지에 기록·SCENARIO §2). 휘발 시 §2.1 재생성. **이 실측이 `/dddart` 첫 실전 구동(커맨드 시뮬레이션)을 겸한다** — 커맨드·에이전트 결함 발견은 그 자체가 산출.

## §10-4 산출물 지도

| 산출물 | 위치 | 비고 |
|---|---|---|
| Coordinator 커맨드 | `dddart/commands/dddart.md` (~33KB) | 본설계 §1~§7 집행 + 5렌즈 교정 반영(수정 모드 G1' 강제·미니 게이트 폐쇄·exit 1 분기·build-state 시점·재절단·시도 한도 3회 등) |
| 에이전트 7종 | `dddart/agents/` | architect(11.8K)·리뷰어 4종(4.3~4.9K)·coder(8.4K)·discipline-reviewer(9.6K ≤15K 상한) — frontmatter `skills:` 주입 실증 완료 |
| codex 미러 | `codex-dddart/` | 스킬 9 byte-exact + 커맨드·역할 스킬 7 변환(spawn/wait/close 동형·notes.md 강등·어휘 잔존 0) + README 축소표(9행) |
| sync 도구 | `workspace/tools/corpus_mirror_sync.py` | 불변식 1(작업장 본문≡배포)·2(Claude≡codex byte-exact) — 코퍼스 수정 후 `--write`로 동기 |
| 패턴 B 스모크 픽스처 | `/tmp/dddart-pb-smoke` (휘발) | widget test 3종 — 재생성: flutter create+go_router, main.dart는 implementation-flutter §3 문면 |

## 코퍼스 유지보수 메모

- 수정은 **작업장 final → awk 절단 → 배포 미러 → `corpus_mirror_sync.py --write`(codex)** 경로만. 절단 명령은 코퍼스 설계안 §5.
- 커맨드·에이전트(SKILL.md·agents/·commands/)는 sync 스코프 밖 — Claude판 수정 시 codex 역할 스킬은 변환 스크립트 재실행(git 이력 `8110787` 이후 커밋의 python 스크립트 참조), codex 커맨드는 수동 미러.
- 잔여 미확정: riverpod_lint 최소 SDK(도입 시 1회 확인) / **패턴 B 실기기 시각 확인**(메커니즘은 widget test 검증 완료 — 골격 구현 시 1회) / typeId 전역 유일 백스톱 후보 / 도메인 예외 최종 처분 경로(실전 발생 시).
- **확립 양식·충실도 계명(전 Wave 누적)**: ① 러너·구현·실물 서술은 직접 확인 후 쓴다(추정 금지) ② 실물 추종은 규약이 고장으로 진단한 지점에서 면책 아님 ③ 예제·주석에 원료 없는 규칙 발명 금지 ④ §인용은 실문면 공증 ⑤ frontmatter description에 화살괄호 금지 ⑥ 스킬명 위임은 풀네임+§번호 ⑦ 검증 발견도 검증 후 수용 ⑧ **(§10-4 추가) 스킬 예제는 컴파일 스모크가 잡는다** — subtreeContext 사례: SDK 정합 확인≠컴파일 가능, 코드 예제는 실행 픽스처로 1회 검증.

## 운영 방침 (사용자 지시 — 메모리 등재)

- **ultracode 상시 승인**: fan-out 실익 지점 자율 사용 — 고지+토큰 비용 보고. 합성은 메인 루프.
- **검수 기준 = AI 소비성**: 다렌즈 적대 리뷰+재검 1회+실행 스모크.

## 문서 지도

| 문서 | 지위 |
|---|---|
| `2026-06-11-dddart-file-tree.md` | **확정** — 제1 규약(§10-5 ①②③④ 전부 확정) |
| `2026-06-12-pipeline-design.md` | **확정·§10-4 집행 완료** — §6 슬라이스 분할만 2단계 실측 후 최종화 |
| `2026-06-12-backstop-design.md` | **확정·구현 완료** |
| `2026-06-12-skill-corpus-plan.md` | v3.4 — §10-3 종결 기록 |
| `2026-06-12-slice-simulation.md` | **2단계 실측 준비물(다음 작업의 입력)** |
| `2026-06-12-file-tree-final-review.md` | 기록 — **삭제 후보(사용자 확인 후)** |

**배포 현황**: 스킬 9/9(houserules 6.7K+30K+11K / state 4.0K+19K / data 3.7K+13K / ui 3.4K+10K / ddd 3.9K+23K / cleancode 3.6K+94K / dart 3.9K+13K / flutter 3.9K+14K / riverpod 4.0K+13K) + 커맨드 1 + 에이전트 7 + codex 미러 전체. validate·로드 스모크·sync 전부 green.
