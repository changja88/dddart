#!/usr/bin/env bash
# dddart eval — 테스트 스위트 병렬 결정성 게이트
# EVAL-METHOD §2.6-5 · feedback-010 항목 5(테스트 결정성·차원→게이트 강등)
#
# green 빌드 재현성 검사: flutter test를 *병렬* concurrency로 N회 실행해 전회 exit 0을 요구한다.
# (기계 게이트 — 주관 RUBRIC 차원 아님·BG류. 단일출처·미러 불필요.)
#
# 실패 시 양태를 분해한다(8차 선분해 — 코퍼스 처방 확정 전):
#   - serial(--concurrency=1) green인데 병렬만 red → 자원/타이밍 경합(전역 싱글톤 reset로는 안 풀릴 수 있음)
#   - serial도 red → 순서 의존 또는 잔존 상태(--test-randomize-ordering-seed로 순서축 확인)
# 메커니즘 주의: flutter test는 파일(suite)별 isolate·isolate는 static 미공유라
#   "병렬 cross-shard 싱글톤 오염"은 경로가 닫혀 있다 → reset 부재가 1차 가설이 아니다.
#   (--test-randomize-ordering-seed는 *순서 의존* 별축이라 병렬 경합을 대체하지 못한다 — 보조용.)
#
# 사용: parallel-determinism-gate.sh <산출물 루트> [N=5] [concurrency]
#   N           반복 횟수(기본 5·≥3 권장)
#   concurrency flutter test --concurrency 값(미지정 시 flutter 기본=병렬 >1)
# 종료: 0=전회 green / 2=1회+ red / 1=사용·환경 오류
set -u

ROOT="${1:-}"
N="${2:-5}"
CONC="${3:-}"

if [ -z "$ROOT" ] || [ ! -f "$ROOT/pubspec.yaml" ]; then
  echo "사용: $0 <산출물 루트(pubspec.yaml 보유)> [N=5] [concurrency]" >&2
  exit 1
fi
if ! command -v flutter >/dev/null 2>&1; then
  echo "[gate] flutter 미설치 — 환경 오류" >&2
  exit 1
fi

CONC_ARG=()
[ -n "$CONC" ] && CONC_ARG=(--concurrency="$CONC")

echo "[gate] $ROOT — codegen 선행(build_runner)"
( cd "$ROOT" && dart run build_runner build --delete-conflicting-outputs ) >/dev/null 2>&1 \
  || { echo "[gate] build_runner 실패 — 환경/코드 오류" >&2; exit 1; }

echo "[gate] flutter test 병렬 ${CONC:+--concurrency=$CONC }×$N 회"
green=0; red=0
for i in $(seq 1 "$N"); do
  if ( cd "$ROOT" && flutter test ${CONC_ARG[@]+"${CONC_ARG[@]}"} ) >"/tmp/dgate-run-$i.log" 2>&1; then
    green=$((green+1)); echo "  run $i: green"
  else
    red=$((red+1));     echo "  run $i: RED (log: /tmp/dgate-run-$i.log)"
  fi
done

if [ "$red" = 0 ]; then
  echo "[gate] PASS — 병렬 $N/$N green(결정적)"
  exit 0
fi

echo "[gate] FAIL — 병렬 red ${red}/${N}건 → 양태 분해(8차 선분해)"
echo "  · serial(--concurrency=1) 대조:"
if ( cd "$ROOT" && flutter test --concurrency=1 ) >/tmp/dgate-serial.log 2>&1; then
  echo "    serial green → 병렬-only flaky = 자원/타이밍 경합 가능(전역 싱글톤 reset로 안 풀릴 수 있음 · log /tmp/dgate-serial.log)"
else
  echo "    serial도 RED → 순서 의존/잔존 상태 의심(log /tmp/dgate-serial.log)"
fi
echo "  · 순서축(--test-randomize-ordering-seed random) 대조:"
if ( cd "$ROOT" && flutter test --concurrency=1 --test-randomize-ordering-seed random ) >/tmp/dgate-order.log 2>&1; then
  echo "    순서 무작위 serial green → 순서 의존 아님(병렬 경합 축 · log /tmp/dgate-order.log)"
else
  echo "    순서 무작위에서 RED → 순서 의존(log /tmp/dgate-order.log)"
fi
echo "[gate] 실패 로그(/tmp/dgate-run-*.log)에서 어느 파일·단언이 깨지는지 확인해 코퍼스 처방을 확정한다."
exit 2
