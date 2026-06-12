# dddart 백스톱 스크립트 설계 (§10-2)

- 상태: **확정(2026-06-12) — 적대 점검 2렌즈(HaffHaff 실물 픽스처) 반영 + 사용자 확정(§11 4건 전부 권장대로). 구현 시점만 미결**
- 입력: 제1 규약 `2026-06-11-dddart-file-tree.md`(확정) · 본설계 `2026-06-12-pipeline-design.md` §10(확정 요구사항) · 파이널 리뷰 §5 불변식 39종 · dddjango 스크립트 16종 실물 · 적대 점검 발견(P0 5·P1 16·P2 다수 — 전부 반영, §11에 잔여 결정)
- 산출물(이 문서가 사양인 것): **러너 1개 + 검사 패밀리 4개(51종) + extract_contract** — 구현 시점(즉시 vs §10-4와 함께)은 사용자 결정.

---

## 1. 원칙 (dddjango에서 승계하는 것 / 바꾸는 것)

**승계 — 규약과 철학:**

- **고정밀 저-recall**: 거짓양성 ≈ 0이 목표. 확신 없는 패턴은 검사하지 않고 에이전트(discipline·리뷰어) 영역으로 넘긴다. 백스톱 통과가 의미 점검을 면제하지 않는다(본설계 §6-4).
- **종료코드 규약**: `0`=clean / `1`=사용·내부 오류 / `2`=blocker. blocker는 전 검사 발견을 합쳐 일괄 출력(fail-fast 금지 — 한 번에 반송).
- **검사마다 자기완결 문서화**: *왜 결정적 백스톱인가*(에이전트가 못 잡는 이유) · 거짓양성 게이트 · 위반 시 교정 방법을 구현 파일 문서주석에 담는다(dddjango check-*.py 양식).

**변경 — 근거를 옮기고 산출물은 버린다:**

| dddjango | dddart | 근거 |
|---|---|---|
| Python (대상 환경이 보장) | **Dart, 코어 라이브러리만** (`dart:io`·`dart:convert`·내장 RegExp·`Process.run`) | 대상 = Flutter 프로젝트 → `dart` SDK 100% 보장, Python은 무보장(특히 Windows). pubspec 불요 — `dart run` 단독 실행 |
| 1검사 = 1스크립트 16개 (검사가 이질적 의미론) | **검사 패밀리 4개 = Dart 라이브러리, 러너 = 단일 엔트리, 인프로세스 실행** | dddart 51종은 동질적·기계적(경로·import·명명) — 같은 순회·파서·게이트 공유. Dart VM 기동(~1초)을 1회로 상각 |
| `git status --porcelain`만 (작업 트리 기준) | `git diff <스냅샷>` + porcelain 합집합 (§3) | 파이프라인이 슬라이스 green마다 커밋(본설계 §6-2-1)하므로 작업 트리만 보면 커밋된 변경을 놓친다 — build-state.json의 Phase 2 진입 스냅샷이 정확한 기준점 |

**스크립트는 파이프라인 상태를 모른다**: build-state.json을 읽지 않고 모든 컨텍스트(diff 기준점·대상 경로)를 인자로 받는다 — Coordinator가 호출 시 주입. 스크립트의 지식 = git + 파일시스템 + 제1 규약뿐.

## 2. 파일 구성·실행 인터페이스

```
dddart/scripts/
├── backstop.dart            # 러너 엔트리 — 인자 해석·게이트 계산·검사 실행·집계·종료코드
├── extract_contract.dart    # G1 계약 절단 엔트리 (§7 — 백스톱과 별개 도구)
└── src/
    ├── common.dart          # 파일 수집·전처리(주석/문자열)·import 파서·git 연동·발견 모델·리포트
    ├── check_structure.dart # ST 12종 — 구조·경로
    ├── check_imports.dart   # IM 22종 — import 방향
    ├── check_naming.dart    # NM 16종 — 식별자·명명
    └── check_cycles.dart    # CY 1종 — BC 순환 래칫
```

```
dart run <플러그인>/scripts/backstop.dart <대상 프로젝트 루트> \
  [--diff-base <commit>]     # Phase 2 진입 git 스냅샷 해시 (Coordinator가 build-state.json에서 주입)
  [--all]                    # 게이트 무시 전역 검사 (수동 감사용 — §3 폭주 주의)
  [--only st,im,nm,cy]       # 패밀리 선택 (검사 ID 단위도 허용: --only IM5)
  [--update-baseline]        # 순환 래칫 베이스라인 명시 갱신
```

- **출력**: 검사 ID별 발견 블록(§6 양식) → 요약 줄(`N개 검사, M건 blocker`) → 종료코드.
- **전제 확인**: 대상에 `pubspec.yaml`·`lib/` 없으면 exit 1. 패키지명은 pubspec `name:`에서 1회 읽어 `package:<self>/` import 해소에 사용.

## 3. 게이트 의미론

변경 집합(러너가 1회 계산, 전 검사 공유):

