# DT-2 가드 + screenProbes green 강제 — 구현 plan (작업 A·C)

> **For agentic workers**: 코퍼스 markdown 편집 plan(도구 코드 불변). "테스트 사이클" = 앵커 grep(편집 전 현존) → 편집 → 앵커 grep(신규 present·구 absent) → 양판 대칭. 단계는 `- [ ]` 체크박스. REQUIRED SUB-SKILL: superpowers:subagent-driven-development 또는 executing-plans.

**Goal**: 14차 거짓 PASS(FID 게이트 6회 미발동)와 DT-2 치명 누수(N=2 swap)를 닫는다 — render-smoke 테스트로 screenProbes를 green 경로에 강제하고, 에러바디 정규화기의 catch-내부 throw를 단일출구로 수렴시킨다.

**Architecture**: 승인된 설계 명세 `2026-06-22-fid-measurement-dt2-design.md` 중 **작업 A(DT-2)·C(screenProbes)만** 집행. **작업 B(image set-membership)는 적대 검증이 4결함(appbar/nav 맹점·extract dedup 비대칭·L2 은폐·repeat 비대칭)을 노출해 별도 재설계 회차로 분리**(사용자 결정 2026-06-22·아래 §분리 근거). 측정 도구(`compare_layout`·`dump_to_ir`·`extract_layout`·`fid-gate`·`positive-control`)는 **이번 회차 전부 불변**. 순수 코퍼스 편집.

**Tech Stack**: 코퍼스 markdown(`skills/*/references/final.md`·`agents/coder.md`·codex `SKILL.md`·`RUBRIC.md`) + `workspace/tools/corpus_mirror_sync.py`.

## 적대 검증 반영 (4렌즈·2026-06-22)

- **작업 A(렌즈 2·견고)**: Dart 시맨틱 전제를 실측 스니펫으로 확증 — `on DioException` 절 내부 `fromJson` throw는 형제 `on TypeError`*와* 말미 `catch (e)` catch-all *모두* 못 잡고 누수. backstop에 DT-2 검출 로직 없음(결정 레인 무반응). Q-6/DT-2/4규칙/G-8 거짓 FAIL 0. → 처방 옳음. **MINOR 1건 반영**: 불변식 산문에 "기존 catch-all도 못 잡는다"는 *진짜* 근거 명시.
- **작업 C(렌즈 3·원안 작동 안 함 → 교정)**: render-smoke `main()`을 `_support.dart`(헬퍼)에 두면 `flutter test`가 **수집 안 함**(`*_test.dart`만 실행) → 강제 0. 저장소 자신이 `fid-gate.sh:63`(`_support.dart`→`fid_dump_test.dart` 복사)·`dump_probe.dart.txt`(별도 `*_test.dart`가 헬퍼 import)로 정답 패턴 증명. + 빈 맵 도망로(`screenProbes={}`→단언 0개 green). → **render-smoke를 별도 `render_smoke_test.dart`로 + `isNotEmpty` 비-vacuity 가드**로 교정(BLOCKER 2건 해소).
- **렌즈 3 MAJOR(fid-gate exit 3 기계 격상) 보류**: green 강제(coder 측·1차 방어)가 제대로 작동하면 미노출이 애초에 안 생긴다. fid-gate exit-3 → BLOCKER *기계* 격상은 RUBRIC 채점 정책 변경이라 **작업 B(측정 재설계) 회차에서 같이** 본다. 이번엔 green 강제 + RUBRIC 산문 보강(2차 안전망)까지. (한계로 기록.)
- **plan 기계(렌즈 4)**: 앵커·old 블록 **전부 문자 단위 일치**(시술 실패 0). 정밀화 #2(fid-gate "도장 금지"는 이미 명문·exit 격상 *문언*은 미이행이나 green 강제로 대체) 정직 표기.

## Global Constraints (모든 Task 암묵 포함)

