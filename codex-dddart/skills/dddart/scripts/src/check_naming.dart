/// NM — 식별자·명명 17종 (설계 §5 + NM17 view fat). 게이트: added 파일.
///
/// *왜 결정적 백스톱인가*: 종류 폴더↔접미사↔클래스명의 3중 일치(제1 규약 §7)는
/// casefold 문자열 비교로 환원된다. 본문 검사(NM9·NM10·NM13)는 주석·문자열 마스킹
/// 본문(§4-2) + 괄호 균형 스캔(§4-6)으로 멀티라인·제네릭 변형까지 버틴다.
/// 거짓양성 게이트 = added 한정 + 검사별 명시 예외(router·exception.dart).
/// hive는 예외가 아니라 정식 종류다 — data_source/local_storage/에 접근(_local_data_source)·
/// 스키마(_box·파일당 1모델)·배선(_hive_adapters·클래스 0)이 살고, 내용 검사는 HV 소유(feedback-032).
library;


import 'common.dart';

// 접미사 → 종류 (긴 것 우선 매칭용으로 정렬해 사용)
const _suffixKind = {
  '_local_data_source.dart': 'local_storage(접근)',
  '_hive_adapters.dart': 'local_storage(배선)',
  '_shared_state.dart': 'shared_state',
  '_ui_extension.dart': 'ui_extension',
  '_specification.dart': 'specification',
  '_data_source.dart': 'data_source',
  '_use_case.dart': 'use_case',
  '_section.dart': 'section',
  '_service.dart': 'service',
  '_handler.dart': 'handler',
  '_widget.dart': 'widget',
  '_state.dart': 'state',
  '_view.dart': 'view',
  '_repo.dart': 'repository',
  '_box.dart': 'local_storage(스키마)',
  '_vm.dart': 'view_model',
};

// 종류 폴더 → 허용 접미사 집합
const _kindSuffixes = <String, List<String>>{
  'use_case': ['_use_case.dart'],
  'view_model': ['_vm.dart'],
  'state': ['_state.dart'],
  'shared_state': ['_shared_state.dart'],
  'service': ['_service.dart'],
  'data_source': ['_data_source.dart'],
  'local_storage': ['_local_data_source.dart', '_box.dart', '_hive_adapters.dart'],
  'repository': ['_repo.dart'],
  'view': ['_view.dart'],
  'section': ['_section.dart'],
  'widget': ['_widget.dart'],
  'ui_extension': ['_ui_extension.dart'],
  'domain_service': ['_service.dart'],
  'specification': ['_specification.dart'],
  'handler': ['_handler.dart'],
};

/// top-level 선언 파서(NM3·NM14·NM16 공유) — 수식어 무시, plain extension·typedef·
/// 전역 함수/변수는 카운트 제외(설계 NM3 확정 — "클래스 1+동반 extension" 합법 패턴 통과).
final _declRe = RegExp(
    r'(?:^|\n)[ \t]*(?:(?:abstract|sealed|final|base|interface)[ \t]+)*(class|enum|extension[ \t]+type|mixin(?:[ \t]+class)?)[ \t]+([A-Za-z_$][\w$]*)');

List<(String kind, String name, int line)> topLevelDecls(MaskedSource ms) {
  final out = <(String, String, int)>[];
  for (final m in _declRe.allMatches(ms.tokensView)) {
    final kind = m.group(1)!.replaceAll(RegExp(r'[ \t]+'), ' ');
    out.add((kind, m.group(2)!, ms.lineOf(m.start)));
  }
  return out;
}

