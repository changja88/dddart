#!/usr/bin/env dart
/// dddart 결정적 백스톱 러너 — 단일 엔트리, 검사 51종 인프로세스 실행.
/// 설계: workspace/design/2026-06-12-backstop-design.md (확정 2026-06-12)
///
/// 사용:
///   dart run backstop.dart <대상 프로젝트 루트> [--diff-base <commit>] [--all]
///                          [--only st,im,nm,cy|<검사ID>…] [--update-baseline]
///
/// 종료코드: 0=clean / 1=사용·내부 오류 / 2=blocker(발견 일괄 출력 — fail-fast 금지).
/// 게이트: 구조·명명=added, import=touched의 added 줄, 골격=신규 단위, 순환=전역+베이스라인.
/// 스크립트는 파이프라인 상태(build-state.json)를 모른다 — 컨텍스트는 전부 인자(§1).
library;

import 'dart:io';

import 'src/check_cycles.dart';
import 'src/check_imports.dart';
import 'src/check_naming.dart';
import 'src/check_structure.dart';
import 'src/common.dart';

const _totalChecks = 52; // ST12 + IM22 + NM17 + CY1

void main(List<String> argv) {
  String? targetPath;
  String? diffBase;
  var allMode = false;
  var updateBaseline = false;
  final only = <String>{};

  for (var i = 0; i < argv.length; i++) {
    final a = argv[i];
    switch (a) {
      case '--diff-base':
        diffBase = argv[++i];
      case '--all':
        allMode = true;
      case '--update-baseline':
        updateBaseline = true;
      case '--only':
        only.addAll(argv[++i].split(',').map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty));
      default:
        if (a.startsWith('--')) {
          stderr.writeln('[backstop] 사용 오류: 알 수 없는 옵션 $a');
          exit(1);
        }
        targetPath = a;
    }
  }
  if (targetPath == null) {
    stderr.writeln('사용: dart run backstop.dart <대상 프로젝트 루트> '
        '[--diff-base <commit>] [--all] [--only st,im,nm,cy] [--update-baseline]');
    exit(1);
  }

  final root = Directory(targetPath);
  if (!root.existsSync()) {
    stderr.writeln('[backstop] 사용 오류: 디렉터리 아님 — $targetPath');
    exit(1);
  }

  bool familyOn(String fam) =>
      only.isEmpty || only.contains(fam) || only.any((o) => o.startsWith(fam) && o.length > 2);
  bool idOn(String id) {
    if (only.isEmpty) return true;
    final l = id.toLowerCase();
    final fam = l.substring(0, 2);
    return only.contains(l) || only.contains(fam);
  }

  final ctx = BackstopContext.build(root: root, diffBase: diffBase, allMode: allMode);

  if (!ctx.gitRepo) {
    ctx.notices.add('[info] git 저장소 아님 — 게이트 불가, 전역 검사로 퇴화(레거시 발견 폭주 가능). '
        'G0의 git init+초기 커밋 제안이 정답 경로(설계 §3·§8).');
  } else if (diffBase == null && !allMode) {
    ctx.notices.add('[info] --diff-base 없음 — 게이트 불가, 전역 검사로 퇴화. '
        '파이프라인 호출은 Phase 2 진입 스냅샷을 주입한다(설계 §8).');
  }

  final findings = <Finding>[];
  try {
    if (familyOn('st')) findings.addAll(runStructure(ctx));
    if (familyOn('im')) findings.addAll(runImports(ctx));
    if (familyOn('nm')) findings.addAll(runNaming(ctx));
    if (familyOn('cy')) findings.addAll(runCycles(ctx, updateBaseline: updateBaseline));
  } catch (e, st) {
    stderr.writeln('[backstop] 내부 오류: $e\n$st');
    exit(1);
  }

  final shown = findings.where((f) => idOn(f.checkId)).toList()
    ..sort((a, b) {
      final c = a.checkId.compareTo(b.checkId);
      if (c != 0) return c;
      final p = a.path.compareTo(b.path);
      if (p != 0) return p;
      return (a.line ?? 0).compareTo(b.line ?? 0);
    });

  for (final n in ctx.notices) {
    stdout.writeln(n);
  }
  if (ctx.notices.isNotEmpty) stdout.writeln('');
  for (final f in shown) {
    stdout.writeln(f);
    stdout.writeln('');
  }
  final mode = ctx.gated ? 'gated(diff-base ${diffBase!.substring(0, diffBase.length < 8 ? diffBase.length : 8)})' : (allMode ? 'all' : '전역 퇴화');
  stdout.writeln('[backstop] 검사 $_totalChecks종($mode) — blocker ${shown.length}건');
  exit(shown.isEmpty ? 0 : 2);
}
