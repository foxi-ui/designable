---
title: Formily 集成
description: TreeNode 与 JSON Schema 互转、SchemaField 渲染与设置面板。
outline: deep
---

# Formily 集成

::: tip 本章正在编写
站点骨架与「快速开始」已经可用，本章会随后补全。下面是计划覆盖的内容。
:::

## 本章将覆盖

- `@designable/formily-transformer`：`TreeNode` ↔ Formily JSON Schema。
- `x-component`、`x-component-props`、`x-decorator` 的映射规则。
- 运行时渲染：`createForm` + `SchemaField`。
- 设置面板：`SettingsForm`、`propsSchema`，以及 `DataSourceSetter` / `ReactionsSetter` / `ValidatorSetter` 的使用边界。
- antd playground 的完整接线拆解：哪些是框架必需，哪些是 demo 逻辑。
- 保存、恢复、预览的完整数据流。

## 先读这些

- [注册系统与物料](./registry-and-materials)
- 源码：`formily/transformer/src/`、`formily/setters/src/`、`formily/antd/src/`
- 示例：`formily/antd/playground/main.tsx`、`formily/antd/playground/service/`
