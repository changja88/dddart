# RUNBOOK — 날씨 7일 예보 dddart 라이브런 (claude·codex)

> **사용자가 직접 드라이브하는 라이브런 실행서.** 환경 표준 = `TEST-ENV.md`, 입력 정본 = `SCENARIO-WEATHER.md`. 이 문서는 "플러그인 로드 → 실행 프롬프트(verbatim) → 게이트 → 채점"을 한 곳에 모은 복붙 가이드다. 에이전트는 **green 빌드까지**, 실기기 런타임·실호출은 사용자(`TEST-ENV.md` §5).

## 0. 선결물 (전부 확정)

| 항목 | 값 |
|---|---|
| OpenAPI | `https://kingdom-h.com/api/schema/?format=json` (배포 확인 · weather 목록/상세 2 paths) |
| 디자인 | Stitch MCP `projects/2284872291805682410` "심플 주간 날씨 예보" (✅2026-06-16 read 확인 · `updateTime` `2026-06-16T09:25:39Z` · 실화면 2 [목록 `33cc5745…` 390×984 · 상세 `8dc99c31…` 390×892] + design-system asset 1 · **유일 프로젝트** → 2+ 선택 불요·사용 확인만) — **인자 아님**, Phase 0에서 탐지·확인. ⚠️**실데이터 브랜드≠렌더**: `overridePrimaryColor` #4a90e2(seed) ≠ `namedColors.primary` #005da7(렌더)·sec #f5a623≠#835500·ter #4a4a4a≠#5c5c5c → `--from-theme`가 둘 다 산출+불일치 경고(roundness ROUND_EIGHT) |
| baseline(순정) | 순정 = 커밋 `abee26d` (민낯 · dio 없음). **기존 `dddart-run/*` 폴더 전부 이전 런 소비**(06-13·06-14·06-15·06-16 0149 = 1~4차). **feedback-007 5차 연결진단 런폴더 = `dddart-20260616-2025-{claude,codex}` 생성 완료**(순정 `abee26d` 검증: HEAD·clean·lib=main.dart only·dio 패키지 0 — `grep dio`의 1은 안드 주석 "stuDIO" 오탐) |
| 커맨드 | design args 제거판 — 인자 `[feature, api_url]` (커밋 `36829ee`) |
| 플러그인 소스 | `/Users/hyun/Desktop/dddart/dddart` (claude) · codex 미러 동기 · 소스 HEAD `a8fb2e3` (feedback-006) **+ feedback-007 미커밋 working tree**(연결진단 대상 — 커밋 시 이 줄에 해시 기입) |

> **새 순정 런폴더 만들기**(런 폴더 불변 — 기존 폴더는 이전 런 기록으로 보존). ✅ feedback-006 4차분(`20260616-0149`)은 이미 생성됨 — 아래는 재현 레시피(2026-06-13 폴더가 history에 순정 `abee26d` 보유):
> ```bash
> TS=20260616-$(date +%H%M)
> for v in claude codex; do
>   NEW=~/Desktop/dddart-run/dddart-$TS-$v
>   git clone ~/Desktop/dddart-run/dddart-20260613-2310-$v "$NEW"
>   git -C "$NEW" reset --hard abee26d && git -C "$NEW" clean -fdx
> done
> ```
> 결과 `dddart-$TS-{claude,codex}` = 순정 abee26d. (기존 폴더 재사용하려면 그 폴더에서 `git reset --hard abee26d && git clean -fdx` — 단 이전 런 워크트리 소실.)

## 1. dddart 플러그인 로드 (✅ 2026-06-16 feedback-007 재동기 완료 · 아래는 재현/갱신 절차)

> **상태(2026-06-16 · 소스 = feedback-006 `a8fb2e3` + feedback-007 미커밋)**: claude·codex 둘 다 **feedback-007 재동기 완료 + 소스와 byte-identical 검증**. claude = 델타 3파일(`commands/dddart.md`·`scripts/extract_design.dart`·`scripts/test/run_fixtures.sh`)만 **캐시(`~/.claude/plugins/cache/dddart-dev/dddart/0.1.1/`)에 외과적 cp** → `diff -rq` 콘텐츠 0 델타. codex = cp 루프 17스킬 재복사 → 0 델타. **재동기 방법 근거**: 버전 0.1.1 동결이라 `update`/`install`이 stale 캐시를 재사용(지난 feedback-006 시 입증) → **로더는 캐시 콘텐츠를 그대로 로드(소스 재해시 안 함)**이므로 캐시 콘텐츠를 직접 갱신하는 게 결정적·검증가능. **마커 검증**: 양 배포본 `design_source`=5·`extract_design.dart --from-theme`=7 · feedback-006 백스톱 "검사 55종"·`check_tests.dart`·`check_pubspec.dart` 무회귀. `claude plugin list` → `dddart@dddart-dev` v0.1.1 enabled · codex `~/.codex/skills/` 17스킬. **새 claude/codex 세션부터 자동 로드.** 아래 절차는 **재현·소스 변경 시 갱신용**(reinstall 폴백 포함).

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
- **반영 검증(feedback-007)**: `commands/dddart.md`에 `design_source`(5회)·`has_design_tokens`·frontmatter Stitch 읽기 5종 · `scripts/extract_design.dart`에 `--from-theme`(7회) — *(feedback-006 잔존)* `scripts/backstop.dart` "검사 55종" · `scripts/src/check_tests.dart`·`check_pubspec.dart` 존재

