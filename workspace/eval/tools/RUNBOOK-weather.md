# RUNBOOK — 날씨 7일 예보 dddart 라이브런 (claude·codex)

> **사용자가 직접 드라이브하는 라이브런 실행서.** 환경 표준 = `TEST-ENV.md`, 입력 정본 = `SCENARIO-WEATHER.md`. 이 문서는 "플러그인 로드 → 실행 프롬프트(verbatim) → 게이트 → 채점"을 한 곳에 모은 복붙 가이드다. 에이전트는 **green 빌드까지**, 실기기 런타임·실호출은 사용자(`TEST-ENV.md` §5).

## 0. 선결물 (전부 확정)

| 항목 | 값 |
|---|---|
| OpenAPI | `https://kingdom-h.com/api/schema/?format=json` (배포 확인 · weather 목록/상세 2 paths) |
| 디자인 | Stitch MCP `projects/2284872291805682410` (목록 `33cc57459ab341b78602f54959084931` · 상세 `8dc99c312d5142a39a9ad0f30ac353b1`) — **인자 아님**, Phase 0에서 화면 확인 |
| baseline | `~/Desktop/dddart-run/dddart-20260613-2310-{claude,codex}` (순정 민낯 · 67파일 · dio 없음 · HEAD `abee26d`) |
| 커맨드 | design args 제거판 — 인자 `[feature, api_url]` (커밋 `36829ee`) |
| 플러그인 소스 | `/Users/hyun/Desktop/dddart/dddart` (claude) · codex 미러 9/9 동기 |

## 1. dddart 플러그인 로드

### claude — 이미 user scope 설치 완료 (`dddart@dddart-dev`)
플러그인을 **user scope로 설치**했다(`claude plugin list` → `dddart@dddart-dev` · enabled · 캐시 `73e75ca`). user scope라 baseline을 안 건드리고 **테스트 폴더에서 claude를 그냥 열면 자동 로드**된다:
```bash
cd ~/Desktop/dddart-run/dddart-20260613-2310-claude
claude
```
세션 진입 후 확인:
- `/help` → dddart 호출명 확인 (커맨드는 최신 Claude Code에서 skill로 병합 — `/dddart:dddart` 또는 `/dddart`)
- `/mcp` → Stitch 연결 확인 (Phase 0 디자인에 필요)

> 설치 절차(재현용): `claude plugin marketplace add /Users/hyun/Desktop/dddart` → `claude plugin install dddart@dddart-dev --scope user`. **소스(`~/Desktop/dddart/dddart`)를 고치면** `claude plugin update dddart@dddart-dev`로 최신화(재시작 후 적용).

### codex — `~/.codex/skills/`에 설치 완료 (17개 스킬)
codex는 `~/.codex/skills/<name>/SKILL.md`를 자동 로드한다(graphify와 동일 방식 · marketplace 불요). codex-dddart의 17개 스킬(`dddart` Coordinator + 역할 7 + 지식 9)을 복사 설치했다. **codex 재시작 후** 새 세션에서 로드된다:
```bash
cd ~/Desktop/dddart-run/dddart-20260613-2310-codex
codex
```
세션에서 `/mcp`로 Stitch 연결 확인. `dddart`는 description 매칭으로 트리거되거나 §2 codex 프롬프트로 명시 호출.
> 설치 절차(재현): `for s in ~/Desktop/dddart/codex-dddart/skills/*/; do rm -rf ~/.codex/skills/$(basename "$s"); cp -R "$s" ~/.codex/skills/$(basename "$s"); done` → codex 재시작. **소스 변경 시 재복사**(심볼릭이 아닌 복사라 자동 반영 안 됨). 제거: `~/.codex/skills/`의 dddart·dddart-*·architecture-*·implementation-*·discipline-* 삭제.

## 2. 실행 프롬프트 (verbatim · 복붙)

### claude판
```
/dddart:dddart "날씨 예보 기능을 추가해줘. 서버 API에서 오늘부터 7일간의 일별 예보를 받아 리스트로 보여주고, 목록에서 날짜 항목을 탭하면 그날의 상세 화면으로 들어간다. 목록 항목은 날짜, 날씨 상태, 최고기온과 최저기온을 보여준다. 상세 화면은 목록 정보에 더해 습도, 풍속, 강수확률을 보여준다. 날씨 상태는 맑음·구름많음·흐림·비·눈·뇌우 6종이며, 상태마다 아이콘과 색으로 구분해 표시한다." "https://kingdom-h.com/api/schema/?format=json"
```

### codex판
```
dddart로 날씨 예보 기능을 추가해줘 — 순서대로 ① 기능: 서버 API에서 오늘부터 7일간의 일별 예보를 받아 리스트로 보여주고, 목록에서 날짜 항목을 탭하면 그날의 상세 화면으로 들어간다. 목록 항목은 날짜·날씨 상태·최고기온·최저기온을 보여주고, 상세 화면은 거기에 더해 습도·풍속·강수확률을 보여준다. 날씨 상태는 맑음·구름많음·흐림·비·눈·뇌우 6종이며 상태마다 아이콘과 색으로 구분해 표시한다. ② OpenAPI: https://kingdom-h.com/api/schema/?format=json
```
> 디자인은 두 판 모두 **인자가 아니다** — Phase 0에서 Coordinator가 연결된 Stitch MCP로 화면을 탐색·확인한다.

## 3. 게이트 예상답 (`SCENARIO-WEATHER.md` §4 — 라이브런에선 사용자가 직접 확인)
- **G0**: 풀 모드(신규 화면 2 · 신규 BC) · BC 배치 = 신규 `weather` · 계약 = OpenAPI URL 동결 · 디자인 = Stitch MCP → 승인
- **G1**(가장 간단하게): 페이지네이션 · 로컬 캐시 · 당겨서 새로고침 **전부 미적용** · 날짜 오름차순 · condition 6종 아이콘/색/한글 라벨 → 승인
- **G2**: green(컴파일 + `flutter analyze` 신규이슈 0 + 테스트) 도달 시 승인. `flutter run` 런타임·스크린샷 대조는 사용자.

## 4. 채점 (런 종료 후)
- **갭 원장**: 순정 커밋(`abee26d`) 대비 `git diff` = dddart 산출물 전량 (코퍼스 갭의 원천)
- **품질**: `rubric/RUBRIC.md`(57차원 · 치명17 · 빌드게이트) + `rubric/EVAL-METHOD.md`
- 결과지: `workspace/eval/results/<YYYYMMDD-HHMM>-weather-{claude,codex}.md`
