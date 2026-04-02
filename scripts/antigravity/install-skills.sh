#!/usr/bin/env bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/skills"
ANTIGRAVITY_GLOBAL_DIR="$HOME/.gemini/antigravity/skills"

echo -e "\033[0;36mInstalling Superpowers skills as flat global Antigravity skills...\033[0m"

if [ ! -d "$ANTIGRAVITY_GLOBAL_DIR" ]; then
    echo "Creating Antigravity global skills directory: $ANTIGRAVITY_GLOBAL_DIR"
    mkdir -p "$ANTIGRAVITY_GLOBAL_DIR"
fi

if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "\033[0;31mSkills directory not found at: $SKILLS_DIR\033[0m"
else
    INSTALLED_COUNT=0

    for SKILL_DIR in "$SKILLS_DIR"/*; do
        if [ -d "$SKILL_DIR" ]; then
            SKILL_NAME=$(basename "$SKILL_DIR")
            TARGET_DIR="$ANTIGRAVITY_GLOBAL_DIR/superpowers-$SKILL_NAME"

            if [ -L "$TARGET_DIR" ] || [ -d "$TARGET_DIR" ]; then
                echo -e "\033[0;33mRemoving existing link: $TARGET_DIR\033[0m"
                rm -rf "$TARGET_DIR"
            fi

            echo "Linking superpowers-$SKILL_NAME -> $SKILL_DIR"
            ln -s "$SKILL_DIR" "$TARGET_DIR"
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        fi
    done

    echo ""
    echo -e "\033[0;32mSuccessfully installed $INSTALLED_COUNT skills to Antigravity global location.\033[0m"
    echo -e "\033[0;36mGlobal location: $ANTIGRAVITY_GLOBAL_DIR\033[0m"
fi
