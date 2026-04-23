# Community Tips

Best practices collected from the Claude Code community, organized by category. This file is updated weekly via automated script.

> Last updated: 2026-04-23 (added Opus 4.7 prompting, document-and-clear, checkpoint/rollback, master-clone subagents, less-permission-prompts tips)

---

## Prompt Engineering Tips

**Specify the output format explicitly.** Claude defaults to verbose explanations. When you want code only, say "return only the modified function, no explanation." When you want a list, say "return a numbered list of 5 items." Explicit format instructions reduce post-processing and save context.

**Include the error message verbatim, not a paraphrase.** Claude pattern-matches on error messages. "It says something about a null reference" triggers a guess. Pasting the exact error trace triggers a diagnosis.

**Tell Claude what you've already tried.** "I've already tried restarting the server and clearing the cache" prevents Claude from suggesting those first. Saves a round trip.

**Use positive constraints, not just negative ones.** "Don't use jQuery" is weaker than "use vanilla JS fetch API." Negative constraints leave too much ambiguous; positive constraints specify the target.

**Separate your constraints from your goal.** "I need to add pagination. Constraints: no new dependencies, must work with the existing `useFetch` hook, TypeScript strict mode." Structured prompts produce more targeted output than prose.

**Ask for the trade-offs before asking for the solution.** "What are the trade-offs between approach A and approach B for this feature?" often produces better information than "implement this feature." Use plan mode for this.

**Opus 4.7 punishes vague prompts — state tone, structure, audience, and constraints.** The model "does exactly what you tell it." Hints are no longer enough; rewrite go-to prompts and Skill files to explicitly name the desired tone, output structure, target audience, and hard constraints. Opus 4.7 also reasons more and calls tools less, so explicitly request parallel subagents (e.g., "spawn 3 parallel Task() agents to explore X, Y, Z") when you want concurrency. Source: https://www.productcompass.pm/p/claude-opus-4-7-guide (April 2026).

---

## CLAUDE.md Best Practices

**Keep it under 200 lines.** CLAUDE.md loads at the start of every session. Every line you add is a tax on every session. Ruthlessly prune what isn't load-bearing.

**Structure with clear headers.** Recommended sections: `## Overview`, `## Tech Stack`, `## Project Structure`, `## Conventions`, `## Anti-Patterns`, `## Key Files`. Claude navigates structured documents better than prose.

**Include anti-patterns, not just patterns.** "We use Zod for validation, never yup" is more useful than "we use Zod for validation." Anti-patterns prevent the 20% of cases where Claude would reach for the wrong tool.

**Update CLAUDE.md when you make architectural decisions.** If you decide to migrate from REST to tRPC, update CLAUDE.md that day. Stale CLAUDE.md is actively harmful — it trains Claude to use deprecated patterns.

**Version-control CLAUDE.md like code.** It should go through PR review. Stale or incorrect entries should trigger a fix ticket.

**Separate project CLAUDE.md from global CLAUDE.md.** Global `~/.claude/CLAUDE.md` holds preferences that apply everywhere (preferred languages, formatting style, code review style). Project CLAUDE.md holds project-specific facts. Don't mix them.

**Use update conventions.** Add a line at the top: `<!-- Last updated: 2026-03-29 — reason: migrated from REST to tRPC -->`. Makes it easy to audit whether it's current.

---

## Workflow Patterns

**Brainstorm → Plan → Execute.** Before starting any feature, ask Claude to brainstorm approaches (Level 2). Then use plan mode to select one and detail the steps. Then execute. Skipping brainstorm leads to the first solution, not the best one.

**Systematic debugging workflow.** When stuck on a bug: (1) define the expected vs. actual behavior precisely, (2) identify the smallest reproducible case, (3) ask Claude to generate 3 hypotheses, (4) test the most likely one, (5) iterate. Do not jump to "fix it" without a hypothesis.

**Verify before claiming done.** Before telling yourself (or Claude) the task is complete: run the tests, check the edge cases you identified at the start, re-read the original requirements. "It seems to work" is not verification.

**The rubber duck reset.** When stuck in a long session, describe the problem to Claude from scratch as if starting fresh: "I'm trying to do X. The relevant code is Y. What I've tried is Z." This forces clarity and often the solution appears in the re-framing.

