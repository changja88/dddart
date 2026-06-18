/// MD — 모델 선언 형태 2종 (feedback-009). 게이트: added 모델 파일.
///
/// *왜 결정적 백스톱인가*: 엔티티·VO·State의 직렬화 형태(@freezed + json_serializable 직파싱)는
/// architecture-ddd §3·architecture-state §3가 *필수 형태*로 규정한다 — 수기 fromJson·수기 타입
/// 리더·모델 안 FormatException은 그 계약 위반이며 "형태"로 결정 판별된다(6차 codex 수기모델이
/// reviewer·백스톱 두 관문 사이 사각을 빠져나간 사례를 닫는다). 엔진/회차 불변의 기계 floor다.
///
/// 거짓양성 차단(적대검증 스펙): added 한정(레거시 면책) + enum/exception.dart/생성파일 제외 +
/// 모델 클래스 자신의 fromJson factory만 타깃(@JsonKey 컨버터·도메인 *Exception 비대상).
/// 파일=단일 클래스 불변식(discipline-houserules §1)을 써서 파일-수준으로 안전 판별한다.
library;

import 'common.dart';

const _ruleDdd = '제1 규약 §9-2·architecture-ddd §3 직파싱(필수 형태)';
const _ruleState = 'architecture-state §3 — 항상 freezed State';

// 모델 스코프 판별 ---------------------------------------------------------

bool _isEntityOrVo(String f) {
  if (!hasSeg(f, 'domain_layer')) return false;
  final p = parentDirOf(f);
  return p == 'entity' || p == 'value_object';
}

/// domain_layer/<agg>/<agg>.dart — 애그리거트 루트 직속 파일.
bool _isAggregateRoot(String f) {
  final s = segsOf(f);
  final di = s.indexOf('domain_layer');
  if (di < 0 || di != s.length - 3) return false; // domain_layer/<agg>/<file>
  return baseNameOf(f) == '${s[di + 1]}.dart';
}

bool _isStateFile(String f) =>
    hasSeg(f, 'application_layer') && parentDirOf(f) == 'state';

/// @freezed 비대상 형태는 제외: enum 디렉터리·exception.dart(도메인 예외 다중 클래스).
bool _isExcludedShape(String f) =>
    hasSeg(f, 'enum') || parentDirOf(f) == 'enum' || baseNameOf(f) == 'exception.dart';

// 형태 패턴 ---------------------------------------------------------------

final _classRe = RegExp(
    r'(?:^|\n)[ \t]*(?:abstract\s+|sealed\s+|final\s+|base\s+|interface\s+)*class\s+(\w+)');
final _freezedRe = RegExp(r'@[Ff]reezed\b');
final _fromJsonFactoryRe = RegExp(r'factory\s+\w+\.fromJson\s*\(');
final _genFromJsonRe = RegExp(r'_\$\w+FromJson\s*\(');
final _readHelperRe = RegExp(r'_read\w+\s*\(\s*Map<'); // 수기 타입 리더 선언
final _formatExcRe = RegExp(r'\bFormatException\b');

List<Finding> runModels(BackstopContext ctx) {
  final out = <Finding>[];
  for (final f in ctx.dartFiles.where(ctx.isAdded)) {
    if (_isExcludedShape(f)) continue;
    final isEntVo = _isEntityOrVo(f);
    final isRoot = _isAggregateRoot(f);
    final isState = _isStateFile(f);
    if (!isEntVo && !isRoot && !isState) continue;

    final ms = ctx.maskOf(f);
    final code = ms.noComments;

    final classM = _classRe.firstMatch(code);
    if (classM == null) continue; // 클래스 선언 없음(enum-only·typedef 등) → 비대상

    // ---- MD1: @freezed presence (entity/VO/root/state 공통)
    if (!_freezedRe.hasMatch(code)) {
      final cls = classM.group(1) ?? '?';
      out.add(Finding(
          'MD1',
          f,
          ms.lineOf(classM.start),
          '모델 클래스 `$cls`에 @freezed 미부착 — 엔티티·VO·State는 @freezed로 선언한다(수기 final class 모델 금지)',
          isState ? _ruleState : _ruleDdd,
          '`@freezed abstract class $cls with _\$$cls`로 선언하고 직렬화는 생성 companion에 위임한다(enum은 @freezed 비대상 — @JsonValue 매핑).'));
    }

    // ---- MD2: 수기 직렬화 (entity/VO/root만 — State는 fromJson 없음)
    if (isState) continue;
    // 생성 위임(`_$XFromJson`)이 있으면 fromJson은 codegen이다 — 이때 `_read*(Map<…>)`는
    // 수기 파서가 아니라 @JsonKey(fromJson:) 컨버터(스펙 면제)다. hasGen이면 둘 다 끈다
    // (적대검증 2차 FP 차단 — 합법 컨버터 오발 방지). 수기 모델은 hasGen이 없어 그대로 발화.
    final hasGenFromJson = _genFromJsonRe.hasMatch(code);
    final handFromJson = _fromJsonFactoryRe.hasMatch(code) && !hasGenFromJson;
    final handReader = _readHelperRe.hasMatch(code) && !hasGenFromJson;
    if (!handFromJson && !handReader) continue;

    final signals = <String>[
      if (handFromJson) '수기 fromJson(생성 위임 `_\$…FromJson` 부재)',
      if (handReader) '수기 타입 리더 `_read…(Map<…>)`',
      if (_formatExcRe.hasMatch(code)) '모델 안 FormatException',
    ];
    final hits = <int>[
      if (handFromJson) _fromJsonFactoryRe.firstMatch(code)!.start,
      if (handReader) _readHelperRe.firstMatch(code)!.start,
    ];
    final at = hits.reduce((a, b) => a < b ? a : b);
    out.add(Finding(
        'MD2',
        f,
        ms.lineOf(at),
        '수기 직렬화 — ${signals.join('·')} — 직파싱은 @freezed + json_serializable 생성 companion 전담',
        _ruleDdd,
        'fromJson은 `=> _\$XFromJson(json)` 생성 위임만 두고 수기 파서·`_read*` 리더·모델 안 FormatException을 제거한다(파싱 실패 정규화는 safeApiCall §2의 몫).'));
  }
  return out;
}
