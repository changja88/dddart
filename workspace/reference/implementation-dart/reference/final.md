# Dart 표기법 — Effective Dart·널 안전·freezed 3·패턴 매칭

## P1 Source Sufficiency

| field | value |
|---|---|
| purpose | dddart가 생성하는 Dart 코드의 언어 표기 단일 출처 — Effective Dart 선별(의도적 일탈 2건 명문화 포함), 널 안전 관용구, freezed 3.x 표기 계약, when/map의 패턴 매칭 대체, Dart 3 문법 가용분·상한, json_serializable, dartz Either 최소 표면. |
| use when | 클래스·함수·상수의 이름과 형태를 정할 때, nullable을 다룰 때, freezed 모델·State를 선언할 때, union을 분기할 때, JSON 매핑을 쓸 때, Either를 다룰 때. |
| exclude/handoff | 어느 위치에 어떤 파일·클래스가 오는가는 discipline-houserules, 도메인 모델 규율은 architecture-ddd, State 계약은 architecture-state, Either의 계약 의미(Right=성공·실패 운반)는 architecture-data, @riverpod·go_router·retrofit·hive 표기는 implementation-riverpod·implementation-flutter로 위임. |
| core criteria | Dart SDK ^3.9(=3.0~3.8 언어 기능 누적 — 3.9 자체는 신규 기능 없음)·freezed 3.2·json_serializable 6.x·dartz 0.10.1, 전 항목 공식 문서 원문 확인(2026-06-12 — 절별 URL은 작업장 external.md). 기존 배포본 예제(state·data·ddd) 전수 검증 — 표기 충돌 0, Effective Dart와의 의도적 일탈 2건만 §2에 명문화. |
| source priority | 1 공식(dart.dev·pub.dev·GitHub changelog/migration guide 원문) 2 dddart 결정(HaffHaff 방언 우선 지점·비채택) 3 HaffHaff 실물(BadRequestResponse 철자 등). |
| P1 classification | sufficient — dartz 휴면 사실과 대안(fpdart)은 §8에 기록(교체는 기준점 변경이라 비채택). freezed 3.1의 when/map 재추가 옵션의 기본값은 공식 미명시이나 dddart가 패턴 매칭 표준이라 무영향. |

> **출처:** dart.dev(Effective Dart 4부·null-safety·patterns·class-modifiers·evolution) · pub.dev(freezed 3.2 README/changelog/migration guide·json_serializable 6.14·dartz 0.10.1 API) — 2026-06-12 확인, 절별 URL은 작업장 external.md.
> 본문 속 `(규약 §N)`은 **출처 표기**이며 로드 대상이 아니다. 로드 가능한 위임은 "스킬명 + §번호(또는 주제)"뿐.

---

## 목차

- §1. 버전·전제 — SDK ^3.9의 정확한 의미·상한
- §2. Effective Dart 선별 — 명명·문서·API 형태·에러 처리 (의도적 일탈 3건)
- §3. 널 안전 실전 — required·연산자·promotion 관용구
- §4. freezed 3.x — 표준 표기 계약
- §5. union 분기 — when/map 대신 switch 패턴 매칭
- §6. Dart 3 문법 — 레코드·패턴·modifier·컬렉션 합성
- §7. json_serializable — @JsonKey·freezed 연동
- §8. dartz Either — 최소 표면·fold 통일

---

## §1. 버전·전제 — SDK ^3.9의 정확한 의미·상한

**Dart 3.9 자체는 신규 언어 기능이 없다** — `sdk: ^3.9.0`에서 가용한 문법은 3.0~3.8 누적분이다: Patterns·Records·Class modifiers·Switch 표현식(3.0), private final 필드 promotion(3.2), digit separators(3.6), wildcard `_`(3.7), null-aware element(3.8).

- **상한 주의**: 최신 Dart(3.12)의 dot shorthands(`.enumValue` 축약 — 3.10)·private named parameters(3.12)는 **^3.9 프로젝트에서 컴파일 불가** — 생성 코드에 쓰지 않는다. 언어 버전은 pubspec의 min SDK가 정한다.
- 패키지 기준: freezed 3.2·freezed_annotation 3.x / json_serializable 6.x·json_annotation 4.9 / dartz 0.10.1.

## §2. Effective Dart 선별 — 명명·문서·API 형태·에러 처리 (의도적 일탈 3건)

**명명(케이싱)** — 파일·클래스 명명의 *무엇*은 discipline-houserules §4 소유, 여기는 언어 케이싱 규칙:

