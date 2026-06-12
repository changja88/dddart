# 다음 작업 (2026-06-12 갱신 #7 — Wave 2 완료)

> **상태: §10-3 진행 중 — Wave 1·2 완료(스킬 4/9 배포), Wave 3 착수 직전.** 살아있는 단일 근거 5개 = 제1 규약 + 본설계 + 백스톱 설계 + **코퍼스 설계안 v3.2**(`2026-06-12-skill-corpus-plan.md`) + 작업장 규약(`workspace/reference/spec.md`). 미반영 수정 없음.

## 즉시 할 일 — Wave 3: architecture-**ddd** · discipline-**cleancode** (이식)

코퍼스 설계안 §2~§6이 단일 근거. Wave 표준 절차(원료 정독 → review.md → 작업장 final.md → SKILL.md → 배포 절단·복사 → 게이트 4종)는 Wave 1·2와 동일하며, Wave 3 특수성:

1. **원료** — 반입 완료본: `workspace/reference/architecture-ddd/reference/`의 internal.md(41.4KB — 사용자 서적 요약)+external.md(90.7KB — dddjango 소스판 final, 머리말에 선별 규칙: Event Sourcing·Saga·CQRS·UoW 등 full-DDD는 "dddart 비채택" 명시) / `discipline-cleancode/reference/`의 internal.md(33.5KB)+external.md(89.4KB — Django 4줄·Python 펜스 82개만 치환 대상). + 규약 ddd: §3.2·§3.3 중 UseCase·판정 소유·강등·§9 결정 / cleancode: §10-5 코드 규율.
2. **ddd**: dddjango 절 구조 승계하되 선별 — "dddart 비채택" 명시 절 포함(없는 척 금지 — 에이전트가 full-DDD 관행을 들고 올 때 막는 음성 지식). review.md = 선별 기록. **합성 중 §10-5 ③(애그리거트 일관성 경계의 코드 규율 — 루트 경유 변경 원칙 등 freezed 불변+직파싱 하 최소 규칙, VM 판정 강등 상세) 결정 — 사용자 확인 지점.**
3. **cleancode**: dddjango §1~§17 승계 + Python 예제 82개 Dart 치환(fan-out 실익 — ultracode 후보) + §10-5 규율(반복>상속) 추가. review.md = 치환 기록.
4. **검증 게이트**: ⓐ 로드 스모크 기대 Skills=**6** ⓑ 관통(주입 누적 — houserules+state+data+**ddd·cleancode**로 판정 소유 과제: 도메인 판정 1개가 VM이 아닌 domain에 생기는지) ⓒ 4렌즈+재검 1회 ⓓ Wave 1·2가 남긴 ddd·cleancode 전방 위임 백필(grep "architecture-ddd\|discipline-cleancode").

### Wave 1·2에서 확립된 양식 규칙 (이후 5종 전부 적용)