- 수집 명령: `git diff --name-status -z <diff-base>`(작업 트리 vs 기준점 — 미커밋 포함) ∪ `git status --porcelain -z --untracked-files=all`. **`-uall` 필수** — 기본값은 미추적 디렉터리를 `?? lib/` 한 줄로 접어 **신규 BC 전체가 added에서 누락**된다(적대 점검 P0, git 실증). `-z`(NUL 구분)로 공백·인용 경로 파싱 고정.
- **touched** = 위 합집합 중 **파일시스템에 현존하는 경로**만 (상태 `D`와 리네임의 old 경로는 제외 — 삭제 파일 검사 시도는 내부 오류의 원인).
- **added** = diff 상태 X열 ∈ {A} ∪ porcelain `??` ∪ 리네임(`R*`)의 새 경로. (`AM`류 2글자 코드는 X열 기준 — 적대 점검 P1.)
- **added 디렉터리** = `git ls-tree -r <diff-base>`에 그 경로 하위 파일이 0개인 디렉터리 (added 파일 포함 여부가 아님 — 레거시 디렉터리에 새 파일을 추가해도 그 디렉터리는 added가 아니다. "신규 단위" 판별의 일반화이며, modified 레거시 면책 의미론과 정합).
- **added 줄** = `git diff -U0 <diff-base> -- <파일>`의 `+` 줄 (미추적 파일은 전 줄).

| 게이트 | 적용 | 의미 |
|---|---|---|
| **A**dded | ST(골격 제외)·NM 전부 — added 파일·added 디렉터리 기준 | 새로 만든 것만 — 레거시(HaffHaff drift류)에 불발화. 본설계 §10 확정 |
| **T**ouched+added줄 | IM 전부 — touched 파일의 **added 줄에 등장하는** directive·토큰만 | "위반 import의 *추가*"를 잡는다 — 레거시 파일에 한 줄을 수정해도 기존 위반 import에 불발화(적대 점검 P2: 파일 단위 touched는 레거시 수정 시 blocker 폭주 → 반송 불능) |
| **U** 신규 단위 | ST4(골격 완비) | 신규 BC·애그리거트·개념 폴더·root·design_system이 생긴 경우만 그 단위의 완비를 검사 |
| **G** 전역+베이스라인 | CY1(순환 래칫) | 순환은 두 BC의 합작이라 touched 한정 불가 — 전 BC 그래프 + 베이스라인 동결로 레거시 면책 |

- `--all`: added·touched를 "전 파일·전 줄"로 치환(신규 단위·베이스라인 의미론은 유지). **레거시 프로젝트에서는 발견 폭주가 정상** — 파이프라인 게이트 용도가 아니라 수동 감사 용도.
- **비git 폴백**: 게이트 계산 불가 → 전역 검사로 퇴화 + ST4 생략(신규 단위 판별 불가) + 첫 줄 고지. 레거시 비git에서는 사실상 운용 불능이므로 **G0 전제조건에서 `git init`+초기 커밋을 제안**하는 것이 정답 경로(§11 본설계 개정 후보 ③).

## 4. 공통 기반 (`src/common.dart`)

1. **파일 수집**: `lib/**/*.dart`. 제외 — `*.g.dart`·`*.freezed.dart`(codegen part), **`lib/firebase_options.dart`**(flutterfire 생성물 — NM3 거짓양성 실증), `.dart_tool/`·`build/`. 제1 규약 §7.1-1의 codegen 예외와 일치.
2. **전처리 — 주석·문자열 마스킹**(적대 점검 P1 승격): 라인 주석(`//`)·블록 주석(`/* */` — **상태 추적 필수**, 줄 단위 정규식은 블록 주석 내부 줄을 directive로 오인)·문자열 리터럴(`'`·`"`·triple·raw)을 마스킹하는 패스 1개를 두고 **directive 파서(주석만 제거한 본문)와 토큰 검사(주석+문자열 제거한 본문)가 공유**한다. 이것이 없으면 "교정 주석의 `BuildContext` 토큰 → 재차 blocker" 반송 무한 루프가 생긴다.
3. **import 파서**: 주석 제거 본문에서 `^\s*(import|export)\s` directive를 `;`까지 읽어 따옴표 URI 전부 수집(조건부 import의 다중 URI 포함, 이중 따옴표·raw 허용). `part`는 수집하되 **import 간선으로 취급하지 않는다**(`part of <라이브러리명>;`은 URI 0개로 무해 — HaffHaff part 479건 전수 인용형 실측).
4. **경로 정규화**: 상대 URI 해소는 RFC join이 아니라 **lib/ 루트 클램핑** — Dart package URI 의미론과 동일하게 잉여 `../`는 lib/에서 멈춘다. (적대 점검 P0: HaffHaff에 깊이 초과 상대 import 9건 실존·정상 컴파일 — 나이브 정규화는 lib/ 밖 경로를 산출해 IM 전 검사가 침묵하고, `../` 하나로 IM을 우회하는 회피 벡터가 된다. 8단 실물을 단위 픽스처로 채택.) `package:<self>/…`도 같은 정규화 — 이후 모든 IM 검사는 정규화 경로 하나로 판별.
5. **경로 술어**: 세그먼트는 **정확 일치**(`/view/`가 `view_model/`·`overview/`에 비매칭 — 검증 완료). BC 판별은 `lib/application/` 다음 **경로 성분** 비교(문자열 접두 비교면 `chat`이 `chat_request`를 자기 BC로 오인). 종류 폴더 판별은 개념 폴더 1단 아래에 동일 적용(§4 성장 규칙) — **ST·NM의 모든 경로 술어에 공통**.
6. **토큰 검사 공통**: 마스킹 본문에서 멀티라인 호출은 **괄호 균형 스캔**으로 첫 인자 추출(NM9·NM13 공유 — 줄 단위 캡처는 멀티라인 호출에서 빈 인자를 잡아 오판).
7. **발견 모델**: `{checkId, severity(blocker), path, line?, message, rule(제1 규약 조항), fix}`.
8. **보조 진단**(blocker 아님): 계층 직속의 비종류 디렉터리가 종류명과 편집거리 1 이내면 "종류 폴더 오타 의심" 경고 병기(ST4가 오타 폴더를 '신규 개념 폴더'로 오분류해 오도 메시지를 내는 것 방지).

