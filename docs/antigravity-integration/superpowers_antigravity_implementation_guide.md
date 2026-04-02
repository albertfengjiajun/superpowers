# Superpowers × Antigravity：实现参考指南

**状态**：实现设计阶段 v1.0  
**目标**：为工程团队提供具体的代码框架、API 合约、和集成检查清单

---

## 第一部分：核心代码框架

### 1.1 Tool 接口定义

```typescript
// File: ~/antigravity/core/types/tool.ts

/**
 * Antigravity 中 Tool 的通用接口
 * Superpowers Skills 通过实现此接口被集成
 */

export interface ToolInvocationContext {
  /** 用户输入 */
  user_input: string;
  
  /** 当前项目上下文 */
  project_context: {
    root_dir: string;
    language: string;
    framework?: string;
    test_framework?: string;
  };
  
  /** 工作流上下文 */
  workflow_context: {
    current_phase: WorkflowPhase;
    previous_artifacts: Map<string, ArtifactBase>;
    approved_designs?: DesignSpecArtifact;
    approved_plan?: PlanArtifact;
  };
  
  /** Agent API 访问权限 */
  agentAPI: AgentAPIClient;
  
  /** Artifact 存储访问权限 */
  artifactStore: ArtifactStore;
  
  /** 用户配置 */
  user_preferences: {
    auto_gate_threshold?: "blocker" | "warning" | "info";
    max_parallelism?: number;
    preferred_execution_mode?: "sequential" | "parallel" | "adaptive";
  };
}

export interface ToolInvokeResult {
  /** 生成的 Artifact */
  artifact: ArtifactBase;
  
  /** 下一步执行的 Tools */
  next_tools?: string[];
  
  /** 是否需要人工批准 */
  requires_approval: boolean;
  
  /** 人工批准的最后期限（可选） */
  approval_deadline?: Date;
  
  /** 额外的元数据 */
  metadata?: Record<string, any>;
}

export interface Tool {
  /** 工具唯一 ID */
  id: string;
  
  /** 工具显示名称 */
  name: string;
  
  /** 工具描述 */
  description: string;
  
  /** 触发条件（正则表达式） */
  trigger_pattern: RegExp;
  
  /** 工作流阶段 */
  phase: WorkflowPhase;
  
  /** 执行此工具 */
  invoke(context: ToolInvocationContext): Promise<ToolInvokeResult>;
  
  /** 工具的 Artifact 输出模板 */
  output_schema: ArtifactSchema;
  
  /** 下一个可能的 Tools */
  next_tools?: string[];
  
  /** 是否自动触发（vs. 需要用户指令） */
  auto_trigger: boolean;
}

export enum WorkflowPhase {
  DISCOVERY = "discovery",           // 用户提交想法
  DESIGN = "design",                 // Brainstorming
  PLANNING = "planning",             // 任务分解
  SETUP = "setup",                   // 工作环境准备
  EXECUTION = "execution",           // 代码实现
  REVIEW = "review",                 // 代码审查
  FINALIZATION = "finalization",     // 合并/发布
}
```

### 1.2 Superpowers Tool 实现示例

#### 示例 1：brainstorming Tool

```typescript
// File: ~/antigravity/tools/superpowers/design-spec.ts

export class DesignSpecTool implements Tool {
  id = "superpowers:design_spec";
  name = "Design Specification";
  description = "Refines rough ideas through questions and explores design options";
  trigger_pattern = /design.*|architecture|spec|plan|build/i;
  phase = WorkflowPhase.DESIGN;
  auto_trigger = true;
  output_schema = DesignSpecArtifactSchema;
  next_tools = ["superpowers:implementation_plan", "superpowers:setup_isolated_workspace"];
  
  async invoke(context: ToolInvocationContext): Promise<ToolInvokeResult> {
    // 1. Prepare the skill instructions
    const skillInstructions = `
You are executing the Superpowers "brainstorming" skill.

Your task is to refine the user's rough idea into a design specification.

Steps:
1. Ask clarifying questions about:
   - User goals and success criteria
   - Key constraints and requirements
   - Target users/systems
   - Performance/security concerns
   
2. Propose 2-3 design options with trade-offs
3. Make a recommendation with rationale
4. Present architecture (diagrams as ASCII or text)

Follow these principles:
- Be Socratic: ask questions first
- Show options: never prescribe a single solution
- Seek user approval: "Does this direction feel right?"
- Break into readable sections

Output format:
Return a JSON object matching DesignSpecArtifact.
    `;
    
    // 2. Invoke the Agent
    const agentResponse = await context.agentAPI.invoke({
      system_prompt: skillInstructions,
      user_message: context.user_input,
      output_format: "json",
      output_schema: DesignSpecArtifactSchema.jsonSchema(),
    });
    
    // 3. Parse the response into an Artifact
    const designSpec: DesignSpecArtifact = JSON.parse(agentResponse);
    
    // 4. Create and store the artifact
    const artifactId = await context.artifactStore.create({
      ...designSpec,
      type: "design-spec",
      status: "draft",
      requires_human_approval: true,
    });
    
    return {
      artifact: designSpec,
      next_tools: this.next_tools,
      requires_approval: true,
      approval_deadline: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours
    };
  }
}
```

#### 示例 2：implementation_plan Tool

