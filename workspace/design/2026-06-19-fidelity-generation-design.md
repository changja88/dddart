# 시각 충실도 생성측 설계 (2026-06-19)

> 평가측 짝: `2026-06-19-fidelity-eval-design.md`(layout-ir 추출기·oracle 재사용). 자료조사: `2026-06-19-stitch-fidelity-research.md`.
> 합의 경위: 평가측 먼저 완료 → 생성측. 주입 구도 + **L1·L2 강제** 합의(2026-06-19).
> **상태: 큰 그림 합의 · architect/coder 지침 세부는 코퍼스 확인 후 구체화.** 생성측은 **코퍼스(생성 파이프라인) 변경**이라 평가측보다 침습이 크다 → 양판 미러 동기 + 다음 런 동결 + **별도 사용자 승인** 필요(코퍼스 불변 원칙).

---

## 0. 목표·범위

- **목표**: 평가측이 시안에서 추출하는 `layout-ir`을 coder 쪽 **입력**으로 돌려줘 엔진 간 레이아웃 분기를 *원인 측*에서 줄인다. 평가측이 "달라진 걸 잡는다"면, 생성측은 "덜 달라지게 한다".
- **범위**: 생성 파이프라인의 layout-ir **소비**(extract_design 추출 확장·design-architect·coder·architecture-ui). 추출기·oracle 자체는 평가측에서 이미 설계.
- **비목표**: HTML→위젯 직변환(코퍼스 금지)·픽셀좌표 강제(Anima 함정)·말단 슬롯 강제(L3=유도·L4=눈).

## 1. 주입 구도

```
Phase 0 (동결·추출)
  extract_design → design-tokens.json + layout-ir.json   ← 평가측과 공유
Phase 1 (설계)
  design-architect: layout-ir의 L1·L2를 설계 명세에 강제 반영
                    (+ L3 말단 슬롯·design-ref HTML은 참고)
Phase 2 (구현)
  coder: architect 설계를 view/section/widget 규약대로 구현
사후
  평가측 L1·L2 게이트: 시안 layout-ir vs 생성 구조 → 골격·섹션구성 누락 FAIL
```

## 2. 강제 강도 (평가측과 대칭)

| 계층 | 생성측 | 평가측 |
|---|---|---|
| **L1 골격** | **강제**(architect 반드시 반영) | 게이트(❌) |
| **L2 섹션 구성** | **강제**(architect 반드시 반영) | 게이트(❌·평탄화) |
| **L3 말단 슬롯** | 유도(참고로 줌) | 약신호(⚠) |
| **L4 픽셀·미관** | 사용자 눈 | A1 인간 |

대칭 원칙: 입력으로 강제한 만큼(L1·L2) 출력으로 게이트하고, 유도한 만큼(L3) 신호로 본다.

## 3. 원리 — "무엇을" vs "어떻게" 분리 (ScreenCoder식)

- `layout-ir` = **무엇을**: 섹션·반복 그룹·이미지·슬롯의 존재·순서.
- dddart 규약 = **어떻게**: MVVM·view 수동·section 위젯·widget 재사용·NM17 등.
- 두 축이 직교라 충돌 안 함(평가측 검산에서 시안 section ↔ dddart section 자연 대응 확인). architect는 "무엇을"을 layout-ir에서 고정받고, "어떻게"를 규약대로 결정.

## 4. 분기가 실제로 주는 메커니즘 — 입력 유도 + 출력 게이트 **쌍**

- 입력만(architect에 구조 주기): LLM이라 안 지킬 수 있음.
- 게이트만(평가측): "달라진 걸 알 뿐", 덜 달라지게 하진 못함.
- **둘이 쌍으로**: architect가 L1·L2를 반영(유도) + 평가측 L1·L2 게이트가 검증(닫음). 자료조사 ScreenCoder가 +3.6%p 얻은 "구조를 명시 입력으로 고정" 효과의 dddart 구현.

## 5. 이미지 처리 ([[stitch-image-asset-bundling]] 합류)

- `layout-ir`이 `<img>`를 `image` 노드로 보존(src/alt) → coder가 `Image.asset` + pubspec 번들.
- 평가측 **L1 `image` 게이트**가 누락을 닫음(사용자 지적 ② 자동 포착).
- **✅ URL 실측(2026-06-19)**: 현재 HTTP 200·핫링크 비차단·CORS `*`·image/png 233KB → **다운로드 가능**. 단 `cache-control: max-age=86400`(24h 캐시 재검증)·서명 만료 헤더 없음·Google CDN은 폐기 가능 → **URL 수명 보장 없음**. 결론 = **빌드타임 다운로드+번들(`Image.asset`) 확정**(런타임 `Image.network` 직참조는 수명 위험·자료조사 가설 확인). N=1 주의: 한 번 조회가 영구/단기를 증명하진 않으나 "수명 보장 없음 + 다운로드 가능"이면 번들이 안전한 선택.
- **여전히 미확인**: 재배포 **라이선스**(헤더로 안 나옴) — 사용자 콘텐츠 CDN 약관 확인 필요(번들=로컬 복제라 별도 검토).

## 6. measure-first · 코퍼스 침습

- 변경 대상: `extract_design`(layout-ir 추출 추가) + `design-architect`(소비 지침) + `coder`/`implementation-*`(구현) + `architecture-ui`(규약). 전부 **코퍼스(생성 파이프라인 핵심)**.
- 절차: 양판 미러(claude `commands/`·`agents/`·`skills/` ↔ codex `SKILL.md`, `final.md`는 `corpus_mirror_sync`) 동기 + **다음 런 동결** + **사용자 별도 승인**(코퍼스 불변).
- 평가측(주로 eval 변경)을 먼저 안정화한 뒤 생성측을 얹는 게 measure-first 순서(생성 개선 효과를 평가측으로 측정).

## 7. 열린 질문 · 다음 단계

- **architect가 layout-ir 소비하는 지침의 구체 형태** — 코퍼스 `design-architect`·`design-review-ui` 확인 후 확정(명세에 L1·L2를 어떻게 박게 할지).
- **coder 지침·architecture-ui 규약 반영** — `coder`·`implementation-flutter`·`architecture-ui/references/final.md`.
- ~~layout-ir JSON 스키마~~ **✅ 정의됨**: `2026-06-19-layout-ir-schema.md`. 남은 세부 4건은 그 문서 §6.
- **"표준 pump 진입점" 규약** — 평가측 렌더 덤프와 공유(테스트 규약).
- **다음**: 코퍼스(`design-architect`·`coder`·`architecture-ui`) 읽고 layout-ir 소비 지침을 구체화. 이미지 트랙은 URL 만료 실측 후.
