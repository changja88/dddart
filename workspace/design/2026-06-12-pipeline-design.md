# dddart 파이프라인 본설계 (§10-1)

- 상태: **초안 — 적대 리뷰 5렌즈(2026-06-12) 반영 완료, 사용자 최종 확정 대기**
- 입력: `2026-06-12-pipeline-agent-composition.md`(확정) · 제1 규약 `2026-06-11-dddart-file-tree.md`(확정) · dddjango 실물(`/Users/hyun/Desktop/dddjango/dddjango/`) · `2026-06-12-slice-simulation.md` · `2026-06-12-pipeline-adversarial-review.md`(blocker 11·사용자 결정 4건 — 전부 반영)
- 지위: `/dddart` 커맨드와 에이전트 7종 파일(§10-4에서 작성)의 단일 근거. **dddjango에서 바뀌는 것만 상세히 적고, 같은 것은 "dddjango 동일"로 표기** — 동일 항목은 §10-4 작성 시 원문을 용어 치환으로 이식한다.

---

## 1. 전체 구조

dddjango와 같은 게이트 골격. Coordinator는 오케스트레이션·게이트·산출물 통합·검증 보고를 맡고 설계 명세·구현 코드는 직접 쓰지 않는다. **Coordinator가 직접 쓰는 것**: 스코프 메모 · 검증 보고 · 외부 진실 스냅샷(config·openapi 동결본·server-contract·design-ref) · git 스냅샷 기록 · `build-state.json`.

| 단계 | 게이트 | dddjango 대비 변화 |
|---|---|---|
| Phase 0 요구·스코프 | G0 | 모드 **삼분류**(풀/수정/트리비얼) + 전제조건 검사 + 외부 진실 출처 해소(lens 제안 절차는 삭제 — 4축 항상) |
| Phase 1 설계 | G1 | 리뷰어 4종 전부 병렬(풀 빌드) + G1 직후 계약 기계 절단 |
| Phase 2 구현 | G2 | TDD 이중 루프 제거 — 규모 적응형 2분할, codegen 규약, 베이스라인 green, 백스톱 러너 |
| Phase 3 마무리·검증 보고 | — | 동일(실행한 검증만 보고) |

## 2. 산출물·설정

- 기능 산출물 폴더 `.dddart/<생성일>-<기능-slug>/`: `scope.md` · `design-spec.md` · **`openapi-full.json`**(G0 동결 원본) · **`server-contract.json`**(G1 직후 기계 절단 경량본) · **`design-ref/`**(디자인 이미지) · **`build-state.json`**(phase·완료 슬라이스·git 스냅샷 ref·G1 결정 로그·analyze 베이스라인 — 세션 사멸 후 재개 앵커). 폴더 생성·재사용 절차(ⓐ/ⓑ 선택)·기본 커밋 — dddjango 동일. 단 `ls .dddart/` 목록은 **디렉터리만** 나열(config.json이 섞이지 않게).
- 프로젝트 설정 `.dddart/config.json`: `"openapi_url"` 단일 키(다중 서버 출처는 1차 범위 아님 — 명시). 갱신은 Read 후 Write. **Coordinator만 읽고 쓴다** — 하위 에이전트 본문에 금지 1줄을 박는다(산문 강제, dddjango "하위는 명세만" 규율과 동급).
- 동시 세션: **한 프로젝트 한 빌드** 가정(git 스냅샷·touched-gate·config 갱신이 간섭하므로).

## 3. 진행 가시성

dddjango 동일 — TodoWrite task 리스트 + 게이트에서만 트래커·배너 + 게이트 사이 한 줄 상태 + 산출물은 경로+요지만. lens가 항상 4축이라 트래커에 lens 표기 없음.

```
dddart  [✓ 스코프] → [▶ 설계] → [· 구현] → [· 마무리]
```

## 4. Phase 0 — 요구·스코프 (G0)

**모드 판별 — 구조 단위 삼분류**(파일 수 기준 아님 — "신규 파일이면 풀"과 소형 축퇴의 모순 해소):

