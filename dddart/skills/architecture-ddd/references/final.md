# 도메인 아키텍처 — 간소화 DDD·판정 소유·애그리거트 클라 규율

> **출처:** dddjango `architecture-ddd` final 소스판(2026-06-12 반입 — Evans·Vernon·Millett·Percival&Gregory·Fowler 합성, 서지 전문은 작업장 external.md 말미) · 제1 규약 §3.2·§3.3·§7.1·§9·§10-5 ③ · dddart 파이프라인 본설계(2026-06-12) §5·§8·§9.
> 본문 속 `(규약 §N)`·`(본설계 §N)`은 **출처 표기**이며 로드 대상이 아니다 — 규칙 자체는 본문에 자족적으로 서술된다. 로드 가능한 위임은 "스킬명 + §번호(또는 주제)"와 공유 reference(`undecidable.md`)뿐.

---

## 목차

- §1. dddart의 DDD — 간소화의 지도
- §2. 전략 어휘 — 도메인·BC·유비쿼터스 언어
- §3. 값 객체·엔티티 — freezed·직파싱 하의 형태
- §4. 애그리거트 — 일관성 경계의 클라 번역 (§10-5 ③)
- §5. 판정 소유와 강등 — 1곳째부터 domain
- §6. 도메인 서비스 — 주어 귀속·stateless
- §7. Specification — 재사용·조합되는 판정
- §8. UseCase — Model의 관문
- §9. 빈혈 vs 풍부 — 트랜잭션 스크립트의 함정
- §10. dddart 비채택 패턴 — 음성 지식
- §11. 핵심 요약

---

## §1. dddart의 DDD — 간소화의 지도

DDD의 전술 패턴은 궁극적으로 **시스템의 자유도를 줄여 복잡성을 낮추는 수단**이다 — 복잡한 것을 불변성으로 감싸고, 비즈니스 규칙을 그 규칙의 주인 안에 가둬서 "아무 데서나 아무 값이나 바뀔 수 있는" 상태를 없앤다. dddart는 이 목적은 전부 취하되, 서버·조직 환경을 전제하는 장치는 버린 **간소화 DDD**다.

| 채택 | 형태 |
|---|---|
| 바운디드 컨텍스트·유비쿼터스 언어 | BC = `lib/application/<bc>/`(기능 영역), 같은 개념 같은 철자 (§2) |
| 값 객체·엔티티·애그리거트 | freezed 불변 + 직파싱, 애그리거트(개념) 1차 폴더 (§3·§4) |
| 판정 소유 | **1곳째부터 domain 기본** — dddart 고유 1급 규칙 (§5) |
| 도메인 서비스·Specification | 주어 귀속·공용 위치 없음 (§6·§7) |
| 응용 서비스 | **UseCase**로 치환 — Model의 관문, command+query 통합 (§8) |

| 비채택 | 대체 |
|---|---|
| 도메인 이벤트·Event Sourcing·Saga·CQRS·Repo 인터페이스+UoW·DIP·핵사고날·ACL·컨텍스트 맵·증류·Data Mapper·대규모 구조·마이크로서비스식 BC 분리 | §10 — 각 항목의 *왜*와 dddart의 대체 경로 |

판단이 갈리는 경계(BC 어휘 보유·게이트 입장·판정 귀속)는 공유 reference `undecidable.md`(`${CLAUDE_PLUGIN_ROOT}/skills/discipline-houserules/references/undecidable.md`) §3·§4·§8이 판별 절차를 소유한다 — 이 문서는 규칙 본문을 소유한다.

## §2. 전략 어휘 — 도메인·BC·유비쿼터스 언어