- **불가침(이번 회차)**: 모든 eval 측정 도구 — `compare_layout.dart`·`dump_to_ir.dart`·`dddart/scripts/extract_layout.dart`·`fid-gate.sh`·`positive-control/`·`layout-ir-schema.md`. **image 측정은 작업 B 후속**(스키마 정규화 규모).
- **미러**: `references/final.md`(architecture-data·implementation-dart·implementation-test) = `corpus_mirror_sync.py --write`(배포→소스 `workspace/reference/`+codex 자동). `agents/coder.md`·`SKILL.md` = **수동** codex 미러. `RUBRIC.md`(eval) = 단일(미러 불요).
- **앵커 기반**: 라인 번호 아닌 *문구*로 grep(드리프트 대비). 아래 라인 번호는 2026-06-22 기준 참고값.
- **시술은 별도 승인**·**다음 런 동결**·**커밋은 사용자 요청 시**·**feedback-016(생성측 충실도 10항목)·작업 B(image)와 별개 회차**.
- **N=1 인과 단정 금지**: 다음 런 실측은 "X 적용 후 Y 관찰"로 기록.

## File Structure

| 파일 | 책임 | 변경 | 미러 |
|---|---|---|---|
| `dddart/skills/architecture-data/references/final.md` | safeApiCall 골든 | :56 `fromJson` try/on Object 가드 + 불변식(catch-all 근거 포함) | auto(`--write`) |
| `dddart/skills/implementation-dart/references/final.md` | catch 위생 규율 | :49 safeApiCall 조항에 "파서 2차 throw" 단서 1줄 | auto(`--write`) |
| `dddart/agents/coder.md` | 구현 산출 규약 | :35 screenProbes + 별도 `render_smoke_test.dart`(isNotEmpty+role) 필수 산출 | 수동→`dddart-coder/SKILL.md` |
| `dddart/skills/implementation-test/references/final.md` | 헬퍼 계약·§7 | :135 render-smoke 별도파일 소비 승격 + 테스트 파일 예시 | auto(`--write`) |
| `dddart/skills/implementation-test/SKILL.md` | §7 라우팅 | :29 "render-smoke 테스트가 소비" 미세 갱신 | 수동(plugin-native) |
| `workspace/eval/rubric/RUBRIC.md` | §H FID 판정 | :138 "미노출 반복=픽스처 흠" 미세 보강 | eval 단일 |

## 작업 B 분리 근거 (이번 제외·기록)

적대 검증(렌즈 1)이 패치 end-to-end로 4결함 재현: ① `_countImages`가 appbar/bottomnav slot image 미집계 → 시안=area image vs 코드=AppBar 내부 거짓 FAIL(**14차와 동형**) ② `extract_layout._dominantType`의 Set dedup vs `dump_to_ir` 장당 1개 → 총수 비대칭(**compare 1파일로 불가**) ③ L2 image 제외+`_collapse`가 section 내부 image 누락 은폐 ④ repeat 형성 비대칭 갤러리 거짓 FAIL. **근본**: image가 area일 수도 slot일 수도 있고 두 파서가 같은 image를 다른 레벨에 둔다 — L1·L2 어디서 비교해도 레벨 비대칭이 샌다. 깨끗한 해법 = image를 layout-ir에서 **위치 무관 단일 표현**(screen 레벨 `images:[]`)으로 정규화 = `dump_to_ir`+`extract_layout`+스키마+`compare` **4곳**(설계 원안 3파일보다 큼·스키마 동결 변경) → **별도 brainstorming**. **image "측정" 보류 ≠ image "재현" 보류**: 시안 요소 100% 재현(사용자 공리)은 육안 오라클(feedback-015)+생성측 처방(feedback-016)이 담보하고, image 측정 거짓 FAIL은 육안으로 무시 가능.

---

## 작업 A — DT-2 가드 골든 (생성측·코어 무관·먼저)

