# 수정 계획 (확정 v2 — 적대 리뷰 4명 + feedback-010 통합) — 9차 claude IM22 토끼굴

> **상태: 확정**(적대 리뷰 4명·2026-06-19 반영). 초안 v1의 P1~P4 → R1~R7 재구성. 실제 수정은 사용자 승인 후.
> **결정 원칙**: 이 프로젝트 자체 데이터가 **"코퍼스 산문은 취약·기계 floor는 엔진불변 홀드"**를 입증(feedback-010 N=2~3). 처방 무게중심을 산문→기계로.

## 결정적 재발견 (feedback-010 통합)
9차 "date 직렬화 misplacement"는 **단일 사건이 아니다** — 같은 불안정 region이 **3연속 진동**:
- 7차: `weather_navigator.dart` 직렬화 green-on-mutation (feedback-010 FC-2)
- 8차: `weather_list_view.dart` 직렬화 (feedback-010 "navigator→view 진동·guide취약 예고적중")
- 9차: `common/util/date_path_codec.dart`로 이동 → IM22 버그 충돌 → 토끼굴
각 회차 **코퍼스 산문 보강(architecture-ddd §3)을 시도했으나 전부 무효** — feedback-010 §72: *"guide 취약 thesis 재확인 → **기계화(custom_lint/AST/grep floor) 승격 재검(미해결)**"*. ⓓ에 이미 `DateFormat`/`toIso8601String` grep 처방(약).
**→ 이 계획의 정체성 = feedback-010이 미해결로 남긴 "기계화 승격"의 실행.** 초안 P2(carrier 산문)는 이미 3회 실패한 산문의 4번째 반복이었다(적대 리뷰 2·4 적중).

## RCA 요약 (교정본·미확정 포함)
인과: 엔진 규율차 → date를 DateTime carrier로 과모델링 → 직렬화 의무 → 변환을 common으로(7→8→9 진동 3번째) → **IM22 backstop 버그** 충돌 → green 코드 런중 리팩터 + `.g.dart` 수기편집(analyze 사각) → 표류 2시간.
- **미확정(선결)**: ⓐ 9차 raw 결과/트랜스크립트가 원장에 부재(최신=8차) → "IM22가 트리거"는 재구성 의존, 보존 필요. ⓑ claude 리팩터 시작 계기(순환 실재 vs 자발). ⓒ Coordinator 체크포인트(§6.2.1) 9차 실태.

## 양판 미러 (경로 정정 — 초안 오류)
- 렌즈/규율 스킬: `dddart/skills/<skill>/` ↔ `codex-dddart/skills/<skill>/` (codex는 `dddart/` 중간 없음)
- backstop scripts: `dddart/scripts/` ↔ `codex-dddart/skills/dddart/scripts/`
- 콘텐츠 동기화 확인(정정 경로 diff 0). **단 coder 규율은 구조 비대칭**: claude=`dddart/agents/coder.md`(에이전트), codex=`codex-dddart/skills/dddart-coder/SKILL.md`(스킬) → diff 0 불가·**두 구조에 각각 번역** 필요(R4·R6).

---

## 확정 처방

### R1 (필수) — IM22 common 데이터 허용 [기계·실현 확증]
- **대상**: `dddart/scripts/src/check_imports.dart:209-220` (+ codex 미러)
- **수정**: `ok` 술어에 `t.startsWith('common/') ||` 추가 + 메시지(`:217`) 갱신.
- **근거(정정)**: IM22는 **allowlist(default-deny)**, IM21은 **denylist(default-allow)** — navigator→common은 "암묵 통과", router→common은 "누락 차단" = 비대칭 버그. SSOT = houserules §5(`discipline-houserules/references/final.md:206` — common은 domain만 예외). (초안 §21 "IM21 명시 허용" 근거는 오류 — 정정)
- **동반(누락 보완)**: houserules §5/§3.7 매트릭스에 router→common 명문화(코퍼스-러너 정합) + `run_fixtures.sh`에 router→common PASS / router→infra BLOCK fixture 추가(현재 IM22 fixture 0건).

### R2 (필수·핵심·R1과 묶음) — codec-token backstop 신설 [기계·feedback-010 미해결 실행]
- **대상**: `dddart/scripts/src/check_imports.dart` (신규 규칙·IM23류) (+ codex 미러)
- **수정**: `<bc>_router.dart`·`<bc>_navigator.dart`에서 ⓐ `e.uri.startsWith('package:intl/')` import 차단(IM1 `e.uri` 패턴) + ⓑ `scanTokens`로 `DateFormat(`/`.format(`/`toIso8601String()` 토큰 차단(IM14 템플릿·added 줄 게이트·마스킹).
- **경계(feedback-010 §47 VW-7 과대범위 교정 준수)**: 단순 식별자 String 전달(`'$id'`·이미 String)은 통과. **변환 로직(날짜 포맷·다필드 조립)만** 차단(적대 리뷰 3의 숫자 id 오적용 경고 해소).
- **실현성 확증**: `e.uri.startsWith('package:flutter/')`(IM1:38)·`scanTokens(ms, RegExp(...))`(IM8:228·IM14:242) 인프라 기존 존재.
- **역할**: 기존 산문(§3.72 "navigator는 전달만"·architecture-ui §6 "라우트 이름만")의 **충실한 기계 집행**. R1을 안전하게(router→common 데이터 허용·codec 로직 차단). **7→8→9 진동을 끊는 기계 floor**.
- ⚠️ **R1+R2 = 한 패키지. do both or neither**(R1만 하면 안티패턴 무방비).

