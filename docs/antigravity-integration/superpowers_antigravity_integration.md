# Superpowers × Antigravity：深度集成架构设计

**状态**：架构设计阶段 v1.0  
**目标受众**：Antigravity 核心工程团队、Superpowers 社区维护者  
**关键决策点**：Skills → Tools 映射、Artifacts 生命周期管理、Subagent 编排  

---

## 执行摘要

### 整合的核心价值主张

**Superpowers** 提供：严谨的工程工作流（Brainstorming → Planning → TDD-Driven Execution）  
**Antigravity** 提供：多界面协调、异步 Agent、Artifact 管理  

**整合目标**：
- 将 Superpowers 的 18+ 个 Skills（声明式 Markdown 工作流）映射为 Antigravity Tools（可调用的实体）
- 在 Antigravity 的 Agent Manager 中以**可视化 Artifacts** 形式展现 Superpowers 的设计文档、计划、和执行跟踪
- 利用 Antigravity 的异步 Agent 能力，实现 Superpowers 的 subagent-driven-development（并行子任务执行）
- 保持 Superpowers 的 TDD 哲学，在 Antigravity 的 Browser 和 Editor 中强制测试优先执行

### 整合的三大支柱

```
┌─────────────────────────────────────────────────────────────────┐
│                    Antigravity 三大界面                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │     Editor     │  │    Browser   │  │  Agent Manager   │   │
│  │   (编码实现)   │  │   (验证测试) │  │  (工作流编排)    │   │
│  └────────────────┘  └──────────────┘  └──────────────────┘   │
│         ↑                   ↑                     ↑             │
│         └───────────────────┴─────────────────────┘             │
│                      信息流向                                    │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│               Superpowers Skills → Antigravity Tools             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  [Skill 1] brainstorming                                 │  │
│  │  → Tool: plan_spec_artifact (生成设计文档)              │  │
│  │  → Artifact Type: markdown (spec)                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  [Skill 2] writing-plans                                 │  │
│  │  → Tool: create_implementation_plan (分解任务)           │  │
│  │  → Artifact Type: implementation-plan (JSON + Markdown) │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  [Skill 3-4] test-driven-development +                   │  │
│  │              subagent-driven-development                  │  │
│  │  → Tool: dispatch_task_subagent (启动子任务代理)         │  │
│  │  → Artifact Type: task-execution-log (追踪执行)          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 第一部分：Skills → Tools 映射体系

### 1.1 映射框架设计

#### 核心概念

**Superpowers Skill**（声明式）
```yaml
---
title: "Brainstorming"
description: "Refines rough ideas through questions..."
trigger: "design.*|architecture|spec|plan"
when: "Before writing code"
next-skills: ["writing-plans", "using-git-worktrees"]
---
# Skill Content (Markdown instructions)
```

**Antigravity Tool**（可调用）
```typescript
interface AntigravityTool {
  id: string;                          // "superpowers:brainstorming"
  name: string;                        // "Plan Design Artifact"
  skill_source: string;                // "obra/superpowers-skills"
  trigger_pattern: RegExp;             // from skill.trigger
  phase: "planning" | "execution" | "review";
  
  // Tool invocation
  invoke(context: ToolContext): Promise<Artifact>;
  
  // Artifact binding
  artifact_template: ArtifactTemplate;
  
  // Agent coordination
  next_tools?: string[];               // from skill.next-skills
  requires_human_approval?: boolean;
}
```

#### 映射的四个层级

```
Level 1: Metadata Mapping (元数据映射)
  Skill frontmatter → Tool registry entry
  
Level 2: Invocation Mapping (调用映射)
  Tool.invoke() → Skill execution in agent context
  
Level 3: Artifact Mapping (产物映射)
  Skill outputs → Typed Artifacts in Manager view
  
Level 4: Orchestration Mapping (编排映射)
  next-skills chain → Tool dispatch sequence + human gates
```

### 1.2 Skills 到 Tools 的分类映射

#### 分类 A：规划工具（Planning Tools）

| Superpowers Skill | Antigravity Tool | Artifact 产物 | 触发时机 |
|---|---|---|---|
| `brainstorming` | `superpowers:design_spec` | `DesignSpecArtifact` (MD) | 新特性开始 |
| `writing-plans` | `superpowers:implementation_plan` | `PlanArtifact` (JSON + MD) | 设计审批后 |
| `breaking-down-system-design` | `superpowers:architecture_graph` | `ArchitectureArtifact` (Mermaid) | 架构复杂度高 |

#### 分类 B：协作工具（Collaboration Tools）

| Superpowers Skill | Antigravity Tool | Artifact 产物 | 触发时机 |
|---|---|---|---|
| `using-git-worktrees` | `superpowers:setup_isolated_workspace` | `WorkspaceSetupArtifact` | 计划审批后 |
| `dispatching-parallel-agents` | `superpowers:dispatch_subagents` | `SubagentDispatchLog` | 任务队列就绪 |
| `subagent-driven-development` | `superpowers:execute_with_review` | `ExecutionLogArtifact` | 子任务执行 |

#### 分类 C：执行工具（Execution Tools）

| Superpowers Skill | Antigravity Tool | Artifact 产物 | 触发时机 |
|---|---|---|---|
| `test-driven-development` | `superpowers:tdd_cycle` | `TestExecutionLog` | 每个任务内 |
| `systematic-debugging` | `superpowers:debug_session` | `DebugTranscript` | 失败恢复 |
| `verification-before-completion` | `superpowers:verify_completion` | `VerificationReport` | 任务完成前 |

#### 分类 D：审查工具（Review Tools）

| Superpowers Skill | Antigravity Tool | Artifact 产物 | 触发时机 |
|---|---|---|---|
| `requesting-code-review` | `superpowers:code_review_gate` | `ReviewChecklist` | 任务完成时 |
| `receiving-code-review` | `superpowers:feedback_integration` | `ReviewFeedback` | 反馈到达时 |
| `finishing-a-development-branch` | `superpowers:branch_completion` | `MergeDecisionArtifact` | 所有任务完成 |

### 1.3 工具注册与发现机制

#### 注册架构

```javascript
// File: ~/.antigravity/tools/superpowers-registry.json
{
  "source": "obra/superpowers-skills",
  "version": "5.0.6",
  "tools": [
    {
      "id": "superpowers:design_spec",
      "name": "Design Specification",
      "skill_path": "skills/collaboration/brainstorming/SKILL.md",
      
      // Metadata from SKILL.yaml
      "trigger_pattern": "design.*|architecture|spec|plan",
      "description": "Refines rough ideas through questions...",
      "phase": "planning",
      
      // Tool configuration
      "artifact_type": "design-spec",
      "requires_approval": true,
      "estimated_duration_minutes": 15,
      
      // Next tools in the chain
      "next_tools": [
        "superpowers:implementation_plan",
        "superpowers:setup_isolated_workspace"
      ],
      
      // Invocation behavior
      "invocation": {
        "mode": "agentic",                    // Agent 自主调用
        "context_requirements": [
          "project_type",
          "user_goals",
          "constraints"
        ],
        "output_schema": "DesignSpecArtifact"
      }
    },
    // ... 更多工具
  ]
}
```

#### 发现流程（Antigravity Editor 启动）

```
1. Session Start Hook
   ↓