- **풀 파이프라인**: 신규 화면(view 삼총사)·신규 애그리거트·신규 BC·라우트 추가 중 하나라도 생기면.
- **수정 모드**: 기존 구조 안의 파일 추가·수정(신규 파일이 있어도 기존 구조 내 — 예: 기존 화면에 section 1개 추가).
- **트리비얼**(2026-06-12 결정 D1): 신규 파일 0 + 비구조 diff(문구·토큰 값·아이콘 — 시그니처·State 모양·라우트 불변). 절차 = 판정을 배너로 승인 1회 → 직접 편집 → touched 백스톱+analyze만(에이전트·빌드·G2 생략). *왜* — 하한 없는 무거움(라벨 수정에 10~20분·개입 2회)은 파이프라인 우회를 학습시키고, 우회 경로엔 백스톱조차 없다 — 패스트트랙이되 접수대(백스톱)는 거친다.

판별된 **모드와 근거를 G0 배너의 1급 항목으로 항상 표시**하고 승인받는다(dddjango "모호하면 확인"보다 강화). *왜* — 입구는 단일 커맨드+자연어 판별 유지(사용자 사전 분류는 코드를 본 조사보다 부정확, 커맨드 분리는 표면 2배), 모드 추론은 lens 추론(폐지)과 달리 오판이 항상 게이트에 표면화되고 근거가 기계적이라 추론을 둬도 된다.

**전제조건 검사**(신설 — 적대 리뷰 A7): git 저장소 여부·작업 트리 청결을 확인한다. 비git이면 git 스냅샷·touched-gate가 전체 검사로 퇴화함을 G0 배너에 고지. dirty면 "커밋/스태시 후 진행 vs 그대로 진행(중단 복구 불가 고지)"을 배너 항목으로 표면화 — 사용자 WIP를 파이프라인이 무단 커밋·파괴하지 않는다.

**서버 계약 출처 해소**:
1. 커맨드 인자에 OpenAPI 주소가 있으면 그것을 쓰고 config에 저장/갱신.
2. 없으면 config의 `openapi_url`을 읽어 한 줄 보고.
3. 둘 다 없으면 1회 안내 후 저장. 답 없으면 폴백: 기존 DataSource 패턴 → 가정 계약(G1 확인 항목 승격). **URL fetch 실패(죽은 주소·인증 필요)도 '없음'과 같은 폴백에 합류 + G0 배너에 표시.**
4. 출처가 URL이면 **G0 승인 후 openapi.json 원본 전체를 `openapi-full.json`으로 동결**(Bash로 취득 — 도구 확정은 §10-4). "관련 엔드포인트 절단"은 여기서 하지 않는다 — '관련' 판별은 LLM 재량이고 G0엔 명세가 없다. **절단은 G1 직후 기계 수행**(§5-7).
5. 폴더 ⓐ 재사용 시 "외부 진실 스냅샷 재동결 여부"를 폴더 선택 질문에 합류(stale 계약 방지 — design-ref 동일).

**화면 디자인 출처 해소**(개정 — 수동 폴백이 1급 기본 경로, 적대 리뷰 A10):
1. **기본 경로**: 사용자가 내보낸 이미지 파일 경로를 받아 Coordinator가 Bash `cp`로 `design-ref/`에 동결. Write 도구는 텍스트 전용이라 Coordinator가 이미지를 직접 저장할 수 없다.
2. **MCP 경로는 보조**: 세션에 "이미지를 로컬 파일로 만들 수 있는" MCP 서버가 연결돼 있을 때만(서버 변종 의존 — Stitch는 표준 MCP 부재).
3. 출처 없음 = Claude 자체 설계(기존 화면 관례+design_system 토큰) — 정상 경로.
4. 경계 규율 유지: 디자인 출처는 "무엇처럼 보이나"의 단일 근거, **Figma 생성 코드 직수입 금지**. config 비저장(기능별 값).

스코프 메모 Y 항목·배치 질문 — dddjango 동일(기존 서술 유지).

## 5. Phase 1 — 설계 (G1)

골격(architect 초안 → 독립 리뷰 병렬 → 반영·중재 → G1 배너 → 결정 처리 ①기본 수락/②Y 채택/③Z 결정) — dddjango 동일. 차이:

