# fix 012 — IM22 backstop 버그·codec-token 기계 floor·.g.dart 래칫 구멍 (사전등록형·적대 4차 반영)

> **트리거**: 9차 claude IM22 false-positive 토끼굴(2시간 표류 미완)·codex 완주. RCA(적대 검증 거침)·적대 리뷰 4명·feedback-010 통합. **상세 설계·근거·미확정 = `workspace/design/2026-06-19-im22-rabbithole-remediation-plan.md`(확정 v2)**.
> **결정 원칙**: 이 프로젝트 자체 데이터(feedback-010 N=2~3)가 "코퍼스 산문 취약·기계 floor 엔진불변 홀드"를 입증. 처방 무게중심 산문→기계.
> **재발견**: date 직렬화 misplacement는 7차(navigator)→8차(view)→9차(common→IM22) **3연속 진동**. feedback-010 §72 "기계화 승격(미해결)"의 실행이 이 회차.

## 메타
- **회차**: 012
- **트리거**: 9차 양판(`~/Desktop/dddart-run/dddart-20260619-1435-{claude,codex}`)·RCA(적대 1차)·수정 계획 적대 4명(2026-06-19)
- **베이스 코퍼스**: `9afa6f0`(현 HEAD)
- **검증 런**: 10차(양판)
- **상태**: **R1~R5+R7 시술·검증 완료(2026-06-19)·양판 미러**. **R6 종결**(선결확인: 체크포인트 작동·구현갭 없음·R1이 입구 차단). **R7**: 적대 2명 감사 → IM allowlist는 IM22 고립·NM13 fp 1건 수정. `run_fixtures.sh` **28/28** PASS·회귀 0. (시술 결과·R6 선결확인·R7 시술 절 참조)

## 교정 항목 (사전등록 ①~④ · 수정/10차 후 ⑤~⑥)

| # | 우선 | ① 대상 | ② 근거 | ③ 처방(파일·양판) | ④ 예상효과 | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| **R1** | 필수(R2 묶음) | IM22 router 허용목록 **common 누락**(false-positive) | allowlist(default-deny) 비대칭 — IM21(denylist)은 navigator→common 암묵통과·houserules §5(common은 domain만 예외) | `check_imports.dart:212` `t.startsWith('common/') ‖` 추가 + 메시지:217 갱신 · 양판 · houserules §5/§3.7 매트릭스 router→common 명문 · fixture 추가 | router→common BLOCK→PASS · router→infra 여전 BLOCK · **9차式 IM22 토끼굴 트리거 제거** | — | 10차 |
| **R2** | 필수·핵심 | router/nav가 직렬화 codec **직접 보유**(7차 nav `DateFormat`·진동 floor 부재) | feedback-010 ⓓ "기계화 승격(미해결)" · 산문 3회 무효(§72) | `check_imports.dart` 신규 규칙(IM23): router/nav에서 `package:intl/` import + `DateFormat(`/`toIso8601String(` 토큰 차단(IM1 `e.uri`+IM14 `scanTokens`·added줄 게이트) · **단순 String 전달은 통과**(feedback-010 §47 과대범위 교정) · 양판 | raw 직렬화 in nav/router 기계 차단(7차式 재발 floor). **⚠️한계: codec을 common 거주+호출하는 9차式은 미적발**(R1이 합법화·차선이나 작동) · positive-control로 과대범위 검증 | — | 10차 |
| **R3** | 필수·신규 | `.g.dart` 수기편집이 **analyze 사각**(houserules §147 `exclude:**/*.g.dart`) | 9차 2시간 표류 직접 원인(green 래칫이 수기편집 미적발) | codegen 게이트(Coordinator §6.2.1)에서 `build_runner` 재생성 후 `.g.dart`/`.freezed.dart` git-clean 검증·수기 hunk면 fail | 수기편집 `.g.dart` 표면화·표류 차단 | — | 10차 |
| **R4** | 보조 cheap | `.g.dart` 수기편집 금지 산문 부재 | R3 reinforcement | `implementation-riverpod` codegen절 or `coder.md:40`(+codex 번역) 1줄 | non-load-bearing | — | — |
| **R5** | 강등 | ~~carrier 산문~~ | feedback-010 산문 무효(3회) | **P2 폐기** · R2가 기계로 흡수 · §3.72에 1문장 non-load-bearing(§126 `isStale(DateTime now)` 정당 케이스 보전) | — | — | — |
| **R6** | ~~재겨냥~~→**종결** | 런중 재설계 차단 actor | 체크포인트=Coordinator(§6.2.1)·coder 아님 | **선결확인이 종결**: 체크포인트 작동(슬라이스 green 커밋 정확)·구현 갭 없음 | **선결확인 ✅** 9차 git log(슬1 `e9bded8`·슬2 `cefb807` green·codex 재설계 0). 토끼굴=green 이후 감사반영(`216d27f` router→common)→IM22 fp 7건→24파일 비틀기(`7178550`). **R1이 입구 차단=재발불가** | 10차 관찰: 'green→red=revert 우선' 안티패턴 R1 차단 후 재발 여부 |
| **R7** | ✅**시술** | 허용목록형 규칙(IM5·IM13·IM16·NM9·NM13) | IM22 동일 fp 클래스 | 적대 2명 감사 → NM13 둘째루프에 `go_router` import 게이트(`check_naming.dart`·IM22 R1 동형) | NM13 토큰 과대매칭 fp 제거 · IM allowlist는 IM22 고립 확인 | **28/28 PASS**(F17a 통과·F17b 차단)·양판 diff 0 |