2. Load superpowers-registry.json
   ↓
3. For each tool:
   - Parse trigger_pattern as RegExp
   - Register with Editor's tool dispatcher
   - Cache artifact_type mappings
   ↓
4. On user message:
   - Match against all trigger_patterns
   - If match → Tool becomes available in context
   - Agent can invoke via superpowers:tool-id
   ↓
5. Tool invocation:
   - Load corresponding SKILL.md
   - Execute skill instructions with agent context
   - Generate artifact per artifact_type schema
   ↓
6. Artifact Creation:
   - Artifact sent to Manager view
   - Awaits human gate (if requires_approval=true)
   - Chains to next_tools
```

---

## 第二部分：Artifacts 生命周期与 Manager 视图集成

### 2.1 Artifact 类型系统设计

#### 基础架构

```typescript
interface ArtifactBase {
  id: string;                          // UUID
  type: ArtifactType;                  // discriminator
  source_tool: string;                 // "superpowers:brainstorming"
  timestamp: ISO8601;
  status: "draft" | "pending_review" | "approved" | "in_progress" | "completed" | "blocked";
  
  // Lineage tracking
  parent_artifact_id?: string;         // e.g., spec → plan
  blocking_artifacts?: string[];       // e.g., spec blocks plan execution
  
  // Human interaction
  human_approval_required: boolean;
  approval_deadline?: ISO8601;
  approved_by?: string;
  approval_notes?: string;
}
```

#### 核心 Artifact 类型定义

##### Type 1: DesignSpecArtifact

```typescript
interface DesignSpecArtifact extends ArtifactBase {
  type: "design-spec";
  
  content: {
    // Section 1: Problem statement
    problem_context: {
      user_goals: string[];
      constraints: string[];
      success_criteria: string[];
    };
    
    // Section 2: Design options (from brainstorming)
    design_options: Array<{
      name: string;
      description: string;
      trade_offs: string[];
      recommendation_score: 0-100;
    }>;
    
    // Section 3: Chosen architecture
    chosen_design: {
      architecture: string;            // Mermaid/ASCII diagram as string
      rationale: string;
      key_components: string[];
      data_flow: string[];
    };
    
    // Section 4: Open questions
    open_questions?: Array<{
      question: string;
      impact: "blocker" | "important" | "nice-to-have";
    }>;
  };
  
  // Manager view rendering
  render_format: "markdown";           // Frontend renders from markdown
  section_count: number;               // For progressive disclosure in UI
  estimated_tokens: number;            // For token budget tracking
}
```

##### Type 2: PlanArtifact

```typescript
interface PlanArtifact extends ArtifactBase {
  type: "implementation-plan";
  
  content: {
    // Metadata
    derived_from_spec: string;         // reference to DesignSpecArtifact.id
    total_tasks: number;
    estimated_total_duration_minutes: number;
    
    // Task breakdown
    tasks: Array<{
      id: string;                      // "TASK-001"
      sequence: number;                // execution order
      title: string;
      description: string;
      
      // Task specifics (from writing-plans skill)
      file_paths: string[];            // Exact files to modify
      dependencies: string[];          // Task IDs that must complete first
      estimated_duration_minutes: 2-5; // Superpowers constraint
      
      // Success criteria
      implementation_steps: Array<{
        step: number;
        action: string;
        verification: string;          // How to verify this step
      }>;
      
      // Code sketch (not final)
      code_sketch?: string;            // Pseudo-code or outline
      
      // Testing strategy
      test_requirements: {
        test_file: string;
        test_cases: string[];
        coverage_target: number;       // percentage
      };
      
      // Assigned to
      assigned_subagent?: string;      // Can be null initially
      status: "pending" | "assigned" | "in_progress" | "completed" | "failed";
    }>;
    
    // Verification checklist
    verification_checklist: Array<{
      category: "unit_tests" | "integration" | "style" | "performance";
      items: string[];
    }>;
  };
  
  render_format: "markdown+json";      // Hybrid: narrative + structured data
  
  // For Manager view
  task_list_view: boolean;             // Show kanban-style board
  can_dispatch_subagents: boolean;     // true after approval
}
```

##### Type 3: ExecutionLogArtifact

```typescript
interface ExecutionLogArtifact extends ArtifactBase {
  type: "execution-log";
  
  content: {
    plan_reference: string;            // PlanArtifact.id
    current_task_index: number;
    tasks_completed: number;
    tasks_failed: number;
    
    // Per-task execution records
    task_executions: Array<{
      task_id: string;                 // "TASK-001"
      subagent_id: string;             // Assigned agent ID
      
      // TDD cycle tracking
      tdd_cycles: Array<{
        cycle_number: number;
        phase: "red" | "green" | "refactor";
        
        red_phase?: {
          test_file_created: string;
          test_code: string;
          test_run_result: "failed" | "error";
          error_message: string;
        };
        
        green_phase?: {
          implementation_file: string;
          code_written: string;
          test_run_result: "passed";
          execution_time_ms: number;
        };
        
        refactor_phase?: {
          changes_made: string;
          code_metrics: {
            cyclomatic_complexity: number;
            duplication_rate: number;
          };
        };
        
        commit_hash: string;
        commit_message: string;
      }>;
      
      // Two-stage review results (from subagent-driven-development)
      review_results: {
        spec_compliance_check: {
          passed: boolean;
          issues: string[];
          checked_by: string;
        };
        code_quality_check: {
          passed: boolean;
          issues: string[];
          checked_by: string;
        };
        blocker_issues: string[];
        approved_at: ISO8601;
      };
      
      task_status: "completed" | "failed";
      failure_reason?: string;
      duration_minutes: number;
    }>;
    
    // Aggregate stats
    statistics: {
      total_commits: number;
      total_tests_added: number;
      total_tests_passed: number;
      code_review_feedback_cycles: number;
      avg_cycle_duration_minutes: number;
    };
  };
  
  render_format: "markdown+live-metrics";
  
  // For Manager view
  is_live_updating: boolean;           // Updates in real-time as tasks progress
  progress_percentage: number;         // 0-100
  next_action_required?: string;       // "Approve task 5" or "Fix failing test"
}
```

##### Type 4: ReviewChecklist & FeedbackArtifact

```typescript
interface ReviewChecklistArtifact extends ArtifactBase {
  type: "review-checklist";
  
