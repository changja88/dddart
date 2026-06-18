# dddart rubric 개선 — 테스트 스킬 평가 (확정 설계 v2 · 동결됨 2026-06-17)

> **현재 상태(2026-06-17·brainstorming 종료·설계 확정)**: feedback-008(테스트 스킬 2종) 커밋 완료(`d18f2d1`). brainstorming 결론 = **새 채점 차원 신설 불필요** — FC-1/G-7이 색충돌을·FC-2가 헛테스트를 *이미* 측정한다(rubric은 판사이지 피고가 아님). 대신 스킬이 *산출물 모양을 바꿨으므로*(판정=도메인 단위테스트·view=VM-override 위젯테스트) **기존 FC-2 측정을 새 seam에 맞게 *유효화*하는 보정**이 필요하다(안 하면 6차 채점이 올바른 도메인 단위테스트를 거짓 FAIL). 아래 **§확정 설계**가 정본(이하 §목표~§제약은 그 결론에 이른 분석). **동결됨(2026-06-17)** → **6차 feedback-009 완료** → **feedback-010 v2 전부 적용·커밋(measure-first 5건+코퍼스 산문 3건 `327640c` · Phase 3 ②RV1 backstop·⑤러너·VW-7 교정 `882cc0c`·2026-06-18) — 다음 = 8차 라이브런(사용자 드라이브)**(아래 **§7차 라이브런 → feedback-010**이 compact 재개 앵커). 동결 후 소급 변경 금지(`EVAL-METHOD.md §0`·§5). 코퍼스 불변(eval-side·양판 미러·백스톱 무관). 프로젝트 밖 writing 금지·메모리 보류.

## 7차 라이브런 → feedback-010 v2 (전부 적용·커밋 327640c+882cc0c · 다음=8차 라이브런 · compact 재개 앵커 · 2026-06-18)