- **버림**: 초안 P2(산문·3회 실패)·P4 원형(carrier 타입탐지=타입추론 필요·불가)·P3 원형(actor 오류).
- **R1+R2 = do both or neither**(R1만 하면 raw 직렬화 floor 없이 IM22만 풀려 7차式 재발 무방비).

## measure-first / 검증 (10차·사전등록)
- **R1**: positive-control 회귀 0 + `run_fixtures.sh`에 router→common PASS / router→infra BLOCK fixture.
- **R2**: router/nav의 `DateFormat`·`intl` import 케이스 FAIL + 단순 String 전달 PASS(positive-control 과대범위 반증). 7→8→9 진동 차단 실측.
- **R3**: 수기편집 `.g.dart` 케이스 게이트 차단 실측.
- **R7**: 실 라이브런서 NM13이 합법 코드(common util·domain VO의 `push`·`replace`)를 막지 않는지 + 진짜 라우트 리터럴은 차단 유지 관찰(fixture F17 검증 완료 → 실코드 무재발 확인).
- N=1 → ≥2 런 확정.

## 시술 결과 (2026-06-19 — R1~R5 완료·검증·양판)
- **R1 ✅** `check_imports.dart:212` common 허용 1줄 + 메시지(:217)·양판 diff 0. fixture F15a(router→common PASS)·F15b(router→infra 여전 BLOCK). **houserules 수정 불요** — §5(`discipline-houserules/references/final.md:206`)의 "common 전 계층·domain만 예외"가 이미 router→common 허용(매트릭스 BC루트 행에 common 열 없음 = 본문 전계층 규칙 적용). R1은 러너를 houserules에 맞춘 버그 수정(코퍼스↔러너 정합 회복·초안 "동반 명문화"는 불요로 정정).
- **R2 ✅** 신규 IM23 — import(`package:intl/`)+토큰(`DateFormat(`·`toIso8601String()`) 차단·양판·규칙 수 주석 23종. fixture F16a/b(차단)·F16c(단순 String 통과·과대범위 반증). **한계 유지**: codec을 common 거주+호출(9차式)은 미적발(R1이 합법화·차선이나 작동).
- **R3 ✅** `dddart/commands/dddart.md:158`·codex `skills/dddart/SKILL.md:173` 빌드 게이트에 "codegen 재생성 후 `.g.dart`/`.freezed.dart` `git diff` 검증"(Coordinator의 coder 독립 재검증·§147 analyze 사각 보전)·양판. *완전 스크립트 자동은 아니나(백스톱은 build 미수행) Coordinator 빌드 게이트 절차라 coder 자기보고보다 상위 검증.*
- **R4 ✅** `dddart/agents/coder.md:40`·codex `skills/dddart-coder/SKILL.md:37`에 ".g.dart 수기편집 금지·재생성·§147 사각" 산문·양판. R3의 cheap reinforcement.
- **R5 ✅(폐기)** 초안 P2(carrier 산문) 폐기 — R2가 기계로 흡수. §3.72 추가 산문 보류(과해석 방지·적대 리뷰 3 §126 `isStale` 보전).
- **검증** `run_fixtures.sh` 26/26 PASS(F15·F16 신규·기존 F1~F14 회귀 0)·양판 diff 0. baseline `9afa6f0`.
- **양판 비대칭**: check_imports.dart=동일 cp(diff 0). R3·R4는 구조 다름(claude `agents/`·`commands/` ↔ codex `skills/dddart*`)이라 각 구조에 번역(문구 동일·grep 1:1 확인).

