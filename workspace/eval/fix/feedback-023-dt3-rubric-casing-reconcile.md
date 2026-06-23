# feedback-023 — DT-3 RUBRIC 철자/케이싱 채점 경계 화해 (eval 단일출처)

> 사전등록형 원장(eval-fix-ledger). 예상효과 먼저·다음 런(17차) 실측 대조.
> **상태**: 시술 완료 · 17차 검증 대기. **scope**: eval 단일출처(RUBRIC.md만)·**코퍼스 무변경·미러 불요·동결 불요**.

## 회차/증상
- **16차**(`20260623-1331`) codex DT-3 **🟡 비치명**. `bad_request_response.dart`:
  - `final class BadRequestResponse` — **plain class**(@freezed 아님)
  - 손수 작성 fromJson: `json['errorType']`·`json['isShow']` (**camelCase 키**), `@JsonKey` 전무
  - 역할계약 3필드(errorType/msg/isShow)·어휘(timeout/parse/unknown)·isShow:true는 **모두 충족**
  - grader 두 근거: ① camelCase 철자 불일치 ② 계약위험 무표기 (사각 신고·grader 재량·비치명)

## ROC (4렌즈 적대 검증 완료 — `wf_81708130`·326k·만장일치)
- **회귀 아님 = 최초·단발**. 직접 추적 codex 런: camelCase는 **16차 1회**(직전 전부 snake·plain 런들조차 snake). **16차 ≠ 12차**(12차 `20260620-2323` = `implements Exception`·message/statusCode 2필드 = 역할계약 오류 ❌; 16차 = 3필드 역할계약 정확·form+키만 일탈 🟡). 원장 1:1 깨짐 주의.
- **지배 뿌리 = 엔진 자유변수**. 15→16차 코퍼스 **byte 불변**(fix018/020만·error-envelope 무관·양판 IDENTICAL)인데 @freezed-snake(13/14/15)→plain-camel(16) 뒤집힘. 직접 코드 N=16 = Q-7(N=2)보다 강함. **결정론적 코퍼스 뿌리 부재 증명** → 생성측 강제 처방은 표적이 없음.
- **분기점 해소 = 서버 봉투 부재**. openapi `error_type`/`is_show` **0건**·`/api/v1/weather/`(200)·`/{date}/`(200+404)·404 바디 스키마 없음(DRF `{detail}`). camel·snake **둘 다 기능 무해**(fromJson이 이 서버 바디 성공 파싱 불가·`safeApiCall` on Object 폴백). codex design-spec:155 "client-side normalized failure model **not a frozen OpenAPI schema**"·:32 404 계약위험 표기(DT-8 ✅).
- **핵심 모순(3중)** = RUBRIC:78 "철자 일탈=FAIL"·"JSON error_type" ↔ architecture-data **§2:42 "필드 철자(error_type/msg/is_show)는 HaffHaff 봉투 예시·대상 서버 봉투에 맞춰 fromJson 조정"** ↔ EVAL-METHOD:144 "DT-3=어휘·isShow만(철자 미포함)". 서버 봉투 미규정 시 일탈 기준 철자 자체가 없음 → 루브릭이 이식된 HaffHaff 예시로 채점. **snake 강제 = §2 정면 모순 + 과적합 → 절대 금지.**
- **길목 분리(VW-4 패턴)** = @freezed+@JsonKey 골든이 implementation-dart §7에만·RUBRIC 인용 길목 §2엔 사용처(camelCase Dart 식별자 *시범*)만·architect design-spec:155 form 과소명세·MD1 백스톱 scope(entity/VO/루트/State)가 common/network 에러봉투 제외(`check_models.dart:59`)·grader 전원 plain-vs-freezed 미적발(camel만 적발).
- **적대 교정 3건**: ⓐ 수치 정정(@freezed 12·plain 4·snake 14·N=16 with-file·"13/17·16/17·17"은 loose) ⓑ "정면 모순" 과장 → "철자 축 채점 기준 미정의"(PASS "error_type **등**"=예시 어감) ⓒ **②(계약위험 무표기)는 서버-불변** → reconcile이 무마 금지(렌즈 D) → **DT-8 귀속으로 해소**(DT-8 FAIL "가정 무표기" 기소유·codex DT-8 PASS).

## 처방 ① — RUBRIC.md:78 철자/케이싱 carve-out (단일출처)
- **근거**: `data §2` → `data §2·impl §7` (@JsonKey 매핑은 §7 거주).
- **PASS** `(JSON error_type 등)` → "**JSON 키는 서버 에러봉투 명세 시 그 철자로 `@JsonKey` 매핑·미규정 시 클라 철자/케이싱 무관 — §2 '봉투는 예시·서버 맞춤'**". (역할계약 3필드·어휘·isShow:true·fromJson isShow 보존 유지)
- **FAIL** `필드·철자·어휘 일탈, 클라 생성 무음` → "**필드(역할계약 3필드)·어휘 일탈, 서버 봉투가 명세됐는데 그 철자와 불일치(봉투 미규정 시 케이싱은 DT-3 비대상 — 가정 봉투 계약위험 표기는 DT-8 소관), 클라 생성 무음(isShow:false)**".
- **효과**: ① §2·EVAL-METHOD:144와 화해 ② 봉투 미규정 서버(weather형)에서 케이싱만으로 🟡/❌ 차단(엔진 자유변수 표본을 결함으로 오짚지 않음) ③ 서버-불변 결함(역할계약·어휘·isShow)은 잔류(과소채점 차단) ④ ②는 DT-8로 귀속(이중감점·무마 동시 차단).

