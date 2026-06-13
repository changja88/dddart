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

### claude — `--plugin-dir` (설치 불요 · 소스 직접 로드 = 항상 최신)
```bash
cd ~/Desktop/dddart-run/dddart-20260613-2310-claude
claude --plugin-dir /Users/hyun/Desktop/dddart/dddart
```
세션 진입 후 확인:
- `/help` → 커맨드 이름 확인 (보통 `/dddart:dddart`, 충돌 없으면 `/dddart`)
- `/mcp` → Stitch 연결 확인 (Phase 0 디자인에 필요)

> `--plugin-dir`은 그 세션에서만 유효(매번 플래그). 소스를 직접 읽으므로 별도 설치·캐시·최신화가 불요 — 소스가 곧 최신이다. (정식 marketplace 설치를 원하면 별도로 marketplace.json을 만든다.)

### codex — codex-dddart 스킬 로드
```bash
cd ~/Desktop/dddart-run/dddart-20260613-2310-codex
# codex 세션에서 codex-dddart 플러그인/스킬 로드 (codex CLI 메커니즘 — 환경별 확인)
```
> codex 로드 절차는 codex CLI 쪽이라 claude와 다르다. **claude판을 먼저 돌리고**, codex는 그 후 로드 방법을 확정해 진행.

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
