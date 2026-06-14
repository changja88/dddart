> **[dddart 원료 메모] 외부 조사** — implementation-dart 담당. 1차 출처: dart.dev·pub.dev·GitHub 공식 저장소 — 전 항목 WebFetch 실확인, **확인일 2026-06-12**. 각 절 머리에 출처 URL 표기.
> 지위: 작업장 원료(external) — 메인 루프가 final.md로 합성한다. dddart 소비처(freezed 모델·State·safeApiCall·Either·패턴 매칭) 중심 선별이며 백과사전식 나열이 아니다. 기존 배포본과의 충돌 2건·미결 2건은 StructuredOutput 보고와 동일 내용을 §해당 위치에 ⚠/❓로 표기했다.
> 버전 기준(확인 결과): Dart SDK ^3.9 · freezed 3.2.5/freezed_annotation 3.x · json_serializable 6.14/json_annotation 4.9 · **riverpod 3.x 정식(stable) 확정**(§7) · dartz 0.10.1(휴면 — §6).

---

## 1. Effective Dart — 코드 생성 직결 규칙 선별

> 출처(2026-06-12 확인): https://dart.dev/effective-dart/style · https://dart.dev/effective-dart/documentation · https://dart.dev/effective-dart/usage · https://dart.dev/effective-dart/design
> 규칙 명칭은 공식 문서의 DO/DON'T/PREFER/AVOID/CONSIDER 원문이다. 4부 전체가 아니라 AI coder가 dddart 코드를 생성할 때 실제로 닿는 규칙만 선별했다.

### 1.1 명명 (style)

| 대상 | 케이싱 | 규칙 원문 |
|---|---|---|
| 클래스·enum·typedef·타입 파라미터·extension | `UpperCamelCase` | "DO name types using UpperCamelCase" / "DO name extensions using UpperCamelCase" |
| 파일·패키지·디렉터리·import prefix | `lowercase_with_underscores` | "DO name packages, directories, and source files using lowercase_with_underscores" |
| 그 외 전부(변수·파라미터·멤버·최상위 선언) | `lowerCamelCase` | "DO name other identifiers using lowerCamelCase" |
| **상수** | **`lowerCamelCase`** | "PREFER using lowerCamelCase for constant names" — `SCREAMING_CAPS` 금지(기존 파일이 이미 그 스타일일 때만 추종 허용) |

**약어 케이싱** — "DO capitalize acronyms and abbreviations longer than two letters like words":

- 3자 이상 약어는 일반 단어처럼: `Http`·`Sms`·`Uri`·`Nasa` (HTTP·SMS·URI 아님)
- 2자 약어 중 영어에서 대문자로 쓰는 것은 대문자 유지: `ID`·`TV`·`UI` — **dddart의 `VM` 접미(`ChannelSummaryVM`)는 이 부류로 공식 규칙 정합**
- `lowerCamelCase` 식별자의 머리에서는 전부 소문자: `httpConnection`·`tvSet`

기타: "DON'T use a leading underscore for identifiers that aren't private" · "DON'T use prefix letters"(헝가리안 금지) · "PREFER using wildcards for unused callback parameters" — 미사용 콜백 파라미터는 비바인딩 `_`(Dart 3.7+, §4.2).

**import 배치**: ① "DO place dart: imports before other imports" ② "DO place package: imports before relative imports" ③ "DO specify exports in a separate section after all imports" ④ "DO sort sections alphabetically".

### 1.2 문서 주석 (documentation)

- "DO use /// doc comments to document members and types" — `/** */` 아닌 `///`. "DON'T use block comments for documentation"(일반 주석은 `//`).
- "DO start doc comments with a single-sentence summary" + "DO separate the first sentence of a doc comment into its own paragraph" — 첫 문장 요약 뒤 빈 줄.
- "DO use square brackets in doc comments to refer to in-scope identifiers" — `[Order]`·`[cancel]`처럼 스코프 내 식별자는 대괄호 참조(자동 링크).
- 서술 형태: 부작용이 목적인 함수·메서드는 3인칭 동사로 시작("Connects to the server") / non-bool 프로퍼티는 명사구 / bool 프로퍼티는 "Whether ..."로 시작.
- 범위: "PREFER writing doc comments for public APIs" / private은 CONSIDER. 코드 예시는 백틱 펜스("PREFER backtick fences for code blocks").

