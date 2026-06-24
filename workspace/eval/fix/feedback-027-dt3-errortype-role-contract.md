# feedback-027 — DT-3 errorType 역할계약 길목 강제 (architect 명세 열거 + reviewer 감사)

> 사전등록형 원장(eval-fix-ledger). 예상효과 먼저·다음 런(18차) 실측 대조.
> **상태**: 시술 완료 · 18차 검증 대기. **scope**: 코퍼스(design-architect·discipline-reviewer 양판 4파일)·**eval 무변경·final.md 무변경**·다음 런 동결.

## 회차/증상
- **17차**(`20260624-0122`) codex DT-3 **🟡 비치명**. `bad_request_response.dart`:
  - `@freezed BadRequestResponse({required String msg, required bool isShow, int? statusCode})`
  - **errorType 필드 부재**(statusCode 대체)·`fromUnknown`이 FormatException/timeout/Object를 단일 출구로 뭉갬(어휘 timeout/parse/unknown 전무·기인 분류 소멸)
  - claude 17차는 errorType 보유(골든 §7:134 등가·PASS)

## ROC (1단계 — 5렌즈 적대 검증 `wf_a61ad6c5`·466k)
- **회귀 아님**. fix023(`4883869`)은 RUBRIC 4줄(케이싱 carve-out)만·코퍼스 0접촉. 17차는 케이싱 문제 없음(@freezed 정상 키)·결함은 **errorType 필드 탈락**(다른 축). 12차(plain·2필드·❌)와는 *errorType+어휘 축만 겹침·전체 형태 상이*(N=2지만 form/심각도 다름).
- **지배 뿌리 = 엔진 자유변수**(field-set 출렁: 12❌·13~16 errorType 보유·17 부재·form plain↔freezed). 동일회차 양엔진 byte-동일 코퍼스서 claude 보유/codex 탈락.
- **길목 무강제(feedback-018/021 동형)**: 지식 실재(architecture-data §2:41-42 역할계약 errorType+msg+isShow·어휘 timeout/parse/unknown / implementation-dart §7:134 골든 @freezed BadRequestResponse with errorType)이나, **architect spec 미열거**(design-architect:40 "Either 계약·실패 정규화"만·:44 @freezed 명시는 entity/VO/루트/State뿐 에러봉투 제외) + **coder가 architecture-data 미로드**(spec이 SoT·코덱스 design-spec:141 "generic normalized error"가 골든을 덮음) + **reviewer 무감사** + 백스톱 MD1 common/network 제외.
- **errorType=범용 역할계약(비-과적합 검증)**: §2:42가 "기인 errorType+msg+isShow"를 역할계약으로·"철자(error_type)만 HaffHaff 예시"로 명시. statusCode는 전송계층이라 기인(timeout/parse/unknown) 구분 불가·codex 자신의 design-spec:142가 어휘 요구했으나 모델 구분불가=자기모순. claude는 동일 봉투부재서 errorType 유지=codex 단독일탈.
- **DT-8 무흠**(codex가 봉투부재를 design-spec:39 계약위험 표기) → DT-3 순수 단독 결함(이중감점 아님).

## 처방 — 코퍼스 길목 강제 (eval 무변경·RUBRIC:78이 이미 errorType 요구)

### 편집 ① design-architect data절 (claude `agents/design-architect.md` ∥ codex `SKILL.md`·트윈 IDENTICAL)
"Either 계약(Right=성공·실패 정규화 — **정규화 에러 모델 `BadRequestResponse`의 역할계약을 명세에 열거한다**: 역할계약 3필드 기인 `errorType`+`msg`+`isShow`(§7 골든대로 @freezed), **클라 생성 실패는 `errorType`으로 기인[timeout·parse·unknown 등]을 구분·`isShow:true`**[server-invariant], 서버 에러 바디 경로는 그 봉투 스키마로 `fromJson`·필드 맞춤[봉투 미규정 시 클라 철자 자유] — architecture-data §2 carve-out·implementation-dart §7. "generic normalized error"로 뭉뚱그리면 coder가 기인 필드를 흘린다)"

