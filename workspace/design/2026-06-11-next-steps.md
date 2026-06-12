# 다음 작업 (2026-06-12 갱신 #2)

> **상태: 제1 규약 확정(2026-06-12) + 에이전트 구성 브레인스토밍 합의 완료.**
> 리뷰 전체 결과·백스톱 불변식 39종: `2026-06-12-file-tree-final-review.md`

## 즉시 할 일

1. ~~제1 규약 최종 확정~~ — 완료. 상태줄 "확정(2026-06-12)"로 변경됨.
2. ~~에이전트 구성 브레인스토밍~~ — 완료. **`2026-06-12-pipeline-agent-composition.md` 확정**: 커맨드 1 + 에이전트 7종(architect / 리뷰어 ddd·ui·state·data **4종 전부 항상 활성** / coder / discipline-reviewer), acceptance-tester 공백 흡수(슬라이스=Coordinator, Green=analyze+빌드+백스톱+G2 행위 체크리스트 눈 확인), OpenAPI 입력 설계(`.dddart/config.json`의 `openapi_url`·인자 우선·계약 스냅샷·Coordinator만 config 읽기).
3. **§10-1 파이프라인 본설계** — `2026-06-12-pipeline-design.md` 작성 + **적대 리뷰 5렌즈 통과·반영 완료**(`2026-06-12-pipeline-adversarial-review.md` — blocker 11·사용자 결정 4건: 트리비얼 채널·수정 모드 touched-layer lens·touched 경량 감사·G2 스크린샷). 핵심 보강: 판정 소유 양성 규칙(1곳째부터 domain 기본 — 제1 규약 §3.3 개정), codegen 규약, analyze 베이스라인 green, build-state.json, openapi-full 동결→G1 후 기계 절단(extract-contract.py), 모드 삼분류(구조 단위), 정수 임계. **사용자 최종 확정 대기** → 확정 시 §10-2 백스톱 설계 착수(요구: touched-gate 예외 절·추가 백스톱 4건·러너 1개·extract-contract.py). 참고 실물: `/Users/hyun/Desktop/dddjango/`.

## 파이널 리뷰 결과 요약 (2026-06-12)

- 방법: 3자 리뷰(정독 + 정합성 에이전트 + 아키텍트 에이전트) + 시나리오 시뮬레이션 3건. 발견 critical 5·major 9·minor 23 — **전부 해소·반영 완료**.
- 핵심 진단: 정적 트리는 완성형이었으나 동적 배선(root 협력 채널)이 미규정 → §3.6에 "root 내부 협력 규칙" 신설로 해소.
- 실측 수치 재측정 완료(BC 16개, App 44/36, VM 77/4, common 55/11, refresh 8BC/12VM) — 문서·메모리 교정 반영.

## 사용자 확정 7건 (순서대로 결정 — 상세는 문서 §3.6·메모리)

1. 푸시 탭 청취·정규화 = root_destination_handler 소유, 디스패치 `rootRouter.go(url)` 단일
2. initializer는 부수효과만 — 시동 질문은 root_vm.build()가 UseCase 재조회
3. handler 3종 = Service 변종(@Riverpod keepAlive) — @riverpod 화이트리스트 = BC 3변종 + root 2변종
4. rootRouter = plain 전역 변수 — redirect는 UseCase 직접 생성·호출
5. hive 어댑터 = `data_source/<bc>_hive_adapters.dart`, root_initializer만 import 예외
6. 걸치는 domain_service 공용 위치 폐지 — 조율=UseCase, 순수 판정=주어 애그리거트 귀속
7. **Either Right=성공** (기존 프로젝트 관례 우선 단서, 잠정 폐기)

## 남은 흐름

1. **사용자 최종 확정** → 문서 상태줄을 "확정"으로 변경
2. §10-1 파이프라인 — Coordinator 커맨드·에이전트 7종(architect, 리뷰어 ddd·ui·state·data, coder, discipline-reviewer)·G0/G1/G2 게이트
3. §10-2 백스톱 스크립트 초기 세트 — **리뷰 리포트의 불변식 39종 목록이 준비물** (⚠ 표시 3건은 결정 1~5로 이미 해소됨)
4. §10-3 스킬 9종 코퍼스 / §10-4 저장소 골격(`dddart/`·`codex-dddart/`·`workspace/` + sync 도구 이식)
5. 이연: §10-5 코드 규율(① 에러 계약·State 에러 필드 ③ 애그리거트 규율·VM 판정 강등 상세 ④ 스크롤톱), §10-6 도메인 이벤트(재논의 트리거 대기)