  content: {
    task_reference: string;            // "TASK-003"
    execution_log_reference: string;   // ExecutionLogArtifact.id
    
    // From requesting-code-review skill
    checklist_items: Array<{
      category: "correctness" | "edge_cases" | "style" | "performance" | "test_coverage";
      checks: Array<{
        check: string;
        status: "pass" | "fail" | "info";
        severity: "blocker" | "critical" | "warning" | "info";
        details: string;
      }>;
    }>;
    
    // Aggregate decision
    overall_verdict: "approve" | "request_changes" | "approve_with_notes";
    blocker_count: number;
    reviewer_notes: string;
  };
  
  render_format: "markdown";
}
```

### 2.2 Manager 视图的 Artifact 展示体系

#### Agent Manager 界面布局

```
┌──────────────────────────────────────────────────────────────────┐
│                    AGENT MANAGER (Artifact-Centric)              │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Left Panel: Workflow Pipeline                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ ⚙️  Setup               [status]                           │ │
│  │    └─→ Design          [approval_pending]  ◆ Review       │ │
│  │        ├─→ Plan        [draft]             ⊘ Blocked      │ │
│  │        └─→ Workspace   [completed]        ✓ Done          │ │
│  │    └─→ Execution       [in_progress]                      │ │
│  │        ├─ TASK-001     [completed]        [View Details]  │ │
│  │        ├─ TASK-002     [in_progress]      [View Details]  │ │
│  │        ├─ TASK-003     [blocked]          [View Details]  │ │
│  │        └─ TASK-004     [pending]          [View Details]  │ │
│  │    └─→ Finalize        [pending]                          │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  Center Panel: Artifact Content Viewer                           │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ 📄 Design Specification (by brainstorming)                 │ │
│  │ Status: ◆ Pending Your Approval                           │ │
│  │                                                            │ │
│  │ Problem Context                                           │ │
│  │ ──────────────────                                        │ │
│  │ User Goals:                                               │ │
│  │ • Secure authentication with OAuth 2.0                   │ │
│  │ • Support multiple providers (GitHub, Google)            │ │
│  │ • Token refresh without user re-login                    │ │
│  │                                                            │ │
│  │ Design Options (3 considered)                            │ │
│  │ ──────────────────────────────                           │ │
│  │ ✓ Option A: JWT-based with refresh tokens (Recommended) │ │
│  │ Option B: Session-based with secure cookies             │ │
│  │ Option C: OAuth provider delegation (risky)              │ │
│  │                                                            │ │
│  │ [Show More] [Approve This Design]  [Request Revisions]  │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  Right Panel: Metrics & Actions                                  │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ 📊 Workflow Stats                                          │ │
│  │ ────────────────                                           │ │
│  │ Elapsed: 12 minutes 45 seconds                            │ │
│  │ Design Iterations: 2                                      │ │
│  │ Next Gate: Plan Approval (2 hours remaining)              │ │
│  │                                                            │ │
│  │ 🔗 Related Artifacts                                      │ │
│  │ ────────────────────                                      │ │
│  │ • Implementation Plan (9 tasks)  [View]                  │ │
│  │ • Git Worktree Setup Log         [View]                  │ │
│  │                                                            │ │
│  │ ⚡ Quick Actions                                           │ │
│  │ ──────────────────                                        │ │
│  │ [Revise Design]  [Approve & Continue]  [Pause]           │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

#### 工作流状态机（Manager 视图中的可视化）

```
┌─────────────────────────────────────────────────────────────┐
│           Superpowers Workflow State Machine                │
│         (As rendered in Antigravity Manager)               │
└─────────────────────────────────────────────────────────────┘

[START] User Request
  ↓
  ⚙️ Skill Discovery
  └─ Check trigger patterns
     Match? → Load tool registry
  ↓
[Design Phase]
  📄 brainstorming tool invoked
  ├─ Agent asks questions
  ├─ Generates options
  ├─ Creates DesignSpecArtifact
  └─ 🔴 GATE 1: Human Review Required
     ├─ [Approve] → Continue
     └─ [Revise] → Back to Agent
  ↓
[Planning Phase]
  📋 writing-plans tool invoked
  ├─ Parse DesignSpec
  ├─ Break into tasks
  ├─ Creates PlanArtifact
  └─ 🔴 GATE 2: Human Review Required
     ├─ [Approve] → Continue
     └─ [Adjust] → Back to Agent
  ↓
[Setup Phase]
  🔧 using-git-worktrees tool invoked
  ├─ Create isolated branch
  ├─ Run setup scripts
  └─ Artifact: WorkspaceSetupLog
  ↓
[Execution Phase - Parallel]
  Subagent Dispatch (dispatching-parallel-agents)
  ├─ For each TASK in Plan:
  │  ├─ Spawn subagent-driven-development
  │  ├─ Execute TDD cycle (RED-GREEN-REFACTOR)
  │  ├─ Run code review checks
  │  └─ 🔴 GATE 3: Per-task quality gate
  │     ├─ [Approve] → Next task
  │     └─ [Block] → Abort, flag issue
  │
  └─ Create ExecutionLogArtifact (live updating)
  ↓
[Finalization Phase]
  verification-before-completion tool
  ├─ Run full test suite
  ├─ Generate coverage report
  └─ 🔴 GATE 4: Final approval
     ├─ [Merge to main] → Worktree cleanup
     └─ [Create PR] → Keep worktree
  ↓
[COMPLETE] Task Done

Legend:
🔴 GATE = Human approval checkpoint
📄 = Artifact generated
⚙️ = Tool invoked
```

### 2.3 Manager 中的 Artifact 交互设计

#### Artifact 查看与编辑流程

```typescript
// Artifact 在 Manager 中的核心交互

interface ManagerArtifactView {
  // 1. 展示模式（取决于 artifact.type）
  rendering_mode: "read-only" | "interactive" | "live-updating";
  
  // 2. 渐进式披露（Progressive Disclosure）
  sections: Array<{
    title: string;
    content: string;               // Markdown
    expanded: boolean;
    expandable: boolean;
    token_estimate: number;        // For token budget awareness
  }>;
  
  // 3. 交互元素
  actions: Array<{
    label: string;
    action_type: "approve" | "revise" | "request_changes" | "view_details";
    is_primary: boolean;
    requires_confirmation: boolean;
  }>;
  
  // 4. 上下文链接
  related_artifacts: Array<{
    artifact_id: string;
    artifact_type: string;
    relationship: "parent" | "child" | "sibling" | "blocking";
    link_text: string;
  }>;
  
  // 5. 实时更新（for ExecutionLogArtifact）
  is_live: boolean;
  auto_refresh_interval_seconds?: number;
  live_metrics?: {
    current_task: string;
    progress_percentage: number;
    last_update: ISO8601;
  };
}
```

