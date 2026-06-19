# fix 010 — 직렬화 seam(FC-2)·측정 명확화(SD-3·Q-1)·테스트 결정성 (사전등록형·적대 2차 반영)

> RCA: 7차 포렌식(소스 직독·회귀추적·**적대검증 1차 11 서브에이전트 ~1.3M토큰 → 시술 직전 적대 2차 8 서브에이전트 ~642K토큰**). **핵심 = 7차 비-PASS 전 항목(치명 1·WEAK 3·사각 1)의 뿌리를 고치기 *전* 예상을 박고, 8차로 실측 대조.**
> ⚠️ **전략 헤드라인(미러 유지·적대 2차 확증)**: 코퍼스 지배 스킬은 양엔진 byte-동일이고 7차 흠은 *공유 공백 위 엔진 런-변동*(진동)이다. ①④는 6차에 **정반대 거동**(6차 claude navigator는 String 수신·직렬화 안 함·M4 RED / 6차 codex는 super.key)이 소스로 확증돼 "엔진 고정 성향 아님·N=1 진동"이 *강화*됨 → 엔진전용 근거 부족(엄밀히 더 나은 항목 0). 결정축 = **기계(엔진불변) vs guide(취약)**.
> ⚠️ **적대 2차 정정 헤드라인**: v1 사전등록이 적대 2차에서 다수 결함 적발 — ①처방이 RUBRIC VW-7 중복·architecture-ui §6 모순·repo 중복사이트 누락·**진짜 레버(골든/측정 seam)** 오인 / ③RCA "규칙 부재" 오진(§3·§4 이미 존재)·"도메인*Exception 치환" 오분류(parse≠전이위반)·codex 패턴 대체로 적법 / ⑤메커니즘 불가(isolate static 비공유)·도구 오류(randomize-ordering≠병렬경합)·reset 실재 / ②산문 잉여·백스톱 FP 과소·ID 충돌 / ④lint floor 누락·dim 오귀속. **아래는 그 정정을 반영한 v2.**
> ⚠️ **정직 표기**: 항목 1·4는 *guide+측정보강*(8차가 1차 반증). 항목 2 백스톱·항목 5 러너검사만 기계 floor(변종포함 positive-control 반증 전제). 항목 3은 *코드 교정 아님·측정 명확화*(codex 패턴 적법·rubric 경계 정리). N=1 인과 단정 금지.

## 메타
- **회차**: 010 (v2 — 적대 2차 반영)
- **트리거**: 7차 양판 — `results/20260618-1610-weather-{claude,codex,compare,graders-raw}.md`. + 시술 직전 적대 2차(2026-06-18·워크플로우 `wf_24c44040-b60`).
- **베이스 코퍼스**: `9aa5c86`(현 HEAD·feedback-009 a27c357 + A13-1 골든 f3f2b3e + 스크린샷 제거 299fd09)
- **시술 커밋**: `327640c`(measure-first 5건 + 코퍼스 산문 3건·양미러 11/11) → `4c423fd`(해시 기록) → **`882cc0c`(Phase 3 ②RV1 backstop·⑤러너 게이트·VW-7 과대범위 교정·재미러)**. 전부 2026-06-18·main 직접·push 안 함.
- **검증 런**: `<다음 라이브런(8차)·양판>`
- **상태**: **✅ 8차 검증 완료(2026-06-19·`results/20260619-0124-weather-*`) — 측정 보강 5/5 작동·코퍼스 산문 1건(①직렬거주) 무효(guide취약 예고적중)·신규 발견 1(claude M3 vacuity)·도구버그 1 수정(러너 게이트 bash3.2). 8차 판정: claude FAIL(치명 FC-2)·codex PASS(TIER-Q 상).**

## 적대 2차 요약 (시술 직전 반증 — 8 서브에이전트)
- **방향(미러)은 반증 견디고 강화**·confabulation 없음(전건 file:line·6차 0012/7차 1312 폴더 분리).
- **5항목 전부 구체 결함 적발**: ①③⑤ 중대(레버/RCA/메커니즘 오류)·②④ 경(잉여/표기). v1대로 시술 시 ①은 8차도 green 가능(측정 seam 미보강)·③은 금지 패턴 미화 우려·⑤는 헛침(도구 불일치).
- **measure-first 선결 다수 발견**: ①골든 M4 seam·VW-7 FAIL문언·③RUBRIC SD-3 경계·④Q-1 dim은 eval 단일출처라 **8차 채점 착수 전** 등록(소급 금지).