### R3 (필수·신규) — `.g.dart` 래칫 구멍 fix [기계·표류 직접 방지]
- **근거**: houserules §147 `exclude: **/*.g.dart` → 생성물 수기편집이 **analyze green 래칫에 안 보임**(2시간 표류 직접 원인).
- **수정**: codegen 게이트(Coordinator)에서 `build_runner build` 후 `.g.dart`/`.freezed.dart`가 재생성 결과와 git-clean인지 검증(수기 hunk 있으면 fail). EVAL-METHOD §65 "BG-1 재생성이 손작성 codegen 덮어쓰기=반-게이밍" 장치를 **라이브런 파이프라인 게이트로 승격**.
- **지점**: Coordinator/coder 게이트 절(정확 지점 = pipeline 설계 §6.2.1 인근·수정 시 특정).

### R4 (보조·cheap) — 산문 1줄 [non-load-bearing]
- `.g.dart`/`.freezed.dart`는 build_runner 재생성만·수기편집 금지 — `implementation-riverpod` codegen 절 또는 `dddart/agents/coder.md:40`(+ codex `dddart-coder/SKILL.md` 번역). R3(기계)의 cheap reinforcement.

### R5 (강등) — carrier 가이드: 산문 폐기 → R2 흡수 [P2 폐기]
- feedback-010이 산문 무효 판정(3회). 초안 P2(carrier 산문 보강) **폐기**.
- 대체: carrier 선택은 R2(codec-token)가 기계로 강제(router/nav가 변환 못 보유 → String 전달 유도). 잔여 산문은 §3.72에 1문장 non-load-bearing(과해석 방지: §126 `isStale(DateTime now)` 정당 케이스 보전 — 적대 리뷰 3).

### R6 (재겨냥) — 런중 재설계: coder → Coordinator 체크포인트 [actor 정정]
- 초안 P3(b)는 coder 겨냥 오류. 체크포인트(git-snapshot·commit-per-green-slice)는 **Coordinator(§6.2.1)** 소유.
- **수정**: "green 커밋된 슬라이스의 런중 자발적 재설계"를 Coordinator가 git diff로 표면화·차단/재승인. **선결: 9차에 §6.2.1 체크포인트가 실제 작동했는지 확인**(작동 안 했으면 구현 갭, 작동했으면 강화).

### R7 (권장·후속·별도 회차) — 허용목록형 규칙 false-positive 감사 [재발 클래스]
- IM22와 같은 클래스(이름/허용목록 휴리스틱): NM9(view `ref.watch` provider명)·NM13(라우트 리터럴)·IM5. R1을 IM22 단건으로 좁히면 같은 토끼굴이 다른 규칙서 재발 가능.
- 범위 확대·우선순위 후순위 → 별도 회차.

---

## 최소 충분 집합 · 우선순위
1. **R1 + R2** (묶음·필수·기계·이번 핵심) — IM22 버그 + codec-token floor. 확실성 최고.
2. **R3** (필수·기계·신규) — `.g.dart` 게이트.
3. **R4** (cheap 보조).
4. **R6** (재겨냥·선결 확인 필요).
5. **R5** (R2에 흡수·산문 최소).
6. **R7** (후속·별도 회차).
- **버림**: 초안 P2(산문·3회 실패)·P4(carrier 타입 탐지 = 타입추론 필요·불가)·P3 원형(actor 오류).

## 선결 / 미확정 (확정 전 또는 병행)
- 9차 raw 결과 원장 보존(RCA 증거 기반 강화 — 적대 리뷰 2).
- §6.2.1 체크포인트 9차 실태 확인(R6).
- coder 양판 구조 비대칭(R4·R6 번역).
- RCA 미확정 1건(순환 vs 자발).

## 검증 계획 (10차·사전등록형)
- **R1**: positive-control 회귀 0 + router→common PASS / router→infra BLOCK fixture.
- **R2**: router/nav의 `DateFormat`·`intl` import 케이스 FAIL + 단순 String 전달 PASS(positive-control). **7→8→9 진동 차단 실측**.
- **R3**: 수기편집 `.g.dart` 케이스 게이트 차단 실측.
- `feedback-012` ⑥ 다음 런 실측 대조. N=1 → ≥2 런 확정.
