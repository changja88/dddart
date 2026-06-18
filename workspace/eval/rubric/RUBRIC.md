# dddart 품질 평가지 v1 — 규칙 준수 + 기능 정확성 (평가 항목)

> **상태**: v1 (2026-06-13) — 코퍼스 9종 전수 조사 + 6축 적대 검증을 거쳐 도출(아래 §출처). *사용자 "동결됨" 확인 후 채점 착수*(미동결 채점 = §과적합 위반). `EVAL-METHOD.md` v2(품질 채점)와 정합.
> **목적**: 산출물이 ① **dddart 플러그인의 규칙(간소화 DDD·MVVM·하우스룰·Dart/Flutter 관용구)을 얼마나 잘 지키는가** + ② **요청 기능을 올바르게 구현했는가**를 측정한다. *baseline 대비 차별가치는 안 잰다 — 규칙 준수가 핵심.* 기능 정확성은 잰다(형태만 맞고 동작이 틀린 산출물을 거른다).
> **PASS 바 = 표준 규칙(앵커 아님)**: 판정 기준은 각 항목 §근거의 *코퍼스 표준 조항*이다. "플러그인이 실제로 낸 수준"을 바로 두지 않는다(순환 방지). 새 산출물은 표준 조항으로 채점한다.
> **명시적 비측정(과대주장 제거)**: baseline 대비 가치 · 미시 가독성·복잡도(유지보수성은 구조 대리까지) · 런타임 성능·보안(후속 트랙) · 명세 내적 품질(후순위) · 파이프라인 프로세스 규율(coder 경량본 사용·리뷰어 권한 경계 등 — `EVAL-METHOD.md` 소관) · **시각/디자인 충실도**(시안↔렌더 일치 — 레이아웃·간격·아이콘 처리·실제 색·미관): AI 채점자가 렌더를 못 봐 구조적으로 못 닫음 → **인간 오라클 위임·자동 채점 비측정(A1)**. VW-4/5는 토큰 단일출처·매핑 *거주*만 보지 *시안 일치*를 안 본다(결과지 구조·기능 PASS ≠ 시안 일치). 이들은 평가지 밖/위임/후속.
> **범위**: 이 문서 = 평가 *항목*. 채점·집계·완료 = `EVAL-METHOD.md`. 결과지 형식 = `rubric-metrix.md`. 고정 입력 = `tools/SCENARIO-*.md`.
> **레인 표기**: **결정** = 구조-인지 grep/스크립트·백스톱 러너 exit·`flutter analyze`. **의미** = 서브에이전트 grader 판단. **치명** = 치명 게이트(이진 PASS/FAIL, WEAK 금지).
> **Goodhart 차단(전역 규칙)**: 결정 레인 항목 다수는 텍스트만 피하면 통과한다. **의미 레인 FAIL이면 결정 스크립트 통과여도 그 항목 FAIL**(치명 항목은 치명 FAIL)이다 — dddjango status-객체 누수 교훈. 각 항목 *게이밍* 주의를 본다.

---

## A. TIER-S 척추 — 도메인 충실도 (S-DDD)
표준: `architecture-ddd/references/final.md` (+ cleancode 도메인 절)