## 교정 항목 (사전등록 v2 — ①~④ 작성, 다음 런 후 ⑤~⑥)

| # | 우선 | ① 대상(dim·관측점) | ② 원인(뿌리·적대2차 정정) | ③ 처방(파일·미러/단일출처) | ④ 예상효과(전→후·dim) | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| 1 | 핵심(치명) | **FC-2**(치명) — claude 7차 M4 navigator 날짜 직렬화 **green-on-mutation**(`weather_navigator.dart:22`)·**+ `weather_repo.dart:42` 동일 직렬화 중복**(DRY·실네트워크 path). codex는 VO `toApiPath()` 단일거주 + navigate 테스트 4건으로 M4 red | **측정 seam 사각 + 직렬화 중복거주**(코퍼스 산문 부재 아님). (a)골든 M4 주입사이트가 직렬화 format step 미열거·기본 seam(VM-override)이 navigator 직렬화 **구조적 미도달**(테스트가 M4 못 두드림) (b)VW-7 FAIL문언이 "뷰 onTap"만 명명→navigator/repo 인라인 misplacement 의미 grader 미적발(claude VW-7 거짓✅) (c)직렬화 로직 navigator+repo 중복·테스트가능 도메인 단위 부재 | **3축**: ⓐ(코퍼스·미러) architecture-ddd/ui — "송신 직렬화는 **테스트가능 도메인 단위(VO 메서드 우선·VM 변환 허용)** 단일거주, navigator는 결과 문자열 *전달만*, view·repo 인라인·중복 금지"(VW-7 PASS·§6 정합) ⓑ(골든·measure-first) FC-GOLDEN §2 M4에 직렬화 step 명시·§5 어댑터에 "navigator/repo 거주(VM-override 미도달)면 seam=도메인단위 직접/integration" ⓒ(RUBRIC·measure-first) VW-7 FAIL에 "navigator/repo 인라인 직렬화" 추가 ⓓ(기계 floor 후보·약) navigator/view/repo의 `DateFormat('yyyy-MM-dd')`/`toIso8601String()` path조립 grep(표시 'EEE M/d' 구별)·DRY중복·positive-control 선행 ⓔ discipline-test §3.4 한계주석(탭-날짜 FORM은 section 콜백서 멈춰 하류 직렬화 미검) | 전: M4 死(green-on-mut)·VW-7 거짓✅ → 후: 골든 seam이 직렬화 round-trip 두드림 + VW-7가 misplacement 적발 + 단일거주 → **M4 red·VW-7 정확채점**. dim **FC-2**. ⚠️guide+골든/RUBRIC(measure-first)·repo 포함·8차 1차반증 | 골든M4·VW-7·산문§3 `327640c` | **부분 적중**: M4 mutation **양엔진 RED**(claude 라우터배선 위젯테스트·codex VO단위·**7차 green-on-mut 해소**·골든 M4 seam 작동)·VW-7 **claude FAIL 적발**(`weather_list_view.dart:41-45` 직렬화 view 거주)/**codex PASS**(VO `toRouteParam`)=측정 적중. **단 claude FC-2 여전 FAIL** — M4 아닌 **신규 M3(목록 기온슬롯) vacuous**(`forecast_tile_widget:88·94` 무단언). 코퍼스 산문 §3은 claude 직렬 거동 미교정(navigator 7차→view 8차 진동·**guide취약 예고적중**). **측정망 적중·코퍼스 산문 무효** |
| 2 | 권장(WEAK) | **ST-8**(비치명) — claude 7차 `main.dart:14` retry OFF 부재·6차 `main.dart:19` 보유(회귀·N=1). codex 양 런 보유 | retry OFF **산문은 이미 명문**(impl-riverpod §8:115-125 코드+사용자확정)·기계검사 0. claude 재구조화 중 N=1 드롭(산문 부재 아님). RUBRIC ST-8은 *구조-존재* 검사(weather 행위 미발화) | ⓐ산문 (a) **폐기**(§8 이미 명문·잉여)·선택적 main 합성 체크리스트 1줄 ⓑ(백스톱·핵심·단일출처) main.dart **기능적 retry-OFF 존재** 검사 — `ProviderScope(retry:)`뿐 아니라 **`ProviderContainer(retry:)+UncontrolledProviderScope` 변종·per-provider opt-only도 통과**(5차 폴더 20260616-2025 실표본을 positive-control 반증에 명시 포함)·**신규 family ID(ST8 점유됨)**·거짓-FAIL 0 확인 후 투입 | 전: ST-8 WEAK → 후: 백스톱이 부재 결정 차단(변종 거짓-FAIL 0)·ST-8 PASS 고정. dim **ST-8**. ⚠️N=1·변종포함 positive-control 통과 선결 | RV1 backstop `882cc0c` | **적중**: 양엔진 retry-OFF 보유(claude `main.dart:19`·**7차 회귀 복구**·codex `:17`)·**ST-8 PASS 양쪽**. RV1 백스톱 **무발화(정탐)** — 둘 다 retry 보유라 발화 안 함이 정답(8차 실표본에 부재 케이스 없음·부재 시 발화는 F14a fixtures가 입증). N=1 |
| 3 | 권장(측정명확화) | **SD-3**(비치명) — codex 7차 `forecast_date.dart` `.parse` 팩토리가 FormatException throw(`@JsonKey fromJson: ForecastDate.parse` 컨버터 + `detail_vm:16` 런타임 양용). **기본생성자 무검증·`safeApiCall:27` 정규화(행위 안전)**. claude VO 미사용 N/A | RCA "명령형 부재"는 **오진** — §3:71(모델내 FormatException 금지+@JsonKey 컨버터 면제)·§4:90(생성검증 비강제)·RUBRIC SD-3(전이조건 위반=도메인*Exception) **이미 존재**. 진짜 긴장: (a)§3 면제가 "top-level/static 함수"만 명명·**factory 컨버터 미포함**(경계 모호) (b)SD-3가 *전이 invariant* 대상인데 grader가 *parse-throw*를 끼워넣음→정상값 미차단·정규화되는 컨버터 parse가 위반인지 불명(grader 2/3 분열 증거) | **"도메인*Exception 치환" 폐기**(parse=직렬화 경계·FormatException 의미상 정확·도메인*Exception은 전이위반 전용·치환은 오분류). ⓐ(RUBRIC·measure-first) SD-3 FAIL 명확화 "**safeApiCall이 정규화하는 컨버터/parse-throw는 SD-3 위반 아님**(정상값 미차단·전이 invariant만 대상)" ⓑ(코퍼스·미러·선택) §3 면제에 "fromJson 컨버터로 쓰는 factory/static parse도 면제(safeApiCall 정규화 전제)" 1구 | 전: SD-3 WEAK 2/3(경계 모호) → 후: grader 합의 PASS·진동 감소. dim **SD-3**. ⚠️**코드 교정 아님·측정 명확화**(codex 적법)·정직표기 정정 | RUBRIC SD-3 경계 `327640c` | **적중**: codex `forecast_date.dart:16 DateTime.parse`(safeApiCall 정규화·정상값 미차단)를 **grader 3/3 PASS**(7차 WEAK 2/3 진동 → 8차 합의)·RUBRIC SD-3 주의(:30) 경계 적용. 측정 명확화 적중·codex 적법 확정 |
| 4 | 권장(최저·WEAK) | **위젯 키 관용**(Q-1로 채점되나 RUBRIC Q-1=명명/타입 텍스트 밖) — codex 7차 `forecast_tile_widget.dart:13` 레거시 `Key? key`(계산 기본키 `key ?? Key('forecast-tile-${date.toApiPath()}')`·N=1 1파일·타 위젯 9종 super.key). 6차 codex super.key | super.key 명령형 가이드 **전무**(impl-flutter grep 0·impl-riverpod §7 예시 1건만). **단 `use_super_parameters` lint(flutter_lints·양 런 active·lints recommended.yaml:71)가 평범한 `super(key:key)` forward는 이미 기계 적발**·계산키 패턴(`key ?? Key(...)`)엔 미발화 → guide 잔여 실효=lint 미적발 케이스 한정 | implementation-flutter §6 인근 "위젯 생성자는 super.key·**계산 기본키는 호출부 ValueKey/static 팩토리**(레거시 Key? key 회피)" 명문. `--write` 양미러. (lint floor 분담·§56 안정키 양립 정직표기) | 전: 위젯 키 WEAK(기능등가·N=1·lint 미적발 잔여) → 후: super.key 일관. dim **위젯키 관용**(Q-1 채점·차기 동결창 정의 검토). ⚠️최저신뢰·N=1 | impl-flutter super.key `327640c` | **적중**: claude super.key 10/0·codex **11/0**(7차 `forecast_tile_widget.dart:13` 레거시 Key? key 회귀 → 8차 전부 super.key 복구)·레거시 forward 0. Q-1 dim 보류 유지(차기 동결창) |
| 5 | 권장(게이트로 강등) | **테스트 결정성**(차원 신설→**기계 게이트**) — 양엔진 7차 `flutter test` 병렬 flaky(grader 관측·N=1)·조정자 단일실행 green. **claude·codex 둘 다 이미 싱글톤 reset 보유** | RCA "reset 부재→cross-shard 싱글톤 오염"은 **2중 오류** — (a)reset 실재(claude `forecast_list_vm_test.dart:48-53` adapter 백업복원·codex `dio_client.dart:14 resetForTest`) (b)메커니즘 **불가**(`flutter test`는 파일별 isolate·isolate static 비공유→cross-shard 오염 경로 없음). 증상(병렬-only·serial green)은 *순서의존* 아닌 *병렬 자원/타이밍 경합* 가능성(미분해·N=1) | **randomize-ordering-seed 폐기**(순서도구라 병렬경합 미타격·순서검사는 serial=이미 green). ⓐ(eval 러너·단일출처) "`flutter test` **기본/명시 concurrency(>1)로 ×N회 전회 green**" 결정검사(**차원 아님·기계 게이트**) ⓑ(8차 선분해) 병렬 N회 로그로 실패양태(파일·단언·serial 대비) 분해→경합/순서/잔존상태 가린 뒤 코퍼스 처방 ⓒ(코퍼스 (a) 격하) impl-test 싱글톤 reset 규약=관행의 성문화(8차 행동 불변·reset만으론 미해소 가능 ⚠️) | 전: 병렬 flaky(잠재취약·미측정·N=1) → 후: 러너 게이트가 병렬 N회 green 요구로 포착. dim **(게이트)테스트 결정성**. ⚠️**차원→게이트 강등**·8차 선분해 후 코퍼스·소급금지 | 러너 게이트 `882cc0c` | **결정적 확정 + 도구버그 적발**: 양엔진 **병렬 ×5 전회 green**(7차 "flaky" 미재현 → N=1 grader 관측이었음). **단 게이트 1차 실행이 자체 버그 노출** — macOS bash 3.2 + `set -u`에서 빈 배열 `"${CONC_ARG[@]}"` unbound로 병렬 분기만 死("RED" 오보)·serial 분기는 정상("green") → 거짓 flaky 양태. **`${CONC_ARG[@]+...}` 안전관용구로 수정**(미커밋). 수정 후 양엔진 결정적. **코퍼스 처방 불요**(선분해 결과 flaky 아님) |