### Task 1: safeApiCall 골든에 정규화기 throw 가드 (`architecture-data/references/final.md`)

**Files**: Modify `dddart/skills/architecture-data/references/final.md` (:56 골든 + 불변식 산문).

**Interfaces**:
- Produces: 골든 `safeApiCall` 본문 — `on DioException` 절 내부 `fromJson` 호출이 try/on Object로 감싸져 2차 throw도 `Left`로 수렴. coder가 직역.

- [ ] **Step 1: 앵커 현존 확인** — Run: `grep -n 'BadRequestResponse.fromJson(data)); // 서버 에러 바디 그대로' dddart/skills/architecture-data/references/final.md` → 1 매치(L56).

- [ ] **Step 2: :56 골든 라인을 try/on Object 가드로 교체.**

old(:55-57):
```dart
    if (data is Map<String, Object?>) {
      return Left(BadRequestResponse.fromJson(data)); // 서버 에러 바디 그대로 — isShow도 서버 값
    }
```
new:
```dart
    if (data is Map<String, Object?>) {
      try {
        return Left(BadRequestResponse.fromJson(data)); // 서버 에러 바디 그대로 — isShow도 서버 값
      } on Object {
        // 정규화기 자신이 throw(봉투 스키마 불일치) — 이 throw는 이미 진입한 on DioException 절 내부라
        // 형제 on TypeError(아래)도 말미 catch-all(맨 끝 catch (e))도 못 잡는다(전부 같은 try의 형제).
        // 그래서 여기서 직접 단일출구로 수렴시킨다.
        return Left(BadRequestResponse(errorType: 'unknown', msg: 'unexpected error body', isShow: true));
      }
    }
```

- [ ] **Step 3: 골든 직후 산문 불변식 추가**(:42 역할 계약 bullet 다음·골든 코드블록 직전 또는 직후):
  > **에러바디 정규화기(`fromJson`)도 throw할 수 있다** — 대상 서버 봉투가 골든 가정과 다르면(필수 필드 누락 등) `fromJson`이 `TypeError`를 던진다. 그 호출은 *이미 `on DioException` 절 내부*라 **형제 `on TypeError`는 물론 맨 끝 `catch (e)` catch-all도 못 잡는다**(Dart: 진입한 catch 절 내부의 새 예외는 같은 try의 다른 on절·catch-all로 가지 않고 바깥으로 전파) → `safeApiCall` 밖으로 샌다 = 단일출구 누수. 그래서 `fromJson` 호출만 try/on Object로 감싸 그 throw도 `Left`로 수렴시킨다. (:42 "대상 서버 봉투에 맞춰 `fromJson` 조정"은 *설계 시점* 대응이고, 이 가드는 *런타임 throw* 대응 — 둘은 보완.)

- [ ] **Step 4: 검증** — Run: `grep -nE 'try \{|on Object \{|정규화기 자신이 throw|unexpected error body|catch-all도 못 잡는다' dddart/skills/architecture-data/references/final.md` → 골든 가드 + 불변식 산문 present. Run: `grep -c 'on TypeError catch' dddart/skills/architecture-data/references/final.md` → 1 유지(형제 절 보존).

### Task 2: catch 위생 조항에 파서 2차 throw 단서 (`implementation-dart/references/final.md`)

**Files**: Modify `dddart/skills/implementation-dart/references/final.md` (:49 safeApiCall 광범위 catch 조항).

- [ ] **Step 1: 앵커 확인** — Run: `grep -n 'safeApiCall의 광범위 catch' dddart/skills/implementation-dart/references/final.md` → 1 매치(L49).

- [ ] **Step 2: :49 조항 끝(`Error 구현체는 프로그래밍 오류에만 던진다.` 직후)에 단서 1문장 추가:**
  > 단 **`safeApiCall`의 catch 절 *내부*에서 호출하는 파서(`fromJson` 등)의 2차 throw는 그 단일 경계가 못 잡는다** — 진입한 on절 내부의 새 예외는 형제 on절·말미 catch-all로 가지 않아 `safeApiCall` 밖으로 샌다. 정규화기 호출은 자체 try/catch로 감싸 그 throw도 `Left`로 수렴시킨다(architecture-data §2 골든).

