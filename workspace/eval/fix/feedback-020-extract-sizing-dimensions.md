# fix 020 — extract 치수 추출 확장 (리스트 과대 결정론 채널 복원)

> 사전등록형 + **시술 완료**. 예상효과를 *고친 직후* 박고 16차 결과지로 실측 대조(EVAL §자기보고 불신).

## 메타
- **회차**: 020
- **트리거**: 15차 codex 산출물 사용자 육안(리스트 아이템 과대·이미지 하단 짤림) + 본세션 workflow RCA(`wf_8490981f`·9에이전트) + 적대 3렌즈 교정
- **베이스 코퍼스**: `7c28c13`
- **시술 커밋**: `1fc7946`
- **검증 런**: 16차+ (육안·자동 게이트 불가)
- **상태**: **검증됨**(✅ 적중 1/1 — 16차 codex 96/36 토큰 승격·green·미러 11/11·양판 IDENTICAL)

## 증상 (사용자 육안 — FID-L4·자동 미측정 영역)
codex 15차 weekly 화면: ① 리스트 아이템이 시안보다 큼 ② 브로콜리 이미지 하단이 짤려 보임. (claude는 UI/UX 정확 — 사용자 평가)

## RCA (workflow + 메인 보완 + 적대 3렌즈 교정)
**3증상으로 분해되고, 코퍼스로 고칠 수 있는 건 ①뿐:**

### ① 리스트 과대 → **extract 정규식 공백(1층 단일 뿌리)** [본 처방 대상]
- codex 열폭 `width:104`·아이콘 `size:40`(눈대중 매직넘버) vs 시안 `w-24`=96px·`text-4xl`=36px vs **claude 96·36 정확 명중**.
- 뿌리: `extract_design.dart:327` `_arbitrary` 정규식이 대괄호 `-[...]` 리터럴만 잡아 **plain Tailwind 치수 유틸(`w-24`·`text-4xl`)을 카테고리째 누락** → 아이템 치수가 `design-tokens.json`에 도달 못함(양 엔진 공통 빈 채널). claude는 `design-spec.md:478`에서 architect가 `text-4xl≈36px` *수기 환산*으로 우회 보정(비결정), codex는 미환산 → coder 눈대중.
- **적대 교정**(렌즈 B): 2층(architect 환산)은 비결정 땜질이라 결정론 교정은 **1층(extract)으로 수렴**. 카드 패딩은 시안 20과 일치(과대 아님) — 과대는 열폭/아이콘 +8/+4 경미.

### ② 이미지 검은 사각형 → **Stitch 시안 src URL 오매핑** [코퍼스 밖·처방 불가]
- 사용자가 본 "검은 사각형"은 브로콜리가 아니라 **"바이브 코딩" 홍보 이미지**(512×383·알파 없음·양 엔진 md5 `c1caf648` 동일).
- ★**URL 재취득 실측**: manifest src(`lh3.googleusercontent.com/aida-public/AB6…`·alt="Broccoli Icon")가 **지금도 HTTP 200으로 그 이미지 반환** → 만료 아니라 **시안 URL 자체가 오매핑**. `fetch_images`는 src를 충실히 따랐고 받은 PNG도 유효 — **dddart 파이프라인 밖(Stitch 입력 결함)**. 코퍼스로 고칠 수 없음(내용 오라클=비전 필요·과함).

### ③ z-order 가림 → **codex §9:248 위반(규율 존재)** [폐기]
- codex가 시안 음수마진 겹침(`-mb-16 z-20`)을 `Transform.translate(0,-64)`로 번역하며 리스트를 이미지 위 레이어로 그림(이미지 하단 가림). 단 `impl-flutter §9:248`("`<img>` 위치·형제 순서 시안 그대로 재현")이 **이미 강제** → 규율 부재 아니라 coder 변동성. claude는 겹침 *생략*(양 엔진 다 시안 겹침 미재현).
- **폐기 근거**(적대 렌즈 C): §9 중복 + **feedback-015 "코퍼스 레이아웃 어휘 0·Stitch HTML=형상 SoT" 공리 정면 위반**(z-order는 형상) + weather 과적합. ②에셋이 체감 주범이고 z-order는 2차 귀결.

## 시술 (적용 완료)
| # | 대상 | 처방(파일·미러) | 예상효과(전→후) | 실증 |
|---|---|---|---|---|
| 1 | 리스트 과대(열폭·아이콘) | `extract_design.dart` `_collectClassTokens` 치수 확장(`w/h/size-N`→`N×4px`·`text-{scale}`→px 테이블·**gap/p/m 제외**) + `architecture-ui §8` "plain 치수 전수" 명시 | 16차 codex 열폭→96·아이콘→36(claude 수준 결정론 인용) | ✅ **e2e: codex design-ref 재추출 시 `w-[96px]`·`text-[36px]` 등 치수 10종 `arbitraryValues` 합류**(라이브런 7종→17종·미세간격 미합류) |