#### 实例：PlanArtifact 的交互设计

```
┌─────────────────────────────────────────────────────────────┐
│ Implementation Plan (from writing-plans)                    │
│ Status: Pending Approval                                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ [📋 Overview]  [🔧 Tasks]  [✅ Checklist]  [📊 Stats]      │
│                                                              │
│ ── Overview Section ─────────────────────────────────────  │
│                                                              │
│ Based on Design Spec (OAuth 2.0 Auth System)               │
│                                                              │
│ Total Tasks: 9                                              │
│ Estimated Duration: 45-50 minutes                           │
│ Complexity: Medium                                          │
│                                                              │
│ ✓ All dependencies satisfied                                │
│ ✓ No circular dependencies detected                         │
│                                                              │
│ [Collapse] [Next: Tasks]                                   │
│                                                              │
│ ── Tasks Section ──────────────────────────────────────── │
│                                                              │
│ Can expand individual tasks to see code sketches           │
│                                                              │
│ ✓ TASK-001 (3 min)   Create OAuth provider interface       │
│   Files: src/oauth/providers/index.ts                      │
│   Dependencies: none                                        │
│   [View Details]                                            │
│                                                              │
│ ✓ TASK-002 (5 min)   Implement GitHub OAuth strategy       │
│   Files: src/oauth/providers/github.ts                     │
│   Dependencies: TASK-001                                    │
│   Tests: github.test.ts (5 test cases)                     │
│   [View Details]                                            │
│                                                              │
│ ... (7 more tasks)                                          │
│                                                              │
│ ── Verification Checklist ────────────────────────────── │
│                                                              │
│ Unit Tests: 95%+ coverage target                           │
│ Integration Tests: OAuth flow tested end-to-end            │
│ Code Style: ESLint + Prettier pass                         │
│ Performance: No N+1 queries, <100ms auth latency           │
│                                                              │
│ ── Quick Actions ──────────────────────────────────────── │
│                                                              │
│ [⬅️ Back to Design]  [❌ Request Changes]  [✅ Approve]   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 第三部分：Multi-Agent 编排与执行

### 3.1 Subagent 生命周期管理

#### Antigravity 中的 Subagent 模型

在 Antigravity 中，subagent 是指：
- **独立的 Agent 实例**，拥有自己的上下文和工作目录
- **异步运行**，与主 Agent 和其他 subagents 并行
- **受约束的职责**，专注于单个任务（2-5 分钟工作量）
- **可追踪和可管理**，通过 Agent Manager 监控

```typescript
interface Subagent {
  id: string;                          // "subagent-task-001"
  parent_agent_id: string;             // Main agent ID
  
  // Task assignment
  assigned_task: {
    task_id: string;                   // "TASK-003"
    task_title: string;
    plan_artifact_id: string;          // Reference to PlanArtifact
    execution_context: {
      file_paths: string[];            // Exact files to edit
      code_sketch: string;             // Guidance
      test_requirements: string[];     // What tests must pass
    };
  };
  
  // Lifecycle
  state: "pending" | "running" | "tdd_red" | "tdd_green" | "tdd_refactor" | 
         "review_pending" | "completed" | "failed";
  
  // TDD phase tracking
  tdd_phase: "red" | "green" | "refactor" | null;
  
  // Execution context
  working_directory: string;           // Temporary worktree path
  git_branch: string;                  // Task-specific branch
  
  // Communication
  last_message?: string;               // Agent's last status
  awaiting_human_decision?: boolean;   // Blocked waiting for approval
  
  // Metrics
  start_time: ISO8601;
  end_time?: ISO8601;
  duration_seconds?: number;
  commits_made: number;
  tests_added: number;
  tests_passed: number;
  
  // Results
  result?: {
    status: "success" | "failure";
    reason?: string;
    artifacts?: string[];             // Artifact IDs created
  };
}
```

### 3.2 Subagent 执行编排模式

#### 模式 A：串行执行（Sequential）

```
用户点击 "开始执行"
  ↓
[Dispatcher] 从 PlanArtifact 读取任务列表
  ↓
TASK-001
  ├─ Spawn Subagent-001
  ├─ Wait for completion
  ├─ Review results
  └─ 🔴 GATE: Approve before proceeding
  ↓
TASK-002
  ├─ Spawn Subagent-002 (only after TASK-001 approved)
  ├─ Wait for completion
  └─ 🔴 GATE
  ↓
... (continue)
  ↓
All tasks completed
  ├─ Run full test suite
  └─ Offer merge/PR options
```

**适用场景**：任务间有强依赖关系，或用户偏好逐步审批

#### 模式 B：并行执行（Parallel，带依赖感知）

```
用户点击 "开始执行"
  ↓
[Dispatcher] 构建任务 DAG（有向无环图）
  ├─ Identify: TASK-001, TASK-002 无依赖
  ├─ Identify: TASK-003 → depends on TASK-002
  └─ Identify: TASK-004, TASK-005 → depends on TASK-003
  ↓
第一波（并行）
  Subagent-001 (TASK-001)     ─┐
  Subagent-002 (TASK-002)     ─┼─ 并行执行
                               ↓
                          等待完成 & 审批
                          (可批量审批 W1)
  ↓
第二波（并行）
  Subagent-003 (TASK-003)   ─┐
                             ├─ 并行执行
                             ↓
                        等待完成 & 审批
  ↓
第三波（并行）
  Subagent-004 (TASK-004)   ─┐
  Subagent-005 (TASK-005)   ─┼─ 并行执行
                             ↓
                        等待完成 & 审批
  ↓
Finalization
  Run all tests, offer merge
```

**适用场景**：大型 PR（10+ 任务），任务间依赖清晰，加快迭代速度

#### 模式 C：自适应执行（Adaptive，基于进度自动调整）

```
初始设定
  ├─ 用户选择 "preferred_parallelism": 3（最多同时 3 个 subagents）
  └─ 设置 "auto_gate_threshold": "warning"（警告级别自动通过，blocker 需人工）
  ↓
动态调度
  While tasks_remaining:
    ├─ Check active_subagents < max_parallelism
    ├─ Spawn next_available_subagent(respecting dependencies)
    ├─ On subagent completion:
    │   ├─ Auto-gate decision (based on threshold)
    │   ├─ If approved: remove from queue, mark as done
    │   └─ If blocked: notify human, pause dispatcher
    └─ Loop
  ↓
优化指标
  ├─ Track: avg time between task start and approval
  ├─ Track: % of auto-gated vs human-gated tasks
  └─ Suggestion: "Consider lowering auto_gate_threshold for speed"
