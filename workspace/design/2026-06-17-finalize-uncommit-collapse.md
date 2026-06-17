# 설계 — 마무리 미커밋 합치기 (finalize uncommit collapse·옵션 B)

> 트리거: 사용자가 "파이프라인 자동 커밋 때문에 어떤 파일이 바뀌었는지 검토 후 직접 커밋하기 어렵다"고 제기 → 옵션 B 채택. **런 중에는 복구용 커밋을 유지하고, 마무리에서만 전체를 미커밋 변경분 하나로 합쳐 사용자가 검토·직접 커밋하게 한다.**
> 양판 미러: claude `dddart/commands/dddart.md` + codex `codex-dddart/skills/dddart/SKILL.md` (수동 양판). scripts·rubric 영향 없음(이 변경은 커맨드 절차만).

## 1. 배경·목표

- **현행**: 풀/수정 모드는 (a) Phase 2 진입 시 `.dddart/` 산출물 커밋(=git_snapshot), (b) 슬라이스 green마다 커밋, (c) G2 마무리 커밋을 자동 생성한다. 런 폴더(타깃 프로젝트)에 5~7개 커밋이 쌓인다.
- **문제**: 사용자의 "커밋은 내가 통제" 원칙과 충돌하고, 변경분을 *한 단위로* 검토하기 어렵다(커밋이 슬라이스별로 흩어짐).
- **목표**: 런이 끝나면 파이프라인이 만든 커밋을 **자동으로 풀어** 모든 변경을 *미커밋 한 묶음*으로 남긴다 → 사용자가 `git status`/`git diff`로 확인 후 **직접 한 번** 커밋. 사용자는 해시를 알 필요도, 명령을 칠 필요도 없다.

## 2. 핵심 설계

커밋이 떠받치는 유일한 load-bearing 기능은 **런 중 중단/재개 복구**다(마지막 green 슬라이스로 롤백). 백스톱 `--diff-base`와 채점은 *미커밋 변경분까지* baseline 대비 diff로 보므로(`common.dart:408`·fixture F1 실증) 커밋과 무관하다.

따라서:
- **런 중**: 슬라이스 커밋을 *그대로 유지* — 복구 메커니즘 무손상.
- **마무리(Phase 3, G2 승인 직후)**: `git reset --soft <런 시작 직전 HEAD>` 1회로 파이프라인이 만든 모든 커밋(산출물·슬라이스·마무리)을 풀어 단일 미커밋(스테이징된) 변경분으로 모은다.

이 방식은 기존 복구 계약을 *추가만* 하고 *변경하지 않는다*(원칙 08 — 동작 보존하며 작은 단위 개선). 옵션 A(커밋 전면 제거)는 복구 계약을 재작성해야 해서 더 큰 변경·더 적은 이득이라 기각.

**되돌림 대상 = 런 시작 직전 HEAD(산출물 커밋 *전*)**: 이래야 산출물(`.dddart/`)과 코드가 *함께* 미커밋으로 모여 사용자가 한 번에 검토·커밋한다(현행 `dddart.md:32` "산출물은 코드와 함께 커밋" 의도와 정합). git_snapshot(산출물 커밋)으로 되돌리면 산출물만 따로 커밋된 채 남아 의도와 어긋난다.

## 3. 정확한 코퍼스 편집 (claude `dddart.md`·codex 미러 동형)

### E1. build-state 스키마에 `pre_run_head` 추가 (`dddart.md` line 49 영역)

```
"git_snapshot": "<Phase 2 진입 시점 커밋 해시 — 백스톱 --diff-base·중단 복구의 기준>",
+ "pre_run_head": "<런 시작 직전(산출물 커밋 전) HEAD 해시 — Phase 3 마무리 '미커밋 합치기' soft-reset 기준. G0에서 깨끗한 트리로 시작한 full/modify에서만 채운다. dirty 진행·비git이면 미기록(=합치기 생략 신호)>",
```

### E2. 갱신 시점 보강 (`dddart.md` line 57)

"Phase 2 진입 시(git_snapshot·analyze_baseline·slices 목록)" → 여기에 "**산출물 커밋 *전* `pre_run_head` 기록**(깨끗한 트리 시작 시)"을 더한다.

