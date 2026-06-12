# 코퍼스 작업장 규약

dddart 스킬 9종의 코퍼스 원료·작업본은 여기서 관리한다. 배포본은 `dddart/skills/<스킬>/`(SKILL.md + references/)이다. 구조는 dddjango `workspace/reference/`를 승계했다.

## 구조 (스킬 9종 공통)

```
workspace/reference/<스킬>/reference/
├── internal.md   # 사용자 직접 제공 원료 — 읽은 책의 요약. 에이전트가 만들지 않는다.
├── external.md   # 외부 자료 조사 — 에이전트 수행 (공식 문서·평판 자료. ddd·cleancode는 dddjango final 반입분이 이 슬롯)
├── review.md     # internal·external 교차 리뷰 기록
└── final.md      # 최종 합성본 — 배포본 references/final.md와 본문 동일 유지
```

네 파일이 전부 필수는 아니다(dddjango도 houserules·implementation-django 계열은 final만 보유).

- **internal.md는 사용자만 제공한다.** dddjango에서 internal이 없던 스킬은 dddart에서도 없다. ddd·cleancode의 사용자 서적 요약은 이미 dddjango final(=반입된 external) 안에 합성돼 있다.
- **제1 규약·본설계·HaffHaff 실측은 internal이 아니다.** 확정 설계 문서이므로 코퍼스에 슬라이스 사본을 만들지 않고, final 합성 때 `workspace/design/` 문서를 직접 원료로 읽고 §번호로 인용한다(사본은 규약 개정 시 stale 신뢰원이 되는 drift 표면).

## 미러 불변식 (dddjango corpus_mirror_sync 승계)

1. 소스 `final.md` 본문 ≡ 배포 `dddart/skills/<스킬>/references/final.md` 본문
2. 배포(claude) ≡ 배포(codex) — `codex-dddart/`는 배포본이 생긴 뒤 동기화 도구로 기계 생성한다. 빈 미러를 먼저 만들지 않는다.

drift 검사 도구 포팅(dddjango `workspace/tools/corpus_mirror_sync.py`)은 §10-4 이후.

## 신뢰원

코퍼스 내용의 단일 근거는 제1 규약(`workspace/design/2026-06-11-dddart-file-tree.md`)과 본설계 §8(절 귀속)이다. 이 작업장의 문서는 그 슬라이스·합성본이며, 충돌 시 설계 문서를 따른다.
