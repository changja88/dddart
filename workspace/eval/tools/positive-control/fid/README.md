# FID positive-control — L2 등가 재구성 거짓-FAIL 반증 (사전등록·feedback-011)

> **상태: 사전등록(시술·2026-06-19) — fixture Dart·실측은 판정원 도구 구현 후(step 2)**. measure-first 사전등록형: 표본 설계·예상(거짓-FAIL 0)을 *먼저* 박고, 렌더 덤프·대조 도구가 생기면 실측 대조한다(예상 어긋나면 평탄화 규칙 보정·fix 원장).
> **이 게이트의 선결성**: `RUBRIC.md §H`·`EVAL-METHOD §0-6`이 FID-L1·L2 **치명 게이트 활성**의 선결로 이 반증을 건다 — 통과 전까지 FID는 리포트·약신호.

## 기존 positive-control과 무엇이 다른가

| | `positive-control/` (notice·A12) | `positive-control/fid/` (이 문서) |
|---|---|---|
| 반증 대상 | "채점 기계가 known-good을 PASS시키나"(치명 18 거짓-FAIL) | "**FID-L2 평탄화가 등가 재구성을 흡수하나**"(구조 묶음 차이 거짓-FAIL) |
| 표본 | 합성 공지 BC 1벌(치명 18 PASS) | 같은 시안 layout-ir의 **묶음/래퍼 차이 변종 ≥2 + 음성 대조** |
| 판정원 | 백스톱·analyze·mutation | 렌더 덤프·대조 리포트(step 2 도구) |

FID는 *시각 구조*라 새 거짓-FAIL 축(등가 재구성)이 생긴다 — 같은 화면을 위젯으로 다르게 묶어도(투명 래퍼·중간 group) 시각 결과가 같으면 PASS여야 한다. 이를 게이트 투입 전 반증한다.

## 표본 설계 (같은 시안 = 같은 layout-ir·다른 위젯 묶음)

기준 시안: weekly-list card `unit.slots = [text(fixed,left), icon(flex,center), text(fixed,right)]`(동결본 §4). 이 한 unit을 위젯 트리로 **다르게 묶은 변종**:

| 변종 | 위젯 트리(card unit) | 평탄화 후(schema §3) | 예상 L2 |
|---|---|---|---|
| **A 평탄** | `Row[Text, Icon, Text]` | `[text, icon, text]` | ✅ PASS |
| **B 투명 래퍼** | `Row[Text, Center[Icon], Text]` | `[text, icon, text]`(Center 투명 흡수) | ✅ PASS |
| **C 중간 group** | `Row[Text, Row[Icon, SizedBox], Text]` | `[text, icon, text]`(중간 Row·spacer 흡수) | ✅ PASS |
| **D 적층 묶음** | `Row[Text, Column[Icon], Text]` | `[text, icon, text]`(Column 투명 흡수) | ✅ PASS |
| **(음성) E 누락** | `Row[Text, Text]` (icon 빠짐) | `[text, text]` | ❌ **FAIL이어야**(진짜 차이) |
| **(음성) F 순서** | `Row[Icon, Text, Text]` | `[icon, text, text]` | ❌ **FAIL이어야**(순서 뒤바뀜) |

**예상(사전등록)**: A~D = **거짓-FAIL 0**(평탄화가 묶음/래퍼 흡수) · E·F = 정탐 FAIL(누락·순서는 평탄화 후에도 불일치). 즉 **게이트가 등가는 통과시키고 진짜 차이만 잡는다**.

## 확정할 schema §6 4파라미터 — 변종 G~J (구현자 자유도 축소·구체 표본)

A~F가 평탄화 등가/음성을 반증한다면, G~J는 schema §6 4파라미터 잠정값을 반증한다. **구현자가 변종을 임의 설계하지 않도록 표본을 못박는다**(반증 범위 주관화 차단·D6):

