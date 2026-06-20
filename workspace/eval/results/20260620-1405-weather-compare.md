# 비교 집계지 — weather 11차 (claude vs codex 양판) · EVAL-METHOD §4·§4.5

> 입력 = `20260620-1405-weather-claude.md`·`-codex.md`. 방법 v3.2·baseline `abee26d`·코퍼스 `60a63aa`(R6+R1~R4 시술). **N=1·인과 단정 금지·절대값 비교 무의미(엔진 파이프라인 상이)·동률 시 과정지표 보조.**

## A. 산출물 품질 차분

| 항목 | claude | codex | 우세 | 비고 |
|---|---|---|---|---|
| 치명 18 PASS 수 *(정정)* | **18/18** (FC-1·FC-3 개정 PASS) | **18/18** | **동률** | 골든 개정으로 claude 색 FAIL 해소(D-0) |
| TIER-Q 등급 | 산정 자격 확보·상~중(원채점 미전개) | **상**(WEAK 1·FAIL 0) | ≈동률 | claude 정밀 Q-1~9는 원채점 사전식 종료로 미수행 |
| 색 팔레트 디자인 충실 *(정정)* | **디자인 4색 헥스 정확**(#F5A623·#9B9B9B·#356091·#4A90E2·cloudy=overcast 묶음) | **디자인 4색 미사용**(theme 토큰+인디고 발명·임의 6색) | **claude** | 런 북극성=디자인 충실 → claude 우위 |
| 레이아웃 디자인 충실(A1·사용자 눈) | Stitch와 동일(이미지 제외) | 스스로 변경(영역 drop 의심) | **claude** | 사용자 육안 판정·적대 grader도 codex drop 의심 |
| 이미지 에셋 반영 | ❌ 미사용 | ❌ 미사용 | 동률(양 실패) | 단 생성측 지시 코퍼스 미반영(D-2)→불복종 아님 |
| 아키텍처 의미 10치명 | ✅ 전부 PASS/NA | ✅ 전부 PASS/NA | 동률 | 양쪽 도메인 순수·Either 통과·VM 직행·show 금지 정합 |
| FC-2 비-vacuity | ✅ M1~M4 red | ✅ M1~M4 red | 동률 | |
| FID(시각 구조 자동) | ➖ A1 폴백 | ➖ A1 폴백 | 동률 | 양쪽 screenProbes 미노출(규약 미준수) |

**판정 (정정·2026-06-20 골든 개정)**: **치명 게이트 무승부**(양 18/18 PASS). 구판의 "codex 우세"는 골든 결함(디자인 미열람 색 조항)에 기인한 것으로 무효. **디자인 충실도(이 런 북극성)로 보면 오히려 claude 우위** — 색은 디자인 4색 헥스 정확(claude·cloudy=overcast=#9B9B9B는 design_md 명시) vs 디자인색 미사용·임의 6색(codex), 레이아웃은 Stitch 동일(claude) vs 자기변형(codex·적대 grader 영역 drop 의심). 즉 **"claude=디자인 충실 / codex=자기변형" 패턴이 색·레이아웃 양 층위에서 일관**. 아키텍처·DDD·R6 패턴은 양쪽 동률.

## B. 과정 지표 차분 (보조·절대값 아님 — A9)

| 지표 | claude | codex | 차분 | 비고 |
|---|---|---|---|---|
| 슬라이스 수(build-state) | ≥3(foundation·model·view-list·…) | 2(model·view) | claude 多 | 파이프라인 분해 상이·우열 아님 |
| coder 호출·반송·재시도·토큰 | (미측정) | (미측정) | — | 런 트랜스크립트 필요·채점자 미보유 |

> comparability: 두 엔진 내부 루프·게이트 형태가 달라 절대값 비교 무의미. 산출물 품질은 치명 게이트 **무승부**(디자인 충실도만 claude 우위·D-0)라 과정지표는 보조 불요.

## C. feedback-013 (R6+R1~R4) 검증 verdict — *이 런의 목적*

> 11차는 10차 백스톱 폭발(MD1×명세격상×엔진 plain 3축 곱)에 대한 R6+R1~R4 시술의 효과 실측 런. 사전등록 예상효과 대조(eval-fix 폐곱 원장).

| 예상효과(feedback-013 ⑥) | 11차 실측 | 판정 |
|---|---|---|
| **plain class 탈출 차단**(R1+R6 핵심) | **양 엔진 모두 컬렉션 루트 @freezed+named factory** — claude `WeeklyForecast.fromDays(..sort)`·codex `WeatherForecast.fromUnorderedSummaries(..sort)`. plain 탈출 **0** | ✅ **작동 확정** |
| **백스톱 최종 0**(첫커밋부터 올바름의 종료상태) | 양 엔진 `--diff-base abee26d` **blocker 0**(58종) | ✅ |
| **NM 클러스터 별도 카운트**(R2 산문 바닥 실효 판단) | 백스톱 최종 0이라 **NM 위반 0**(최종 산출물 기준) | ✅(최종)·런중 미측정 |
| 막판 백스톱 11·14→0~2·소요 2h→1h | **런 트랜스크립트 필요·산출물엔 부재**(사용자 드라이브 세션) | ⏸ 미측정 |

**verdict**: R6+R1~R4의 **직접 표적(plain class 도망→막판 대수술)은 차단 확정** — 양 엔진이 정렬 불변식을 *도메인 루트 @freezed named factory*로 거주(10차 plain 어트랙터 재발 0). 백스톱 종료 0. **단 "평균 2배→1배" 회귀 해소의 정량 확정은 런중 막판 적발 수·소요 시간 실측이 필요**(트랜스크립트 부재로 이번엔 정성 신호까지). R5(명세 dry-run 린터) 추가 여부 = NM 런중 클러스터 미측정이라 **보류 유지**(최종 NM 0은 긍정이나 런중 발화는 미관측).

## D. 공통 발견 + 런 메타 (양 엔진)

**D-0 골든 개정·무승부 (2026-06-20)**: 구판 골든 'G-7 6색 distinct·동일 색=자동 FAIL'이 디자인 소스(design_md: 기능 4색·cloudy=overcast=#9B9B9B 명시)를 미열람 작성돼 **디자인 충실(claude)을 위반으로 오판**. `FC-GOLDEN-WEATHER.md` G-7/N4/§68을 '구별=아이콘∨색·완전 미구별만 FAIL'로 개정 → claude FC-1/FC-3 PASS·**무승부**. 색 팔레트 디자인 일치는 FID/A1로 이관. 교훈: FC 골든 색·시각 조항은 디자인 소스 입력 필수.

1. **screenProbes 미노출**(implementation-test §7 표준 pump 규약) → FID 자동 게이트 양 엔진 미작동·A1 폴백. **9차 claude는 screenProbes 보유 → 11차 양 엔진 규약 회귀** — FID 자동 채점 2런 연속 effect size 미축적. (다음 라이브런 코더 규약 준수 점검 필요·후속 교정 후보)
2. **테스트 골든셋 미사용**: 양 엔진 자체 테스트가 FC-GOLDEN 고정셋 D(7건 섞임)를 안 쓰고 소수 fixture로 정렬 검증(비-vacuous는 성립이나 골든셋 강제 부재) — RUBRIC FC-2 사각(A13).
3. **claude 테스트 `colors.length==4` 재평가**: 구판은 '색 붕괴를 못박은 역-오라클'로 봤으나, **디자인 4색이 정답이므로 디자인 팔레트를 올바로 핀하는 정상 단언**으로 재평가(역-오라클 비판 소멸). 단 골든셋 D 미사용(item 2)은 유효.

**D-2 이미지 에셋·레이아웃 강제 = 이 런의 북극성 (★)**: 양 엔진 모두 Stitch 삽입 이미지(바이브코딩 배너 512×383) **미반영**(`lib` Image.asset 0·pubspec `assets:` 양쪽 주석 확인). **단 이는 불복종이 아니라 생성측 지시 부재** — 코퍼스 grep 결과 extract_design `images[]`·coder `Image.asset`·architect layout-ir 소비가 **전부 미반영**(landed = 측정 게이트 layout-ir 추출기·fid-gate·screenProbes 규약뿐·생성측은 `2026-06-19-fidelity-generation-design.md`에서 "별도 승인 필요·미구체화"). 레이아웃 강제도 미반영 → claude의 Stitch 일치는 **강제 없는 본연 충실도**, codex 이탈은 본연 충실도 약함. **다음 작업 = 설계만 끝낸 생성측(Image.asset 번들·layout-ir L1·L2 강제)을 코퍼스에 실제 구현**(코퍼스 불변 원칙·별도 승인 건).

## 판정 (§4.3)

- **치명 게이트**: **무승부**(양 18/18 PASS). 구판 "codex 우세"는 골든 결함(디자인 미열람 색 조항)에 기인·무효(D-0).
- **디자인 충실도(이 런 북극성)**: **claude 우위** — 색 4색 헥스 정확·레이아웃 Stitch 동일 vs codex 임의 6색·자기변형. 이미지 에셋은 양 엔진 미반영이나 **생성측 지시 코퍼스 미구현이라 불복종 아님**(D-2).
- **N=1**: 인과 단정 금지(claude 충실/codex 변형이 *항상*은 아님)·보조 S2 보강 필요.
- **메타**: R6+R1~R4는 표적(plain 도망) 차단 작동(양 엔진 컬렉션 루트 @freezed). 색 건은 R6 무관 — 골든 결함이었고 개정으로 해소. 이미지·레이아웃 강제(생성측)는 설계만 완료·코퍼스 미구현 = 다음 작업(별도 승인). FID 자동 게이트 규약 회귀(양판 screenProbes 미노출)는 별도 후속.
