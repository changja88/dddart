# dddart 채점 방법 v3.2 — 일관 채점 집행 사양 (어떻게 같은 라벨을 산출하나)

> **범위**: 이 문서 = 채점 *방법·집행*(빌드·결정∥의미 레인·역할 분리·항목별 결정-판정 표·치명 게이트·집계·완료). 채점 *항목* = `RUBRIC.md`(57차원). 고정 입력 = `tools/SCENARIO-*.md`. FC 사전등록 = 해당 SCENARIO의 `tools/FC-GOLDEN*.md`. 결과지 형식 = `rubric-metrix.md`.
> **북극성**: 산출물이 dddart 규칙(간소화 DDD·MVVM·하우스룰·관용구)을 지키고 기능을 올바르게 구현했는지를 *재현 가능하게* 채점한다 — **누가 채점해도 같은 산출물엔 같은 라벨**.
> **v3.1 전환(2026-06-13)**: v3(집행 레이어 신설)을 **7렌즈 적대 리뷰(32건 전수 교정)**로 보강. blind 배포본의 계층 라벨(경로 마스킹과 위치 판정의 양립), grep 정규식 표준화, 백스톱 매핑 누락(IM20·ST7) 보정, FC-2 주입 사이트 결정화, codegen produced/env 분리, 소급 FAIL 금지를 반영. dddjango EVAL-METHOD v3(검증된 모범)의 집행 장치를 dddart 57차원에 이식하되 **dddart 고유**(① /dddart 빌드가 채점 대상 생성 ② 백스톱 51종 ③ UI 행위 골든)를 반영.
> **v3.2 전환(2026-06-17)**: feedback-008 테스트 스킬(discipline-test·implementation-test)이 판정 검증을 위젯테스트→*맞는 seam*(판정=순수 도메인 단위 직접·view=VM-override 위젯·통합=Dio목/integration)으로 옮긴 데 맞춰 **FC-2 집행을 seam-일반화**(§2.3·§2.5·`tools/FC-GOLDEN-WEATHER.md §2·§5`). **기준 변경이 아니라 유효화** — 측정 대상(골든 행위의 비-vacuity)은 불변이고 mutation을 *코드 모양*에 맞춰 정확히 꽂을 뿐이다. **불변 3조 보존**: ① floor는 *골든 행위별*(seam에 테스트 존재로 대체 불가) ② 코드/주입사이트 부재·vacuous=FAIL(정렬은 *뒤섞은 입력* 필수) ③ FC-2 치명·이진·WEAK금지. **seam은 *코드가 판정을 둔 위치*를 따른다**(정렬이 VM 거주면 VM-override 테스트가 red — `tools/positive-control` 정렬=VM과 비충돌·거주 강제 아님). 디코이는 새 게이트 아님(직접모순=FC-1+green-on-correct 포섭·약화단위=A13·vacuity=floor). 소급 FAIL 금지(§5 — 산출 시점 커밋 기준).
> **인과 한계(과대주장 차단)**: 이 채점은 산출물이 규칙을 *지킨 수준*과 기능 정확성을 측정한다 — baseline 대비 인과 기여는 측정 밖(N=1 단정 금지·`RUBRIC.md` 비측정 절 정합).
> **표준 버전 시점(소급 FAIL 금지)**: 산출물은 *그 산출 시점의 코퍼스 커밋*(결과지 헤더 기록) 기준 RUBRIC으로 채점한다. 이후 RUBRIC/코퍼스가 개정돼도 이전 산출분을 새 기준으로 소급 FAIL 처리하지 않으며, 채점 근거 §조항은 산출 당시 커밋으로 인용한다(기준의 *올바른 적용 교정*은 소급 아님·기준 변경도 아님).

---

## §0 동결 게이트 (채점 착수 전 — 사용자 "동결됨" 확인 필수)

**미동결 상태로 채점하면 §5 사전등록을 자동 위반한다(채점 중 기준 확정 = 사후 합리화).**

> ⛔ **아래가 전부 해소되고 `RUBRIC.md`·이 문서 헤더가 "동결됨"으로 바뀌기 전에는 어떤 산출물도 채점하지 않는다.**

1. **RUBRIC 동결**: `RUBRIC.md`의 차원·PASS/FAIL·레인·치명 18 목록(+**FID-L1·L2** — §H 활성 조건 3선결 충족 2026-06-19·**치명 20 활성**·9차부터 집계 산입·소급 없음)(채점 중 추가·삭제·기준 변경 금지 — §5).
2. **고정 입력 동결**: 채점할 `SCENARIO-S*.md` §1(task verbatim)·§2(baseline 커밋)·§4(게이트 답).
3. **FC 골든 표 사전등록**: **해당 SCENARIO의 FC-GOLDEN**(S1=`tools/FC-GOLDEN.md`; **S2·S3은 채점 전 별도 작성** — 미작성이면 그 시나리오 채점 착수 불가)의 골든 행위표·mutation을 **코드 열람 전·채점 전**에 동결(작성자⊥채점자·미열람 선언·§2.5). mutation 수는 시나리오별 가변(S1=정렬·중요·배지 3종).
4. **환경 동결·기록**: 모델·effort·채점일·baseline 커밋·코퍼스 커밋·**코드젠 도구 환경 스냅샷**(§6.2)을 결과지 헤더에.
5. **백스톱 결정성 baseline 확인**: `.dddart/backstop-baseline.json`(CY1 순환 래칫)이 baseline 커밋에 존재·동결(채점 중 `--update-baseline` 금지 — 순환 래칫 무력화 방지).
6. **Positive control 확인(A12 — 거짓-FAIL 기계 차단)**: 채점 기계가 *known-good을 PASS시킬 수 있음*이 입증돼 있어야 한다. **dddart 규약을 준수하도록 작성된 합성 known-good fixture**(에러표시=view `ref.listen`·UseCase가 Either 통과·`if(!ref.mounted)return` 가드·계층 역류 0)를 `tools/`에 사전등록하고, 채점 기계가 그것을 **치명 18 전수 PASS·TIER-Q 상**으로 통과시키는지 1회 확인한다. *주의*: HaffHaff 원본은 기준점 *방언*이되 dddart가 에러표시·계층에서 *의도적으로 더 엄격*(architecture-ddd §5 UI호출 금지·architecture-ui §7 show() 금지로 HaffHaff `ErrorDialog.show()` drift 교정)이라 **그대로는 positive control 후보가 아니다**(known-good이 치명 게이트 FAIL = 정탐). **이 게이트 미통과 상태에서 산출한 모든 픽스처 FAIL에는 '기계 결함 가능성 미배제' 단서를 결과지에 단다**(거짓-FAIL 기계 배제 전까지 FAIL은 잠정). **현재 등록·검증됨**: `tools/positive-control/`(합성 공지 BC — 치명 18 PASS·`flutter analyze` "No issues found!"·mutation 3/3 red 실증·2026-06-14·채점지 `tools/positive-control/README.md`)가 이 게이트를 충족한다 → 현행 코퍼스 기준 거짓-FAIL 기계 아님 확정. 코퍼스가 치명 게이트 정의·관용구를 개정하면 재검한다. **FID 게이트(조건부·feedback-011)**: FID-L1·L2를 치명으로 활성하려면 *별도* positive-control `tools/positive-control/fid/`(등가 재구성 표본 — 같은 layout-ir의 묶음/래퍼 차이 변종이 L2 평탄화 비교에서 거짓-FAIL 0임을 반증)가 선결이다. **step 2a·2b 완료**: layout-ir 평탄화 반증(`fixture/run.sh` 7케이스 — 등가 group/block/hero text 흡수=PASS·진짜 차이[누락·순서·영역]=FAIL)·코드 렌더 덤프(`dump_probe.dart.txt`+`dump_to_ir.dart`) 8차 실물 등가 흡수·`_collapse` false regression 0. **표준 pump 진입점 규약(`implementation-test §7 screenProbes`·코퍼스 양판 미러·승인 2026-06-19)으로 3선결 완비 → 게이트 활성** → FID-L1·L2=치명(18→20)·L3=약신호·9차부터 집계 산입(소급 없음). **9차가 `screenProbes` 자동 경로 첫 운용**(N=1·effect size·false regression율 9차 실측). 산출물이 `screenProbes`를 노출하지 않으면(코더 규약 미준수)만 렌더 덤프 불가 → 그 런 A1 폴백+규약위반 기록(결과지 FID ➖·coordinator 수기 게이트 흉내 금지·blind 보존·`RUBRIC.md §H`).

## §1 산출물 빌드 (채점 대상 생성 — dddart 고유 단계)

dddjango는 이미 산출된 fixture를 채점하나, dddart는 `/dddart`를 구동해 채점 대상을 *생성*한다.

