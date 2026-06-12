# 2026-06-11-dddart-file-tree.md 파이널 리뷰 결과

- 일자: 2026-06-12
- 방법: 3자 리뷰 — 정독(메인) + 정합성 에이전트 + 아키텍트 에이전트 병렬. 리뷰 축 4개(MVVM 적합성 / DDD 수준 / 상호참조 정합 / 판별 규칙 계산 가능성) + 실전 시나리오 시뮬레이션 3건.
- 종합 판정: **정적 트리는 출시 가능 수준, 동적 배선은 미완성.** 트리·명명·계층·골격의 정적 형태는 실측 근거가 충실하고 판별 규칙 다수가 import/경로 기반으로 환원된다. 그러나 시나리오 3개 중 2개(푸시 딥링크, 전역 게이트)가 "파일 이름은 정해지지만 데이터·이벤트가 흐를 합법 경로가 없는" 상태로 막혔고, 원인은 전부 한 뿌리 — **root 내부 협력·반응형 채널 미규정**(@riverpod 3변종 제한 × handler/initializer의 provider 접근 부재 × BC→root 단방향). §3.6에 "root 내부 협력 규칙" 절 하나를 신설하면 critical 2건 + major 2건이 한 번에 닫힌다.

---

## 1. Critical — 규약을 그대로 따르면 모순·막힘 (확정 전 해소 필수)

### C1. 푸시 탭→딥링크 배선이 현행 규칙 조합으로 결정 불가 (아키텍트)
- FCM에서 수신과 탭은 같은 SDK 스트림(`onMessageOpenedApp`·`getInitialMessage`)에서 나온다. §3.6은 "탭은 root_destination_handler, 수신은 push BC service"로 가르지만 — push BC service가 탭을 받으면 root로 전달할 채널이 없고(BC→root 금지), root handler가 직접 들으면 푸시 payload 스키마→URL 정규화 로직(푸시 도메인 지식)이 root에 상주한다. 청취 주체·정규화 함수 자리·디스패치 수단(`go(url)` vs navigator)·콜드스타트 initial message 처리 시점이 전부 침묵.
- HaffHaff 실물(`firebase_messaging_service.dart`의 `_safeHandle`→`DestinationHandler()`)이 정확히 이 자리이며 신규 규약상 재현 불가.
- 권고: "푸시 탭 청취·정규화는 root_destination_handler 소유(payload 스키마는 '전 BC 목적지' 지식으로 간주), push BC service는 수신·토큰만, 디스패치는 `go(url)` 단일 수단" 명문화.

### C2. root_initializer → root_vm 부트스트랩 결과 주입 경로 부재 (아키텍트)
- main.dart 최소형 = `root_initializer 호출 → runApp(ProviderScope(...))` 순서인데 root_vm은 ProviderScope 이후에만 존재. 초기 검사 결과(강제업데이트·자동로그인 성패)를 전달할 길이 없다. HaffHaff가 이 간극을 메우던 수단(생성자 인자 `isInitBoxSuccess`·`ValueListenableBuilder`)은 둘 다 §8에서 drift로 폐기됐고 대체 메커니즘이 없다.
- 권고(택1): ① initializer가 순수 결과 객체를 반환하고 main이 `ProviderScope(overrides:)`로 주입 ② 부트스트랩 결과는 root_vm.build()가 UseCase 재호출로 획득.

### C3. hive 어댑터 조립 ↔ root Model 규율 import 충돌 (3자 일치)
- §3.6 "root도 BC의 **UseCase만** 호출(Repo·box 직행 금지)" vs §9-9 "BC 엔티티의 어댑터 등록 함수는 BC **infra**가 노출하고 root_initializer가 조립" — root→BC infra import가 동시에 금지·요구된다. 백스톱이 "root→infra import 금지"로 검사하면 initializer는 항상 위반.
- 권고: "예외: hive 어댑터 등록 함수(§9-9)에 한해 root_initializer의 BC infra import 허용" 명시, 또는 등록 함수를 BC 루트 파일로 격상.

### C4. rootRouter "GoRouter provider" ↔ @riverpod 3변종 제한 (정독+정합성)
- §7.2 "(GoRouter **provider** `rootRouter`)" vs §9-13 "@riverpod는 VM·SharedState·Service 3변종 + root_vm뿐(그 외 전부 금지, 백스톱 검사 대상)". router는 화이트리스트 밖 — 명명표를 따르면 백스톱에 걸린다 (HaffHaff 실물도 `rootRouterProvider`).
- 권고: BC 라우터처럼 plain 전역 변수(`final GoRouter rootRouter`)로 통일하거나 §9-13에 명시적 예외 추가. (redirect에서 ref가 필요하면 예외가 불가피 — C2 결정과 연동됨.)