### E3. Phase 2 진입 준비 — `pre_run_head` 캡처 (`dddart.md` line 143)

현행: "먼저 `.dddart/` 산출물을 커밋한다 … 그 다음 현재 커밋 해시를 git_snapshot에 기록."
→ 앞에 한 문장 삽입: "**G0에서 깨끗한 트리로 시작했으면 산출물 커밋 *전* `git rev-parse HEAD`를 `pre_run_head`로 기록한다**(마무리 미커밋 합치기 기준 — dirty로 진행했거나 비git이면 기록하지 않는다 = 합치기 생략). 그 다음 `.dddart/` 산출물을 커밋하고 … git_snapshot 기록."

### E4. Phase 3 마무리에 합치기 단계 신설 (`dddart.md` line 160~162)

현행 Phase 3은 검증 보고만 한다. 맨 앞에 합치기 단계를 신설:

> **미커밋 합치기 (full/modify·`pre_run_head` 있을 때만 — G2 승인 직후)**: 파이프라인이 만든 커밋을 풀어 사용자 검토용 단일 미커밋 변경분으로 모은다.
> 1. **안전 가드(전부 통과해야 실행)**: ⓐ `pre_run_head`가 기록돼 있다(깨끗한 트리 시작). ⓑ `git rev-parse HEAD`가 `build-state.json`의 마지막 슬라이스 `commit`과 일치한다(파이프라인이 마지막으로 남긴 지점). ⓒ `git merge-base --is-ancestor <pre_run_head> HEAD`가 참(되돌림 대상이 현재의 조상). **하나라도 어긋나면(사용자가 런 중 커밋·HEAD 이동 등) soft-reset을 실행하지 않고**, 커밋을 그대로 둔 채 배너에 수동 안내(`git reset --soft <pre_run_head>` 한 줄)만 보고한다(D+ 폴백).
> 2. **실행**: `git reset --soft <pre_run_head>`. **`--soft`만 쓴다**(`--hard`·`--mixed` 금지 — 작업 트리·인덱스를 보존해 파일·변경이 한 줄도 사라지지 않게). 결과: 산출물+코드 전체가 *스테이징된 미커밋* 한 묶음으로 남는다.
> 3. **보고**: Phase 3 검증 보고에 "변경분 N파일을 미커밋(스테이징)으로 모음 — `git status`로 목록, `git diff --staged`로 내용 검토 후 직접 커밋하세요"를 더한다.
> 4. **생략 케이스**: `pre_run_head` 없음(dirty 시작·비git)·트리비얼(애초에 미커밋)이면 합치기 없이 사유만 보고한다.

### E5. 경계·역할 보강 (`dddart.md` line 9·193)

Coordinator가 직접 하는 git 작업에 "마무리 미커밋 합치기(soft-reset)"를 명시(line 9 "git 스냅샷 기록" 인접·line 193 경계).

### E6. codex 미러 (`codex-dddart/skills/dddart/SKILL.md`)

E1~E5를 codex 방언으로 동형 적용: build-state 스키마(SKILL line 57 영역)·갱신 시점(67)·Phase 2 진입 준비(158)·Phase 3 마무리·경계. git 명령 자체는 동일(네이티브 셸). 적용 후 양판 의미 동치 확인(바이트 동일은 불요 — 방언 차이 존재).

## 4. 안전 가드 (이 설계의 생명)

soft-reset은 HEAD를 옮기는 작업이라 잘못 쓰면 사용자 커밋을 훼손할 수 있다. 가드 원칙:
- **되돌림 대상은 기록된 `pre_run_head`만** — 추측 금지(`git_snapshot^` 같은 영리한 도출도 금지·명시 필드만, 원칙 07).
- **3중 사전검증**(ⓐⓑⓒ 위) 통과 시에만 실행 — 어긋나면 *아무것도 되돌리지 않고* 수동 안내로 폴백(파괴보다 보수).
- **`--soft` 전용** — 작업 트리·인덱스 보존(파일 손실 0). `--hard`/`--mixed` 금지.
- **G2 승인 후에만** — 승인 전 거부·재실행 시 복구용 커밋이 필요하므로 합치기는 런 완료 후로 한정.
- **깨끗한 트리 시작 한정** — dirty 진행은 사용자 WIP가 섞여 되돌림 대상 식별이 흐려지므로 합치기를 생략(현행 line 103 "dirty=중단복구 불가 고지"와 정합).

