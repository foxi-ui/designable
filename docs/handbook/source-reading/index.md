---
title: 源码阅读系列（转载）
description: 陈豪（xjchenhao）的 Designable 源码阅读系列，共 8 篇，覆盖工程结构、运行与二开、全局注册、自定义组件、响应器和常见问题，按作者声明转载并注明出处。
outline: deep
---

# Designable 源码阅读（转载）

::: warning 来源与授权
本系列转载自陈豪（xjchenhao）的语雀专栏「designable 源码阅读」：<https://www.yuque.com/xjchenhao/development>。

作者在每篇文章中声明：**本文为原创文章，如需转载，请注明来源并保留原文链接 xjchenhao，谢谢！**

本站在作者声明的范围内转载，并在每篇文章顶部保留作者、原文链接和发布时间。文章版权归原作者所有；如作者要求下架，请联系删除。
:::

::: tip 阅读提示
本系列写于 2022–2023 年，部分 API 与当前仓库 HEAD 存在差异。建议先读主手册的[快速开始](../getting-started)和[架构与对象模型](../architecture)，再结合本系列理解源码细节；遇到不一致处以当前源码为准。
:::

## 系列文章

| #   | 文章                                                                   | 主题                                         | 原文                                                                 |
| --- | ---------------------------------------------------------------------- | -------------------------------------------- | -------------------------------------------------------------------- |
| 01  | [designable 工程结构](./01-project-structure)                          | 目录结构、各包职责、工程配置                 | [语雀](https://www.yuque.com/xjchenhao/development/rncluc)           |
| 02  | [运行与二开](./02-run-and-customize)                                   | 本地运行、Antd v4 → v5、常见构建问题         | [语雀](https://www.yuque.com/xjchenhao/development/gaw7kwshnsmldlsi) |
| 03  | [designable 代码提交规范](./03-commit-convention)                      | `cz-conventional-changelog` 与提交校验       | [语雀](https://www.yuque.com/xjchenhao/development/tmdayt)           |
| 04  | [「表单设计器开发指南」的内容补充](./04-form-builder-guide-supplement) | React 层、shared、settings-form 的组件与 API | [语雀](https://www.yuque.com/xjchenhao/development/gt1k7i)           |
| 05  | [全局注册与状态管理](./05-global-registry)                             | `GlobalRegistry`、语言、图标与行为注册       | [语雀](https://www.yuque.com/xjchenhao/development/fp8gv5)           |
| 06  | [增加自定义组件](./06-custom-components)                               | 编辑态/渲染态组件、Behavior、Resource        | [语雀](https://www.yuque.com/xjchenhao/development/dhv90n)           |
| 07  | [响应器的使用](./07-reactions)                                         | Formily 响应器的函数上下文与常用写法         | [语雀](https://www.yuque.com/xjchenhao/development/ktq6dm)           |
| 08  | [常见问题](./08-faq)                                                   | 外链依赖、自定义扩展、联动等 FAQ             | [语雀](https://www.yuque.com/xjchenhao/development/qggv7f)           |

## 转载说明

- 原文为语雀 Lake 格式，本站转换为 Markdown；仅调整标题层级、代码块格式与图片路径，技术内容未做改写。
- 原文中的配图已下载到站点 `public/yuque/` 下，以保证访问稳定；图片版权归原作者所有。
- 每篇文章顶部的「来源与授权」块保留了作者、原文链接与发布时间。

完整的来源清单见[内容来源与授权](../appendix/sources)。
