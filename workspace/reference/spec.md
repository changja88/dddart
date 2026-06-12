# 코퍼스 작업장 규약

dddart 스킬 9종의 코퍼스 원료·작업본은 여기서 관리한다. 배포본은 `dddart/skills/<스킬>/`(SKILL.md + references/)이다. 구조는 dddjango `workspace/reference/`를 승계했다.

## 구조 (스킬 9종 공통)

```
workspace/reference/<스킬>/reference/
├── external.md   # 외부 원료 — dddjango 이식분, 일반 지식
├── internal.md   # 내부 원료 — 제1 규약 슬라이스, HaffHaff 실측
├── review.md     # 적대 점검 기록
└── final.md      # 합성 최종본 — 배포본 references/final.md와 본문 동일 유지
```

네 파일이 전부 필수는 아니다. 직격 이식 스킬(ddd·cleancode·houserules)은 final.md만으로 시작할 수 있다(dddjango도 동일).

## 미러 불변식 (dddjango corpus_mirror_sync 승계)

1. 소스 `final.md` 본문 ≡ 배포 `dddart/skills/<스킬>/references/final.md` 본문
2. 배포(claude) ≡ 배포(codex) — `codex-dddart/`는 배포본이 생긴 뒤 동기화 도구로 기계 생성한다. 빈 미러를 먼저 만들지 않는다.

drift 검사 도구 포팅(dddjango `workspace/tools/corpus_mirror_sync.py`)은 §10-4 이후.

## 신뢰원

코퍼스 내용의 단일 근거는 제1 규약(`workspace/design/2026-06-11-dddart-file-tree.md`)과 본설계 §8(절 귀속)이다. 이 작업장의 문서는 그 슬라이스·합성본이며, 충돌 시 설계 문서를 따른다.