**Incremental commits during long sessions.** Commit after each working increment, not at the end. Gives you recovery points and makes it easier to `/clear` and re-orient without losing progress.

**Spec first, implement second.** Write the function signature and docstring before asking Claude to implement. "Implement this function: [signature + docstring]" produces better output than "write a function that does X."

**Checkpoint before autonomous work, rollback instead of fix-forward.** Reddit community consensus: always commit (or rely on `/rewind`, aliased to `/undo` since v2.1.108) before letting Claude run autonomously. If the result is wrong, rollback and restart with a sharper prompt rather than trying to correct a degraded session. Starting fresh has a higher success rate than wrestling corrections. Source: https://www.morphllm.com/claude-code-reddit (April 2026).

---

## Context Window Management Tips

**The 90-minute rule.** After 90 minutes of active work on a complex task, check for degradation signs (repeated questions, convention drift, hallucinated references). If you see two or more, `/clear` and re-anchor.

**Summarize before switching tasks.** Before `/clear`, ask Claude: "Summarize the key decisions made and current state of the work so I can paste this as context in the next session." Paste the summary into CLAUDE.md or keep it handy.

**Prefer Grep over Read for exploration.** When you don't know exactly which file or line you need, use Grep. Reading whole files "just in case" is the fastest way to blow your context budget.

**Subagents for research isolation.** When you need to deeply explore a library, a log file, or a foreign codebase, use the Agent tool. The subagent absorbs the exploration cost; you receive a compact summary.

**CLAUDE.md is loaded context, not free.** Every line in CLAUDE.md is present in every session. Don't add things to CLAUDE.md that would only matter in 1-in-20 sessions. Those belong in separate files that Claude reads on demand.

**"Document & Clear" beats automatic compaction.** Auto-compaction is opaque and error-prone. Instead, have Claude dump progress, decisions, and open questions to a markdown file (e.g., `.claude/session-notes.md`), then `/clear`, then restart the next session by reading that summary. Reserve `/compact` for cases where the recent context is still genuinely needed. Source: https://blog.sshh.io/p/how-i-use-every-claude-code-feature (2026).

---

## Subagent Patterns

**Prefer master-clones over specialist subagents.** Custom subagents gatekeep information and force rigid workflows, losing holistic reasoning. Instead, let the primary agent spawn parallel copies of itself via `Task()` — this preserves the full context model and reasoning style. Reserve specialist subagents for cases where you genuinely need isolated context (e.g., worktree isolation, available via v2.1.83+). Source: https://blog.sshh.io/p/how-i-use-every-claude-code-feature (2026).

---

## Team Patterns

**Shared CLAUDE.md in version control.** For teams, CLAUDE.md is a shared artifact. Treat it as such: PR reviews for changes, changelog entries for significant updates, clear ownership for keeping it current.

**Custom skills encode team conventions.** The highest-leverage team investment is building skills that encode your specific conventions, not generic ones. A "create-feature" skill that knows your stack, your test patterns, and your PR process pays off on every feature.

**Onboarding via CLAUDE.md.** A good CLAUDE.md doubles as an onboarding document. If a new team member (or Claude) can read it and know how to work in the codebase, it's doing its job.

**Code review skill with team standards.** Build a code review skill that encodes your team's actual standards: security checks relevant to your domain, performance patterns you care about, anti-patterns specific to your codebase. Generic code review is less useful than opinionated code review.

**Conventions log.** Keep a `decisions/` folder with short ADR (Architecture Decision Record) files. Reference them from CLAUDE.md. Claude can read ADRs on demand when working on related areas, without loading them into every session.

---

## Permissions & Allowlist Tuning

**Use `/less-permission-prompts` to auto-generate an allowlist.** The built-in skill (shipped in v2.1.111, 2026-04-16) scans your recent transcripts for common read-only Bash and MCP tool calls, then proposes a prioritized allowlist for `.claude/settings.json`. Run it periodically to cut down on permission prompt noise without hand-curating. Since v2.1.113, `cd <current-directory> && git …` no longer triggers a permission prompt, and `sandbox.network.deniedDomains` lets you block specific domains instead of allowlisting every host. Source: https://code.claude.com/docs/en/changelog (v2.1.111 / v2.1.113, April 2026).

---

*This file is updated weekly. Tips are marked with the date they were added or last revised.*