| ID | 항목 | §근거 | PASS | FAIL | 레인 | 치명 |
|---|---|---|---|---|---|---|
| **SD-1** 판정 소유·빈혈 차단 | 도메인 어휘 판정·계산이 1곳째부터 domain 거주 | ddd §5·§9 / cc §8.2·§8.5 | "~할 수 있는가"·"~은 얼마인가" 류 판정·계산이 소비처 1곳이어도 domain(애그리거트 메서드·domain_service·specification·VO/enum)에 거주, VM은 변환만 | 새 판정이 BC domain에 0개이고 VM·view·State getter·ui_extension에만; **또는** 단순 변환·조립을 domain에 억지 투입(과잉 — 양면 게이트) | 의미 | ✅ |
| **SD-2** 루트 경유 변경 | 조건·계산·전이 갱신은 애그리거트 루트 메서드 | ddd §4 3규칙-1(§10-5 ③) | 조건/계산/전이가 걸린 갱신이 루트 메서드로 새 인스턴스 반환; Model 밖 copyWith는 분기·전이 없는 단순 복제뿐 | Model 밖(VM·UseCase·view)의 copyWith 호출에 분기·계산·전이 조건이 붙음 | 의미(+결정) | ✅ |
| **SD-3** 불변식 도메인 예외 검증 | 전이 조건 위반은 변경 메서드 안 도메인 예외 | ddd §4 3규칙-2 | 전이 조건 위반 시 루트 변경 메서드 안에서 `exception.dart`의 도메인 `*Exception` throw | 검증이 메서드 밖(VM·UseCase) 또는 일반 Exception·문자열; **생성 시점 검증으로 직파싱을 막으면 위반**(서버 데이터 정상 유입 차단) | 의미(+결정) | — |
| **SD-4** VO·엔티티 도메인 형태 | VO/엔티티가 freezed·도메인 연산을 자기 안에 보유 | ddd §3 | VO/엔티티가 @freezed + json_annotation 직파싱, 도메인 연산(add/multiply 류)이 VO/enum 메서드로 거주 | VO 밖에서 원시값(int/double) 도메인 산수, 또는 freezed 아닌 가변 VO | 의미(+결정) | — |
| **SD-5** 애그리거트 경계·참조 | 엔티티 소속·팩토리 생성·참조 형태 | ddd §3·§4 3규칙-3 | 엔티티가 애그리거트 루트/종속으로만, 도메인 규칙 걸린 생성은 애그리거트 팩토리, 참조는 **서버 중첩 응답=중첩 직파싱(면제)**·클라 신규 조립만 ID | 독립 엔티티 정의, 외부 규칙검사 생성, 클라 신규 조립인데 객체 통째 끌어안음 | 의미 | — |
| **SD-6** 도메인서비스·specification 귀속 | 교차 판정 귀속처·spec 형태 | ddd §6·§7 | 교차 애그 판정이 주어 애그리거트 domain_service에 stateless 거주(애그는 서비스 미주입), specification 풀네임(`_spec` 축약 0), 조합 계층은 실수요 시만 | common에 도메인 로직, 애그가 서비스 주입, `_spec` 축약, 수요 없는 조합 추상 선깔기 | 의미(+결정) | — |
| **SD-7** UseCase 관문 | 무상태 위임·Either 통과·UI 호출 금지 | ddd §8 | UseCase가 무상태 plain·도메인 위임·Repo Either 끝까지 통과/조합(새 throw 0·실패 침묵 폐기 0)·도메인 개념 명명·UI(flutter material/presentation/design_system·재export 사슬 포함) import 0 | 비즈로직 직접 구현·새 throw·실패 침묵 폐기·화면명 UseCase·**UI 호출(치명)** | 의미(+결정) | ✅(UI호출) |
| **SD-8** 비채택 패턴 미도입 | 간소화 DDD 음성 지식 | ddd §10 | event/·*Event·디스패처·port/·acl/·dto/·Repo 추상 인터페이스·DI 컨테이너 0; **이름 우회 변종**(개명 DTO·위장 이벤트)도 의미 레인 0 | 비채택 장치 도입(폴더·접미사 또는 의미 변종) | 의미(+결정) | — |
| **SD-9** 유비쿼터스 언어 — 계층 관통 철자 | 같은 도메인 개념이 계층 가로질러 동일 철자·어순 | ddd §2 | 동일 개념의 개념 폴더·파일이 domain/application/presentation에서 동일 철자(어순 포함) | `lounge_post_manage`↔`manage_lounge_post` 류 어순·철자 drift | 결정+의미 | — |

> **SD-1 주의(Goodhart·교차)**: 결정 레인만이면 도메인 어휘 없는 *빈 wrapper*를 domain에 두어 녹색 가능 → grader가 "실제 판정이 거주하는가"를 의미 확인해야 PASS. **VM이 specification을 import·평가하면 SD-1 위반**(SD-6 아님 — 판정 소유 단독 소유). enum 분류 판정(isShippable 류)이 enum 밖 VM/extension으로 흩어지면 SD-1 FAIL.
> **SD-7 주의**: "Either 통과·새 throw 금지"만으론 *침묵 폐기*를 못 막는다 — 실패를 삼켜 성공만 반환하는 변종은 DT-1과 교차로 잡는다.
> **SD-3 경계(컨버터/parse·measure-first 2026-06-18)**: SD-3는 *전이 조건 위반*(루트 변경 메서드)의 도메인 예외 검증을 본다 — '일반 Exception'·'생성 시점 차단' FAIL문언은 이 맥락이다. **fromJson 컨버터/직렬화 경계의 parse-throw(`FormatException` 등)가 `safeApiCall`로 정규화되고 *정상 서버값을 차단하지 않으면* SD-3 위반 아님**(parse=직렬화 관심사·architecture-ddd §3 컨버터 면제·safeApiCall 단일 출구). '생성 시점 검증 차단'은 *정상값까지 막는* 생성자 검증을 뜻한다(무검증 기본 생성자 + 별도 `.parse` 팩토리는 미저촉). 컨버터 parse-throw의 예외 *타입*(일반 vs 도메인)만으로 WEAK 주지 않는다 — parse 실패는 전이 invariant 위반이 아니므로 도메인 `*Exception`이 정답도 아니다.

---

## B. TIER-S 척추 — 뷰 계층·표현 분리 (S-VIEW)
표준: `architecture-ui/references/final.md` (+ flutter 위젯·cleancode FatWidget)

