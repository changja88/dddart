# 이미지 충실도 — 생성측 유도 + 측정 제외 (구현 plan)

> **For agentic workers**: 코퍼스 markdown(§9) + eval 도구(compare/run.sh/schema/RUBRIC/EVAL) 혼합 plan. "테스트 사이클"은 작업류별로 다르다 — **§9 편집** = 앵커 grep→편집→앵커 grep→`--write` 미러. **compare 편집** = 편집→`dart analyze`→**positive-control 재검**(Task 3)이 게이트. **문서(schema/RUBRIC/EVAL)** = 앵커 grep→scrub→grep(image 잔존 0). 단계는 `- [ ]` 체크박스. REQUIRED SUB-SKILL: superpowers:subagent-driven-development 또는 executing-plans.

**Goal**: 이미지 충실도(위치·존재)를 생성측 §9가 제자리에 그리도록 유도 + 사용자 육안 판정으로 옮기고, FID 게이트에서 image를 제거한다(작업 C로 활성화된 거짓 FAIL 차단).

**Architecture**: 승인된 설계 `2026-06-22-image-fidelity-eye-design.md`(2차 적대 검증 통과) 집행. 생성측=§9 한 구절(coder/architect/review-ui 불변), 측정측=compare가 image를 L1/L2에서 완전 제외 + 스키마 동결 유지(육안 재료) + RUBRIC/EVAL image→L4 이관. image 통째빠짐 자동 미검출=의도(육안)·fetch_images 별도 라운드.

**Tech Stack**: 코퍼스 markdown(`implementation-flutter/references/final.md`) + `corpus_mirror_sync.py` + eval dart/bash(`compare_layout.dart`·`positive-control/fid/fixture/run.sh`·`layout-ir-schema.md`·`RUBRIC.md`·`EVAL-METHOD.md`).

## Global Constraints (모든 Task 암묵 포함)

- **feedback-015 공리**: 코퍼스 레이아웃 어휘 0·**명세(설계서)에 형상/위치 기입 금지**·"닫힌 매핑 표" 금지(§9 예시는 "닫힌 목록 아님" 유지). architect·review-ui **불변**.
- **측정 도구 변경 positive-control 재검 선결**: `compare_layout.dart` 변경(Task 2)은 Task 3(run.sh ⓐⓑ PASS·기존 회귀 0) 통과가 투입 게이트.
- **스키마 노드 트리 동결**: `layout-ir-schema.md` §1 image role/src/alt(`:26·28·38·52`)·§4 예시 image(`:90`) **불변** — extractor가 image area/slot 계속 방출(`ref.json` SoT·육안 재료). §3에 *비교 규칙 주석*만(노드 변경 아님).
- **미러**: `§9`(implementation-flutter final.md) = `corpus_mirror_sync.py --write`(배포→소스+codex 3사본). **compare/run.sh/schema/RUBRIC/EVAL = eval 단일(미러 불요)**. coder.md 불변→수동 미러 없음.
- **앵커 기반**: 라인 번호 아닌 *문구*로 grep(드리프트 대비). 아래 라인은 2026-06-22 기준 참고값.
- **image 통째빠짐 자동 미검출 = 의도**(사용자 확정·육안). 단 coder `render_smoke_test`는 image role 펌프 단언을 유지(픽스처 자기검사·feedback-016)이라 *코더측*엔 image 존재 약신호가 잔존 — `compare` 게이트만 image를 무시한다(모순 아님·smoke=자기검사·compare=시안대조). measure-first 빈틈은 fetch_images 안정화(별도 라운드)가 담보.
- **시술은 별도 승인**·**다음 런 동결**·**커밋은 사용자 요청 시**.

## File Structure

| 파일 | 책임 | 변경 | 미러 |
|---|---|---|---|
| `dddart/skills/implementation-flutter/references/final.md` | §9 형상 규율 | §9에 "`<img>`도 형상" 불릿 1개(괄호 밖) | auto(`--write`) |
| `workspace/eval/tools/compare_layout.dart` | FID 대조 | L1·L2 image 제외 + 헤더 doc 1구 | eval 단일 |
| `workspace/eval/tools/positive-control/fid/fixture/run.sh` | 거짓-FAIL 반증 | ⓐⓑ 상주 케이스 2개 | eval 단일 |
| `workspace/eval/tools/layout-ir-schema.md` | 동결 스키마 | §3에 비교 규칙 주석 1줄(노드 불변) | eval 단일 |
| `workspace/eval/rubric/RUBRIC.md` | §H FID 판정 | FID-L1 image scrub(PASS+FAIL)·L4·주의⑥·historical | eval 단일 |
| `workspace/eval/rubric/EVAL-METHOD.md` | 채점 집행 | FID-L1 `:129` image scrub·`:162`·historical `:125` | eval 단일 |

