# Claude Code Capabilities

A comprehensive reference of Claude Code features, tools, and models.

---

## Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Normal** | Default | Claude acts autonomously, executes tools without prompting |
| **Plan** | `--plan` flag or `/plan` command | Forces collaboration — Claude proposes a plan and waits for approval before executing |
| **Fast** | `--fast` flag | Same model, optimized for faster output; useful for high-volume, low-stakes tasks |

**When to use plan mode:** Any task with irreversible side effects (file deletions, API calls, migrations), multi-step work where you want checkpoints, or when onboarding to a new codebase.

---

## Native Tools

Claude Code ships with these built-in tools (no MCP required):

### File System
| Tool | Purpose |
|------|---------|
| `Read` | Read file contents, with optional `offset` and `limit` for large files |
| `Write` | Create or overwrite a file entirely |
| `Edit` | Apply exact string replacements in a file — prefer over Write for partial changes |
| `Glob` | Find files by name pattern (e.g., `**/*.ts`) — sorted by modification time |
| `Grep` | Search file contents with full regex support; supports `output_mode`, `type`, `glob` filters |

### Execution
| Tool | Purpose |
|------|---------|
| `Bash` | Run shell commands; supports `timeout`, `run_in_background` |

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
| `Skill` | Invoke a named skill (SKILL.md-based custom workflow) |
| `NotebookEdit` | Edit Jupyter notebook cells |

---

## Key Features

### Compaction
Claude Code automatically summarizes conversation history when the context window fills. This preserves working memory at the cost of losing older verbatim messages. Compaction is triggered automatically and is transparent to the user.

- Watch for: repeated questions, lost file state, regression in code quality
- Mitigation: `/clear` to start fresh, or explicitly re-anchor key context

### Context Window
| Model | Max Tokens | Practical Degradation Point |
|-------|-----------|----------------------------|
| Claude Opus 4.6 | 1M tokens | ~110K tokens (as of March 2026) |
| Claude Sonnet 4.6 | 200K tokens | ~110K tokens (as of March 2026) |
| Claude Haiku 4.5 | 200K tokens | ~80K tokens |

At ~110K tokens, response quality degrades noticeably even though the window has capacity. See `context-window.md` for management strategies.

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
Event-driven automation running shell commands at lifecycle points:

| Hook | Fires When |
|------|-----------|
| `PreToolUse` | Before any tool is called |
| `PostToolUse` | After any tool call completes |
| `SessionStart` | At the beginning of a new session |

Hooks are configured in `settings.json`. They execute outside Claude — useful for linting, logging, notifications, or blocking dangerous operations.

### Slash Commands
Built-in commands available in the Claude Code interface:
- `/clear` — clear conversation context
- `/plan` — enter plan mode
- `/compact` — manually trigger compaction
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
| **Claude Opus 4.6** | 1M tokens | Complex reasoning, large codebases, architecture decisions |
| **Claude Sonnet 4.6** | 200K tokens | Balanced performance and speed; default for most tasks |
| **Claude Haiku 4.5** | 200K tokens | Fast, low-cost tasks; simple Q&A, formatting, quick edits |

Model selection guidance:
- Use Opus 4.6 when: accuracy matters more than speed, working with 50K+ token contexts, complex multi-file refactors
- Use Sonnet 4.6 when: standard development work, feature implementation, code review
- Use Haiku 4.5 when: high-volume pipelines, quick lookups, content generation at scale

---

## IDE & Platform Support

| Platform | Notes |
|----------|-------|
| **VS Code** | Extension available; full tool support |
| **JetBrains** | Plugin available; full tool support |
| **Web app** | claude.ai/code — browser-based; some tool restrictions |
| **Desktop app** | Mac and Windows; full feature parity with CLI |
| **CLI** | `claude` command; most flexible; scriptable via `claude -p` |

### CLI-Specific Features
- `claude -p "<prompt>"` — non-interactive, pipe-friendly mode
- `claude --fast` — fast mode flag
- `claude --plan` — plan mode flag
- Scriptable for cron jobs, CI pipelines, and batch processing