> **feedback-010 사전등록 v2(적대2차 8서브에이전트 정정 반영).** compact/재개 = **(1) measure-first 선결 6건(eval 단일출처·8차 채점 *전*·소급금지): 골든 M4 seam·VW-7 FAIL문언·SD-3 FAIL문언·Q-1 dim·G-7/A1·러너 병렬게이트 → (2) 코퍼스 시술(승인 후): 미러 산문 ①ⓐ(직렬화 *테스트가능 도메인단위 거주*·VW-7정합·navigator 금지 아님)·③ⓑ(§3 컨버터 면제 1구)·④(super.key) `corpus_mirror_sync.py --write` + 단일출처 ②백스톱(변종포함 positive-control·신규ID)·⑤러너게이트. ⑤코퍼스 처방은 8차 선분해 후 보류.** 정본 = **`workspace/eval/fix/feedback-010-navseam-weaksweep-determinism.md`**(v2·measure-first 선결 절·Phase 3 시술 절 포함). **(1) measure-first 5건 + (2) 코퍼스 산문 3건(`327640c`) + Phase 3 ②RV1 backstop·⑤러너 게이트·VW-7 교정(`882cc0c`) 전부 적용·커밋·양미러 11/11.** compact/재개 다음 = **8차 라이브런(사용자 드라이브)·baseline=HEAD `882cc0c`** → 채점 시: RV1 backstop 발화 확인·M4 직렬화 red(골든 seam)·VW-7/SD-3 효과·러너 게이트(`workspace/eval/tools/parallel-determinism-gate.sh`) 병렬 선분해 → **feedback-010 ⑥ 실측 기입**. (④ RUBRIC Q-1 dim 차기 동결창 보류.) 결과지 4종 `results/20260618-1610-weather-{claude,codex,compare,graders-raw}.md`(커밋). 적대2차 워크플로우 `wf_24c44040-b60`(8에이전트·642K토큰). 코퍼스(산출) `a27c357`·**채점 골든 `f3f2b3e`(A13-1 정합)**·baseline `abee26d`. 런 폴더 `~/Desktop/dddart-run/dddart-20260618-1312-{claude,codex}`·6차 `-0012-`·5차 `-20260616-2025-`. 환경 Dart 3.12.1·Flutter 3.44.1.
>
> **판정**: **codex = 준수(PASS)** — 치명 17 전수·G-1~G-8 일치·FC-2 M1·M4 red·적대도 "근거 없음". / **claude = 보수 FAIL** — **FC-2 M4**(navigator 날짜 직렬화 死검증·조정자 직접 +1일 변이에도 green) + **G-7 인간 큐**(cloudy=overcast=`Icons.cloud`·아이콘 5 distinct·색 6·A1 경계·결과지 권장 A·**사용자 판단 미정**). ST-8 WEAK.
>
> **측정 목표 달성**: **A13-1(정렬) 정합 성공** — 6차 공통 "M1 정렬 死+vacuous"가 **양쪽 해소**(정렬 domain 거주·뒤섞은 입력 테스트·M1 red 직접 실증). 6차→7차 codex 역전(**N=1·인과 단정 금지**).
>
> **feedback-010 사전등록 v2(5건·`feedback-010-navseam-weaksweep-determinism.md`·미적용·8차 검증대기·적대2차 정정)**: ① **FC-2**(치명·**진짜레버=측정 seam**: 골든 M4에 직렬화 step·VW-7 FAIL문언에 navigator/repo·claude repo:42 중복 포함·코퍼스 산문은 "*테스트가능 도메인단위 거주*"로 VW-7정합(navigator 금지 아님)·guide+측정보강) ② **ST-8**(retry 백스톱·**산문 잉여**(§8 이미 명문)·변종포함 positive-control(5차 ProviderContainer)·신규ID(ST8 점유)·기계) ③ **SD-3 측정명확화**(codex `.parse` 적법·**도메인*Exception 치환 폐기**(parse≠전이위반)·RUBRIC SD-3 경계 명시·코드 교정 아님) ④ **위젯키 super.key**(impl-flutter 명문·**use_super_parameters lint가 평범 forward 이미 floor**·dim Q-1 텍스트밖·guide) ⑤ **테스트결정성 차원→게이트 강등**(isolate static 비공유→cross-shard 오염 **불가**·claude/codex **reset 실재**·randomize-ordering 폐기→**병렬 ×N green** 러너게이트·8차 선분해). **제외**(적대2차 확증): 아이콘 FC-1/3=UI/A1·인간 오라클·스킬 무관 / N/A=시나리오 미발화·결함 아님 / codex ST-2·SD-5=PASS. **적대 1차11+2차8 서브에이전트**: 1차 confabulation 1건 적발·폐기 / **2차 confabulation 0**(전건 file:line·6차0012/7차1312 분리)·**미러 강화**(엔진전용 엄밀우위 0·①④ 6차 정반대거동=진동 확증)·결정축 **기계 vs guide**·measure-first 선결 6건은 8차 채점 전 등록.
>
> 이후 → feedback-010 코퍼스 시술 → **8차 라이브런** → **[[stitch-image-asset-bundling]]** 이미지 기능(메모리). N/A 시나리오 확장도 후속 트랙.

## 6차 라이브런 → feedback-009 (적용 완료 · 2026-06-18)

> **6차 RCA → feedback-009 수립·적용·적대검증 완료.** compact 후 재개 = **7차 라이브런 준비**(`workspace/eval/tools/RUNBOOK-weather.md`). 정본은 **`workspace/eval/fix/feedback-009-st2-deadbranch-freezed-gate.md`**(적용 내역·적대검증 3패스·잔여). 아래 6차 findings/A13은 그 입력(역사 기록·대부분 feedback-009로 라우팅).
>
> **feedback-009 적용 요약(코퍼스·이 커밋):** **ST-2** 死분기 카브아웃(architecture-state §4)+reviewer 2-조건 트리거 / **@freezed** ddd §3 명령형+**백스톱 MD1·MD2 신설(55→57종·양엔진)** / **DT-5** no-DI 경계(state §2·data §1)+reviewer §6(백스톱은 🟡·N=1로 보류). G-8 무변경·finalize-collapse(항목5) 별도 트랙. **적대검증 3패스**(구현 후 MD `_read*(Map<)` FP 1건 적발→`!hasGen` 게이트 수정·F13 회귀잠금). 미러 11/11·run_fixtures 17/17·positive-control 0. **7차가 ST-2 PASS·수기모델 기계 차단을 실측**(인과는 N=1 주의·measure-first).

