# <font style="color:rgb(18, 19, 23);">Agent Skills</font>
<font style="color:rgb(18, 19, 23);">Skills are an</font><font style="color:rgb(18, 19, 23);"> </font>[<font style="color:rgb(18, 19, 23);">open standard</font>](https://agentskills.io/home)<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">for extending agent capabilities. A skill is a folder containing a</font><font style="color:rgb(18, 19, 23);"> </font>`<font style="color:rgb(18, 19, 23);">SKILL.md</font>`<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">file with instructions that the agent can follow when working on specific tasks.</font>

## <font style="color:rgb(18, 19, 23);">What are skills?</font>
<font style="color:rgb(18, 19, 23);">Skills are reusable packages of knowledge that extend what the agent can do. Each skill contains:</font>

+ **<font style="color:rgb(18, 19, 23);">Instructions</font>**<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">for how to approach a specific type of task</font>
+ **<font style="color:rgb(18, 19, 23);">Best practices</font>**<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">and conventions to follow</font>
+ **<font style="color:rgb(18, 19, 23);">Optional scripts and resources</font>**<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">the agent can use</font>

<font style="color:rgb(18, 19, 23);">When you start a conversation, the agent sees a list of available skills with their names and descriptions. If a skill looks relevant to your task, the agent reads the full instructions and follows them.</font>

## <font style="color:rgb(18, 19, 23);">Where skills live</font>
<font style="color:rgb(18, 19, 23);">Antigravity supports two types of skills:</font>

| **<font style="color:rgb(18, 19, 23);">Location</font>** | **<font style="color:rgb(18, 19, 23);">Scope</font>** |
| :--- | :--- |
| `<font style="color:rgb(18, 19, 23);"><workspace-root>/.agents/skills/<skill-folder>/</font>` | <font style="color:rgb(18, 19, 23);">Workspace-specific</font> |
| `<font style="color:rgb(18, 19, 23);">~/.gemini/antigravity/skills/<skill-folder>/</font>` | <font style="color:rgb(18, 19, 23);">Global (all workspaces)</font> |


**<font style="color:rgb(18, 19, 23);">Workspace skills</font>**<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">are great for project-specific workflows, like your team's deployment process or testing conventions.</font>

**<font style="color:rgb(18, 19, 23);">Global skills</font>**<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">work across all your projects. Use these for personal utilities or general-purpose tools you want everywhere.</font>

<font style="color:rgb(18, 19, 23);">Note: Antigravity now defaults to .agents/skills, but still maintains backward support for .agent/skills.</font>

## <font style="color:rgb(18, 19, 23);">Creating a skill</font>
<font style="color:rgb(18, 19, 23);">To create a skill:</font>

1. <font style="color:rgb(18, 19, 23);">Create a folder for your skill in one of the skill directories</font>
2. <font style="color:rgb(18, 19, 23);">Add a</font><font style="color:rgb(18, 19, 23);"> </font>`<font style="color:rgb(18, 19, 23);">SKILL.md</font>`<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">file inside that folder</font>

```plain
.agents/skills/
└─── my-skill/
    └─── SKILL.md
```

<font style="color:rgb(18, 19, 23);">Every skill needs a</font><font style="color:rgb(18, 19, 23);"> </font>`<font style="color:rgb(18, 19, 23);">SKILL.md</font>`<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">file with YAML frontmatter at the top:</font>

```plain
---
name: my-skill
description: Helps with a specific task. Use when you need to do X or Y.
---

# My Skill

Detailed instructions for the agent go here.

## When to use this skill

- Use this when...
- This is helpful for...

## How to use it

Step-by-step guidance, conventions, and patterns the agent should follow.
```

### <font style="color:rgb(18, 19, 23);">Frontmatter fields</font>
| **<font style="color:rgb(18, 19, 23);">Field</font>** | **<font style="color:rgb(18, 19, 23);">Required</font>** | **<font style="color:rgb(18, 19, 23);">Description</font>** |
| :--- | :--- | :--- |
| `<font style="color:rgb(18, 19, 23);">name</font>` | <font style="color:rgb(18, 19, 23);">No</font> | <font style="color:rgb(18, 19, 23);">A unique identifier for the skill (lowercase, hyphens for spaces). Defaults to the folder name if not provided.</font> |
| `<font style="color:rgb(18, 19, 23);">description</font>` | <font style="color:rgb(18, 19, 23);">Yes</font> | <font style="color:rgb(18, 19, 23);">A clear description of what the skill does and when to use it. This is what the agent sees when deciding whether to apply the skill.</font> |


<font style="color:rgb(18, 19, 23);">Tip: Write your description in third person and include keywords that help the agent recognize when the skill is relevant. For example: "Generates unit tests for Python code using pytest conventions."</font>

## <font style="color:rgb(18, 19, 23);">Skill folder structure</font>
<font style="color:rgb(18, 19, 23);">While</font><font style="color:rgb(18, 19, 23);"> </font>`<font style="color:rgb(18, 19, 23);">SKILL.md</font>`<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">is the only required file, you can include additional resources:</font>

```plain
.agents/skills/my-skill/
├─── SKILL.md       # Main instructions (required)
├─── scripts/       # Helper scripts (optional)
├─── examples/      # Reference implementations (optional)
└─── resources/     # Templates and other assets (optional)
```

<font style="color:rgb(18, 19, 23);">The agent can read these files when following your skill's instructions.</font>

## <font style="color:rgb(18, 19, 23);">How the agent uses skills</font>
<font style="color:rgb(18, 19, 23);">Skills follow a</font><font style="color:rgb(18, 19, 23);"> </font>**<font style="color:rgb(18, 19, 23);">progressive disclosure</font>**<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">pattern:</font>

1. **<font style="color:rgb(18, 19, 23);">Discovery</font>**<font style="color:rgb(18, 19, 23);">:</font><font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">When a conversation starts, the agent sees a list of available skills with their names and descriptions</font>
2. **<font style="color:rgb(18, 19, 23);">Activation</font>**<font style="color:rgb(18, 19, 23);">:</font><font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">If a skill looks relevant to your task, the agent reads the full</font><font style="color:rgb(18, 19, 23);"> </font>`<font style="color:rgb(18, 19, 23);">SKILL.md</font>`<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">content</font>
3. **<font style="color:rgb(18, 19, 23);">Execution</font>**<font style="color:rgb(18, 19, 23);">:</font><font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">The agent follows the skill's instructions while working on your task</font>

<font style="color:rgb(18, 19, 23);">You don't need to explicitly tell the agent to use a skill—it decides based on context. However, you can mention a skill by name if you want to ensure it's used.</font>

## <font style="color:rgb(18, 19, 23);">Best practices</font>
### <font style="color:rgb(18, 19, 23);">Keep skills focused</font>
<font style="color:rgb(18, 19, 23);">Each skill should do one thing well. Instead of a "do everything" skill, create separate skills for distinct tasks.</font>

### <font style="color:rgb(18, 19, 23);">Write clear descriptions</font>
<font style="color:rgb(18, 19, 23);">The description is how the agent decides whether to use your skill. Make it specific about what the skill does and when it's useful.</font>

### <font style="color:rgb(18, 19, 23);">Use scripts as black boxes</font>
<font style="color:rgb(18, 19, 23);">If your skill includes scripts, encourage the agent to run them with</font><font style="color:rgb(18, 19, 23);"> </font>`<font style="color:rgb(18, 19, 23);">--help</font>`<font style="color:rgb(18, 19, 23);"> </font><font style="color:rgb(18, 19, 23);">first rather than reading the entire source code. This keeps the agent's context focused on the task.</font>

### <font style="color:rgb(18, 19, 23);">Include decision trees</font>
<font style="color:rgb(18, 19, 23);">For complex skills, add a section that helps the agent choose the right approach based on the situation.</font>

## <font style="color:rgb(18, 19, 23);">Example: A code review skill</font>
<font style="color:rgb(18, 19, 23);">Here's a simple skill that helps the agent review code:</font>

```plain
---
name: code-review
description: Reviews code changes for bugs, style issues, and best practices. Use when reviewing PRs or checking code quality.
---

# Code Review Skill

When reviewing code, follow these steps:

## Review checklist

1. **Correctness**: Does the code do what it's supposed to?
2. **Edge cases**: Are error conditions handled?
3. **Style**: Does it follow project conventions?
4. **Performance**: Are there obvious inefficiencies?

## How to provide feedback

- Be specific about what needs to change
- Explain why, not just what
- Suggest alternatives when possible
```

