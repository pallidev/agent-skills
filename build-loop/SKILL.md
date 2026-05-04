---
name: build-loop
description: GSD Phase를 자동으로 연속 실행하는 스킬. Ralph Wiggum Loop 패턴을 GSD 워크플로우에 적용. .planning/phases/ 구조가 있는 프로젝트에서 claude -p로 각 Phase를 headless 세션에서 순차 실행한다.
allowed-tools: Bash(claude -p:*), Bash(cat .planning/*:*), Bash(ls .planning/*:*)
---

# Build Loop

GSD Phase를 자동으로 연속 실행하는 스킬입니다.

## 사용법

```
/build-loop
```

## 동작 방식

1. `.planning/phases/` 디렉토리를 스캔하여 모든 Phase를 탐색
2. `build-loop-state.json`에서 진행 상태를 읽음 (없으면 초기화)
3. 미완료 Phase 중 가장 번호가 작은 것을 찾음
4. 해당 Phase의 PLAN.md를 읽어 `claude -p`로 headless 세션에서 실행
5. 완료되면 상태 파일 업데이트 후 다음 Phase로 진행
6. 모든 Phase가 완료되면 종료

## 상태 파일 형식

`.planning/build-loop-state.json`:

```json
{
  "project": "프로젝트명",
  "startedAt": "2026-05-04T00:00:00Z",
  "updatedAt": "2026-05-04T01:30:00Z",
  "phases": [
    {
      "id": "01-project-setup",
      "name": "프로젝트 세팅 & DB 스키마",
      "status": "complete",
      "startedAt": "2026-05-04T00:00:00Z",
      "completedAt": "2026-05-04T00:15:00Z"
    },
    {
      "id": "02-crud-api",
      "name": "CRUD API 엔드포인트",
      "status": "in_progress",
      "startedAt": "2026-05-04T00:15:00Z",
      "completedAt": null
    }
  ]
}
```

## 지시사항

/build-loop 명령이 호출되면 다음을 수행하세요:

### 1단계: 상태 초기화 또는 복원

`.planning/build-loop-state.json` 파일이 있는지 확인합니다.
- 있으면: 기존 상태를 읽어 들입니다
- 없으면: `.planning/phases/` 디렉토리를 스캔하여 초기 상태 파일을 생성합니다

### 2단계: 다음 Phase 실행

미완료 Phase(status가 `pending` 또는 `in_progress`) 중 가장 번호가 작은 것을 찾습니다.
해당 Phase의 계획 파일(`XX-XX-PLAN.md` 또는 `XX-CONTEXT.md`)을 읽습니다.

Bash 도구를 사용하여 headless Claude 세션으로 실행합니다:

```bash
claude -p "$(cat .planning/phases/01-project-setup/01-01-PLAN.md)"
```

### 3단계: 상태 업데이트

실행이 완료되면 상태 파일을 업데이트합니다:
- 해당 Phase의 `status`를 `complete`로 변경
- `completedAt`에 현재 시간 기록
- 다음 Phase의 `status`를 `in_progress`로 변경

### 4단계: 반복 또는 종료

- 미완료 Phase가 남아있으면 2단계로 돌아갑니다
- 모든 Phase가 완료되면 최종 요약을 출력합니다

## 주의사항

- 각 Phase 실행 전 반드시 사용자에게 어떤 Phase를 실행할지 알립니다
- Phase 실행이 실패하면 사용자에게 알리고 다음 Phase로 넘어갈지 묻습니다
- 상태 파일은 항상 최신 상태로 유지합니다
- Orchestrator 세션의 컨텍스트를 최소화하기 위해 각 Phase의 실행 결과는 요약만 유지합니다