**채점 결과(커밋 `5e40c17`·결과지 4종 `results/20260618-0012-weather-{claude,codex,compare,graders-raw}.md`)** — 양판 **둘 다 ❌ FAIL**:
- **공통 = FC-2/M1**(정렬 死=서버순서 위임·정렬코드 0·order test가 사전정렬 fixture라 vacuous). 동결 룰 적용(소급 금지).
- **claude** = FC-2/M1 *단독*(치명 16 PASS·정규 dddart형: @freezed/json·clean 단일 에러채널·no-DI·정직 테스트·**역대 최청정**).
- **codex** = FC-2/M1 + **ST-2**(죽은 State.error 채널·VM 미set·view 死분기·consumeError 0·**3:0 만장**) + **FC-1/G-8**(라벨 "구름 많음"≠"구름많음"·cosmetic·인간큐) + WEAK군(전 모델 **수기 비-@freezed**·SD-4/DT-4/ST-3·전 계층 optional 주입 DT-5).
- **진전**: 5차 양판 공통 색 충돌·M3 vacuity·codex 디코이 → 6차 해소(**feedback-008 테스트 스킬 효과 시사**·N=1 인과 단정 금지). v3.2 seam 일반화 유효화 실증(codex 도메인·ui_ext 테스트 정확 인정).
- grader 3(n1·n2 중립·adv 적대)·전원 Claude·**비-Claude 오라클 0(⚠️ A3)**·positive-control 2026-06-14 검증 인용(백스톱 55 byte-불변).

**이미 조치(커밋 `2326dd0`)**: A13-1(정렬) → RUNBOOK §3 프롬프트에 "서버 응답 순서에 의존하지 말고 앱에서 날짜 오름차순으로 정렬해 보여준다" 명시(양판). 정렬이 앱 책임이 돼 차기 런부터 M1이 공정한 치명 게이트.

**수정 계획 입력(미해결·다음 단계서 [[eval-fix-ledger]]식 분류·예상효과 사전등록)** — eval-side(채점) vs 코퍼스 feedback(플러그인) 라우팅:
- **A13-1 잔여 해소(2026-06-18 12:48·7차 런 전 창)**: `SCENARIO §4`+`FC-GOLDEN §0` 게이트답에서 "(서버 순서 유지)" 제거 → "앱 책임·서버 응답 순서 의존 금지"로 정합(프롬프트 `2326dd0`·RUNBOOK §3/§4와 일치). GOLDEN에 amend 감사 스탬프. M1은 이미 "뒤섞은 입력·무정렬=vacuous FAIL"로 정합돼 측정 대상 불변. EVAL-METHOD §0.2·§5 창·소급 아님. **미커밋**.
- **A13-2(eval+코퍼스)**: 아이콘 distinct 미검증 — 색 set-size만 보는 테스트가 아이콘 swap 우회. FC-GOLDEN M2 / `discipline-test §3.1`에 아이콘 distinct 단언.
- **A13-3(코퍼스/백스톱·신중)**: 수기 비-@freezed 모델이 BG 통과로 백스톱 전체 탈출(codex) — "도메인/State가 @freezed인가" 결정검사 부재=게임가능 갭.
- **A13-4(eval)**: G-8/N7 라벨 이진 일치 — 공백·시각등가 한글 허용대역 없음. FC-GOLDEN "정규화 후 비교" 단서.
- **A13-5(코퍼스 feedback)**: codex ST-2 죽은-but-read 상태필드(읽기전용에 액션 에러채널 과적) — architecture-state/discipline 피드백 후보.
- **A13-6**: 실질성 관문/near-degenerate 도메인 — 프롬프트 정렬 명시로 부분 완화.
- **codex codegen 포기(코퍼스 feedback)**: 전 모델 수기 fromJson — implementation-dart/discipline 피드백 후보.

