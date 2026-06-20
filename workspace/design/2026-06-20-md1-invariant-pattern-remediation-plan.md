# 설계 v2 — MD1×불변식 봉인 패턴 처방 (적대 리뷰 6/6 partial 반영)

> **트리거**: 10차 양판 백스톱 폭발(claude 11·codex 14·1h→2h). ultracode RCA(`wf_298fba27`) + 적대 리뷰(`wf_e67d0daf`·6관점). 원장 = `feedback-013`.
> **결정 원칙(feedback-010/012 계승)**: 산문 3회 무효·기계 floor만 엔진불변 홀드. **v2의 핵심 = 무게중심을 코퍼스 예제/산문(R1·R3·R4)에서 기계 floor(R5 명세 린터·R6 MD1 메시지)로 이동.**

## v1→v2 적대 리뷰 교정 (6/6 partial)

**RCA 교정 (스모킹건 결함 — Q1·Q2·Q5가 코드로 반증)**:
- v1의 "8차 codex가 루트를 @freezed private-ctor로 봉인해 통과" = **부정확**. 8차 codex는 **컬렉션 루트를 안 만들었다**(`Forecast`=단일일 평탄·List 0개·`f54df9a`). 정렬은 `ForecastChronologyService`(**도메인 서비스**, `final class`=MD1 면제)가 소유. design-spec L57이 정렬 소유를 명세 단계에 박음.
- 진짜 변별자 = "예제 유무"가 아니라 **"애그리거트 루트가 컬렉션 정렬을 소유하느냐"의 spec 결정**(8차=도메인서비스 / 9·10차=루트 격상).
- **잔여는 "도망"이 아니라 "지연"**: MD1(러너)은 이미 plain을 잡고 전환을 강제한다 — 10차 codex `1888d83`이 막판에 *스스로* `@freezed`+named factory로 전환(R1 패턴과 동일). 문제는 전환이 **막판 백스톱 시점 = 대수술(2h)**. → 처방 목표 = "전환을 막판→명세단계로 당김" + "막판 방황→기계 붙여넣기".

**엔진 진짜 장벽 (Q1)**: 9차 claude 주석 — "freezed 3.x는 private-named 값 생성자를 map/when 헬퍼 충돌로 표현 못 한다 → plain". v1 R1은 추론 1단계("정렬=비정렬 생성 불가")만 반박하고 이 2단계(map/when 충돌)·"fromJson은 codegen이라 봉인 무의미"를 침묵.

**무게중심 이동 (Q2·Q3·Q5)**: §3·§4 @freezed 예제는 9·10차 당시 *이미 존재*(`const Money._()`·`const Order._()`)했는데도 도망 — "예제 존재해도 안 따름" 트랙레코드. R1·R3·R4 같은 코퍼스 보강은 feedback-010 무효 산문과 같은 위험. 진짜 처방은 **R5·R6 기계 floor**.

## 코퍼스 현황 (교정)

