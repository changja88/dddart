# 범용 클린 코드 원칙 종합 가이드 (Dart·Flutter)

## P1 Source Sufficiency

| field | value |
|---|---|
| purpose | dddart가 생성하는 Dart/Flutter 코드의 유지보수성 규율 단일 출처 — 이름·함수 형태·책임·캡슐화·추상화·SOLID·중복·오류 처리·레거시·스멜·리팩토링, 그리고 dddart 고유 결정(반복>상속). |
| use when | 코드 리뷰·리팩토링에서 "이해 가능한가, 응집적인가, 명시적인가, 동작을 보존하며 바꿀 수 있는가"를 물을 때. |
| exclude/handoff | 도메인 모델링·판정 소유는 architecture-ddd, 파일트리·명명 사실은 discipline-houserules, VM·State 동작은 architecture-state, Either·실패 처리는 architecture-data, Dart 관용구·표기법은 implementation-dart로 위임. |
| core criteria | dddjango discipline-cleancode final(보편 규율 — CC·APoSD·IP·OO·PC·WELC 합성본)의 직격 이식: 산문 보존, Python 예제 80펜스 전량 Dart 치환(2026-06-12, 6-agent 분담·치환 기록은 review.md), Django 언급 일반화. + dddart 결정 반영: §16 테스트 전제에 dddart 단서(테스트 없음 — 안전망은 analyze 래칫·백스톱), §18 신설(반복>상속 — 규약 §10-5 ①), 원본 §18(Python 관용구)은 비승계(implementation-dart가 대체). |
| source priority | 1 dddjango final 소스판(external.md — 서지 전문은 그 말미) 2 제1 규약 §10-5(dddart 코드 규율 결정) 3 Effective Dart(치환 관례 기준). |
| P1 classification | sufficient — 산문은 원전 보존이 원칙이라 발명 표면이 좁다. 치환 중 구조 변경(리플렉션 부재·definite return 등 언어 차이 기인)은 review.md에 전수 기록. §18은 규약 §10-5 ① 문면("base VM·공용 헬퍼 없음·반복이 더 결정적")의 전개. |

> **출처:** dddjango `discipline-cleancode` final 소스판(2026-06-12 반입) 합성 서지 — [CC] Clean Code(로버트 C. 마틴) · [IP] 켄트 벡의 구현 패턴 · [OO] 객체지향의 사실과 오해(조영호) · [PC] 파이썬 클린코드 2nd(마리아노 아나야) · [APoSD] A Philosophy of Software Design(존 오스터하우트) · [CodeC] Code Complete(스티브 맥코넬) · [PP] The Pragmatic Programmer(토마스·헌트) · [Ref] Refactoring(마틴 파울러) · [WELC] Working Effectively with Legacy Code(마이클 페더스). + 제1 규약 §10-5 · Effective Dart(치환 관례).
> 본문 속 `(규약 §N)`·출처 태그(`[CC]` 등)는 **출처 표기**이며 로드 대상이 아니다 — 규칙 자체는 본문에 자족적으로 서술된다. 로드 가능한 위임은 "스킬명 + §번호(또는 주제)"뿐.

---

## 목차

- §1. 클린 코드란 무엇인가
- §2. 이름 짓기 (Naming)
- §3. 함수와 메서드 설계
- §4. 주석과 문서화
- §5. 코드 형식과 구조
- §6. 추상화와 캡슐화
- §7. 깊은 모듈 설계
- §8. 객체 설계 원칙
- §9. SOLID 원칙
- §10. 디자인 패턴
- §11. 상태 관리
- §12. 오류 처리
- §13. 중복 제거와 DRY
- §14. 협력과 의존성 관리
- §15. 리팩토링
- §16. 레거시 코드 다루기 (dddart 단서: 생성 코드엔 행위 검증 테스트 산출[green=flutter test]·레거시 특성화 테스트는 비강제 — 안전망은 analyze 래칫·백스톱·테스트)
- §17. 설계 철학과 프로세스
- §18. dddart 코드 규율 — 반복>상속 (원본 §18 Python 관용구는 비승계 — implementation-dart가 대체)
- 핵심 요약 체크리스트 (말미 — 전 범주 1줄 요약표)

---

## §1. 클린 코드란 무엇인가

### 1.1 핵심 정의

클린 코드에 대한 정의는 대가들마다 표현이 다르지만 공통된 본질이 있다.

> "깨끗한 코드는 한 가지를 제대로 한다" -- 비야네 스트롭스트룹 **[CC]**

> "깨끗한 코드는 단순하고 직접적이다. 잘 쓴 문장처럼 읽힌다." -- 그래디 부치 **[CC]**

> "클린 코드인지 아닌지는 다른 엔지니어가 코드를 읽고 유지 관리할 수 있는지 여부에 달려 있다" **[PC]**

> "프로그래밍 언어의 진정한 의미는 아이디어를 다른 개발자에게 전달하는 것이다" **[PC]**

### 1.2 클린 코드의 세 가지 비결 [CC]

론 제프리스가 정리한 클린 코드의 핵심:

1. **중복 줄이기** -- 같은 작업을 반복하면 아이디어를 제대로 표현하지 못한 증거다
2. **표현력 높이기** -- 의미 있는 이름, 단일 책임 메서드
3. **초반부터 간단한 추상화 고려하기** -- 실제 구현을 감싸는 추상화

### 1.3 세 가지 가치 [IP]

켄트 벡은 훌륭한 프로그래밍의 공통 가치를 다음과 같이 정의한다:

- **커뮤니케이션** -- 코드를 쉽게 이해하고, 수정하고, 사용할 수 있는가
- **단순성** -- 복잡도를 낮춰 빠르게 이해할 수 있는가 (단, 과도한 단순화는 커뮤니케이션을 저해)
- **유연성** -- 변경에 대응할 수 있는가 (유연성은 복잡도를 증가시키므로 필요한 경우에만)

### 1.4 소프트웨어 비용 공식 [IP]

```
전체 비용 = 개발 비용 + 유지 비용
유지 비용 = 이해 비용 + 수정 비용 + 테스트 비용 + 설치 비용
```

**유지 비용이 대부분을 차지하며, 그중에서도 이해 비용이 핵심이다.**

### 1.5 복잡성의 본질 [APoSD]

소프트웨어 설계의 근본 문제는 **복잡성 관리**다. 복잡성이란 시스템을 이해하고 수정하기 어렵게 만드는 구조적 특성이다.

#### 복잡성의 세 가지 발현

| 발현 | 설명 | 예시 |
|------|------|------|
| **Change Amplification** | 단순한 변경이 여러 곳의 수정을 요구 | 색상 상수가 10개 파일에 분산 |
| **Cognitive Load** | 한 작업을 완료하기 위해 알아야 할 것이 많다 | 함수 호출을 위해 5개 모듈의 상태를 이해해야 함 |
| **Unknown Unknowns** | 무엇을 해야 하는지, 제안된 해법이 올바른지조차 불분명 | 숨겨진 의존성이나 암묵적 규칙 |

#### 복잡성의 두 가지 근원

- **의존성(dependencies)**: 코드를 고립적으로 이해하고 수정할 수 없는 상태
- **모호성(obscurity)**: 중요한 정보가 명확하지 않은 상태

### 1.6 제1 기술적 명령: 복잡성 관리 [CodeC]

고품질 코드는 읽는 사람에게 **일관된 추상화 수준**을 노출하며, 명확한 경계로 구분된다. 본질적 복잡성(essential complexity)은 최소화하고, 우발적 복잡성(accidental complexity)의 확산을 방지한다.

---

## §2. 이름 짓기 (Naming)

### 2.1 의도를 분명히 밝혀라 [CC]

변수, 함수, 클래스 이름은 존재 이유, 수행 기능, 사용 방법에 모두 답해야 한다.
따로 주석이 필요하다면 의도를 분명히 드러내지 못했다는 뜻이다.

```dart
// --- 나쁜 예 ---
final d = 7; // 경과 일수

// --- 좋은 예 ---
final elapsedDaysSinceCreation = 7;
```

### 2.2 그릇된 정보를 피하라 [CC]

유사한 개념은 유사한 표기법을 사용하되, 실제와 다른 정보를 이름에 담지 마라.

```dart
// --- 나쁜 예 ---
final accountList = {}; // 실제로는 Map인데 List라고 명명

// --- 좋은 예 ---
final accounts = {};
final accountMap = {};
```

### 2.3 의미 있게 구분하라 [CC]

불용어(Info, Data, a, the)를 사용하면 개념을 구분하지 못한 채 이름만 달리한 것이다.

```dart
// --- 나쁜 예 ---
class ProductInfo { ... }
class ProductData { ... }  // Info와 Data는 아무것도 구분하지 못한다

// --- 좋은 예 ---
class Product { ... }
class ProductDetail { ... }  // 구체적으로 무엇이 다른지 이름에 반영
```

### 2.4 검색하기 쉬운 이름과 변수 이름 길이 [CC] [CodeC]

이름 길이는 **범위(scope) 크기에 비례**해야 한다. 넓은 범위에서 사용되는 변수일수록 긴 이름이 필요하고, 좁은 범위의 지역 변수는 짧아도 된다. **[CC]**

평균적인 가이드라인으로, 변수 이름의 최적 평균 길이는 **10-16자**(Gorla, Benander, Benander 연구), 루틴 이름은 **15-20자**를 참고한다. **[CodeC]**

```dart
// --- 나쁜 예 ---
for (var i = 0; i < 34; i++) {
  s += t[i] * 4 / 5; // 4, 5, s, t가 무엇인지 알 수 없다
}

// --- 좋은 예 ---
const workDaysPerWeek = 5;
for (var taskIndex = 0; taskIndex < numberOfTasks; taskIndex++) {
  final realDays = taskEstimate[taskIndex] * realDaysPerIdealDay;
  weeklySum += realDays / workDaysPerWeek;
}
```

### 2.5 한 개념에 한 단어를 사용하라 [CC]

추상적인 개념 하나에 단어 하나를 선택해 고수한다.

```dart
// --- 나쁜 예 ---
class UserRepository {
  User fetchUser() { ... }   // fetch
}

class OrderRepository {
  Order retrieveOrder() { ... }  // retrieve -- 같은 개념에 다른 단어
}

// --- 좋은 예 ---
class UserRepository {
  User getUser() { ... }
}

class OrderRepository {
  Order getOrder() { ... }  // 통일된 용어 사용
}
```

### 2.6 클래스 이름은 명사, 메서드 이름은 동사 [CC] [IP]

```dart
// 클래스: 명사 또는 명사구
class Customer { ... }
class AddressParser { ... }

// 메서드: 동사 또는 동사구
void postPayment() { ... }
void deletePage() { ... }
```

### 2.7 의도 제시형 이름 [IP]

메서드 이름에는 의도만 전달하고 구현 전략은 담지 마라.

```dart
// --- 나쁜 예 ---
Customer linearSearchCustomer(String customerId) { ... }

// --- 좋은 예 ---
Customer findCustomer(String customerId) { ... }
```

### 2.8 역할 제시형 작명 [IP]

변수 이름은 연산에서의 역할을 반영하여 짓는다. 생명기간, 범위, 타입은 문맥에서 전달된다.

```dart
// --- 나쁜 예 ---
final tempStrList = getItems();

// --- 좋은 예 ---
final results = getItems();        // 컬렉터 역할
final pendingCount = queue.length; // 카운터 역할
```

### 2.9 컬렉션은 복수형으로 [IP]

여러 데이터를 저장하는 변수는 복수형이어야 한다.

```dart
// --- 나쁜 예 ---
final member = [user1, user2, user3];

// --- 좋은 예 ---
final members = [user1, user2, user3];
```

### 2.10 한정자(Qualifier) 배치: 핵심 개념을 앞에 [CodeC]

핵심 개념을 접두어로, 한정자를 뒤에 배치한다. 관련 변수들이 그룹으로 인식되고, IDE 자동완성과 알파벳 정렬에서도 이점이 있다.

```dart
// --- 나쁜 예: 한정자가 앞에 ---
final totalRevenue = ...;
final avgRevenue = ...;
final maxRevenue = ...;

// --- 좋은 예: 핵심 의미를 앞에, 한정자를 뒤에 ---
final revenueTotal = ...;
final revenueAverage = ...;
final revenueMax = ...;
// 핵심 개념(revenue)이 항상 앞에 있으므로 그룹으로 인식 가능
```

### 2.11 불리언 변수 명명과 사용 [CodeC]

불리언은 이름이 참/거짓을 드러내게 하고, 사용할 때도 `if (flag == true)`처럼 불리언 리터럴과 비교하지 말고 값 자체를 조건으로 쓴다.

