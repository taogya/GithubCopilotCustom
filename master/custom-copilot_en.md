# GitHub Copilot Customization Master Reference

> **Purpose of this file:** A reference for AI to automatically generate GitHub Copilot custom configuration files tailored to a project.
> This is not a human-oriented tutorial but a specification document for AI to reference and accurately generate files.
>
> **How to use:** Analyze the project, then generate custom configuration files according to the specifications in this document.

---

## 1. File List and Placement Rules

```
project-root/
├── .github/
│   ├── copilot-instructions.md          # 1.1 Always-on custom instructions
│   ├── copilot-hooks.json               # 1.6 Agent hooks
│   ├── instructions/
│   │   └── *.instructions.md            # 1.2 Scoped instructions (default location)
│   ├── prompts/
│   │   └── *.prompt.md                  # 1.3 Prompt files
│   ├── agents/
│   │   └── *.agent.md                   # 1.4 Custom agents
│   └── skills/
│       └── <skill-name>/
│           ├── SKILL.md                 # 1.5 Agent skills
│           ├── scripts/                 # Skill scripts
│           └── templates/               # Skill templates
├── .vscode/
│   ├── mcp.json                         # 1.7 MCP server configuration
│   └── settings.json                    # 1.8 VS Code settings (Copilot-related)
├── AGENTS.md                            # 1.9 Always-on agent instructions
├── CLAUDE.md                            # 1.10 Claude-compatible instruction file
└── src/
    └── *.instructions.md                # 1.2 Scoped instructions (can be placed anywhere)
```

---

## 1.1 copilot-instructions.md

- **Location:** `.github/copilot-instructions.md`
- **Scope:** Applied to all chat requests and agent mode (not applied to inline suggestions in the editor)
- **Format:** Markdown (no frontmatter)
- **Length:** Keep concise (too long becomes noise; guideline: under 500 lines)

### Content to Include

1. **Tech stack** (languages, frameworks, major libraries and versions)
2. **Coding conventions** (naming rules, formatting, prohibited patterns)
3. **Architecture policy** (directory structure, layering, dependency direction)
4. **Testing policy** (framework, coverage criteria, test naming)
5. **Project-specific reference documents** (link using `[](path)` format)
6. **Prohibitions** (`any` type forbidden, class components forbidden, etc.)

### Template

```markdown
# Project Instructions

## Tech Stack
- Language: {language} {version}
- Framework: {framework} {version}
- Testing: {test_framework}
- Styling: {styling_approach}
- Package Manager: {package_manager}

## Coding Conventions
- {convention_1}
- {convention_2}
- {convention_3}

## Architecture
- {architecture_pattern}
- Directory structure: [](./docs/ARCHITECTURE.md)

## Prohibitions
- {prohibition_1}
- {prohibition_2}

## Testing Policy
- Framework: {test_framework}
- Coverage criteria: {coverage_criteria}
- Test naming: {test_naming_convention}
```

---

## 1.2 *.instructions.md (Scoped Instructions)

- **Location:** `.github/instructions/` (default) or any directory
- **Scope:** Applied to chat requests that operate on files matching the `applyTo` glob pattern
- **Format:** YAML frontmatter + Markdown body
- **Path configuration:** Customize search paths with `chat.instructionsFilesLocations`

### Frontmatter Specification

```yaml
---
name: "Display Name"        # Optional: name shown in UI (defaults to filename)
description: "Description"  # Optional: shown on hover in Chat view
applyTo: "glob-pattern"     # Optional: target file pattern (if omitted, not auto-applied but can be manually attached)
---
```

### applyTo Pattern Examples

| Pattern | Target |
|---------|--------|
| `**/*.ts` | All TypeScript files |
| `**/*.test.ts` | All test files |
| `src/api/**` | All files under src/api |
| `**/*.{ts,tsx}` | All TS/TSX files |
| `*.md` | Markdown files at root only |
| `**/*.css` | All CSS files |

### Template

```markdown
---
name: "{display_name}"
description: "{description}"
applyTo: "{glob_pattern}"
---
- {instruction_1}
- {instruction_2}
- {instruction_3}
```

### Generation Rules

- Consider creating one file per major directory/file type in the project
- Use descriptive file names (e.g., `api-guidelines.instructions.md`, `test-rules.instructions.md`)
- Split by role: testing, API, components, styles, etc.

---

