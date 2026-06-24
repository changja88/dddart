# feedback-028 — ST-5 함수형 `Provider<UseCase>` DI seam · reviewer 의미감사 보강 (Q-7·HR-6 보류)

> 18차 라이브런(`20260624-1345`) codex 잔여 결함 ST-5·Q-7·HR-6 ROC. baseline `abee26d`·코퍼스 `75dac05`+fix027(working tree). 사용자 지시: 회귀/신규 판별 + 기존 fix 무효 이유 + 다면 ROC + 적대 리뷰 + 처방 계획(과적합·모순 절대 금지) + 계획 적대 리뷰. ultracode 허가.
> ROC 도시어: `scratchpad/roc-codex-st5-q7-hr6.md`. 워크플로 `wf_b1ff9fa8-f2c`(ROC 검증+1차 적대 반증·538k)·`wf_1265eafc-182`(계획 2차 적대 리뷰·250k).

## 증상 (18차 codex)

- **ST-5 🟡 WEAK(2:1·Y-g3 적대만)**: `lib/application/weather/application_layer/use_case/weather_forecast_use_case.dart:12-17` 에 무애너테이션 수기 함수형 `final Provider<WeatherForecastUseCase> ... = Provider<WeatherForecastUseCase>((Ref ref){...})` DI seam. VM provider는 @riverpod 클래스형 정상·UseCase DI만 함수형.
- **Q-7 🟡 WEAK(만장)**: press 효과 미구현(InkWell만·AnimatedScale 0)·`AppDuration.press`/`heroFade` 죽은토큰(인용 0)·매직넘버 width:96/112·size:36(fix020 토큰 후퇴).
- **HR-6 🟡 WEAK(2:1·Y-g2만)**: `root/handler/root_error_record_handler.dart`(RootErrorRecordHandler·plain 데이터 VO)가 `_handler`(이벤트원 전속) 접미사를 단 명명 의도 일탈.

## 회귀/신규 판별 + "기존 fix 왜 무효"

| 결함 | 판별 | 근본 원인 | 기존 fix 무효 이유 |
|---|---|---|---|
| **ST-5** | **간헐 재발**(codex 19런 중 3회: 06-14·06-16-0149·18차·14런 휴면 후 재발·claude는 0회) | 규율 **3중 존재**(architecture-state §2:48 "DI 없음·직접 생성"·houserules §4 규칙6:164 "UseCase=plain class"·implementation-riverpod §2:41 함수형 비채택/§9:129 legacy 비채택)인데 ① 결정적 백스톱이 `@riverpod` 애너테이션만 봄(**설계상 의도** — 2026-06-12-backstop-design.md:146·217이 수동/비-codegen provider를 "에이전트 영역"으로 명시 선언) ② reviewer DI-seam 감사(:77)가 **생성자형 `?? Default()`만 열거**·함수형 Provider 래핑 형태 이름 부재 | **이 형태를 막는 fix가 존재한 적 없음.** 누락이 아니라 미규정·간헐 |
| **Q-7** | 재발(N=4+) | **엔진 비결정**(press 인용수 런별 0/3/0/2/0·claude 구현/codex 미구현·17차조차 AnimatedScale(scale:1) vacuous·매직넘버는 design-tokens 추출 정상인데 토큰화만 출렁=**fix020 무결함**) | fix 적용한 적 없음 — feedback-019/021 **의도적 보류**(엔진 비결정·측정 빈곤·화석은 못 잡음) |
| **HR-6** | N=1 신규·경미 | `_handler` 의미론(트리주석·§4표로만 약하게 명시·결정론 미강제) 회색지대·파일명=클래스명 일치·형식 게이트 전부 통과·엔진 비결정(claude는 파일 미생성) | 미규정 영역·결정론 미강제 |

## 적대 리뷰 1: 백스톱 처방 기각 (3/3·BLOCKER 2·CONCERN 1)

제1 후보(백스톱 NM7/NM8을 함수형 `Provider<T>()`까지 확장)는 적대 반증으로 **기각**:
- **R1 과적합 BLOCKER + R3 CONCERN(공통·결정적)**: `2026-06-12-backstop-design.md:13`(고정밀 저-recall·확신 없으면 에이전트로) + `:146·:217` **수동/비-codegen provider = 백스톱 밖·에이전트(reviewer) 영역 명시 선언**. 백스톱 추가 = 의도된 설계 결정 역전. RUBRIC:61 ST-5 레인='의미(+결정)'=grader 축.
- **R2 모순 BLOCKER**: ID 충돌(ST5=check_structure §3.2 점유)·family 오배치(RV)·codex측 check_riverpod.dart 부재(양판 비대칭)·§9 legacy 신호=`/legacy.dart` import(`.g.dart` 아님).
- 확립 패턴(feedback-018/021/024/027)·grader(graders-raw:44)·compare(:65) 모두 처방 경로로 **architect 명세 + reviewer 의미감사** 지목(백스톱 아님).

## ★처방 (시술 완료·다음 런 동결) — ST-5만