- **final.md**: 제목 → P1 표(작업장만) → 서지 blockquote → 출처 해제 1줄("(규약 §N)…은 출처 표기, 로드 대상 아님") → TOC → `## §N.` grep 앵커. 경로 형태 금지(유일 예외 `${CLAUDE_PLUGIN_ROOT}`).
- **위임**: 후방=스킬명+§번호 / 전방(미작성)=스킬명+주제(Wave 완결 시 백필). **공유 reference(undecidable.md)는 각 final 첫 언급에 전체 경로 1회 + 이후 단축**(W2 확립). 중복 소유: houserules=사실 단일 출처·lens=절차 — 닫힌 열거는 축약 없이 복사 또는 위임만.
- **SKILL.md**: description 1~2문장 좁은 식별(화살괄호 금지·1024자)·`user-invocable: false` → "언제 쓰나"(로드 후 행동 지시+경계 위임) → "핵심 운영 원칙"(§인용 불릿 8~10) → 라우팅 표(**질문 어휘 행 + §위치 — 나열 순서까지 § 오름차순과 위치 대응시킬 것**, W2 P3 교훈). keepAlive 경계 문구는 state(완료)·riverpod(W4에서) 양쪽.
- **배포 절단**: `awk 'BEGIN{skip=0} /^## P1 Source Sufficiency/{skip=1; next} skip && /^> \*\*출처:\*\*/{skip=0} !skip{print}' 작업장final > 배포final` + diff 미러 검증.
- **충실도 주의 2건**: ① 러너 동작 서술은 구현 실물(`dddart/scripts/src/`) 직접 확인(W1 교훈 — CY는 BC 간 SCC·파일 단위 아님이 W2에서 재확인됨) ② **HaffHaff 실물 추종은 규약이 그 실물을 고장으로 진단한 지점에서 면책 근거가 아니다**(W2 isShow P1 판례 — 실물 isShow:false 추종이 규약 *왜*의 고장 재성문화였음. 규약 *왜*까지 읽고 함의를 따를 것).
- **관통 테스트 방식**(W2 확립): /tmp 픽스처 git init → 스킬 주입 에이전트가 슬라이스 생성(Model→View 2슬라이스 — 중간 상태는 NM4 삼총사 발화가 정상) → `dart run dddart/scripts/backstop.dart <픽스처> --diff-base <초기커밋>` 0건. coder의 "스킬 공백·모순 보고"가 부산물 발견 채널(W2에서 navigator context 수단·합법 import 사슬 2건 발굴 → ui §6 보강).

## 남은 흐름

- **Wave 4**: implementation dart·flutter·riverpod — 외부 조사(공식 문서) 병렬(ultracode 후보), 합성은 riverpod 우선. **flutter 작성 중 §10-5 ④(스크롤톱 — 미결) 결정 — 사용자 확인 지점.** keepAlive 경계 문구를 riverpod SKILL.md에. 로드 스모크 기대 Skills=9.
- 이후: **§10-4 저장소 골격·파일 작성**(커맨드·에이전트 7종 — 에이전트 frontmatter `skills:`는 dddjango 자구 유지+주입 수신 스모크, discipline-reviewer ~15KB 상한, 17종 공유 reference 경로 주입) → **2단계 실측**(안 1 vs 안 2 비교 빌드 — §6 분할 최종 확정).
- 보류: 파이널 리뷰 문서 삭제(사용자 확인 후), codex-dddart 미러·corpus_mirror_sync 포팅(§10-4 이후 — 절단 의미론 반영 필수).

## 운영 방침 (사용자 지시 — 메모리에도 등재)

- **ultracode 상시 승인**: fan-out 실익 지점에서 자율 사용 — 사용 시 고지+토큰 비용 보고. **합성(저작)은 메인 루프.**
- **검수 기준 = AI 소비성**: 4렌즈 서브에이전트 리뷰("독자는 AI다") + Wave별 관통 테스트.

## 문서 지도

| 문서 | 지위 |
|---|---|
| `2026-06-11-dddart-file-tree.md` | **확정** — 제1 규약(헌법) |
| `2026-06-12-pipeline-design.md` | **확정** — 본설계 |
| `2026-06-12-backstop-design.md` | **확정·구현 완료** — 백스톱 단일 근거(`dddart/scripts/`) |
| `2026-06-12-skill-corpus-plan.md` | **확정 v3.2** — §10-3 실행 계획. Wave 1·2 완료 표기 |
| `workspace/reference/spec.md` | 작업장 규약 — internal=사용자 제공 서적 요약, 미러 불변식(P1 절 단서) |
| `2026-06-12-file-tree-final-review.md` | 기록 — **삭제 후보(사용자 확인 후)** |
| `2026-06-12-slice-simulation.md` | 기록+준비물(안 2 정의) — 2단계 실측 후 삭제 후보 |

배포 현황(스킬 4/9): discipline-houserules(SKILL 6.7KB+final 30KB+undecidable 11KB) / architecture-state(SKILL 4.0KB+final 18KB) / architecture-data(SKILL 3.7KB+final 13KB) / architecture-ui(SKILL 3.4KB+final 10KB). 전부 ⟷ 작업장 P1 보유판 미러 OK·plugin validate 통과·로드 스모크 Skills (4).