1. **baseline 복제**: `SCENARIO §2` baseline 작업트리를 **단일 커밋으로 굳히고 그 해시를 결과지 헤더에 기록**. 두 안 비교 시 *같은 baseline 커밋의 깨끗한 복제* 2벌(`git worktree` 또는 복제 디렉터리)에서 각각 출발.
2. **`/dddart` 구동**: `SCENARIO §1` 프롬프트 verbatim 투입, 게이트는 §4 답 고정. 산출물(생성 Flutter/Dart 코드 + `.dddart/<날짜>-*/` 스냅샷)이 채점 대상.
3. **자기보고 불신**(dddjango 관례·`RUBRIC.md` 정합): coder·Coordinator "완료" 보고를 **믿지 않고** 조정자가 산출물·transcript·`git diff`·`flutter analyze`·**백스톱 러너**로 직접 채점한다. 부재 단정 시 명령+출력 인용(§2.6).
4. **변경 집합 고정 (백스톱 `--diff-base` 주입)**: 백스톱은 added/touched 게이트라 `--diff-base <baseline 커밋>`을 **반드시 주입**한다(생략 시 전역 퇴화→레거시 발견 폭주·`backstop.dart:73-79`). 신규 BC는 대부분 신규 파일이나, 기존 BC 수정분(router·root branch 배선)은 touched로 잡히므로 baseline 대비 diff가 변경 집합의 정본이다.
5. **codegen produced/env 분리**(e-lens): codegen 의존(`build_runner`·`freezed`·`json_serializable`·`retrofit_generator`·`riverpod_generator`)의 pubspec 핀은 **코더 책무(produced = `git diff <baseline>`의 pubspec.yaml dev_dependencies)**다. BG-1은 *코더가 핀한* 의존으로 `dart pub get`→`build_runner build`가 성공하는지로 판정하며, baseline·전역 활성 도구가 코더 핀 누락을 가리지 않게 baseline pubspec 상태와의 diff를 함께 인용한다. 조정자가 채점 위해 추가·활성화한 도구는 produced에서 배제하고 `(조정자 추가)` 태그(§6.2 헤더 스냅샷). **조정자는 코더 핀 *버전*을 변경하지 않는다(A7)** — 핀 누락·과거 버전으로 BG-1이 깨지면 그대로 FAIL 근거이지, 조정자가 버전을 올려 통과시키면 produced 왜곡(핀 업그레이드 금지·`(조정자 추가)`는 *부재 도구 보강*만 허용·기존 핀 *상향* 아님).

---

## §2 채점 프로토콜 — 결정 레인 ∥ 의미 레인 (일관 채점 집행 핵심)

### §2.0 역할 분리 (blind 집행 메커니즘)

blind는 *설계 의도*가 아니라 *집행*이어야 한다. 행위자를 분리한다(dddjango §1.0 이식).

- **조정자(coordinator) 1명**: 결정 레인(백스톱·`flutter analyze`·grep)을 실행하고 결과를 **봉인**한다. 산출물 출처(런타임·variant 라벨·앵커 위치·diff)를 보유하되 grader에게 넘기지 않는다. FC mutation 주입·테스트 실행(결정 레인 — 도메인 단위·위젯·integration 전 스위트)도 조정자가 수행. **조정자의 코드 열람·사이트 식별은 *기계적 위치 사실*만 산출한다** — "정렬 비교자 심볼이 파일 X에 존재"는 적되 "X가 domain이라 SD-1 PASS" 같은 *의미 적법성 결론*은 내리지 않는다(그 판정은 의미 grader 독립 몫·§2.4).
- **의미 grader N≥3**(조정자와 *별개 세션/인격*): 봉인된 결정 결과·출처 라벨·variant명을 **받지 못한 채** 의미 채점만 한다. 중 **1명은 적대 grader**("이 산출을 통과시키지 마라"). **적대 grader 필수 커버(A6)**: 적대 grader는 *결정 레인이 원리상 못 잡는 의미 변종*을 항목별로 명시 점검한다 — **HR-5 채널④(view) 디코이·SD-1 빈 wrapper·DT-1 Left no-op·VW-6 우회명 self-show·ST-8 동형 신호버스·함수형 provider 위장**(§2.1 백스톱 blind-spot 카드와 1:1 — 결정으로 안 닫히는 칸은 적대 grader 보고 의무).
- **blind 증거 영속(A3 교정)**: grader N명 각자의 *raw blind verdict*(차원별 Y/N + 줄인용·결정 결과·variant 미수령 상태 작성)를 결과지와 함께 `results/<…>-grader-<n>.md`로 **영속·커밋**한다 — "N명이 채점했다"를 *주장*이 아니라 *증거*로 남겨 단일 저자가 N목소리를 위장하는 것을 차단한다. **만장일치인데 per-grader 산출·κ(§2.2)가 둘 다 없으면 blind 붕괴 적신호**다.
- **비-Claude 오라클 의무(A3 교정·동종 사각 차단)**: 조정자·grader·FC 작성자가 전부 같은 모델 계열이면 'blind'는 *동종 증언*(in-family attestation)이지 독립 검증이 아니다 — 산출물도 채점자도 같은 계열이면 같은 사각(디자인 미인지·동일 추론 맹점)을 공유한다. **의미 레인 grader N명 중 최소 1명은 비-Claude 모델(또는 인간)**이어야 한다. 확보 불가 시 결과지 헤더 ⚠️에 "의미 레인 전원 동일 계열 — 독립성 미확보"를 명시한다.
- **FC 골든표 작성 인격은 적대 grader가 아니다**(b-lens 정합): 골든표 작성은 *조정자·의미 grader와 별개의 사전등록 전담 인격*이 맡아, "적대 grader 1명"을 규칙 의미 레인(SD·VW·ST 등)에 온전히 남긴다. 골든표 작성자는 그 산출물 FC 의미 채점에서만 제외(다른 차원은 무관).
- **결과지 비회람**: 결과지(variant·절대경로·파일:줄 포함)는 §2.4 봉인 해제 후 조정자 합성본이며, **채점이 끝나기 전 어떤 grader에게도 회람하지 않는다**. 두 안 비교 시 plan-a 결과지를 plan-b grader가 보지 않는다(학습 전이·variant 누수 차단).
- 한 행위자가 결정·의미를 겸하면 blind가 깨지므로 금지. **"결정 PASS면 의미 생략" 절대 금지** — 의미 레인은 *항상* 수행(§2.4).

#### variant 마스킹 집행 절차 (두 안 비교 시 — b-lens)
선언만으론 안 된다. 두 안의 *구조 형상*(어떤 파일이 한 슬라이스로 묶였나)이 plan-a(2분할)/plan-b(행위 세로)를 노출하므로:
1. grader에게는 **슬라이스/커밋 경계·생성 순서·반송 흔적을 제거한** 차원별 코드 모음만 준다(어느 파일이 어느 슬라이스였는지 비식별).
2. grader는 plan-a/b 구조 시그니처가 적힌 `SCENARIO §3`·이 문서 §4를 **수령하지 않는다**(조정자 전용).
3. 두 산출물을 동일 형식 익명 번들 2개(라벨 **X·Y**)로 제시 — 조정자만 X/Y↔plan-a/b 매핑 보유.

### §2.1 결정 레인 — 백스톱·analyze·grep

dddart의 강점: 제1 규약의 구조·명명·import 방향·BC 순환은 **백스톱 51종**(`dddart/scripts/backstop.dart`)이 의미 해석 0으로 판별한다. 결정 레인은 이를 1급 도구로 쓴다.

- **산출 = `{신호 有/無}` + 줄 인용 + blind-spot 카드**(원리상 못 보는 것).
- **백스톱 실행**: `dart run dddart/scripts/backstop.dart <산출물 루트> --diff-base <baseline> [--only st,im,nm,cy]`. **exit 0=clean / 1=사용·내부 오류 / 2=blocker**(발견 일괄 출력). exit 2의 각 Finding은 `검사ID·경로·줄·규칙·교정`을 담는다 — 그대로 결정 레인 근거로 인용.
- **`flutter analyze`**: BG-2(analyze green 래칫)·Q-1 일부(케이싱 lint)·BG-1(codegen 후 컴파일). codegen은 `dart run build_runner build` **후** analyze(미실행 시 `.g.dart` 부재로 위양성).
- **grep/구조 스크립트**: 백스톱이 안 보는 결정 술어는 §2.6의 **표준 grep 명령 형태**(정규식·검색 루트 고정)로 닫는다 — bare 토큰 직접 치기 금지(공백·메타문자 변형 비매칭 위험).
- **codegen 면제와 손작성 차단**: 백스톱은 `.g.dart`·`.freezed.dart`를 검사 대상에서 제외하나, 조정자는 BG-1 `build_runner build` **후** `git diff`로 codegen이 *생성기 출력과 일치*함을 확인한다 — 불일치(손으로 도메인 분기를 codegen-명 파일에 숨김)면 손작성 의심으로 결정+의미 레인 정상 적용. **BG-1 재생성이 손작성 codegen-명 파일을 덮어쓰는 것이 1차 반-게이밍 장치**(컴파일 깨짐 또는 위반 표면화).