## 5. 검사 사양 시트 — 51종

> 원# = 파이널 리뷰 §5 번호, 추# = 본설계 §10 추가 4건, 매# = 제1 규약 §3.7 매트릭스 보충(적대 점검 P0 — "백스톱 검사 대상" 선언인데 39종 목록에 미번역이던 행), 신# = 적대 점검 신설. 게이트: §3의 A/T/U/G. 모든 발견은 blocker(exit 2).

### ST — 구조·경로 (12종, `check_structure.dart`)

| ID | 출처 | 게이트 | 판별식 | 예외·비고 |
|---|---|---|---|---|
| ST0 | 신 | A | `lib/` 직속 added가 화이트리스트 외 → 위반. 허용: `main.dart`·`firebase_options.dart`·4컨테이너 디렉터리(`root`·`application`·`common`·`design_system`) | lib/ 직속 사각지대 봉쇄(HaffHaff 떠돌이 `system_initializer.dart`가 실물). 규약 §2 트리의 기계 번역 — firebase_options는 규약 등재 후보(§11-①) |
| ST1 | 1 | A | `lib/application/` 직속에 added **파일** 존재 → 위반 (직속은 BC 디렉터리만) | — |
| ST2 | 2 | A | BC 직속 added 파일이 `<bc>_router.dart`·`<bc>_navigator.dart` 외 → 위반. **`<bc>` = BC 폴더명 바인딩** — 접미사만 맞는 타 BC명(`channel/` 안 `chat_router.dart`)도 위반 | — |
| ST3 | 3 | A | BC 직속 added 디렉터리가 4계층 표기(`domain_layer`·`application_layer`·`infra_layer`·`presentation_layer`) 외 → 위반 | `presentation_later`류 오타 자동 검출 |
| ST4 | 4 | U | 신규 단위의 골격 완비: BC=4계층+§5 전 종류 폴더, 애그리거트=`<agg>.dart`+5종 폴더, 개념 폴더=그 계층 종류 폴더 완비, root=4폴더+scaffold 3종, design_system=4폴더+foundation 7파일. 빈 폴더는 `.gitkeep` 필수 | `exception.dart`는 골격 대상 아님(§3.2). 파일시스템 기준 검사. 비git이면 생략+고지(§3). §4-8 오타 진단 병기 |
| ST5 | 5 | A | `domain_layer/` 직속 added가 `<aggregate>/` 디렉터리 외 → 위반. 애그리거트 폴더 안 added가 `<agg>.dart`·`exception.dart`·5종 폴더(`entity`·`value_object`·`enum`·`domain_service`·`specification`) 외 → 위반 | C5 해소 확정 반영(공용 위치 없음) |
| ST6 | 6 | A | 계층 직속(또는 개념 폴더 직속) added 디렉터리가 종류 화이트리스트 외 → 위반: app 5종 / infra 3종 / pres 4종. **infra 직속의 비종류 디렉터리(개념 폴더 포함) → 위반**(평면 유지 §4) | 개념 폴더는 app·pres만 허용 |
| ST7 | 7 | A | added 디렉터리명 deny: `app`·`bridge`·`block`·`viewmodel`·`repo`·`container` (BC 내부), `provider` (common 직속) | 구명칭 §8·§9-8 |
| ST8 | 8 | A | `lib/root/` 직속 added가 `router`·`scaffold`·`handler`·`initializer` 4디렉터리 외 → 위반(직속 파일 포함). `scaffold/` 직속 added 디렉터리가 `view`·`view_model`·`state` 외 → 위반 | 4폴더 하위의 개념 분할(§4 — `handler/<이벤트원>/`)은 허용 |
| ST9 | 9 | A | `root/` 이하 added 파일명이 `root_` 접두가 아니면 위반 | `.gitkeep` 제외 |
| ST10 | 10 | A | design_system: ⓐ `foundation/` added 파일이 7파일 외 ⓑ `theme/` added가 `app_theme.dart` 외 ⓒ `component/` 직속 added 파일 ⓓ `component/` added 디렉터리명 deny `widget`·`etc`·`common`·`misc` → 위반 | 새 토큰 종류가 필요하면 규약 개정이 먼저(단일 출처 보호) |
| ST11 | 11 | A | `common/` 직속 added가 `enum`·`network`·`local_database`·`service`·`util` 5디렉터리 외 → 위반(직속 파일 포함) | §6·§9-11 |

