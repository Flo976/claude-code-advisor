# Claude Code Capabilities

A comprehensive reference of Claude Code features, tools, and models.

_Last updated: 2026-04-23 (v2.1.118)._

---

## Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Normal** | Default | Claude acts autonomously, executes tools without prompting |
| **Plan** | `--plan` flag or `/plan` command | Forces collaboration — Claude proposes a plan and waits for approval before executing |
| **Fast** | `--fast` flag | Same model, optimized for faster output; useful for high-volume, low-stakes tasks |
| **Auto** | Default on Max with Opus 4.7 (GA) | Model works with classifier-gated permissions — denials surface via `PermissionDenied` hook and are visible in `/permissions` → Recent (press `r` to retry). `autoMode.allow`/`soft_deny`/`environment` accept `"$defaults"` to extend the built-in list. No `--enable-auto-mode` flag required. (v2.1.111 GA, v2.1.118 `$defaults`) — source: https://code.claude.com/docs/en/changelog |

**When to use plan mode:** Any task with irreversible side effects (file deletions, API calls, migrations), multi-step work where you want checkpoints, or when onboarding to a new codebase.

---

## Effort Levels

Effort controls reasoning depth per call (not per session).

| Level | When to use |
|-------|-------------|
| `low` | Trivial edits, quick lookups |
| `medium` | Previous default for Pro/Max |
| `high` | New default for Pro/Max on Opus 4.6 and Sonnet 4.6 (raised from `medium` in v2.1.117, 2026-04-22) |
| `xhigh` | **Recommended default for Opus 4.7 in agentic coding** — near-`max` reasoning without runaway tokens (introduced v2.1.111, 2026-04-16) |
| `max` | Only for genuinely hard subproblems — now shows diminishing returns / overthinking on Opus 4.7 |

- `/effort` with no arguments opens an interactive slider (arrow-key navigation) as of v2.1.111.
- Source: https://claude.com/blog/best-practices-for-using-claude-opus-4-7-with-claude-code, https://github.com/anthropics/claude-code/releases

---

## Native Tools

Claude Code ships with these built-in tools (no MCP required):

### File System
| Tool | Purpose |
|------|---------|
| `Read` | Read file contents, with optional `offset` and `limit` for large files |
| `Write` | Create or overwrite a file entirely |
| `Edit` | Apply exact string replacements in a file — prefer over Write for partial changes |
| `Glob` | Find files by name pattern (e.g., `**/*.ts`) — sorted by modification time. On native macOS/Linux builds, routed through embedded `bfs` via Bash (v2.1.113+) |
| `Grep` | Search file contents with full regex support; supports `output_mode`, `type`, `glob` filters. On native macOS/Linux builds, routed through embedded `ugrep` via Bash (v2.1.113+) |

Native binaries: the CLI now spawns a native Claude Code binary instead of bundled JavaScript. Windows / npm-installed builds continue to use the bundled JS flow (Glob/Grep unchanged there). Source: https://code.claude.com/docs/en/changelog

