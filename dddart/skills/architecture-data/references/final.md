# 데이터 아키텍처 — Either 계약·실패의 단일 출구·계약 스냅샷

> **출처:** 제1 규약(dddart 표준 파일트리, 2026-06-11~12) §3.4·§6·§9·§10-5 · dddart 파이프라인 본설계(2026-06-12) §2·§4·§5·§9 · 백스톱 스크립트 설계(2026-06-12) §7 · HaffHaff-App 실물 대조(2026-06-12).
> 본문 속 `(규약 §N)`·`(본설계 §N)`·`(백스톱 설계 §N)`은 **출처 표기**이며 로드 대상이 아니다 — 규칙 자체는 본문에 자족적으로 서술된다. 로드 가능한 위임은 "스킬명 + §번호(또는 주제)"와 공유 reference(`undecidable.md`)뿐.

---

## 목차

- §1. infra_layer 지도 — 단일 진실 원천 Repo와 세 이웃
- §2. 실패의 단일 출구 — safeApiCall 전 예외 정규화
- §3. Repo Either 계약 — Right=성공, 전 실패 Either
- §4. DataSource — 도메인 엔티티 직접 반환 (DTO 없음)
- §5. 로컬 데이터 2층 — BC 캐시 vs 엔진·전역
- §6. infra service — 수동 SDK 어댑터
- §7. 계약 스냅샷 체계 — 동결·기계 절단·사용 규율
- §8. 계약 위험 행위 — tracer 앵커

---

## §1. infra_layer 지도 — 단일 진실 원천 Repo와 세 이웃

infra_layer는 종류 3폴더다 (규약 §3.4 — 폴더·명명 사실은 discipline-houserules §1·§4):

| 종류 | 역할 | 계약 |
|---|---|---|
| `data_source/` 원격 | retrofit 추상 클래스 — 엔드포인트 정의 | 도메인 엔티티 **직접 반환** (§4) |
| `data_source/` 로컬 | BC 도메인 데이터의 로컬 저장 접근자 — hive box 읽기/쓰기 | §5 |
| `repository/` | **구체 클래스 (인터페이스 없음** — 규약 §9-1**)**. 원격·로컬 DataSource를 조합하는 **단일 진실 원천** | `safeApiCall`로 감싸 `Either<BadRequestResponse, T>` 반환 (§2·§3) |
| `service/` | 수동 SDK 어댑터 — 호출당하는 쪽 | §6 |

호출 방향: UseCase → Repo·infra service → DataSource·SDK. Repo·DataSource는 무상태 plain class이며 사용처가 직접 생성한다(DI 없음 — 규약 §9-13).

**이 스킬과 architecture-state의 경계** (본설계 §8 — 한 주제 한 소유자): data(이 스킬) = 데이터가 앱 바깥(서버·디스크)과 어떻게 오가는가 / state = 들어온 데이터가 앱 안에서 화면들 사이에 어떻게 살아 있는가. 판례 ① **캐싱**: hive 저장 = 이 스킬(§5), 메모리 keepAlive = architecture-state §9. ② **에러**: 서버 에러가 오는 모양(Either 계약·정규화 — §2·§3) = 이 스킬, 그 에러를 State에 담아 표시·소비하는 방식 = architecture-state §4.

## §2. 실패의 단일 출구 — safeApiCall 전 예외 정규화

`safeApiCall`은 DioException만이 아니라 **모든 예외**(타임아웃·JSON 파싱·타입 캐스트)를 잡아 `BadRequestResponse`로 정규화한다 (규약 §3.4 — §10-5 ① 확정). Repo·infra service는 어떤 실패도 throw로 탈출시키지 않는다 — **전 실패 = Either**.

- *왜* — HaffHaff 실측: 기존 safeApiCall은 DioException만 잡아 파싱 실패가 그물 밖으로 탈출해 미정의 동작(크래시·무한 로딩)이 됐고, 타임아웃은 `isShow:false`로 무음, 좋아요류 에러는 Either 통째 폐기 — **실패의 절반이 사용자에게 도달하지 못했다.**
- 서버가 에러 바디를 주면 `BadRequestResponse.fromJson`으로 그대로 싣고(서버가 보낸 `isShow`를 그대로 존중), 클라에서 생긴 실패는 `errorType`으로 기인을 구분해 생성한다 — 어휘는 `timeout`·`parse`·`unknown`.
- `BadRequestResponse`는 freezed 모델로 필드 3개다(HaffHaff 실물 철자): `errorType`(JSON `error_type`)·`msg`(`msg`)·`isShow`(`is_show`). **클라 생성 에러는 `isShow: true`로 만든다** — 위 *왜*가 "타임아웃은 isShow:false로 무음"을 고장으로 진단했으므로, 정규화가 그 무음을 재생산하지 않는다(표시·소비 정책 자체는 architecture-state §4 소유).

표준 골격 — 계약의 직역이다(dio·retrofit 표기법 상세는 implementation-flutter §4 소유):