### 1.3 API 형태 (design)

- **"AVOID starting a function or method name with get"** — "In most cases, the method or function should be a getter with get removed from the name." 일을 하는 메서드면 일을 말하는 동사(`download`·`fetch` 류)로.
  ⚠ **conflictFlag ①**: dddart 배포본의 Repo·UseCase 표면은 `getChannels()`(architecture-data final.md L85-86, architecture-state final.md L91)·`getOrder()`(architecture-ddd final.md L174)다. HaffHaff 방언이 기준점이므로 방언 우선이 자연스러우나, 공식 AVOID와의 일탈임을 final.md(또는 houserules)에 명문화할지 메인 루프 결정 필요.
- "DO use getters for operations that conceptually access properties" — 무인자·결과 중심·멱등·가시적 부작용 없음이면 getter. dddart 정합 예: ddd §4 `Money get totalAmount`.
- bool 이름은 긍정형: "PREFER the 'positive' name for a boolean property or variable" (`isConnected` ○ / `isDisconnected` ×).
- "AVOID positional boolean parameters" — bool 인자는 named로(`copyWith(isShow: true)` 형태가 정합).
- "PREFER making fields and top-level variables final" — freezed `addImplicitFinal`(기본 true)이 모델 쪽을 자동 충족(§3.4).
- "DON'T define a setter without a corresponding getter".
- 타입 표기: "DO type annotate public APIs"(필드·최상위 변수·파라미터·반환 타입) / "DON'T redundantly type annotate initialized local variables"(공식은 초기화 지역 변수 추론 권장 — **단 dddart는 의도적 일탈3으로 지역 변수도 타입 명시**: HaffHaff 방언 기준점, final.md §2; 추론 용인은 뷰 `ref.watch`/`ref.read` 바인딩·RHS 타입 박힌 리터럴 한정).
- "PREFER making declarations private" — 공개는 의도 신호다.
- "AVOID defining a one-member abstract class when a simple function will do" — 메서드 1개짜리 추상 클래스 대신 함수 타입. (dddart는 어차피 Repo 인터페이스 비채택 — 정합.)
- "DO use class modifiers to control if your class can be extended" — §4.5.
- "AVOID defining custom equality for mutable classes" — 가변 클래스에 커스텀 `==` 금지. dddart는 freezed 불변 + 생성 `==`로 충족.

### 1.4 사용 (usage) — 컬렉션·null·에러 처리

- "DO use collection literals when possible" — `<Type>[]`·`<K, V>{}` 리터럴(spread·collection-for를 품을 수 있다 — §4.6).
- "DO use whereType() to filter a collection by type" — `objects.whereType<int>()`이 `where + cast` 조합보다 우선.
- "DON'T create a lambda when a tear-off will do" — `list.forEach(print)`처럼 함수 참조 직접 전달.
- "DON'T use async when it has no useful effect" — await 없이 Future를 그대로 반환하면 `async` 생략. (data §3 `getChannels() => safeApiCall(...)` 화살표 위임이 정확히 이 형태.)
- null 초기화: "DON'T explicitly initialize variables to null" · "DON'T use an explicit default value of null" — nullable은 암묵 null.
- **에러 처리 4규칙**:
  - "AVOID catches without on clauses" — on 없는 catch는 "anything thrown by the code in the try block"을 잡는다(StackOverflowError·OutOfMemoryError까지).
  - "DON'T explicitly catch Error or types that implement it" — "Since an Error indicates a bug in your code, it should unwind the entire callstack, halt the program, and print a stack trace."
  - "DO use rethrow to rethrow a caught exception" — `rethrow`는 원 스택트레이스 보존, `throw`는 리셋.
  - "DO throw objects that implement Error only for programmatic errors".
  ⚠ **conflictFlag ②**: architecture-data final.md L68(`on TypeError catch` — TypeError는 Error 하위)·L70(bare `catch (e)`)의 safeApiCall은 위 두 규칙과 정면 충돌한다. 단 이는 "전 실패를 Either로 정규화하는 단일 경계"라는 의도적 정책(같은 파일 §2의 *왜*가 근거)이므로, 수정이 아니라 **공식 가이드 대비 의도적 일탈임을 명문화**(경계 1곳에서만 허용, 일반 코드에서는 4규칙 준수)하는 쪽이 정합 — 메인 루프 결정 필요.

