# feedback-032 — hive 배치 재설계: data_source/local_storage/ 하위층 정식화 + HV1 신설 (v2·적대 리뷰 반영)

## 메타
- **회차**: 032
- **트리거**: broccoli_app 라이브런(dddart 1.1.0, 신규 shared BC `managed_copy` — 프로젝트 최초 hive 도입)에서 NM3 오탐 blocker. 외부 리포트 `dddart-nm3-hive-gap-report.md`(broccoli_app 세션 산출 — 본 저장소 `results/` 결과지 아님, 도구 갭 리포트).
- **베이스 코퍼스**: `3fa2dd2`
- **시술 커밋**: `<미커밋>` (2026-07-20 작업 트리 적용 완료 — 커밋은 사용자 승인 후)
- **검증 런**: (다음 hive 채택 라이브런 후 채움)
- **상태**: 🔧적용·검증대기(v2 — 시술 전 적대 리뷰 3렌즈 반영)

## 시술 결과 (2026-07-20 — 픽스처·미러 검증, 라이브런 실측은 ⑥에)

- 백스톱: `check_naming.dart`(local_storage 종류 등재·`_local_data_source` 이동·exemptHive 삭제·헤더 주석)·`check_structure.dart`(ST6 data_source 하위 경계 2분기)·`check_hive.dart` 신설(HV1)·`backstop.dart`(배선·60종·usage `md,hv`) — `dart analyze` 0건.
- 픽스처: F26(a flat 배선→NM1 / a2 flat 접근→NM1 / b 완전골격+local_storage 3파일→st·nm·hv green / c box명 불일치→NM3 / d 하위 폴더 2종→ST6)·F27(a 무어노테이션→HV1 / b freezed 병용 무발화 / c common 범위 반증 / d 레거시 래칫) — **전체 56/56 PASS**(F1~F25 무회귀). positive-control은 lib 사본 수동 실행(`--all --only hv`)으로 무발화·60종 표기 확인(스위트 밖 1회성 — 스위트 내 반증은 F26b·F27b/c/d가 담당).
- 문서: houserules final.md 7사이트+SKILL(평면 예외·§7.2 표 3행·트리·import 예외·carve-out·drift 표)·architecture-data final.md 4사이트+SKILL(§1 표·§4 소속·§5 재작성·어휘 대조)·implementation-flutter §5(3파일 분리 예시·registrar 금지 불릿·:177 "향후 후보" 유지)·commands/dddart.md(:154 3파일·:163 60종). architecture-state 3곳은 경로 무언급 확인 — no-op.
- 미러: `corpus_mirror_sync --write→--check` 11/11 in-sync·codex scripts 4파일(수정 3+신설 check_hive.dart 1·common.dart는 무변경 확인) 바이트 동일(diff -q)·codex SKILL 3종(orchestrator·houserules·architecture-data)+design-review-data 수동 양판.
- 잔존 인용: `data_source/<bc>_hive_adapters`·`data_source/<개념>_local_data_source` — dddart/·codex-dddart/·workspace/reference/ 0건(external.md·review.md는 연구 스냅샷이라 제외). 57·58종 표기 0건.
- **사후 독립 리뷰(계획 정합 전수 대조·검증 5종 재현)**: Critical 0·Important 1(implementation-flutter §5:147 "@GenerateAdapters 양립 불가" 근거의 구모델 잔재 1문장 — box 파일 분산 선언으로 교정·재동기)·Minor 5(HV 헤더 관례·F26a 단언 ID 조임·원장 계수 2건 정확화 — 반영 / fix README 018~031 갭 표기 = 의도적 스코프 밖 기재 / 배선 파일 클래스 0 무단속 = 위 보류 등재). 판정 "With fixes → 교정 완료".

## 배경 — 왜 "면제 보강"이 아니라 "배치 재설계"인가