## 5. 엣지 케이스

| 상황 | 처리 |
|---|---|
| dirty 트리로 시작(사용자 "그대로 진행") | `pre_run_head` 미기록 → 합치기 생략·사유 보고(수동 안내) |
| 비git(사용자 git init 거부) | 커밋 자체가 없음 → 합치기 N/A |
| 트리비얼 모드 | 애초에 미커밋(diff-base=편집 직전 HEAD)이라 해당 없음 |
| 수정 모드 | full과 동일 적용(커밋 발생하는 경로면 마무리에서 합치기) |
| 세션 사멸 후 재개 | `pre_run_head`가 build-state에 영속 → 재개 후에도 합치기 가능. 단 G2 승인 후 합치기 전 사멸은 드묾 |
| 런 중 사용자가 커밋함 | 가드 ⓑⓒ 실패 → soft-reset 생략·수동 안내(자동 파괴 회피) |
| 합치기 후 build-state의 슬라이스 해시 dangling | 런 완료 후라 재개 불요 → 무해(필요 시 phase=finalize만 갱신) |

## 6. 영향 없음 (불변 확인)

- **백스톱 `--diff-base <git_snapshot>`**: 런 중 동작·변경 없음(합치기는 마무리에만).
- **런 중 중단/재개 복구**: 슬라이스 커밋 유지 → 무손상.
- **scripts·rubric·fixtures**: 커맨드 절차 변경뿐이라 무관.

## 7. eval 채점 영향 (주의)

eval 런 폴더에서는 슬라이스별 커밋이 채점 narration(어느 슬라이스가 뭘 했는지)에 유용하다. 마무리 합치기가 켜지면 *완료된* 런의 슬라이스 커밋이 사라진다(채점은 baseline 대비 전체 diff로 가능하나 슬라이스 narration 상실). → **결정 필요**: eval 런에 한해 합치기를 끄는 스위치를 둘지, 아니면 채점을 합치기 *전*(G2 승인 직후·합치기 직전)에 수행할지. 1차 권장: 채점은 합치기 전 상태(런 직후 커밋 존재)에서 수행 — 코퍼스에 eval 전용 분기를 넣지 않는다(원칙 05 YAGNI). 적대 리뷰 쟁점.

## 8. 검증 계획

- soft-reset은 fixture로 자동검증하기 까다롭다(런 전체 시뮬레이션 필요). → 가드 로직의 *정확성*은 적대 리뷰(git 안전 렌즈)로 검증하고, 실제 거동은 다음 라이브런 마무리에서 관측(사용자 드라이브).
- 양판 미러 의미 동치 확인(claude·codex 동형).
- 변경 후 `dddart.md`·`SKILL.md` 재독으로 절차 정합(가드 3조건·생략 케이스·--soft 전용 문구 누락 없음).

## 9. 적대 리뷰에 던질 질문 (reviewers가 공격할 것)

1. **plugin/command 규약**(claude 공식문서): `git reset --soft`가 `allowed-tools`의 Bash로 충분한가? Claude Code 커맨드 규약·`${CLAUDE_PLUGIN_ROOT}`·frontmatter와 충돌 없나? 커맨드가 사용자 레포 히스토리를 자동 재작성하는 게 플러그인 경계상 허용되는 패턴인가?
2. **codex skill 규약**(codex 공식문서): codex SKILL.md 미러가 Codex skill 작성 규약·네이티브 셸 실행과 정합한가? claude/codex 거동 차이로 생기는 함정?
3. **git 안전**(공격적): soft-reset이 사용자 데이터를 잃거나 깨진 상태를 남길 모든 경로 — detached HEAD·shallow clone·submodule·pre-existing 스테이징·중단된 finalize·hooks·재개 후 중복 reset 등. 가드 3조건으로 정말 충분한가?
4. **YAGNI·계약 정합**(공격적): B가 과설계인가? 마무리 합치기가 복구·백스톱·재개·"산출물 코드와 함께 커밋"·eval 채점 중 무엇을 깨는가? `--soft` vs `--mixed`(검토 편의 — 전자는 `git diff --staged` 필요)는 어느 쪽이 사용자 목표에 맞나? 더 단순한 정답이 있나?

