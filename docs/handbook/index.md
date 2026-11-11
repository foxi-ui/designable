---
layout: home

hero:
  name: Designable
  text: 开发者手册
  tagline: 从零接入表单设计器：对象模型、生命周期、物料注册与 Formily 集成
  image:
    src: /logo.svg
    alt: Designable
  actions:
    - theme: brand
      text: 快速开始
      link: /getting-started
    - theme: alt
      text: 架构与对象模型
      link: /architecture

features:
  - icon: 🧭
    title: 按接入顺序组织
    details: 从 createDesigner 到 SchemaField，按真实接入路径展开，而不是按包罗列 API。
  - icon: 🔄
    title: 讲清生命周期
    details: Engine、Workspace、Viewport 的创建、挂载、事件绑定与销毁顺序，配时序图。
  - icon: 🧩
    title: 面向扩展
    details: 自定义物料、Behavior、设置面板、多工作区与 iframe 沙箱，都有最小示例。
  - icon: 🎯
    title: 标注 API 边界
    details: 区分推荐用法、可用但谨慎和内部实现，避免依赖非稳定 API。
---

<div class="handbook-section">

## 这本手册解决什么问题

仓库里的各包 README 基本只有标题，源码注释也很少。直接读实现来接入，容易被 `Engine`、`Workbench`、`Workspace`、`Operation` 这一串对象绕住。

这本手册只覆盖一条主线：**用 `@designable/core` + `@designable/react` + `@designable/formily-antd` 搭出表单设计器，并把 Schema 接回 Formily**。每个结论都对照当前仓库源码，示例来自 `examples/` 和 `formily/antd/playground`。

</div>

<div class="handbook-section">

## 主线数据流

```mermaid
flowchart LR
  A["createDesigner()"] --> B["Engine"]
  B --> C["Workbench"]
  C --> D["Workspace"]
  D --> E["Operation"]
  E --> F["TreeNode 组件树"]
  F --> G["@designable/formily-transformer"]
  G --> H["Formily JSON Schema"]
  H --> I["SchemaField 运行时渲染"]
```

完整的对象图（`Selection`、`History`、`Viewport`、`Outline` 等旁支）见[架构与对象模型](./architecture)。

</div>

<div class="handbook-section">

## 包与职责

<div class="table-scroll">

| 包                                | 职责                                                                   | 手册位置                                                                                        |
| --------------------------------- | ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `@designable/core`                | 引擎、工作区、节点树、事件、注册表、撤销重做                           | [架构与对象模型](./architecture)、[TreeNode](./tree-node)、[注册系统](./registry-and-materials) |
| `@designable/react`               | Designer 容器、面板、Widgets、Hooks                                    | [React 层](./react-layer)                                                                       |
| `@designable/formily-antd`        | Ant Design 物料、Behavior、Resource、设置面板 Schema                   | [Formily 集成](./formily-integration)                                                           |
| `@designable/formily-transformer` | TreeNode 与 Formily JSON Schema 的双向转换                             | [Formily 集成](./formily-integration)                                                           |
| `@designable/formily-setters`     | `DataSourceSetter`、`ReactionsSetter`、`ValidatorSetter` 等配套 setter | [Formily 集成](./formily-integration)                                                           |
| `@designable/react-settings-form` | 设置面板表单与通用 setter                                              | [React 层](./react-layer)                                                                       |

</div>

</div>

<div class="handbook-section">

## 从哪里开始

<div class="handbook-grid">

[**第一次接入**<br><span>装依赖、渲染画布、理解最小闭环。</span>](./getting-started)

[**理解对象模型**<br><span>Engine → Workbench → Workspace → Operation 到底谁管谁。</span>](./architecture)

[**搞清生命周期**<br><span>什么时候 mount、什么时候绑定事件、什么时候销毁。</span>](./lifecycle)

[**接入 Formily**<br><span>TreeNode 与 JSON Schema 互转，保存、预览、运行时渲染。</span>](./formily-integration)

</div>

</div>

<div class="handbook-section">

## 源码阅读系列（转载）

陈豪（xjchenhao）的 8 篇 Designable 源码阅读文章已按作者声明转载，涵盖工程结构、运行与二开、全局注册、自定义组件、响应器等主题。每篇均保留作者、原文链接与发布时间。

[进入源码阅读系列](./source-reading/)

</div>

<div class="handbook-section">

## 版本基准

本手册基于本仓库 `main`（commit `3e961de`）的源码整理。npm 上最新的 `@designable/core` 是 `1.0.0-beta.45`，比该提交早 34 个提交；外部项目安装 npm 包时，遇到与文中不一致的 API，请以仓库源码为准。详见[快速开始](./getting-started#versions)。

</div>