**핵심 핀**: 코퍼스 HEAD `d18f2d1`(feedback-008) · eval `2326dd0`(RUNBOOK 프롬프트 정렬)·`5e40c17`(6차 결과지) · baseline `abee26d`(유일 소스 `dddart-20260613-2310-*` history·remote/tag 없음) · 런폴더 `dddart-20260618-0012-{claude@ab99a82,codex@64bb27e}`.

## 확정 설계 v2 (적대 리뷰 4렌즈 반영 · **eval 편집 적용 완료 · 동결됨 2026-06-17**)

범위 = `workspace/eval/`만(코퍼스/미러/백스톱 무관). **새 점수 축 0**(C안 기각 — 과적합·`RUBRIC.md:6` "프로세스 규율 비측정"·57차원 동결). 적대 리뷰(4렌즈·약 380k 토큰)가 v1 실질 구멍 6건+디코이 등급을 잡아 v2로 교정·적용했다.

### 핵심 원칙 ([B] 반영)
- **seam은 *코드가 판정을 둔 위치*를 따른다** — "정렬=무조건 도메인 테스트"가 아니라, 정렬이 도메인에 살면 도메인 단위테스트가·VM에 살면 VM-override 위젯테스트가 그 mutation에 red여야 한다(positive-control 정렬=VM·PASS와 비충돌). 유효화=측정을 *코드 모양*에 정확히 꽂음, 거주 강제 아님.
- **floor는 *골든 행위별*** — "맞는 seam에 테스트 0개"가 아니라 "**골든 두드리는 테스트(맞는 seam) 0개=FAIL**"(골든 앵커 보존 — v1 치환이 이를 떨어뜨려 "정렬만 미검증"을 거짓 PASS시킬 뻔).
- **코드/주입사이트 부재·vacuity = FAIL** — 라이브 서버가 이미 오름차순이라(SCENARIO §4·FC-GOLDEN §1) 정렬은 *뒤섞은 입력*이라야 비-vacuous(이미 정렬된 fixture는 무정렬 코드도 green). seam 이동이 이 floor를 면제하지 않음.

### A. [필수·적용됨] FC-2 seam 재보정 — 전 occurrence
- **3-seam 정본**: 판정(정렬·시간 양갈래=도메인 / **색 N-구별=ui_extension 매핑**)=**순수 단위테스트**(seam A·위젯/provider 미펌프) / view(슬롯·탭·표시 + 액션실패 State error)=**VM-override 위젯테스트**(seam B·repo/usecase provider 없음) / 네트워크 Left·통합=Dio목·integration(seam C). ※색 N-구별은 *테스트 seam*만 seam A지 거주는 ui_extension(≠도메인) — "도메인 판정" 라벨 금지(`discipline-test §3.1`).
- 적용 위치: `EVAL-METHOD §2.5 FC-2`(L148 — 3-seam·범주오인+단서·A2②·디코이 라우팅·러너) / `§2.3 FC-2 행`(L120 — widget 토큰 전부·골든 앵커 보존) / 헤더 v3.1→**v3.2**(L1·L6 전환 노트·불변 3조) / `RUBRIC §G FC-2`(L126) / **`FC-GOLDEN-WEATHER §2`(L69·M1 L73·L79·§5 어댑터 L108 — seam별 분기·뒤섞은 입력·사이트 死=FAIL)** ← v1이 빠뜨린 6차 직접 사용물. (잔재 L43·L117 role/blind-spot도 일반화.)
- S1 `FC-GOLDEN.md`도 **동일 seam-일반화 적용**(2026-06-17·일관성 — 정렬=코드 거주 seam·배지=ui_extension 단위·탭/새로고침=VM-override; positive-control VM 정렬과 정합).