```dart
// --- 나쁜 예: true/false가 불명확 ---
var status = true;
var sourceFile = true;

// --- 좋은 예: 이름 자체가 참/거짓을 암시 ---
var isValid = true;
var hasPermission = true;
var sourceFileFound = true;
var orderComplete = false;

// --- 나쁜 예: 부정형 이름 (이중 부정 발생) ---
var notFound = true;
if (!notFound) { // 혼란스럽다
  // ...
}

// --- 좋은 예: 긍정형 이름 사용 ---
var found = false;
if (found) {
  // ...
}
```

### 2.12 `num` 사용 회피 [CodeC]

```dart
// --- 나쁜 예: num의 의미가 모호 ---
var numCustomers = 5;   // 총 수? 인덱스?
var customerNum = 3;    // 총 수? 인덱스?

// --- 좋은 예: 명확한 이름 ---
var customerCount = 5;  // 총 수
var customerIndex = 3;  // 인덱스
```

### 2.13 루프 변수 명명 [CodeC]

```dart
// 허용: 짧은 루프에서 관례적 이름
for (var i = 0; i < 10; i++) {
  matrix[i] = 0;
}

// 좋은 예: 긴 루프나 중첩 루프에서는 의미 있는 이름
for (final (teamIndex, team) in teams.indexed) {
  for (final (playerIndex, player) in team.players.indexed) {
    scores[teamIndex][playerIndex] = player.score;
  }
}
```

---

## §3. 함수와 메서드 설계

### 3.1 함수는 작게, 모듈은 깊게 [CC] [APoSD]

**함수 수준**: 함수를 만드는 첫째 규칙은 "작게!"이고, 둘째 규칙도 "더 작게!"이다. 의미 있는 이름으로 다른 함수를 추출할 수 있다면, 그 함수는 여러 작업을 하고 있다. **[CC]**

**모듈/클래스 수준**: 최고의 모듈은 단순한 인터페이스 뒤에 강력한(큰) 기능을 숨기는 "깊은 모듈"이다. 과도하게 작은 함수/클래스는 "얕은 모듈"이 되어 인터페이스가 구현만큼 복잡해질 수 있다. **[APoSD]**

**통합 가이드라인**: 공개 인터페이스(모듈, 클래스)는 깊게 설계하되, 내부 구현은 작은 private 함수로 분해한다.

```dart
// --- 나쁜 예: 하나의 함수가 너무 많은 일을 한다 ---
String renderPage(PageData pageData, bool isSuite) {
  final isTestPage = pageData.hasAttribute('Test');
  if (isTestPage) {
    final testPage = pageData.wikiPage;
    var newContent = '';
    newContent += includeSetupPages(testPage, isSuite);
    newContent += pageData.content;
    newContent += includeTeardownPages(testPage, isSuite);
    pageData.content = newContent;
  }
  return pageData.html;
}

// --- 좋은 예: 작은 함수로 분해 (내부 구현) ---
String renderPage(PageData pageData, bool isSuite) {
  if (isTestPage(pageData)) {
    includeSetupAndTeardown(pageData, isSuite);
  }
  return pageData.html;
}
```

```dart
// --- 나쁜 예: 얕은 모듈 -- 인터페이스가 구현만큼 복잡 ---
class FileReader {
  void open(String path) { ... }
  bool checkPermissions(String path) { ... }
  List<int> readBytes(int offset, int length) { ... }
  String decode(List<int> data, String encoding) { ... }
  void close() { ... }
}

// 사용하려면 호출자가 5단계를 전부 알아야 한다
final reader = FileReader();
reader.open('data.txt');
if (reader.checkPermissions('data.txt')) {
  final raw = reader.readBytes(0, 1024);
  final text = reader.decode(raw, 'utf-8');
  reader.close();
}

// --- 좋은 예: 깊은 모듈 -- 단순한 인터페이스 뒤에 복잡성을 숨김 ---
import 'dart:convert';
import 'dart:io';

/// 파일을 읽어 텍스트로 반환한다. 권한, 인코딩, 리소스 정리를 내부에서 처리.
String readText(String path, {Encoding encoding = utf8}) =>
    File(path).readAsStringSync(encoding: encoding);

// 호출자는 한 줄이면 된다
final text = readText('data.txt');
```

### 3.2 한 가지만 해라 [CC] [IP]

> "함수는 한 가지를 해야 한다. 그 한 가지를 잘 해야 한다. 그 한 가지만을 해야 한다." **[CC]**

의미 있는 이름으로 다른 함수를 추출할 수 있다면, 그 함수는 여러 작업을 하고 있다.

### 3.3 추상화 수준은 하나로 [CC] [IP]

한 함수 내의 모든 문장은 동일한 추상화 수준이어야 한다.

```dart
// --- 나쁜 예 ---
void compute() {
  input();
  flags |= 0x0080; // 갑자기 추상화 수준이 바뀜
  output();
}

// --- 좋은 예 ---
void compute() {
  input();
  setLoadedFlag(); // 동일한 추상화 수준 유지
  output();
}
```

### 3.4 함수 인수는 최소로 [CC] [IP]

이상적인 인수 개수는 0개이다. 인수가 많으면 인수 객체를 만들어라.

```dart
// --- 나쁜 예 ---
Circle makeCircle(double x, double y, double radius) { ... }

// --- 좋은 예 ---
Circle makeCircle(Point center, double radius) { ... }
```

### 3.5 플래그 인수를 쓰지 마라 [CC]

플래그 인수는 함수가 여러 가지 일을 한다고 대놓고 선언하는 것이다.

```dart
// --- 나쁜 예 ---
void render(bool isSuite) { ... }

// --- 좋은 예 ---
void renderForSuite() { ... }
void renderForSingleTest() { ... }
```

### 3.6 명령과 조회를 분리하라 [CC]

함수는 무언가를 수행하거나 무언가에 답하거나 둘 중 하나만 해야 한다.

```dart
// --- 나쁜 예 ---
/// 속성을 설정하고 성공 여부를 반환
bool setAttribute(String name, String value) { ... }

if (setAttribute('username', 'alice')) { // 설정인가? 확인인가?
  // ...
}

// --- 좋은 예 ---
bool attributeExists(String name) { ... }
void setAttribute(String name, String value) { ... }

if (attributeExists('username')) {
  setAttribute('username', 'alice');
}
```

### 3.7 부수 효과를 일으키지 마라 [CC]

부수 효과는 시간적 결합(temporal coupling)이나 순서 종속성을 초래한다.

```dart
// --- 나쁜 예 ---
bool checkPassword(String username, String password) {
  final user = findUser(username);
  if (user != null && verify(user.encodedPhrase, password)) {
    session.initialize(); // 부수 효과! 이름에서 예측 불가
    return true;
  }
  return false;
}

// --- 좋은 예 ---
bool checkPassword(String username, String password) {
  final user = findUser(username);
  if (user == null) {
    return false;
  }
  return verify(user.encodedPhrase, password);
}

bool login(String username, String password) {
  if (checkPassword(username, password)) {
    session.initialize();
    return true;
  }
  return false;
}
```

### 3.8 대칭성을 활용하라 [IP]

코드의 대칭성을 찾아내서 명확히 표현하면 읽기 수월해진다.

```dart
// --- 나쁜 예 ---
void compute() {
  input();
  helper.process(this); // 비대칭적
  output();
}

// --- 좋은 예 ---
void compute() {
  input();
  process(); // 대칭적 -- 모두 this에게 메시지
  output();
}

void process() {
  helper.process(this);
}
```

### 3.9 고품질 루틴 설계 [CodeC]

#### 루틴을 만들어야 하는 이유

- 복잡성을 줄인다 (한 번에 한 가지에 집중)
- 이해하기 쉬운 추상화를 도입한다
- 코드 중복을 피한다
- 변경의 영향을 제한한다
- 코드를 숨긴다 (정보 은닉)

#### 루틴의 결정 횟수(Decision Count)

한 루틴의 결정 횟수가 **10을 초과**하면 재설계를 고려하라.

```dart
// --- 나쁜 예: 결정 횟수 과다 ---
void processOrder(Order order) {
  if (order.status == 'new') {
    if (order.paymentMethod == 'credit') {
      if (order.amount > 1000) {
        if (order.customer.isVip) {
          // ...
        }
      }
    }
  }
}

// --- 좋은 예: 전략 패턴 등으로 분해 ---
class OrderProcessor {
  late final Map<String, void Function(Order)> _statusHandlers = {
    'new': _handleNew,
    'pending': _handlePending,
  };

  void process(Order order) {
    final handler = _statusHandlers[order.status];
    if (handler == null) {
      throw ArgumentError('Unknown status: ${order.status}');
    }
    return handler(order);
  }
}
```

---

---

## §4. 주석과 문서화

> **통합 원칙**: 구현 주석(인라인 주석)은 최소화하되, 인터페이스 주석(문서 주석, 공개 API 문서)은 적극적으로 작성한다. **[CC] + [APoSD]**

### 4.1 구현 주석은 최소화하라 [CC] [IP]

> "주석은 코드로 의도를 표현하는 것에 실패했기 때문에 작성한다." **[CC]**

주석 대신 코드 자체로 의도를 표현해야 한다. 주석은 코드와 동기화가 깨지기 쉽고, 주석을 작성하고 일관성을 유지하는 비용을 정당화할 수 있는 경우에만 사용해야 한다. **[IP]**

```dart
// --- 나쁜 예 ---
// 직원에게 복지 혜택을 받을 자격이 있는지 검사한다
if ((employee.flags & hourlyFlag) != 0 && employee.age > 65) {
  // ...
}

// --- 좋은 예 ---
if (employee.isEligibleForFullBenefits) {
  // ...
}
```

### 4.2 인터페이스 주석은 필수로 작성하라 [APoSD]

Ousterhout은 "좋은 코드는 주석이 필요 없다"는 통념에 **반대**한다. 인터페이스 주석과 멤버 변수 주석은 짧게라도 반드시 작성해야 하며, 이는 복잡성을 줄이고 Unknown Unknowns를 방지하는 핵심 도구다.

- **인터페이스 주석**: 모듈의 전체적 동작, 인자, 반환값, 부작용, 예외를 문서화하라
- **구현 주석**: "무엇"이 아닌 "왜"를 설명하라
- **멤버 변수 주석**: 변수의 목적을 짧게라도 반드시 설명하라

```dart
// --- 나쁜 주석: 코드를 반복 (무엇) ---
count += 1; // count를 1 증가시킨다

// --- 좋은 주석: 이유를 설명 (왜) ---
count += 1; // 재시도 횟수를 추적하여 최대 3회 초과 시 중단하기 위함
```

### 4.3 계층별 주석 가이드라인 요약

| 계층 | 방침 | 근거 |
|------|------|------|
| **공개 API / 인터페이스** | 적극 작성 (문서 주석 필수) | 복잡성 감소, Unknown Unknowns 방지 **[APoSD]** |
| **내부 구현 (인라인)** | 최소화 ("왜"만 기록) | 코드 자체가 "무엇"을 설명해야 함 **[CC]** |
| **멤버 변수** | 짧게라도 필수 | 변수의 목적이 이름만으로 불충분할 때 **[APoSD]** |

### 4.4 유용한 주석의 유형 [CC]

- **법적인 주석** -- 저작권, 라이선스 정보
- **의도를 설명하는 주석** -- "왜" 이런 결정을 했는지
- **결과를 경고하는 주석** -- 스레드 안전성 경고 등
- **TODO 주석** -- 앞으로 할 일 (나쁜 코드의 핑계로 사용 금지)
- **중요성을 강조하는 주석** -- 대수롭지 않아 보이지만 중요한 것

### 4.5 나쁜 주석의 유형 [CC]

- 같은 이야기를 중복하는 주석
- 의무적으로 다는 주석
- 이력을 기록하는 주석 (소스 관리 시스템이 있다)
- 있으나 마나 한 주석 (당연한 사실 언급)
- 주석으로 처리한 코드 (그냥 삭제하라)

### 4.6 문서화와 주석은 다르다 [PC]

- **주석(comment)**: 가능한 한 적게. 코드 자체가 문서화되어야 한다.
- **문서 주석(doc comment)**: 컴포넌트의 동작 방식, 입출력 정보를 설명. "이유가 아니라 설명"이다.

### 4.7 문서 주석(doc comment) 작성법

문서 주석(doc comment)은 **무엇을** 문서화할지가 원칙이다 — 모듈/클래스/함수/스크립트의 동작·입출력·예외·호출 제약을 설명한다(§4.6). 구체 양식(`///` 삼중 슬래시 주석, 첫 문장 요약, `[식별자]` 참조 관례)과 Dart 작성 규칙은 Effective Dart의 문서화 가이드를 따른다.

---

## §5. 코드 형식과 구조

### 5.1 형식은 의사소통이다 [CC]

코드 형식은 의사소통의 일환이다. 구현 스타일과 가독성 수준은 유지보수 용이성과 확장성에 계속 영향을 미친다.

### 5.2 적절한 행 길이를 유지하라 [CC]

500줄이 넘지 않고 대부분 200줄 정도인 파일로도 커다란 시스템을 구축할 수 있다. **[CC]**

