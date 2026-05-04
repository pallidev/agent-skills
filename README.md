# agent-skills

Claude Code 커스텀 스킬 모음.

## 설치

### 전체 스킬 설치

```bash
git clone https://github.com/pallidev/agent-skills.git
cd agent-skills
bash skills.sh
```

### 특정 스킬만 설치

```bash
bash skills.sh build-loop
```

### 한 줄 설치 (curl)

```bash
bash <(curl -s https://raw.githubusercontent.com/pallidev/agent-skills/main/skills.sh) build-loop
```

## 스킬 목록

| 스킬 | 설명 |
|------|------|
| **build-loop** | GSD Phase를 `claude -p`로 자동 연속 실행. Ralph Wiggum Loop 패턴 적용 |

## 스킬 추가 방법

1. 새 디렉토리 생성: `mkdir my-skill`
2. `SKILL.md` 파일 작성 (frontmatter에 name, description 포함)
3. `skills.sh`가 자동으로 인식

## 제거

```bash
rm ~/.claude/skills/<스킬명>
```
