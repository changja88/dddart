#!/usr/bin/env bash
# dddart 백스톱 픽스처 테스트 (설계 §12-3 필수 4종 + 보강)
# F1 porcelain -uall 신규 BC / F2 상대 import lib/ 클램핑 / F3 블록 주석 directive
# F4 멀티라인 ref.listen<T>( / F5 added 줄 게이트(레거시 면책) / F6 IM5 4채널
# F7 CY1 래칫 / F8 extract_contract
set -u
SCRIPTS="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0; FAIL=0

run_backstop() { dart "$SCRIPTS/backstop.dart" "$@" 2>&1; }

assert() { # assert <이름> <기대exit> <출력에 있어야 할 패턴|-> <출력에 없어야 할 패턴|-> <실제exit> <출력>
  local name="$1" wantexit="$2" want="$3" unwant="$4" gotexit="$5" out="$6" ok=1
  [ "$gotexit" != "$wantexit" ] && ok=0
  [ "$want" != "-" ] && ! grep -q "$want" <<<"$out" && ok=0
  [ "$unwant" != "-" ] && grep -q "$unwant" <<<"$out" && ok=0
  if [ $ok = 1 ]; then PASS=$((PASS+1)); echo "PASS $name"; else
    FAIL=$((FAIL+1)); echo "FAIL $name (exit=$gotexit want=$wantexit)"; echo "$out" | head -20 | sed 's/^/    /'
  fi
}

mkproj() { # mkproj <dir> — pubspec(name: pkg) + lib/main.dart + git 초기 커밋, BASE 출력
  local p="$1"; mkdir -p "$p/lib"
  echo "name: pkg" > "$p/pubspec.yaml"
  echo "void main() {}" > "$p/lib/main.dart"
  git -C "$p" init -q
  git -C "$p" -c user.name=t -c user.email=t@t add -A
  git -C "$p" -c user.name=t -c user.email=t@t commit -qm base
  git -C "$p" rev-parse HEAD
}

T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT

# ---------- F1: porcelain -uall — 미커밋 신규 BC의 파일이 added로 잡히는가
P="$T/f1"; BASE=$(mkproj "$P")
mkdir -p "$P/lib/application/coupon/application_layer/view_model"
echo "class CouponApp {}" > "$P/lib/application/coupon/application_layer/view_model/coupon_app.dart"
OUT=$(run_backstop "$P" --diff-base "$BASE" --only nm); E=$?
assert "F1 porcelain -uall 신규 BC(NM2 구접미사)" 2 "NM2" - "$E" "$OUT"

# ---------- F2: 상대 import 8단 — lib/ 클램핑으로 IM7 검출
P="$T/f2"; BASE=$(mkproj "$P")
mkdir -p "$P/lib/application/chat/application_layer/view_model"
cat > "$P/lib/application/chat/application_layer/view_model/chat_vm.dart" <<'EOF'
import '../../../../../../../../common/local_database/token_box.dart';
class ChatVM {}
EOF
OUT=$(run_backstop "$P" --diff-base "$BASE" --only im); E=$?
assert "F2 상대 import lib/ 클램핑(IM7)" 2 "IM7" - "$E" "$OUT"

# ---------- F3: 블록 주석·라인 주석 속 directive — 불발화
P="$T/f3"; BASE=$(mkproj "$P")
mkdir -p "$P/lib/application/chat/domain_layer/chat/entity"
cat > "$P/lib/application/chat/domain_layer/chat/entity/msg.dart" <<'EOF'
/*
import 'package:flutter/material.dart';
*/
// import 'package:flutter/material.dart';
class Msg {}
EOF
OUT=$(run_backstop "$P" --diff-base "$BASE" --only im); E=$?
assert "F3 주석 속 directive 불발화" 0 - "IM1" "$E" "$OUT"