코드/주석의 구체적 줄 길이(line length) 수치는 `dart format` 포매터와 `analysis_options.yaml` 린트 설정으로 강제한다.

### 5.3 일관성이 핵심이다 [PC]

좋은 코드 레이아웃에서 가장 필요한 특성은 **일관성**이다. 코드가 일관되게 구조화되어 있으면 가독성이 높아지고 이해하기 쉬워진다.

### 5.4 자동화 도구를 활용하라 [PC]

포매팅, 린팅, 타입 검사를 자동화해야 한다. 이 모든 검사는 CI(지속적 통합)의 일부가 되어야 한다.

---

## §6. 추상화와 캡슐화

### 6.1 추상화를 통한 복잡성 극복 [OO]

> "현상은 복잡하다. 법칙은 단순하다. 버릴 게 무엇인지 알아내라." -- 파인만

추상화의 두 가지 방법:
1. 공통점을 취하고 차이점을 버리는 **일반화**
2. 불필요한 세부 사항을 제거하는 **단순화**

### 6.2 구현이 아니라 인터페이스에 맞춰 코딩하라 [IP] [OO]

> "설계상의 결정을 필요 이상으로 노출하지 말라" **[IP]**

```dart
// --- 나쁜 예 ---
class ReportGenerator {
  void generate(List<Object?> data) {
    final mysqlConn = MySqlConnection(); // 구체적 구현에 의존
    mysqlConn.save(data);
  }
}

// --- 좋은 예 ---
class ReportGenerator {
  ReportGenerator(this._storage);

  final StorageInterface _storage;

  void generate(List<Object?> data) {
    _storage.save(data); // 인터페이스에 의존
  }
}
```

### 6.3 상태를 캡슐화하라 [OO]

객체의 자율성은 내부와 외부를 명확하게 구분하는 것으로부터 나온다.

> "객체가 무엇(what)을 수행하는지는 알 수 있지만 어떻게(how) 수행하는지에 대해서는 알 수 없어야 한다." **[OO]**

```dart
// --- 나쁜 예 ---
class BankAccount {
  double balance = 0; // 외부에서 직접 수정 가능
}

final account = BankAccount();
account.balance = -1000; // 불변식 위반 가능

// --- 좋은 예 ---
class BankAccount {
  double _balance = 0;

  void deposit(double amount) {
    if (amount <= 0) {
      throw ArgumentError('입금액은 양수여야 합니다');
    }
    _balance += amount;
  }

  double get balance => _balance;
}
```

### 6.4 인터페이스와 구현의 분리 원칙 [OO]

> "객체를 구성하지만 공용 인터페이스에 포함되지 않는 모든 것이 구현에 포함된다." **[OO]**

객체 설계의 핵심은 외부에 공개되는 인터페이스와 내부에 감춰지는 구현을 명확하게 분리하는 것이다.

### 6.5 정보 은닉 (Information Hiding) [APoSD]

깊은 모듈을 달성하는 가장 중요한 기법이다. 설계 결정과 내부 정보를 인터페이스 뒤에 캡슐화하여 외부에 노출하지 않는다.

```dart
// --- 나쁜 예: Information Leakage (정보 누출) ---
// 두 모듈이 같은 파일 형식 지식을 공유한다
class CsvReader {
  List<List<String>> read(String path) {
    final lines = File(path).readAsLinesSync();
    return [for (final line in lines) line.trim().split(',')];
  }
}

class CsvWriter {
  void write(String path, List<List<String>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.write('${row.join(',')}\n');
    }
    File(path).writeAsStringSync(buffer.toString());
  }
}

// --- 좋은 예: 형식 지식을 한 모듈에 집중 ---
class CsvFormat {
  static const delimiter = ',';
  static const lineEnding = '\n';

  static List<String> parseRow(String line) =>
      line.trim().split(delimiter);

  static String formatRow(List<String> fields) =>
      '${fields.join(delimiter)}$lineEnding';
}
```

---

## §7. 깊은 모듈 설계 [APoSD]

### 7.1 깊은 모듈 vs 얕은 모듈

Ousterhout의 핵심 개념: 최고의 모듈은 강력한 기능을 제공하면서 단순한 인터페이스를 갖는다.

```
깊은 모듈 (Deep Module)        얕은 모듈 (Shallow Module)
┌─────────┐                    ┌─────────────────────────┐
│Interface│ <- 단순             │        Interface        │ <- 복잡
├─────────┤                    ├─────────────────────────┤
│         │                    │ Implementation          │ <- 단순
│ Impl.   │ <- 복잡 (숨김)      └─────────────────────────┘
│         │
│         │
└─────────┘
```

### 7.2 전략적 프로그래밍 vs 전술적 프로그래밍 [APoSD]

| 전술적 (Tactical) | 전략적 (Strategic) |
|-------------------|-------------------|
| "동작하면 된다, 다음 작업으로" | "훌륭한 설계를 만들자, 동작도 당연히 해야 한다" |
| 단기적 속도 | 장기적 생산성에 투자 |
| 복잡성 누적 -> 기능 추가 비용 증가 | 복잡성 통제 -> 지속적으로 빠른 기능 추가 |

**전술적 토네이도(Tactical Tornado)**: 다른 사람보다 훨씬 빠르게 코드를 쏟아내지만, 완전히 전술적(임기응변적)으로 작업하는 프로그래머. 그들이 남긴 코드는 다른 개발자가 유지보수해야 한다.

```dart
// 전술적 프로그래밍: "일단 돌아가게 만들자"
Object? handleRequest(Map<String, dynamic> req) {
  if (req['type'] == 'A') {
    final data = req['data'] ?? {};
    final result = (data['value'] ?? 0) * 2;
    if (req['format'] == 'json') {
      return {'result': result};
    }
    return result.toString();
  } else if (req['type'] == 'B') {
    final data = req['data'] ?? {};
    final result = (data['value'] ?? 0) * 3;
    if (req['format'] == 'json') {
      return {'result': result};
    }
    return result.toString();
  }
}

// 전략적 프로그래밍: 설계에 투자
abstract interface class RequestHandler {
  double compute(double value);
}

class TypeAHandler implements RequestHandler {
  TypeAHandler({this.multiplier = 2.0});

  final double multiplier;

  @override
  double compute(double value) => value * multiplier;
}

class TypeBHandler implements RequestHandler {
  TypeBHandler({this.multiplier = 3.0});

  final double multiplier;

  @override
  double compute(double value) => value * multiplier;
}

class RequestRouter {
  final Map<String, RequestHandler> _handlers = {
    'A': TypeAHandler(),
    'B': TypeBHandler(),
  };

  Object handle(Map<String, dynamic> req) {
    final handler = _handlers[req['type']];
    if (handler == null) {
      throw ArgumentError("Unknown type: ${req['type']}");
    }
    final num value = req['data']?['value'] ?? 0;
    final result = handler.compute(value.toDouble());
    if (req['format'] == 'json') {
      return {'result': result};
    }
    return result.toString();
  }
}
```

### 7.3 설계의 레드 플래그 [APoSD]

| 레드 플래그 | 설명 |
|------------|------|
| 얕은 모듈 | 인터페이스가 구현에 비해 지나치게 복잡 |
| 정보 누출 | 같은 지식이 여러 모듈에 분산 |
| 시간적 분해 | 실행 순서에 따라 모듈을 나눈 결과 정보가 분산 |
| 과도한 노출 | 내부 구현이 API에 불필요하게 드러남 |
| Pass-through 메서드 | 거의 아무것도 하지 않고 다른 메서드를 호출만 하는 메서드 |
| Pass-through 변수 | 긴 호출 체인을 통해 전달만 되는 변수 |

---

---

## §8. 객체 설계 원칙

### 8.1 행동이 상태를 결정한다 [OO]

상태를 먼저 결정하고 행동을 나중에 결정하면 설계에 나쁜 영향을 끼친다.

> "어떤 객체가 어떤 타입에 속하는지를 결정하는 것은 객체가 수행하는 행동이다." **[OO]**

```dart
// --- 나쁜 예: 데이터 주도 설계 ---
class Employee {
  String name = '';
  int salary = 0;
  String department = '';
  // 데이터를 먼저 정의하고 행동은 나중에...
}

// --- 좋은 예: 책임 주도 설계 ---
abstract class Employee {
  Money calculatePay();
  Hours reportHours();
  // 행동을 먼저 정의하고 필요한 데이터는 내부에 캡슐화
}
```

### 8.2 묻지 말고 시켜라 (Tell, Don't Ask) [OO]

어떻게 해야 하는지 묻지 말고 무엇을 해야 하는지 요청하라.

```dart
// --- 나쁜 예: 물어보고 직접 처리 ---
if (order.status == 'paid') {
  order.status = 'shipped';
  warehouse.removeStock(order.items);
}

// --- 좋은 예: 시키기 ---
order.ship(warehouse); // 주문 객체가 자율적으로 처리
```

### 8.3 조건문을 다형성으로 대체하라 [CC] [IP]

중복되는 조건부 로직이나 분기문의 결과에 따라 로직이 달라지는 경우, 명시적인 조건문 대신 메시지(다형성)를 사용하는 것이 좋다.

```dart
// --- 나쁜 예 ---
Money calculatePay(Employee employee) {
  if (employee.type == 'COMMISSIONED') {
    return calculateCommissionedPay(employee);
  } else if (employee.type == 'HOURLY') {
    return calculateHourlyPay(employee);
  } else if (employee.type == 'SALARIED') {
    return calculateSalariedPay(employee);
  }
  throw ArgumentError('알 수 없는 employee.type: ${employee.type}');
}

// --- 좋은 예 ---
abstract class Employee {
  Money calculatePay();
}

class CommissionedEmployee extends Employee {
  @override
  Money calculatePay() { /* ... */ }
}

class HourlyEmployee extends Employee {
  @override
  Money calculatePay() { /* ... */ }
}

class SalariedEmployee extends Employee {
  @override
  Money calculatePay() { /* ... */ }
}
```

### 8.4 위임으로 유연성 확보 [IP]

하위클래스는 정적(생성 시점 결정)이지만 위임은 런타임에 변경 가능하다.

```dart
// --- 나쁜 예: 조건문으로 도구 분기 ---
void mouseDown() {
  if (tool == 'SELECTING') {
    // ...
  } else if (tool == 'CREATING_RECTANGLE') {
    // ...
  }
}

// --- 좋은 예: 위임 ---
void mouseDown() {
  tool.mouseDown(); // 도구 객체에 위임
}
```

### 8.5 로직과 데이터를 함께 유지하라 [IP]

데이터와 그 데이터를 처리하는 로직을 밀접하게, 가급적 같은 메서드 혹은 같은 객체 내에 배치하라.

```dart
// --- 나쁜 예 ---
String formatAddress(String street, String city, String state, String zipcode) {
  return '$street, $city, $state $zipcode';
}

// --- 좋은 예 ---
class Address {
  Address(this.street, this.city, this.state, this.zipcode);

  final String street;
  final String city;
  final String state;
  final String zipcode;

  String format() => '$street, $city, $state $zipcode';
}
```

### 8.6 변화율에 따라 분리하라 [IP]

함께 변하는 로직과 데이터는 함께 관리하고, 변화율이 다른 것은 분리한다.

```dart
// --- 나쁜 예 ---
class Payment {
  Payment(this.value, this.currency);

  final num value;
  final String currency; // value와 currency는 항상 함께 변한다
}

// --- 좋은 예 ---
class Money {
  Money(this.value, this.currency);

  final num value;
  final String currency;
}

class Payment {
  Payment(this.amount);

  final Money amount; // 대칭적인 필드를 별도 객체로 분리
}
```

---

## §9. SOLID 원칙

### 9.1 단일 책임 원칙 (SRP) [PC] [CC]

클래스는 하나의 책임만 가져야 하며, 변경 이유도 단 하나여야 한다.

```dart
// --- 나쁜 예 ---
class SystemMonitor {
  void loadActivity() { /* ... */ }
  void identifyEvents() { /* ... */ }
  void streamEvents() { /* ... */ } // 세 가지 독립적 책임
}

// --- 좋은 예 ---
class ActivityLoader { /* ... */ }
class EventIdentifier { /* ... */ }
class EventStreamer { /* ... */ }
```

> "만약 객체의 속성이나 메서드의 특성이 다른 클래스에서 발견되면 이들을 다른 곳으로 옮겨야 한다." **[PC]**

#### Flutter/dddart 경계에서의 책임 분리

UI 프레임워크 코드는 도메인 규칙, 입출력 변환, 저장소 접근, 렌더링, 권한/인증, 상태 전이가 한 함수나 클래스에 모이기 쉽다. 이때 파일 이름이나 계층 이름보다 **변경 이유**가 우선 판단 기준이다.