| ID | 항목 | §근거 | PASS | FAIL | 레인 | 치명 |
|---|---|---|---|---|---|---|
| **VW-1** Fat Widget 금지 | build는 표시·위임만 | cc §9.1 / ui | build/위젯 콜백이 표시·이벤트 위임만 | 권한·상태전이·가격 등 정책이 build에 | 의미 | ✅ |
| **VW-2** 3단 판별·과승격 금지 | view/section/widget 책임 배치 | ui §1·§4 | section/widget이 ref·자기 VM 없이 prop·콜백으로 성립, view 삼총사는 자기 상태·로직(ref 사유)이 실재할 때만; widget은 화면 State 미수신 | 자기상태·ref 0인데 _vm 과승격, widget이 화면 State 수신 | 의미 | — |
| **VW-3** dumb 조각 계약 | section/widget = ref·provider 금지 | ui / HR IM8·IM9 | section/widget에 ref·provider import 0, 데이터=prop·동작=콜백 | ref 보유, dumb 조각이 화면 전속 데이터를 prop 우회로 받음 | 결정+의미 | — |
| **VW-4** 시각 토큰 단일 출처 | foundation 토큰만·VM 시각 getter 금지 | ui §7 / HR NM10 | 색·타이포·duration이 App* 토큰(foundation 7파일) 참조, VM/State에 시각 반환 getter·design_system import 0 | 토큰 밖 시각 리터럴(`Color(0x…)`·생 TextStyle·`Colors.*`·생 Duration) 또는 VM/State 시각 매핑 | 결정+의미 | — |
| **VW-5** ui_extension = 도메인→UI 매핑 유일 자리 | 색·아이콘·라벨 매핑 거주 | ui §5 | 도메인 enum/VO→UI 매핑이 `*_ui_extension.dart` extension에만 | 매핑이 VM·State getter·design_system에 누수 | 의미 | — |
| **VW-6** 표시 소유·show() 금지 | 컴포넌트 자기표시 경로 차단 | ui §7 | design_system 컴포넌트가 전역키/전역 context로 자기를 띄우는 static 경로 0; 다이얼로그·시트는 View가 자기 BuildContext로 호출 | 컴포넌트가 전역키/context로 자기표시 static 메서드(이름 무관 show/present/display) 노출 | 의미 | ✅ |
| **VW-7** 라우트 단일 출처·navigator 분업 | 리터럴 router 안만·이름 참조 | ui §6 / HR | 라우트 path/name 리터럴이 `<bc>_router.dart`의 `abstract final class <Bc>Routes`에만, navigator는 pushNamed로 상수만·view import 0, BC는 GoRoute만 export(셸 조립은 root_router)·**내비 인자(path-param) 도메인값 직렬화는 VO/VM 소유**(뷰 onTap은 도메인 값을 VM에 위임하거나 VO 노출 키만 navigator에 전달) | 리터럴 산개(상수 우회·문자열 조립), navigator가 view import, BC가 StatefulShell 조립, **뷰 onTap·navigator·repo가 도메인값을 인라인 *포맷·변환***(`toIsoDate(date)`·`DateFormat().format(date)`·다필드 path 조립 류 — VO/VM 소유 위반·거주처 무관; 단순 식별자 `'$id'`·이미 String인 값 전달은 *변환 로직* 아님·제외) | 결정+의미 | — |

> **VW-7 주의**: 동일 BC 내 `navigator→router→view` import 사슬은 순환 아님(FAIL 금지). **정적 view(약관·안내)는 VM·State 없이 합법** — VW-2 삼총사 미완을 거짓 FAIL 내지 않는다.
> **VW vs SD 이중계상 금지**: build 내 정책 위반은 표현층(VW-1)·도메인층(SD-1) 중 한 번만 감점한다.

---

## C. TIER-S 척추 — 상태·뷰모델 (S-STATE)
표준: `architecture-state/references/final.md` + `implementation-riverpod/references/final.md`