| 변종 | 파라미터(schema §6) | 위젯 트리 | 잠정 규칙 | 예상 |
|---|---|---|---|---|
| **G** section fallback | §6-1 | `*Section` 없이 `Scaffold.body→Column[Text, ListView]` | body 직속 비투명 그룹=단일 section | ✅ section 1개로 정규화(거짓-FAIL 0) |
| **H** repeat 임계 | §6-2 | 동형 형제 2개 `[Row,Row]` vs 1개 `[Row]` | ≥2=repeat-group·1=block | ✅ 2개→repeat·1개→block 정확 분기 |
| **I** button 분기 | §6-3 | `InkWell(onTap:x)[Text]` vs `InkWell()[Text]` | onTap 비-null=button·null=투명 | ✅ 콜백 유무로 button/투명 정확 분기 |
| **J** 평탄화 깊이 | §6-4 | `Row[Text, Column[Padding[Row[Icon]]], Text]`(3단 중첩) | area·repeat 경계까지 재귀 평탄화 | ✅ `[text,icon,text]`로 흡수(무한 방어·스택 안전) |

**예상(사전등록)**: G~J 전부 잠정 규칙대로 정규화돼 거짓-FAIL 0. 어긋나면 해당 파라미터 잠정값을 fix 원장(예상효과 먼저·실측 대조)으로 보정 후 동결본 §6 확정. **도구 시그니처**(렌더 덤프·대조 도구 입출력)는 step 2 구현 시 A~J 표본이 통과하도록 정의된다(이 표본이 도구 인수 테스트 역할).

## 검증 계획·실측 (2a layout-ir 평탄화 완료 / 2b 렌더 덤프 대기)

**step 2a — compare 평탄화 반증(layout-ir 레벨·✅ 완료 2026-06-19)**: `fixture/run.sh`가 `ref.json`에서 변종을 파생해 `compare_layout.dart --gate`로 대조.
```
bash workspace/eval/tools/positive-control/fid/fixture/run.sh
```
- ✅ **등가 재구성 거짓-FAIL 0**: A 동일·C group 흡수·D block 펼침 → 전부 PASS(exit 0)
- ✅ **진짜 차이 정탐**: E icon 누락·F 순서변경·L1 영역누락(8차 image·bottomnav 갭 재현) → 전부 FAIL(exit 2)
→ compare의 **평탄화가 등가는 흡수·진짜 차이는 검출**함이 실증됨(거짓-FAIL 기계 아님·layout-ir 레벨).

**step 2b — 렌더 덤프 정확성(✅ 8차 실물 핵심 입증·2026-06-19)**: `dump_probe`(`../dump_probe.dart.txt` 템플릿·flutter test) + `dump_to_ir.dart`(위젯 트리→layout-ir)로 8차 claude 산출물 실측.
- ✅ **실물 등가 흡수**: weekly InkWell card→`repeat{text,icon,text}`·detail metrics `_MetricCard`→`repeat{icon,text,text}` — ListView internal 20+겹·묶음 깊이를 정규화가 흡수(거짓-FAIL 0).
- ✅ **L1 갭 결정론 포착**: weekly `누락=[image,bottomnav]`·detail `누락=[bottomnav]`(8차 사용자 지적 ② 재현).
- ✅ **false regression 해소(2026-06-19)**: 연속 동종 slot **collapse**(`compare_layout.dart _collapse`·schema §3)로 시안 div 흡수 vs 코드 `Text`×2 비대칭 해소. run.sh **G 케이스** 반증·8차 detail hero L2 ✓(`추가=[text]` 해소). 진짜 차이(E·F·L1) FAIL 유지(회귀 0).
- ⬜ 위젯 변종 A~J 정식 fixture(8차 실물로 핵심 입증·정식 변종은 9차 후속).

→ step 2a·2b **+ hero 보정 완료**. 측정 정확도 완성(L1 갭 포착·L2 등가 PASS·false regression 0). **게이트 활성 선결 = 표준 pump 진입점 규약(코퍼스 승인) 1건만 남음**(`RUBRIC.md §H` 조건 ②).

## 결론 (도구 후 채움)

⬜ FID-L2 평탄화가 등가 재구성을 흡수하고 진짜 차이만 잡음이 실증되면 게이트 활성 선결 충족. (현재: 사전등록만·도구 step 2 대기)