```typescript
// File: ~/antigravity/tools/superpowers/implementation-plan.ts

export class ImplementationPlanTool implements Tool {
  id = "superpowers:implementation_plan";
  name = "Implementation Plan";
  description = "Breaks design into concrete, bite-sized tasks with exact file paths and code";
  trigger_pattern = /plan|tasks|break.*down|implement/i;
  phase = WorkflowPhase.PLANNING;
  auto_trigger = false;  // Triggered after design approval
  output_schema = PlanArtifactSchema;
  next_tools = ["superpowers:setup_isolated_workspace"];
  
  async invoke(context: ToolInvocationContext): Promise<ToolInvokeResult> {
    // 1. Get the approved design spec
    const designSpec = context.workflow_context.approved_designs;
    if (!designSpec) {
      throw new Error("Design spec approval required before planning");
    }
    
    // 2. Prepare the planning skill instructions
    const skillInstructions = `
You are executing the Superpowers "writing-plans" skill.

Based on this design specification:
${JSON.stringify(designSpec, null, 2)}

Break down the implementation into concrete tasks following these rules:

Rules:
1. Each task should be 2-5 minutes of work
2. List exact file paths
3. Provide code sketches (not full implementation)
4. Include test requirements
5. No circular dependencies
6. Mark task dependencies clearly

For each task:
- task_id: TASK-001, TASK-002, etc.
- title: One-line description
- file_paths: ["src/oauth/providers/index.ts", ...]
- dependencies: ["TASK-001"] or []
- test_file: "src/oauth/__tests__/index.test.ts"
- test_cases: ["Should export OAuthProvider interface", ...]
- code_sketch: Pseudocode or structure

Output format:
Return a JSON object matching PlanArtifact.
    `;
    
    const agentResponse = await context.agentAPI.invoke({
      system_prompt: skillInstructions,
      user_message: `Create an implementation plan for: ${designSpec.content.chosen_design.architecture}`,
      output_format: "json",
      output_schema: PlanArtifactSchema.jsonSchema(),
    });
    
    const plan: PlanArtifact = JSON.parse(agentResponse);
    
    // 3. Validate the plan (check for circular dependencies, etc.)
    this.validatePlan(plan);
    
    // 4. Store the plan
    const artifactId = await context.artifactStore.create({
      ...plan,
      type: "implementation-plan",
      status: "draft",
      requires_human_approval: true,
      derived_from_spec: designSpec.id,
    });
    
    return {
      artifact: plan,
      next_tools: this.next_tools,
      requires_approval: true,
    };
  }
  
  private validatePlan(plan: PlanArtifact): void {
    // Check for circular dependencies
    const taskIds = new Set(plan.content.tasks.map(t => t.id));
    const visited = new Set<string>();
    
    for (const task of plan.content.tasks) {
      this.checkCycles(task.id, new Set(), plan.content.tasks);
    }
    
    // Check all dependencies exist
    for (const task of plan.content.tasks) {
      for (const dep of task.dependencies || []) {
        if (!taskIds.has(dep)) {
          throw new Error(`Task ${task.id} depends on non-existent task ${dep}`);
        }
      }
    }
  }
  
  private checkCycles(
    taskId: string,
    visited: Set<string>,
    allTasks: Task[]
  ): void {
    if (visited.has(taskId)) {
      throw new Error(`Circular dependency detected at ${taskId}`);
    }
    
    visited.add(taskId);
    const task = allTasks.find(t => t.id === taskId);
    
    if (task) {
      for (const dep of task.dependencies || []) {
        this.checkCycles(dep, new Set(visited), allTasks);
      }
    }
  }
}
```

#### 示例 3：subagent_dispatcher Tool

```typescript
// File: ~/antigravity/tools/superpowers/execute-plan.ts

export class ExecutePlanTool implements Tool {
  id = "superpowers:execute_plan";
  name = "Execute with Subagent TDD";
  description = "Dispatches subagents to implement plan tasks using TDD";
  trigger_pattern = /execute|start.*implement|begin/i;
  phase = WorkflowPhase.EXECUTION;
  auto_trigger = false;  // User triggers after plan approval
  output_schema = ExecutionLogArtifactSchema;
  next_tools = [];  // Chains internally
  
  async invoke(context: ToolInvocationContext): Promise<ToolInvokeResult> {
    // 1. Get the approved plan
    const plan = context.workflow_context.approved_plan;
    if (!plan) {
      throw new Error("Implementation plan approval required");
    }
    
    // 2. Create execution log artifact
    const executionLog: ExecutionLogArtifact = {
      id: uuid(),
      type: "execution-log",
      status: "in_progress",
      source_tool: this.id,
      timestamp: new Date().toISOString(),
      human_approval_required: false,
      plan_reference: plan.id,
      current_task_index: 0,
      tasks_completed: 0,
      tasks_failed: 0,
      task_executions: [],
      statistics: {
        total_commits: 0,
        total_tests_added: 0,
        total_tests_passed: 0,
        code_review_feedback_cycles: 0,
        avg_cycle_duration_minutes: 0,
      },
    };
    
    const logId = await context.artifactStore.create(executionLog);
    
    // 3. Determine execution mode
    const executionMode = context.user_preferences.preferred_execution_mode || "parallel";
    
    // 4. Dispatch subagents
    const dispatcher = new SubagentDispatcher(
      context.agentAPI,
      context.artifactStore,
      context.project_context
    );
    
    const session = await dispatcher.dispatchFromPlan(
      plan,
      executionMode
    );
    
    // 5. Return execution log
    return {
      artifact: executionLog,
      next_tools: [],  // Execution happens asynchronously
      requires_approval: false,  // Per-task gates happen during execution
    };
  }
}
```