## 1.3 *.prompt.md (Prompt Files)

- **Location:** `.github/prompts/`
- **Invocation:** Type `/filename` (without extension) in chat
- **Format:** YAML frontmatter (optional) + Markdown body
- **Path configuration:** Customize with `chat.promptFilesLocations`

### Frontmatter Specification

```yaml
---
description: "Description text"     # Optional: shown in slash command list
name: "Command name"                # Optional: slash command name (defaults to filename)
tools:                              # Optional: restrict available tools
  - editFiles
  - runInTerminal
  - readFile
  - codebase
agent: "agent"                      # Optional: execution agent (ask/agent/plan/custom agent name)
model: "gpt-4o"                     # Optional: language model
argument-hint: "Hint"               # Optional: hint text in chat input field
---
```

### Available Variables

| Variable | Expands to |
|----------|-----------|
| `${file}` | Full path of the currently open file |
| `${fileBasename}` | File name (with extension) |
| `${fileDirname}` | File's directory path |
| `${fileBasenameNoExtension}` | File name (without extension) |
| `${selection}` / `${selectedText}` | Current text selection |
| `${workspaceFolder}` | Workspace folder path |
| `${workspaceFolderBasename}` | Workspace folder name |
| `${input:variableName}` | Prompts user for input at runtime |

### File References

```markdown
See:
[](../../path/to/file.md)
```

Use `[]()` format to attach project files as context.

### Template

```markdown
---
description: "{description}"
tools:
  - {tool_1}
  - {tool_2}
---
# {task_title}

Target: ${file}

{task_instructions}
```

### Commonly Created Prompt Files

| File Name | Purpose |
|-----------|---------|
| `review.prompt.md` | Code review |
| `test.prompt.md` | Test generation |
| `refactor.prompt.md` | Refactoring |
| `doc.prompt.md` | Documentation generation |
| `commit.prompt.md` | Commit message generation |
| `migrate.prompt.md` | Library migration |
| `debug.prompt.md` | Debug assistance |
| `security.prompt.md` | Security check |

---

## 1.4 *.agent.md (Custom Agents)

- **Location:** `.github/agents/`
- **Invocation:** Select from Agents dropdown in Chat, or mention with `@filename`
- **Format:** YAML frontmatter + Markdown body (persona & instructions)
- **Path configuration:** Customize with `chat.agentFilesLocations`

### Frontmatter Specification

```yaml
---
# Basic
tools:                              # Optional: array of available tools (string list of tool names)
  - editFiles
  - runInTerminal
  - readFile
  - codebase
description: "Agent description"    # Optional: shown in agent list
name: "Display name"                # Optional: display name different from filename
model: "gpt-4o"                     # Optional: specify model (string or prioritized array)

# Agent-to-agent collaboration
handoffs:                           # Optional: handoff targets
  - label: "Button label"           # Display text on handoff button
    agent: agent-name               # Target agent identifier
    prompt: "Prompt text"           # Prompt to send to target agent
    send: false                     # Optional: auto-submit prompt (default: false)
    model: "GPT-5 (copilot)"        # Optional: model for handoff execution
agents:                             # Optional: sub-agents (* to allow all)
  - sub-agent-1

# MCP integration
mcp-servers:                        # Optional: MCP servers to use
  - server-name

# Advanced settings
argument-hint: "Specify review target"  # Optional: hint text at invocation
user-invokable: true                    # Optional: can user invoke directly (default: true)
disable-model-invocation: false         # Optional: disable automatic model invocation (default: false)
target: "vscode"                        # Optional: target mode (vscode / github-copilot)
---
```

### Body Structure

```markdown
# Your Role
{persona_description}

# Rules
- {rule_1}
- {rule_2}

# Workflow
1. {step_1}
2. {step_2}
3. {step_3}

# Output Format
{output_format_description}
```

### Template

```markdown
---
tools:
  - {tool_1}
  - {tool_2}
description: "{description}"
handoffs:
  - label: "{handoff_label}"
    agent: {handoff_agent_1}
    prompt: "{handoff_prompt}"
---

# Your Role
You are {role_description}.

# Rules
- {rule_1}
- {rule_2}
- {rule_3}

# Workflow
1. {workflow_step_1}
2. {workflow_step_2}
3. {workflow_step_3}

# Output Format
- {output_format}
```

### Built-in Tools Reference