#### 백스톱 러너 ↔ RUBRIC 차원 매핑 표 (② — 실독 기반·검사 ID 단위)

> 각 러너가 *실제로* 보는 차원의 **결정 부분**. "닫힘"=백스톱 exit로 그 차원 FAIL이 직접 잡힘. "부분"=백스톱은 일부만, 의미 레인이 나머지(빈혈·디코이·판정 누수). **게이트**: ST·NM=added 파일 / IM=touched의 added 줄 / ST4=신규 단위 / CY1=전역+baseline.

| 러너(검사 수) | 주 커버 차원 | 핵심 검사 ID → 차원 | 결정 닫힘? | blind-spot(원리상 못 봄) |
|---|---|---|---|---|
| **check_structure (ST 12)** | HR-1·HR-2·HR-3·HR-7·HR-9 | ST0·1·2·3→**HR-1** / ST6→**HR-2**·HR-9(infra평면) / ST4→**HR-3**(골격) / ST5→HR-1(domain 트리) / **ST7→HR-7·HR-2**(구명칭·폐지 폴더 deny) / ST8·9→**HR-7** / ST10→HR-7·**VW-4**(foundation 7) / ST11→HR-7(common 5종) / ST2→**VW-7**(BC router 직속) | **HR-1·2·3 닫힘 / HR-9 부분**(infra평면만·분할후 성장규율은 의미) | 폴더·파일 *존재/위치*만 — 내용 빈혈(빈 골격 HR-3 PASS≠실질), codegen, 레거시(added 밖) |
| **check_imports (IM 22)** | HR-4·HR-5·HR-7 | IM1·11·12·17·18·19→**HR-4**(역류) / IM5→**HR-5**(4채널) / IM2·3·4·6·13·15·16→**HR-7** / IM7·12(BuildContext)→**ST-1**(VM직행)·**SD-7**(UI호출) / IM8(WidgetRef)·9→**VW-3** / IM10·**20**·21·22→**VW-7**(navigator/router; IM20=use_case·state·shared_state→navigator 금지) / IM13→**VW-4** / IM14→HR-7 | HR-4·5 **닫힘**(방향·경로) | import *경로/토큰*만 — 동적 import, 별칭 우회, 의미(Either 폐기·판정 위장·**채널④ view 디코이**), codegen, 레거시 줄 |
| **check_naming (NM 16)** | HR-6·HR-2·HR-8 | NM2·3·15·**11**(foundation App접두·lowerCamel)→**HR-6** / NM1→**HR-2** / NM4·5·6→**HR-8**(삼총사·접두) / NM7·8→**ST-5**(@riverpod위치·HR권위) / NM9→**VW-3** / NM10→**VW-4**(시각리터럴; NM11은 명명 검사라 VW-4 아님) / NM12→HR-7 / NM13→**VW-7** / NM14→**VW-5**(ui_ext 파일순도만) / NM16→**DT-5** | **HR-6·2 닫힘 / HR-8 부분**(삼총사 존재·접두만·실질은 의미) | 파일명·접미사·토큰만 — Q-1 케이싱 대부분(SCREAMING_CAPS·헝가리안) 미커버(NM11 한정), NM9 근사(별칭·복잡식 못 봄), **NM14는 ui_ext 파일순도만(VW-5 누수 자리=VM/State는 미커버)**, codegen, 레거시 |
| **check_cycles (CY 1)** | HR-5(신규 순환) | CY1→**HR-5**(BC 신규 순환 0) | **닫힘**(쌍 단위·방향) | BC *간* import 순환만 — BC 내부·계층 순환·**SD-1과 무관**(판정 소유 아님), baseline 등록 쌍 불발화 |

> **매핑 교정 기록(plan 잠정 추정·1차 v3 대비)**: ① CY1은 HR-5 전담, **SD-1 무관**. ② IM·NM은 HR 외 ST-1·VW-3·4·5·7·SD-7·DT-5·ST-5의 *결정 부분*까지 커버(IM20·ST7·NM11 보정 포함). ③ Q-1은 백스톱 거의 미커버 — NM11(foundation)만, 본체는 `flutter analyze`+의미. ④ HR-8·HR-9는 **부분**(빈 삼총사 실질·분할후 성장규율은 의미 전담).

#### added/신규 판정

dddart는 신규 BC라 dddjango "기존 앱 대체 판정 적재"(마스크 C) 복잡성이 대부분 불발이나, **added 판정은 백스톱에 내장**(`isTouched`/`isAdded`가 `--diff-base` git diff로 산출). 따라서 신규 파일은 전체가 added로 자동 처리, 기존 BC 수정분은 touched의 added 줄만 IM 발화(레거시 면책), codegen은 면제(§2.1 손작성 차단 단서).

### §2.2 의미 레인 (결정 결과에 **blind**)

- **이진 하위질문으로 분해**("잘 지켰나?" 금지). 예 SD-1: "이 새 판정/계산이 domain(애그리거트 메서드·domain_service·specification·VO/enum)에 거주하는가? VM·view·State getter에만 있지 않은가? (Y/N + 줄)".
- **🔴 필수 줄 인용** — 인용 없는 PASS·FAIL 무효. 빈혈·디코이·판정 누수(SD-1·ST-1 위장·DT-1 Left no-op)는 *코드 정독*으로만 잡힌다.
- **판정 바 = 표준 §근거 조항**(`RUBRIC.md` 각 항목 §근거); 앵커=예시로만 대조(임계값 아님·순환 방지).
- **grader 배포본 = 코드 본문 + *익명화된 계층/종류 라벨***(b-lens blocker 교정): SD-1·ST-1·VW-7·HR 등 다수 의미 술어가 "계층 위치 판정"이므로 **경로를 통째로 지우면 채점 불가**. 따라서 grader는 각 스니펫에 `L=domain_layer/<agg-1>`·`L=application_layer/view_model`·`L=presentation_layer/view` 같은 **계층·종류 토큰**을 함께 받는다 — **계층·종류는 보존, *인스턴스명은 익명 인덱스***(`<agg-1>`·`<agg-2>`…). **익명 치환 대상**(치환표는 조정자만 보유·§2.0): BC명·기능명·**애그리거트명·도메인 개념명**(dddart 규약상 애그리거트명≡BC명≡기능명이라 누설 시 blind 붕괴)·화면명·route명·실파일명·절대경로·줄번호·variant명, 그리고 **코드 본문의 도메인 식별자(클래스·필드·enum 이름: 예 `Announcement`·`isPinned`)는 *일관 치환***(같은 식별자→같은 익명 토큰 — 기능 정체를 가려 FC·단일 산출물 blind를 지키되, 철자 일관성(SD-9)·계층 거주(SD-1)는 일관 치환이라 관측 보존). "계층 라벨조차 없으면 채점 불가"인 항목(SD-1·ST-1·HR-1·VW-7)은 라벨 필수.
- **FC-1·FC-3는 익명-스니펫 규율의 예외**(b-lens): 코드 정독·행위 대조 항목이므로 grader는 *익명화된 산출물 전체 + 골든 행위표(어댑터 없이 외부 행위만)*를 받아 채점한다 — **예외는 스니펫 분할 면제일 뿐 마스킹 완화가 아니다**(위 일관 치환 — BC명·variant명·애그리거트/도메인 식별자·실파일명/경로, 두 안 비교 시 §2.0 슬라이스 평탄화까지 — 그대로 유지; 안 그러면 plan-a/b 구조 형상·기능 정체가 FC grader에 노출). FC-2 실행 어댑터(조정자 보유)는 red/green 실행 전용이며 FC-1 행위 대조는 grader가 외부 행위표로 독립 수행.
- **치명 보수 판정**: *치명 18 항목*은 2:1 split이어도 1명이라도 줄인용 동반 FAIL이면 보수 FAIL + 인간 큐. 비치명만 2:1→WEAK. 차원별 일치율(κ) 보고(N≥2) — **κ는 결과지에 차원별로 *반드시 출력*한다(A3): 만장일치 보드인데 κ 행·per-grader 산출(§2.0)이 둘 다 없으면 단일 저자 위장 적신호다.** **split 방향·동률 결정화(A8)**: 위 판정은 split *방향 무관*(FAIL이 다수든 소수든) — **치명** = ≥1 줄인용 FAIL이면 보수 FAIL(1:1 동률 포함); **비치명** = 만장일치 PASS만 PASS, ≥1 FAIL(1:1 동률 포함)이면 WEAK 상한, 만장일치 FAIL이면 FAIL.
- **rubric 사각 신고칸(A13 교정·채점 *미반영*)**: 각 grader는 raw verdict 말미에 **"현 RUBRIC 57차원으로는 안 잡히는데 위반/우려로 보이는 것"** 자유서술 1칸을 채운다(예: 시각 충실도·미측정 동작·차원 부재 사각·시나리오 미발화 의심·**산출 test 품질** — 정렬 단언이 입력≠기대를 쓰고 양끝 고정하나·위치 단언이 비대칭·음수로 슬롯 식별 강제하나·탭→상세가 비-edge+전달값 echo하나·N-구별이 충돌 시 자동 축소하나, *매처 이름 아닌 행위 술어로*). 이 칸은 **이번 채점 점수에 산입하지 않는다**(사전등록 동결 위반 방지·§5) — **다음 동결 라운드의 RUBRIC 개정 입력**으로만 수집하고 결과지 5.5절에 모은다. A1류 *차원-부재* 사각이 채점 중엔 안 드러나고 사후 적대리뷰에만 의존하던 공백을, grader 단계에서 상시 포착하는 안전판이다.

