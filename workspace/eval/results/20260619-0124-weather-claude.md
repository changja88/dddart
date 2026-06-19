# 8차 채점 결과 — weather · claude (단일 variant)

## 1. 헤더 (§6.2)
- **방법**: EVAL-METHOD v3.2 · **채점일** 2026-06-19 01:24 (KST)
- **산출물 루트**: `/Users/hyun/Desktop/dddart-run/dddart-20260618-2228-claude` (HEAD abee26d + 미커밋 작업트리 = 산출물 전량)
- **variant**: 단일(claude) · 비교 집계 = `20260619-0124-weather-compare.md`
- **baseline 커밋**: `abee26d`(민낯 main.dart) · **코퍼스 커밋**: `cda1950`(feedback-010 v2)
- **모델·effort**: claude Opus / 기본 · **산출물 mtime**: 2026-06-18 22:2x (런 종료 후 불변·채점 중 변화 0 — 런-정지 OK)
- **코드젠 환경**: Dart 3.12.1 / Flutter 3.44.1 · build_runner exit 0 · dev_deps: freezed·json_serializable·retrofit_generator·riverpod_generator·build_runner(전부 코더 핀·`(조정자 추가)` 0)
- **task**(SCENARIO §1 verbatim): 날씨 7일 예보 — 목록(날짜 오름차순·7건·날짜/상태/최고/최저)→탭→상세(+습도/풍속/강수확률)·상태 6종 아이콘/색/한글.
- **게이트 답**(§4): 풀모드·페이지네이션/캐시/당겨새로고침 미적용·정렬 날짜 오름차순·6종 ui_extension.
- **FC 골든 사전등록**: `FC-GOLDEN-WEATHER.md`(2026-06-14 동결·06-18 amend·코드미열람) — 사용 ✓
- **N_grader**: 3(표준2+적대1) · **구성 ⚠️ 비-Claude 오라클 미확보**(전원 Claude·in-family) · grader raw = `20260619-0124-weather-graders-raw.md`
- **positive control**: 통과(`tools/positive-control/`·치명17 PASS 실증 — 거짓-FAIL 기계 아님)
- **⚠️**: N=1·인과 단정 금지·앵커=예시·소급 FAIL 금지·자기보고 불신(조정자 직접 검증)·**시각/디자인 충실도 비측정(인간 오라클 위임·A1 — 구조·기능 PASS ≠ 시안 일치)**

## 2. 빌드 게이트 (verdict-first)
- **BG-1 컴파일**: ✅ PASS — `build_runner build` exit 0·freezed/part/키워드 정상.
- **BG-2 analyze green**: ✅ PASS — `flutter analyze` "No issues found!"(신규 error/warning 0).
- `flutter test`: 19/19 green · 병렬 결정성 ×5 green(러너 게이트 PASS).

## 3. 치명 17 (per-ID)
| 축 | ID | 항목 | 종합 | 근거 |
|---|---|---|---|---|
| DDD | SD-1 | 판정 소유·빈혈 차단 | ✅ | 정렬 판정 domain 거주(`forecast.dart:38 byDateAsc`·`:43-47 sortByDate`)·UseCase 호출만·빈혈 아님 |
| DDD | SD-2 | 루트 경유 변경 | ➖N/A | 읽기전용·전이 갱신 미발화 |
| DDD | SD-7 | UseCase 관문 | ✅ | `forecast_use_case.dart:19-38` 무상태·Either 통과·새 throw 0·UI import 0 |
| VIEW | VW-1 | Fat Widget 금지 | ✅ | view build 표시·위임만(`weather_list_view.dart:23-38`) |
| VIEW | VW-6 | 표시 소유·show() 금지 | ✅ | 전역키/자기표시 static 0(grep 무결과)·`back_app_bar`는 자기 context maybePop |
| STATE | ST-1 | VM 직행 | ✅ | VM Model 방향=UseCase뿐·Repo/box/SDK·BuildContext 0(IM7/12 백스톱 clean) |
| STATE | ST-2 | 에러 2채널 | ✅ | 조회 실패=build throw→AsyncError(`weather_list_vm.dart:29`)·읽기전용이라 액션채널 정당 부재 |
| STATE | ST-4 | mounted 가드 | ➖N/A | await 후 state 접근 경로 미발화(읽기전용 build) |
| DATA | DT-1 | Either 실패 계약 | ✅ | Repo `Future<Either<BadRequestResponse,T>>`·소비처 Left 비폐기·fold no-op 0 |
| DATA | DT-2 | 단일 출구 | ✅ | `safe_api_call.dart` 4갈래→Either·Repo throw 0·인터셉터 정규화 0 |
| HR | HR-1 | 4계층·BC 컨테이너 | ✅ | 백스톱 ST0/1/2/3 clean |
| HR | HR-4 | 계층 import 역류 | ✅ | 백스톱 IM 역류 clean |
| HR | HR-5 | 교차 BC 4채널 | ➖N/A | 단일 BC weather·타 BC import 0(IM5/CY1 clean) |
| BUILD | BG-1 | 컴파일 | ✅ | build_runner exit 0 |
| BUILD | BG-2 | analyze green | ✅ | analyze 0/0 |
| FC | FC-1 | 골든 오라클 | ✅ | G-1~G-8 전건 일치(grader 3/3·κ=1.0) |
| FC | FC-2 | 비-vacuous | ❌ **FAIL** | **정본 M3(목록 타일 high/low slot swap) GREEN**(조정자 실측·grader 3/3 확인) — 목록 기온 슬롯 단언 부재(상세 hero로만 커버·`forecast_tile_widget.dart:88·94` 무보호). M1·M2·M4는 RED. **필수 M1~M4 red율 75%<100% = FC-2 vacuous FAIL** |
| FC | FC-3 | 도메인 정합 | ✅ | N1~N7 관측 0 |

