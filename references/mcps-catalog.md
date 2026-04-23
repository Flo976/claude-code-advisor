# MCPs Catalog

A catalog of known Model Context Protocol (MCP) servers, with guidance on when and when not to use each.

---

## What is an MCP?

Model Context Protocol servers extend Claude Code with new tools. They run as separate processes and communicate with Claude via a standardized protocol. Each MCP adds new tool calls to the session.

**Important:** Every active MCP consumes context tokens just by being available, even if you never call its tools. This is the primary anti-pattern to avoid. See the anti-patterns section below.

**MCP Tool Search (lazy loading).** Recent Claude Code versions ship a built-in MCP Tool Search that defers loading of tool schemas until they are needed — Anthropic reports up to ~95% reduction in MCP-related context usage. This means the old hard rule of "keep MCPs off unless used today" has softened: with Tool Search enabled, you can afford a broader set of configured servers without paying the full per-session token cost. The discipline around avoiding redundant MCPs (see anti-patterns) still applies — cheaper is not free.

---

## Catalog

### Figma MCP

**What it does:**
- Reads design files: layout, components, colors, typography, spacing
- Captures screenshots of specific frames or components
- Extracts design tokens (colors, spacing, type scales) as CSS variables
- Supports Code Connect — maps Figma components to codebase components
- Can write designs back into Figma files

**When to use:**
- You are implementing a design directly from a Figma file
- You need pixel-accurate spacing, color, or typography values
- You want to extract assets (icons, images) from a design file
- You are building Code Connect mappings for a design system

