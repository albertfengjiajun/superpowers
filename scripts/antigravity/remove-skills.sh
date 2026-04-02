#!/usr/bin/env bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/skills"
ANTIGRAVITY_GLOBAL_DIR="$HOME/.gemini/antigravity/skills"

echo -e "\033[0;36mRemoving Superpowers skills from global Antigravity location...\033[0m"

if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "\033[0;31mSkills directory not found at: $SKILLS_DIR\033[0m"
else
    REMOVED_COUNT=0

    for SKILL_DIR in "$SKILLS_DIR"/*; do
        if [ -d "$SKILL_DIR" ]; then
            SKILL_NAME=$(basename "$SKILL_DIR")
            TARGET_DIR="$ANTIGRAVITY_GLOBAL_DIR/superpowers-$SKILL_NAME"

            if [ -L "$TARGET_DIR" ] || [ -d "$TARGET_DIR" ]; then
                echo -e "Removing link: $TARGET_DIR"
                rm -rf "$TARGET_DIR"
                REMOVED_COUNT=$((REMOVED_COUNT + 1))
            fi
        fi
    done

    echo ""
    echo -e "\033[0;32mSuccessfully removed $REMOVED_COUNT skills from Antigravity global location.\033[0m"
fi
