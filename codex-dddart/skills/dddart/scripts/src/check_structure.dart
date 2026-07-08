/// ST — 구조·경로 12종 (설계 §5). 게이트: added 파일·added 디렉터리, ST4만 신규 단위.
///
/// *왜 결정적 백스톱인가*: 트리의 형태(어떤 폴더·어떤 직속 파일이 합법인가)는 제1 규약
/// §2·§5가 전수 화이트리스트로 정의한다 — LLM 판단이 0인 영역이며, 위반은 항상
/// "규약 밖 경로의 존재"라는 기계적 사실이다. 거짓양성 게이트 = added 한정(레거시 면책).
library;

import 'dart:io';

import 'common.dart';

const _rule2 = '제1 규약 §2 표준 트리';
const _rule5 = '제1 규약 §5 골격 완비';

List<Finding> runStructure(BackstopContext ctx) {
  final out = <Finding>[];
  final addedFiles = ctx.dartFiles.where(ctx.isAdded).toList();
  // .gitkeep 등 비dart 파일도 직속 검사 대상이어야 하므로 디렉터리 직속은 fs로 본다.

  // ---- ST0: lib/ 직속 화이트리스트
  for (final f in addedFiles.where((f) => !f.contains('/'))) {
    if (f != 'main.dart') {
      out.add(Finding('ST0', f, null,
          'lib/ 직속 허용 외 파일 — 허용: main.dart·firebase_options.dart·4컨테이너(root/application/common/design_system)',
          _rule2,
          '내용의 정체대로 재배치한다 — BC 코드면 application/<bc>/, 조립이면 root/, 횡단이면 common/, 시각이면 design_system/.'));
    }
  }
  for (final d in ctx.allDirs.where((d) => !d.contains('/'))) {
    if (!{'root', 'application', 'common', 'design_system', 'l10n'}.contains(d) &&
        ctx.isAddedDir(d)) {
      out.add(Finding('ST0', d, null,
          'lib/ 직속 허용 외 디렉터리 `$d/` — 4컨테이너 외 최상위 폴더 금지', _rule2,
          '기능 코드는 application/<bc>/ 4계층으로, 공용은 common/·design_system/으로.'));
    }
  }

  // ---- ST1: application/ 직속 파일 금지
  // area 직속 파일은 별도 불요 — 직속 파일이 있으면 area로 판별되지 않아(보수 폴백,
  // feedback-031) 그 폴더는 BC 취급 → ST2/ST4가 발화한다.
  for (final f in addedFiles) {
    final s = segsOf(f);
    if (s.length == 2 && s[0] == 'application') {
      out.add(Finding('ST1', f, null,
          'application/ 직속 파일 — 직속은 BC(또는 area) 디렉터리만', _rule2,
          '소속 BC를 정해 application/<bc>/ 안으로 옮긴다(라우터·내비게이터면 그 BC 직속).'));
    }
  }

  // ---- ST2: BC 직속 파일 2종 + <bc> 바인딩 (area 하위 BC 포함 — feedback-031)
  for (final f in addedFiles) {
    final s = segsOf(f);
    if (s[0] != 'application') continue;
    final bi = (s.length > 2 && ctx.areas.contains(s[1])) ? 2 : 1;
    if (s.length == bi + 2) {
      final bc = s[bi];
      final name = s.last;
      if (name != '${bc}_router.dart' && name != '${bc}_navigator.dart') {
        out.add(Finding('ST2', f, null,
            'BC 직속 허용 외 파일 — 허용은 `${bc}_router.dart`·`${bc}_navigator.dart` 2종(접두=BC 폴더명)뿐',
            '제1 규약 §3.1', '계층 폴더 안 제자리로 옮기거나, 라우팅 짝이면 BC명 접두로 개명한다.'));
      }
    }
  }

  // ---- ST3: BC 1뎁스 = 4계층 화이트리스트 (area 하위 BC 포함 — feedback-031)
  for (final d in ctx.allDirs) {
    final s = segsOf(d);
    if (s[0] != 'application') continue;
    final bi = (s.length > 2 && ctx.areas.contains(s[1])) ? 2 : 1;
    if (s.length == bi + 2 && !layerNames.contains(s.last) && ctx.isAddedDir(d)) {
      out.add(Finding('ST3', d, null,
          'BC 직속 허용 외 디렉터리 `${s.last}/` — 4계층 고정 표기만(domain_layer·application_layer·infra_layer·presentation_layer)${_typoHint(s.last, layerNames)}',
          _rule2, '4계층 중 정체에 맞는 폴더로 옮기고 오타면 표기를 교정한다.'));
    }
  }

  // ---- ST5: domain_layer 직속·애그리거트 폴더 내부
  for (final f in addedFiles) {
    final s = segsOf(f);
    final di = s.indexOf('domain_layer');
    if (s[0] != 'application' || di < 0) continue;
    if (di == s.length - 2) {
      out.add(Finding('ST5', f, null,
          'domain_layer 직속 파일 — 직속은 `<aggregate>/` 디렉터리만', '제1 규약 §3.2',
          '애그리거트 폴더(기본값: BC 동명)를 만들어 그 안으로.'));
    } else if (di == s.length - 3) {
      final agg = s[di + 1];
      final name = s.last;
      if (name != '$agg.dart' && name != 'exception.dart') {
        out.add(Finding('ST5', f, null,
            '애그리거트 폴더 직속 허용 외 파일 — 허용은 `$agg.dart`(루트)·`exception.dart`뿐',
            '제1 규약 §3.2', '5종 폴더(entity·value_object·enum·domain_service·specification) 중 제자리로.'));
      }
    }
  }
  for (final d in ctx.allDirs) {
    final s = segsOf(d);
    final di = s.indexOf('domain_layer');
    if (s[0] != 'application' || di < 0 || !ctx.isAddedDir(d)) continue;
    if (di == s.length - 3 && !domainKinds.contains(s.last)) {
      out.add(Finding('ST5', d, null,
          '애그리거트 하위 허용 외 디렉터리 `${s.last}/` — 5종 폴더만${_typoHint(s.last, domainKinds)}',
          '제1 규약 §3.2', 'entity·value_object·enum·domain_service·specification 중 정체에 맞게.'));
    }
  }

  // ---- ST6: 계층/개념 폴더 직속 종류 화이트리스트 (+infra 평면, area 하위 BC 포함)
  for (final d in ctx.allDirs) {
    final s = segsOf(d);
    if (s[0] != 'application' || !ctx.isAddedDir(d)) continue;
    final bi = (s.length > 2 && ctx.areas.contains(s[1])) ? 2 : 1;
    if (s.length < bi + 3) continue;
    final layer = s[bi + 1];
    final name = s.last;
    if (layer == 'application_layer' || layer == 'presentation_layer') {
      final kinds = layer == 'application_layer' ? appKinds : presKinds;
      if (s.length == bi + 3) continue; // 계층 직속 비종류 디렉터리 = 개념 폴더(합법, §4)
      if (s.length == bi + 4 && !kinds.contains(name)) {
        out.add(Finding('ST6', d, null,
            '개념 폴더 하위 허용 외 디렉터리 `$name/` — ${layer == 'application_layer' ? 'app 5종' : 'pres 4종'}만${_typoHint(name, kinds)}',
            '제1 규약 §4·§5', '종류 폴더 표기로 교정하거나 제자리로 옮긴다.'));
      }
    } else if (layer == 'infra_layer') {
      if (s.length == bi + 3 && !infraKinds.contains(name)) {
        out.add(Finding('ST6', d, null,
            'infra_layer 직속 허용 외 디렉터리 `$name/` — infra는 평면 유지(개념 폴더 금지), 3종(data_source·repository·service)만${_typoHint(name, infraKinds)}',
            '제1 규약 §4', 'HaffHaff 16개 BC 전수에서 infra는 평면 — 종류 3폴더로 정리한다.'));
      }
    }
  }

  // ---- ST7: 구명칭 디렉터리 deny + BC·area 이름 deny(계층·컨테이너명 — feedback-031)
  const bcDeny = {'app', 'bridge', 'block', 'viewmodel', 'repo', 'container'};
  const nameDeny = {...layerNames, 'root', 'application', 'common', 'design_system'};
  for (final d in ctx.allDirs.where(ctx.isAddedDir)) {
    final s = segsOf(d);
    if (s[0] == 'application' && s.length > 2 && bcDeny.contains(s.last)) {
      out.add(Finding('ST7', d, null, '구명칭 디렉터리 `${s.last}/`', '제1 규약 §8·§9-8',
          'app→use_case, bridge→shared_state, block→section, viewmodel→view_model, repo→repository, container→view/section/widget 정리.'));
    }
    if (s[0] == 'application' &&
        (s.length == 2 || (s.length == 3 && ctx.areas.contains(s[1]))) &&
        nameDeny.contains(s.last)) {
      out.add(Finding('ST7', d, null,
          'BC·area 이름 `${s.last}/` — 계층명·컨테이너명은 BC·area 이름으로 금지(경로 판별 오염)',
          '제1 규약 §2', '기능 어휘로 개명한다 — 계층·컨테이너명은 트리의 예약어다.'));
    }
    if (s[0] == 'common' && s.length == 2 && s.last == 'provider') {
      out.add(Finding('ST7', d, null, 'common/provider/ — 폐지된 종류(2026-06-12)', '제1 규약 §9-11',
          '정체대로 재배치 — BC 어휘면 그 BC shared_state, 전 BC 배선이면 root/.'));
    }
  }

  // ---- ST8: root 직속·scaffold 직속
  const rootDirs = {'router', 'scaffold', 'handler', 'initializer'};
  for (final f in addedFiles) {
    final s = segsOf(f);
    if (s.length == 2 && s[0] == 'root') {
      out.add(Finding('ST8', f, null, 'root/ 직속 파일 — 직속은 역할 4폴더만', '제1 규약 §3.6',
          'router/·scaffold/·handler/·initializer/ 중 역할에 맞는 폴더로.'));
    }
  }
  for (final d in ctx.allDirs.where(ctx.isAddedDir)) {
    final s = segsOf(d);
    if (s.length == 2 && s[0] == 'root' && !rootDirs.contains(s[1])) {
      out.add(Finding('ST8', d, null,
          'root/ 직속 허용 외 디렉터리 `${s[1]}/` — 역할 4폴더만${_typoHint(s[1], rootDirs)}',
          '제1 규약 §3.6', 'router/·scaffold/·handler/·initializer/로 정리.'));
    }
    if (s.length == 3 && s[0] == 'root' && s[1] == 'scaffold' && !{'view', 'view_model', 'state'}.contains(s[2])) {
      out.add(Finding('ST8', d, null,
          'scaffold/ 직속 허용 외 디렉터리 `${s[2]}/` — view·view_model·state 3종만', '제1 규약 §3.6',
          '삼총사 종류 폴더로 정리한다.'));
    }
  }

  // ---- ST9: root_ 접두
  for (final f in addedFiles) {
    final s = segsOf(f);
    if (s[0] == 'root' && !baseNameOf(f).startsWith('root_')) {
      out.add(Finding('ST9', f, null, 'root/ 이하 파일명 `root_` 접두 위반', '제1 규약 §3.6',
          'root_<이름>으로 개명 — BC 코드의 `import …root_…` 한 줄로 위반이 식별되는 설계.'));
    }
  }

  // ---- ST10: design_system
  const foundation7 = {
    'app_color.dart', 'app_typography.dart', 'app_spacing.dart', 'app_radius.dart',
    'app_shadow.dart', 'app_duration.dart', 'app_asset.dart'
  };
  for (final f in addedFiles) {
    final s = segsOf(f);
    if (s[0] != 'design_system') continue;
    if (s.length == 3 && s[1] == 'foundation' && !foundation7.contains(s[2])) {
      out.add(Finding('ST10', f, null,
          'foundation 표준 7파일 외 — 새 토큰 종류는 규약 개정이 먼저(시각 값 단일 출처 보호)',
          '제1 규약 §6', '기존 7파일 중 해당 토큰으로 합치거나 규약 개정을 제안한다.'));
    }
    if (s.length == 3 && s[1] == 'theme' && s[2] != 'app_theme.dart') {
      out.add(Finding('ST10', f, null, 'theme/ 직속은 app_theme.dart만', '제1 규약 §6',
          'ThemeData 조립은 app_theme.dart 하나로 — light/dark도 그 안의 확장점.'));
    }
    if (s.length == 3 && s[1] == 'component') {
      out.add(Finding('ST10', f, null, 'component/ 직속 파일 금지 — 부품군 1차', '제1 규약 §6',
          '부품군 폴더(button/·dialog/ 등)를 만들어 그 안으로.'));
    }
  }
  for (final d in ctx.allDirs.where(ctx.isAddedDir)) {
    final s = segsOf(d);
    if (s.length == 3 && s[0] == 'design_system' && s[1] == 'component' &&
        {'widget', 'etc', 'common', 'misc'}.contains(s[2])) {
      out.add(Finding('ST10', d, null, 'component/ 정크드로어 군 `${s[2]}/` 금지', '제1 규약 §6',
          '분류 안 되는 부품은 정크드로어가 아니라 새 부품군 폴더를 만든다.'));
    }
  }

  // ---- ST11: common 직속 5종
  const common5 = {'enum', 'network', 'local_database', 'service', 'util'};
  for (final f in addedFiles) {
    final s = segsOf(f);
    if (s.length == 2 && s[0] == 'common') {
      out.add(Finding('ST11', f, null, 'common/ 직속 파일 금지 — 5종 폴더만', '제1 규약 §6',
          'enum·network·local_database·service·util 중 정체에 맞는 폴더로.'));
    }
  }
  for (final d in ctx.allDirs.where(ctx.isAddedDir)) {
    final s = segsOf(d);
    if (s.length == 2 && s[0] == 'common' && !common5.contains(s[1])) {
      out.add(Finding('ST11', d, null,
          'common/ 직속 허용 외 디렉터리 `${s[1]}/` — 5종만${_typoHint(s[1], common5)}',
          '제1 규약 §6·§9-11', '입장 판별(§6)대로 — BC 어휘면 그 BC로, 조립이면 root/로, 그 외 5종 중 하나로.'));
    }
  }

  // ---- ST4: 신규 단위 골격 완비
  if (!ctx.canDetectNewUnits) {
    ctx.notices.add('[info] ST4(골격 완비) 생략 — git 기준점 없음(신규 단위 판별 불가, §3)');
  } else {
    out.addAll(_skeleton(ctx));
  }

  return out;
}