---

## 第二部分：Artifact 类型的 TypeScript 定义

### 2.1 基础接口

```typescript
// File: ~/antigravity/core/types/artifacts.ts

export type ArtifactType = 
  | "design-spec"
  | "implementation-plan"
  | "execution-log"
  | "review-checklist"
  | "workspace-setup-log"
  | "verification-report";

export type ArtifactStatus = 
  | "draft"
  | "pending_review"
  | "approved"
  | "in_progress"
  | "completed"
  | "blocked"
  | "failed";

export interface ArtifactBase {
  id: string;
  type: ArtifactType;
  source_tool: string;
  timestamp: string;  // ISO8601
  status: ArtifactStatus;
  
  // Tracking
  parent_artifact_id?: string;
  blocking_artifacts?: string[];
  
  // Human interaction
  human_approval_required: boolean;
  approval_deadline?: string;
  approved_by?: string;
  approval_notes?: string;
  
  // Lineage
  status_history?: Array<{
    from: ArtifactStatus;
    to: ArtifactStatus;
    reason?: string;
    timestamp: string;
  }>;
}

export interface DesignSpecArtifact extends ArtifactBase {
  type: "design-spec";
  
  content: {
    problem_context: {
      user_goals: string[];
      constraints: string[];
      success_criteria: string[];
    };
    
    design_options: Array<{
      name: string;
      description: string;
      trade_offs: string[];
      recommendation_score: number;  // 0-100
    }>;
    
    chosen_design: {
      architecture: string;
      rationale: string;
      key_components: string[];
      data_flow: string[];
    };
    
    open_questions?: Array<{
      question: string;
      impact: "blocker" | "important" | "nice-to-have";
    }>;
  };
  
  // Rendering hints
  render_format: "markdown";
  section_count: number;
  estimated_tokens: number;
}

export interface Task {
  id: string;
  sequence: number;
  title: string;
  description: string;
  
  // Implementation details
  file_paths: string[];
  dependencies: string[];
  estimated_duration_minutes: number;  // 2-5 per Superpowers
  
  // Steps
  implementation_steps: Array<{
    step: number;
    action: string;
    verification: string;
  }>;
  
  // Testing
  test_requirements: {
    test_file: string;
    test_cases: string[];
    coverage_target: number;  // percentage
  };
  
  // Execution state
  assigned_subagent?: string;
  status: "pending" | "assigned" | "in_progress" | "completed" | "failed";
  
  // Optional guidance
  code_sketch?: string;
}

export interface PlanArtifact extends ArtifactBase {
  type: "implementation-plan";
  
  content: {
    derived_from_spec: string;
    total_tasks: number;
    estimated_total_duration_minutes: number;
    
    tasks: Task[];
    
    verification_checklist: Array<{
      category: "unit_tests" | "integration" | "style" | "performance";
      items: string[];
    }>;
  };
  
  render_format: "markdown+json";
  task_list_view: boolean;
  can_dispatch_subagents: boolean;
}

export interface TDDCycleRecord {
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
}

export interface TaskExecution {
  task_id: string;
  subagent_id: string;
  
  tdd_cycles: TDDCycleRecord[];
  
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
    approved_at: string;
  };
  
  task_status: "completed" | "failed";
  failure_reason?: string;
  duration_minutes: number;
}

export interface ExecutionLogArtifact extends ArtifactBase {
  type: "execution-log";
  
  content: {
    plan_reference: string;
    current_task_index: number;
    tasks_completed: number;
    tasks_failed: number;
    
    task_executions: TaskExecution[];
    
    statistics: {
      total_commits: number;
      total_tests_added: number;
      total_tests_passed: number;
      code_review_feedback_cycles: number;
      avg_cycle_duration_minutes: number;
    };
  };
  
  render_format: "markdown+live-metrics";
  is_live_updating: boolean;
  progress_percentage: number;
  next_action_required?: string;
}
```

---

## 第三部分：Artifact Store 实现

