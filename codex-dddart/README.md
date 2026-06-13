# codex-dddart — Codex 미러

`dddart/`(Claude Code 플러그인)의 Codex 배포 미러. **지식 코퍼스(스킬 9종 `references/`)는 Claude 배포본과 byte-exact 동일**하고(`workspace/tools/corpus_mirror_sync.py`가 검사), 커맨드·에이전트는 Codex 실행 모델로 변환됐다.

## 구성

| Claude (`dddart/`) | Codex (`codex-dddart/skills/`) | 변환 |
|---|---|---|
| `commands/dddart.md` | `dddart/SKILL.md` | Coordinator → 사용자 트리거 스킬. scripts(백스톱 러너·extract_contract) 동봉 |
| `agents/<역할>.md` ×7 | `dddart-<역할>/SKILL.md` ×7 | 서브에이전트 → 역할 스킬(코디네이터가 spawn_agent로 디스패치) |
| `skills/<스킬>/` ×9 | `<스킬>/` ×9 | 그대로 복사(SKILL.md + references — byte-exact) |

## 기능 축소표 (Claude → Codex)

| 기능 | Claude | Codex | 영향·완화 |
|---|---|---|---|
| 커맨드 인자 | `arguments` named + `argument-hint` | 스킬 1급 인자 **없음** | claude 위치 인자 `[feature, api_url, design]` → codex는 본문이 **순서대로 해석**(기능→API→디자인). 사용 예시는 `default_prompt`/`defaultPrompt`로 표시 |
| 서브에이전트 | `Agent` 도구 + `agents/*.md` 자동 등록 | `spawn_agent`/`wait_agent`/`close_agent` (**`multi_agent` — 기본 on**) | 역할 정의를 `dddart-<역할>` 스킬로 분리 — 코디네이터가 명령형으로 로드 지시. (드물게) multi_agent가 꺼져 있으면 안내 후 정지(단일 컨텍스트 역할극 금지) |
| 스킬 자동 주입 | 에이전트 frontmatter `skills:` | **없음** | 역할 스킬 본문의 "로드할 지식 스킬" 절이 대체 — 서브에이전트가 직접 로드 |
| 게이트 승인 UI | `AskUserQuestion`(선택지·multiSelect) | binary approve/deny뿐 | **평문 질문 파싱**으로 대체 — 배너 뒤 "승인하려면 '승인', 고치려면 …" + 번호 목록 |
| 진행 가시성 | `TodoWrite` | `update_plan` | 동등 치환 |
| 이미지 입력 | `design-ref/` 이미지를 에이전트가 판독 | **비보장** | **치수·색 토큰·요소 목록 텍스트 메모(`design-ref/notes.md`)로 강등** — 이미지는 보조, 메모가 시각 근거 |
| 디자인 MCP 보조 경로 | 세션 MCP 감지 | 감지 방식 상이·비보장 | 기본 경로(사용자 내보낸 파일 셸 `cp` 동결)만 신뢰 |
| 플러그인 경로 변수 | `${CLAUDE_PLUGIN_ROOT}` | **미해석** | 커맨드·역할 스킬에서는 "이 스킬 디렉터리의 scripts/"·"로드한 스킬 폴더의 references/"로 환언 완료. **코퍼스 references/final.md 안에 남은 `${CLAUDE_PLUGIN_ROOT}`는 byte-exact 불변식 때문에 의도된 잔존** — "이 스킬들이 설치된 플러그인 루트"로 읽는다(공유 reference는 `discipline-houserules/references/undecidable.md`) |
| 커맨드 호출 제어 | `disable-model-invocation: true` (`/dddart` 명시 호출 전용) | description 매칭으로 자가 트리거 가능 | description의 음성 트리거("단순 단일 파일 수정…에는 쓰지 않는다")로 오발동 완화 |

## 동기 절차

코퍼스 수정은 항상 **작업장 final → awk 절단 → Claude 배포 → codex 복사** 경로다(직접 수정 금지). drift 검사·해소:

```bash
python3 workspace/tools/corpus_mirror_sync.py           # 검사 (exit 0=in-sync, 2=drift, 3=구조 깨짐)
python3 workspace/tools/corpus_mirror_sync.py --write   # 해소 (소스←배포 본문, codex←배포 전체)
```

커맨드·역할 스킬(SKILL.md)은 sync 스코프 밖이다(plugin-native 단일 파일 — Claude판 수정 시 수동으로 재변환).
