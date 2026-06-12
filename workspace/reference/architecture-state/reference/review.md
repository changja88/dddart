# architecture-state 합성 전 리뷰 — 다출처 통합·경계 결정 기록

> Wave 2는 internal/external이 없는 규약 직접 인용형이다. 이 리뷰는 dddjango의 internal vs external 교차 리뷰 대신 **다출처 통합 리뷰**다: 원료 절들 간 중복 정규화, 타 스킬과의 소유 경계, 공백(발명 위험) 점검, final 구조 결정을 기록한다.
>
> **원료**: 제1 규약 §3.3(전문)·§3.6(전문)·§9-3·§9-7·§9-11·§9-13·§8 해당 행(refresh_notifier·scroll_to_top·comment_added·능동 service·BC 공유 상태·교차 BC VM watch)·§10-5 ① + 본설계 §8(lens 경계·keepAlive 경계·컨트롤러 View 소유 귀속).

## A. 출처 간 중복 — final 단일 서술 위치

같은 규칙이 규약 여러 절에 반복 서술된다(§3.3 본문 ↔ §9-7 결정 요약 ↔ §10-5 ① 확정 기록). final은 **§3.3 본문 서술을 정본**으로 삼고 §9·§10-5는 보강 단서만 취한다:

| 규칙 | 등장 절 | final 서술 위치 (1곳) |
|---|---|---|
| State 계약(전 VM freezed `*State`) | §3.3 · §9-7 · §10-5 ① | final §3 |
| 에러 2채널 | §3.3 · §3.4 단서 · §9-7 · §10-5 ① | final §4 |
| BuildContext 금지·navigator 경유 | §3.3 · §9-7 | final §2 |
| 컨트롤러 View 소유 | §3.3 · §10-5 ① · 본설계 §8 귀속 | final §2 |
| `@riverpod` 허용 위치 | §7.1-6 · §9-13 · §3.6 | **위임** — 닫힌 열거는 houserules 소유, state는 결정 절차만 |
| 과거형 사건명 금지 | §3.3 · §8 · §9-15 | final §5 (판별 절차는 undecidable §10 위임) |
| root 동작 규율 | §3.6 · §9-15 | final §10 |

## B. 소유 경계 결정

- **vs houserules(사실 단일 출처)**: 파일·폴더·명명·import 매트릭스·4채널 전체 목록·`@riverpod` 허용 위치 닫힌 열거 — 전부 houserules final §1·§4·§5 위임. state 본문은 **동작 계약과 결정 절차**만.
- **vs data(본설계 §8 lens 경계 — final §1에 명시)**: 캐싱 — hive 저장=data / 메모리 keepAlive=state. 에러 — 서버 에러가 오는 모양(Either·BadRequestResponse 정규화)=data / 그 에러를 State에 담아 표시·소비하는 방식=state.
- **vs ui**: view 3단 판별·dumb 규율=ui. **표준 listen 패턴 정식 예제는 state 소유**(코퍼스 설계안 §3 배정 — State 계약의 소비 절차이기 때문). ui final §2에서 watch·listen은 state 위임.
- **vs ddd(전방)**: UseCase 자체(도메인 개념 명명·판정 소유·강등)는 ddd. state는 "VM은 Model 방향으로 UseCase만 호출"이라는 VM 쪽 규율만.
- **vs riverpod(전방)**: keepAlive **표기법**(`@Riverpod(keepAlive: true)` 문법)·@riverpod 변종 문법 위임. state는 수명 **결정**(어느 변종·언제 keepAlive) 소유. 경계 문구를 양쪽 SKILL.md에(코퍼스 설계안 §4).
- **vs cleancode(전방)**: 반복>상속 일반 규율은 cleancode. state는 "base VM·공용 헬퍼를 만들지 않는다"는 확정 사실+정식 예제만.
- **vs flutter(전방)**: 탭 재탭 스크롤톱의 PrimaryScrollController 상세는 §10-5 ④ 미결 — flutter 작성 중 결정. state §8은 "BC는 신호를 듣지 않는다·root_view 직접 처리" 원칙까지만.
- **vs undecidable.md(공유 reference)**: handler 입장(§5)·거의 빈 VM·푸시 정규화(§6)·common 살아있는 상태(§7)·과거형 사건명 판별(§10) — 판별 절차 재서술 금지, 위임만. state final은 각 주제의 **작성 규율**(어떻게 만드나)을 소유.

## C. 공백·발명 위험 (P1 기록 대상)

1. **listen 패턴 예제 코드** — 규약에 완성 코드 없음. 패턴 요소(표준 필드 `BadRequestResponse? error`·`ref.listen` 감지·`isShow` 존중·`consumeError()` 명시 소비·조회 throw→AsyncValue.error)는 전부 규약 §3.3 명시 → 예제는 명시 요소의 조립이며 발명 아님. freezed·@riverpod 문법 디테일은 표기법 스킬 위임 1줄 표시.
2. **BadRequestResponse 필드 철자** — HaffHaff 실물 확인(2026-06-12): `errorType`·`msg`·`isShow` (`message` 아님 — msg). 예제에 실물 철자 사용.
3. **shared_state 명시적 reset** — 규약은 "keepAlive + 명시적 reset"까지만. reset 메서드 모양은 최소 서술(상태를 초기값으로 되돌리는 공개 메서드), 시그니처 발명 금지.
4. **scroll_to_top 대체 메커니즘 상세** — §10-5 ④ 미결. 원칙(§8·§9-11 처방)까지만 서술하고 상세는 flutter 전방 위임.

## D. final 구조 (10절)

§1 application_layer 지도(3변종 축·lens 경계) / §2 ViewModel(번역·변환·BuildContext 금지·컨트롤러) / §3 State 계약 / §4 에러 2채널(정식 예제) / §5 SharedState(keepAlive+reset·과거형 금지·일회성 소비) / §6 Service(헤드리스·능동/수동) / §7 교차 BC 상태 측면(4채널 중 상태 채널) / §8 refresh 채널 처방(폐지 종류의 대체) / §9 keepAlive 수명 결정 / §10 합성 루트의 상태 동작 규율.

코퍼스 설계안 §3 state 행 골격 대조: VM 3변종(§1·§2·§5·§6)·State 계약(§3)·에러 2채널(§4)·컨트롤러 View 소유(§2)·표준 listen 패턴 정식 예제(§4)·shared_state(§5)·4채널 상태 측면(§7)·refresh 채널 처방(§8)·일회성 이벤트 소비(§5)·keepAlive 수명 결정(§9)·합성 루트(§10) — 전부 커버.
