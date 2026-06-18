# fix 009 — codex 단독 결함: ST-2 死분기·@freezed 게이트 (사전등록형)

> RCA: `workspace/design/2026-06-17-rubric-test-eval-design.md` §6차 + 본 세션 차분(코퍼스 전수 `diff`·런폴더 전수 grep). **핵심 = "1차 목표(claude PASS·codex FAIL) 항목"의 뿌리를 고치기 *전* 예상을 박고, 다음 라이브런(7차)으로 실측 대조.**
> ⚠️ **RCA 헤드라인(반전)**: claude·codex 코퍼스는 지배 스킬 전부 **byte-동일**(`diff -rq` 전수 — differ 0). 비대칭은 **미러 드리프트가 아니라 "공유된 공백·사각 위 엔진 행동 차이"**다. 그래서 처방 전략 = *미러 동기화 불가(이미 동일) → 공유 공백을 명시 가드 + 결정적 백스톱으로 엔진-불변 레일화(양 미러 동시)*.
> ⚠️ **정직 표기**: 항목 1의 reviewer 트리거는 *가이드+의미레인*(기계 보장 아님 — 결정성 없어 backstop 기각). 항목 2의 backstop만 기계 floor. N=1 인과 단정 금지(아래 전부 "적용 후 동시관찰"로 기록).

## 메타
- **회차**: 009
- **트리거**: 6차 양판 — `results/20260618-0012-weather-codex.md`(ST-2 3:0 만장·SD-4/DT-4/ST-3 수기·DT-5)·`-compare.md`·`-graders-raw.md`(ST-2 만장·A13). claude는 동일 항목 전부 PASS(`-claude.md`).
- **베이스 코퍼스**: `d18f2d1`(feedback-008·6차에 적재된 상태)
- **시술 커밋**: `<미적용 — 코퍼스 불변 방침·사용자 승인 대기>`
- **검증 런**: `<다음 라이브런(7차)·양판>`
- **상태**: **🔧 적용·미커밋(2026-06-18) — 7차 검증대기**(코퍼스 편집+백스톱 신설 완료·사용자 승인 후 적용·커밋 대기)

## 교정 항목 (사전등록 — ①~④ 작성, 다음 런 후 ⑤~⑥)