- **도메인과 하위 도메인**: 도메인은 소프트웨어로 해결하려는 문제 영역 전체, 하위 도메인은 그 안의 구획이다. 하위 도메인은 **발견**하는 것이고(업무가 이미 그렇게 나뉘어 있다), 바운디드 컨텍스트는 **설계**하는 것이다(우리가 경계를 긋는다).
- **바운디드 컨텍스트(BC)**: 하나의 모델·하나의 언어가 일관되게 통하는 명시적 경계다. 같은 단어도 컨텍스트가 다르면 다른 모델이다 — 마케팅의 '리드'와 영업의 '리드'는 다른 클래스로 산다. dddart에서 BC의 물리 형태는 `lib/application/<bc>/`(기능 영역)이고, BC 간 통신은 4채널만 허용된다(닫힌 열거는 discipline-houserules §5). 화면이 어느 BC에 속하는지·BC 어휘를 "보유"하는지의 판별은 `undecidable.md` §3.
- **교차 BC 채널 선택 절차** (규약 §9-3 — 각 채널의 정의가 곧 용도다): 타 BC의 **어휘(타입)만** 필요하면 ① 도메인 타입 import, **행위·데이터 접근**이면 ② 그 BC UseCase 호출(단일 관문), **화면 이동**이면 ③ navigator 호출(이름만), **화면 자체를 보여주려면** ④ view 임베드. 반응형으로 "살아 있는" 타 BC 상태가 필요해 보이면 설계를 다시 본다 — architecture-state §7.
- **유비쿼터스 언어**: 도메인 전문가와 코드가 같은 단어를 쓴다 — 코드의 클래스·메서드·파일명이 업무 어휘를 그대로 반영해야 대화와 코드 사이의 번역 비용(과 번역 중 왜곡)이 사라진다. dddart의 집행 형태: **같은 개념은 계층이 달라도 같은 철자**(어순 포함 — discipline-houserules §2), UseCase는 화면이 아니라 도메인 개념 단위 명명(§8).
- **지식 탐구**: 원전의 워크숍 서사(도메인 전문가와의 반복 대화)는 dddart 파이프라인에선 G0 스코프 메모·G1 설계 리뷰가 그 자리다 — 행위 목록의 어휘를 다듬는 일이 지식 탐구의 실행 형태다.

## §3. 값 객체·엔티티 — freezed·직파싱 하의 형태

**값 객체(VO)** — 식별자가 없고, 속성 조합이 곧 동등성이며, 불변이다. 원전에서 불변·동등성 구현에 들이는 노력(frozen dataclass·equals 오버라이드)을 **freezed가 언어 수준에서 전부 제공한다** — dddart의 VO는 freezed 클래스다(표기법은 implementation-dart §4 소유):

```dart
// domain_layer/<aggregate>/value_object/money.dart
@freezed
abstract class Money with _$Money {
  const Money._();
  const factory Money(int amount) = _Money;

  Money add(Money other) => Money(amount + other.amount);
  Money multiply(int count) => Money(amount * count);
}
```

- VO에 도메인 연산을 메서드로 담는 것이 핵심이다 — `Money`가 더하기를 알고, 호출부는 `int` 산수를 하지 않는다. "값 객체의 상태 관련 **모든** 비즈니스 로직은 자신의 경계 안에 있다."
- 도메인 분류 값은 `enum/`(예: `ChannelType`) — 분류에 붙는 판정(`isShippable` 류)은 enum의 getter·메서드로 담는다.

**엔티티** — 고유 식별자를 보유하고, 식별자가 같으면 속성이 달라도 같은 것이다. dddart에서 엔티티는 **애그리거트의 일부로만 사용**한다(독립 엔티티 없음): 애그리거트 루트(`<aggregate>.dart` 폴더 직속) 또는 종속 엔티티(`entity/`).

- **직파싱**: 엔티티는 서버 JSON을 직접 파싱한다(freezed + json_annotation, DTO 없음 — 규약 §9-2). 유입 경로 계약은 architecture-data §4 소유.
- 의도를 드러내는 인터페이스: 메서드 이름은 "무엇을 하는가"(도메인 어휘)를 말하고 "어떻게"를 숨긴다 — `order.cancel()`이지 `order.setStatus(canceled)`가 아니다. 부작용 없는 함수(조회는 상태를 바꾸지 않음)는 freezed 불변이 구조로 보장한다.

## §4. 애그리거트 — 일관성 경계의 클라 번역 (§10-5 ③)

애그리거트는 연관된 엔티티·VO를 하나로 묶은 **일관성 관리의 단위**다. 루트 엔티티가 경계의 문이고, 폴더 형태는 애그리거트(개념) 1차다(트리 사실은 discipline-houserules §1·§3).

원전(Vernon 4규칙)은 가변 객체·DB 트랜잭션 전제라 클라에 그대로 못 쓴다 — dddart 번역(클라엔 트랜잭션이 없고, freezed라 이미 불변이며, **서버가 진실원천**이다):