---

## 작업 A — 생성측: §9에 "`<img>`도 형상" (코어 무관·먼저)

### Task 1: §9 이미지 위치 불릿 추가 (`implementation-flutter/references/final.md`)

**Files**: Modify `dddart/skills/implementation-flutter/references/final.md` (§9 불릿 목록 끝).

**Interfaces**:
- Produces: §9가 `<img>`의 컨테이너 내 위치·순서를 형상의 일부로 명시(괄호 밖 별도 불릿) → coder가 §9 읽을 때 image 위치 포함 인지. 명세 무기입·닫힌 표 아님.

- [ ] **Step 1: 앵커 현존 확인** — Run: `grep -nE '## §9. 레이아웃 형상|형상은 명세가 아니라 시안 소관' dddart/skills/implementation-flutter/references/final.md` → §9 제목 + 마지막 불릿(`:247`) present.

- [ ] **Step 2: §9 마지막 불릿(`:247` "형상은 명세가 아니라 시안 소관") 뒤에 새 불릿 추가:**

old(`:247`):
```
- **형상은 명세가 아니라 시안 소관**: 명세 화면 절에 축·배치가 없는 것은 정상이다(architecture-ui §8) — 반송하지 말고 시안에서 형상을 가져온다.
```
new(불릿 1개 추가):
```
- **형상은 명세가 아니라 시안 소관**: 명세 화면 절에 축·배치가 없는 것은 정상이다(architecture-ui §8) — 반송하지 말고 시안에서 형상을 가져온다.
- **이미지(`<img>`)도 형상의 일부**: `<img>`의 컨테이너 내 위치·형제 순서도 시안 그대로 재현한다. §8(에셋)이 *무엇을 어떤 토큰으로* 가져올지 정하고, *어디에 놓일지*는 이 형상 규율(시안 `<img>` 자리)이 정한다 — 배선만 하고 시안 위치를 흘리지 않는다. (별도 매핑 표 아님 — 시안 재현 의무의 명시.)
```

- [ ] **Step 3: 검증** — Run: `grep -nE '이미지\(`<img>`\)도 형상의 일부|어디에 놓일지는 이 형상 규율' dddart/skills/implementation-flutter/references/final.md` → present. Run: `grep -c '닫힌' dddart/skills/implementation-flutter/references/final.md` → §9:245 "닫힌 목록 아님" 보존 확인(공리). 새 불릿이 괄호 밖 standalone인지 육안(괄호 중첩 0).

---

## 작업 B — 측정측: FID 게이트에서 image 제외 (positive-control 선결)

### Task 2: compare_layout image 제외 (`workspace/eval/tools/compare_layout.dart`)

**Files**: Modify `workspace/eval/tools/compare_layout.dart` (L1 `:58-59`·`_flattenSlots` `:144-154`·헤더 doc `:7`).

**Interfaces**:
- Consumes: `_areas(screen)` role 시퀀스·section `_flattenSlots`. 스키마 불변.
- Produces: L1 role 시퀀스·L2 평탄화에서 image 제거(총수 비교 안 함). image 통째빠짐·위치 차이 모두 게이트 통과(육안).

- [ ] **Step 1: 편집 전 baseline** — Run: `bash workspace/eval/tools/positive-control/fid/fixture/run.sh` → 현 7케이스 결과 기록(편집 후 회귀 대조).

- [ ] **Step 2: L1 role 시퀀스에서 image 제외.**

old(`:57-59`):
```dart
    // ---- L1: 영역 골격 ----
    final refRoles = _areas(r).map((Map<String, dynamic> a) => a['role'] as String).toList();
    final gotRoles = _areas(g).map((Map<String, dynamic> a) => a['role'] as String).toList();
```
new:
```dart
    // ---- L1: 영역 골격 (image 제외 — 위치=생성측 §9·측정=L4 육안) ----
    final refRoles = _areas(r).map((Map<String, dynamic> a) => a['role'] as String).where((String x) => x != 'image').toList();
    final gotRoles = _areas(g).map((Map<String, dynamic> a) => a['role'] as String).where((String x) => x != 'image').toList();
```

