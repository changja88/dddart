# feedback-003 — 지역변수 타입 명시·내비인자 VO/VM 소유·디자인 구조 충실도 (회고)

> **상태: ↩️롤백됨(revert `17100a9` · 2026-06-15) · 효과 입증 0** · 시술→검증→롤백까지 완료라 회고로 기록(템플릿 작동 검증 1호).
> **트리거** 1차 양판 — `results/20260614-0151-weather-claude.md`(❌FAIL) · `results/20260614-0135-weather-codex.md`(✅PASS+WEAK2)
> **베이스 코퍼스** `676e317` · **시술 커밋** `7717607`("지역변수 타입 명시·내비인자 VO/VM 소유·디자인 구조 충실도 게이트") · **검증 런** 2차 양판 `results/20260615-0106-weather-claude.md`·`results/20260615-0214-weather-codex.md`(둘 다 ❌FAIL) · **롤백** `17100a9`

## 시술 실체 (커밋 `7717607` · 18파일)

| 처방 | 건드린 파일 | 목적 유형 |
|---|---|---|
| 지역변수 타입 명시 | `implementation-dart/SKILL.md`·`references/final.md`(양판)·`external.md` | 방언 정합(HaffHaff ~96% 명시) |
| 내비인자 VO/VM 소유 | `architecture-ui/references/final.md`·`design-architect`·`design-review-ui` | 결함 교정(codex 내비 WEAK) |
| 디자인 구조 충실도 게이트 | `architecture-ui/references/final.md`·`design-review-ui`·`dddart/SKILL.md`·`commands/dddart.md` | 결함 교정(design-ref 충실) |
| (부수) | `README.md`·`dddart-coder/SKILL.md` 각 2줄(내비/타입 문구만) | — |

**★사실: `coder.md`·`dddart-coder/SKILL.md` 변경 = 각 2줄, 테스트 산출 책무 추가 0.** 1차 claude 종합 FAIL의 *단독 원인*(FC-2 테스트 0)을 구조적으로 안 건드림.

## 사전등록 vs 실측 (회고 재구성)

| 1차 측정 결함 | 심각도 | 피드백3 겨냥 | ④예상효과(있었다면) | ⑤실측(2차) | 판정 |
|---|---|---|---|---|---|
| **claude FC-2 테스트 0** | **치명·FAIL 단독원인** | ❌ 안 함 | (적었어야: FC-2 FAIL→PASS) | FC-2 **여전 FAIL**(테스트 0) | ❌ **결정적 원인 방치** |
| claude 정렬 미문서화 | 중 | △ 간접 | — | 2차도 정렬 부재 | ❌ 무효 |
| claude 도메인 얇음(애그+enum 2개) | 비치명 | ✅ 디자인 충실도 | 도메인 표현력↑ | **게이트 비발동**(2차 design-ref 부재·Stitch 미연결) | △ **효과 귀속 불가** |
| codex 내비 end-to-end 커버리지 공백 | WEAK | ✅ 내비 VO/VM | 내비 배선↑ | codex 2차 백스톱5로 선-FAIL | △ 측정 무의미 |
| codex 정렬 취약성 | WEAK | ✗ | — | 2차도 정렬 위임 | = |
| 지역변수 타입 명시 | **1차 미측정**(Q PASS) | ✅ | — (겨냥 dim 없음) | 2차도 측정 dim 없음 | — **방언 정합 목적·라이브런 검증 대상 아님** |

### ★디자인 충실도 게이트 = 발동 기회 0 (핵심 정정)

피드백3 디자인 게이트는 전부 **"design-ref가 있으면"** 전제(diff: "(있으면) design-ref", "이미지/시안이 있으면"). 그런데 **2차는 양판 모두 Stitch MCP 미연결 → design-ref 부재**(compare.md 헤더 "디자인=Stitch MCP 미연결→자체설계") → **게이트 비발동.** 따라서 claude 2차 도메인 풍부(`forecast_date` VO·`forecast_summary` entity)를 이 게이트 효과로 **귀속할 수 없다**(초기 회고의 "✅개선" 판정은 오귀속 — 정정). 이 게이트는 *해로운 게 아니라 미검증*이다 — Stitch 연결 라이브런에서 사전등록형 재검증 가치 있음(→ 별도 과제).

### 신규 회귀 (피드백3가 예측 못 함 — 피드백3 변경 영역과 교집합 0 = 비결정성)

| 회귀 | 1차 | 2차 | 피드백3가 그 영역 건드림? |
|---|---|---|---|
| **claude ST-2** | ✅ `throw error`(BadReq) | ❌ `throw Exception(failure.msg)` 격하 | ❌ 에러처리 무변경(§2는 catch·타입뿐) |
| **codex G-8 라벨** | ✅ 한글 | ❌ 영문·overcast→cloudy 의미밀림 | ❌ 어휘/라벨 무변경 |
| **codex 백스톱** | 0 | 5 blocker | ❌ 구조 규약 무변경 |
| **codex ST-5** | ✅ @riverpod | 🟡 legacy Provider | ❌ provider 형태 무변경 |

→ 4건 모두 피드백3가 건드린 3영역(디자인·내비·타입)과 **무관**. 즉 회귀는 피드백3 *부작용이 아니라 런 비결정성*이며, **롤백해도 돌아오지 않는다**(diff 사실·N=1 비결정성).

## 회차 요약

- **예상 적중 0/0**(측정 dim으로 사전등록한 처방 0) · 효과 입증 **0** · 회귀 4(피드백3 무관·비결정성)
- **한 줄 결론**: 피드백3 3영역 전부 2차로 효과 입증 0 — 디자인 게이트=design-ref 부재로 **비발동**, 타입 명시=측정 dim 없음(방언 정합 목적), 내비 VO/VM=codex 선-FAIL로 측정 무의미. 효과 없는 변경을 코퍼스에 남기면 근거 없는 규칙이 쌓이므로 **`17100a9`로 롤백**. 회귀 4건은 피드백3와 교집합 0(롤백 무관·비결정성). 결정적 치명(claude FC-2)·구조(codex 백스톱)는 애초에 피드백3가 안 겨냥 → **`feedback-004`가 사전등록형으로 재겨냥.**
- **잔존 과제**: 디자인 충실도 게이트는 *미검증*(비발동)이지 해롭지 않음 → Stitch MCP 연결 라이브런에서 사전등록형 재투입 검토(현 롤백엔 포함됨).
- ⚠️ N=1 인과 단정 금지: 회귀가 "피드백3 탓이 아님"은 단정이 아니라 *변경 영역 교집합 0*이라는 diff 사실에서 온다.
