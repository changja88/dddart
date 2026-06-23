# fix 021 — Q-6 빈 runZonedGuarded 핸들러 길목 연결 (잠복갭 신규검출)

> 사전등록형. 예상효과를 *고치기 전* 박고 17차 결과지로 실측 대조(EVAL §자기보고 불신).

## 메타
- **회차**: 021
- **트리거**: `results/20260623-1331-weather-{claude,codex}.md`(Q-6 양판 `runZonedGuarded(...,(e,s){})` 빈 핸들러·g3 적발) + 본세션 4렌즈 적대 검증(Q-6 ROC **HOLDS**)
- **베이스 코퍼스**: `1fc7946`
- **시술 커밋**: (미커밋·사용자 지시 대기)
- **검증 런**: 17차
- **상태**: **시술완료**(3렌즈 리뷰 통과·17차 검증대기·미커밋)

## RCA 요약 (본세션 4렌즈 적대 검증 — general-purpose 병렬)
- **증상**: 16차 양판 main.dart에 `runZonedGuarded(..., (Object e, StackTrace s) {})` 빈 에러 핸들러(claude `:30`·codex `:20`). 16차 처음 🟡(g3 적대 grader가 처음 main.dart 부트스트랩 정독).
- **회귀 아니라 잠복갭 신규검출**: runZonedGuarded 의무는 Wave1 커밋 `638219b`부터 불변(`houserules/references/final.md:235`·`undecidable.md:94`). 15차→16차 코퍼스 델타(fix018/020)에 main.dart/runZonedGuarded 변경 0건. `runZonedGuarded`는 **16차 이전 결과지에 0건 등장**(15런 Q-6 ✅는 전부 safeApiCall만 평가) → grader 정독 깊이만 16차에 바뀜(검출 아티팩트).
- **뿌리 = 처방 지식이 강제 길목에 미연결**: 코퍼스는 이미 빈 runZonedGuarded 핸들러를 스멜로 명명하고 처방까지 적어둠(`final.md:292` 반송표 "빈 `runZonedGuarded` 핸들러 등 → `root/handler/root_error_handler.dart`"·`:39` 트리 주석). 그러나 — (a) 생성 스펙(`:235`)·coder 1차 판정 절차(`undecidable §11:94`)에 **onError 위임 요구 미동거**, (b) reviewer(`:76`)는 main.dart 최소형을 *로직 유입(비즈니스 분기·상태 보유)*만 감사·**빈 핸들러 미감사**, (c) root_error_handler **동작 규율 부재**(`:39` 주석 한 줄뿐), (d) 백스톱(58종·md/im/nm/tg/cy/pj/rv) main.dart **미검사**. = [[feedback-018]] "지식만 있고 강제 길목엔 없음" 동형.
- **적대 검증 교정**:
  - 렌즈 A: 1차 "최소형 압력이 빈 바디를 *유도*"는 과장(위임 한 줄 `(e,s)=>rootErrorHandler.report(e,s)`도 합법) → **"코퍼스가 빈 핸들러를 *막지 못함*"**(부정 규율·게이트 부재)이 정확.
  - 렌즈 D: **진짜 결함**(RUBRIC Q-6 "빈 catch 0·침묵 삼킴" 정면 위반·무주석·면제[safeApiCall·의도 폴백] 비해당). "논쟁적"은 심각도 논쟁이지 결함성 부정 아님.
  - 렌즈 C: **처방 가치 高·회귀 안전** — read-only 감사 + houserules 산문은 extract/layout/asset 기계(레이아웃·에셋 16차 완벽)와 격리. main.dart 부트스트랩 어휘는 그 기계를 0건 참조.
  - **Q-6≠Q-7 별도 처방**(렌즈 C): Q-6은 "이미 있는 지식을 길목 동거"(read-only·회귀 0)·Q-7은 "소멸 데이터 복원"(extract_design 손댐·회귀 민감) — 묶으면 무해한 Q-6이 Q-7 검증 부담을 떠안음.

## 교정 항목 (사전등록 — ①~② 고치기 전 / ③~④ 17차 후)

| # | 우선 | ① 대상 결함 | ② 원인(뿌리·길목 공백) | ③ 처방(파일·미러) | ④ **예상효과**(전→후) | ⑤ 시술커밋 | ⑥ 실측 |
|---|---|---|---|---|---|---|---|
| 1 | ★위생 | Q-6 main.dart 빈 `runZonedGuarded` onError(침묵 삼킴) | 생성 스펙(`final.md:235`)·coder 절차(`undecidable §11`)에 onError 위임 미동거 | houserules `final.md §5(:235)` — `runZonedGuarded` 뒤에 "onError는 `root_error_handler`로 위임·빈 `(e,s){}` 바디로 침묵 삼키지 않는다·root_error_handler도 침묵 삼킴 금지(최소 관찰가능·외부 리포트 SDK는 앱 소관)" + `undecidable.md §11(:94)` 위반 신호에 "빈 `runZonedGuarded` onError(`root_error_handler` 미위임·침묵 삼킴)" 추가. **미러**: final.md auto(`--write`)·undecidable.md 수동 양판 | 17차 양판 main.dart onError가 `root_error_handler` 위임(빈 `(e,s){}` 0)·Q-6 🟡→✅ | | |
| 2 | 강제 | reviewer 빈 핸들러 미감사(강제력 길목 공백) | reviewer `:76`이 main.dart 최소형을 *로직 유입*만 감사 | `discipline-reviewer.md` main.dart 최소형 감사(`:76`)에 "전역 에러 핸들러(`runZonedGuarded` onError·`FlutterError.onError`)가 빈 바디로 침묵 삼킴(`root_error_handler` 미위임)=important — 빈 catch 위생(Q-6)의 부트스트랩 변종" 추가. **미러**: 수동 양판(claude `agents/` ∥ codex `dddart-discipline-reviewer/SKILL.md`·감사 본문 IDENTICAL) | 빈 핸들러 재발 시 reviewer 감사 발화(생성 길목+감사 길목 동급화·feedback-018 ★교훈) | | |