| 스멜 | 증상 | 클린 코드 관점의 판단 |
|------|------|-----------------------|
| **Fat Model** | model 클래스가 직렬화/저장소 매핑, 도메인 상태 전이, 외부 알림, 결제/재고/권한 정책, 조회 포맷까지 모두 처리한다 | 데이터와 불변식을 가까이 두는 것은 좋지만, 외부 I/O나 유스케이스 흐름까지 model에 넣으면 변경 이유가 섞인다. |
| **Fat Widget / Fat Controller** | widget의 build 메서드나 controller/notifier가 입력 이벤트 처리 뒤 권한, 상태 전이, 계산, 저장, 알림, 화면 갱신을 긴 절차로 모두 수행한다 | framework entrypoint는 얇게 유지하고, 의도 있는 application/service 함수나 도메인 객체에 정책을 맡긴다. |
| **Fat DTO / Mapper** | DTO나 fromJson/toJson 매퍼가 validation을 넘어 주문 상태 변경, 가격 계산, DB 조회, 외부 호출을 수행한다 | 입출력 계약과 도메인 정책이 섞여 테스트와 재사용이 어려워진다. |
| **Build-method business logic** | build 메서드, 공용 widget, builder 콜백에서 권한/상태/가격 정책을 직접 계산한다 | 렌더링 관심사가 도메인 규칙을 숨기면 변경 누락과 중복이 커진다. |
| **Service dumping ground** | 모든 로직을 `services.dart`로 옮겼지만 함수들이 서로 다른 정책과 I/O를 공유 전역처럼 사용한다 | 이름만 service인 얕은 모듈은 책임 분리가 아니다. 유스케이스, 도메인 규칙, 조회, 외부 연동의 변경 이유를 다시 나눠야 한다. |

다만 모든 model method가 Fat Model인 것은 아니다. 단일 엔티티의 불변식, 상태 질의, 표현 독립적인 작은 행위는 model이나 값 객체에 두는 편이 더 응집도 높을 수 있다. 반대로 설계 결정이 먼저 필요한 문제는 클린 코드 스멜로만 처리하지 않고 소유 스킬로 라우팅한다 — 애그리거트 경계·판정 소유는 architecture-ddd §4·§5, 서버 계약·Either는 architecture-data §3·§7, 상태·에러 표시는 architecture-state §4.

### 9.2 개방/폐쇄 원칙 (OCP) [PC] [CC]

확장에는 개방되고 수정에는 폐쇄되어야 한다. 새로운 요구사항이 생기면 새로운 것을 추가만 할 뿐 기존 코드는 그대로 유지해야 한다.

```dart
// --- 나쁜 예 ---
class SystemMonitor {
  SystemMonitor(this.eventData);

  final Map<String, dynamic> eventData;

  Event identifyEvent() {
    if (eventData['before']['session'] == 0 &&
        eventData['after']['session'] == 1) {
      return LoginEvent(eventData);
    }
    // 새 이벤트마다 이 메서드를 수정해야 한다
    return UnknownEvent(eventData);
  }
}

// --- 좋은 예 ---
abstract class Event {
  Event(this.eventData);

  final Map<String, dynamic> eventData;
}

class LoginEvent extends Event {
  LoginEvent(super.eventData);

  static bool meetsCondition(Map<String, dynamic> eventData) =>
      eventData['before']['session'] == 0 &&
      eventData['after']['session'] == 1;
}

class UnknownEvent extends Event {
  UnknownEvent(super.eventData);
}

class SystemMonitor {
  SystemMonitor(this.eventData);

  final Map<String, dynamic> eventData;

  // Dart에는 서브클래스를 런타임에 열거하는 리플렉션이 없으므로
  // (판별 조건, 생성자) 쌍을 명시적으로 등록한다.
  // 새 이벤트 타입이 생겨도 identifyEvent 본문은 수정하지 않는다.
  static final _eventTypes = <(
    bool Function(Map<String, dynamic>),
    Event Function(Map<String, dynamic>),
  )>[
    (LoginEvent.meetsCondition, LoginEvent.new),
    // 새 이벤트 타입은 여기에 등록만 한다
  ];

  Event identifyEvent() {
    for (final (meetsCondition, create) in _eventTypes) {
      if (meetsCondition(eventData)) {
        return create(eventData);
      }
    }
    return UnknownEvent(eventData);
  }
}
```

### 9.3 리스코프 치환 원칙 (LSP) [PC] [OO]

하위 클래스는 부모 클래스를 대체할 수 있어야 한다. 클라이언트는 사용하는 클래스의 계층 구조 변경에 대해 완전히 독립적이어야 한다.

```dart
// --- 나쁜 예: LSP 위반 ---
class Event {
  bool meetsCondition(Map<String, dynamic> eventData) => false;
}

class LoginEvent extends Event {
  @override
  bool meetsCondition(dynamic eventData) => // 파라미터 타입 변경!
      (eventData as List).isNotEmpty; // 부모 계약(Map)과 달리 List를 요구한다
}

// --- 좋은 예 ---
class LoginEvent extends Event {
  @override
  bool meetsCondition(Map<String, dynamic> eventData) => // 부모와 동일한 서명
      eventData['after']?['session'] == 1;
}
```

### 9.4 인터페이스 분리 원칙 (ISP) [PC]

작은 인터페이스를 만들어라. 클라이언트가 필요하지 않은 메서드를 구현하도록 강제하지 마라.

```dart
// --- 나쁜 예 ---
abstract class EventParser {
  Event fromXml(String xml);
  Event fromJson(String json); // 어떤 클래스는 둘 중 하나만 필요할 수 있다
}

// --- 좋은 예 ---
abstract class XmlEventParser {
  Event fromXml(String xml);
}

abstract class JsonEventParser {
  Event fromJson(String json);
}
```

### 9.5 의존성 역전 원칙 (DIP) [PC]

> **dddart 단서**: 아래 DIP 일반론은 원전 이론 보존이다 — dddart는 **DI 없음·직접 생성이 확정**이다(UseCase·Repo·DataSource는 사용처가 직접 생성 — architecture-ddd §10 비채택 표). "구체 클래스 직접 의존"을 나쁜 예로 읽지 말고, 변동 축이 실재할 때의 추상화 경계 사고법으로만 읽는다.

구체적 구현이 아닌 추상화에 의존하라. 세부 사항은 추상화에 의존해야 한다.

```dart
// --- 나쁜 예 ---
class EventStreamer {
  final Syslog _target = Syslog(); // 구체 클래스에 직접 의존
}

// --- 좋은 예 ---
class EventStreamer {
  EventStreamer(this._target); // 인터페이스에 의존

  final DataTargetClient _target;

  void stream(List<Event> events) {
    for (final event in events) {
      _target.send(event.serialize());
    }
  }
}
```

> "일반적으로 구체적인 구현이 추상 컴포넌트보다 훨씬 더 자주 바뀔 것이다. 이런 이유로 추상화를 사용한다." **[PC]**

---

---

## §10. 디자인 패턴

범용 GoF/Kent Beck 패턴의 핵심 개념과 구조를 다룬다. 원칙 자체는 언어 비종속적이며, 코드 예시는 Dart로 작성되었다.

### 10.1 팩토리 메서드 (Factory Method) [GoF]

객체 생성을 서브클래스에 위임하여, 생성할 구체 클래스를 결정하는 코드와 사용하는 코드를 분리한다. OCP(개방/폐쇄 원칙)를 준수하여 새로운 타입 추가 시 기존 코드를 수정하지 않는다.

```dart
// --- 나쁜 예: 생성 로직이 조건문에 직접 묶임 ---
class NotificationService {
  void send(String type, String message) {
    if (type == 'email') {
      print('Email: $message');
    } else if (type == 'sms') {
      print('SMS: $message');
    }
    // 새 타입 추가마다 이 메서드를 수정해야 한다
  }
}

// --- 좋은 예: 팩토리 메서드로 생성 위임 ---
abstract interface class Notification {
  void send(String message);
}

class EmailNotification implements Notification {
  @override
  void send(String message) => print('Email: $message');
}

class SmsNotification implements Notification {
  @override
  void send(String message) => print('SMS: $message');
}

abstract interface class NotificationFactory {
  Notification create();
}

class EmailFactory implements NotificationFactory {
  @override
  Notification create() => EmailNotification();
}

class SmsFactory implements NotificationFactory {
  @override
  Notification create() => SmsNotification();
}

// 사용: 새 타입은 새 Factory 서브클래스만 추가
void notify(NotificationFactory factory, String message) {
  final notification = factory.create();
  notification.send(message);
}
```

### 10.2 추상 팩토리 (Abstract Factory) [GoF]

연관된 객체군을 구상 클래스 이름 없이 생성한다. 상속보다 구성(composition)을 선호하며, 제품군 전체를 일관되게 교체할 수 있다.

```dart
// --- 나쁜 예: 구상 클래스에 직접 의존 ---
class Application {
  final button = WindowsButton(); // OS 교체 시 전부 수정
  final checkbox = WindowsCheckbox();
}

// --- 좋은 예: 추상 팩토리로 제품군 생성 ---
abstract interface class Button {
  String render();
}

abstract interface class Checkbox {
  String render();
}

abstract interface class GuiFactory {
  Button createButton();
  Checkbox createCheckbox();
}

class WindowsButton implements Button {
  @override
  String render() => '<win-btn/>';
}

class WindowsCheckbox implements Checkbox {
  @override
  String render() => '<win-chk/>';
}

class WindowsFactory implements GuiFactory {
  @override
  Button createButton() => WindowsButton();

  @override
  Checkbox createCheckbox() => WindowsCheckbox();
}

class MacFactory implements GuiFactory {
  @override
  Button createButton() => MacButton();

  @override
  Checkbox createCheckbox() => MacCheckbox();
}

// 사용: 팩토리만 교체하면 제품군 전체가 바뀜
class Application {
  Application(GuiFactory factory)
      : button = factory.createButton(),
        checkbox = factory.createCheckbox();

  final Button button;
  final Checkbox checkbox;
}
```

### 10.3 값 객체 (Value Object) [Kent Beck]

불변이며 동등성(equality)으로 비교하는 객체다. 별칭(aliasing) 문제를 원천 차단하고, 도메인 개념을 명확하게 표현한다.

```dart
// --- 나쁜 예: 원시 타입으로 도메인 개념 표현 ---
var price = 1000;     // 통화 정보 없음, 음수 가능, 별칭 문제
var currency = 'KRW'; // price와 currency의 관계가 암묵적

// --- 좋은 예: 값 객체로 도메인 개념 캡슐화 ---
class Money {
  Money(this.amount, this.currency) {
    if (amount < 0) {
      throw ArgumentError('금액은 음수일 수 없다');
    }
  }

  final int amount;
  final String currency;

  Money add(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('통화가 다르면 합산할 수 없다');
    }
    return Money(amount + other.amount, currency);
  }

  // 값 객체는 동등성으로 비교한다 (불변 데이터 모델이면 freezed로 자동 생성 가능)
  @override
  bool operator ==(Object other) =>
      other is Money && amount == other.amount && currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, currency);
}

// 불변: 한번 생성하면 변경 불가, 별칭 문제 없음
final price = Money(1000, 'KRW');
final total = price.add(Money(500, 'KRW')); // Money(1500, 'KRW')
```

### 10.4 널 객체 (Null Object) [Kent Beck]

null 검사를 반복하는 대신, 아무 일도 하지 않는 객체를 사용한다. 다형성을 활용하여 조건문을 제거하고 코드 흐름을 단순화한다.

```dart
// --- 나쁜 예: null 검사가 곳곳에 산재 ---
class UserService {
  Logger? _logger;

  Logger? getLogger() => _logger;

  void process() {
    final logger = getLogger();
    if (logger != null) {      // 매번 null 검사
      logger.info('처리 시작');
    }
    _doWork();
    if (logger != null) {      // 또 null 검사
      logger.info('처리 완료');
    }
  }
}

// --- 좋은 예: 널 객체로 null 검사 제거 ---
/// 아무 일도 하지 않는 로거.
class NullLogger implements Logger {
  @override
  void info(String msg) {}

  @override
  void error(String msg) {}
}

class UserService {
  UserService({Logger? logger}) : _logger = logger ?? NullLogger();

  final Logger _logger;

  void process() {
    _logger.info('처리 시작'); // null 검사 불필요
    _doWork();
    _logger.info('처리 완료'); // 항상 안전하게 호출
  }
}
```

### 10.5 전략 패턴 (Strategy) [GoF]

알고리즘을 캡슐화하여 런타임에 교체할 수 있게 한다. 조건문(if/else if 체인)을 다형성으로 대체하며, 새로운 전략 추가 시 기존 코드를 수정하지 않는다.