- [ ] **Step 3: L2 `_flattenSlots` 단일 emit point에서 image 제외.**

old(`:144-154`):
```dart
List<String> _flattenSlots(List<Map<String, dynamic>> slots) {
  final out = <String>[];
  for (final s in slots) {
    if (s['type'] == 'group') {
      out.addAll(_flattenSlots((s['slots'] as List? ?? const <dynamic>[]).cast<Map<String, dynamic>>()));
    } else {
      out.add(s['type'] as String);
    }
  }
  return _collapse(out);
}
```
new:
```dart
List<String> _flattenSlots(List<Map<String, dynamic>> slots) {
  final out = <String>[];
  for (final s in slots) {
    if (s['type'] == 'group') {
      out.addAll(_flattenSlots((s['slots'] as List? ?? const <dynamic>[]).cast<Map<String, dynamic>>()));
    } else if (s['type'] != 'image') {
      out.add(s['type'] as String); // image는 게이트 비교 제외(위치=§9·L4 육안)
    }
  }
  return _collapse(out);
}
```

- [ ] **Step 4: 헤더 doc L1 설명에 image 제외 표기.**

old(`:7`):
```
///   L1(골격): areas role 시퀀스(존재·종류·순서).
```
new:
```
///   L1(골격): areas role 시퀀스(존재·종류·순서·image 제외[위치=§9·L4 육안]).
```

- [ ] **Step 5: analyze green** — Run: `cd workspace/eval/tools && dart analyze compare_layout.dart` → "No issues found".

### Task 3: positive-control 재검 + ⓐⓑ 상주 (`positive-control/fid/fixture/run.sh`)

**Files**: Modify `workspace/eval/tools/positive-control/fid/fixture/run.sh` (등가 PASS 그룹에 ⓐⓑ 추가). 기존 A·C·D·G·E·F·"L1 영역누락" 7케이스 보존.

**Interfaces**:
- Consumes: `ref.json`(area image top-level·list repeat·hero blocks). `check label transform expected-exit note`.
- Produces: ⓐ 섹션 내부 image(area→slot) → PASS · ⓑ 다른 섹션 image → PASS · 기존 7케이스 회귀 0.

- [ ] **Step 1: ⓐⓑ 케이스 추가** — `:37`("G hero text 흡수" check) 다음 줄에 삽입:
```bash
check "ⓐ image 섹션내부" "img=next(a for a in areas if a['role']=='image'); areas.remove(img); sec('hero')['children'].append({'kind':'block','slots':[{'type':'image'}]})"  0  "image area→hero slot(area↔slot 레벨 차이)·image 제외로 PASS"
check "ⓑ image 다른섹션" "img=next(a for a in areas if a['role']=='image'); areas.remove(img); sec('list')['children'].insert(0,{'kind':'block','slots':[{'type':'image'}]})"  0  "image area→list slot(위치 차이)·image 제외로 PASS"
```

- [ ] **Step 2: 실행·예상 대조** — Run: `bash workspace/eval/tools/positive-control/fid/fixture/run.sh`. 검증:
  - **ⓐ·ⓑ exit 0(PASS)** — image 위치만 다른데 통과(거짓 FAIL 0).
  - **기존 7케이스 = Step 1 baseline 동일**: A·C·D·G PASS·E·F·"L1 영역누락" FAIL(특히 "L1 영역누락"은 image+bottomnav 제거 → **bottomnav로 여전히 exit 2** 정탐 유지·image 제외 무영향).
  - 최종 `✅ 거짓-FAIL 0` + `exit 0`(FAIL=0).
  - 어긋나면 Task 2 보정 후 재실행. **ⓐⓑ PASS + 기존 회귀 0이라야 compare 변경 투입 확정.**

### Task 4: schema §3 비교 규칙 주석 (`layout-ir-schema.md`)

**Files**: Modify `workspace/eval/tools/layout-ir-schema.md` (§3 `:69-77`·노드 트리 불변).

- [ ] **Step 1: 앵커 확인** — Run: `grep -n 'L2 게이트 비교 시:' workspace/eval/tools/layout-ir-schema.md` → `:71` present.

