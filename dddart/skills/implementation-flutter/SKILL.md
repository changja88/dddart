---
name: implementation-flutter
description: Flutter 스택 표기법 — go_router(라우트·탭 셸·redirect·전환), 탭 재탭 2단 동작(스택 리셋+스크롤톱), dio/retrofit, hive_ce(@HiveType 방식·@GenerateAdapters 비채택), 위젯 수명·BuildContext 안전. 라우팅·DataSource·hive·위젯 컨트롤러 코드를 쓸 때 로드한다.
user-invocable: false
---

# Flutter 표기법

## 언제 쓰나

라우트·내비게이션·탭 셸 코드를 쓸 때, DataSource(retrofit)·dio 설정을 쓸 때, hive 캐시·어댑터를 쓸 때, StatefulWidget 컨트롤러·async 콜백을 다룰 때 로드한다. 전문을 읽지 말고 아래 라우팅 표로 필요한 절만 부분 적재한다. 경계:

- 라우팅 짝의 역할·리터럴 단일 출처 규율 → `architecture-ui`
- root 동작 규율·refresh 처방 → `architecture-state`
- safeApiCall·Either·로컬 2층 계약 → `architecture-data`
- @riverpod·AsyncValue → `implementation-riverpod`, freezed·언어 → `implementation-dart`

## 핵심 운영 원칙

- go = 스택 교체, push = 쌓기 — 이동은 이름 기반(pushNamed), 전역 인스턴스 호출(rootRouter.go)은 공식 API 표면 그대로 (§2)
- 탭 셸은 StatefulShellRoute.indexedStack — 탭 인덱스는 navigationShell이 보유, 게이트는 top-level redirect (§2)
- **탭 재탭 2단 동작(확정)**: 중첩 화면이면 분기 첫 화면 복귀(goBranch initialLocation), 첫 화면이면 분기 옵저버로 찾은 라우트 PSC를 animateTo(0) — 전부 root_view 소유, BC는 무관여 (§3)
- BC 화면의 유일한 접점: 최상위 수직 스크롤뷰에 controller·primary를 지정하지 않는다(기본값 유지 — 자동 부착) (§3)
- 재탭 신호 버스(BC가 listen)는 비채택 — 금지 채널의 재생산 (§3)
- DioException 8종 중 타임아웃 3종·badResponse가 safeApiCall 분기의 근거 — 인터셉터는 헤더·로깅 한정(정규화는 safeApiCall 단일 출구) (§4)
- retrofit은 @RestApi 추상 클래스+factory+part — 반환은 Future 엔티티 직반환 (§4)
- **@GenerateAdapters 비채택**(패키지 1파일 강제 — BC 분산 선언과 빌드 충돌): @HiveType per-class를 저장 전용 Box 모델에 붙인다 — 엔티티 무어노테이션 보존 (§5)
- typeId는 앱 전역 유일 — BC별 대역 주석으로 조정, 등록 함수는 isAdapterRegistered 가드 (§5)
- 컨트롤러는 State가 생성·dispose가 해제(쌍 규율), await 뒤 context는 mounted 체크 — lint가 집행 (§6)
- **테스트는 전용 스킬로 이전**: 무엇을/오라클/비-vacuity/단언 FORM은 `discipline-test`, Flutter 메커니즘(provider override 가짜 주입·`ProviderContainer.test`·NoSplash/Timer 회피·mocktail 더블·날짜 주입)은 `implementation-test` (§7)

## 상세 레퍼런스

| 질문 | 위치 |
|---|---|
| 버전·패키지 라인(hive_ce는 원조 hive와 별개) | [`references/final.md`](references/final.md) §1 |
| 라우트 정의·이동·탭 셸·redirect·전환 표기 | final.md §2 |
| 탭 재탭 동작을 어떻게 구현하나 | final.md §3 |
| DioException 분기·dio 설정·retrofit 표기 | final.md §4 |
| hive 어댑터·box·초기화 표기 | final.md §5 |
| 컨트롤러 보유·async gap의 context | final.md §6 |
| 테스트 표기는 어디로 이전했나(discipline-test·implementation-test) | final.md §7 |

각 절은 필요한 절만 읽는다(`## §N.` 헤더로 grep 가능 — 전체 로드 불필요).
