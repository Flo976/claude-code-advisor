# Changelog

All notable updates to the Claude Code Advisor knowledge base are documented here.

## 2026-04-23 — Update (first run of the subagent-based flow)

### Setup local
- 67 skills, 0 MCPs, 33 plugins detected

### Updated files
- `capabilities.md` — Opus 4.7 + `xhigh` effort, Auto mode GA, `/effort`/`/recap`/`/ultrareview`/`/team-onboarding`/`/tui`, PowerShell tool, native bfs/ugrep, `PermissionDenied` hook, PreToolUse `defer`, hooks→MCP. Context window table realigned: 1M GA for Opus/Sonnet 4.6, rot threshold 300–400K.
- `context-window.md` — Rot threshold updated to 300–400K on 1M GA models (was ~110K), Document & Clear pattern, `/resume` speedup, `/usage` replaces `/cost`+`/stats`, `ENABLE_PROMPT_CACHING_1H`.
- `mcps-catalog.md` — MCP Tool Search lazy loading, `_meta["anthropic/maxResultSizeChars"]`, community core must-haves, startup concurrency, `MCP_CONNECTION_NONBLOCKING`, enterprise managed settings.
- `community-tips.md` — Opus 4.7 explicit prompting, Document & Clear, checkpoint/rollback over fix-forward, master-clone subagents, `/less-permission-prompts`.
- `anti-patterns.md` — 8 new anti-patterns including negative-only constraints, Opus 4.7 vague hints, @-mention big docs, CLAUDE.md vs hooks, fix-forward, custom slash-command libraries, `allowed-tools:` frontmatter trust, wide-open subagent tool allowlists.

### Unchanged
- `modes-and-patterns.md` (core framework — edited manually, not via automated research)

### Notes
- First end-to-end run of the subagent-based `/advisor update` flow (replaces previous `claude -p` pipeline that timed out on large prompts).
- Dispatched 1 web-research subagent + 5 parallel per-file subagents. Total ~268K tokens, ~90s wall clock thanks to parallel dispatch.
- Post-run fix: realigned context-window table in `capabilities.md` with `context-window.md` (agents didn't cross-check each other's scope).


## 2026-03-31 — Local update

### Setup local
- 64 skills, 1 MCPs, 32 plugins detected

### Knowledge base
- Local-only update (no web research)


## 2026-03-30 — Rename skill to /advisor

### Fix
- Renamed skill from `claude-code-advisor` to `advisor` in SKILL.md frontmatter
- The slash command is now `/advisor` instead of `/claude-code-advisor`
- Thanks to Jimmy Andriamparany for the feedback

## 2026-03-29 — Local update

### Setup local
- 62 skills, 0 MCPs, 32 plugins detected

### Unchanged
- anti-patterns.md
- capabilities.md
- community-tips.md
- context-window.md
- mcps-catalog.md
- modes-and-patterns.md


## 2026-03-29 — Local update

### Setup local
- 62 skills, 0 MCPs, 32 plugins detected

### Knowledge base
- Local-only update (no web research)


## 2026-03-29 — Local update

### Setup local
- 62 skills, 0 MCPs, 32 plugins detected

### Knowledge base
- Local-only update (no web research)


## 2026-03-29 — Manual update

### Setup local
- 62 skills, 0 MCPs, 32 plugins detected

### Knowledge base
- Local-only update (no web research)

## 2026-03-29 — Initial release

- Knowledge base created with 7 reference files
- Update script with `claude -p` integration
- Cron scheduling for weekly auto-update