### 편집 ② discipline-reviewer §6 신규 bullet (VW-4·FC-1 감사와 평행·트윈 IDENTICAL)
"**에러 정규화 역할계약 (DT-3·백스톱 MD1 사각)**: 정규화 에러 모델이 역할계약의 *기인*을 잃으면 important — 3필드(`errorType`+`msg`+`isShow`·§7 골든대로 @freezed)에서 `errorType` 떨구고 전송계층 값(`statusCode` 등)으로 대체하거나, 클라 생성 실패 분류를 `errorType` 분류축 없이 단일 값으로 뭉개(예: `fromUnknown`이 분기 없이 errorType 미설정)... **면제**: 서버 바디 분기 스키마 맞춤(철자 적응·§2 carve-out·단 클라생성 errorType은 server-invariant라 면제 아님)·철자/케이싱(DT-3 무관)·계약위험 무표기(DT-8 소관)·safeApiCall 단일출구는 DT-2·에러 소비는 ST-2 별 축(이중감점 금지)."

### 강제력 3겹
① golden §7:134(coder 로드 implementation-dart·이미 존재) ② **architect spec 열거(신규·coder SoT 교정)** ③ **reviewer 감사(신규·백스톱 사각)**.

## 무모순·무과적합·회귀안전 (2·3단계 검증)
- **2단계 시술 전 4렌즈**(`wf_fcd0c18f`·367k·GO-WITH-FIXES·BLOCKER 0): §2:42/fix023/§7:95/DT-8/SD-9 하드 모순 0·codex 두 결함 경로 정확 포착·claude 거짓-FAIL 0·extract/§8/fix020/에셋 0교차·강제력 도달 확인. 교정 반영: DT-2 용어 회피·면제절 서버바디 한정·field-set 전경화·form 중립화·기계 앵커.
- **완전성 점검 3렌즈**(`wf_055158d0`·330k): 잔여 10스킬+eval 전수. cleancode 死-필드 긴장 = **코퍼스 5겹 해소**(死코드=실행불가·"필드만 있고 view 안읽으면 무해" carve-out·errorType은 isShow 구동·Left 패턴매칭 계약·이중감점 0). 잔여 architecture/impl 직교. **eval 전수 정합**(RUBRIC:78/:148 권위가 errorType 필드 명시·EVAL:144는 압축 라벨). ST-2 carve-out 누락 발견→면제절 추가.
- **회귀안전**: eval/final.md/레이아웃/에셋/extract/fix020 무접촉·17차 양판 PASS 거짓-FAIL 0·17차 완벽 UI 무위협.

## 예상효과 (18차 측정 목표)
- 18차 codex가 BadRequestResponse에 errorType+클라생성 timeout/parse/unknown 구분 보유하면 DT-3 PASS. architect spec이 역할계약 열거하는지(spec grep)·reviewer가 errorType 탈락 신고하는지.
- **측정 정직**: field-set 엔진 변동이라 18차 비재발 가능(효과=floor-raising 비결정·fix021/024 착지 선례). errorType 필드 grep 가능하나 자동 게이트 아님·reviewer가 의미 관문. errorType은 표시앱 미소비("형태 계약 보존" 가치·기능 버그 아님).

## 재발 트리거
- 18차에도 codex errorType 탈락 → architect spec/reviewer 문언 강화 or coder 로드 경로 재검토.
- form plain 회귀(@freezed 이탈) → corpus-freezed 재개 검토(현재는 §7:134 골든 의존).

## 시술 후 검증
- **양판 트윈 byte-IDENTICAL**(architect data절·reviewer §6 bullet diff 빈 출력).
- 변경 정확히 4파일(claude 2 + codex 2)·eval/final.md/extract 무접촉(git status grep 빈).
- 누적 비용 ROC 466k + 계획 367k + 완전성 330k = ~1.16M(12 서브에이전트·Opus·effort max).