```

**适用场景**：新用户或实验项目，逐步学习最佳并行度

### 3.3 Subagent TDD 执行约束

#### 约束框架

```typescript
interface SubagentTDDConstraints {
  // 绝对禁止（Cannot Violate）
  must_write_test_first: true;         // RED phase 强制
  must_show_failing_test: true;        // 不能跳过失败证明
  must_make_test_pass: true;           // GREEN phase 必须成功
  must_commit_per_phase: true;         // 每个阶段必须独立 commit
  
  // 风险控制（Guardrails）
  delete_code_written_before_test: true;  // TDD 违规代码必须删除
  max_code_lines_per_task: 300;        // 防止过大任务
  require_test_coverage_minimum: 80;   // %
  
  // 监控与报告（Observability）
  log_all_commits: true;
  track_tdd_phase_duration: true;      // RED/GREEN/REFACTOR 各多久？
  report_test_failure_patterns: true;  // 什么样的测试最容易失败？
  
  // 恢复机制（Recovery）
  on_test_failure_action: "pause" | "retry_with_hint" | "escalate_to_human";
  max_retry_attempts: 3;
  retry_hint_source: "claude_analysis" | "similar_task_history";
}
```

#### TDD 执行的实际流程（在 Subagent 内）

```
Subagent Startup (TASK-003)
  ├─ Load task context from PlanArtifact
  ├─ Switch to task-specific git branch
  └─ Create execution environment
  ↓
[RED Phase]
  ├─ Agent: "You are about to write a test for [requirement]"
  ├─ Agent creates: test_file.test.ts
  ├─ Test content: Covers all requirements, fails by design
  ├─ Run: npm test -- test_file.test.ts
  ├─ Verify: Test fails with clear error message
  ├─ Commit: git commit -m "RED: Test for [requirement]"
  └─ 📝 Log to ExecutionLogArtifact (red_phase details)
  ↓
[GREEN Phase]
  ├─ Agent: "Now implement minimal code to make test pass"
  ├─ Agent creates/modifies: implementation.ts
  ├─ Implementation: Minimal, passes test
  ├─ Run: npm test -- test_file.test.ts
  ├─ Verify: Test passes
  ├─ Commit: git commit -m "GREEN: Implement [feature]"
  └─ 📝 Log to ExecutionLogArtifact (green_phase details)
  ↓
[REFACTOR Phase]
  ├─ Agent: "Refactor for clarity, performance, maintainability"
  ├─ Possible actions:
  │   ├─ Extract functions/classes
  │   ├─ Improve variable names
  │   ├─ Add JSDoc comments
  │   ├─ Remove duplication
  │   └─ Optimize algorithms
  ├─ Re-run: npm test -- test_file.test.ts
  ├─ Verify: Test still passes
  ├─ Commit: git commit -m "REFACTOR: Improve [aspect]"
  └─ 📝 Log to ExecutionLogArtifact (refactor_phase details)
  ↓
[Review Gate 1: Spec Compliance]
  ├─ Reviewer checks: Does implementation match PlanArtifact?
  ├─ Verify: All specified features implemented
  ├─ Decision: Pass/Fail
  ├─ If Fail: Comment with specific issues, return to RED phase
  └─ If Pass: Continue
  ↓
[Review Gate 2: Code Quality]
  ├─ Run automated checks:
  │   ├─ ESLint, Prettier
  │   ├─ Code coverage (target: 80%+)
  │   ├─ Cyclomatic complexity (target: <10)
  │   └─ No security issues
  ├─ Reviewer manual check:
  │   ├─ Design patterns correct?
  │   ├─ Error handling adequate?
  │   └─ Performance acceptable?
  ├─ Decision: Approve/Request Changes
  ├─ If Changes: Agent makes adjustments, new RED cycle
  └─ If Approve: Mark task as done
  ↓
[Task Completion]
  ├─ Subagent state → "completed"
  ├─ Update ExecutionLogArtifact with full TDD metrics
  └─ Signal parent Agent: Ready for next task

警告：如果检测到代码在测试之前写的
  └─ Enforce: Delete pre-test code, restart RED phase
```

### 3.4 Subagent 与 Manager 的通信

#### 状态更新协议

```typescript
// Subagent 定期向 Manager 发送更新
interface SubagentStatusUpdate {
  subagent_id: string;
  timestamp: ISO8601;
  
  // 当前状态
  state: "running" | "tdd_red" | "tdd_green" | "tdd_refactor" | 
         "review_pending" | "blocked_on_human_decision" | "completed" | "failed";
  
  // 进度信息
  progress?: {
    current_phase: string;             // "Implementing feature X"
    estimated_completion_minutes: number;
    last_log_message: string;          // "Test created and failing as expected"
  };
  
  // 若需要人工决策
  decision_required?: {
    decision_type: "approve_quality" | "fix_test_failure" | "clarify_requirement";
    context: string;
    options?: string[];                // Suggested decisions
    deadline?: ISO8601;
  };
  
  // 生成的产物（可选）
  artifact_updates?: Array<{
    artifact_id: string;
    new_content: string;               // Partial update
  }>;
}
```

#### Subagent 在 Manager 中的可视化

```
┌─────────────────────────────────────────────────────────────┐
│ Execution Phase (Live)                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ Parallel Tasks (Wave 1)                                     │
│ ├─ 🟢 TASK-001 [████████████░░░] 95% Complete            │
│ │   Subagent-001 | TDD Phase: Refactor                     │
│ │   Last message: "Extracted utility functions..."         │
│ │   [View Details] [View Code Diff]                        │
│ │                                                            │
│ ├─ 🟡 TASK-002 [███████░░░░░░░░] 45% Complete            │
│ │   Subagent-002 | TDD Phase: Green                        │
│ │   Last message: "Test now passing, writing impl..."      │
│ │   [View Details]                                          │
│ │                                                            │
│ └─ 🟠 TASK-003 [⚠️  BLOCKED]                              │
│     Subagent-003 | Waiting on Human Approval                │
│     Issue: Code quality check found 3 warnings               │
│     Details:                                                 │
│     • Missing error handling in oauth callback               │
│     • Cyclomatic complexity 12 (target: <10)               │
│     • No JSDoc for public functions                         │
│     [Request Changes] [Approve Anyway]                      │
│                                                              │
│ Next Wave (Ready to Start)                                  │
│ └─ ⏳ TASK-004 [Waiting] - Depends on TASK-003             │
│                                                              │
│ Statistics                                                   │
│ ├─ Active Subagents: 2 / 3 (configurable)                  │
│ ├─ Completed: 1 task in 12 min 34 sec                      │
│ ├─ In Progress: 2 tasks                                     │
│ ├─ Blockers: 1 (needs manual review)                       │
│ └─ Estimated Total Time: 48 minutes                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 第四部分：实现架构与集成点