| # | 우선 | ① 대상(dim·관측점) | ② 원인(뿌리·공백) | ③ 처방(파일·미러) | ④ 예상효과(전→후·dim) | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| 1 | 핵심 | **ST-2**(치명·3:0 만장) — codex view가 `state.error`에 도달불가 死분기(`weather_forecast_list_view.dart:40-41`·`detail_view:46`). VM writer 0(전수 grep 확인)·실제 에러는 `.when(error:)` 채널①이 전담. claude는 error 필드 생략(PASS) | 코퍼스(architecture-state, 양엔진 byte-동일)가 침묵. **단 진짜 뿌리는 "필드 선언"이 아니라 "writer 0인 `state.error`에 view가 분기를 그린 것"** — positive-control 골든(읽기전용 notice BC·error 필드 보유·writer 0)이 ST-2 ✅PASS인 게 필드 무죄의 증거 | architecture-state `final.md` **§3:56/:59 원문 불변**(RUBRIC ST-3 "error 필드 부재=결함"과 정합·양미러 byte-동일 유지) + **§4에 死분기 정의 1문장 첨가**: "조회전용 State에 error 필드를 둘 수는 있으나 미사용은 무해 — view가 `state.error`에 분기를 그리면 writer 없는 死분기다; 분기를 그릴 거면 채널② writer(액션 메서드)가 실재해야 한다" → `corpus_mirror_sync.py --write`. + discipline-reviewer §3 **트리거 2-조건 AND**: "(그 State를 쓰는 *모든* VM·헬퍼 통틀어 `state.error` writer 0) AND (view/section이 `state.error`(`.value?.error`)를 읽어 분기) → 死채널 important" → SKILL·agents 수동 양판. **backstop 불채택**(결정성 없음·확장 copyWith 사각·fixture 과발동) | 전: codex ST-2 FAIL(死분기) → 후: 死분기 소거·ST-2 PASS / claude·fixture 무회귀. dim: **ST-2** | ✅적용(미커밋·§시술기록) | 7차대기 |
| 2 | 핵심 | **SD-4/DT-4/ST-3**(WEAK) — codex 수기 비-@freezed 전 모델(`daily_forecast.dart`·`daily_forecast_summary.dart` 수기 `fromJson`+`_readString/_readInt/_readDouble`+`FormatException`; States·root non-@freezed). claude 전부 @freezed | 코퍼스(architecture-ddd/data, byte-동일)가 "@freezed+json_annotation 직파싱"을 **서술/조건절로만** 적고 명령형 의무·수기 금지 없음 + reviewer 미로드 + backstop 미검사 = **두 관문 사각**. (run-variable: codex 3~5차 @freezed·6차만 수기) | **b1 코퍼스**: architecture-ddd §3/architecture-data §4를 명령형+**범위명시**("entity·value_object·State는 @freezed+json_serializable로 선언한다; 모델 클래스 자신의 수기 `fromJson` factory·모델 내 `_read*`·모델 내 `FormatException` 금지" — **enum[@JsonValue]·`@JsonKey(fromJson:)` 컨버터·도메인 `*Exception` 제외**·"DTO" 명사 도입 금지) → `--write`. **b2 backstop**(`tools/` 단일출처·added-units·전역제외 `*.g.dart`/`*.freezed.dart`/`exception.dart`/enum/DataSource·Repo): **Detector A**(범위[entity/VO/root/state] 내 non-enum 클래스가 @freezed 미부착→blocker) + **Detector B**(클래스 자신 `factory X.fromJson` 본문≠`_$XFromJson(json)` OR 모델 내 `_read\w+` 헬퍼 OR 모델 내 `FormatException`[도메인 `*Exception` 제외]→blocker). **positive-control 거짓-FAIL 반증 후 투입**(fixture @freezed 표본 비발동 확인·README:34) | 전: 수기 모델 WEAK(미게이트) → 후: 기계 blocker로 SD-4/DT-4/ST-3 해소·**엔진/회차 불변**. dim: **SD-4·DT-4·ST-3** | ✅적용(미커밋·§시술기록) | 7차대기 |
| 3 | 보류 | **FC-1/G-8**(보수·cosmetic) — codex "구름 많음"(공백) vs "구름많음" | architect 패러프레이즈(설계발)·프롬프트는 무공백. 뿌리는 직전 커밋 `2326dd0`(정렬 명시) 후 **미측정** | **변경 없음.** c2(코퍼스 노트) 기각(eval↔코퍼스 결합·과적합·설계문서 §B 자기기각 패턴 재림·정당 카피개선 위축). c1 정규화 기각(strict-match를 N=1로 무름·A13-4 "허용대역" 미끄럼 입구). 6차는 §2.2 보수FAIL+인간큐+cosmetic으로 **이미 올바르게 처리** | 측정 dim 없음(**관측 대기**). 같은 공백 재발(N≥2) 시 c1 "현상유지 명문화"(완화 아님)만 검토 | — | 관측대기 |
| 4 | 권장(완료) | **DT-5**(🟡WEAK·채점자 split) — codex Repo/UseCase/VM/DataSource **4곳 균일** `{Dep? dep}) : _x = dep ?? Default()` 선택적 주입 seam(use_case:9·detail_vm:13·list_vm:13·repo:12). claude **0곳**(직접 생성) | 코퍼스(byte-동일) data §1:32·state §2:48이 "직접 생성·DI 없음"은 말하나 **선택적 주입 seam을 명시 금지 안 함**(WEAK 문구공백) — codex가 글자(폴백=직접생성) 충족·정신 우회. seam 동기(테스트)는 dddart가 Dio목+VM override로 해소하므로 불요 | **b1**(채택·양미러): state §2·data §1에 "선택적 named param+`?? Default()` 폴백 금지·**위치 인자 직접전달**(`DataSource(DioClient.instance)`)은 정당·테스트는 VM override/Dio목(impl-test §2)" 명문화 + **reviewer §6 DI seam 트리거**(양판). **b2 백스톱 기각/보류**(적대검증: 🟡 split에 런-차단 백스톱은 과집행·measure-first README:35·N=1·`?? *Service()`/메서드param 오탐) | 전: seam WEAK·기준 모호 → 후: 기준 명시로 차기 seam 억제·reviewer 포착. dim: **DT-5**(가이드·기계 아님) | ✅적용(미커밋·§시술기록) | 7차대기 |
| 5 | 프로세스(rubric 비측정) | **finalize-collapse 불발**(codex) — 2커밋(품질 `9723bde`→build-state 별도 `64bb27e`)이 `HEAD==last_commit` 가드를 구조적으로 깸→collapse 미발화. 채점 무영향(`64bb27e` 핀) | codex-dddart 마무리 스킬이 build-state.json을 last_commit 기록 *후* 별도 커밋 → HEAD≠last_commit 강제 | codex-dddart finalize 스킬 수정 후보(예: build-state를 최종 파이프라인 커밋에 포함해 1커밋화, 또는 가드가 `pre_run_head` 기준 collapse·후행 build-state 커밋 허용). **설계 필요(원라이너 아님)** | rubric 비측정(런 위생). claude는 정상 발화(프로세스 비대칭) | — | — |