```dart
// --- 나쁜 예: 조건문으로 알고리즘 분기 ---
int calculateDiscount(int price, String method) {
  if (method == 'fixed') {
    return price - 1000;
  } else if (method == 'percent') {
    return (price * 0.9).toInt();
  } else if (method == 'vip') {
    return (price * 0.8).toInt();
  }
  // 새 할인 방식마다 이 함수를 수정해야 한다
  throw ArgumentError('지원하지 않는 할인 방식: $method');
}

// --- 좋은 예: 전략 패턴으로 알고리즘 캡슐화 ---
abstract interface class DiscountStrategy {
  int apply(int price);
}

class FixedDiscount implements DiscountStrategy {
  FixedDiscount({this.amount = 1000});

  final int amount;

  @override
  int apply(int price) => price - amount;
}

class PercentDiscount implements DiscountStrategy {
  PercentDiscount({this.rate = 0.1});

  final double rate;

  @override
  int apply(int price) => (price * (1 - rate)).toInt();
}

// 사용: 전략 객체만 교체
int calculateDiscount(int price, DiscountStrategy strategy) =>
    strategy.apply(price);

final finalPrice = calculateDiscount(10000, PercentDiscount(rate: 0.2));
```

### 10.6 옵저버 패턴 (Observer) [GoF]

객체의 상태 변경을 관찰자들에게 자동으로 통보한다. 발행자와 구독자를 느슨하게 결합하여, 서로의 구체적인 구현을 알 필요 없이 협력한다.

```dart
// --- 나쁜 예: 직접 호출로 강한 결합 ---
class Order {
  String _status = 'pending';

  void complete() {
    _status = 'completed';
    EmailService().sendConfirmation(this);  // 직접 의존
    InventoryService().updateStock(this);   // 직접 의존
    AnalyticsService().trackPurchase(this); // 새 서비스마다 수정
  }
}

// --- 좋은 예: 옵저버 패턴으로 느슨한 결합 ---
abstract interface class OrderObserver {
  void onOrderCompleted(Order order);
}

class Order {
  final List<OrderObserver> _observers = [];
  String _status = 'pending';

  void addObserver(OrderObserver observer) {
    _observers.add(observer);
  }

  void complete() {
    _status = 'completed';
    for (final observer in _observers) {
      observer.onOrderCompleted(this);
    }
  }
}

class EmailNotifier implements OrderObserver {
  @override
  void onOrderCompleted(Order order) {
    print('확인 메일 발송: $order');
  }
}

class StockUpdater implements OrderObserver {
  @override
  void onOrderCompleted(Order order) {
    print('재고 갱신: $order');
  }
}

// 사용: 옵저버 추가/제거만으로 기능 확장
final order = Order();
order.addObserver(EmailNotifier());
order.addObserver(StockUpdater());
order.complete();
```

### 10.7 템플릿 메서드 (Template Method) [GoF] [Kent Beck]

알고리즘의 전체 순서(골격)를 상위 클래스에서 고정하고, 각 단계의 구체적 구현은 하위 클래스에서 정의한다. 공통 흐름의 중복을 제거하면서 세부 동작을 유연하게 변경할 수 있다.

```dart
import 'dart:convert';

// --- 나쁜 예: 흐름이 각 클래스에 중복 ---
class CsvExporter {
  String export(List<Map<String, Object?>> data) {
    final header = data.first.keys.join(',');         // 1) 헤더
    final rows = data.map((d) => d.values.join(',')); // 2) 본문
    return '$header\n${rows.join('\n')}';             // 3) 조립
  }
}

class JsonExporter {
  String export(List<Map<String, Object?>> data) {
    final header = '';             // 1) 헤더 (불필요하지만 흐름 중복)
    final body = jsonEncode(data); // 2) 본문
    return body;                   // 3) 조립
  }
}

// --- 좋은 예: 템플릿 메서드로 흐름 고정 ---
abstract class DataExporter {
  /// 알고리즘 골격: 순서를 고정한다.
  String export(List<Map<String, Object?>> data) {
    final header = buildHeader(data);
    final body = buildBody(data);
    return assemble(header, body);
  }

  String buildHeader(List<Map<String, Object?>> data);

  String buildBody(List<Map<String, Object?>> data);

  /// 기본 조립: 하위 클래스에서 재정의 가능.
  String assemble(String header, String body) =>
      header.isNotEmpty ? '$header\n$body' : body;
}

class CsvExporter extends DataExporter {
  @override
  String buildHeader(List<Map<String, Object?>> data) =>
      data.first.keys.join(',');

  @override
  String buildBody(List<Map<String, Object?>> data) =>
      data.map((d) => d.values.join(',')).join('\n');
}

class JsonExporter extends DataExporter {
  @override
  String buildHeader(List<Map<String, Object?>> data) => '';

  @override
  String buildBody(List<Map<String, Object?>> data) => jsonEncode(data);
}
```

### 10.8 플러거블 객체 (Pluggable Object) [Kent Beck]

동일한 조건문이 두 번 이상 반복되면, 조건 분기를 객체로 대체한다. 조건을 생성 시점에 한 번만 결정하고 이후에는 다형성으로 해결한다.

```dart
// --- 나쁜 예: 같은 조건문이 여러 곳에 반복 ---
class GraphEditor {
  GraphEditor(this.mode);

  final String mode;

  void onMouseDown(int x, int y) {
    if (mode == 'select') {
      _startSelection(x, y);
    } else if (mode == 'draw') {
      _startDrawing(x, y);
    }
  }

  void onMouseUp(int x, int y) {
    if (mode == 'select') {       // 같은 조건 반복!
      _finishSelection(x, y);
    } else if (mode == 'draw') {  // 같은 조건 반복!
      _finishDrawing(x, y);
    }
  }
}

// --- 좋은 예: 플러거블 객체로 조건문 제거 ---
abstract interface class Tool {
  void onMouseDown(int x, int y);
  void onMouseUp(int x, int y);
}

class SelectionTool implements Tool {
  @override
  void onMouseDown(int x, int y) {
    print('선택 시작: ($x, $y)');
  }

  @override
  void onMouseUp(int x, int y) {
    print('선택 완료: ($x, $y)');
  }
}

class DrawingTool implements Tool {
  @override
  void onMouseDown(int x, int y) {
    print('그리기 시작: ($x, $y)');
  }

  @override
  void onMouseUp(int x, int y) {
    print('그리기 완료: ($x, $y)');
  }
}

class GraphEditor {
  GraphEditor(this._tool); // 조건을 생성 시점에 한 번만 결정

  final Tool _tool;

  void onMouseDown(int x, int y) => _tool.onMouseDown(x, y); // 조건문 없음

  void onMouseUp(int x, int y) => _tool.onMouseUp(x, y);     // 조건문 없음
}
```

> Dart 고유 구현 트릭은 implementation-dart §2(Effective Dart 선별)·§6(Dart 3 문법)을 참조한다.

---

## §11. 상태 관리

### 11.1 변수의 범위와 생명주기를 일치시켜라 [IP] [CodeC]

변수의 범위와 생명기간은 가까운 것이 좋다. 같은 범위에서 정의된 변수들은 같은 생명기간을 갖는 것이 좋다. **[IP]**

**변수의 "생존 시간(live time)"을 최소화**하라. 변수가 선언된 후 마지막으로 참조되기까지의 거리가 짧을수록 좋다. **[CodeC]**

```dart
// --- 나쁜 예 ---
Object? result; // 훨씬 나중에 사용될 변수를 미리 선언
// ... 100줄의 코드 ...
result = compute();

// --- 좋은 예 ---
// ... 100줄의 코드 ...
final result = compute(); // 사용 직전에 선언
```

### 11.2 값 객체를 활용하라 [IP] [OO]

변치 않는 값을 표현할 때는 값 객체를 사용하라. 생성 후 상태가 변경되지 않아야 한다.

```dart
// --- 나쁜 예: 가변 상태 ---
class Transaction {
  Transaction(this.value);

  int value; // 외부에서 변경 가능
}

// --- 좋은 예: 값 객체 ---
class Transaction {
  const Transaction({
    required this.value,
    required this.creditAccount,
    required this.debitAccount,
  });

  final int value;
  final String creditAccount;
  final String debitAccount;
  // final 필드와 const 생성자로 불변 보장 (데이터 모델이면 freezed 활용 가능)
}
```

### 11.3 상태 접근은 간접 접근을 기본으로 [IP]

내부에서는 직접 접근을 허용하되, 외부에서는 메서드를 통해 접근하라.

```dart
// --- 나쁜 예 ---
class Rectangle {
  int width = 0;
  int height = 0;
  int area = 0; // width/height와 의존 관계인데 직접 접근
}

// --- 좋은 예 ---
class Rectangle {
  Rectangle(this._width, this._height);

  final int _width;
  final int _height;

  int get area => _width * _height;
}
```

### 11.4 공용 상태 vs 가변 상태 [IP]

- **공용 상태**: 여러 연산에서 같은 데이터를 사용하는 경우 필드로 선언
- **가변 상태**: 인스턴스마다 전혀 다른 데이터 요소가 필요한 경우에만 맵으로 표현
- 가능하다면 공용 상태를 사용하는 것이 좋다

---

---

## §12. 오류 처리

> **통합 원칙**: 오류 처리는 두 단계로 접근한다. **1순위**: 오류 조건 자체를 설계에서 제거한다 **[APoSD]**. **2순위**: 설계로 제거할 수 없는 오류는 예외와 계약(DbC)으로 처리한다 **[CC] [PC]**.

### 12.1 1순위: 오류를 존재에서 제거하라 [APoSD]

예외 처리는 소프트웨어 시스템에서 **가장 큰 복잡성 원천 중 하나**다. 가능하다면 오류 조건 자체를 설계적으로 제거하라.

```dart
// --- 나쁜 예: 오류 조건이 불필요하게 존재 ---
class TextBuffer {
  void deleteSelection() {
    if (!hasSelection()) {
      throw NoSelectionException('Nothing is selected');
    }
    // ... 삭제 로직
  }
}

// --- 좋은 예: 오류를 존재에서 제거 ---
class TextBuffer {
  /// 현재 선택 영역을 삭제한다. 선택이 없으면 아무것도 하지 않는다.
  void deleteSelection() {
    if (!hasSelection()) {
      return; // 예외 대신 정상 흐름으로 처리
    }
    // ... 삭제 로직
  }
}
```

### 12.2 2순위: 오류 코드보다 예외를 사용하라 [CC]

오류 코드를 반환하면 호출자는 오류 코드를 곧바로 처리해야 하고, 명령/조회 분리 규칙을 위반한다.

```dart
// --- 나쁜 예 ---
var result = deletePage(page);
if (result == ErrorCode.ok) {
  result = registry.deleteReference(page.name);
  if (result == ErrorCode.ok) {
    // ...
  }
}

// --- 좋은 예 ---
try {
  deletePage(page);
  registry.deleteReference(page.name);
  configKeys.deleteKey(page.name.makeKey());
} on Exception catch (e) {
  logger.error(e);
}
```

### 12.3 Try/Catch 블록은 분리하라 [CC]

정상 동작과 오류 처리 동작을 분리하면 이해하고 수정하기 쉬워진다.

```dart
// --- 좋은 예 ---
void delete(Page page) {
  try {
    deletePageAndAllReferences(page);
  } on Exception catch (e) {
    logError(e);
  }
}

void deletePageAndAllReferences(Page page) {
  deletePage(page);
  registry.deleteReference(page.name);
  configKeys.deleteKey(page.name.makeKey());
}
```

### 12.4 올바른 추상화 수준에서 예외를 처리하라 [PC]

예외는 함수가 캡슐화하고 있는 로직에 대한 것이어야 한다. 서로 다른 수준의 추상화를 혼합하지 마라.

### 12.5 보호절(Guard Clause)을 활용하라 [IP]

주요 흐름과 예외 흐름의 차이를 부각시켜라.

```dart
// --- 나쁜 예 ---
void compute() {
  final server = getServer();
  if (server != null) {
    final client = server.getClient();
    if (client != null) {
      final request = client.getRequest();
      if (request != null) {
        processRequest(request);
      }
    }
  }
}

// --- 좋은 예 ---
void compute() {
  final server = getServer();
  if (server == null) return;
  final client = server.getClient();
  if (client == null) return;
  final request = client.getRequest();
  if (request == null) return;
  processRequest(request);
}
```

### 12.6 계약에 의한 디자인 (DbC) [PC]

사전조건과 사후조건을 명시적으로 정의하여 책임 소재를 명확히 하라.

```dart
/// 양수 두 개를 더한다.
double addPositiveNumbers(double a, double b) {
  if (a <= 0 || b <= 0) {
    throw ArgumentError('입력 값은 양수여야 합니다'); // 사전 조건
  }

  final result = a + b;

  assert(result > 0, '결과 값은 양수여야 합니다'); // 사후 조건
  return result;
}
```

### 12.7 방어적 프로그래밍 [CodeC]

