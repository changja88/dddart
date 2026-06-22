# fix 015 — 레이아웃 형상 Stitch SoT 복원 (사전등록형·14차 육안 검증대기)

> **트리거**: 13차 라이브런 후 **사용자 육안 발견**(평가지에 *없는* 내용) — "양 엔진 레이아웃 강제 안 됨·claude는 강제 *전*이 더 스티치 유사·세로 배치를 가로로 하는 등 크게 어긋남". 이 RCA가 feedback-014 "L 적중"을 **거짓성공으로 뒤집음**.
> **순서 단서(정직)**: 시술은 이 사전등록 *전* 완료(`e49b4fe`·RCA→설계→plan→시술 한 세션)·이 등록은 **14차 라이브런(측정) 전**이라 measure-first 보존(④예상효과를 ⑥실측 전에 박음). ④는 설계 `2026-06-22-layout-stitch-sot-design §10` 육안 체크리스트를 옮긴 것.
> **★측정 오라클 = 사용자 육안**(FID 자동게이트 intact-but-shelved·screenProbes 9차부터 미노출). 구조 grep는 보조.

## 메타
- **회차**: 015
- **트리거**: 13차 `results/20260622-0323-weather-*` 후 **사용자 육안 RCA**(결정레인 외·이 세션 적대검증·블라스트 반경 스윕)
- **베이스 코퍼스**: `8fe3800` (13차 채점 코퍼스 — Track B area-tree + size-link + asset)
- **시술 커밋**: `e49b4fe` (레이아웃 Stitch SoT 복원 — 형상 어휘 철거·시안 HTML 단일근거)
- **검증 런**: 14차 `results/20260622-1636-weather-*`(2026-06-22·사용자 드라이브)
- **상태**: ✅ 14차 검증완료 — **형상 F 양 엔진 적중**(grep+g3 독립대조 6/6 시안 일치·★최종 육안=사용자)·부수 **DT-2 swap** 발견

## 배경 — feedback-014 "L 적중"의 거짓성공 (★핵심 교훈)
- feedback-014 ⑥은 hero 아이콘 **120(size-link) "2/2 적중"**으로 기록했다. **그러나 그 size-link이 번들된 Track B area-tree(축맹 IR)가 레이아웃 *형상*(축)을 회귀시켰고, 좁은 size 지표는 이걸 못 봤다.** → measure-first가 *너무 좁은 지표*(점값 size·축과 직교)로 **거짓성공**을 낸 교과서 사례. 지표가 실패 모드(축)를 담지 못하면 통과해도 현실은 회귀.
- **블라스트 반경**(RCA 스윕·시안 CSS 대조·claude PRE=11차 `20260620-1206` / POST=13차 `20260621-2231` byte-동일 시안):
  - **claude**: detail 메트릭 섹션 `grid-cols-1`(세로)→`Row(Expanded×3)`(가로)·메트릭 카드 헤더 icon+label Row→세로스택·목록타일 날짜폭 96→56.
  - **codex**: 메트릭 카드 내부 `flex-col`→`Row`·hero 기온 baseline(가로)→`Column`(세로)·앱바 sticky→슬라이버 스크롤 이탈.
  - 프레임은 *향상*(nav·브로콜리·maxWidth480·아이콘120)이나 **축 뒤집힘이 시지각 지배** → 사용자 "much worse" 정당(최악-오류-지배 가중).
- **적대검증 정정 2건**(과장 제거): ⓐ coder는 시안 *보유*(축 입력 부재 아님·명세에 주의 빼앗김) ⓑ 뒤집힘은 *확률적·엔진분기*(claude 섹션·codex 카드/hero) = coder 변동성 잔여.

## 교정 항목 (사전등록 표 — ①~⑤·⑥은 14차 후)

