# RUNBOOK — 날씨 7일 예보 dddart 라이브런 (claude·codex 양판)

> **역할 경계**(오판 방지): **§1·§2(새 폴더 생성·플러그인 재동기)는 *준비*다 — "라이브런 준비" 요청 시 오케스트레이션 에이전트가 직접 실행**한다(사용자에게 넘기지 않는다). **§3·§4(프롬프트·게이트)는 *런*이라 사용자 드라이브** — 평가 대상이므로 사용자가 *새 세션*에서 `/dddart`를 구동한다(런 내부 dddart 파이프라인이 green 빌드까지). **§5 채점은 런 종료 후 에이전트가 지원**하고(FID 게이트 포함 — `fid-gate.sh`로 시안↔코드 구조 대조·2026-06-19 활성), 실기기 런타임(`flutter run`·스크린샷)만 사용자다. 입력 정본 `SCENARIO-WEATHER.md` · 환경 `TEST-ENV.md` · 채점 `rubric/`. **§1(폴더 생성)·§2(플러그인 재동기)는 시나리오 무관 공통 절차**(새 시나리오 RUNBOOK도 동일·`abee26d`는 통신 인프라 미설치 순정 출발점이라 시나리오 무관)·**§3 프롬프트·§4 게이트답만 weather 고유**(새 시나리오는 §3·§4만 교체).

## 고정 입력
- **OpenAPI**: `https://kingdom-h.com/api/schema/?format=json` (drf-spectacular → `?format=json` 필수)
- **디자인**: Stitch MCP `projects/2284872291805682410` — **인자 아님**. Phase 0에서 Coordinator가 탐지·확인.
- **baseline**: 순정 커밋 `abee26d`(dio 등 통신 인프라 미설치 민낯). 프로젝트 repo엔 없고 **런 폴더 git history에만** 있음 → 1차 폴더 `dddart-20260613-2310-*`가 순정 소스.

## 1. 새 런 폴더 생성 (매 런 — 제일 먼저 · **에이전트 준비**)
🔒 매 런 = 새 폴더(고유 timestamp). 기존 폴더 reset/clean·재사용 금지(런 기록 보존).
⚠️ **baseline `abee26d`는 remote·tag·프로젝트 repo 어디에도 없다 — 오직 1차 런 폴더 `dddart-20260613-2310-{claude,codex}`의 git history에만 산다.** 그래서 이 폴더가 **유일 baseline 소스**다(삭제 금지 · 아무 폴더나 소스 아님 — 예: `2304`엔 abee26d 없음). 아래 블록은 소스 부재·clone 실패·baseline 오염을 *조용히 넘기지 않고* 검증한다.
```bash
SRC=~/Desktop/dddart-run/dddart-20260613-2310      # 유일 순정 abee26d 소스
TS=$(date +%Y%m%d-%H%M)
for v in claude codex; do
  [ -d "$SRC-$v/.git" ] || { echo "❌ baseline 소스 없음: $SRC-$v — 중단(이 폴더 복구 전엔 런 불가)"; break; }
  NEW=~/Desktop/dddart-run/dddart-$TS-$v
  [ -e "$NEW" ] && { echo "❌ 이미 존재(덮어쓰기 금지): $NEW"; continue; }
  git clone -q "$SRC-$v" "$NEW" && git -C "$NEW" reset -q --hard abee26d && git -C "$NEW" clean -qfdx
  H=$(git -C "$NEW" rev-parse --short HEAD); L=$(ls "$NEW"/lib | tr '\n' ' '); D=$(git -C "$NEW" status --porcelain | wc -l | tr -d ' ')
  { [ "$H" = abee26d ] && [ "$L" = "main.dart " ] && [ "$D" = 0 ]; } \
    && echo "✅ $NEW (abee26d·민낯·clean)" \
    || echo "❌ $NEW 검증실패 HEAD=$H lib=[$L] dirty=$D — baseline 오염, 중단"
done
```
→ `✅ …-claude`·`✅ …-codex` **둘 다 떠야** 진행. ❌면 그 원인부터(소스 폴더 복구 등).

## 2. 플러그인 재동기 (현재 코퍼스 적재 · **에이전트 준비**)
버전 0.1.1 동결이라 `update`/`install`이 **stale 캐시를 재사용** → 캐시를 먼저 지운다.
```bash
# claude
rm -rf ~/.claude/plugins/cache/dddart-dev
claude plugin marketplace add /Users/hyun/Desktop/dddart
claude plugin install dddart@dddart-dev --scope user
# codex
for s in /Users/hyun/Desktop/dddart/codex-dddart/skills/*/; do
  n=$(basename "$s"); rm -rf ~/.codex/skills/"$n"; cp -R "$s" ~/.codex/skills/"$n";
done
```
**확인**(새 세션): `claude plugin list` → `dddart@dddart-dev` enabled · `/mcp` → Stitch 연결 · codex `ls ~/.codex/skills` = 19종 · 양쪽 `discipline-test`·`implementation-test` 존재.