```typescript
// File: ~/antigravity/core/artifact-store.ts

export class ArtifactStore {
  private memoryStore = new Map<string, ArtifactBase>();
  private persistentStore: PersistentStorage;
  private watchers: Array<{
    filter: (event: ArtifactStoreEvent) => boolean;
    callback: (event: ArtifactStoreEvent) => void;
  }> = [];
  
  constructor(private persistent_dir: string) {
    this.persistentStore = new JsonFileStorage(persistent_dir);
  }
  
  async create(artifact: Omit<ArtifactBase, 'id'>): Promise<string> {
    const id = this.generateId(artifact.type);
    const fullArtifact: ArtifactBase = {
      ...artifact,
      id,
    };
    
    // Store in memory
    this.memoryStore.set(id, fullArtifact);
    
    // Persist
    await this.persistentStore.set(
      `artifact:${artifact.type}:${id}`,
      JSON.stringify(fullArtifact)
    );
    
    // Notify watchers
    this.notifyWatchers({
      event: 'artifact_created',
      artifact_id: id,
      artifact_type: artifact.type,
      timestamp: new Date(),
    });
    
    return id;
  }
  
  get<T extends ArtifactBase>(
    artifact_id: string,
    expected_type?: string
  ): T {
    const artifact = this.memoryStore.get(artifact_id);
    
    if (!artifact) {
      throw new Error(`Artifact not found: ${artifact_id}`);
    }
    
    if (expected_type && artifact.type !== expected_type) {
      throw new TypeError(
        `Expected artifact type ${expected_type}, got ${artifact.type}`
      );
    }
    
    return artifact as T;
  }
  
  async updateState(
    artifact_id: string,
    new_state: ArtifactStatus,
    reason?: string
  ): Promise<void> {
    const artifact = this.memoryStore.get(artifact_id);
    if (!artifact) {
      throw new Error(`Artifact not found: ${artifact_id}`);
    }
    
    const old_state = artifact.status;
    artifact.status = new_state;
    
    // Track history
    if (!artifact.status_history) {
      artifact.status_history = [];
    }
    artifact.status_history.push({
      from: old_state,
      to: new_state,
      reason,
      timestamp: new Date().toISOString(),
    });
    
    // Persist
    await this.persistentStore.set(
      `artifact:${artifact.type}:${artifact_id}`,
      JSON.stringify(artifact)
    );
    
    // Notify
    this.notifyWatchers({
      event: 'artifact_state_changed',
      artifact_id,
      old_state,
      new_state,
      timestamp: new Date(),
    });
  }
  
  async updateContent<T extends ArtifactBase>(
    artifact_id: string,
    updates: Partial<T['content']>
  ): Promise<void> {
    const artifact = this.memoryStore.get(artifact_id) as T;
    if (!artifact) {
      throw new Error(`Artifact not found: ${artifact_id}`);
    }
    
    artifact.content = {
      ...artifact.content,
      ...updates,
    };
    
    await this.persistentStore.set(
      `artifact:${artifact.type}:${artifact_id}`,
      JSON.stringify(artifact)
    );
    
    this.notifyWatchers({
      event: 'artifact_content_updated',
      artifact_id,
      timestamp: new Date(),
    });
  }
  
  async approve(
    artifact_id: string,
    approved_by: string,
    notes?: string
  ): Promise<void> {
    const artifact = this.memoryStore.get(artifact_id);
    if (!artifact) {
      throw new Error(`Artifact not found: ${artifact_id}`);
    }
    
    artifact.approved_by = approved_by;
    artifact.approval_notes = notes;
    
    await this.updateState(artifact_id, 'approved', `Approved by ${approved_by}`);
  }
  
  subscribe(
    filter: (event: ArtifactStoreEvent) => boolean,
    callback: (event: ArtifactStoreEvent) => void
  ): () => void {
    const watcher = { filter, callback };
    this.watchers.push(watcher);
    
    // Return unsubscribe function
    return () => {
      this.watchers = this.watchers.filter(w => w !== watcher);
    };
  }
  
  private notifyWatchers(event: ArtifactStoreEvent): void {
    for (const watcher of this.watchers) {
      if (watcher.filter(event)) {
        watcher.callback(event);
      }
    }
  }
  
  private generateId(artifact_type: string): string {
    // Artifact IDs: artifact-type-timestamp-random
    const timestamp = Date.now().toString(36);
    const random = Math.random().toString(36).substring(2, 8);
    return `${artifact_type.replace(/_/g, '-')}-${timestamp}-${random}`;
  }
  
  async cleanup(max_age_hours: number = 24): Promise<void> {
    const now = Date.now();
    const max_age_ms = max_age_hours * 3600 * 1000;
    
    const toDelete: string[] = [];
    
    for (const [id, artifact] of this.memoryStore.entries()) {
      const artifact_age = now - new Date(artifact.timestamp).getTime();
      if (artifact_age > max_age_ms && artifact.status === 'completed') {
        toDelete.push(id);
      }
    }
    
    for (const id of toDelete) {
      const artifact = this.memoryStore.get(id)!;
      this.memoryStore.delete(id);
      await this.persistentStore.delete(`artifact:${artifact.type}:${id}`);
    }
  }
}

export interface ArtifactStoreEvent {
  event: 'artifact_created' | 'artifact_state_changed' | 'artifact_content_updated' | 'artifact_deleted';
  artifact_id: string;
  artifact_type?: string;
  old_state?: ArtifactStatus;
  new_state?: ArtifactStatus;
  timestamp: Date;
}
```

---

## 第四部分：Subagent Dispatcher 核心实现

