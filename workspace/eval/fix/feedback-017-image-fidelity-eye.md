# fix 017 — 이미지 충실도 생성측 유도 + FID 게이트 image 제외 (육안 오라클·사전등록형)

> 복사본. **핵심 = "예상효과"를 *고치기 전*에 박고, 다음 라이브런(15차) 결과지로 "실측"을 채워 대조.** image **위치**는 자동 미측정 — 육안 오라클([[feedback-015]]·★측정=사용자 눈)이 판정하고 생성측 §9가 시안 자리 재현을 유도한다. fetch_images 통째빠짐 안정화(asset 공급)는 [[feedback-014]] 후속 별도 라운드.

## 메타
- **회차**: 017
- **트리거**: feedback-016(screenProbes green 강제)가 FID 게이트를 **실발동**시킴 → 켜진 게이트의 `compare_layout`이 image를 area(top-level)↔slot(섹션 내부) **레벨 비대칭**으로 비교해 **15차부터 거짓 FAIL 위험**(시안 image=top-level `<img>`→area role 'image' vs 코드 image=컨테이너 내부→slot type 'image'·동일 이미지인데 L1/L2 시퀀스 불일치). + 이미지 "제자리" 보증 부재(존재만 세면 위치 무의미·사용자 지적 "제자리에 그리지 않으면 의미 없다").
- **베이스 코퍼스**: `506e7ea` (시술 직전 HEAD·feedback-016과 동일 베이스·in-flight 공존)
- **시술 커밋**: `<미적용 — 사용자 승인 후 커밋>`
- **검증 런**: `results/<15차 라이브런>` (재라이브런 후 채움)
- **상태**: 적용·미커밋 (15차 검증대기)
- **선행 게이트**: positive-control ⓐⓑ PASS(image area→slot 위치차 거짓 FAIL 0)·기존 7케이스 회귀 0("L1 영역누락"은 bottomnav로 정탐 유지)·`dart analyze` green·3사본 미러 in-sync(`--check` exit 0). 설계 `2026-06-22-image-fidelity-eye-design.md`(2차 적대 검증 통과)·plan `2026-06-22-image-fidelity-eye-plan.md`(적대 검증 BLOCKER 0·MAJOR 1[Task 8 델타가드]·MINOR 보정·measure-tool 패치 실측 PERFECT).

## 교정 항목 (사전등록 표)

| # | 우선 | ① 대상 결함(dim) | ② 원인(뿌리·코퍼스 공백) | ③ 처방(파일·미러) | ④ **예상효과**(전→후) | ⑤ 시술커밋 | ⑥ 실측·판정 |
|---|---|---|---|---|---|---|---|
| 1 | 측정 | **image 거짓 FAIL**(FID-L1/L2) — feedback-016가 게이트 켜며 15차부터 발현 위험 | image가 area(top-level `<img>`)↔slot(컨테이너 내부) **레벨 비대칭** → 총수/시퀀스 대조가 동일 이미지를 불일치로 읽음. 자동 *위치* 측정은 렌더 좌표=스크린샷 영역(사용자 배제·feedback-015) | `compare_layout.dart` L1 `.where(role!='image')`·`_flattenSlots` 단일 emit point `type!='image'` 필터 + 헤더 doc / `layout-ir-schema.md §3` 비교규칙 주석(노드 §1 동결) / `RUBRIC §H`·`EVAL §2.3 A'` FID-L1 image scrub·L4 이관 / **eval 단일(미러 불요)** | **15차 compare가 image로 exit 2 안 냄**(image area↔slot 레벨차 거짓 FAIL 0·positive-control ⓐⓑ 즉시 반증·기존 정탐 E/F/L1영역누락 유지) | (미적용) | (대기) |
| 2 | 생성(육안) | **이미지 제자리 재현** — 존재만으론 위치 무의미 | §9가 형상 일반론만 말하고 `<img>`를 콕 집지 않아 "배선만 하고 시안 위치 흘림" 여지. §8(에셋)은 *무엇을* 가져올지만 정함 | `implementation-flutter/references/final.md §9` 새 불릿("`<img>`도 형상의 일부"·컨테이너 내 위치·형제순서 시안 재현) / `corpus_mirror_sync.py --write`(3사본) / coder·architect·review-ui **불변**(§9 단독) | **coder가 `<img>`를 시안 자리에 재현**(배선만 하고 위치 흘림 0) — 양 엔진 시안 대조 시 image 위치 일치 | (미적용) | (대기·**사용자 육안**) |

- **②원인**: 둘 다 뿌리 = "image의 *위치*가 자동 측정 부적합(area↔slot 레벨 비대칭·렌더좌표=스크린샷)". 측정은 그래서 게이트에서 **빼고**, 생성은 §9가 시안 자리를 **콕 집어** 육안 판정 재료를 옳게 만든다.
- **③처방·미러**: §9 1불릿 = `corpus_mirror_sync.py --write`(배포→소스+codex 3사본·in-sync 확인). compare/run.sh/schema/RUBRIC/EVAL = **eval 단일**(미러 불요). coder·architect·review-ui = 불변(수동 미러 없음). 스키마 노드 §1 동결(`extract_layout`이 image area 계속 방출·`ref.json` SoT·육안 재료).
- **④예상효과**: image = **L4 육안 이관**. positive-control ⓐⓑ가 *즉시* 거짓 FAIL 0 반증(시술 시점 확증). 다음 런 compare가 image로 exit 2 안 냄(15차 실측). 항목 2(제자리)는 **자동 측정 없음** — 사용자 육안만(grep/code 무관·feedback-015 오라클).

## 보류·분리 (이 원장 밖)
- **fetch_images 통째빠짐 안정화**: image가 통째 빠지는 것의 *자동* 검출은 의도적으로 안 함(육안·사용자 확정). fetch_images 자체 안정화(asset 공급 신뢰성)는 [[feedback-014]] 후속 별도 라운드.
- **image 위치 자동 게이트화**: 렌더 좌표 측정은 스크린샷 영역(픽셀 비전 게이트 배제·feedback-015)이라 미채택. 재투입 트리거 = "육안으로 image 위치 회귀가 패턴화"될 때만 재검토.

## 회차 요약 (다음 런 후)
- 예상 적중 **N/2** · 무효 **N** · ⚠️역효과/신규회귀 **N**
- **한 줄 결론**:
- ⚠️ N=1 인과 단정 금지 — "X 적용 후 Y 관찰(동시발생)"로 기록. 항목 1(거짓 FAIL 0)은 compare exit로 결정 판정 가능·항목 2(제자리)는 **사용자 육안 판정**(grep/code 무관).
