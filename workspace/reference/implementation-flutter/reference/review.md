# implementation-flutter 합성 전 리뷰 — 조사 신뢰도 검증 기록

> Wave 4 외부 조사형. external.md(2026-06-12)의 신뢰도 검증과 합성 결정 기록. **§10-5 ④ 결정의 원료·확정 기록 포함.**

## A. 조사 신뢰도

- 공식 문서 + **Flutter SDK 3.44.1 소스 직독**(primary_scroll_controller·scaffold handleStatusBarTap·routes의 ModalRoute PSC 주입·scroll_controller — 행 번호까지) + hive_ce_generator 소스 직독(1파일 강제의 throw 지점 실측) + 공식 이슈(#131829) 대조. "소박한 독해 불성립"을 추정이 아니라 SDK 소스로 증명한 것이 신뢰도의 증거.
- HaffHaff pubspec.lock 실측으로 버전 기준 고정(go_router 16.2.4 등).

## B. 충돌 처리 (2건)

1. **hive_ce @GenerateAdapters 1파일 강제 vs data §5 BC별 선언**: 조사의 3안 중 **HaffHaff 실물 방식이 답** — 실물은 @GenerateAdapters를 안 쓰고 **별도 저장 전용 Box 모델에 @HiveType per-class**(+자가 등록)를 쓴다(2026-06-12 실물 확인: member_box.dart의 @HiveType(typeId:1)·member_hive.dart의 isAdapterRegistered 가드). 이 방식은 ① 파일 제약 없음(BC별 분산 가능) ② 도메인 엔티티 무어노테이션 보존(별도 Box 클래스) ③ 규약 문면("`<bc>_hive_adapters.dart`에 선언·등록 함수, root_initializer가 조립") 그대로 성립 — **규약 개정 불요, @GenerateAdapters만 비채택 명시**. 남는 비용: typeId 전역 유일 수동 관리 → BC별 대역 주석 규약 + 백스톱 향후 후보.
2. **"root가 PSC 공급" 소박한 독해 불성립**(ModalRoute가 라우트마다 PSC 주입 — shadowing): 규약 §9-11 문구("root_view가 PrimaryScrollController **등으로** 직접 처리")의 구현 경로를 패턴 B로 구체화 — 규약 문면의 "등으로"가 수용하는 범위라 규약 개정 불요. state §8의 "미결" 표기는 확정으로 갱신(2026-06-12).

## C. §10-5 ④ 확정 기록 (2026-06-12 사용자)

**탭 재탭 2단 동작**: ① 분기에 중첩 화면이 쌓여 있으면 분기 첫 화면으로 복귀(패턴 A — goBranch initialLocation 공식 관용구) ② 분기 루트면 스크롤 최상단(패턴 B — StatefulShellBranch.observers로 top ModalRoute 추적 → subtreeContext → PrimaryScrollController.maybeOf → animateTo(0)). 전부 root_view 소유·BC 무관여(유일 접점 = 최상위 수직 스크롤뷰의 controller·primary 미지정 기본값 유지). 패턴 C(신호 버스 — HaffHaff scroll_to_top_notifier)는 금지 채널 재생산으로 비채택 명시. iOS 상태바 탭(셸 구조에서 #131829로 깨짐)도 같은 함수 재사용으로 복원 가능.

## D. 합성 결정

- go_router 기준은 16.x 유지(HaffHaff lock — 기존 프로젝트 우선), 17 차이는 §2 말미 메모(본문 표기 동일이라 승격 무비용).
- 인터셉터 경계 명문화: 정규화는 safeApiCall 단일 출구 — 인터셉터는 헤더·로깅 한정(두 정규화 지점 충돌 방지).
- CancelToken 비채택 현행 유지 — 도입 시 cancel 무음 분기 필요를 §4에 단서.
- box.listenable() 비사용(상태 반응은 riverpod 소관) — §5에 1줄.

## D-2. 4렌즈 1라운드 교정·기록 보완 (2026-06-12 사후)

- **§6 showDialog·showModalBottomSheet 표기 블록**: 조사 무기록 — Wave 3 소비성 P3(상호 포인터 루프)의 도착지로 1라운드 후 추가된 위임 이행(architecture-ui §7가 "구체 호출 표기는 implementation-flutter §6 소유"로 명시 위임). API 표기는 표준 Flutter 시그니처.
- **§5 Box 모델 예제 교정**: 초안의 `extends HiveObject`·late 필드는 실물 무근거 — HaffHaff member_box.dart 재확인(2026-06-12) 결과 **plain class·const 생성자·final 필드**가 실물 형태라 그대로 교정. `toDomain()`/`from()` 명명은 합성 결정(실물은 Hive 클래스 쪽 변환 메서드 — dddart는 Box 모델에 쌍 메서드로 단순화, 변환 자체는 Box 분리의 필연).
- **§2 17.x 메모 완화**: "observers 양쪽 유효" 단정 → "17 변경 기록 없음·승격 시 1회 확인"으로(조사 기록 범위 정합).
- **§3 제목·출처 행**: "§10-5 ④"에 문서명(규약) 병기 — 본문 §앵커와의 오독 방지(plugin-dev P3).

## E. 잔여 미확정 (P1 표 반영)

- 패턴 B 실기기 스모크 미수행(공개 API·SDK 소스 정합은 전부 확인) — §10-4 root 골격 구현 시 1회 검증.
- dio QueuedInterceptor(토큰 갱신 직렬화) 미조사 — 소비처 확정 시 추가.
