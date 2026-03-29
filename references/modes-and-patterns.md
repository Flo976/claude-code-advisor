# Modes and Patterns: The 6-Level Framework

This is the core reference file for the claude-code-advisor knowledge base. It describes six levels of Claude Code mastery, their defining characteristics, and a decision matrix for matching task types to the right level of engagement.

---

## Overview

Most people stay at Level 1 or 2 and wonder why results are inconsistent. Levels 3–6 are where compounding returns kick in. The goal is not to always operate at Level 6 — it is to know which level fits the task and apply it deliberately.

---

## Level 1 — Prompter

**Core identity:** Uses Claude Code as a blunt instrument. Fires off prompts and takes what comes back.

**Defining behavior:**
- Sends one large prompt and hopes for the best
- Accepts output without critically evaluating it
- Relies on Claude's defaults for everything

**Skills to develop at this level:**
- Writing clear, specific prompts (goal + constraints + context)
- Evaluating output critically — does it actually solve the problem?
- Basic terminal literacy (navigating the CLI, understanding tool calls)

**Signs you're stuck at Level 1:**
- Frequent "this isn't what I meant" moments
- Copy-pasting Claude output directly into production without review
- Asking the same question multiple times with slight variations

**Upgrade trigger:** When you notice Claude going in the wrong direction on tasks you care about.

---

## Level 2 — Collaborator

**Core identity:** Uses plan mode deliberately. Treats Claude as a junior partner, not an oracle.

**Defining behavior:**
- Invokes plan mode (`/plan`) for any non-trivial task
- Asks "what am I missing?" before approving a plan
- Iterates collaboratively rather than issuing single mega-prompts
- Challenges Claude's assumptions and pushes back on weak proposals

**Key practices:**
- "Before you proceed, what questions do you have about the requirements?"
- "What are the top three risks in this approach?"
- "Show me the plan first. Don't start implementing yet."

**Signs you're operating at Level 2:**
- You catch issues in plans before they become bugs in code
- You treat Claude's first response as a draft, not a deliverable
- You ask clarifying questions proactively

**When Level 2 is enough:** Design decisions, architecture discussions, simple bug fixes where the solution space is well-understood.

**Upgrade trigger:** When you notice the same context being re-explained every session, or when Claude loses important project conventions mid-task.

---

## Level 3 — Context Engineer

**Core identity:** Manages information flow deliberately. Knows that the right context at the right time determines output quality.

**Defining behavior:**
- Maintains a well-structured `CLAUDE.md` that encodes project conventions, constraints, and preferences
- Monitors context window usage and intervenes before degradation
- Provides examples (not just descriptions) for complex requirements
- Uses `/clear` or subagents to reset context when needed
- Uses `Glob` and `Grep` with specific patterns instead of reading entire files

**Key insight:** Context window quality degrades at ~110K tokens (as of March 2026) even though the window is 200K. More context is not always better — irrelevant context crowds out relevant context.

**CLAUDE.md best practices:**
- Keep under 200 lines
- Structured with headers: Project Overview, Tech Stack, Conventions, Anti-Patterns, Key Files
- Updated when conventions change — stale CLAUDE.md is worse than none
- Include 2–3 concrete examples of preferred code style

**Token management tactics:**
- `/clear` between unrelated tasks
- Use `Read` with `offset`/`limit` instead of reading entire large files
- Prefer `Grep` over `Read` when searching for specific patterns
- Use subagents for research that doesn't need to pollute the main context
- Summarize findings and pass them back, not raw file dumps

**Signs you're operating at Level 3:**
- Claude consistently follows your project's conventions without reminder
- You notice context window size and act before quality drops
- Your sessions stay focused and don't balloon with irrelevant file contents

**Upgrade trigger:** When you find yourself doing the same multi-step process (API integration, test setup, migrations) repeatedly from scratch.

---

## Level 4 — Tool User

**Core identity:** Adds MCPs and external integrations strategically. Understands what each tool actually does before reaching for it.

**Defining behavior:**
- Selects MCPs based on concrete need, not FOMO
- Understands the front-end/back-end/auth/DB architecture conceptually before using tools that touch those layers
- Evaluates tool cost: each MCP adds context overhead and a new failure mode
- Treats tool selection as a surgical decision, not a shopping spree

**Key insight:** "Capability does not equal performance." Having 15 MCPs configured doesn't make you a Level 4 user — understanding when to reach for each one does.

**Anti-pattern to avoid:** The "kid in a candy store" pattern — installing every available MCP and ending up with a bloated, slow, unreliable setup. See `anti-patterns.md`.

