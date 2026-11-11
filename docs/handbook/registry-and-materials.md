---
title: 注册系统与物料
description: 说明 GlobalRegistry、Behavior、Resource 与设置面板 Schema 的注册机制，掌握如何配置拖拽、属性面板和默认 props，把 Ant Design 组件完整接入 Designable 的物料体系。
outline: deep
---

# 注册系统与物料

::: tip 本章正在编写
站点骨架与「快速开始」已经可用，本章会随后补全。下面是计划覆盖的内容。
:::

## 本章将覆盖

- `GlobalRegistry`：behaviors、icons、locales、language 的注册与查询。
- `createBehavior` / `createResource` / `createDesigner` 的职责与返回结构。
- Behavior 的 `selector` 匹配与 `extends` 依赖排序。
- 物料如何进入 `ResourceWidget`，`propsSchema` 如何驱动 `SettingsForm`。
- 自定义业务组件物料的最小完整示例。

## 先读这些

- [快速开始](./getting-started)
- 源码：`packages/core/src/registry.ts`、`externals.ts`、`types.ts`
- 示例：`examples/basic/src/main.tsx`、`formily/antd/src/components/Input/preview.ts`

## 延伸阅读（转载）

- [全局注册与状态管理](./source-reading/05-global-registry)：`GlobalRegistry` 的语言、图标与行为注册。
- [增加自定义组件](./source-reading/06-custom-components)：编辑态/渲染态组件、Behavior 与 Resource。