→ **치명 FAIL 1건(FC-2)** → §3 집계 step2에서 **산출물 전체 FAIL**.

## 4. 차원별 판정
### A. S-DDD
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| SD-1 | 판정 소유 | ✅ | `forecast.dart:38·43-47` 도메인 거주 |
| SD-2 | 루트 경유 변경 | ➖N/A | 전이 미발화 |
| SD-3 | 불변식 도메인 예외 | ➖N/A | VO 검증 throw 0·safeApiCall이 FormatException 정규화(`safe_api_call.dart:32`) |
| SD-4 | VO 도메인 형태 | ✅ | `temperature_range.dart` freezed VO |
| SD-5 | 애그리거트 경계 | ✅ | Forecast 단일 애그·중첩 직파싱 |
| SD-6 | 도메인서비스 귀속 | ➖N/A | 교차 판정 미발화 |
| SD-7 | UseCase 관문 | ✅ | 무상태·Either 통과 |
| SD-8 | 비채택 패턴 | ✅ | event/port/acl/dto/추상 0 |
| SD-9 | 유비쿼터스 철자 | ✅ | forecast 개념 계층 일관 |
### B. S-VIEW
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| VW-1 | Fat Widget | ✅ | 표시·위임만 |
| VW-2 | 3단 판별 | ✅ | section/widget prop·콜백 성립 |
| VW-3 | dumb 조각 계약 | ✅ | section/widget ref 0(IM8/9 clean) |
| VW-4 | 시각 토큰 단일출처 | ✅ | App* 토큰·VM 시각 getter 0 |
| VW-5 | ui_extension 매핑 | ✅ | enum→UI가 `weather_condition_ui_extension.dart`에만 |
| VW-6 | show() 금지 | ✅ | 전역 자기표시 0 |
| VW-7 | 라우트 단일출처·navigator 분업 | 🟡 **WEAK** | **날짜→path 직렬화가 view 인라인 다필드 조립**(`weather_list_view.dart:41-45 _serializeDate`·VO/VM 소유 위반·거주처 무관 FAIL문언 적중·grader 3/3). navigator는 String 전달만(OK). 비치명→WEAK |
### C. S-STATE
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| ST-1 | VM 직행 | ✅ | UseCase만 |
| ST-2 | 에러 2채널 | ✅ | 조회 채널 정합 |
| ST-3 | State 형태 | ✅ | application/state freezed·자기 State |
| ST-4 | ref 규율 | ➖N/A | mounted 경로 미발화 |
| ST-5 | provider 형태 | ✅ | 클래스형 @riverpod·top-level |
| ST-6 | SharedState·교차 BC | ➖N/A | 단일 BC |
| ST-7 | root 합성 | ➖N/A | root 미변경 |
| ST-8 | 비채택(retry OFF 등) | ✅ | `main.dart:19 retry:(_,__)=>null` 보유(7차 회귀 복구)·RV1 백스톱 무발화(정탐) |
| ST-9 | base VM 금지 | ✅ | 각 VM `_$VM`만 extends |
### D. S-DATA
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| DT-1 | Either 실패 계약 | ✅ | Future<Either>·Left 비폐기 |
| DT-2 | 단일 출구 | ✅ | safeApiCall·throw 0 |
| DT-3 | BadRequestResponse | ➖N/A | baseline 소유·신규 확장 0 |
| DT-4 | DTO 없음 | ✅ | DataSource 엔티티 직반환 |
| DT-5 | Repo/DataSource 형태 | ✅ | 구체 단일·무상태·직접 생성 |
| DT-6 | retrofit 표기 | ✅ | @RestApi·factory·part |
| DT-7 | hive 캐시 | ➖N/A | 로컬 캐시 미사용 |
| DT-8 | 계약 스냅샷 | ✅ | 인용 path 계약 실재 |
| DT-9 | infra service 어댑터 | ➖N/A | SDK 어댑터 미사용 |
### E. S-HR
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| HR-1 | 4계층·BC 컨테이너 | ✅ | 백스톱 clean |
| HR-2 | 종류 폴더·접미사 | ✅ | 백스톱 clean |
| HR-3 | 신규 골격 완비 | ✅ | 4계층·종류 폴더 |
| HR-4 | import 역류 | ✅ | 백스톱 clean |
| HR-5 | 교차 BC 4채널 | ➖N/A | 단일 BC |
| HR-6 | 파일·클래스 명명 | ✅ | 백스톱 clean |
| HR-7 | root/common/design 경계 | ✅ | 백스톱 clean |
| HR-8 | 화면 삼총사 | ✅ | vm·view·state 동거 |
| HR-9 | 개념 1차 성장 | ✅ | 단일 개념 직속 |