# ---------- F4: 멀티라인 ref.listen<T>( — 자기 VM 통과, 타 provider 검출(정확히 1건)
P="$T/f4"; BASE=$(mkproj "$P")
mkdir -p "$P/lib/application/lounge/presentation_layer/view"
cat > "$P/lib/application/lounge/presentation_layer/view/lounge_detail_view.dart" <<'EOF'
class LoungeDetailView {
  void build(dynamic ref) {
    ref.listen<AsyncValue<int>>(
      loungeDetailVMProvider,
      (p, n) {},
    );
    ref.watch(loungeDetailVMProvider.select((s) => s.title));
    ref.read(loungeDetailVMProvider.notifier);
    ref.watch(memberVMProvider);
  }
}
EOF
OUT=$(run_backstop "$P" --diff-base "$BASE" --only nm9); E=$?
N=$(grep -c "NM9" <<<"$OUT" || true)
if [ "$E" = 2 ] && [ "$N" = 1 ] && grep -q "memberVMProvider" <<<"$OUT"; then
  PASS=$((PASS+1)); echo "PASS F4 멀티라인 ref.listen 근사(NM9 정확히 1건)"
else
  FAIL=$((FAIL+1)); echo "FAIL F4 (exit=$E, NM9=$N)"; echo "$OUT" | head -20 | sed 's/^/    /'
fi

# ---------- F5: added 줄 게이트 — 레거시 위반 import 불발화, 신규 위반 줄만 발화
P="$T/f5"; mkdir -p "$P/lib/application/chat/domain_layer/chat/entity"
echo "name: pkg" > "$P/pubspec.yaml"; echo "void main() {}" > "$P/lib/main.dart"
cat > "$P/lib/application/chat/domain_layer/chat/entity/old.dart" <<'EOF'
import 'package:flutter/material.dart';
class Old {}
EOF
git -C "$P" init -q
git -C "$P" -c user.name=t -c user.email=t@t add -A
git -C "$P" -c user.name=t -c user.email=t@t commit -qm base
BASE=$(git -C "$P" rev-parse HEAD)
echo "// touched" >> "$P/lib/application/chat/domain_layer/chat/entity/old.dart"
OUT=$(run_backstop "$P" --diff-base "$BASE" --only im); E=$?
assert "F5a 레거시 위반 import 불발화(added 줄 밖)" 0 - "IM1" "$E" "$OUT"
echo "import 'dart:ui';" >> "$P/lib/application/chat/domain_layer/chat/entity/old.dart"
OUT=$(run_backstop "$P" --diff-base "$BASE" --only im); E=$?
assert "F5b 신규 위반 줄 발화(IM1 dart:ui)" 2 "IM1" - "$E" "$OUT"

# ---------- F6: IM5 4채널 — shared_state 차단, entity 통과
P="$T/f6"; BASE=$(mkproj "$P")
mkdir -p "$P/lib/application/chat/application_layer/view_model"
cat > "$P/lib/application/chat/application_layer/view_model/chat_room_vm.dart" <<'EOF'
import 'package:pkg/application/member/application_layer/shared_state/member_shared_state.dart';
import 'package:pkg/application/member/domain_layer/member/entity/photo.dart';
import 'package:pkg/application/member/application_layer/use_case/member_use_case.dart';
class ChatRoomVM {}
EOF
OUT=$(run_backstop "$P" --diff-base "$BASE" --only im5); E=$?
N=$(grep -c "IM5" <<<"$OUT" || true)
if [ "$E" = 2 ] && [ "$N" = 1 ] && grep -q "shared_state" <<<"$OUT"; then
  PASS=$((PASS+1)); echo "PASS F6 IM5 4채널(shared_state만 차단)"
else
  FAIL=$((FAIL+1)); echo "FAIL F6 (exit=$E, IM5=$N)"; echo "$OUT" | head -20 | sed 's/^/    /'
fi

# ---------- F7: CY1 래칫 — 생성→동결→신규 쌍 발화
P="$T/f7"; BASE=$(mkproj "$P")
mkdir -p "$P/lib/application/a/application_layer/use_case" "$P/lib/application/b/application_layer/use_case"
echo "import 'package:pkg/application/b/application_layer/use_case/b_use_case.dart'; class AUseCase {}" \
  > "$P/lib/application/a/application_layer/use_case/a_use_case.dart"
echo "import 'package:pkg/application/a/application_layer/use_case/a_use_case.dart'; class BUseCase {}" \
  > "$P/lib/application/b/application_layer/use_case/b_use_case.dart"