> **Tip:** Type `#` in the chat input field to see a list of all available tools.

#### File Operations

| Tool Name | Function |
|-----------|----------|
| `editFiles` | Apply edits to files in the workspace |
| `createFile` | Create a new file |
| `readFile` | Read file content |
| `listDirectory` | List files in a directory |
| `createDirectory` | Create a new directory |
| `fileSearch` | Search for files using glob patterns |
| `textSearch` | Find text in files |

#### Terminal & Tasks

| Tool Name | Function |
|-----------|----------|
| `runInTerminal` | Run a shell command in the integrated terminal |
| `getTerminalOutput` | Get terminal command output |
| `terminalLastCommand` | Get the last terminal command and its output |
| `terminalSelection` | Get the current terminal selection |
| `runTask` | Run an existing task |
| `createAndRunTask` | Create and run a new task |
| `getTaskOutput` | Get task output |

#### Search & Context

| Tool Name | Function |
|-----------|----------|
| `codebase` | Search code in the workspace |
| `searchResults` | Get results from the Search view |
| `usages` | Find All References / Find Implementation / Go to Definition |
| `problems` | Get errors and warnings from the Problems panel |
| `selection` | Get the current editor selection |
| `changes` | Get the list of source control changes |

#### External Integration

| Tool Name | Function |
|-----------|----------|
| `fetch` | Fetch web page content |
| `githubRepo` | Search code in a GitHub repository |
| `extensions` | Search for VS Code extensions |
| `installExtension` | Install a VS Code extension |

#### Testing

| Tool Name | Function |
|-----------|----------|
| `runTests` | Run unit tests |
| `testFailure` | Get test failure information |

#### Notebooks

| Tool Name | Function |
|-----------|----------|
| `editNotebook` | Edit a notebook |
| `getNotebookSummary` | Get the list of notebook cells |
| `readNotebookCellOutput` | Read notebook cell output |
| `runCell` | Run a notebook cell |

#### VS Code Operations

| Tool Name | Function |
|-----------|----------|
| `runVscodeCommand` | Run a VS Code command |
| `openSimpleBrowser` | Preview a locally-deployed web app |
| `VSCodeAPI` | Ask about VS Code functionality and extension development |

#### Scaffolding

| Tool Name | Function |
|-----------|----------|
| `new` | Scaffold a new workspace |
| `newWorkspace` | Create a new workspace |
| `newJupyterNotebook` | Scaffold a new Jupyter notebook |
| `getProjectSetupInfo` | Get project setup instructions and configuration |

#### Other

| Tool Name | Function |
|-----------|----------|
| `runSubagent` | Run a task in an isolated subagent context |
| `todos` | Track implementation progress with a todo list |

#### Tool Sets (Groups of Tools)

| Tool Set Name | Function |
|---------------|----------|
| `edit` | Enable modification tools |
| `search` | Enable file search tools |
| `runCommands` | Enable terminal command tools |
| `runNotebooks` | Enable notebook execution tools |
| `runTasks` | Enable task execution tools |

