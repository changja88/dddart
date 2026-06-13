# workspace/eval — dddart 품질 채점 시스템

`/dddart` 산출물이 ① **플러그인의 규칙(간소화 DDD·MVVM·하우스룰·Dart/Flutter 관용구)을 지키는가** + ② **요청 기능을 올바르게 구현했는가**를 *재현 가능하게* 채점하는 홈. 매 채점이 같은 잣대(`RUBRIC.md`)로 이뤄진다.

> **차용 범위(2026-06-13)**: dddjango `workspace/eval/`에서 **인프라(폴더 골격)와 방식(사전등록·고정 입력 verbatim·결과지 표준 형식·치명 게이트·레인 분리·앵커=예시·자기보고 불신·N=1 인과 금지)만** 가져왔다. dddjango는 서버 전용이라 그 도메인 차원(33차원·django-ninja·ORM)은 한 줄도 안 가져온다 — **dddart의 57 차원은 클라이언트 코퍼스 9종 전수 조사 + 적대 검증으로 새로 도출**했다. [[dddart-project-context]]

## 구조

```
eval/
├── README.md                # 이 인덱스
├── rubric/                  # 채점 기준 (정본 — 단일 출처)
│   ├── RUBRIC.md             # 채점 *항목* (무엇을): 57 차원 — S-DDD·S-VIEW·S-STATE·S-DATA·S-HR·BUILD·FC·TIER-Q
│   ├── EVAL-METHOD.md        # 채점 *방법* (어떻게): 빌드·blind 역할·결정∥의미 레인·항목별 결정-판정 표(백스톱 매핑)·치명 게이트·집계 (v3.1)
│   └── rubric-metrix.md      # 채점 결과지 템플릿 (치명 게이트 + 차원 판정 + 등급 + 발견 로그)
├── tools/                   # 고정 입력 (채점 입력 정본)
│   └── SCENARIO-S1.md        # S1 신규 BC 공지 — task verbatim·baseline·게이트 답·FC 골든 입력
└── results/                 # 결과지 (<YYYYMMDD-HHMM>-<scenario>-<variant>.md) — 채점 시 생성
```

> `results/`는 채점 시 생성한다(빈 폴더 git 미추적). 파일명 = `<YYYYMMDD-HHMM>-<scenario>-<variant>.md`(예: `20260613-1400-s1-plan-a.md`).

## 채점 차원 (RUBRIC.md 요약)

| 축 | 이름 | 항목 | 치명 |
|---|---|---|---|
| **S-DDD** | 도메인 충실도 | SD-1~9 | SD-1·2·7 |
| **S-VIEW** | 뷰 계층·표현 분리 | VW-1~7 | VW-1·6 |
| **S-STATE** | 상태·뷰모델 | ST-1~9 | ST-1·2·4 |
| **S-DATA** | 데이터·계약 | DT-1~9 | DT-1·2 |
| **S-HR** | 하우스룰·구조 | HR-1~9 | HR-1·4·5 |
| **BUILD** | 빌드 게이트(dddart 고유) | BG-1~2 | 둘 다 |
| **FC** | 기능 정확성 | FC-1~3 | 셋 다 |
| **TIER-Q** | 품질·관용구(카운트) | Q-1~9 | — |

치명 게이트 17개 — 하나라도 FAIL이면 픽스처 전체 FAIL. **빌드 게이트**(컴파일·analyze green)는 dddart가 산출물 테스트가 얕고 codegen 의존이라 신설한 1차 정확성 기질.

## 관리 규약 (채점 시)

1. **채점 기준은 `rubric/`이 단일 출처.** `RUBRIC.md`(항목)로 보고 `EVAL-METHOD.md`(방법)로 채점·집계. 기준 변경은 *채점 착수 전*에만(EVAL-METHOD §0·§5 사전등록 — 미동결 채점 = 과적합 위반).
2. **고정 입력은 `tools/SCENARIO-S1.md` verbatim.** task·baseline·게이트 답·FC 골든을 토씨까지 동일 투입.
3. **레인 분리·Goodhart 차단**: 결정(grep/스크립트/백스톱)과 의미(grader)를 분리하되, **의미 레인 FAIL이면 결정 스크립트 통과여도 FAIL**(치명은 치명 FAIL).
4. **정직 경계**: 앵커=예시(임계값 아님·순환 방지), N=1 인과 단정 금지, 거짓 FAIL 함정(정적 view·codegen 면제·수치 가이드 등) 회피.
5. **결과지 형식**은 `rubric-metrix.md` 표준 템플릿.

## 슬라이스 두 안 비교 (RUBRIC 적용의 한 사례)

본설계 §6 슬라이스 분할(안 1 Model/View 2분할 vs 안 2 행위 세로)은 **같은 `RUBRIC.md`를 두 산출물에 적용**하고 + *과정 지표*(coder 호출·토큰·반송·재방문 차분)를 더해 확정한다(`EVAL-METHOD.md §4`·`rubric-metrix.md` 부록). `/dddart` 첫 실전 구동을 겸한다. 배경 = `workspace/design/2026-06-12-slice-simulation.md`.

## 출처

57 차원 = 코퍼스 9종 전수 조사(워크플로우 `wyzdio23w` · 18에이전트 2렌즈 · A후보 333+B갭 109) → 6 구조축 적대 검증(`wf_81f22781-657` · 53항목·drop 0·근거 슬립 3 교정) → 메인 루프 합성·작성. **EVAL-METHOD 집행 레이어(v3.1) = 백스톱 러너 4종 실독 매핑 + dddjango EVAL-METHOD 301줄 이식 → 7렌즈 적대 리뷰(`wf_85acf811-ee5` · 32건 전수 교정·거짓양성 0)**. 착수 가이드 = `workspace/design/2026-06-11-next-steps.md`.
