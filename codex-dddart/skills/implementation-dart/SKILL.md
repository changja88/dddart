---
name: implementation-dart
description: Dart 언어 표기법 — Effective Dart 선별(dddart 의도적 일탈 2건 포함), 널 안전 관용구(promotion·지역 변수 복사), freezed 3.x 표기 계약, union의 switch 패턴 매칭, json_serializable, dartz Either 최소 표면. Dart 코드의 이름·형태·모델 선언을 쓸 때 로드한다.
user-invocable: false
---

# Dart 표기법

## 언제 쓰나

클래스·함수·상수의 이름과 형태를 정할 때, nullable을 다룰 때, freezed 모델·State를 선언할 때, union을 분기할 때, JSON 매핑·Either를 쓸 때 로드한다. 전문을 읽지 말고 아래 라우팅 표로 필요한 절만 부분 적재한다. 경계:

- 파일·클래스 명명의 **무엇**(어떤 이름이 와야 하나) → `discipline-houserules`
- 도메인 모델 규율(애그리거트·VO)·State 계약 → `architecture-ddd`·`architecture-state`
- Either의 계약 의미(Right=성공) → `architecture-data`
- @riverpod·go_router·retrofit·hive 표기 → `implementation-riverpod`·`implementation-flutter`

## 핵심 운영 원칙

- 상수는 lowerCamelCase(SCREAMING_CAPS 금지), 3자+ 약어는 단어처럼(Http·Sms), import는 dart:→package:→상대 순 (§2)
- **의도적 일탈 2건**: Repo·UseCase 조회 메서드의 get 접두는 dddart 방언으로 유지 / 광범위 catch는 safeApiCall 한 곳만 — 일반 코드는 에러 4규칙(on 절 의무·Error 캐치 금지·rethrow) (§2)
- bool 인자는 named로, 공개 API는 타입 명시, 초기화된 지역 변수는 추론 (§2)
- freezed 프로퍼티는 public getter라 promotion 불가 — **지역 변수 복사가 표준 관용구**, `!` 연쇄는 열화 형태 (§3)
- freezed 3: 단일 생성자 모델은 `abstract`, union은 `sealed` 키워드 의무 — 커스텀 getter·메서드엔 `const X._()` 필수 (§4)
- freezed 컬렉션은 unmodifiable — 갱신은 `copyWith(lines: [...lines, item])` 리터럴 합성으로 (§4·§6)
- `copyWith(field: null)`은 실제 null 대입(공식 지원 — consumeError의 근거) (§4)
- union 분기는 when/map(3.0 제거)이 아니라 **switch 패턴 매칭** — sealed라 `_` 없이 소진성 컴파일 검사 (§5)
- SDK ^3.9 = 3.0~3.8 문법까지 — 3.10 dot shorthands·3.12 private named params는 컴파일 불가 (§1)
- Either는 dartz·표면 고정(Left/Right·fold·map·flatMap) — **분해는 fold로 통일**(sealed가 아니라 switch 소진성 없음) (§8)

## 상세 레퍼런스

| 질문 | 위치 |
|---|---|
| SDK 버전이 허용하는 문법 범위 | [`references/final.md`](references/final.md) §1 |
| 케이싱·import 배치·문서 주석·API 형태·에러 처리 | final.md §2 |
| nullable을 어떻게 다루나 — promotion 관용구 | final.md §3 |
| freezed 모델 선언 표기 | final.md §4 |
| union을 어떻게 분기하나 | final.md §5 |
| 레코드·패턴·class modifier·컬렉션 합성 | final.md §6 |
| @JsonKey·JSON 매핑 | final.md §7 |
| Either 표기·dartz 유지보수 사실 | final.md §8 |

각 절은 필요한 절만 읽는다(`## §N.` 헤더로 grep 가능 — 전체 로드 불필요).
