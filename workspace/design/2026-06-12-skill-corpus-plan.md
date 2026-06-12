# 스킬 9종 코퍼스 작성 설계안 (§10-3)

> **상태: v3.3 — 확정 (2026-06-12). Wave 1·2·3 완료**(W1: discipline-houserules + undecidable.md 17종 / W2: architecture-state·data·ui / W3: architecture-ddd·discipline-cleancode — §10-5 ③ 사용자 확정 안 A(루트 경유 3규칙), 80펜스 Dart 치환, 5렌즈 리뷰+재검 12/12·판정 소유 관통 blocker 0건·전방 위임 10곳 백필). 적대 리뷰 3렌즈(skill-creator·plugin-dev·내부 정합, 22건) 반영 후 검증 워크플로 3렌즈까지 반영. 단일 근거: 본설계 §8(절 귀속·lens 경계)·§9(판별 배정)·§10-3(제약), 제1 규약, `workspace/reference/spec.md`(작업장 규약). 리뷰 결정 2건 채택: ① 규약 §6 common → houserules 귀속(본설계 §8 동시 개정) ② Wave별 경량 관통 테스트 도입. W2 추가 확립: 공유 reference 위임은 첫 언급에 `${CLAUDE_PLUGIN_ROOT}` 전체 경로 1회+이후 단축 / 실물(HaffHaff) 추종은 규약이 고장으로 진단한 지점에서 면책 근거가 아니다(isShow 판례).

## 1. 완결 단위

한 스킬 = 원료 → (review.md) → **final.md(작업장)** → **SKILL.md + references/final.md(배포본)**.

- 배포본 절단 기준(dddjango 실물 실측): **"P1 Source Sufficiency" 절만 제거**하고 제목·서지(출처 blockquote)는 배포본에도 유지한다. 작업장 final이 **P1 절**의 단일 보관처.
- 미러 불변식: 작업장 final 본문(**P1 절 제거 후**) ≡ 배포 final 본문 — spec.md 불변식 1에 같은 단서를 동반 개정(2026-06-12). corpus_mirror_sync 포팅 시 이 절단 의미론을 반영한다(미반영 시 전 스킬 drift 오발화 또는 작업장 P1 절 오삭제).

## 2. 작성 순서 — 4 Wave (작업 성격 기준)

| Wave | 스킬 | 성격 | 비고 |
|---|---|---|---|
| 1 | discipline-**houserules** + **17종 공유 reference** | 규약 직접 인용 | 유일한 필독 스킬·표준 트리 단일 출처. 첫 산출물로 양식 확정 |
| 2 | architecture-**state → data → ui** | 규약 직접 인용 | 파이프라인의 심장(§10-5 ① 결정 전부) |
| 3 | architecture-**ddd** · discipline-**cleancode** | 이식(치환·선별) | 원료 완전체 반입 완료. **합성 중 §10-5 ③(애그리거트 일관성 경계 규율) 결정 — 사용자 확인 지점** |
| 4 | implementation-**dart · flutter · riverpod** | 외부 조사 | 조사 3종 병렬, 합성은 riverpod 우선. **flutter 작성 중 §10-5 ④(스크롤톱) 결정 — 사용자 확인 지점** |

**전방 참조 규칙**: 선행 Wave가 후행 스킬 소유 주제를 만나면(예: state가 UseCase 관문을 서술할 때) 본문으로 풀어 쓰지 않고 **"스킬명 + 주제" 위임 한 줄**만 둔다(미작성 final의 §번호는 인용할 수 없으므로 §번호 위임은 후방 참조에만). **Wave 완결 단계에서 선행 Wave가 남긴 전방 위임에 §번호를 백필하고 grep으로 잔여 placeholder 0건을 검증**한다. 중복 서술은 발산의 시작이다.

## 3. 스킬별 원료·목차 골격·review 여부

