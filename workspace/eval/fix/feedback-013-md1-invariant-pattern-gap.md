# fix 013 — MD1(@freezed 필수)×불변식 봉인 패턴 부재 (사전등록형·ultracode RCA 18 + 적대 리뷰 6/6 partial 반영)

> **트리거**: 10차 양판 백스톱 막판 적발 **폭발**(claude 11·codex 14건)·평균 소요 **1h→2h 회귀**. 사용자 지적("평균 2배=그 자체가 실패, 결국 green이어도 의미 없음")으로 성공 기준을 "빠른 1회 green(막판 대수술 없음)"으로 재정의 → 10차는 양 엔진 **실패**.
> **결정 원칙**: 백스톱은 깐깐해지지 않았다(NM/IM 규칙 6-15 이후 `git diff` byte-identical). 변곡점 9차의 근본 = **MD1(@freezed 모델 필수, 6-18 feedback-009 신설) × 명세 격상 × 엔진 plain 도망의 곱**. **처방 무게중심 = 기계 floor(R5 명세 린터·R6 MD1 메시지)·R1~R4 보조**(feedback-010/012 교훈: 산문 무효·기계 홀드).
> **9차 토끼굴(2h)과 구분**: 9차 claude 단발 표류 = IM22 fp 버그+`.g.dart` 사각+체크포인트 부재이고 **feedback-012 R1·R3·R6이 이미 처리**(10차 IM22 무재발 확인). 10차 양판 폭발은 그 *이후* 발생한 **별개의 병** = 이 원장.

## 메타
- **회차**: 013
- **트리거**: 10차 양판(`~/Desktop/dddart-run/dddart-20260619-2248-{claude,codex}`)·ultracode RCA(사실수집 6 + 적대검증 12·`wf_298fba27`) + 처방 적대 리뷰(6관점·`wf_e67d0daf`)·2026-06-20
- **베이스 코퍼스**: `d30cd85`(feedback-012 R1~R7 머지본)
- **검증 런**: 11차(양판)
- **상태**: **R6+R1~R4 시술 완료(2026-06-20·양판·`run_fixtures` 31/0·diff 0·미커밋)**. R5(명세 dry-run 린터) 미시술 = 11차 결과 후 판단. 적대 리뷰 6/6 partial 반영·상세 설계 v2 = `workspace/design/2026-06-20-md1-invariant-pattern-remediation-plan.md`.

## RCA — 3축의 곱 (적대검증·적대 리뷰로 정교화)

**현상**: 막판 백스톱 적발 1~8차 0~2건 → 9차 claude 7건 → 10차 claude 11·codex 14건 단조 급증. 같은 고참 규칙(NM2/3/4/9/12·IM21/22, 6-12 출생)인데 8차까진 거의 안 걸림.

| 축 | 내용 | 증거 |
|---|---|---|
| **규칙축** | **MD1(@freezed 필수)** 신설 — entity·VO·aggregate root·state 강제. 6-12 NM/IM과 달리 변곡점 직전 출생 | `check_models.dart` 최초 = `a27c357`(6-18 feedback-009). NM/IM `git diff 140d237 9afa6f0` = **빈 출력** |
| **설계축** | 같은 weather를 1~5차는 flat @freezed 엔티티로, **9·10차는 "정렬 불변식 소유 애그리거트 루트 + ForecastDate VO"로 격상**. 명세에 **러너 바닥 없음**(check_*는 생성코드만·명세 .md 비검사) → NM 클러스터 최대 잔여 | 10차 claude design-spec §3.1·L83-87(`_view_*` 지시)·L406(자기인증 "일치✔"인데 NM2/4 위반) |
| **엔진축** | `@freezed` 포기→**plain class 도망**(어트랙터지만 런별 추측 변동) | 10차 claude `class WeeklyForecast`·주석 "freezed는 공개 생성자 강제라 봉인 불가". 10차 codex `final class`(`1888d83~1`) |

**세 축이 곱해질 때만 폭발.**

