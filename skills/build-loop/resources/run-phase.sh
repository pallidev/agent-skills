#!/bin/bash
# run-phase.sh — 단일 Phase를 headless Claude 세션에서 실행
# 사용법: bash run-phase.sh <phase-dir>
# 예시: bash run-phase.sh .planning/phases/01-project-setup

set -e

PHASE_DIR="$1"

if [ -z "$PHASE_DIR" ]; then
  echo "Usage: bash run-phase.sh <phase-dir>"
  echo "Example: bash run-phase.sh .planning/phases/01-project-setup"
  exit 1
fi

# PLAN.md 찾기 (여러 형식 지원)
PLAN_FILE=""
for f in "$PHASE_DIR"/*-PLAN.md "$PHASE_DIR"/*-01-PLAN.md; do
  if [ -f "$f" ]; then
    PLAN_FILE="$f"
    break
  fi
done

if [ -z "$PLAN_FILE" ]; then
  echo "❌ PLAN.md를 찾을 수 없습니다: $PHASE_DIR"
  exit 1
fi

echo "🚀 Phase 실행: $(basename "$PHASE_DIR")"
echo "📋 계획 파일: $PLAN_FILE"
echo ""

# headless Claude 세션으로 실행
claude -p "$(cat "$PLAN_FILE")"

echo ""
echo "✅ Phase 완료: $(basename "$PHASE_DIR")"