### B. [비채점·A13 흡수·적용됨] 테스트 품질 관측 — 토큰 리터럴 금지
v1 #3(§5.5 신설칸·FORM 토큰 명명)은 eval↔코퍼스 결합(과적합·`RUBRIC.md:5` 순환방지 위반)+A13 중복이라 기각. → 기존 **A13 사각신고칸**(`§2.2`)에 **행위 술어**로 흡수(매처 이름 금지). 코퍼스 `discipline-test §3.1`도 단위선택 우려를 A13으로 라우팅. *별도 §5.5 신설칸 안 만듦.*

### 디코이 ([필수 게이트 아님 — 라우팅·적용됨])
직접모순형=FC-1+green-on-correct 포섭 / 약화단위형((아이콘,색) 쌍)=A13 관측 / vacuity형(이미 정렬 fixture)=A의 floor. `EVAL-METHOD §2.5`에 라우팅 1줄만(새 게이트/축 신설 안 함·레인 혼입 방지).

### measure-first / 동결
편집 적용 완료·**동결됨(2026-06-17)**. 6차 양판 라이브런(사용자 드라이브) 채점 준비 완료 — 동결 후 소급 변경 금지(`§0`·§5 — 미동결 채점=과적합 위반).

## 목표

eval rubric(`workspace/eval/rubric/`)이 산출물 *구현*뿐 아니라 **coder가 산출한 *테스트*의 품질**(비-vacuity·디코이·FORM 준수)을 채점하게 한다. 그래야 6차 라이브런이 discipline-test/implementation-test의 효과를 *측정*한다(현재는 FORM이 작동했는지 채점할 전용 칸이 약함).

## 배경 — rubric이 *이미* 측정하는 것 (읽고 확인함 · 중복 신설 금지)

eval 시스템(`workspace/eval/README.md`): 57차원·8축(S-DDD·S-VIEW·S-STATE·S-DATA·S-HR·BUILD·**FC**·TIER-Q)·치명 게이트 17. 채점 = `RUBRIC.md`(항목) + `EVAL-METHOD.md`(방법 v3.1) + `rubric-metrix.md`(결과지). 고정 입력 = `tools/SCENARIO-WEATHER.md`·`FC-GOLDEN-WEATHER.md`.

**FC축이 5차 FAIL을 이미 잡았다**(`RUBRIC.md` L125-127):
- **FC-1 골든 오라클**(의미·치명): grader가 외부 행위표 G-1~G-8 사전등록 후 코드 대조. **G-7**(`FC-GOLDEN-WEATHER.md` L62)이 이미 "**6종 색 집합 distinct(6개)** ∧ 아이콘 distinct ∧ cloudy≠overcast"를 핀 → 5차 FC-1 FAIL = G-7 색충돌(clear==cloudy). **즉 "색 단독 N-distinct 판정단위"는 이미 골든에 있다.**
- **FC-2 테스트·메커니즘 비-vacuous**(결정·치명): 핵심 판정에 **mutation M1~M5 주입 후 coder의 test가 red인지** 확인. M1=정렬역전→G-1, M2=매핑swap→G-7, M3=최고/최저swap→G-3·4, M4=목록→상세 날짜오류→G-5, M5=상세지표누락→G-6(`FC-GOLDEN-WEATHER.md` L73-77). **green이면 vacuous→FC-2 FAIL.** 5차 FC-2 FAIL = M1/M3/M4에 test가 green(헛). **즉 비-vacuity는 이미 mutation으로 측정된다.**
- **FC-3 도메인 정합 negative-gate**(의미·치명) + **N4**(L90) = 두 상태 같은 아이콘/색 공유(cloudy↔overcast).

## 실제 갭 (개선이 채울 것 — brainstorming 대상)

