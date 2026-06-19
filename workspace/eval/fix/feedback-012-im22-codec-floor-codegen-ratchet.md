# fix 012 — IM22 backstop 버그·codec-token 기계 floor·.g.dart 래칫 구멍 (사전등록형·적대 4차 반영)

> **트리거**: 9차 claude IM22 false-positive 토끼굴(2시간 표류 미완)·codex 완주. RCA(적대 검증 거침)·적대 리뷰 4명·feedback-010 통합. **상세 설계·근거·미확정 = `workspace/design/2026-06-19-im22-rabbithole-remediation-plan.md`(확정 v2)**.
> **결정 원칙**: 이 프로젝트 자체 데이터(feedback-010 N=2~3)가 "코퍼스 산문 취약·기계 floor 엔진불변 홀드"를 입증. 처방 무게중심 산문→기계.
> **재발견**: date 직렬화 misplacement는 7차(navigator)→8차(view)→9차(common→IM22) **3연속 진동**. feedback-010 §72 "기계화 승격(미해결)"의 실행이 이 회차.

## 메타
- **회차**: 012
- **트리거**: 9차 양판(`~/Desktop/dddart-run/dddart-20260619-1435-{claude,codex}`)·RCA(적대 1차)·수정 계획 적대 4명(2026-06-19)
- **베이스 코퍼스**: `9afa6f0`(현 HEAD)
- **검증 런**: 10차(양판)
- **상태**: **R1~R5 시술·검증 완료(2026-06-19)·양판 미러**. R6 선결 대기·R7 후속. `run_fixtures.sh` 26/26 PASS·회귀 0. (시술 결과 절 참조)

## 교정 항목 (사전등록 ①~④ · 수정/10차 후 ⑤~⑥)

| # | 우선 | ① 대상 | ② 근거 | ③ 처방(파일·양판) | ④ 예상효과 | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| **R1** | 필수(R2 묶음) | IM22 router 허용목록 **common 누락**(false-positive) | allowlist(default-deny) 비대칭 — IM21(denylist)은 navigator→common 암묵통과·houserules §5(common은 domain만 예외) | `check_imports.dart:212` `t.startsWith('common/') ‖` 추가 + 메시지:217 갱신 · 양판 · houserules §5/§3.7 매트릭스 router→common 명문 · fixture 추가 | router→common BLOCK→PASS · router→infra 여전 BLOCK · **9차式 IM22 토끼굴 트리거 제거** | — | 10차 |
| **R2** | 필수·핵심 | router/nav가 직렬화 codec **직접 보유**(7차 nav `DateFormat`·진동 floor 부재) | feedback-010 ⓓ "기계화 승격(미해결)" · 산문 3회 무효(§72) | `check_imports.dart` 신규 규칙(IM23): router/nav에서 `package:intl/` import + `DateFormat(`/`toIso8601String(` 토큰 차단(IM1 `e.uri`+IM14 `scanTokens`·added줄 게이트) · **단순 String 전달은 통과**(feedback-010 §47 과대범위 교정) · 양판 | raw 직렬화 in nav/router 기계 차단(7차式 재발 floor). **⚠️한계: codec을 common 거주+호출하는 9차式은 미적발**(R1이 합법화·차선이나 작동) · positive-control로 과대범위 검증 | — | 10차 |
| **R3** | 필수·신규 | `.g.dart` 수기편집이 **analyze 사각**(houserules §147 `exclude:**/*.g.dart`) | 9차 2시간 표류 직접 원인(green 래칫이 수기편집 미적발) | codegen 게이트(Coordinator §6.2.1)에서 `build_runner` 재생성 후 `.g.dart`/`.freezed.dart` git-clean 검증·수기 hunk면 fail | 수기편집 `.g.dart` 표면화·표류 차단 | — | 10차 |
| **R4** | 보조 cheap | `.g.dart` 수기편집 금지 산문 부재 | R3 reinforcement | `implementation-riverpod` codegen절 or `coder.md:40`(+codex 번역) 1줄 | non-load-bearing | — | — |
| **R5** | 강등 | ~~carrier 산문~~ | feedback-010 산문 무효(3회) | **P2 폐기** · R2가 기계로 흡수 · §3.72에 1문장 non-load-bearing(§126 `isStale(DateTime now)` 정당 케이스 보전) | — | — | — |
| **R6** | 재겨냥 | 런중 재설계 차단 actor | 체크포인트=Coordinator(§6.2.1)·coder 아님 | Coordinator가 green 커밋 슬라이스 런중 재설계를 git diff로 표면화 · **선결: 9차 §6.2.1 실태 확인** | — | — | 10차 |
| **R7** | 후속·별도 | 허용목록형 규칙 클래스(NM9·NM13·IM5) | IM22 동일 false-positive 클래스 | 별도 회차 감사 | — | — | — |