## 3. 실행 프롬프트 (verbatim·복붙 · **사용자 런 — 새 세션**)
**claude** (런 폴더에서 `claude` 진입):
```
/dddart:dddart "날씨 예보 기능을 추가해줘. 서버 API에서 오늘부터 7일간의 일별 예보를 받아 리스트로 보여주고, 목록에서 날짜 항목을 탭하면 그날의 상세 화면으로 들어간다. 목록 항목은 날짜, 날씨 상태, 최고기온과 최저기온을 보여주며, 목록은 서버 응답 순서에 의존하지 말고 앱에서 날짜 오름차순으로 정렬해 보여준다. 상세 화면은 목록 정보에 더해 습도, 풍속, 강수확률을 보여준다. 날씨 상태는 맑음·구름많음·흐림·비·눈·뇌우 6종이며, 상태마다 아이콘과 색으로 구분해 표시한다." "https://kingdom-h.com/api/schema/?format=json"
```
**codex** (런 폴더에서 codex 진입):
```
dddart로 날씨 예보 기능을 추가해줘 — 순서대로 ① 기능: 서버 API에서 오늘부터 7일간의 일별 예보를 받아 리스트로 보여주고, 목록에서 날짜 항목을 탭하면 그날의 상세 화면으로 들어간다. 목록 항목은 날짜·날씨 상태·최고기온·최저기온을 보여주고, 목록은 서버 응답 순서에 의존하지 말고 앱에서 날짜 오름차순으로 정렬해 보여준다. 상세 화면은 거기에 더해 습도·풍속·강수확률을 보여준다. 날씨 상태는 맑음·구름많음·흐림·비·눈·뇌우 6종이며 상태마다 아이콘과 색으로 구분해 표시한다. ② OpenAPI: https://kingdom-h.com/api/schema/?format=json
```

## 4. 게이트 답 (claude·codex 동일 · **사용자 런**)
- **G0**: 풀 모드(신규 화면 2 · 신규 BC `weather`) · 계약=OpenAPI URL · 디자인=Stitch MCP(Phase 0 확인) → 승인
- **G1**(가장 간단하게): 페이지네이션·로컬 캐시·당겨 새로고침 **전부 미적용** · 정렬=**날짜 오름차순** · 6종 아이콘·색·한글 라벨=ui_extension → 승인
- **G2**: green(컴파일 + `flutter analyze` 신규이슈 0 + 테스트) 도달 시 승인. `flutter run`·스크린샷 대조는 사용자.

## 5. 채점 (런 종료 후 · 에이전트 지원)
- **갭 원장**: 순정 `abee26d` 대비 `git diff` = 산출물 전량
- **품질**: `rubric/RUBRIC.md` + `rubric/EVAL-METHOD.md`(v3.2) — 치명 18(+FID 활성 시 20)
- **테스트(FC-2)**: **`flutter clean && flutter test`** — `clean` 선행 필수(미선행 시 stale 셰이더로 InkWell 탭 테스트 거짓 실패)
- **FID 시각 충실도(L1·L2 치명 게이트·2026-06-19 활성)**: `bash workspace/eval/tools/fid-gate.sh <산출물 루트>` (양판 각각)
  - 시안(`.dddart/*/design-ref/*.html`) vs 코드(`screenProbes` 렌더 덤프) 결정론 대조 → 화면별 L1 골격·L2 섹션 PASS/FAIL.
  - exit **0**=전 화면 PASS / **2**=L1·L2 FAIL(치명·결과지 ❌) / **3**=`screenProbes` 미노출 → **A1 폴백**(코더 표준 pump 규약 미준수·❌ 도장 금지·시안 ir만 `design-ref/../ref-layout.json`에 보존·사용자 눈 재료).
  - **전제**: 9차 코더가 `_support.dart`에 `screenProbes`(implementation-test §7) 노출. **9차가 자동 경로 첫 운용** — 8차 dry-run 실측: weekly L1 누락=[image,bottomnav]·detail L1 누락=[bottomnav] 자동 포착.
  - L3=약신호(⚠·사용자 눈)·L4(미관·아이콘 심볼)=A1. `flutter clean` 후 첫 실행은 `flutter test`가 pub get 자동 처리.
- **결과지**: `workspace/eval/results/<YYYYMMDD-HHMM>-weather-{claude,codex}.md`
