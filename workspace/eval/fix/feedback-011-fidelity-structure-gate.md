# fix 011 — 시각 충실도 평가측: 구조 충실도 게이트(FID-L1·L2·layout-ir) (사전등록형·1/3단계)

> **배경(트리거)**: 8차 양판에서 평가지에 없던 시각 충실도 갭이 표면화 — codex가 Stitch 시안과 다르게 그림(섹션 분해 이탈)·양엔진 모두 삽입 이미지 미사용·**bottomnav 누락**(list/detail 양 화면). 시각 충실도는 A1 인간 오라클(EVAL §2.5 의도적 자동 비측정)이라 **기능 PASS인데 시안 불일치가 자동 회귀로 안 잡힌다**.
> **자료조사·설계 완료(2026-06-19)**: 심층 자료조사(4축·1차 출처)·전제검증(Stitch HTML 시맨틱·`absolute=0`·무의존 파싱 가능)·평가측/생성측/스키마 설계·list/detail 검산·이미지 URL 실측. 근거 4문서 = `workspace/design/2026-06-19-{stitch-fidelity-research,fidelity-eval-design,fidelity-generation-design,layout-ir-schema}.md`.
> **3단계 로드맵**(measure-first "평가측 먼저" — 생성 개선 효과를 평가측으로 측정): **1=평가측(이번 011)** · 2=생성측(architect/coder layout-ir 소비) · 3=이미지 번들. 2·3은 코퍼스(생성 파이프라인) 변경이라 별도 회차·별도 승인.
> ⚠️ **정직 표기**: 이건 *결함 수정이 아니라 신설 측정 도입*. N=1·9차가 1차 실측. **효과크기는 dddart 자체 eval로 측정 필요**(자료조사 ScreenCoder +3.6%p는 웹/HTML 외삽). L1·L2 게이트는 **positive-control(등가 산출물 거짓-FAIL 반증) 선결** 후 투입. 특히 L2는 false regression 보정이 초기 몇 회 필요(평탄화+measure-first 보정으로 관리).
> ⚠️ **A1 경계 유지**: 최종 시각·미관 판정은 여전히 사용자 눈. 자동 게이트는 결정론 구조(L1·L2)만, L3=약신호(리포트·눈), L4=인간. VLM grader 보류.

## 메타
- **회차**: 011 (1/3단계 — 평가측 구조 충실도 게이트)
- **트리거**: 8차 양판 시각 충실도 갭(`results/20260619-0124-weather-*`) + 심층 자료조사/설계(2026-06-19)
- **베이스 코퍼스**: `cda1950`(현 HEAD·feedback-010 8차와 동일)
- **설계 근거**: `workspace/design/2026-06-19-{stitch-fidelity-research,fidelity-eval-design,fidelity-generation-design,layout-ir-schema}.md`
- **검증 런**: `<다음 라이브런(9차)·양판>`
- **상태**: **평가측 step 1·2a·2b 핵심 완료(2026-06-19)** — 선결 1·2·3·4 + 도구 4(전부 구현·analyze clean): `extract_layout.dart`(시안 HTML→layout-ir·코퍼스·양판 미러)·`compare_layout.dart`(L1/L2/L3·평탄화·eval)·`dump_probe.dart.txt`(산출물 flutter test 템플릿)+`dump_to_ir.dart`(위젯 트리→layout-ir·eval) + positive-control(평탄화 `run.sh` 반증·8차 실물 등가 흡수). **8차 실측: L1 image/bottomnav 갭 결정론 포착·weekly card/metrics repeat 등가 흡수**. **게이트 활성 직전 — 선결 1건**: 표준 pump 진입점 규약(코퍼스·별도 승인). hero text 흡수 false regression은 `_collapse`(연속 동종 slot 축약·schema §3) 보정 완료(8차 hero L2 ✓·run.sh G 반증). 그 전 비활성·A1 위임. ⑥실측은 9차. 커밋: 미정(사용자 일괄 예정).

## 교정 항목 (사전등록 — ①~④ 작성, 다음 런 후 ⑤~⑥)