- **백스톱 결정적 게이트(빈 `runZonedGuarded` grep)**: **measure-first 보류** — 빈 바디 형태 다양(오탐 위험)·feedback-018 선례. coder(undecidable §11)+reviewer로 먼저 닫고 17차 실측 후 필요 시 승격.

## 비-과적합 가드 (plugin-general-purpose)
- 규율 진술은 **"전역 에러 핸들러는 침묵 삼키지 마라(root_error_handler 위임)"**로 범용 — weather/특정 SDK 무관. `runZonedGuarded`·`root_error_handler`는 dddart 표준 구조(이미 코퍼스 `:235`·`:292`·트리 `:39`). **"외부 크래시리포트 SDK 연결은 앱 소관"** 명시로 특정 리포터(Crashlytics/Sentry) 강제 회피. root_error_handler 내부 구현 형태는 미규정(위임+비-침묵까지만).

## 강제력 길목 (feedback-018 ★교훈)
- **생성 길목**(`undecidable §11`·coder 1차 판정자) + **감사 길목**(reviewer 종심 검증) 둘 다 닫음 — 지식(houserules §5)만 고치고 길목 안 고치는 동형 함정 회피. main.dart "최소형" 1차 판정자가 coder(`coder.md:46`)이고 종심 검증자가 reviewer(`discipline-reviewer.md:86`)임을 실측 확인.

## 미러
- houserules **final.md §5**: `corpus_mirror_sync.py --write`(소스←배포·codex←배포·스코프=final.md 9종).
- houserules **undecidable.md §11**: 수동 양판(dddart `skills/.../undecidable.md` ∥ codex `skills/.../undecidable.md`·현재 byte IDENTICAL·스코프 밖).
- **discipline-reviewer**: 수동 양판(claude `agents/discipline-reviewer.md` ∥ codex `skills/dddart-discipline-reviewer/SKILL.md`·감사 본문 IDENTICAL·frontmatter/경로만 상이).

## 측정 (★자동 가능 — Q-7과 대비)
- Q-6은 **양판 일관·표적 명확·측정 가능**(빈 `runZonedGuarded` grep). 17차 실측 = 산출물 main.dart에서 onError 위임 확인(`grep runZonedGuarded`·빈 `(e,s){}` 부재) + reviewer 감사 발화 여부.
- ⚠️ 검출 아티팩트였으므로(grader 정독 깊이가 16차에 처음 main.dart 도달) 17차 grader가 main.dart 부트스트랩을 **계속 정독**하도록 결과지 g3 루틴 유지 — 안 그러면 "고쳤는지" 자체가 안 보임.

## 시술 후 리뷰 게이트 (3렌즈 — 2026-06-23·general-purpose 병렬)
**전 렌즈 통과**:
- **소비성 PASS**(경미 CONCERN 비차단): coder→②(`undecidable §11`·`coder.md:46` 명시 로드·강함)·reviewer→③(종심 감사·강함) 로드 경로 성립. CONCERN("최소 관찰가능" 해석 폭)은 하한(빈 바디 금지)이 기계적 명확·재발 차단 충분으로 비차단(logger 구체형은 dddart 비결정 허용·과규정 회피가 옳음). `root_error_handler` 명칭 전역 1철자·"§7 반송표"→`:292` 해소 정확.
- **정합·회귀 SAFE+COHERENT**: 레이아웃/에셋 기계(extract_design·extract_layout·fetch_images·triage·§8·§9)와 **0 교차**(신규 어휘 5줄 전부 houserules+reviewer 도메인). 모순 4질문 무혐의 — architecture-state §4 에러2채널 *보완*(전역 zone=2채널 누수 최후망)·RUBRIC Q-6 정확 확장·최소형 충돌 없음(위임 1줄=배선≠로직)·Dio 인터셉터 `onError` 어휘 분리. 양판 IDENTICAL.
- **실효성 EFFECTIVE·과적합 무혐의**: ★**`:292` 췌언 정체 규명** — §7 서문이 enforcement를 백스톱에 위임하나 백스톱(58종·ST/IM/NM/CY/TG/PJ/RV) main.dart 본문 미검사 → `:292`는 "존재하지 않는 게이트"를 가리킨 死문구였음. ②③이 main.dart에 *실제 도는* 생성(coder)·감사(reviewer) 길목으로 강제력 이동([[feedback-018]] 동형 함정 회피). 길목 동급화 닫힘(양판 byte). 과적합 0(범용·SDK 앱소관·기존 구조).
- **잔존 리스크(정직)**: 백스톱 보류로 EFFECTIVE가 확률적 — reviewer LLM 감사 비결정 + 16차 검출 자체가 grader 정독 아티팩트. → 17차 grader가 main.dart 부트스트랩 **계속 정독**해야 "고쳤는지" 보임(측정 섹션 명시).

## 회차 요약 (17차 후)
- (비움 — 17차 실측 후 기입)
