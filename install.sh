#!/bin/bash
set -e

INSTALL_DIR="$HOME/.claude/skills/claude-code-advisor"

echo ""
echo "  Claude Code Advisor — Installing..."
echo ""

if [ -d "$INSTALL_DIR" ]; then
    echo "  Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "  Cloning repository..."
    git clone https://github.com/Flo976/claude-code-advisor.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

echo "  Generating local skills catalog..."
python3 scripts/update-knowledge.py --local-only

echo ""
echo "  === Claude Code Advisor installed ==="
echo ""
echo "  Usage:"
echo "    In Claude Code, say:"
echo "      /advisor              — Get strategy recommendation"
echo "      /advisor update       — Update knowledge base"
echo ""
echo "    Or use natural language:"
echo "      'how should I approach this?'"
echo "      'what's the best way to...'"
echo "      'conseille-moi'"
echo ""
