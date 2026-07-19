# fix — 코퍼스 교정 원장 (원인분석·처방·검증)

라이브런 → 채점(`results/`) → **원인분석·처방(여기) → 코퍼스 교정 커밋 → 재라이브런**의 폐곱(closed loop)을 닫는 영속 기록.

## 왜 분리하나 (measurement vs prescription)

- `results/` = *측정*(이번 런이 어땠나). `fix/` = *처방*(무엇을 왜 고치고, 다음 런에서 어떻게 바뀌어야 성공인가).
- 종전엔 "교정 후보"가 결과지에 묻히고, 실제 교정은 git 커밋에만 남아 **근거·예상효과·실측이 한 곳에 없었다**. 그래서 "1차 피드백이 나아진 게 있나?"에 git 로그를 역추적해야 했다(→ `feedback-003` 회고가 그 사례).
- **핵심 장치 = 예상효과 사전등록**: 고치기 *전*에 "다음 런에서 어느 측정 dim이 전→후로 바뀌어야 성공"을 박는다. 다음 런 결과지가 그대로 채점표가 되어 **사후 합리화·헛처방을 조기 차단**한다. (feedback-003이 실패한 이유 = 이 칸이 없어 결정적 치명 미겨냥이 사후에야 드러남.)

## 구조

- `TEMPLATE.md` — 사전등록형 1회차 양식(복사 → `feedback-NNN-<요지>.md`)
- `feedback-NNN-*.md` — 회차별 1파일(결함별로 쪼개지 않음·한 회차=여러 교정 묶음)
- **001·002는 1차 라이브런 *이전* 코퍼스 정비라 전후 실측이 없음** → fix 추적은 003(1차→2차 사이 유일 교정)부터.

## 인덱스