### Execution
| Tool | Purpose |
|------|---------|
| `Bash` | Run shell commands; supports `timeout`, `run_in_background` |
| `PowerShell` (rolling out) | Native PowerShell tool on Windows; opt in/out with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` (also enables on Linux/macOS). v2.1.84 / v2.1.111 — source: https://code.claude.com/docs/en/changelog |

### Agent & Orchestration
| Tool | Purpose |
|------|---------|
| `Agent` | Launch a subagent in an isolated context — ideal for research, parallelizable tasks |
| `TaskCreate` / `TaskUpdate` | Manage tasks within the session |

### Web
| Tool | Purpose |
|------|---------|
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse a specific URL |

### UI & Notebooks
| Tool | Purpose |
|------|---------|
| `Skill` | Invoke a named skill (SKILL.md-based custom workflow). Since v2.1.108, Claude can also discover and invoke built-in slash commands (`/init`, `/review`, `/security-review`) through this tool — source: https://code.claude.com/docs/en/changelog |
| `NotebookEdit` | Edit Jupyter notebook cells |
| `PushNotification` | Send a mobile push notification when Remote Control is enabled and "Push when Claude decides" is on (v2.1.110) — source: https://github.com/anthropics/claude-code/releases |

---

## Key Features

### Compaction
Claude Code automatically summarizes conversation history when the context window fills. This preserves working memory at the cost of losing older verbatim messages. Compaction is triggered automatically and is transparent to the user.

- Watch for: repeated questions, lost file state, regression in code quality
- Mitigation: `/clear` to start fresh, or explicitly re-anchor key context

### Context Window
| Model | Max Tokens | Practical Degradation Point |
|-------|-----------|----------------------------|
| Claude Opus 4.7 | 1M tokens | ~300–400K tokens |
| Claude Opus 4.6 (1M GA) | 1M tokens | ~300–400K tokens |
| Claude Sonnet 4.6 (1M GA) | 1M tokens | ~300–400K tokens |
| Claude Haiku 4.5 | 200K tokens | ~80K tokens |

_1M context is GA for Opus 4.6 and Sonnet 4.6 (March 2026). Measurable context rot starts around 300–400K tokens on 1M models — goal drift and memory corruption become more likely well before the automatic 83.5% compaction trigger. Pre-1M Sonnet/Opus models keep the prior ~110K practical threshold. See `context-window.md` for management strategies._

### Subagents
Launched via the `Agent` tool. Each subagent runs in an isolated context with its own tool access. Useful for:
- Parallel research (multiple codebases or topics simultaneously)
- Isolating context-heavy tasks (large file analysis, full test runs)
- Separating concerns in multi-phase workflows

Subagents cannot share memory with the parent session directly — they communicate only through their output text.

### Worktrees
Claude Code supports git worktrees for parallel, isolated work on the same repository. Each worktree has its own working directory and branch. Useful for:
- Running multiple features simultaneously
- Comparing approaches side-by-side
- Keeping a clean main branch while experimenting

### Hooks
Event-driven automation running shell commands — or, since v2.1.118, MCP tools directly via `type: "mcp_tool"` (source: https://code.claude.com/docs/en/changelog) — at lifecycle points:

| Hook | Fires When |
|------|-----------|
| `PreToolUse` | Before any tool is called. Can return `permissionDecision: "defer"` to pause headless execution at a tool call (exits with `stop_reason: "tool_deferred"`) — v2.1.89 |
| `PostToolUse` | After any tool call completes |
| `SessionStart` | At the beginning of a new session |
| `PermissionDenied` | Fires when auto-mode classifier denies a tool call. Return `{retry: true}` to retry — v2.1.89 / v2.1.111 |

Hooks are configured in `settings.json`. They execute outside Claude — useful for linting, logging, notifications, or blocking dangerous operations. Source: https://code.claude.com/docs/en/hooks

### Slash Commands
Built-in commands available in the Claude Code interface:
- `/clear` — clear conversation context
- `/plan` — enter plan mode
- `/compact` — manually trigger compaction
- `/effort` — open an interactive slider to set effort level (v2.1.111)
- `/recap` — generate a one-line summary of prior context when returning to a paused session; auto-recap runs on resume. Configurable via `/config`; force on for telemetry-disabled builds with `CLAUDE_CODE_ENABLE_AWAY_SUMMARY=1` (v2.1.108) — source: https://code.claude.com/docs/en/changelog
- `/ultrareview` — multi-agent cloud code review: spins up parallel cloud sandbox reviewers that only surface findings after reproducing/verifying them. Team or Enterprise plan (research preview); v2.1.113 adds a diffstat in the launch dialog (v2.1.111) — source: https://code.claude.com/docs/en/changelog
- `/team-onboarding` — scans local usage patterns, commands, and MCP server usage to generate a personalized teammate ramp-up guide (v2.1.101) — source: https://smartscope.blog/en/generative-ai/claude/claude-code-team-onboarding-guide/
- `/tui` — toggles TUI rendering; `/tui fullscreen` enables flicker-free alt-screen rendering with virtualized scrollback (also exposed via a `tui` setting). v2.1.110 — source: https://github.com/anthropics/claude-code/releases
- `/init`, `/review`, `/security-review` — can also be invoked by the model via the `Skill` tool (v2.1.108)
- Custom commands defined in CLAUDE.md or skills

### Skills (SKILL.md)
Custom reusable workflows stored as `SKILL.md` files in `~/.claude/skills/` or project-local directories. Skills are invoked via the `Skill` tool. They can encode multi-step processes, decision trees, checklists, and sub-skill calls.

### Plugins
Extend Claude Code with MCP servers. Plugins can add new tools, resources, and prompts. See `mcps-catalog.md` for known MCPs.

### Experimental: Agent Teams
Multiple coordinated Claude Code sessions working in parallel, with orchestration logic. Not yet stable — treat as experimental. Primary use case: very large projects where decomposition into independent workstreams is clear.

---

## Models

| Model | Context | Best For |
|-------|---------|----------|
| **Claude Opus 4.7** | 1M tokens | Agentic coding with `xhigh` effort (recommended default); complex multi-step engineering work |
| **Claude Opus 4.6** | 1M tokens | Complex reasoning, large codebases, architecture decisions |
| **Claude Sonnet 4.6** | 1M tokens (GA) | Balanced performance and speed; default for most tasks |
| **Claude Haiku 4.5** | 200K tokens | Fast, low-cost tasks; simple Q&A, formatting, quick edits |

Model selection guidance:
- Use Opus 4.7 (with `xhigh`) when: agentic coding, multi-file engineering, hard problems where reasoning depth matters. Reserve `max` only for the hardest subproblems.
- Use Opus 4.6 when: accuracy matters more than speed, working with 50K+ token contexts, complex multi-file refactors
- Use Sonnet 4.6 when: standard development work, feature implementation, code review
- Use Haiku 4.5 when: high-volume pipelines, quick lookups, content generation at scale

Source (Opus 4.7 guidance): https://claude.com/blog/best-practices-for-using-claude-opus-4-7-with-claude-code

---

## IDE & Platform Support

| Platform | Notes |
|----------|-------|
| **VS Code** | Extension available; full tool support |
| **JetBrains** | Plugin available; full tool support |
| **Web app** | claude.ai/code — browser-based; some tool restrictions |
| **Desktop app** | Mac and Windows; full feature parity with CLI |
| **CLI** | `claude` command; most flexible; scriptable via `claude -p`. Native binary on macOS/Linux (v2.1.113+); Windows/npm builds use bundled JS |

### CLI-Specific Features
- `claude -p "<prompt>"` — non-interactive, pipe-friendly mode
- `claude --fast` — fast mode flag
- `claude --plan` — plan mode flag
- Scriptable for cron jobs, CI pipelines, and batch processing
