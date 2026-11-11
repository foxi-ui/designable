---
title: 实战 Recipes
description: 汇总可直接复用的实战配方：自定义物料、设置面板、多工作区、iframe 沙箱、主题定制与国际化。每个配方都给出最小可运行示例和关键源码位置，方便按需组合到自己的项目。
outline: deep
---

# 实战 Recipes

::: tip 本章正在编写
站点骨架与「快速开始」已经可用，本章会随后补全。下面是计划覆盖的内容。
:::

## 本章将覆盖

- 自定义业务组件物料：behavior、locales、图标、`propsSchema` 一次配齐。
- 自定义设置面板与自定义 setter。
- 多工作区：`Workbench.addWorkspace` / `switchWorkspace`。
- iframe 沙箱渲染：`Simulator` / `Viewport` 的 `contentWindow`。
- 主题与国际化：`setDesignerLanguage`、`registerDesignerLocales`、`prefixCls` / `theme`。

每个 recipe 都会给出「改动点 + 最小代码 + 验证方式」。

## 先读这些

- [注册系统与物料](./registry-and-materials)
- [Formily 集成](./formily-integration)
- 示例：`examples/multi-workspace/`、`examples/sandbox/`