| # | 우선 | ① 대상 결함 | ② 원인(뿌리·코퍼스 책무) | ③ 처방(파일·미러) | ④ 예상효과(전→후·14차 육안) | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| **F** | 🔑 | **레이아웃 *형상* 회귀**(축 세로↔가로)·양 엔진·claude 강제전>후. RUBRIC 정식 dim 없음(FID A1 폴백)·육안+스윕 측정 | 코퍼스가 **축맹 레이아웃 어휘**(layout-ir/area-tree) *소유* → 시안 직접재현 대체("눈대중 금지")·위젯명 금지로 Flutter 축(Row/Column) 표현 통로 차단·coder 주의 빼앗김 | **형상 어휘 철거**(commands 배선·design-architect area-tree·review-ui L1·architecture-ui §8 IR직교) **+ Stitch HTML=형상 SoT**(impl-flutter **§9** 신설·coder design-ref 승격+carve-out·architect 분해전담·architecture-ui §8 "형상과 직교"·codex **㉥** HTML≠notes)·양판(final.md `--write`·agents/commands 수동) | (claude) 메트릭 섹션 **세로 회복**·(codex) 카드내부 **세로**·hero 기온 **가로**·앱바 **고정** / 프레임(nav·이미지·maxWidth·120) **유지** / **신규 축 뒤집힘 0**(coder가 HTML 재현) | `e49b4fe` | ✅**적중**: 양 엔진 6컨테이너 전 시안 축 일치(grep+g3 독립대조). claude 메트릭 섹션 `Column` 세로·카드 헤더 `Row` 가로 / codex 카드 `Column`(flex-col)·hero 기온 `Row`baseline·앱바 `Scaffold`고정. 13차 축 회귀 전면 회복·프레임(hero120·maxWidth480·에셋[claude]) 유지·신규 뒤집힘 0. ★최종 육안=사용자 |

- **②원인**: 증상(특정 화면 Row)이 아니라 뿌리 = *코퍼스가 형상을 소유*. **공리(사용자 확정): 코퍼스 레이아웃 어휘 0 · Stitch HTML=형상 단일근거 · 값 운반(색·크기·이미지) 유지.** 어휘에 축 토큰 추가는 공리가 기각(어휘 확장도 소유·다음 미토큰에서 또 샘).
- **생성측 한 곳 격리**: F는 생성측 형상 사슬(extract 미연결 + architect 형상 미규정 + coder HTML 재현)이라 N=1 단일 축 변경.

## measure-first 측정 (14차 · ★육안 + 보조 grep · 설계 §10)

**형상(F) — 엔진별·컨테이너별 분리 관측**:
| 컨테이너 | 13차(전) | 14차 기대(후) | 육안 + 보조 grep |
|---|---|---|---|
| claude detail 메트릭 섹션 | `Row(Expanded×3)` 가로 ✗ | **세로**(시안 grid-cols-1) | 3카드 세로 스택 / 메트릭 section이 `Column`·`ListView` 래핑(`Row(` 아님) |
| codex 메트릭 카드 내부 | `Row` 가로 ✗ | **세로**(시안 flex-col) | 아이콘 위 라벨/값 / 카드 위젯 `Column` |
| codex hero 기온(최고/최저) | `Column` 세로 ✗ | **가로 baseline**(시안 items-baseline) | 최고°/최저° 가로 / `Row(` |
| codex 앱바 | 슬라이버 스크롤 이탈 ✗ | **고정**(시안 sticky) | 스크롤해도 상단 고정 / `AppBar`·`SliverAppBar pinned` |
| **프레임(회귀 가드)** | 있음 ✓ | **유지**(nav·브로콜리·maxWidth480·hero120) | 소실 0 |
| **신규 축 뒤집힘** | — | **0** | 13차에 맞던 축(claude 카드내부 세로·codex 섹션 세로) 14차 무파손 |