### C5. 다수 애그리거트 domain_service의 "공용 위치"가 트리 문법과 모순 (정합성)
- §3.2 "여러 애그리거트에 걸치면 `domain_layer/` 공용 위치로" vs §4 "domain_layer는 **항상** 애그리거트 1차"·§2 트리·§5 골격(직속은 `<aggregate>/`만). 공용 위치의 경로·이름이 어디에도 정의되지 않았고, 정의하면 "항상 1차"가 깨진다.
- 권고(택1): ① `domain_layer/_shared/domain_service/` 같은 명시 위치 정의 + §2·§5 반영 ② "걸치는 서비스는 주 애그리거트에 귀속" 규칙으로 단순화.

---

## 2. Major

| # | 발견 | 출처 | 권고 |
|---|---|---|---|
| M1 | **root handler·initializer의 객체 형태 미정** — handler는 플랫폼 이벤트를 받아 BC service provider를 구동하므로 사실상 Service 변종인데 @riverpod 화이트리스트 밖. plain class면 ref가 없어 HaffHaff `RootLifecycleHandler`의 WidgetRef 필드 안티패턴이 재발 | 아키텍트+정합성 | handler에 Service 변종(@Riverpod keepAlive) 지위 부여 + 구동(초기 listen 등록) 주체를 §3.6에 명시 |
| M2 | **root_vm의 뱃지 등 반응형 상태 공급 채널 무규정** — 뱃지는 BC 어휘, UseCase는 무상태 단발이라 반응성이 없음. root의 4채널 면제가 'watch 포함'인지 침묵 (NiA·Prism은 셸의 feature 상태 구독이 표준) | 아키텍트 | "root_vm·root_view는 BC SharedState watch 허용(면제의 명시적 일부)"을 §3.6에 추가 |
| M3 | **`## 10` 헤딩 부재** — §10-2·§10-5·§10-6 참조 6곳이 무번호 목록("이 문서 확정 후 순서대로")을 가리킴. 또 §8 scroll_to_top 행의 "(§10-5)"는 그 목록 항목 5에 스크롤톱 내용 자체가 없음 | 3자 일치 | 목록에 `## 10. 후속 작업` 헤딩 부여 + 항목 5에 스크롤톱 상세 추가(또는 참조 삭제) |
| M4 | **§8 drift 표 누락 행** — 본문이 drift로 선언한 것 중 표에 없는 것: `app/`·`bridge/`·`block/` 구명칭 3행(§9-8), UseCase의 ErrorDialog 호출·VM의 BuildContext 보유(§9-7), 화면 state의 domain→application 이동(전 BC), domain 평면→애그리거트 1차, main.dart 비대, `appbar/`→`app_bar/` | 정합성 | 표가 "백스톱의 단일 근거"라면 전부 행으로 추가 (또는 §8 서두에 범위 한정 명시) |
| M5 | **4채널 ④ "export된 view"의 export 판별 기준 부재** — 어떤 view가 임베드 가능한지 표식이 없어 백스톱이 채널 ④를 식별 불가. 타 BC section·widget·ui_extension import의 지위도 미규정 | 아키텍트+정합성 | "타 BC presentation은 view/만 import 가능(전 view 자동 export)" 식으로 확정 |
| M6 | **계층 import 매트릭스 미명문** — View가 Repo를 직접 import해도 위반 조문을 특정할 수 없음(§3.3 화살표에서 추론만 가능). §10-2 백스톱의 1순위 검사 대상인데 본문에 없음 | 아키텍트 | 4계층×4계층 허용 매트릭스 표 1개 추가 |
| M7 | **Either 방향(Left=성공)·에러 전달 채널이 '잠정'으로 제1 규약에 잔류** — 플러그인이 생성할 모든 코드의 중추 시그니처. dartz 일반 관례(Right=성공)와 반대라 LLM 코더가 관례대로 쓸 확률이 높음 | 아키텍트 | 문서 확정 전 §10-5 ② 결정 + State 에러 필드 최소 규약(필드명 1개·일회성 소비)을 본문 승격 |
| M8 | **도메인 규칙의 자리를 강제하는 규칙 부재** — specification 평가만 "UseCase 이하"로 제한했을 뿐, 일반 비즈니스 판정이 VM에 상주하는 것을 막는 조문이 없음. 직파싱+freezed 구조에서 domain_layer 빈혈화가 구조적으로 합법 | 아키텍트 | 최소 휴리스틱 명문화(예: "둘 이상의 VM이 같은 판정을 복제하면 domain_service/specification으로 강등") — §10-5 ③ 위임 명시 |
| M9 | **실측 수치 불일치** — 재실측 결과: BC 16개(문서 17), common 역import 11파일(문서 15, dio client 3은 `'application/json'` 문자열 오탐 추정), `_app.dart` 44개(문서 "App 17개"), `_vm.dart` 77개(문서 "VM 31개" — 모집단 정의 불명), refresh_notifier 12파일/8BC(문서 11개 BC). 실제 역import인 `common/service/status_handler.dart`(member VO·MemberHive·ConfirmDialog)는 문서 전체에 부재 | 정합성 | 모집단 정의 차이일 수 있으므로 **측정식 병기** 또는 재측정. status_handler는 §8 행 추가 |

