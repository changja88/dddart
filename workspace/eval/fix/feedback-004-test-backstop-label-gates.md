# feedback-004 — 테스트 산출 게이트·백스톱 실행 강제·명세일치·task 어휘 보존 (초안·사전등록)

> **상태: 제안(미적용)** · 이 회차는 *고치기 전*이라 ④예상효과까지만 채우고 ⑤시술·⑥실측은 다음 라이브런 후. **코퍼스 교정 적용은 별도 사용자 승인 필요**(코퍼스 불변 방침).
> **트리거** 2차 양판 — `results/20260615-0106-weather-claude.md` · `results/20260615-0214-weather-codex.md` · 집계 `results/20260615-0214-weather-compare.md §5`(교정 후보 6건을 여기로 승격)
> **베이스 코퍼스** `17100a9`(피드백3 롤백 후 — 코퍼스 내용은 1차 완성본 `676e317`과 동등)

## 사전등록 표 (③처방·미러경로·④예상효과 = 측정 dim)

| # | 우선 | ① 대상 결함 | ② 원인(뿌리) | ③ 처방·미러 | ④ **예상효과**(전→후) |
|---|---|---|---|---|---|
| 1 | **공통 최우선** | claude FC-2 테스트 0 (1·2차 동일) | `coder` 책무에 테스트 산출 0 — green 빌드를 비-vacuous로 잇는 게이트 부재 | `dddart/agents/coder.md` + `implementation-dart/references/final.md`에 "슬라이스마다 핵심 행위 mutation 1+ 테스트" 게이트. coder·SKILL 수동 양판 미러 / final.md는 mirror_sync | **claude FC-2: FAIL→PASS** (test/ 비어있음=즉시 FAIL 해소) |
| 2 | **공통 최우선** | codex 백스톱 5 blocker (1차 0→회귀) | G2 게이트가 백스톱 *실행*을 강제 안 함 → 미실행을 "통과"로 처리 | `dddart/commands/dddart.md`·`dddart/SKILL.md` G2 절차에 "백스톱 exit 0 미달=게이트 차단". 수동 양판 미러 | **codex 백스톱: 5→0** (미실행 시 G2 통과 불가) |
| 3 | claude | claude ST-2 `throw Exception` plain 격하 (1차 정석→회귀) | design-spec은 `throw error`(BadReq) 옳으나 coder 구현이 격하·감수 미포착 | `implementation-dart/references/final.md` "build 실패 throw=BadRequestResponse"(mirror_sync) + `tools/backstop.dart` 규칙 "build 내 plain Exception throw 탐지"(eval 단일출처) | **claude ST-2: FAIL→PASS** |
| 4 | codex | codex G-8 라벨 영문화 (1차 한글→회귀·overcast→cloudy 의미밀림) | task 표시 어휘(한글)를 coder/ui가 보존 강제 안 함 → G1에서 영문 변질 | `architecture-ui/references/final.md`·`coder.md`에 "SCENARIO 표시 어휘 보존·FC-GOLDEN 대조". final.md mirror_sync / coder 수동 미러 | **codex FC-1 G-8: FAIL→PASS** (한글 라벨 복원) |
| 5 | codex | codex 백스톱 ST4·ST5 (애그 `weather_forecast_detail` 직속·`entity/` 누락) | 추가 투영 배치 규약 불명 → detail이 애그 직속 | `architecture-ddd/references/final.md` "추가 투영 엔티티는 `entity/`·골격 완비"(mirror_sync) + backstop 규칙 보강(eval) | **codex 백스톱 ST4·ST5: blocker→0** (#2와 합류) |
| 6 | codex | codex ST-5 legacy 함수형 Provider (1차 @riverpod→회귀) | provider 형태 강제 부재 | `implementation-dart/references/final.md` "provider=@riverpod 클래스형, 함수형 Provider 금지"(mirror_sync) | **codex ST-5: WEAK→PASS** |
| 7 | 공통 차순위 | 양판 G-1/N2 정렬 (날짜 오름차순 부재) | SCENARIO §1④"표시" ↔ §4 G1"서버 순서 유지" 내부 긴장 미해소 | **SCENARIO 확정 선행**(S2/S3 작성과 연동) "오름차순=제품 보증 vs 서버 위임" + FC-GOLDEN 정렬 단언. `tools/`(eval 단일출처) | **양판 FC-1/3 G-1: 모호→확정 판정** (방향 우선 결정 필요) |

## 적용 순서 (승인 시)
1. **#1·#2 먼저**(공통 최우선·종합 FAIL 직격) → 단독으로도 다음 런 claude FC-2·codex 백스톱 회복 검증 가능.
2. #3·#6(명세/형태 일치) → backstop 규칙 보강분은 `tools/positive-control`로 거짓-FAIL 반증 후 투입.
3. #4·#5(codex 어휘·구조) → FC-GOLDEN 한글 대조와 함께.
4. #7은 SCENARIO 정책 결정(사용자) 선행 — S2/S3와 묶어 별도.

## 회차 요약 (다음 런 후 채움)
- 예상 적중 _/7 · 무효 _ · ⚠️역효과 _
- 한 줄 결론: _