- [ ] **Step 3: 검증** — Run: `grep -nE 'catch 절 \*내부\*에서 호출하는 파서|2차 throw' dddart/skills/implementation-dart/references/final.md` → present.

---

## 작업 C — screenProbes green 경로 강제 (측정·코퍼스)

> **★렌즈 3 핵심**: render-smoke는 **`_support.dart`(헬퍼)가 아니라 별도 `*_test.dart`**에 둬야 `flutter test`가 수집·실행한다. + `isNotEmpty` 가드로 빈 맵 도망 차단. 저장소 정답 패턴 = `dump_probe.dart.txt`(별도 `*_test.dart`가 `_support.dart` import).

### Task 3: coder.md screenProbes + render_smoke_test 필수 산출 (`agents/coder.md`)

**Files**: Modify `dddart/agents/coder.md` (:35 행위 검증 테스트 묶음).

**Interfaces**:
- Produces: coder가 슬라이스마다 (a) `test/<bc>/_support.dart`에 `screenProbes` 맵 노출 + (b) 별도 `test/<bc>/render_smoke_test.dart`에 그 맵을 소비하는 render-smoke 테스트(`isNotEmpty` + role별 `findsOneWidget`) 작성 → green 래칫이 screenProbes 존재·비어있지 않음을 강제.

- [ ] **Step 1: 앵커 확인** — Run: `grep -n '행위 검증 테스트(필수 산출)' dddart/agents/coder.md` → 1 매치(L35). Run: `grep -c 'screenProbes' dddart/agents/coder.md` → **0**.

- [ ] **Step 2: :35 bullet 끝(`discipline-reviewer FORM-감사 대상).` 직후·신규 문장)에 추가:**
  > **screenProbes + render-smoke 테스트(필수 산출)**: `test/<bc>/_support.dart`에 화면 role→펌프+루트 finder 맵(`screenProbes`·implementation-test §7)을 노출하고, **별도 `test/<bc>/render_smoke_test.dart`**(헬퍼가 아니라 `*_test.dart`라야 `flutter test`가 수집한다 — `_support.dart`에 `main`을 두면 실행되지 않는다)에서 `_support.dart`를 import해 ⓐ `expect(screenProbes, isNotEmpty)` ⓑ 각 role을 펌프해 `findsOneWidget`을 단언한다(implementation-test §7 형태). 이 단언들이 `screenProbes`를 *소비*하므로 누락·빈 맵이면 `flutter test`가 red = green 래칫이 차단 — FID 평가측 진입점이 green 경로로 강제된다(누락 시 fid-gate A1 폴백·❌ 도장 금지·RUBRIC §H). 기존 `pumpList`/`pumpDetail` 위에 얇게 얹는다(중복 펌프 정의 금지).

- [ ] **Step 3: 검증** — Run: `grep -nE 'render_smoke_test.dart|isNotEmpty|green 경로로 강제' dddart/agents/coder.md` → present. Run: `grep -c 'screenProbes' dddart/agents/coder.md` → ≥1.

### Task 4: implementation-test §7 render-smoke 별도 파일 + isNotEmpty (`implementation-test/references/final.md`)

**Files**: Modify `dddart/skills/implementation-test/references/final.md` (:135 산문 + :145 예시 직후).

- [ ] **Step 1: 앵커 확인** — Run: `grep -n '유일하게 discipline-test FORM이 직접 소비하지 않는' dddart/skills/implementation-test/references/final.md` → 1 매치(L135).

- [ ] **Step 2: :135 산문 수정** — "단언이 부르지 않음" → "별도 render-smoke 테스트 파일이 소비".