- **②원인 공통**: 6차 = 코퍼스가 *틀린 게 아니라 침묵/약-서술*한 영역에서 codex 엔진이 claude와 다르게 행동. **N=1**이고 codex 자신도 회차마다 갈림(@freezed 3~5차 준수·6차 일탈) → "엔진 고정 성향" 단정 금지. 처방은 *엔진/회차 불변 레일*(기계 가드)에 무게.
- **③미러**: `references/final.md`=`corpus_mirror_sync.py --write`(claude↔codex byte-exact) · SKILL·agents·discipline-reviewer 수동 양판 · backstop·FC-GOLDEN·eval(`workspace/eval/`)=단일출처(미러 불필요). **코퍼스 *적용*은 별도 사용자 승인(코퍼스 불변).**
- **④정직 표기(헛처방 조기경보)**: 항목 1 reviewer 트리거는 *가이드*(기계 floor 아님 — backstop 결정성 없어 기각, 7차가 1차 반증). 항목 2 backstop만 기계 floor(단 positive-control 반증 선행). 항목 3은 측정 dim 0(관측). 항목 4(DT-5)는 b1+reviewer 채택(가이드·기계 아님)·b2 백스톱 보류. 항목 5는 rubric 비측정.

## 적대 리뷰 반영 (3렌즈·~227k subagent tokens — 원안을 실질 교정)
- **A(ST-2) 🔴 원안 결함**: backstop #3("선언됐는데 writer 0인 error 필드")·carve-out("조회VM은 error 필드 금지")이 **dddart 자신의 positive-control 골든**(`tools/positive-control/` — 읽기전용 notice BC·State에 `BadRequestResponse? error` 보유·writer 0·view 미분기·ST-2 ✅PASS, README:63)을 **오발**. + RUBRIC `:58` ST-3이 "error 필드 부재=결함"이라 §3:56/:59 재작성은 코퍼스 자기모순. **수리**: 무게중심을 "필드 선언"→"view 死분기"로 이동 · §3 원문 불변 · reviewer 2-조건 AND(writer 0 *전 VM·헬퍼* AND view 분기 실재 — 확장 copyWith·family 오탐 차단) · **backstop 기각**.
- **B(@freezed) 🔴 원안 결함**: backstop 원안이 **enum**(`weather_condition.dart` 수기 `fromJson`+`FormatException`·@freezed *불가*·@JsonValue가 정도)·`@JsonKey(fromJson:)` 컨버터(impl-dart §140 허용)·생성 `.g.dart` call-site·도메인 `*Exception`(`requireSevenDays()` invariant)을 **오발**. **수리**: 2-detector 분리(A=@freezed presence·B=수기 직렬화) · 전역제외(.g/.freezed/exception.dart/enum/DataSource) · 클래스-자신-factory만 타깃 · positive-control 거짓-FAIL 반증 게이트.
- **C(G-8) 🟡 둘 다 기각**: c2(코퍼스 노트)=설계문서 §B(`:43-44`)가 이미 기각한 *eval↔코퍼스 결합·과적합* 재림 + 정당 카피개선 위축. c1(정규화)=동결 strict-match를 N=1로 무름 + A13-4 "시각등가 허용대역"으로 미끄러질 입구 + N7/G-8은 본디 *enum→라벨 오배치*를 막지 공백이 아님. §2.2가 이미 보수FAIL+인간큐로 처리 → **변경 없음**.

