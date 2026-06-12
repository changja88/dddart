# discipline-cleancode 합성 전 리뷰 — 치환 기록

> Wave 3 이식형(직격). external.md = dddjango final 소스판 — 보편 규율이라 산문 보존, **Python 예제 80펜스 전량 Dart 치환**(2026-06-12, 6-agent 병렬 분담 A~F + 메인 루프 통합·검수). 이 리뷰는 치환 결정의 기록이다.

## A. 치환 총괄

- 80/80 펜스 치환(python 잔존 0 — grep 검증). 산문·절 번호·표·출처 태그([CC][APoSD][IP][OO][PC][WELC]) 보존.
- 절 구조: 원본 §1~§17 승계 + **원본 §18(Python 관용구) 비승계**(implementation-dart가 대체) + **신설 §18(반복>상속 — 규약 §10-5 ①)**.
- 관례 기준: Effective Dart — SCREAMING_CAPS→lowerCamelCase const, get_/set_ 메서드→getter/setter, 약어 케이싱(CSV→Csv·GUI→Gui·SMS→Sms·HTML→Html), docstring→`///`, snake_case→lowerCamelCase.

## B. 언어 차이로 구조가 바뀐 치환 (의미 보존 확인 완료)

| 위치 | Python | Dart 치환 | 비고 |
|---|---|---|---|
| §3.9 | `__init__`에서 핸들러 dict 구성 | `late final` 필드 + 인스턴스 메서드 tear-off | Dart는 필드 초기화식에서 this 참조 불가 |
| §9.2 OCP | `Event.__subclasses__()` 런타임 리플렉션 | (정적 판별 함수, 생성자 tear-off) 레코드 등록 목록 + 구조분해 루프 | Flutter에 리플렉션 없음 — "본문 무수정·등록만 추가" 교훈은 주석으로 보존 |
| §9.3 LSP | 서명 불일치 오버라이드(dict→list) | `dynamic` 파라미터 + 다운캐스트 | Dart 분석기가 invalid_override를 거부 — "컴파일은 통과하나 치환성이 깨지는" 동일 위반을 합법 Dart로 |
| §12.2 | 오류 코드 상수 E_OK | `enum ErrorCode` | Dart 관용형 |
| §12.7b | 예외 튜플 단일 except | `on` 절 2개 분리 | Dart는 on 다중 타입 불가 |
| §13.1 | 연쇄 비교 `0 < age < 150` | `0 < age && age < 150` vs `age > 0 && …` 대조 재현 | |
| §14.4 | `collections.UserList` 상속 | `dart:collection` `ListBase` 상속 | 등가 안티패턴 |
| §14.6·§7.2·§16.2 | `typing.Protocol`(구조적) | `abstract interface class`/`abstract class` + `implements`(명목적) | 구조적 타이핑 부재 — 계약 vs 골격은 implements/extends로 구분 |
| §15.1 | `Decimal` | `double` + 정밀도 주석 | Dart 코어에 Decimal 없음 |
| §8.3·§9.2·§10.5 | 암묵 None 폴스루 | 말미 `throw ArgumentError`/return 보완 | definite return 요구 — 원본 의도 주석 보존 |
| §17.7 | truthiness `if x:` | `if (x != null)` | "0도 거짓" 뉘앙스 소실 — 핵심 결함(암호 이름·매직 넘버) 보존 |

## C. dddart 결정 반영 (산문 수정 3곳 + 신설 1절 — 치환 밖 유일한 손질)

1. **§16 머리 dddart 단서**: 테스트 없음 결정 — 안전망은 analyze green 래칫·백스톱·G2 행위 대조. Sprout/Wrap은 테스트 없이도 유효("기존 코드 수정 불요구"와 한 방향).
2. **§16.5 특성화 테스트**: "dddart 비적용(테스트 없음 결정·원전 보존)" 제목 표시 — 워크플로 F가 플래그한 테스트 전제 7곳 중 코드 예제 절. WELC 정의("레거시=테스트 없는 코드")는 원전 인용으로 유지.
3. **§17.1**: "단위 테스트는 통과한다" → dddart 번역(analyze green 래칫) 병기.
4. **§18 신설**: 반복>상속 — base VM·공용 헬퍼 금지의 일반화, §13 DRY와의 경계("지식의 중복"은 도메인으로 모으고 "표기의 반복"은 모으지 않는다).
5. 교정 2건: batch-D의 작업장 경로 발명 → "implementation-dart 스킬" 위임으로(경로 형태 금지), §4.7 제목 독스트링→문서 주석.

## C-2. 4렌즈 1라운드 교정 기록 (2026-06-12 사후)

1. **체크리스트 복원**(fidelity P2): 원본 말미 "핵심 요약 체크리스트" 31행이 batch 분담 경계(§17까지) 탓에 미기록 누락 → 언어 중립이라 그대로 복원(+dddart 단서 2곳 병기: DIP 행·레거시 행), TOC 등재.
2. **비채택 충돌 단서 2곳**(plugin-dev P2): §9.5 DIP·§14.6 Repo 인터페이스에 §16 동형의 "dddart 단서" blockquote 추가 — 직격 이식이 자매 스킬 확정 결정(직접 생성·구체 Repo)과 충돌하는 지점의 교정 장치.
3. **침묵 폴백 경계**(소비성 P2): §12.7 견고성 폴백 예제 뒤에 "의도가 명시된 설계 결정 vs 침묵 폴백" 구분 + Either 운반 원칙(architecture-data §3) 1문단.
4. **§15 definite-return 보완**(fidelity P3): §15.1 calculatePrice·§15.3 getInsuranceRate 나쁜 예 말미 throw 추가(B10과 일관).
5. **출처줄 서지 정정**(fidelity P3): [OO]=객체지향의 사실과 오해(조영호)·[PC]=파이썬 클린코드 2nd(아나야)로 교정, [CodeC]·[PP]·[Ref] 추가 — 원본 머리 범례 기준.
6. **잔여 산문 변경 전수 기재**(fidelity P3 — B표 보완): ① 독스트링→문서 주석 용어가 §4.7 제목 외 §4 통합 원칙·§4.3 표·§4.6·§4.7 본문(PEP 257→Effective Dart)에도 적용 ② §5.2 Ruff→dart format·analysis_options.yaml ③ §9.1 소절 제목·표 5행 Django→Flutter 등가(Fat View/Router→Fat Widget/Controller 등) ④ §16.2 표 'monkeypatch→함수 주입 교체'. 전부 언어 이식 기인·의미 보존.
7. SKILL.md 교정: description 화살괄호 제거(P1 — "상속보다 반복"으로 환언), §13·§15 원칙 문구를 본문 실문면에 정합("발음 가능" 제거·"성급한 추상화" 문구를 §13 실태로 교체·안전망 인용을 §16으로), 라우팅 §5 행 추가, 소절 grep 어포던스 고지.

## D. 경계

- vs **ddd**: 빈혈·판정 소유는 ddd §5·§9 소유 — cleancode §6(캡슐화)·§8(객체 설계)은 일반론, 도메인 어휘 판정의 귀속은 ddd 위임.
- vs **implementation-dart(전방)**: Dart 관용구·표기법 상세(원본 §18의 자리) 위임.
- vs **state**: §11(상태 관리) 일반론은 보존 — riverpod 상태는 architecture-state 소유(§11에서 위임 불요 — 원본이 언어 중립 서술).
