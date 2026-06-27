# dddart 프로젝트 지침

## 프로젝트 목적

이 저장소는 `dddart` 플러그인을 개발하는 워크스페이스다. 플러그인은
`/dddart` 커맨드(Coordinator)가 기존 Flutter 프로젝트의 한 기능을 간소화 DDD +
철저한 MVVM 방식으로 요구→설계→구현까지 단계별 게이트로 빌드하도록 오케스트레이션한다.
**Claude Code(`dddart/`)와 Codex(`codex-dddart/`) 양 런타임을 지원**하며, 둘 다
같은 GitHub 레포에서 마켓으로 배포한다(Claude `dddart@changja88-dddart` · Codex `dddart@changja88-dddart`).
정본은 `dddart/`이고 `codex-dddart/`는 동기 미러(`corpus_mirror_sync`로 동기 검증)
— 단, 디자인 관련 `agents/`·`SKILL.md`는 claude=Claude Design / codex=Stitch 비대칭으로 의도적으로 발산한다.

## 저장소 구조

- `dddart/` — 실제 플러그인. `.claude-plugin/plugin.json`(매니페스트) +
  `commands/dddart.md`(Coordinator) + `agents/*.md`(7개 subagent) +
  `skills/*/references/final.md`(11개 스킬) + `scripts/`(extract·fetch 도구 +
  `backstop.dart`/`src/check_*.dart` 결정적 백스톱 58종).
- `codex-dddart/` — Codex 런타임 미러. `skills/*/SKILL.md` + `skills/dddart/scripts/`(백스톱 미러).
- `workspace/reference/**` — 소스 코퍼스(아키텍처·구현 레퍼런스의 `final.md`). 스킬 재생성의 1차 근거.
- `workspace/design/`, `workspace/plan/` — 빌드 설계 메모와 계획서.
- `workspace/eval/` — 라이브런 평가 폐곱(`results/` 채점·`fix/` 처방 원장·`rubric/`·`tools/`).
  코퍼스 교정은 라이브런→채점→처방→재라이브런으로 검증한다(예상효과 사전등록·다음 런 실측 대조).

## 작업 위치 원칙

- 플러그인 산출물(커맨드·subagent·스킬·매니페스트·백스톱)은 `dddart/` 아래에 둔다.
- 빌드 과정의 설계·계획·레퍼런스·평가 등 개발 산출물은 `workspace/` 아래에 둔다.
- 플랫폼·도구 규격상 루트에 있어야 동작하는 파일만 예외적으로 루트에 두고,
  이유를 변경 내용에 남긴다.

## 플러그인 작성 원칙

- 커맨드·subagent 파일 본문은 곧 런타임 시스템 프롬프트다. 설계 근거 같은
  메타코멘트로 본문을 오염시키지 않는다.
- 한 주제는 한 소유자가 — 역할 경계를 넘기지 않는다(설계 명세=architect, 코드=coder, 감수=discipline-reviewer).
- 스킬은 소스 코퍼스(`workspace/reference/**`)를 근거로 작성하며, 플러그인 이름은 `dddart`로 일관되게 쓴다.
- **양판 동기**: `dddart/`(정본)를 고치면 `codex-dddart/` 미러도 함께 맞춘다 — final.md는
  `corpus_mirror_sync`로 동기하고, 백스톱 스크립트·추출 스크립트(`extract_design`·`fetch_images`)는
  ADD-A-MODE(기존 모드 불변·신규 모드 추가) 방식으로 byte-identical 미러를 유지한다.
  단, **`agents/`·`SKILL.md`는 디자인 출처 비대칭으로 의도적으로 발산**하므로 byte-identical로 단정하지 않는다.
- **의도된 엔진 비대칭(디자인 출처)**: claude는 Claude Design(claude.ai 내장 `DesignSync`·읽기 전용)을
  쓰고, codex는 Stitch MCP를 유지한다. 이유: Claude Design은 표준 MCP가 아니라 claude.ai에 내장된 도구라
  OpenAI Codex에서 접근할 수 없다. 이 발산은 'drift'가 아닌 의도된 비대칭이므로, 미러 동기·diff 리뷰 시
  `agents/`·`SKILL.md`의 디자인 관련 변경을 오탐으로 처리하지 않는다.
- 플러그인 매니페스트나 구조를 바꾸면 `claude plugin validate dddart --strict`로 검증한다.

## 코퍼스 교정 원칙 (평가 폐곱)

- 코퍼스(`dddart/` + `codex-dddart/`) 변경은 라이브런 채점으로 결함을 확인하고, 고치기 *전에*
  예상효과(다음 런에서 바뀔 측정 dim)를 `workspace/eval/fix/feedback-NNN-*.md`에 사전등록한다.
- 과적합(특정 시나리오 역설계)·다른 코퍼스와의 모순은 금지한다. 처방 전 적대적 리뷰로 검증한다.
- N=1 인과 단정 금지(엔진 비결정으로 런마다 출렁일 수 있다 — 유발이 아니라 동시발생으로 기록).

## 변경 방식

- 기존 파일과 사용자 변경을 보존한다.
- 불필요한 추상화나 미리 만든 확장 지점을 추가하지 않는다.
- 구조 변경·대규모 재작성은 작은 단위로 나누고, 논의 후 진행한다.