1. **architect 입력**: 스코프 메모 · `openapi-full.json` 경로 · (있으면) `design-ref/` · 명세 저장 경로 · (있으면) BC 배치 고정 · (있으면) G1 override. 조사 의무에 design_system·common 재사용 후보 추가. **"필요한 엔드포인트가 동결본에 없으면 임의 가정하지 말고 보고"** 규율(스냅샷 절단 누락의 안전망).
2. **명세에 담는 것** — 4 lens + lens 무관 2(기존 서술 유지)에 추가:
   - **판정 소유 라벨링(양성 규칙 — 적대 리뷰 A1)**: 행위 목록의 모든 수치·비교·자격 판정에 소유자(애그리거트 메서드·domain_service·specification vs VM 변환)를 **항목별로 명시**한다. **도메인 어휘로 진술되는 판정은 1곳째부터 domain이 기본**이고, VM 소유 주장에는 *왜*를 요구한다. *왜* — 신규 기능의 판정은 항상 소비처 1곳이라 "2곳 복제 강등"만으론 빈혈에 집행자가 없다.
   - **계약 위험 행위 표기(data)**: 스냅샷·기존 패턴으로 확인 불가한 의미 가정이 걸린 행위를 명세에 '계약 위험'으로 표기한다(tracer 발동의 기계 앵커 — §9 표의 신규 행).
3. **자기모순 1회 스캔**(dddjango architect 동형): 절 간 소유권·명명·시그니처·불변식 일치 — **구조 결정 절(파일 목록·분할) 포함**(§4 성장 규칙·철자 일치 — "두 번째 개념"의 1차 결정은 파일 목록 소유자인 architect다).
4. **리뷰어 4종 전부 병렬** — 각자 명세 + 명세가 인용하는 동결 스냅샷(`openapi-full.json`의 인용 부분은 data, `design-ref/`는 ui)을 본다. 타 노트·코드 안 봄. "해당 없음 + 근거 한 줄" 의무, 누락 자체를 발견으로.
5. 가정 계약의 G1 배너 승격(동일).
6. (선택) discipline-reviewer 경량 점검 — Coordinator 재량(동일).
7. **G1 승인 직후 — `server-contract.json` 기계 절단**: 명세가 인용한 엔드포인트 paths를 입력으로 `extract-contract.py`(paths 선별 + `$ref` 전이 폐쇄 추출 — §10-2 산출물)를 Bash로 실행해 경량본을 만든다. *왜* — '관련' 판단이 명세 인용으로 치환돼 LLM 재량이 소멸하고, LLM 손절단의 dangling `$ref`(깨진 스냅샷)를 막는다. 이후 coder·G2는 경량본만 본다.

## 6. Phase 2 — 구현 (G2)

> **잠정 확정(2026-06-12)**: 슬라이스 분할·작업 순서는 지면 시뮬레이션 3렌즈 + 적대 리뷰 5렌즈를 거친 **"규모 적응형 Model/View 2분할"**. dddjango의 행위 세로 슬라이스는 근거(1 인수 테스트 ≈ 1 슬라이스) 소멸로 불승계. **최종 확정은 2단계 실측 후**(§10 — 비교 대상: 안 2 행위 세로+결정적 묶기). coder **순차 호출**(병렬 금지)은 확정.

절차:

1. **슬라이스 도출(Coordinator, 기계 규칙 — 정수 임계)**: 계수 = 명세 파일 목록의 신규+수정 합산(코드 작성 전 계산 가능 — 줄 수는 도출 입력이 아니다).
   - **축퇴(1호출)**: 기능 전체가 풀 빌드 **7 이하** / 수정 모드 **5 이하**.
   - **2분할**: 그 초과 — 슬라이스 1(Model) = 골격+domain+infra+application(use_case·state·view_model·shared_state·**service** — **hive 어댑터 파일 생성 포함**) / 슬라이스 2(View) = presentation(view·section·**widget**·ui_extension) + 배선(BC router GoRoute·root branch·**root_initializer의 hive 어댑터 조립 1줄**·handler 연결).
   - **세분**: 한 슬라이스가 풀 **8 이상** / 수정 **6 이상**이면 Model은 애그리거트·계층 단위, View는 화면 단위로 분할.
   - **tracer 선행 — 기계 플래그 2개 중 하나면**: ① 가정 계약(G1 승격 케이스) ② 명세의 '계약 위험' 표기 행위 존재. tracer = 하층 관통 + 그 위험 행위 1개의 종단 1줄기. tracer가 골격 생성을 소유하고(첫 슬라이스), tracer가 만든 파일은 후속 슬라이스에 "기존 수정" 의미론으로 전달.
   - 행위 목록은 슬라이스 단위가 아니라 G2 체크리스트·행위↔코드 대조의 단위(동일). task 리스트에 하위 task로 펼친다.