| 스킬 | 원료 | final.md 골격 | review.md |
|---|---|---|---|
| houserules | 규약 §2·§3.7·§4·§5·§7·§8 + **§6 중 common**(입장 판별 4단계·콜백 주입·역import 금지) + 백스톱 연동 절은 **백스톱 설계 §2·§3**(검사 열거 금지 — 러너 호출 사실+패밀리 4종 수준만) | 표준 트리 전문 + 성장 규칙 + 골격 완비 + 명명 총괄표 + import 매트릭스 + 표기 표준화 + common 입장 판별 | 생략 (원료가 적대 점검 통과본) |
| ui | 규약 §3.5·§3.1·**§6 중 design_system** | 바인딩 1단+표현 2단, BC 루트 라우팅 짝, design_system 사용 규칙·전역 키 show() 금지. **트리 구조·import 가능 계층 '사실'은 houserules 위임 — ui 본문은 사용 '절차'(전환 토큰·show() 금지 사례·ui_extension 자리)만** | 생략 (순수 슬라이스) |
| state | 규약 §3.3·§3.6·**§9-11 + §8 해당 행**(refresh_notifier 등 drift 처방 — §8 '사실'은 houserules 소유, state는 처방 '절차'만) + §10-5 ① | VM 3변종, State 계약(항상 freezed `*State`), 에러 2채널(조회 throw / 액션 error 필드+consumeError), **컨트롤러 View 소유(값은 VM 메서드 인자)**, **표준 listen 패턴 정식 예제(base VM·공용 헬퍼 없음 — 규율 자체는 cleancode 소유)**, shared_state, 4채널 상태 측면(교차 BC SharedState watch 금지·root 면제), refresh 채널 처방(refresh_notifier 폐지), 일회성 이벤트 소비, keepAlive 수명 결정, 합성 루트 | 작성 (결정 밀도 최고) |
| data | 규약 §3.4·**§9-9(로컬 2층)** + 본설계 **§2·§4·§5**(계약 스냅샷 산출물 정의·동결·폴백·사용 규율) + 백스톱 설계 §7 — **도구 명칭·사양은 백스톱 설계 §7이 단일 근거**(`extract_contract.dart`) | 실패의 단일 출구(safeApiCall 정규화), Repo Either 계약, 로컬 2층, 계약 스냅샷·extract_contract 사용법, '계약 위험 행위' 판별(본설계 §9 신규 1 — tracer 앵커) | 작성 |
| ddd | internal+external(반입) + 규약 §3.2·**§3.3 중 UseCase·판정 소유·강등**·§9 결정 | dddjango 절 구조 승계하되 선별: 전술 패턴·UseCase 관문·판정 소유(1곳째부터 domain 기본·Model 밖 2곳 강등) + "dddart 비채택" 명시 절 | 작성 (선별 기록) |
| cleancode | internal+external(반입) + §10-5 코드 규율 | dddjango §1~§17 승계, Python 예제 82개 Dart 치환, §10-5 규율(반복>상속) 추가 | 작성 (치환 기록) |
| dart | 외부 조사 | Effective Dart, 타입·널 안전, freezed 표기법 | 작성 (조사 신뢰도 검증) |
| flutter | 외부 조사 | 프레임워크 코어, go_router·dio·retrofit(@RestApi)·hive 표기법 | 작성 |
| riverpod | 외부 조사 | @riverpod 5변종 화이트리스트, keepAlive 표기법, watch/listen 규율 | 작성 |

## 4. 제약 반영 지점 (본설계 §10-3·§8·§9)

