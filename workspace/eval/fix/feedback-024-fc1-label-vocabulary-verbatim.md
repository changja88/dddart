# feedback-024 — FC-1 도메인 표시 라벨·enum 식별자 verbatim 규율 (코퍼스)

> 사전등록형 원장(eval-fix-ledger). 예상효과 먼저·다음 런(17차) 실측 대조.
> **상태**: 시술 완료 · 17차 검증 대기. **scope**: 코퍼스(architecture-ddd §2·architecture-ui §5·design-architect 양판·discipline-reviewer 양판)·**양판 미러·다음 런 동결·별도 승인됨**. eval·골든 무수정.

## 회차/증상
- **16차**(`20260623-1331`) codex **치명 FC-1/FC-3 FAIL**. `weather_condition_ui_extension.dart`:
  - `cloudy` → "흐림"(구름많음이어야)·`overcast` → enum `mostlyCloudy`(@JsonValue('overcast')) → "대체로 흐림"(흐림이어야)
  - **"구름많음" 전역 부재(task 6라벨 중 1개 누락)·"대체로 흐림" 발명(task에 없는 라벨)**
  - claude 정답: `cloudy`→구름많음·`overcast`→흐림.
- 서버 ConditionEnum=`clear/cloudy/overcast/rain/snow/thunderstorm`·task=맑음/구름많음/흐림/비/눈/뇌우.

## ROC (4렌즈 적대 검증 — `w1102rr6m`·377k·내 가설 중대 교정)
- **★스모킹건 "scope.md 영어 왕복번역" REFUTED**: 15차(PASS)도 동일 왕복(scope.md:15)했으나 design-spec:12 "frozen API enum is authoritative" 자기교정→enum verbatim 유지→정답. 왕복은 **동반 증상**이지 인과 아님.
- **지배 뿌리 = enum 명명 결정 노드 엔진 자유변수**: codex가 `mostlyCloudy` 발명 여부를 비결정적으로 정함(2/6 발명·4/6 서버명 유지·동일 코퍼스·11✓12✗13✓14✓15✓16✗). 공유 불변식 = "대체로흐림 발명 + 구름많음 소실"(토큰 아닌 **라벨 멤버십**).
- **★라벨 거주지 양엔진 갈림**: claude=domain enum `displayName`(architecture-ddd §2 유비쿼터스 언어)·codex=`ui_extension`(§5) → §5만 고치면 displayName 경로 死문구.
- **★codex-dddart `agents/` 부재**: design-architect=claude agent·codex skill·`coder.md:5` ddd/ui 미로드 실측 → architect 명세가 생성 1차 길목(VW-4 동형).
- **코퍼스 갭(2겹)**: ① task 표시 라벨을 verbatim 권위 어휘로 강제하는 규율 부재 ② architecture-ui §5는 라벨을 "매핑 대상"으로 언급만·도출 규율 ZERO. (architecture-ddd §2:47이 "번역 중 왜곡"을 원리로 명명하나 "같은 철자"에 한정.)
- **eval·골든 무결함**: FC-GOLDEN §0이 이미 cloudy=구름많음/overcast=흐림 + 혼동주의 핀·G-8/N7 검출 작동·16차 정당 FAIL·grader 오짚음 0. 사용자 의도 = 골든이 기상학+task verbatim으로 추론·동결 → **비준만**(사용자 승인 완료).

## 처방 (코퍼스·일반 원리·weather 비종속)
1. **architecture-ddd §2:47**(유비쿼터스 언어·1차): "task가 도메인 표시 라벨을 명시 열거하면 그 정본 문자열이 권위 어휘 — 코드가 라벨을 어디 두든 verbatim 보유·타 언어 왕복 번역/발명/누락 금지(번역 중 왜곡의 한 형태)·도메인 enum 식별자는 서버 계약 enum 값을 verbatim(@JsonValue 서버값과 의미 어긋나는 재명명 금지)".
2. **architecture-ui §5:74**(정합): 라벨 *텍스트*는 도메인 유비쿼터스 언어(ddd §2)·task 정본 verbatim·enum 표시명 소유 시 인용·이 extension 신규 결정은 색·아이콘. §5↔§2 모순 제거.
3. **design-architect 도메인(ddd) 절**(claude:37 agent + codex:36 skill 양판): "도메인 enum 식별자·표시 라벨은 task 정본 라벨·서버 계약 enum 값을 verbatim 명세 — 왕복 번역·의미 재명명·발명·누락 금지(ddd §2)". coder가 skills 미로드 → 생성 1차 길목.
4. **discipline-reviewer**(claude:78 + codex:79 양판): code-only 감사 — 도메인 enum 식별자가 그 @JsonValue 서버값을 의미 재명명하면 신고(important); 표시 라벨이 task 어휘와 어긋나는 왕복 번역/발명/누락 흔적이면 신고(명세/task 대조 가능 시).