/// NM17 — view 파일에서 위젯을 빌드해 반환하는 top-level 함수의 흔한 반환형(이름에 Widget이
/// 없는 구체 위젯). 반환형에 `Widget`이 포함되면(Widget·Widget?·List<Widget>·PreferredSizeWidget…)
/// 이 집합과 무관하게 잡는다 — 이 집합은 Widget 토큰이 없는 구체 위젯 반환을 보완한다.
const _widgetReturnTypes = {
  'Column', 'Row', 'Stack', 'Scaffold', 'Padding', 'Container', 'SizedBox',
  'Center', 'Align', 'Expanded', 'Flexible', 'ListView', 'GridView', 'Wrap',
  'Card', 'Material', 'AppBar', 'SingleChildScrollView', 'CustomScrollView',
  'SliverList', 'SliverToBoxAdapter', 'Positioned', 'ConstrainedBox',
  'ColoredBox', 'DecoratedBox', 'FittedBox', 'AspectRatio', 'Form', 'Table', 'Flex',
};

/// 이름에 `Widget`을 포함하지만 렌더링 위젯이 아닌 프레임워크 타입 — NM17 함수 검사의 거짓양성 방지.
const _nonWidgetReturnTypes = {
  'WidgetRef', 'WidgetsBinding', 'WidgetState', 'WidgetStateProperty',
  'WidgetStatesController', 'WidgetTester',
};