### IM — import 방향 (22종, `check_imports.dart`)

> 게이트 전부 **T**(touched 파일의 added 줄). 판별은 §4 정규화 경로·세그먼트 술어 기준.

| ID | 출처 | 판별식 | 예외·비고 |
|---|---|---|---|
| IM1 | 12 | `domain_layer/**`에서 `package:flutter/` 또는 **`dart:ui`** import → 위반 | dart:ui는 Flutter 없이 Color를 쥐는 표준 탈출구(적대 점검). freezed·json_annotation·dartz 자유 |
| IM2 | 13 | `lib/root/` 경로를 import하는 파일이 `main.dart` 외 → 위반 | importer가 root/ 내부면 제외(상호 import 자유 — §3.6) |
| IM3 | 14 | `common/**`에서 `application/`·`root/` 경로 import → 위반 | — |
| IM4 | 15 | `design_system/**`에서 `application/`·`root/` 경로 import → 위반 | — |
| IM5 | 16 | BC A 파일이 BC B(A≠B) 경로 import 시 허용 4채널 외 → 위반. 허용 target: ① domain **타입**만 — `/entity/`·`/value_object/`·`/enum/` 세그먼트·애그리거트 루트(`domain_layer/<agg>/<agg>.dart`)·`exception.dart` (**`domain_service/`·`specification/`은 deny** — 채널①은 타입이지 도메인 로직 실행이 아니다, §9-3) ② `use_case/` 세그먼트 ③ `<bcB>_navigator.dart` ④ presentation의 `/view/` 세그먼트 | root는 importer에서 제외(4채널 면제 — IM6·IM2가 담당). infra·view_model·shared_state·state·section·widget·ui_extension·router 자동 금지 |
| IM6 | 22 | `root/**` 파일이 BC `/infra_layer/` 경로 import → 위반 | 유일 예외: importer가 **`root/initializer/` 이하** ∧ target이 `*_hive_adapters.dart`(§3.4·§9-9 — 파일명 고정 대신 폴더 기준: §4 성장 규칙로 initializer가 분할돼도 유지) |
| IM7 | 17 | application의 `view_model/`·`shared_state/`·`service/` 파일이 `/infra_layer/`·`common/local_database/`·**`common/network/dio_client.dart`** import → 위반 | Model 방향은 UseCase만(§3.3). `common/network/`의 나머지(bad_request 등 에러 타입)는 합법 — HaffHaff 24곳+ 실측. use_case→infra는 합법이라 importer에서 제외 |
| IM8 | 18 | `section/`·`widget/`·`ui_extension/` 파일이 riverpod 계열(`package:flutter_riverpod/`·`package:hooks_riverpod/`·`package:riverpod*`) import 또는 본문 `WidgetRef` 토큰 → 위반 | dumb 보장(§3.5). 토큰은 마스킹 본문(§4-2) 기준 |
| IM9 | 19 | `widget/` 파일이 `application_layer` 하위 `state/` 세그먼트 경로 import → 위반 | 이중 조건으로 `shared_state/` 자연 배제(검증 완료) — widget의 shared_state는 IM8이 잡음 |
| IM10 | 20 | `<bc>_navigator.dart`가 `/presentation_layer/` import → 위반 | 라우트 이름만 참조(§3.1) |
| IM11 | 21 | `application_layer/**` 파일이 `/presentation_layer/` import → 위반 | §3.7 application→presentation ✗ (자기 BC 포함) |
| IM12 | 추③ 강화 | `application_layer/**` 파일이 `package:flutter/` import(**전면** — 예외: `package:flutter/foundation.dart`) 또는 본문 `BuildContext` 토큰 → 위반 | 적대 점검 P1: material.dart는 widgets.dart의 re-export — material·cupertino만 막으면 widgets.dart로 전량 우회(HaffHaff VM 8파일 실측). 전면 금지는 컨트롤러(TextEditingController 등)의 View 소유를 함의 — §11-④ |
| IM13 | 추②+21+§3.7 | `design_system/` import 허용 importer 화이트리스트 외 → 위반. 허용: `presentation_layer/**` · `root/scaffold/**` · **`*_router.dart`·`root_router.dart`**(§11-② 규약 1줄 확정 후보) · `main.dart` · design_system 내부 | §3.7 헤더의 기계 번역. router 포함 근거: GoRoute pageBuilder의 전환 토큰(AppDuration) — 제외 시 합법 라우터가 차단됨 |
| IM14 | 추① | `application_layer/service/**` 파일이 ⓐ `_navigator.dart` import ⓑ 본문 `.go(`·`.goNamed(`·`.pushNamed(` 호출 → 위반 | 내비는 VM만(§3.7), 플랫폼 이벤트발 내비는 root_destination_handler 소유(§3.6). `rootRouter.go(`는 root 소속이라 대상 밖(의도) |
| IM15 | +권고 | `application/**`·`common/**`·`design_system/**` 파일이 `main.dart` import → 위반 | 전역 인스턴스는 common 소속(§3.6·§6) |
| IM16 | 37 | `main.dart`의 import가 화이트리스트 외 → 위반: `dart:*` · `package:flutter/` · riverpod 계열 · **`package:flutter_localizations/`·gen_l10n 산출물(`package:flutter_gen/`·`l10n/`)** · self `root/**` · self `design_system/theme/app_theme.dart` | §3.6 본문의 기계 번역 + 지역화 앱 실전 보정(적대 점검 P1 — l10n 없인 합법 main이 blocker). **part directive는 대상 제외**(§4-3) |
| IM17 | 매 | `presentation_layer/**` 파일이 `/infra_layer/` import → 위반 | §3.7 pres→infra ✗ — *가장 흔한 계층 위반*(View→Repo 직행)인데 39종에 미번역이었다(적대 점검 P0) |
| IM18 | 매 | `infra_layer/**` 파일이 `/application_layer/`·`/presentation_layer/` import → 위반 | §3.7 infra 행 |
| IM19 | 매 | `domain_layer/**` 파일의 lib 내부 import 중 target이 `domain_layer` 하위가 아니면 → 위반 (application·infra·presentation·common·design_system·root 전부) | §3.7 domain 행 — "common은 전 계층 가능하되 domain만 예외". 타 BC domain은 IM5 ①이 추가 제약 |
| IM20 | 매 | application의 `use_case/`·`state/`·`shared_state/` 파일이 `_navigator.dart` import → 위반 | §3.7 "BC 루트는 **VM만**" — service는 IM14, 나머지 3종이 이 검사 |
| IM21 | 매 | `<bc>_navigator.dart`가 `/domain_layer/`·`/application_layer/`·`/infra_layer/` import → 위반 | §3.7 BC루트 행 — navigator의 합법 import는 자기 router(상수)·common·패키지뿐 (presentation은 IM10) |
| IM22 | 매 | `<bc>_router.dart`의 lib 내부 import 중 허용 외 → 위반. 허용: 자기 BC presentation의 `/view/` 세그먼트 · 자기 BC 루트 · design_system(IM13 허용 시) | §3.7 "router→view만(GoRoute builder), navigator 금지" — section·widget·application·infra·domain 차단 |