리포트의 원안은 NM3에 NM1과 대칭인 `exemptHive` 한 줄 추가였다. RCA를 파니 뿌리가 더 깊었다: 규약이 `<bc>_hive_adapters.dart`를 "@HiveType 모델 여러 개+등록 함수 조립 파일"로 강제하는데, 이 형태는 NM1(폴더↔접미사)·NM3(한 파일 한 클래스)를 **둘 다 면제받아야만 존재 가능**하다 — 배치가 하우스 문법과 충돌한다는 신호. hive는 접근(로컬 출처)·스키마(@HiveType 모델)·배선(어댑터 등록)의 묶음인데 셋을 data_source 평면에 섞은 것이 원인이다.

사용자 결정(2026-07-20): hive 전부를 data_source 하위의 역할명 폴더 **`local_storage/`** 로 이동. 스키마는 파일당 1모델(`<개념>_box.dart`), 배선은 등록 함수 전용 파일. 이러면 box 파일은 파일명=클래스명이 자연 성립하고 등록 파일은 public 클래스 0개라 **NM1·NM3 면제가 소멸**한다(원 사건의 NM3 오탐은 면제 추가 없이 구조로 해소). hive 전용 스킬 신설은 기각 — 지식 소유권은 implementation-flutter §5·architecture-data §5·houserules 3-분할로 완결, 문제는 규율 부재가 아니라 백스톱 무지였다.

```
infra_layer/data_source/
  <개념>_data_source.dart           # 원격 출처만 평면에
  local_storage/                    # 로컬 저장 모듈(접근+스키마+배선)
    <개념>_local_data_source.dart   # 로컬 출처(box 접근)
    <개념>_box.dart                 # @HiveType 스키마 — 파일당 1모델, 클래스 <개념>Box
    <bc>_hive_adapters.dart         # 등록 함수만(시동 배선) — public 클래스 0
```

## 시술 전 적대 리뷰 (3렌즈 서브에이전트 — v1→v2 정정)

관례(feedback-005 적대리뷰·feedback-010 시술직전 적대 v2)대로 시술 전에 코퍼스 모순·과적합·실효성 3렌즈 병렬 적대 리뷰를 수행했다. 주요 발견과 처분:

