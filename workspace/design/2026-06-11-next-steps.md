# 다음 작업 (2026-06-12 갱신 #3 — compact 인계)

> **상태: §10-1 파이프라인 본설계 확정**(적대 리뷰 5렌즈 통과 — blocker 11·사용자 결정 4건 전부 반영). 문서 통합 완료 — **살아있는 단일 근거 = 제1 규약 + 본설계 2개뿐**. git 커밋 3개(`6186dcc` 스냅샷 → `2315c97` 통합 → 확정 커밋). 미반영 수정 없음.

## 즉시 할 일 (compact 직후) — §10-2 백스톱 스크립트 설계

1. **준비물**: `2026-06-12-file-tree-final-review.md` §5 불변식 39종(구조 11·import 12·명명 16) + 본설계 §10 추가 4건(① service/에서 navigator import·`.go(` 금지 ② view_model·shared_state·use_case에서 design_system import 금지 ③ application_layer에서 BuildContext·material import 금지 ④ repository 추상 클래스 금지).
2. **요구사항(본설계 §10 확정)**: touched-gate 기본 + **예외 절**(순환 래칫=전역 검사+베이스라인(`.dddart/` 루트 저장) / 골격 완비=신규 생성 BC 한정 / 구조·명명=added 파일 기준) · **러너 스크립트 1개**(전체 실행·집계 — 커맨드 인라인 금지, dddjango식 인라인이면 카탈로그만 ~28KB) · **`extract-contract.py`**(openapi paths 선별+`$ref` 전이 폐쇄 추출)도 §10-2 산출물 · 종료코드 2=blocker(발견 합쳐 일괄 반송).
3. **참고 실물**: dddjango 스크립트 16종 `/Users/hyun/Desktop/dddjango/dddjango/scripts/` — touched-gate(`git status --porcelain`)·exit code·고정밀 저-recall 철학의 원형.
4. **산출**: 백스톱 설계 문서(검사 목록·각 사양·예외) → 사용자 확정 → 구현 시점(즉시 vs §10-4와 함께)은 사용자와 결정.

## 남은 흐름

- §10-2(위) → **§10-3 스킬 9종 코퍼스**(architecture ddd·ui·state·data / discipline cleancode·houserules / implementation dart·flutter·riverpod — 필독 reference는 houserules 1개뿐·16종 공유 reference 1파일·**§10-5 ①(State 에러 필드·일회성 소비) 선결정 필요**) → **§10-4 저장소 골격·파일 작성**(dddjango 용어 치환 이식 + 본설계 추가분: discipline 본문 ~15KB 상한·codex 축소표·build-state.json 스키마·$ARGUMENTS URL 파싱·openapi 취득 도구) → **2단계 실측**(같은 기능을 안 1 vs 안 2(행위 세로+결정적 묶기 — 정의는 슬라이스 시뮬레이션 문서)로 비교 빌드).
- 이연: §10-5 코드 규율(① 에러 계약은 §10-3 전 선결정 ③ 애그리거트 규율 ④ 스크롤톱 — 귀속: cleancode·implementation), §10-6 도메인 이벤트(트리거 대기).

## 문서 지도 (compact 후 길잡이)

| 문서 | 지위 |
|---|---|
| `2026-06-11-dddart-file-tree.md` | **확정** — 제1 규약(헌법). 2026-06-12 적대 리뷰 개정 4곳 포함(§3.3 판정 소유 양성 규칙·§3.7 단서 2건·§10-5 귀속) |
| `2026-06-12-pipeline-design.md` | **확정** — 파이프라인 단일 근거(에이전트 구성 §1.1~1.4 포함). §6 분할만 실측 후 최종화 |
| `2026-06-12-file-tree-final-review.md` | 기록+준비물(39종·17종) — §10-2·3 반영 후 삭제 후보 |
| `2026-06-12-slice-simulation.md` | 기록+준비물(안 2 정의) — 실측 후 삭제 후보 |
| (삭제됨 — git `6186dcc`) | 에이전트 구성 문서(본설계 흡수)·적대 리뷰 리포트(처리 완료) |

결정 누적: 메모리 `dddart-simplified-ddd.md` (파이프라인 본설계 불릿에 적대 리뷰 반영분까지 최신).