**Good Level 4 decisions:**
- Use Context7 MCP for library docs instead of WebSearch (lower latency, better formatting)
- Use Figma MCP only when working directly from a design file, not for general UI work
- Disable MCPs not relevant to the current project in that project's settings

**Signs you're operating at Level 4:**
- You can explain why each enabled MCP is there
- You notice when an MCP is adding noise rather than signal
- You understand the failure modes of your tool stack

**Upgrade trigger:** When you notice yourself executing the same multi-step workflow repeatedly and thinking "this should be a script."

---

## Level 5 — Skill Architect

**Core identity:** Encodes reusable workflows as skills. Benchmarks and tests them.

**Defining behavior:**
- Creates skills using the `skill-creator` skill as a starting point
- Keeps skills focused — one skill does one thing well
- Writes test cases and benchmarks for critical skills
- Maintains a personal skills library that compounds over time
- Documents when to invoke each skill (and when NOT to)

**Key practices:**
- Skills under 500 lines — if longer, split into sub-skills
- Each skill has a clear trigger condition and exit condition
- Include explicit "do not use this skill when X" guidance
- Version-control skills alongside project code

**Signs you're operating at Level 5:**
- You have skills that save you 20+ minutes per use
- Your skills encode your team's conventions, not just generic workflows
- You benchmark new skills against doing the task manually

**Skill categories to build:**
- Code review skill (with your standards)
- Debugging checklist skill
- Feature implementation skill (your specific stack)
- Deployment verification skill

**Upgrade trigger:** When you're managing multiple parallel workstreams and need to coordinate them.

---

## Level 6 — Manager

**Core identity:** Orchestrates multiple sessions, worktrees, and agent teams. Decides what gets done and by whom — not how.

**Defining behavior:**
- Decomposes large projects into independent workstreams
- Uses git worktrees to run parallel feature branches without interference
- Launches subagents for isolated, context-heavy tasks
- Reviews outputs at a high level and routes corrections rather than diving into details
- Maintains coordination logic outside individual sessions (in CLAUDE.md, task files, or external tools)

**Key insight:** At Level 6, your job is to decide what gets done, not to supervise every keystroke. Micro-managing subagents defeats the purpose. Clear task specs and good review processes are the leverage.

**Signs you're operating at Level 6:**
- You regularly run 3+ parallel workstreams without confusion
- You can hand off a complex task to a subagent with a spec and trust the output
- You review at the interface level (does it work? does it conform?) not the implementation level

**When Level 6 is overkill:** Any project where the workstreams aren't genuinely independent, or where coordination cost exceeds the parallelization benefit. Small-to-medium features don't need Level 6.

---

## Decision Matrix

Use this table to match your task to the appropriate level and recommended approach.

| Task Type | Level | Recommended Approach |
|-----------|-------|---------------------|
| Quick question / factual lookup | 1 | Direct prompt, no ceremony |
| Bug fix in known location | 1–2 | Prompt with file context; use plan mode if the fix is non-trivial |
| New feature (clear spec) | 2–3 | Plan mode first; provide CLAUDE.md context; review plan before execution |
| Refactoring existing code | 3 | Manage context carefully; use Grep to scope files; subagent for large codebases |
| Integrating external API/service | 4 | Use Context7 MCP for docs; understand auth/data flow before starting |
| Repetitive multi-step process | 5 | Build a skill; benchmark it against manual execution |
| Large project (10+ files) | 6 | Decompose into workstreams; use worktrees; orchestrate with subagents |
| Design/architecture decision | 2 | Collaborative discussion in plan mode; ask "what am I missing?" |
| Debugging complex issue | 3–4 | Systematic debugging skill; use subagents for isolated reproduction |
| Code review | 5 | Invoke a code review skill encoding your team's standards |
| Full project from scratch | 6 | Spec first; decompose; parallel workstreams for independent modules |

---

## Level Progression Tips

1. **Don't skip levels.** Level 3 context engineering is necessary foundation for Level 5 skill building. Skipping to Level 6 without Level 3 habits leads to chaotic orchestration.

2. **Levels are situational.** An expert uses Level 1 for quick lookups and Level 6 for major refactors. The skill is matching level to task, not always operating at maximum sophistication.

3. **Teach your team the vocabulary.** When your team shares the 6-level framework, code review comments like "this needs a Level 3 approach" become actionable.

4. **The bottleneck shifts.** At Level 1, the bottleneck is prompt quality. At Level 3, it's context management. At Level 6, it's decomposition and coordination. Know your current bottleneck.