- **②원인 공통**: 7차 흠 대부분 *guide-only 칸의 엔진 런-변동 + 측정망 사각*. feedback-008(FC-2 vacuity·guide)이 6차 회복시킨 M4/아이콘이 7차 claude에 재회귀(진동)했고 feedback-009(@freezed 기계·ST-2 가이드)는 codex 6→7 적중 — **기계 floor 엔진불변 홀드·guide 취약** 재확인. 적대 2차 추가: **①의 진짜 레버는 코퍼스 산문이 아니라 골든/RUBRIC 측정 seam**(코퍼스만 고치면 8차도 green 가능).
- **③미러/단일출처**: `references/final.md` = `corpus_mirror_sync.py --write`(claude↔codex byte-동기·항목 1ⓐ·3ⓑ·4) / backstop·FC-GOLDEN·RUBRIC·EVAL·러너 = **단일출처(미러 불필요)**(항목 1ⓑⓒⓓ·2ⓑ·3ⓐ·5ⓐ). **코퍼스 *적용*은 별도 사용자 승인.**
- **④정직 표기**: 항목 1·4 guide+측정보강(8차 1차반증). 항목 2 백스톱·5 러너검사 기계 floor(변종포함 positive-control/일반검사 전제). 항목 3 *측정 명확화*(코드 결함 아님). 전부 N=1 — "적용 후 동시관찰"로 기록·확정엔 ≥2 런 또는 기계화 승격 필요.

