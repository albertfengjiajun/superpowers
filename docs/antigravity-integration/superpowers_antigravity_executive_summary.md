# Superpowers × Antigravity 整合：执行摘要与决策指南

**级别**：Architectural Decision Record (ADR)  
**日期**：2026-04-02  
**状态**：Ready for Architecture Review  

---

## 1. 问题陈述

### 背景

**Google Antigravity** 是一个 agent-first IDE，支持多个并行 Agent 跨越 Editor、Browser、Manager 三大界面执行复杂任务。

**Superpowers** 是一个严谨的工程工作流框架，内置 18+ 个声明式 Skills（Markdown 定义），强制执行 TDD、设计评审、计划验证等最佳实践。

### 挑战

1. **工作流可视化**：Superpowers 的 Skills 是"隐形的" Agent 指令，在 Antigravity 的 Manager UI 中无法追踪设计→计划→执行的进度
2. **产物管理**：设计文档、实现计划、执行日志没有统一的产物（Artifact）模型，难以复用和审计
3. **协作交互**：Superpowers 的人工审批门（design approval、plan approval）与 Antigravity 的异步 Agent 编排不匹配
4. **并行执行**：Superpowers 的 subagent-driven-development 需要 Antigravity 的任务分发和协调机制

### 机会

整合可以实现：
- **端到端的可追踪工作流**：从模糊需求到优化代码
- **产物驱动的开发**：每个阶段生成可复用的 Artifact，支持审查、修改、历史查询
- **智能的多 Agent 编排**：利用 Antigravity 的异步能力和 Superpowers 的工程约束

---

## 2. 整合架构总结

### 核心整合模式：Skills → Tools → Artifacts → Manager

```
┌─────────────────────────────────────────────────────────────┐
│ 用户请求 ("help me build payment system")                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                 ┌───────▼─────────┐
                 │ Trigger Matching │
                 │ (正则 skills)    │
                 └───────┬─────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
    ┌───▼──────┐  ┌──────▼────────┐  ┌───▼──────┐
    │brainstorm│  │writing-plans  │  │execute   │
    │(Skill)   │  │(Skill)        │  │(Skill)   │
    └───┬──────┘  └──────┬────────┘  └───┬──────┘
        │                │                │
    ┌───▼──────────────────────────────────▼──┐
    │      Tools Registry                    │
    │  (superpowers-registry.json)           │
    └───┬──────────────────────────────────┬──┘
        │                                  │
 ┌──────▼──────────┐         ┌────────────▼────────┐
 │ design_spec     │         │implementation_plan │
 │ tool            │         │ tool                │
 └──────┬──────────┘         └────────────┬────────┘
        │                                  │
    ┌───▼──────────────────────────────────▼──┐
    │   Agent Invocation & Execution        │
    │   (Agent API with skill instructions) │
    └───┬──────────────────────────────────┬──┘
        │                                  │
  ┌─────▼──────────┐          ┌──────────▼───────┐
  │DesignSpec     │          │Implementation    │
  │Artifact       │          │Plan Artifact     │
  │(JSON+Markdown)│          │(JSON+Markdown)   │
  └─────┬──────────┘          └──────────┬───────┘
        │                                  │
        └──────────────┬───────────────────┘
                       │
            ┌──────────▼──────────┐
            │  Artifact Store     │
            │  (persistent + mem) │
            └──────────┬──────────┘
                       │
            ┌──────────▼──────────┐
            │  Agent Manager UI   │
            │  (可视化工作流)     │
            │  (人工审批)         │
            └─────────────────────┘
                       │
            ┌──────────▼──────────┐
            │ Execution Phase     │
            │ (Subagents + TDD)   │
            │ (ExecutionLog)      │
            └─────────────────────┘
```

### 关键设计决策