**When NOT to use:**
- General UI work not tied to a specific Figma file
- When the designer hasn't structured the Figma file clearly (you'll get noise, not signal)
- For exploring visual design options (it reads designs; it doesn't generate them)
- When you don't have access to the Figma file in question

**Notes:**
- Requires a Figma access token in your environment
- Node IDs in Figma URLs use `-` separators; the MCP expects `:` — convert accordingly
- Code Connect requires setup work upfront; pays off on large design systems

---

### Atlassian MCP

**What it does:**
- Reads and creates Jira issues (get, create, edit, transition, add comments/worklogs)
- Reads and creates Confluence pages (get, create, update, add inline/footer comments)
- Searches both Jira (JQL) and Confluence (CQL)
- Links Jira issues to each other

**When to use:**
- You are working on a task tracked in Jira and want Claude to read the ticket directly
- You need to update a Confluence page with implementation notes or decisions
- You want to create Jira subtasks automatically from a plan Claude generates
- You need to look up acceptance criteria, background, or linked tickets without leaving the terminal

**When NOT to use:**
- When the relevant context is already pasted into your prompt — don't add MCP overhead just for convenience
- For bulk operations better handled by Jira's native automation
- When you don't have Atlassian credentials configured

**Notes:**
- JQL and CQL queries can be constructed by Claude if you describe what you need in English
- Useful in `PostToolUse` hooks to automatically log work after Claude completes tasks

---

### Context7 MCP

**What it does:**
- Fetches current, accurate documentation for libraries and frameworks
- Resolves library IDs from common names (`react`, `next`, `prisma`, etc.)
- Returns structured documentation snippets optimized for LLM consumption
- Covers API syntax, configuration, migration guides, CLI usage

**When to use:**
- Any time you need library documentation (prefer this over WebSearch for lib docs)
- When working with a library you suspect may have changed since your training cutoff
- For version-specific API lookups (e.g., "how does Next.js 15 handle caching?")
- For migration guides between versions

**When NOT to use:**
- For general programming concepts not tied to a specific library
- For internal/proprietary libraries not in the Context7 registry
- For debugging business logic (this is docs lookup, not code analysis)

**Notes:**
- This should be a default-on MCP for most development work
- Much faster and more accurate than WebSearch for library documentation
- Use `resolve-library-id` first, then `query-docs` with the resolved ID

---

### Vercel MCP

**What it does:**
- Lists and inspects deployments (status, build logs, runtime logs)
- Gets project configuration and environment variables
- Deploys projects to Vercel
- Accesses toolbar threads (visual feedback from stakeholders)
- Checks domain availability

**When to use:**
- Debugging a failed deployment (access build logs without leaving the terminal)
- Reviewing runtime errors in production or preview environments
- Automating deployment as part of a larger workflow
- Responding to toolbar feedback during UI review sessions

**When NOT to use:**
- For Vercel documentation (use Context7 MCP or the `vercel:*` skills instead)
- When you can check the Vercel dashboard faster than the MCP would
- For projects not hosted on Vercel

**Notes:**
- Requires a Vercel access token
- Pair with the `vercel:investigation-mode` skill for systematic production debugging
- Build and runtime logs are the highest-value capabilities; use them first

---

### shadcn MCP

**What it does:**
- Lists components available in shadcn/ui registries
- Searches for specific components by name or description
- Returns the exact `npx shadcn add` command for installing components
- Shows component examples and variants
- Supports custom registries beyond the default shadcn registry

**When to use:**
- You are building a UI with shadcn/ui and want to find or install components
- You want to check what's available before writing custom components
- You are working with a custom component registry in your organization

**When NOT to use:**
- For non-shadcn UI work
- When you already know the component name — just run `npx shadcn add <name>` directly
- For styling questions not related to component installation

**Notes:**
- Use `list_items_in_registries` to browse; use `get_add_command_for_items` to get the install command
- The `get_audit_checklist` tool is useful for reviewing a component implementation against shadcn conventions

---

### GitHub MCP

**What it does:**
- Creates, reads, and updates GitHub issues and pull requests
- Manages branches and repository operations
- Reads file contents from repositories
- Runs and monitors GitHub Actions workflows

**When to use:**
- You want Claude to read PR comments or issue descriptions directly
- You are automating PR creation as part of a workflow
- You need to interact with GitHub repositories programmatically

**When NOT to use:**
- For simple git operations — use the `Bash` tool with standard git commands
- When the `gh` CLI can do the job more simply
- For repositories you don't have API access to

**Notes:**
- Availability depends on your Claude Code configuration
- The `gh` CLI (via `Bash`) covers most GitHub needs without MCP overhead
- Most valuable when you need GitHub context integrated into a larger workflow

---

## Community "core must-haves"

Beyond the servers detailed above, community consensus in 2026 consistently lists the following as high-value MCPs. Enable them on demand rather than globally.

- **Filesystem MCP** — sandboxed read/write access to specified directories. Useful when you want Claude to operate outside the current project root in a controlled way. Prefer the built-in file tools for normal in-repo work.
- **PostgreSQL MCP** — direct SQL execution against a configured database. Valuable for schema inspection, query shaping, and data debugging. Keep credentials tight; prefer read-only roles.
- **Sequential Thinking MCP** — exposes an explicit chain-of-thought scratchpad tool for long multi-step reasoning. Helpful for planning-heavy tasks where Claude benefits from structured intermediate state.
- **Playwright / Puppeteer MCP** — browser automation (navigation, DOM inspection, screenshots). Use for end-to-end testing, scraping, or reproducing UI bugs. `claude-in-chrome` is the newer in-browser alternative on some setups.
- **Memory MCP (knowledge graph)** — persistent, structured memory across sessions. Useful for long-running projects where Claude should recall entities, decisions, or relationships over time.

The two most-recommended additions beyond the obvious (GitHub, Filesystem) are **Context7** (already above) and **Sequential Thinking**.

---

## Anti-Patterns

### The "Kid in a Candy Store"
Installing every available MCP because they look useful. Result: bloated context, slower responses, higher token costs, and MCPs fighting for attention in the system prompt.

**Rule:** Only enable an MCP if you can complete the sentence "I need this MCP because ___" for a task you are doing today.

### MCP for Everything
Using an MCP when a simpler tool works just as well. Example: using the GitHub MCP to read a file you could `cat` in one second via `Bash`.

**Rule:** Reach for an MCP when it provides access to something Claude otherwise cannot get — not when it provides a slower path to something you can already do.

### Forgetting MCPs Are Always On
Configuring MCPs globally and forgetting they're active in every session. With MCP Tool Search, the cost of an idle MCP is now much smaller — but not zero, and servers still connect at startup.

**Rule:** Use project-level MCP configuration to enable MCPs only where they're relevant. Review your global MCP list quarterly. Rely on Tool Search to absorb the marginal case, not to excuse a bloated global list.

### Over-persisting MCP tool output
Some MCP servers return huge result payloads (database dumps, large documents). By default, Claude Code truncates very large tool results; some servers legitimately need more.

**Rule:** If a data-heavy MCP is being unhelpfully truncated, check whether the server sets `_meta["anthropic/maxResultSizeChars"]` (it can request up to ~500K). Do not try to bypass this limit client-side — a security fix explicitly closed that door.

---

## Configuration Notes

MCPs are configured in `~/.claude/.mcp.json` (global) or `.mcp.json` in the project root (project-local). Project-local settings override globals for that project. Prefer project-local configuration to keep MCP scope narrow.

**Startup behavior.** Recent Claude Code versions connect to local and `claude.ai` MCP servers concurrently, so total startup time is roughly bounded by the slowest server rather than the sum. `resources/templates/list` is deferred until the first `@`-mention, reducing idle chatter.

**Headless / `-p` mode.** Set `MCP_CONNECTION_NONBLOCKING=true` to keep `claude -p` from blocking on MCP connections; servers are given a ~5s connection window and then the run proceeds without them. Useful in CI and scripted pipelines where an unreachable MCP shouldn't fail the whole invocation.

**Result size override.** MCP servers may declare `_meta["anthropic/maxResultSizeChars"]` on a tool result to persist larger payloads (up to ~500K) when they genuinely need to. Server-side declaration only — this is not a client-side knob.

**Enterprise / managed settings.** Organizations can constrain plugin marketplaces via managed settings: `blockedMarketplaces` and `strictKnownMarketplaces` are enforced on install, update, refresh, and autoupdate. The official Anthropic marketplace (`claude-plugins-official`) is available by default; third-party marketplaces (e.g. community bundles packaged via `ccpi`-style CLIs) should only be added after a review of what they ship. Treat third-party MCP servers the same way you treat any other untrusted code executing in your environment.