### §2.3 항목별 결정-판정 표 (① — 57차원)

치명 + 결정으로 닫히는 항목을 **우선 명문화**, 나머지는 `RUBRIC.md` 레인 칸이 1차다. 표의 grep 칸은 **정규식**(§2.6 표준 명령으로 실행 — bare 토큰 아님).

#### (A) 치명 게이트 18 — 전수 명문화 (이진 PASS/FAIL·WEAK 금지; FID-L1·L2 활성 시 20 — §A')

> 결정=백스톱 ID/analyze/grep(정규식) · 의미=grader 이진 하위질문 · blind-spot=결정 레인이 못 보는 것. **[결정 PASS ∧ 의미 FAIL]이면 치명 FAIL**(§2.4 Goodhart).

| 치명 항목 | 결정 명령 | 의미 이진 하위질문 | PASS 신호 | FAIL 신호 | blind-spot |
|---|---|---|---|---|---|
| **SD-1** 판정 소유 | (없음 — 의미 전담) | 새 판정·계산이 BC domain에 ≥1 거주? VM/view/State getter/ui_ext에만 있지 않나? *빈 wrapper* 아닌 실판정인가? | domain에 실판정 거주·VM은 변환만 | domain에 판정 0개 **또는** 빈 wrapper 위장 **또는** 단순변환 domain 과잉투입 | 백스톱 전무 — **순수 의미**. VM이 specification import·평가해도 SD-1(SD-6 아님) |
| **SD-2** 루트 경유 변경 | grep `\.copyWith\s*\(` 위치(Model 밖) | Model 밖 copyWith에 분기·계산·전이 조건이 붙나? 루트 메서드가 새 인스턴스 반환하나? | 전이는 루트 메서드 / 밖 copyWith는 단순 복제 | VM·UseCase·view copyWith에 분기·전이 | grep는 위치만 — "분기가 붙었나"는 의미 |
| **SD-7** UI 호출 금지(UseCase) | **backstop IM12** + grep UseCase의 `package:flutter/(material|widgets)` import (IM20=navigator→VW-7 소관·SD-7 아님) | UseCase가 무상태·도메인 위임·Either 통과(새 throw 0·침묵 폐기 0)·UI(재export 사슬 포함) import 0? | UI import 0·Either 끝까지 통과 | UI 호출(치명)·새 throw·실패 침묵 폐기 | IM12는 직접 flutter import만 — *재export 사슬*·침묵 폐기는 의미(DT-1 교차) |
| **VW-1** Fat Widget | (없음 — 의미 전담) | build/위젯 콜백이 표시·이벤트 위임만 하나? 권한·전이·가격 정책이 build에 없나? | 표시·위임만 | 정책이 build에 | 순수 의미 — VW vs SD 이중계상 금지 |
| **VW-6** show() 금지 | (없음 — 의미 전담; grep static `(show|present|display)`는 *후보 수집 보조*일 뿐 PASS 신호 아님) | 컴포넌트가 전역키/전역 context로 자기표시 static 경로 노출? 다이얼로그는 View가 자기 context로 호출? | (결정 닫힘 아님 — 의미 전담) 자기표시 static 0 | 전역 자기표시 static(이름 무관) | grep는 흔한 이름만 — **우회 명명(announce/popup/open)은 의미 전담**, grep 0건을 PASS 신호로 박제 금지 |
| **ST-1** VM 직행 | **backstop IM7·IM12**(BuildContext) | VM의 Model 방향 호출이 UseCase뿐인가? Repo/box/SDK 직행·BuildContext·UI 컨트롤러 미보유? | UseCase만·State만 노출 | Repo/box/SDK 직행·컨트롤러 보유 | IM7·12는 import/토큰 — *판정 누수*(VM 도메인 분기 후 State getter 위장)는 SD-1 단독 |
| **ST-2** 에러 2채널 | grep `\bvalueOrNull\b`(BG-1 교차)·`consumeError\s*\(` | 조회 실패=build throw→AsyncError? 액션 실패=State.error+listen+모든 경로(isShow 공히) consumeError 소비? throw 대상이 BadRequestResponse? | 2채널 정확·전 경로 소비 | 채널 혼선·plain throw·isShow:false 미소비·valueOrNull | consumeError *존재*는 grep, *모든 경로 소비*는 의미 |
| **ST-4** mounted 가드 | grep `await`·`ref\.mounted`·`requireValue` | await 직후 state 접근 전 `if(!ref.mounted)return`? 가드가 await 경계 안? 무전제 requireValue 아닌가? | await 경계마다 가드 | mounted 누락·가드가 경계 밖·무전제 requireValue | grep는 토큰 존재 — *경계 위치 정합*은 의미 |
| **DT-1** Either 실패 계약 | grep `Future<Either<`·`\.fold\s*\(`/`\.map\s*\(` | Repo 시그니처 Future<Either<BadReq,T>>? 모든 소비처가 Left 비폐기·상위 전달? fold Left 분기가 no-op 아닌가? | Left 비폐기·전달 | Either 미사용·Left fold no-op | grep는 fold *존재* — *Left 분기 no-op*은 의미(ST-2와 직교) |
| **DT-2** 단일 출구 | grep `\b(throw|rethrow)\b`(repo·infra)·`safeApiCall` | Repo·infra service throw/rethrow 0? 외부 호출 safeApiCall로 Either? 인터셉터 onError 통과? | throw 0·safeApiCall 감쌈 | throw 탈출·rethrow·인터셉터 에러 정규화 | grep는 throw 키워드 — *인터셉터 정규화*는 의미 |
| **HR-1** 4계층·BC 컨테이너 | **backstop ST0·1·2·3** | (결정 닫힘) | ST exit 0(해당 ID) | ST0/1/2/3 발화 | 위치만 — 빈 골격 실질은 HR-3·SD-1 교차 |
| **HR-4** 계층 import 역류 | **backstop IM1·11·12·17·18·19** | (결정 닫힘) | IM 역류 ID exit 0 | IM1/11/12/17/18/19 발화 | added 줄만·codegen 면제·동적 import 못 봄 |
| **HR-5** 교차 BC 4채널 | **backstop IM5 + CY1** | (IM5/CY1은 채널 *경로·방향* 닫음) **채널④(view) import가 실제 표시 임베드인가, 타 BC 상태·분기를 끌어오는 디코이인가? 채널① 타입이 빈 wrapper 우회인가?** | IM5·CY1 exit 0 ∧ 채널④ 실사용 정상 | IM5(채널 밖)·CY1(신규 순환) 발화 **또는 채널④ view 디코이** | IM5는 경로·방향만(`presentation_layer && view` 경로 통과) — **채널④ 실사용·채널① 빈혈은 의미 필수(SD-1·ST-1 교차·`RUBRIC.md` HR 주의 정합)** |
| **BG-1** 컴파일 가능 | `dart run build_runner build`(코더 핀 의존) → `flutter analyze`(error) | (결정 닫힘) | codegen·analyze error 0 | freezed 키워드/part/const X._() 누락·3.10+ 문법·valueOrNull | analyze가 못 잡는 런타임 크래시는 FC-2/행위 테스트. 코더 핀 누락은 §1.5 produced diff |
| **BG-2** analyze green 래칫 | `flutter analyze`(added 신규 이슈) | (결정 닫힘) | added 신규 error·warning 0 | added 코드 새 analyzer 이슈 | baseline 대비 신규만 — 레거시 이슈 면책 |
| **FC-1** 골든 오라클 | (의미 — 외부 오라클) | FC-GOLDEN 골든 행위표 전 케이스 일치? (예: S1=정렬·배지·새로고침·상세; 시나리오별 FC-GOLDEN 참조) | 전 케이스 일치 | 하나라도 불일치 | 코드 정독+행위 대조 — 사전등록 표가 척도 |
| **FC-2** 비-vacuous | mutation(시나리오별 N종) 각각 자기 사이트 주입 후 **행위 검증 테스트(맞는 seam — 판정=순수 단위·view=VM-override 위젯·통합=integration) red**(조정자 실행) | (결정 — 주입 실행) | mutation마다 red·메커니즘 **행위 검증 테스트** 검증 | mutation에도 green(헛 테스트)·**골든 두드리는 테스트(맞는 seam) 0개=즉시 FAIL(N/A 금지)** | 테스트 0개=비-vacuous 입증 불가=치명 FAIL. 사전등록 mutation이 척도 |
| **FC-3** 도메인 정합 | (의미 — negative gate) | 골든 결과 대비 명백한 도메인 오류(예: S1=중요 공지 하단·배지 누락·새로고침 미동작·정렬 역전) 부재? | 명백 오류 0 | 명백 오류 1+ | 의미 정독 — FC-1과 교차(골든이 1차) |