| Vernon 규칙 | dddart 번역 |
|---|---|
| 1. 진짜 불변식을 경계 안에서 보호 | 불변식 검증은 **루트의 변경 메서드 안에서** (아래 3규칙-2) |
| 2. 작은 애그리거트 | 유지 — 일관성 유지에 필요한 만큼만, 그 이상은 별도 애그리거트(리뷰 수천 건을 상품에 넣지 않는다) |
| 3. 타 애그리거트는 ID 참조 | 서버 응답 모양 우선 (아래 3규칙-3) — ORM FK 금지 확장은 서버 관심사라 해당 없음 |
| 4. 경계 밖은 결과적 일관성 | 클라의 애그리거트 간 동기화는 **서버 재조회(`ref.invalidateSelf`)·SharedState**(architecture-state §5)가 그 자리 — 도메인 이벤트는 비채택(§10) |

**§10-5 ③ 확정 3규칙 (2026-06-12 사용자 확정 — 안 A)**:

1. **루트 경유 변경**: 조건·계산·상태 전이가 걸린 갱신은 **애그리거트 루트의 메서드가 새 인스턴스를 반환**하는 형태로만 한다. freezed의 `copyWith`는 누구나 부를 수 있는 만능 문이라 불변만으로는 규칙 산개를 못 막는다 — VM·UseCase의 copyWith 직접 호출은 **도메인 의미 없는 단순 복제에만** 허용하고, 분기·계산·전이 조건이 붙는 순간 루트 메서드로 옮긴다.
2. **불변식은 변경 메서드 안에서 검증**: 전이 조건 위반은 도메인 예외(`exception.dart`의 `*Exception`)를 throw한다. **생성 시점 검증은 강제하지 않는다** — 직파싱 전제에서 생성자 검증은 서버 데이터가 들어오는 길을 막는다. 클라가 책임질 것은 사용자가 일으키는 변경뿐이다.
3. **타 애그리거트 참조**: 서버 응답이 중첩 객체면 중첩 그대로 직파싱한다. **클라가 새로 조립하는 관계만 ID 참조 우선**이다.

```dart
// domain_layer/order/order.dart — 애그리거트 루트
@freezed
abstract class Order with _$Order {
  const Order._();
  const factory Order({
    required String id,
    required String ordererId,           // 클라 조립 관계 — ID 참조 (3규칙-3)
    required List<OrderLineItem> lines,  // 종속 — 서버 중첩 그대로
    required OrderStatus status,
  }) = _Order;
  factory Order.fromJson(Map<String, Object?> json) => _$OrderFromJson(json); // 직파싱 — 생성 검증 없음 (3규칙-2)

  Money get totalAmount => lines.fold(const Money(0), (sum, l) => sum.add(l.amount));

  Order cancel() {                       // 루트 경유 변경 (3규칙-1)
    if (!status.isCancelable) throw OrderNotCancelableException();
    return copyWith(status: OrderStatus.canceled);
  }
}
```

- **애그리거트를 팩토리로**: 새 객체 생성에 도메인 규칙이 걸리면(차단된 상점은 상품 등록 불가) 그 규칙을 아는 애그리거트의 메서드가 생성을 소유한다 — `store.createProduct(...)`.
- 갱신된 애그리거트의 서버 반영은 UseCase→Repo의 일(architecture-data §3), 화면 반영은 VM의 일(architecture-state §2) — 루트 메서드는 새 인스턴스를 돌려줄 뿐 저장·표시를 모른다.

## §5. 판정 소유와 강등 — 1곳째부터 domain

dddart 고유의 1급 규칙이다 (규약 §3.3 — HaffHaff 실측 drift(판정·에러 표시의 Model 밖 거주)의 직접 처방):