```typescript
// File: ~/antigravity/core/subagent-dispatcher.ts

export class SubagentDispatcher {
  constructor(
    private agentAPI: AgentAPIClient,
    private artifactStore: ArtifactStore,
    private projectContext: ProjectContext
  ) {}
  
  /**
   * Dispatch subagents based on a PlanArtifact
   */
  async dispatchFromPlan(
    plan: PlanArtifact,
    execution_mode: 'sequential' | 'parallel' | 'adaptive' = 'parallel'
  ): Promise<ExecutionSession> {
    // 1. Validate plan structure
    const taskDAG = this.buildDAG(plan.content.tasks);
    
    // 2. Create execution session
    const session = new ExecutionSession({
      plan_id: plan.id,
      execution_mode,
      max_parallelism: 3,  // Default, configurable
    });
    
    // 3. Create execution log artifact
    const executionLog: ExecutionLogArtifact = {
      id: uuid(),
      type: 'execution-log',
      status: 'in_progress',
      source_tool: 'superpowers:execute_plan',
      timestamp: new Date().toISOString(),
      human_approval_required: false,
      plan_reference: plan.id,
      current_task_index: 0,
      tasks_completed: 0,
      tasks_failed: 0,
      task_executions: [],
      statistics: {
        total_commits: 0,
        total_tests_added: 0,
        total_tests_passed: 0,
        code_review_feedback_cycles: 0,
        avg_cycle_duration_minutes: 0,
      },
    };
    
    session.execution_log_artifact_id = await this.artifactStore.create(executionLog);
    
    // 4. Execute based on mode
    if (execution_mode === 'sequential') {
      await this.executeSequential(session, plan, taskDAG);
    } else if (execution_mode === 'parallel') {
      await this.executeParallel(session, plan, taskDAG);
    } else {
      await this.executeAdaptive(session, plan, taskDAG);
    }
    
    // 5. Finalize execution log
    await this.artifactStore.updateState(
      session.execution_log_artifact_id,
      'completed'
    );
    
    return session;
  }
  
  private async executeSequential(
    session: ExecutionSession,
    plan: PlanArtifact,
    taskDAG: TaskDAG
  ): Promise<void> {
    const tasks = plan.content.tasks;
    
    for (let i = 0; i < tasks.length; i++) {
      const task = tasks[i];
      
      // Check if dependencies are satisfied
      const depsOk = task.dependencies?.every(depId => 
        session.completed_tasks.has(depId)
      ) ?? true;
      
      if (!depsOk) {
        session.markFailed(task.id, "Dependency not met");
        continue;
      }
      
      // Spawn subagent
      const subagent = await this.spawnSubagent(session, task, plan);
      
      // Wait for completion
      await subagent.completion;
      
      // Check for blockers
      if (subagent.result?.review_results.blocker_issues.length) {
        session.markBlocked(task.id, subagent.result.review_results.blocker_issues);
        
        // Notify user and wait for decision
        const decision = await this.requestUserDecision({
          task_id: task.id,
          blockers: subagent.result.review_results.blocker_issues,
          allow_override: true,
        });
        
        if (decision === 'abort') {
          throw new Error(`Execution aborted at task ${task.id}`);
        }
        // If 'override', continue
      } else {
        session.markCompleted(task.id);
      }
      
      // Update execution log
      await this.updateExecutionLog(session, task, subagent.result!);
    }
  }
  
  private async executeParallel(
    session: ExecutionSession,
    plan: PlanArtifact,
    taskDAG: TaskDAG
  ): Promise<void> {
    const max_parallel = session.max_parallelism;
    const activeSubagents = new Map<string, Subagent>();
    const taskQueue = this.buildTaskQueue(plan.content.tasks, taskDAG);
    
    while (taskQueue.length > 0 || activeSubagents.size > 0) {
      // Spawn new subagents up to max_parallel
      while (activeSubagents.size < max_parallel && taskQueue.length > 0) {
        const task = taskQueue.shift()!;
        const subagent = await this.spawnSubagent(session, task, plan);
        activeSubagents.set(task.id, subagent);
      }
      
      // Wait for any subagent to complete
      const { taskId, subagent, result } = await Promise.race(
        Array.from(activeSubagents.entries()).map(([tid, sa]) =>
          sa.completion.then(r => ({ taskId: tid, subagent: sa, result: r }))
        )
      );
      
      activeSubagents.delete(taskId);
      
      // Process result
      if (result.task_status === 'completed') {
        session.markCompleted(taskId);
        
        // Enqueue dependent tasks
        const newly_ready = taskDAG.getTasksReadyAfter(taskId);
        taskQueue.push(...newly_ready);
      } else {
        session.markFailed(taskId, result.failure_reason);
      }
      
      await this.updateExecutionLog(session, plan.content.tasks.find(t => t.id === taskId)!, result);
    }
  }
  
  private async spawnSubagent(
    session: ExecutionSession,
    task: Task,
    plan: PlanArtifact
  ): Promise<Subagent> {
    // 1. Create worktree for task
    const worktree_path = await this.createTaskWorktree(task);
    
    // 2. Create subagent instance
    const subagent = new Subagent({
      id: `subagent-${task.id}`,
      parent_agent_id: session.main_agent_id,
      assigned_task: task,
      working_directory: worktree_path,
      git_branch: `task/${task.id}`,
    });
    
    // 3. Build system prompt for TDD
    const systemPrompt = this.buildTDDSystemPrompt(task, plan);
    
    // 4. Invoke Agent API to run subagent
    const completion = this.agentAPI.spawnSubagent({
      subagent_id: subagent.id,
      system_prompt: systemPrompt,
      working_directory: worktree_path,
      git_config: {
        branch: subagent.git_branch,
        author: `Subagent ${subagent.id} <agent@antigravity.local>`,
      },
    }).then(result => {
      // Process result
      const taskExecutionResult = this.parseSubagentResult(task, result);
      subagent.result = taskExecutionResult;
      return taskExecutionResult;
    });
    
    subagent.completion = completion;
    return subagent;
  }
  
  private buildTDDSystemPrompt(task: Task, plan: PlanArtifact): string {
    return `
You are implementing a task using Test-Driven Development (TDD).

