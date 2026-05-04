---
name: build-loop
description: "Automatically execute GSD phases sequentially using claude -p headless sessions. Use when the user says \"run build loop\", \"execute all phases\", \"start build loop\", or wants to automate phase-by-phase execution of a GSD project. Requires .planning/phases/ directory structure."
metadata:
  author: pallidev
  version: "1.0.0"
---

# Build Loop

GSD(Get Shit Done)로 분해한 Phase를 `claude -p` 헤드리스 세션으로 자동 연속 실행하는 스킬. Ralph Wiggum Loop 패턴을 GSD 워크플로우에 적용한다.

## 사전 조건

이 스킬은 GSD가 생성한 `.planning/phases/` 디렉토리 구조가 필요하다:

```
.planning/
├── PROJECT.md
├── REQUIREMENTS.md
├── ROADMAP.md
└── phases/
    ├── 01-project-setup/
    │   ├── 01-CONTEXT.md
    │   └── 01-01-PLAN.md
    ├── 02-crud-api/
    │   ├── 02-CONTEXT.md
    │   └── 02-01-PLAN.md
    └── ...
```

GSD가 설치되어 있지 않다면 `npx get-shit-done-cc@latest`로 설치한다.

## 사용법

```
/build-loop
```

## Step 1: 상태 초기화 또는 복원

`.planning/build-loop-state.json` 파일이 있는지 확인한다.

**있으면:** 기존 상태를 읽어 들여 중단된 Phase부터 재개한다.

**없으면:** `.planning/phases/` 디렉토리를 스캔하여 초기 상태 파일을 생성한다:

```json
{
  "project": "<PROJECT.md의 프로젝트명>",
  "startedAt": "<현재 ISO 8601 타임스탬프>",
  "updatedAt": "<현재 ISO 8601 타임스탬프>",
  "phases": [
    {
      "id": "01-project-setup",
      "name": "<Phase 이름>",
      "status": "pending",
      "startedAt": null,
      "completedAt": null
    }
  ]
}
```

## Step 2: 다음 Phase 실행

미완료 Phase(status가 `pending` 또는 `in_progress`) 중 가장 번호가 작은 것을 찾는다.

해당 Phase의 계획 파일(`XX-01-PLAN.md`)을 읽고, `claude -p`로 headless 세션에서 실행한다:

```bash
claude -p "$(cat .planning/phases/01-project-setup/01-01-PLAN.md)"
```

실행 전 사용자에게 어떤 Phase를 실행할지 알린다.

## Step 3: 상태 업데이트

실행이 완료되면 상태 파일을 업데이트한다:

1. 완료된 Phase의 `status`를 `complete`로 변경
2. `completedAt`에 현재 시간 기록
3. 다음 Phase의 `status`를 `in_progress`로 변경
4. `updatedAt`에 현재 시간 기록

## Step 4: 반복 또는 종료

- 미완료 Phase가 남아있으면 Step 2로 돌아간다
- 모든 Phase가 완료되면 최종 요약을 출력한다:
  - 총 Phase 수
  - 총 소요 시간
  - 성공/실패 Phase 목록

## 실패 처리

Phase 실행이 실패하면:

1. 사용자에게 실패 내용을 알린다
2. 다음 Phase로 넘어갈지, 중단할지, 재시도할지 묻는다
3. 재시도 시 동일한 Phase를 다시 실행한다

## 주의사항

- Orchestrator 세션의 컨텍스트를 최소화하기 위해 각 Phase의 실행 결과는 요약만 유지한다
- 상태 파일은 항상 최신 상태로 유지하여 세션이 끊어져도 재개 가능하다
- 각 Phase는 별도의 독립 세션(새 컨텍스트 윈도우)에서 실행되어 컨텍스트 로트를 방지한다
