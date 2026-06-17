# dddart 테스트 규율 — 회귀 안전망·단언 FORM

> **출처:** Flutter 공식 테스트 정전(docs.flutter.dev/testing/overview — "many unit and widget tests ... enough integration tests")·flutter_test matcher API(api.flutter.dev/flutter/flutter_test — `findsOneWidget`·`findsWidgets`≡`findsAny`·`find.descendant`)·package:matcher(dart.dev — `orderedEquals`·`isA().having`)·Martin Fowler(Eradicating Non-Determinism·test behaviors not implementation)·업계 합의(SWE@Google·dcm.dev) — 2026-06-17 확인 · dddart 5차 양판 라이브런(FC-2 vacuity·FC-1/3 색충돌·codex 디코이) 트리거.
> 본문 속 `(검증 §N)`은 작업장 자료조사(`workspace/design/2026-06-17-test-strategy-design.md`)의 출처 표기이며 로드 대상이 아니다. Flutter 메커니즘·결정성·더블은 implementation-test, 판정 소유는 architecture-ddd로 위임한다.

---

## 목차

- §1. 목적 — 회귀 안전망·무게중심·날짜 결정성
- §2. 오라클을 명세에서 끄는 법 — 비-vacuity 자가점검
- §3. 단언 FORM — 디코이-불가 4형 + 도메인 양갈래
- §4. 무엇을 생략하나
- §5. red일 때 — 반송·reviewer FORM-감사

---

## §1. 목적 — 회귀 안전망·무게중심·날짜 결정성

dddart가 만드는 코드는 파이프라인이 이미 생성한다 — 테스트는 그 코드를 *짜는* 드라이버(TDD)가 아니라 **이미 생성된 명세-정확 코드를 차후 수정으로부터 지키는 회귀 안전망**이다. 실사용처는 *수정 모드*다: 누군가 나중에 이 코드를 고칠 때 명세가 정한 행위가 깨지면 red가 울려야 한다.

- **가두는 대상은 명세이지 현재 코드가 아니다.** 기대값을 *명세*에서 끌면 안전망, *구현*에서 베끼면 디코이(코드가 틀려도 같이 틀린 채 green)다. 버그 상태를 가두면 디코이, 아무것도 안 가두면 헛테스트(vacuous).
- **무게중심 = thick domain** (Flutter 공식 정전: "많은 unit·widget + 핵심을 덮을 만큼의 integration" — unit이 maintenance·speed 우위). 비중 순서:
  - domain 판정·UseCase·Either 양갈래 — **두텁게**(가장 결정적·가장 싸다).
  - state·VM 상태 전이·정렬/필터/매핑 — 중간.
  - UI는 **핵심 행위만 얇게**(탭→이동·슬롯 표시) — 위젯 트리 *형태*는 테스트하지 않는다(§4).
- **정렬·구별은 도메인 판정이다** — VM 변환이 아니라 도메인에서 두드린다(판정 소유는 architecture-ddd §5). 목록 색 구별·날짜 정렬을 VM 테스트로만 덮으면 판정이 위층으로 샌 것을 테스트가 묵인한다.
- **날짜 결정성**: 도메인 판정은 *기준일을 인자로 받는 순수 함수*로 두고 테스트는 고정 날짜를 주입한다. `DateTime.now()` 실시각에 의존하는 테스트는 pre-commit에서 *무관한 날*에 깨진다(테스트 수행 시각에 통과 여부가 달라지면 안 된다). '지금'이 실제로 필요한 edge는 오버라이드 가능한 provider/인자로 격리한다 — 주입 메커니즘은 implementation-test §5.

## §2. 오라클을 명세에서 끄는 법 — 비-vacuity 자가점검

**2단계 오라클**: ① 코드를 보지 않고 *명세*에서 기대값을 추출한다(이 화면은 날짜 오름차순·최고기온은 위 슬롯·탭하면 그 항목 날짜가 상세로). ② 그 기대값으로 단언한다. 구현을 열어 기대값을 베끼면 — LLM이 테스트를 생성할 때의 *구현-미러링* 경향(Fowler·업계 합의) — 코드의 버그가 그대로 오라클에 복사돼 디코이가 된다(5차 codex가 색 충돌을 "정답"으로 단언한 경로).