### NM — 식별자·명명 (16종, `check_naming.dart`)

> 게이트 전부 **A**(added 파일). 본문 검사는 §4-2 마스킹·§4-6 균형 스캔 적용.

| ID | 출처 | 판별식 | 예외·비고 |
|---|---|---|---|
| NM1 | 24 | 종류 폴더 안 added 파일의 접미사 불일치 → 위반. 긴 접미사 우선: `_shared_state` > `_state`, `_local_data_source` > `_data_source`. 맵: use_case=`_use_case` / view_model=`_vm` / state=`_state` / shared_state=`_shared_state` / service=`_service` / data_source=`_data_source`·`_local_data_source` / repository=`_repo` / view=`_view` / section=`_section` / widget=`_widget` / ui_extension=`_ui_extension` / domain_service=`_service` / specification=`_specification` / **handler=`_handler`**(root) | data_source의 `<bc>_hive_adapters.dart`는 명시 예외(§3.4). entity·value_object·enum은 개념명(접미사 검사 없음) |
| NM2 | 25 | added 파일명 접미사 deny: `_app.dart`·`_bridge.dart`·`_block.dart`·`_view_state.dart`·`_spec.dart`·`_btn.dart` | §8·§9-8 구접미사 |
| NM3 | 26 | added 파일의 top-level public 선언 **(수식어 무시: class·enum·mixin·extension type)** 2개 이상 → 위반. 1개면 이름 casefold(소문자·언더스코어 제거) ≠ 파일명 casefold → 위반. **plain extension·typedef·전역 함수·전역 변수는 카운트 제외** | 예외: `exception.dart`(모음 허용)·codegen·**`*_router.dart`·`root_router.dart` 전면 면제**(§3.1이 GoRoute 전역 변수 + `<Bc>Routes` 클래스 동거를 강제 — 적대 점검 P1). "클래스 1+동반 extension" 합법 패턴(HaffHaff 만연)은 extension 제외로 자연 통과. casefold 자체는 연속 대문자(`ChatRoomVM`↔`chat_room_vm`) 전수 일치 검증 완료 |
| NM4 | 27 | added `<x>_vm.dart`(view_model/·scaffold/view_model/)에 대응하는 `<x>_view.dart`·`<x>_state.dart`가 같은 BC(또는 root scaffold)에 부재 → 위반 | VM 기준 단방향(§7.1-3) — 정적 view는 VM 없이 합법. 대응 파일은 **파일시스템 기준**(added 아니어도 인정). 비고: `AsyncValue<엔티티>` 직노출 VM(state 파일 없음)은 규약 문면상 위반이 맞다 — 죽은 state 파일 양산이 관찰되면 §10-5 State 규약에서 재론(§11-④) |
| NM5 | 28 | added section 파일명이 같은 BC의 view 파일 접두(`<화면>_view.dart`의 `<화면>`)로 시작하지 않으면 → 위반 | 대응 view는 **파일시스템 기준**(같은 슬라이스 동시 생성 합법 — 적대 점검 P1) |
| NM6 | 29 | added widget 파일명이 같은 BC의 view 접두를 포함하면 → 위반. **view 접두가 BC명과 동일(casefold)하면 그 접두는 매칭 제외** | BC명 접두는 도메인 어휘와 구별 불가(`store_view` 존재 시 `store_item_widget`은 합법 — HaffHaff 4 BC 실측, 적대 점검 P1) |
| NM7 | 30 | `@riverpod`·`@Riverpod(` 어노테이션이 허용 위치 외 → 위반. 허용: **경로에 `application_layer` 세그먼트 존재 ∧ 직계 부모 디렉터리명 ∈ {`view_model`, `shared_state`, `service`}** + `root/scaffold/view_model/` + `root/handler/` | 세그먼트+직계부모 이중 조건 — 개념 폴더 1차(`application_layer/<개념>/view_model/`)에서도 정확(적대 점검 P1). infra `service/`는 application_layer 세그먼트 부재로 자연 배제. 표기 2토큰으로 실측 93건 전부 커버 |
| NM8 | 31 | `common/**`에서 `@riverpod`·`@Riverpod(` → 위반 | NM7의 부분집합이지만 별도 메시지(§6 "common은 살아있는 상태를 갖지 않는다"). 수동 provider(`NotifierProvider(...)`)는 proxy 밖 — 에이전트 영역(§6 규약 선언과 정합) |
| NM9 | 32 | view 파일에서 `ref\.(watch|read|listen|listenManual)(<…>)?\(` 호출의 첫 인자(균형 스캔 추출)가 — casefold 기준 — `<파일접두>vm…provider`로 시작하지도, `sharedstateprovider`를 식별자 끝으로 포함하지도 않으면 → 위반 | 제네릭(`ref.listen<AsyncValue<T>>(`)·`listenManual`·멀티라인 호출 — HaffHaff 실물 3변형 반영(적대 점검 P1). `.notifier`·`.future`·family 인자는 startswith로 자연 통과 |
| NM10 | 33 | BC `presentation_layer/**`·`design_system/component/**`·`root/scaffold/**`에서 `Color(0x`·`Color.from`·`\bTextStyle(` 리터럴 → 위반 | foundation·theme·ds util 제외(토큰 정의·빌더의 자리 — `text_style_maker` 실물 확인). `Color.from`(fromRGBO·fromARGB)은 생성자 리터럴 동급으로 추가. `Colors.*` 팔레트는 §9 한계(규약 문면 밖) |
| NM11 | 34 | `foundation/` 파일: 클래스명 `App<토큰>` 불일치, **public** `static const` 멤버명 lowerCamelCase(`^[a-z][a-zA-Z0-9]*$`) 불일치 → 위반 | private(`_`) 멤버 제외(적대 점검 P2) |
| NM12 | 35 | `component/<군>/` added 파일이 `*_<군>.dart` 불일치(**군명 단독 `<군>.dart`는 허용** — 무수식 기본 부품), 클래스명 `<수식><군>`(casefold) 불일치, 파일명 `ds_` 접두 → 위반 | `loading/loading.dart` 류 기본 부품 관례 수용(적대 점검 P2 — 사양 결정) |
| NM13 | 36 | ⓐ `GoRoute(` 토큰이 `*_router.dart`·`root_router.dart` 외 파일에 등장 ⓑ 내비 호출(`\.(go|goNamed|push|pushNamed|pushReplacement|pushReplacementNamed|replace|replaceNamed)\(`)의 첫 인자(균형 스캔)가 문자열 리터럴 → 위반 | path·name 단일 출처(§3.1)의 고정밀 근사 — 상수 참조는 통과. 충돌 검증 완료: `.replaceRange(`·dio `.post(`·`TypedGoRoute(` 비매칭, HaffHaff 내비 23건 전수 무오탐. `Navigator.pushNamed(context,'/x')`(2번째 인자)는 §9 한계 |
| NM14 | 38 | `ui_extension/` added 파일에 top-level `class`·`enum`·`mixin`·**`extension type`** 선언 → 위반 (plain extension만 허용) | extension type은 class 동급 구조(적대 점검 P2) |
| NM15 | 39 | `domain_layer/<agg>/` 직속 added 파일 중 **`exception.dart`를 제외한** 각각에 대해 파일명 ≠ 폴더명 또는 클래스명 casefold ≠ 폴더명 casefold → 위반 | exception.dart 면제(§3.2 합법 동거 — 적대 점검 P1). ST5(허용 목록)·ST4(존재)와 분담 — NM15는 철자 일치만 |
| NM16 | 추④ | `repository/` added 파일에 정규식 `^\s*(abstract\b[\w\s]*|sealed\s+)class` 매칭 선언 → 위반 | `sealed`(암묵 abstract)·`abstract final`·`abstract mixin` 변형 포함(적대 점검 P1). retrofit `@RestApi` abstract는 `data_source/` 소속이라 무충돌(HaffHaff abstract 217건 전수 data_source 실측) |