```dart
// common/network/safe_api_call.dart — 파일명 = 주 선언명 snake_case. Right=성공 (§3)
Future<Either<BadRequestResponse, T>> safeApiCall<T>(
  Future<T> Function() apiCall,
) async {
  try {
    return Right(await apiCall());
  } on DioException catch (e) {
    final data = e.response?.data;
    if (data is Map<String, Object?>) {
      return Left(BadRequestResponse.fromJson(data)); // 서버 에러 바디 그대로 — isShow도 서버 값
    }
    final isTimeout = e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
    return Left(BadRequestResponse(
      errorType: isTimeout ? 'timeout' : 'unknown',
      msg: e.message ?? 'network error',
      isShow: true, // 클라 생성 에러 — 무음 재생산 금지
    ));
  } on FormatException catch (e) { // JSON 파싱
    return Left(BadRequestResponse(errorType: 'parse', msg: e.message, isShow: true));
  } on TypeError catch (e) { // 타입 캐스트
    return Left(BadRequestResponse(errorType: 'parse', msg: e.toString(), isShow: true));
  } catch (e) {
    return Left(BadRequestResponse(errorType: 'unknown', msg: e.toString(), isShow: true));
  }
}
```

## §3. Repo Either 계약 — Right=성공, 전 실패 Either

Repo의 공개 메서드는 `Either<BadRequestResponse, T>`를 반환하며 **Right=성공**이다 (규약 §3.4 — 통용 관례로 2026-06-12 확정. HaffHaff 실물은 Left=성공이었으나 dddart 표준은 통용 방향. **기존 프로젝트에 확립된 Either 방향이 있으면 그것 우선**).

```dart
// infra_layer/repository/channel_repo.dart
class ChannelRepo {
  final ChannelDataSource _remote = ChannelDataSource(DioClient.instance);

  Future<Either<BadRequestResponse, List<Channel>>> getChannels() =>
      safeApiCall(() => _remote.getChannels());
}
```

- **UseCase는 Repo의 Either를 통과·조합하며 새 throw를 만들지 않는다** — 조회 실패를 AsyncValue.error로 넘기는 throw는 VM의 일이다(architecture-state §4). UseCase 자체의 규율(도메인 개념 명명·판정 소유)은 architecture-ddd §8 소유.
- Either를 받아서 실패 쪽을 버리는 코드(성공만 fold하고 에러 무시)는 금지 — HaffHaff 실측 drift(좋아요류 에러 통째 폐기)의 재발이다. 에러를 표시하지 않는 결정조차 State의 error 필드를 거쳐 명시적으로 한다(architecture-state §4).

## §4. DataSource — 도메인 엔티티 직접 반환 (DTO 없음)

원격 DataSource는 retrofit 추상 클래스로 엔드포인트를 정의하고 **도메인 엔티티를 직접 반환한다** — `dto/` 계층이 없다 (규약 §3.4·§9-2). 서버 JSON은 도메인 엔티티(freezed + json_annotation)가 직접 파싱한다.

- 엔티티의 모델링(entity/value_object 구분은 architecture-ddd §3·애그리거트 경계는 §4)은 architecture-ddd 소유 — 이 스킬은 "유입 경로에 변환 계층을 두지 않는다"는 계약만 소유한다.
- 도메인 엔티티에 storage 어노테이션을 붙이지 않는다 — hive 어댑터 선언은 §5의 어댑터 파일 소속이다.
- retrofit `@RestApi`·dio 클라이언트 표기법은 implementation-flutter §4 소유.

## §5. 로컬 데이터 2층 — BC 캐시 vs 엔진·전역

로컬 저장은 2층으로 갈린다 (규약 §3.4·§9-9 — common 쪽 입장 판별은 discipline-houserules §6):

| 층 | 위치 | 담는 것 |
|---|---|---|
| BC 도메인 데이터 캐시 | 그 BC `infra_layer/data_source/<개념>_local_data_source.dart` | BC 엔티티의 hive box 정의·읽기/쓰기 |
| 엔진·전역 데이터 | `common/local_database/` | hive 초기화, 토큰·앱 설정 — BC 어휘 없는 것만 |

- **Repo 하나가 원격+로컬 DataSource를 조합**해 단일 진실 원천 역할을 한다 — 자리 부재로 생기던 `*_box_repo` 변형(HaffHaff drift)을 만들지 않는다.
- 다른 BC·전역 서비스가 이 데이터를 원하면 **이 BC의 UseCase를 호출**한다 — box 직접 접근 금지 (규약 §9-9: HaffHaff에서 member·notice 캐시가 common에 가면서 역의존과 문 없는 직접 접근 10곳+이 실측됐다).
- **hive 어댑터 노출**: BC 엔티티의 어댑터 등록 함수는 `data_source/<bc>_hive_adapters.dart` 한 파일에 모은다 — `root_initializer`가 import할 수 있는 유일한 BC infra 파일이다(시동 배선 — 규약 §3.4·§3.6). 어댑터 선언(@HiveType 저장 전용 Box 모델)도 이 파일 소속 — **@GenerateAdapters는 비채택**(패키지 1파일 강제가 BC 분산 선언과 충돌). hive 표기법·typeId 대역 규칙은 implementation-flutter §5 소유.
- 디스크 캐시(이 절) vs 메모리 keepAlive 캐시의 소유 경계는 §1 — 메모리 쪽은 architecture-state §9.