| ID | 항목 | §근거 | PASS | FAIL | 레인 | 치명 |
|---|---|---|---|---|---|---|
| **ST-1** VM 책임 경계 | UseCase만·BuildContext/컨트롤러 미보유·변환만 | state §2 | VM의 Model 방향 호출이 UseCase 인스턴스뿐(Repo·DataSource·box·SDK·infra service import/생성 0), BuildContext·UI 컨트롤러 미보유(전환은 navigator), 자기 freezed State만 노출 | Repo/box/SDK 직행, BuildContext·TextEditingController 등 보유 | 결정+의미 | ✅(직행) |
| **ST-2** 에러 2채널 | 조회=build throw→AsyncError / 액션=State.error+listen+consumeError | state §4 | 조회 실패는 build()가 `BadRequestResponse` throw→AsyncValue.error; 액션 실패는 State.error(`BadRequestResponse?`) + ref.listen 감지·표시 후 모든 경로(isShow true/false 공히) consumeError() 소비 | 채널 혼선, throw 대상이 plain Exception/문자열, isShow:false 경로 미소비, **valueOrNull 사용(컴파일 불가)** | 의미(+결정) | ✅ |
| **ST-3** State 형태·노출 계약 | application/state freezed·자기 State만 | state | *State가 `application_layer/state/`의 @freezed, build()가 자기 freezed State만 반환(도메인 엔티티·PagingState 등 패키지 타입은 필드로 래핑), 액션 VM도 최소 State(error 1개) | domain_layer State, 패키지 타입·엔티티 직노출, error 필드 부재 | 결정 | — |
| **ST-4** ref 규율 | watch/read/listen/mounted/select | riverpod §4·§5 | watch=build 안만, read=핸들러·메서드 1회(리빌드 회피 아님), listen=build 안 부수효과, **await 직후 state 접근 전 `if(!ref.mounted)return`**, 부분구독 select, 재조회 invalidateSelf | build 밖 watch, 리빌드 회피 read, listen 내 상태변경, mounted 누락·가드가 await 경계 밖, 무전제 requireValue | 의미(+결정) | ✅(mounted) |
| **ST-5** provider 형태·표기 | 클래스형·top-level·family·keepAlive·legacy 금지 | riverpod §2·§9 | 모든 @riverpod이 클래스형(`class extends _$X`)·top-level codegen final, family는 build 인자, keepAlive는 `@Riverpod(keepAlive:true)`, legacy provider·`legacy.dart` import 0 | 함수형(읽기전용 파생값 클래스 위장 포함), 동적 생성, legacy 직참조·재export 우회 | 의미(+결정) | — |
| **ST-6** SharedState·교차 BC | 전파·교차 watch·갱신버스 | state §7·§8 | 데이터 변화는 그 BC keepAlive SharedState(+공개 reset)로, 타 BC SharedState/VM watch 0(root만 면제), 갱신버스(refresh_notifier)·신호버스 0, 명사 관심사 명명 | 타 BC watch(root 외), 타 BC·common이 refresh/invalidate 호출, reset 부재, 과거형/DateTime·카운터 핵 이벤트 위장 | 의미(+결정) | — |
| **ST-7** root 합성 구조 | root_vm·handler·initializer·rootRouter | state §10 | root_vm=앱 전역 표시 상태만, handler 3종=keepAlive Notifier·root_vm이 watch 활성화, root_initializer=부수효과만(결과 반환 0), rootRouter=plain 전역 변수(provider 아님) | root_vm에 BC 도메인, handler plain class, initializer 결과 반환, rootRouter provider화 | 결정+의미 | — |
| **ST-8** 비채택 (retry OFF·hooks·valueOrNull 등) | 금지 표면 | riverpod §8·§9 | main.dart ProviderScope `retry:(_,__)=>null` 1줄, hooks_riverpod·copyWithPrevious·valueOrNull·Mutations·신호버스 0; 특수 화면 per-provider opt-in은 합법 | 전역 retry OFF 부재, 비채택 표면 사용, 동형 신호버스 | 결정+의미 | — |
| **ST-9** base VM·공용 헬퍼 금지 | 정식 예제 반복 | state §2·§4 | 각 VM이 `_$VM`만 extends, 에러·listen·consumeError를 §4 정식 예제대로 본문 인라인 반복 | base/추상 VM, 공용 에러/listen mixin·extension·추출 헬퍼 | 결정+의미 | — |

> **ST 주의**: ST-7(root)·ST-6(교차 BC)은 단일 BC 신규 기능 산출물에선 거의 미발화 — **root 미변경·SharedState 부재를 거짓 FAIL 내지 않는다**(발화 조건: 교차 watch/refresh·root 변경 *발생 시*만). ST-1의 *판정 누수*(VM이 도메인 분기 후 State getter 위장)는 SD-1 단독 소유 — 여기서 중복 채점하지 않는다.

---

## D. TIER-S 척추 — 데이터·계약 (S-DATA)
표준: `architecture-data/references/final.md` + `implementation-flutter/references/final.md`(retrofit/hive/dio)