## 예상효과 (17차 측정 목표)
- codex가 17차에 `cloudy`→구름많음·`overcast`→흐림(또는 서버 enum verbatim 유지·mostlyCloudy 미발명)으로 FC-1 PASS.
- **측정 정직(boundary case·VW-4 동형)**: 검출은 골든(G-8/N7)이 이미 함. 처방 효과 = 생성 floor↑(다음 런 오답률↓) + 양판 reviewer code-only 검출(enum 재명명) + §2↔§5 정합. **엔진 N=2 변동**이라 17차 비재발 시 측정 불능 가능 — **17차 grep(cloudy↔overcast 라벨·enum 식별자)으로 정직 보고하고 엔진 변동 단서 병기.** floor 보장 주장 금지(N=3 후 재발률 실측 전).
- **DT-3/Q-7과 다른 처방 정당**: 치명·결정론적 정답(task 라벨 멤버십)·grep 검출 가능(발명/누락·enum 재명명 = 양성 신호·화석 아님)·명명된 코퍼스 갭.

## 무모순·무과적합·회귀안전
- **무과적합**: weather 라벨(맑음/구름많음) 코퍼스 하드코딩 0 — "task 열거 라벨 verbatim·서버 enum verbatim" 일반 원리만. 특정 배정은 골든(eval 단일출처). task가 라벨 미열거 시나리오엔 자연 비적용(도메인 자율 명명).
- **무모순**: §5↔§2 정합(라벨=도메인 유비쿼터스 언어·§5는 색·아이콘 신규 결정). enum 식별자 verbatim은 §3:71(@JsonValue) 정합. "번역 중 왜곡"(기존 §2:47) 확장이라 신서사 아님.
- **회귀안전**: 레이아웃/에셋/fix020/VW-4(§8)/DT-3(eval) 무관. 색·아이콘 매핑 규율(§5 기존) 불변.
- **강제력 3겹**: 지식(ddd §2 + ui §5) + architect 명세(양판) + reviewer 감사(양판) — feedback-018/021 교훈(지식만으론 死문구).

## 시술 후 적대 리뷰 (3렌즈)
- **렌즈1(소비성·정합·모순) = PASS(강)+CONCERN2**: AI 소비성 PASS(reviewer code-only enum-재명명 판정 가능·task-필요 부분 명시 분리)·§2↔§5 정합 PASS(라벨 거주지 양쪽 커버)·enum-verbatim은 casing 아닌 *의미* 표적이라 snake→camel 정당 변환 무저촉·@JsonValue/SD-9/§3:71 무충돌·조건 게이팅+면제로 정당 도메인 명명 보호.
- **렌즈2(과적합·회귀) = PASS(BLOCKER0·CONCERN0)**: 하드코딩 0 실증(weather/특정라벨/enum 0건)·일반 원리만·자유명명 면제·§5 색/아이콘 규율 불변·레이아웃/에셋/fix020/VW-4/DT-3 0교차·양판 byte-identical·3-tier 동기화.
- **렌즈3(강제력·재분류) = PASS(견고)+CONCERN2**: architect 명세=1차 차단(생성)·reviewer=2차(명세 종속)·claude domain-displayName 정답 무혐의(§2 거주지 무관 봉합)·codex design-architect SKILL이 ddd/ui 로드 실측(architect 길목 살아있음)·SKILL 본문 직접 박음(死문구 낮음)·효과 floor-raising 정직(검출 0 추가=골든 소유·N=2 측정불능 명시).
- **채택 1건(렌즈3 CONCERN B)**: reviewer 면제절에 "task 열거 밖 방어적 폴백 멤버(`unknown` 등)는 발명 아님" 1구 추가(18차류 방어 멤버 과탐 봉합·양판).
- **미채택**: 렌즈1 CONCERN1(reviewer 어휘감사↔FC-2 매핑핀 교차 가이드)=nit·reviewer 인격 이미 분별 / 렌즈3 CONCERN A(verbatim 식별자 19차 과탐)=19차 골든 개정 전이라 현 골든 기준 정당 표적 가능성↑·추가 조치 불요.

## ★ 처방 경계 (렌즈1 CONCERN2·렌즈3 효과 정직)
- **코퍼스가 잡는 것**: task 라벨 *발명*("대체로 흐림")·*누락*("구름많음" 소실)·enum 식별자 *의미 재명명*(`mostlyCloudy`@JsonValue('overcast')). → 16차 codex 결함 본체.
- **코퍼스가 못 잡는 것(사각·골든/명세 소관)**: 식별자도 정상이고 6라벨도 다 쓰되 **페어링만 의미 역전**(`cloudy`→흐림·`overcast`→구름많음 식으로 한글만 뒤바꿈)은 task 텍스트에 enum↔라벨 페어링이 없어 코퍼스 단독 미포착. **이 갈래는 FC-GOLDEN §0 1:1 핀(이미 존재)+사용자 의도 동결이 진짜 처방**(채점 검출). 코퍼스는 발명/누락/재명명만 강제하는 *보완재*다. → "FC-1 종결"로 보지 말 것.

## 재발 트리거
- 17차 codex FC-1 재발(mostlyCloudy 발명 또는 라벨 스크램블)·N=3 누적 → 강제력 부족 진단(reviewer task 입력 보강·또는 측정 게이트 강화).
- codex 자연어 구동이 design-architect skill 미engage 확인 시 → 지식 길목(ddd §2) 강조·codex 구동 순서 점검.

## 우선순위/비준
- FC-1 = 치명. 골든 매핑(cloudy=구름많음·overcast=흐림) 사용자 비준 완료(2026-06-23).