## measure-first 선결 (eval 단일출처·8차 채점 착수 *전* 등록·소급 금지)
> EVAL-METHOD §0·§5 정합 — 아래는 코퍼스 아님(승인 불요)이나 *측정을 바꾸므로* 8차 빌드/채점 전 의도적 등록·문서화한다. **2026-06-18 적용 5/6**(④ 차기 동결창 보류·미적용).
1. ✅**FC-GOLDEN-WEATHER §2 M4 + §5 어댑터**(항목 1ⓑ·적용) — M4 주입사이트에 "날짜→문자열 직렬화 format step(DateTime→path)" 명시 + §5 seam 규칙(직렬화가 navigator/repo 거주=VM-override 구조적 미도달→도메인단위 직접 호출(VO.toApiPath)·integration seam).
2. ✅**RUBRIC VW-7 FAIL문언**(항목 1ⓒ·적용) — "뷰 onTap·**navigator·repo**가 도메인값 인라인 직렬화(`DateFormat().format(date)` 류·거주처 무관)"로 확장.
3. ✅**RUBRIC SD-3 주의**(항목 3ⓐ·적용) — SD-3 주의에 "safeApiCall 정규화 컨버터/parse-throw는 위반 아님(정상값 미차단·전이 invariant만 대상)·예외 타입만으로 WEAK 금지·parse는 도메인*Exception도 정답 아님" 경계 명시.
4. ⏸**RUBRIC Q-1 / 위젯 키 절**(항목 4·**보류**) — 위젯 키 관용을 Q-1 정의 포함/별도 절 여부는 차기 동결창 검토(현 Q-1=명명/타입 전용·미적용).
5. ✅**FC-GOLDEN G-7 ↔ A1 경계**(housekeeping·적용) — G-7 판정바에 "아이콘 distinct=A1 인간큐·치명 아님·**색 distinct만 자동 측정**" 명시(§3 N4 아이콘 부분도 이 경계·거짓 🟡 차단).
6. ✅**EVAL-METHOD §2.6 병렬 결정성 가드**(항목 5ⓐ·적용) — `flutter test` 병렬 concurrency>1 ×N(≥3) 전회 green 기계 게이트 + 실패양태 선분해·"isolate static 비공유→cross-shard 오염 불가·reset 실재·randomize-ordering 별축" 주의 등록.