## 2. 널 안전 실전 — late·?.·!·??·promotion·required

> 출처(2026-06-12 확인): https://dart.dev/null-safety/understanding-null-safety · https://dart.dev/tools/non-promotion-reasons · https://dart.dev/effective-dart/usage

### 2.1 연산자·키워드 의미론

- **`required`**: named 파라미터가 non-nullable이고 기본값이 없으면 `required` 필수 — "all optional parameters must either have a nullable type or a default value"(이 조건을 못 채우는 named 파라미터의 유일한 합법 형태가 required). freezed const factory의 `required String id`가 이 규칙의 직역.
- **`?.`**: 수신자가 null이면 **체인의 나머지 전체가 단락**된다 — "the entire rest of the method chain is short-circuited and skipped". 따라서 `a?.b.c`로 충분하며, `thing?.doohickey?.gizmo`처럼 ?.가 연쇄되면 그것은 `doohickey` 자체가 nullable 반환이라는 뜻이다(불필요한 ?. 중복 금지).
- **`??`**: null 병합 — `e.message ?? 'network error'`(data §2 형태).
- **`!`**: nullable을 non-nullable로 **런타임 캐스트** — "using ! comes with a loss of static safety. The cast must be checked at runtime to preserve soundness and it may fail and throw an exception." 실패 메시지는 "Null check operator used on a null value". 마지막 수단 — 지역 변수 promotion(§2.2)·`??`·패턴(§2.3)으로 대부분 대체된다.
- **`late`**: 읽기마다 초기화 검사 런타임 삽입 — 미초기화 읽기는 예외(LateInitializationError 메시지). `late final`은 1회 대입만 허용(2회째 대입 예외). 초기화식이 붙은 `late`는 **lazy** — "deferred and run lazily the first time the field is accessed".
  - "AVOID late variables if you need to check whether they are initialized" — 초기화 여부를 검사할 길이 없으므로, 검사가 필요하면 nullable + null 검사로.
  - "AVOID public late final fields without initializers"(design) — 공개 setter가 생겨버린다. private + getter 또는 팩토리로.

### 2.2 타입 promotion — 정밀 규칙 (과잉 단순화 주의)

"필드는 promotion 안 된다"는 옛 단순화다 — 공식 규칙(2026-06-12 확인):

| 대상 | promotion | 근거(공식 원문) |
|---|---|---|
| 지역 변수 | **항상 가능** | null 검사·`is`·`as`·`!`·대입 모두 promotion 유발 |
| **private final 필드** | **Dart 3.2부터 가능** | 조건: private(`_`)·final·non-external·동명 getter/비승격 필드/noSuchMethod 전달자가 라이브러리에 없음 |
| public 필드 | 불가 | "it's possible for other libraries to override public fields with a getter ... non-private fields cannot be promoted" |
| non-final 필드 | 불가 | "could be modified any time between the time they're tested and the time they're used" |
| **getter** | **불가** | "The compiler has no way to guarantee that a getter returns the same result every time" |

**dddart 직결 귀결**: freezed 모델의 프로퍼티는 추상 클래스+mixin의 **getter 선언**이고 public이다 — 두 사유 모두로 **절대 promotion 되지 않는다**. 따라서 **지역 변수 복사가 표준 관용구**다:

```dart
// 공식 처방 그대로 — 지역 변수에 받으면 그 변수가 promotion 된다
final error = next.valueOrNull?.error; // freezed State의 getter → 지역 변수로
if (error == null) return;
error.isShow; // 여기서 error는 BadRequestResponse로 promotion 완료
```

state §4 View 예제(L113-114)가 정확히 이 패턴이다 — 검증 정합 ✓. `state.value!.error!` 같은 `!` 연쇄는 이 관용구의 열화 형태로 취급한다.

### 2.3 패턴 대안

usage의 "CONSIDER type promotion or null-check patterns for using nullable types"가 제시하는 두 번째 길 — null-check 패턴:

```dart
if (this.response case var response?) {
  // response는 non-nullable로 바인딩됨
}
```