2. **슬라이스마다 coder 순차 호출** — 입력: 명세 · 이번 슬라이스 · `server-contract.json` · (있으면) design-ref · **기존 BC 트리 요약**(기존 BC 수정 시) · **골격 생성 포함 여부 플래그**(무기억 coder는 자신이 첫 호출인지 모른다). *왜 순차*(기존 서술 유지 — green 기준 시점·컨텍스트 비대 없음). 호출 절차:
   1. **git 스냅샷**: 호출 시작 전 현재 커밋 해시를 `build-state.json`에 기록. **슬라이스가 green으로 끝날 때마다 커밋**(§2 기본 커밋과 정합). 중단(F3) 복구 = 기록 해시 이후 변경만 revert 후 동일 입력 재호출 — G0 전제조건 검사 덕에 사용자 기존 변경은 불가침.
   2. 내부 **bottom-up**(참조 실재·오류 국소성·빈혈 차단 — 기존 서술 유지): Model 호출 = 골격(플래그 시 — §5 골격 완비 전체: 종류 폴더 .gitkeep + `<aggregate>.dart` 항상 생성, 이번 작업이 신설하는 모든 골격 단위 — BC·개념 폴더·root·design_system) → domain → infra → application. View 호출 = presentation → 배선. 명세 파일 목록이 닿는 계층만.
   3. **codegen 규약(신설 — 적대 리뷰 A6)**: codegen 어노테이션(@riverpod·@freezed 등)을 touched했으면 **analyze 전에 `dart run build_runner build --delete-conflicting-outputs` 실행**. build_runner 미설치면 버전-핀 규율(무핀 설치로 resolve한 실버전을 dev_dependencies에 핀)로 준비. codegen 오류는 analyze 오류와 구분해 보고. *왜* — `.g.dart` 부재면 green 래칫이 구조적으로 깨진다.
   4. **층별 green 래칫 — green의 정의(신설 — 적대 리뷰 A5)**: Phase 2 진입 시 Coordinator가 **analyze 베이스라인을 1회 캡처**(build-state.json 기록). green = **베이스라인 대비 신규 이슈 0**(브라운필드의 기존 경고·오류에 불발화). 기존 파일 수정은 파일별 green(= touched 파일에 error 0). 각 계층 끝마다 Bash 실제 실행(자동 통과 간주 금지).
   5. 임계 근접 호출은 공개 표면 먼저 → analyze → 본문 2단 권장(줄 수 ~1.2k 초과 예상이 발동 신호). 호출 경계를 넘는 타입 스텁 파일 선생성 금지(동일).
   - **반송 규율(확장 — 적대 리뷰 A3·A1)**: 기존(구조 결정 부재·규약 어긋남·메커니즘 대체 금지)에 더해 — **"이번 슬라이스의 계층 밖 파일 수정이 필요해지면(View 슬라이스의 State 필드 부족 포함) 수정도 우회 계산도 금지, 보고한다**(Coordinator가 Model 재개봉 또는 설계 반송 판단). **View 슬라이스에서 Model 파일이 변경됐으면 Model 경계 경량 감사 1회 재실행**". + **기존 BC 수정 시 같은 판정의 기존 복제를 grep 후 발견을 보고**(강등 규칙의 관측자 — 지금까지 발화 조건을 볼 에이전트가 없었다).
