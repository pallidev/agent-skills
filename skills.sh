#!/bin/bash
# skills.sh — Claude Code 스킬 설치 스크립트
# 사용법: bash skills.sh [스킬명]
# 예시: bash skills.sh build-loop
#       bash skills.sh (전체 설치)

set -e

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

# 설치 가능한 스킬 목록
AVAILABLE_SKILLS=()
for dir in "$SKILLS_DIR"/*/; do
  if [ -f "$dir/SKILL.md" ]; then
    skill_name=$(basename "$dir")
    AVAILABLE_SKILLS+=("$skill_name")
  fi
done

install_skill() {
  local skill_name="$1"
  local source_dir="$SKILLS_DIR/$skill_name"

  if [ ! -f "$source_dir/SKILL.md" ]; then
    echo "❌ 스킬을 찾을 수 없습니다: $skill_name"
    echo "   사용 가능: ${AVAILABLE_SKILLS[*]}"
    exit 1
  fi

  mkdir -p "$CLAUDE_SKILLS_DIR"

  # 이미 존재하면 심볼릭 링크 재생성
  if [ -e "$CLAUDE_SKILLS_DIR/$skill_name" ]; then
    rm -rf "$CLAUDE_SKILLS_DIR/$skill_name"
  fi

  ln -s "$source_dir" "$CLAUDE_SKILLS_DIR/$skill_name"
  echo "✅ $skill_name 설치 완료 → $CLAUDE_SKILLS_DIR/$skill_name"
}

# 메인
if [ $# -eq 0 ]; then
  echo "🔧 전체 스킬 설치 (${#AVAILABLE_SKILLS[@]}개)"
  echo ""
  for skill in "${AVAILABLE_SKILLS[@]}"; do
    install_skill "$skill"
  done
  echo ""
  echo "🎉 전체 설치 완료! Claude Code를 재시작하면 적용됩니다."
else
  echo "🔧 스킬 설치: $1"
  echo ""
  install_skill "$1"
  echo ""
  echo "🎉 설치 완료! Claude Code를 재시작하면 적용됩니다."
fi