**(A) reviewer DI-seam 의미감사에 provider 래핑 형태 1문장 추가** (양판 수동 미러):
- `dddart/agents/discipline-reviewer.md:77` ∥ `codex-dddart/skills/dddart-discipline-reviewer/SKILL.md:78` (DI-seam bullet·byte-IDENTICAL) 끝에 추가:
  > 같은 no-DI 위반의 **provider 래핑 형태** — Model 관문(UseCase·Repo·DataSource)을 무애너테이션 수기 `Provider<T>((ref) => …)`(`@riverpod` 클래스형도, `legacy.dart` provider도 아닌 base Provider 생성자)로 감싸 노출하면 외부 치환용 DI seam이다(important·ST-5 동축). 이들은 plain class로 사용처(VM)에서 직접 생성하며 provider가 되지 않는다 — `@riverpod` provider는 상태 보유 ViewModel 변종(VM·SharedState·Service·root 2변종)만이다(architecture-state §2·houserules §4·riverpod §2). 백스톱 NM7/NM8은 `@riverpod` 애너테이션만, riverpod_lint `unsupported_provider_value`는 `legacy.dart` 값만 보므로, 무애너테이션 수기 `Provider<T>`는 양쪽 모두에 형태상 비가시 — 이 의미 렌즈가 전담한다.

**근거**: reviewer:77이 이미 "DI seam ... 의미 렌즈 전담" 선언하나 생성자형만 열거 → 설계가 이미 reviewer에 할당한 책임을 **완성**(백스톱 기각과 상보). eval/golden/architect/backstop 무수정.

## 적대 리뷰 2: 계획 (A) 검증 (3/3 refuted=false·CONCERN — gap-closing 확정)

- **L1 과적합·오인용**: 과적합 무혐의("Model 관문" 코퍼스 정본 범용어). 교정 반영: "houserules §4-6"→**"§4"**(:164는 §4 규칙6·§6은 별주제·메인 검증 완료·state §2:48도 "§4 소유")·"함수형 provider"→**"base Provider 생성자"**.
- **L2 모순·거짓양성**: 모순 0(implementation-test §2:31 "useCaseProvider 부재라 override 불가" 기명시=재진술)·거짓양성 0(표적 좁음·rootRouter/위치인자/@riverpod carve)·이중감점 0(reviewer 생성측 ∥ grader 채점측). 교정 반영: **"(또는 legacy StateProvider 류)" 삭제**(StateProvider는 legacy.dart라 riverpod_lint+import로 이미 정적검출·진짜 사각은 plain `Provider<T>` 단일)·lint 사각 명시.
- **L3 ceremonial-vs-gap·측정**: **★(A)=ceremonial 아님·진짜 gap-closing**. reviewer:77은 생성자형만 구체 열거·전문 provider 형태 0건·gap 실증(κ=0.33·2/3 누락·feedback-018 "FORM 구체 열거=강제력" 적용). 교정 반영: "(important·ST-5 동축)" 귀속 명시.

## 측정 (다음 런 = 19차)

- **★floor-raising 비결정·grader 수렴 표적**: claude 0회·codex 간헐(N=3)=엔진 비결정. **비재현 시 효과 직접 측정 불능**(VW-4·FC-1 상속). 단 화석 아닌 양성 산출물이라 목표는 **검출+grader 수렴(κ 0.33→1.0·16차 FC-1 §0표 동일 메커니즘)**.
- 측정 방법: codex use_case/repo/data_source에서 `= Provider<` grep(재발 여부) + ST-5 grader κ(reviewer 보강이 grader 수렴 유도하는지).

## 보류 (무처방)

- **Q-7 = 보류 확정**(반증 실패·보류 강화): 엔진 비결정·press 미구현은 부재 화석이라 백스톱/reviewer로 잡기 어렵고 강제하면 과적합. feedback-019/021 동형. 매직넘버는 fix020 무결함(추출 정상·토큰화만 출렁).
- **HR-6 = 보류**(경미·회색지대·N=1 신규·엔진 비결정): 처방하려면 일반 helper 명명 자유 침범 위험. **N=2 재발 시 재검토**.

## 부수 위생 (✅처리 완료·별건·이번 ROC 무관)

- **codex-dddart `check_riverpod.dart` 부재**(claude 9 ∥ codex 8 백스톱) = RV1(전역 retry-OFF)이 codex 쪽에 미적용인 선재 divergence였음. **✅미러 완료**(2026-06-24·사용자 "처리해"):
  - `dddart/scripts/src/check_riverpod.dart` → `codex-dddart/skills/dddart/scripts/src/check_riverpod.dart` 복사(byte-IDENTICAL).
  - `dddart/scripts/backstop.dart` → codex 러너 복사(RV 배선 5곳: usage 2·import·`_totalChecks 57→58`·`if (familyOn('rv')) runRiverpod` — 두 러너 델타가 **정확히 RV뿐**이라 통째 복사로 byte-IDENTICAL).
  - 검증: codex `dart analyze` 클린(No issues found)·나머지 런타임 스크립트(check_* 8·extract_* 4·fetch_images·icon_map·common) 전부 byte-IDENTICAL → codex 백스톱이 claude와 완전 동등(RV 포함 8검사군).
  - **픽스처 하니스(`scripts/test/run_fixtures.sh`)는 claude 전용**(codex는 `test/` 디렉터리 git 이력 0건)=런타임 스크립트만 미러·하니스는 byte-identical 사본을 claude 쪽서 검증하는 dev 도구. 정상.
  - 영향: 처리 전엔 **잠복**(codex 최근 10런 모두 retry-OFF 자발 준수=물린 적 없음)이었으나, 미래 codex 런이 retry-OFF 떨구면(7차 claude 선례) 이제 codex 백스톱도 결정적 차단. 코퍼스 변경 → 다음 런 동결.

## 상태

- **시술 완료·미커밋**(사용자 승인 "st-5만 처방 진행"·2026-06-24). 커밋은 별도 지시 시.
- 코퍼스 변경(reviewer 양판 2파일) → **다음 런(19차) 동결**.