3. **discipline-reviewer 감사 리듬**: 기본 G2 직전 홀리스틱 1회 + **Model/View 경계 통과 시 경량 1회**(판정 소유 감사 최적 시점) + 슬라이스 **3개 이상**(dddjango 동일 — '4개' 표기 정정)이면 슬라이스별 경량. **입력(필수)**: 코드 · 명세 · **슬라이스 계획 · 현재 완료 슬라이스(=감사 범위)** — "아직 안 만든 것"과 "누락"을 구별(적대 리뷰 I12). 홀리스틱 점검에 ① 행위 목록↔코드 실현 대조 ② **판정 소유 대조(신설 — 명세의 소유자 라벨 ↔ 실제 위치, 새 판정이 그 BC domain에 0개이고 VM·view·State getter·ui_extension에만 살면 blocker — dddjango C형 직격의 클라이언트 이식)**.
4. **결정적 백스톱**: **러너 스크립트 1개로 일괄 실행**(39종+추가분을 커맨드에 인라인하지 않는다 — dddjango식 인라인이면 카탈로그만 ~28KB, 적대 리뷰 I14). blocker(종료코드 2)면 발견 합쳐 한 번에 반송(동일). 통과가 discipline 의미 점검을 면제하지 않음(동일).
5. **빌드(개정 — 적대 리뷰 I10)**: 타깃 결정 절차 — 기존 빌드 스크립트·CI 설정 감지 → 없으면 android 존재 시 `flutter build apk --debug`, iOS 전용이면 `--simulator` 또는 `--no-codesign` → 판별 불가면 G2 배너 전 1회 질문. **환경 기인 실패(툴체인·서명)는 반송이 아니라 미실행 보고**(코드 기인 실패만 반송) — 거짓 반송 루프 차단.
6. **G2 배너**: 행위 체크리스트(**위험 항목 별표 우선 마킹** — 전수 대조를 강제하지 않음) + 디자인 시각 대조 + **스크린샷 베스트 에포트 첨부**(2026-06-12 결정 D4 — 시뮬레이터에서 실행 가능하면 `xcrun simctl io booted screenshot`로 캡처해 배너에 첨부, **판독은 사용자** — 보류된 '에이전트 판독'과 무관, 실패 시 생략) + 실행 안내(**사용자가 `flutter run -d <기기>`로 실행** 후 항목 대조). 승인 시 Phase 3.
7. **중간 눈 확인 — 미니 게이트로 정식화(적대 리뷰 I9)**: 발동은 기계적 — **가정 계약(G1 승격) 케이스면 항상**, tracer 직후 1회. 전용 미니 배너(확인 항목 = 가정 계약 항목만, 가능하면 스크린샷 첨부) + 결과 3분기: 가정 맞음 = 진행 / 다름 = 설계 반송 + 스냅샷을 관측 사실로 갱신 / 실행 불가 = 구현 반송.

## 7. Phase 3 · 수정 모드 · 트리비얼 · 엣지

- **Phase 3**: 실행한 검증만 보고 + 미실행 사유 명시 — dddjango 동일.
- **수정 모드**:
  - 슬라이스 도출 입력 = **G0 영향 파일 목록**(스코프 메모 산출, G0 배너 승인 항목 — 적대 리뷰 A9: 순수 구현 수정은 명세 갱신이 없어 도출 앵커가 따로 필요하다).
  - 설계 변경 있으면 G1' — 리뷰어는 **touched-layer 기계 매핑**(2026-06-12 결정 D2): domain→ddd / infra→data / application(use_case·state·view_model·shared_state·service)→state / presentation→ui, **ddd는 항상**. *왜* — 4축 항상의 폐지 근거(추론 불신)는 추론이 있을 때 얘기다. touched 계층은 G0 조사가 이미 확보한 **기계 신호**라 침묵 사각 논거가 소멸한다.
  - discipline 감사 = **touched 파일 한정 경량 1회**(결정 D3 — 빈혈은 작은 수정의 누적으로 침전하므로 0회는 불가, 트리비얼 채널이 라벨급을 흡수하므로 경량으로 충분).
  - 빌드 = **조건부**: codegen 대상·에셋·네이티브·pubspec touched 시만 실행, 아니면 analyze로 갈음하고 **생략 사유를 G2 배너에 1줄 보고**(검증 미실행 보고 금지 규율과 양립).
  - 수정 중 신규 파일이 생기면 골격·명명 규율 동일 적용(한 줄 명시).