- [ ] **Step 2: §3 "L2 게이트 비교 시:" 항목 끝(`:77` 예시 줄 뒤)에 주석 1줄 추가:**
  > **image는 L1/L2 게이트 비교에서 제외**(위치=생성측 형상 §9·측정=FID-L4 육안·2026-06-22). extractor·dump는 image area/slot을 *계속 방출*(노드 트리 §1 동결·`ref.json` SoT·육안 대조 재료)하고 `compare_layout`만 게이트 시퀀스에서 무시한다.

- [ ] **Step 2.5: §5 `:114` historical 표지**(적대 리뷰 Q5 보정) — `:114`("area image ❌ FID-L1 대상 — 코드에 Image 노드 없음") 현재시제 단정에 "(현재 image는 L4 육안 이관·2026-06-22 — §5는 8차 설계 예시)" 단서 추가. L1 scrub 후 compare 동작과 정합. Run: `grep -n 'area image.*FID-L1 대상' workspace/eval/tools/layout-ir-schema.md` → `:114` 앵커 확인.

- [ ] **Step 3: 검증** — Run: `grep -nE 'image는 L1/L2 게이트 비교에서 제외' workspace/eval/tools/layout-ir-schema.md` → present. Run: `grep -cE '"appbar" \| "image" \| "section"|image.*전용' workspace/eval/tools/layout-ir-schema.md` → 노드 정의(`:26·28`) **보존**(동결).

### Task 5: RUBRIC §H FID-L1 image scrub (`RUBRIC.md`)

**Files**: Modify `workspace/eval/rubric/RUBRIC.md` (§H `:142`·`:145`·`:147`·historical `:137`).

- [ ] **Step 1: 앵커 확인** — Run: `grep -n 'FID-L1.*구조 골격\|FID-L4.*픽셀' workspace/eval/rubric/RUBRIC.md` → `:142`·`:145`.

- [ ] **Step 2: `:142` FID-L1 행 PASS+FAIL 양쪽 image 제거.**

old(`:142`):
```
| **FID-L1** 구조 골격 충실도 | 화면 영역(appbar/image/section/bottomnav)의 존재·종류·순서가 시안과 일치 | schema §1·§2(번역표)·§5 | 시안 layout-ir `areas`의 role 집합·순서가 렌더 덤프와 일치(영역 누락·종류오인·순서변경 0) | image·bottomnav·section 등 영역 누락, 종류 오인(section↔appbar), 순서 뒤바뀜 | 결정(대조 도구) | ✅(활성·9차 첫 운용) |
```
new(image 2곳 제거):
```
| **FID-L1** 구조 골격 충실도 | 화면 영역(appbar/section/bottomnav)의 존재·종류·순서가 시안과 일치 | schema §1·§2(번역표)·§5 | 시안 layout-ir `areas`의 role 집합·순서가 렌더 덤프와 일치(영역 누락·종류오인·순서변경 0) | bottomnav·section 등 영역 누락, 종류 오인(section↔appbar), 순서 뒤바뀜 | 결정(대조 도구) | ✅(활성·9차 첫 운용) |
```

- [ ] **Step 3: `:145` FID-L4 행에 이미지 추가 + `:147` 주의 ⑥ 추가.**

`:145` old `| **FID-L4** 픽셀·미관 | 패딩·정렬 정확값·그림자·실제 색·아이콘 심볼·미관 |` → 항목 칸에 "**이미지 존재·위치**·" 선두 추가: `| **FID-L4** 픽셀·미관 | **이미지 존재·위치**·패딩·정렬 정확값·그림자·실제 색·아이콘 심볼·미관 |`.

`:147` FID 주의 끝(⑤ 다음)에 ⑥ 추가:
  > ⑥ **이미지 존재·위치는 L4 육안**(생성측 §9가 시안 자리에 재현 유도·fetch_images 담보)·L1/L2 비측정(2026-06-22) — image area↔slot 레벨 차이가 거짓 FAIL을 내던 것을 제거. "통째 빠짐"도 자동 미검출(육안·fetch_images 별도).

- [ ] **Step 4: historical `:137` 시점 표지** — Run: `grep -n '8차.*image\|image 누락.*통과' workspace/eval/rubric/RUBRIC.md`로 §H 성격 서술(`:137` "8차에서 image·bottomnav 누락…기능 PASS로 통과") 찾아, 그 문장에 "(현재 image는 L4 육안 이관·2026-06-22)" 단서 1구 추가(historical 보존·stale 표지).