| 회차 | 트리거 | 시술 커밋 | 상태 | 한 줄 |
|---|---|---|---|---|
| [003](feedback-003-typehint-navvo-designfidelity.md) | 1차 양판 | `7717607` → 롤백 `17100a9` | ↩️롤백됨 | 3영역 전부 효과 입증 0(디자인게이트 design-ref부재로 비발동·타입 dim0·내비 선-FAIL)·회귀4는 피드백3와 무관(비결정성) |
| [004](feedback-004-test-backstop-label-gates.md) | 2차 양판 | (미적용·제안) | 제안 | 테스트 게이트·백스톱 실행 강제·ST-2 명세일치·G-8 한글 보존 등 7건 사전등록 |
| [005](feedback-005-stitch-typeforce-viewfat.md) | 사용자 3목표 | `d397ad6` → `140d237` | ✅완료(3차 검증) | Stitch 스크립트 추출·타입 전면강제(BC 국소 lint)·view 위젯클래스 차단(NM17)·적대리뷰 4개 반영 |
| [006](feedback-006-testgate-foundation-pin.md) | 3차 양판 | `a8fb2e3` | ✅검증완료(4차) | 백스톱 +2검사(TG 행위테스트·PJ 의존성)·coder 테스트 게이트·riverpod 3.x 핀 — FC-2 비-vacuity만 잔존(→008) |
| [007](feedback-007-stitch-designmd-source.md) | Stitch 연결 후 | (미커밋·배포 동기) | ✅검증완료(5차 **양판**) | 연결 경로 첫 발동·**양판 5/5 프로세스 관측 성공**(design-ref 채움·design_source 핀·has_design_tokens=true·**Stitch 쓰기 0회=읽기전용 HELD**·claude·codex 둘 다)·디자인시스템 실소비. 부작용=제한 팔레트 색충돌(**양 엔진 동일 clear=cloudy=#FEAE2C·2/2**·FC-1/3) — rubric 종합은 FC-2 vacuity로 FAIL(연결 무관·→008·엔진 무관 확정) |
| [008](feedback-008-test-skills-positive-form.md) | 5차 양판 FC-2·FC-1/3 | (코퍼스 작성 완료·미커밋) | 🔧작성완료(6차 검증대기) | 테스트 스킬 2종 신설(`discipline-test`+`implementation-test`·각 3벌)·**positive FORM 가이드**(비-vacuity/디코이·coder 산출+reviewer #8)·§7→포인터(6사이트)·houserules test/ sparse·Key 짝·날짜 주입(시간 가드 철회)·**백스톱 무변경**(`_totalChecks` 55·sync 11/11·픽스처 16/16)·기계 floor는 6차 실측 후 조건부 승격 |
| [009](feedback-009-st2-deadbranch-freezed-gate.md) | 6차 양판 codex 단독 | (적용·미커밋) | 🔧적용·미커밋(7차검증대기) | ST-2 死분기(view가 `state.error` 도달불가 분기·§3원문불변+reviewer 2조건AND·backstop기각)·@freezed 게이트(2-detector·enum/`@JsonKey`컨버터/생성파일/도메인exception 제외·positive-control 반증)·G-8 변경없음(§2.2가 처리)·DT-5/finalize-collapse 후속 |
| [010](feedback-010-navseam-weaksweep-determinism.md) | 7차 양판 + 시술직전 적대2차 | `327640c`+`882cc0c`(v2) | 🔧v2 전부적용·커밋(8차검증대기) | **v2(적대2차 정정)**: FC-2 진짜레버=측정 seam(골든 M4+VW-7 FAIL문언+repo 중복·코퍼스 산문 단독은 8차도 green)·ST-8 백스톱(변종포함 positive-control·신규ID·산문잉여)·SD-3 **측정명확화**(codex parse 적법·도메인*Exception 치환 폐기·RUBRIC 경계)·위젯키 super.key(lint floor 분담·dim Q-1 텍스트밖)·테스트결정성 **차원→게이트 강등**(isolate static 비공유→오염 불가·reset 실재·randomize→병렬×N)·아이콘=UI/A1 배제·measure-first 선결 6·적대 1차11+2차8 서브에이전트 |
| [011](feedback-011-fidelity-structure-gate.md) | 8차 양판 | FID 게이트 신설(`fid-gate.sh`) | ✅9차 운용 | 시각 충실도 갭(codex 섹션 이탈·양판 삽입 이미지 미사용·bottomnav 누락)이 A1 오라클이라 자동 회귀 미포착 → 시안↔코드 구조 결정론 대조 L1·L2 치명 게이트 신설(2026-06-19 활성) |
| [012](feedback-012-im22-codec-floor-codegen-ratchet.md) | 9차 claude IM22 토끼굴 | `d30cd85`(R1~R7) | ✅10차 검증(IM22 무재발) | claude IM22 false-positive 2h 표류 RCA(carrier 모델링·IM22 버그·런중 표류)·R1~R7(R6 종결·R7 NM13 go_router 게이트) |
| [013](feedback-013-md1-invariant-pattern-gap.md) | 10차 양판 백스톱 폭발 | `60a63aa`(R6+R1~R4) | ✅11차 검증(plain 차단 확정·R5 보류) | 막판 백스톱 폭발(claude11·codex14)·1h→2h 회귀 = MD1×명세격상×엔진plain 곱·기계 floor(R6 MD1메시지·R5 명세린터 보류) |
| [014](feedback-014-layout-size-asset-supply.md) | 12차 양판 | `8fe3800` | ✅13차 검증완료(L·A 2/2 적중) | 북극성=생성측: 레이아웃 크기연결(architect triage+ui §8) + 에셋 공급(fetch_images·manifest SSOT·Image.asset). **13차 실측: 양판 hero 120(claude 32→회복·codex 유지)·에셋 token=배선·둘 다 작동**. 부수: claude FC-2 자발해소·codex DT-2 신규치명 |
| [015](feedback-015-layout-stitch-sot.md) | 13차 양판(사용자 육안) | `e49b4fe` | 🔧적용·14차 육안 검증대기 | **feedback-014 "L 적중"=거짓성공 RCA**: size-link(점값) 적중했으나 번들된 축맹 area-tree가 형상(축) 회귀(세로→가로·양엔진·claude 강제전>후). 공리=코퍼스 레이아웃 어휘 0·**Stitch HTML=형상 SoT**(impl §9·coder 승격·architect 분해전담·area-tree 철거)·측정=육안. codex DT-2 1순위 유지 |
| [016](feedback-016-fid-measurement-dt2.md) | 14차 양판(`20260622-1636`) | `<미커밋>` | ⏳15차 검증대기 | **DT-2 단일출구 누수**(safeApiCall `on DioException` 절 *내부* `fromJson` throw를 형제 `on TypeError`·말미 catch-all이 못 잡고 샘·N=2 swap) 골든 try/on Object 가드 + **screenProbes green 강제**(6회 게이트 미발동 종결·헬퍼 아닌 별도 `render_smoke_test.dart`+isNotEmpty). image set-membership은 017로 분리 |
| [017](feedback-017-image-fidelity-eye.md) | 14차 후속(게이트 활성 부작용) | `<미커밋>` | ⏳15차 검증대기 | feedback-016가 FID 게이트 실발동시키며 **image area↔slot 레벨차 거짓 FAIL 위험** → `compare` L1/L2에서 image 제외(위치=L4 **육안**)·`§9` "`<img>`도 형상" 제자리 재현 유도(생성측 단독·coder/architect/review-ui 불변)·positive-control ⓐⓑ 반증. fetch_images 통째빠짐은 014 후속 분리 |
| 018~031 | — | — | (인덱스 미기재) | 각 `feedback-0NN-*.md` 파일 직접 참조 — 인덱스 백필은 별도 작업 |
| [032](feedback-032-hive-local-storage-restructure.md) | broccoli_app hive 첫 도입(NM3 오탐 리포트) | `<미커밋>` | 🔧적용·검증대기(다음 hive 런) | **hive 배치 재설계** — `data_source/local_storage/` 하위층(접근+스키마 `_box.dart` 파일당 1모델+배선 등록 함수만), NM1·NM3 **면제 소멸**, ST6 하위 경계, **HV1 신설**(box @HiveType 필수 — HV2·HV3는 보류·승격조건 명기), registrar footgun §5 명문화, §6→§5 drift, 총계 60종 일괄. **시술 전 적대 리뷰 3렌즈**(코퍼스 모순·과적합·실효성) 반영 v2 — 픽스처 56/56·positive-control hv 무발화·미러 11/11 |

## 규약

- **사전등록 먼저**(①~④), 실측(⑤~⑥)은 다음 라이브런 후. 빈 ⑥은 "검증대기"의 정상 상태.
- **N=1 인과 단정 금지**: "처방 X가 회귀 Y를 유발"이 아니라 "X 적용 후 Y 동시 관찰"로 기록.
- **코퍼스 수정 경로**: deploy `dddart/skills/*/references/final.md` 편집 → `corpus_mirror_sync.py --write`(소스·codex 동기) / SKILL·agents·commands 수동 양판 미러 / backstop·FC-GOLDEN·eval(`workspace/eval/`)은 단일 출처(미러 불필요).
- **fix 자체도 eval 하위 → 양판 미러 불필요.** 코퍼스 교정 *적용*은 별도 사용자 승인(코퍼스 불변 방침).
- backstop 규칙 신설분은 `tools/positive-control`로 거짓-FAIL(기계가 PASS도 낼 수 있나) 반증 후 투입.
