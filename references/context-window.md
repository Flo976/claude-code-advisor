# Context Window Management

Token management is one of the highest-leverage skills in Claude Code. This file covers limits, degradation signs, and strategies to stay in the high-performance zone.

---

## Limits and Degradation

| Model | Max Tokens | Degradation Starts | Effective Range |
|-------|-----------|-------------------|-----------------|
| Claude Opus 4.6 | 1M tokens | ~110K tokens (as of March 2026) | 0–110K |
| Claude Sonnet 4.6 | 200K tokens | ~110K tokens (as of March 2026) | 0–110K |
| Claude Haiku 4.5 | 200K tokens | ~80K tokens | 0–80K |

**Key insight:** The 200K window does not mean 200K tokens of consistent quality. After ~110K tokens, Claude's ability to track earlier context, follow conventions, and maintain coherence degrades measurably — even though the window still has capacity.

The 1M window on Opus 4.6 is genuinely useful for whole-codebase analysis, but the same degradation dynamics apply: the first 110K tokens get the most attention.

---

## Signs of Context Window Degradation

Watch for these signals — they indicate it's time to reset, compact, or use subagents:

- **Repeated questions:** Claude asks for information you already provided earlier in the session
- **Convention drift:** Code stops following the style or patterns established at the start of the session
- **Lost file state:** Claude refers to an older version of a file you've already edited
- **Inconsistency:** Different parts of the same response contradict each other
- **Verbose responses that miss the point:** Claude writes a lot but doesn't answer the actual question
- **Missed constraints:** Requirements you specified early in the session are no longer honored
- **Hallucinated references:** Claude invents file paths, function names, or imports that don't exist

When you see two or more of these signs in the same session, treat context degradation as the likely cause before debugging anything else.

---

## Strategies

### 1. `/clear` — Start Fresh
The most reliable way to restore performance. Use it between unrelated tasks or whenever degradation signs appear.

**When to use:** Between different features or bugs, after a task completes, when pivoting to a different area of the codebase.

**Cost:** You lose all conversational history. Mitigate by adding key facts to CLAUDE.md before clearing.

---

### 2. Compaction — Summarize Instead of Clear
`/compact` triggers automatic context summarization. Claude summarizes older history into a condensed form, freeing up tokens while preserving key decisions.

**When to use:** Mid-task when you want to preserve context but reduce size. Works well for long debugging sessions or multi-hour feature work.

**Limitation:** Summary quality varies. After compaction, verify Claude still knows the critical constraints before continuing.

---

### 3. Subagents for Research
When you need to explore something (read a library's code, analyze a large log file, investigate an unfamiliar codebase), use the `Agent` tool to spawn a subagent. The subagent runs in isolation and returns only its findings — not the full content it processed.

**Pattern:**
```
Use Agent to: Read the Prisma schema and all migration files, then return a summary of:
1. Current schema structure (table names, key columns)
2. Any pending migrations and what they change
3. Any patterns or naming conventions you observe
Return only the summary, not raw file contents.
```

The parent session gets a compact summary instead of thousands of lines of raw content.

---

### 4. Worktrees for Parallel Work
Use git worktrees to maintain multiple parallel sessions, each working on a different branch. This keeps each session's context focused on one task.

**When to use:** When you have multiple independent features in progress, or want to run experiments without polluting your main session.

**Setup:**
```bash
git worktree add ../project-feature-x feature/x
cd ../project-feature-x
claude
```

---

### 5. Concise CLAUDE.md
A bloated CLAUDE.md is a tax on every session. Every token in CLAUDE.md is loaded at the start of each session, consuming context before any work begins.

**Budget:** Keep CLAUDE.md under 200 lines / ~3K tokens. If it's growing, extract non-essential content to separate reference files that Claude reads on demand.

**What belongs in CLAUDE.md:** Project overview (2–3 sentences), tech stack, critical conventions, anti-patterns specific to this codebase, key file paths.

**What doesn't belong:** Full API documentation, complete code examples longer than 10 lines, historical decisions, meeting notes.

---

### 6. Glob and Grep Over Full File Reads
Reading entire files when you need a fraction of their content is the most common way to blow the context budget.

**Prefer:**
- `Grep` with specific patterns to find relevant lines
- `Glob` to list files matching a pattern before deciding which to read
- `Read` with `offset` and `limit` when you know which section you need

**Avoid:**
- Reading entire large files (>200 lines) when you're looking for one function
- Passing `cat *` outputs into the prompt
- Reading files "just in case they're relevant"

---

### 7. Progressive Disclosure
Provide context in layers. Start with the minimum needed to understand the task. Add more only when Claude asks for it or when output quality indicates more is needed.

**Principle:** Claude doesn't need to see the whole codebase to fix a bug in one function. Give it the function, the relevant types, and the test that's failing — nothing more.

---

## Context Budget by Task Type

Use these rough budgets to calibrate how much context to load:

| Task Type | Target Budget | Notes |
|-----------|--------------|-------|
| Quick question / factual | < 5K tokens | No file context needed |
| Bug fix (single file) | 5–15K tokens | File + relevant imports + test |
| New feature (moderate) | 20–50K tokens | Spec + related files + conventions |
| Large refactor | Use subagents | Each subagent handles a module |
| Full codebase analysis | Use Agent tool | Subagent reads all; returns summary |
| Multi-day project | Worktrees + /clear | One session per workstream |

---

## Context Budget Tracking

Claude Code doesn't show a real-time token counter in most interfaces. Estimate usage by:
1. Tracking the number and size of files you've read in the session
2. Noting how many rounds of back-and-forth have happened
3. Watching for degradation signs (see above)

**Rule of thumb:** If you've been in a session for more than 90 minutes of active work on a complex task, check for degradation signs. Consider a `/clear` or `/compact`.

---

## The Progressive Disclosure Pattern in Practice

**Bad (context-heavy):**
```
Here is our entire codebase. The problem is in the auth module. Fix the login bug.
[pastes 20 files]
```

**Good (progressive disclosure):**
```
I have a login bug. The error is: [specific error message].

The relevant file is `src/auth/login.ts`. Please read it and identify the issue.
```

Then, only if needed: "Also check `src/auth/session.ts` for how sessions are created."

The second approach loads 5–15K tokens instead of 200K+, leaves Claude with working memory for the actual fix, and produces better output.