old(:135 첫 문장):
```
`screenProbes`는 §7에서 **유일하게 discipline-test FORM이 직접 소비하지 않는** 헬퍼다(테스트 단언이 부르지 않음) — eval FID 평가측 렌더 덤프가 이 한 맵만 상대 import해 산출물의 모든 화면을 *배선 추론 0*으로 일관 덤프한다.
```
new:
```
`screenProbes`는 discipline-test §3 FORM이 직접 부르지는 않지만 **별도 render-smoke 테스트 파일(`render_smoke_test.dart`)이 직접 소비한다**(아래) — 그 단언이 맵을 펌프하므로 `screenProbes` 미작성·빈 맵이면 green이 깨진다(coder 필수 산출·green 경로 강제). 이 render-smoke는 *헬퍼(`_support.dart`)가 아니라 `*_test.dart`*라야 `flutter test`가 수집·실행한다. eval FID 평가측 렌더 덤프도 이 한 맵만 상대 import해 산출물의 모든 화면을 *배선 추론 0*으로 일관 덤프한다.
```

- [ ] **Step 3: :145(screenProbes 맵 예시 코드블록 닫는 `};`) 직후에 render-smoke 테스트 파일 예시 추가:**
```dart

// test/<bc>/render_smoke_test.dart — 헬퍼가 아니라 *_test.dart라야 flutter test가 수집한다.
// 단언이 screenProbes를 소비해 green 경로로 강제(coder.md 필수 산출).
import 'package:flutter_test/flutter_test.dart';
import '_support.dart';

void main() {
  test('screenProbes는 화면을 등록한다(비어있지 않음)', () {
    expect(screenProbes, isNotEmpty); // 빈 맵 도망 차단(forEach 0회 green 방지)
  });
  screenProbes.forEach((String role, ScreenProbe probe) {
    testWidgets('renders $role', (WidgetTester tester) async {
      expect(await probe(tester), findsOneWidget);
    });
  });
}
```
+ 코드블록 직후 1줄: "`screenProbes`를 `_support.dart`(헬퍼·import 대상)에 정의하고 이 `main`은 별도 `render_smoke_test.dart`에 둔다 — `_support.dart`의 `main`은 `flutter test`가 호출하지 않는다(저장소 `dump_probe.dart.txt`와 동일 패턴)."

- [ ] **Step 4: 검증** — Run: `grep -nE "render-smoke 테스트 파일.*직접 소비|render_smoke_test.dart|expect\(screenProbes, isNotEmpty\)" dddart/skills/implementation-test/references/final.md` → present.

### Task 5: SKILL.md §7 라우팅 + RUBRIC §H 미세 보강

**Files**: Modify `dddart/skills/implementation-test/SKILL.md` (:29) · `workspace/eval/rubric/RUBRIC.md` (:138).

- [ ] **Step 1: SKILL.md :29 앵커 확인·갱신** — Run: `grep -n 'eval FID 렌더 덤프가 소비하는 화면 진입점 맵' dddart/skills/implementation-test/SKILL.md`. 그 문장에 render-smoke 소비 절 삽입:
  > `screenProbes`만 예외로 FORM이 아니라 **별도 render-smoke 테스트(`render_smoke_test.dart`·§7)와 eval FID 렌더 덤프가 소비**하는 화면 진입점 맵이다(view·헬퍼 이름을 맵 안에 가둬 프로브가 BC 이름에 비의존·green 경로 강제) (§7)

- [ ] **Step 2: RUBRIC §H:138 미세 보강** — Run: `grep -n '산출물이' workspace/eval/rubric/RUBRIC.md`로 `산출물이 \`screenProbes\`를 노출하지 않으면` 문장 찾아, 끝에 1절 추가:
  > — coder.md가 screenProbes + 별도 `render_smoke_test.dart`(isNotEmpty + role별 단언)를 **필수 산출**로 강제하므로(green 경로), 미노출은 단순 측정 불능이 아니라 **코더 픽스처 흠**(반복 시 산출물 품질 결함으로 결과지 명기)이다. coordinator는 A1 폴백을 "정상 면제"로 읽지 말고 흠으로 기록한다. (exit-3의 *기계* BLOCKER 격상은 작업 B 측정 재설계 회차에서 검토 — 이번엔 green 강제 + 이 산문이 1·2차 방어.)