- **도메인 어휘로 진술되는 판정·계산은 1곳째부터 domain이 기본**이다 — "신규 기능의 판정은 항상 소비처가 1곳"이라 복제 시점 강등 규칙만으로는 빈혈에 집행자가 없다. 설계 명세는 행위 목록의 모든 수치·비교·자격 판정에 소유자(애그리거트 메서드·domain_service·specification vs VM 변환)를 항목별로 라벨링하고, **VM 소유를 주장하려면 *왜*를 적는다** (본설계 §5-2).
- **VM의 일은 변환이지 판정이 아니다**: 도메인 결과를 화면 State로 바꾸는 것(포맷·정렬·표시 여부 조립)이 변환이고, "~할 수 있는가"·"~은 얼마인가"를 계산하는 것이 판정이다. specification의 평가·조합도 Model(UseCase 이하)에서만 한다 (규약 §7.1-5).
- **강등 규칙**: 같은 도메인 판정이 **Model 밖 2곳**(VM·view·section·ui_extension·State getter 포함)에 복제되면 `domain_service/` 또는 `specification/`으로 강등한다. 선택 기준은 규약 §3.2 문면 그대로 — **재사용·조합되는 판정 규칙이면 specification**(§7), **단발 판정·계산이면 domain_service**(§6) 또는 애그리거트 메서드 복귀.
- **시간 의존 판정은 '지금'을 인자로 받는 순수 함수다**: `bool isStale(DateTime now)`처럼 기준일을 *주입*받고 도메인 안에서 `DateTime.now()`를 직접 부르지 않는다(domain_layer는 순수 — `package:flutter`뿐 아니라 비결정 시각도 들이지 않는다). '지금'이 실제로 필요한 자리는 application 계층의 오버라이드 가능 provider/인자로 격리한다. *왜* — 시각을 직접 읽는 판정은 테스트가 수행 시각에 따라 통과 여부가 달라져 회귀 안전망을 무력화하고 pre-commit에서 무관한 날 깨진다(테스트의 고정 날짜 주입은 implementation-test §5·테스트 규율은 discipline-test).
- 판정 귀속(어느 애그리거트의 일인가)의 판별 절차·반송 인용 조문은 `undecidable.md` §8 소유 — 1차 결정자(architect)와 검증자(ddd 리뷰어·discipline-reviewer)가 같은 파일을 적재한다.

## §6. 도메인 서비스 — 주어 귀속·stateless

여러 애그리거트에 걸친 도메인 로직의 자리다. **상태 없이(stateless) 로직만** 구현하며, 애그리거트는 도메인 서비스를 모른다(원전 의사결정 채택 유지):

- **애그리거트가 도메인 서비스를 파라미터로 받지 않는다** — UseCase가 도메인 서비스를 호출하고 그 **결과 값만** 애그리거트 메서드에 전달한다(`order.applyDiscount(discount)` — Order는 `DiscountService`를 모른다).
- **주어 귀속** (규약 §3.2 — dddart가 원전에 더한 배치 규칙): 여러 애그리거트에 걸치는 순수 판정·계산은 **규칙의 주어 애그리거트의 `domain_service/`에 귀속**한다. 주어는 **그 규칙이 누구의 속성·정책인가**로 식별한다 — 등급별 할인율이면 (할인을 받는 주문이 아니라) 할인 정책의 주체인 등급·멤버십 쪽. 판정형("X가 ~할 수 있는가")과 계산형("X의 ~은 얼마인가") 모두 동일하다. **공용 위치는 없다**(`common/`에 도메인 로직 금지 — discipline-houserules §6).
- **흐름 조율은 UseCase의 일**이다 — 여러 판정·호출의 순서를 엮는 것은 도메인 서비스가 아니라 §8의 관문이 한다.
- 응용 서비스 vs 도메인 서비스 구분(원전 [A]): 애그리거트의 상태를 변경하거나 상태 값을 계산하는가 → 도메인 서비스 / 조회·저장·흐름의 조율인가 → UseCase.

## §7. Specification — 재사용·조합되는 판정

비즈니스 규칙을 독립 객체로 캡슐화하고 논리 연산으로 조합하는 패턴이다. dddart 용도는 원전 3용도 중 **검증**(객체가 규칙을 만족하는가)과 **선택**(컬렉션 필터링) — 생성(빌더 전달)은 클라 수요가 없어 비강조.

```dart
// domain_layer/lounge_post/specification/visible_lounge_post_specification.dart
class VisibleLoungePostSpecification {
  const VisibleLoungePostSpecification();
  bool isSatisfiedBy(LoungePost post) =>
      !post.isBlinded && !post.isDeleted && post.author.isActive;
}
```

- **풀네임 강제**: `<규칙>_specification.dart` → `<규칙>Specification` — `_spec` 축약 금지(명명 사실은 discipline-houserules §4).
- 조합이 필요하면 명시 메서드로 — Dart에는 Python의 연산자 오버로드 관례(`&`·`|`·`~`)를 쓰지 않고 `and(other)`·`or(other)`·`not()` 메서드 또는 단순 bool 합성으로 충분하다. 조합 계층(AndSpecification 류)은 **조합 수요가 실재할 때만** 만든다 — 규칙 하나에 추상 기반 클래스부터 깔지 않는다.
- **평가·조합은 Model(UseCase 이하)에서만** 한다 — VM이 specification을 import해 직접 평가하면 §5 위반이다.
- 강등 도착지로서의 역할: §5의 강등에서 "재사용·조합되는 판정"이 이리로 온다.

