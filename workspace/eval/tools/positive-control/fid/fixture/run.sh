#!/usr/bin/env bash
# FID positive-control (step 2a · layout-ir 평탄화 반증)
#
# compare_layout.dart이 **등가 재구성(묶음/래퍼 차이)은 PASS, 진짜 구조 차이는 FAIL**함을 반증한다
# (RUBRIC §H 게이트 활성 조건 ②의 layout-ir 레벨 부분). ref.json에서 변종을 파생해 --gate로 대조.
#
# 범위: 이 스크립트는 *compare의 평탄화*(L2 등가 흡수·차이 검출)를 반증한다.
#   위젯 트리 변종 A~J(렌더 덤프 → layout-ir 정확성)는 step 2b(dump_layout 구현) 후 README 표대로 추가.
# 사용: bash run.sh   (종료 0=반증 통과·실패 건수=exit)

set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git -C "$DIR" rev-parse --show-toplevel)"
CMP="$ROOT/workspace/eval/tools/compare_layout.dart"
REF="$DIR/ref.json"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
FAIL=0

check() { # label  py-transform  expected-exit  note
  python3 - "$REF" "$TMP/g.json" "$2" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
s = d['screens'][0]
areas = s['areas']
def sec(label): return next(a for a in areas if a.get('label') == label)
exec(sys.argv[3])
json.dump(d, open(sys.argv[2], 'w'))
PY
  dart run "$CMP" --ref "$REF" --got "$TMP/g.json" --gate >/dev/null 2>&1; e=$?
  if [ "$e" = "$3" ]; then echo "  ✓ $1 — $4 (exit $e)"; else echo "  ✗ $1 — $4 (exit $e ≠ 기대 $3)"; FAIL=$((FAIL + 1)); fi
}

echo "== 등가 재구성 → PASS(0) · 거짓-FAIL 0 반증 =="
check "A 동일"       "pass"  0  "변형 없음"
check "C group 흡수" "u=sec('list')['children'][0]['unit']['slots']; u[1]={'type':'group','slots':[u[1]]}"  0  "icon→group[icon]·평탄화 흡수"
check "D block 펼침" "sec('hero')['children']=[{'kind':'block','slots':[{'type':'text'},{'type':'icon'},{'type':'text'}]}]"  0  "hero 2블록→1블록·평탄화 동일"
check "G hero text 흡수" "sec('hero')['children'].append({'kind':'block','slots':[{'type':'text'}]})"  0  "hero 끝 text 추가(코드 Text 분리 모사)·연속 동종 collapse 흡수"

echo "== 진짜 차이 → FAIL(2) · 정탐 =="
check "E icon 누락"  "u=sec('list')['children'][0]['unit']['slots']; del u[1]"  2  "card에서 icon 제거"
check "F 순서변경"   "u=sec('list')['children'][0]['unit']['slots']; u[0],u[1]=u[1],u[0]"  2  "text↔icon 순서"
check "L1 영역누락"  "s['areas']=[a for a in areas if a['role'] not in ('image','bottomnav')]"  2  "image·bottomnav 제거(8차 갭 재현)"

echo "—————"
if [ "$FAIL" = 0 ]; then
  echo "✅ 거짓-FAIL 0 · 정탐 검출 — compare 평탄화 반증 통과(step 2a)"
else
  echo "❌ 반증 실패 ($FAIL건) — 평탄화 규칙 보정 필요(fix 원장)"
fi
exit "$FAIL"