### CY — 순환 래칫 (1종, `check_cycles.dart`)

| ID | 출처 | 게이트 | 판별식 |
|---|---|---|---|
| CY1 | 23 | G | BC 의존 그래프(파일 import를 BC 단위로 합산한 방향 간선 — **합법 4채널 import 포함**, §9-15 "BC import 그래프"는 채널 무관)에서 SCC를 구해, 같은 SCC에 속한 BC 무순서쌍 집합을 산출. 베이스라인에 없는 신규 쌍 → 위반 |

- **베이스라인**: `.dddart/backstop-baseline.json` — `{"cycle_pairs": [["a","b"], …]}` 정렬 저장. **커밋 대상**(래칫은 공유 상태).
- **부재 시 자동 생성**: 현재 쌍 전부 동결 + "베이스라인 생성(N쌍 동결)" 보고 + exit 0 — Coordinator가 커밋하고 **G0 배너에 표면화**(실수 삭제로 인한 무음 래칫 리셋 방지).
- **stale 쌍 보고**(적대 점검 P1): 매 실행에 "베이스라인에 있으나 현재 미발생인 쌍 N개 — `--update-baseline` 권장"을 출력(exit 0 유지) — Coordinator가 갱신 커밋을 트리거하면 해소된 순환의 재발 면책이 닫힌다(래칫 되감기).
- **교정 문구 필수**: 합법 채널만으로 이룬 신규 순환(상호 navigator 호출 등)에서 coder가 "합법 import인데 왜 blocker"에 빠지지 않도록, 해소 경로(한쪽을 root 경유 딥링크로·구조 재배치)를 fix 문구에 담는다.
- 쌍 단위(간선·경로 아님)인 이유: 리팩터링으로 경로 형태가 바뀌어도 같은 순환이 남는다 — "A와 B가 서로에게 닿는가"가 안정적 최소 단위. 3-BC 순환에 새 BC 합류 시 신규 쌍으로 정확 발화(검증 완료).

