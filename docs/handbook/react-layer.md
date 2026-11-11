---
title: React 层
description: Designer 容器、面板、Widgets 与 Hooks。
outline: deep
---

# React 层

::: tip 本章正在编写
站点骨架与「快速开始」已经可用，本章会随后补全。下面是计划覆盖的内容。
:::

## 本章将覆盖

- `Designer` Provider 与 `DesignerEngineContext`。
- 容器：`Workbench`、`Workspace`、`Viewport`、`Simulator`、`Layout`。
- 面板：`StudioPanel`、`CompositePanel`、`WorkspacePanel`、`ToolbarPanel`、`ViewportPanel`、`SettingsPanel`、`ViewPanel`。
- 常用 Widgets：`ResourceWidget`、`OutlineTreeWidget`、`HistoryWidget`、`NodePathWidget`、`GhostWidget` 等。
- Hooks 按用途分组：engine / workbench / workspace / viewport / tree / selection / hover / prefix / theme。
- 自定义面板与布局的接入方式。

## 先读这些

- [快速开始](./getting-started)
- 源码：`packages/react/src/containers/`、`panels/`、`widgets/`、`hooks/`

## 延伸阅读（转载）

- [「表单设计器开发指南」的内容补充](./source-reading/04-form-builder-guide-supplement)：React 层与 settings-form 的组件说明。
- [响应器的使用](./source-reading/07-reactions)：设置面板中响应器的函数上下文与常用写法。
