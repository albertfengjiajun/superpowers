# Superpowers × Antigravity 整合文档导航指南

**如何使用这份文档包**

你现在拥有三份深度设计文档。本指南帮助你根据角色快速定位相关内容。

---

## 📚 文档概览

### 1. **Executive Summary** (你在这里)
   - 📄 文件：`superpowers_antigravity_executive_summary.md`
   - 🎯 目标受众：项目经理、决策者、架构评审委员会
   - ⏱️ 阅读时间：15-20 分钟
   - 📌 核心内容：
     - 问题陈述与机会
     - 整合架构总结（图示）
     - 4 大阶段实现计划
     - 风险与缓解策略
     - KSI（关键成功指标）
     - **决策与批准** ← ADR 在这里
   - 🎬 何时阅读：
     - 项目启动前，获取全景图
     - 架构评审会议的基础材料
     - 向利益相关者解释整合价值

---

### 2. **Integration Architecture Design** (核心设计文档)
   - 📄 文件：`superpowers_antigravity_integration.md`
   - 🎯 目标受众：系统架构师、技术 Lead、核心工程团队
   - ⏱️ 阅读时间：45-60 分钟
   - 📌 核心内容分六大部分：
     ```
     第一部分：Skills → Tools 映射体系
     ├─ 1.1 映射框架设计
     ├─ 1.2 Skills 分类映射（3×4 表格）
     ├─ 1.3 工具注册与发现机制
     └─ 📊 42 个 Skills 映射到 11 个 Tools
     
     第二部分：Artifacts 生命周期与 Manager 视图
     ├─ 2.1 Artifact 类型系统
     │   ├─ DesignSpecArtifact
     │   ├─ PlanArtifact
     │   ├─ ExecutionLogArtifact (live-updating)
     │   └─ ReviewChecklistArtifact
     ├─ 2.2 Manager 视图展示体系
     │   ├─ Pipeline 可视化（3 column layout）
     │   └─ Artifact 状态机（工作流图）
     └─ 2.3 Manager 中的交互设计
     
     第三部分：Multi-Agent 编排与执行
     ├─ 3.1 Subagent 生命周期
     ├─ 3.2 执行编排模式（串行/并行/自适应）
     ├─ 3.3 TDD 执行约束（绝对强制）
     └─ 3.4 Subagent ← Manager 通信协议
     
     第四部分：实现架构与集成点
     ├─ 4.1 系统集成拓扑（全景图）
     ├─ 4.2 核心集成点的 API 定义
     └─ 3 个集成点：ToolLoader, ArtifactStore, SubagentDispatcher
     
     第五部分：关键工程决策与权衡
     ├─ 5.1 决策矩阵（各点做了什么选择）
     └─ 5.2 架构约束（Token 预算、Artifact 大小、Git 限制）
     
     第六部分：实现路线图
     └─ Phase 1-4，各 2-4 周
     ```
   - 🎬 如何使用：
     - **第一次阅读**：全部读一遍，建立整体理解
     - **针对性深入**：某个 Part 需要细化时，重点阅读
     - **参考手册**：实现时，频繁查阅第二、三部分的类型定义和流程图

---

### 3. **Implementation Reference Guide** (代码与实现)
   - 📄 文件：`superpowers_antigravity_implementation_guide.md`
   - 🎯 目标受众：工程师、代码审查者、测试人员
   - ⏱️ 阅读时间：60-90 分钟（或分次阅读）
   - 📌 核心内容分六大部分：
     ```
     第一部分：核心代码框架 (TypeScript)
     ├─ 1.1 Tool 接口定义（通用合约）
     ├─ 1.2 Superpowers Tool 实现示例
     │   ├─ DesignSpecTool
     │   ├─ ImplementationPlanTool
     │   └─ ExecutePlanTool
     └─ 200+ 行可运行代码
     
     第二部分：Artifact 类型的 TS 定义
     ├─ 2.1 基础接口（ArtifactBase）
     ├─ 完整的 TypeScript interface 定义
     └─ 所有 5 种 Artifact 类型的 schema
     
     第三部分：ArtifactStore 实现
     ├─ 完整的 TypeScript 类
     ├─ create(), get(), updateState(), approve()
     ├─ subscribe() 和观察者模式
     └─ cleanup() 过期清理
     
     第四部分：SubagentDispatcher 核心实现
     ├─ dispatchFromPlan()
     ├─ executeSequential() / executeParallel() / executeAdaptive()
     ├─ TDD system prompt 生成
     ├─ TaskDAG 和拓扑排序
     ├─ ExecutionSession 状态机
     └─ 500+ 行关键代码
     
     第五部分：集成检查清单
     ├─ 5.1 前置条件（6 项）
     ├─ 5.2 Phase 1 检查清单（设计+Artifact）
     ├─ 5.3 Phase 2 检查清单（Subagent+TDD）
     ├─ 5.4 Phase 3 检查清单（并行执行）
     ├─ 5.5 Phase 4 检查清单（Manager UI）
     └─ 完整的 [ ] 勾选项目
     
     第六部分：常见实现问题与解决方案
     ├─ 问题 1：Token 预算爆炸 (解决方案代码)
     ├─ 问题 2：Git Worktree 冲突 (lock 机制)
     └─ 问题 3：TDD 强制失败 (违规检测)
     ```
   - 🎬 如何使用：
     - **开始编码前**：完整读一遍，理解全貌
     - **编码时**：第一、三、四部分是 copy-paste 的源代码
     - **测试时**：第五部分是完整的 checklist
     - **卡壳时**：第六部分是 FAQ