## R6 선결확인 (2026-06-19 — 9차 런 폴더 git 증거)
- **체크포인트는 작동했다 = 구현 갭 아님**. 9차 claude git log: `17dc93d`(진입)→`e9bded8`(슬1 green)→`cefb807`(슬2 green=CR1 종단, 17:42). codex도 4슬라이스 Implement+Record 쌍·`8e1dd33` 종료.
- **토끼굴은 전 슬라이스 green *이후***: `216d27f`(감사 발견1 "date 단일 거주" 반영 — router→common 신설)→`0e10e54`(baseline 동결·`cycle_pairs`만)→`7178550`("blocker 7건 해소"=24파일 689+/972- 비틀기)→미커밋 표류 1h40m. **codex는 이 구간 0개**(재설계 커밋 없음).
- **RCA 코드 확정**: 미커밋 `weather_router.dart` diff(`-package:intl/`·`-DateFormat(green) → +common/util/date_path_codec` import) = router→common 실재 = IM22 트리거. 재구성→확정.
- **종결 근거**: 체크포인트 작동·구현 갭 없음 + **R1이 입구(IM22 fp) 차단 → 9차式 재발불가**. R6 산문화는 feedback-010 *산문 무효* 반복 위험. soft-reset 복구 인프라(`dddart.md:145·153`)는 abort시만 발동·blocker 대응엔 미사용 = 잔여 교훈("green→red=revert 우선")만 10차 관찰.

## R7 시술 (2026-06-19 — 적대 2명 감사 + NM13 fix·양판)
- **IM 패밀리 CLEAN**(적대 A): allowlist 4종(IM5·IM13·IM16·IM22)이 houserules §5/§6 *허용* 조항과 1:1 정합 → IM22는 고립 버그. (1차 스크리닝 오류 2건 교정: 모든 IM이 단일 게이트 클로저(`check_imports.dart:28-30`) 경유→브라운필드 fp 구조부재 · IM16 보강.)
- **NM13 fp FOUND·수정**(적대 B): 둘째 루프 정규식(`.go|.push|.replace|…`)이 수신타입 무시 + `if(!isRouter)` 트리 전역 발화 → go_router 미import 파일의 동명 사용자 메서드(`PathBuilder.push('x')`·`Slug.replace('y')`)가 위치 문자열 리터럴과 만나면 거짓양성(실측 3건). **수정**: 둘째 루프에 `ctx.edgesOf(f).any((e)=>e.uri.startsWith('package:go_router/'))` 게이트(IM22 R1 동형 — 합법성 신호). 첫 루프(GoRoute 정의)는 CLEAN이라 불변.
- **NM9·NM10·게이트비대칭 = CLEAN**(반증 실패): NM9 allowlist(자기VM+SharedState)는 architecture-state 정합·selector/family/위젯VM 통과 실측. NM은 added 파일만 순회(`check_naming.dart:81`)라 브라운필드 fp 불가.
- **검증**: `run_fixtures.sh` **28/28 PASS**(F17a go_router 미import push 통과·F17b import+리터럴 차단)·기존 회귀 0·양판 diff 0.

## 선결 / 미해결
- ✅ **해소** — 9차 claude 런 폴더(git+`.dddart`) 보존·router diff로 IM22 트리거 코드 확정(위 절).
- ✅ **R6 선결확인·종결**(위 절) — 체크포인트 작동·구현 갭 없음·R1이 입구 차단.
- coder 양판 구조 비대칭(claude=`dddart/agents/coder.md` 에이전트 / codex=`dddart-coder/SKILL.md` 스킬 → diff 0 불가·각각 번역).
- ✅ **해소** — RCA 시작 계기 = 자발 아님·감사반영(`216d27f`)+backstop fp(`7178550`)가 떠밀음(트리거 실재).

## 범위 제외
- R7(허용목록 규칙 클래스 감사)·생성측 carrier 강제는 별도 회차.