- [ ] **Step 3: 검증** — Run: `grep -c 'render_smoke_test' dddart/skills/implementation-test/SKILL.md` → ≥1. Run: `grep -c '코더 픽스처 흠' workspace/eval/rubric/RUBRIC.md` → 1.

---

## 작업 D — 미러 + 정합성 스윕

### Task 6: final.md 양판 동기 (`corpus_mirror_sync.py --write`)

**Files**: 자동 — `workspace/reference/{architecture-data,implementation-dart,implementation-test}/reference/final.md`(소스) + `codex-dddart/skills/{...}/references/final.md`(codex).

- [ ] **Step 1: 동기 실행** — Run: `python3 workspace/tools/corpus_mirror_sync.py --write`.
- [ ] **Step 2: drift 0 확인** — Run: `python3 workspace/tools/corpus_mirror_sync.py --check` → exit **0**.
- [ ] **Step 3: 3사본 앵커** — Run: `grep -rl 'unexpected error body' dddart/ codex-dddart/ workspace/reference/` → architecture-data 3사본. Run: `grep -rl 'render_smoke_test.dart' dddart/ codex-dddart/ workspace/reference/` → implementation-test 3사본. Run: `grep -rl '2차 throw' dddart/ codex-dddart/ workspace/reference/` → implementation-dart 3사본.

### Task 7: codex 수동 미러 — coder·SKILL (`codex-dddart/skills/`)

**Files**: Modify `codex-dddart/skills/dddart-coder/SKILL.md` · `codex-dddart/skills/implementation-test/SKILL.md`. (`agents/`·`SKILL.md`는 `--write` 비대상 → 수동.)

- [ ] **Step 1: coder 등가** — `dddart-coder/SKILL.md`에서 Task 3 등가(screenProbes + 별도 `render_smoke_test.dart` 필수 산출·isNotEmpty). codex 행위 테스트 묶음 앵커 위치 찾아 동형 삽입. Run: `grep -c 'render_smoke_test' codex-dddart/skills/dddart-coder/SKILL.md` → ≥1.
- [ ] **Step 2: impl-test SKILL 등가** — `codex-dddart/skills/implementation-test/SKILL.md`에서 Task 5 Step1 등가(render-smoke 별도파일 소비 절). Run: `grep -c 'render_smoke_test' codex-dddart/skills/implementation-test/SKILL.md` → ≥1.
- [ ] **Step 3: 양판 대칭 확인** — claude↔codex 개념 대칭(문구 엔진별 상이 허용). coder 산출 앵커·impl-test §7 render-smoke 양쪽 present.

### Task 8: 최종 정합성 스윕 + measure-first 사전등록 (양 엔진)

**Files**: 읽기 전용 검증 + fix 원장 사전등록.