## 시술 기록 (2026-06-18 적용·미커밋 — 코퍼스 불변 방침상 사용자 승인 후 작성)

사용자 승인(권장 방향)으로 항목 1·2 적용. **코퍼스 편집 + 백스톱 신설**이라 커밋은 사용자 요청 시.

**적용 범위**
- **ST-2**(항목 1): `architecture-state/references/final.md` §4에 死분기 정의 1문장(필드 선언 무해·view의 `state.error` 분기가 死) + `discipline-reviewer` §3 **2-조건 AND 트리거**(writer 0 ∧ view 분기) — claude `agents/`·codex `skills/dddart-discipline-reviewer` **양판**. §3:56/:59 원문·RUBRIC ST-3 **불변**(모순 회피). 死필드 backstop은 적대검증대로 **불채택**(결정성 없음·fixture 과발동).
- **@freezed b1**(항목 2): `architecture-ddd/references/final.md` §3 직파싱 bullet을 **명령형+범위명시**(entity·VO는 @freezed+json_serializable·모델 자신의 수기 fromJson/`_read*`/모델 내 FormatException 금지·enum[@JsonValue]·`@JsonKey` 컨버터·도메인 `*Exception` 제외).
- **@freezed b2 백스톱**(항목 2): `scripts/src/check_models.dart` 신설(**MD1** @freezed presence·**MD2** 수기 직렬화) + `backstop.dart` 배선(import·`familyOn('md')`·`_totalChecks` 55→**57**·docstring). **양 엔진 byte-copy**(claude `dddart/scripts/`·codex `codex-dddart/skills/dddart/scripts/`).

**적용 중 정밀화(설계 정합)**
- b1은 **architecture-ddd §3 단독** — "한 주제 한 소유자"상 data §4는 modeling을 ddd에 위임(미수정), State는 architecture-state §3 "항상 freezed"가 이미 명령(중복 회피).
- **MD2 트리거 = handFromJson ∨ handReader** — 독립 `FormatException`은 `@JsonKey` 컨버터 오탐 우려로 *트리거에서 제외*(메시지에 신호로만 병기).
- positive-control는 pubspec 부재(부분 프로젝트)라 **임시 프로젝트 래핑**으로 반증.

**검증 증거(자기보고 불신·실측)**
- 구문 `dart analyze` clean.
- **CATCH**: codex 6차 → **9 MD**(MD1 7: States 2·VO 2·entity 1·root 2 / MD2 2: daily_forecast·daily_forecast_summary) — SD-4/DT-4/ST-3 기계 포착.
- **NO-FP**: claude 6차 @freezed → **MD 0**.
- **positive-control 거짓-FAIL 반증**: known-good(notice BC·@freezed) 전수 → **blocker 0**(MD 0). README:34 게이트 충족.
- **회귀**: `run_fixtures.sh` **17/17**(F13 MD 픽스처 신설 — 수기→MD1+MD2·@freezed→침묵).
- **미러**: `corpus_mirror_sync.py` **11/11 in-sync** · reviewer 양판 bullet 동일 · codex 백스톱 **파리티**(57종·codex 6차 9 MD·claude 6차 0 MD).