## 6. 발견 메시지 양식

dddjango 양식 승계 — 발견마다 3행:

```
[IM5] BLOCKER — lib/application/chat/application_layer/view_model/chat_room_vm.dart:8
  위반: 타 BC member의 shared_state import — 교차 BC는 4채널만 (제1 규약 §9-3)
  교정: member의 UseCase를 호출하거나(데이터), 그 화면 view를 임베드한다(표시). SharedState watch는 같은 BC 안에서만.
```

교정 행은 검사별 고정 문구(구현 파일에 상수로) — "무엇이 합법 경로인가"까지 안내해 coder 반송 루프를 1회로 끝낸다.

## 7. `extract_contract.dart` — G1 계약 기계 절단

> 백스톱이 아니라 파이프라인 도구(본설계 §5-7). 같은 scripts/에 두되 러너와 무관한 별도 엔트리.

```
dart run <플러그인>/scripts/extract_contract.dart \
  <openapi-full.json> --paths <paths-file> --out server-contract.json
```

- **입력**: paths-file = 명세(design-spec.md)가 인용한 엔드포인트 목록 — 한 줄에 `GET /api/v1/members/{id}` (메서드 생략 시 그 path 전 메서드). Coordinator가 명세에서 기계 추출해 작성.
- **알고리즘**:
  1. 인용 path를 동결본 `paths`에서 **정확 일치**로 선별(퍼지 매칭 없음). 메서드 선별 시 **path item을 통째로 복사한 뒤 비인용 메서드 키만 제거** — path item 레벨의 공유 `parameters`·`servers`·`summary`·`description`·`$ref`를 보존한다(operation만 뽑으면 `{id}` 선언이 유실돼 invalid 계약 — 적대 점검 P1).
  2. 선별 서브트리의 `$ref` 수집 — **`discriminator.mapping`의 값 문자열도 ref로 수집**(`$ref` 키가 아니라 키 스캔에서 새는 관례 — 적대 점검 P2). `#/components/...` 로컬 참조를 **visited 집합 기반 전이 폐쇄**까지 추적(순환 스키마 대비).
  3. 닿은 components 서브트리만 복사. `#/components/` 외 로컬 ref(`#/paths/...` operation 재사용 관례)는 **경고 + 해당 서브트리 동반 복사**(dangling 침묵 금지). 비로컬 ref(`http://`·파일)는 경고 + 원문 보존.
  4. `openapi`·`info`·`servers`·**루트 `security`**·`components.securitySchemes`(전체) 보존 — security 유실은 인증 요구가 계약에서 사라지는 것(적대 점검 P1). OpenAPI 3.1 `webhooks`·`components.pathItems`는 비복사 시 **경고 출력**(무음 드롭 금지).
- **실패 의미론**: 인용 path가 동결본에 없으면 **exit 1 + 누락 목록 + 근사 후보 병기**("유사 path 존재: `/api/v1/members/{memberId}`" — trailing slash·파라미터명 차이의 오귀책 방지, 반송 1회로 끝낸다). 이것 자체가 발견이다(존재하지 않는 엔드포인트 인용 = architect 임의 가정, 본설계 §5-1 위반) — Coordinator는 설계 반송.
- exit: 0=성공 / 1=인용 누락·파싱 실패. (blocker 의미론 없음 — 게이트 도구가 아니다.) OpenAPI 3.x JSON 전제 — YAML·Swagger 2.0은 exit 1 + 안내.

## 8. 파이프라인 접속점 (모드별 호출 사양)

| 시점 | 호출 | diff-base |
|---|---|---|
| 풀/수정 — Phase 2 백스톱 단계(본설계 §6-4, 빌드 전) | `backstop.dart <root> --diff-base <h>` | Phase 2 진입 시 git 스냅샷(build-state.json) |
| 트리비얼 — 직접 편집 후(본설계 §7) | 동일 | 트리비얼 시작 시 스냅샷 |
| G0 직후(베이스라인 부재 시) | `backstop.dart <root> --only cy` | (전역이라 불요) — 생성된 베이스라인 커밋+배너 표면화 |
| G1 승인 직후(본설계 §5-7) | `extract_contract.dart …` | — |