## §8. UseCase — Model의 관문

원전의 응용 서비스를 dddart는 `use_case/`의 **UseCase**로 치환한다 (규약 §3.3 — dddjango의 command+query 통합). 도메인과 ViewModel 계층을 잇는 매개체이며, **비즈니스 로직을 직접 구현하지 않고 도메인 객체에 위임**한다.

**UseCase의 책임** (원전 목록의 클라 번역):
- Repo·infra service를 호출해 애그리거트를 얻는다 (트랜잭션 관리 항목은 클라에 없음 — 삭제)
- 애그리거트·도메인 서비스의 도메인 기능을 실행하고 흐름을 조율한다 (§6)
- Repo의 `Either`를 통과·조합해 반환한다 — **새 throw를 만들지 않는다** (architecture-data §3)

**UseCase가 하면 안 되는 것**:
- 도메인 로직 직접 구현(판정·계산 — §5) · 상태 보유(무상태 plain class — DI 없이 사용처가 직접 생성, 규약 §9-13)
- **UI 호출** — `package:flutter/material`·presentation·design_system import 금지. 에러 표시는 ViewModel 계층의 일(architecture-state §4). HaffHaff 실측: App(=UseCase 전신) 44개 중 36개가 ErrorDialog를 직접 호출했다 — Model→View 역류의 대표 drift.
- **도메인 개념 단위 명명** (규약 §7.1-4): UseCase는 화면이 아니라 도메인 개념으로 짓는다 — 여러 VM이 하나의 UseCase를 공유한다. `<화면>_use_case.dart`가 생기면 오판 신호(판별 절차는 `undecidable.md` §8). 위임 한 줄짜리 UseCase도 정상이다 — 관문의 일관성이 우선(architecture-state §1).

```dart
// application_layer/use_case/order_use_case.dart — 개념 단위 (화면명 아님)
class OrderUseCase {
  final OrderRepo _repo = OrderRepo(); // 직접 생성 — DI 없음

  Future<Either<BadRequestResponse, Order>> cancelOrder(String orderId) async {
    final found = await _repo.getOrder(orderId);
    return found.map((order) => order.cancel()); // 도메인 위임 + Either 통과
  }
}
```

## §9. 빈혈 vs 풍부 — 트랜잭션 스크립트의 함정

**빈혈 도메인 모델**(Fowler 명명 안티패턴): 데이터 클래스는 필드만 갖고, 모든 로직이 서비스(클라에선 VM·UseCase)에 사는 형태. 객체 지향의 모양에 절차적 본질 — 같은 판정이 서비스마다 복제되고, 데이터와 규칙의 거리 때문에 불변식이 새는 곳을 추적할 수 없게 된다.

- dddart의 빈혈 신호: **새 판정이 그 BC의 domain에 0개이고 VM·view·State getter·ui_extension에만 산다** — discipline-reviewer의 홀리스틱 점검이 이것을 blocker로 본다(본설계 §6-3). §4 루트 경유·§5 판정 소유가 사전 차단 장치다.
- **단, 모든 로직을 억지로 도메인에 넣지 않는다** — 원전(6.6 단순 비즈니스 로직 패턴)의 균형: 분기 한두 개의 단순 흐름에 도메인 모델 의식(ritual)을 강요하면 그것대로 과잉이다. 기준은 §5의 정의다 — **도메인 어휘로 진술되는** 판정·계산이 domain의 것이고, 단순 입출력 변환·화면 조립은 VM의 것이다. 도메인이 비어 있는 BC(다수 BC 투영 화면 등)는 골격 그대로 정상이다(discipline-houserules §3).

## §10. dddart 비채택 패턴 — 음성 지식

full-DDD 관행을 들고 오는 것을 막는 명시 목록이다. **아래 패턴을 제안·도입하지 않는다** — 각각 dddart의 대체 경로가 있다:

