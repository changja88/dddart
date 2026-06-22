# fix 014 — 레이아웃 크기연결 + 에셋 공급 파이프라인 (사전등록형·13차 검증대기)

> **트리거**: 12차 양판(`results/20260621-0203-weather-{claude,codex,compare}.md`). **북극성 = 이미지/레이아웃 생성측**(평가측은 완비·11차 무승부 후 ★초점 이동).
> **순서 단서(정직)**: 시술은 compact 전 완료(`8fe3800`)·이 사전등록은 **13차 라이브런(측정) 전 작성**이라 measure-first 정신은 보존(④예상효과를 ⑥실측 전에 박음 → 13차 결과지가 채점표). ⑤시술커밋이 미리 채워진 건 이례(시술→사전등록 역순)이나 핵심(사후 합리화·헛처방 차단)은 **측정 전**이라 유효. 역순인 만큼 ④는 시술 design 문서(`2026-06-21-layout-enforcement-design §6`·`asset-track-a-design §8`)의 사전 측정 계획을 그대로 옮긴 것(시술 후 끼워 맞춘 게 아님).

## 메타
- **회차**: 014
- **트리거**: `results/20260621-0203-weather-{claude,codex,compare}.md` (12차)
- **베이스 코퍼스**: `480eb11` (12차 채점 코퍼스 — Track B layout 입력 유도·AppAsset 토큰 정의)
- **시술 커밋**: `8fe3800` (생성측 강제 v4 — 레이아웃 크기연결 + 에셋 공급 파이프라인)
- **검증 런**: 13차 `results/20260622-0323-weather-{claude,codex,compare,graders-raw}.md` (2026-06-22 채점)
- **상태**: ✅ **적용·13차 검증완료 — L·A 예상효과 2/2 적중**

## 배경 — 12차 측정 기준선 (북극성 = 생성측 이미지/레이아웃)
- **레이아웃 크기**: claude는 area 충실(area 토큰 19회)이나 **크기 흘림**(hero 상태 아이콘 시안 120 → **32px**). codex는 크기 자발 충실(codex *architect*가 spec:208에 박음)·area는 자기변형(영역 drop 의심). → 차이 = **area엔 "정형 출력 강제"(area 어휘 트리)가 있었고 크기엔 없었다**(원인은 "산문 점검이라서"가 아니라 "정형 출력 강제 부재").
- **이미지 에셋**: 양판 `Image.asset` **0**·pubspec `assets:` **주석**·다운로드 **0**(이미지 자리만·실제 미반영). 소비측(AppAsset 토큰·사용 규칙)은 Track B(`480eb11`) 완비, **공급측이 빈 사슬**(다운로드·번들·pubspec 소유자 0).
- **갈림(처방 밖)**: claude FC-2 vacuous(치명 FAIL)·codex DT-3 plain BadReq·codex 라벨 drift — 이번 시술과 **무관**(레이아웃/에셋 아님).

## 교정 항목 (사전등록 표 — ①~⑤ 작성·⑥은 13차 후)

| # | 우선 | ① 대상 결함 | ② 원인(뿌리·코퍼스 책무 공백) | ③ 처방(파일·미러) | ④ 예상효과(전→후) | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| **L** | 🔑 | **레이아웃 크기 충실** — 12차 claude hero 아이콘 120→32px 퇴행(육안+grep·RUBRIC 정식 dim 없는 북극성·FID L4/미관 영역) | 생성측에 "추출된 크기를 분해한 조각에 연결하는 size-link" 부재. area엔 정형 출력 강제(area 트리) 있었고 크기엔 없었다 | **design-architect** triage 정형목록 출력강제(추출 `arbitraryValues`·비도메인 `typography` 전수 1줄 결정[채택/미채택+조각 연결]·빈칸0)+소비 지시에 크기 추가 / **architecture-ui §8 신설**(크기→조각 연결 규율)·양판(agents 수동·final.md `--write`) | (1차 architect) design-spec에 triage 정형블록 출력(추출 토큰 전수) → (2차 coder) hero `Icon`/`Image` size를 시안값(120/96/32) 근접 반영. **claude 32→120 회복**. **codex 무변**(이미 자율·회귀 가드) | `8fe3800` | ✅**적중**: 양판 hero **120**(claude `iconSize=120`·12차 32→회복·codex `detailWeatherIconSize=120` 유지)·architect triage 출력(claude 11·codex 7)·2단 작동 |
| **A** | 🔑 | **이미지 에셋 미반영** — 12차 양판 Image.asset 0·pubspec assets 주석·다운로드 0 | 공급측 빈 사슬(다운로드·번들·pubspec 소유자 0). 소비측(AppAsset)은 Track B 완비했으나 공급측 0 | **fetch_images.dart 신설**(Phase 0 다운로드·manifest SSOT·token 결정론)+**Coordinator**(fetch 호출·`has_design_images`·G0 배너·closed-list)+**design-architect**(src 의미매핑 정형목록)+**implementation-flutter §8**+**coder**(manifest src 조인·app_asset·pubspec 멱등·Image.asset)·양판(final.md `--write`·SKILL/agents/scripts 수동+`cmp`) | 다운로드 ok(`assets/images/*.png` 존재·manifest `status:"ok"`)·pubspec `assets/images` 선언·`Image.asset(AppAsset.X)` 배선·**manifest token수 = 배선수**(흘린 이미지 0·중첩 누락 0). 양판 | `8fe3800` | ✅**적중**: 양판 다운로드 ok(claude `weather-list-1.png`·codex `list-1.png`)·`Image.asset(AppAsset)` 배선·**token=배선 1=1**(흘림0)·pubspec 선언·has_design_images true |