| # | 우선 | ① 대상(신설 차원·관측점) | ② 근거(왜·8차 실증) | ③ 처방(파일·measure-first/코퍼스/도구) | ④ 예상효과(전→후·dim) | ⑤ 시술 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| 1 | 핵심(신설 게이트) | **FID-L1**(구조 골격 충실도·신설 치명) — 8차 양엔진 `image` 누락·`bottomnav` 누락(list/detail)·codex 섹션 이탈이 A1 비측정이라 자동 미포착 | 시각 충실도=A1 인간(EVAL §2.5)·자동 회귀 게이트 부재 → **골격 누락이 기능 PASS로 통과**. 8차 검산: 시안 `[appbar,image,section,bottomnav]` vs claude `[appbar,—,ListView,—]`(image·nav 누락) | (RUBRIC·measure-first) `rubric/RUBRIC.md`에 **FID-L1 신설**: 화면 영역(appbar/image/section/bottomnav) **존재·종류·순서=치명 게이트**. 집계 위치(치명 군 편입 vs 별도 FID 군)는 시술 시 RUBRIC 구조 보며 확정. 판정원: 시안 layout-ir vs 렌더 덤프 대조(항목 3 도구) | 전: 골격 누락 미측정(②자동 미포착) → 후: image/bottomnav/섹션 누락 자동 FAIL. dim **FID-L1**. ⚠️신설·N=1·positive-control 선결 | ✅`RUBRIC.md §H` 등록(2026-06-19)·**집계 위치=별도 FID 군(섹션 H)·치명 20 조건부 활성(현 18→활성 시 20)** 확정·`EVAL §2.3 (A')`·rubric-metrix §2.5 | (9차 실측·게이트 활성 후) |
| 2 | 핵심(신설 게이트·평탄화) | **FID-L2**(섹션 구성 충실도·신설 치명) — 섹션 내부 의미노드 순서·존재·반복 분기(8차 claude `ListView` vs codex `header-section`+`card-Column`) | 레이아웃 분해가 LLM *참고*라 엔진 진동·자동 미측정(같은 byte-identical 시안→다른 분해, §3.5 실증) | (RUBRIC·measure-first) **FID-L2 신설**: 섹션 내 의미노드 **순서·존재·반복(`card×N`)=치명·평탄화 비교**(묶음 깊이 흡수·반복 횟수는 데이터 의존이라 제외). **3겹 통제**(평탄화·measure-first 보정·positive-control) `fidelity-eval-design.md §5.1` | 전: 섹션 분기 미측정 → 후: 진짜 차이(누락·순서) FAIL·등가 재구성 PASS. dim **FID-L2**. ⚠️false regression 보정 초기 필요·positive-control 선결 | ✅`RUBRIC.md §H` FID-L2 등록·평탄화 3겹 통제 명문(`EVAL §2.5`·schema §3)·positive-control/fid 표본 사전등록 | (9차 실측·게이트 활성 후) |
| 3 | 핵심(도구·공유 토대) | **layout-ir 추출·대조**(평가·생성 공유) — 시안 파서(HTML→ir)·렌더 덤프(위젯트리→ir)·대조 리포트 | 양쪽 **동일 스키마** 산출해야 대조 가능. 현 `extract_design`은 토큰만(구조·`<img>` 버림·RCA §3.5) | (도구) `dddart/scripts/extract_design.dart` 확장(시안 layout-ir·`design-tokens.json` 옆 `layout-ir.json`·무의존 파싱) + **평가 도구 신설**(렌더 덤프=`debugDumpApp`류·대조·리포트, `workspace/eval/tools/`) + `layout-ir-schema.md` 준수. 말단(L3)까지 추출·리포트 | 전: 구조 추출 경로 0 → 후: 결정론 ir 산출·시안∥코드 대조 리포트(사용자 눈 재료). dim **(도구)**. ⚠️스키마 §6 4파라미터 positive-control 확정 | ✅스키마 동결본 + **시안 파서 `extract_layout`·대조 `compare_layout`·렌더 덤프 `dump_probe`+`dump_to_ir` 전부 구현·8차 실증**(L1 image/bottomnav 갭 결정론 포착·weekly card/metrics repeat 등가 흡수)·평탄화+실물 positive-control 반증(step 2a·2b·2026-06-19) / **게이트 활성 선결 1: 표준 pump 진입점 규약(코퍼스 승인)**(hero text 흡수는 `_collapse` 보정 완료·run.sh G 반증·8차 hero L2 ✓) | (9차 실측·pump 규약 후 활성) |
| 4 | 권장(코퍼스·미러·양판) | **표준 pump 진입점**(렌더 덤프 전제) — 화면 pump 배선이 산출물마다 상이(claude `_support.dart` vs codex 헬퍼) | coordinator가 산출물 무관하게 렌더 덤프하려면 일관 진입점 필요(없으면 배선 추론) | (코퍼스·미러) `architecture-ui`/`implementation-test` 테스트 규약에 "**구조 덤프용 표준 pump 진입점**"(시그니처·반환) 명문. 양판 미러(`corpus_mirror_sync`). **생성측(2단계)과 공유 토대** | 전: 배선 추론 필요 → 후: 일관 덤프. dim **(규약)**. ⚠️코퍼스 변경·별도 승인·2단계와 공유 | (2단계와 함께) | (9차+) |
| 5 | 보류(명시) | **VLM grader**(의미 레인) — 비도입 | 사용자 눈 중복(A1)·VLM 전문가 15~20%p 미달(WebDevJudge)·비결정·자기보고·비용 ROI·YAGNI | **비도입.** 재투입 트리거 = "**구조 diff PASS인데 사용자 눈에 반복적으로 걸리는 미관 회귀**"가 라이브런서 패턴화되면(코드+스크린샷+시안·pairwise·blind N≥3·생성≠채점·게이트 아닌 신호) | — | — | — |