## Phase 3 시술 (2026-06-18 · ②ST-8 백스톱 · ⑤러너 게이트)
- **② RV1 백스톱**(단일출처·미러 불필요): `dddart/scripts/src/check_riverpod.dart` 신설 + `backstop.dart` 배선(`_totalChecks` 57→58·**새 family `RV`**·검사ID `ST8`(check_structure 점유) 충돌 회피). 루트 합성(main.dart류 *touched*)에 전역 retry-OFF(`ProviderScope`/`ProviderContainer`의 `retry:` 인자) 부재면 RV1 발화·합성 0개=N/A 무발화. **positive-control**: `scripts/test/run_fixtures.sh` **F14a-d** — 부재 발화(7차 회귀 실표본)·ProviderScope(retry:) 침묵(6차)·**ProviderContainer+UncontrolledProviderScope 변종 침묵(5차 실표본 — 거짓-FAIL 반증)**·BC단독 N/A 무발화. **전체 21/21 PASS**·`dart analyze` clean.
- **⑤ 러너 병렬 결정성 게이트**(eval 단일출처): `workspace/eval/tools/parallel-determinism-gate.sh` 신설 — `flutter test` 병렬 ×N 전회 green=exit0 / red=exit2+양태 분해(serial·순서축 대조). EVAL-METHOD §2.6-5 포인터. **기계 게이트·차원 아님**·8차 실행 시 선분해 겸.
- **VW-7 과대범위 교정(positive-control 적발)**: measure-first VW-7/§3 '직렬화 거주' 문언이 positive-control navigator의 `'$id'`(int→String 식별자 전달)를 거짓-FAIL할 위험 → RUBRIC VW-7·architecture-ddd §3을 "**변환 로직 있는 직렬화**(날짜 포맷·다필드 조립)만, 단순 식별자 `'$id'`·String 전달 제외"로 정밀화·재미러(11/11 in-sync). *positive-control이 제 역할(규칙 변경 후 known-good 거짓-FAIL 차단).*