---

## 10. 적대 리뷰 반영 (4렌즈 — claude규약·codex규약·git안전·YAGNI) — **이 절이 §2~§5의 가드·필드를 대체한다**

4 서브에이전트(공식문서 인용·git는 /tmp 실험) 결과. 수렴 발견(독립 2명+)은 高신뢰로 전면 반영.

### 10.1 반영한 BLOCKER/CRITICAL

- **[R3·R4 수렴] 가드 ⓑ "HEAD==마지막 슬라이스 커밋"은 죽은 코드** — 파이프라인은 마지막 슬라이스 *뒤에* 감사반영·**backstop-baseline**(`dddart.md:155` 브라운필드 첫 런)·G2마무리 커밋을 더 만든다. 실측 런 로그로 확정(HEAD≠마지막 슬라이스). → **폐기.** 새 가드는 `last_commit`(파이프라인이 커밋마다 갱신하는 자기 tip)과 HEAD 일치로 "런 종료 후 사용자가 안 건드림"을 본다.
- **[R3] 멱등성 부재** — 합치기 후 사용자가 커밋 → 재실행이 그 커밋 파괴(reflog로만 복구). → **합치기 성공 시 `pre_run_head`를 비운다**(빈 값=가드ⓐ 실패=재실행 자동 생략).
- **[R3·/tmp실험] detached HEAD** — `reset --soft`가 분리 포인터만 옮겨 작업이 브랜치에 좌초. 가드 ⓒ(is-ancestor) 통과함. → **가드: `git symbolic-ref -q HEAD` 성공(브랜치 부착)일 때만.**
- **[R2·공식문서+openai/codex #7071·#9273] Codex `.git` read-only 마운트** — workspace-write 샌드박스가 `.git`을 읽기전용 bind-mount → git 쓰기가 승인 escalation 대상이거나 실패. (단 *실측*: 이 프로젝트 codex 라이브런은 슬라이스 커밋이 이미 성공 → 사용자 환경은 git쓰기 허용. 합치기는 기존 커밋과 동일 권한층이라 커밋이 되면 reset도 된다.) → **git 쓰기 실패(환경/권한)도 가드 실패로 보고 D+ 폴백**(자동 reset 없이 수동 명령 안내).

### 10.2 반영한 MAJOR

- **[R1·R2] 승인 게이트** — 사용자 레포 히스토리 자동 재작성은 동의 필요. → **별도 게이트 추가 대신 G2 배너에 "승인 시 마무리에서 파이프라인 커밋을 미커밋으로 합침" 1줄 고지**. 기존 G2 승인이 합치기 동의를 겸한다(추가 마찰 0·사용자 "아무것도 안 함" 목표 유지).
- **[R1·R3] 합치기 직전 트리 재확인** — `pre_run_head`는 Phase 2에 기록되나 Phase 2~3 사이 사용자가 stash/WIP 추가 가능. → **reset 직전 `git status --porcelain` 빈 출력 재확인**(+ `.git/index.lock` 부재).
- **[R4·R1] 합치기 시점 = Phase 3 *마지막* 단계**(검증 보고 *후*) — "G2 직후"가 아니라 보고를 끝낸 뒤 마지막에. 보고는 커밋 무손상 상태에서 생성.
- **[R2] codex 미러: "git 명령은 동일(네이티브 셸)" 문구 오류** — 명령 *문자열*은 같으나 *실행 거동*(`.git` 읽기전용·approval)이 다름. → §3 E6 문구 교정 + 합치기는 **Coordinator 직접**(서브에이전트 spawn 아님·codex 경계에 명시).

### 10.3 반영한 MINOR / 기각

- **[R3 실험] `--soft` 유지 확정** — full 빌드는 대부분 *신규 파일*인데 `--mixed`는 신규를 untracked(`??`)로 빼 `git diff`에 안 보인다(`--mixed`의 장점이 dddart엔 무효). `--soft`는 전체를 한 스테이징 단위로 모아 `git diff --staged` 검토 후 `git commit` 한 번. → **§9-4의 `--mixed` 옹호 폐기.**
- **[R4·R3] 사용자 검토 명령 정정** — `--soft`는 전부 스테이징이라 plain `git diff`가 빈 출력. → 보고문·사용자 안내는 **`git diff --staged`**(또는 `git reset`로 언스테이징 후 검토).
- **[R3·/tmp실험] hooks 우려 종결** — `git reset --soft`는 pre-commit/post-checkout/post-commit **어느 것도 발화 안 함**. 사용자의 *후속* 커밋만 pre-commit 정상 발화(바람직).
- **[R3] gc·exit code** — 모든 가드 git 명령 **exit 0 검사**(gc된 `pre_run_head`는 exit128). 실패=합치기 생략.
- **[R4] 더 단순한 대안(git_snapshot로 합치기·필드0) 기각 근거 보강** — 그 방식은 산출물이 *별도 자동 커밋*으로 남아 사용자가 다룰 잔여 커밋이 생긴다. 사용자는 "자동 커밋 통제"를 원했으므로 **잔여 0(pre_run_head 합치기)**이 목표에 더 맞다. 필드 비용(2개)은 데이터손실 방지값에 비해 사소·**fail-safe**(필드 없거나 불일치=D+ 폴백).
- **[R1] allowed-tools에 `git reset` 별도 규칙 — 기각(blocker 아님)** — 현행 unscoped `Bash`가 이미 git commit/add/curl/dart를 다 돌린다·git reset 동일. 스코핑하면 나머지 Bash가 깨진다. 의도신호는 코퍼스 주석으로 충분.
- **[R4] eval 채점** — 합치기는 Phase 3 끝에 발화·그레이더는 baseline 대비 전체 diff로 채점(슬라이스 narration은 reflog). **eval 전용 스위치 미도입(YAGNI)**·§7 "합치기 전 채점" 약속을 "합치기 후 changeset을 baseline 대비 채점"으로 정직 교정. **⚠️ 채점 사본은 `git clone`이 아니라 `cp -r`** — 합치기된 런은 변경분이 *미커밋(스테이징)*이라 `git clone`은 커밋된 히스토리만 복사해 생성 코드를 통째로 놓친다(`cp -r`은 워킹트리·인덱스 포함). 이후 `--diff-base abee26d` 백스톱은 스테이징분도 보므로 정상.

### 10.4 최종 가드 (합치기 실행 전 *전부* 충족 — 하나라도 실패/ git오류 시 reset 없이 D+ 수동안내)

1. **ⓐ** `pre_run_head` 존재(깨끗한 트리 시작·미합치). *합치기 성공 후 비움 → 멱등.*
2. **ⓑ** `git symbolic-ref -q HEAD` 성공(브랜치 부착·detached 아님).
3. **ⓒ** `git status --porcelain` 빈 출력 **그리고** `.git/index.lock` 부재(트리 청결·동시 git 없음).
4. **ⓓ** `git rev-parse HEAD` == build-state `last_commit`(런 종료 후 사용자 커밋 없음) **그리고** `git merge-base --is-ancestor <pre_run_head> HEAD` exit 0(정합 sanity).
5. 통과 시 **`git reset --soft <pre_run_head>`**(exit 0 필수) → `pre_run_head` 비움(멱등) → `git diff --staged` 검토 안내 보고.
6. **D+ 폴백**(어느 가드든 실패·git 쓰기 거부): 커밋 그대로 두고 배너에 `git reset --soft <pre_run_head>` 한 줄만 보고(자동 파괴 회피·파일 무손상).

### 10.5 build-state 새 필드 (2개·fail-safe)

- `pre_run_head` — 런 시작 직전 HEAD(reset 대상·청결시작 신호·합치기 후 비움=멱등). 깨끗한 시작 full/modify에서만.
- `last_commit` — 파이프라인이 커밋할 때마다(산출물·슬라이스·감사·backstop-baseline·마무리) 갱신하는 최신 자기 커밋. 가드 ⓓ 기준.