- 화면/위젯명은 14차 신규 생성이라 file:line 불가 — **컨테이너 *축* 패턴**으로 대조(앵커=축, 라인 아님).
- **★오라클 = 사용자 육안**(자동 FID 미발동·design §10). grep는 구조 보조.
- **N=1·인과 단정 금지** — "처방이 회귀 해소를 *유발*" 아니라 "처방 후 세로 관찰".

## 겨냥 안 한 dim (이번 시술 범위 밖 — 14차 관측만·처방 0)
- **DT-2 (★14차 swap·1순위 미시술)**: 13차 codex 무가드 FAIL → 14차 **codex 자발 가드 PASS(`safe_api_call.dart:60-64` `_tryServerResponse` try/on-Object)·claude 무가드 FAIL(`:20` fromJson `on DioException` 내부)로 swap**. 코퍼스 미규정 N=1 비결정의 **N=2 입증**(같은 구멍이 회차마다 다른 엔진에서 발현). 레이아웃 시술과 무관. → **다음 라운드 1순위**(가드 골든 `architecture-data`/`implementation-dart`: safeApiCall이 fromJson 자기 정규화기 throw도 try/catch 단일출구 수렴). 3-grader 만장일치+조정자 정독·false green(`weather_repo_test` 404 바디 부재) 확인.
- **claude FC-2**: 13차 자발 비-vacuous(N=1 변동)·재발 방지 후속 가치(12차 compare 부록 #1).
- **screenProbes A1 폴백**: 9차부터 미해결(측정 진입점)·**측정 설계로 미룸**(이번 육안). 단 배포 implementation-test §7엔 규약 존재(코더 산출물이 안 따름).
- **size-link·asset(feedback-014 L·A)**: **유지=회귀 가드** — 14차에 hero 120·`Image.asset(AppAsset)` token=배선 유지 확인(형상 시술이 값 운반 안 깼나).

## 회차 요약 (14차 · `results/20260622-1636`)
- 예상 적중 **1/1**(F 형상 양 엔진) · 무효 **0** · ⚠️역효과/신규회귀 **0**(형상 시술 표적 한정)
- **한 줄 결론**: **형상 Stitch SoT 시술이 표적대로 작동** — 13차 축 회귀(세로↔가로)가 14차 양 엔진 **6컨테이너 전부 시안 일치**로 회복(claude 메트릭 섹션 Column·카드 헤더 Row / codex 카드 flex-col·hero baseline·앱바 고정·grep+g3 독립대조 6/6·6/6). 프레임(hero120·maxWidth480·에셋[claude]) 유지·신규 뒤집힘 0. **★최종 육안=사용자 `flutter run` 대기**. **부수 발견(형상 무관·N=1)**: DT-2 양 엔진 swap(claude 13차 PASS→14차 무가드 FAIL·codex 13차 FAIL→14차 가드 PASS) → 픽스처 13차와 역전(claude FAIL·codex PASS, 단 결정 인자 DT-2는 코퍼스 미규정 비결정이라 엔진 실력차 아님)·codex 에셋 공급 회귀(claude 유지)·codex dart-define 흠 해소.
- **★선기록 교훈 입증**: measure-first 지표는 *실패 모드를 담아야* 한다 — feedback-014 점값 size(hero 120)는 축 회귀와 직교라 거짓성공을 냈다. feedback-015는 **축(형상)을 지표**로 삼아 양 엔진 적중을 정확히 포착(함정 회피 확인). in-family grader·자동 FID 부재라 사용자 육안이 형상 오라클·g3 grep 보조.
- ⚠️ N=1 인과 단정 금지(형상 회복도 "시술 후 관찰"·양판 2/2 동시라 신호 강함).
- **다음 1순위**: 🔑 **DT-2 가드 골든**(feedback-014/015 예고·**N=2 입증**: codex 13차+claude 14차 같은 구멍·swap) — safeApiCall이 `fromJson`(정규화기 자신)의 throw도 try/catch로 단일출구 수렴. → 신규 fix 회차.