| 决策点 | 选项 | 采纳 | 权衡 |
|--------|------|------|------|
| **Skills 加载** | (A) 编译 vs (B) 运行时解析 | **(B)** 运行时解析 | ✅ 社区贡献无需编译 / ❌ 性能稍低但可接受 |
| **Artifact 存储** | (A) 仅内存 vs (B) 内存+持久化 | **(B)** 混合 | ✅ 支持恢复和审计 / ❌ 存储成本 |
| **执行模式** | (A) 串行 vs (B) 并行 vs (C) 自适应 | **(B+C)** 智能并行 + 用户可选 | ✅ 平衡速度和稳定性 / ❌ 实现复杂度 |
| **TDD 强度** | (A) 建议性 vs (B) 强制性 | **(B)** 强制，违规删除代码 | ✅ 保证代码质量 / ❌ 严格可能挫伤用户 |
| **人工审批** | (A) 全自动 vs (B) 每任务 vs (C) 阈值自适应 | **(B+C)** 可选 | ✅ 灵活适配不同团队 / ❌ 配置复杂 |

---

## 3. 关键组件

### 3.1 Skills → Tools Mapping

**42 个 Superpowers Skills** 映射到 **3 大类 Tool**：

```
Planning Tools (设计与计划)
├─ superpowers:design_spec          (brainstorming → DesignSpecArtifact)
├─ superpowers:implementation_plan  (writing-plans → PlanArtifact)
├─ superpowers:architecture_graph   (breaking-down-system-design → Architecture)
└─ superpowers:setup_workspace      (using-git-worktrees → WorkspaceSetupLog)

Execution Tools (代码实现)
├─ superpowers:execute_plan         (subagent-driven-development + TDD)
├─ superpowers:tdd_cycle            (test-driven-development → RED-GREEN-REFACTOR)
├─ superpowers:debug_session        (systematic-debugging → DebugTranscript)
└─ superpowers:dispatch_subagents   (dispatching-parallel-agents → TaskLog)

Review Tools (质量保证)
├─ superpowers:code_review_gate     (requesting-code-review → ReviewChecklist)
├─ superpowers:feedback_integration (receiving-code-review → ReviewFeedback)
└─ superpowers:branch_completion    (finishing-a-development-branch → MergeDecision)
```

**映射的收益**：
- ✅ Skill 自动注册为可调用 Tool
- ✅ Skill 指令 (Markdown) → Agent System Prompt
- ✅ Skill next-skills → Tool 编排链
- ✅ Tool 输出 → 类型化 Artifact

### 3.2 Artifact 类型系统

**核心 Artifact 类型** （JSON Schema）：

```typescript
DesignSpecArtifact {
  problem_context: {goals, constraints, success_criteria}
  design_options: [{name, trade_offs, recommendation_score}]
  chosen_design: {architecture, rationale, key_components}
}

PlanArtifact {
  tasks: [{id, title, file_paths, dependencies, estimated_duration}]
  verification_checklist: [{category, items}]
}

ExecutionLogArtifact {
  task_executions: [{
    task_id, subagent_id,
    tdd_cycles: [{phase: RED|GREEN|REFACTOR, commit, test_result}],
    review_results: {spec_compliance, code_quality, blockers}
  }]
  statistics: {total_commits, tests_added, avg_cycle_duration}
}

ReviewChecklistArtifact {
  checklist_items: [{category, checks, severity}]
  overall_verdict: approve|request_changes
}
```

**生命周期**（状态机）：
```
draft → pending_review → approved → in_progress → completed
                    ↑                    │
                    └────── blocked ◄────┘
                    
（可选路径：failed）
```

**在 Manager 中的展示**：
- **Pipeline View**：设计→计划→执行→完成（可视化状态转移）
- **Artifact Viewer**：展开/折叠、渐进式披露
- **Live Metrics**：实时进度、TDD cycle 计数
- **Approval Gates**：快速批准/驳回按钮

### 3.3 Multi-Agent 编排

**三种执行模式**：

```
Mode 1: Sequential (串行)
┌─── TASK-001 ─→ Review ─→ Approved ─→
└─────────────────────────┐
                          │
                      ┌─── TASK-002 ─→ Review ─→ ...
最安全，适合学习和小项目

Mode 2: Parallel (并行，DAG 感知)
      ┌─── TASK-001 ┐
      │             ├─→ Review & Batch Approval ─→
      └─── TASK-002 ┘
      
      ┌─── TASK-003 (depends on 001+002) ─→ Review ─→
最快，需要任务间依赖清晰

Mode 3: Adaptive (自适应)
用户配置：max_parallelism = 3, auto_gate_threshold = "warning"
系统自动调整并行度和批准策略
最聪明，适合有经验的团队
```