> **Reference:** [Use tools with agents](https://code.visualstudio.com/docs/copilot/agents/agent-tools) / [Cheat sheet - Chat tools](https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features#_chat-tools)

---

## 1.5 SKILL.md (Agent Skills)

- **Location:** `.github/skills/<skill-name>/SKILL.md`
- **Path configuration:** Customize with `chat.agentSkillsLocations`
- **Invocation:** Agent uses the skill / `/skill-name` slash command

### Directory Structure

```
.github/skills/<skill-name>/
├── SKILL.md          # Skill definition (required)
├── scripts/          # Execution scripts (optional)
│   └── run.sh
├── templates/        # Templates (optional)
│   └── template.yaml
└── resources/        # Resources (optional)
    └── schema.json
```

### SKILL.md Frontmatter

```yaml
---
name: "Skill name"
description: "Skill description"
---
```

### Template

```markdown
---
name: "{skill_name}"
description: "{skill_description}"
---
# {skill_title}

{skill_instructions}

## Scripts
- `scripts/{script_name}` - {script_description}

## Templates
- `templates/{template_name}` - {template_description}
```

---

## 1.6 copilot-hooks.json (Agent Hooks)

- **Location:** `.github/copilot-hooks.json`
- **Function:** Bind shell commands to agent lifecycle events
- **Note:** Preview feature. Can be disabled by organization policy.

### JSON Structure

```jsonc
{
  "hooks": {
    "EventName": [
      {
        "type": "command",           // Required: fixed "command"
        "command": "shell command",  // Required: command to execute
        "timeout": 30,               // Optional: timeout in seconds
        "cwd": "working directory",  // Optional: working directory
        "env": {                     // Optional: environment variables
          "KEY": "value"
        },
        "windows": {                 // Optional: Windows-specific override
          "command": "windows-cmd"
        },
        "linux": {                   // Optional: Linux-specific override
          "command": "linux-cmd"
        },
        "osx": {                     // Optional: macOS-specific override
          "command": "osx-cmd"
        }
      }
    ]
  }
}
```

### Hook Events

| Event | Timing | Use Case |
|-------|--------|----------|
| `SessionStart` | Session start | Environment check, dependency verification |
| `UserPromptSubmit` | User submission | Input validation |
| `PreToolUse` | Before tool execution | Block dangerous operations |
| `PostToolUse` | After tool execution | Auto-run lint / tests |
| `PreCompact` | Before context compaction | Save important information |
| `SubagentStart` | Sub-agent start | Logging |
| `SubagentStop` | Sub-agent end | Result verification |
| `Stop` | Session end | Cleanup |

### PreToolUse Permission Control

`PreToolUse` hooks can control tool execution by outputting JSON to stdout:

```json
{"permissionDecision": "allow"}
```

| Value | Behavior |
|-------|----------|
| `"allow"` | Allow tool execution |
| `"deny"` | Deny tool execution |
| `"ask"` | Ask user for confirmation |

### Command Arguments

Hook commands automatically receive arguments (e.g., `--tool-name`, `--tool-call-id`).

### Template

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "type": "command",
        "command": "{post_tool_command}",
        "timeout": {timeout_seconds}
      }
    ],
    "SessionStart": [
      {
        "type": "command",
        "command": "{session_start_command}",
        "timeout": {timeout_seconds}
      }
    ]
  }
}
```

---

## 1.7 mcp.json (MCP Server Configuration)

- **Location:** `.vscode/mcp.json`
- **Function:** Provide external tools, APIs, and databases to Copilot

### JSON Structure

```jsonc
{
  "servers": {
    "server-name": {
      // stdio transport (local process)
      "type": "stdio",
      "command": "executable",
      "args": ["arg1", "arg2"],
      "env": {
        "ENV_VAR": "${input:input-id}"
      }
    },
    "server-name-2": {
      // HTTP transport (remote)
      "type": "http",
      "url": "https://example.com/mcp"
    },
    "server-name-3": {
      // SSE transport
      "type": "sse",
      "url": "https://example.com/sse"
    }
  },
  "inputs": [
    {
      "id": "input-id",
      "type": "promptString",
      "description": "Input description",
      "password": true
    }
  ]
}
```

### Transport Types

| Type | Use Case | Required Fields |
|------|----------|----------------|
| `stdio` | Local process (most common) | `command`, `args` |
| `http` | Remote HTTP server | `url` |
| `sse` | Server-Sent Events | `url` |

### Commonly Used MCP Servers

| Package | Purpose |
|---------|---------|
| `@modelcontextprotocol/server-github` | GitHub operations |
| `@modelcontextprotocol/server-filesystem` | File system |
| `@modelcontextprotocol/server-postgres` | PostgreSQL |
| `@modelcontextprotocol/server-sqlite` | SQLite |
| `@modelcontextprotocol/server-brave-search` | Web search |

### Template

```jsonc
{
  "servers": {
    "{server_name}": {
      "type": "stdio",
      "command": "{command}",
      "args": ["{arg1}", "{arg2}"],
      "env": {
        "{ENV_KEY}": "${input:{input_id}}"
      }
    }
  },
  "inputs": [
    {
      "id": "{input_id}",
      "type": "promptString",
      "description": "{description}",
      "password": {is_password}
    }
  ]
}
```

---

## 1.8 VS Code Settings (Key Copilot-Related Settings)

Copilot customization settings in `settings.json`:

```jsonc
{
  // Search paths for custom instruction files
  "chat.instructionsFilesLocations": [
    { ".github/instructions": "**" }
  ],

  // Search paths for prompt files
  "chat.promptFilesLocations": [
    { ".github/prompts": "**" }
  ],

  // Search paths for custom agents
  "chat.agentFilesLocations": [
    { ".github/agents": "**" }
  ],

  // Search paths for agent skills
  "chat.agentSkillsLocations": [
    { ".github/skills": "**" }
  ],

  // Tool auto-approval
  "chat.tools.global.autoApprove": false,            // All tools (default: false)
  "chat.tools.terminal.autoApprove": false,           // Terminal commands
  "chat.tools.urls.autoApprove": false,               // URL fetching
  "chat.tools.edits.autoApprove": false,              // File editing

  // Agent settings
  "chat.agent.enabled": true,
  "chat.agent.maxRequests": 30
}
```

---

## 1.9 AGENTS.md

- **Location:** Project root (or any directory)
- **Scope:** Auto-detected by VS Code, **always applied to all chat requests**
- **Format:** Markdown (no frontmatter)
- **Purpose:** Additional instructions used alongside copilot-instructions.md

### Template

```markdown
# Agent Rules

