---
name: architecture-state
description: dddart 상태 아키텍처 — ViewModel 3변종(VM·SharedState·Service)과 State 계약, 에러 2채널, keepAlive 수명 결정, 합성 루트의 상태 동작 규율. 들어온 데이터가 앱 안에서 화면들 사이에 어떻게 살아 있는가를 결정·검수할 때 로드한다.
user-invocable: false
---

# 상태 아키텍처

## 언제 쓰나

VM·State·SharedState·Service를 설계·작성·검수할 때, 에러 표시 경로·상태 수명·공유 범위를 결정할 때 로드한다. 전문을 읽지 말고 아래 라우팅 표로 필요한 절만 부분 적재한다. 경계:

- 파일·폴더·명명·import 매트릭스·4채널 닫힌 열거 **사실** → `discipline-houserules`
- 데이터가 앱 바깥과 오가는 방식(Either 계약·safeApiCall·hive 캐시) → `architecture-data`
- view/section/widget 3단 판별·dumb 규율 → `architecture-ui`
- UseCase 명명·판정 소유·강등 → `architecture-ddd`
- `@riverpod`·freezed **표기법** → `implementation-riverpod`·`implementation-dart`

**keepAlive 경계**: 수명 *결정*(어느 변종·언제 keepAlive)은 이 스킬 소유, `@Riverpod(keepAlive: true)` *표기법*은 implementation-riverpod 소유.

## 핵심 운영 원칙

- ViewModel 3변종은 *상태의 수명*과 *구동원*으로 가른다: VM=화면 1개·View 이벤트, SharedState=화면 N개·여러 VM/View, Service=앱 전역·플랫폼 이벤트 (§1)
- VM·SharedState·Service는 Model 방향으로 UseCase만 호출한다 — Repo·DataSource·SDK 직접 호출 금지, 위임 한 줄짜리 UseCase도 정상 (§1)
- VM은 도메인 엔티티·패키지 타입을 직노출하지 않고 항상 자기 freezed State를 노출한다 — 액션 전용 VM도 error 필드 1개짜리 최소 State (§3)
- 에러는 2채널뿐: 조회 실패는 build()가 throw(AsyncValue.error→error 빌더), 액션 실패는 State의 error 필드+ref.listen 감지·표시 후 consumeError() 명시 소비 (§4)
- base VM·공용 헬퍼를 만들지 않는다 — §4 정식 예제를 그대로 반복한다 (§2·§4)
- BuildContext 보유 금지(전환은 navigator 경유)·UI 컨트롤러는 View 소유(값은 VM 메서드 인자) (§2)
- SharedState는 keepAlive+명시적 reset, 과거형 사건명(`_added` 류) 금지 — 상태로 위장한 이벤트다 (§5)
- 타 BC SharedState·VM watch 금지 — 필요하면 그 BC UseCase 호출 또는 view 임베드. root만 면제 (§7)
- 교차 갱신 버스(refresh_notifier 류)는 폐지 — 데이터 변화는 그 BC SharedState, 라이프사이클발 갱신은 root_lifecycle_handler→BC service (§8)
- root_vm은 "거의 빈 VM", handler 3종은 Service 변종(root_vm이 활성화), initializer는 부수효과만 — 시동 질문은 root_vm이 UseCase 재조회 (§10)

## 상세 레퍼런스

| 질문 | 위치 |
|---|---|
| 이 상태는 VM·SharedState·Service 중 어디인가, data와의 경계는 | [`references/final.md`](references/final.md) §1 |
| VM이 해도 되는 일·금지(BuildContext·컨트롤러·DI) | final.md §2 |
| State 모양 — freezed 계약·최소 State·직노출 금지 | final.md §3 |
| 에러를 어떻게 표시하나 — 2채널·정식 예제 | final.md §4 |
| 화면 간 공유 상태 — keepAlive·reset·사건명 금지 | final.md §5 |
| 플랫폼 이벤트를 받는 코드 — 능동/수동·푸시 분업 | final.md §6 |
| 타 BC의 상태가 필요할 때 | final.md §7 |
| 화면 갱신·스크롤톱 요구가 올 때 | final.md §8 |
| keepAlive를 쓸지 결정 | final.md §9 |
| root_vm·handler·initializer·게이트의 상태 동작 | final.md §10 |
| 판별이 갈리는 경계 사례(handler 입장·거의 빈 VM·common 상태·과거형 사건명) | 공유 reference `undecidable.md` §5·§6·§7·§10 (discipline-houserules 동봉) |

각 절은 필요한 절만 읽는다(`## §N.` 헤더로 grep 가능 — 전체 로드 불필요).