잘못된 입력으로부터 프로그램을 보호하라. "외부"를 어디로 정할지 결정하고, 그 경계에서 데이터를 검증하라. 예외는 구체적으로 잡는다 — 모든 예외를 무차별로 삼키면(`on` 절 없는 catch/광범위 catch) 버그가 가려지므로, 실제로 처리할 수 있는 구체적 예외 유형만 명시한다.

#### 단언(Assertion) vs 오류 처리

| 상황 | 기법 |
|------|------|
| 절대 발생해서는 안 되는 조건 | `assert` 사용 |
| 발생할 수 있는 예상된 조건 | 오류 처리 코드 사용 |
| 고신뢰성이 필요한 코드 | 둘 다 사용 |

```dart
// Assertion: 개발 중 논리 오류 탐지
double calculateDiscount(double price, double rate) {
  assert(rate >= 0.0 && rate <= 1.0, 'Discount rate must be 0-1, got $rate');
  assert(price >= 0, 'Price must be non-negative, got $price');
  return price * (1 - rate);
}

// 오류 처리: 외부 입력 검증
double parseUserInput(String rawRate) {
  final rate = double.tryParse(rawRate);
  if (rate == null) {
    throw InvalidInputException("'$rawRate' is not a valid number");
  }
  if (rate < 0.0 || rate > 1.0) {
    throw InvalidInputException('Rate must be between 0 and 1, got $rate');
  }
  return rate;
}
```

#### 정확성(Correctness) vs 견고성(Robustness)

- **정확성**: 부정확한 결과를 절대 반환하지 않는다 (안전 필수 시스템)
- **견고성**: 소프트웨어가 계속 작동하도록 최선을 다한다 (소비자 앱)

```dart
// 정확성 우선 (안전 필수 시스템)
double calculateMedicationDose(double weightKg, double dosagePerKg) {
  if (weightKg <= 0 || dosagePerKg <= 0) {
    throw CriticalError('Invalid medication calculation parameters');
  }
  final dose = weightKg * dosagePerKg;
  if (dose > maxSafeDose) {
    throw CriticalError('Dose ${dose}mg exceeds safety limit');
  }
  return dose;
}

// 견고성 우선 (소비자 앱)
Map<String, dynamic> loadUserPreferences(String path) {
  try {
    return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  } on FileSystemException {
    return defaultPreferences; // 기본값으로 계속 동작
  } on FormatException {
    return defaultPreferences;
  }
}
```

> **침묵 폴백과의 경계**: 위 "견고성 우선" 폴백이 합법인 것은 **의도가 명시된 설계 결정**(기본 설정으로 계속 동작)이기 때문이다 — 잡은 예외를 아무 표시 없이 빈 값으로 바꿔 실패 자체를 숨기는 침묵 폴백과 다르다. dddart에서 서버 호출 실패는 폴백이 아니라 Either로 운반한다(실패 쪽을 버리는 코드 금지 — architecture-data §3).

---

## §13. 중복 제거와 DRY

### 13.1 DRY는 지식의 중복을 금지하는 것이다 [PP]

> "모든 지식은 시스템 안에서 단일하고 모호하지 않은 권위 있는 표현을 가져야 한다." **[PP]**

DRY는 단순한 코드 중복 금지가 아니다. **지식의 중복**을 금지하는 것이다. 같은 코드라도 서로 다른 지식을 표현한다면 중복이 아닐 수 있고, 다른 코드라도 같은 지식을 표현한다면 DRY 위반이다.

```dart
// DRY 위반: 같은 검증 지식이 두 곳에
class UserValidator {
  bool validateAge(int age) => 0 < age && age < 150;
}

class UserForm {
  bool isValidAge(int age) => age > 0 && age < 150; // 같은 규칙의 다른 표현
}

// DRY 준수: 검증 규칙의 단일 소스
class AgePolicy {
  static const minAge = 0;
  static const maxAge = 150;

  static bool isValid(int age) => age > minAge && age < maxAge;
}

class UserValidator {
  bool validateAge(int age) => AgePolicy.isValid(age);
}
```

```dart
// DRY가 아닌 경우: 우연히 같은 코드지만 다른 지식
bool validateUserAge(int age) {
  return 0 < age && age < 150; // 사용자 나이 정책
}

bool validateBuildingFloors(int floors) {
  return 0 < floors && floors < 150; // 건물 층수 제한 -- 우연히 같은 범위
}

// 이 두 함수를 합치면 안 된다. 서로 다른 도메인 지식을 표현한다.
```

### 13.2 코드 중복 제거 예시 [CC] [PC]

> "어쩌면 중복은 소프트웨어에서 모든 악의 근원이다." **[CC]**

```dart
// --- 나쁜 예 ---
void processStudents(List<Student> students) {
  final ranking = [...students]
    ..sort((a, b) => (a.passed * 11 - a.failed * 5)
        .compareTo(b.passed * 11 - b.failed * 5));
  for (final student in ranking) {
    final score = student.passed * 11 - student.failed * 5; // 중복!
    print('${student.name}: $score');
  }
}

// --- 좋은 예 ---
int calculateScore(Student student) => student.passed * 11 - student.failed * 5;

void processStudents(List<Student> students) {
  final ranking = [...students]
    ..sort((a, b) => calculateScore(a).compareTo(calculateScore(b)));
  for (final student in ranking) {
    print('${student.name}: ${calculateScore(student)}');
  }
}
```

### 13.3 지역적 변화의 원칙 [IP]

코드를 수정할 때 함께 바꿔야 하는 부분을 최소화하라. 중복을 없애는 방법은 프로그램을 여러 작은 부분으로 나누는 것이다.

---

## §14. 협력과 의존성 관리

### 14.1 역할, 책임, 협력 [OO]

> "객체지향에서 가장 중요한 개념은 역할, 책임, 협력이다." **[OO]**

- **역할**: 대체 가능성을 의미한다 (다형성)
- **책임**: 객체가 아는 것(knowing)과 하는 것(doing)으로 구성
- **협력**: 역할과 책임을 조화롭게 연결

### 14.2 메시지가 인터페이스를 결정한다 [OO]

> "객체가 메시지를 선택하는 것이 아니라 메시지가 객체를 선택하게 해야 한다." **[OO]**

어떤 행위(메시지)가 필요한지 먼저 결정한 후에, 이 행위를 수행할 객체를 결정하라 (What/Who 사이클).

### 14.3 응집력과 결합력 [PC] [IP]

- **응집력(Cohesion)**: 높을수록 좋다. 작고 잘 정의된 목적을 가진 모듈
- **결합력(Coupling)**: 낮을수록 좋다. 객체 간 의존성 최소화

```dart
// --- 나쁜 예: 높은 결합력 ---
class Order {
  void process() {
    final db = MySqlDatabase(); // 구체 클래스에 직접 의존
    db.save(data);
    final email = SmtpEmailSender(); // 또 다른 구체 클래스에 직접 의존
    email.send(confirmation);
  }
}

// --- 좋은 예: 낮은 결합력 ---
class Order {
  Order(this._repository, this._notifier);

  final Repository _repository;
  final Notifier _notifier;

  void process() {
    _repository.save(data);
    _notifier.send(confirmation);
  }
}
```

### 14.4 상속보다 합성을 우선하라 [IP] [PC] [OO]

상속의 단점:
- 되돌리기 어렵다
- 하위 클래스는 상위 클래스에 강하게 결합된다
- 동적으로 변화하는 로직을 나타낼 수 없다

> "단지 부모 클래스에 있는 메서드를 공짜로 얻을 수 있기 때문에 상속을 하는 것은 좋지 않다." **[PC]**

```dart
// --- 나쁜 예: 재사용만을 위한 상속 ---
/// 리스트의 모든 메서드가 노출됨 -- 필요하지 않은 것까지
class TransactionPolicy extends ListBase<Transaction> {
  // ...
}

// --- 좋은 예: 합성 ---
class TransactionPolicy {
  final List<Transaction> _transactions = [];

  void add(Transaction transaction) {
    _transactions.add(transaction);
  }

  int get length => _transactions.length;
}
```

### 14.5 직교성 (Orthogonality) [PP]

두 가지 이상의 것이 직교적이면, 하나의 변경이 다른 것에 영향을 주지 않는다. 관련 없는 것들 사이의 영향을 제거하라.

```dart
// --- 나쁜 예: 직교성 위반 -- UI 로직과 비즈니스 로직이 결합 ---
class ReportGenerator {
  String generate(List<Map<String, dynamic>> data) {
    var html = '<html><body>';
    final total =
        data.fold<double>(0, (sum, item) => sum + (item['amount'] as num));
    final tax = total * 0.1; // 비즈니스 로직
    html += '<h1>Total: $total</h1>'; // UI 로직
    html += '<p>Tax: $tax</p>';
    html += '</body></html>';
    return html;
  }
}

// --- 좋은 예: 직교적 분리 ---
class TaxCalculator {
  static const rate = 0.1;

  double calculate(double amount) => amount * rate;
}

class ReportData {
  late final double total;
  late final double tax;

  ReportData(List<Map<String, dynamic>> items) {
    total = items.fold<double>(0, (sum, item) => sum + (item['amount'] as num));
    tax = TaxCalculator().calculate(total);
  }
}

class HtmlReportRenderer {
  String render(ReportData report) =>
      '<html><body>'
      '<h1>Total: ${report.total}</h1>'
      '<p>Tax: ${report.tax}</p>'
      '</body></html>';
}
```

### 14.6 가역성 (Reversibility) [PP]

> **dddart 단서**: 아래 Repository 인터페이스 예제는 원전 이론 보존이다 — dddart의 Repo는 **구체 클래스 1개(인터페이스 없음)**가 확정이다(architecture-ddd §10 비채택 표·architecture-data §1). DB 교체 가역성은 서버 관심사이고, 클라의 가역성은 계층 경계(import 매트릭스)가 담보한다.

되돌리기 어려운 결정을 피하라. 추상화를 통해 핵심 결정을 교체 가능하게 만들라.

```dart
// --- 나쁜 예: 특정 DB에 직접 결합 ---
import 'package:postgres/postgres.dart';

class UserRepository {
  Future<User?> find(int userId) async {
    final conn = await Connection.open(/* ... */);
    final result = await conn.execute(
      Sql.named('SELECT * FROM users WHERE id = @id'),
      parameters: {'id': userId},
    );
    return result.isEmpty ? null : User.fromRow(result.first);
  }
}

// --- 좋은 예: 추상화로 결정을 가역적으로 만듬 ---
abstract interface class UserRepository {
  Future<User?> find(int userId);
}

class PostgresUserRepository implements UserRepository {
  @override
  Future<User?> find(int userId) async {
    // ...
  }
}

class MongoUserRepository implements UserRepository {
  @override
  Future<User?> find(int userId) async {
    // ...
  }
}

// DB를 바꿔도 UserRepository를 사용하는 코드는 변경 불필요
```

---


---

## §15. 리팩토링

### 15.1 코드 스멜 카탈로그 [Ref]

코드 스멜(code smell)은 더 깊은 문제를 나타내는 표면적 징후다. Kent Beck과 함께 정리한 이 목록은 리팩토링의 출발점이 된다.

#### 비대화 스멜 (Bloaters)

| 스멜 | 설명 | Dart 예시 |
|------|------|-------------|
| **Long Method** | 메서드가 너무 길어 이해하기 어렵다 | 50줄 이상의 함수 |
| **Long Parameter List** | 파라미터가 너무 많다 | `void f(a, b, c, d, e, f, g)` |
| **Large Class** | 한 클래스가 너무 많은 책임을 진다 | 500줄 이상의 클래스 |
| **Primitive Obsession** | 원시 타입에 지나치게 의존한다 | 금액을 `double`로만 표현 |
| **Data Clumps** | 같은 데이터 그룹이 반복 등장한다 | `(x, y, z)` 좌표를 개별 변수로 전달 |

```dart
// 코드 스멜: Primitive Obsession
String calculatePrice(double amount, String currency) {
  if (currency == 'USD') {
    return '\$${amount.toStringAsFixed(2)}';
  } else if (currency == 'KRW') {
    return '${amount.toStringAsFixed(0)}원';
  }
  throw ArgumentError('unsupported currency: $currency'); // (통화마다 분기가 끝없이 자란다)
}

// 리팩토링: 값 객체(Value Object) 도입
class Money {
  // 정밀도가 중요하면 최소 화폐 단위 int 보관 또는 decimal 패키지를 고려한다
  final double amount;
  final String currency;

  const Money(this.amount, this.currency);

  String display() {
    final formats = <String, String Function(double)>{
      'USD': (a) => '\$${a.toStringAsFixed(2)}',
      'KRW': (a) => '${a.toStringAsFixed(0)}원',
    };
    final formatter = formats[currency] ?? (a) => '$a $currency';
    return formatter(amount);
  }
}
```

```dart
import 'dart:math';

// 코드 스멜: Data Clumps
double distance(double x1, double y1, double x2, double y2) =>
    sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));

// 리팩토링: Introduce Parameter Object
class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  double distanceTo(Point other) =>
      sqrt(pow(other.x - x, 2) + pow(other.y - y, 2));
}
```