- [ ] **Step 5: 검증** — Run: `grep -c 'appbar/image/section\|image·bottomnav·section 등 영역 누락' workspace/eval/rubric/RUBRIC.md` → **0**(FID-L1 image scrub). Run: `grep -c '이미지 존재·위치는 L4 육안' workspace/eval/rubric/RUBRIC.md` → 1.

### Task 6: EVAL-METHOD FID-L1 image scrub (`EVAL-METHOD.md`)

**Files**: Modify `workspace/eval/rubric/EVAL-METHOD.md` (`:129`·`:162`·historical `:125`).

- [ ] **Step 1: 앵커 확인** — Run: `grep -n 'role 집합·종류·순서 일치(image·bottomnav 포함)' workspace/eval/rubric/EVAL-METHOD.md` → `:129` present.

- [ ] **Step 2: `:129` FID-L1 PASS 신호 image scrub.**

old(`:129` PASS 칸): `role 집합·종류·순서 일치(image·bottomnav 포함)` → new: `role 집합·종류·순서 일치(bottomnav 포함·image는 L4 육안 이관)`.

- [ ] **Step 3: `:162` 시각 충실도 단락에 image=L4 1줄** — Run: `grep -n '시각/디자인 충실도 — 구조는 FID' workspace/eval/rubric/EVAL-METHOD.md`로 `:162` 찾아, "(미관) 픽셀·간격…(L4)" 나열에 "**이미지 존재·위치**" 추가(미관 L4 군에 합류): "…전체 미관·**이미지 존재·위치**(L4)…".