기존이 vacuity·색 distinct를 잡으므로, *새로* 필요한 건 좁다:
1. **디코이 탐지** — FC-2 mutation은 *vacuity*(test가 너무 약함)는 잡지만 *디코이*(test가 골든과 **모순되는 것을 "정답"으로 단언** — 5차 codex가 clear==cloudy를 "distinct"로 단언)는 다른 실패 모드다. mutation을 통과해도 *버그 상태를 가둔* 디코이일 수 있다. → "산출 test의 단언이 골든과 모순되지 않는가" 채점 칸 후보(negative-gate 추가 또는 FC 확장).
2. **FORM 준수(프로세스·스킬 소비 측정)** — 산출 test가 처방 FORM(toSet·scrambled+orderedEquals+양끝echo·keyed-slot+비대칭음수·non-edge+날짜echo+findsOneWidget)을 *썼나* / 금지패턴(findsWidgets·.first·대칭fixture)을 피했나. = discipline-test가 *소비됐는지*의 관측(feedback-008 항목4식 프로세스 dim·rubric 점수 아닐 수도).
3. **seam 적응** — feedback-008이 정렬 test를 **도메인 직접**(VM 아님)·위젯 test를 **VM override**(repo provider 없음)로 옮김. FC-GOLDEN M1 주입 사이트/어댑터(`FC-GOLDEN-WEATHER.md` L73·L103·L108)가 "정렬은 도메인 단위 거주" 기대 + no-repo-provider seam을 반영해야 mutation이 새 코드에 정확히 꽂힌다.
4. **위상 결정(brainstorm)** — 신설 축(예: S-TEST)인가 / FC-2·FC-3 확장인가 / TIER-Q(카운트) 추가인가. 디코이는 치명? 프로세스 dim은 비치명?

## 대상 파일 (전부 workspace/eval — 코퍼스 아님)

- `workspace/eval/rubric/RUBRIC.md` — 차원(FC-1~3 = L125-127·치명17 = L154). 테스트-품질 dim 추가/확장 지점.
- `workspace/eval/rubric/EVAL-METHOD.md` — 채점 방법(§0·§5 사전등록 규칙·mutation 실행·레인 분리). 디코이/FORM 채점 절차 추가 지점.
- `workspace/eval/rubric/rubric-metrix.md` — 결과지 템플릿(새 dim 행).
- `workspace/eval/tools/FC-GOLDEN-WEATHER.md` — 골든+mutation(G-7 색 = L62·M1~M5 = L73·N4 = L90·어댑터 = L103/L108). seam 적응·디코이 negative-gate 후보.
- (참고) `workspace/eval/tools/positive-control/README.md` 실재 — 거짓-FAIL 반증용.

## 제약 (반드시 지킬 것)

- **eval = 채점 side, 코퍼스 아님** → codex 양판 미러·백스톱 무관(`eval/fix/README.md` L33 "fix 자체도 eval 하위 → 양판 미러 불필요"). `corpus_mirror_sync.py` 스코프 밖. **dddart/·codex-dddart/ 안 건드림.**
- **measure-first / 과적합 차단**: rubric 변경은 **채점 *착수 전*에만**(EVAL-METHOD §0·§5 — "미동결 채점 = 과적합 위반"). 즉 **6차 라이브런 *전*에** 사전등록·동결. 결과 보고 고치면 안 됨.
- **시각/디자인 충실도 = A1 비측정**(인간 오라클·AI 렌더 못 봄) — 테스트-품질 채점은 *구조·행위*만(색 distinct는 값 집합이라 측정 가능·시안 일치는 비측정).
- **레인 분리**: 결정(mutation 주입 실행·grep)과 의미(grader 판단) 분리. 디코이 판정이 어느 레인인가도 결정 대상.
- 프로젝트 밖 writing 금지·메모리 저장 보류(스코프 미확정)·커밋은 사용자 요청 시·main 직접·push 안 함.

## 재개 시 첫 행동

**brainstorming 종료(2026-06-17) — 위 §확정 설계가 결론**(갭 4종 처리: seam 적응=#1 필수·디코이=#2 싼 보험·FORM 준수=#3 비채점 관측·위상 결정=새 축 기각). 다음: ① 사용자 **'동결됨' 확인** → ② §확정 설계대로 `EVAL-METHOD.md`(v3.2)·`RUBRIC.md` 편집(FC-2 seam 재보정 + 디코이 1줄 + 비채점 관측) → ③ 사용자 spec 리뷰 → ④ 6차 라이브런 전 동결(measure-first). 코퍼스/미러/백스톱 무관.