### 🔑 스모킹건 — 8차 codex (적대 리뷰 교정본)
- **8차 codex는 MD1 켜진 상태인데 0~2건 통과** — 단 v1 "루트를 @freezed로 봉인" = **부정확**(적대 Q1·Q5). 8차 codex는 **컬렉션 루트를 안 만들었다**(`Forecast`=단일일 평탄·List 0개). 정렬은 `ForecastChronologyService`(**도메인 서비스**·`final class`=MD1 면제)가 소유(`f54df9a`·design-spec L57). → 진짜 변별자 = "예제 유무"가 아니라 **"애그리거트 루트가 컬렉션 정렬을 소유하느냐"의 spec 결정**(8차=도메인서비스 / 9·10차=루트 격상).
- **잔여는 "도망"이 아니라 "지연"**(적대 Q2): MD1은 이미 plain을 잡고 전환을 강제 — 10차 codex `1888d83`이 막판에 *스스로* `@freezed`+named factory 전환(R1 패턴과 동일). 문제는 전환이 **막판 백스톱 시점=대수술(2h)**. → 처방 = 전환을 막판→명세단계로 당김(R5)·막판 방황→기계 붙여넣기(R6).
- **엔진 진짜 장벽**(적대 Q1): 9차 claude 주석 "freezed 3.x는 private-named 생성자를 map/when 충돌로 표현 못 함→plain". v1 R1은 이 장벽·"fromJson codegen이라 봉인 무의미"를 침묵 → R1 가드 보강.

### 적대검증이 기각한 오답 (제 초기 가설 포함)
- ❌ **"명세가 충돌 구조 자초"** → refuted: 9차 codex 개념분할 갖고 완주·10차 버리고 폭발.
- ❌ **"테스트/FID 의무가 주의력 전위"** → refuted: 8차 동일 부하인데 0건·델타 screenProbes 13줄.
- ❌ **"백스톱 로직 엄격화"** → refuted: NM/IM byte-identical.
- △ **"산출물 과설계"** → partial: 변별자 = 루트 plain vs @freezed(VO 유무 아님).

## 교정 항목 (사전등록 · v2 = 기계 floor 중심)

| # | 우선 | ① 대상 | ② 근거 | ③ 처방(파일·양판) | ④ 예상효과 | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| **R6** | 🔑기계·cheap | MD1 적발 후 엔진 전환 "방황"(2h 주원인) | 10차 codex 자력 전환 실증(지연이지 도망 아님)·현 MD1 메시지 named factory 언급 0 | `check_models.dart:75` MD1 메시지 분기 — 컬렉션 필드 가진 루트면 named factory 템플릿 인라인·양판 | 막판 방황→기계 붙여넣기·소요 회귀 완화 | — | 11차 |
| **R5** | 🔑기계·1순위 | 명세 NM/MD/IM **러너 바닥 부재** → NM 클러스터 막판 폭발 | 10차 claude 자기인증 실패(L406)·R2 산문은 LLM 양끝(architect도 위반 자가통과) | design-spec 파일목록을 **G1(코드 작성 전)** check_naming/models/imports로 dry-run·위반 시 fail·양판(도구+Coordinator 게이트) | 막판 대수술→명세단계 차단·R2에 러너 바닥 | — | 11차 |
| **R1** | 보조 | 컬렉션 named factory 예제·plain 금지 가드 부재 | §3·§4 예제 있으나 컬렉션 정렬용 부재·엔진 map/when 오판 | architecture-ddd §4+impl-dart §4: 컬렉션 named factory 예제 + 가드(타입봉인 무의미·fromJson codegen·map/when 충돌·plain=MD1위반 **스코프 한정** enum/exception/common 제외)·양판 | MD1 인간가독 근거·plain 도망률↓ | — | 11차 |
| **R2** | 보조→R5 승격 | 명세 모델타입 침묵·백스톱 deny 미인식 | 9차 명세 모델타입 침묵→coder plain·자기모순 스캔 deny 미검사 | design-architect: 모델 @freezed 명세 필수필드(R5 입력 정형화)·자기스캔→백스톱 정합 스캔 교체·"일치✔" 자기인증 금지·houserules §4 `_view_vm` 반례·NM5 섹션접두·NM12·양판 | 명세발 NM 클러스터 제거(R5가 기계 집행) | — | 11차 |
| **R3** | 보조·R2 결박 | router/navigator가 domain VO 인자 | 명세가 VO 인자 박음(claude L343·codex L256)·진동 (b)패밀리 | architecture-ddd §3+ui §6: 공개 메서드·builder 인자=String·복원 view/VM·**R3∧R2 do both or neither**·양판 | IM21/22 제거·진동 (b) 종결(증상 차단) | — | 11차 |
| **R4** | 보조·cheap | JsonConverter·표시변환 헬퍼 동거(NM3·formatter-NM3) | 코더 재량·v1은 converter만(formatter 미커버) | impl-dart §7: JsonConverter+display-text/formatter 클래스 별파일 or top-level(static·top-level 예외)·양판 | NM3+formatter-NM3 제거 | — | — |