- ⓐ 필독은 houserules뿐 — 나머지 8종 SKILL.md는 "언제 쓰나 + 경계 위임" 절로 라우팅(전량 적재 차단).
- ⓑ houserules SKILL.md ≤8KB — SKILL.md가 곧 규칙 본문(결정 순서 → 충돌 중재 → 레드 플래그 → 백스톱 연동), 구체 트리는 final.md. 분량 집행은 §5 참조.
- ⓒ **17종 공유 reference 1파일** — 구성: 파이널 리뷰 §6의 원 17종 중 'export된 view'는 백스톱 이관으로 **실질 16종**(본설계 §9) **+ 신규 1 '계약 위험 행위' = 17종**. 원료 = 파이널 리뷰 §6 + **본설계 §9 표(배정표 포함)**. 위치 `discipline-houserules/references/`, 참조 경로는 **`${CLAUDE_PLUGIN_ROOT}/skills/discipline-houserules/references/<파일>.md`**(상대 경로 금지 — 설치 캐시에서 깨짐). 적재 대상 = **§9 배정표의 전 에이전트 양쪽**: 1차 결정자(design-architect·coder)와 검증자(design-review 4종·discipline-reviewer) — §10-4 에이전트 정의에서 경로 주입하고, **houserules SKILL.md 라우팅 표에도 1행 등재**(미참조 번들 자산 금지).
- keepAlive 경계 문구는 architecture-state·implementation-riverpod 양쪽 SKILL.md에.

## 5. SKILL.md·final.md 공통 양식 (dddjango 동형 + 리뷰 보강)

**frontmatter**: `name`·`description`·`user-invocable: false`.

- `user-invocable`은 공식 skill-creator 검증기의 허용 필드가 아니다(Claude Code 런타임 수용은 dddjango로 실증). → **공식 .skill 패키징 도구체인(quick_validate/package_skill) 사용 금지**를 전제로 유지.
- **description 규칙**: 9종은 자동 트리거용이 아니라 **에이전트 주입 전용** — dddjango식 pushy 트리거 문구를 의도적으로 비승계한다. 1~2문장의 좁은 식별·위임 서술(설치 사용자의 매 세션에 상시 적재되는 비용 + 메인 스레드 오발동 차단). 화살괄호 금지(`AsyncValue<T>` 등 제네릭 유입 주의), 1024자 이하.

**본문(8종 공통)**: "언제 쓰나"(= 트리거 조건이 아니라 **로드 후 행동 지시** — 어느 절을 읽고 무엇을 타 스킬에 위임하나; 공식 규칙과의 의도된 변형) → "핵심 운영 원칙"(§인용 불릿 8~10개) → "상세 레퍼런스"(주제→final.md 절 라우팅 표).

**houserules 특수 양식(공통 양식 면제)**: ⓑ의 4절 구조(결정 순서→충돌 중재→레드 플래그→백스톱 연동) + 라우팅 표만. 8KB 집행 장치 —

- 절별 예산: 결정 순서 ~3KB / 충돌 중재 ~1KB / 레드 플래그 ~1.5KB / 백스톱 연동 ~0.5KB / frontmatter+라우팅 표 ~1.5KB ≈ 7.5KB (dddjango 실물 19.7KB는 동형 기준이 아니라 압축 대상 — 같은 4절이 dddjango에선 9.4KB+).
- 압축 전략: dddjango식 개정 서사("…개정으로 폐지됐다")·동일 규칙 다중 반복 강조를 비승계하고 **현행 규칙만** 서술. 17종 공유 reference 등재는 라우팅 표 1행.
- 초과 시 강등 순서: 레드 플래그 상세 → 백스톱 연동 상세를 final.md로 이동(8KB는 본설계 §10-3 확정 제약 — 완화하지 않는다).

**final.md**: 상단 **TOC 필수** + **grep 가능한 안정 헤더 규약(`## §N.` 일관)** — 90KB급은 Read 1회 기본 한도(2000줄)를 초과하므로 부분 적재(grep→offset Read)가 전제다.

**상호 참조 규칙**: 스킬 본문 간 참조는 **"스킬명 + §번호" 위임**(후방) 또는 **"스킬명 + 주제" 위임**(전방 — §2 백필 규칙)만 허용, 파일 경로 금지(유일 예외: ⓒ의 공유 reference `${CLAUDE_PLUGIN_ROOT}` 경로).

**중복 소유 경계**: houserules = 트리·명명·import **사실**의 단일 출처 / lens(architecture 4종) final = 판별·결정 **절차** + houserules 위임 인용. 같은 사실을 두 final에 본문 서술하지 않는다 — 규약 직접 인용 Wave(1·2)에서 원료 절이 매트릭스 사실을 포함하면 **위임으로 치환**해 옮긴다(§3 ui 행의 마킹이 그 집행).