ABSOLUTE CONSTRAINTS (Cannot violate):
1. Write test FIRST (RED phase)
2. Show the test FAILING first
3. Write implementation code (GREEN phase)
4. Make test PASS
5. Refactor (REFACTOR phase)
6. Each phase = separate git commit

Task: ${task.title}
Files to modify: ${task.file_paths.join(', ')}

Test File: ${task.test_requirements.test_file}
Test Cases Required (${task.test_requirements.test_cases.length}):
${task.test_requirements.test_cases.map((tc, i) => `${i + 1}. ${tc}`).join('\n')}

Coverage Target: ${task.test_requirements.coverage_target}%

Code Guidance (optional, not prescriptive):
${task.code_sketch || '(No sketch provided)'}

INSTRUCTIONS:
1. Create ${task.test_requirements.test_file}
2. Write test cases that FAIL
3. Run tests: npm test -- ${task.test_requirements.test_file}
4. Verify: Tests fail with clear errors
5. Report: "RED: [test output]"
6. Commit: git commit -m "RED: Test for ${task.title}"

7. Create/modify implementation in ${task.file_paths[0]}
8. Write minimal code to pass tests
9. Run tests again
10. Verify: All tests PASS
11. Report: "GREEN: [test output]"
12. Commit: git commit -m "GREEN: ${task.title}"

13. Refactor for clarity and performance
14. Run tests: should still pass
15. Report: "REFACTOR: [changes]"
16. Commit: git commit -m "REFACTOR: ${task.title}"

For each phase, format your response as:
PHASE: [RED | GREEN | REFACTOR]
TEST_OUTPUT: [test run output]
CODE: [code diff or snippet]
COMMIT_MSG: [commit message]
    `;
  }
  
  private parseSubagentResult(task: Task, result: any): TaskExecution {
    // Parse the agent's TDD cycle output
    // This is pseudo-code; actual parsing depends on agent response format
    
    const tddCycles: TDDCycleRecord[] = [];
    let current_cycle = 0;
    
    for (const phase of result.phases) {  // e.g., ["RED", "GREEN", "REFACTOR"]
      if (phase === 'RED') {
        tddCycles.push({
          cycle_number: current_cycle,
          phase: 'red',
          red_phase: {
            test_file_created: task.test_requirements.test_file,
            test_code: result[`red_test_code_${current_cycle}`],
            test_run_result: 'failed',
            error_message: result[`red_error_${current_cycle}`],
          },
          commit_hash: result[`commit_hash_${current_cycle * 3}`],
          commit_message: result[`commit_msg_red_${current_cycle}`],
        });
      } else if (phase === 'GREEN') {
        tddCycles[current_cycle].green_phase = {
          implementation_file: task.file_paths[0],
          code_written: result[`green_code_${current_cycle}`],
          test_run_result: 'passed',
          execution_time_ms: result[`green_exec_time_${current_cycle}`],
        };
        tddCycles[current_cycle].commit_hash = result[`commit_hash_${current_cycle * 3 + 1}`];
      } else if (phase === 'REFACTOR') {
        tddCycles[current_cycle].refactor_phase = {
          changes_made: result[`refactor_changes_${current_cycle}`],
          code_metrics: {
            cyclomatic_complexity: result[`refactor_complexity_${current_cycle}`],
            duplication_rate: result[`refactor_duplication_${current_cycle}`],
          },
        };
        tddCycles[current_cycle].commit_hash = result[`commit_hash_${current_cycle * 3 + 2}`];
        current_cycle++;
      }
    }
    
    return {
      task_id: task.id,
      subagent_id: `subagent-${task.id}`,
      tdd_cycles: tddCycles,
      review_results: {
        spec_compliance_check: {
          passed: result.spec_compliance_passed,
          issues: result.spec_compliance_issues || [],
          checked_by: 'code-review-bot',
        },
        code_quality_check: {
          passed: result.code_quality_passed,
          issues: result.code_quality_issues || [],
          checked_by: 'linter-bot',
        },
        blocker_issues: result.blocker_issues || [],
        approved_at: new Date().toISOString(),
      },
      task_status: result.success ? 'completed' : 'failed',
      failure_reason: result.failure_reason,
      duration_minutes: result.duration_minutes,
    };
  }
  
  private buildDAG(tasks: Task[]): TaskDAG {
    return new TaskDAG(tasks);
  }
  
  private buildTaskQueue(tasks: Task[], dag: TaskDAG): Task[] {
    // Return tasks in dependency order
    return dag.topologicalSort();
  }
  
  private async createTaskWorktree(task: Task): Promise<string> {
    const workdir = path.join(
      this.projectContext.workspace_root,
      `.superpowers-task-${task.id}`
    );
    
    await fs.mkdir(workdir, { recursive: true });
    // Additional setup if needed
    
    return workdir;
  }
  
  private async updateExecutionLog(
    session: ExecutionSession,
    task: Task,
    result: TaskExecution
  ): Promise<void> {
    const log = this.artifactStore.get<ExecutionLogArtifact>(
      session.execution_log_artifact_id,
      'execution-log'
    );
    
    log.content.task_executions.push(result);
    log.content.tasks_completed = session.completed_tasks.size;
    log.content.tasks_failed = session.failed_tasks.size;
    log.content.statistics.total_commits += result.tdd_cycles.length;
    
    await this.artifactStore.updateContent(
      session.execution_log_artifact_id,
      log.content
    );
  }
  
  private async requestUserDecision(params: {
    task_id: string;
    blockers: string[];
    allow_override: boolean;
  }): Promise<'abort' | 'override' | 'skip'> {
    // This would integrate with Manager UI to get user feedback
    // For now, placeholder
    return 'abort';
  }
}

export class TaskDAG {
  constructor(private tasks: Task[]) {}
  
  topologicalSort(): Task[] {
    // Implementation of topological sort
    // Returns tasks in dependency order
    const sorted: Task[] = [];
    const visited = new Set<string>();
    
    const visit = (taskId: string) => {
      if (visited.has(taskId)) return;
      visited.add(taskId);
      
      const task = this.tasks.find(t => t.id === taskId);
      if (!task) return;
      
      for (const dep of task.dependencies || []) {
        visit(dep);
      }
      
      sorted.push(task);
    };
    
    for (const task of this.tasks) {
      visit(task.id);
    }
    
    return sorted;
  }
  
  getReadyTasks(completed: Set<string>): Task[] {
    return this.tasks.filter(t =>
      !completed.has(t.id) &&
      (t.dependencies?.every(d => completed.has(d)) ?? true)
    );
  }
  
  getTasksReadyAfter(taskId: string): Task[] {
    const newly_ready: Task[] = [];
    
    for (const task of this.tasks) {
      if (!task.dependencies?.includes(taskId)) continue;
      
      // Check if all other dependencies are met (assume previously completed)
      if (task.dependencies.every(d => d === taskId)) {
        newly_ready.push(task);
      }
    }
    
    return newly_ready;
  }
}

export class ExecutionSession {
  id = uuid();
  main_agent_id = 'main-agent';  // From Antigravity context
  execution_mode: 'sequential' | 'parallel' | 'adaptive';
  max_parallelism: number;
  start_time = Date.now();
  end_time?: number;
  
  completed_tasks = new Set<string>();
  failed_tasks = new Set<string>();
  blocked_tasks = new Map<string, string[]>();  // taskId -> blockers
  
  execution_log_artifact_id?: string;
  
  constructor(config: {
    plan_id: string;
    execution_mode: 'sequential' | 'parallel' | 'adaptive';
    max_parallelism: number;
  }) {
    this.execution_mode = config.execution_mode;
    this.max_parallelism = config.max_parallelism;
  }
  
  markCompleted(taskId: string): void {
    this.completed_tasks.add(taskId);
  }
  
  markFailed(taskId: string, reason: string): void {
    this.failed_tasks.add(taskId);
  }
  
  markBlocked(taskId: string, blockers: string[]): void {
    this.blocked_tasks.set(taskId, blockers);
  }
}

export class Subagent {
  id: string;
  parent_agent_id: string;
  assigned_task: Task;
  working_directory: string;
  git_branch: string;
  
  state: SubagentState = 'pending';
  result?: TaskExecution;
  completion!: Promise<TaskExecution>;
  
  constructor(config: {
    id: string;
    parent_agent_id: string;
    assigned_task: Task;
    working_directory: string;
    git_branch: string;
  }) {
    this.id = config.id;
    this.parent_agent_id = config.parent_agent_id;
    this.assigned_task = config.assigned_task;
    this.working_directory = config.working_directory;
    this.git_branch = config.git_branch;
  }
}

export type SubagentState = 
  | 'pending'
  | 'running'
  | 'tdd_red'
  | 'tdd_green'
  | 'tdd_refactor'
  | 'review_pending'
  | 'completed'
  | 'failed';
```