### codex — 신규 설치 필요 (현재 dddart류 0개)
codex는 `~/.codex/skills/<name>/SKILL.md`를 자동 로드한다(marketplace 불요). codex-dddart의 17개 스킬(`dddart` Coordinator + 역할 7 + 지식 9)을 복사한다:
```bash
for s in /Users/hyun/Desktop/dddart/codex-dddart/skills/*/; do
  n=$(basename "$s"); rm -rf ~/.codex/skills/"$n"; cp -R "$s" ~/.codex/skills/"$n";
done
```
**codex 재시작 후** 새 세션에서 로드. `/mcp`로 Stitch 확인. **반영 검증(feedback-007)**: `~/.codex/skills/dddart/SKILL.md`에 `design_source`(5회) · `scripts/extract_design.dart`에 `--from-theme`(7회) — *(feedback-006 잔존)* `backstop.dart` "검사 55종" · `scripts/src/check_tests.dart`·`check_pubspec.dart` 존재. `dddart`는 description 매칭 또는 §2 codex 프롬프트로 호출.
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
- **G0**: 풀 모드(신규 화면 2 · 신규 BC) · BC 배치 = 신규 `weather` · 계약 = OpenAPI URL 동결 · **디자인 출처 = Stitch MCP `projects/2284872291805682410`(연결 탐지 → 사용자 확인) · G0 배너에 "디자인 출처" 1줄 명시**(feedback-007 — 자체설계/미연결이면 그 사실 명시) → 승인
- **G1**(가장 간단하게): 페이지네이션 · 로컬 캐시 · 당겨서 새로고침 **전부 미적용** · 날짜 오름차순 · condition 6종 아이콘/색/한글 라벨 → 승인
- **G2**: green(컴파일 + `flutter analyze` 신규이슈 0 + 테스트) 도달 시 승인. `flutter run` 런타임·스크린샷 대조는 사용자.

## 3.5 연결 진단 관측 (feedback-007 ⑥ 채움 · 런 중 사용자 확인)
> 이 5차 런의 **핵심 목적** = Stitch *연결* 경로의 코퍼스 거동 첫 실측(6런 연속 미연결로 0회 테스트였음). 디자인/시각 충실도는 rubric **비측정**(인간 오라클·A1)이라 아래는 *프로세스 관측*(rubric PASS/FAIL 아님). 관측값을 `workspace/eval/fix/feedback-007-stitch-designmd-source.md` ⑥칸에 기록. **자기보고 불신** — 산출물·도구호출 로그를 직접 확인.
- **① 출처 질문**: Phase 0에서 연결 MCP 탐지 후 "어느 디자인 출처를 쓸지" 질문이 뜨는가(Stitch 1개면 사용 확인·2+면 선택). 침묵 자체설계 = 결함.
- **② design-ref 산출**: 기능 폴더에 `design-ref/`(예 `designtheme.json` + `design-tokens.json`)가 채워지는가. 화면 HTML 있으면 HTML 모드, design-only면 `--from-theme` 모드로 토큰 추출.
- **③ has_design_tokens=true**: 빌드상태 플래그가 토큰 추출 성공으로 잡히는가(`has_stitch_html`=화면 HTML 유무는 별개 플래그).
- **④ G0 배너 "디자인 출처" 1줄**: 출처(프로젝트 id·updateTime)·자체설계/미연결 여부가 배너에 명시되는가.
- **⑤ Stitch 쓰기 도구 0회**: 도구호출 로그에 `mcp__stitch__` **읽기 5종만**(list_projects·get_project·list_screens·get_screen·list_design_systems)·**쓰기 9종 0회**(create_*·edit_*·generate_*·update_*·upload_*·apply_*). 쓰기 1회라도 = 읽기전용 소프트락 실패(→ 하드락 hook 재검토 트리거).

## 4. 채점 (런 종료 후)
- **갭 원장**: 순정 커밋(`abee26d`) 대비 `git diff` = dddart 산출물 전량 (코퍼스 갭의 원천)
- **품질**: `rubric/RUBRIC.md`(57차원 · 치명17 · 빌드게이트) + `rubric/EVAL-METHOD.md`
- **테스트 실행(FC-2 결정레인)**: `flutter clean && flutter test` — **`clean` 선행 필수**. 미선행 시 `git clone`+`reset`+`clean -fdx` 프로비저닝이 남긴 stale 빌드 산출물로 `ink_sparkle.frag` 셰이더가 부재 → InkWell 탭 테스트가 *거짓 실패*한다(feedback-006 계획 적대리뷰 실측: clean 후 +22/-5→+24/-3·3/3 재현). clean 후 잔존 실패는 **coder 책임**(never-resolved future 위 loading 펌프 등 하니스 결함)이며 "환경이라 무시" 면제 판단 금지(자기보고 불신). 백스톱은 55종(`TG`·`PJ` 추가 — feedback-006).
- 결과지: `workspace/eval/results/<YYYYMMDD-HHMM>-weather-{claude,codex}.md`
