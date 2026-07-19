/// HV — hive 저장 모듈 1종 (feedback-032). 게이트: added 파일.
///
/// HV1: `data_source/local_storage/`의 `_box.dart`(저장 스키마)에 **@HiveType 부착**이
///   있는가 — box 파일은 "@HiveType 저장 전용 Box 모델 1개"가 정체다(architecture-data §5·
///   implementation-flutter §5). 무어노테이션 box 파일은 유령 종류(어댑터 미생성·등록 불가)라
///   MD1(@freezed 게이트)과 동형으로 파일종의 구조 정의를 검사한다.
///
/// *왜 결정적 백스톱인가*: 어노테이션 존재는 마스킹 본문(tokensView — 주석·문자열 무시)의
/// 토큰 검사로 환원된다. 거짓양성 게이트 = added 파일 한정(레거시 면책) + freezed 병용
/// (`@freezed @HiveType`)은 존재 검사라 자연 통과.
///
/// 설계 근거: workspace/eval/fix/feedback-032(hive 배치 재설계 — local_storage 하위층).
/// 보류(승격 조건은 feedback-032 보류 목록): HV2(@HiveType의 `_box.dart` 밖 등장 금지 —
/// 오배치 실측 후) / HV3(typeId 전역 유일 — box 2개+ 실측 후·리터럴 한계 명기 필요).
/// 한계: 기존 box(비added)의 @HiveType *삭제* 회귀는 미탐(added 래칫 수용 한계),
/// @HiveType 모델 없는 원시 저장(`Hive.box<Map>` 등)은 결정적 검사 불가(reviewer 몫).
library;

import 'common.dart';

final _hiveTypeRe = RegExp(r'@HiveType\s*\(');

/// HV family 러너 — HV1.
List<Finding> runHive(BackstopContext ctx) {
  final out = <Finding>[];
  for (final f in ctx.dartFiles.where(ctx.isAdded)) {
    if (parentDirOf(f) != 'local_storage' || !hasSeg(f, 'infra_layer')) continue;
    if (!baseNameOf(f).endsWith('_box.dart')) continue;
    if (_hiveTypeRe.hasMatch(ctx.maskOf(f).tokensView)) continue;
    out.add(Finding('HV1', f, null,
        '`_box.dart` 저장 스키마에 @HiveType 부재 — box 파일은 @HiveType 저장 전용 모델 1개가 정체',
        'implementation-flutter §5 — @HiveType per-class(@GenerateAdapters 비채택)',
        '클래스에 `@HiveType(typeId: <BC 대역>)`·필드에 `@HiveField(n)`을 달고 build_runner로 어댑터를 생성한다. '
        '저장 모델이 아니면 이 파일은 local_storage/ 소속이 아니다.'));
  }
  return out;
}