| ID | 항목 | §근거 | PASS | FAIL | 레인 | 치명 |
|---|---|---|---|---|---|---|
| **DT-1** Either 실패 계약 | Repo Future<Either>·Left 비폐기 | data §3 | Repo 공개 시그니처 `Future<Either<BadRequestResponse,T>>`(기존 프로젝트가 Left=성공이면 그 방향 존중), 모든 소비처가 Left를 폐기 않고 상위 전달 | Either 미사용 / Left를 fold·map에서 무시하고 성공만(텍스트상 fold 있어도 Left 분기 no-op이면 FAIL) | 의미(+결정) | ✅ |
| **DT-2** 단일 출구·throw 금지 | safeApiCall | data §2·§6 / fl §4 | Repo·infra service throw/rethrow 0, 외부 호출은 safeApiCall로 감싸 Either, safeApiCall이 DioException·FormatException·TypeError 개별+catch-all, 인터셉터 onError는 통과(정규화 안 함) | throw 탈출·rethrow·Future.error 우회, 인터셉터가 에러 정규화(단일 출구 깨짐) | 의미(+결정) | ✅ |
| **DT-3** BadRequestResponse 계약 | 3필드·어휘·isShow | data §2 | **(신규 도입 시)** freezed 3필드 errorType/msg/isShow(JSON error_type 등), 어휘 timeout·parse·unknown, 클라 생성 isShow:true·서버 바디 fromJson isShow 보존 | 필드·철자·어휘 일탈, 클라 생성 무음(isShow:false) | 결정+의미 | — |
| **DT-4** DTO 없음·엔티티 직반환 | 유입 변환 계층 부재 | data §4 | DataSource 반환이 도메인 엔티티(컬렉션), dto/·DTO·매퍼 0, 서버 JSON은 엔티티 freezed 직파싱 | DTO 계층 또는 **이름 바꾼 변환 계층**(Model/Response/Mapper/extension)으로 직반환 우회 | 의미(+결정) | — |
| **DT-5** Repo/DataSource 형태 | 구체·무상태·직접 생성 | data §1 | Repo가 인터페이스 없는 단일 구체 클래스(원격+로컬 조합), Repo·DataSource 무상태 plain·직접 생성(DI 없음) | 추상 인터페이스, 가변 상태 필드, DI 컨테이너 | 결정+의미 | — |
| **DT-6** retrofit DataSource 표기 | @RestApi·factory·part·엔티티 직반환 | fl §4 | @RestApi() abstract+factory(Dio,{baseUrl})+part, @GET/@POST/@Path/@Query/@Body, 반환 Future<엔티티>/Future<List>/Future<void> | HttpResponse<T> 원시 반환, 어노테이션 누락 | 결정 | — |
| **DT-7** hive 로컬 캐시 | Box 모델·typeId·2층·listenable 금지 | fl §5 / data §5 | **(로컬 캐시 둘 때)** @HiveType은 저장 전용 Box 모델에만(엔티티 무어노테이션·Box↔도메인 변환은 `_local_data_source` 표기로 합법), typeId 전역 유일+대역 주석, isAdapterRegistered 가드가 openBox 전, BC 캐시는 `_local_data_source`, box는 put/get만, @GenerateAdapters·*_box_repo·타 BC box 직행 0 | 엔티티에 @HiveType, listenable로 UI 갱신, 타 BC box 직행 | 결정+의미 | — |
| **DT-8** 계약 스냅샷 운용 | 동결본 대조·계약 위험 표기 | data §7·§8 | 산출물 인용 path가 `server-contract.json` 동결본에 실재(extract_contract exit 0), 스냅샷 밖 의미 가정은 명세에 "계약 위험" 명시하고 그 표기가 실제 미확인 가정과 일치 | 없는 엔드포인트 인용, 가정 무표기, "계약 위험" 글자만 박고 실제 위험 누락 | 결정+의미 | — |
| **DT-9** infra service = 수동 어댑터 | 무상태·UseCase 모름·실패 Either | data §6 | **(SDK 어댑터 둘 때)** infra service가 무상태(가변·keepAlive·상태 노출 0)·UseCase import 0·실패 Either 정규화; 능동(상태·이벤트 반응·UseCase 호출)은 application service | infra service가 능동·throw 탈출 | 결정+의미 | — |

> **DT-1 vs ST-2 직교**: DT-1은 *Left 비폐기·소비처 전달*(생산·계약면)까지, *표시·consumeError·isShow*(소비면)는 ST-2 단독. **DT-4 vs SD-4 직교**: SD-4는 "VO에 도메인 연산 거주", DT-4는 "유입 변환 계층 부재" — 같은 코드를 다른 기준으로 본다(이중 감점 금지).

---

## E. TIER-S — 하우스룰·구조 (S-HR)
표준: `discipline-houserules/references/final.md` (+ `undecidable.md`)

