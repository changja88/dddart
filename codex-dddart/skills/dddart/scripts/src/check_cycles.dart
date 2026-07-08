/// CY1 — BC 순환 래칫 (설계 §5 CY). 게이트: 전역 + 베이스라인.
///
/// *왜 결정적 백스톱인가*: 순환은 두 BC의 합작이라 touched 한정이 불가능한 유일한
/// 검사다. BC import 그래프(합법 4채널 포함 — §9-15는 채널 무관)의 SCC에서 같은
/// 컴포넌트에 속한 무순서쌍을 산출하고, 베이스라인(`.dddart/backstop-baseline.json`,
/// 커밋 대상)에 없는 신규 쌍만 blocker. 쌍 단위인 이유: 경로는 리팩터링으로 형태가
/// 바뀌어도 같은 순환이 남는다 — "A와 B가 서로에게 닿는가"가 안정적 최소 단위.
library;

import 'dart:convert';
import 'dart:io';

import 'common.dart';

List<Finding> runCycles(BackstopContext ctx, {required bool updateBaseline}) {
  final out = <Finding>[];

  // BC 그래프 (전역 — 게이트 없음)
  final edges = <String, Set<String>>{};
  for (final f in ctx.dartFiles) {
    final a = bcOf(f, ctx.areas);
    if (a == null) continue;
    for (final e in ctx.edgesOf(f)) {
      if (e.type != TargetType.internal) continue;
      final b = bcOf(e.target!, ctx.areas);
      if (b != null && b != a) edges.putIfAbsent(a, () => {}).add(b);
    }
  }
  final nodes = <String>{...edges.keys, for (final s in edges.values) ...s};

  // Tarjan SCC
  final pairs = _sccPairs(nodes, edges);

  final baselineFile = File('${ctx.root.path}/.dddart/backstop-baseline.json');
  Set<String> baseline = {};
  if (baselineFile.existsSync()) {
    final j = jsonDecode(baselineFile.readAsStringSync()) as Map<String, dynamic>;
    baseline = {for (final p in (j['cycle_pairs'] as List)) ((p as List).cast<String>()..sort()).join('|')};
  }

  String pairKey(List<String> p) => (List<String>.from(p)..sort()).join('|');
  final current = {for (final p in pairs) pairKey(p)};

  if (!baselineFile.existsSync()) {
    baselineFile.parent.createSync(recursive: true);
    _write(baselineFile, current);
    ctx.notices.add('[info] CY1 베이스라인 생성 — 현재 순환 쌍 ${current.length}개 동결 '
        '(.dddart/backstop-baseline.json — 커밋하고 다음 게이트 배너에 표면화할 것)');
    return out;
  }
  if (updateBaseline) {
    _write(baselineFile, current);
    ctx.notices.add('[info] CY1 베이스라인 갱신 — ${baseline.length}쌍 → ${current.length}쌍');
    return out;
  }

  for (final key in current.difference(baseline)) {
    final p = key.split('|');
    out.add(Finding('CY1', 'application/${p[0]} ↔ application/${p[1]}', null,
        'BC 신규 순환 — `${p[0]}`와 `${p[1]}`가 서로에게 닿는다(직·간접)', '제1 규약 §9-15',
        '합법 채널 import의 조합도 순환이면 blocker다 — 한쪽 의존을 끊는다: 화면 이동이면 root 경유 딥링크(`rootRouter.go`)로, '
        '데이터면 방향을 정해 한쪽만 UseCase를 호출하게. 의도된 구조면 사용자 승인 후 --update-baseline.'));
  }
  final stale = baseline.difference(current);
  if (stale.isNotEmpty) {
    ctx.notices.add('[info] CY1 베이스라인에 있으나 현재 미발생인 쌍 ${stale.length}개'
        '(${stale.map((s) => s.replaceAll('|', '↔')).join(', ')}) — --update-baseline 권장(래칫 되감기)');
  }
  return out;
}

void _write(File f, Set<String> pairKeys) {
  final pairs = (pairKeys.toList()..sort()).map((k) => k.split('|')).toList();
  f.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert({'cycle_pairs': pairs})}\n');
}

List<List<String>> _sccPairs(Set<String> nodes, Map<String, Set<String>> edges) {
  var index = 0;
  final idx = <String, int>{};
  final low = <String, int>{};
  final onStack = <String>{};
  final stack = <String>[];
  final pairs = <List<String>>[];

  void strongConnect(String v) {
    idx[v] = low[v] = index++;
    stack.add(v);
    onStack.add(v);
    for (final w in edges[v] ?? const <String>{}) {
      if (!idx.containsKey(w)) {
        strongConnect(w);
        low[v] = low[v]!.compareTo(low[w]!) < 0 ? low[v]! : low[w]!;
      } else if (onStack.contains(w)) {
        low[v] = low[v]!.compareTo(idx[w]!) < 0 ? low[v]! : idx[w]!;
      }
    }
    if (low[v] == idx[v]) {
      final comp = <String>[];
      String w;
      do {
        w = stack.removeLast();
        onStack.remove(w);
        comp.add(w);
      } while (w != v);
      if (comp.length > 1) {
        comp.sort();
        for (var i = 0; i < comp.length; i++) {
          for (var j = i + 1; j < comp.length; j++) {
            pairs.add([comp[i], comp[j]]);
          }
        }
      }
    }
  }

  for (final v in nodes) {
    if (!idx.containsKey(v)) strongConnect(v);
  }
  return pairs;
}
