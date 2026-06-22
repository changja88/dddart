# FID 측정 봉합 + DT-2 가드 — 설계 (2026-06-22)

> **목적**: 14차 거짓 PASS(측정 미작동)와 DT-2 치명 누수를 닫는다. **이번 회차 = 측정 ①screenProbes 강제 + ③image 위치 + DT-2 가드 골든.**
> **트리거**: 14차 라이브런(사용자 육안 "codex 리스트 다름" ↔ grep "6/6 일치" 거짓 PASS) → FID 실효성 자료조사(`2026-06-22-fid-gate-efficacy-research.md`) → 4렌즈 적대 리뷰.
> **제약**: 결정론 유지 · 양판 미러(claude↔codex) · 코퍼스/도구 변경 별도 승인·다음 런 동결 · 도구 변경은 positive-control 재검 선결 · measure-first 사전등록.
> **근거**: 자료조사(구조 IR 채택 옳음·고치면 실효 2/3 자동) + 적대 리뷰(② 내용확장·2층·간격폰트 후순위 — 결정성 못 지킴·코어 회귀 위험; DT-2는 측정과 직교라 같이).

## 1. 범위 (적대 리뷰 후 확정)

| 포함 (이번) | 제외 (후순위·기록) |
|---|---|
| ① screenProbes 강제 (green 경로) | ② 내용확장 IR(색·텍스트·아이콘·이미지 정체) — 결정성 못 지킴 |
| ③ image area 위치(set-membership) | 간격·폰트 토큰 등가 — 가능하나 다음 |
| DT-2 가드 골든 (생성측) | 도구 사각 3개(repeat 접미사·블록경계 collapse·appbar/nav 슬롯) — 코어 위험·14차 미발현 |
|  | 2층(스크린샷 반자동)·AI 비전·픽셀 비교 — **폐기** |

**셋의 독립성**: DT-2(생성측)·① ③(측정측)은 서로 직교 — 순서 자유, 한 회차에 묶되 시술/검증은 분리.

---

## 2. 작업 1 — DT-2 가드 골든 (생성측)

**현재** (`dddart/skills/architecture-data/references/final.md:46-74` 표준 골격):
```dart
} on DioException catch (e) {
  final data = e.response?.data;
  if (data is Map<String, Object?>) {
    return Left(BadRequestResponse.fromJson(data)); // 무가드 — :56
  }
  ...
} on TypeError catch (e) { return Left(...'parse'...); } // :68 — 형제 절
```

**문제**: `fromJson`(:56)이 봉투 스키마 불일치(서버 4xx가 `{detail:...}` 등 필수 필드 누락)로 `TypeError`를 던지면, 그건 **이미 `on DioException` 절 내부**라 형제 `on TypeError`(:68)가 **못 잡는다**(Dart 시맨틱: 진입한 catch 절 내부의 새 예외는 같은 try의 다른 on절로 안 감) → `safeApiCall` 밖 탈출 = 단일출구 누수. grep `throw` 0이라 백스톱은 PASS(결정 레인 무력). N=2 swap(codex 13차·claude 14차).

**처방** — :56을 try/catch로 가드:
```dart
if (data is Map<String, Object?>) {
  try {
    return Left(BadRequestResponse.fromJson(data)); // 서버 에러 바디 그대로 — isShow도 서버 값
  } on Object {
    // 정규화기 자신이 throw(봉투 스키마 불일치) — catch 절 내부 throw는 형제 on절이 못 잡으므로
    // 여기서 직접 단일출구로 수렴시킨다.
    return Left(BadRequestResponse(errorType: 'unknown', msg: 'unexpected error body', isShow: true));
  }
}
```
+ **산문 불변식 1줄**(골든 직전/직후): "에러바디 정규화기(`fromJson`)도 throw할 수 있다 — catch 절 *내부*의 throw는 형제 on절이 못 잡고 단일출구 밖으로 샌다. 정규화기 호출을 try/catch로 감싸 그 throw도 `Left`로 수렴시킨다." (현 :44 "대상 서버 봉투에 맞춰 fromJson 조정"은 *설계 시점* 대응만 다뤄 *런타임 throw*를 비워둠 → 이 공백을 메움.)