### 4.1 系统集成拓扑

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Antigravity System                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │     Editor       │  │     Browser      │  │  Agent Manager   │ │
│  │  (IDE Surface)   │  │  (Test/Verify)   │  │  (Orchestration) │ │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘ │
│           │                     │                     │           │
│           └─────────────────────┼─────────────────────┘           │
│                                 │                                 │
│                    ┌────────────▼─────────────┐                   │
│                    │   Workspace Abstraction   │                   │
│                    │  (Git, Files, Execution) │                   │
│                    └────────────┬─────────────┘                   │
│                                 │                                 │
├─────────────────────────────────┼─────────────────────────────────┤
│                   TOOLS LAYER (Superpowers Integration)            │
├─────────────────────────────────┼─────────────────────────────────┤
│                                 │                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │ Planning     │  │ Execution    │  │  Review      │            │
│  │ Tools        │  │  Tools       │  │  Tools       │            │
│  │              │  │              │  │              │            │
│  │ • design_    │  │ • tdd_cycle  │  │ • code_      │            │
│  │   spec       │  │ • dispatch_  │  │   review_    │            │
│  │ • impl_plan  │  │   subagents  │  │   gate       │            │
│  │ • arch_      │  │ • execute_   │  │ • feedback_  │            │
│  │   graph      │  │   with_review│  │   integration│            │
│  └──────────────┘  └──────────────┘  └──────────────┘            │
│           │               │                   │                   │
│           └───────────────┼───────────────────┘                   │
│                           │                                       │
│                ┌──────────▼─────────┐                            │
│                │  Tool Invocation   │                            │
│                │  & Artifact Gen.   │                            │
│                └──────────┬─────────┘                            │
│                           │                                       │
├───────────────────────────┼──────────────────────────────────────┤
│          ARTIFACT LAYER (State Management)                        │
├───────────────────────────┼──────────────────────────────────────┤
│                           │                                       │
│  ┌───────────────────────▼──────────────────────┐               │
│  │   Artifact Store                             │               │
│  │   (In-Memory + Persistent)                   │               │
│  │                                               │               │
│  │   • DesignSpecArtifact                       │               │
│  │   • PlanArtifact                             │               │
│  │   • ExecutionLogArtifact                     │               │
│  │   • ReviewChecklist                          │               │
│  │   • (All typed artifacts)                    │               │
│  │                                               │               │
│  │   Operations:                                 │               │
│  │   • Create, Read, Update, Subscribe          │               │
│  │   • State transitions (draft→approved)       │               │
│  │   • Lineage tracking (parent/child)          │               │
│  │   • TTL management (cleanup old artifacts)   │               │
│  └────────────────────────────────────────────┘               │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│           AGENT COMMUNICATION LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Main Agent ←→ Subagents (via message queue)                    │
│  • Task dispatch messages                                       │
│  • Status updates                                               │
│  • Decision notifications                                       │
│  • Results aggregation                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 核心集成点的 API 定义

#### 集成点 1：Tool Registry Loading

```typescript
// File: ~/.antigravity/integrations/superpowers-loader.ts

export class SuperpowersToolLoader {
  async loadToolRegistry(): Promise<ToolRegistry> {
    // 1. Fetch superpowers-registry.json
    const registry = await fetch(
      'file://' + os.homedir() + '/.config/superpowers/skills/../registry.json'
    );
    
    // 2. For each tool in registry:
    const tools = [];
    for (const toolDef of registry.tools) {
      // 3. Load corresponding SKILL.md
      const skillContent = await fs.readFile(
        join(registry.skills_dir, toolDef.skill_path),
        'utf-8'
      );
      
      // 4. Parse frontmatter + content
      const { frontmatter, content } = parseMD(skillContent);
      
      // 5. Create Tool object
      const tool = new AntitgravityTool({
        id: toolDef.id,
        name: frontmatter.title,
        trigger_pattern: new RegExp(frontmatter.trigger),
        invoke_handler: this.createInvokeHandler(toolDef, frontmatter, content),
        artifact_template: this.getArtifactTemplate(toolDef.artifact_type),
        next_tools: frontmatter.next_skills?.map(s => `superpowers:${s}`),
        requires_approval: toolDef.requires_approval,
      });
      
      tools.push(tool);
    }
    
    return new ToolRegistry(tools);
  }
  
  private createInvokeHandler(
    toolDef: ToolDefinition,
    frontmatter: Record<string, any>,
    skillContent: string
  ): ToolInvokeHandler {
    return async (context: ToolInvocationContext) => {
      // This handler is called when the tool is invoked
      // It delegates to the Agent to execute the skill
      
      const systemPrompt = `
You are executing the Superpowers skill: "${frontmatter.title}"

Skill Instructions:
${skillContent}

Context:
${JSON.stringify(context, null, 2)}

Follow the skill instructions step-by-step.
Generate the appropriate artifact as output.
      `;
      
      // Invoke Agent API to execute this skill
      const result = await context.agentAPI.invoke({
        system_prompt: systemPrompt,
        user_message: context.user_input,
        output_schema: this.getOutputSchema(toolDef.artifact_type),
      });
      
      // Parse result and create artifact
      const artifact = this.createArtifact(toolDef, result);
      
      return {
        artifact,
        next_tools: frontmatter.next_skills,
        requires_approval: toolDef.requires_approval,
      };
    };
  }
}
```

#### 集成点 2：Artifact 创建与存储

```typescript
// File: ~/.antigravity/core/artifact-store.ts

export class ArtifactStore {
  // Create a new artifact
  async create(artifact: ArtifactBase): Promise<string> {
    const id = uuid();
    const storageKey = `artifact:${artifact.type}:${id}`;
    
    // Store in memory + persistent
    this.memoryStore.set(id, artifact);
    await this.persistentStore.set(storageKey, JSON.stringify(artifact));
    
    // Subscribe watchers
    this.notifyWatchers({
      event: 'artifact_created',
      artifact_id: id,
      artifact_type: artifact.type,
    });
    
    return id;
  }
  
  // Update artifact state
  async updateState(
    artifact_id: string,
    new_state: ArtifactState,
    reason?: string
  ): Promise<void> {
    const artifact = this.memoryStore.get(artifact_id);
    artifact.status = new_state;
    
    if (reason) {
      artifact.status_history ??= [];
      artifact.status_history.push({
        from: artifact.status,
        to: new_state,
        reason,
        timestamp: new Date().toISOString(),
      });
    }
    
    await this.persistentStore.set(
      `artifact:${artifact.type}:${artifact_id}`,
      JSON.stringify(artifact)
    );
    
    this.notifyWatchers({
      event: 'artifact_state_changed',
      artifact_id,
      new_state,
    });
  }
  
  // Get artifact with type safety
  get<T extends ArtifactBase>(
    artifact_id: string,
    type: T['type']
  ): T {
    const artifact = this.memoryStore.get(artifact_id);
    if (!artifact || artifact.type !== type) {
      throw new Error(`Artifact not found or type mismatch: ${artifact_id}`);
    }
    return artifact as T;
  }
  
  // Subscribe to changes
  subscribe(
    filter: (event: ArtifactStoreEvent) => boolean,
    callback: (event: ArtifactStoreEvent) => void
  ): () => void {
    const watcher = { filter, callback };
    this.watchers.push(watcher);
    
    // Unsubscribe function
    return () => {
      this.watchers = this.watchers.filter(w => w !== watcher);
    };
  }
  
  // Cleanup old artifacts
  async cleanup(max_age_hours: number = 24): Promise<void> {
    const now = Date.now();
    const max_age_ms = max_age_hours * 3600 * 1000;
    
    for (const [id, artifact] of this.memoryStore.entries()) {
      const artifact_age = now - new Date(artifact.timestamp).getTime();
      if (artifact_age > max_age_ms && artifact.status === 'completed') {
        this.memoryStore.delete(id);
        await this.persistentStore.delete(`artifact:${artifact.type}:${id}`);
      }
    }
  }
}
```

