# SCENARIO-S1 — 신규 BC 공지 (2단계 실측 고정 입력 정본)

> **고정 입력**: 변경은 실측 *착수 전*에만(`EVAL-METHOD.md §0`·사전등록). 런 간 흔들리면 두 안 비교가 오염된다. 이 파일의 §1·§2·§4는 안 1·안 2 양쪽 빌드에 **동일하게** 투입되고, **§3만 두 안이 다른 단 하나의 변수**다.
> **시나리오 좌표**: S1 = 신규 BC 공지(~13파일)·**슬라이스 도출 plan-a/plan-b 비교 실험 전용**(§3이 두 안이 갈리는 단 하나의 변수). 두 안의 갈림은 *중대형 기능*에서만 발동(`slice-simulation.md §3` "갈림의 본질"). S2(기존 BC 확장 7+3)·S3(수정 모드 5+2)는 **좌표만 둔 미작성 시나리오**(현재 파일 없음 — 실현 시 같은 틀로 SCENARIO-S2/S3 생성). ※ 이 파일은 plan 비교 실험용이며, 일반 라이브런 시나리오(레이아웃·충실도 등)는 `SCENARIO-WEATHER` 등 별도 정본을 쓴다.

## §1 표준 task 프롬프트 (verbatim — 사용자가 `/dddart`에 주는 문장)

```
공지사항 기능을 추가해줘. 서버 API에서 공지 목록을 받아 리스트로 보여주고,
목록에서 항목을 탭하면 상세 화면으로 들어가 본문을 본다.
공지는 제목, 본문, 게시일, 중요 여부를 가진다.
중요로 표시된 공지는 목록 맨 위에 고정되고 '중요' 배지가 붙는다.
목록은 당겨서 새로고침할 수 있다.
```

- **행위 목록**(G2 체크리스트·행위↔코드 대조 단위): ① 공지 목록 조회 ② 공지 상세 조회 ③ 중요 공지 상단 고정·정렬 ④ 중요 배지 표시 ⑤ 당겨서 새로고침.
- **규모**: 신규 BC 1개 + 화면 2개(목록·상세). 풀 빌드 신규 ~13파일(생성물 제외) → 본설계 §6 임계상 **2분할 발동, Model 슬라이스가 세분 임계(8) 근처**. 두 안의 거동 차가 드러나는 중대형 구간.

## §2 픽스처 baseline

- **위치**: `/tmp/dddart-w2-fixture` (휘발 — 부재 시 §2.1로 재생성).
- **상태**: `channel` BC(공지와 독립한 기존 BC·목록 조회) + `common/network/`(dio_client·safe_api_call·bad_request_response) 빌드된 **green**. `lib` 14파일(`*.g.dart`·`*.freezed.dart` 제외). `flutter analyze` green·표기 green이 baseline.
- **baseline 확정 절차**: 실측 착수 시 픽스처 작업트리를 **단일 커밋으로 굳히고 그 해시를 결과지 헤더에 기록**한다(dddjango 관례 — `relive` 헤더 `baseline 989da53`). 두 안은 *같은 baseline 커밋의 깨끗한 복제*에서 각각 출발한다(`git worktree` 또는 복제 디렉터리 2벌).
- **산출물 폴더**: announcement는 신규 기능 → `.dddart/<날짜>-announcement-*/` **새 폴더(ⓑ)**. 기존 `.dddart/backstop-baseline.json`은 백스톱 결정성 baseline(유지·재생성 금지).

### §2.1 재생성 절차 (픽스처 부재 시)

`flutter create` → 의존성(§2.2) 주입 → `channel` BC 골격(목록 조회·HaffHaff 방언 4계층·green) 빌드 → 표기 green 확인. 상세 복원은 픽스처 git 이력(`01838bd` "초기 픽스처" + Wave 누적분).

### §2.2 의존성 (pubspec.yaml — `implementation-*` §1 버전 라인)