OUT=$(run_backstop "$P" --diff-base "$BASE" --only cy); E=$?
assert "F7a 베이스라인 자동 생성(exit 0·동결 보고)" 0 "베이스라인 생성" "CY1] BLOCKER" "$E" "$OUT"
OUT=$(run_backstop "$P" --diff-base "$BASE" --only cy); E=$?
assert "F7b 동결 쌍 면책" 0 - "CY1] BLOCKER" "$E" "$OUT"
mkdir -p "$P/lib/application/c/application_layer/use_case"
echo "import 'package:pkg/application/a/application_layer/use_case/a_use_case.dart'; class CUseCase {}" \
  > "$P/lib/application/c/application_layer/use_case/c_use_case.dart"
echo "import 'package:pkg/application/c/application_layer/use_case/c_use_case.dart'; class A2UseCase {}" \
  > "$P/lib/application/a/application_layer/use_case/a2_use_case.dart"
OUT=$(run_backstop "$P" --diff-base "$BASE" --only cy); E=$?
assert "F7c 신규 순환 쌍 발화" 2 "CY1" - "$E" "$OUT"

# ---------- F8: extract_contract — 전이 폐쇄·보존·누락 시 근사 후보
P="$T/f8"; mkdir -p "$P"
cat > "$P/openapi-full.json" <<'EOF'
{
  "openapi": "3.0.0",
  "info": {"title": "t", "version": "1"},
  "security": [{"bearer": []}],
  "paths": {
    "/api/v1/members/{id}": {
      "parameters": [{"name": "id", "in": "path", "required": true, "schema": {"type": "string"}}],
      "get": {"responses": {"200": {"content": {"application/json": {"schema": {"$ref": "#/components/schemas/Member"}}}}}},
      "delete": {"responses": {"204": {"description": "x"}}}
    },
    "/api/v1/other": {"get": {"responses": {"200": {"content": {"application/json": {"schema": {"$ref": "#/components/schemas/Other"}}}}}}}
  },
  "components": {
    "securitySchemes": {"bearer": {"type": "http", "scheme": "bearer"}},
    "schemas": {
      "Member": {"type": "object", "properties": {"photo": {"$ref": "#/components/schemas/Photo"}}},
      "Photo": {"type": "object", "properties": {"url": {"type": "string"}}},
      "Other": {"type": "object"}
    }
  }
}
EOF
echo "GET /api/v1/members/{id}" > "$P/cited.txt"
OUT=$(dart "$SCRIPTS/extract_contract.dart" "$P/openapi-full.json" --paths "$P/cited.txt" --out "$P/server-contract.json" 2>&1); E=$?
C=$(cat "$P/server-contract.json" 2>/dev/null || echo "")
ok=1
[ "$E" = 0 ] || ok=0
grep -q '"Photo"' <<<"$C" || ok=0           # $ref 전이 폐쇄
grep -q '"parameters"' <<<"$C" || ok=0      # path item 공유 파라미터 보존
grep -q '"security"' <<<"$C" || ok=0        # 루트 security 보존
grep -q '"Other"' <<<"$C" && ok=0           # 비인용 스키마 미포함
grep -q '"delete"' <<<"$C" && ok=0          # 비인용 메서드 제거
if [ $ok = 1 ]; then PASS=$((PASS+1)); echo "PASS F8a extract 전이 폐쇄·보존·절단"; else
  FAIL=$((FAIL+1)); echo "FAIL F8a (exit=$E)"; echo "$C" | head -30 | sed 's/^/    /'
fi
echo "GET /api/v1/members/{memberId}" > "$P/cited2.txt"
OUT=$(dart "$SCRIPTS/extract_contract.dart" "$P/openapi-full.json" --paths "$P/cited2.txt" --out "$P/x.json" 2>&1); E=$?
assert "F8b 인용 누락 exit 1 + 근사 후보" 1 "유사 path" - "$E" "$OUT"

# ---------- F9: ST4 신규 BC 골격 미완비
P="$T/f9"; BASE=$(mkproj "$P")
mkdir -p "$P/lib/application/coupon/domain_layer/coupon"
echo "class Coupon {}" > "$P/lib/application/coupon/domain_layer/coupon/coupon.dart"
OUT=$(run_backstop "$P" --diff-base "$BASE" --only st4); E=$?
# ST4 발동 + 새 BC에 analysis_options.yaml 누락도 골격 미완비로 잡혀야 함(타입 전면강제 생성 게이트)
if [ "$E" = 2 ] && grep -q "ST4" <<<"$OUT" && grep -q "analysis_options.yaml" <<<"$OUT"; then
  PASS=$((PASS+1)); echo "PASS F9 ST4 신규 BC 골격 미완비(analysis_options.yaml 생성 게이트 포함)"