| ID | 항목 | §근거 | PASS | FAIL | 레인 | 치명 |
|---|---|---|---|---|---|---|
| **HR-1** 4계층·BC 컨테이너 | 위치·계층·직속 | hr §0 | 신규 BC가 `application/<bc>/` 하위, BC 1뎁스={domain,application,infra,presentation}_layer, BC 직속 2파일(router·navigator)만, application/ 직속 BC 폴더만 | 루트 평면, 4계층 누락/평면, 직속 잡파일 | 결정 | ✅ |
| **HR-2** 종류 폴더·접미사 | 화이트리스트·지정 접미사 | hr §0·§4.2 | 새 파일이 계층별 종류 폴더 화이트리스트 안, 폴더별 *지정* 접미사(view_model→`_vm`·repository→`_repo`·shared_state→`_shared_state`[긴 우선]·나머지 동명) 일치 | 화이트리스트 밖 폴더(provider/·viewmodel/ 등) 또는 폴더-지정접미사 불일치 | 결정 | — |
| **HR-3** 신규 골격 완비 | 4계층+종류 폴더+.gitkeep | hr ST4 | 신규 BC가 4계층·종류 폴더 전부·애그리거트 루트, 빈 폴더 .gitkeep | 골격 누락 | 결정 | — |
| **HR-4** 계층 import 역류 금지 | §5 매트릭스 | hr §5 | domain은 순수 Dart만(flutter·common 포함 비순수 0), application은 presentation import 0, presentation은 infra import 0, infra는 상위 import 0 | 매트릭스 ✗ 셀 위반 | 결정 | ✅ |
| **HR-5** 교차 BC 4채널만 | 도메인타입·UseCase·navigator·view | hr | 타 BC import가 도메인 타입(entity·VO·enum·애그루트·exception)·UseCase·navigator·view뿐, 신규 순환 0 | 4채널 밖 import(타 BC application/infra/presentation 내부), 신규 순환 | 결정+의미 | ✅ |
| **HR-6** 파일·클래스 명명 | 파일명=클래스·구접미사 금지 | hr §4 | 파일명=주 public 클래스 snake_case(public 1선언), 구접미사(_app·_bridge·_block·_view_state·_spec·_btn) 0, 애그리거트 루트 철자 일치, foundation 토큰 App 접두·lowerCamelCase | 변형 접미사·복수 public·철자 불일치 | 결정 | — |
| **HR-7** root/common/design_system 경계 | 접두·폴더·BC어휘·import | hr §4·§6 | root/ 이하 root_ 접두·역할 4폴더, root import는 main.dart만, common 직속 5폴더(enum·network·local_database·service·util)·BC 어휘 0(필요 시 콜백 주입·root_initializer 배선), design_system import 화이트리스트·application/root import 0 | common에 BC 어휘·@riverpod·살아있는 상태, design_system이 application/root import, root 외부 import | 결정+의미 | — |
| **HR-8** 화면 삼총사·section/widget 접두 | VM 기준 동거·전속 접두 | hr | `<x>_vm`이 있으면 `<x>_view`·`<x>_state` 동거(정적 view 면제), section 소속 화면 접두, widget 화면명 금지(BC명=화면명 겹침은 예외) | VM 있는데 삼총사 미완, section 무접두, widget이 화면명 보유 | 결정+의미 | — |
| **HR-9** 개념 1차·종류 2차 성장 | 분할 후 직속 동결 | hr §2 | 단일 개념 BC는 종류 폴더 직속이 정상, 둘째 개념 확정 시 개념 폴더 분할·이후 신규는 개념 폴더(infra 미분할) | 분할 후에도 직속 폴더에 신규 파일, infra를 개념 분할 | 결정+의미 | — |

> **HR 결정 PASS ≠ 실질 보증(교차 의존)**: HR-3 빈 골격·HR-8 빈 삼총사·HR-5 채널④ 경로-only는 *구조·이름만* 본다 — 빈혈/디코이 실질은 SD-1·ST-1·의미 레인이 막는다(교차 표기). **@riverpod 허용 위치**(VM·SharedState·service·root 2변종) 닫힌 열거는 houserules 소유이나 ST-5와 같은 규칙(채점은 ST-5에서, HR이 위치 권위). **백스톱 러너는 added/신규 단위만 발화** — 레거시 불발화·codegen(.g/.freezed)·exception.dart 다중 클래스를 결함 오판 금지.

---

## F. 빌드 게이트 (BUILD) — dddart 고유 (테스트 약함·codegen 의존)
표준: `implementation-dart §1·§4` · `implementation-flutter §2` · houserules §4·§8(analyze green 래칫)

> **성격**: 위반=빌드 실패·산출물 무가치 = **치명**. dddart는 산출물 테스트가 얕고 codegen(freezed/json/retrofit/riverpod)에 의존해, "컴파일·정적분석이 통과하는가"가 1차 정확성 기질이다. TIER-Q(품질 카운트)와 분리해 게이트화한다.

| ID | 항목 | §근거 | PASS | FAIL | 레인 | 치명 |
|---|---|---|---|---|---|---|
| **BG-1** 컴파일 가능 | codegen·키워드·SDK 문법 | dart §1·§4 / fl §2 | freezed 단일생성자 `abstract`·union `sealed` 키워드, 본문 멤버 시 `const X._()`, codegen part 지시문(`.freezed.dart`·`.g.dart`) 완비, GoRoute builder/pageBuilder 필수, SDK ^3.9 문법 상한(3.10+ dot shorthand·private named params 0), valueOrNull 0 | 키워드/const X._()/part 누락·3.10+ 문법·valueOrNull = 컴파일 불가 | 결정 | ✅ |
| **BG-2** analyze green 래칫 | added 코드 신규 이슈 0 | hr §4·§8 / cc §16·§17.1 | `flutter analyze`가 added 코드에 새 error·warning 0(baseline 대비 신규 이슈 래칫) | added 코드가 새 analyzer 이슈 도입 | 결정 | ✅ |

