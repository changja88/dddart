# 다음 작업 (2026-06-12 갱신 #8 — Wave 3 완료)

> **상태: §10-3 진행 중 — Wave 1·2·3 완료(스킬 6/9 배포), Wave 4 착수 직전.** 살아있는 단일 근거 5개 = 제1 규약 + 본설계 + 백스톱 설계 + **코퍼스 설계안 v3.3**(`2026-06-12-skill-corpus-plan.md`) + 작업장 규약(`workspace/reference/spec.md`). 미반영 수정 없음.

## 즉시 할 일 — Wave 4: implementation-**dart · flutter · riverpod** (외부 조사)

Wave 표준 절차(원료 → review.md → 작업장 final → SKILL.md → 배포 절단 → 게이트 4종)는 동일. Wave 4 특수성:

1. **외부 조사 3종 병렬**(ultracode fan-out 후보 — 공식 문서 기준): dart=Effective Dart·타입/널 안전·freezed 표기법(state §3·§4 예제와 정합 필수) / flutter=프레임워크 코어·go_router·dio/retrofit(@RestApi)·hive 표기법(data §2·§4·§5·ui §6과 정합) / riverpod=@riverpod 5변종 화이트리스트·keepAlive 표기법·watch/listen 규율(state 전체와 정합). **합성은 riverpod 우선**(가장 위반이 잦은 스택 — 본설계 §8). review.md = 조사 신뢰도 검증 기록.
2. **flutter 작성 중 §10-5 ④(탭 재탭 스크롤톱 — root_view의 PrimaryScrollController 처리 상세) 결정 — 사용자 확인 지점.** state final §8이 "미결" 표기로 위임해 둠 — 확정 후 그 표기도 갱신.
3. **keepAlive 경계 문구를 riverpod SKILL.md에**(state SKILL.md엔 이미 있음 — 양쪽 의무, 코퍼스 설계안 §4).
4. **검증 게이트**: ⓐ 로드 스모크 기대 Skills=**9** ⓑ 관통(표기법 과제 — 주입 누적으로 freezed·@riverpod·retrofit 표기가 정확한 코드 생성, `dart analyze` green까지) ⓒ 4렌즈+재검(충실도 렌즈는 공식 문서 대조 — 조사 출처 신뢰도 포함) ⓓ Wave 1~3이 남긴 implementation 전방 위임 백필(grep "implementation-dart\|implementation-flutter\|implementation-riverpod") + state §8 "미결" 갱신 + **placeholder 전수 0건(코퍼스 완결)**.

### 확립된 양식 규칙 (불변 — Wave 1~3 누적)

- **final.md**: 제목 → P1 표(작업장만) → 서지 → 출처 해제 1줄 → TOC → `## §N.` 앵커. 경로 금지(유일 예외 `${CLAUDE_PLUGIN_ROOT}`). 공유 reference는 첫 언급 전체 경로 1회+이후 단축. 스킬명은 풀네임(약칭 "houserules §5" 금지 — W3 P3).
- **위임**: 후방=스킬명+§번호 / 전방=스킬명+주제(Wave 완결 시 백필). 닫힌 열거는 복사 또는 위임만.
- **SKILL.md**: description 좁은 식별(**화살괄호 절대 금지 — W3 P1 재발**)·user-invocable: false → 언제 쓰나(경계 위임) → 핵심 원칙(§인용 — **인용 §에 그 내용이 실재하는지 공증할 것**, W3 P2 2건이 전부 이것) → 라우팅 표(실질 규칙 절 전부 등재·위치 대응 순서·소절 grep 어포던스 고지).
- **배포 절단**: awk 명령(P1 절 제거) + diff 미러 검증. undecidable류는 cp.
- **충실도 3계명**: ① 러너·구현 서술은 실물 확인 ② HaffHaff 실물 추종은 규약이 고장으로 진단한 지점에서 면책 아님(isShow 판례) ③ **예제 주석에 처분 정책을 발명하지 않는다**(W3 P1 — 원료에 없는 규칙은 주석으로도 금지, 공백은 review.md에 기록하고 보고).
- **이식형 추가 규칙**(W3 확립): 원전과 dddart 확정 결정이 충돌하는 절은 본문 보존 + **"dddart 단서" blockquote**(§9.5 DIP·§14.6·§16 방식). 비채택은 음성 지식 절(ddd §10)에 *왜*+대체 경로와 함께 닫힌 열거.
- **관통 테스트**: /tmp 픽스처 git init → 스킬 주입 에이전트 → 백스톱 `--diff-base` 0건. coder의 "스킬 공백 보고"가 부산물 발견 채널.

## 남은 흐름

- **Wave 4 완료 시 §10-3 종결** → **§10-4 저장소 골격·파일 작성**(커맨드 1+에이전트 7종 — `skills:` 필드 dddjango 자구+주입 수신 스모크, discipline-reviewer ~15KB 상한, 17종 공유 reference(undecidable.md) 경로 주입 — §9 배정표의 1차 결정자·검증자 전 에이전트, codex 미러 축소표, $ARGUMENTS URL 파싱, build-state.json 스키마, openapi Bash curl) → **2단계 실측**(안 1 vs 안 2 비교 빌드 — §6 분할 최종 확정) → codex-dddart 미러·corpus_mirror_sync 포팅(절단 의미론 반영).
- **미규정 1건 기록**(W3 fidelity 발견 — ddd review.md E-5): 도메인 예외(전이 위반)의 최종 처분 경로(누가 잡아 사용자에게 어떻게 보이나). 사전 판정(canX) 소비로 UI가 진입 차단하는 것이 자연 경로이나 명문 규칙 없음 — 실전 발생 시 결정.
- 보류: 파이널 리뷰 문서 삭제(사용자 확인 후).

## 운영 방침 (사용자 지시 — 메모리 등재)

- **ultracode 상시 승인**: fan-out 실익 지점 자율 사용 — 고지+토큰 비용 보고. **합성은 메인 루프.**
- **검수 기준 = AI 소비성**: 4렌즈(이식형은 5렌즈 — 충실도 분리) 리뷰 + 재검 1회 + Wave별 관통 테스트.

## 문서 지도

| 문서 | 지위 |
|---|---|
| `2026-06-11-dddart-file-tree.md` | **확정** — 제1 규약(헌법) |
| `2026-06-12-pipeline-design.md` | **확정** — 본설계 |
| `2026-06-12-backstop-design.md` | **확정·구현 완료** — 백스톱 단일 근거 |
| `2026-06-12-skill-corpus-plan.md` | **확정 v3.3** — Wave 1·2·3 완료 표기 |
| `workspace/reference/spec.md` | 작업장 규약 |
| `2026-06-12-file-tree-final-review.md` | 기록 — **삭제 후보(사용자 확인 후)** |
| `2026-06-12-slice-simulation.md` | 기록+준비물 — 2단계 실측 후 삭제 후보 |

배포 현황(스킬 6/9): discipline-houserules(6.7KB+30KB+11KB) / architecture-state(4.0KB+18KB) / architecture-data(3.7KB+13KB) / architecture-ui(3.4KB+10KB) / **architecture-ddd(3.9KB+22KB)** / **discipline-cleancode(3.6KB+92KB — 80펜스 Dart·§18 신설·체크리스트)**. 전부 미러 OK·validate 통과·로드 스모크 Skills (6). §10-5는 ①②③ 확정·④만 미결(W4).