else
  FAIL=$((FAIL+1)); echo "FAIL F9 (exit=$E)"; echo "$OUT" | head -20 | sed 's/^/    /'
fi

# ---------- F10: extract_design — config JS→JSON 정규화·아이콘(data-icon+FILL/텍스트폴백)·임의값·icon_map
P="$T/f10"; mkdir -p "$P/design-ref"
cat > "$P/design-ref/s.html" <<'EOF'
<!DOCTYPE html><html><head>
<script id="tailwind-config">
        tailwind.config = {
          darkMode: "class",
          theme: {
            extend: {
              "colors": {
                      "primary": "#005da7",
                      "background": "#f8f9fa"
              },
              "spacing": {
                      "gutter": "16px"
              },
              "fontFamily": {
                      "headline": ["Plus Jakarta Sans"]
              },
              "fontSize": {
                      "headline": ["32px", { "lineHeight": "40px", "fontWeight": "600" }]
              }
      },
          },
        }
    </script>
</head><body>
<button class="material-symbols-outlined text-primary">arrow_back</button>
<span class="material-symbols-outlined text-4xl" data-icon="sunny" style="font-variation-settings: 'FILL' 1;">sunny</span>
<div class="bg-surface-bright shadow-[0_4px_20px_0px_rgba(0,0,0,0.04)] -mt-6"></div>
</body></html>
EOF
OUT=$(dart "$SCRIPTS/extract_design.dart" "$P/design-ref" --out "$P/design-tokens.json" --icon-map "$SCRIPTS/icon_map.json" 2>&1); E=$?
C=$(cat "$P/design-tokens.json" 2>/dev/null || echo "")
ok=1
[ "$E" = 0 ] || ok=0
grep -q '"primary": "#005da7"' <<<"$C" || ok=0                 # 무인용 상위키·trailing comma 정규화 후 색 파싱
grep -q '"gutter": "16px"' <<<"$C" || ok=0                     # spacing
grep -q '"Plus Jakarta Sans"' <<<"$C" || ok=0                 # fontFamily+fontSize 병합
grep -q '"name": "sunny"' <<<"$C" || ok=0                      # data-icon
grep -A2 '"name": "sunny"' <<<"$C" | grep -q '"fill": 1' || ok=0   # 인라인 FILL
grep -q '"flutter": "Icons.sunny"' <<<"$C" || ok=0            # icon_map 매핑
grep -q '"name": "arrow_back"' <<<"$C" || ok=0                # data-icon 없는 텍스트 폴백
grep -q 'shadow-\[0_4px_20px' <<<"$C" || ok=0                 # 임의값(shadow rgba)
grep -q '"-mt-6"' <<<"$C" || ok=0                             # 음수마진
if [ $ok = 1 ]; then PASS=$((PASS+1)); echo "PASS F10 extract_design 정규화·아이콘·임의값·매핑"; else
  FAIL=$((FAIL+1)); echo "FAIL F10 (exit=$E)"; echo "$C" | head -40 | sed 's/^/    /'
fi

# ---------- F11: NM17 view-fat 우회 차단 — 멀티라인 extends·위젯 반환 함수(List<Widget>·Widget?·구체위젯)·순수 helper 통과
P="$T/f11"; BASE=$(mkproj "$P")
mkdir -p "$P/lib/application/board/presentation_layer/view"
cat > "$P/lib/application/board/presentation_layer/view/board_list_view.dart" <<'EOF'
import 'package:flutter/material.dart';

class BoardListView extends StatelessWidget {
  const BoardListView({super.key});
  @override
  Widget build(BuildContext context) => _rows(context).first;
}

class _FatBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _MultiBody
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

List<Widget> _rows(BuildContext context) => <Widget>[const SizedBox()];

Widget? _header(BuildContext context) => null;

Column _col() => Column(children: <Widget>[]);

String _label(int n) => '$n';