- **②원인 공통**: 12차 compare §3 결론 — *시술한 부분(설계측 area 입력 강제)은 작동, 미시술 부분(크기 연결·에셋 공급)은 갭*. L·A 둘 다 **생성측 한 곳**(L=architect 정형강제+coder 집행 / A=Phase0+architect+coder 사슬)이라 N=1 단일 변수 격리.

## measure-first 측정 (13차·grep 사전등록 — design 문서에서 이전)

**레이아웃 크기(L) — 2단 분리**(어느 단계가 흘리나 격리·`2026-06-21-layout-enforcement-design §6`):
- **1차(architect 출력)**: design-spec에 triage 정형 블록 존재? 추출 토큰 전수 1줄 결정 목록(채택/미채택+조각 연결). `grep`로 triage 블록·항목 수 = 추출 토큰 수.
- **2차(coder 반영)**: 산출물 hero 위젯 size 리터럴 grep → 시안값 대조. 사전지정 위젯 = **상세화면(`daily_forecast_detail` 류) hero `Icon`/`Image` size**. 12차 실측(120/96/32) 비교 기준. claude 32→시안 근접이면 ✅·여전히 32류면 (2차 흘림)=coder측 후속 강제 트리거.
- **codex 무변 확인**: 규율 추가가 이미 자율로 하는 codex 산출물을 바꾸지 않나(회귀 가드).

**에셋(A) — grep 구분**(`asset-track-a-design §8`):
- **다운로드**: `ls <run>/assets/images/*.png` + manifest `status:"ok"` 수 > 0.
- **pubspec**: `grep 'assets/images' <run>/pubspec.yaml`.
- **배선**: `grep -rc 'Image.asset(AppAsset.' <run>/lib/` — **존재만으론 부족**. **manifest token 수 = 배선 수 대조**(다운로드 N개 중 배선 M개 차 = 흘린 이미지·중첩 누락 검출).
- 양판 각각.

**동시·분리 관측**: 크기(L)와 이미지(A)를 각각 grep으로 구분(한 런에 두 시술이라 dim 혼선 방지). N=1·인과 단정 금지.

## 겨냥 안 한 dim (이번 시술 범위 밖 — 13차 재발 관측만·처방 0)
- **claude FC-2 vacuous**(12차 치명 FAIL): 이번 시술 **무관**. 13차 재발 시 별도 라운드(12차 compare 부록 #1 = `implementation-test`/`discipline-test`에 "매핑 검증=6종 전수 expect·distinct 불충분" 명문화). **처방 안 했으니 그대로일 수 있음**(정직 — 13차도 claude 치명 FAIL 가능).
- **codex DT-3 plain BadReq·라벨 drift**: 무관·관측만.
- **screenProbes 미노출 → FID 게이트 A1 폴백**: 9차부터 미해결(코더측 출력 규약·이번 무시술). **13차도 A1 폴백 예상** → 레이아웃 크기 검증은 자동 FID 아닌 **grep+육안**(design §6 "정직 격하" 인정).
- **결정적 floor**(`check_pubspec`에 "Image.asset 있는데 pubspec assets 미선언 발화"): 13차 후 measure-first 후속(이번 미적용·`asset-track-a-design §5·§8`).

## 회차 요약 (13차 후 — 2026-06-22 채점)
- 예상 적중 **2/2**(L·A 둘 다 양판 작동) · 무효 **0** · ⚠️역효과/신규회귀 **0**
- **한 줄 결론**: **레이아웃 크기연결·에셋 공급 두 시술 모두 양 엔진 집행 확정** — claude hero 32→120 회복·codex 120 유지(L)·양판 에셋 다운로드·배선·token=배선(A). 12차 "이미지 자리만·hero 크기 퇴행" 해소. 생성측 북극성 1차 목표 달성.
- **겨냥 안 한 dim 실측**(처방 표적 밖):
  - **claude FC-2 자발 개선**: 12차 vacuous(치명 FAIL)→13차 비-vacuous(M2 매핑 swap red). feedback-014 미시술이었으므로 **N=1 산출 변동**(인과 단정 금지). → 12차 부록 #1(매핑 전수 expect 명문화)은 *코퍼스 강제 없이도* 이번엔 충족됐으나, 재발 방지엔 여전히 후속 가치.
  - **codex DT-2 신규 치명 FAIL**: safe_api_call fromJson 무가드 누수(12차 미관측·13차 발견). → **다음 라운드 1순위 fix**(compare 부록 #1·#3).
  - **screenProbes 양판 미노출**: FID 자동게이트 A1 폴백 지속(예상대로·코더측 미시술).
- **결정적 floor 후속**(check_pubspec): 13차 에셋 양판 작동 확인 → floor 도입은 *재발 시* 판단(이번 무재발이라 보류 유지·measure-first).
- ⚠️ N=1 인과 단정 금지 — "처방 X가 Y를 유발" 아니라 "X 적용 후 Y 관찰". in-family grader 한계(DT-2 split 조정자 확정).
