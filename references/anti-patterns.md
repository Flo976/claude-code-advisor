# Anti-Patterns

Common mistakes organized by the 6-level framework. Each pattern includes a concrete example and a correction.

---

## Level 1 — Prompter Anti-Patterns

### 1.1 The Vague Prompt
**What it looks like:**
```
fix my code it's broken
```

**Why it fails:** Claude has no idea what "broken" means, which code to look at, or what success looks like. It will either ask clarifying questions (slow) or guess (risky).

**Correction:**
```
The function `processPayment` in `src/payments/processor.ts` throws a TypeError at line 47 when `amount` is null. It should return an error object instead of throwing. Here is the current function: [paste function].
```

The corrected prompt has: what, where, what's wrong, what the expected behavior is.

---

### 1.2 The Mega-Prompt
**What it looks like:**
```
Build me a full-stack app with user auth, a dashboard, API integration with Stripe and Salesforce, an admin panel, email notifications, PDF export, and mobile-responsive design. Here's all my existing code: [pastes 50 files]
```

**Why it fails:** Claude will attempt to do everything at once, the context fills immediately with irrelevant content, and the output will be superficial on every requirement. You also lose the ability to review and correct incrementally.

**Correction:** Break into phases. Use Level 2 (plan mode) to decompose first, then execute one phase at a time. Each phase has its own focused context.

---

### 1.3 Not Reading Output Critically
**What it looks like:** Copy-pasting Claude's output directly into production without running it, reading it, or testing it.

**Why it fails:** Claude makes mistakes. Confident-sounding output is still wrong ~10–20% of the time on non-trivial tasks, especially with edge cases, error handling, and security.

**Correction:** Every Claude output is a draft. Run the code. Read the diff. Ask "does this actually handle the edge case I care about?" before committing.

---

### 1.4 Treating Repeated Prompting as a Strategy
**What it looks like:** Sending the same prompt 5 times with minor wording changes, hoping one will produce the right output.

**Why it fails:** If your prompt lacks the necessary context, no amount of rewording will fix it. Temperature variation produces noise, not targeted improvement.

**Correction:** When Claude's output is wrong, diagnose why. Is the problem missing context? Wrong framing? Then add that specific thing to the prompt.

---

## Level 2 — Collaborator Anti-Patterns

### 2.1 Skipping Plan Mode for Non-Trivial Tasks
**What it looks like:** Directly executing a database migration or multi-file refactor without reviewing a plan first.

**Why it fails:** Claude will make choices you would have changed if you'd seen them in advance. Some of those choices are hard to reverse (dropped columns, changed APIs, deleted files).

**Correction:** For any task with side effects or multiple files, use `/plan` first. The 2-minute review is always cheaper than the debugging session.

---

### 2.2 Rubber-Stamping Claude's Plans
**What it looks like:** Claude proposes a plan. You say "looks good, proceed" without reading it.

**Why it fails:** You've outsourced the judgment call to Claude — but Claude doesn't know your stakeholder constraints, technical debt history, or organizational preferences.

**Correction:** Actually read the plan. Ask "what am I missing?" Ask "what are the risks of approach B vs. A?" Push back on anything that doesn't sit right.

---

### 2.3 Not Asking Clarifying Questions First
**What it looks like:** You have a vague idea of what you want. You don't ask Claude to surface assumptions or ambiguities before diving in.

**Why it fails:** Claude will make assumptions. Some will be wrong. You find out after implementation, not before.

**Correction:** Before any non-trivial task, ask: "Before you start, what assumptions are you making? What information would change your approach?"

---

### 2.4 Treating Every Task as Requiring Collaboration
**What it looks like:** Using plan mode for "rename this variable" or "fix this typo."

**Why it fails:** Overhead without benefit. Plan mode adds ceremony that's only valuable when there are real decisions to make.

**Correction:** Save plan mode for tasks where judgment calls matter. Trivial tasks are Level 1 tasks.

---