- **버림**: 초안 P2(산문·3회 실패)·P4 원형(carrier 타입탐지=타입추론 필요·불가)·P3 원형(actor 오류).
- **R1+R2 = do both or neither**(R1만 하면 raw 직렬화 floor 없이 IM22만 풀려 7차式 재발 무방비).

## measure-first / 검증 (10차·사전등록)
- **R1**: positive-control 회귀 0 + `run_fixtures.sh`에 router→common PASS / router→infra BLOCK fixture.
- **R2**: router/nav의 `DateFormat`·`intl` import 케이스 FAIL + 단순 String 전달 PASS(positive-control 과대범위 반증). 7→8→9 진동 차단 실측.
- **R3**: 수기편집 `.g.dart` 케이스 게이트 차단 실측.
- N=1 → ≥2 런 확정.

## 시술 결과 (2026-06-19 — R1~R5 완료·검증·양판)
- **R1 ✅** `check_imports.dart:212` common 허용 1줄 + 메시지(:217)·양판 diff 0. fixture F15a(router→common PASS)·F15b(router→infra 여전 BLOCK). **houserules 수정 불요** — §5(`discipline-houserules/references/final.md:206`)의 "common 전 계층·domain만 예외"가 이미 router→common 허용(매트릭스 BC루트 행에 common 열 없음 = 본문 전계층 규칙 적용). R1은 러너를 houserules에 맞춘 버그 수정(코퍼스↔러너 정합 회복·초안 "동반 명문화"는 불요로 정정).
- **R2 ✅** 신규 IM23 — import(`package:intl/`)+토큰(`DateFormat(`·`toIso8601String()`) 차단·양판·규칙 수 주석 23종. fixture F16a/b(차단)·F16c(단순 String 통과·과대범위 반증). **한계 유지**: codec을 common 거주+호출(9차式)은 미적발(R1이 합법화·차선이나 작동).
- **R3 ✅** `dddart/commands/dddart.md:158`·codex `skills/dddart/SKILL.md:173` 빌드 게이트에 "codegen 재생성 후 `.g.dart`/`.freezed.dart` `git diff` 검증"(Coordinator의 coder 독립 재검증·§147 analyze 사각 보전)·양판. *완전 스크립트 자동은 아니나(백스톱은 build 미수행) Coordinator 빌드 게이트 절차라 coder 자기보고보다 상위 검증.*
- **R4 ✅** `dddart/agents/coder.md:40`·codex `skills/dddart-coder/SKILL.md:37`에 ".g.dart 수기편집 금지·재생성·§147 사각" 산문·양판. R3의 cheap reinforcement.
- **R5 ✅(폐기)** 초안 P2(carrier 산문) 폐기 — R2가 기계로 흡수. §3.72 추가 산문 보류(과해석 방지·적대 리뷰 3 §126 `isStale` 보전).
- **검증** `run_fixtures.sh` 26/26 PASS(F15·F16 신규·기존 F1~F14 회귀 0)·양판 diff 0. baseline `9afa6f0`.
- **양판 비대칭**: check_imports.dart=동일 cp(diff 0). R3·R4는 구조 다름(claude `agents/`·`commands/` ↔ codex `skills/dddart*`)이라 각 구조에 번역(문구 동일·grep 1:1 확인).

## 선결 / 미해결
- 9차 raw 결과/트랜스크립트 원장 부재(RCA "IM22가 트리거"가 재구성 의존) → 보존.
- §6.2.1 Coordinator 체크포인트 9차 실태(R6 — 작동 안 했으면 구현 갭).
- coder 양판 구조 비대칭(claude=`dddart/agents/coder.md` 에이전트 / codex=`dddart-coder/SKILL.md` 스킬 → diff 0 불가·각각 번역).
- RCA 미확정 1건(순환 실재 vs 자발).

## 범위 제외
- R7(허용목록 규칙 클래스 감사)·생성측 carrier 강제는 별도 회차.
