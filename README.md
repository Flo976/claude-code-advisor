<div align="center">

# Claude Code Advisor

**Stop guessing. Start mastering.**

The AI-powered strategy advisor that tells you *exactly* how to use Claude Code
for any task — which mode, which skills, which tools, and why.

[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-6B4FBB?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBkPSJNMTIgMkM2LjQ4IDIgMiA2LjQ4IDIgMTJzNC40OCAxMCAxMCAxMCAxMC00LjQ4IDEwLTEwUzE3LjUyIDIgMTIgMnoiIGZpbGw9IndoaXRlIi8+PC9zdmc+&logoColor=white)](https://claude.ai/code)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Auto-Update](https://img.shields.io/badge/Knowledge_Base-Weekly_Auto--Update-blue?style=for-the-badge)](#auto-update)

---

*Based on the [6 Levels of Claude Code Mastery](references/modes-and-patterns.md) framework*

</div>

## The Problem

Claude Code has **plan mode**, fast mode, subagents, worktrees, skills, MCPs, hooks, agent teams...

**How do you know which to use when?**

Most developers use Claude Code at **Level 1** — as a blunt instrument — and miss 80% of its potential. The features evolve fast, best practices shift weekly, and nobody on your team has time to keep up.

**Claude Code Advisor fixes that.** Ask it before any task, and it tells you the optimal strategy.

---

## The 6 Levels of Claude Code Mastery

| Level | Name | You're here if... | Key skill to develop |
|:-----:|------|-------------------|---------------------|
| **1** | **Prompter** | You type a request and hope for the best | Clear prompts, evaluating output |
| **2** | **Collaborator** | You use plan mode and ask questions | Active collaboration, "what am I missing?" |
| **3** | **Context Engineer** | You manage CLAUDE.md and the context window | Right context at the right time |
| **4** | **Tool User** | You add MCPs and external tools strategically | Being surgical — right tool, right job |
| **5** | **Skill Architect** | You create custom skills and workflows | Skill creation, benchmarking |
| **6** | **Manager** | You run multiple sessions and delegate | Deciding *what*, not *how* |

> *"You need to understand the six levels of Claude Code if you don't want to get stuck in your progress."*

---

## How It Works

You describe your task. The advisor analyzes your context and recommends the optimal strategy.

```
You: "I need to refactor the auth module across 15 files in our Next.js app"

Advisor:

  ## Strategy for: Refactor auth module across 15 files

  Level 6 — Manager

  ### Mode
  Plan mode first to design the refactoring strategy, then dispatch.

  ### Skills to activate
  - `superpowers:brainstorming` — explore the refactoring approach before coding
  - `superpowers:subagent-driven-development` — dispatch one subagent per file group

  ### Context preparation
  - Ensure CLAUDE.md documents the current auth patterns
  - Create a worktree to isolate the refactoring work

  ### Context window strategy
  - Use subagents for each file group (auth routes, middleware, utils)
  - Keep main session under 80K tokens for coordination only

  ### Avoid
  - Don't try to refactor all 15 files in one session (context overflow)
  - Don't micro-manage subagents — give them clear specs and let them work

  ### Tips
  - Use `/clear` between each file group to keep context fresh
  - Consider `Context7` MCP for up-to-date Next.js 16 auth middleware docs
  - Test the refactored auth on a staging branch before merging — auth bugs are hard to rollback

  ### Why this approach
  15 files is too many for a single context window. Level 6 (Manager) lets you
  coordinate parallel subagents, each handling 3-5 related files. The brainstorming
  skill ensures you have a solid plan before dispatching work.
```

---

## Quick Start

### One-liner install

**macOS / Linux:**
```bash
bash <(curl -s https://raw.githubusercontent.com/Flo976/claude-code-advisor/main/install.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Flo976/claude-code-advisor/main/install.ps1 | iex
```

### Or clone manually

**macOS / Linux:**
```bash
git clone https://github.com/Flo976/claude-code-advisor.git ~/.claude/skills/claude-code-advisor
cd ~/.claude/skills/claude-code-advisor && python3 scripts/update-knowledge.py
```

**Windows:**
```powershell
git clone https://github.com/Flo976/claude-code-advisor.git $env:USERPROFILE\.claude\skills\claude-code-advisor
cd $env:USERPROFILE\.claude\skills\claude-code-advisor; python scripts/update-knowledge.py
```

### Use it

In Claude Code:

```
/advisor
```

> **Note:** The slash command is `/advisor` (not `/claude-code-advisor`). The `name` field in SKILL.md determines the command name.

Or just ask naturally:

- *"How should I approach this?"*
- *"What's the best strategy for..."*
- *"Conseille-moi"*
- *"What am I missing?"*

---

## Knowledge Base

The advisor draws from **7 constantly-updated reference files**:

| File | Contains | Updated by |
|------|----------|-----------|
| [`capabilities.md`](references/capabilities.md) | Claude Code features, modes, tools | Anthropic docs |
| [`modes-and-patterns.md`](references/modes-and-patterns.md) | The 6-level framework + decision matrix | Core framework |
| [`mcps-catalog.md`](references/mcps-catalog.md) | Known MCPs — when to use, when to avoid | Docs + community |
| [`skills-catalog.md`](references/skills-catalog.md) | *Your* installed skills (auto-generated) | Local scan |
| [`context-window.md`](references/context-window.md) | Token management strategies | Docs + experience |
| [`anti-patterns.md`](references/anti-patterns.md) | Common mistakes per level | Experience + community |
| [`community-tips.md`](references/community-tips.md) | Best practices from the wild | Weekly web research |

---

## Auto-Update

The knowledge base has two update paths:

**Local scan** — instant, no network, no LLM. Refreshes `skills-catalog.md` from
your installed skills, MCPs, and plugins. Runs automatically at the start of
every `/advisor` invocation.

**Full update** (`/advisor update`) — dispatches parallel subagents:
1. One research subagent searches the web (Claude Code releases, community tips,
   new MCPs) — loads `WebSearch`/`WebFetch` via `ToolSearch`
2. Six per-file subagents analyze the research and rewrite their target
   reference file independently — isolated failures, parallel execution
3. Results are consolidated into [`CHANGELOG.md`](CHANGELOG.md)

### Setup weekly auto-update

```
/schedule create --name "advisor-update" --cron "0 9 * * 1" --prompt "/advisor update"
```

### Manual update anytime

```
/advisor update
```

---

## For Teams

This skill is designed for **team deployment**:

| Step | Who | What |
|------|-----|------|
| 1 | Lead | Fork/maintain the repo with team-specific tips |
| 2 | Each dev | `git clone` to their machine |
| 3 | Automatic | `skills-catalog.md` generated per machine (`.gitignore`d) |
| 4 | Team | Add shared tips to `community-tips.md` via PR |
| 5 | Each dev | `git pull` to sync shared knowledge |

The skill adapts to each developer's setup while sharing team knowledge.

---

## Contributing

**Found a useful Claude Code tip?**
Add it to [`references/community-tips.md`](references/community-tips.md) and open a PR.

**Discovered a new anti-pattern?**
Add it to [`references/anti-patterns.md`](references/anti-patterns.md).

**Know a great MCP?**
Add it to [`references/mcps-catalog.md`](references/mcps-catalog.md).

---

## Language / Langue

The advisor **automatically responds in your language**. Write in French, get advice in French. Write in English, get advice in English.

> **Pour les francophones** : le skill répond en français si vous écrivez en français. Dites simplement "conseille-moi" ou "comment faire ça au mieux ?" et la recommandation sera entièrement en français. Le README reste en anglais pour la visibilite open-source, mais l'utilisation quotidienne est 100% francophone.

---

## License

[MIT](LICENSE) — use it, fork it, share it.

---

<div align="center">

**Built with Claude Code, for Claude Code users.**

<sub>By <a href="https://github.com/Flo976">Florent Didelot</a> / <a href="https://sooatek.com">Sooatek</a></sub>

</div>