## Code Change Rules
- {rule_1}
- {rule_2}

## Commit Rules
- {commit_rule_1}
- {commit_rule_2}

## Prohibitions
- {prohibition_1}
- {prohibition_2}
```

---

## 1.10 CLAUDE.md

- **Location:** Project root (or any directory)
- **Scope:** Same as AGENTS.md, always applied to all chat requests
- **Format:** Markdown
- **Purpose:** Claude-compatible instructions (`.claude/rules`, `.claude/agents`, `.claude/skills` folders also supported)

---

## 2. Generation Strategy Guidelines

### 2.1 Project Analysis → File Generation Flow

1. **Understand project structure**
   - Identify languages, frameworks, and major libraries
   - Understand directory structure and layering
   - Check existing config files (`package.json`, `tsconfig.json`, `.eslintrc`, etc.)

2. **Minimum files to generate**
   - `.github/copilot-instructions.md` (required: project-wide instructions)
   - `.github/prompts/review.prompt.md` (recommended: code review)
   - `.github/prompts/test.prompt.md` (recommended: test generation)

3. **Additional files by project scale**

| Scale | Additional Files |
|-------|-----------------|
| Small (~10 files) | copilot-instructions.md alone is sufficient |
| Medium (~100 files) | + .instructions.md (2-3 files) + prompts (2-3 files) |
| Large (100+ files) | + custom agents + skills + hooks + MCP |

### 2.2 File Naming Conventions

| File Type | Naming Pattern | Example |
|-----------|---------------|---------|
| `*.instructions.md` | `{scope}-{purpose}.instructions.md` | `api-guidelines.instructions.md` |
| `*.prompt.md` | `{action}.prompt.md` | `review.prompt.md` |
| `*.agent.md` | `{role}.agent.md` | `reviewer.agent.md` |
| `SKILL.md` | Directory name as identifier | `.github/skills/deploy/SKILL.md` |

### 2.3 Quality Checklist

Items to verify during generation:

- [ ] Does copilot-instructions.md specify the tech stack?
- [ ] Does copilot-instructions.md include prohibitions?
- [ ] Are .instructions.md applyTo patterns valid glob syntax?
- [ ] Do .prompt.md variables only use officially supported ones? (see variable list above)
- [ ] Are .agent.md frontmatter field names correct?
- [ ] Do .agent.md tools only reference existing tool names?
- [ ] Is copilot-hooks.json structured as `hooks > EventName > array`?
- [ ] Is mcp.json structured as `servers > ServerName > config`?
- [ ] Are files placed in the correct locations (especially default paths)?

---

## 3. Official Documentation URLs

| Topic | URL |
|-------|-----|
| Customization overview | https://code.visualstudio.com/docs/copilot/customization/overview |
| Custom instructions | https://code.visualstudio.com/docs/copilot/customization/custom-instructions |
| Prompt files | https://code.visualstudio.com/docs/copilot/customization/prompt-files |
| Custom agents | https://code.visualstudio.com/docs/copilot/customization/custom-agents |
| Agent skills | https://code.visualstudio.com/docs/copilot/customization/agent-skills |
| MCP servers | https://code.visualstudio.com/docs/copilot/customization/mcp-servers |
| Hooks | https://code.visualstudio.com/docs/copilot/customization/hooks |
| Language models | https://code.visualstudio.com/docs/copilot/customization/language-models |
| Settings reference | https://code.visualstudio.com/docs/copilot/reference/copilot-settings |
| Cheat sheet | https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features |
| Context engineering | https://code.visualstudio.com/docs/copilot/guides/context-engineering-guide |
| TDD flow | https://code.visualstudio.com/docs/copilot/guides/test-driven-development-guide |

---

## 4. Practical Example: TypeScript + React Project

Below is a full configuration example. Select and adapt based on your actual project needs.

### .github/copilot-instructions.md

```markdown
# Project Instructions