지역 변수 복사와 등가이며, 분해까지 겸할 때(§4.4) 유리하다.

## 3. freezed 3.x — 3.0 breaking·표기 계약·배포본 검증

> 출처(2026-06-12 확인): https://pub.dev/packages/freezed (README) · https://pub.dev/packages/freezed/changelog · https://raw.githubusercontent.com/rrousselGit/freezed/master/packages/freezed/CHANGELOG.md · https://github.com/rrousselGit/freezed/blob/master/packages/freezed/migration_guide.md · https://pub.dev/documentation/freezed_annotation/latest/freezed_annotation/Freezed-class.html
> 버전: **3.2.5 안정 최신**(2026-02-03, analyzer 10 지원). 4.0.0-dev.1 프리릴리스 존재 — 비채택. 런타임 어노테이션은 freezed_annotation 3.x 동행(HaffHaff 3.1 핀 정합).

### 3.1 3.0.0 breaking (2025-02-25) — changelog 원문

1. **"Removed `map/when` and variants. These have been discouraged since Dart got pattern matching."** — `when`·`map`·`maybeWhen`·`maybeMap` 제거. 대체는 Dart 3 패턴 매칭(§3.3).
2. **"Freezed classes should now either be `abstract`, `sealed`, or manually implements `_$MyClass`."** — 키워드 수기 표기 의무화. migration guide의 구분: **단일 생성자 모델 → `abstract`**, **다중 생성자(union) → `sealed`**.
3. 컬렉션 프로퍼티는 기본 unmodifiable 뷰로 변환(List/Map/Set → UnmodifiableListView/UnmodifiableMapView/UnmodifiableSetView) — `makeCollectionsUnmodifiable`(클래스별)·build.yaml(전역)로 비활성 가능. 귀결: **freezed 모델의 리스트를 제자리 변경(mutate)하면 런타임 에러** — 항상 `[...list, item]`처럼 새 컬렉션을 만들어 `copyWith`로 교체한다.

부수: 3.0은 factory 없는 단순 클래스 선언("mixed mode")도 지원하나, dddart 표준 표기는 const factory 형태 유지(아래 §3.2). 3.1.0(2025-07-02)이 `when`/`map`을 **"Added `when`/`map` back"**으로 재추가 — `@Freezed(when: FreezedWhenOptions, map: FreezedMapOptions)` 옵션으로 통제된다(annotation API 확인: "Options for customizing the generation of `map`/`when` functions"). ❓ **unresolved ①**: 옵션 미지정 시 기본 생성 여부는 공식 문서 미명시 — 단 코퍼스 규칙에는 영향 없다: README가 방향을 못박는다(§3.3 인용), **dddart는 when/map을 쓰지 않고 switch 패턴 매칭을 쓴다.**

### 3.2 표준 표기 계약 (3.x 검증 완료 형태)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart'; // fromJson/toJson 쓸 때만

// ① 단일 생성자 모델 = abstract
@freezed
abstract class Order with _$Order {
  const Order._();                       // ② 커스텀 메서드·getter를 두려면 private 생성자 필수
  const factory Order({                  // ③ const factory + named/positional 파라미터
    required String id,                  //    non-nullable·무기본값 → required
    @Default([]) List<OrderLineItem> lines, // ④ @Default는 const 값만
    OrderStatus? status,
  }) = _Order;