| 대상 | 케이싱 |
|---|---|
| 클래스·enum·typedef·extension | `UpperCamelCase` |
| 파일·디렉터리·import prefix | `lowercase_with_underscores` |
| 변수·파라미터·멤버·최상위 선언·**상수** | `lowerCamelCase` — `SCREAMING_CAPS` 금지 |

- **약어**: 3자 이상은 단어처럼(`Http`·`Sms`·`Uri` — HTTP·SMS 아님), 영어에서 대문자인 2자 약어는 유지(`ID`·`UI` — dddart의 `VM` 접미도 이 부류로 정합). lowerCamelCase 머리에선 전소문자(`httpConnection`).
- 비공개 아닌 식별자에 선행 `_` 금지 · 헝가리안 접두 금지 · 미사용 콜백 파라미터는 `_`.
- **import 배치**: `dart:` → `package:` → 상대, 각 구획 알파벳순, export는 별도 구획.

**문서 주석**: `///`(블록 주석 금지) · 첫 문장 요약 후 빈 줄 · 스코프 내 식별자는 `[Order]` 대괄호 참조 · bool 프로퍼티는 "~인지 여부(Whether)"로 · 공개 API에 우선 작성. 주석의 *언제·왜*는 discipline-cleancode §4 소유 — 여기는 표기.

**API 형태**: 개념상 속성 접근이면 getter(무인자·멱등·부작용 없음 — `Money get totalAmount` 정합) · bool 이름은 긍정형(`isConnected`) · **bool 인자는 named로**(positional bool 금지) · **공개 API·지역 변수·클로저 파라미터 모두 타입 명시**(`final List<Channel> channels = await ...`·`(BuildContext c, int i) => ...` — 일탈3·`always_specify_types` 강제) · setter만 단독 정의 금지 · await 없이 Future를 그대로 반환하면 `async` 생략(`getChannels() => safeApiCall(...)` 화살표 위임이 이 형태).

**의도적 일탈 3건 (dddart 결정 — 공식 AVOID보다 방언·정책 우선)**:

1. **조회 메서드의 `get` 접두**: 공식은 "AVOID starting a function or method name with get"이지만, **dddart의 Repo·UseCase 조회 메서드는 `getChannels()` 형태를 쓴다** — HaffHaff 방언이 기준점이고 기존 코드와의 일관이 우선이다(규약 §1 원칙 1). 그 외 일반 메서드는 공식대로 일을 말하는 동사로.
2. **safeApiCall의 광범위 catch**: 공식은 "AVOID catches without on clauses"·"DON'T explicitly catch Error"지만, **safeApiCall 한 곳만 예외**다 — 전 실패를 Either로 정규화하는 의도적 단일 경계(architecture-data §2의 *왜*가 근거). **일반 코드에서는 4규칙을 지킨다**: on 절 없는 catch 금지 · Error 캐치 금지(버그는 전파되어 스택트레이스를 남겨야 한다) · 재던질 땐 `rethrow`(원 스택 보존 — `throw e`는 리셋) · Error 구현체는 프로그래밍 오류에만 던진다.
3. **지역 변수·클로저 파라미터 타입 명시**: 공식은 "AVOID type annotating initialized local variables"(추론 권장)이지만, **dddart는 지역 변수·클로저 파라미터까지 타입을 적는다**(`final List<DailyForecast> forecasts = ...`·`(BuildContext context, int index) => ...`) — HaffHaff 방언(지역 변수 ~96% 명시)이 기준점이고, 생성 BC 폴더의 `analysis_options.yaml`에 `always_specify_types`+`always_declare_return_types`로 **기계 강제**한다(codegen `*.g.dart`·`*.freezed.dart`는 `exclude`). Flutter `itemBuilder`·`AsyncValue.when`·`GoRoute` builder 콜백도 타입 명시 — 표준 콜백과의 마찰은 감수한다(dddart 확정). **컬렉션 리터럴에도 타입 인자를 적는다**(`<Widget>[...]`·`<String, String>{...}`·`@Default(<Notice>[])`) — always_specify_types는 타입 인자 없는 리스트·맵·셋 리터럴까지 잡으므로 위젯 트리의 `children`도 `children: <Widget>[...]`로 쓴다(전면 강제의 비용·장황함 감수).

## §3. 널 안전 실전 — required·연산자·promotion 관용구