---

## 3. Minor (요약)

1. "root/ import는 main.dart뿐" 규칙에 **root 내부 상호 import 제외** 명시 (백스톱 구현 시 모호) — 정독
2. `show_snackbar.dart`가 common/util("순수 유틸") 실예로 등재 — 성격상 design_system/util(시각 동작) — 정독
3. 시각 리터럴 금지 범위가 "BC presentation·component"뿐 — **root/scaffold/view 누락** — 정독
4. §4 presentation 분할 예시에 `ui_extension/` 누락 + 분할 후 직속 종류 폴더의 처분(동결 여부) 미규정 — 정독+아키텍트
5. `exception.dart`의 상시 생성 여부 모호 — §5 표에 없고 §9-0은 "보유" — 아키텍트
6. 게이트 상태 주인 중복 — §3.6 "root_vm이 강제업데이트 상태 보유" vs §7.2 게이트 삼총사(`root_<게이트>_vm`) — "게이트 표시 여부는 root_vm, 내부 상태는 게이트 VM" 경계 한 줄 — 아키텍트
7. 게이트 전환 메커니즘(라우터 redirect vs 위젯 분기) 미규정 — scaffold는 탭 프레임이라 비탭 라우트를 못 덮음 — 아키텍트
8. ScreenName 해체 후 **라우트 path·name 상수의 표기 형식** 미규정 (BC마다 발산 위험) — 아키텍트
9. rootNavigatorKey·snackBarKey·routeObserver·logger·페이지 전환 헬퍼의 새 자리 미규정 + "BC·common에서 `main.dart` import 금지" 미명시 (HaffHaff 실측: BC 4파일이 main import) — 아키텍트
10. shared_state의 keepAlive 여부 미규정 (autoDispose면 유실 — §8이 스스로 지적한 위험) — 아키텍트
11. "Repo는 단일 진실 원천" vs "직접 생성"의 긴장 — **UseCase·Repo·DataSource 무상태** 요구 미명문 — 아키텍트
12. StatefulShellBranch 조립 주체 미규정 ("branch 조립은 root_router, BC는 GoRoute만 export" 권고) — 아키텍트
13. BC 엔티티의 hive 영속 표기 자리 미규정 — 도메인 어노테이션이면 domain이 storage에 물듦 (hive_ce `@GenerateAdapters` infra 측 선언 권고) — 아키텍트
14. 골격 완비×개념 분할 = 빈 폴더 폭증 — 백스톱에 ".gitkeep 폴더의 비표준 파일" 검사로 상쇄 — 아키텍트
15. §3.3 "VM·View가 SharedState를 watch" — **"같은 BC의"** 한정 미명시 — 정합성
16. "common은 살아있는 상태를 갖지 않는다" vs 실예 TokenManager(가변 싱글턴) — 규범과 proxy(@riverpod 금지)의 간극 명시 — 정합성
17. §7.2 총괄표에 common 5종·design_system theme/·util/ 행 부재 — 정합성
18. design_system의 import 금지 규칙(→application·root) 미명문 (함의로만 존재) — 정합성
19. root/ 성장 규칙 — §4 위임이 BC 계층 문법이라 root에 그대로 적용 불가 — 정합성+정독
20. use_case의 `package:flutter/material` import 금지 미명시 (UI 호출 금지의 백스톱화) — 정합성
21. "과거형 사건명 shared_state 금지" 규칙이 §8 표에만 존재 — §3.3 본문 이동 — 정합성
22. common/service/value_object/·common/provider/state/ 비표준 폴더가 전수 조사 누락 — 정합성
23. "(15)" vs "(§9-15)" 참조 표기 혼재 — 정독

