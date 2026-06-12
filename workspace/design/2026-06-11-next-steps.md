# 다음 작업 (2026-06-12 갱신 #4)

> **상태: §10-2 백스톱 설계 확정**(적대 점검 2렌즈 — P0 5건·P1 16건 반영, 사용자 확정 4건 전부 권장대로 — 규약·본설계 1줄 개정 반영 완료). 살아있는 단일 근거 = 제1 규약 + 본설계 + **백스톱 설계** 3개.

## 즉시 할 일

1. **§10-5 ① 선결정**(§10-3 착수 전, 사용자와 결정) — State 에러 필드·일회성 소비 + 백스톱 연동 2건(State 파일 없는 VM 허용 여부 — NM4 / 컨트롤러 소유 계층 — IM12). 제1 규약 §10-5 ①에 등재됨.
2. → **§10-3 스킬 9종 코퍼스** 착수.

> 백스톱은 **구현 완료**(2026-06-12, 사용자 결정 A — 즉시 구현): `dddart/scripts/`(러너+패밀리 4+extract_contract+픽스처 13종). analyze 0·픽스처 13/13·HaffHaff 스모크(전역 1,462건 drift 정합 / gated 클린 트리 0건). 상세는 백스톱 설계 §12.

## 남은 흐름

- §10-3 스킬 9종(architecture ddd·ui·state·data / discipline cleancode·houserules / implementation dart·flutter·riverpod — 필독 reference는 houserules 1개뿐·16종 공유 reference 1파일) → **§10-4 저장소 골격·파일 작성**(dddjango 용어 치환 이식 + 본설계 추가분 — scripts/는 이미 제자리) → **2단계 실측**(같은 기능을 안 1 vs 안 2로 비교 빌드).
- 이연: §10-5 코드 규율(① 위 선결정 ③ 애그리거트 규율 ④ 스크롤톱 — 귀속: cleancode·implementation), §10-6 도메인 이벤트(트리거 대기).

## 문서 지도

| 문서 | 지위 |
|---|---|
| `2026-06-11-dddart-file-tree.md` | **확정** — 제1 규약(헌법). 2026-06-12 개정: 적대 리뷰 4곳 + §10-2 확정 3곳(§2 firebase_options·§3.7 router·§10-5 ① 연동 2건) |
| `2026-06-12-pipeline-design.md` | **확정** — 파이프라인 단일 근거. §6 분할만 실측 후 최종화. §10-2 확정 반영(§4 git init 제안·§10 포인터) |
| `2026-06-12-backstop-design.md` | **확정·구현 완료** — 백스톱 단일 근거(검사 51종·러너·extract_contract). 구현물 = `dddart/scripts/` |
| `2026-06-12-file-tree-final-review.md` | 기록 — **§5(39종)는 백스톱 설계로 대체됨**. §6(기계 판별 불가 17종)만 §10-3 공유 reference 준비물 — 반영 후 삭제 후보 |
| `2026-06-12-slice-simulation.md` | 기록+준비물(안 2 정의) — 실측 후 삭제 후보 |

결정 누적: 메모리 `dddart-simplified-ddd.md` (백스톱 설계 불릿까지 최신).
