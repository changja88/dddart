# TEST-ENV — dddart 실전 구동 테스트 환경 표준

`/dddart`를 실제로 구동해 채점할 때, **매 구동이 바이트 동일한 민낯 baseline에서 출발**해야 결과를 비교할 수 있다(claude판↔codex판, 1차↔2차). 이 문서는 그 환경을 *재현 가능하게* 만드는 절차·규칙·불변식의 단일 출처다. 시나리오(공지·날씨 등)와 무관한 **공통 전제**이며, 시나리오별 입력(task·디자인·OpenAPI 계약)은 별도(예: 작업공간의 `INPUT-SPEC.md`, `SCENARIO-S1.md`)에 둔다.

---

## 1. 핵심 원칙

- **민낯 측정**: baseline은 순정 Flutter 그대로. dio·common/network·기타 의존성을 **선설치하지 않는다**. dddart가 스스로 추가하는지가 측정 대상이다. 사전 설치·힌트·코드 주입 금지.
- **바이트 동일**: claude판·codex판은 동일 baseline에서 출발해야 동형성 비교가 성립. 한 번 정리한 baseline을 복제해 만든다(각자 `flutter create` 금지 — 산출물이 미세하게 다를 수 있다).
- **diff 기준점**: 각 테스트 폴더는 순정 상태를 git으로 커밋해 둔다. 구동 후 `git diff`(순정 커밋 대비)가 곧 "dddart가 무엇을 해냈나"의 전량 = 갭 원장의 원천.
- **라이브 테스트는 항상 사용자가 드라이브**(§5).
- **결정성**: timestamp는 추측하지 않고 `date` 명령으로 얻는다(dddart 산출물 폴더 규약과 동일 철학).

---

## 2. 경로·명명 규칙

| 항목 | 값 |
|---|---|
| baseline 원본 | `~/Desktop/smaple` (순정 Flutter — §3 사양) |
| 작업공간 | `~/Desktop/dddart-run/` |
| 테스트 폴더 | `dddart-<YYYYMMDD-HHMM>-<variant>` · `variant ∈ {claude, codex}` |
| timestamp | `date +%Y%m%d-%H%M` (한 테스트 세션의 claude/codex는 **동일 ts 공유**) |
| 시나리오 입력 | `~/Desktop/dddart-run/INPUT-SPEC.md` (현재=날씨) |

예: `dddart-20260613-2035-claude` · `dddart-20260613-2035-codex`.

---

## 3. baseline 사양 (`~/Desktop/smaple`)

`flutter create` 순정 산출물. 재현 시 이 사양과 일치해야 한다.

- Flutter **3.44.1** (stable) / Dart 동봉.
- `pubspec.yaml` `dependencies`: `flutter`(sdk) + `cupertino_icons: ^1.0.8` **뿐**. **dio 없음**.
- `lib/main.dart`(기본 카운터 앱), `test/widget_test.dart`(기본 위젯 테스트).
- `android/`·`ios/`·`analysis_options.yaml`·`.metadata`·`pubspec.lock`·`README.md`·표준 `.gitignore` 포함.
- git 순정 커밋 후 추적 파일 **67개**.

> baseline을 새로 만들어야 하면: 빈 디렉터리에서 `flutter create smaple` 후 결과를 `~/Desktop/smaple`로 둔다. 버전이 다르면 이 문서의 버전 줄을 함께 갱신한다.

---

## 4. 구축 절차 (복붙 가능)

```bash
# 0) 현재 시각으로 세션 timestamp 고정 (claude/codex 공유)
TS=$(date +%Y%m%d-%H%M)
RUN=~/Desktop/dddart-run
mkdir -p "$RUN"

# 1) 정리된 단일 baseline 생성 (IDE/빌드 캐시 제거 → 진짜 순정 소스)
rm -rf "$RUN/_pristine"
cp -R ~/Desktop/smaple "$RUN/_pristine"
rm -rf "$RUN/_pristine/.dart_tool" "$RUN/_pristine/.idea" "$RUN/_pristine/smaple.iml"

# 2) 두 벌 복제 (바이트 동일)
for v in claude codex; do
  rm -rf "$RUN/dddart-$TS-$v"
  cp -R "$RUN/_pristine" "$RUN/dddart-$TS-$v"
done
rm -rf "$RUN/_pristine"

# 3) 동일성 검증 (무출력 = 동일)
diff -rq "$RUN/dddart-$TS-claude" "$RUN/dddart-$TS-codex" && echo "IDENTICAL ✓"

# 4) 각 폴더 git 순정 커밋 (diff 기준점)
for v in claude codex; do
  cd "$RUN/dddart-$TS-$v"
  git init -q && git add -A
  GIT_AUTHOR_NAME=hyun GIT_AUTHOR_EMAIL=dev@numchida.com \
  GIT_COMMITTER_NAME=hyun GIT_COMMITTER_EMAIL=dev@numchida.com \
    git commit -qm "순정 baseline (smaple Flutter 3.44.1·dio 없음·민낯)"
  echo "$v: $(git rev-parse --short HEAD) / $(git ls-files | wc -l | tr -d ' ')파일"
done
```

**구축 후 불변식 체크**(하나라도 어기면 환경 무효):
- [ ] claude·codex 폴더가 `diff -rq`로 동일.
- [ ] 두 폴더 모두 git 순정 커밋 존재(67파일).
- [ ] `pubspec.yaml`에 dio 없음 · `.dart_tool/` 없음(= `pub get` 안 함).
- [ ] baseline(`~/Desktop/smaple`)은 원본 보존(테스트 폴더만 사용).

---

## 5. 라이브 테스트 = 항상 사용자 드라이브 (방침)

에이전트(나)는 **green 빌드까지만** 책임진다 = 컴파일 통과 + `flutter analyze` green + 단위/위젯 테스트. 다음은 **항상 사용자가 직접** 수행한다:

- 서버 배포(kingdom-server 등) 및 배포 URL 확보.
- 라이브 API 실호출·실데이터 검증.
- 실기기/시뮬레이터/에뮬레이터 런타임 구동·수동 QA.

따라서 구동 시 `baseUrl`은 **placeholder**로 두고 green 빌드를 목표한다(라이브 서버 불요). 런타임 스모크는 사용자가 배포 후 직접 드라이브한다.

---

## 6. 구동 → 채점 흐름

1. §4로 환경 구축(claude·codex 2벌).
2. 시나리오 입력(`INPUT-SPEC.md`: 기능 요청 + OpenAPI 계약 + 디자인) 준비.
3. `/dddart` 구동 — claude판(`dddart/`)·codex판(`codex-dddart/`). claude는 메인이 Coordinator로 시뮬레이션(에이전트 정의 주입 spawn·게이트는 INPUT-SPEC 기반 고정답).
4. 구동 후 `git diff`로 산출물 전량 포착.
5. `rubric/`(RUBRIC·EVAL-METHOD) 적용 — ① 갭 원장(어디까지 해냈나) ② 품질(57차원·치명18·FID 활성 시 20·빌드게이트). 결과지 → `results/<YYYYMMDD-HHMM>-<scenario>-<variant>.md`.