| 비채택 | *왜* | dddart의 대체 |
|---|---|---|
| **도메인 이벤트** (`event/`·`*Event`·핸들러·디스패처) | 클라는 도메인 이벤트를 생성하지 않고 구독한다. HaffHaff 실물 0건, 클라엔 트랜잭션·프로세스 경계 없음 (규약 §9-15) | 교차 BC 통지는 4채널(discipline-houserules §5), 화면 동기화는 SharedState(architecture-state §5), 서버 이벤트 구독은 그 BC의 `application_layer/service/`(architecture-state §6). 이벤트형 요구가 진짜면 설계 반송 — shared_state로 위장하지 않는다 |
| **Event Sourcing·Saga** | 분산 트랜잭션·이벤트 저장은 서버 관심사 | 서버가 진실원천 — 클라는 재조회 |
| **CQRS** (Command/Query 모델 분리) | 클라 규모에서 분리 비용 > 이득 | UseCase가 command+query 통합 (규약 §3.3) |
| **Repository 인터페이스 + UoW** | 구체 Repo 직접 생성 결정에서 추상 계층은 무의미 — 행위 테스트는 Repo 인터페이스 DI가 아니라 provider override로 격리한다 (규약 §9-1) | Repo는 구체 1개 — architecture-data §1 |
| **DIP·DI 컨테이너** | 직접 생성 결정 (규약 §9-13) | UseCase·Repo·DataSource는 사용처가 직접 생성 |
| **핵사고날(포트·어댑터)** | `port/` 없음 (규약 §9-0) | 계층 import 매트릭스(discipline-houserules §5)가 경계 |
| **ACL·컨텍스트 맵(OHS 등)** | 조직 간 패턴 — 클라 단일 팀, `acl/` 없음 (규약 §9-3) | 교차 BC는 4채널 |
| **Data Mapper·DTO** | 직파싱 결정 (규약 §9-2) | 엔티티가 서버 JSON 직접 파싱 — architecture-data §4 |
| **증류·Event Storming·팀 토폴로지** | 조직 전략·워크숍 기법 — 기능 추가 파이프라인 범위 밖 | G0 스코프·G1 설계가 그 자리 |
| **대규모 구조** (Evans Large-Scale Structure — 시스템 은유·책임 계층 등) | 전사 시스템 조직 패턴 — 단일 앱 범위 밖 | 표준 트리·BC 골격(discipline-houserules §1)이 dddart의 전체 구조 |
| **마이크로서비스식 BC 분리** (BC별 패키지·배포 분리) | 클라 단일 바이너리 — 배포 경계가 없다 | BC는 `application/<bc>/` 폴더 경계 + 4채널로 충분 |

- 이 표는 "몰라서 안 쓰는 것"과 "알고 안 쓰는 것"을 가르는 음성 지식이다 — 리뷰에서 위 패턴이 제안되면 이 절을 인용해 반송한다.

## §11. 핵심 요약

| 구분 | 규칙 | 한 줄 |
|---|---|---|
| 전략 | BC·유비쿼터스 언어 | BC = `application/<bc>/`, 같은 개념 같은 철자, 교차 BC는 4채널 (§2) |
| 전술 | 값 객체 | freezed 불변 + 도메인 연산 메서드 — 호출부가 원시값 산수를 하지 않는다 (§3) |
| 전술 | 엔티티 | 애그리거트의 일부로만, 서버 JSON 직파싱 (§3) |
| 전술 | 애그리거트 | 조건·계산·전이는 루트 메서드(새 인스턴스 반환), 검증은 변경 메서드 안, 생성 검증 비강제 (§4) |
| 전술 | 판정 소유 | 도메인 어휘 판정은 1곳째부터 domain — VM은 변환만, Model 밖 2곳 복제 시 강등 (§5) |
| 전술 | 도메인 서비스 | 주어 애그리거트에 귀속·stateless·애그리거트는 서비스를 모름 (§6) |
| 전술 | Specification | 재사용·조합 판정, 풀네임, Model에서만 평가 (§7) |
| 전술 | UseCase | Model의 관문 — 도메인 위임·Either 통과·UI 금지·개념 단위 명명 (§8) |
| 경계 | 빈혈 차단 | 새 판정이 domain 0개 + VM·view에만 = blocker (§9) |
| 경계 | 비채택 | 이벤트·CQRS·ES·Saga·Repo 인터페이스·DIP·핵사고날·ACL·DTO — 제안하지 않는다 (§10) |
