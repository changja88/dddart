# RUNBOOK — 날씨 7일 예보 dddart 라이브런 (claude·codex)

> **사용자가 직접 드라이브하는 라이브런 실행서.** 환경 표준 = `TEST-ENV.md`, 입력 정본 = `SCENARIO-WEATHER.md`. 이 문서는 "플러그인 로드 → 실행 프롬프트(verbatim) → 게이트 → 채점"을 한 곳에 모은 복붙 가이드다. 에이전트는 **green 빌드까지**, 실기기 런타임·실호출은 사용자(`TEST-ENV.md` §5).

## 0. 선결물 (전부 확정)

| 항목 | 값 |
|---|---|
| OpenAPI | `https://kingdom-h.com/api/schema/?format=json` (배포 확인 · weather 목록/상세 2 paths) |
| 디자인 | Stitch MCP `projects/2284872291805682410` (목록 `33cc57459ab341b78602f54959084931` · 상세 `8dc99c312d5142a39a9ad0f30ac353b1`) — **인자 아님**, Phase 0에서 화면 확인 |
| baseline(순정) | 순정 = 커밋 `abee26d` (민낯 · dio 없음). **기존 `dddart-run/*` 4폴더는 전부 이전 런으로 소비됨**(2026-06-13·06-14 · HEAD=weather 빌드 완료) → feedback-005 런은 **새 순정 폴더**에서 (아래 스니펫) |
| 커맨드 | design args 제거판 — 인자 `[feature, api_url]` (커밋 `36829ee`) |
| 플러그인 소스 | `/Users/hyun/Desktop/dddart/dddart` (claude) · codex 미러 9/9 동기 · 소스 HEAD `cddfd12` |

> **새 순정 런폴더 만들기**(런 폴더 불변 — 기존 4폴더는 이전 런 기록으로 보존). 2026-06-13 폴더가 history에 순정 `abee26d`를 가지므로 거기서 추출:
> ```bash
> TS=20260615-$(date +%H%M)
> for v in claude codex; do
>   NEW=~/Desktop/dddart-run/dddart-$TS-$v
>   git clone ~/Desktop/dddart-run/dddart-20260613-2310-$v "$NEW"
>   git -C "$NEW" reset --hard abee26d && git -C "$NEW" clean -fdx
> done
> ```
> 결과 `dddart-$TS-{claude,codex}` = 순정 abee26d. (기존 폴더 재사용하려면 그 폴더에서 `git reset --hard abee26d && git clean -fdx` — 단 이전 런 워크트리 소실.)

## 1. dddart 플러그인 로드 (✅ 2026-06-15 설치 완료 · 아래는 재현/갱신 절차)

> **상태(2026-06-15 · 소스 HEAD `cddfd12`)**: claude·codex 둘 다 **설치 완료 + 소스와 byte-identical 검증**(claude 0 diff · codex 17/17 일치 · E3 `extract_design.dart`·F-fix NM17 `_nonWidgetReturnTypes`·backstop "검사 52종" 모두 확인). `claude plugin list` → `dddart@dddart-dev` v0.1.1 enabled · codex `~/.codex/skills/` 17스킬. 직전 인계물 시점엔 미설치였고(플러그인 캐시 sweep로 claude 등록 소실·codex 미복사), 이번 턴에 (재)설치함. **새 claude/codex 세션부터 자동 로드.** 아래 절차는 **재현·소스 변경 시 갱신용**.

### claude — 재설치 필요 (단순 `update` 불가)
설치 기록이 없어 `claude plugin update`는 대상이 없다. 게다가 캐시 폴더 버전이 소스와 같은 `0.1.1`이라 **stale 캐시 재사용을 막으려면 캐시를 먼저 지우고** 재설치한다:
```bash
rm -rf ~/.claude/plugins/cache/dddart-dev                  # 1) stale 오펀 캐시 제거 (버전 0.1.1 동일 → 재사용 차단)
claude plugin marketplace add /Users/hyun/Desktop/dddart   # 2) marketplace 재등록 (매니페스트 name=dddart-dev)
claude plugin install dddart@dddart-dev --scope user       # 3) user scope 설치
```
user scope라 baseline을 안 건드린다. **claude 재시작 후** 순정 런폴더에서 열면 자동 로드:
```bash
cd <새 순정 런폴더>   # §0 스니펫으로 생성
claude
```
세션 진입 후 확인:
- `claude plugin list` → `dddart@dddart-dev` · enabled
- `/help` → 호출명 (`/dddart:dddart` 또는 `/dddart`) · `/mcp` → Stitch 연결
- **반영 검증**: 설치본에 `scripts/extract_design.dart` 존재(E3) · `scripts/backstop.dart`에 "검사 52종"

### codex — 신규 설치 필요 (현재 dddart류 0개)
codex는 `~/.codex/skills/<name>/SKILL.md`를 자동 로드한다(marketplace 불요). codex-dddart의 17개 스킬(`dddart` Coordinator + 역할 7 + 지식 9)을 복사한다:
```bash
for s in /Users/hyun/Desktop/dddart/codex-dddart/skills/*/; do
  n=$(basename "$s"); rm -rf ~/.codex/skills/"$n"; cp -R "$s" ~/.codex/skills/"$n";
done
```
**codex 재시작 후** 새 세션에서 로드. `/mcp`로 Stitch 확인. **반영 검증**: `~/.codex/skills/dddart/scripts/extract_design.dart` 존재. `dddart`는 description 매칭 또는 §2 codex 프롬프트로 호출.
> **소스 변경 시 재복사**(심볼릭 아닌 복사라 자동 반영 안 됨). 제거: `~/.codex/skills/`의 dddart·dddart-*·architecture-*·implementation-*·discipline-*.

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
- **테스트 실행(FC-2 결정레인)**: `flutter clean && flutter test` — **`clean` 선행 필수**. 미선행 시 `git clone`+`reset`+`clean -fdx` 프로비저닝이 남긴 stale 빌드 산출물로 `ink_sparkle.frag` 셰이더가 부재 → InkWell 탭 테스트가 *거짓 실패*한다(feedback-006 계획 적대리뷰 실측: clean 후 +22/-5→+24/-3·3/3 재현). clean 후 잔존 실패는 **coder 책임**(never-resolved future 위 loading 펌프 등 하니스 결함)이며 "환경이라 무시" 면제 판단 금지(자기보고 불신). 백스톱은 55종(`TG`·`PJ` 추가 — feedback-006).
- 결과지: `workspace/eval/results/<YYYYMMDD-HHMM>-weather-{claude,codex}.md`