- **②근거 공통**: 시각 충실도가 A1 인간 비측정이라 **기능 게이트 통과 = 시안 일치 아님**(8차 image/bottomnav 누락이 PASS로 통과). 자료조사: 충실도 레버 = 평가측(회귀 잡기) + 생성측(덜 흔들리게)의 **쌍**. 이번 011은 평가측(쌍의 절반) — 생성측(2단계)이 입력 유도로 닫는다.
- **③미러/단일출처**: RUBRIC·EVAL-METHOD·layout-ir 스키마·평가 도구 = **eval 단일출처**(미러 불필요·measure-first 등록). `extract_design.dart`·표준 pump 진입점(항목 4) = **코퍼스**(양판 미러·별도 승인). 코퍼스 *적용*은 사용자 승인.
- **④정직 표기**: 신설 측정(결함 수정 아님). L1·L2 게이트는 positive-control(등가 거짓-FAIL 반증) 선결. 효과크기 자체 eval 측정 필요. N=1 — 9차 1차 실측·확정엔 ≥2 런.

## measure-first 선결 (eval 단일출처·9차 채점 착수 *전* 등록·소급 금지)
> EVAL-METHOD §0·§5 정합 — 코퍼스 아님(승인 불요)이나 *측정을 바꾸므로* 9차 빌드/채점 전 의도적 등록.
> **시술 진행(2026-06-19): 1·2·3 완료 · 4 명세 등록(검증은 판정원 도구 step 2 후).** FID 게이트는 도구+positive-control 충족 전까지 비활성(리포트·약신호).
1. ✅ **RUBRIC FID-L1·L2 차원 신설**(항목 1·2) — 화면 영역 게이트(L1)·섹션 구성 게이트(L2·평탄화). FID-L3=약신호(리포트·눈)·FID-L4=A1 명시. **집계 위치 확정 = 별도 FID 군(`RUBRIC.md §H`)·치명 20 조건부 활성(현 18→활성 시 20)**(positive-control+도구 선결).
2. ✅ **layout-ir 스키마 동결**(항목 3) — `tools/layout-ir-schema.md` **동결본(SSOT) 신설**(노드 트리·번역표·평탄화). design 문서는 경위로 강등(포인터). §6 4파라미터 잠정값 명시·positive-control로 확정 예정.
3. ✅ **EVAL-METHOD §2.5 보강** — A1 인간 오라클에 "구조 골격·섹션 구성·말단 슬롯(L1·L2·L3)은 FID 결정 레인으로 측정·L4(미관·아이콘 심볼)는 인간 유지" 경계 명시(A1 재정의·축소). §0·§2.3 (A')·§3·§6도 정합.
4. 🔶 **positive-control 선결 등록** — `tools/positive-control/fid/` 등가 재구성 표본(A~D 묶음/래퍼 차이=거짓-FAIL 0 예상·E·F 음성 대조=정탐 FAIL) **명세 사전등록 완료**. fixture Dart·실측 반증은 판정원 도구(step 2) 후 → L2 게이트 거짓-FAIL 0 반증 후 투입.

## 범위 제외 (이번 단계 밖)
- **생성측(2단계)** — architect/coder layout-ir 소비·L1·L2 강제. 코퍼스 변경·별도 회차·별도 승인. `fidelity-generation-design.md`.
- **이미지 번들(3단계)** — `Image.asset` 빌드타임 번들(URL 실측 완료: 다운로드 가능·수명 보장 없음). 코퍼스 변경. 라이선스 별도 검토. [[stitch-image-asset-bundling]].
- **VLM grader** — 보류(항목 5·트리거 명시).
- **스키마 §6 4파라미터**(section fallback·repeat 임계·button 분기·평탄화 깊이) — 구현 시 positive-control로 확정.

## 미해결 (시술·후속)
- **도구 구현** — 시안 파서(extract_design 확장)·렌더 덤프·대조 리포트. 9차 전 시술 + positive-control.
- **positive-control(L2)** — 등가 재구성(묶음/래퍼 차이) 거짓-FAIL 반증이 L2 게이트 투입 선결.
- **표준 pump 진입점(항목 4)** — 코퍼스 변경이라 2단계(생성측)와 함께 승인·미러.
- **효과크기 측정** — 9차에서 L1·L2 게이트 작동·false regression율 실측 → ⑤⑥ 기입·≥2 런으로 확정.
- ✅ **집계 위치**(해소·2026-06-19 시술) — **별도 FID 군(`RUBRIC.md §H`)·치명 게이트 활성 시 18→20 편입** 확정. (시술 중 "치명 17"이 실제 18개인 선재 오계수도 함께 교정.)