---

## G. TIER-S 핵심 — 기능 정확성 (FC)
> 형태가 맞아도 *동작이 틀리면* 무가치다. FC는 코드가 **요청 기능을 실제로 올바르게** 하는지를 *명세와 독립된 외부 기준*으로 잰다(그린바인데 기능 오류인 순환 차단). **치명 게이트.**

| ID | 항목 | PASS | FAIL | 레인 | 치명 |
|---|---|---|---|---|---|
| **FC-1** 골든 오라클 | 평가자가 *명세 무관* 외부 행위표(SCENARIO §1 — 중요 공지 상단 고정·배지·당겨 새로고침 등)를 *채점 전* 사전등록하고 코드를 그 표로 직접 두드림 | 모든 골든 케이스 일치 | 하나라도 불일치(정렬·표시·동작) | 의미(외부 오라클) | ✅ |
| **FC-2** 테스트·메커니즘 비-vacuous | 핵심 로직에 mutation(정렬 역전·조건 반전·status 값) 주입 후 **행위 종류별 맞는 seam의 테스트가 red**인지 확인(판정=순수 도메인 단위·view=VM-override 위젯·통합=integration); 재탭 2단·내비 등 lint 사각은 위젯테스트로 행위 검증 | mutation마다 red·메커니즘 행위 검증됨 | mutation에도 green(헛 테스트)·메커니즘 미검증 | 결정(주입 실행) | ✅ |
| **FC-3** 도메인 정합(negative gate) | 명백한 도메인 오류 부재(중요 공지 하단·배지 누락·새로고침 미동작·차감 역전 등) | 명백 오류 0 | 명백 오류 1+ | 의미 | ✅ |

> FC 골든 표는 SCENARIO별로 *채점 전에* 사전등록(과적합 방지). FC vs SD: SD는 "비빈혈 형태", FC는 "그 판정이 맞나" — 비빈혈인데 틀린 모델은 SD PASS·FC FAIL.

---

## H. TIER-Q 품질 (카운트 기반 — 치명 아님; `EVAL-METHOD.md` 등급)
표준: `implementation-dart` + `discipline-cleancode` + `implementation-flutter`(표기)

| ID | 항목 | §근거 | PASS | FAIL/WEAK | 레인 |
|---|---|---|---|---|---|
| **Q-1** Dart 명명·타입 표기 | dart §2·§명명 | 클래스/enum/typedef/extension UpperCamel·변수/멤버/상수 lowerCamelCase(SCREAMING_CAPS 0)·3자+ 약어 단어화·2자 유지·공개 식별자 선행 _ 0·헝가리안 0·bool 긍정형·**지역 변수 타입 명시**(추론은 뷰 ref 바인딩·타입 박힌 리터럴 한정 — dart §2 일탈3) | SCREAMING_CAPS 상수·헝가리안·부정형 bool·공개 선행 _·**허용 예외 밖 지역 변수 타입 미명시** | 결정 |
| **Q-2** freezed 표기(비컴파일부) | dart §4·§5 | 컬렉션 갱신은 새 리터럴 합성+copyWith, union 분기는 `_` 디폴트 없는 소진 switch(when/map 0) | 컬렉션 제자리 변경, 소진 switch에 `_` 삽입, when/map 사용 | 결정 |
| **Q-3** dartz Either 표면 | dart §8 | 표면 고정(Either/Left/Right/fold/map/flatMap만)·fold Left 첫인자·map은 Right만·dartz 유지 | IList·Option·연산자·fpdart, fold 순서 오류 | 결정 |
| **Q-4** null 안전 관용구 | dart §3 | promotion(지역변수 복사)·??·패턴 우선, `!`는 보호절/promotion 불가 자리 단일 최후수단, required(non-null 무기본 named) | `!` 연쇄(`x!.y!`), nullable 명시 null 초기화, 공개 late final(무초기화) | 결정+의미 |
| **Q-5** 직렬화 표기 | dart §4 | @JsonKey 생성자 부착·서버 키 명시 매핑, enum @JsonValue·unknownEnumValue, 중첩 전송 explicitToJson, custom 변환 top-level/static | @JsonKey 오부착, 인스턴스 메서드 custom 변환 | 결정 |
| **Q-6** catch 위생 | dart §2 / cc | 일반 코드 catch는 on절 구체 타입, Error/무차별 캐치 0, 재던질 때 rethrow, 빈 catch 0 | on절 없는 catch·on Error·throw e 재설정·침묵 삼킴(safeApiCall·의도 폴백은 면제) | 결정+의미 |
| **Q-7** 잔여 구조 스멜 | cc | 죽은 코드 0·매직넘버 상수화·보호절·CQS·플래그 인자 0·중복 표현식 추출 | 도달 불가 코드·정당화 없는 매직넘버·플래그 인자·CQS 위반 | 결정+의미 |
| **Q-8** import 정렬·주석 형식 | dart / cc §4·§5 | import dart:→package:→상대·구획 알파벳, 블록 주석 0, doc은 `///`·첫문장 요약·bool은 Whether | import 순서·구획 위반, `/* */` 블록 주석, /// 양식 위반 | 결정+의미 |
| **Q-9** flutter 내비 표기 | fl §2·§3 | go=교체/push=쌓기·pushNamed, CustomTransitionPage(duration=토큰)·탭은 NoTransitionPage, redirect는 UseCase(context 비사용), StatefulShellRoute.indexedStack·탭 인덱스=navigationShell.currentIndex | go/push 오용·매직 duration·redirect가 context 사용·별도 탭 인덱스 상태 | 결정+의미 |

