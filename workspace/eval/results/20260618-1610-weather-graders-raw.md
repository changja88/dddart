# grader 패널 raw 증거 — 20260618-1610-weather (§2.0 blind 영속·A3)

> **N_grader 3/산출물**(n1·n2 중립·adv 적대)·**전원 Claude 계열 — 비-Claude 오라클 0(A3 독립성 미확보)**. 각 grader는 다른 grader·결정레인 결과·variant 미수령 상태로 산출물 `lib/**`·`test/**` + RUBRIC·EVAL-METHOD·FC-GOLDEN·SCENARIO 정독. **조정자가 FC-2 mutation(M1·M4) 직접 주입·실행·복원**(grader 보고를 자기보고 불신으로 재현). 각 grader subagent_tokens ~140-180k.

## 조정자 결정 레인 실측 (봉인 결과)

| 검사 | claude | codex |
|---|---|---|
| `backstop.dart --diff-base abee26d` | 57종·blocker 0·exit 0 | 57종·blocker 0·exit 0 |
| `build_runner build` | exit 0 | exit 0(15 outputs) |
| `flutter analyze` | "No issues found!"(0.9s) | "No issues found!"(1.1s) |
| `flutter clean && flutter test`(단일) | +23 All passed | +24 All passed |
| **FC-2 M1**(정렬 역전·직접) | **red**(forecast_test+list_vm_test) | **red**(chronology_service_test+list_vm_test) |
| **FC-2 M4**(navigator 날짜·직접) | **green**(+8 passed — 死검증) | **red**(navigate 4건) |
| 산출물 무결성 | git diff empty(staged 유지) | `list_view.dart` grader 미복원 1건→조정자 checkout 복원·diff empty |

## claude grader 패널

### claude-n1 (중립)
- 치명 16/17 PASS, **FC-1 G-7 부분 FAIL**(cloudy=overcast=`Icons.cloud`·아이콘 5 distinct·`ui_extension:21-23`)·인간 큐 제출(A1 경계). FC-2 PASS 주장(M1~M5 red·당시 M4 미주입). ST-8 WEAK. TIER-Q 상.
- 판단 근거: "골든 G-7 문언상 아이콘 distinct 위반이나 색 6 distinct로 화면 6종 구별 성립·A1(아이콘 심볼=비측정)과 충돌 → 단일 grader로 치명 확정 안 함·인간 큐."

### claude-n2 (중립)
- 치명 코드차원 전수 PASS, **테스트 스위트 flaky RED**(병렬 실행 시 정렬 테스트 1~3건 비결정 실패·serial green·전역 DioClient.instance 싱글톤 오염 진단). G-7 아이콘 약화. FC-2 잠정(green-on-correct 전제 훼손). ST-8 WEAK.
- 핵심: "production 코드 무결(격리·serial·소스 ascending 실증)이나 `flutter test` 기본 실행 exit 1 — green 빌드 재현성·FC-2 러너 전제 영향."

### claude-adv (적대)
- **FC-2 FAIL** 확정 주장 — M2b(아이콘-only 충돌)→14/14 green·**M4(navigator 날짜)→23/23 green** → G-7 아이콘·G-5 navigator 직렬화 두 골든이 어느 seam에서도 비-vacuous 미검증. ST-8 결정 FAIL. → 픽스처 FAIL.
- **조정자 재현**: M4 green을 직접 확인(`weather_navigator.dart:22` +1일→+8 passed) → **adv 확정**. M2b는 코드가 이미 5 distinct(사실)·테스트가 (아이콘,색)쌍만 단언(약화 단위형).

## codex grader 패널

### codex-n1 (중립)
- 치명 17 전수 PASS·G-1~G-8 전 일치(**G-7 아이콘 6 distinct**: cloud_queue≠cloud)·FC-2 M1~M4 red. **테스트 flaky**(전역 rootRouter 싱글톤) 사각. SD-3 WEAK(생성검증). TIER-Q 상.

### codex-n2 (중립)
- 치명 17 전수 PASS·G-7 일치·FC-2 M1~M4 red. SD-3 WEAK·Q-1 WEAK(`Key? key` 레거시 생성자). 테스트 flaky 사각. TIER-Q 상. → 준수 PASS.

### codex-adv (적대)
- **"통과 막을 근거 없음"** — SD-1 빈wrapper·HR-5 채널④·DT-1 Left no-op·ST-1 누수·VW-6 우회 self-show·ST-2 valueOrNull·ST-5 함수형 위장·FC vacuity 8종 집중 공격했으나 의미 변종 미발견. M1 정렬 뒤섞은 입력 비-vacuous·M4 navigate red 확인. **거짓 FAIL 금지로 날조 안 함**.

## 차원별 κ (일치율) 요약
- **claude**: 치명 14(N/A 3 제외) 중 13 만장 PASS·**FC-2 1:2→adv FAIL + 조정자 직접 재현으로 보수 FAIL**·FC-1 G-7 3/3 아이콘 미충족 인지(판정 인간 큐). ST-8 WEAK 3/3.
- **codex**: 치명 17 **3/3 만장 PASS(adv 포함)**·G-1~G-8 3/3·FC-2 M1~M4 red 3/3. SD-3 WEAK 2/3·Q-1 WEAK 1/3(보수 반영).
- **blind 붕괴 적신호 없음**: per-grader 산출 상이(적대 grader가 claude FC-2 FAIL·codex "근거 없음"으로 갈림 — 단일 저자 위장 아님).

## 사각 신고칸 통합 (A13·채점 미산입·다음 동결 라운드 RUBRIC 개정 입력)
1. **G-7 아이콘 distinct vs A1 비측정 긴장** — 골든이 "아이콘 6 distinct"를 기능 술어로 박았으나 RUBRIC A1은 아이콘 심볼 선택을 비측정 위임. (아이콘,색)쌍 우회를 EVAL §2.5는 "약화 단위형→사각칸"으로 분류. G-7의 아이콘 절을 (a)기능 게이트 유지 vs (b)A1 이관 정본화 필요.
2. **navigator 직렬화 seam 공백** — G-5 정본 사이트(탭 핸들러·route 파라미터)가 navigator 직렬화 구간을 누락 가능(claude). FC-GOLDEN §5 어댑터에 navigator end-to-end seam 명시 권고.
3. **테스트 병렬 flaky(양쪽)** — 전역 싱글톤 공유·테스트 reset 부재로 `flutter test` 기본 병렬 비결정. RUBRIC에 "산출 테스트 스위트 결정성(병렬 green)" 차원 부재 — implementation-test 격리 규약 + 차원 신설 검토.
4. **claude 산출물 staged 미커밋** — 파이프라인 커밋 단계 누락(코덱스는 7커밋). EVAL 비측정(프로세스)이나 G2 green 게이트·재현성 관점 발견 로그.