- **트리비얼**(신설 — §4 판별 기준): 배너 승인 1회 → 직접 편집 → touched 백스톱 + analyze → 완료 보고. 에이전트·빌드·G2 없음.
- **엣지**(확장): 게이트 거부 재실행·리뷰어 충돌 중재·analyze/빌드 반복 실패 보고·행위 항목 구현 불가 보고 — 기존 유지. 추가: **구현 중 설계 반송의 재진입 절차(적대 리뷰 A8)** — architect 재호출 산출에 "변경 파일 diff"를 요구 → Coordinator가 diff 기준으로 슬라이스 재도출 → 영향 슬라이스만 재개봉(coder 입력은 "기존 수정" 의미론). **세션 사멸 후 재개**: 폴더 ⓐ 재사용 + `build-state.json`으로 phase·완료 슬라이스·스냅샷 ref 복원.

## 8. 에이전트별 스킬 주입 (9종 슬라이싱)

스킬 9종: architecture-**ddd**·**ui**·**state**·**data** / discipline-**cleancode**·**houserules** / implementation-**dart**·**flutter**·**riverpod**.

implementation 3종은 dddjango 5종의 대응 이식(2026-06-12 확인):

| dddjango | dddart | 대응 논리 |
|---|---|---|
| implementation-python | implementation-dart | 언어 관용구·타입. **freezed 귀속** |
| implementation-django | implementation-flutter | 프레임워크 코어. **go_router·dio/retrofit·hive 귀속**(규약 측면은 architecture-ui·data 소유) |
| implementation-django-ninja | implementation-riverpod | **가장 위반이 잦은 스택은 단독 스킬** — @riverpod 화이트리스트 5변종·keepAlive·watch 규율 |
| implementation-django-web | (해당 없음) | Flutter는 표현 계층 하나 |
| implementation-test | (없음) | 테스트 없음 결정 |

| 에이전트 | 주입 스킬 | dddjango 대응 |
|---|---|---|
| design-architect | architecture 4종 + discipline-houserules | 동형(tdd 제외) |
| design-review-ddd·ui·state·data | 각 architecture 1종 | 동형 |
| coder | implementation 3종 + discipline-cleancode·houserules | 동형(tdd 제외) |
| discipline-reviewer | discipline-cleancode·houserules | 동형(tdd 제외) |

추가 규칙(적대 리뷰 A2·I15·I16):
- **17종(실질 16종 — §9) 판별 절차는 공유 reference 1파일**로 작성해 **1차 결정자와 검증자 양쪽** 에이전트가 같은 파일을 적재한다 — 스킬 귀속표와 검증자 배정표의 모순(discipline-reviewer가 코퍼스에 없는 규칙의 검증자가 되는 문제) 해소.
- **keepAlive 경계**: 수명 *결정* = architecture-state / `@Riverpod(keepAlive:)` *표기법* = implementation-riverpod — 경계 문구를 양쪽 SKILL.md에 박는다.

제1 규약 절 → 스킬 귀속(§10-3 가이드 — 기존 유지): architecture-ddd ← §3.2·§3.3 중 UseCase·판정 소유·강등·§9 결정 / architecture-ui ← §3.5·§3.1·§6 중 design_system / architecture-state ← §3.3 중 VM 3변종·state·shared_state·4채널 상태 측면·§3.6 / architecture-data ← §3.4·로컬 2층·계약 스냅샷 사용법 / discipline-houserules ← §2·§3.7·§4·§5·§7·§8 / discipline-cleancode ← dddjango 이식+§10-5 코드 규율 / implementation 3종 ← 신규.

## 9. 기계 판별 불가 판별의 에이전트 배정 (16종 + 신규 1)

원칙: 백스톱 = 사후 불변식(위반 검출), 에이전트 지침 = 판별 절차(배치 결정). "export된 view"는 M5 해소로 백스톱 영역에 이관돼 **삭제**(원 17종 → 실질 16종).