---

## 第五部分：集成检查清单

### 5.1 实现前置条件

- [ ] Antigravity 的核心架构确定（Editor、Browser、Manager 各组件成熟）
- [ ] Agent API 定义完整（invoke、spawnSubagent 等接口）
- [ ] Artifact Store 实现可用
- [ ] Git worktree 支持确认
- [ ] 测试框架选定（Jest / Mocha）

### 5.2 Phase 1 实现检查清单

**Registry & Discovery**
- [ ] `superpowers-registry.json` 生成脚本编写完成
- [ ] SKILL.md frontmatter 解析器测试通过
- [ ] Tool 注册机制集成到 Editor
- [ ] Tool trigger matching 逻辑验证

**Artifact 基础设施**
- [ ] ArtifactBase 接口及子类型定义
- [ ] ArtifactStore 基本功能测试通过
  - [ ] create() → artifact ID 生成正确
  - [ ] get() → 类型安全检查
  - [ ] updateState() → 状态转换验证
- [ ] JSON 持久化层集成
- [ ] In-memory cache 有效性检查

**Tool 实现（各 2-3 个）**
- [ ] `design_spec` tool 完整实现
  - [ ] Agent invoke 集成
  - [ ] DesignSpecArtifact 生成
  - [ ] Manager 中的展示
- [ ] `implementation_plan` tool 完整实现
  - [ ] Plan validation（依赖、圆形依赖检查）
  - [ ] PlanArtifact 序列化
- [ ] Manager UI 展示原型
  - [ ] Artifact list view
  - [ ] Artifact detail view（展开/折叠）
  - [ ] 批准/驳回按钮

**测试**
- [ ] Unit 测试：各 Tool 的 invoke() 逻辑
- [ ] Integration 测试：Tool → Artifact → Store → UI
- [ ] 人工测试：完整工作流一遍（设计→计划）

---

