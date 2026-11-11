---
title: TreeNode 与编辑操作
description: 讲解 TreeNode 组件树的查询、遍历、增删改、选中、悬停与快照操作，以及这些编辑操作如何通过 Operation 同步到画布、大纲树、设置面板和撤销重做历史，并给出常用代码示例。
outline: deep
---

# TreeNode 与编辑操作

::: tip 本章正在编写
站点骨架与「快速开始」已经可用，本章会随后补全。下面是计划覆盖的内容。
:::

## 本章将覆盖

- `TreeNode` 的字段：`componentName`、`props`、`children`、`sourceName`、`hidden`。
- 查询：`find`、`findAll`、`findById`、`getParents`、`previous` / `next` / `siblings`、`descendants`。
- 修改：`append` / `prepend` / `wrap`、`setProps`、`setComponentName`、`from`、`takeSnapshot`。
- `designerProps` 与 `designerLocales` 如何从 behavior 合并到节点。
- `Selection` 与 `Hover` 的公开操作。

## 先读这些

- [架构与对象模型](./architecture)
- 源码：`packages/core/src/models/TreeNode.ts`、`Selection.ts`、`Hover.ts`