**비-vacuity 자가점검**(작성·검수 공통): "이 단언이 의존하는 로직을 머릿속으로 *한 곳* 깨봤을 때 red가 되는가?" — '아니오'면 단언이 행위를 안 두드린 헛테스트다. 존재(테스트 1개)만으론 닫히지 않는다 — §3의 디코이-불가 FORM으로 교체한다. (기존 implementation-flutter §7에 있던 "머릿속으로 깨봤을 때 red" 자가점검을 *FORM 선택 규율*로 격상한 것이다 — 그 §7 테스트 표기는 discipline-test·implementation-test로 이전됐다.)

## §3. 단언 FORM — 4형 + 도메인 양갈래(보강)

단언 *형태*로 디코이를 막게 고른다. **단 형태만으로 디코이가 *불가*한 건 §3.1(집합 크기)뿐이고, §3.2~§3.4는 coder가 이 형태를 쓰는지에 실효가 달린 *가이드*다**(§5·정직). 각 FORM은 5차 양판 실패 1건을 직격한다. **셋업은 dddart no-DI seam을 따른다**(repo/usecase provider는 dddart에 없다 — Repo·UseCase는 직접 생성): 판정(구별·정렬·도메인 양갈래)은 *순수 도메인 단위를 직접* 호출하고, view 행위(위치·탭)는 *VM provider override*로 통제된 State를 주입한다(seam·헬퍼 계약은 implementation-test §2·§7). 여기선 *단언 형태*가 초점이다.

### §3.1 구별(distinctness) — 집합 크기 FORM  *(FC-1·FC-3 색 충돌 직격)*

충돌하면 집합이 줄어 **자동 red**. 디코이로 못 쓴다 — 충돌을 "정답"이라 단언하려면 길이를 N 미만으로 적어야 하는데 그건 명세 N과 어긋나 리뷰에서 드러난다(codex가 `clear == cloudy == secondaryContainer`를 "distinct"로 단언한 디코이가 *이 형태에선 작성 불가*).

```dart
test('6개 condition의 listColor가 서로 다르다', () {
  final Set<Color> colors = WeatherCondition.values
      .map((WeatherCondition c) => c.listColor)
      .toSet();
  expect(colors.length, WeatherCondition.values.length); // 충돌 → 집합 축소 → 자동 red
});
```

**판정단위는 색 *단독* N-distinct로 고정한다**(그래야 5차 색충돌을 형태로 막는다). `(아이콘, 색)` *쌍*의 Set으로 단위를 바꾸면 색이 충돌해도 아이콘이 달라 통과하는 우회가 생긴다 — 명세/골든이 색-단독을 정했으면 색만 `toSet`한다. 명세가 명시적으로 `(아이콘,색)` 쌍 단위를 정한 경우에만 record의 Set을 쓴다(단위 *선택*은 별도 eval 트랙·grader A13).

색 매핑이 `ui_extension`에 살면(architecture-ui §5 — 색·아이콘 매핑의 *유일한 자리*) `c.listColor`가 그 extension getter다 — 이 거주는 정당하므로 discipline-reviewer는 이를 판정 빈혈(§2 blocker)로 오판하지 않는다(UI 매핑 ≠ 도메인 판정).

### §3.2 순서(order) — 뒤섞은 입력 ≠ 기대 + `orderedEquals` + 양끝 echo  *(FC-2 M1 정렬 직격)*

`orderedEquals`만으론 부족했다 — 이미 정렬된 fixture를 넣으면 *무정렬* 코드도 green(M1이 vacuous였던 이유)이다. 두 가지를 형태로 못박는다: ⓐ 입력 순서 ≠ 기대(뒤섞은 입력 — 하드룰) ⓑ 양끝 echo(정렬'됨' 흉내가 아니라 *어느* 순서인지 고정). **정렬은 도메인 판정이므로**(architecture-ddd §5) VM/provider가 아니라 *정렬을 소유한 도메인 단위*(애그리거트 메서드·domain_service·specification)를 **직접 호출**한다(seam A — repo provider 없음):

```dart
test('정렬: 뒤섞인 입력을 날짜 오름차순으로', () {
  final List<ForecastSummary> scrambled = <ForecastSummary>[fc(d(3)), fc(d(1)), fc(d(2))]; // ≠ 기대(하드룰)
  final List<ForecastSummary> sorted = ForecastWeek(scrambled).orderedByDate; // 도메인 단위 직접
  final List<DateTime> dates = sorted.map((ForecastSummary f) => f.date).toList();
  expect(dates, orderedEquals(<DateTime>[d(1), d(2), d(3)])); // 전체 순서
  expect(dates.first, d(1)); // 양끝 echo — '정렬됨' 흉내 차단
  expect(dates.last,  d(3));
});
```