### 5.3 Phase 2 实现检查清单

**Subagent 基础**
- [ ] Subagent 类定义完整
- [ ] ExecutionSession 管理
- [ ] spawnSubagent API 集成
- [ ] Status update 消息队列

**TDD Enforcement**
- [ ] TDD system prompt 生成
- [ ] RED phase 检测（测试创建和失败证明）
- [ ] GREEN phase 检测（测试通过）
- [ ] REFACTOR phase 检测
- [ ] Commit 分离验证
- [ ] 预写代码检测和删除机制

**Sequential Execution**
- [ ] Task queue 管理
- [ ] Dependency 检查
- [ ] Per-task 审批门实现
- [ ] ExecutionLogArtifact 生成和更新

**测试**
- [ ] Unit 测试：DAG topological sort
- [ ] Integration 测试：sequential execution 完整流程
- [ ] 压力测试：长工作流（10+ 任务）

---

### 5.4 Phase 3 实现检查清单

**DAG 与并行**
- [ ] TaskDAG 构建正确性
- [ ] 圆形依赖检测
- [ ] topologicalSort() 验证
- [ ] getReadyTasks() 逻辑测试
- [ ] Critical path analysis（可选）

**Parallel Execution**
- [ ] maxParallel 参数化和约束
- [ ] 并行 worktree 创建和清理
- [ ] Slot-based 调度逻辑
- [ ] 失败恢复机制（partially completed tasks）
- [ ] 并行锁（防止 git 冲突）

**Adaptive Mode**
- [ ] 动态并行度调整算法
- [ ] 自动门控阈值应用
- [ ] 用户偏好学习（可选）

**测试**
- [ ] Unit 测试：DAG 复杂情景（菱形依赖、长链）
- [ ] Integration 测试：并行 execution（3-5 并行任务）
- [ ] 压力测试：大规模并行（10+ 任务）
- [ ] Failure scenario 测试

---

### 5.5 Phase 4 实现检查清单

**Manager UI**
- [ ] Workflow pipeline visualization
- [ ] Task kanban/list view
- [ ] Live metrics dashboard
- [ ] Artifact viewer（展开/折叠、高亮）
- [ ] Real-time log streaming
- [ ] Diff viewer（for code reviews）

**交互**
- [ ] Quick approve/reject buttons
- [ ] Task detail modal
- [ ] Status filter/search
- [ ] Keyboard shortcuts
- [ ] Mobile responsiveness（可选）

**高级特性**
- [ ] Artifact history/diff
- [ ] Execution replay/debug
- [ ] Performance analytics
- [ ] Export/reporting

**测试**
- [ ] UI component unit tests
- [ ] E2E 测试（完整工作流）
- [ ] 性能测试（大量 artifacts）
- [ ] 可访问性测试（WCAG）

---

## 第六部分：常见实现问题与解决方案

### 问题 1：Token 预算爆炸

**现象**：运行几个 subagents 后，token 成本急剧增加  
**根因**：ExecutionLog 和 context 堆积

**解决方案**
```typescript
// 1. 限制 context 大小
const MAX_CONTEXT_TOKENS = 30_000;

// 2. 按需加载 artifact
const artifactLoader = new LazyArtifactLoader({
  load_full_on: 'user_request',
  cache_summary_only: true,
});

// 3. 归档旧的 task executions
const archivedLog = {
  ...executionLog,
  task_executions: executionLog.task_executions.slice(0, 5),  // 只保留最后 5 个
  archived_count: totalTasks - 5,
};
```

### 问题 2：Git Worktree 冲突

**现象**：多个 subagents 修改同一文件，git merge 失败  
**根因**：缺乏 lock 机制或合并策略

**解决方案**
```typescript
// 1. 文件级别的锁定
const fileLockManager = new FileLockManager();
await fileLockManager.lock(`src/auth.ts`, `subagent-task-001`, 300);  // 5 min timeout

// 2. 自动 rebase 策略
const rebaseStrategy = 'auto_interactive';  // Agent 自己解决冲突

// 3. 依赖约束（防止同时修改）
// Task DAG 中标记 "cannot_run_in_parallel": ["file1.ts"]
```

### 问题 3：TDD 强制失败

**现象**：Agent 在 RED 阶段写了实现代码，没有失败的测试  
**根因**：Agent 没有严格遵循 TDD

**解决方案**
```typescript
// 1. 检测违规代码
const detectPreTestCode = (testFile, implementationFile): boolean => {
  // 在 RED 阶段，implementationFile 应该不存在或为空
  const implExists = fs.existsSync(implementationFile);
  return implExists;  // 违规！
};

// 2. 强制删除
if (detectPreTestCode(...)) {
  fs.unlinkSync(implementationFile);
  subagent.message = "Code written before test! Deleting. Please start with RED phase.";
  // Restart RED phase
}

// 3. 跟踪违规
logger.warn('TDD violation detected', {
  task_id: task.id,
  subagent_id: subagent.id,
  violation: 'pre_test_code',
});
```

---

**End of Implementation Guide**

---

## 附录：相关资源引用

- [Superpowers Architecture Design](./superpowers_architecture_design.md)
- [Antigravity README](./README.md)
- [Agent Skills Specification](./agent-skills.md)
- [Rules & Workflows](./rules-workflows.md)

---

**版本历史**

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2026-04-02 | 初始版本，包含完整的代码框架和实现指南 |