**Subagent TDD 约束** （绝对强制）：
1. RED phase：写失败的测试
2. GREEN phase：实现最小代码使测试通过
3. REFACTOR phase：改进代码
4. 每个 phase = 单独 commit
5. 违规代码自动删除

---

## 4. 技术栈与依赖

### 4.1 核心依赖

| 组件 | 技术 | 理由 |
|------|------|------|
| **Tool Registry** | JSON + YAML parsing | 轻量、可版本化 |
| **Artifact Store** | TypeScript Map + JSON files | 简单、可持久化 |
| **Subagent API** | Antigravity Agent API | 原生支持 |
| **Git Integration** | Worktree + Branch management | 隔离和可回滚 |
| **DAG Processing** | Topological sort (自实现) | 无外部依赖 |
| **UI Rendering** | React (Antigravity native) | 一致的用户体验 |

### 4.2 性能约束

```
Token Budget (每个完整工作流)
├─ brainstorming Tool:       ~2,000 tokens
├─ writing-plans Tool:       ~3,000 tokens
├─ Per-task Subagent:        ~5,000 tokens (TDD 3 cycles)
├─ Code Review:              ~2,000 tokens
└─ Total (9-task project):   ~45,000 tokens (可接受)

Latency Budget
├─ Tool Invocation:          <2 seconds
├─ Artifact Creation:        <500ms
├─ Subagent Spawn:           <500ms
├─ End-to-End Workflow:      ~30-60 min (9-task project)

Storage Budget
├─ Per Artifact (average):   10-50 KB
├─ Per Project (monthly):    5-10 MB
└─ Retention Policy:         Auto-cleanup after 30 days for draft artifacts
```

---

## 5. 实现阶段与时间表

### Phase 1：基础集成（2-3 周）
**目标**：证明 Skills → Tools → Artifacts 的可行性

```
Week 1:
  - Registry 生成脚本
  - Artifact Store (in-memory)
  - Tool 接口定义

Week 2:
  - brainstorming + writing-plans 两个 Tool 完整实现
  - Manager UI 原型（Artifact viewer）

Week 3:
  - 端到端测试（设计→计划）
  - 性能基准测试
```

**交付物**：
- [ ] superpowers-registry.json 格式确定
- [ ] ArtifactStore API 稳定
- [ ] 2 个 Tool 的完整演示
- [ ] Manager 中的 Artifact 展示工作

### Phase 2：执行与 TDD（3-4 周）
**目标**：实现 Subagent 驱动的 TDD 执行

```
Week 1:
  - Subagent 类定义
  - Task spawning 机制
  - TDD system prompt 生成

Week 2:
  - TDD 强制（RED-GREEN-REFACTOR）
  - 预写代码检测和删除

Week 3:
  - Sequential execution 完整流程
  - 人工审批门集成

Week 4:
  - 完整工作流测试（设计→计划→实现）
  - 性能优化
```

**交付物**：
- [ ] Subagent 可靠启动
- [ ] TDD 强制有效
- [ ] ExecutionLog 实时更新
- [ ] 完整工作流演示

### Phase 3：并行与编排（3-4 周）
**目标**：支持智能并行执行

```
Week 1:
  - TaskDAG 构建和拓扑排序
  - 圆形依赖检测

Week 2:
  - Parallel execution 模式
  - 失败恢复

Week 3:
  - Adaptive mode 实现
  - 性能测试（10+ 并行任务）

Week 4:
  - 压力测试和优化
```

**交付物**：
- [ ] DAG 处理正确性证明
- [ ] 并行执行稳定可靠
- [ ] 自动并行度调整工作

### Phase 4：UI 完善（2-3 周）
**目标**：生产级别的 Manager UI

```
Week 1:
  - Workflow pipeline visualization
  - Task kanban board
  - Live metrics dashboard

Week 2:
  - Artifact diff viewer
  - Real-time log streaming
  - 搜索和过滤

Week 3:
  - 性能优化和可访问性
  - 文档和用户教程
```

**交付物**：
- [ ] Manager UI 完整功能
- [ ] 无明显性能瓶颈
- [ ] 完整的用户文档

---

## 6. 关键成功指标 (KSI)

### 功能指标