---

## 🎯 按角色快速导航

### 👨‍💼 项目经理 / 产品经理

**你需要**：理解价值主张、时间表、成本、风险

**阅读路线**（30 分钟）：
1. Executive Summary 第 1-2 节（问题 + 架构总结）
2. Executive Summary 第 5 节（KSI）
3. Executive Summary 第 7 节（风险与缓解）
4. Executive Summary 第 9 节（后续步骤）
5. 可选：Integration Design 的图表 (第 4.1 节)

**关键数字**：
- ⏱️ 实现周期：8-12 周（4 个 Phase）
- 💰 工程成本：~4 工程师 × 3 个月
- 📈 首批收益：2 个月后（Phase 1-2 完成）
- 🎯 目标 KSI：95% 工作流完成率、<2 分钟审批延迟

---

### 👨‍🏛️ 架构师 / 技术 Lead

**你需要**：完整的设计、决策依据、集成点、权衡

**阅读路线**（90 分钟）：
1. Executive Summary 全文（获得决策背景）
2. Integration Design 第 1-4 部分（核心设计）
3. Integration Design 第 5 部分（权衡 & 约束）
4. Implementation Guide 第 1-4 部分（代码框架检查）
5. Implementation Guide 第 5 部分（完整性检查）

**关键思考点**：
- ✅ 这个整合是否保留了 Superpowers 的核心哲学（TDD、设计评审）？
  > YES：Skills 作为声明式文档，运行时解析，TDD 强制，人工审批门
- ✅ 这个架构在 Antigravity 中的集成点有哪些？
  > 4 个：ToolLoader, ArtifactStore, SubagentDispatcher, ManagerUI
- ✅ 最大风险是什么？
  > Token 成本（缓解：预算追踪）和 TDD 合规（缓解：自动删除）
- ✅ 关键的工程决策有哪些？
  > 5 个 ADR（见 Executive Summary 第 8 节）

---

### 👨‍💻 工程师 / 实现者

**你需要**：可运行的代码框架、API 合约、检查清单、FAQ

**阅读路线**（120 分钟，分次阅读）：
1. **第一天**：
   - Executive Summary 第 2 节（快速了解整体架构）
   - Implementation Guide 第 1-2 部分（TS 接口和示例代码）
2. **第二天**：
   - Integration Design 第 2-3 部分（Artifacts + Subagent 详解）
   - Implementation Guide 第 3-4 部分（Store + Dispatcher 核心代码）
3. **开始编码**：
   - Implementation Guide 第 5 部分（按 checklist 一个一个 task）
   - **遇到问题**：Implementation Guide 第 6 部分（FAQ）
4. **Code Review**：
   - Integration Design 第 4 部分（集成点 API 合约）
   - Implementation Guide 第 5 部分（checklist 逐项验证）

**起始任务**（优先级）：
1. 实现 `superpowers-registry.json` 生成器 + 加载器
2. 实现 `ArtifactStore` (in-memory first)
3. 实现 `DesignSpecTool` (最简单的 Tool)
4. 集成到 Manager UI（展示 Artifact）
5. 实现 `ExecutePlanTool` + Subagent spawning

---

### 👨‍🔬 QA / 测试人员

**你需要**：可测试的组件、验收标准、场景清单

**阅读路线**（60 分钟）：
1. Integration Design 第 2.1 节（Artifact 类型 + 生命周期）
2. Implementation Guide 第 5 部分（完整检查清单）
3. Executive Summary 第 6 节（KSI）
4. Implementation Guide 第 6 部分（常见问题）

**测试策略**：
- **单元测试**：Tool、ArtifactStore、TaskDAG
- **集成测试**：Tool 链 (design → plan → execute)
- **系统测试**：完整工作流（从零开始到代码提交）
- **性能测试**：并行执行、大型 Artifacts、cleanup
- **压力测试**：50+ Artifacts、10+ 并行 Subagents