## 5. TIER-Q 등급 — **중** (WEAK 2·FAIL 0) *[치명 FAIL로 산출물 전체 FAIL이나 품질 기록 보존]*
| ID | 항목 | 판정 | 근거 |
|---|---|---|---|
| Q-1 | Dart 명명·타입 | ✅ | super.key 10/0·지역변수 타입 명시 양호 |
| Q-2 | freezed 표기 | ✅ | copyWith·소진 switch |
| Q-3 | Either 표면 | ✅ | dartz 고정 |
| Q-4 | null 안전 | 🟡 | `weather_detail_view.dart:38 data.forecast!`(보호절 단일 최후수단·경계) |
| Q-5 | 직렬화 표기 | ✅ | @JsonKey·@JsonValue |
| Q-6 | catch 위생 | ✅ | on절 구체·safeApiCall 면제 |
| Q-7 | 구조 스멜 | 🟡 | 날짜·기온 표시 포맷이 `forecast_tile_widget.dart:15·23` 자유함수(ui_extension 정합 이탈·표시변환 거주 분산) |
| Q-8 | import 정렬·주석 | ✅ | dart→package→상대 |
| Q-9 | flutter 내비 표기 | ✅ | pushNamed·NoTransition |

## 6. 의미적 변종 / 백스톱-blind 메타
- **[결정 PASS ∧ 의미 FAIL] 없음**(치명). FC-2는 결정 레인(조정자 mutation 주입)에서 직접 FAIL.
- VW-7은 백스톱 미커버(IM10/20은 navigator import만 봄·view 인라인 직렬화는 의미 레인 전담) → grader 3/3 적발. **measure-first VW-7 FAIL문언 확장이 정확히 포착**(claude 7차 거짓✅ → 8차 정탐).

## 7. 발견 로그
1. **FC-2 치명 FAIL — 목록 기온 슬롯 vacuous**: 조정자 정본 M3(`forecast_tile_widget.dart:88·94` max↔min) 주입 시 `flutter test` GREEN. 원인 = 목록 타일 high/low 단언이 어느 테스트에도 없음(최고/최저 단언은 detail hero `weather_detail_view_test.dart:14-21`에만·별개 위젯). M1(정렬)·M2(색)·M4(직렬화)는 RED.
2. **VW-7 직렬화 view 거주(7차 navigator→8차 view 이동·N=1 진동)**: `weather_list_view.dart:41-45 _serializeDate`가 `'${date.year}-$month-$day'` 다필드 조립. 코퍼스 architecture-ddd §3(직렬화 VO/VM 단일거주) 규칙이 claude 거동을 교정 못 함(guide 취약 재확인) — *단 측정(VW-7 WEAK + M4 red)은 정확히 포착*.
3. **⑥② retry-OFF 복구**: `main.dart:19` 보유(7차 부재 회귀 → 8차 복구). RV1 백스톱 무발화(둘 다 retry 보유·정탐).
4. **M4 직렬화는 RED(7차 green-on-mutation 해소)**: 라우터 배선 위젯테스트(`_support.dart:155-176` 실 GoRouter·`weather_list_view_test.dart:81-84` 독립 oracle)로 직렬화 round-trip 두드림. measure-first 골든 M4 seam 작동.

## 8. 잔여흠 원장
- FC-2 목록 기온 슬롯 미검증(치명) — 산출물 결함.
- VW-7 직렬화 view 거주(비치명·WEAK).
- Q-7 표시 포맷 자유함수 분산(WEAK).

## 9. 한 줄 요지
**claude 8차 = FAIL (치명 FC-2 — 목록 타일 최고/최저 기온 슬롯을 어떤 테스트도 단언하지 않아 M3 mutation이 green 생존·vacuous).** FC-1 기능·구조 치명 16/17은 PASS이고 retry-OFF 회귀는 복구됐으나, 7차 M4 직렬화 vacuity를 고친 자리에서 M3 기온 슬롯 vacuity가 새로 드러남(테스트 커버리지 진동). VW-7 직렬화 view 거주는 비치명 WEAK. *N=1·인과 단정 금지·positive-control 통과(기계 결함 아님).*