## Level 3 — Context Engineer Anti-Patterns

### 3.1 No CLAUDE.md
**What it looks like:** Starting every session by re-explaining your tech stack, coding conventions, and project structure.

**Why it fails:** Claude has no persistent memory between sessions. Without CLAUDE.md, every session starts from zero. Conventions drift. Claude uses patterns it learned from other projects.

**Correction:** Create `CLAUDE.md` at project root with: overview, tech stack, file structure, key conventions, anti-patterns to avoid. Under 200 lines. Update it when conventions change.

---

### 3.2 Dumping the Entire Codebase
**What it looks like:**
```bash
cat $(find . -name "*.ts") | claude "refactor the auth module"
```

**Why it fails:** You've filled the context window with mostly irrelevant content. Claude will miss things in the auth module because its attention is diluted across 100 files.

**Correction:** Use `Grep` to find relevant files, read only those, and pass only what matters. "Relevant" means: the files to change + their direct dependencies + the tests.

---

### 3.3 Stale CLAUDE.md
**What it looks like:** CLAUDE.md that still references a database library you migrated away from 6 months ago, or conventions that were superseded by a team decision.

**Why it fails:** Stale CLAUDE.md is worse than none. It actively misleads Claude into following deprecated patterns.

**Correction:** Review CLAUDE.md at the start of every sprint or when making significant architectural changes. Treat it like code, not documentation.

---

### 3.4 Not Managing Context Between Tasks
**What it looks like:** Switching from "fix the payment bug" to "build the notification system" in the same session without clearing context.

**Why it fails:** Context from task 1 pollutes task 2. File state may be inconsistent. Conventions from one area of the codebase interfere with another.

**Correction:** Use `/clear` between unrelated tasks. Use subagents when you need to explore something without polluting the main session. Reset is cheap; debugging context pollution is not.

---

### 3.5 Reading Files When Grepping Would Do
**What it looks like:**
```
Read src/utils/helpers.ts  # 800 lines, you need one function
```

**Why it fails:** You've spent ~6K tokens on content that's 95% irrelevant.

**Correction:**
```
Grep for "function processDate" in src/utils/helpers.ts
```
Or use `Read` with `offset` and `limit` if you know roughly where the function is.

---

## Level 4 — Tool User Anti-Patterns

### 4.1 The Kid in a Candy Store
**What it looks like:** Installing every MCP that looks interesting. Current setup: Figma, GitHub, Jira, Slack, Stripe, Linear, Notion, Salesforce, and 6 others — for a solo side project.

**Why it fails:** Each MCP's tool list appears in the system prompt. With 15 MCPs, you've consumed 10–20K tokens of context budget before writing a single line of code. Response times increase. Claude gets confused about which tools to use.

**Correction:** Only enable MCPs you will use in the current project. Use project-local MCP settings to scope them appropriately. Audit your MCP list quarterly.

---

### 4.2 Using MCPs Without Understanding Them
**What it looks like:** "I installed the Figma MCP so Claude can design my app."

**Why it fails:** The Figma MCP reads designs; it doesn't generate them. If you don't understand what a tool does, you'll use it for the wrong job and get confused when it fails.

**Correction:** Before enabling an MCP, read its documentation. Understand exactly what each tool does and what it can't do. See `mcps-catalog.md` for guidance.

---

### 4.3 MCP as a Crutch for Missing Context
**What it looks like:** Using the GitHub MCP to read a file in the repo... when the repo is already on disk and you could `Read` it directly.

**Why it fails:** You've added latency, MCP overhead, and a network dependency for something trivially available locally.

**Correction:** Use MCPs for data that genuinely isn't available otherwise (design files in Figma, deployments in Vercel, tickets in Jira). Don't use them as a fancier way to do what simpler tools already do.

---

### 4.4 Not Understanding the Architecture You're Integrating With
**What it looks like:** Using a database MCP without understanding the schema, or using an auth MCP without knowing the token flow.