- [ ] **Step 4: historical `:125`·`:135` 시점 표지**(적대 리뷰 전수 보정) — `:125`("8차 실측: L1 image/bottomnav 갭 결정론 포착") *및* `:135`(§2.3 A' 박스 "8차 실측: L1 image/bottomnav 갭 포착") **둘 다**에 "(image는 2026-06-22 L4 육안 이관·아래 FID-L1은 bottomnav/section만)" 단서 추가(표지 일관성). Run: `grep -n '8차 실측: L1 image/bottomnav' workspace/eval/rubric/EVAL-METHOD.md` → `:125`·`:135` 두 줄 확인.

- [ ] **Step 5: 검증** — Run: `grep -c 'image·bottomnav 포함' workspace/eval/rubric/EVAL-METHOD.md` → **0**. Run: `grep -c 'image는 L4 육안 이관' workspace/eval/rubric/EVAL-METHOD.md` → ≥1. **치명 20 불변 확인**: `grep -c '치명 20\|18→20\|18 + FID' workspace/eval/rubric/EVAL-METHOD.md` 변동 없음(FID-L1·L2 항목 자체는 게이트 유지).

---

## 작업 C — 미러 + 정합성 스윕

### Task 7: §9 양판 동기 (`corpus_mirror_sync.py --write`)

**Files**: 자동 — `workspace/reference/implementation-flutter/reference/final.md`(소스) + `codex-dddart/skills/implementation-flutter/references/final.md`(codex).

- [ ] **Step 1: 동기 실행** — Run: `python3 workspace/tools/corpus_mirror_sync.py --write`.
- [ ] **Step 2: drift 0** — Run: `python3 workspace/tools/corpus_mirror_sync.py --check` → exit **0**.
- [ ] **Step 3: 3사본 앵커** — Run: `grep -rl '이미지(`<img>`)도 형상의 일부' dddart/ codex-dddart/ workspace/reference/` → implementation-flutter 3사본(배포·codex·소스).

### Task 8: 최종 정합성 스윕 + measure-first 사전등록

**Files**: 읽기 전용 검증 + fix 원장.

- [ ] **Step 1: 생성측 불변 가드(★델타 기반·적대 리뷰 MAJOR 보정)** — `git status`는 *누적* 상태라 feedback-016 DT-2 in-flight 변경(coder.md screenProbes·architecture-data/implementation-dart/implementation-test final.md·RUBRIC §H header·codex 미러)이 이미 dirty다. 따라서 **clean 단언 금지** — 시술 직전 baseline 스냅샷(`git status --short > $TMP/before.txt`) 대비 **이 회차가 *추가로* 건드린 파일**에만 `coder.md`·`design-architect.md`·`design-review-ui.md`·`dddart-coder/SKILL.md` **없음** 확인(`comm`/diff로 before↔after 델타). in-flight dirty는 이 가드 대상 아님.
- [ ] **Step 2: 측정 스키마 노드 불변** — Run: `git diff workspace/eval/tools/layout-ir-schema.md` → §1 노드(role/src/alt) 변경 0·§3 주석만. extractor(`dddart/scripts/extract_layout.dart`)·`dump_to_ir.dart` **clean**(image area 계속 방출).
- [ ] **Step 3: image scrub 완전성** — Run: `grep -rn 'appbar/image/section\|image·bottomnav 포함\|image·bottomnav·section 등' workspace/eval/rubric/` → **0**(RUBRIC·EVAL FID-L1에서 image 제거 완료). historical 라인은 시점 표지 보유.
- [ ] **Step 4: 변경 파일 일치(★델타 기반)** — *이 회차 델타*(baseline 대비 before↔after)가 plan File Structure = implementation-flutter final.md **3사본**(배포+소스+codex) + compare/run.sh/schema/RUBRIC/EVAL **5** = **8파일** + 예상 밖 0. ⚠️ `RUBRIC.md`는 feedback-016(§H header)·이 회차(FID-L1 scrub) *양쪽*이 건드리므로 델타에 포함(정상). 그 외 feedback-016 in-flight 14파일은 델타 제외(사전 dirty).
- [ ] **Step 5: fix 원장 사전등록** — `workspace/eval/fix/feedback-017-image-fidelity-eye.md` 신설(TEMPLATE 복사). 사전등록표:

  | 항목 | 전(현재) | 후 기대 | 측정 |
  |---|---|---|---|
  | image 거짓 FAIL | 작업 C로 게이트 켜짐→15차 image=area 거짓 FAIL 위험 | 게이트 image 무시→image 위치 차이 거짓 FAIL 0 | positive-control ⓐⓑ + 다음 런 compare |
  | 이미지 제자리 | §9 image 위치 암묵 | §9 `<img>` 콕 집음→coder 제자리 재현 | 사용자 육안(자동 아님) |

- [ ] **Step 6: 보고** — 변경 파일(diff stat) + 앵커 검증 + "coder/architect/review-ui·스키마 노드·extractor 불변" 1줄 + positive-control ⓐⓑ 결과 + measure-first 경로. **커밋은 사용자 요청 시·다음 런 동결.**

---

## Self-Review (작성자 점검)

- **Spec 커버리지**: 설계 §3(생성측)=Task 1·7 / §4(측정측)=Task 2·3·4·5·6 / §5(육안 명문)=Task 5 Step3 / §6 순서(생성측→측정 positive-control 선결)=작업 A→B / §7 measure-first=Task 8 Step5. 설계 적대 리뷰 MINOR(경로 rubric/·FAIL 컬럼·잔존 단언 전수·ref-layout 폴백·ⓐⓑ 상주) 전부 Task에 반영.
- **Placeholder**: 없음 — 각 편집에 앵커 grep + 실제 old/new(compare 패치·run.sh transform[ref.json 구조 기반]·RUBRIC/EVAL scrub 문구) 인라인.
- **타입/앵커 일관**: compare `_flattenSlots` 단일 emit point(`:150`) 한 곳이 L2 전 경로 방출구(렌즈 2 확증). run.sh transform은 `ref.json` 실구조(area image·sec('list')·sec('hero')) 기반. RUBRIC/EVAL FID-L1 PASS+FAIL 양 컬럼 일관 scrub.
- **순서/의존**: 생성측(1) → compare(2) → positive-control 게이트(3) → schema/RUBRIC/EVAL 문서 정합(4·5·6) → §9 미러(7) → 스윕(8). compare(2) 투입 게이트 = positive-control(3). 미러는 §9만(measure 도구·문서는 eval 단일).
- **공리·불변 가드**: coder/architect/review-ui 불변(Task 8 Step1)·스키마 노드 동결(Step2)·extractor 불변(Step2) = Global Constraint + 명시 검증.

## 실행 핸드오프

plan 저장: `workspace/design/2026-06-22-image-fidelity-eye-plan.md`. 시술 전 **별도 사용자 승인**(코퍼스 불변·다음 런 동결). 두 옵션:
1. **Inline**(권장) — 작업 A→B→C 체크포인트(코퍼스 앵커 grep 결정적·positive-control·미러 검증 직접).
2. **Subagent-Driven** — Task별 fresh subagent + 단계 사이 리뷰.
