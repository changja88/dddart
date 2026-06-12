/// IM — import 방향 22종 (설계 §5). 게이트: touched 파일의 added 줄.
///
/// *왜 결정적 백스톱인가*: 계층·컨테이너의 의존 방향(제1 규약 §3.7 매트릭스·§9-3
/// 4채널·§3.6 root 규칙)은 정규화된 import 경로 하나로 판별된다 — 의미 해석 0.
/// 거짓양성 게이트 = added 줄 한정(레거시 파일의 기존 위반 import에 불발화 — §3)
/// + 주석·문자열 마스킹(교정 주석의 토큰이 재차 blocker가 되는 루프 차단 — §4-2).
library;

import 'common.dart';

List<Finding> runImports(BackstopContext ctx) {
  final out = <Finding>[];
  for (final f in ctx.dartFiles.where(ctx.isTouched)) {
    final segs = segsOf(f);
    final bc = bcOf(f);
    final base = baseNameOf(f);
    final parent = parentDirOf(f);
    final inDomain = hasSeg(f, 'domain_layer');
    final inApp = hasSeg(f, 'application_layer');
    final inInfra = hasSeg(f, 'infra_layer');
    final inPres = hasSeg(f, 'presentation_layer');
    final isBcRootFile = segs.length == 3 && segs[0] == 'application';
    final isNavigator = isBcRootFile && base == '${bc}_navigator.dart';
    final isBcRouter = isBcRootFile && base == '${bc}_router.dart';
    final isMain = f == 'main.dart';
    final inRoot = segs[0] == 'root';

    void add(String id, int line, String msg, String rule, String fix) {
      if (ctx.lineIsAdded(f, line)) out.add(Finding(id, f, line, msg, rule, fix));
    }

    for (final e in ctx.edgesOf(f)) {
      final t = e.target; // internal 정규화 경로 (lib-상대)
      final isInternal = e.type == TargetType.internal && t != null;

      // ---- IM1: domain → flutter·dart:ui 금지
      if (inDomain) {
        if (e.uri.startsWith('package:flutter/') || e.uri == 'dart:ui') {
          add('IM1', e.line, 'domain_layer에서 `${e.uri}` import — 순수 Dart 계층',
              '제1 규약 §3.2',
              'UI 매핑(색·아이콘·라벨)은 presentation의 ui_extension/으로 — 도메인은 freezed·dartz 등 순수 패키지만.');
        }
        // ---- IM19: domain → 비domain 내부 경로 금지
        if (isInternal && !hasSeg(t, 'domain_layer')) {
          add('IM19', e.line, 'domain_layer에서 `$t` import — domain은 domain만 본다(common 포함 금지)',
              '제1 규약 §3.7', '도메인 이유로만 바뀌는 코드만 남기고, 변환·조율은 UseCase/VM으로 올린다.');
        }
      }

      // ---- IM2: root import는 main.dart만 (root 내부 상호 import 제외)
      if (isInternal && t.startsWith('root/') && !inRoot && !isMain) {
        add('IM2', e.line, 'root/ import — root를 아는 곳은 main.dart뿐(BC가 root를 알면 격리 붕괴)',
            '제1 규약 §3.6', '필요한 것이 전역 인스턴스면 common으로, 전 BC 배선이면 root handler가 *이쪽을* 호출하는 방향으로 뒤집는다.');
      }

      // ---- IM3·IM4: common·design_system → application·root 금지
      if (segs[0] == 'common' && isInternal && (t.startsWith('application/') || t.startsWith('root/'))) {
        add('IM3', e.line, 'common에서 `$t` import — common은 모두가 아는 곳, 아무도 모르면 안 된다',
            '제1 규약 §6', 'BC 어휘가 필요하면 그 코드는 common 실격 — 해당 BC로 옮기고, BC 일이 필요하면 콜백 주입으로 뒤집는다.');
      }
      if (segs[0] == 'design_system' && isInternal && (t.startsWith('application/') || t.startsWith('root/'))) {
        add('IM4', e.line, 'design_system에서 `$t` import — 시각 요소는 BC 어휘를 모른다',
            '제1 규약 §6', '도메인 의존 부품은 그 BC presentation의 widget으로 내린다.');
      }

      // ---- IM5: 교차 BC 4채널
      if (bc != null && isInternal) {
        final tbc = bcOf(t);
        if (tbc != null && tbc != bc) {
          final tsegs = segsOf(t);
          final inTDomain = hasSeg(t, 'domain_layer');
          final domainType = inTDomain &&
              (hasSeg(t, 'entity') || hasSeg(t, 'value_object') || hasSeg(t, 'enum') ||
                  (tsegs.length == 5 && tsegs[4] == '${tsegs[3]}.dart') ||
                  baseNameOf(t) == 'exception.dart');
          final ok = domainType ||
              hasSeg(t, 'use_case') ||
              (tsegs.length == 3 && tsegs[2] == '${tbc}_navigator.dart') ||
              (hasSeg(t, 'presentation_layer') && hasSeg(t, 'view'));
          if (!ok) {
            final reason = inTDomain
                ? 'domain_service·specification은 도메인 로직 — 채널①은 타입(엔티티·VO·enum)만, 행위는 UseCase 관문'
                : 'infra·VM·SharedState·state·section·widget·ui_extension은 채널 밖';
            add('IM5', e.line, '타 BC `$tbc`의 `$t` import — 교차 BC는 4채널만($reason)',
                '제1 규약 §9-3',
                '데이터·행위는 그 BC UseCase 호출, 표시는 view 임베드, 이동은 navigator, 타입은 entity/value_object/enum만.');
          }
        }
      }

      // ---- IM6: root → BC infra 금지 (initializer의 hive_adapters만 예외)
      if (inRoot && isInternal && hasSeg(t, 'infra_layer')) {
        final exempt = f.startsWith('root/initializer/') && baseNameOf(t).endsWith('_hive_adapters.dart');
        if (!exempt) {
          add('IM6', e.line, 'root에서 BC infra `$t` import — root도 Model 규율(UseCase만) 적용',
              '제1 규약 §3.6', '그 BC UseCase를 호출한다. 유일 예외는 initializer→`*_hive_adapters.dart`(시동 배선).');
        }
      }

      // ---- IM7: VM·SharedState·Service → infra·local_database·dio_client 금지
      if (inApp && {'view_model', 'shared_state', 'service'}.contains(parent) && isInternal) {
        if (hasSeg(t, 'infra_layer') || t.startsWith('common/local_database/') || t == 'common/network/dio_client.dart') {
          add('IM7', e.line, 'ViewModel 변종에서 `$t` import — Model 방향은 UseCase만',
              '제1 규약 §3.3', '위임 한 줄짜리라도 UseCase를 거친다 — 관문의 일관성이 지름길의 근거가 되지 않는다.');
        }
      }

      // ---- IM8(import 절반): section·widget·ui_extension → riverpod 금지
      if (inPres && {'section', 'widget', 'ui_extension'}.contains(parent)) {
        if (e.uri.startsWith('package:flutter_riverpod/') ||
            e.uri.startsWith('package:hooks_riverpod/') ||
            e.uri.startsWith('package:riverpod')) {
          add('IM8', e.line, '$parent에서 riverpod import — dumb 표현 조각은 provider의 존재를 모른다',
              '제1 규약 §3.5', '상태가 필요해진 것은 승격 신호 — view+vm 쌍(삼총사)으로 승격한다.');
        }
      }

      // ---- IM9: widget → 화면 state 금지
      if (inPres && parent == 'widget' && isInternal && hasSeg(t, 'application_layer') && hasSeg(t, 'state')) {
        add('IM9', e.line, 'widget에서 화면 State `$t` import — 재사용 부품은 화면을 모른다',
            '제1 규약 §3.5', '엔티티·원시값·콜백 prop으로 바꾼다. 화면 전속이면 section으로.');
      }

      // ---- IM10·IM21: navigator의 금지 방향
      if (isNavigator && isInternal) {
        if (hasSeg(t, 'presentation_layer')) {
          add('IM10', e.line, 'navigator에서 presentation `$t` import — 라우트 이름만 참조',
              '제1 규약 §3.1', '`<Bc>Routes` 상수(`pushNamed`)만 쓴다 — View import는 순환(VM→navigator→View→VM)을 만든다.');
        } else if (hasSeg(t, 'domain_layer') || hasSeg(t, 'application_layer') || hasSeg(t, 'infra_layer')) {
          add('IM21', e.line, 'navigator에서 계층 코드 `$t` import — navigator는 정적 push 헬퍼일 뿐',
              '제1 규약 §3.7', 'navigator의 합법 import는 자기 router(라우트 상수)·common뿐.');
        }
      }

      // ---- IM11: application → presentation 금지
      if (inApp && isInternal && hasSeg(t, 'presentation_layer')) {
        add('IM11', e.line, 'application_layer에서 presentation `$t` import — 역류',
            '제1 규약 §3.7', 'UI가 필요한 결정은 State로 노출하고 View가 ref.listen으로 소비한다.');
      }

      // ---- IM12(import 절반): application → flutter 전면 금지(foundation 예외)
      if (inApp && e.uri.startsWith('package:flutter/') && e.uri != 'package:flutter/foundation.dart') {
        add('IM12', e.line, 'application_layer에서 `${e.uri}` import — UI 호출 금지(widgets.dart는 material의 원천이라 전면 금지)',
            '제1 규약 §3.3·§3.7', '시각·위젯 의존은 presentation으로, 토큰 매핑은 ui_extension으로. foundation.dart(immutable 등)만 허용.');
      }

      // ---- IM13: design_system import 화이트리스트
      if (isInternal && t.startsWith('design_system/')) {
        final ok = inPres ||
            f.startsWith('root/scaffold/') ||
            isMain ||
            segs[0] == 'design_system' ||
            isBcRouter ||
            f == 'root/router/root_router.dart';
        if (!ok) {
          add('IM13', e.line, '`$t` import — design_system은 presentation·root scaffold·router·main만',
              '제1 규약 §3.7', '시각 토큰이 필요한 로직은 ui_extension(도메인→UI 매핑의 유일한 자리)으로 옮긴다.');
        }
      }

      // ---- IM14(import 절반): app service → navigator 금지
      if (inApp && parent == 'service' && isInternal && baseNameOf(t).endsWith('_navigator.dart')) {
        add('IM14', e.line, 'application service에서 navigator import — 내비는 VM만',
            '제1 규약 §3.7·§3.6', '플랫폼 이벤트발 화면 이동은 root_destination_handler 소유 — 딥링크 URL로 정규화해 디스패치한다.');
      }

      // ---- IM15: main.dart 역import 금지
      if (isInternal && t == 'main.dart' && (segs[0] == 'application' || segs[0] == 'common' || segs[0] == 'design_system')) {
        add('IM15', e.line, 'main.dart import — 엔트리포인트를 역참조',
            '제1 규약 §3.6', '필요한 전역 인스턴스(logger·routeObserver 등)는 common 소속으로 옮긴다.');
      }

      // ---- IM16: main.dart import 화이트리스트
      if (isMain) {
        final okExternal = e.uri.startsWith('dart:') ||
            e.uri.startsWith('package:flutter/') ||
            e.uri.startsWith('package:flutter_riverpod/') ||
            e.uri.startsWith('package:hooks_riverpod/') ||
            e.uri.startsWith('package:riverpod') ||
            e.uri.startsWith('package:flutter_localizations/') ||
            e.uri.startsWith('package:flutter_gen/');
        final okInternal = isInternal &&
            (t.startsWith('root/') || t == 'design_system/theme/app_theme.dart' || t.startsWith('l10n/'));
        if (!(okExternal || okInternal)) {
          add('IM16', e.line, 'main.dart 화이트리스트 외 import `${e.uri}` — 엔트리포인트 최소형',
              '제1 규약 §3.6', 'SDK 초기화는 root_initializer, 테마는 app_theme 한 줄, 라우터는 root_router 한 줄 — 그 외는 main의 일이 아니다.');
        }
      }

      // ---- IM17: presentation → infra 금지
      if (inPres && isInternal && hasSeg(t, 'infra_layer')) {
        add('IM17', e.line, 'presentation에서 infra `$t` import — View→Repo 직행',
            '제1 규약 §3.7', '데이터는 VM이 UseCase로 가져와 State로 노출한다.');
      }

      // ---- IM18: infra → application·presentation 금지
      if (inInfra && isInternal && (hasSeg(t, 'application_layer') || hasSeg(t, 'presentation_layer'))) {
        add('IM18', e.line, 'infra에서 상위 계층 `$t` import — 역류',
            '제1 규약 §3.7', 'infra는 호출당하는 쪽 — 필요한 값은 인자로 받는다.');
      }

      // ---- IM20: use_case·state·shared_state → navigator 금지
      if (inApp && {'use_case', 'state', 'shared_state'}.contains(parent) && isInternal &&
          baseNameOf(t).endsWith('_navigator.dart')) {
        add('IM20', e.line, '$parent에서 navigator import — BC 루트 호출은 VM만',
            '제1 규약 §3.7', '화면 전환은 VM의 일 — UseCase는 Either만 반환하고 결정은 VM이 한다.');
      }

      // ---- IM22: router 허용 목록
      if (isBcRouter && isInternal) {
        final tbc = bcOf(t);
        final ok = t.startsWith('design_system/') || // 전환 토큰(IM13 허용과 정합)
            (tbc == bc &&
                ((hasSeg(t, 'presentation_layer') && hasSeg(t, 'view')) ||
                    segsOf(t).length == 3)); // 자기 BC 루트
        if (!ok) {
          add('IM22', e.line, 'router에서 `$t` import — router는 자기 BC view(GoRoute builder)와 BC 루트만',
              '제1 규약 §3.7·§3.1', 'section·widget은 view가 조립하고, 게이트 상태 확인은 root_router redirect(UseCase 직접 생성)의 일.');
        }
      }
    }

    // ================= 토큰 검사 (마스킹 본문 §4-2, added 줄 게이트) =================
    final ms = ctx.maskOf(f);

    // IM8: WidgetRef 토큰
    if (inPres && {'section', 'widget', 'ui_extension'}.contains(parent)) {
      for (final (line, _) in scanTokens(ms, RegExp(r'\bWidgetRef\b'))) {
        add('IM8', line, '$parent에서 `WidgetRef` 보유 — dumb 표현 조각', '제1 규약 §3.5',
            'prop·콜백으로 받는다. 상태가 필요하면 view+vm 승격.');
      }
    }
    // IM12: BuildContext 토큰
    if (inApp) {
      for (final (line, _) in scanTokens(ms, RegExp(r'\bBuildContext\b'))) {
        add('IM12', line, 'application_layer에서 `BuildContext` 보유', '제1 규약 §3.3·§9-7',
            '화면 전환은 navigator 헬퍼(라우트 이름만), 에러 표시는 State 노출 → View의 ref.listen.');
      }
    }
    // IM14: service의 내비 호출 토큰
    if (inApp && parent == 'service') {
      for (final (line, _) in scanTokens(ms, RegExp(r'\.(go|goNamed|pushNamed)\('))) {
        add('IM14', line, 'application service에서 내비 호출(`.go(`류)', '제1 규약 §3.6',
            '플랫폼 이벤트의 화면 이동은 root_destination_handler가 딥링크 URL로 디스패치한다.');
      }
    }
  }
  return out;
}