- [ ] **Step 1: DT-2 양판** — Run: `grep -rc 'on Object {' dddart/skills/architecture-data codex-dddart/skills/architecture-data workspace/reference/architecture-data` → 3사본 ≥1. `on TypeError catch` 보존 확인.
- [ ] **Step 2: screenProbes 양판** — coder(claude `agents/coder.md` + codex `dddart-coder/SKILL.md`) + impl-test(final 3사본 + SKILL 2판) render-smoke·isNotEmpty 앵커 전수 present.
- [ ] **Step 3: 측정 도구 불변 가드** — Run: `git diff --stat`에 `workspace/eval/`·`dddart/scripts/extract_layout.dart` **없음** 확인(image 측정 불가침·작업 B 후속). 변경은 코퍼스 markdown + RUBRIC.md만.
- [ ] **Step 4: 값 운반 무변경** — design-tokens/size-link/asset-manifest 앵커 양판 존속(`grep -c 'arbitraryValues\|asset-manifest\|app_asset' …` 변동 없음).
- [ ] **Step 5: fix 원장 사전등록** — `workspace/eval/fix/feedback-016-fid-measurement-dt2.md` 신설(TEMPLATE 복사). 설계 §7 사전등록표(image 행 제외):

  | 항목 | 전(14차) | 후 기대 | 측정 |
  |---|---|---|---|
  | DT-2 | claude 무가드 FAIL·N=2 swap | 양 엔진 가드 PASS·404 바디 불일치 누수 0 | 골든 정독 + safeApiCall 의미 |
  | screenProbes | 양 엔진 미노출·6회 A1 폴백 | 양 엔진 `_support.dart`+`render_smoke_test.dart` 노출·fid-gate exit≠3 실발동 | `find render_smoke_test.dart`·`grep screenProbes`·fid-gate exit |

- [ ] **Step 6: 보고** — 변경 파일 목록(diff stat) + 앵커 검증 결과 + "측정 도구/값운반 불변·image=작업 B 후속" 1줄 + measure-first 사전등록 경로. **커밋은 사용자 요청 시·다음 런 동결.**

---

## Self-Review (작성자 점검)

- **Spec 커버리지**: 설계 §2(DT-2)=Task 1·2·6 / §3(screenProbes)=Task 3·4·5·6·7 / §6 시술 순서(DT-2→screenProbes·image 제외)=작업 A→C / §7 measure-first=Task 8 Step5. **설계 §4(image)는 작업 B로 분리**(사용자 결정·§분리 근거에 명기). 설계 §3-3(fid-gate BLOCKER 격상)은 green 강제로 대체·exit 격상은 B 회차 보류(Task 5 Step2 명기).
- **적대 검증 반영**: 렌즈 2 MINOR(catch-all 근거)=Task 1 Step2·3. 렌즈 3 BLOCKER 1·2(render-smoke 별도 `*_test.dart`+isNotEmpty)=Task 3·4 전체. 렌즈 3 MAJOR(exit 격상)=Task 5 Step2 보류 명기. 렌즈 4(정직 표기)=§적대 검증 반영·§분리 근거.
- **Placeholder**: 없음 — 각 편집에 앵커 grep + 실제 old/new 코드·문구 인라인.
- **타입/앵커 일관**: `ScreenProbe` typedef는 §7 기존 정의 재사용(Task 4 main `(String role, ScreenProbe probe)`). render-smoke `main`은 **별도 `render_smoke_test.dart`**에 둠(Task 3·4·7 전부 동일 파일명·`_support.dart`와 구분 일관). `import '_support.dart'` 상대 경로(저장소 `dump_probe.dart.txt` 패턴).
- **순서/의존**: 코퍼스 편집(1·2·3·4·5) → final 자동미러(6) → codex 수동(7) → 스윕(8). 도구 변경 0 → positive-control 게이트 불요(green 강제는 다음 런 라이브런서 실증). DT-2(A)는 코어 무관·먼저.
- **불가침 가드**: 모든 측정 도구 = Global Constraint + Task 8 Step3 명시 검증(`git diff`에 `workspace/eval/`·`extract_layout.dart` 없음).

## 실행 핸드오프

plan 저장: `workspace/design/2026-06-22-fid-measurement-dt2-plan.md`(작업 A·C). 시술 전 **별도 사용자 승인** 필요(코퍼스 불변 방침·다음 런 동결). 두 실행 옵션:
1. **Inline**(권장) — 이 세션·작업 A→C→D 체크포인트(코퍼스 편집은 앵커 grep 결정적·양판 미러 검증을 메인이 직접).
2. **Subagent-Driven** — Task별 fresh subagent + 단계 사이 리뷰.