| 렌즈 | 발견 | 처분 |
|---|---|---|
| 과적합 P0 | HV2(@HiveType 위치)·HV3(typeId 유일)는 미측정 예방 검사 — 특히 HV3는 box 1개뿐인 현 시점 원리상 측정 불가. 기존 검사 신설은 전부 측정 구동(MD=6차·RV=7차 실측) | **HV1만 신설(예방적 표기)**, HV2·HV3 보류 강등(아래 보류 목록). §5:177 "향후 후보" 문구 유지(확정 표기 철회). 총계 62→**60종** |
| 코퍼스 P0 | "infra는 평면" 명시 문언 4곳(houserules final:119·SKILL:20·arch-data:23·ST6 메시지)이 계획 갱신 목록에 부재 — hive 토큰이 없어 grep 사각 | 4곳 전부 "data_source/local_storage/ 1단 예외" 명문화를 편집 목록에 추가 |
| 실효성 P1 | `_local_data_source.dart`의 문서 마이그레이션 누락(houserules §7.2 표 :193·:257·:283·arch-data :116) — coder가 표대로 flat 생성 시 **원 사건과 동종의 NM1 오탐 재도입** | 전 사이트 편집 등재 + §7.2에 box·배선 행 신설 + F26에 flat local 위반 케이스 + 검증 grep에 `_local_data_source` 포함 |
| 코퍼스 P1 | 검증 grep이 편집 범위 밖 `workspace/reference/**/external.md:332`와 자기모순 | 검증 grep에서 `external.md`·`review.md` 제외(연구 스냅샷 — 갱신 대상 아님) |
| 과적합 P0 | `_box.dart`→`<개념>Box` 자동 강제(NM3 결합)는 예시(`ChannelBox`)의 규약 격상 — 실물 2건(HaffHaff `MemberHive`·broccoli `LoadingCopyHiveModel`)이 다른 명명 | **유지·명시 결정으로 기록**: 실물 2건은 무규약 시대 명명이라 규약 반증이 아니고, "Box 모델"은 규율 자체의 용어(architecture-data:121·implementation-flutter §5 전편)이며, 하우스 문법(폴더=파일 접미사=클래스 접미사·NM3 상시 강제)상 "접미사 비강제" 선택지는 존재하지 않는다 — 접미사 선택의 문제일 뿐이고 코퍼스 근거는 Box가 유일 |
| 과적합·코퍼스 P1 | `local_storage` 어휘는 코퍼스 무전례 발명 + `common/local_database`와 근접 혼동 | 채택 사유 기록(아래 결정 기록) + houserules에 2층 어휘 대조 1줄 명문화 |
| 과적합 P1 | ST6 확장 중 repository/·service/ 하위 금지는 실증 0 예방 조임 + "평면 정합" 자기 오라벨 | **data_source 하위(local_storage만 허용)+local_storage 하위 금지로 축소** — 신설 예외의 경계 정의만. 형제 금지는 보류. 정당화 문구를 "1단 예외의 결정적 번역"으로 교정 |
| 실효성 P2 | F26b가 ST4 골격 요구(analysis_options.yaml 포함)를 은폐 — 거짓 FAIL 위험. "전 패밀리 green" 과대 | F26b = 완전 골격+analysis_options.yaml+local_storage 3파일, `--only st,nm,hv` 한정. "전 패밀리" 철회 |
| 실효성 P2 | exemptHive 삭제 시 **비게이트 모드**(`--all`·비git)에서 레거시 flat 조립 파일 NM1 발화 | 의도된 동작으로 기록 — gated 주입(diff-base)이 정답 경로(백스톱 설계 §8). gated에서는 added 게이트가 레거시 면책(리뷰 실측 확인) |
| 실효성 P2 | HV1 한계: 기존 box의 @HiveType *삭제* 회귀(비added) 미탐 · 무스키마 저장(`Hive.box<Map>` 원시 저장)은 HV 전체 우회 | 한계로 명기 — 전자는 added 래칫 수용 한계, 후자는 결정적 검사 불가(discipline-reviewer 의미 감사 몫). 승격 후보: "local_data_source가 openBox하는데 형제 `_box.dart` 0개" 휴리스틱 |

리뷰가 방어 확인한 것(요지): NM3 자연통과 성립(등록 파일 decl 0·box 파일명=클래스명), IM 전 검사 경로 무의존(IM6 basename 호환), MD·ST4·TG1 무충돌, gated 레거시 무회귀, 우회 벡터(비접미사 스키마→NM1·가짜 엔티티→MD1) 차단, codex 미러 현재 바이트 동일.

## 결정 기록 (발명·격상의 명시 방어)

- **`local_storage` 폴더명**: 사용자 결정(2026-07-20, 기술명 `hive/` 대신 역할명·접근 포함 전부 이동). `hive/` 기각 사유 = 역할 기반 폴더 문법(view_model·use_case…) 유지. `local_database` 기각 사유 = common 층 폴더와 동명이면 로컬 2층(BC 캐시 vs 엔진·전역)이 폴더명으로 구별 불가 — 이름 대비가 2층 구분을 어휘로 고정한다(houserules에 대조 1줄 명문화).
- **`_box.dart`/`<개념>Box` 규정 격상**: 위 적대 리뷰 처분 참조. §7.2 표·implementation-flutter §5에 예시가 아닌 규정으로 명문화한다.
- **houserules "한 파일 주 클래스 하나" 예외 등재는 no-op** — 새 구조에서 등록 파일은 클래스 0개, box 파일은 1개라 원칙 위반이 발생하지 않는다.

## 교정 항목 (사전등록 표 — 고치기 전 ①~④ 작성, 다음 런 후 ⑤~⑥)

