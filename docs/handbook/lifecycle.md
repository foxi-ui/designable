---
title: 生命周期
description: 设计器从创建、挂载、事件绑定到销毁的完整顺序。
outline: deep
---

# 生命周期

::: tip 本章正在编写
站点骨架与「快速开始」已经可用，本章会随后补全。下面是计划覆盖的内容。
:::

## 本章将覆盖

- `createDesigner` → `engine.mount()` → `Workspace.ensureWorkspace` → `Viewport.onMount` 的调用顺序。
- React 容器的 `useEffect` / `useLayoutEffect` 分别负责什么。
- iframe 视口与非 iframe 视口的挂载差异。
- `operation.snapshot()`、`History` 的 push / undo / redo / goto 时机。
- `workspace.serialize()` / `workspace.from()` 的保存与恢复。

## 先读这些

- [架构与对象模型](./architecture)
- 源码：`packages/core/src/models/Engine.ts`、`Workbench.ts`、`Workspace.ts`、`Operation.ts`
- 源码：`packages/react/src/containers/Designer.tsx`、`Workspace.tsx`、`Viewport.tsx`