---

## 4. 시나리오 시뮬레이션 (아키텍트)

| 시나리오 | 결과 |
|---|---|
| (a) 새 BC 추가 (쿠폰) | **통과** — 파일 생성 전부 규칙만으로 결정 가능. 경미한 침묵 3건: 라우트 상수 표기(minor 8), parentNavigatorKey 자리(minor 9), exception.dart(minor 5) |
| (b) 푸시 → 쿠폰 상세 딥링크 | **막힘** — C1. 합법 배선이 존재하지 않음 |
| (c) 전역 강제 업데이트 게이트 | **막힘** — C2 + minor 6·7. 파일 이름은 결정되나 동작 배선이 결정 불가 |

---

## 5. 백스톱 가능 불변식 전수 목록 (§10-2 준비물 — 39종)

> 정합성 에이전트 목록 기준(아키텍트 23종과 합집합·중복 제거). ⚠ = critical/major 해소 후 확정 가능.

### 구조·경로 (11)
1. `lib/application/` 직속은 디렉터리만 (BC 목록 = `lib/application/*/`)
2. BC 직속 파일은 `<bc>_router.dart`·`<bc>_navigator.dart` 2종만
3. BC 하위 1뎁스는 4계층 고정 표기만 (화이트리스트 — `presentation_later` 류 오타 자동 검출)
4. 골격 완비 — §5 표의 모든 종류 폴더 존재 (+빈 폴더 `.gitkeep`)
5. `domain_layer/` 직속은 `<aggregate>/`만, 폴더 내 허용은 `<aggregate>.dart`·`exception.dart`·5종 폴더만 ⚠C5
6. application 5종 / infra 3종 / presentation 4종 화이트리스트 (개념 1차 시 개념 폴더 안 동일)
7. 구명칭 디렉터리 deny: `app/`·`bridge/`·`block/`·`viewmodel/`·`repo/`·`container/`·common `provider/`
8. `lib/root/` 직속은 4폴더만, scaffold만 view/·view_model/·state/ 보유
9. `root/` 이하 모든 파일명 `root_` 접두
10. design_system: foundation 7파일·`theme/app_theme.dart`·component 직속 파일 금지·정크드로어 군 금지
11. common 직속은 5종(enum·network·local_database·service·util)만

### import 방향 (12)
12. `domain_layer/**`에서 `package:flutter` import 금지
13. `root/`를 import하는 파일은 main.dart뿐 (root 내부 상호 import 제외 — minor 1)
14. `common/**`에서 `application/`·`root/` import 금지
15. `design_system/**`에서 `application/`·`root/` import 금지 (본문 명문화 필요 — minor 18)
16. 타 BC import는 4채널 경로만: `domain_layer/**`·`**/use_case/**`·`<bc>_navigator.dart`·`**/view/**` 허용, 그 외(infra·view_model·shared_state·state·section·widget) 금지 ⚠M5
17. view_model/·shared_state/·service/(app)에서 `infra_layer/`·`common/local_database/` import 금지 (Model 방향 UseCase만)
18. section/·widget/·ui_extension/에서 riverpod 패키지 import·`WidgetRef` 금지
19. widget/에서 `**/state/` import 금지 (화면 State 받기 금지의 경로 근사)
20. `<bc>_navigator.dart`에서 `presentation_layer/` import 금지
21. use_case/에서 `presentation_layer/`·`design_system/`·`package:flutter/material` import 금지
22. root/에서 BC `infra_layer/` import 금지 ⚠C3 (어댑터 예외 확정 후)
23. BC import 그래프 신규 순환 금지 — SCC 베이스라인 래칫
- (+추가 권고) `application/`·`common/`에서 `main.dart` import 금지 — minor 9