- **`required`**: non-nullable·무기본값 named 파라미터의 유일한 합법 형태 — freezed const factory의 `required String id`가 직역.
- **`?.`**: 수신자가 null이면 **체인 나머지 전체가 단락** — `a?.b.c`로 충분하다. `?.`가 연쇄되면 중간 반환이 nullable이라는 뜻일 때만.
- **`??`**: null 병합(`e.message ?? 'network error'`). nullable 변수를 명시적으로 null 초기화하지 않는다(암묵 null).
- **`!`**: 런타임 캐스트 — 실패하면 throw. **마지막 수단**: 지역 변수 promotion·`??`·패턴으로 대부분 대체된다.
- **`late`**: 읽기마다 초기화 검사 — 미초기화 읽기는 런타임 예외. 초기화 여부를 검사해야 하면 late가 아니라 nullable로. 공개 late final(초기화식 없음)은 금지 — setter가 노출된다.
- **promotion 정밀 규칙**: 지역 변수는 항상 promotion / **private final 필드는 Dart 3.2부터** / public 필드·getter는 불가. **freezed 프로퍼티는 public getter라 절대 promotion 되지 않는다** — **지역 변수 복사가 표준 관용구**다:

```dart
final BadRequestResponse? error = next.value?.error; // freezed State getter → 지역 변수 복사(타입 명시·일탈3)
if (error == null) return;
error.isShow;                    // 여기서 error는 non-null로 promotion 완료
```

`state.value!.error!` 같은 `!` 연쇄는 이 관용구의 열화 형태다 — 쓰지 않는다.

## §4. freezed 3.x — 표준 표기 계약

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart'; // fromJson/toJson 쓸 때만

@freezed
abstract class Order with _$Order {        // ① 단일 생성자 모델 = abstract (3.0부터 키워드 의무)
  const Order._();                          // ② 커스텀 getter·메서드를 두려면 private 생성자 필수
  const factory Order({
    required String id,
    @Default([]) List<OrderLineItem> lines, // ③ @Default는 const 값만
    OrderStatus? status,
  }) = _Order;

  factory Order.fromJson(Map<String, Object?> json) => _$OrderFromJson(json); // ④ 직파싱
}
```

- ① 3.0 breaking: freezed 클래스는 `abstract` 또는 `sealed`(union — §5) 키워드가 의무다(공식은 제3 선택지로 수동 `implements _$X`도 허용 — dddart 비사용).
- ② `const X._()`가 있어야 생성 클래스가 extends로 바뀌어 본문 getter·메서드가 허용된다(없으면 컴파일 에러) — 도메인 메서드(`cancel()` 류)·계산 getter의 공식 근거.
- **copyWith의 null 의미론**: `copyWith(error: null)`은 **실제로 null을 대입한다**(공식 지원) — consumeError 패턴(architecture-state §4)의 성립 근거.
- **컬렉션은 unmodifiable**(3.0 기본): freezed 모델의 List·Map·Set은 제자리 변경(mutate) 시 **런타임 에러** — 갱신은 항상 새 컬렉션 합성 + copyWith: `copyWith(lines: [...lines, newLine])` (§6).
- `@JsonKey`는 **생성자 파라미터에** 붙인다(§7). fromJson 시그니처는 `Map<String, Object?>`(`Map<String, dynamic>`과 호환).
- 모델·State의 *무엇*(어떤 클래스를 어디에)은 architecture-ddd §3·§4·architecture-state §3 소유 — 여기는 표기.

## §5. union 분기 — when/map 대신 switch 패턴 매칭

**3.0에서 `when`·`map`(·maybe 변종)은 제거됐다.** 공식 입장: "Instead of using when/map, use the official Dart syntax"(패턴 매칭). 3.1이 옵션으로 재추가했지만 **dddart는 쓰지 않는다** — 표준은 switch 패턴 매칭:

```dart
// union 선언 — 다중 생성자 = sealed
@freezed
sealed class PaymentResult with _$PaymentResult {
  const factory PaymentResult.success(String receiptId) = PaymentSuccess;
  const factory PaymentResult.declined(String reason) = PaymentDeclined;
}