- **미러**: `extract_design.dart` **수동 양판**(dddart `scripts/` ∥ codex `skills/dddart/scripts/`·corpus_mirror_sync는 final.md만 미러)·byte-IDENTICAL 검증. `architecture-ui final.md` auto(`--write`·소스·codex). **미러 11/11 in-sync**.
- **처방2(architect px 환산) 독립 시술 불요**: §8 전수·빈칸0 + `design-architect.md:38·63` 자기점검이 이미 배선 → 새 토큰 자동 흡수.

## 모순 점검 (다른 코퍼스 — 전수)
- §7 "미세간격=`app_spacing`"·"무의미 토큰 양산 방지": ✅ gap/p/m·비율(`w-1/2`)·키워드(`w-full`)·비-크기(`text-center`) 전부 제외(단위테스트 실증).
- §8 "형상과 직교(절대 크기만)": ✅ 크기만·배치 무관.
- **feedback-015 "레이아웃 어휘 0"**: ✅ 크기는 §8 *값*이지 형상 *어휘* 아님(z-order는 형상이라 ③ 폐기로 일관).
- Track A/B: ✅ `extract_design`(토큰) vs `extract_layout`(형상) 분리.
- 강제력 길목(FC-2 교훈): ✅ extract(결정론 스크립트) + §8 강제(이미 배선) — 지식만 고치는 함정 회피.

## 과적합 적대 리뷰 (커밋 전·2렌즈·사용자 요청)
- **과적합 무혐의** (렌즈A 스케일 하드코딩·렌즈B 화이트리스트 독립 확증):
  - ① Stitch `tailwind-config`는 **named 토큰만 추가·numeric 스케일(`'24'`·`'4xl'`) 재정의 0**(실측·양 엔진) → 하드코딩 = config 읽기와 **byte 동일 결과**.
  - ② `w-24`→96·`text-4xl`→36은 **Tailwind v3 공식 스펙 강제값**(spacing 1스텝=0.25rem=4px·`text-4xl`=2.25rem=36px·공식 docs)·**역설계 아님**("표준이라서 codex가 틀린 것").
  - ③ 화이트리스트 `w/h/size/text`는 weather 맞춤이 아니라 **§8 size/form 직교 원리** — 누락된 `min-h-screen`·`max-w-md`는 *형상*이라 제외가 옳음.
- **견고성 교정 반영**(ⓐⓑ·이 시술에 포함):
  - ⓐ `_sizingFont`에서 **본문 크기(`text-xs/sm/base` ≤16px) 제외 → 헤딩 스케일(`lg`↑)만**(노이즈 사전 차단·weather 0회·미래 가드). e2e 불변·단위테스트 경계 확인.
  - ⓑ 주석에 **"Stitch extend-only 전제(base 교체 시 무효)·형상 유틸 의도적 제외"** 원리 명시(under-fit 가드).
- **별도 처방 보류**(ⓒ·measure-first): §8 "전수·빈칸 0"이 저신호 치수를 hero와 동급 핀 강제 → 복잡 시안에서 hero 신호 매몰 위험. weather 17종 미발현이라 신호 등급제는 다음 런 관찰 후 별도.

## 측정 (★자동 불가)
- 크기 과대 = FID-L4·`compare_layout`이 image 제외·layout-ir에 치수축 없음 → **자동 게이트 불가**. 16차 실측 = grep(codex 산출 size 리터럴) + 시안 대조 + **사용자 육안**.
- ⚠️ feedback-014 거짓성공 함정 — "점값 96 적중"을 성공으로 박지 말고 *형상·전체 인상*까지 본다.

## 비-처방 기록 (코퍼스 미수정)
- **②에셋 오류**: Stitch 입력 결함·코퍼스 밖. 라이브런 시 사용자 이미지 육안 확인(A1)으로. [[stitch-image-asset-bundling]] "URL 수명보장없음"의 새 발현 — 단 이번은 만료 아니라 *오매핑*.
- **③z-order**: §9 중복·공리 위반·경미 → 폐기.

## 회차 요약 (16차 후)
- 예상 적중 **1/1** · 무효 **0** · ⚠️역효과 **0**
- **한 줄 결론**: codex `app_spacing.dart forecastSlotWidth=96`·`forecastConditionIcon=36`(15차 104/40 눈대중 매직넘버→**AppSpacing 토큰 승격**·시안 w-24=96px·text-4xl=36px 정확)·design-tokens `w-[96px]`·`text-[36px]` 양판 합류 = 결정론 채널 복원. claude는 이미 직독 96/36(변별=codex 단독). **부수 이득: codex 크기 토큰 경유로 VW-4 무누출**(claude는 `fontSize:18` 리터럴 🟡). 측정=육안(FID-L4·자동 불가).
- ⚠️ N=1 인과 단정 금지 — "020이 96 인용을 *유발*"이 아니라 "020 적용 후 16차 codex 96 인용 관찰". claude는 이미 96(직독)이라 변별은 codex 단독 — 자발 변동 가능성 상존(실측 확인).