#### 객체지향 남용 스멜 (OO Abusers)

| 스멜 | 설명 |
|------|------|
| **Refused Bequest** | 하위 클래스가 상속받은 메서드/속성 중 일부만 사용 |
| **Alternative Classes with Different Interfaces** | 같은 일을 하지만 인터페이스가 다른 클래스들 |
| **Temporary Field** | 특정 상황에서만 사용되는 인스턴스 변수 |

```dart
// 코드 스멜: Refused Bequest
class Animal {
  void walk() {/* ... */}
  void swim() {/* ... */}
  void fly() {/* ... */}
}

class Dog extends Animal {
  @override
  void walk() {/* ... */}
  @override
  void swim() {/* ... */}
  @override
  void fly() => throw UnimplementedError(); // 개는 날 수 없다
}

// 리팩토링: 인터페이스 분리 (abstract class를 인터페이스로 사용)
abstract class Walkable {
  void walk();
}

abstract class Swimmable {
  void swim();
}

class Dog implements Walkable, Swimmable {
  @override
  void walk() {/* ... */}
  @override
  void swim() {/* ... */}
  // fly는 필요 없으므로 구현하지 않는다
}
```

#### 변경 방해 스멜 (Change Preventers)

| 스멜 | 설명 |
|------|------|
| **Divergent Change** | 하나의 클래스가 여러 이유로 변경된다 (SRP 위반) |
| **Shotgun Surgery** | 하나의 변경이 여러 클래스에 산발적으로 영향 |
| **Parallel Inheritance Hierarchies** | 한 계층에 클래스를 추가하면 다른 계층에도 추가해야 한다 |

```dart
// 코드 스멜: Shotgun Surgery
class Order {
  double totalWithTax() => subtotal * 1.1; // 세율 하드코딩
}

class Invoice {
  double taxAmount() => amount * 0.1; // 같은 세율이 다른 곳에도
}

// 리팩토링: Move Method -- 세금 로직을 한 곳으로 집중
class TaxCalculator {
  static const double rate = 0.1;

  static double calculate(double amount) => amount * rate;
}

class Order {
  double totalWithTax() => subtotal + TaxCalculator.calculate(subtotal);
}
```

#### 불필요한 것들 (Dispensables)

| 스멜 | 설명 |
|------|------|
| **Speculative Generality** | "나중에 필요할지도 모른다"는 이유로 추가한 미사용 추상화 |
| **Dead Code** | 실행되지 않는 코드 |
| **Lazy Class** | 하는 일이 너무 적어 존재 이유가 없는 클래스 |
| **Duplicated Code** | 같은 코드 구조의 반복 |

```dart
// 코드 스멜: Speculative Generality
/// 미래를 위해 만든 추상 클래스 -- 현재 구현체는 하나뿐
abstract class AbstractDataProcessor {
  void process(Object? data);
  void validate(Object? data);
  void transform(Object? data);
  void serialize(Object? data);
}

class CsvProcessor extends AbstractDataProcessor {
  // 유일한 구현체
  // ...
}

// 리팩토링: 실제로 필요할 때까지 추상화를 미룬다 (YAGNI)
class CsvProcessor {
  void process(Object? data) {/* ... */}
  // 두 번째 구현체가 필요해질 때 공통 인터페이스를 추출한다
}
```

#### 커플러 스멜 (Couplers)

| 스멜 | 설명 |
|------|------|
| **Feature Envy** | 메서드가 자기 클래스보다 다른 클래스의 데이터를 더 많이 사용 |
| **Middle Man** | 메서드 대부분이 다른 객체에 위임만 한다 |
| **Inappropriate Intimacy** | 두 클래스가 서로의 내부를 지나치게 탐색 |
| **Message Chains** | `a.b().c().d()` 식의 긴 호출 체인 (디미터 법칙 위반) |

```dart
// 코드 스멜: Feature Envy
class OrderPrinter {
  void printDetails(Order order) {
    print('Customer: ${order.customer.name}');
    print('Address: ${order.customer.address.street}');
    print('Total: ${order.total()}');
    print('Tax: ${order.total() * order.taxRate}');
  }
}

// 리팩토링: Move Method -- 해당 데이터를 가진 객체에 로직을 이동
class Order {
  String formatDetails() {
    return 'Customer: ${customer.name}\n'
        'Address: ${customer.formatAddress()}\n'
        'Total: ${total()}\n'
        'Tax: ${calculateTax()}';
  }
}
```

### 15.2 주요 리팩토링 기법 [Ref]

#### Extract Method

```dart
// Before
void printOwing() {
  print('*' * 40);
  print('****** Customer Owes ******');
  print('*' * 40);

  var outstanding = 0.0;
  for (final order in orders) {
    outstanding += order.amount;
  }

  print('name: $name');
  print('amount: $outstanding');
}

// After
void printOwing() {
  _printBanner();
  final outstanding = _calculateOutstanding();
  _printDetails(outstanding);
}

void _printBanner() {
  print('*' * 40);
  print('****** Customer Owes ******');
  print('*' * 40);
}

double _calculateOutstanding() =>
    orders.fold(0.0, (sum, order) => sum + order.amount);

void _printDetails(double outstanding) {
  print('name: $name');
  print('amount: $outstanding');
}
```

#### Replace Temp with Query

```dart
// Before
double getPrice() {
  final basePrice = quantity * itemPrice;
  double discountFactor;
  if (basePrice > 1000) {
    discountFactor = 0.95;
  } else {
    discountFactor = 0.98;
  }
  return basePrice * discountFactor;
}

// After
double getPrice() => _basePrice * _discountFactor;

double get _basePrice => quantity * itemPrice;

double get _discountFactor => _basePrice > 1000 ? 0.95 : 0.98;
```

#### Decompose Conditional

```dart
// Before
double calculateCharge(DateTime date, int quantity) {
  double charge;
  if (date.month >= 6 && date.month <= 9) {
    charge = quantity * summerRate;
  } else {
    charge = quantity * winterRate + winterServiceCharge;
  }
  return charge;
}

// After
double calculateCharge(DateTime date, int quantity) {
  if (_isSummer(date)) {
    return _summerCharge(quantity);
  }
  return _winterCharge(quantity);
}

bool _isSummer(DateTime date) => date.month >= 6 && date.month <= 9;

double _summerCharge(int quantity) => quantity * summerRate;

double _winterCharge(int quantity) =>
    quantity * winterRate + winterServiceCharge;
```

#### Replace Nested Conditional with Guard Clauses

```dart
// Before
double getPayAmount() {
  double result;
  if (isDead) {
    result = deadAmount();
  } else {
    if (isSeparated) {
      result = separatedAmount();
    } else {
      if (isRetired) {
        result = retiredAmount();
      } else {
        result = normalAmount();
      }
    }
  }
  return result;
}

// After (Guard Clauses)
double getPayAmount() {
  if (isDead) return deadAmount();
  if (isSeparated) return separatedAmount();
  if (isRetired) return retiredAmount();
  return normalAmount();
}
```

### 15.3 테이블 주도 방법 (Table-Driven Methods) [CodeC]

논리문(if/case) 대신 테이블에서 정보를 조회하는 기법. 거의 모든 논리적 선택을 테이블 조회로 대체할 수 있다.

```dart
// --- 나쁜 예: 복잡한 조건 분기 ---
double getInsuranceRate(int age, String gender, bool smoker) {
  if (age < 18) {
    if (gender == 'male') {
      if (smoker) {
        return 0.05;
      } else {
        return 0.03;
      }
    } else {
      if (smoker) {
        return 0.04;
      } else {
        return 0.02;
      }
    }
  } else if (age < 35) {
    // ... (연령대 × 성별 × 흡연 분기가 계속 중첩된다)
  }
  throw ArgumentError('unhandled case');
}

// --- 좋은 예: Table-Driven Method ---
const insuranceRates = <(String, String, bool), double>{
  ('youth', 'male', true): 0.05,
  ('youth', 'male', false): 0.03,
  ('youth', 'female', true): 0.04,
  ('youth', 'female', false): 0.02,
  ('adult', 'male', true): 0.08,
  ('adult', 'male', false): 0.05,
};

String _ageGroup(int age) {
  if (age < 18) return 'youth';
  if (age < 35) return 'adult';
  return 'senior';
}

double getInsuranceRate(int age, String gender, bool smoker) {
  final key = (_ageGroup(age), gender, smoker);
  final rate = insuranceRates[key];
  if (rate == null) {
    throw ArgumentError('No rate defined for $key');
  }
  return rate;
}
```

---

## §16. 레거시 코드 다루기

> **dddart 단서**: dddart는 **생성 코드의 외부 관찰 행위를 두드리는 검증 테스트를 산출한다**(coder 필수 산출·green=`flutter test`·신규 BC는 백스톱 TG가 강제) — 단 레거시 전체를 감싸는 특성화 테스트·Seam 도입 같은 *대규모 레거시 테스트 인프라*는 비강제다. 이 절의 테스트 전제 장치(Seam·특성화 테스트·Sensing)는 원전(WELC) 이론으로 보존하되, dddart에서 동작 보존의 안전망은 **analyze green 래칫·결정적 백스톱·G2 행위 대조 + 행위 검증 테스트**다. Sprout/Wrap(기존 코드를 최소로 건드리는 변경 기법)은 그대로 유효하며, "기존 코드 수정 불요구" 경계 규칙(discipline-houserules §7)과 한 방향이다.

### 16.1 레거시 코드의 정의 [WELC]

> **레거시 코드란 테스트가 없는 코드다.**

아무리 잘 작성되었든, 아무리 예쁘고 객체지향적이고 잘 캡슐화되었든, 테스트가 없으면 레거시 코드다.

### 16.2 Seam 개념 [WELC]

**Seam**: 코드를 편집하지 않고도 동작을 변경할 수 있는 지점. 테스트를 삽입하기 위한 틈새를 찾는 핵심 개념.

| Seam 유형 | 설명 | Dart 적용 |
|-----------|------|-------------|
| **Object Seam** | 인터페이스를 정의하고 프로덕션 객체를 테스트용 가짜 객체로 교체 | 추상 클래스 인터페이스 + 의존성 주입 |
| **Link Seam** | 구현 함수를 교체 | 함수 타입 파라미터·필드로 주입한 함수 교체 |

```dart
// Object Seam: 의존성 주입으로 테스트 가능하게 만들기

// Before: 테스트 불가능 (외부 서비스에 직접 결합)
class OrderService {
  void placeOrder(Order order) {
    final server = SmtpClient('smtp.company.com'); // 구체 SMTP 클라이언트를 직접 생성
    server.sendMessage(/* ... */);
  }
}

// After: Object Seam 도입 (테스트 가능)
abstract class EmailSender {
  void send({required String to, required String subject, required String body});
}

class OrderService {
  OrderService({required EmailSender emailSender}) : _emailSender = emailSender;

  final EmailSender _emailSender;

  void placeOrder(Order order) {
    _emailSender.send(
      to: order.customerEmail,
      subject: 'Order Confirmation',
      body: 'Order ${order.id} placed.',
    );
  }
}

// 테스트에서 가짜 객체 사용
class FakeEmailSender implements EmailSender {
  final sentEmails = <(String, String, String)>[];

  @override
  void send({required String to, required String subject, required String body}) {
    sentEmails.add((to, subject, body));
  }
}

void main() {
  test('placeOrder는 이메일을 한 번 보낸다', () {
    final sender = FakeEmailSender();
    final service = OrderService(emailSender: sender);
    service.placeOrder(sampleOrder);
    expect(sender.sentEmails.length, 1);
  });
}
```

### 16.3 Sprout Method (발아 메서드) [WELC]

새 기능을 추가할 때, 기존 코드를 수정하지 않고 **새 메서드로 작성**한 후 기존 코드에서 호출한다.

```dart
// 기존 레거시 코드 (테스트 없음, 수정하기 위험)
class TransactionGate {
  void postEntries(List<Entry> entries) {
    for (final entry in entries) {
      entry.postDate = DateTime.now();
      _verifyEntry(entry);
      _persist(entry);
    }
  }
}

// 새 요구사항: 중복 항목 필터링 추가
// Sprout Method: 새 기능을 별도 메서드로 작성 (테스트 가능)
class TransactionGate {
  void postEntries(List<Entry> entries) {
    final uniqueEntries = _removeDuplicates(entries); // 새 메서드 호출
    for (final entry in uniqueEntries) {
      entry.postDate = DateTime.now();
      _verifyEntry(entry);
      _persist(entry);
    }
  }

  /// 중복 항목을 제거한다. (새 메서드 -- 단위 테스트 작성 가능)
  List<Entry> _removeDuplicates(List<Entry> entries) {
    final seen = <Object>{};
    final unique = <Entry>[];
    for (final entry in entries) {
      if (!seen.contains(entry.id)) {
        seen.add(entry.id);
        unique.add(entry);
      }
    }
    return unique;
  }
}
```