| 판별 규칙 | 1차 결정 | 검증 |
|---|---|---|
| view/section 판별("VM이 필요한가") | architect(화면 분해) | ui → discipline-reviewer |
| "맥락" 판단(section 화면 전속) | architect | **ui**(화면 분해 어휘 — ddd에서 재배정) |
| BC "어휘" 보유 · 귀속 tie-break · 조립 vs 다수 BC 투영 | architect(BC 배치) | ddd |
| "BC 어휘 없는 게이트"(root scaffold) | architect | ddd |
| handler 입장("2+ BC 분배") | architect | state |
| "거의 빈 VM"(root_vm) · 푸시 "정규화" 의미론 | architect | state → discipline-reviewer |
| common "살아있는 상태" | architect | state → discipline-reviewer |
| domain_service "중심" · UseCase "도메인 개념 단위" | architect | ddd → discipline-reviewer |
| **"두 번째 개념" 식별 · "같은 개념 같은 철자"** | **architect**(파일 목록 소유 — 자기모순 스캔 §5-3) | discipline-reviewer(coder는 구현 중 2차 발견자 — 디렉터리 대조 후 보고) |
| 과거형 사건명(형태소) | **architect**(파일명은 명세 구조 결정 소유) | state → discipline-reviewer |
| main.dart "최소형" | coder | discipline-reviewer |
| **'계약 위험 행위' 표기(신규 — tracer 앵커)** | **architect**(명세 결정 항목) | **data** |

## 10. 다음 단계로 전달하는 요구사항

- **§10-2(백스톱)**:
  - touched-gate 기본 + **예외 절**(적대 리뷰 정합 B2): 순환 래칫 = 전역 검사 + 베이스라인(저장 위치 `.dddart/` 루트) / 골격 완비 = 신규 생성 BC 한정 / 구조·명명 = added 파일 기준(modified 레거시 오탐 방지).
  - **추가 백스톱 4건**: ① `application_layer/service/**`에서 `_navigator` import·`.go(` 호출 금지 ② `view_model/`·`shared_state/`·`use_case/`에서 `design_system/` import 금지(ui_extension·presentation·root scaffold만 허용) ③ `application_layer/**`에서 `BuildContext`·`package:flutter/material` import 금지 ④ repository 추상 클래스(인터페이스) 금지.
  - **러너 스크립트 1개**(전체 실행·집계 — 커맨드 인라인 금지) + **`extract-contract.py`**(paths 선별+`$ref` 전이 폐쇄 추출)도 §10-2 산출물.
- **§10-3(스킬)**: 절 귀속 가이드(§8) 적용. **필독 reference는 houserules 표준 트리 1개뿐**(dddjango 컨텍스트 예산 성립 조건의 명시 승계 — coder가 references 전량을 읽으면 ~140k+ 토큰으로 불가). houserules SKILL.md는 체크리스트 ≤8KB + 세부는 references. **16종 공유 reference 1파일** 작성. **§10-5 ①(State 에러 필드·일회성 소비)을 §10-3 착수 전 선결정**(state 리뷰어 점검 기준의 미결 규약 선참조 해소).
- **§10-4(파일 작성)**: "dddjango 동일" 항목 용어 치환 이식 + `argument-hint` 기존 문구. 추가 — **discipline-reviewer 본문 ~15KB 상한**(판례·변종은 references로 — dddjango 실물 40KB가 경고) / **codex 미러 기능 축소표**(argument-hint 부재·MCP 감지 상이·이미지 입력 비보장 → 치수·색 토큰 텍스트 메모로 강등) 1급 산출 / `$ARGUMENTS`에서 URL 추출 규칙 명시 / `build-state.json` 스키마 정의 / openapi 취득 도구 확정(Bash curl 기본) / Coordinator 경계 문구는 §1의 "직접 쓰는 것" 목록으로(dddjango 원문 그대로 이식 금지).
- **슬라이스 분할 2단계 실측(§6 잠정 확정의 최종화)**: §10-4 후 같은 기능을 안 1과 안 2(행위 세로+결정적 묶기)로 비교 빌드(dddjango `workspace/eval/` 방식). 지표: 토큰·호출 수 / 반송·복구 비용 / 발견 수·G2 통과율. 상세: `2026-06-12-slice-simulation.md` · 적대 리뷰: `2026-06-12-pipeline-adversarial-review.md`.