## 처방 ② — 보류
- **corpus-freezed (form @freezed)**: 보류. 엔진 자유변수라 명세로 결정론화 불가(Q-7형 화석)·§7:95가 `exception.dart`류 plain 면제→"@freezed 강제"=코퍼스 자기모순·grader 미적발·ceremonial·측정빈곤·§7 이중거주(렌즈 D DROP).
- **camelCase 단독**: reconcile에 흡수(16차 🟡 케이싱 축을 false-flag 재분류).

## 예상효과 (17차 측정 목표)
- 17차에서 codex가 (a) 봉투 미규정 서버에 camel/snake 어느 쪽이든 + 역할계약 3필드·어휘·isShow 충족 → **DT-3 PASS**(케이싱만으로 🟡 안 뜸). (b) 만약 명세된 서버 봉투와 철자 불일치면 그땐 정당 감점. (c) 가정 무표기는 DT-8에서 평가.
- **측정 정직**: form/key는 엔진 비결정이라 17차 비재발 가능 → 처방 "효과"는 라이브런으로 직접 검증 어려움(Q-7 부분 상속). **검증 핵심 = 채점 기준 정합**(다음 런에서 봉투 미규정인데 케이싱만으로 DT-3 감점이 *안* 나오는지 = 채점 정의 작동).

## 무모순·무과적합·회귀안전
- **무코퍼스변경**: RUBRIC = eval 단일출처 → 양판 미러·다음 런 동결 **불요**.
- **무모순**: snake/freezed 강제 회피 → §2·§7 충돌 0. DT-8(가정 무표기)·EVAL-METHOD:144(어휘·isShow)·SD-9/HR-6(각자 철자) 모두 정합. 서버-불변/서버-종속 차원 분리.
- **무과적합**: 특정값(error_type/weather/DRF) 미고정 → "서버 봉투 명세 시 그 철자 대조"로 일반화.
- **회귀안전**: 채점 기준 read-only·레이아웃/에셋/fix020 무관·생성측 무변경.

## 재발 트리거
- 계약위험 무표기 **N=2** 반복 → DT-8/§2 길목 강화(design-architect 명세·reviewer 감사).
- form plain이 **명세된 서버 봉투와 무관하게 파싱 누수** → corpus-freezed 재개(design-architect:45 열거 + coder 로드까지·feedback-018/021 교훈).
- camel 단독 재발 → 무처방(엔진 표본).

## 시술 후 적대 리뷰 (2렌즈 병렬·ROC 4렌즈에 더해)
- **렌즈2(재분류·무마·과적합) = PASS**: 16차 codex DT-3 **PASS**로 올바른 재분류(서버 봉투 미규정 — openapi Error 스키마 `{detail}`만·errorType/is_show 0건 → 케이싱 비대상·역할계약 충족)·12차 codex DT-3 **FAIL 유지**(2필드=역할계약 누락·carve-out이 면제 안 함)·가상 진짜결함 4종(명세된 봉투 철자 불일치·어휘 누락·isShow:false 무음·계약위험 무표기[DT-8]) **전부 포착**·과적합 무혐의(특정값 0·임의 봉투 일반 작동).
- **렌즈1(정합·모순·이중감점) = CONCERN(BLOCKER 0)**: §2·§7 인용 정확·EVAL-METHOD:144 수렴(기존 잠복 3자 모순 치유)·DT-8 귀속 깔끔 분리(undecidable §12 소유 확인)·SD-9/HR-6 무충돌·무마 0. **CONCERN 2건 채택**:
  - ⓐ operationalize: PASS에 "서버 에러봉투 명세 시[= `server-contract.json` 동결본 error 응답 스키마에 실재]" 1구 추가 — grader가 봉투 명세 여부를 DT-8과 동일 메커니즘으로 일관 판정.
  - ⓑ 직교 노트: RUBRIC:86에 "**DT-3 vs DT-8 직교**(봉투 명세 여부로 갈림·이중감점 금지)" 1행 추가 — 기존 DT-1/ST-2·DT-4/SD-4 직교 노트와 형식 대칭.
- **최종 시술 = RUBRIC.md 2곳**(:78 DT-3 행·:86 직교 노트)·eval 단일출처·**코퍼스 무변경·미러/동결 불요**·테이블 무결성 유지·git = RUBRIC.md + 본 원장만.

## 우선순위
DT-3 🟡 = 비치명·부수 사각. 16차 실제 치명 = FC-1(cloudy/overcast 한글 라벨 역전) — 다음 처방.