| # | 우선 | ① 대상 결함(dim·FC골든) | ② 원인(뿌리·코퍼스 어느 책무 공백) | ③ 처방(어느 코퍼스 파일·미러경로) | ④ **예상효과**(전→후) | ⑤ 시술커밋 | ⑥ 실측·판정 |
|---|---|---|---|---|---|---|---|
| 1 | P0 | NM3 오탐 blocker — 규율대로 담은 hive 조립 파일에 발화(broccoli_app 실측, 매 hive 빌드 수동 판정 강요) | 규약이 조립 파일을 강제 → NM1·NM3 이중 면제 필요 배치. 백스톱 설계(2026-06-12) NM3 예외 목록에 hive 누락은 그 증상 | 배치 재설계: `architecture-data`(:23·:28·:107·:116·§5)·`implementation-flutter` §5·`discipline-houserules`(:67·:119·:193·:236·:241·:257·:283·SKILL:20)·`commands/dddart.md:154`(3벌·양판 미러) + `check_naming.dart` local_storage 종류 등재·`exemptHive` 삭제 + ST6 data_source 하위 경계(백스톱은 codex 사본 바이트 동기) | 다음 hive 채택 런에서 NM1·NM3 오탐 0(새 구조 green) — F26b가 결정적 재현. flat 배치는 NM1이 정당 발화(F26a·a2) | | |
| 2 | P1(예방적) | `_box.dart` 신설 파일종의 정체 무검사 — @HiveType 없는 box 파일이 유령 종류가 됨. **측정 dim 없음(예방적 — 신설 파일종의 구조 정의, MD1 동형)** | 신설 종류에 내용 계약 검사 부재 | `check_hive.dart` 신설 **HV1**(local_storage/ 안 added `_box.dart`에 `@HiveType\(` 부재 → 발화) + `backstop.dart` 배선 + F27 픽스처 | F27 전 서브케이스 PASS·positive-control `--only hv` 무발화. 라이브런 dim은 없음 — 다음 hive 런에서 오탐 0 유지 관찰 | | |
| 3 | P1 | data_source 하위 디렉터리 미탐 갭 — 신설 예외(local_storage)의 경계가 무단속이면 임의 하위 폴더가 합법화됨 | ST6 구현이 `s.length == bi+3`에서 멈춤 — 종류 폴더 하위는 무단속 | `check_structure.dart` ST6 확장: **data_source 하위는 `local_storage/`만 허용, local_storage 하위 디렉터리 금지**(repository/·service/ 하위는 보류 — 실증 0) | F26d(`data_source/junk/`) ST6 발화·F26b(local_storage) 무발화 | | |
| 4 | P2(예방적) | `lib/hive_registrar.g.dart` footgun — hive_ce_generator 자동 생성 무가드 전역 `Hive.registerAdapters()` 확장이 미사용 stray로 잔존(broccoli_app 실측), 호출 시 typeId 재등록 HiveError 위험 | implementation-flutter §5에 registrar 생성물 언급 자체가 없음(수기 국소 등록만 기술) | `implementation-flutter/references/final.md` §5에 호출 금지 불릿 명문화(등록 노출면은 `register<Bc>HiveAdapters()` 유일). build.yaml 억제 여부는 생성기 실측 후에만 기재 | 예방적(리포트 실측 기반이나 오호출 사고는 미발생) — 다음 hive 런에서 registrar 호출 0 유지 관찰 | | |
| 5 | P2(예방적) | design-review-data 절번호 drift — hive 근거를 "architecture-data §6"으로 인용(실제 §5, §6은 infra service) | 에이전트 지시문과 스킬 절번호 사이 수동 양판 미러의 drift | `dddart/agents/design-review-data.md:31` + codex `skills/dddart-design-review-data/SKILL.md:34` §6→§5 (수동 양판) | 예방적(측정 dim 없음) — 리뷰어 인용 정확성 | | |
| 6 | P2 | 검사 총계 표기 drift 3중 — backstop.dart 헤더 57·상수 58·주석 IM22(실측 59: ST12+IM23+NM17+CY1+TG1+PJ2+MD2+RV1) + README 58종·commands/discipline-reviewer/corpus_mirror_sync 57종 혼재 | 검사 신설 시 표기 사이트 목록이 없어 갱신 누락 반복 | HV1 포함 **60종** 일괄. 사이트 목록(재발 방지): `backstop.dart`(:2·:26·:56 usage `md`·`hv`) / `README.md`(5곳) / `AGENTS.md:18` / `dddart/commands/dddart.md:163` / `dddart/agents/discipline-reviewer.md:13` / `workspace/tools/corpus_mirror_sync.py:21` / codex `skills/dddart/SKILL.md:173`·`skills/dddart-discipline-reviewer/SKILL.md:14`·codex `backstop.dart` | 전 사이트 60종 일치(grep로 57·58종 잔존 0) | | |