정렬이 VM·view의 `.sort()`로 새 있으면 이 도메인 테스트가 *작성 불가*해진다 — 그 자체가 판정 누수 신호다(판정 소유 §5·reviewer #2). `fc()`=요약 값 빌더(implementation-test §7).

### §3.3 위치(position) — keyed-slot finder + 비대칭·음수 fixture  *(FC-2 M3 기온 위치 직격)*

디코이 위험 = 대칭 fixture(high == low·둘 다 양수)면 슬롯 스왑·부호 누락이 통과한다. *비대칭 + 음수* + 슬롯 `Key`로 막는다. 슬롯 위치는 view 행위라 **VM provider override**로 통제된 State를 주입한다(seam B — implementation-test §2):

```dart
testWidgets('기온: 최고/최저가 각자 슬롯에', (WidgetTester tester) async {
  await pumpDetail(tester, detailState(high: 7, low: -3)); // detail VM override(implementation-test §7)
  final Text high = tester.widget<Text>(find.byKey(const Key('temp-high')));
  final Text low  = tester.widget<Text>(find.byKey(const Key('temp-low')));
  expect(high.data, formatTemp(7));   // 정확 일치 — contains('7')는 '17'·'27'에도 통과(금지)
  expect(low.data,  formatTemp(-3));  // 음수: 슬롯 스왑·부호 누락 포착
});
```

high ≠ low(비대칭)·하나는 음수다. 대칭/양수 fixture는 스왑을 못 잡는다. **단언은 `formatTemp(7)` 정확 일치**다 — `contains('7')`는 부분문자열이라 `'17'`·`'27'`에도 통과해 스왑을 놓친다. 슬롯은 `Key`로 고정한다(텍스트 위치 추정 금지) — 단언이 `Key('temp-high')`를 집으므로 *생성 코드가 그 Key를 달아야* 한다(짝 규약은 architecture-ui — keyed-slot 단언 위젯은 안정 `Key` 부착). `formatTemp`는 SUT 포맷터 재사용(implementation-test §7).

### §3.4 탭→상세 인자 전달 — non-edge 탭 + 날짜-echo fake + subtree `findsOneWidget`  *(FC-2 M4 탭날짜 직격 · codex 디코이의 정체)*

5차 codex M4 디코이 = `.first` 탭 + 날짜 무관 하드코딩 상세 fake + `findsWidgets`(주간 화면에 잔존하는 날짜 텍스트를 흡수). 셋을 형태로 막는다: ⓐ non-edge 탭(`.at(2)` — `.first`는 "아무거나"라 의도 아닌 항목을 탭할 수 있다·**리스트 ≥3 전제**) ⓑ 상세 VM이 *탭한(navigated) 날짜*를 echo ⓒ 상세 subtree 안에서 `findsOneWidget`으로 정확히 1. 목록은 VM override로 통제하고 상세는 *날짜를 되울리는* fake VM을 쓴다(seam B — `pumpList`가 둘 다 배선·implementation-test §7):

```dart
testWidgets('탭→상세: 탭한 항목의 날짜가 상세로 전달', (WidgetTester tester) async {
  final List<ForecastSummary> week = <ForecastSummary>[fc(d(3)), fc(d(1)), fc(d(2)), fc(d(4))]; // ≥3(.at(2) 전제)·뒤섞임
  await pumpList(tester, week); // 목록 VM=week·상세 VM=날짜 echo fake (implementation-test §7)
  final Finder target = find.byType(ForecastTile).at(2);          // non-edge(.first 금지·리스트 ≥3)
  final DateTime tapped = tester.widget<ForecastTile>(target).summary.date;
  await tester.tap(target);
  await tester.pumpAndSettle();
  final Finder detail = find.byType(ForecastDetailView);
  expect(detail, findsOneWidget);
  expect(
    find.descendant(of: detail, matching: find.text(formatDate(tapped))),
    findsOneWidget, // 날짜-echo: 상세 VM이 탭한 날짜를 되울려야 통과
  );
});
```

fixture는 **최소 3개**다(`.at(2)`가 3번째를 집으므로 2개 이하면 finder가 런타임 에러). `formatDate`는 SUT 포맷터 재사용(별도 포맷을 만들면 디코이).

**`findsWidgets`·`findsAny`(="적어도 1")는 쓰지 않는다** — 주변/중복 위젯을 흡수해 "그 항목의 날짜"가 아니라 "어딘가 그 텍스트"를 통과시킨다(M4 디코이의 정체·검증 §B). 정확 개수는 `findsOneWidget`(정확히 1)·`findsExactly(n)`·`findsNothing`(0)으로 고정한다.

### §3.5 도메인 양갈래 — 판정의 두 결과를 도메인에서 직접  *(thick domain 무게중심 · 보강)*

판정은 *충족*과 *위반* 둘 다 두드려야 안전망이다 — 한쪽만 덮으면 다른 갈래의 회귀를 묵인한다. 판정은 도메인 단위라(architecture-ddd §5) 순수하게 직접 호출한다(seam A — provider·network 불요):

```dart
test('도메인 양갈래: 갱신 후 7일 경과면 stale', () {
  final DateTime base = DateTime(2026, 6, 17);                                       // 고정 주입(§1 날짜 결정성)
  expect(Forecast(updatedAt: base).isStale(base.add(const Duration(days: 8))), isTrue);  // 위반 갈래
  expect(Forecast(updatedAt: base).isStale(base.add(const Duration(days: 6))), isFalse); // 충족 갈래
});
```

UseCase의 `Either<BadRequestResponse, T>`를 *직접* 단언할 땐 양채널 matcher가 `isA<Right<BadRequestResponse, T>>().having((Right<BadRequestResponse, T> r) => r.value, 'value', expected)` / `isA<Left<BadRequestResponse, T>>()`다(implementation-test §3). 단 **Left(`BadRequestResponse`)는 *네트워크/infra* 실패**라 통제하려면 Dio 목이 필요하고(seam C·통합·드물게), **도메인 규칙 위반은 State error 채널**(architecture-state §4)이지 `BadRequestResponse`가 아니다 — 그래서 도메인 양갈래의 1차는 위처럼 *도메인 판정을 직접* 두드리는 것이다. `isA<Right>()`만 보고 `.having`로 값을 안 보면 vacuous에 가깝다(분기 + 값을 함께 고정).

## §4. 무엇을 생략하나

자명하거나 구현을 미러링하는 테스트는 헛테스트를 부른다 — 행위와 공개 API만 테스트한다(Fowler·SWE@Google: "test only behavior and module public API"). 다음은 쓰지 않는다:

- **getter·조건 없는 위임** — 한 줄 통과·필드 반환은 행위가 없다.
- **private 메서드** — 공개 행위를 통해 간접 검증된다(직접 테스트하려고 가시성을 열지 않는다).
- **위젯 트리 *형태*** — "Column 안에 Text 2개" 같은 레이아웃 구조는 행위가 아니다(시각은 인간 오라클이 본다 — G2 배너).
- **시각 스타일·golden** — 색·폰트·여백의 픽셀 일치는 dddart 비채택(시각=인간 오라클·골든은 폰트/플랫폼 비결정을 도구가 인정 — implementation-test §8).
- **프레임워크 내부** — riverpod·go_router·hive 자체 동작은 그들의 테스트 몫이다.

생략은 *대충*이 아니다 — 핵심 판정·정렬·매핑·분기·탭 전달은 §3 FORM으로 두텁게 덮는다.

## §5. red일 때 — 반송·reviewer FORM-감사

- **spec-anchored red = 코드가 틀린 것**: 명세에서 끈 단언이 red면 *코드를 고친다*. 테스트를 약화(단언 삭제·`findsWidgets`로 완화·기대값을 코드에 맞춤)하거나 삭제해 green을 만들지 않는다 — 그건 안전망을 스스로 끊는 것이다. 시도 한도 내(coder 3회 규율) green이 안 되면 보고한다(명세 가정 오류인지 구현 난점인지 구분).
- **discipline-reviewer FORM-감사 렌즈**(올바른 모양 *확인* — 금지 적발이 아니라): 핵심 행위마다 §3 FORM을 썼는가 · 오라클이 *명세*에서 왔는가(구현-미러 아님) · 구별은 뒤섞은 입력 + 정확 개수(`findsOneWidget`)인가 · 단언이 충분히 좁은가(`findsWidgets`/대칭 fixture/`.first`/한쪽 갈래만 같은 vacuity·디코이 형태가 있는가). 발견은 coder가 반영한다(reviewer는 코드를 고치지 않는다).
- **자가집행 FORM의 한계(정직)**: §3.1 집합-크기는 충돌 시 자동 red라 *작성 형태*가 디코이를 막지만, 나머지 FORM의 실효는 coder가 그 형태를 *쓰는가*에 달렸다(기계 강제 아님) — 그래서 reviewer FORM-감사가 짝이고, 재발 시 작성자 분리·정적 분석으로 승격한다(measure-first).