**미러 경로·산문 정합**
- final.md(architecture-state·ddd) → `--write`(src splice + codex 복사). reviewer/dddart SKILL/command/corpus_mirror "55종"→"**57종+모델**" **5곳** 갱신. **결과지·feedback-006/008·design-doc의 "55종"은 과거 측정·기록이라 보존**(measure-first·소급 금지). `workspace/flow/dddart-timeline.html`(viz)은 후속.
- `run_fixtures.sh` F13은 claude 전용(codex test/ 미러 없음 — 기존 비대칭).

**적대검증 2차(구현 후·3렌즈·~273k subagent tokens)**
- lane 2(문구)·lane 3(완전성/미러) **견고 통과** — 계획↔구현 일치(18파일)·신규 모순 없음·미러 byte-동일·`corpus_mirror` 11/11·State @freezed는 architecture-state §3가 기명령(b1 범위결정 정당)·55→57 완전. known-good enum(`notice_category.dart`)이 수기 fromJson+FormatException인데 MD 침묵 = enum 카브아웃 실증.
- lane 1(백스톱 코드)이 **MD2 `handReader` FP 1건 적발**(important·잠복): `@JsonKey(fromJson: _readX(Map<…>))` 합법 컨버터(스펙 면제)를 `_read\w+\(Map<`가 오발. **수정 적용**: `handReader`를 `!hasGenFromJson`로 게이트(컨버터는 `_$XFromJson` 생성 위임 보유 → 제외; 수기 모델은 위임 없어 그대로 발화) + **F13에 `@JsonKey` 컨버터 케이스 추가**(회귀잠금). 재검증: analyze clean·run_fixtures **17/17**·CATCH codex 9 MD·NO-FP claude 0·양판 check_models byte-동일.
- lane 1 독립 재현으로 CATCH/NO-FP/fixtures/byte-동일 숫자 전부 확인(자기보고 불신 충족).

**DT-5 적대검증·적용(후속·1렌즈·~107k tokens)**
- 차분 확정: WEAK 문구공백·규칙 byte-동일·codex 4곳 seam(`{Dep? dep}) : _x = dep ?? Default()`)·claude 0곳. 스켑틱 판정 = **b1 코퍼스+reviewer 채택·b2 백스톱 기각**.
- 근거: ① 테스트 대안(Dio목+VM override+도메인직접 = implementation-test §2 A/B/C) **실재 확인** → b1이 불가능 요구 아님(feedback-008:39이 동일 이슈 기해소). ② DT-5는 🟡 채점자 split이라 런-차단 백스톱은 과집행 + measure-first(README:35) + N=1 위배. ③ b2 원안은 `?? *Service()`·메서드 param 오탐(probe 실증).
- **적용**: architecture-state §2·architecture-data §1에 경계 명문화(**위치 인자 직접전달 정당**·선택적 주입 seam 금지·테스트는 VM override/Dio목) → `--write` 양미러(11/11) + discipline-reviewer §6 DI seam 트리거(양판 byte-동일). **백스톱 무변경(57종 유지)**.
- b2는 **N≥2 재발 시** init-list 한정 정규식(`Service` 제외)+positive-control 반증 후 승격 후보.

## 회차 요약 (검증 런 후 — 7차)
*(검증대기 — 다음 라이브런 후 작성. 예상 적중 N/M·무효 N·⚠️역효과 N)*

## 미해결 (검증·후속)
- **DT-5**(항목 4): 차분·적대검증 **완료** — b1(경계 명문화)+reviewer §6 적용(양미러). **b2 백스톱은 N≥2 재발 시** init-list 한정 정규식(`Service` 제외)+positive-control 반증 후 승격 후보(현재 🟡·measure-first·N=1로 보류).
- **@freezed backstop 구현 결정**(항목 2): regex vs AST(custom_lint) — Detector A/B의 "클래스 자신 factory 본문" 판별 정확도. positive-control 16/16 + @freezed 표본 비발동 사전 반증 필수.
- **항목 1 reviewer 트리거 = 가이드(비기계)** — 7차 실측이 死분기 재현 시 결정성 확보 재검(현재 결정레인 사각).
- **finalize-collapse**(항목 5): codex-dddart 마무리 스킬 설계 — 별도 트랙.
