# feedback-025 — fid-gate `_support.dart` 선택 버그 (eval 도구·단일출처)

> 사전등록형 원장(eval-fix-ledger). **상태**: 수정 완료·17차 검증 대기. **scope**: eval 도구(`workspace/eval/tools/fid-gate.sh`)·**단일출처·미러 불요·코퍼스 무관**.

## 증상 (16차 claude fid-gate A1 오폴백·claude 무죄)
16차 claude는 `presentation_layer/_support.dart`에 `screenProbes`를 **정확히 노출**(시그니처도 정확)했는데도 fid-gate가 A1 폴백 → FID 미측정. claude 코드 결함이 아니라 **도구의 파일 선택 버그**.

## ROC (직접 재현·잠복 버그)
- `fid-gate.sh:53`(구): `SUP="$(find "$OUT/test" -name _support.dart | head -1)"` + `if [ -z "$SUP" ] || ! grep -q screenProbes "$SUP"`.
- **위치 기반 선택**: `_support.dart`가 여럿이면 `head -1`이 find 순서(알파벳) 첫 파일만 집고, 그게 screenProbes를 안 가지면 다른 곳의 정상 파일을 무시한 채 A1.
- **16차 claude 재현**: `_support.dart` 2개 — `application_layer/_support.dart`[screenProbes **X**·먼저] + `presentation_layer/_support.dart`[screenProbes **O**·무시됨]. head-1이 application_layer를 집음 → grep 실패 → A1.
- **잠복 확정(회귀 아님)**: fid-gate.sh는 15→16차 창에 변경 0(마지막 `a4b3bbe`/`9afa6f0` 모두 그 이전). 회귀 ROC 실측:
  | claude 런 | _support 개수 | head-1 screenProbes | 결과 |
  |---|---|---|---|
  | 15차(0058) | 1 | O | 작동 |
  | 16차(1331) | 2 | X | A1 오폴백 |
  15차는 단일 _support(screenProbes O)라 head-1 정확 → 작동. 16차에 application_layer 테스트용 _support 추가 → head-1 오선택. **도구 불변·생성물 구조 변동이 잠복 버그 노출.**

## 수정 (내용 기반 선택)
```bash
# (구) SUP="$(find "$OUT/test" -name _support.dart | head -1)"; if [ -z "$SUP" ] || ! grep -q screenProbes "$SUP"; then
# (신)
SUP="$(find "$OUT/test" -name _support.dart -exec grep -l "screenProbes" {} + 2>/dev/null | head -1)"
if [ -z "$SUP" ]; then
```
- screenProbes를 **담은** 첫 `_support.dart`를 고른다(위치 아닌 내용). 하나도 없으면 빈값 → 진짜 미노출 A1(기존과 동일). 주석 2줄로 근거 명기.

## 검증
- **syntax OK**(`bash -n`).
- **16차 claude**: 수정 도구가 `presentation_layer/_support.dart`(screenProbes O) 선택 = **A1 대신 정상 선택**(버그 수정 작동).
- **무회귀**: 15차 O→O(단일 정상)·13차(1 _support·screenProbes X)→빈값 A1(기존과 동일·정당)·14차/0035(_support 0)→A1(불변). **16차류(다중 _support·screenProbes 비-선두)만 X→O로 변경, 나머지 전부 불변.**
- **positive-control fid**: 스텁(`ref.json`+`run.sh`만·_support 없음·정식 A~J fixture 미구축) → 선택 경로 미운용·무관.

## 자기 적대 점검 (edge)
- **다중 BC·screenProbes _support 2개+**: head-1이 첫 BC만 테스트 — 기존(구 head-1)도 동일 한계·**악화 아님**. weather는 단일 BC·단일 screenProbes _support라 무영향.
- **grep -l 느슨 매칭**(주석/import의 screenProbes도 매칭): 기존 `grep -q`와 동일 수준·악화 아님(_support가 screenProbes를 언급하면 정의가 관례).
- **BSD/GNU grep `-exec grep -l {} +`**: macOS(사용자 드라이브 머신)·linux 모두 portable.

## ★ 하류 미해결 (별건·이 수정 범위 밖)
선택 수정만으로 claude FID가 완전 측정된다는 보장은 없음:
- **pending timer**: claude 16차 AnimatedScale(Q-7) 등 애니메이션이 probe 덤프 시점에 미settle → `testWidgets` teardown "pending timer" 실패 가능. probe(`dump_probe.dart.txt`)는 settle 안 함·screenProbes(코더 작성) pump가 settle해야. **probe 견고성 or screenProbes settle 규약 후보**(corpus·별건).
- **dump_to_ir 섹션파싱**: pending timer로 테스트가 죽어 code-tree json 부분/누락 시의 하류 증상으로 추정(dump_to_ir 자체는 결정론 워커·명백 버그 없음).
- **둘 다 flutter test 재현 필요(사용자 드라이브)** → 17차 라이브런에서 선택 수정 후 claude가 여전히 pending timer로 A1인지 실측 후 판단.
- **codex screenProbes 시그니처**(`ScreenPump` void vs 표준 `ScreenProbe=Future<Finder>`): codex 코더 흠·gate가 정당 A1 — 도구 버그 아님·별건(corpus screenProbes 시그니처 강제력 후보).

## 예상효과 (17차)
- claude가 다중 _support여도 fid-gate가 screenProbes 보유 파일 선택 → **선택 버그로 인한 A1 소멸**. 단 pending timer 잔존 시 다른 사유로 A1 가능(별건·실측).
- 측정: 17차 claude fid-gate 로그에 `presentation_layer/_support.dart` 선택·"screenProbes 미노출 A1" 미발생 확인.