List<Finding> runNaming(BackstopContext ctx) {
  final out = <Finding>[];
  final added = ctx.dartFiles.where(ctx.isAdded).toList();

  // BC별 view 접두 수집(파일시스템 기준 — NM4·5·6, 같은 슬라이스 동시 생성 합법)
  final viewPrefixes = <String, Set<String>>{}; // bc(또는 'root') → 접두
  for (final f in ctx.dartFiles) {
    if (parentDirOf(f) == 'view' && baseNameOf(f).endsWith('_view.dart')) {
      final owner = bcOf(f, ctx.areas) ?? (f.startsWith('root/scaffold/') ? 'root' : '');
      if (owner.isEmpty) continue;
      viewPrefixes.putIfAbsent(owner, () => {}).add(
          baseNameOf(f).substring(0, baseNameOf(f).length - '_view.dart'.length));
    }
  }

  for (final f in added) {
    final segs = segsOf(f);
    final base = baseNameOf(f);
    final parent = parentDirOf(f);
    final bc = bcOf(f, ctx.areas);
    final inApp = hasSeg(f, 'application_layer');
    final isRouter = base.endsWith('_router.dart') &&
        (isBcRootPath(f, ctx.areas) || f == 'root/router/root_router.dart');

    // ---- NM1: 종류 폴더 ↔ 접미사 (긴 접미사 우선)
    final kindOfFolder = _kindSuffixes[parent];
    if (kindOfFolder != null && _folderContextOk(f, parent)) {
      String? fileKind;
      for (final s in _suffixKind.keys) {
        if (base.endsWith(s)) {
          fileKind = s;
          break; // map 정의 순서 = 긴 것 우선
        }
      }
      final ok = fileKind != null && kindOfFolder.contains(fileKind);
      if (!ok) {
        out.add(Finding('NM1', f, null,
            '`$parent/` 안 파일 접미사 불일치 — 허용: ${kindOfFolder.join('·')}'
            '${fileKind != null ? ' (현재 접미사는 ${_suffixKind[fileKind]} 종류)' : ''}',
            '제1 규약 §7.1-2', '종류는 폴더가 결정하고 접미사가 재확인한다 — 접미사를 폴더 종류에 맞춘다.'));
      }
    }

    // ---- NM2: 구접미사 deny
    for (final deny in ['_app.dart', '_bridge.dart', '_block.dart', '_view_state.dart', '_spec.dart', '_btn.dart']) {
      if (base.endsWith(deny)) {
        out.add(Finding('NM2', f, null, '구접미사 `$deny`', '제1 규약 §8·§9-8',
            '_app→_use_case, _bridge→_shared_state, _block→_section, _view_state→_state, _spec→_specification, _btn→_button.'));
      }
    }

    final ms = ctx.maskOf(f);
    final decls = topLevelDecls(ms);
    final publicDecls = decls.where((d) => !d.$2.startsWith('_')).toList();

    // ---- NM3: 파일당 public 선언 1개 + 파일명=클래스명 casefold
    if (base != 'exception.dart' && !isRouter) {
      if (publicDecls.length > 1) {
        out.add(Finding('NM3', f, publicDecls[1].$3,
            'top-level public 선언 ${publicDecls.length}개(${publicDecls.map((d) => d.$2).join(', ')}) — 한 파일 한 클래스',
            '제1 규약 §7.1-1', '두 번째 선언을 자기 파일로 분리한다(plain extension·typedef는 동거 합법).'));
      } else if (publicDecls.length == 1) {
        final name = publicDecls.first.$2;
        if (casefold(name) != casefold(base.substring(0, base.length - 5))) {
          out.add(Finding('NM3', f, publicDecls.first.$3,
              '클래스명 `$name` ≠ 파일명(casefold) — 파일명 = 주 클래스명 snake_case',
              '제1 규약 §7.1-1', '파일명 또는 클래스명을 일치시킨다.'));
        }
      }
    }

    // ---- NM4: 삼총사(VM 기준 단방향)
    if (parent == 'view_model' && base.endsWith('_vm.dart') &&
        (inApp || f.startsWith('root/scaffold/'))) {
      final prefix = base.substring(0, base.length - '_vm.dart'.length);
      final scope = bc != null ? '${bcDirOf(f, ctx.areas)}/' : 'root/scaffold/';
      final hasView = ctx.dartFiles.any((g) => g.startsWith(scope) && baseNameOf(g) == '${prefix}_view.dart');
      final hasState = ctx.dartFiles.any((g) => g.startsWith(scope) && baseNameOf(g) == '${prefix}_state.dart');
      if (!hasView || !hasState) {
        final missing = [if (!hasView) '${prefix}_view.dart', if (!hasState) '${prefix}_state.dart'];
        out.add(Finding('NM4', f, null, '삼총사 미완 — 같은 접두 ${missing.join('·')} 부재',
            '제1 규약 §7.1-3', 'VM이 있으면 view·state가 1:1:1로 대응한다(State 모양 규약은 §10-5 ① 확정 예정).'));
      }
    }

    // ---- NM5: section 접두 = 소속 화면
    if (parent == 'section' && bc != null && base.endsWith('_section.dart')) {
      final prefixes = viewPrefixes[bc] ?? {};
      final ok = prefixes.any((p) => base.startsWith('${p}_'));
      if (!ok) {
        out.add(Finding('NM5', f, null,
            'section 파일명이 같은 BC의 어떤 view 접두로도 시작하지 않음(view: ${prefixes.isEmpty ? '없음' : prefixes.join('·')})',
            '제1 규약 §3.5', 'section은 한 화면 전속 — `<화면>…_section.dart`. 비전속이면 widget이다.'));
      }
    }

    // ---- NM6: widget 파일명에 view 접두 금지(BC명 동일 접두는 제외)
    if (parent == 'widget' && bc != null && base.endsWith('_widget.dart')) {
      for (final p in viewPrefixes[bc] ?? const <String>{}) {
        if (casefold(p) == casefold(bc)) continue; // BC명=화면명은 도메인 어휘와 구별 불가
        if (base.contains(p)) {
          out.add(Finding('NM6', f, null, 'widget 파일명에 화면 이름 `$p` 포함 — 화면 비전속 부품',
              '제1 규약 §3.5', '화면 전속이면 section으로, 진짜 재사용 부품이면 화면 이름을 뗀다.'));
          break;
        }
      }
    }

    // ---- NM7·NM8: @riverpod 허용 위치
    final riverpodHits = scanTokens(ms, RegExp(r'@(riverpod\b|Riverpod\()'));
    if (riverpodHits.isNotEmpty) {
      final allowed = (inApp && {'view_model', 'shared_state', 'service'}.contains(parent)) ||
          f.startsWith('root/scaffold/view_model/') ||
          f.startsWith('root/handler/');
      if (!allowed) {
        final isCommon = segs[0] == 'common';
        out.add(Finding(isCommon ? 'NM8' : 'NM7', f, riverpodHits.first.$1,
            isCommon
                ? 'common에서 @riverpod — common은 살아있는 상태를 갖지 않는다(호출당하는 도구, 행위자 아님)'
                : '@riverpod 허용 위치 외 — VM·SharedState·Service(application) + root scaffold VM·handler뿐',
            isCommon ? '제1 규약 §6·§9-13' : '제1 규약 §9-13',
            isCommon
                ? '정체를 따져 제자리로 — BC 어휘면 그 BC shared_state, 전 BC 배선이면 root.'
                : 'UseCase·Repo·DataSource는 plain class — 사용처에서 직접 생성한다(DI 없음).'));
      }
    }

    // ---- NM9: view의 ref.watch 인자 근사
    if (parent == 'view' && base.endsWith('_view.dart')) {
      final prefix = casefold(base.substring(0, base.length - '_view.dart'.length));
      for (final m in RegExp(r'ref\.(watch|read|listen|listenManual)\s*(?:<[^(]*>)?\s*\(')
          .allMatches(ms.tokensView)) {
        final arg = firstArgOf(ms.tokensView, m.end);
        final ident = RegExp(r'^[A-Za-z_$][\w$]*').firstMatch(arg)?.group(0) ?? '';
        final il = casefold(ident);
        final ok = il.startsWith('${prefix}vmprovider') || il.endsWith('sharedstateprovider');
        if (!ok && ctx.lineIsAdded(f, ms.lineOf(m.start))) {
          out.add(Finding('NM9', f, ms.lineOf(m.start),
              'view가 자기 VM(`${prefix}VMProvider`)·SharedState 외 provider 소비: `$ident`',
              '제1 규약 §3.5·§9-10', '다른 데이터가 필요하면 자기 VM이 UseCase로 가져와 State에 담는다 — view의 watch는 바인딩이지 조회가 아니다.'));
        }
      }
    }

    // ---- NM10: 시각 리터럴 금지
    final inVisualScope = (bc != null && hasSeg(f, 'presentation_layer')) ||
        f.startsWith('design_system/component/') ||
        f.startsWith('root/scaffold/');
    if (inVisualScope) {
      for (final (line, _) in scanTokens(ms, RegExp(r'\bColor\(0x|\bColor\.from|\bTextStyle\('))) {
        out.add(Finding('NM10', f, line, '시각 리터럴(Color 생성자·생 TextStyle) — foundation 토큰만',
            '제1 규약 §6·§9-12', 'AppColor·AppTypography 토큰을 쓴다 — 없는 값이면 foundation에 토큰을 추가하는 것이 먼저.'));
      }
    }

    // ---- NM11: foundation 토큰 표기
    if (segs.length == 3 && segs[0] == 'design_system' && segs[1] == 'foundation') {
      if (publicDecls.length == 1 && !publicDecls.first.$2.startsWith('App')) {
        out.add(Finding('NM11', f, publicDecls.first.$3,
            'foundation 클래스 `${publicDecls.first.$2}` — `App<토큰>` 표기', '제1 규약 §6', 'AppColor·AppSpacing처럼 App 접두.'));
      }
      for (final m in RegExp(r'static\s+const\s+(?:[\w<>, ]+\s+)?([A-Za-z_$][\w$]*)\s*=')
          .allMatches(ms.tokensView)) {
        final name = m.group(1)!;
        if (!name.startsWith('_') && !RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(name)) {
          out.add(Finding('NM11', f, ms.lineOf(m.start),
              '토큰 상수 `$name` — lowerCamelCase', '제1 규약 §6', 'WHITE·Semantic_Green000류 표기 혼재 금지 — lowerCamelCase로.'));
        }
      }
    }

    // ---- NM12: component 부품군 표기
    if (segs.length == 4 && segs[0] == 'design_system' && segs[1] == 'component') {
      final group = segs[2];
      if (base.startsWith('ds_')) {
        out.add(Finding('NM12', f, null, '`ds_` 접두 — 컴포넌트는 무접두(종류 접미사가 구별자)',
            '제1 규약 §6', '접두를 뗀다.'));
      }
      if (base != '$group.dart' && !base.endsWith('_$group.dart')) {
        out.add(Finding('NM12', f, null,
            '부품군 `$group/` 안 파일명 — `*_$group.dart`(기본 부품은 `$group.dart`)',
            '제1 규약 §6', '부품군 폴더 = 파일 접미사 = 클래스 접미사.'));
      }
    }

    // ---- NM13: 라우트 단일 출처 근사
    if (!isRouter) {
      for (final (line, _) in scanTokens(ms, RegExp(r'\bGoRoute\('))) {
        out.add(Finding('NM13', f, line, 'GoRoute 정의가 router 파일 밖에 등장',
            '제1 규약 §3.1', 'GoRoute는 `<bc>_router.dart`가 export하고 root_router가 조립한다.'));
      }
      // 내비 리터럴은 go_router를 실제 import한 파일에서만 검사한다 — push·replace 등은
      // 스택·빌더·VO의 보편 메서드명이라, go_router 미import 파일의 동명 사용자 메서드가
      // 위치 문자열 리터럴을 받으면 거짓양성이 났다(feedback-012 R7·IM22 R1 동형: 합법성 신호 게이트).
      final usesGoRouter = ctx.edgesOf(f).any((e) => e.uri.startsWith('package:go_router/'));
      if (usesGoRouter) {
        for (final m in RegExp(r'\.(go|goNamed|push|pushNamed|pushReplacement|pushReplacementNamed|replace|replaceNamed)\s*\(')
            .allMatches(ms.tokensView)) {
          final arg = firstArgOf(ms.tokensView, m.end);
          if ((arg.startsWith("'") || arg.startsWith('"')) && ctx.lineIsAdded(f, ms.lineOf(m.start))) {
            out.add(Finding('NM13', f, ms.lineOf(m.start),
                '내비 호출에 라우트 문자열 리터럴 직접 전달', '제1 규약 §3.1',
                '라우트 path·name 리터럴은 `<bc>_router.dart` 안에서만 — `<Bc>Routes` 상수를 참조한다.'));
          }
        }
      }
    }

    // ---- NM14: ui_extension은 extension만
    if (parent == 'ui_extension') {
      for (final d in decls) {
        out.add(Finding('NM14', f, d.$3,
            'ui_extension 파일에 top-level `${d.$1}` 선언 — extension만 허용', '제1 규약 §3.5',
            '위젯·상태는 widget/·state/로 — 여기는 도메인 enum·VO → UI 매핑 extension의 자리.'));
      }
    }

    // ---- NM15: 애그리거트 루트 철자 일치
    {
      final di = segs.indexOf('domain_layer');
      if (segs[0] == 'application' && di >= 0 && di == segs.length - 3 && base != 'exception.dart') {
        final agg = segs[di + 1];
        if (base != '$agg.dart') {
          out.add(Finding('NM15', f, null,
              '애그리거트 폴더 `$agg/` 직속 파일명 `$base` — 루트는 폴더명과 동일(`$agg.dart`)',
              '제1 규약 §3.2·§7.2', '루트 파일명=폴더명=클래스명. 다른 개념이면 5종 폴더 안으로.'));
        }
      }
    }

    // ---- NM16: repository 추상 클래스 금지
    if (parent == 'repository') {
      for (final m in RegExp(r'(?:^|\n)[ \t]*(?:abstract\b[\w \t]*?|sealed[ \t]+)class\b')
          .allMatches(ms.tokensView)) {
        out.add(Finding('NM16', f, ms.lineOf(m.start),
            'repository에 추상(abstract·sealed) 클래스 — 간소화 DDD는 인터페이스 없음',
            '제1 규약 §9-1', 'Repo는 구체 클래스 하나 — 원격+로컬 DataSource를 조합하는 단일 진실 원천.'));
      }
    }

    // ---- NM17: view 위젯 직접 빌드 차단 (주 view 외 위젯 클래스·위젯 빌드 top-level 함수 금지)
    // view는 State를 그리고 section/widget을 조립할 뿐 — 위젯 트리를 직접 빌드하지 않는다(제1 규약 §3.5).
    // 막는 우회: private·언더스코어 없는 추가 위젯 클래스(멀티라인 `extends` 포함)와, 위젯을 반환하는
    // top-level 함수(반환형에 `Widget` 포함 — Widget·Widget?·List<Widget>·PreferredSizeWidget… —
    // 또는 흔한 구체 위젯 _widgetReturnTypes). 반환형이 위젯이 아닌 순수 helper(String·Color 등)는
    // view-fat이 아니므로 통과시킨다.
    if (parent == 'view' && base.endsWith('_view.dart')) {
      final mainName = casefold(base.substring(0, base.length - 5));
      for (final m in RegExp(
              r'(?:^|\n)[ \t]*(?:(?:abstract|sealed|final|base|interface)[ \t]+)*class[ \t]+([A-Za-z_$][\w$]*)(?:<[^>]*>)?\s+extends\s+[\w$]*Widget\b')
          .allMatches(ms.tokensView)) {
        final name = m.group(1)!;
        if (casefold(name) == mainName) continue; // 주 view 클래스 1개만 합법
        out.add(Finding('NM17', f, ms.lineOf(m.start),
            'view 파일에 추가 위젯 클래스 `$name` — view는 위젯 트리를 직접 빌드하지 않는다',
            '제1 규약 §3.5',
            'error/loading은 design_system 컴포넌트를 직접 반환하고, 목록·상세 조립은 section으로 분리한다.'));
      }
      for (final m in RegExp(r'(?:^|\n)([A-Z][\w$]*(?:<[^>]*>)?\??)[ \t]+([A-Za-z_$][\w$]*)[ \t]*\(')
          .allMatches(ms.tokensView)) {
        final ret = m.group(1)!;
        final bare = ret.replaceAll(RegExp(r'[<?].*'), '');
        if (_nonWidgetReturnTypes.contains(bare)) continue; // WidgetRef 등 비위젯 프레임워크 타입
        if (!ret.contains('Widget') && !_widgetReturnTypes.contains(bare)) continue;
        out.add(Finding('NM17', f, ms.lineOf(m.start),
            'view 파일에 위젯 빌드 top-level 함수 `${m.group(2)}` (반환 `$ret`) — 위젯 빌드는 section/widget으로',
            '제1 규약 §3.5', '함수로 위젯 트리를 빌드하지 않는다 — section/widget 위젯으로 분리한다.'));
      }
    }
  }
  return out;
}

/// 종류 폴더명이 우연히 같은 비검사 위치(예: common/service, infra service는 검사하되
/// domain의 enum 등 무접미사 종류와 혼동 방지)를 거른다.
bool _folderContextOk(String f, String parent) {
  switch (parent) {
    case 'view_model':
    case 'state':
      return hasSeg(f, 'application_layer') || f.startsWith('root/scaffold/');
    case 'use_case':
    case 'shared_state':
      return hasSeg(f, 'application_layer');
    case 'service':
      // app·infra service 모두 `_service.dart` — common/service도 §7.2상 동일 접미사
      return hasSeg(f, 'application_layer') || hasSeg(f, 'infra_layer') || f.startsWith('common/');
    case 'data_source':
    case 'local_storage':
    case 'repository':
      return hasSeg(f, 'infra_layer');
    case 'view':
      return hasSeg(f, 'presentation_layer') || f.startsWith('root/scaffold/');
    case 'section':
    case 'widget':
    case 'ui_extension':
      return hasSeg(f, 'presentation_layer');
    case 'domain_service':
    case 'specification':
      return hasSeg(f, 'domain_layer');
    case 'handler':
      return f.startsWith('root/');
  }
  return true;
}