## 6. 검증 — 체크포인트 + 관통 테스트 + 로드 스모크

1. **최소 plugin.json 선생성**(완료 — `{"name": "dddart"}`). **로드 스모크의 양성 신호**: `claude plugin details dddart`의 컴포넌트 인벤토리에서 **Wave별 기대 스킬 수**(W1=1 → W2=4 → W3=6 → W4=9)를 확인한다 — 세션 기동 성공만으로는 frontmatter 파싱 실패로 인한 침묵 누락(0개 상태와 관찰 동일)과 구별 불가. 현 단계(SKILL.md 0개) 스모크가 확인하는 것은 manifest 파싱뿐.
2. **Wave별 4렌즈 AI 리뷰**(2026-06-12 Wave 1에서 사용자 육안 검토를 대체 — 사용자 지시 "독자는 AI이므로 서브에이전트 리뷰가 더 정확"): ⓐ skill-creator 공식 기준 ⓑ plugin-dev 공식 기준+기계 검증 ⓒ **AI 소비성 실증**(신선한 에이전트가 라우팅 표→grep→부분 적재로 마이크로 과제 수행, 전문 읽기 금지) ⓓ **원문 충실도**(누락·왜곡·발명 사냥 — 발명은 P1 이상). 워크플로 병렬 실행, 발견 반영 후 재검 1회. Wave 1 실증: ⓒ가 라우팅 실효를 측정(과제당 1~2 Read)하고 ⓓ가 합성자의 자가 수정 오류(경계 규칙 발명)를 잡았다.
3. **Wave별 경량 관통 테스트 1회**(공식 skill-creator의 평가 루프 최소선). **주입은 누적** — houserules를 상시 포함한다(생산 에이전트 프로필(본설계 §8 표)에 lens 단독 조합이 없고, lens final은 사실을 houserules에 위임하므로 단독 주입은 위임 해소 불능). 기준:
   - Wave 1: houserules 주입 → BC 1개 빈 골격 생성 → 백스톱 구조·명명 통과. **17종 공유 reference는 백스톱 검증 불능 영역(기계 판별 불가)이므로 판별 판례 소과제(정답지 대조)로 분리 검증.**
   - Wave 2 예: houserules+state+data 주입 → VM 1개 생성 → 백스톱 gated 0건.
   - 결함은 해당 Wave에서 수정(코퍼스 완주 후 발견 시 수정 비용이 9종으로 번짐).
4. Wave 단위 완결(final+SKILL+배포 복사+커밋) 후 보고. **완결 단계에 §2의 전방 위임 §번호 백필+grep 검증 포함.**

## 7. 상위 문서 개정 기록 (이 설계가 유발한 개정)

- 본설계 §8 귀속표(2026-06-12, 2건): ① discipline-houserules에 "규약 §6 중 common" 추가 — 적대 리뷰가 발견한 귀속 공백(common은 HaffHaff 최다 drift 축인데 무귀속) 보정 ② architecture-state에 "컨트롤러 View 소유" 추가 — §10-5 ① 확정 5건 중 운반자 없던 1건 보정.
- 본설계 §10-3: "16종 공유 reference" → "**17종**(실질 16 + 신규 1 — §9)" 수치 정합.
- 본설계 §5-7·§10-2: `extract-contract.py` → `extract_contract.dart` 2곳 교정(백스톱 Dart 전환 시점의 stale 표기).
- spec.md 미러 불변식 1: 본문 정의 단서("P1 절 제거 후, 제목·서지는 배포본 유지") 추가.
- §10-4 메모: 에이전트 frontmatter `skills:` 필드는 공식 plugin-dev 코퍼스 문서화 범위 밖(dddjango 작동 실증) — dddjango와 자구까지 동일하게 유지하고, 주입 수신 스모크 1회를 작성 게이트로.