// 소비 — sealed라 소진성(exhaustiveness)이 컴파일 검사된다: _ 디폴트 없이 전 변종을 다룬다
final message = switch (result) {
  PaymentSuccess(:final receiptId) => '완료 $receiptId',
  PaymentDeclined(:final reason) => '거절 $reason',
};
```

- riverpod의 `AsyncValue.when`은 별개다(잔존 API — implementation-riverpod §5) — 제거된 것은 freezed의 생성 메서드.
- **dartz Either는 이 표준의 예외다** — sealed가 아니라 switch 소진성 검사를 받지 못하므로 분해는 `fold`로 한다(§8).

## §6. Dart 3 문법 — 레코드·패턴·modifier·컬렉션 합성

- **레코드·구조분해**: `final (String name, int age) = userInfo(json);` / named는 `final (:name, :age) = ...`(named 패턴 바인딩은 추론 허용). **공개 계약(Repo·UseCase 반환)은 명명된 freezed 모델·Either가 표준** — 레코드는 지역적·사적 묶음에 한정한다(타입 명시·의도 공개 원칙).
- **객체 패턴**: `if (order case Order(status: OrderStatus.canceled)) ...` / `Order(:final status)` 축약. freezed getter를 패턴 바인딩으로 추출하면 promotion 불가(§3)를 우회하는 효과.
- **switch 표현식·guard**: `switch (x) { Pattern when cond => ..., _ => ... }` — `||` 패턴·if-case(`if (data case {'user': [String name, _]}) ...`) 가용.
- **class modifier**: `sealed`(같은 라이브러리 하위형 한정 → 소진 switch — freezed union의 짝) · `final`(외부 상속·구현 금지) · `interface`(구현만) · `base`(상속만). 어순: `abstract` → modifier → `class`. 확장을 통제할 의도가 있을 때만 쓴다.
- **컬렉션 합성**: `<String>[...defaults, ...?maybeNull, for (final Channel c in cs) c.name, if (flag) extra, ?nullableElement]` — freezed 컬렉션이 unmodifiable이므로 **이 리터럴 합성이 리스트 갱신의 표준 형태**다. 리터럴 타입 인자(`<String>`)·for 변수 타입(`final Channel c`)은 always_specify_types가 요구한다(§2 일탈3).

## §7. json_serializable — @JsonKey·freezed 연동

freezed와 함께 쓸 때 모델 파일에는 §4-④(fromJson factory)만 쓰면 된다 — freezed가 json_serializable을 내부 연동한다.

```dart
// 필드명 매핑 — freezed에선 생성자 파라미터에
const factory BadRequestResponse({
  @JsonKey(name: 'error_type') required String errorType,
  required String msg,
  @JsonKey(name: 'is_show') required bool isShow, // 실물 철자(HaffHaff) — architecture-data §2
}) = _BadRequestResponse;
```

- 그 외 API 모델에 유효한 @JsonKey 파라미터: `defaultValue`(역직렬화 null 대체) · `fromJson`/`toJson`(커스텀 변환 — top-level/static 함수만) · `unknownEnumValue`(서버 enum 확장 내성).
- enum 값 매핑: `@JsonValue('paid')`.
- `explicitToJson: true` — 중첩 freezed 모델을 서버로 보낼 때(toJson이 중첩 객체의 toJson을 실제 호출).
- 일괄 `fieldRename: FieldRename.snake`보다 **명시 @JsonKey가 dddart 실물 방식**이다 — 서버 키가 코드에 보이는 쪽이 계약 대조(architecture-data §7)에 유리하다.

## §8. dartz Either — 최소 표면·fold 통일

dddart의 Either는 dartz다(HaffHaff 실사용). **사용 표면을 좁게 고정한다** — `Either`·`Left`·`Right`·`fold`·`map`(·연쇄가 필요하면 `flatMap`)만 쓰고, 그 밖의 dartz 표면(IList·Option·연산자)은 쓰지 않는다:

| 멤버 | 시그니처 요지 | 용도 |
|---|---|---|
| `fold(ifLeft, ifRight)` | **Left 핸들러가 첫 인자** | 유일한 종단 분해기 |
| `map(f)` | Right만 변환·Left 통과 | UseCase의 Either 통과(architecture-ddd §8) |
| `flatMap(f)` | Either 반환 연산 연쇄 | Repo 조합 |
| `Left(v)`·`Right(v)` | 생성 | Right=성공은 dddart 계약(architecture-data §3 — dartz는 방향 비강제) |

- **분해는 fold로 통일한다**: dartz의 Either는 Dart 3 이전 설계라 **sealed가 아니다** — `switch (either) { case Left(): ... }`는 소진성 검사를 받지 못한다(§5의 패턴 매칭 표준에서 의도적으로 제외되는 타입).
- `map`은 예외를 잡지 않는다 — 도메인 예외(`order.cancel()`의 throw)는 Either 밖으로 전파된다. 의도된 동작이다: Either는 *서버 실패* 채널이고 도메인 불변식 위반은 예외 채널(architecture-ddd §4).
- **유지보수 사실**: dartz 0.10.1이 최종(2021년경 — 사실상 휴면)이나 현 SDK에서 동작은 문제없다(HaffHaff 실사용). 활발히 유지되는 대안 fpdart(fold→match 등 호출면 상이)가 존재하지만 **교체는 기준점 변경이라 비채택** — 기존 프로젝트에 확립된 Either 라이브러리를 따른다.