  factory Order.fromJson(Map<String, Object?> json) => _$OrderFromJson(json); // ⑤ 직파싱
}
```

- ② **private 생성자의 효과**: `const X._()`가 있으면 생성 클래스가 X를 implements 대신 **extends** 하므로 본문에 getter·메서드를 쓸 수 있다(없으면 컴파일 에러). README 원문 예제가 `const Person._(); ... void method() {...}` 형태. — ddd §3 `const Money._()`·§4 `const Order._()`의 공식 근거.
- ④ `@Default`는 const 한정("factory constructors cannot specify defaults") — 비상수 기본값은 private 생성자 쪽 본문 getter로 우회.
- ⑤ fromJson 시그니처는 README 표준이 `Map<String, Object?>` — `Map<String, dynamic>`과 상호 할당 가능(§5.4)하므로 어느 쪽도 컴파일된다. 배포본 ddd §4 표기와 정합 ✓.
- **copyWith**: 모든 freezed 클래스에 생성. **`copyWith(field: null)`은 실제로 null을 대입한다**("Notice Freezed supports `person.copyWith(age: null)`" — README) — state §4 `consumeError()`의 `copyWith(error: null)`이 성립하는 공식 근거 ✓. 중첩 모델은 deep copy 문법: `company.copyWith.director.assistant(name: 'John')`.
- **@JsonKey는 생성자 파라미터에** 붙인다(§5.2) — 생성 프로퍼티로 자동 복사.
- union(다중 생성자)은 `sealed` + 명명 생성자(`factory Model.first(...) = First;`) — 소비는 §3.3. 직렬화가 필요하면 `@Freezed(unionKey:)`·`fallbackUnion`으로 통제(annotation API 확인).

### 3.3 when/map의 대체 — 공식 입장과 마이그레이션 형태

README 원문: **"As of Dart 3, Dart now has built-in pattern-matching using sealed classes. As such, you no-longer need to rely on Freezed's generated methods. Instead of using `when`/`map`, use the official Dart syntax."** + "in the long term, you should stop relying on them and migrate to `switch` expressions."

migration guide의 정식 before/after:

```dart
// before (freezed 2.x)
final res = model.map(
  first: (String a) => 'first $a',
  second: (int b, bool c) => 'second $b $c',
);

// after (freezed 3.x — Dart 3 패턴 매칭)
final res = switch (model) {
  First(:final a) => 'first $a',
  Second(:final b, :final c) => 'second $b $c',
};
```

sealed 루트이므로 switch가 **소진성(exhaustiveness)을 컴파일 검사**한다 — `_` 디폴트 없이 전 변종을 다루는 것이 표준(§4.5).

### 3.4 배포본 검증 결과 (충돌 없음)

| 배포본 예제 | freezed 3.x 판정 |
|---|---|
| state §3·§4 `@freezed abstract class ChannelSummaryState with _$ChannelSummaryState` + `@Default([])` + `BadRequestResponse? error` | ✓ 정합(단일 생성자 = abstract, @Default const) |
| state §4 `consumeError()`의 `copyWith(error: null)` | ✓ 공식 지원(null 대입 의미론) |
| ddd §3 `Money` — `const Money._()` + positional `const factory Money(int amount)` + `add`/`multiply` 메서드 | ✓ 정합(private 생성자 → 메서드 허용) |
| ddd §4 `Order` — `const Order._()` + `fromJson(Map<String, Object?>)` + `Money get totalAmount` + `cancel()`이 내부에서 `copyWith` 호출 | ✓ 정합 |
| 배포본 전체에서 `when`/`map` 사용 0건 | ✓ 3.0 제거와 정합 — 유지할 것 |

참고: `@Freezed` annotation 옵션 확인분 — `copyWith`/`equal`/`fromJson`/`toJson`(bool?), `addImplicitFinal`(기본 true — 파라미터 전부 final 가정), `genericArgumentFactories`(기본 false), `unionKey`/`unionValueCase`/`fallbackUnion`.

## 4. Dart 3.9 문법 — 코퍼스 관련 (가용 기능과 상한)

> 출처(2026-06-12 확인): https://dart.dev/resources/language/evolution · https://dart.dev/language/patterns · https://dart.dev/language/class-modifiers

### 4.1 버전 지도 — 3.9의 정확한 의미

공식 evolution 페이지 기준: **Dart 3.9 자체는 신규 언어 기능이 없다**(null safety 가정·Flutter SDK 제약 처리 갱신뿐). 즉 "SDK ^3.9 문법" = 3.0~3.8 누적분이다:

| 도입 버전 | 기능 |
|---|---|
| 3.0 | **Patterns, Records, Class modifiers, Switch expressions, If-case clauses** |
| 3.2 | private final 필드 promotion (§2.2) |
| 3.3 | extension types (zero-cost 래핑 — 코퍼스 비소비, 존재만 기록) |
| 3.6 | digit separators (`1_000_000`) |
| 3.7 | wildcard variables — `_` 비바인딩 |
| 3.8 | null-aware elements — 컬렉션 리터럴 안 `?expr` |

**상한 주의(AI coder 오염 방지)**: 언어 버전은 pubspec의 min SDK가 정한다 — 최신 Dart는 3.12(2026-05-18 출시)지만 `sdk: ^3.9.0` 프로젝트에서는 **3.10 dot shorthands(`.enumValue` 축약)·3.12 private named parameters를 쓸 수 없다.** 생성 코드에 이 둘이 나오면 컴파일 실패다.

### 4.2 레코드·구조분해

```dart
var (name, age) = userInfo(json);   // positional 분해
final (:name, :age) = getData();    // named 필드 — :축약(같은 이름 변수로 바인딩)
```

다중 반환값에 사용 — 단 dddart에서 공개 계약(Repo·UseCase 반환)은 명명된 freezed 모델·Either가 표준이고, 레코드는 지역적·사적 묶음에 한정하는 것이 §1.3(타입 명시·의도 공개)과 정합.

### 4.3 객체 패턴 — freezed 모델 분해

```dart
var Foo(:one, :two) = myFoo;             // 선언 분해
if (order case Order(status: OrderStatus.canceled)) { ... } // 상수 매칭
switch (shape) { case Square(length: var l): ... }          // getter 추출
```

`Order(:final status)` 축약형 = `Order(status: final status)`. freezed 프로퍼티는 getter이므로 객체 패턴으로 그대로 추출된다 — promotion 불가(§2.2)를 패턴 바인딩이 우회하는 효과.

### 4.4 switch 표현식·if-case·guard

```dart
var isPrimary = switch (color) {
  Color.red || Color.yellow || Color.blue => true, // || 패턴
  _ => false,                                      // _ 디폴트
};