| 指标 | 目标 | 测量方法 |
|------|------|--------|
| **工作流完成率** | ≥95% | 测试 100 个完整工作流 |
| **TDD 强制有效性** | 100% 合规 | 检测预写代码 |
| **并行任务支持** | ≥10 并行无冲突 | 压力测试 |
| **人工审批延迟** | <1 分钟（UI 响应） | 用户界面性能测试 |
| **Artifact 查询性能** | <100ms | 基准测试 |

### 质量指标

| 指标 | 目标 | 测量方法 |
|------|------|--------|
| **代码覆盖率** | ≥85% | Jest/Istanbul |
| **E2E 测试通过率** | 100% | 完整工作流测试 |
| **代码审查通过率** | 2 个 +1 before merge | GitHub PR |
| **Bug 密度** | <2 per 1000 lines | Issue tracking |

### 用户体验指标

| 指标 | 目标 | 测量方法 |
|------|------|--------|
| **学习曲线** | <30 min to first successful workflow | 新用户测试 |
| **任务成功率** | ≥90% (minimal human intervention) | 用户日志分析 |
| **错误恢复** | <2 min from blocker to resume | 压力测试 + UX 观察 |

---

## 7. 风险与缓解策略

### 风险 1：Token 成本爆炸

**风险**：大型 PR (20+ 任务) 导致 token 使用激增  
**影响**：用户成本难以预测  
**概率**：高  
**缓解**
- ✅ Token 预算追踪（per artifact）
- ✅ Artifact 汇总和归档（只保留最近 5 个 task executions）
- ✅ 可配置的 context 大小（默认 30K tokens）
- ✅ 成本估计器（计划生成时预测总成本）

### 风险 2：Git Worktree 冲突

**风险**：多 subagents 修改同一文件，merge 失败  
**影响**：执行中断，需要人工干预  
**概率**：中  
**缓解**
- ✅ 文件级锁定（同一文件不并行修改）
- ✅ 自动 rebase 策略
- ✅ 任务依赖约束（标记哪些任务不能并行）
- ✅ Conflict resolution agent（可选）

### 风险 3：Agent TDD 不合规

**风险**：Agent 绕过 RED phase，直接写实现代码  
**影响**：TDD 约束失效，代码质量下降  
**概率**：中  
**缓解**
- ✅ 强制删除预写代码（automate）
- ✅ TDD system prompt 强化（频繁提醒）
- ✅ Compliance monitoring（追踪违规频率）
- ✅ 用户可禁用自动删除，改为人工审批

### 风险 4：Manager UI 性能下降

**风险**：大量 Artifacts (~1000+) 导致 UI 卡顿  
**影响**：用户体验恶化  
**概率**：低但重要  
**缓解**
- ✅ Lazy loading（按需加载 artifact 内容）
- ✅ 虚拟化列表（只渲染可见的 items）
- ✅ 索引和缓存（artifact metadata）
- ✅ 定期清理（auto-cleanup 过期 artifacts）

### 风险 5：Superpowers 社区反馈

**风险**：社区反感 "Antiquary 专有工具"，导致 Skills 分裂  
**影响**：生态分化，维护成本增加  
**概率**：低  
**缓解**
- ✅ 开放设计审查（社区参与 ADR）
- ✅ Backward 兼容性（Skills 不变，Tool 层兼容）
- ✅ 贡献指南（明确如何创建新 Tool）
- ✅ 长期愿景沟通（Superpowers 核心地位不变）

---

## 8. 决策与批准

### 架构决策

**ADR-001：采用运行时 Skills → Tools 映射**
- ✅ **决策**：使用 JSON registry + 动态 frontmatter 解析，而非编译成二进制
- ✅ **理由**：社区可直接修改 SKILL.md，保留 Superpowers 的 Markdown 设计哲学
- ✅ **权衡**：稍低的启动性能，但容错性更好，适合快速迭代

**ADR-002：强制 TDD 并自动删除预写代码**
- ✅ **决策**：违反 RED-GREEN-REFACTOR 约束的代码自动删除，无选项
- ✅ **理由**：保证工程严谨性，Superpowers 的核心价值主张
- ✅ **权衡**：可能挫伤用户，但长期 ROI 高；可提供 override 选项供高级用户