**보조**: `implementation-dart/references/final.md`의 "safeApiCall 한 곳만 광범위 catch" 조항에 "catch 절 내부에서 호출하는 파서의 2차 throw가 단일출구를 깬다"는 표기 단서 1줄.

**양판 미러**: `architecture-data` final.md `--write`(소스·codex 동기) + `implementation-dart` final.md `--write`. 산문 변경이라 SKILL/agents 무관. 앵커 grep으로 양판 일치 재확인.

**검증**: 백스톱 무관(코드 예제 텍스트). 다음 런 DT-2 실측 = **양 엔진 PASS**(catch 내부 fromJson 가드 확인·404 바디 불일치 누수 0). 사전등록 성공 기준 = swap 종결(N=2 → 양 엔진 가드).

---

## 3. 작업 2 — screenProbes 강제 (측정·green 경로)

**현재**: `dddart/agents/coder.md`에 screenProbes 0건(grep). `implementation-test §7:135`이 "screenProbes는 **단언이 부르지 않는** 유일 헬퍼"라 명시 → green 래칫이 산출을 강제 안 함 → 9~14차 6회 연속 `_support.dart` 자체 미산출. `fid-gate.sh:54` 부재 시 `exit 3`(A1 폴백 = 도망로).

**뿌리**(적대 L3): 관측되지 않는 산출물은 강제되지 않는다 — coder.md에 적기만으론 7회째 누락 위험. **소비하는 결정적 체크를 green 경로에** 넣어야 한다.

**처방** — 3겹:
1. **coder.md 필수 산출 추가**(:35 행위 검증 테스트 묶음 옆): "**screenProbes + render-smoke 단언(필수 산출)** — `test/<bc>/_support.dart`에 화면 role→펌프+루트 finder 맵(`screenProbes`·implementation-test §7)을 노출하고, **각 role을 펌프해 `findsOneWidget`을 단언하는 render-smoke 테스트**를 작성한다. 이 단언이 screenProbes를 *소비*하므로 누락 시 컴파일/green이 깨진다(= FID 평가측 진입점이 green 경로로 강제됨)."
2. **implementation-test §7에 render-smoke 단언 형태 명시**:
   ```dart
   void main() {
     screenProbes.forEach((role, probe) {
       testWidgets('renders $role', (tester) async {
         expect(await probe(tester), findsOneWidget);
       });
     });
   }
   ```
   §7:135의 "render-smoke 시드를 겸한다"를 *실제 단언*으로 승격(현재는 의도만 서술).
3. **fid-gate.sh + RUBRIC 격상**: `_support.dart`/screenProbes 부재를 `exit 3`(A1 폴백·코더 탓 아님)에서 **코더 표준 pump 규약 위반 = 측정 불능 흠(BLOCKER 신호)**으로 격상. RUBRIC §H에 "screenProbes 미노출 = 코더 규약 위반(픽스처 흠)·A1 도망 금지" 명문.

**양판 미러**: coder.md·implementation-test final.md(`--write`)·implementation-test SKILL.md(수동) = 양판. fid-gate.sh·RUBRIC §H = eval 단일(미러 불요).

**검증**: positive-control = screenProbes 노출본 → green·fid-gate 발동 / 미노출본 → green 깨짐(컴파일) + fid-gate BLOCKER 신호. 다음 런 = **양 엔진 screenProbes 노출 → fid-gate 실제 발동(A1 폴백 0·6회 미해결 봉합)**.

---

## 4. 작업 3 — image area 위치 (측정·거짓 FAIL 방지)

**현재**(`workspace/eval/tools/dump_to_ir.dart:87-90`): `_collectAreas` walk가 `_isSection`을 먼저 매치(:87)하면 그 서브트리로 안 내려가(`_blocks` 처리) → **`*Section` 내부 `Image`는 image area로 승격 안 되고 section 슬롯으로 흡수**. claude가 브로콜리를 `WeeklyForecastSection` 내부에 둠(`weekly_forecast_section.dart:33`·합리적 선택) → 코드 image area 0 vs 시안 image area 1 → **L1 누락 거짓 FAIL**(옳게 그렸는데 실패).