- **무게중심(v2 재편)**: R5·R6=기계 floor(핵심)·R1~R4=보조 코퍼스(인간가독 근거·gap 메움). v1의 "R1=무게중심"은 적대 Q2(산문무효 위험)로 격하.
- **처방 밖 잔여**(적대 Q5): NM5×2·formatter-NM3×1 → R2/R4 확장으로 커버.
- **결박**: R3∧R2 = do both or neither(명세가 VO 인자 박으면 R3 무효). R3/R4 load-bearing 철회.
- **버림**: MD1 완화/예외(기각 — 8차가 @freezed로 됨 증명·규칙 아닌 패턴/기계가 답).

## 시술 결과 (2026-06-20 — R6+R1~R4·양판·미커밋)
- **R6 ✅** `check_models.dart:75` MD1 메시지에 컬렉션 루트 named factory 템플릿(`_collectionFieldRe`+`isRoot` 분기)·양판 cp diff 0. fixture **F18a**(컬렉션 plain→템플릿)·**F18b**(@freezed 침묵 positive-control)·**F18c**(컬렉션無 plain→템플릿 미제시 과대범위 반증). `run_fixtures` 31/0(F1~F17 회귀 0).
- **R1 ✅** architecture-ddd §4(컬렉션 named factory 예제 `WeeklyForecast.fromDays`+가드: 타입봉인 무의미·fromJson codegen·map/when 충돌·plain=MD1 스코프 한정 enum/exception/common 제외)·implementation-dart §4(map/when 장벽 표기)·양판.
- **R2 ✅** design-architect(모델 @freezed 명세 필수·router=String 명세·**백스톱 정합 스캔** 신설·자기인증 금지)·houserules §4(_view 끼움 금지 반례)·양판(claude `agents/`↔codex `skills/dddart-design-architect` 번역 1:1).
- **R3 ✅** architecture-ddd §3·architecture-ui §6(router/nav 공개 인자=String·복원 view/VM)·양판. **R3∧R2 결박**(명세가 String 인자 강제해야 효력).
- **R4 ✅** implementation-dart §7(JsonConverter+display-text/formatter 별파일·top-level/VO 내부 static 예외)·양판.
- **R5 보류**: 명세 dry-run 린터 — 신규 도구·명세 정형화 선결. 11차서 R6+R2로 NM 클러스터가 안 잡히는지 보고 판단(적대 Q3·Q5: R2 산문은 LLM 양끝이라 NM 100% 차단 불확실).
- **양판**: `final.md` 4개·`check_models.dart` = cp diff 0. design-architect = 번역(문구 1:1). `run_fixtures.sh`는 claude만(codex 테스트 부재).

## measure-first / 검증 (11차·사전등록·적대 보강)
- **positive-control(R6·R1)**: @freezed+named factory(`.fromX`·`.fromJson` 아님) 루트 PASS / plain 루트 FAIL · VO+JsonConverter 동거 NM3 FAIL / VO 내부 static 컨버터(8차 codex) PASS · enum·exception plain MD1 미발화(과대범위 반증).
- **R5**: 명세 dry-run이 `_view_state`·plain 모델·router VO 인자를 G1서 적발하는 fixture.
- **종합 게이트**: 막판 백스톱 11·14 → **0~2** · 소요 2h → **1h**.
- **막판수술 측정(적대 Q4·Q5)**: "**첫 커밋(슬라이스)부터 올바름 — 막판 fix-pass(VO→String·plain→@freezed) 0회**"(최종상태 아닌 과정). **NM 클러스터(NM2/4/5/12)·formatter-NM3를 MD1 클러스터와 별도 카운트** — R2/R5 산문↔기계 바닥의 실효 분리 관찰("0~2 회복"의 낙관/근거 판별).
- N=1(10차 폭발) → ≥2 런(11차 회복)로 인과 확정.

## 미확정 / 후속
- **R5 구현 비용**: 명세 파일목록 정형화 범위(architect 출력 형식 — 경량 컬럼 파싱 vs 완전 트리). 시술 단계 평가.
- 10차 11·14 정확 카운트 미확정(라이브 중단·커밋 비열거) → 11차 코디네이터 출력으로 확정.
- 처방 우선순위: **R6**(cheap·즉효) → **R5**(1순위·비용 큼) → R1~R4(보조). R6 단독으로도 2h 회귀 일부 완화 가능.
- 관련: `feedback-012`(9차 IM22·R1~R7)·`feedback-010`(산문 무효·기계화 승격)·`feedback-009`(MD1 신설). RCA 원본 `wf_298fba27`(18·194만)·적대 리뷰 `wf_e67d0daf`(6·64만).
