#!/usr/bin/env bash
# FID 게이트 채점 — 산출물 시안(design-ref HTML) vs 코드(screenProbes 렌더 덤프) 결정론 대조.
# 표준 pump 진입점 규약(implementation-test §7 screenProbes·코퍼스·양판) 전제. RUBRIC §H·EVAL §2.3 FID.
#
# 사용:  bash fid-gate.sh <산출물 루트>
# 종료:  0 = FID-L1·L2 전 화면 PASS
#        2 = FID-L1/L2 FAIL(구조 이탈 — 결과지 ❌·치명)
#        3 = screenProbes 미노출/덤프 불가 → A1 폴백(코더 표준 pump 규약 미준수·❌ 도장 금지·RUBRIC §H)
#        1 = 입력 오류(design-ref 없음 등)
# 주: bash 3.2(macOS 기본) 호환 — mapfile 미사용.
set -u
TOOLS="$(cd "$(dirname "$0")" && pwd)"
REPO="$(git -C "$TOOLS" rev-parse --show-toplevel)"
EXTRACT="$REPO/dddart/scripts/extract_layout.dart"
DUMP2IR="$TOOLS/dump_to_ir.dart"
COMPARE="$TOOLS/compare_layout.dart"
PROBE="$TOOLS/dump_probe.dart.txt"

OUT="${1:-}"
{ [ -n "$OUT" ] && [ -d "$OUT" ]; } || { echo "사용: bash fid-gate.sh <산출물 루트>"; exit 1; }
OUT="$(cd "$OUT" && pwd)"
WORK="$(mktemp -d)"
PROBE_DST=""
cleanup() { [ -n "$PROBE_DST" ] && rm -f "$PROBE_DST"; rm -rf "$WORK"; }
trap cleanup EXIT

echo "== FID 게이트: $OUT =="

# ── 1. 시안 design-ref → 시안 layout-ir ──
DREF="$(find "$OUT/.dddart" -type d -name design-ref 2>/dev/null | head -1)"
[ -n "$DREF" ] || { echo "❌ 시안 design-ref 없음(.dddart/*/design-ref) — Phase 0 시안 동결 누락"; exit 1; }
echo "시안 design-ref: $DREF"
dart run "$EXTRACT" "$DREF" --out "$WORK/ref.json" || { echo "❌ extract_layout 실패"; exit 1; }

# 시안 화면 이름 수집(bash 3.2 호환) · role 분류
SCREENS=()
while IFS= read -r line; do [ -n "$line" ] && SCREENS+=("$line"); done < <(python3 -c "import json;[print(s['screen']) for s in json.load(open('$WORK/ref.json'))['screens']]")
# 코드 role ↔ 시안 화면명 매칭(시나리오별 명명 휴리스틱 금지·임의 화면쌍 대조 차단):
#   ① role==screen 정확  ② role⊂screen 또는 screen⊂role 부분(유일할 때만)  ③ 시안·코드 각 1화면이면 단일 특례  ④ 불일치=미검증
match_screen() {  # $1=code role → 시안 screen명 또는 빈값
  local role="$1" s hit="" n=0
  for s in "${SCREENS[@]}"; do [ "$s" = "$role" ] && { printf '%s' "$s"; return; }; done
  for s in "${SCREENS[@]}"; do
    case "$s" in *"$role"*) hit="$s"; n=$((n+1)); continue;; esac
    case "$role" in *"$s"*) hit="$s"; n=$((n+1));; esac
  done
  [ "$n" = 1 ] && { printf '%s' "$hit"; return; }
  { [ "${#SCREENS[@]}" = 1 ] && [ "$NTREE" = 1 ]; } && { printf '%s' "${SCREENS[0]}"; return; }
  printf ''
}

# ── 2. 표준 pump 규약 준수(screenProbes 노출)? ──
# _support.dart는 여럿일 수 있다(application_layer·presentation_layer 등 계층별 테스트 지원 파일) —
# screenProbes는 그 중 하나(화면 펌프 진입점이 있는 쪽)에만 산다. 위치(find 순서·알파벳)가 아니라
# *내용*으로 고른다: screenProbes를 담은 첫 _support.dart. 하나도 없으면 진짜 미노출 → A1.
SUP="$(find "$OUT/test" -name _support.dart -exec grep -l "screenProbes" {} + 2>/dev/null | head -1)"
if [ -z "$SUP" ]; then
  echo "⚠️ screenProbes 미노출 → 렌더 덤프 불가·A1 폴백(코더 표준 pump 규약 미준수·RUBRIC §H·❌ 도장 금지)"
  cp "$WORK/ref.json" "$(dirname "$DREF")/ref-layout.json" 2>/dev/null \
    && echo "   시안 layout-ir → $(dirname "$DREF")/ref-layout.json (사용자 눈 대조 재료로 보존)"
  exit 3
fi
SUPDIR="$(dirname "$SUP")"

# ── 3. dump_probe 주입 → flutter test → code-tree-<role>.json ──
PROBE_DST="$SUPDIR/fid_dump_test.dart"
cp "$PROBE" "$PROBE_DST"
REL="test/${SUPDIR#"$OUT"/test/}/fid_dump_test.dart"
echo "렌더 덤프: flutter test $REL"
if ! ( cd "$OUT" && FID_DUMP_DIR="$WORK" flutter test "$REL" ); then
  echo "⚠️ 렌더 덤프 실패(컴파일/펌프 오류) → A1 폴백(screenProbes 시그니처/펌프 점검·❌ 도장 금지)"; exit 3
fi
ls "$WORK"/code-tree-*.json >/dev/null 2>&1 || { echo "⚠️ code-tree 산출 0 → A1 폴백"; exit 3; }

# ── 4. 코드 layout-ir(dump_to_ir) → 시안 이름으로 라벨(compare 이름매칭) → 대조 ──
NTREE=$(ls "$WORK"/code-tree-*.json 2>/dev/null | wc -l | tr -d ' ')
FAIL=0; CMP=0
for tree in "$WORK"/code-tree-*.json; do
  role="$(basename "$tree" .json)"; role="${role#code-tree-}"
  sc="$(match_screen "$role")"
  [ -n "$sc" ] || { echo "⚠️ 코드 화면 '$role'에 대응하는 시안 화면명 없음 — 임의 매칭 금지·이 화면 미검증(screenProbes role 키를 design-ref screen명 기반으로 — implementation-test §7)"; continue; }
  dart run "$DUMP2IR" "$tree" --screen "$sc" --out "$WORK/got-$role.json" || { FAIL=1; continue; }
  echo "── 대조: 코드 role '$role' ↔ 시안 '$sc' ──"
  dart run "$COMPARE" --ref "$WORK/ref.json" --got "$WORK/got-$role.json" --screen "$sc" --gate; e=$?
  CMP=1
  [ "$e" = 2 ] && FAIL=2
done

[ "$CMP" = 1 ] || { echo "⚠️ 대조 0건 → A1 폴백"; exit 3; }
echo "—————"
if [ "$FAIL" = 0 ]; then echo "✅ FID-L1·L2 전 화면 PASS"; exit 0
elif [ "$FAIL" = 2 ]; then echo "❌ FID-L1/L2 FAIL(구조 이탈·치명)"; exit 2
else echo "⚠️ dump_to_ir 오류 → A1 폴백"; exit 3; fi
