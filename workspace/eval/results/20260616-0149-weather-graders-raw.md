# grader 패널 raw verdict — 20260616-0149-weather (A3 blind 증거 영속)

> EVAL §2.0·§2.2. 6 grader(claude 3 + codex 3) 독립 blind 의미 채점. 조정자 결정레인 결과 미수령·각자 코드 정독. **비-Claude 오라클 0 — 전원 동일 계열(A3 독립성 미확보·헤더 ⚠️).** 만장일치 보드엔 per-grader·κ 동반(단일저자 위장 차단). 아래는 각 grader 최종 verdict 요지(전문은 채점 세션 transcript).

## claude 산출물 (BC=weather)

### n1 (표준)
- **치명 16 PASS / FC-2 ❌ FAIL.** FC-2 근거(mutation 실증): M1(정렬 역전 `.reversed`)→29 테스트 전부 GREEN(정렬 코드 0·순서 단언 0·목록테스트가 사전정렬 fake override). 대조로 M2(아이콘)·M3(`weather_label_transform_test` `28°/19°`)·M4(`70%`)는 정상 RED. → "오직 G-1 순서만 테스트 사각."
- FC-1 ✅(서버 순서 보존·Map/Set 재정렬 0). 비치명 거의 PASS·Q-7 경미(미사용 error/onRetry·아이콘 size).
- A13: 정렬 서버 위임이 라이브 서버 오름차순일 때만 G-1 참·순서 고정 테스트 0.

### n2 (표준)
- **치명 17 FAIL 0(PASS 14·N/A 3).** FC-2 ✅ 주장: 지정 4타깃(기온 `weather_label_transform_test:55`·6종 `forecast_test`+view·탭날짜 `weather_navigation_test:73-78`·상세지표 `weather_detail_view_test:57-60`) 전부 mutation-kill 가능·29 케이스 실재(더미 아님). 단 **"정렬 회귀 안전망 비어있음"** 명시(list_view_test가 사전정렬 fake·순서 비단언).
- 종합 PASS·TIER-Q 9/9 PASS. 패키지명 `smaple` 오타 관찰(컴파일 무영향).

### adv (적대)
- **FC-2 ❌ + FC-3 ❌ FAIL.** FC-2: M1 사살 사이트 부재(lib sort 0)·순서 단언 0(`weather_list_view_test:38-93` 사전정렬·`findsWidgets`만). FC-3: N2(서버 미정렬 시 그대로 노출). **설계단계 정렬 위험 미인지**(design-spec §8 CR 등록부·§11 자기모순 스캔에 정렬/순서 0 hit). 나머지 치명 PASS(SD-1·ST-1·ST-2·DT-1 등 인용 동반 진짜 PASS).
- → "형태·규칙 모범적이나 핵심 행위 '날짜 오름차순'을 코드가 보증 안 하고 서버 우연 의존·검증 테스트 0."

> **조정자 종합**: FC-1은 외부진실(실서버 오름차순)+게이트 "서버 순서 유지"로 **PASS**(동작 정확). adv의 FC-1/FC-3 FAIL은 shuffled-D 가정 적용 — 그 robustness 우려는 **FC-2(미테스트)로 귀속**(EVAL §2.4 외부행위 vs 비-vacuity 분리). 치명 FAIL = FC-2 단독(2/3 FAIL·보수).

## codex 산출물 (BC=weather_forecast)

### n1 (표준)
- **치명 FC-2 ⚠️WEAK→FAIL(보수) / 그 외 PASS.** mutation 실측: M2(아이콘)=RED·M4(날짜)=RED·M5(지표)=RED, **M3(기온 max↔min swap)=GREEN**(summary card가 27°C·19°C *존재*만 단언·위치 미단언)·M1(정렬)=사이트 부재. FC-1 ✅. SD-9 ✅(역전 없음)·ST-5 ✅(@riverpod 3.x).
- A13: 시각 충실도 비측정.

### n2 (표준)
- **FC-2 ❌ FAIL(M1 vacuous)·ST-2 PARTIAL.** 순서 단언 0·`weather_forecast_repo_test`가 "server list order" 보존만 단언(정렬 부재를 역으로 코드화). ST-2 액션채널(error+consumeError) listen/호출 배선 0(死코드)이나 읽기전용이라 조회채널 충족으로 치명 통과 권장. BG-1 주의: pubspec `sdk:^3.12.1`(3.9 상한 초과·기능 미사용). Q-8 경미(import 절대·상대 혼용).
- FC-1 ✅(서버 전제)·치명 14 PASS·SD-1/HR-5 N/A.

### adv (적대)
- **FC-1 ❌ + FC-2 ❌ FAIL.** 전 파이프라인 정렬 0(grep 무히트)·`forecast_list_body_section`이 서버 배열 그대로 렌더·shuffled D 주입 시 첫 항목 D2→G-1 FAIL. FC-2: M1 사이트 부재+repo test가 정렬 부재 보증. **적대 가설(Map 재조립 순서 상실)은 반증**(List 보존). **SD-9 역전·VW-4 누수 반증(무혐의).** 나머지 15 치명 PASS.
- → "DDD/MVVM/하우스룰 거의 만점·기능 정확성 게이트가 단일 누락(정렬)으로 치명 FAIL."

> **조정자 종합**: FC-1/FC-3은 외부진실+게이트로 **PASS**(adv의 shuffled-D FAIL은 FC-2로 귀속). 치명 FAIL = FC-2(3/3 만장일치·정렬축 M1 + n1 기온축 M3). SD-9·ST-5 3차 결함 **해소 확인**(adv 명시 반증).

## κ·split 요약

| 차원 | claude(n1·n2·adv) | codex(n1·n2·adv) | 조정자 판정 |
|---|---|---|---|
| FC-2 | ❌✅❌ (2:1) | ❌(보수)❌❌ (3:0) | **양판 ❌ 치명 FAIL** |
| FC-1 | ✅✅❌ | ✅✅❌ | **PASS**(외부진실·adv=FC-2 귀속) |
| FC-3 | ✅✅❌ | ✅✅❌ | **PASS** |
| 치명 PASS 10(SD-1·SD-7·VW-1·VW-6·ST-1·ST-2·DT-1·DT-2·HR-1·HR-4) | ✅✅✅ | ✅✅✅ | PASS |
| SD-9·ST-5(codex 3차 결함) | — | 해소✅ | 회복 확인 |