if (data case {'user': [String name, int age]}) {  // if-case — 맵·리스트 패턴 검증+분해
  print('User $name is $age years old.');
}

case (int a, int b) when a > b:                    // guard — when 절(거짓이면 다음 case로)
```

### 4.5 sealed·class modifiers

```dart
sealed class Shape {}
double calculateArea(Shape shape) => switch (shape) {
  Square(length: var l) => l * l,
  Circle(radius: var r) => math.pi * r * r,
}; // 전 하위형이 같은 라이브러리에 있음을 컴파일러가 알아 소진성 검사 — _ 불요
```

| modifier | 의미(공식 요지) |
|---|---|
| (없음) | 어디서든 생성·상속·구현·믹스인 |
| `abstract` | 생성 불가(라이브러리 안팎 공히) |
| `sealed` | **암묵 abstract** + 하위형은 같은 라이브러리에만 → **소진 switch 가능**. `abstract sealed` 조합은 금지(중복) |
| `final` | 라이브러리 밖 상속·구현 전면 금지 — 하위형은 base/final/sealed 의무 |
| `interface` | 밖에서 구현(implement)만 가능, 상속 불가 |
| `base` | 밖에서 상속(extend)만 가능, 구현 불가 — 하위형에 base/final/sealed 전이 |

조합 어순: `abstract` → `base`/`interface`/`final`/`sealed` → `mixin` → `class` (`abstract interface class` 등 허용). freezed union의 `sealed`(§3)·"DO use class modifiers to control if your class can be extended"(§1.3)가 소비처다.

### 4.6 collection-for·spread·null-aware element

```dart
final all = [
  ...defaults,                  // spread (2.3+)
  ...?maybeNull,                // null-aware spread
  for (final c in channels) c.name, // collection-for
  if (showExtra) extra,         // collection-if
  ?nullableElement,             // null-aware element (3.8+) — null이면 원소 자체가 빠짐
];
```

freezed 컬렉션이 unmodifiable(§3.1-3)이므로 이 리터럴 합성이 리스트 갱신의 표준 형태다: `copyWith(lines: [...lines, newLine])`.

## 5. json_serializable 6.x — @JsonKey·필드 직렬화

> 출처(2026-06-12 확인): https://pub.dev/packages/json_serializable (6.14.0, 2026-05 중순 발행·Google verified publisher). 런타임 어노테이션은 json_annotation 4.9 라인(생성기 6.x 요구 짝).

### 5.1 기본 배선

`part 'x.g.dart'` + `dart run build_runner build`. freezed와 함께 쓸 때는 freezed가 json_serializable을 내부 연동 — 모델 파일에는 §3.2의 ⑤(fromJson factory)만 쓰면 된다.

### 5.2 @JsonKey — 필드 단위 제어 (dddart 1순위 소비)

```dart
@JsonKey(name: 'first_name') final String firstName; // 평클래스: 필드에
// freezed: 생성자 파라미터에 (생성 프로퍼티로 자동 복사 — freezed README 확인)
factory Example(@JsonKey(name: 'my_property') String myProperty) = _Example;
```

`BadRequestResponse`(data §2의 철자 errorType←`error_type`·msg←`msg`·isShow←`is_show`)의 메커니즘 직역 — **널러블·기본값 확정은 HaffHaff 실물(internal) 소관**이며 여기선 표기만 확정한다. 단 state §4가 `if (error.isShow)`로 분기하므로 isShow는 non-null bool이어야 정합:

```dart
@freezed
abstract class BadRequestResponse with _$BadRequestResponse {
  const factory BadRequestResponse({
    @JsonKey(name: 'error_type') required String errorType,
    required String msg,
    @JsonKey(name: 'is_show') @Default(true) bool isShow, // 예시 — 실물 철자·널러블이 기준
  }) = _BadRequestResponse;

