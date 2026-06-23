# feedback-026 — screenProbes 반환-소비 형태·시그니처 form-pin (코퍼스)

> 사전등록형 원장. **상태**: 시술 완료·17차 검증 대기. **scope**: 코퍼스(implementation-test §7 + coder.md 양판)·양판 미러·다음 런 동결·별도 승인됨. eval/tools 무수정.

## 회차/증상 (16차 codex FID 정당 A1·코더 흠·도구 무죄)
codex `test/application/weather_forecast/presentation_layer/view/_support.dart`:
- `:15 typedef ScreenPump = Future<void> Function(WidgetTester tester)` (표준 `ScreenProbe = Future<Finder>` 위반)·`:22 Future<void> pumpWeeklyForecast(...)` (Finder 미반환).
- render_smoke 재작성(`:12-15`): `await probe.value(tester)`(반환 미소비) + `expect(find.byKey(ValueKey(probe.key)), findsOneWidget)`(별도 finder).
- → fid-gate probe(`dump_probe.dart.txt:44 ScreenProbe`·`:46 final Finder root = await probe(tester)`)가 `ScreenProbe` 이름·`Future<Finder>` 반환 기대 → 컴파일 불일치 → flutter test 실패 → **A1**(도구 무죄).

## ROC (4렌즈 적대 `w9svgb2yn`·301k)
- **§7은 형태를 *이미 핀***(`:138 typedef ScreenProbe=Future<Finder>`·`:159 expect(await probe(tester),findsOneWidget)` 반환소비). → FC-1 "형태 부재"가 아닌 **feedback-018/021 死형태 패턴**: 지식은 §7에 있으나 강제 길목(coder.md:36 / codex SKILL:33)이 *행위*("펌프해 findsOneWidget 단언, §7 형태")로만 환언 → codex가 paraphrase 만족하며 계약 깨는 변형 선택.
- **green 자가강제 실증**: `expect(await probe(tester), findsOneWidget)` + `Future<void>` = `use_of_void_result` 컴파일 에러 → 그 형태 쓰면 green 래칫이 자가강제(**단 코더가 형태 채택 시 조건부**·16차는 미채택).
- **coder가 implementation-test 로드**(coder.md:9·codex SKILL:12) → 지식 도달 O(**FC-1 미로드 死문구와 차이·처방 더 강함**).
- **회귀 = 엔진변수**(15차 codex 정확 `ScreenProbe/Future<Finder>`·16차 위반·동일 코퍼스·**1정/1오 불안정**). path: codex `agents/` 없음 → `codex-dddart/skills/dddart-coder/SKILL.md:33`.
- 적대 교정: 내 도시어 "§7 형태 미핀"=REFUTED(§7 핀돼 있음)·"green 자가강제 단정"=조건부로 QUALIFIED·path-label codex=SKILL:33.

## 처방 (form-pin·만장일치 KEEP)
1. **implementation-test §7**(canonical·final.md): render_smoke 템플릿 뒤에 ban+why 명문 — "probe 반환 finder를 *소비*하는 형태(`expect(await probe(tester), findsOneWidget)`)라야 한다·반환 버리고 `find.byKey` 등 별도 finder 단언 대체 금지(`Future<void>` green 누수→FID 진입점 파괴)·typedef `ScreenProbe`/`Future<Finder>` 고정·`ScreenPump`/`Future<void>` 금지".
2. **coder.md:36 + codex SKILL:33**(양판·생성 길목): ⓑ를 "각 role 펌프해 **probe 반환 finder를 소비**(`expect(await probe(tester), findsOneWidget)`)로 단언·반환 버린 별도 finder 단언 대체 금지·typedef `ScreenProbe=Future<Finder>` 고정"으로 정밀화.
- ★렌즈C 정련: **"find.byKey 금지"가 아니라 "반환 소비"**로 표현 — probe가 *어떤* finder를 반환하든(view 루트든 byKey든) 그 *반환을 expect에 넣는 형태*만 강제(과적합 회피).