> **Q 카운트 주의(거짓 FAIL·게이밍)**: 수치(결정 10·500줄·50줄)는 *재설계 고려 가이드*이지 하드컷 아님(초과만으로 FAIL 금지). Tell-Don't-Ask·캡슐화는 DTO·조회모델·VO·State 면제. doc 주석 *존재*는 강제 아님(형식 위반만 감점·Effective Dart 위임). Fat Widget→VW-1, 시각 매직→VW-4, 미사용 추상→SD-8, base VM→ST-9 소유(Q-7서 중복 채점 금지). `rootRouter.go`(context 없는 전역 내비)는 위반 아님.

---

## 동결 전 결정 (사용자 "동결됨" 확인 대상)

1. **치명 게이트 목록(보수적 17)**: SD-1·SD-2·SD-7(UI호출) / VW-1·VW-6 / ST-1(직행)·ST-2·ST-4(mounted) / DT-1·DT-2 / HR-1·HR-4·HR-5 / BG-1·BG-2 / FC-1·FC-2·FC-3. — "틀리면 산출물 무가치"만(적대 검증 보수 배정). 의미 레인 FAIL이면 치명 항목은 치명 FAIL(Goodhart 차단).
2. **빌드 게이트(F) 신설**: dddjango에 없는 dddart 고유 — 테스트 약함·codegen 의존이라 컴파일·analyze green이 1차 정확성. 치명.
3. **MVVM 분리**: 통합 S-MVVM 대신 S-VIEW(표현)+S-STATE(상태) 2축(코퍼스 조사 신호 99:8). view↔vm↔state 결선은 VW-2·HR-8 교차.
4. **TIER-Q 카운트 기반**: 가중치 수치 미정의 → 카운트 등급(`EVAL-METHOD.md`). BG로 컴파일 전제 이관, 잔여만 품질.
5. **조건부 차원**: DT-3(BadReq 신규 도입 시)·DT-7(로컬 캐시 둘 때)·DT-9(SDK 어댑터 둘 때)·ST-6·ST-7(교차/root 발생 시) — 미발화 시 N/A(FAIL 아님).
6. **미동결(후속)**: 앵커(첫 산출 후 예시로·임계값 금지)·FC 골든 표(SCENARIO별 채점 전 사전등록)·보안 차원.

## 교차 채점 규칙 (이중계상 방지)
- 판정 누수: **SD-1** 단독(VM 위장 포함) · VM 구조 직행/BuildContext: **ST-1**.
- VO 도메인 형태: **SD-4** · 유입 변환계층 부재: **DT-4**.
- Either Left 비폐기: **DT-1** · 표시·소비(consumeError·isShow): **ST-2**.
- show()/표시 소유: **VW-6** · 라우트 단일출처: **VW-7** · @riverpod 위치: **ST-5**(HR 권위).
- HR 결정 PASS는 실질(빈혈·디코이) 보증 아님 → SD-1·ST-1·의미 레인 교차.

## 출처
- **코퍼스 조사**: 워크플로우 `wyzdio23w` — 9스킬×2렌즈 18에이전트(추출자/적대보완자), A후보 333 + B갭 109.
- **적대 검증**: 워크플로우 `wf_81f22781-657` — 6 구조축 검증(53항목·**drop 0**·근거 슬립 3 교정·치명 promote 3/demote 2·누락 14 흡수).
- 합성·작성·판정 소유: 메인 루프. 검증 입력 노트 `_synthesis-dimensions.md`(폐기).

(채점 절차·집계·등급·완료 = `EVAL-METHOD.md` · 결과지 = `rubric-metrix.md` · 고정 입력 = `tools/SCENARIO-S1.md`)
