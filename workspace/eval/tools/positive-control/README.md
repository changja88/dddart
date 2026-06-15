# Positive control — dddart-준수 합성 known-good (A12)

> **목적**: 채점 기계가 *known-good을 PASS시킬 수 있음*을 실증한다 — "거짓-FAIL 기계"가 아님을 입증(EVAL-METHOD `§0-6`·`§3-8`·메타검증 A12). 라이브 2런(claude ❌·codex ⏸️)이 모두 PASS 미달이라 "기계가 PASS를 낼 수 있는가"가 미입증이었고, 이 fixture가 그 게이트를 닫는다.
> **작성 경위**: HaffHaff 원본은 기준점 *방언*이되 App 계층이 `ErrorDialog.show()`를 직접 호출(전역 132처)해 dddart의 더 엄격한 규약(SD-7 UI호출 금지·VW-6 show() 금지·HR-4 역류)을 *의도적으로* 어긴다 → 그대로는 positive control 후보 불가(known-good이 치명 FAIL=정탐). 따라서 dddart 규약을 **처음부터 준수하도록 합성**했다.

## 무엇인가

**공지(notice) 목록+상세 BC** 한 벌(수직 슬라이스) — 읽기 전용, 명시 정렬(고정 공지 상단·최신순), 도메인 판정(`isHighlighted`), 분류 배지. `fixture/lib/application/notice/**`(17 소스 + 6 골격) + `fixture/test/application/notice/**`(3 테스트).

## dddart 규약 준수점 (HaffHaff drift 교정 포함)

| 규약 | 준수 방식 | file (fixture/lib/application/notice/) |
|---|---|---|
| 에러 표시 = view 측(App.show 금지) | `.when(error:)`에서 `ErrorFeedback` 위젯 렌더·`ref.invalidate` 재시도 | `presentation_layer/view/notice_list_view.dart` |
| UseCase = Either 통과·UI import 0 | dartz/common/domain/repo만 import·throw 0 | `application_layer/use_case/notice_use_case.dart` |
| 정렬 = VM 변환(ddd §5) | VM `_sortedForDisplay`(도메인 아님·표현 변환) | `application_layer/view_model/notice_list_vm.dart` |
| 도메인 판정 = 1곳째 domain 거주 | `Notice.isHighlighted`(엔티티 메서드)·소비처는 결과만 표시 | `domain_layer/notice/notice.dart` |
| 내비 인자 = VM/navigator 소유(뷰 인라인 직렬화 금지·codex식) | 뷰 onTap→`vm.openNotice(id)`→navigator가 `'$id'` 직렬화 | `notice_navigator.dart`·`presentation_layer/view/notice_list_view.dart` |
| 도메인→UI 매핑 = ui_extension 유일 자리 | category→label·color·icon | `presentation_layer/ui_extension/notice_category_ui_extension.dart` |
| 계층 역류 0 | domain 순수(freezed_annotation만)·application→presentation 0·presentation→infra 0 | (전 계층) |

## 가정하는 bootstrap (호스트 프로젝트 제공)

이 fixture는 *기능 슬라이스*다 — dddart-부트스트랩된 Flutter 프로젝트에 드롭한다. 호스트가 제공해야 하는 것:
- `common/network/`: `safeApiCall`·`BadRequestResponse`·`DioClient`
- `common/service/app_navigator_service.dart`: `appNavigatorKey`
- `design_system/foundation/`: `AppColor`·`AppTypography`·`AppSpacing`·`AppRadius` / `design_system/component/`: `ErrorFeedback`·`EmptyFeedback`·`Loading`
- pubspec deps: flutter_riverpod·riverpod_annotation·go_router·dio·retrofit·dartz·freezed_annotation·json_annotation + dev: build_runner·freezed·json_serializable·retrofit_generator·riverpod_generator
- root_router에 `noticeRouter` 조립

## 검증 기록 (재현 명령 포함)