### 16.4 Wrap Method (감싸기 메서드) [WELC]

기존 메서드를 래핑하여 전후에 새 동작을 추가한다.

```dart
// Wrap Method: 기존 메서드를 감싸서 로깅 추가
class Employee {
  void pay() {
    _logPayment();      // 새 동작 (전)
    _dispatchPay();     // 기존 로직 (이름 변경)
    _updateRecords();   // 새 동작 (후)
  }

  void _dispatchPay() {
    // 원래 pay()의 로직 (이름만 변경)
  }

  /// 급여 지급 로깅 (새 메서드 -- 테스트 가능)
  void _logPayment() {
    // ...
  }

  /// 급여 기록 업데이트 (새 메서드 -- 테스트 가능)
  void _updateRecords() {
    // ...
  }
}
```

### 16.5 특성화 테스트 (Characterization Tests) [WELC] — dddart 레거시엔 비적용(생성 코드는 행위 검증 테스트로 대체·레거시 특성화는 원전 보존)

"올바른 동작"을 검증하는 것이 아니라, **현재 동작을 포착**하는 테스트. 리팩토링 전에 안전망으로 작성한다.

```dart
test('legacyCalculateTax의 현재 동작을 포착한다', () {
  // '올바른' 결과가 아닌 '현재' 결과를 기대한다.
  expect(legacyCalculateTax(1000), 103.5);
  expect(legacyCalculateTax(0), 0);
  expect(legacyCalculateTax(-500), -51.75); // 음수 입력에 대한 현재 동작

  // 이 테스트가 있으면, 리팩토링 중 동작 변경을 즉시 감지할 수 있다
});
```

### 16.6 Sensing과 Separation [WELC]

- **Sensing (감지)**: 코드가 계산하는 값에 접근하여 시스템의 다른 부분에 미치는 영향을 파악
- **Separation (분리)**: 테스트를 위해 코드를 의존성에서 분리

레거시 코드에서 테스트가 어려운 주요 원인은 **얽힌 의존성** 때문이다. Seam을 찾아 의존성을 끊고, 감지와 분리를 통해 테스트 가능한 코드로 전환한다.

---

## §17. 설계 철학과 프로세스

### 17.1 설계 단계에서 두 번 설계하고, 구현 단계에서 빠르게 다듬어라 [APoSD] [CC] [OO]

> **통합 원칙**: 주요 아키텍처/인터페이스 결정은 최소 두 가지 근본적으로 다른 접근법을 비교한다 **[APoSD]**. 세부 구현은 빠르게 작성한 후 테스트를 유지하며 반복적으로 리팩토링한다 **[CC] [OO]**.

**설계 단계 (Design It Twice)** [APoSD]:
- 모든 주요 설계 결정에 대해 최소 **두 가지 근본적으로 다른 접근법**을 고려하라
- 첫 번째 생각이 최선의 설계를 내놓을 가능성은 낮다
- 전술적 프로그래밍("일단 동작하면 된다")은 복잡성을 누적시키고 장기적으로 기능 추가 비용을 증가시킨다

**구현 단계 (빠르게 구현 후 리팩토링)** [CC] [OO]:
1. 처음에는 길고 복잡해도 좋다
2. 다듬고 또 다듬는다
3. 다듬는 와중에도 항상 단위 테스트는 통과한다 — dddart 번역: **analyze green 래칫이 그 자리다**(층별 신규 이슈 0 유지, 자동 테스트는 작성하지 않음)

> "설계를 간단히 끝내고 최대한 빨리 구현에 돌입하라. 머릿속에 객체의 협력 구조가 번뜩인다면 그대로 코드를 구현하기 시작하라." **[OO]**

### 17.2 안정적인 구조 중심 설계 [OO]

기능을 중심으로 구조를 종속시키면 변경에 취약하다.
안정적인 구조(도메인 모델)를 중심으로 기능을 종속시켜야 한다.

> "도메인 모델이 안정적인 이유는 사용자가 도메인의 본질적인 측면을 가장 잘 이해하고 있기 때문이다." **[OO]**

### 17.3 책임 주도 설계 (RDD) [OO]

1. 시스템이 사용자에게 제공해야 하는 기능인 시스템 책임을 파악한다
2. 시스템 책임을 더 작은 책임으로 분할한다
3. 분할된 책임을 수행할 적절한 객체에 할당한다
4. 객체가 다른 객체의 도움이 필요하면 협력을 설계한다

### 17.4 세 가지 관점으로 클래스를 바라보라 [OO]

- **개념적 관점**: 도메인 안의 개념과 관계를 반영
- **명세 관점**: 객체가 협력을 위해 "무엇"을 할 수 있는가 (인터페이스)
- **구현 관점**: 객체의 책임을 "어떻게" 수행할 것인가

> "구현이 아니라 인터페이스에 대해 프로그래밍하라." -- GoF **[OO]**

### 17.5 YAGNI [PC]

유지보수 가능한 소프트웨어를 만드는 것은 미래의 요구사항을 예측하는 것이 아니다. 현재 요구사항을 잘 해결하고, 나중에 수정하기 쉽도록 작성하는 것이다.

### 17.6 패턴은 절대적 진리가 아니다 [IP]

> "패턴은 절대적인 진리가 아니므로 상황에 따라 패턴을 적절히 변화시켜 사용해야 한다." **[IP]**

특정 상황에서 특정 패턴을 왜 쓰는지를 알아야 한다. 원칙을 명확하게 알고 있다면 새로운 패턴을 만들 수도 있다.

### 17.7 깨진 창문 이론 [PP]

하나의 깨진 창문(나쁜 설계, 잘못된 결정, 나쁜 코드)을 방치하면, 전체 소프트웨어가 빠르게 퇴화한다. **발견 즉시 수리하라.** 시간이 없다면 최소한 "판자로 막아 놓으라" (TODO 주석, 예외 발생 등).

```dart
// 깨진 창문: 방치된 나쁜 코드
dynamic calc(Map d) {
  final x = d['v'];
  if (x != null) {
    return x * 1.1;
  }
  return 0;
}

// 수리된 창문
const taxRate = 0.1;

/// 주문 데이터에서 세금 포함 총액을 계산한다.
double calculateTotalWithTax(Map<String, dynamic> orderData) {
  final amount = orderData['amount'] as double?;
  if (amount == null) {
    throw ArgumentError("Order data must contain 'amount'");
  }
  return amount * (1 + taxRate);
}
```

### 17.8 추적탄 (Tracer Bullets) [PP]

프로토타입과 달리, 추적탄 코드는 **최종 시스템의 골격**이 된다. 요구사항에서 시스템의 어떤 측면까지 빠르고 가시적이며 반복적으로 도달하는 것이 목표다.

| 추적탄 (Tracer Bullet) | 프로토타입 (Prototype) |
|------------------------|----------------------|
| 최종 시스템의 일부가 된다 | 작성 후 버린다 |
| 가볍지만 완전하다 | 특정 측면만 탐구한다 |
| 실제 환경에서 동작한다 | 격리된 실험이다 |
| 점진적으로 살을 붙인다 | 정찰/정보 수집 역할 |

### 17.9 기타 핵심 팁 [PP]

| 팁 | 설명 |
|----|------|
| ETC (Easier to Change) | 좋은 설계의 핵심 가치 -- 변경하기 쉬운 코드 |
| 작은 걸음으로 (Take Small Steps) | 항상 작은 단위로 변경하고 확인하라 |
| 일찍 리팩토링하고 자주 리팩토링하라 | 문제를 발견하면 즉시 개선 |
| 최소 결합의 법칙 | 물어보지 말고 말하라 (Tell, Don't Ask) |
| 우연에 의한 프로그래밍을 피하라 | 코드가 왜 동작하는지 항상 이해하라 |

---

---

## §18. dddart 코드 규율 — 반복>상속

> 출처: 제1 규약 §10-5 ①(2026-06-12 확정) — dddjango에 없는 dddart 신설 절.

**패턴의 공통화(상속·믹스인)보다 정식 예제의 반복이 우선한다.**

- **base 클래스·공용 헬퍼로 패턴을 추상화하지 않는다**: `BaseVM`·`ErrorHandlingMixin`·`StateMixin` 류의 ViewModel 계층 패턴 추상화 금지. 에러 listen·consumeError 3줄(architecture-state §4 정식 예제), UseCase 위임 한 줄, Repo의 safeApiCall 감싸기 — 이런 구조 패턴은 생성 위치마다 같은 모양으로 **반복해서 쓴다**.
- ***왜*** — 상속·믹스인 공통화는 전 구현(전 VM)을 한 몸으로 묶는 결합 표면이다: base가 바뀌면 전부 바뀌고, 한 화면의 특수 요구가 base에 옵션 매개변수를 증식시킨다. 그리고 이 코드의 작성자는 AI coder다 — 사람의 DRY 본능(타이핑 절약)과 트레이드오프가 다르다. **AI에겐 반복이 더 결정적이다**: 정식 예제를 그대로 찍는 생성이 base 계층의 암묵 동작을 추론하는 생성보다 오류 표면이 좁다.
- **§13(중복 제거·DRY)과의 경계 — "지식의 중복"과 "표기의 반복"을 가른다**: 같은 비즈니스 지식(판정·계산·상태 전이)이 두 곳에 살면 §13대로 모은다 — 단 모이는 곳은 base 클래스가 아니라 **도메인**(애그리거트 메서드·domain_service·specification — architecture-ddd §5 강등 규칙)이다. 반면 구조 패턴의 반복(listen 3줄·fold 2분기·위임 1줄)은 지식이 아니라 표기다 — 모으지 않는다.
- **공용 함수가 전면 금지인 것은 아니다**: `safeApiCall` 같은 횡단 기반 함수는 common 입장 판별(discipline-houserules §6)을 통과한 정상 거주자다. 금지는 **계층 패턴의 추상화**(ViewModel·Repo·UseCase의 base 계층)이지, BC 무관 도구 함수가 아니다.

---

## 핵심 요약 체크리스트

| 범주 | 원칙 | 출처 |
|------|------|------|
| 이름 | 의도를 드러내는 이름을 사용하라 | [CC] [IP] |
| 이름 | 한 개념에 한 단어, 말장난 금지 | [CC] |
| 이름 | 클래스는 명사, 메서드는 동사 | [CC] [IP] |
| 이름 | 이름 길이는 범위에 비례, 평균 10-16자 참고 | [CC] [CodeC] |
| 이름 | 핵심 개념을 앞에, 한정자를 뒤에 | [CodeC] |
| 함수 | 함수는 작게, 모듈/클래스는 깊게 | [CC] [APoSD] |
| 함수 | 한 가지만 해라, 추상화 수준 통일 | [CC] [IP] |
| 함수 | 인수 최소화, 플래그 인수 금지 | [CC] |
| 함수 | 명령/조회 분리, 부수 효과 금지 | [CC] |
| 주석 | 인터페이스 주석은 필수, 구현 주석은 최소화 | [APoSD] [CC] |
| 객체 | 행동이 상태를 결정한다 | [OO] |
| 객체 | 캡슐화: what은 공개, how는 은닉 | [OO] [IP] |
| 객체 | 인터페이스에 맞춰 코딩하라 | [OO] [IP] |
| 객체 | 묻지 말고 시켜라 (Tell, Don't Ask) | [OO] |
| SOLID | 단일 책임, 개방/폐쇄, 리스코프 치환 | [PC] [CC] |
| SOLID | 인터페이스 분리, 의존성 역전 (dddart: DIP는 §9.5 단서 — 직접 생성 확정) | [PC] |
| 설계 | DRY는 지식 단위로 판단 (표기 반복의 경계는 §18) | [PP] |
| 설계 | 로직과 데이터를 함께 유지 | [IP] |
| 설계 | 변화율에 따라 분리 | [IP] |
| 설계 | 안정적 구조 중심, 책임 주도 설계 | [OO] |
| 설계 | 깊은 모듈, 정보 은닉 | [APoSD] |
| 오류 | 1순위: 설계로 오류 제거, 2순위: 예외 사용 | [APoSD] [CC] |
| 오류 | Try/Catch 분리, 보호절 활용, DbC | [CC] [IP] [PC] |
| 오류 | 방어적 프로그래밍 (assertion vs 오류 처리) | [CodeC] |
| 프로세스 | 설계 단계: 두 번 설계, 구현 단계: 빠르게 다듬기 | [APoSD] [CC] [OO] |
| 프로세스 | YAGNI: 현재에 집중하라 | [PC] |
| 프로세스 | 깨진 창문 즉시 수리 | [PP] |
| 리팩토링 | 코드 스멜 감지 및 기법 적용 | [Ref] |
| 레거시 | Seam, Sprout, Wrap, 특성화 테스트 (dddart: §16 단서 — 안전망은 래칫·백스톱) | [WELC] |