#### (A') FID 시각 충실도 — 조건부 게이트 (§0-6 활성 조건 충족 후 치명·그 전 리포트·약신호)

> 판정원 = **시안 layout-ir(`dddart/scripts/extract_layout.dart`) vs 생성 코드 렌더 덤프(`tools/dump_probe.dart.txt`+`tools/dump_to_ir.dart`)**의 결정론 대조(`tools/compare_layout.dart`·§3 평탄화). **결정 레인 전담**(구조 대조는 의미 grader 무관). **step 2a·2b 핵심 입증 완료**(8차 실측: L1 image/bottomnav 갭 결정론 포착·weekly card/metrics repeat 등가 흡수). **게이트 활성(2026-06-19)**: 표준 pump 진입점 규약(`implementation-test §7 screenProbes`·코퍼스 양판 미러·승인)으로 3선결 완비(hero 인접 text 흡수 false regression은 `_collapse` 보정·`run.sh` G 반증). L1·L2=치명(20)·**9차가 자동 경로 첫 운용**. `RUBRIC.md §H` 정합.

| FID 항목 | 판정원(결정·대조 도구) | PASS 신호 | FAIL 신호 | 거짓-FAIL 통제 / blind-spot |
|---|---|---|---|---|
| **FID-L1** 골격 | 렌더 덤프 `areas` role·순서 vs 시안 layout-ir `areas` | role 집합·종류·순서 일치(image·bottomnav 포함) | 영역 누락·종류 오인(section↔appbar)·순서변경 | 도구 부재 시 판정 불가 / 아이콘 심볼·미관=L4(A1) |
| **FID-L2** 섹션 구성 | section `children` 평탄화 시퀀스 대조(§3) | 평탄화 후 순서보존 일치·repeat-group 존재 일치 | 노드 누락·순서 뒤집힘·repeat↔단일 혼동 | **3겹 통제**: 등가 묶음=평탄화 흡수·measure-first 보정(fix 원장)·positive-control 반증 선결·repeat 횟수=제외 |
| **FID-L3** 슬롯 | unit/block `slot` type·width·align 대조 | slot 3축(type/width/align) 일치 | 슬롯 타입·배치 추상 불일치 | **약신호(⚠)·게이트 아님** → 사용자 눈 |

> **FID 집행 주의**: ① 도구(전부 구현·analyze clean) — 시안 파서=`dddart/scripts/extract_layout.dart`(**별도**·토큰은 `extract_design.dart`) / 대조=`tools/compare_layout.dart` / 코드 렌더 덤프=`tools/dump_probe.dart.txt`+`tools/dump_to_ir.dart`. ② 렌더 덤프는 표준 pump 진입점 규약(`implementation-test §7 screenProbes`·코퍼스 양판·feedback-011 항목 4) 전제 — 산출물 `_support.dart`가 `screenProbes`(role→펌프+루트 finder 맵)를 노출하면 `dump_probe`가 그 한 맵만 순회해 **배선 추론 0**으로 덤프(view·헬퍼·패키지 이름 비의존). **미노출 시만**(코더 규약 미준수) 렌더 덤프 불가 → 그 런 A1 폴백+규약위반 기록(결과지 FID ➖·coordinator 수기 게이트 흉내 금지·blind 보존·`RUBRIC.md §H`). ③ L4(미관·픽셀·아이콘 심볼)는 자동 판정 없음(§2.5 A1).

#### (B) 비치명 차원 — 축별 결정 명령 + RUBRIC 레인 위임

> **의미-위임 칸은 예시일 뿐** — `RUBRIC.md` 레인="결정+의미"인 *모든* 비치명 항목은 grep/백스톱 통과여도 의미 레인 의무(§2.0·§2.4). 백스톱이 닫는 것은 결정으로, 나머지는 의미 1차.

| 축 | 결정 명령(백스톱 ID·grep) | 의미 1차 위임(백스톱 미커버·결정+의미 전 항목) |
|---|---|---|
| **S-DDD** SD-3·4·5·6·8·9 | SD-9→grep 철자 drift(개념 동일성 식별은 의미) / SD-8→grep 비채택 폴더(event/·port/·acl/·dto/) 부재 | SD-3(예외 위치)·SD-4(VO 도메인 연산)·SD-5(애그 경계)·SD-6(domain_service 귀속)·SD-8 이름우회 변종·SD-9 개념 동일성 — 의미 |
| **S-VIEW** VW-2·3·4·5·7 | VW-3→**IM8·9·NM9** / VW-4→**IM13·NM10·ST10** / VW-5→**NM14**(ui_ext 파일순도만·누수자리 미커버) / VW-7→**IM10·20·21·22·NM13·ST2** | VW-2(3단 판별·과승격)·VW-3 prop 우회·**VW-4 VM/State 시각 getter 누수**·**VW-5 매핑 누수(VM/State)** — 의미 |
| **S-STATE** ST-3·5·6·7·8·9 | ST-3→grep State 위치·error 필드 / ST-5→**NM7·8** / ST-8→grep `retry:\s*\(_,\s*__\)\s*=>\s*null`·`valueOrNull`·`hooks_riverpod`·`copyWithPrevious` / ST-9→grep base/mixin VM | ST-5 함수형 위장·ST-6 교차 watch·ST-7 root 합성·**ST-8 동형(개명) 신호버스 위장**·**ST-9 합성/extension base VM 위장** — 의미(발화 시) |
| **S-DATA** DT-3·4·5·6·7·8·9 | DT-5→**NM16**(repo추상)·grep DI / DT-6→grep `@RestApi`·`part` / DT-8→`extract_contract` exit | DT-3(BadReq 어휘·isShow)·DT-4(이름바꾼 변환계층)·DT-7(hive)·DT-9(infra service 능동)·**DT-8 '계약 위험' 무표기/허위 표기** — 의미(조건부 발화) |
| **S-HR** HR-2·3·6·7·8·9 | HR-2→**NM1·ST6** / HR-3→**ST4** / HR-6→**NM2·3·15·NM11**(foundation App접두·lowerCamel) / HR-7→**IM2·3·4·6·13·15·16·ST7·8·10·11·NM12** / HR-8→**NM4·5·6·IM9** / HR-9→**ST6**(infra평면) | HR-7 common BC어휘·**HR-8 빈 삼총사 실질**·HR-9 분할후 성장규율 — 의미 |
| **TIER-Q** Q-1~9 | Q-1→`flutter analyze`(케이싱 lint·NM11 일부) / Q-2~9→grep + `flutter analyze` lint | Q-4·6·7(null·catch·구조 스멜) 의미 / 거짓 FAIL 함정(수치 하드컷·doc 강제·전면 grep) `RUBRIC.md` Q주의대로 면제 |

> **조건부 차원 S1 N/A 정본**(d-lens·`RUBRIC.md §동결 전 결정 5`와 글자 일치): **S1 N/A = DT-7**(hive 미사용·SCENARIO §2.2)·**DT-9**(SDK 어댑터 미사용·네트워크 전용)·**ST-6·ST-7**(교차 BC·root 미발생·SCENARIO §4 단일 BC). **DT-3은 별도 판정**: baseline이 BadRequestResponse를 이미 제공(SCENARIO §2)하면 DT-3 ➖N/A(계약은 baseline 소유); 산출물이 BadReq 필드·어휘·isShow를 **새로 정의·확장할 때만** 발화. ST-2(BadReq *사용* 정합)와 역할 분리. **미발화=N/A(점수 산입 0·FAIL 아님)·vacuous PASS 금지**(`RUBRIC.md` ST·DT 주의).

### §2.4 대조 — 측정의 주 산출물 (Goodhart 차단)

