# agent-skills

Claude Code 커스텀 스킬 모음.

## 설치

### 특정 스킬 설치

```bash
npx skills add pallidev/agent-skills --skill build-loop
```

### 전체 스킬 설치

```bash
npx skills add pallidev/agent-skills
```

### 글로벌 설치 (모든 프로젝트에서 사용)

```bash
npx skills add pallidev/agent-skills --skill build-loop -g
```

## 스킬 목록

| 스킬 | 설명 |
|------|------|
| **build-loop** | GSD Phase를 `claude -p`로 자동 연속 실행. Ralph Wiggum Loop 패턴 적용 |

## 스킬 추가 방법

1. `skills/` 아래에 새 디렉토리 생성: `mkdir skills/my-skill`
2. `SKILL.md` 파일 작성 (frontmatter에 name, description 포함)

## 제거

```bash
npx skills remove build-loop
```
