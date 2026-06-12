---
name: implementation-riverpod
description: riverpod 3.x 표기법 — @riverpod 클래스형 변종·keepAlive·retry(전역 OFF)·ref 규율(mounted 가드)·AsyncValue·invalidateSelf·ConsumerWidget, 금지 표면(legacy·실험 기능)과 lint 연동. VM·SharedState·Service·root 2변종의 riverpod 코드를 쓸 때 로드한다.
user-invocable: false
---

# riverpod 표기법

## 언제 쓰나

VM·SharedState·Service·root_vm·handler의 @riverpod 선언, ref.watch/read/listen 선택, AsyncValue 처리, 재조회·재시도 표기가 필요할 때 로드한다. 전문을 읽지 말고 아래 라우팅 표로 필요한 절만 부분 적재한다. 경계:

- 수명 **결정**(어느 변종이 keepAlive인가)·State 계약·에러 2채널 → `architecture-state`
- @riverpod 허용 위치 닫힌 열거 → `discipline-houserules`
- freezed·언어 표기 → `implementation-dart`

**keepAlive 경계**: `@Riverpod(keepAlive: true)` *표기법*은 이 스킬 소유, 수명 *결정*(SharedState·Service·root handler=예, VM=아니오)은 architecture-state §9 소유.

## 핵심 운영 원칙

- @riverpod는 클래스형 3종만 쓴다(동기 Notifier·FutureOr AsyncNotifier·Stream) — 함수형 3종은 dddart 위치 어휘에 자리가 없다 (§2)
- 표준 VM은 `FutureOr<State> build()` — throw는 AsyncError로 방출된다(에러 채널 ①의 메커니즘) (§2)
- 생성 이름은 `클래스명 선두 소문자+Provider` — VM·SharedState 접미는 strip 패턴에 안 걸린다. family는 build 매개변수로 (§2)
- keepAlive 표기는 `@Riverpod(keepAlive: true)` 하나 — 어느 변종에 붙일지는 architecture-state §9 (§3)
- watch는 build 안, read는 이벤트 핸들러·메서드 안(리빌드 회피용 read 금지), listen은 부수효과 전용 (§4)
- **await 뒤에는 `if (!ref.mounted) return;` 의무** — dispose 후 상호작용은 throw, 이를 잡는 lint는 없다 (§4)
- AsyncValue는 `value`(무throw — valueOrNull은 제거됨)·`requireValue`(hasValue 전제: 액션은 data 상태 UI에서만 노출) (§5)
- 액션 성공 후 재조회는 `ref.invalidateSelf()` — 기본 asReload:false는 이전 값을 유지해 화면이 깜빡이지 않는다 (§6)
- **자동 재시도는 전역 OFF**(ProviderScope retry 1줄 — dddart 확정): 확정 실패의 10회 반복을 막는다, 필요한 화면만 @Riverpod(retry:)로 (§8)
- legacy provider(`/legacy.dart` import가 위반 신호)·실험 기능(Mutations·Offline)·copyWithPrevious·hooks 금지 (§9)

## 상세 레퍼런스

| 질문 | 위치 |
|---|---|
| 버전·패키지 짝(annotation·generator는 4.x) | [`references/final.md`](references/final.md) §1 |
| 어떤 @riverpod 변종을 쓰나·이름·family | final.md §2 |
| keepAlive를 어떻게 쓰나 | final.md §3 |
| watch/read/listen 어디서·mounted 가드 | final.md §4 |
| AsyncValue 멤버·전제 조건 | final.md §5 |
| 재조회·무효화 표기 | final.md §6 |
| View 쪽 — ConsumerWidget·listenManual | final.md §7 |
| 재시도를 어떻게 끄나·켜나 | final.md §8 |
| 쓰면 안 되는 riverpod 표면 | final.md §9 |
| lint로 규약을 기계 집행 | final.md §10 |

각 절은 필요한 절만 읽는다(`## §N.` 헤더로 grep 가능 — 전체 로드 불필요).