#### 集成点 3：Subagent 调度与管理

```typescript
// File: ~/.antigravity/core/subagent-dispatcher.ts

export class SubagentDispatcher {
  // Dispatch subagents based on PlanArtifact
  async dispatchFromPlan(
    plan_artifact_id: string,
    execution_mode: 'sequential' | 'parallel' | 'adaptive' = 'parallel'
  ): Promise<ExecutionSession> {
    const plan = this.artifactStore.get(plan_artifact_id, 'implementation-plan');
    
    // Create execution session
    const session = new ExecutionSession(plan);
    
    // Build task DAG for dependency analysis
    const taskDAG = this.buildDAG(plan.content.tasks);
    
    if (execution_mode === 'sequential') {
      await this.executeSequential(session, plan, taskDAG);
    } else if (execution_mode === 'parallel') {
      await this.executeParallel(session, plan, taskDAG);
    } else {
      await this.executeAdaptive(session, plan, taskDAG);
    }
    
    return session;
  }
  
  private async executeParallel(
    session: ExecutionSession,
    plan: PlanArtifact,
    taskDAG: TaskDAG
  ): Promise<void> {
    const maxParallel = 3; // Configurable
    const activeSubagents = new Set<Subagent>();
    const completedTasks = new Set<string>();
    
    while (completedTasks.size < plan.content.tasks.length) {
      // Find next available task (all dependencies completed)
      const nextTasks = taskDAG.getReadyTasks(completedTasks);
      
      // Spawn subagents up to maxParallel
      while (activeSubagents.size < maxParallel && nextTasks.length > 0) {
        const task = nextTasks.shift()!;
        const subagent = await this.spawnSubagent(session, task, plan);
        activeSubagents.add(subagent);
        
        // Listen for completion
        subagent.on('completed', (result) => {
          activeSubagents.delete(subagent);
          completedTasks.add(task.id);
          
          // Persist execution log
          this.updateExecutionLog(session, task, result);
          
          // Check for blockers before continuing
          if (result.review_results.blocker_issues.length > 0) {
            session.markBlocked(task.id, result.review_results.blocker_issues);
            this.notifyHuman({
              type: 'task_blocked',
              task_id: task.id,
              blockers: result.review_results.blocker_issues,
            });
          }
        });
      }
      
      // Wait for at least one subagent to complete
      await Promise.race(
        Array.from(activeSubagents).map(s => s.completion)
      );
    }
    
    // Wait for all remaining subagents
    await Promise.all(
      Array.from(activeSubagents).map(s => s.completion)
    );
  }
  
  private async spawnSubagent(
    session: ExecutionSession,
    task: Task,
    plan: PlanArtifact
  ): Promise<Subagent> {
    const subagent = new Subagent({
      id: `subagent-${task.id}`,
      assigned_task: task,
      parent_agent_id: session.main_agent_id,
      working_directory: await this.createTaskWorktree(task),
      git_branch: `task/${task.id}`,
    });
    
    // Create system prompt for TDD
    const systemPrompt = this.createTDDSystemPrompt(task, plan);
    
    // Invoke Agent API in subagent mode
    await this.agentAPI.spawnSubagent({
      subagent_id: subagent.id,
      system_prompt: systemPrompt,
      initial_message: `
You are assigned to implement: ${task.title}

Task Details:
${JSON.stringify(task, null, 2)}

Follow the TDD cycle strictly:
1. RED: Write a failing test
2. GREEN: Implement minimal code to pass test
3. REFACTOR: Improve code quality

Each phase must be a separate commit.
      `,
      working_directory: subagent.working_directory,
      git_config: {
        branch: subagent.git_branch,
        author: `Subagent <${subagent.id}@antigravity.local>`,
      },
    });
    
    return subagent;
  }
  
  private createTDDSystemPrompt(task: Task, plan: PlanArtifact): string {
    return `
You are executing a Superpowers TDD cycle for this task.

CONSTRAINTS (Non-negotiable):
1. Write test BEFORE implementation
2. Show the test FAILING first
3. Only then write implementation code
4. Make the test PASS
5. Finally, REFACTOR for quality
6. Each phase = separate git commit

TASK: ${task.title}
FILES: ${task.file_paths.join(', ')}
TEST_FILE: ${task.test_requirements.test_file}
COVERAGE_TARGET: ${task.test_requirements.coverage_target}%

Test Cases Required:
${task.test_requirements.test_cases.map((tc, i) => `${i + 1}. ${tc}`).join('\n')}

Code Sketch (guidance only):
${task.code_sketch}

Report Format:
After each phase, report:
- Phase: RED | GREEN | REFACTOR
- Test output (for RED/GREEN)
- Code changes (diff)
- Commit hash
    `;
  }
  
  private async createTaskWorktree(task: Task): Promise<string> {
    const workdir = path.join(this.workspace_root, `.superpowers-task-${task.id}`);
    await fs.mkdir(workdir, { recursive: true });
    
    // Clone main repo or use linked worktree
    // (Implementation depends on repo layout)
    
    return workdir;
  }
  
  private updateExecutionLog(
    session: ExecutionSession,
    task: Task,
    result: SubagentResult
  ): void {
    const log = this.artifactStore.get(
      session.execution_log_artifact_id,
      'execution-log'
    );
    
    // Find the task execution record
    const execRecord = log.content.task_executions.find(
      te => te.task_id === task.id
    );
    
    if (execRecord) {
      execRecord.tdd_cycles = result.tdd_cycles;
      execRecord.review_results = result.review_results;
      execRecord.task_status = result.task_status;
      execRecord.duration_minutes = result.duration_minutes;
    }
    
    // Update statistics
    log.content.statistics.total_commits += result.tdd_cycles.length;
    log.content.statistics.total_tests_added += result.tests_added;
    log.content.statistics.total_tests_passed += result.tests_passed;
    
    // Persist
    this.artifactStore.updateState(session.execution_log_artifact_id, 'in_progress');
    
    // Notify Manager of progress
    this.notifyWatchers({
      event: 'execution_progress',
      session_id: session.id,
      task_id: task.id,
      progress: log.content.statistics.total_commits,
    });
  }
}
```

