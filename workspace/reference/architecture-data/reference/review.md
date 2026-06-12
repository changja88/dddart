# architecture-data 합성 전 리뷰 — 다출처 통합·경계 결정 기록

> Wave 2 규약 직접 인용형 — internal/external 없음. 다출처(규약 + 본설계 + 백스톱 설계) 통합 시의 정규화·경계·공백 기록.
>
> **원료**: 제1 규약 §3.4(전문)·§9-1·§9-2·§9-9 + 본설계 §2(산출물 정의)·§4(서버 계약 출처 해소)·§5-1·§5-2(계약 위험 표기)·§5-7(기계 절단)·§9(신규 1 검증=data) + 백스톱 설계 §7(`extract_contract.dart` — **도구 명칭·사양의 단일 근거**) + HaffHaff 실물(safeApiCall·BadRequestResponse — 2026-06-12 확인).

## A. 출처 간 정규화

| 규칙 | 등장 절 | final 서술 위치 |
|---|---|---|
| 실패의 단일 출구(safeApiCall 전 예외 정규화) | 규약 §3.4 · §10-5 ① | final §2 |
| Either Right=성공 | 규약 §3.4 · §9-7 · §10-5 ② | final §3 |
| 로컬 2층 | 규약 §3.4 · §6 · §9-9 | final §5 (common 쪽 사실은 houserules §6 위임) |
| 계약 스냅샷 2종(full/contract) | 본설계 §2 · §4 · §5-7 · 백스톱 §7 | final §7 |
| 계약 위험 행위 | 본설계 §5-2 · §9 · undecidable §12 | final §8 (판별 절차는 undecidable §12 위임) |

**HaffHaff 실물 대조(2026-06-12)** — dddart 표준이 무엇을 교정하는지 확정:

- 실물 `safeApiCall`은 `Either<T, BadRequestResponse>`(**Left=성공**)·**DioException만** 캐치·비표준 바디는 `errorType: 'Unknown', isShow: false` 폴백. dddart 표준은 ① 방향 교정(Right=성공 — 통용 관례) ② 전 예외 정규화(타임아웃·파싱·캐스트 — "그물 밖 탈출"이 규약 §3.4가 지적한 실측 결함) ③ errorType 어휘 `timeout`·`parse`·`unknown`.
- `BadRequestResponse` 실물 필드: `errorType`('error_type')·`msg`('msg')·`isShow`('is_show') — final 예제에 실물 철자 사용(`message` 발명 금지).

## B. 소유 경계 결정

- **vs houserules**: infra 종류 폴더·파일 명명·"repository 폴더 전체 표기 + `_repo.dart` 축약" 등 표기 사실 위임(houserules §1·§4). common/local_database 입장 판별은 houserules §6.
- **vs state**: 에러가 오는 모양(Either·정규화)=data / State에 담아 표시·소비=state(state final §4). 캐싱 — hive=data / 메모리 keepAlive=state(state final §9). UseCase가 Either를 통과하고 throw는 VM의 일 — 이 문장은 양쪽에 걸치므로 data §3은 "Repo→UseCase 통과"까지, VM throw는 state §4 위임.
- **vs ddd(전방)**: 도메인 엔티티의 모델링(애그리거트·entity)·판정 소유는 ddd. data는 "DataSource가 도메인 엔티티를 직접 반환(DTO 없음)"이라는 유입 경로 계약만.
- **vs flutter(전방)**: retrofit `@RestApi`·dio·hive **표기법** 위임. data는 종류별 역할·계약만.
- **vs undecidable §12**: '계약 위험 행위' **판별 절차·검증 기준**은 공유 reference 소유(1차 architect·검증 data 리뷰어가 같은 파일 적재). data final §8은 스냅샷 체계 안에서 tracer 앵커가 작동하는 **흐름**(동결→절단→위험 표기→tracer 발동)을 소유.
- **본설계 절차 중 Coordinator 소유분**: 폴더 생성·config.json 관리·재동결 질문은 §10-4 커맨드 정의 소유 — data final §7은 **산출물의 의미와 에이전트 사용 규율**(architect: 동결본에 없으면 임의 가정 말고 보고 / coder·G2: 경량본만 본다 / 리뷰어: 명세가 인용한 스냅샷 부분 대조)만 싣는다.

## C. 공백·발명 위험 (P1 기록 대상)

1. **safeApiCall 표준 구현 전문** — 규약은 계약(전 예외→BadRequestResponse 정규화·errorType 3어휘)만 명시, 코드 없음. final §2는 시그니처+동작 계약+최소 골격 예제로 서술하고, 완성 구현은 코드 생성 시점의 일로 남긴다(발명 아님 — 계약의 직역).
2. **BadRequestResponse 확장 필드** — dddart가 클라 생성 에러(timeout·parse)를 같은 타입에 담으므로 서버 JSON 키와 무관한 생성자 호출이 생긴다. 실물 필드 3개로 충분(추가 필드 발명 금지).
3. **페이지네이션·헤더·인증 등 API 관례** — 원료에 없음. 서술하지 않는다(스냅샷이 사실의 출처 — §7의 "스냅샷 밖 가정 = 계약 위험"이 이 공백의 처방).
4. **클라 생성 에러의 isShow 값** (4렌즈 1라운드 fidelity P1 — 사후 기록): 초안은 HaffHaff 실물을 따라 `isShow: false`로 썼으나, 규약 §3.4 *왜*가 "타임아웃은 isShow:false로 무음"을 **고장**으로 진단한 지점이라 실물 추종이 고장의 재성문화였다(실물 추종이 면책 근거가 되지 않는 지점 — 규약 §1 원칙 1의 교정 우선). 규약 *왜*("실패의 절반이 사용자에게 도달하지 못했다")의 직접 함의로 **`isShow: true`** 채택. 발명이 아니라 문면 도출이며 P1 표에 근거 기록.

## D. final 구조 (8절)

§1 infra_layer 지도(단일 진실 원천 Repo·lens 경계) / §2 실패의 단일 출구(safeApiCall) / §3 Repo Either 계약 / §4 DataSource(원격 직반환·DTO 없음) / §5 로컬 데이터 2층(hive 어댑터 노출 포함) / §6 infra service(수동 SDK 어댑터) / §7 계약 스냅샷 체계(동결·기계 절단·사용 규율) / §8 계약 위험 행위(tracer 앵커).

코퍼스 설계안 §3 data 행 골격 대조: 실패의 단일 출구(§2)·Repo Either 계약(§3)·로컬 2층(§5)·계약 스냅샷·extract_contract 사용법(§7)·계약 위험 행위 판별(§8) — 전부 커버.
