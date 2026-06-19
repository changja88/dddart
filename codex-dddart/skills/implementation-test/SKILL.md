---
name: implementation-test
description: dddart 테스트의 Flutter 메커니즘 표기 — flutter_test 매처·mocktail 더블(코드젠 0)·riverpod 3.x ProviderContainer.test·위젯 펌프 결정성(NoSplash·Timer/Completer)·날짜 주입·네트워크 이미지 목·헬퍼 계약. 테스트 코드를 쓸 때 로드한다. 무엇을/오라클/단언 FORM은 discipline-test 소유.
user-invocable: false
---

# 테스트 표기법

dddart 테스트의 **Flutter 메커니즘·결정성·더블 표기**가 여기 산다 — 격리(ProviderContainer.test)·펌프·더블·시간·네트워크 이미지의 결정성. **무엇을 테스트할지·오라클·단언 FORM·생략은 discipline-test 소유**(이 문서는 그 FORM이 쓰는 셋업·펌프·헬퍼만 표기한다). 표기 사실의 단일 출처는 `references/final.md`다.

## 언제 쓰나

테스트 코드를 작성할 때 — provider/VM 격리, 위젯 펌프, 더블(mock/fake), 비동기·시간·네트워크 이미지의 결정성 확보. 전문을 읽지 말고 아래 표로 필요한 절만 부분 적재한다. 경계:

- 무엇을/오라클/비-vacuity/단언 FORM(구별·순서·위치·탭) → `discipline-test`
- 테스트 파일 위치(test/ = lib 미러·sparse) → `discipline-houserules`(§1·§3)
- @riverpod·AsyncValue 런타임 규율·`ref` → `implementation-riverpod`
- 위젯 수명·async gap의 context → `implementation-flutter` §6

## 핵심 운영 원칙

- 격리 seam은 셋 — **순수 도메인 직접**(판정)·**VM provider override**(view)·**Dio 목**(통합 드물게); `repoProvider`·`useCaseProvider`는 dddart에 없다(DI 없음·`ProviderContainer.test`는 VM 단위 격리에) (§2)
- async provider는 `container.read(p.future)`를 await, 상태 전이는 `await container.pump()` 후 `.value`/`.isLoading` 단언 (§2)
- override는 `overrideWithValue`(Future/Stream 값)·`overrideWith((ref)=>x)`(초기값)·`overrideWithBuild((ref, self)=>x)`(3.x — build만 목·notifier 메서드 보존) (§2)
- 더블은 **mocktail**(코드젠 0): Dio 계층 목·fake VM에 쓴다(repo 주입 seam 없음) — `class _MockDio extends Mock implements Dio {}`·`when(() => x.m()).thenAnswer`·`verify(() => x.m()).called(1)`·`registerFallbackValue` (§3)
- 위젯 펌프 결정성: `splashFactory: NoSplash.splashFactory`(잉크리플 셰이더 회피)·loading은 완료되는 `Completer` 후 settle(Timer 누수 회피)·미완료 future를 펌프한 채 두지 않는다 (§4)
- **날짜 주입**: 도메인 판정은 기준일을 *인자로* 받는 순수 함수·'지금'은 오버라이드 가능 provider/인자로 격리·테스트는 고정 `DateTime`을 주입한다(실시각 안 읽음·게이트 없음) (§5)
- 네트워크 이미지 view는 펌프를 `mockNetworkImages`로 감싼다 — 테스트 환경의 HTTP 400 함정(`Image.network` 크래시) 회피(아이콘이 `IconData`면 미해당) (§6)
- 헬퍼 계약(`d()`·`fc()`·`detailState`/`listState`·`_FakeListVM`/`_FakeDetailVM`·`pumpList`/`pumpDetail`·`formatDate`/`formatTemp`·`screenProbes`)은 §7 단일 정의 — discipline-test FORM이 이 이름·계약을 쓴다. `screenProbes`만 예외로 FORM이 아니라 eval FID 렌더 덤프가 소비하는 화면 진입점 맵이다(view·헬퍼 이름을 맵 안에 가둬 프로브가 BC 이름에 비의존) (§7)

## 상세 레퍼런스

| 질문 | 위치 |
|---|---|
| 패키지 라인·왜 mocktail(vs mockito) | [`references/final.md`](references/final.md) §1 |
| ProviderContainer.test·async·override | final.md §2 |
| mocktail 더블·matcher 어휘 | final.md §3 |
| 위젯 펌프 결정성(NoSplash·Timer/Completer) | final.md §4 |
| 날짜·시간 결정성(주입) | final.md §5 |
| 네트워크 이미지 목(조건부) | final.md §6 |
| 헬퍼 계약 단일 정의 | final.md §7 |
| 안 쓰는 것(golden·patrol·mockito·mutation) | final.md §8 |

각 절은 필요한 절만 읽는다(`## §N.` 헤더로 grep 가능 — 전체 로드 불필요).