- `environment.sdk: ^3.9.0` (json_serializable 6.14 하한).
- 런타임: `dartz ^0.10.1` · `dio ^5.0.0` · `flutter_riverpod ^3.0.0` · `freezed_annotation ^3.0.0` · `go_router ^16.0.0` · `json_annotation ^4.12.0` · `retrofit ^4.0.0` · `riverpod_annotation ^4.0.0`.
- dev: `build_runner ^2.4.0` · `freezed ^3.2.0` · `json_serializable ^6.8.0` · `retrofit_generator ^10.0.0` · `riverpod_generator ^4.0.0`.
- **hive 미사용**(네트워크 전용) → 슬라이스 도출의 "hive 어댑터" 항목은 S1에서 비발동.

## §3 두 안의 슬라이스 도출 절 (← **두 안이 다른 단 하나**)

> 안 2 실행 = 커맨드 **사본**의 "슬라이스 도출"(Phase 2 step 2)만 아래 안 2로 치환. **원본 커맨드 불변**. 나머지 파이프라인(Phase 0·1, G0·G1, coder 순차, 감사 리듬, 백스톱, 빌드, G2)은 두 안 **완전 동일**.

### 안 1 (plan-a) — 규모 적응형 Model/View 2분할 〔커맨드 원문 = 본설계 §6 / `dddart.md:126-130`〕

- **계수** = 명세 파일 목록의 신규+수정 합산(코드 작성 전 계산·줄 수는 입력 아님).
- **축퇴(1호출)**: 풀 7 이하 / 수정 5 이하.
- **2분할**: 초과 — 슬라이스1(Model) = 골격+domain+infra+application(use_case·state·view_model·shared_state·service) / 슬라이스2(View) = presentation(view·section·widget·ui_extension)+배선(BC router GoRoute·root branch·handler 연결).
- **세분**: 한 슬라이스가 풀 8 이상 / 수정 6 이상이면 Model은 애그리거트·계층 단위, View는 화면 단위로 분할.
- **tracer 선행**(기계 플래그 ①가정 계약 ②'계약 위험' 표기 중 하나): 하층 관통 + 위험 행위 1개 종단. tracer가 골격 생성 소유(첫 슬라이스).

### 안 2 (plan-b) — 행위 세로 + 결정적 묶기 〔치환분 = `slice-simulation.md §3 안2`〕

- **기본 = A(행위 세로)**: 슬라이스 = 행위 1개 종단, 내부 bottom-up(domain→infra→application→presentation).
- **결정적 묶기(전제)**: "같은 파일을 쓰는 행위는 같은 슬라이스" — 파일 교집합 기반 기계 병합(LLM 재량 0). 같은 VM·view를 쓰는 행위는 자동 1묶음(사실상 화면 단위로 수렴).
- **위험 우선 정렬(선택)**: 첫 슬라이스를 "조회 최소 경로"가 아니라 "하층 관통 + 계약 위험 최대 행위"로 — tracer 가치 흡수.
- **골격**: 첫 슬라이스가 자신이 건드리는 계층 폴더를 생성, 후속은 "기존 수정" 의미론.

## §4 고정 게이트 답 (두 안 동일 — 흔들리면 비교 오염)

- **G0 계약 출처**: 픽스처에 공지 서버 OpenAPI 없음 → **공지 API는 가정 계약**으로 명세에 명문화(`server-contract.json` 부재·design-spec 가정 계약 절). 이 가정 계약 = **G1 승격** → tracer 플래그 ① 발동(두 안 공통) → **tracer 선행 1줄기 + 미니 게이트 1회**(두 안 공통 비용·상쇄). 미니 게이트 결과 = "가정 맞음 → 진행"(고정).
- **BC 배치**: `announcement` 신규 BC (기존 `channel`과 독립·교차 BC 없음).
- **G1 설계 결정**(고정): 페이지네이션 **안 함**(전체 목록 1회 조회) · 로컬 캐시 **안 함**(네트워크 전용) · 정렬 = **중요(pinned) 우선 → 게시일 내림차순** · 당겨서 새로고침 **함**.
- **G2**: 승인.