## §6. infra service — 수동 SDK 어댑터

`infra_layer/service/`는 **수동** SDK 어댑터다 — 호출당하는 쪽, 상태 없음, UseCase를 모름. Repo의 자매(서버 API 대신 플랫폼 SDK를 감쌈)다 (규약 §3.4).

- **능동이면 application, 수동이면 infra** (규약 §3.3·§3.4): 상태를 보유하고 플랫폼 이벤트에 반응하며 UseCase를 호출하면 `application_layer/service/`(architecture-state §6)다. HaffHaff drift 실례: `permission_service.dart`(keepAlive Notifier·App 호출·상태 노출)가 infra에 있었다 — 성격상 application 물건.
- SDK 호출의 실패도 §2와 같은 정신으로 Either로 정규화해 반환한다 — infra service는 어떤 실패도 throw로 탈출시키지 않는다.

## §7. 계약 스냅샷 체계 — 동결·기계 절단·사용 규율

서버 계약은 추측이 아니라 **동결된 스냅샷**이 사실의 출처다 (본설계 §2·§4·§5). 기능 산출물 폴더 `.dddart/<생성일>-<기능-slug>/`에 2종이 산다:

| 산출물 | 생성 시점 | 내용 | 독자 |
|---|---|---|---|
| `openapi-full.json` | G0(스코프 게이트) 승인 직후 동결 | OpenAPI 원본 **전체** — "관련 엔드포인트 절단"을 여기서 하지 않는다('관련' 판별은 LLM 재량이고 G0엔 명세가 없다) | architect · **data 리뷰어**(명세가 인용한 부분 대조 — G1 리뷰 시점엔 경량본이 아직 없다) |
| `server-contract.json` | G1(설계 게이트) 승인 직후 기계 절단 | 명세가 인용한 paths + `$ref` 전이 폐쇄 — LLM 손절단의 dangling `$ref` 차단 | coder · G2(구현 게이트) 검증 |

절단 도구는 `extract_contract.dart`다 (백스톱 설계 §7 — 도구 사양의 단일 근거. 게이트 도구가 아니라 파이프라인 도구):

```
dart run "${CLAUDE_PLUGIN_ROOT}"/scripts/extract_contract.dart \
  <openapi-full.json> --paths <paths-file> --out server-contract.json
```

- paths-file은 한 줄에 `GET /api/v1/members/{id}` — 명세가 인용한 엔드포인트 목록(Coordinator가 기계 추출). 인용 path가 동결본에 없으면 exit 1 + 누락 목록 + 근사 후보 병기 — **이것 자체가 발견이다**(존재하지 않는 엔드포인트 인용 = architect 임의 가정 → 설계 반송).

**에이전트별 사용 규율**:

- **architect**: 필요한 엔드포인트가 동결본에 없으면 **임의 가정하지 말고 보고**한다 (본설계 §5-1). 명세에는 인용 엔드포인트를 기계 추출 가능하게 적는다.
- **coder·G2**: **경량본(`server-contract.json`)만 본다** — full본 재해석 금지.
- **data 리뷰어**: 명세가 인용한 스냅샷(`openapi-full.json`의 해당 부분)을 직접 대조한다(타 노트·코드 안 봄) — 인용과 스냅샷의 불일치, 스냅샷 밖 가정(§8) 탐지가 일이다.
- 출처 URL 해소·재동결 절차는 Coordinator 소유(커맨드 정의) — 에이전트는 받은 스냅샷을 사실로 쓰되 **갱신하지 않는다**.

## §8. 계약 위험 행위 — tracer 앵커

스냅샷·기존 DataSource 패턴으로 **확인 불가한 의미 가정**이 걸린 행위는 명세에 `계약 위험`으로 표기한다 (본설계 §5-2·§9) — 예: 문서에 없는 필드 의미 추정, 페이지네이션 방식 가정, 에러 코드 의미 가정.

- 이 표기는 **tracer**(가장 위험한 경로의 종단 1줄기 선행 구현) 발동의 기계 앵커다 — 위험 가정을 가장 싸게, 가장 먼저 실물로 검증한다.
- 판정 기준·검증 절차(누락·과잉 탐지)는 공유 reference `undecidable.md` §12 소유다(`${CLAUDE_PLUGIN_ROOT}/skills/discipline-houserules/references/undecidable.md` — 1차 결정자 architect와 검증자 data 리뷰어가 같은 파일을 적재한다). 한 줄 요지: "이 행위가 틀렸다는 것을 컴파일·백스톱·스냅샷 대조 중 무엇도 못 잡는가?" — 그렇다면 계약 위험.
- 이 스킬의 §7 사용 규율과 한 몸이다: 스냅샷이 사실의 출처이므로, **스냅샷 밖 가정은 숨기지 말고 표기**한다 — 표기가 tracer·미니 게이트(사용자 눈 확인)로 이어져 가정이 조기 검증된다.
