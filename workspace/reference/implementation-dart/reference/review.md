# implementation-dart 합성 전 리뷰 — 조사 신뢰도 검증 기록

> Wave 4 외부 조사형. external.md(2026-06-12)의 신뢰도 검증과 합성 결정 기록.

## A. 조사 신뢰도

- 전 항목 공식 출처 WebFetch 실확인 14건(dart.dev 4부·null-safety·patterns·evolution / pub.dev freezed·json_serializable·dartz API / GitHub freezed changelog·migration guide raw) — 규칙 명칭을 공식 DO/DON'T 원문으로 인용. "필드는 promotion 안 됨"이라는 과제 프롬프트의 과잉 단순화를 공식 규칙(private final은 3.2+ 가능)으로 교정한 것이 신뢰도의 증거 — 단 freezed 프로퍼티는 public getter라 결론(지역 변수 복사 관용구)은 동일.
- 기존 배포본 예제 전수 검증: freezed 3 표기(abstract·private 생성자·copyWith null·fromJson 시그니처)·dartz API(fold Left 먼저·map Right 변환) **전부 정합 — 표기 충돌 0**.

## B. 충돌 처리 (2건 — 둘 다 의도적 일탈 명문화)

1. **get 접두 메서드**(공식 AVOID vs HaffHaff 방언): 방언 우선(규약 §1 원칙 1 — 기존 코드 일관) — final §2에 일탈 명문화. 그 외 메서드는 공식대로.
2. **safeApiCall의 광범위 catch**(공식 2규칙 위반): 전 실패 정규화의 의도적 단일 경계(architecture-data §2의 *왜*) — final §2에 "한 곳 한정 예외, 일반 코드는 4규칙" 명문화.

## C. 합성 결정

- **SDK 상한 명문화**: ^3.9 = 3.0~3.8 누적(3.9 자체 신규 없음) — 3.10 dot shorthands·3.12 private named params를 "컴파일 불가" 경고로(AI coder의 최신 문법 오염 방지).
- **when/map 비사용 확정**: 3.0 제거·3.1 옵션 재추가와 무관하게 dddart는 switch 패턴 매칭 표준(공식 입장 직역). 미확정(재추가 옵션의 기본값)은 무영향.
- **레코드는 지역 한정**: 공개 계약은 freezed·Either — §6에 경계.
- **dartz 휴면 사실 기록·교체 비채택**: fpdart 대안 존재를 §8에 기록하되 기준점(HaffHaff 실사용) 변경이라 비채택. 분해는 fold 통일(dartz Either가 sealed 아님 — switch 소진성 없음).
- BadRequestResponse 예시는 실물 철자 유지(`required bool isShow` — external의 @Default(true) 예시 대신 실물 required).
- **fieldRename 일괄 옵션 비채택·명시 @JsonKey 표준**(1라운드 사후 기록 — external은 houserules 영역으로 유보했으나 합성이 확정): 서버 키가 코드에 보이는 쪽이 계약 대조(architecture-data §7)에 유리 + HaffHaff 실물이 명시 방식. 이 항목이 그 결정 기록.
- 1라운드 교정 2건: §4 freezed 키워드 의무 서술에 공식 제3 선택지(수동 implements — dddart 비사용) 병기, §5에 dartz Either의 switch 제외 역방향 가드 1줄(소비성 P3 — §8 단방향 참조 해소).
