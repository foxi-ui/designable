---
title: 架构与对象模型
description: 梳理 Engine、Workbench、Workspace、Operation、TreeNode 与视图层之间的关系，理解 Designable 核心对象模型，以及事件驱动、选中、拖拽和撤销重做在架构中的位置与协作方式。
outline: deep
---

# 架构与对象模型

::: tip 本章正在编写
站点骨架与「快速开始」已经可用，本章会随后补全。下面是计划覆盖的内容。
:::

## 本章将覆盖

- `Engine → Workbench → Workspace → Operation` 的持有关系与职责边界。
- `Operation` 下的 `Tree`、`Selection`、`Hover`、`MoveHelper`、`TransformHelper` 分别解决什么问题。
- `viewport`、`outline`、`screen` 三个视口概念的区别。
- 一次拖拽从 driver 到 tree mutation、snapshot、history 的数据流。

## 先读这些

- [快速开始](./getting-started)
- 源码：`packages/core/src/models/`、`packages/core/src/drivers/`

```mermaid
flowchart TD
  accTitle: Designable 核心对象关系
  accDescr: Engine 派生 Workbench、Screen、Cursor 和 Keyboard；Workbench 管理多个 Workspace；每个 Workspace 包含 Operation、Viewport、Outline 和 History；Operation 管理 TreeNode 树、选中、悬停、移动与变换辅助对象。
  E["Engine"] --> W["Workbench"]
  E --> S["Screen"]
  E --> C["Cursor"]
  E --> K["Keyboard"]
  W --> WS1["Workspace A"]
  W --> WS2["Workspace B"]
  WS1 --> OP["Operation"]
  WS1 --> VP["Viewport"]
  WS1 --> OL["Outline"]
  WS1 --> H["History"]
  OP --> T["Tree (TreeNode)"]
  OP --> SEL["Selection"]
  OP --> HOV["Hover"]
  OP --> MH["MoveHelper"]
  OP --> TH["TransformHelper"]
```

## 延伸阅读（转载）

- [designable 工程结构](./source-reading/01-project-structure)：目录结构、各包职责与工程配置。
- [Designable 源码阅读系列](./source-reading/)：陈豪（xjchenhao）的 8 篇源码阅读文章。