- 결정 ∥ 의미를 나란히. **`[결정 PASS ∧ 의미 FAIL]` = "의미적 변종"** 별도 플래그.
- **치명 18 항목의 의미 레인 FAIL은 결정 레인 PASS와 무관하게 치명 FAIL**(`RUBRIC.md` Goodhart 전역 규칙). 예: ST-1 결정(IM7 exit 0)이어도 VM이 빈 wrapper UseCase 경유로 도메인 분기를 State getter에 위장하면 SD-1 의미 FAIL→치명 FAIL.
- **FC-2 red/green은 *테스트 비-vacuous성*만 증언한다** — SD-1 거주 적법성("정렬이 domain에 사는 게 맞나")은 의미 grader가 독립 판정한다(조정자 어댑터 메모는 *위치 사실*, 적법성 결론 아님). 두 레인 독립 복원.
- **비치명 항목**의 의미적 변종은 WEAK 상한(§3). "결정 PASS면 의미 생략" 절대 금지 — status-객체/valueOrNull/이름우회(개명 DTO·위장 이벤트·함수형 provider 위장·동형 신호버스)는 의미 레인 전담.

### §2.5 FC 측정 (기능 정확성 — 해당 SCENARIO의 FC-GOLDEN 사전등록)

- **FC-1 골든 오라클**: **(주체)** 사전등록 전담 인격(적대 grader 아님·§2.0)이 **(시점)** SCENARIO 수령 직후·코드 *열람 전*에 **(형식)** *명세-독립 외부 행위표*를 FC-GOLDEN에 동결 + 타임스탬프 + "코드 미열람" 선언(열람 후 수정 금지·git diff 검증). **행위표 ⊥ 실행 어댑터**: 행위표는 코드 미열람 작성, *실제 두드릴 위젯·provider·route*는 산출물마다 달라 **조정자가 코드 열람 후 어댑터** 작성(어댑터 메모는 *위치 사실*만·§2.0). **작성자 ⊥ FC 채점자**(작성 인격은 그 산출물 FC 의미 채점 제외). **명세·생성 테스트는 오라클 불인정.**
- **FC-2 mutation**: FC-GOLDEN의 mutation(시나리오별 N종·S1=정렬·중요·배지 3종)을 코드 열람 전 동결. **주입 사이트는 각 mutation이 두드리는 골든 경로상 핵심 판정 *각각*** — S1은 M1·M2=정렬 비교자, M3=배지 매핑/ui_extension(서로 다른 계층이라 "1곳"이 아님). **동작 결정 위치가 여럿이면 전부 주입**(부분 주입 시 다른 경로가 살아 거짓 green); red가 1곳도 안 나면 그 경로가 死코드/중복임을 발견 로그에 기록. **mutation→red는 그 행위가 올바르게 사는 *맞는 seam*의 테스트에서 확인한다**(v3.2 — 테스트 스킬 정합): 판정(정렬·시간 양갈래=도메인 / **색 N-구별=ui_extension 매핑**)=**순수 단위 직접 호출**(위젯·provider 미펌프·seam A; ui_extension은 도메인 아님 — `discipline-test §3.1`이라 색 매핑에 "도메인 거주" 강요 금지) / view(슬롯 위치·탭 라우팅·표시 + **액션 실패의 State error 필드 반영**)=**VM-override 위젯테스트**(seam B·dddart엔 repo/usecase provider 없음 → 상태보유 VM변종만 override) / 네트워크 Left·통합=Dio목·`integration_test/`(seam C·드묾). seam은 *코드가 판정을 둔 위치*를 따른다(정렬이 VM 거주면 VM-override 테스트가 red — positive-control 정렬=VM 비충돌). **'정렬 두드리는 widget test 없음=미검증'은 범주 오인 금지**(도메인 단위테스트가 정답 seam일 수 있음) — *단, 맞는 seam에서도 골든을 두드리는 비-vacuous 테스트가 없거나 주입사이트가 死면 그대로 FAIL*(seam 재배치는 검증 책임의 *위치*만 옮기지 *면제*가 아님; 정렬은 *뒤섞은 입력*(입력≠기대)이라야 비-vacuous — 이미 정렬된 fixture는 무정렬 코드도 green). 그 seam의 테스트가 red면 PASS·green이면 FAIL(vacuous)·**테스트 0개면 즉시 FAIL**. **좁은 예외(A2)**: ① 골든 행위표의 *동적 행위가 0*(mutation 주입 대상 술어 0인 순수 정적 표시 BC)이면 FC-2 ➖N/A 가능(이때도 FC-1·FC-3 적용·degenerate 아님 입증 전제) ② *widget test 0*과 *총 테스트 0*을 구분 — 골든을 두드리는 **순수 도메인 단위테스트**·`integration_test/`·E2E로 검증하면 widget test가 0이어도 비-vacuous 인정(§2.6 수집 오라클이 `test/`·`integration_test/` 모두 포함). 둘 다 아닌 **순수 0(어느 seam에서도 골든 미검증)은 그대로 즉시 FAIL**(게이밍 차단 유지). 러너 = `dart run build_runner build` 선행 후 `flutter test`(전 스위트 — 판정=순수 도메인 단위테스트·재탭 2단·내비·새로고침=위젯테스트로 행위 검증). **디코이 라우팅**(FC-2 결정-레인 클로즈 아님): *직접 모순*형(골든과 반대를 정답으로 단언)은 정답 코드 위에선 red·버그를 가두면 FC-1이 잡음(포섭) / *약화 단위*형((아이콘,색) 쌍으로 색-distinct 우회)은 A13 사각신고칸 관측(코퍼스 `discipline-test §3.1` 정합) / *vacuity*형(이미 정렬된 fixture)은 위 floor가 차단 — **별도 디코이 게이트·축 신설 안 함**.
- **FC-3 도메인 정합**: 의미 grader가 골든 결과+코드 정독으로 명백한 도메인 오류 판정(negative gate).
- **시각/디자인 충실도 — 구조는 FID 결정 레인·미관은 인간(A1)**: 시각 충실도를 둘로 가른다. **(구조) 골격(L1)·섹션 구성(L2)·말단 슬롯(L3)**은 시안 layout-ir vs 렌더 덤프의 **결정론 대조(FID·§2.3 A')로 측정**한다 — 렌더를 *픽셀*로 보지 않고 *위젯 트리 구조*를 덤프해 대조하므로 코드 grader 한계(렌더 미관측)와 무관하다(FC가 *외부 행위*[정렬·매핑·내비]를 골든으로 재는 것과 짝). **(미관) 픽셀·간격·정렬 정확값·그림자·실제 색·아이콘 *심볼*·전체 미관(L4)**은 여전히 렌더 미관측이라 **사용자 육안 대조에 위임**(`SCENARIO §4 G2`·`RUNBOOK` `flutter run`·스크린샷 = 사용자·A1). ⚠️ **FID 게이트 활성 전**(도구·positive-control 미충족·§0-6)이면 L1·L2·L3는 *자동 채점하지 않고* 구조 충실도도 현행 A1(사용자 눈) 위임으로 남는다(결과지 FID 표 ➖·자동 FAIL 없음) — 결과지의 구조·기능·FID-PASS를 '화면이 시안대로'로 오독 금지(미관은 별도·헤더 ⚠️·§6.2). VW-4/5는 토큰·매핑 *거주*만, FID는 *시안 구조 일치* — 직교. (VLM/멀티모달 grader는 보류 — 재투입 트리거 = "구조 PASS인데 미관 회귀 패턴화"·`fidelity-eval-design §6`.)

### §2.6 채점 결정성 가드 — 부정 단정·수집 오라클·런-정지·인용 정밀도 (dddjango §1.5 이식)

자기보고 불신은 *채점자 자신의 부정 단정*에도 적용한다.

1. **수집 오라클 의무**: 테스트 존재·개수는 **`find <산출물루트> -name '*_test.dart'` 출력 인용**으로 판정한다(검색 루트=산출물 프로젝트 루트 — `test/`·`integration_test/` 전부 포함·test/ 한정 금지; Dart 단일 관례라 파일명 완전·실행 불필요·가정 금지). **`flutter test`는 행위 검증(FC-2)** 전용이며 *열거 도구가 아니다*(전 스위트 실행) — 반드시 `dart run build_runner build` 선행 후 실행한다(codegen 미선행 컴파일 실패를 "테스트 0건"으로 오기 금지 — dddjango lastlive-claude 오채점 재현 차단). 백스톱 0건 단정도 `backstop.dart ... ; echo "exit $?"` 출력 인용.
2. **부정 단정 = 출력 인용 의무**: "0건·부재·미설치·미작성" 류 단정은 그것을 산출한 **명령+출력 첨부 없이는 기재 금지**(§2.2 "인용 없는 PASS 무효"의 대칭). 의존성 부재 단정은 `pubspec.yaml`+`dart pub deps` 둘 다 인용. **결정 레인 grep 표준 명령 형태** = `grep -rnE '<정규식>' <산출물루트>/lib`(검색 루트·정규식 고정 — §2.3 표의 grep 칸은 전부 이 형태로 실행하며 bare 토큰을 평문으로 치지 않는다). **표 셀 정규식의 alternation은 `|`로 쓴다**(백틱 코드스팬 내라 GFM 표 안전) — `\|`로 이스케이프하지 않는다(ERE에서 `\|`는 *리터럴 파이프*라 항상 0건 오작동).
3. **런-정지 확인**: 채점 착수 전 산출물 최신 mtime(`.git`/`.dart_tool`/`build` 제외) 기록·채점 시작 시각과 대조해 헤더 박제. 미래 mtime·채점 중 변화 = 진행 중 런 → **채점 보류**.
4. **인용 행 해소 검증(인용 정밀도)**: 결과지·grader verdict의 `파일:줄` 인용은 *실재하는 행*을 가리켜야 한다 — 조정자는 합성 전 각 인용을 **파일 길이·해당 줄 내용과 1회 대조**한다(부재 행·범위 끝 과대 인용·다른 분기 지목 차단). 인용 불일치는 *판정을 뒤집지 않아도 신뢰도 흠*이므로 결과지에서 정정하고 발견 로그에 남긴다(메타검증 실측 흠: 부재 행 인용 2건·loading을 error로 지목·행범위 과대). **채점 루트 밖 파일(서버 등)은 줄·리터럴 정밀 인용 금지**(루트 외라 동결·재현 불가 — 예 `range(7)` 같은 서버 리터럴) → *행위 진술*("서버가 7일 순차 생성으로 결정적 오름차순 반환")로 대체한다.
5. **테스트 스위트 병렬 결정성(사전등록·8차 1차실행·measure-first 2026-06-18)**: green 빌드 재현성을 위해 산출물 `flutter test`를 **기본/명시 concurrency(>1)로 N회(≥3) 실행해 전회 exit 0**을 확인한다(**기계 게이트·주관 RUBRIC 차원 아님**·BG류). 실패 시 *실패 양태*(어느 파일·단언·serial(`--concurrency=1`) 대비 차이)를 분해해 자원/타이밍 경합 vs 순서 의존 vs 잔존 상태를 가린다 — 이것이 코퍼스 처방의 *선분해*다. **메커니즘 주의**: `flutter test`는 파일(suite)별 isolate·isolate는 static 미공유라 "병렬 cross-shard 싱글톤 오염"은 경로가 닫혀 있다(양엔진 7차 산출물은 이미 Dio 싱글톤 reset 보유) → reset 부재는 1차 가설이 아니고, `--test-randomize-ordering-seed`는 *순서 의존* 별축이라 병렬 경합을 대체하지 못한다(병행 가능하나 1차 도구 아님). 7차는 N=1 grader 관측·조정자 단일실행 green(잠재 취약성·미측정)이었다. 러너: `workspace/eval/tools/parallel-determinism-gate.sh <산출물루트> [N=5] [concurrency]`(전회 green=exit 0·red=exit 2+양태 분해).

---

## §3 집계·등급 (사전식 lexicographic — 가중 평균 금지)

```
1)   빌드 게이트(BG-1·BG-2): FAIL이면 산출물 무가치 → 픽스처 전체 FAIL, 종료(이하 결함 기록용).
2)   치명 게이트(18·+FID-L1·L2 활성 시 20): 하나라도 FAIL → 픽스처 전체 FAIL, 종료.
     ※ 치명 항목의 [결정PASS∧의미FAIL]도 여기서 FAIL(§2.4).
     ※ FID-L1·L2는 §0-6 활성 조건(도구+positive-control) 충족 시에만 치명 산입; 미충족이면 리포트·약신호(집계 0·RUBRIC §H).
2.5) 실질성 관문: 판정 유스케이스가 있어야 할 BC가 빈 골격(애그리거트 메서드·specification 실코드 0·import 그래프 0)이면 치명 FAIL.
     데이터소스/네트워크-전용 BC의 *의무* 빈 골격은 degenerate 아님(HR-3 정당).
3)   비치명 항목의 의미적 변종 ≥1 → "준수" 라벨 금지(상한 WEAK).
4)   통과 시에만 TIER-Q 등급(§3.2).
```

1. **빌드 게이트 먼저**: BG-1·BG-2 FAIL → 픽스처 전체 FAIL(이하 결함 기록용).
2. **치명 18 집계**: `RUBRIC.md §동결 전 결정 1`의 목록(SD-1·2·7 / VW-1·6 / ST-1·2·4 / DT-1·2 / HR-1·4·5 / BG-1·2 / FC-1·2·3 = **18개**). 이진 PASS/FAIL. 하나라도 FAIL → 픽스처 FAIL. **FID-L1·L2는 §H 활성 조건 충족 후에만 이 집계에 산입**(미충족 시 별도 FID 리포트 섹션으로 약신호만·치명 점수 불변).
3. **실질성 관문(step 2.5)**: SD-1 의미 레인이 1차 집행하되 집계에 명시 단계로 박제(빈혈 골격이 HR-3 결정 PASS로 빠져나가는 것 차단·dddjango §2.3 ③ 동형).
4. **TIER-Q 카운트 등급**: Q-1~9의 PASS/WEAK/FAIL 카운트. **상**=WEAK ≤2 ∧ FAIL 0 / **중**=WEAK ≤4 ∧ FAIL ≤1 / **하**=그 외. 거짓 FAIL 함정(수치 하드컷·전면 grep·doc 강제)은 `RUBRIC.md` Q주의대로 면제.
5. **범례**: ✅PASS · ❌FAIL · 🟡WEAK(비치명만) · ➖N/A(조건부 미발화).
6. **교차 채점(이중계상 방지)**: `RUBRIC.md §교차 채점 규칙`대로 단일 소유 축에서만 감점(판정 누수=SD-1, 구조 직행=ST-1, Left 비폐기=DT-1, 시각 매직=VW-4 등).
7. **N=1 인과 단정 금지**: 단일 산출물은 "이 산출물이 X를 어겼다"까지 — "플러그인이 *항상* X"라 단정 않는다. 보조 SCENARIO(S2·S3)로 신뢰도 상승.
8. **Positive control 미통과 시 FAIL 신뢰 한계(A12)**: §0-6 positive control 게이트가 통과되지 않은 상태의 픽스처 FAIL은 '기계가 known-good을 PASS시킴'이 미입증이라 **잠정 FAIL** — 한 줄 요지에 '기계 결함 가능성 미배제' 단서를 단다(거짓-FAIL 기계 배제 후 확정).

## §4 슬라이스 두 안 비교 (RUBRIC 적용의 한 사례 — §6 슬라이스 분할 확정)

본설계 §6 슬라이스 분할(안 1 Model/View 2분할 vs 안 2 행위 세로)을 같은 기능으로 비교 빌드해 확정한다. **두 산출물에 동일 `RUBRIC.md`·동일 결정-판정 표(§2.3)를 적용**하고, 추가로 *과정 지표*를 잰다.

1. **공정성**: `SCENARIO §1·§2·§4` verbatim 동일 투입, 안 2는 슬라이스 도출 절(§3)만 치환(원본 커맨드 불변), 독립 컨텍스트(학습 전이 차단), 같은 환경 연속 빌드. **grader는 variant 마스킹**(§2.0 집행 절차 — 익명 번들 X·Y·구조 시그니처 문서 미수령).
2. **두 축으로 비교**:
   - **산출물 품질**: 두 산출물을 `RUBRIC.md`로 채점 — 치명 18 PASS 여부·TIER-Q 등급·차원별 ✅❌ 차분.
   - **과정 지표**(차분만·절대값 아님): coder 호출 수 / 토큰 / 반송(G1'·감사·G2·재시도) / 재방문(완료 슬라이스 재수정). architect·리뷰어 호출·tracer·미니 게이트는 두 안 공통 → 차분 0(상쇄 기록).
3. **판정**: 산출물 품질이 갈리면 그 안, 동률이면 과정 지표 차분 → `slice-simulation.md §3` "갈림의 본질"(안 1=산출물 안정·안 2=과정 복원력)로 질적 해석. **이 명세는 G0·G1 거친 두꺼운 명세 → 안 1 유리 편향 명시**.
4. **커맨드 시뮬레이션 산출**: `/dddart` 첫 실전 구동 겸 — 발견한 커맨드·에이전트 결함은 별도 기록(후속 교정).
5. **과정 지표 비교 축 일반화(A9 교정)**: 위 §4.2 과정 지표(coder 호출 수·토큰·반송·재방문) 차분은 *슬라이스 분할 두 안*(plan-a/plan-b)뿐 아니라 **엔진 양판 비교**(codex vs claude·같은 SCENARIO §1 verbatim)에도 적용한다. 양판 라이브런에서 과정 비용 원장을 결과지/비교 집계지에 **차분으로** 기록해(절대값·인과 단정 금지·§3.7), '산출물 품질이 동률일 때 어느 엔진이 적은 과정 비용으로 도달했나'를 보조 신호로 남긴다. **comparability 단서**: 두 엔진은 내부 파이프라인(Coordinator 루프·게이트 형태)이 달라 절대값 비교는 무의미하고, *같은 사건 종류*(coder 호출·반송·재시도)의 차분과 *동률 시 보조*로만 읽는다 — 양판 결과지에 비용 원장이 0이던 공백(과정지표가 슬라이스 축에만 게이트되던 흠)을 닫는다.

## §5 과적합 방지 (사전등록·관찰집합 동결)

- **사전등록**(§0): RUBRIC·결정-판정 표·골든 표·mutation·기준을 채점 결과 보고 바꾸지 않는다. 바꿀 발견은 *다음 채점 동결 전*에만 반영·기록. **소급 FAIL 금지**(헤더 — 산출 시점 코퍼스 커밋 기준).
- **앵커 = 예시**(임계값 아님): 첫 산출물 후 앵커를 모으되 "플러그인이 낸 수준"을 PASS 바로 굳히지 않는다(바=코퍼스 표준 §조항·순환 방지). §2.3 표의 PASS 신호도 도메인 중립 유지(FC 행위는 FC-GOLDEN 참조·시나리오 어휘 고착 금지).
- **거짓 FAIL 차단**: `RUBRIC.md`의 예외(정적 view 합법·codegen 면제·기존 방향 우선·수치 가이드·중첩 직파싱 면제·조건부 N/A 등)를 무시한 일률 FAIL 금지.
- **새 형태 홀드아웃 + 커버리지 상한 census(축편향 교정)**: S1(신규·읽기전용 BC)은 형태 1종이라 **단일 read-only 시나리오로는 구조상 실측 불가인 차원 ~6–7개(≈11%/57)**가 남는다 — 발화할 코드 경로 자체가 시나리오에 없다. 이 차원들은 S1 결과지에서 **➖N/A(시나리오 미발화·점수 산입 0·FAIL 아님)**이되 *측정됨이 아니다* — **vacuous PASS 금지**(§2.3·§2.4). 완료 신뢰는 아래 census를 S2·S3로 닫아야 성립한다(N=1 보강·§3.7).
  - **S2(액션·상태 전이·교차 BC·다중 애그리거트)가 닫는 미발화**: SD-2(루트 경유 *전이* — S1은 갱신 부재)·SD-6(도메인서비스·교차 판정)·ST-6(SharedState·교차 BC watch)·ST-7(root 합성)·ST-2 *액션* 실패 채널(S1은 조회 채널만 발화)·SD-5 다중 엔티티.
  - **S3(로컬 캐시·SDK 어댑터)가 닫는 미발화**: DT-7(hive)·DT-9(infra service 능동 어댑터).
  - **입력 검증 발화 기능이 닫는 부분 발화**: SD-3(불변식 도메인 예외·VO 검증) — S1은 VO가 얇아 부분 발화(claude는 VO 폴더 빈 → 미발화).
  - **N/A 기인 구분**: *시나리오 설계* 기인 정본 = DT-7·DT-9·ST-6·ST-7(DT-3 별도·§2.3 정본); *읽기전용 기능 형상* 기인 = SD-2·SD-6. 둘 다 S2/S3 전까지 "미측정".
  - **착수 게이트**: S2·S3 채점은 그 시나리오 FC-GOLDEN(골든표·mutation) 사전등록 완료 전 §0에 막힌다(현재 미작성 = 착수 불가).

## §6 완료 판정 + 결과지 형식 동결

**채점 완료** = ① 결과지(`results/<YYYYMMDD-HHMM>-<scenario>-<variant>.md`, `rubric-metrix.md` 형식) — 빌드 게이트 + 치명 18(+FID 활성 시 20) + 차원별 판정 + FID(§2.5) + TIER-Q 등급 + 발견 로그 + 한 줄 요지 + ② (두 안 비교 시) 비교 집계지 + 본설계 §6 확정 + ③ 커맨드 결함 발견분 후속 기록.

### §6.1 결과지 형식 동결 (형식 표류 차단)

모든 신규 결과지는 `rubric-metrix.md`의 골격·순서·칼럼을 유지한다. 섹션 순서(어기면 형식 위반): 1.헤더(§6.2) → 2.빌드 게이트(BG·verdict-first) → 3.치명 18(칼럼 `축·ID·항목·종합·근거`·**per-ID 18행**·**FID 활성 시 +FID-L1·L2 2행=20**; 결정∥의미 분리는 의미적 변종 메타) → 4.차원별 판정(A.S-DDD→B.S-VIEW→C.S-STATE→D.S-DATA→E.S-HR·각 표 칼럼 `ID·항목·판정·근거`·**RUBRIC ID 순서 전 행**) → 4.5 FID 시각 충실도(FID-L1~L4·칼럼 `ID·항목·판정·근거`; 활성 시 L1·L2는 §3 치명표와 교차·미활성이면 리포트·약신호[⚠]·L3 약신호·L4=A1 비측정) → 5.TIER-Q 등급(`ID·항목·판정·근거`·Q-1~9) → 5.5 grader 패널 증거(per-grader raw verdict·차원별 κ·비-Claude 오라클 유무·**rubric 사각 신고**·A3/A13) → 6.의미적 변종/백스톱-blind 메타(*측정의 주 산출물*·조정자 노트보다 앞) → 7.발견 로그 → 8.잔여흠 원장 → 9.한 줄 요지(+두 안 비교 시 비교 집계지 부록).

### §6.2 헤더 블록 (필수 단서)

방법(v3.2) · 채점일 · 산출물 루트(절대경로) · variant(단일/plan-a/plan-b) · baseline 커밋 · 코퍼스 커밋 · 모델·effort · **코드젠 도구 환경 스냅샷**(`dart pub deps` + pubspec dev_dependencies 핀·`(조정자 추가)` 태그로 produced와 분리) · task(SCENARIO §1 verbatim) · 게이트 답(§4) · FC 골든 사전등록 여부·작성 시각 · N_grader(<3이면 명시)·**구성(비-Claude 오라클 유무·A3)** · 산출물 mtime·채점 시작 시각(§2.6 런-정지) · **positive control 통과 여부**(A12 — 미통과 시 FAIL에 기계결함 단서) · **⚠️** N=1·인과 단정 금지·앵커=예시·소급 FAIL 금지·자기보고 불신(조정자 직접 검증)·**시각 충실도: 구조(FID-L1·L2·L3) 측정 / 미관·픽셀·아이콘 심볼(L4) 비측정(A1) — FID 게이트 활성 여부 명기(미활성이면 구조도 리포트·사용자 눈; 구조·기능·FID-PASS ≠ 미관 시안 일치)**.

### §6.3 형식 금지

- ❌ **차원 표에서 `항목`(RUBRIC 이름) 칼럼 생략 금지** — §1 치명(`축·ID·항목·종합·근거`)·§2 차원별(`ID·항목·판정·근거`)·§3 TIER-Q(`ID·항목·판정·근거`) 표는 `rubric-metrix.md` 칼럼을 그대로 쓰고, **RUBRIC 표의 `ID·항목`을 1:1로 적는다**(ID만 적고 항목명 생략 금지). **RUBRIC ID 순서대로 전 행 유지**(SD-1~9·VW-1~7·ST-1~9·DT-1~9·HR-1~9·Q-1~9·치명18 전수) — 압축·생략 금지, 미발화는 ➖N/A 행으로 표기.
- ❌ 차원 표를 "치명/비치명 2군"으로 **대체** 금지(보조 표는 가능, per-축 표 제거 불가).
- ❌ 채점 *과정 서사*(v1→v2 수정 이력) 본문 박제 금지 — 최종 판정만.
- ❌ 백스톱 발화 0건·부재 단정을 명령+출력 인용 없이 기재 금지(§2.6).
- ❌ 미완 채점 중 결과지를 grader에게 회람 금지(§2.0 — 학습 전이·variant 누수).

(결과지 섹션·칼럼·필수 단서 상세 = `rubric-metrix.md` · 채점 항목 = `RUBRIC.md` · 고정 입력 = `tools/SCENARIO-<시나리오>.md` · FC 사전등록 = `tools/FC-GOLDEN-<시나리오>.md`〔라이브런 시나리오별 — 예: `SCENARIO-WEATHER`+`FC-GOLDEN-WEATHER`〕)