**ADR-003：Artifact Store 采用内存 + JSON 文件混合**
- ✅ **决策**：运行时在内存中，持久化到 JSON 文件（~/.antigravity/artifacts/）
- ✅ **理由**：快速查询 + 持久化，支持 session 恢复和审计
- ✅ **权衡**：存储成本，但可接受（5-10 MB/month）

**ADR-004：支持三种执行模式，用户可选**
- ✅ **决策**：Sequential（默认）、Parallel、Adaptive，用户在工作流启动时选择
- ✅ **理由**：平衡速度、稳定性、可学习性；适配不同团队成熟度
- ✅ **权衡**：实现复杂度增加，但可通过优秀的文档缓解

---

## 9. 后续步骤

### 立即行动（1-2 周）

1. **获得 Antigravity 团队批准**
   - [ ] Architecture Review 通过
   - [ ] 确认 Agent API、Artifact Store 的可用性
   - [ ] 识别集成阻塞点

2. **获得 Superpowers 社区反馈**
   - [ ] 在 Discord 宣布计划
   - [ ] 收集对 Tool Registry 格式的意见
   - [ ] 确保 backward 兼容性

3. **原型验证**
   - [ ] 实现 brainstorming + writing-plans 两个 Tool
   - [ ] 创建 Manager UI 模型（Figma）
   - [ ] 端到端演示（设计→计划）

### 后续（3-12 周）

1. **Phase 1-2 实现**（5-7 周）
   - [ ] TDD enforcement 验证
   - [ ] Sequential execution 稳定性

2. **Phase 3-4 实现**（6-8 周）
   - [ ] 并行执行和 Manager UI
   - [ ] 性能优化

3. **Beta 发布**（2 周）
   - [ ] 邀请社区用户
   - [ ] 收集反馈
   - [ ] 快速迭代

4. **GA 发布**
   - [ ] 完整文档
   - [ ] 最佳实践指南
   - [ ] 迁移工具

---

## 10. 结论

### 为什么这个整合很重要

1. **提升 Antigravity 的价值**：从 "AI IDE" 升级到 "AI 工程 Orchestrator"
2. **证明 Superpowers 的有效性**：在生产环境中验证 TDD + 工作流的价值
3. **建立新的生态**：Tools + Artifacts + Multi-Agent 的组合，为未来的 Agent 应用铺路

### 预期成果

| 短期（6 个月） | 中期（1 年） | 长期（2+ 年） |
|---|---|---|
| ✅ 完整的 Skills→Tools 映射 | ✅ 生产级别的性能和稳定性 | ✅ Skill 市场化（评分、推荐） |
| ✅ Manager 中可视化的工作流 | ✅ 社区贡献的新 Skills/Tools | ✅ 跨平台支持（VS Code、Cursor、Codex） |
| ✅ TDD 强制执行 | ✅ 数据驱动的优化（哪些 patterns 最有效） | ✅ ML 增强（自学最佳并行度、参数优化） |
| ✅ 基础的并行执行 | | ✅ 商业化（企业级支持、培训） |

### 最终建议

**推进实现。这个整合充分利用了 Antigravity 和 Superpowers 各自的优势，创造了一个高度协调、工程严谨的 Agent 开发平台。**

---

## 附录 A：术语表

| 术语 | 定义 |
|------|------|
| **Skill** | Superpowers 中的声明式工作流单元（Markdown + YAML frontmatter） |
| **Tool** | Antigravity 中的可调用实体（Skill 的运行时映射） |
| **Artifact** | 工作流的产物（设计文档、计划、执行日志等）|
| **Subagent** | 异步 Agent 实例，负责单个 Task 的 TDD 执行 |
| **TaskDAG** | Task 的依赖图（有向无环图），用于并行调度 |
| **Worktree** | Git 的隔离工作副本，用于 Subagent 执行 |
| **TDD Cycle** | RED → GREEN → REFACTOR 三阶段循环 |
| **Approval Gate** | 人工审批检查点（设计、计划、代码质量等） |

---

## 附录 B：相关文档

- [Superpowers Architecture Design](./superpowers_architecture_design.md)
- [Antigravity README](./README.md)
- [Integration Implementation Guide](./superpowers_antigravity_implementation_guide.md)
- [Quick Reference](./superpowers_quick_reference.md)

---

**Document Version**: 1.0  
**Status**: Ready for Executive Review  
**Next Review**: After Architecture Review Board Decision