## 범위 제외 (수정 대상 아님 — 적대 2차 확증)
- **FC-1(G-7 아이콘 distinct)·FC-3(N4 아이콘 공유)** — **UI/A1·인간 오라클·스킬 무관**(적대 2차 반증 후 유지). architecture-ui §5는 아이콘 *자리*(ui_extension)·*방언*(`Icons.*`)만 강제·*어느 아이콘/충실도*는 design-review-ui·인간 오라클 위임. RUBRIC A1 "아이콘 비측정". G-7이 UI를 행위게이트로 박은 분류오류 → 차기 동결창 정리(위 measure-first 5).
- **N/A 슬롯**(SD-2·ST-4·HR-5·DT-7·ST-6·ST-7 등) — **결함 아님**(읽기전용 단일BC weather 미발화·적대 2차 "발화가능한데 누락된 차원 없음" 확인). 시나리오 확장은 별도 트랙 **보류**(사용자: "나중에").
- **codex ST-2(死필드)·SD-5(VO 거주)** — 7차 **만장 PASS**(feedback-009 ST-2 완전 해소·적대 2차 재확인).

## 적대 리뷰 반영 (본 세션·1차 11 + 2차 8 = 19 서브에이전트)
- **1차**(RCA 수립·~1.3M토큰): 포렌식 2파(navigator·아이콘·retry/flaky·codex 도메인·Q축·N4) + 적대 2파(엔진전용 옹호·결함 실재성·방법 건전성). confabulation 적발·폐기(가드-감사가 6차를 7차로 오인 → 7차 시트+소스+방법-적대로 폐기).
- **2차**(시술 직전·~642K토큰·`wf_24c44040-b60`): 항목 5 적대 + 교차 3(미러vs엔진전용·범위제외·반증가능성). **전건 file:line·6/7차 폴더 분리·confabulation 0.** 메인루프가 load-bearing 사실(VW-7·SD-3·repo:42·골든 M4·항목5 reset·use_super_parameters)을 실파일로 재검증해 v2에 반영.
- **2차 핵심 적발(전부 검증 완료)**:
  - **①**: RUBRIC VW-7(:44)이 이미 "직렬화 VO/VM 소유"·FAIL은 "뷰 onTap"만 명명(navigator 거주는 거짓✅) / claude repo:42가 navigator:22와 별개 직렬화 중복(navigator만 고치면 변이 표적 이동→재-green) / §3.4 VM-override seam은 `MaterialApp(home:)`로 실 GoRouter 미배선·navigator 직렬화 구조적 미도달 / 표시 포맷('EEE M/d')↔송신('yyyy-MM-dd') 패턴 구별 가능→약한 기계 floor 실현. → **진짜 레버=골든/RUBRIC 측정 seam**(코퍼스 산문 단독은 8차도 green 위험).
  - **③**: codex `.parse`는 기본생성자 무검증 + @JsonKey 컨버터/런타임 양용·safeApiCall:27 정규화로 **정상값 미차단·행위 안전** → SD-3(전이 invariant 검증)의 *parse*는 대상 모호(grader 2/3). "도메인*Exception 치환"은 parse를 전이위반으로 오분류 → 폐기. 측정 명확화로 전환.
  - **⑤**: Dart isolate는 static 비공유 → "cross-shard 싱글톤 오염" 메커니즘 불가·claude/codex **이미 reset 보유**·randomize-ordering-seed는 순서도구라 병렬경합 미타격. → 도구 교체(병렬 ×N green)·차원→게이트 강등·8차 선분해.
  - **②**: §8 산문 이미 명문(처방 a 잉여)·백스톱은 5차 `ProviderContainer+UncontrolledProviderScope` 변종을 거짓-FAIL(FP)·`ST8` ID 점유(충돌). → 변종포함 positive-control·신규 ID.
  - **④**: use_super_parameters lint가 평범 forward 이미 floor(처방 미언급)·dim 귀속 오류(Q-1 텍스트 밖)·§56 안정키 양립. → lint 분담·dim 라벨 정정.
  - **미러 평결(사용자 원질문)**: 5항목 중 엔진전용이 *엄밀히 더 나은* 항목 0. 미러 타당·강화. 단 *파이프라인 구조 산물*(finalize-collapse 등 6차 compare:39 "claude 발화·codex 미발화")은 코퍼스로 안 풀리는 엔진 아티팩트라 별도 트랙(010 범위 외).