**있는 것**: architecture-ddd §3(`Money`)·§4(`Order`)·implementation-dart §4에 `@freezed`+`const X._();`+factory 패턴 예제 + §4 3규칙-2("생성 검증 비강제") + MD1 로직(`@[Ff]reezed` 정규식만 검사·entity/VO/루트/state 한정·enum·exception 제외).
**없는 것(갭)**: ① 컬렉션 정렬/정규화 named factory 예제(grep 0건) ② "타입봉인 시도 무의미·plain=MD1위반·봉인은 어차피 fromJson로 깨짐" 가드 ③ 명세가 모델타입(@freezed)·router 인자(String) 명시하도록 하는 강제 ④ **명세 단계에서 NM/MD/IM을 검사하는 러너 바닥**(check_*.dart는 생성코드 lib/*.dart만 검사·명세 .md 비대상) ⑤ MD1 적발 시 named factory 패턴을 손에 쥐여주는 메시지.

## RCA→처방 매핑 (3축·교정)

| RCA 축 | 잔여 성격 | 처방 |
|---|---|---|
| 규칙축(MD1) | MD1은 정상(전환 강제). 잔여=막판 적발 지연 | **R6** MD1 메시지에 named factory 템플릿(막판 방황→기계 붙여넣기) |
| 설계축(명세) | 명세가 모델타입·router 인자·파일명을 백스톱 deny와 어긋나게 지시/침묵. **러너 바닥 없음**(최대 잔여 NM 클러스터) | **R5** 명세 단계 dry-run 린터(핵심) + **R2** 명세 필수필드 |
| 엔진축(plain·VO 도망) | R1+MD1로 흡수(어트랙터)·단독 치명 아님 | **R1** 예제+가드(보조) |
| (부수) carrier·converter | router→domain·formatter 동거 | **R3** router=String(R2 결박)·**R4** 별파일(확장) |

---

# 핵심 — 기계 floor (R5·R6·신규)

## R5 (1순위) — 명세 단계 dry-run 린터

**문제**: 10차 claude NM 클러스터(NM2×2+NM4×2+NM12×1=과반)는 **설계축**이다 — architect 명세가 `_view_state.dart`·plain 루트를 지시하고 L406에서 "명명 일치 ✔" **자기인증**. 기존 자기모순 스캔(design-architect L62)은 절-간 내부일관성만 보고 백스톱 deny 정합을 안 봐서 위반본이 통과. R2(산문 체크리스트)는 architect가 LLM이라 같은 운명(자기인증 실패 실증).
**처방**: design-spec의 **파일 목록 절을 코드 작성 전(G1)에 기계 검사**하는 린터 — 선언된 각 파일경로·모델타입을 `check_naming`(NM2/4/5/12)·`check_models`(MD1)·`check_imports`(IM21/22) 로직으로 dry-run. 위반(`_view_state.dart`·plain 모델·router VO 인자·NM5 섹션접두·NM12 부품군) 적발 시 **G1 fail**(코드 생성 전 차단).
**선결**: architect가 파일 목록을 **기계 파싱 가능 형식**으로 산출(파일경로 + 모델타입 + 명명) — R2와 연동(명세 필수 필드 정형화).
**효과**: 막판 대수술(2h)을 **명세 단계 차단**으로 당김 = "빠른 1회 green" 직격. R2 산문에 러너 바닥 제공.
**위치**: 도구 = `dddart/scripts/`(백스톱 옆·양판) 또는 `workspace/eval/tools/` · 호출 = Coordinator G1 게이트(`dddart.md`·codex SKILL).
**비용**: 신규 도구(명세 정형화 의존) — 시술 비용 큼. feedback-012 R3(codegen 게이트)·IM23이 "산문→기계 승격"의 선례.

## R6 (cheap·즉효) — MD1 메시지에 named factory 템플릿

**문제**: 잔여=지연(10차 codex가 자력 전환 가능 실증). 막판 전환 "방황"이 2h 회귀 주원인. 현 MD1 메시지(`check_models.dart:75`)엔 정렬·named factory·컬렉션 언급 0.
**처방**: `check_models.dart:75` MD1 remediation 분기 보강 — 적발 모델이 **컬렉션 필드(List/Set/Map 생성자 파라미터)를 가진 애그리거트 루트**(`_isAggregateRoot`)이면 named factory 템플릿 인라인:
> `const X._(); const factory X({required List<E> items}) = _X; factory X.fromItems(List<E> raw) => X(items: <E>[...raw]..sort(...));` — 정렬·중복거부는 named factory가 정규화(@freezed 유지·plain 금지·§4 3규칙-2).

**효과**: 백스톱이 plain 루트를 잡는 *그 순간* 정확한 패턴 제시 → 막판 토끼굴(방황)을 막판 기계 붙여넣기로. 10차 codex 자력 전환 실증이 근거. 양판(cp diff 0).
**positive-control**: @freezed+named factory(`.fromX`·`.fromJson` 아님) 루트=PASS / plain 루트=FAIL / 컬렉션 없는 단순 루트는 템플릿 미제시.

---

# 보조 — 코퍼스 보강 (R1·R2·R3·R4)

## R1 (보조) — 컬렉션 named factory 예제 + 정밀 가드
**대상**: architecture-ddd §4 + implementation-dart §4 · 양판
**처방**: §4에 컬렉션 불변식 항목 + `WeeklyForecast.fromDays` 예제. 가드 — (Q1 반영) "정렬·중복제거를 *타입수준 봉인*(공개 생성 경로 제거)으로 강제하지 않는다 — fromJson은 codegen이라 어차피 봉인이 깨지고, 봉인 시도는 freezed 3.x map/when 헬퍼가 private-named 생성자와 충돌해 컴파일 불가. 공개 unnamed factory를 열고 named factory(`fromX`)가 정규화한다(3규칙-2)." (Q6 반영) "**entity·VO·애그리거트 루트·State**를 plain으로 쓰면 MD1 위반(enum·exception.dart·common util은 비대상 — `_isExcludedShape` 정합)."

## R2 (보조→R5로 기계 승격) — 명세 필수 필드 + 백스톱 정합
**대상**: design-architect.md(claude)·dddart-design-architect(codex) · houserules §4 보강
**처방**: ① 모델(entity/VO/루트/State)을 명세 파일목록에 **@freezed 명시**(coder 재량 금지·R5 입력 정형화) ② 자기모순 스캔을 **백스톱 정합 스캔으로 교체**(추가 아님)·L406식 "일치 ✔" 자기인증 문구 금지(deny 대조 없는 선언 무효) ③ 삼총사 `_view` 끼움 금지(houserules §4에 금지형 `weekly_forecast_view_vm.dart` **반례** 추가·prefix=stem−`_view`) ④ **NM5**(섹션 접미사 파일명은 소속 view *전체 접두*로 시작 — view=`daily_forecast_detail`이면 섹션=`daily_forecast_detail_*`) ⑤ NM12(부품군 폴더=접미사).

## R3 (보조·R2 결박) — router/navigator = String only
**대상**: architecture-ddd §3 + architecture-ui §6 · 양판
**처방**: (Q4 반영) "router·navigator의 **공개 메서드 인자·GoRoute builder가 view에 넘기는 인자는 String** path-param(domain VO 금지 — 받으면 import=IM21/22). 호출자(VM)가 `vo.toApiPath()`로 직렬화, 수신 view가 `VO.fromApiPath(String)` 복원." 현 §3.72("문자열 전달만")는 *인자 타입이 String*임을 명시 안 해 `pushDailyForecast(ForecastDate)` 해석 여지를 남김.
**결박**: **R3∧R2 = do both or neither**(feedback-012 R1+R2 선례) — 10차 양 명세가 navigator 인자를 domain VO로 박았으므로(claude L343·codex L256), R2가 명세를 String 인자로 안 고치면 coder가 명세 따라 R3 위반. R3 단독 효력 0(증상 차단).

## R4 (보조·cheap) — 표시 변환 헬퍼 별파일 (범위 확장)
**대상**: implementation-dart §7 · 양판
**처방**: (Q5 반영) "커스텀 JsonConverter **및 표시 변환 헬퍼(display-text·formatter)** 클래스는 별 파일(NM3) 또는 top-level 함수로 — view_model 거주 다중클래스 금지." (`@JsonKey(fromJson:)` top-level 함수·VO 내부 static은 예외=8차 codex 패턴.) v1은 JsonConverter만 다뤄 10차 codex `WeatherForecastDisplayText`-NM3 미커버.

---

## 검증·측정 (적대 리뷰 보강)
- **positive-control(R6·R1)**: @freezed+named factory 루트 PASS / plain 루트 FAIL · VO+JsonConverter 동거 NM3 FAIL / VO 내부 static 컨버터(8차 codex) PASS · enum·exception plain은 MD1 미발화(과대범위 반증·Q6).
- **R5**: 명세 dry-run이 `_view_state`·plain 모델·router VO 인자를 G1서 적발하는 fixture.
- **라이브(11차)**: 막판 백스톱 11·14 → **0~2** · 소요 2h → **1h**.
- **막판수술 측정(Q4·Q5)**: "**첫 커밋(슬라이스)부터 올바름 — 막판 fix-pass(VO→String·plain→@freezed) 0회**"(최종상태 아닌 과정 측정). **NM 클러스터(NM2/4/5/12)·formatter-NM3를 MD1 클러스터와 별도 카운트** — R2/R5 산문↔기계 바닥의 실효를 분리 관찰("0~2 회복"의 낙관/근거 판별).
- N=1→≥2.

## 처방 우선순위 (재편)
1. **R6**(cheap·즉효·러너 1파일) — 막판 방황 차단. 단독으로도 2h 회귀 일부 완화.
2. **R5**(1순위 효과·비용 큼) — 명세단계 차단. R2 정형화 선결.
3. R1·R2·R3·R4(보조 코퍼스) — R5/R6의 인간가독 근거·gap 메움. R3∧R2 결박.

## 미확정
- R5 구현 비용 — 명세 파일목록 정형화 범위(architect 출력 형식 변경). 경량(파일경로+모델타입 컬럼 파싱) vs 완전(트리 파싱).
- 10차 11·14 정확 카운트 미확정(라이브 중단·커밋 비열거) — 11차 코디네이터 출력으로 확정.
- 적대 리뷰 원본 = `wf_e67d0daf`(6관점·64만 토큰).
