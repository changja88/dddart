# 다음 작업 (2026-06-12 갱신 #5 — compact 인계)

> **상태: §10-2 백스톱 설계+구현 완료, §10-5 ① 선결정 완료 — §10-3 착수 직전.** 살아있는 단일 근거 = 제1 규약 + 본설계 + 백스톱 설계 3개. git 커밋 6개(`6186dcc`→`2315c97`→`99a1ae5`→`2de406e` 백스톱 설계→`2da9356` 백스톱 구현→`dfdbfaa` §10-5 ①). 미반영 수정 없음.

## 즉시 할 일 (compact 직후) — §10-3 스킬 9종 코퍼스

1. **9종**: architecture-**ddd·ui·state·data** / discipline-**cleancode·houserules** / implementation-**dart·flutter·riverpod**.
2. **절 귀속**(본설계 §8 — 단일 근거): ddd ← 규약 §3.2·§3.3(UseCase·판정 소유·강등)·§9 결정 / ui ← §3.5·§3.1·§6(design_system) / state ← §3.3(VM 3변종·state·shared_state·4채널 상태 측면·**§10-5 ① 에러 2채널·State 계약**)·§3.6 / data ← §3.4(**실패의 단일 출구** 포함)·로컬 2층·계약 스냅샷 사용법 / houserules ← §2·§3.7·§4·§5·§7·§8 / cleancode ← dddjango 이식+§10-5 규율(③ 애그리거트 규율은 작성 시 결정 — 이연분) / implementation 3종 ← 신규(dart=freezed 귀속, flutter=go_router·dio·hive, riverpod=@riverpod 5변종·keepAlive·watch — 위반 다발 스택 단독).
3. **제약 3개**(본설계 §10-3 확정): ⓐ 필독 reference는 **houserules 표준 트리 1개뿐**(coder가 references 전량 읽으면 ~140k+ 토큰 — dddjango 예산 조건의 명시 승계) ⓑ houserules SKILL.md 체크리스트 **≤8KB**(세부는 references로) ⓒ **기계 판별 불가 16종 공유 reference 1파일**(준비물: `2026-06-12-file-tree-final-review.md` §6) — 1차 결정자(architect)와 검증자 양쪽 에이전트가 같은 파일 적재. + keepAlive 경계 문구(수명 *결정*=architecture-state / 표기법=implementation-riverpod)를 양쪽 SKILL.md에.
4. **참고 실물**: dddjango 스킬 `/Users/hyun/Desktop/dddjango/dddjango/skills/` — SKILL.md 2.8~19.7KB·references 25~93KB 실측(이전 세션). 직격 이식 후보: architecture-ddd·discipline-cleancode·discipline-houserules(용어 치환), 신규 6종은 규약 슬라이싱.
5. **착수 절차(직전 합의)**: dddjango 스킬 실물 구조(SKILL.md 양식·references 분할 방식) 확인 → **9종 목차·작성 순서 설계안 제시 → 사용자 확정 → 작성**.

## 남은 흐름

- §10-3(위) → **§10-4 저장소 골격·파일 작성**: dddjango 용어 치환 이식(커맨드·에이전트 7종) + 본설계 추가분 — discipline-reviewer 본문 ~15KB 상한·codex 미러 축소표·`$ARGUMENTS` URL 파싱·build-state.json 스키마·openapi 취득 Bash curl·Coordinator 경계는 §1 "직접 쓰는 것" 목록. **scripts/는 이미 제자리**(`dddart/scripts/` — 백스톱 구현 완료). → **2단계 실측**: 같은 기능을 안 1 vs 안 2(행위 세로+결정적 묶기 — 정의는 슬라이스 시뮬레이션 문서)로 비교 빌드, §6 분할 최종 확정.
- 이연: §10-5 ③(애그리거트 규율 — cleancode 작성 시)·④(스크롤톱 — implementation 작성 시), §10-6 도메인 이벤트(트리거 대기).

## 문서 지도 (compact 후 길잡이)

| 문서 | 지위 |
|---|---|
| `2026-06-11-dddart-file-tree.md` | **확정** — 제1 규약(헌법). 2026-06-12 개정: 적대 리뷰 4곳 + §10-2 확정 3곳 + **§10-5 ① 본문 승격 4곳**(§3.3 State 계약·에러 2채널·컨트롤러 / §3.4 실패의 단일 출구 / §6 전역 키 show 금지 / §10-5 ① 확정 표기) |
| `2026-06-12-pipeline-design.md` | **확정** — 파이프라인 단일 근거(에이전트 구성 §1.1~1.4·스킬 귀속 §8 포함). §6 분할만 실측 후 최종화 |
| `2026-06-12-backstop-design.md` | **확정·구현 완료** — 백스톱 단일 근거(검사 51종·게이트·러너·extract_contract). 구현물 `dddart/scripts/`(analyze 0·픽스처 13/13·HaffHaff 스모크 통과 — §12) |
| `2026-06-12-file-tree-final-review.md` | 기록 — §5(39종)는 백스톱 설계로 **대체됨**. **§6(기계 판별 불가 17종→실질 16종)만 §10-3 공유 reference 준비물** — 반영 후 삭제 후보 |
| `2026-06-12-slice-simulation.md` | 기록+준비물(안 2 정의) — 2단계 실측 후 삭제 후보 |

결정 누적: 메모리 `dddart-simplified-ddd.md` (§10-5 ① 에러·State 계약 불릿까지 최신 — HaffHaff 실측 수치 포함).