**처방**(적대 L3 — 위치 무관 set-membership): image의 *위치/부모/순서*를 비교에서 빼고 **존재(개수)만** 본다. 양쪽 대칭:
- `dump_to_ir.dart`: image를 *어디 있든*(section 내부 포함) 수집해 카운트.
- `extract_layout.dart`: 시안 `<img>`를 동일 규칙으로 수집(이미 top-level 추출 — 대칭 확인).
- `compare_layout.dart` L1: area role 시퀀스 비교에서 **image를 제외하고, 시안·코드 image 개수만 별도 비교**(누락/추가만 FAIL·순서·부모 무관).

**trade-off**(명시·기록): image *순서/위치 reorder*(이미지를 리스트 위↔아래 이동)는 못 잡는다. 14차 미발현·드묾·"가감 0"(존재)이 우선이므로 수용. 후순위 한계로 기록.

**검증**(positive-control 재검 — **선결**): ⓐ 섹션 내부 image(claude형) → PASS ⓑ 섹션 밖 image → PASS ⓒ image 누락(codex 브로콜리) → FAIL ⓓ image 추가 → FAIL ⓔ 기존 positive-control 7/7 회귀 0. reorder는 "기록된 한계"로 positive-control에서 제외. 다음 런 = **claude류 섹션 내부 image 거짓 FAIL 0 + codex 누락 정탐**.

---

## 5. 후순위 (이번 제외·명시 기록)

- **② 내용확장 IR**(색·텍스트·아이콘·이미지 정체): 적대 L2 — 색 추출소스 부재·시안 색 모순·아이콘 어휘 불일치(sunny↔clear)·이미지 src 절단·동적 라벨 bound로 못 잡음 + 코어 MODIFY 회귀 위험. condition 라벨 추가는 그때까지 미검출(육안).
- **간격·폰트 토큰 등가**(적대 L1): 시안·코드 토큰이 둘 다 결정적이라 스크린샷 없이 가능하나, ②류 확장이라 다음.
- **도구 사각 3개**(적대 L3 신규): repeat-group 접미사 의존·블록경계 collapse 누출(감산 은폐)·appbar/nav 슬롯 미비교. 코어(`compare_layout`) 건드림·14차 미발현 → §08(리팩터링 분리) 위해 별도 회차.

---

## 6. 시술 순서·검증 게이트

1. **DT-2**(생성측·독립·코어 무관) → 양판 미러 → 앵커 grep.
2. **③ image**(도구) → **positive-control 재검 선결**(섹션 내부/밖 PASS·누락 FAIL·7/7 회귀 0) → 통과 후 투입.
3. **① screenProbes**(코퍼스+eval) → 양판 미러 + positive-control(노출 green·미노출 깨짐) → fid-gate BLOCKER 격상.
4. 전부 green 빌드 확인 → **별도 사용자 승인 → 다음 런 동결**.
5. **feedback-016와 별개** — 이 회차는 측정 봉합 + DT-2만. 생성측 충실도 10항목은 다음.

## 7. measure-first 사전등록 (다음 런 성공 기준)

| 항목 | 전(14차) | 후 기대 | 측정 |
|---|---|---|---|
| DT-2 | claude 무가드 FAIL·N=2 swap | 양 엔진 가드 PASS·누수 0 | 의미 정독 + 404 바디 불일치 시뮬 |
| screenProbes | 양 엔진 미노출·6회 A1 폴백 | 양 엔진 노출·fid-gate 실제 발동 | `_support.dart`+screenProbes 존재·fid-gate exit≠3 |
| image 거짓 FAIL | claude 섹션 내부 image 거짓 FAIL 위험 | 거짓 FAIL 0·누락 정탐 | positive-control ⓐ~ⓔ |

⚠️ N=1 인과 단정 금지. 측정 도구 변경은 positive-control이 1차 게이트(다음 런 전 자체 검증).