**Why it fails:** Claude will integrate with the tool at face value. If you don't understand the underlying architecture, you won't recognize when Claude is doing it wrong.

**Correction:** Before integrating an external service with MCP assistance, spend 20 minutes reading the service's own docs. Claude amplifies your understanding; it can't replace it.

---

## Level 5 — Skill Architect Anti-Patterns

### 5.1 Skills Over 500 Lines
**What it looks like:** One SKILL.md file that handles: feature planning, implementation, code review, testing, deployment, and documentation — 800 lines.

**Why it fails:** Long skills are hard to reason about, hard to update, and hard to test. When something goes wrong, you don't know which part failed. Claude also has trouble following complex, intertwined instructions reliably.

**Correction:** Split into sub-skills: `feature-plan.md`, `feature-implement.md`, `feature-review.md`. Each does one thing. The orchestrator skill calls them in sequence.

---

### 5.2 Not Benchmarking Skills
**What it looks like:** Building a skill, using it once, and declaring success.

**Why it fails:** Skills degrade as the codebase changes or as Claude model versions update. Without benchmarks, you don't know when a skill has stopped working.

**Correction:** For each critical skill, define 2–3 test cases (inputs with known expected outputs). Run them when you update the skill or after a model version change.

---

### 5.3 Skills Without Clear Trigger Conditions
**What it looks like:** A skill called "code-review" with no guidance on when to invoke it vs. when to just ask Claude directly.

**Why it fails:** Skills are invoked inconsistently. The overhead of the skill isn't justified for small reviews.

**Correction:** Every skill should include an explicit "When to use this skill" section and a "When NOT to use this skill" section.

---

### 5.4 Over-Generalizing Skills
**What it looks like:** Building a "debugging skill" so generic that it gives advice applicable to any language, framework, or problem type.

**Why it fails:** Generic skills are less useful than specific ones. A skill for debugging React hydration errors is more useful than a skill for "debugging."

**Correction:** Prefer specific, narrow skills over broad, vague ones. You can always create a lightweight orchestrator skill that routes to specialized sub-skills.

---

## Level 6 — Manager Anti-Patterns

### 6.1 Micro-Managing Subagents
**What it looks like:** Launching a subagent with a task, then immediately spawning another session to "check on it" and course-correct mid-task.

**Why it fails:** Subagents have isolated context. Mid-task interference requires re-explaining the full context and often creates inconsistency. You've negated the isolation benefit.

**Correction:** Write better task specs upfront. Include success criteria, constraints, and the exact format you want back. Let the subagent run. Review the output, not the process.

---

### 6.2 No Coordination Model
**What it looks like:** Launching 5 parallel workstreams with no shared conventions, no integration plan, and no review process. Each subagent does its best and the outputs don't fit together.

**Why it fails:** Parallelization without coordination produces parallel messes. Integration takes longer than sequential development would have.

**Correction:** Before launching parallel work, define: the interface contracts between workstreams, the shared conventions all sessions will follow (from CLAUDE.md), and the integration plan (who merges what, in what order).

---

### 6.3 Treating Agent Teams as the Default
**What it looks like:** Using subagents for a 2-hour task because "that's the Level 6 way."

**Why it fails:** Orchestration has overhead. A 2-hour task with well-managed context is faster than decomposing it, speccing 3 subagents, reviewing their outputs, and integrating the results.

**Correction:** Agent teams are for tasks where parallel execution genuinely saves time — typically 10+ file changes across independent modules. For smaller tasks, Level 3-4 with a clean context is faster.

---

### 6.4 Leaving Workstreams Without Entry Points
**What it looks like:** Creating 4 git worktrees with parallel work, then losing track of which is which and what state each is in.

**Why it fails:** The coordination overhead becomes the bottleneck. You spend more time tracking state than doing work.

**Correction:** Maintain a lightweight task file (or CLAUDE.md entry) for each active workstream: what it's doing, what branch, what the current status is, and what the next action is.