## Tech Stack
- TypeScript 5.x + React 18
- Build: Vite
- Testing: Vitest + React Testing Library
- Styling: Tailwind CSS
- State Management: Zustand
- API Communication: TanStack Query

## Coding Conventions
- Use functional components only (class components prohibited)
- `any` type prohibited (use `unknown` + type guards)
- Isolate side effects in Custom Hooks
- Use Result type pattern for error handling

## Naming Conventions
- Components: PascalCase
- Functions/variables: camelCase
- Constants: UPPER_SNAKE_CASE
- File names: kebab-case.ts / kebab-case.tsx

## Directory Structure
- `src/components/` - UI components
- `src/hooks/` - Custom hooks
- `src/stores/` - State management
- `src/api/` - API communication layer
- `src/types/` - Type definitions
- `src/utils/` - Utilities
```

### .github/instructions/test-rules.instructions.md

```markdown
---
applyTo: "**/*.test.{ts,tsx}"
---
- Write tests using the AAA pattern (Arrange / Act / Assert)
- Use descriptive test names (e.g., `it('increments count on button click')`)
- Use vi.mock() for mocking
- Use waitFor / findBy for async tests
- Minimize snapshot tests (prioritize logic tests)
```

### .github/instructions/api-layer.instructions.md

```markdown
---
applyTo: "src/api/**"
---
- Expose API functions as TanStack Query custom hooks
- Convert error responses to AppError type
- Define and validate request/response types with Zod schemas
- Get BASE_URL from environment variables (no hardcoding)
```

### .github/prompts/review.prompt.md

```markdown
---
description: "Code review (bugs, performance, readability, security)"
tools:
  - readFile
  - codebase
---
Review ${file} from these perspectives:

1. **Bug Risk**: null/undefined, boundary values, race conditions
2. **Performance**: unnecessary re-renders, memory leaks
3. **Readability**: naming, function length, nesting depth
4. **Security**: XSS, hardcoded secrets

**Output format:**
- 🔴 Critical / 🟡 Warning / 🔵 Info
- Location, reason, fix suggestion
```

### .github/prompts/test.prompt.md

```markdown
---
description: "Generate test file"
tools:
  - editFiles
  - readFile
  - runInTerminal
---
Generate tests for ${file}.

Rules:
- Use Vitest + React Testing Library
- Write in AAA pattern (Arrange / Act / Assert)
- Cover normal cases, error cases, and edge cases
- Use descriptive test names
- Mock: use vi.mock() for all external dependencies

After generation, run `npx vitest run ${fileBasenameNoExtension}` to verify the results.
```

### .github/agents/reviewer.agent.md

```markdown
---
tools:
  - readFile
  - codebase
  - usages
description: "Code review specialist agent"
---

# Your Role
You are a senior code reviewer with deep expertise in TypeScript/React best practices.

# Rules
- Rate issues by severity: 🔴 Critical / 🟡 Warning / 🔵 Info
- Always include a fix suggestion with each issue
- Mention at least one positive aspect
- Verify compliance with project conventions (copilot-instructions.md)

# Review Perspectives
1. Bug risk (null safety, boundary values, race conditions)
2. Performance (unnecessary computation, memory leaks, re-renders)
3. Maintainability (SOLID principles, DRY, naming)
4. Security (input validation, authentication/authorization)
5. Testability (dependency injection, side effect isolation)
```

### .github/copilot-hooks.json

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "type": "command",
        "command": "npx eslint --fix --no-error-on-unmatched-pattern .",
        "timeout": 30
      }
    ],
    "SessionStart": [
      {
        "type": "command",
        "command": "node --version && npm --version",
        "timeout": 10
      }
    ]
  }
}
```

---

> **Disclaimer**: This is the first edition based on VS Code official documentation (as of July 2025). Content has been reviewed by both AI and humans, but please refer to the official documentation for the latest information.
