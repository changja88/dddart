# implementation-riverpod 합성 전 리뷰 — 조사 신뢰도 검증 기록

> Wave 4 외부 조사형. external.md(2026-06-12 조사)의 신뢰도 검증과 합성 결정 기록.

## A. 조사 신뢰도

- **출처 품질**: 전 항목 공식 1차 출처(pub.dev API 문서·riverpod.dev·GitHub changelog **원문 curl 대조**) — 기억 서술 0. 요약 출처 간 모순 1건(Notifier 재생성 여부)을 changelog 원문으로 해소(dev.12 변경→dev.16 revert — 인스턴스 보존이 정식 동작)한 것이 신뢰도의 증거.
- **버전 판정**: 3.0 정식 출시 확정(2025-09-10)·현행 코어 3.3.x·annotation/generator는 4.x 짝. HaffHaff dev.17과 정식의 표기 차이 사실상 없음(파괴 변경은 dev.12·16 선행) — 기존 표기 자산 유효.

## B. 충돌 처리 (3건 전부 처리 완료)

1. **valueOrNull 제거(컴파일 불가)** → state final §4 예제를 `next.value?.error`로 즉시 교정(2026-06-12).
2. **자동 재시도 기본 ON(행동 변화)** → **dddart 결정: 전역 OFF**(2026-06-12 사용자 확정) — final §8 + state §4 채널 ① 단서 + main.dart 골격(§10-4)에 ProviderScope retry 1줄. 조사 미확정 1번(재시도 중 error 빌더 동작)은 이 결정으로 소멸.
3. **mounted 가드 부재(런타임 위험)** → state final §4 예제에 `if (!ref.mounted) return;` 보강 + final §4에 "lint가 못 잡는다 — 정식 예제 반복으로 강제" 명문화.

## C. 합성 결정

- **화이트리스트를 클래스형 3종으로 좁힘**: 공식 6변종 중 함수형 3종은 dddart 위치 어휘(VM·SharedState·Service·root 2변종 — 전부 변경 메서드 보유)에 대응하는 자리가 없어 비채택. 파생 값은 State 필드·freezed getter로(architecture-state §3 정합).
- **requireValue 전제의 규율화**: "액션은 build가 데이터를 만든 뒤에만"(View가 data 상태 UI에서만 액션 노출) — 조사 권고를 §5에 명문화.
- **실험 기능(Mutations·Offline) 비채택**: 공식 경고("may change in a breaking way") 인용 — dddart의 같은 자리는 확정 설계(State error 필드·hive)가 있다. §9.
- **updateShouldNotify ==(g)·pause(h)는 사실 기록**: consumeError의 null 경유가 == 함정을 자연 회피함을 §5에 — 명시 소비 규칙의 추가 근거.
- lint 연동 표(§10): 규약-기계 집행 겹침 5종 — §10-4에서 analysis_options 골격에 반영할 원료.

## D. 잔여 미확정 (P1 표 반영)

- riverpod_lint 3.1.x(analyzer 플러그인 방식)의 최소 Dart SDK — 도입 시 1회 확인.
- annotation 3.x 말미 버전·generator no-const의 영향 전수 — 실익 낮아 보류.