## 보류 목록 (승격 조건 명기 — 측정된 결함만 처방)

| 보류 항목 | 승격 조건 |
|---|---|
| **HV2** — @HiveType의 `_box.dart` 밖 등장 금지(application/ 한정) | 다음 hive 라이브런에서 엔티티/비box 파일 @HiveType 오배치 실측 1건 |
| **HV3** — typeId 전역 유일 | box 2개+ 프로젝트 실측 또는 typeId 충돌 실측. 설계 노트(선등록): 리터럴 typeId만 결정적(상수 참조·인자 재배열 미탐 — 한계 명기 필수), `common/` 포함 여부는 "common 규율 침묵" 원칙과 정합하게 결정 필요 |
| ST6 repository/·service/ 하위 디렉터리 금지 | 해당 위치 하위 폴더 stray 실측 |
| 등록 완전성(등록 파일이 형제 `_box.dart` 전부 import)·멱등 가드(isAdapterRegistered)·registrar 호출 금지 검사·무스키마 저장 휴리스틱 | 다음 hive 라이브런 실측 |
| 배선 파일 "클래스 0" 무단속(`<bc>_hive_adapters.dart`에 동명 public 클래스를 넣으면 NM3 자연통과 — 사후 리뷰 발견) · IM6 신구조 경로 픽스처(root_initializer→local_storage 배선 무발화는 리뷰 라이브 프로브로 검증됨·스위트 미고정) | HV2 승격 회차에 동반 |
| `common/local_database` 층의 @HiveType 소속 규율 | 코퍼스 침묵 유지(모순 금지) — 별도 회차 |

## broccoli_app 마이그레이션 이동 맵 (별도 저장소 작업 — 가이드만)

| 현행 (managed_copy BC) | 새 구조 |
|---|---|
| `infra_layer/data_source/managed_copy_hive_adapters.dart` 안 `LoadingCopyHiveModel` | `infra_layer/data_source/local_storage/loading_copy_box.dart`의 `LoadingCopyBox`(파일당 1모델·파일명=클래스명) |
| 같은 파일 안 `registerManagedCopyHiveAdapters()` | `infra_layer/data_source/local_storage/managed_copy_hive_adapters.dart`(등록 함수만 잔류) |
| `infra_layer/data_source/managed_copy_local_data_source.dart` | `infra_layer/data_source/local_storage/managed_copy_local_data_source.dart` |
| `lib/hive_registrar.g.dart` (자동 생성 stray) | 미사용 유지(호출 금지 — §5 명문화). 억제 방법은 생성기 실측 후 |

root_initializer의 import는 basename 불변(`managed_copy_hive_adapters.dart`)이라 경로만 갱신. 비게이트(`--all`) 스캔은 마이그레이션 전 레거시 flat 파일에 NM1을 낼 수 있다 — gated(diff-base) 실행이 정답 경로.

## 회차 요약 (다음 런 후)
- 예상 적중 **N/M** · 무효 **N** · ⚠️역효과/신규회귀 **N**
- **한 줄 결론**:
- ⚠️ N=1 인과 단정 금지 — "처방 X가 회귀 Y를 *유발*"이라 쓰지 말고 "X 적용 후 Y 관찰(동시발생)"로 기록.
