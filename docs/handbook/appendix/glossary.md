---
title: Designable 核心术语表
description: 统一 Engine、Workbench、Workspace、Operation、TreeNode、Behavior、Resource 等 Designable 核心术语的含义，说明它们之间的从属关系，避免阅读源码和文档时产生歧义。
outline: deep
---

# 术语表

::: tip 本章正在编写
术语表会随正文一起补全，统一全文译名。
:::

| 术语      | 含义                                                                           |
| --------- | ------------------------------------------------------------------------------ |
| Engine    | 设计器引擎，持有 Workbench、Screen、Cursor、Keyboard                           |
| Workbench | 工作台，管理多个 Workspace 与当前工作区                                        |
| Workspace | 工作区，持有一个 Operation、Viewport、Outline 和 History                       |
| Operation | 一次编辑操作的上下文，持有 Tree、Selection、Hover、MoveHelper、TransformHelper |
| TreeNode  | 组件树节点，设计器的数据模型                                                   |
| Behavior  | 节点的设计器行为，决定能否拖拽、放置、旋转，以及设置面板 Schema                |
| Resource  | 物料资源，描述可拖入画布的组件模板                                             |
| Setter    | 设置面板中的字段编辑器                                                         |
| Driver    | 输入事件驱动（鼠标、键盘、滚动、缩放等）                                       |
| Snapshot  | 历史快照，用于撤销/重做                                                        |