호스트 = dddart 부트스트랩 프로젝트 사본(예 `dddart-run/dddart-20260613-2310-codex`)에 fixture 드롭 후:
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze lib test
flutter test test/application/notice/
```
**결과(2026-06-14)**:
- `pub get` exit 0 · `build_runner` exit 0(29 outputs) · **`flutter analyze` → "No issues found!"**(BG-2) · **`flutter test` → "All tests passed!"(12)**(BG-1 컴파일 + FC-2 baseline).
- **mutation 비-vacuous 실증(3/3 red)**: ① 정렬 비교자 역전(`a.pinned ? -1 : 1`→`? 1 : -1`)→vm 정렬 테스트 red ② 판정 규칙 반전(`||`→`&&`)→isHighlighted·배지 테스트 red(4건) ③ 분류 라벨 swap(`긴급`→`공지`)→위젯 라벨 테스트 red. 적용 후 전부 복원(흔적 0).

**E2d 갱신(2026-06-15·재검 보류)**: feedback-005 목표2(타입 전면 강제)로 `lib/application/notice/analysis_options.yaml`(BC국소·`always_specify_types`+`always_declare_return_types`·codegen exclude)을 추가하고 `lib/**`를 전수 타입 명시로 보강했다 — 지역변수·클로저 파라미터(`(BadRequestResponse error)`·`(BuildContext context, GoRouterState state)`·`(NoticeListState state)`)·fold 결과 타입(VM이 dartz·BadRequestResponse import — architecture-state §4 정합)·**컬렉션 리터럴 타입인자**(`<Widget>[...]`·`@Default(<Notice>[])`). 위 "No issues found!"는 **이 lint 도입 *전*** 측정이라, always_specify_types 하 analyze green은 **다음 라이브런에서 재확인 필요**(`dart analyze`는 호스트 부트스트랩 의존이라 오프라인 불가). test/는 BC국소 options 범위 밖(호스트 루트 lint 적용)이라 미보강. *주의*: always_specify_types는 모든 컬렉션 리터럴에 타입인자를 요구하므로(`children: <Widget>[...]`) 위젯 트리가 장황해진다 — 결정 B(전면)의 실측 비용이며 라이브런이 실용성을 최종 판정한다.

## FC 골든 (사전등록 행위)

- **정렬**: 고정 공지가 최상단, 그다음 미고정은 게시일 최신순. (입력 [id1 06-01 미고정, id2 06-12 미고정, id3 06-02 고정] → 표시 [3,2,1])
- **강조(`isHighlighted`)**: 고정 공지 **또는** 긴급 분류 → 강조 표지(push_pin) 노출. 일반 미고정 → 미노출.
- **분류 라벨**: notice→`공지`·event→`이벤트`·emergency→`긴급`.
- **분기**: loading→"공지를 불러오는 중"·error→"공지를 불러오지 못했어요"+재시도(invalidate)·empty→"공지가 없어요".

## 치명 17 채점지 (이 fixture에 적용) — 종합 PASS

| 항목 | 판정 | 근거(file:line·fixture 기준) |
|---|---|---|
| SD-1 판정 소유 | ✅ | `domain_layer/notice/notice.dart` `isHighlighted` 도메인 판정·widget은 결과만 소비(`notice_row_widget.dart`) — 빈 wrapper 아님(mutation red 입증) |
| SD-2 루트 경유 변경 | ➖ | 읽기 전용·전이 갱신 코드 0(정당 N/A) |
| SD-7 UseCase UI호출 | ✅ | `use_case/notice_use_case.dart` flutter/presentation/design_system import 0·throw 0·Either 통과 |
| VW-1 Fat Widget | ✅ | `view/notice_list_view.dart` build=`.when`+위임만·정책 0 |
| VW-6 show() 금지 | ✅ | 에러=view측 `ErrorFeedback` 위젯·전역 자기표시 static 0·detail back=`context.pop()` |
| ST-1 VM 직행 | ✅ | `view_model/notice_list_vm.dart` Model 호출=`NoticeUseCase()`만·Repo/SDK/BuildContext 0 |
| ST-2 에러 2채널 | ✅ | 조회 실패=build `fold((e)=>throw e)`→AsyncError·view `.when(error:)`·`valueOrNull` 0 |
| ST-4 mounted 가드 | ✅ | build()가 await→즉시 fold→State 반환(await 뒤 state 재접근 0 → 가드 불요·위반 아님) |
| DT-1 Either 실패 계약 | ✅ | `repository/notice_repo.dart` `Future<Either<BadRequestResponse,T>>`·소비처 Left 비폐기(throw 전달) |
| DT-2 단일 출구 | ✅ | repo `safeApiCall`·throw/rethrow 0 |
| HR-1 4계층·BC 컨테이너 | ✅ | `application/notice/` 4×`*_layer/` + BC 직속 2파일(`notice_router`·`notice_navigator`) |
| HR-4 계층 import 역류 | ✅ | domain 순수·application→presentation 0·presentation→infra 0(analyze clean) |
| HR-5 교차 BC 4채널 | ➖ | 단일 기능 BC·타 BC import 0(정당 N/A·거짓 FAIL 금지 조항) |
| BG-1 컴파일 가능 | ✅ | build_runner + analyze 성공(실측) |
| BG-2 analyze green | ✅ | "No issues found!"(실측) |
| FC-1 골든 오라클 | ✅ | 정렬·강조·라벨·분기 골든 일치(테스트 단언) |
| FC-2 비-vacuous | ✅ | 12 테스트 + mutation 3/3 red(실측) |
| FC-3 도메인 정합 | ✅ | 정렬·강조·라벨 방향 정상·명백 오류 0 |

**종합: 치명 17 = 15 ✅ + 2 ➖(SD-2·HR-5) → 전원 non-FAIL → PASS. TIER-Q 상(관용구 청결·analyze 0).**

## 결론 — A12 게이트 실효화

채점 기계가 **dddart-준수 known-good을 치명 17 PASS로 통과**시킴이 실증됐다 → **거짓-FAIL 기계가 아니다**(메타검증 positive control 미완 → 완료). 이제 라이브런 FAIL(claude·codex)은 "기계 결함 가능성"이 배제된 **확정 신호**로 해석할 수 있다(EVAL-METHOD §0-6·§3-8의 잠정 단서 해소 조건 충족). 메타검증 결과지 `results/20260614-2159-meta-validation.md` §4와 정합.