// ---------------------------------------------------------------- ST4 구현

List<Finding> _skeleton(BackstopContext ctx) {
  final out = <Finding>[];
  final lib = '${ctx.root.path}/lib';

  void requireUnit(String unitDir, String unitDesc, Map<String, Set<String>> layerKinds,
      {List<String> requiredFiles = const []}) {
    final missing = <String>[];
    for (final e in layerKinds.entries) {
      final layerPath = e.key.isEmpty ? unitDir : '$unitDir/${e.key}';
      if (!Directory('$lib/$layerPath').existsSync()) {
        missing.add('${e.key.isEmpty ? '' : '${e.key}/'} (계층/단위 폴더 없음)');
        continue;
      }
      for (final k in e.value) {
        final kd = Directory('$lib/$layerPath/$k');
        if (!kd.existsSync()) {
          missing.add('${e.key.isEmpty ? '' : '${e.key}/'}$k/');
        } else if (kd.listSync().isEmpty) {
          missing.add('${e.key.isEmpty ? '' : '${e.key}/'}$k/.gitkeep (빈 폴더 유지)');
        }
      }
    }
    for (final rf in requiredFiles) {
      if (!File('$lib/$unitDir/$rf').existsSync()) missing.add(rf);
    }
    if (missing.isNotEmpty) {
      out.add(Finding('ST4', unitDir, null,
          '$unitDesc 골격 미완비 — 누락: ${missing.join(', ')}', _rule5,
          '비어 있어도 표준 종류 폴더 전부+.gitkeep을 생성한다 — 폴더는 무조건, 코드는 필요할 때만.'));
    }
  }

  // 신규 BC (area 하위 포함 — feedback-031: `application/<bc>` 또는 `application/<area>/<bc>`)
  for (final d in ctx.allDirs) {
    final s = segsOf(d);
    final isBc = s[0] == 'application' &&
        ((s.length == 2 && !ctx.areas.contains(s[1])) ||
            (s.length == 3 && ctx.areas.contains(s[1])));
    if (isBc && ctx.isAddedDir(d)) {
      final bcName = s.last;
      final bcDir = d;
      // 4계층 + 계층별 종류
      requireUnit(bcDir, '신규 BC `$bcName`', {
        'application_layer': appKinds,
        'infra_layer': infraKinds,
        'presentation_layer': presKinds,
        'domain_layer': {},
      }, requiredFiles: const ['analysis_options.yaml']); // 타입 전면강제 국소 lint(houserules §3·decision A)
      // domain: 애그리거트 ≥1 + 각 애그리거트 완비
      final domDir = Directory('$lib/$bcDir/domain_layer');
      if (domDir.existsSync()) {
        final aggs = domDir.listSync().whereType<Directory>().toList();
        if (aggs.isEmpty) {
          out.add(Finding('ST4', '$bcDir/domain_layer', null,
              '신규 BC `$bcName` domain_layer에 애그리거트 폴더 없음 — 기본값은 BC 동명 애그리거트',
              _rule5, '`domain_layer/$bcName/` + `$bcName.dart` + 5종 폴더를 생성한다.'));
        }
      }
    }
  }
  // 신규 애그리거트 (신규 BC 내부 포함 — 단위 중복 보고는 무해하므로 단순 유지.
  // domain_layer 상대 판별이라 area 깊이 무관)
  for (final d in ctx.allDirs) {
    final s = segsOf(d);
    final di = s.indexOf('domain_layer');
    if (s[0] == 'application' && di >= 0 && di == s.length - 2 && ctx.isAddedDir(d)) {
      requireUnit(d, '신규 애그리거트 `${s.last}`', {'': domainKinds},
          requiredFiles: ['${s.last}.dart']);
    }
  }
  // 신규 개념 폴더 (app·pres — area 하위 BC 포함)
  for (final d in ctx.allDirs) {
    final s = segsOf(d);
    if (s[0] != 'application' || !ctx.isAddedDir(d)) continue;
    final bi = (s.length > 2 && ctx.areas.contains(s[1])) ? 2 : 1;
    if (s.length == bi + 3) {
      if (s[bi + 1] == 'application_layer' && !appKinds.contains(s.last)) {
        requireUnit(d, '신규 개념 폴더 `${s.last}`(application)', {'': appKinds});
      }
      if (s[bi + 1] == 'presentation_layer' && !presKinds.contains(s.last)) {
        requireUnit(d, '신규 개념 폴더 `${s.last}`(presentation)', {'': presKinds});
      }
    }
  }
  // root 신설
  if (ctx.allDirs.contains('root') && ctx.isAddedDir('root')) {
    requireUnit('root', '신규 합성 루트', {
      '': {'router', 'scaffold', 'handler', 'initializer'},
      'scaffold': {'view', 'view_model', 'state'},
    }, requiredFiles: const ['analysis_options.yaml']); // 타입 전면강제 국소 lint(houserules §3·decision A)
  }
  // design_system 신설
  if (ctx.allDirs.contains('design_system') && ctx.isAddedDir('design_system')) {
    requireUnit('design_system', '신규 design_system', {
      '': {'foundation', 'theme', 'component', 'util'},
    }, requiredFiles: [
      'analysis_options.yaml', // 타입 전면강제 국소 lint(houserules §3·decision A)
      for (final t in ['color', 'typography', 'spacing', 'radius', 'shadow', 'duration', 'asset'])
        'foundation/app_$t.dart'
    ]);
  }
  return out;
}

/// 종류 폴더 오타 보조 진단(§4-8) — 편집거리 1 이내면 메시지에 힌트 병기.
String _typoHint(String name, Set<String> candidates) {
  for (final c in candidates) {
    if (_editDistance1(name, c)) return ' — `$c/` 오타 의심';
  }
  return '';
}

bool _editDistance1(String a, String b) {
  if (a == b) return false;
  if ((a.length - b.length).abs() > 1) return false;
  var i = 0, j = 0, edits = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      i++;
      j++;
      continue;
    }
    if (++edits > 1) return false;
    if (a.length > b.length) {
      i++;
    } else if (a.length < b.length) {
      j++;
    } else {
      i++;
      j++;
    }
  }
  return edits + (a.length - i) + (b.length - j) <= 1;
}
