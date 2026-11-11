---
title: 故障排查
description: 画布空白、拖拽无效、设置面板空白等常见问题。
outline: deep
---

# 故障排查

::: tip 本章正在编写
本章会在正文完成后补全。先记录最常遇到的几类问题。
:::

## 常见方向

- **画布空白**：`rootComponentName` 与 `components` 的键是否一致；根节点 behavior 是否 `droppable: true`；容器是否有高度。
- **拖拽无效**：物料是否来自 `createResource` 或带静态 `Resource` 的组件；`ComponentTreeWidget` 是否挂载并注册了 behaviors。
- **设置面板空白**：当前是否选中了节点；对应 behavior 是否提供 `propsSchema`。
- **撤销失效**：修改是否经过 `TreeNode` 的 mutation 方法并触发 `operation.snapshot()`。
- **iframe 事件丢失**：`Viewport.onMount` 是否拿到正确的 `contentWindow`；跨域限制。
- **`/docs/` 子路径资源 404**：VitePress 的 `base` 是否配置为 `/docs/`，产物是否合并到 `doc-site/docs/`。

## 延伸阅读（转载）

- [常见问题](../source-reading/08-faq)：原作者整理的 Designable FAQ。
- [运行与二开](../source-reading/02-run-and-customize)：本地运行、Antd 版本升级与常见构建问题。