## 회차 요약 (8차 검증 완료 · 2026-06-19)

> 결과지 `results/20260619-0124-weather-{claude,codex,compare,graders-raw}.md`. baseline `abee26d`·코퍼스 `cda1950`. **판정: claude FAIL(치명 FC-2)·codex PASS(TIER-Q 상).**

**예상 적중 5/5(측정 보강)·무효 1(코퍼스 산문 ①)·신규 발견 1·도구버그 수정 1·역효과 0.**

- **측정 보강(eval 단일출처) = 전건 작동**: ①골든 M4 seam(M4 양엔진 RED·7차 green-on-mut 해소)·VW-7 FAIL문언(claude misplacement 적발/codex PASS) / ②RV1 백스톱(무발화 정탐·F14 fixtures가 부재발화 입증) / ③SD-3 경계(codex grader 3/3 PASS·7차 진동 해소) / ④super.key(양엔진 클린·codex 회귀 복구) / ⑤러너 게이트(둘 다 결정적 확정). **measure-first가 7차 사각을 닫음.**
- **코퍼스 산문 ①(직렬화 거주·미러) = 무효(예고대로)**: architecture-ddd §3 규칙이 claude 직렬화 misplacement(7차 navigator→8차 view·N=1 진동)를 막지 못함 — **guide 취약 thesis 재확인**. 단 *측정망이 정확히 포착*(VW-7 WEAK + M4 red). → 기계화(custom_lint/AST/grep floor) 승격 재검 입력(미해결).
- **신규 발견 — claude FC-2 실패 사이트 이동**: 7차 M4(직렬화) vacuity를 고친 자리에서 8차 M3(목록 기온 슬롯) vacuity가 새로 노출. "FC-2 vacuity"는 단일 사이트가 아니라 *테스트 커버리지 전반의 진동*. 정본 mutation 전수(M1~M4) 실증 주입이 이를 포착(7차 M4 집중이라 M3 잠재). codex는 목록 카드 keyed slot 단언으로 M3까지 비-vacuous.
- **도구버그 수정 — 러너 게이트(`882cc0c` Phase 3 산출물의 1차 실행)**: macOS bash 3.2 `set -u` 빈배열 unbound로 병렬 분기 死("거짓 flaky" 오보). `${CONC_ARG[@]+...}`로 수정(미커밋). *measure-first/1차실행이 도구 자체 결함을 노출한 사례.*
- **codex 우위 축**: 직렬화 VO 단일거주(VW-7 모범·6/7/8차 일관·엔진 안정)·맞는 seam 테스트(도메인 단위·keyed slot)·super.key·parse 적법. **N=1 — "codex 항상 우수" 단정 금지**(6차 claude PASS·회차별 진동).
- **VW-6 해석 seam(부산물)**: grader 3/3이 codex 전역키 내비를 VW-6 FAIL 오인 → 조정자가 코퍼스 §6(처방 관용구)으로 PASS 정정. 차기 동결창: RUBRIC VW-6 FAIL문언에 "navigator §6 전역키 내비 제외" 한 구 추가 검토(measure-first 후보).

## 미해결 (검증·후속)
- **항목 1·4 = guide+측정보강** — 8차 실측이 M4 死/위젯키 재현 시 기계화(custom_lint·AST·항목1ⓓ grep floor) 승격 재검. 항목 1ⓑⓒ(골든/RUBRIC)는 8차 채점 전 등록 필수(measure-first).
- **항목 2 백스톱·항목 5 러너검사** — 변종포함 positive-control 반증(2)·병렬 ×N green 게이트 구현(5)이 시술 선결.
- **항목 3 = 측정 명확화** — RUBRIC SD-3 경계 명시(3ⓐ·8차 전)가 본체. §3 면제 factory 포함(3ⓑ)은 과추상화/중복 회피해 한 곳 통합.
- **항목 5 코퍼스 처방 보류** — 8차 병렬 N회 실패양태 선분해 후 자원경합/순서/잔존상태 판별·그 전엔 impl-test 성문화만(행동 불변 예상).
- **G-7 아이콘 정리·N/A 시나리오 확장** — 차기 동결창/별도 트랙(보류).