## 보류·기각
- **backstop(test/_support typedef grep) 보류(measure-first·N=2)**: `check_tests.dart:24/33-34`가 test/ 이미 traverse하나 **존재만 검사 + `:7` "test/엔 NM/import 규약 미적용" 원칙**이라 시그니처 content-check는 원칙 이탈 → form-pin 단독 17차 효과 본 뒤 codex 재발 시 eval-harness 계약 carve-out으로 추가.
- **reviewer 감사 DROP**: LLM 비결정·결정론 수단(green 자가강제) 있으면 중복.
- **defer DROP**: FID 진입점=A1 측정봉쇄·결정론 수단 존재라 보류 부정직.

## 예상효과 (17차)
- codex가 render_smoke를 반환-소비 형태로 쓰면 `Future<void>` probe는 컴파일 불가 → 표준 `ScreenProbe/Future<Finder>` 강제 → fid-gate probe 정상 컴파일 → FID 측정(fid-gate 선택 fix025와 함께).
- **측정 정직**: green 자가강제는 **코더가 형태 채택 시 조건부**(엔진변수 잔존)·표본 1정/1오로 얇음 → 17차 codex render_smoke 형태 grep(`expect(await probe`·`ScreenProbe`)으로 실측. 비재발해도 효과 불명(FC-1 부분 상속). N=2 재발 시 backstop 후속.

## 무모순·무과적합·회귀안전
- **무과적합**: 범용 FID probe 계약(weather 비종속·role/view명 placeholder·dump_probe가 소비하는 보편 typedef·반환). "반환 소비" 핀이라 probe 내부 finder 선택 자유(과적합 회피).
- **무모순**: §7(:159 형태) ↔ coder.md(행위→형태 강화)·동방향·신규 규율 아님.
- **회귀안전**: 레이아웃/에셋/fix020/VW-4/DT-3/FC-1 무관·fid-gate fix025(선택)와 직교(보완).
- **강제력**: §7 지식 + coder 길목(coder.md/SKILL·도달 확인) — feedback-018/021 교훈(길목까지).

## 시술 후 적대 리뷰 (3렌즈·전부 PASS·BLOCKER0)
- **렌즈1(소비성·정합·모순)=PASS**: "반환 소비" 핀이 렌즈C 정조준(probe 내부 finder 자유·render_smoke 대체단언만 금지)·§7↔coder.md 강화 정합·dump_probe 계약 실증.
- **렌즈2(과적합·회귀)=PASS**: 하드코딩0·범용 FID 계약·§7/coder.md 기존 불변·레이아웃/에셋/fix020/VW-4/DT-3/FC-1/fix025 0교차(fix025와 직교 보완)·트윈 byte-identical(md5)·3-tier 11/11.
- **렌즈3(강제력·재분류·효과)=PASS×3+CONCERN1**: ★**dart analyze 실측**[16차 현 패턴(`await probe.value()`+`find.byKey`+`Future<void>`)=green 통과(구멍 실재) / 핀 형태(`expect(await probe(tester),findsOneWidget)`)+`Future<void>`=`use_of_void_result` red=green 래칫 차단=자가강제 발동]·거짓표적0(15차 codex·16차 claude 인라인 클로저 정합)·codex 도달 O(SKILL:12 로드+:33 본문+:40 자가 flutter test+§7 라우팅·死문구 아님)·**효과 CONCERN**(green 자가강제 조건부[코더가 형태 채택 시]·N=1 1정/1오·17차 비재발 시 측정취약=VW-4/Q-7 동형·단 재발 시 결정적 검출+fid-gate A1 2차그물로 Q-7보다 우위).
- **채택 1건(렌즈3 강제력 비대칭)**: `ScreenPump`/`Future<void>` 명시 금지가 §7(라우팅 도달)에만 → coder.md:36+SKILL:33(직접 로드)에도 "변형 금지" 1구 추가(길목 동급화·feedback-018/021).
- **최종 시술 = 3곳(§7 + coder.md + codex SKILL)·강제력 동급화 1구 = 양판 6파일**·미러 11/11·트윈 IDENTICAL·git=코퍼스6+fix025 2 동거.

## 재발 트리거
- 17차 codex render_smoke 또 재작성(반환 미소비)·N=2 → backstop(check_tests.dart에 _support typedef grep·eval-harness carve-out) 추가.
