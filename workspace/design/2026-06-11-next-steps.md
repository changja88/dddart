# 다음 작업 (2026-06-12 갱신 #6 — compact 인계)

> **상태: §10-3 진행 중 — 설계안 v3.1 확정, Wave 1 완료(v2), Wave 2 착수 직전.** 살아있는 단일 근거 5개 = 제1 규약 + 본설계 + 백스톱 설계 + **코퍼스 설계안**(`2026-06-12-skill-corpus-plan.md`) + 작업장 규약(`workspace/reference/spec.md`). 이번 세션 커밋 9개(`82f23e2` 골격 → `d8eff8f`·`e9e40a8` ddd·cleancode 원료 반입 → `7de0f7c` spec 교정 → `527745f` 설계안 v3 → `638219b` Wave 1 → `6dcf6c2` Wave 1 v2 → 인계 #6). 미반영 수정 없음.

## 즉시 할 일 — Wave 2: architecture-**state → data → ui**

코퍼스 설계안 §2~§6이 단일 근거(골격·원료·review 여부는 §3 표). Wave 표준 절차(Wave 1에서 확립):

1. **원료 정독** — state: 규약 §3.3 전문·§3.6(root 협력 규칙 포함)·§9-3·§9-11·§8 표 해당 행(refresh_notifier·scroll_to_top·comment_added)·§10-5 ① + 본설계 §8 lens 경계(state vs data 판례: 캐싱·에러) / data: 규약 §3.4·§9-9 + 본설계 §2·§4·§5(§5-2 계약 위험·§5-7)·§9(신규 1 검증=data) + 백스톱 설계 §7(extract_contract.dart) / ui: 규약 §3.5·§3.1·§6 중 design_system(전역 키 static show() 금지 — **ui 소유 확정**, houserules는 위임만)·§9-10·§9-12.
2. **review.md**(state·data만 — ui 생략) → **작업장 final.md** 합성 → **SKILL.md** → **배포 절단·복사**.
3. **검증 게이트 4종**: ⓐ 로드 스모크 `claude --plugin-dir "$PWD/dddart" plugin details dddart` — Wave 2 후 기대 Skills=**4** ⓑ 관통 테스트(주입 누적: houserules+state+data → VM 1개 생성 → 백스톱 gated 0건) ⓒ **4렌즈 AI 리뷰 워크플로**(설계안 §6-2: skill-creator·plugin-dev·소비성 실증·원문 충실도) — 발견 반영 후 재검 1회 ⓓ Wave 완결 시 전방 위임 §번호 백필+grep placeholder 0건.
4. Wave 2 결정 지점 없음(§10-5 ③=Wave 3, ④=Wave 4).

### Wave 1에서 확립된 양식 규칙 (이후 8종 전부 적용)

- **final.md**: 제목 → P1 표(작업장만 — 배포 절단 시 제거) → 서지 blockquote → **출처 해제 1줄**("(규약 §N)·(백스톱 설계 §N)·(본설계 §N)은 출처 표기, 로드 대상 아님 — 로드 가능한 위임은 스킬명+주제와 동봉 파일뿐") → TOC → `## §N.` grep 앵커. 경로 형태 금지(문서 제목 표기), 유일 예외 `${CLAUDE_PLUGIN_ROOT}`.
- **위임**: 후방=스킬명+§번호 / 전방(미작성 스킬)=스킬명+주제. **중복 소유**: houserules=트리·명명·import 사실 단일 출처, lens=절차 — 닫힌 열거(IM13 허용 위치 등)는 **축약 없이 복사하거나 위임만**, 집합 재해석 요약 금지(Wave 1 P1의 교훈).
- **SKILL.md**: name·description(1~2문장 좁은 식별, 화살괄호 금지, 1024자 이하)·`user-invocable: false`(공식 .skill 패키징 금지 전제) → "언제 쓰나"(로드 후 행동 지시) → 핵심 운영 원칙(§인용 불릿) → 라우팅 표. **절 제목은 에이전트가 던질 질문의 어휘로**. keepAlive 경계 문구: state(수명 *결정* 소유)·riverpod(표기법 소유) **양쪽 SKILL.md에**.
- **배포 절단 명령**: `awk 'BEGIN{skip=0} /^## P1 Source Sufficiency/{skip=1; next} skip && /^> \*\*출처:\*\*/{skip=0} !skip{print}' 작업장final > 배포final` + undecidable류는 cp. 미러 불변식은 diff로 검증.
- **백스톱 정합 주의**: 러너 동작을 서술할 땐 구현 실물(`dddart/scripts/src/`)을 직접 확인하고 쓸 것 — Wave 1에서 합성자가 게이트 의미론을 절반만 확인하고 규칙을 발명했다가 fidelity 렌즈에 잡혔다(교정 결과: 표기는 파일·구조는 단위 — NM은 added 파일·폴더 무관, ST는 added 디렉터리).

## 남은 흐름

- **Wave 3**: ddd·cleancode — 원료 완전체 반입 완료(`workspace/reference/<스킬>/reference/`의 internal+external, 머리말에 선별 규칙). ddd=선별 이식("dddart 비채택" 명시 절 — Event Sourcing·Saga·CQRS·UoW 등), cleancode=Python 예제 82개 Dart 치환. **합성 중 §10-5 ③(애그리거트 일관성 경계 규율) 결정 — 사용자 확인 지점.**
- **Wave 4**: implementation dart·flutter·riverpod — 외부 조사(공식 문서) 병렬, 합성은 riverpod 우선. **flutter 작성 중 §10-5 ④(스크롤톱) 결정 — 사용자 확인 지점.**
- 이후: **§10-4 저장소 골격·파일 작성**(커맨드·에이전트 7종 — dddjango 용어 치환 + discipline-reviewer ~15KB 상한·codex 미러 축소표·$ARGUMENTS URL 파싱·build-state.json 스키마·openapi Bash curl. 에이전트 frontmatter `skills:`는 dddjango 자구 유지+주입 수신 스모크. scripts/는 이미 제자리) → **2단계 실측**(안 1 vs 안 2 비교 빌드 — §6 분할 최종 확정).

## 운영 방침 (사용자 지시 — 메모리에도 등재)

- **ultracode 상시 승인**: fan-out 실익 지점(외부 조사·예제 치환·다렌즈 검증·관통 테스트)에서 자율 사용 — 사용 시 고지+토큰 비용 보고. **합성(저작)은 메인 루프**(충실도·용어 일관성이 병목).
- **검수 기준 = AI 소비성**: 사용자 육안 검토 대신 4렌즈 서브에이전트 리뷰("독자는 AI다").

## 문서 지도

| 문서 | 지위 |
|---|---|
| `2026-06-11-dddart-file-tree.md` | **확정** — 제1 규약(헌법). 이번 세션 무개정 |
| `2026-06-12-pipeline-design.md` | **확정** — 본설계. 이번 세션 개정 4곳: §8 귀속 2건(houserules+common·state+컨트롤러 View 소유), §10-3 17종, §5-7·§10-2 `extract_contract.dart` 표기 |
| `2026-06-12-backstop-design.md` | **확정·구현 완료** — 백스톱 단일 근거(`dddart/scripts/`) |
| `2026-06-12-skill-corpus-plan.md` | **확정 v3.1** — §10-3 실행 계획(Wave·골격·양식·검증 게이트). Wave 1 완료 표기 |
| `workspace/reference/spec.md` | 작업장 규약 — internal=사용자 제공 서적 요약(에이전트 생성 금지), 미러 불변식(P1 절 단서) |
| `2026-06-12-file-tree-final-review.md` | 기록 — §6(17종)이 `undecidable.md`로 반영 완료. **삭제 후보(사용자 확인 후)** |
| `2026-06-12-slice-simulation.md` | 기록+준비물(안 2 정의) — 2단계 실측 후 삭제 후보 |

Wave 1 산출물: `dddart/skills/discipline-houserules/`(SKILL.md 6.7KB + references/final.md 30KB + undecidable.md 11KB) ⟷ 작업장 `workspace/reference/discipline-houserules/reference/`(final.md P1 보유판 + undecidable.md). plugin.json 메타 완비(validate 경고 0).