---

## 第五部分：关键工程决策与权衡

### 5.1 决策矩阵

| 决策点 | 选项 | 采纳 | 理由 |
|---|---|---|---|
| **Skills 如何加载** | A) 编译成二进制 / B) 在运行时解析 MD | B | 社区可直接修改 SKILL.md，无需重编译；保留 Superpowers 的 Markdown 设计哲学 |
| **Artifact 存储** | A) 仅内存 / B) 内存 + 持久化 | B | 支持 session 恢复、审计日志、历史查询；用户可重新访问已批准的设计 |
| **Subagent 并行** | A) 始终串行 / B) 智能并行 / C) 用户配置 | B+C | 智能 DAG 分析提升速度，但允许用户控制并行度（用于稳定性与学习） |
| **TDD 强制** | A) 建议性 / B) 强制性，违规代码删除 | B | Superpowers 的核心哲学；虽严格但从长期质量看回报最高 |
| **人工审批** | A) 全自动 / B) 每任务审批 / C) 风险阈值自适应 | B+C | 团队可选策略：新项目用 B 学习最佳实践，成熟项目用 C 加速 |

### 5.2 关键架构约束

#### 约束 1：Token 预算意识

由于使用 Claude 作为 agent，token 使用成本显著。实现中应该：

```typescript
interface TokenBudgetConstraint {
  // Per-artifact token tracking
  estimated_tokens_per_artifact: Record<ArtifactType, number> = {
    'design-spec': 2000,         // Typical spec
    'implementation-plan': 3000, // With task details
    'execution-log': 5000,       // Full execution transcript
  };
  
  // Intelligent compression
  strategies: [
    "Summarize old task details after completion",
    "Archive completed ExecutionLogs to persistent store",
    "Use references instead of full artifact content",
  ];
  
  // Progressive disclosure in Manager
  // (Don't load full artifact unless user expands)
}
```

#### 约束 2：Artifact 大小限制

```typescript
interface ArtifactSizeConstraint {
  max_markdown_bytes: 50_000,           // ~12,500 lines
  max_json_structure_depth: 10,         // Prevent deeply nested plans
  max_tasks_per_plan: 50,               // Prevent overwhelming plans
  max_execution_log_entries: 1000,      // Auto-archive old entries
}
```

#### 约束 3：Git 工作树管理

```typescript
interface GitWorktreeConstraint {
  max_parallel_worktrees: 5,            // OS limit concern
  worktree_cleanup_policy: "after_merge" | "manual" | "auto_after_24h";
  branch_naming_convention: "task/TASK-{id}";
  rebase_strategy: "interactive" | "auto";
}
```

---

## 第六部分：实现路线图（分阶段）

### Phase 1：基础集成（2-3 周）

```
Milestone 1.1: Skills 元数据提取
  ├─ 编写 superpowers-registry.json 生成器
  ├─ 从 SKILL.md frontmatter 提取 metadata
  └─ 注册到 Antigravity tool registry

Milestone 1.2: 基础 Artifact 类型定义
  ├─ DesignSpecArtifact schema
  ├─ PlanArtifact schema
  ├─ Artifact Store (in-memory)
  └─ Manager UI 展示原型

Milestone 1.3: 单个 Tool 集成测试
  ├─ brainstorming tool (design-spec 生成)
  ├─ writing-plans tool (implementation-plan 生成)
  └─ 手动测试工作流
```

### Phase 2：Execution 与 Subagent（3-4 周）

```
Milestone 2.1: Subagent 基础
  ├─ Subagent 类定义
  ├─ Task spawning 机制
  ├─ Git worktree 隔离
  └─ Status update 通信

Milestone 2.2: TDD 强制执行
  ├─ TDD cycle tracking
  ├─ RED-GREEN-REFACTOR commit 分离
  ├─ 预写代码检测和删除
  └─ 测试覆盖率强制

Milestone 2.3: Sequential Execution 模式
  ├─ 任务队列管理
  ├─ Per-task 审批门
  ├─ Execution Log 生成
  └─ 集成测试
```

### Phase 3：并行与智能编排（3-4 周）

```
Milestone 3.1: Task DAG 与依赖分析
  ├─ DAG 构建算法
  ├─ 循环检测
  ├─ 关键路径分析
  └─ 可视化 (Manager)

Milestone 3.2: Parallel Execution
  ├─ maxParallel 参数化
  ├─ Slot-based 调度
  ├─ 失败恢复
  └─ 压力测试 (10+ 并行任务)

Milestone 3.3: Adaptive Mode
  ├─ 动态并行度调整
  ├─ 自动门控阈值
  ├─ ML-based 参数优化 (future)
  └─ 用户偏好学习
```

### Phase 4：Manager UI 完善（2-3 周）

```
Milestone 4.1: 工作流可视化
  ├─ Pipeline view (设计→计划→执行→完成)
  ├─ Task kanban board
  ├─ Live metrics 仪表盘
  └─ Artifact diff viewer

Milestone 4.2: 交互增强
  ├─ 快速批准/驳回 UI
  ├─ Task 详情展开/折叠
  ├─ 实时日志流 (tail -f 体验)
  └─ 快捷键支持

Milestone 4.3: 高级特性
  ├─ Artifact 历史对比
  ├─ Subagent 日志导出
  ├─ 工作流重放 (debug)
  └─ 性能分析 (哪些任务最慢)
```

---

## 结论与建议

### 核心整合价值

这个架构设计实现了：

✅ **严谨的工程流程**（Superpowers TDD）在可视化、协作的多 Agent 环境（Antigravity）中的自动化执行  

✅ **可追踪的设计决策**从初始需求（brainstorming）→ 优化的实现计划（writing-plans）→ 最终代码（subagent TDD），所有中间状态都以 Artifacts 形式保存  

✅ **智能的工作流编排**：声明式 Skills (Markdown) 自动映射为可调用的 Tools，支持串行/并行/自适应三种执行策略  

✅ **质量保证机制**：强制 TDD、两阶段代码审查、人工审批门控

### 后续建议

1. **优先实现 Phase 1-2**（基础集成 + TDD 执行），验证核心价值主张
2. **与 Superpowers 社区协作**，确保 Skills 生态与 Antigravity 工具生态兼容
3. **建立测试框架**，包括工作流功能测试和性能基准
4. **文档与培训**，让开发者理解新的工作流模式和 Artifact 生命周期

---

**Document Version**: 1.0  
**Last Updated**: 2026-04-02  
**Status**: Ready for Architecture Review