### 식별자·명명 (16)
24. 종류 폴더↔파일 접미사 일치 (긴 접미사 우선 — `_use_case`·`_vm`·`_state`·`_shared_state`·`_service`·`_repo`·`_data_source`/`_local_data_source`·`_view`·`_section`·`_widget`·`_ui_extension`·`_specification`)
25. 구접미사 deny: `_app.dart`·`_bridge.dart`·`_block.dart`·`_view_state.dart`·`_spec.dart`·`_btn.dart`
26. 파일명 = 주 클래스명 snake_case, 파일당 public 클래스 1개 (codegen·exception.dart 예외)
27. 삼총사: `<x>_vm.dart` 존재 → 동접두 `_view`·`_state` 존재 (VM 기준 단방향)
28. section 파일명은 같은 BC의 view 접두로 시작
29. widget 파일명에 같은 BC view 접두 포함 금지
30. `@riverpod` 허용 위치: application의 view_model/·shared_state/·service/ + root/scaffold/view_model/ ⚠C4·M1 (router·handler 처리 확정 후)
31. common 전체에서 `@riverpod` 금지
32. view의 `ref.watch` 인자는 자기 `<x>VMProvider`·`*SharedStateProvider`만 (정규식 근사)
33. BC presentation·component에서 `Color(0x`·생 `TextStyle(` 리터럴 금지 (foundation 제외; root/scaffold 포함 여부 — minor 3)
34. foundation 토큰 상수 lowerCamelCase·클래스 `App<토큰>`
35. component 부품군: `<군>/` 안 `*_<군>.dart`·클래스 `<수식><군>`·`ds_` 접두 금지
36. 라우트 path·name 문자열 리터럴은 `<bc>_router.dart` 안에서만 (grep 근사)
37. main.dart import 화이트리스트 (본문 명문화 필요)
38. ui_extension/ 파일은 최상위 선언이 `extension`만
39. 애그리거트 루트 파일명 = 애그리거트 폴더명

## 6. 기계 판별 불가 규칙 (17종 — 백스톱이 아니라 에이전트 지침·판별 절차 영역)

view/section 판별("VM이 필요한가")·"맥락" 판단·BC "어휘" 보유(import 없는 어휘)·"거의 빈 VM"·"BC 어휘 없는 게이트"·handler 입장("2+ BC 분배" — 사후 import 수 근사만)·귀속 규칙 3의 tie-break·조립 화면 vs 다수 BC 투영 화면·domain_service "중심" 판정·"두 번째 개념" 식별·"같은 개념 같은 철자"·과거형 사건명(형태소)·"export된" view(M5 해소 시 계산 가능으로 전환)·main.dart "최소형"·푸시 "정규화"(동작 의미론)·common "살아있는 상태"(proxy보다 넓음)·UseCase "도메인 개념 단위".

→ 운용 원칙: **백스톱 = 사후 불변식 39종(위반 검출), 에이전트 지침 = 판별 절차(배치 결정)**로 역할 분담하면 충분히 운용 가능 (양 에이전트 공통 결론).

---

## 7. 권고 처리 순서

1. **사용자 결정 6건** (아래 — C1·C2·C3·C4·C5·M7) → 본문 반영
2. §3.6에 "root 내부 협력 규칙" 절 신설 — C1·C2·M1·M2를 한 번에 닫음
3. 기계적 수정 일괄 — M3(§10 헤딩)·M4(§8 행 추가)·M5·M6(매트릭스 표)·minor 23건
4. M9 수치 — 측정식 병기 또는 재측정
5. 문서 상태줄 확정으로 변경 → §10-1 파이프라인 설계 착수

## 8. 처리 결과 (2026-06-12 — 전부 완료)

사용자 결정 7건(순서대로): ① C1 = root_destination_handler가 탭 청취·정규화 소유, `go(url)` 단일 디스패치 ② C2 = initializer 부수효과만, root_vm.build()가 UseCase 재조회 ③ M1 = handler 3종은 Service 변종(@Riverpod keepAlive), root_vm이 활성화 ④ C4 = rootRouter는 plain 전역 변수 ⑤ C3 = `<bc>_hive_adapters.dart` 표준화 + root_initializer만 import 예외 ⑥ C5 = 공용 위치 폐지 — 조율은 UseCase, 순수 판정은 주어 애그리거트 귀속 ⑦ M7 = **Either Right=성공**(기존 프로젝트 관례 우선 단서).

문서 반영 완료: §3.6 "root 내부 협력 규칙" 신설(M2 SharedState watch 허용·게이트 주인·redirect 메커니즘 포함), §3.7 계층 import 매트릭스 신설(M6), §10 헤딩 신설(M3), §8 drift 행 11개 추가(M4), 4채널 ④ "전 view 임베드 가능·표식 없음"(M5), M9 수치 재측정 교정(BC 16·App 44/36·VM 77/4·common 55/11·refresh 8BC/12VM), minor 1~23 반영. 불변식 목록의 ⚠ 3건(5·22·30번)은 위 결정으로 해소 — §10-2 백스톱 작성 시 그대로 발급 가능.