비git 프로젝트: G0 전제조건에서 `git init`+초기 커밋 제안이 정답 경로(§11-③) — 거부 시 `--all` 전역 퇴화(레거시 발견 폭주 고지).

## 9. 수용한 한계 (정직한 표면화)

1. **정규식 파서**: 같은 줄 이중 directive(`import 'a'; import 'b';`)의 둘째 누락, 병리적 문자열 케이스 — directive 위치 매칭+마스킹으로 사실상 0에 수렴. analyzer AST 승격은 실측에서 오탐이 보이면.
2. **`.go(` 토큰(IM14)**: 내비가 아닌 `.go(` 메서드 오탐 가능 — 대상을 application service/로 한정해 위험 최소화(HaffHaff lib 전체 `.go(` 0건).
3. **NM9·NM13 근사**: 표현식이 변수 경유면 미탐(저-recall 수용). `Navigator.pushNamed(context, '/x')`의 2번째 인자 리터럴 미탐 — Navigator 직접 사용은 IM12(BuildContext)가 부분 차단. 의미 변종은 discipline-reviewer 영역.
4. **NM3**: 같은 파일의 보조 public enum 등도 위반 — 규약 §7.1-1 문면. ui_extension의 extension 철자(`<개념>UiExtension`)는 카운트 제외라 미검 — 에이전트 영역.
5. **NM10**: `Colors.*` 팔레트 직참조 미탐(HaffHaff 53건) — 규약 §6이 `Color(0x`·생 TextStyle로 좁게 정의(문면 충실). "단일 출처" 취지의 흔한 우회로이므로 §10-5 또는 규약 개정에서 재론 후보.
6. **수정 모드의 added 검사**: 기존 파일을 위반 이름 그대로 두면 불발화 — 의도된 레거시 면책. IM은 added 줄 기준이라 기존 위반 import도 불발화 — 동일 의도.
7. **수동 provider**(`final x = NotifierProvider(...)`): NM7·NM8은 어노테이션만 검출 — §6 규약 스스로 proxy 한계로 선언(가변 싱글턴은 에이전트 판단 영역).
8. extract_contract는 OpenAPI 3.x JSON 전제.

## 10. 적대 점검 처리 결과 (2026-06-12)

2렌즈(ST·NM / IM·CY·게이트·파서·extract) 병렬, HaffHaff 861파일 실물 픽스처(directive 5,080건 전수 분류·URI 클램핑 실증·porcelain 동작 실증). **P0 5건 전부 해소**: ① porcelain `-uall`(신규 BC 무검사) → §3 ② 상대 import lib/ 클램핑(IM 전체 우회 벡터) → §4-4 ③ lib/ 직속 사각지대 → ST0 신설 ④ §3.7 매트릭스 미번역 6행 → IM17~22 신설 ⑤ (③과 동근) 떠돌이 파일 — ST0. P1 16건 반영(주석·문자열 마스킹 공유 패스, IM12 flutter 전면 금지, IM16 l10n, NM3 router 면제·카운트 확정, NM9 실물 3변형, CY1 stale 보고, extract path-item 보존·security 보존 등). 잔여 P2는 §9 한계 등재 또는 §11 이관. 검사 수 44 → **51**.

## 11. 규약·본설계 측 개정 4건 (2026-06-12 사용자 확정 — 처리 완료)

4건 전부 권장대로 확정, 반영 완료:

1. **제1 규약 §2**: lib/ 직속에 `firebase_options.dart`(flutterfire 생성물) 등재 — **반영 완료**(트리 행 추가 — ST0·§4-1 제외 목록의 근거 명문화).
2. **제1 규약 §3.7**: design_system 허용 importer에 BC 루트 **router** 포함 — **반영 완료**(헤더 개정, IM13 유지).
3. **본설계 §4 전제조건**: 비git이면 `git init`+초기 커밋 제안 — **반영 완료**(§3 비git 폴백의 정답 경로 성립).
4. **§10-5 선결정 목록 합류**: ⓐ State 파일 없는 VM(`AsyncValue<엔티티>` 직노출) 허용 여부(NM4 연동) ⓑ 컨트롤러 소유 계층(IM12 연동) — **제1 규약 §10-5 ①에 등재 완료**. 그때까지 백스톱은 규약 문면대로 집행.

## 12. 다음 단계

1. 사용자 확정 완료(§11) → **구현 시점 결정(즉시 vs §10-4와 함께 — 미결)**.
2. 확정 후: 파이널 리뷰 문서(`2026-06-12-file-tree-final-review.md`)의 §5는 이 문서로 대체 — §6(기계 판별 불가 17종)은 §10-3 공유 reference로 넘어간 뒤 삭제 후보 확정.
3. 구현 시 단위 픽스처 필수 채택분: 8단 상대 import 클램핑(HaffHaff 실물)·porcelain `-uall` 신규 BC·블록 주석 내 directive·멀티라인 `ref.listen<T>(`.