WidgetRef? _grabRef() => null;
EOF
OUT=$(run_backstop "$P" --diff-base "$BASE" --only nm); E=$?
N=$(grep -c "NM17" <<<"$OUT" || true)
# 기대: _FatBody·_MultiBody(멀티라인)·_rows(List<Widget>)·_header(Widget?)·_col(구체위젯) = NM17 발동.
#       주 view(BoardListView)·순수 helper(_label: String)·WidgetRef 반환(_grabRef: 비위젯 프레임워크 타입)은 미발동.
if [ "$E" = 2 ] \
   && grep -q "_FatBody" <<<"$OUT" && grep -q "_MultiBody" <<<"$OUT" \
   && grep -q "_rows" <<<"$OUT" && grep -q "_header" <<<"$OUT" && grep -q "_col" <<<"$OUT" \
   && ! grep -q "_label" <<<"$OUT" && ! grep -q "BoardListView" <<<"$OUT" && ! grep -q "_grabRef" <<<"$OUT"; then
  PASS=$((PASS+1)); echo "PASS F11 NM17 우회 차단(멀티라인 extends·위젯반환 함수·구체위젯·helper·WidgetRef 면제·주view 면제) [NM17=$N]"
else
  FAIL=$((FAIL+1)); echo "FAIL F11 (exit=$E, NM17=$N)"; echo "$OUT" | head -30 | sed 's/^/    /'
fi

# ---------- F12: extract_design --from-theme — 브랜드seed/렌더색 분리·_fixed 분리·rounded 블록 표적파싱·타이포 매핑·불일치 경고
P="$T/f12"; mkdir -p "$P"
cat > "$P/designtheme.json" <<'EOF'
{
  "designTheme": {
    "colorMode": "LIGHT",
    "customColor": "#4a90e2",
    "overridePrimaryColor": "#4a90e2",
    "overrideSecondaryColor": "#f5a623",
    "roundness": "ROUND_EIGHT",
    "bodyFontFamily": "Be Vietnam Pro",
    "namedColors": {
      "primary": "#005da7",
      "secondary": "#835500",
      "surface": "#f8f9fa",
      "primary_fixed": "#d4e3ff",
      "on_primary_fixed_variant": "#004883"
    },
    "spacing": { "gutter": "16px", "card-padding": "20px" },
    "typography": {
      "body-md": {"fontFamily": "Be Vietnam Pro", "fontSize": "16px", "fontWeight": "400", "lineHeight": "24px"}
    },
    "designMd": "---\nname: AC\ncolors:\n  primary: '#005da7'\nrounded:\n  sm: 0.25rem\n  lg: 1rem\n  full: 9999px\nspacing:\n  gutter: 16px\n---\n\n## Components\n- Cards 16px.\n"
  }
}
EOF
OUT=$(dart "$SCRIPTS/extract_design.dart" --from-theme "$P/designtheme.json" --out "$P/design-tokens.json" 2>&1); E=$?
C=$(cat "$P/design-tokens.json" 2>/dev/null || echo "")
ok=1
[ "$E" = 0 ] || ok=0
grep -q '"source": "designTheme"' <<<"$C" || ok=0                  # 모드 메타
grep -q '"primary": "#4a90e2"' <<<"$C" || ok=0                     # 브랜드 seed(brandColors)
grep -q '"primary": "#005da7"' <<<"$C" || ok=0                     # 렌더 색(colors) — seed와 다름(둘 다 산출)
grep -q '"primary_fixed": "#d4e3ff"' <<<"$C" || ok=0               # *_fixed → extendedColors 분리
grep -q '"lg": "1rem"' <<<"$C" || ok=0                             # designMd `rounded:` 블록만 표적 파싱
grep -q '"full": "9999px"' <<<"$C" || ok=0
grep -A3 '"body-md"' <<<"$C" | grep -q '"family": "Be Vietnam Pro"' || ok=0   # fontFamily→family 매핑
grep -q "브랜드 seed" <<<"$OUT" || ok=0                            # seed≠렌더 불일치 경고 표면화
if [ $ok = 1 ]; then PASS=$((PASS+1)); echo "PASS F12 extract_design --from-theme(브랜드/렌더 분리·_fixed·rounded·타이포·경고)"; else
  FAIL=$((FAIL+1)); echo "FAIL F12 (exit=$E)"; echo "$C" | head -40 | sed 's/^/    /'; echo "$OUT" | sed 's/^/    /'
fi

echo ""
echo "결과: PASS $PASS / FAIL $FAIL"
[ $FAIL = 0 ]
