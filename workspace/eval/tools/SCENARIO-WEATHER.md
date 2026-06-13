# SCENARIO-WEATHER — 날씨 7일 예보 (실전 풀스택 검증 고정 입력)

> **고정 입력(verbatim)**. `TEST-ENV.md` 환경 위에서 claude판·codex판을 동일 task로 구동·채점한다. 변경은 구동 *착수 전*에만(런 간 흔들리면 비교 오염). S1(공지·dio 깔린 green 픽스처)과 달리 이 시나리오의 핵심 변수는 **순정 민낯**(§2)이다 — dddart가 통신 인프라까지 스스로 까는지를 본다.

## §1 task 프롬프트 (verbatim)

**기능 설명**(claude·codex 공통 본문):

```
날씨 예보 기능을 추가해줘. 서버 API에서 오늘부터 7일간의 일별 예보를 받아 리스트로 보여주고,
목록에서 날짜 항목을 탭하면 그날의 상세 화면으로 들어간다.
목록 항목은 날짜, 날씨 상태, 최고기온과 최저기온을 보여준다.
상세 화면은 목록 정보에 더해 습도, 풍속, 강수확률을 보여준다.
날씨 상태는 맑음·구름많음·흐림·비·눈·뇌우 6종이며, 상태마다 아이콘과 색으로 구분해 표시한다.
```

**호출 형태**(인자 규약 — claude=named 위치 / codex=순차 해석. **디자인은 인자 아님** — 양판 다 Phase 0에서 연결된 Stitch MCP로 화면 확인):
- **claude판**(슬래시): `/dddart "<위 기능 설명>" "<OpenAPI URL>"`
- **codex판**(자연어 순차): `dddart로 날씨 예보 기능을 추가해줘 — 순서대로 ① 기능: <위 설명> ② OpenAPI: <URL>`

**인자 값**:
- **OpenAPI URL** = `https://<배포host>/api/schema/?format=json` — kingdom-server `feat/weather-api` **배포 후 확정**(라이브=사용자 드라이브). G0 승인 후 dddart가 `curl`로 `openapi-full.json` 동결 → G1 직후 weather paths만 기계 절단. (drf-spectacular라 `?format=json` 필수 — 기본 YAML은 `extract_contract`가 거부.)
- **디자인 출처** = **Stitch MCP 화면 참조** `projects/2284872291805682410`(목록 `33cc57459ab341b78602f54959084931`·상세 `8dc99c312d5142a39a9ad0f30ac353b1`). **디자인은 인자가 아니다** — 구동 중 Phase 0에서 Coordinator가 연결된 Stitch MCP로 화면을 탐색·사용자 확인해 `get_screen`(이미지·HTML 시안·스크린샷 URL) → `design-ref/`에 동결한다. claude=이미지 판독·codex=HTML 시안 우선. **양판 동일**.

**행위 목록**(G2 체크리스트·행위↔코드 대조 단위): ① 7일 예보 목록 조회 ② 일별 상세 조회 ③ 목록→상세 내비게이션 ④ 날짜 오름차순 표시 ⑤ 상태 6종 아이콘·색 매핑.
**규모**: 신규 BC `weather` + 화면 2개(목록·상세) → 풀 빌드(2분할 예상).

## §2 baseline (순정 민낯 — S1과 정반대)

- **위치**: `~/Desktop/dddart-run/dddart-<YYYYMMDD-HHMM>-{claude,codex}` (`TEST-ENV.md` §4로 생성·git 순정 67파일·바이트 동일). 현재 세션: `dddart-20260613-2158-*`.
- **상태**: **순정 Flutter 3.44.1**. dio·flutter_riverpod·freezed·go_router·retrofit·`common/network`(dio_client·safe_api_call) **전부 미설치**. dddart가 스스로 의존성·통신 인프라·기능을 까는지가 측정 대상(코퍼스 갭이면 멈춰 점검 = 수확).
- **diff 기준**: 순정 커밋 대비 `git diff` = dddart 산출물 전량(갭 원장 원천).

## §3 입력물·채점 경로

- 디자인: **Stitch MCP** `projects/2284872291805682410` → 구동 중 `design-ref/` 동결 (사전 로컬 다운로드 불요·양판 MCP)
- OpenAPI: args URL(배포) → dddart가 `<산출물 폴더>/openapi-full.json` 동결 (사전 JSON 동결본 불요)
- 채점: `rubric/RUBRIC.md`·`rubric/EVAL-METHOD.md` → 결과지 `results/<YYYYMMDD-HHMM>-weather-{claude,codex}.md`

## §4 고정 게이트 답 (claude·codex 동일)

- **G0**: git O·clean(통과) / 모드 = **풀**(신규 화면 2·신규 BC) / BC 배치 = **신규 `weather`**(기존 BC 없음 → 배치 질문 불발동) / 산출물 폴더 = 신규 / 계약 출처 = OpenAPI URL 동결 / 디자인 출처 = Stitch MCP(Phase 0 확인)→design-ref 동결 → **승인**.
- **G1**(가장 간단하게 · Y 항목 전부 기본 미적용): 페이지네이션 **안 함**(서버도 무페이지네이션 배열) · 로컬 캐시 **안 함** · 당겨서 새로고침 **안 함**(디자인엔 visual-only 인디케이터만) · 정렬 = **날짜 오름차순**(서버 순서 유지) · condition 6종 아이콘·색·한글 라벨 = **ui_extension** → **기본 수락(승인)**.
- **G2**: green 빌드(컴파일 + `flutter analyze` 신규이슈 0 + 테스트) 도달 시 **승인**. 스크린샷·`flutter run` 런타임 대조는 **사용자 드라이브**(미실행 고지 — TEST-ENV §5).