  factory BadRequestResponse.fromJson(Map<String, Object?> json) =>
      _$BadRequestResponseFromJson(json);
}
```

API 모델에 유효한 나머지 @JsonKey 파라미터: `defaultValue`(역직렬화 null 대체) · `includeIfNull`(null 필드의 JSON 출력 여부) · `fromJson`/`toJson`(커스텀 변환 — "must be top-level or static") · `required`/`disallowNullValue`(키 부재·null 거부) · `unknownEnumValue`(미지 enum 폴백 — 서버 enum 확장 내성).

### 5.3 클래스 단위 옵션·enum

```dart
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true, includeIfNull: false)
```

- `fieldRename: FieldRename.snake`는 전 필드 일괄 snake_case 매핑 — 개별 `@JsonKey(name:)`이 항상 우선. dddart 배포본(data §2)은 명시 @JsonKey 방식을 실물로 확인했다 — 일괄 옵션 채택 여부는 houserules 영역.
- `explicitToJson: true`: 중첩 모델의 toJson을 실제 호출(기본은 객체 그대로 박힘) — 중첩 freezed 모델을 서버로 보낼 때 필요.
- enum: `@JsonValue(200) success` (값 매핑) · enhanced enum이면 `@JsonEnum(valueField: 'code')`.

### 5.4 Map<String, Object?> ↔ Map<String, dynamic>

생성 `_$XFromJson`의 파라미터는 `Map<String, dynamic>`이지만 `Object?`와 `dynamic`은 상호 할당 가능한 최상위 타입이라 **두 표기는 호환**된다 — freezed README가 `Map<String, Object?>`를 채택(§3.2), data §2의 `data is Map<String, Object?>` 검사 후 `fromJson(data)` 호출도 그대로 성립 ✓.

## 6. dartz Either — 최소 표기·유지보수 상태

> 출처(2026-06-12 확인): https://pub.dev/packages/dartz · https://pub.dev/documentation/dartz/latest/dartz/Either-class.html · https://pub.dev/packages/fpdart

### 6.1 유지보수 상태 (사실 기록)

- **dartz 0.10.1이 최종 — 발행 약 4년 전(2021년경)**, unverified uploader. 이후 릴리스 없음 — **사실상 휴면(dormant)**. 단 Dart 2.12+ 널 안전 충족으로 현 SDK에서 동작 자체는 문제 없음(HaffHaff 실사용이 증거).
- 대안 **fpdart 1.2.0**(2025-10-29 발행): 활발 유지·Flutter Favorite·Dart 3 설계·풍부한 문서("dartz의 최대 약점인 문서 부재"를 명시 겨냥). Either 분해 표준은 `match((l) => ..., (r) => ...)`(인자 순서 동일 — Left 먼저), `mapLeft`·`flatMap`·TaskEither 제공.
- ❓ **unresolved ②**: dartz→fpdart 교체 여부는 기준점(HaffHaff=dartz) 변경 결정이라 이 조사의 권한 밖 — 휴면 사실과 대안만 기록한다. 교체 시 fold→match 등 호출면 치환이 필요해 기계 치환 수준이 아니다.

### 6.2 Either 최소 표면 — API 검증 (data §3·state §4·ddd §8 대조)

공식 API 문서 시그니처 원문:

| 멤버 | 시그니처 | 의미 |
|---|---|---|
| `fold` | `fold<B>(B ifLeft(L l), B ifRight(R r)) → B` | **Left 핸들러가 첫 인자** — 유일한 종단 분해기 |
| `map` | `map<R2>(R2 f(R r)) → Either<L, R2>` | **Right만 변환, Left는 통과** |
| `leftMap` | `leftMap<L2>(L2 f(L l)) → Either<L2, R>` | Left만 변환 |
| `flatMap`(=`bind`) | `flatMap<R2>(Function1<R, Either<L, R2>> f)` | Either 반환 연산 연쇄(중첩 평탄화) |
| `getOrElse` | `getOrElse(R dflt()) → R` | Right 값 또는 폴백 |
| 기타 | `isLeft`/`isRight`·`swap()`·`toOption()` | 보조 |
| 생성 | `Left(value)`·`Right(value)` | 구체 구현 2종 |

**배포본 검증 — 전부 정합 ✓**: data §2 `Right(await apiCall())`·`Left(BadRequestResponse(...))` ✓ / data §3 Repo 반환 `Either<BadRequestResponse, T>`(Right=성공은 dddart 규약 결정 — dartz는 방향 비강제, 통용 관례와 일치) ✓ / state §4 `result.fold((error) => throw error, (channels) => ...)` — Left 먼저 ✓ / ddd §8 `found.map((order) => order.cancel())` — Right 변환·Left 통과 ✓.

주의 2건: ① dartz의 `Either`는 Dart 3 이전(2021) 설계라 **sealed가 아니다** — `switch (either) { case Left(): ... }`는 소진성 검사를 받지 못하므로 **분해는 fold로 통일**한다(코퍼스 표면: `Either`·`Left`·`Right`·`fold`·`map`(·필요시 `flatMap`) — 이 밖의 dartz 표면(IList·Option·연산자 등)은 쓰지 않는다). ② `map`은 예외를 잡아주지 않는다 — `order.cancel()`이 던지는 도메인 예외는 Either 밖으로 throw 전파된다(ddd §4 규칙 2의 의도된 동작 — Either는 *서버 실패* 채널이고 도메인 불변식 위반은 예외 채널).

## 7. 버전 라인 확인 (2026-06-12, pub.dev·dart.dev)

| 패키지/SDK | 확인된 안정 최신 | 발행 시점 | dddart 기준선 판정 |
|---|---|---|---|
| Dart SDK | 3.12 (2026-05-18) | — | 코퍼스는 **^3.9 언어 기능까지만** 사용(§4.1 상한) |
| freezed | **3.2.5** | 2026-02-03 | 3.2 라인 ✓ (4.0.0-dev 비채택) |
| freezed_annotation | 3.x 라인 | — | 3.1 핀 ✓ |
| json_serializable | **6.14.0** | 2026-05 중순 | 6.x ✓ (^6.10 핀이 6.14로 해소됨) |
| json_annotation | 4.9 라인 | — | ✓ |
| riverpod / flutter_riverpod | **3.3.2** | 2026-06-10경 | **3.0 정식 출시 확정** — 3.0.0 stable은 약 2025-09("9 months ago"). 코퍼스는 3.x 정식 기준으로 작성한다 |
| dartz | 0.10.1 (최종) | ~2021 | 휴면 — §6.1 |
| fpdart | 1.2.0 | 2025-10-29 | 대안 후보(미채택) |

- **지시 이행 보고**: "riverpod 3.0 정식 출시 여부를 조사로 확정" → **확정: 정식 출시됨**(3.0.0 stable ~2025-09, 현행 3.3.2). HaffHaff pubspec의 `^3.0.0-dev.17` 핀은 정식 출시 전 시점의 흔적 — 코퍼스 문서는 3.x 정식 API 기준으로 쓴다(표기 상세는 implementation-riverpod 소관).
- riverpod 3.0.0은 min Dart 3.8, 이후 3.x는 min Dart 3.7 요구(pub.dev 확인) — SDK ^3.9 기준선과 충돌 없음.