**关键验收标准**：
```
Phase 1:
  [ ] brainstorming + writing-plans 两个 Tool 工作
  [ ] DesignSpecArtifact 和 PlanArtifact 可正确创建/存储
  [ ] Manager 中可展示 Artifacts

Phase 2:
  [ ] Subagent 可启动，执行 TDD 三阶段
  [ ] 预写代码被自动删除，不影响 GREEN phase
  [ ] 每个 phase 各有独立 commit

Phase 3:
  [ ] 并行任务无 git 冲突（7+ 并行）
  [ ] DAG 依赖正确解析，无圆形依赖
  [ ] 失败任务正确标记，不阻挡下一 wave

Phase 4:
  [ ] Manager UI 响应时间 <100ms
  [ ] Live metrics 实时更新
  [ ] 无 memory leak（cleanup 有效）
```

---

### 👥 社区贡献者 / Superpowers 维护者

**你需要**：工具生态、贡献指南、backward 兼容性承诺

**阅读路线**（45 分钟）：
1. Executive Summary 第 2 节（整合架构简述）
2. Integration Design 第 1 节（Skills → Tools 映射）
3. Implementation Guide 第 1.2 节（Tool 实现示例）
4. Executive Summary 第 8 节（ADR - backward 兼容性承诺）

**核心承诺**：
- ✅ **现有 Skills 不变**：SKILL.md 格式、frontmatter 结构保持不变
- ✅ **Tool 层兼容**：Skills 可选择是否映射为 Tool，不强制
- ✅ **社区 Skills 仍然有效**：自定义 Skills 既能用于 Agent（原有），也能用于 Tools（新增）
- ✅ **开放贡献**：新 Tools 欢迎 PR（基于现有或新增 Skills）

**贡献新 Tool 的流程**：
```
1. Fork obra/superpowers-skills
2. 创建 SKILL.md (或修改现有)
3. 创建对应的 Tool TypeScript 类
4. 提交 PR，包括：
   ├─ Tool 代码 (Tool interface 实现)
   ├─ Unit 测试
   ├─ Artifact schema（如果新增）
   └─ 使用示例（README）
5. Maintenr 审查 → 合并
6. 下次发布时，Tool 自动在 registry 中可用
```

---

## 📊 文档间的逻辑关系

```
Executive Summary
  ├─ 【决策者看这个】
  ├─ 包含 ADR（架构决策记录）
  └─ 指向其他两份文档

    ↓ "为什么？"

Integration Design
  ├─ 【架构师 + 核心工程师看这个】
  ├─ 详解整合的各个方面
  ├─ 包含完整的类型定义、流程图
  └─ 是 Implementation Guide 的理论基础

    ↓ "怎么做？"

Implementation Guide
  ├─ 【工程师 + QA 看这个】
  ├─ TypeScript 代码框架
  ├─ 完整的 checklist
  ├─ 常见问题和解决方案
  └─ 是可直接执行的实现指南
```

---

## 🔍 快速查找表

**我想知道...**

| 问题 | 在哪里找 |
|------|--------|
| 整合的总体价值是什么？ | Executive Summary 第 1 节 + 结论 |
| 有哪些关键设计决策？ | Executive Summary 第 8 节 (ADR) |
| Skills 如何映射到 Tools？ | Integration Design 第 1 节 + 表格 |
| Artifacts 的生命周期是什么？ | Integration Design 第 2 节 + 状态机图 |
| 怎么实现一个 Tool？ | Implementation Guide 第 1.2 节 (示例代码) |
| ArtifactStore 的 API 是什么？ | Implementation Guide 第 3 节 |
| 如何并行执行任务？ | Integration Design 第 3.2 节 + Implementation Guide 第 4 节 |
| Subagent TDD 的约束有哪些？ | Integration Design 第 3.3 节 |
| 哪些是前置条件？ | Implementation Guide 第 5.1 节 |
| Phase 1 需要完成哪些任务？ | Implementation Guide 第 5.2 节 (checklist) |
| 遇到 Token 成本问题怎么办？ | Implementation Guide 第 6 节 (FAQ) |
| 如何贡献新 Tool？ | 本文档（导航指南）的社区部分 |
| 风险有哪些？怎么缓解？ | Executive Summary 第 7 节 |
| 成功的标准是什么？ | Executive Summary 第 6 节 (KSI) |

---

## 📝 文档维护与更新

**版本**：1.0（2026-04-02）  
**状态**：Ready for Architecture Review

**如何提交反馈**：
1. 发现错误或不清楚的地方？→ 提交 GitHub Issue
2. 有补充建议？→ 提交 PR
3. 大的架构问题？→ 发起 ADR（Architectural Decision Record）讨论

**更新计划**：
- **v1.1**（Architecture Review 后）：根据评审意见调整
- **v2.0**（Phase 1 完成后）：补充实现经验、性能数据、最佳实践
- **v3.0**（GA 前）：最终的生产级文档

---

**祝你阅读愉快！** 🚀

如有任何疑问，建议从 Executive Summary 开始，逐步深入到 Integration Design 和 Implementation Guide。

