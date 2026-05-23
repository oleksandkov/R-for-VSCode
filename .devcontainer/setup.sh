#!/usr/bin/env bash
# .devcontainer/setup.sh
# Post-create setup script — runs once after the container is created.
# Called by devcontainer.json "postCreateCommand".

set -euo pipefail

echo ""
echo "=================================================="
echo "   R for VSCode — Dev Container Setup"
echo "=================================================="

# Mark /workspace as safe for Git (avoids "dubious ownership" warnings
# when the host user UID differs from the container user UID on Windows/WSL2).
git config --global --add safe.directory /workspace

# Set a sensible default Git identity placeholder (overridden by host gitconfig if mounted).
if [ -z "$(git config --global user.email 2>/dev/null || true)" ]; then
    git config --global user.email "you@example.com"
    git config --global user.name  "Developer"
fi

# Ensure radian is on PATH for the vscode user
if ! command -v radian &>/dev/null; then
    echo "⚠  radian not found on PATH — attempting pip install..."
    pip3 install --user --no-cache-dir radian
    export PATH="$HOME/.local/bin:$PATH"
fi

echo ""
echo "──────────────────────────────────────────────────"
echo "  Environment Summary"
echo "──────────────────────────────────────────────────"
echo "  R:       $(R --version | head -1)"
echo "  Python:  $(python3 --version)"
echo "  radian:  $(radian --version 2>&1 | head -1)"
echo "  Quarto:  $(quarto --version)"
echo "  Git:     $(git --version)"
echo "──────────────────────────────────────────────────"
echo ""
echo "  Open an R terminal: Ctrl+Shift+P → 'R: Create R Terminal'"
echo "  Attach a session:   Click 'R: (not attached)' → 'Attach Active Terminal'"
echo "  Run R code:         Ctrl+Enter (selection or line)"
echo "  Source file:        Ctrl+Shift+S"
echo "=================================================="
echo ""
