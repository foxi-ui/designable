---
title: 常见问题
description: Designable 使用中的常见问题与原因。
outline: deep
---

# 常见问题

::: info 来源与授权
本文转载自陈豪（xjchenhao）的语雀文章《常见问题》，原文链接：<https://www.yuque.com/xjchenhao/development/qggv7f>，原文发布时间：2022-03-09。

作者在原文中声明：本文为原创文章，如需转载，请注明来源并保留原文链接 xjchenhao，谢谢！

本站仅将原文从语雀格式转换为 Markdown，并调整了标题与代码块格式，技术内容未做改动。文章版权归原作者所有；如作者要求下架，请联系删除。
:::

## 为什么通过外链依赖了资源？

这是 JS 编译器[monaco](https://microsoft.github.io/monaco-editor/) 的依赖，因为体积比较大，不太好整合成进 designable 中。[[1]](https://github.com/alibaba/formily/discussions/1988)

## 官方文档什么时候会完善？

要到 2023 年年初。[[1]](https://github.com/alibaba/designable/discussions/240)

## 有没有自定义组件的成功经验？

可以看下这篇，开发 designable 内置组件缺少的步骤器(FormStep)经验分享。[[1]](https://github.com/alibaba/designable/discussions/136)

## 与阿里 lowcode-engine 的关系与区别是什么？

没啥关联。

[lowcode-engine](https://lowcode-engine.cn/)是打包型的产品，designable 就是设计器引擎，聚焦点不一样。[[1]](https://github.com/alibaba/designable/discussions/245#discussioncomment-2296490)

- designable 不负责包装产品，所以它的定位更像一个 library，它后面的路线是尽可能的优化设计器的各种设计能力
- 至于上层产品如何封装，是由用户自己发挥的。

ps：不过 designable 的组件树[ITreeNode](https://github.com/alibaba/designable/blob/171c64f989ac4f3ef2b22670e80ebc79d966956b/packages/core/src/models/TreeNode.ts)，是遵循阿里巴巴集团的[低代码协议](http://lowcode-engine.cn/lowcode)的。[[2]](https://github.com/alibaba/designable/discussions/240#discussioncomment-2278679)

## react-settings-form 内部组件如何自定义扩展？

先看下代码

```ts
import React from 'react'
import { Form } from '@formily/core'
export interface ISettingFormProps {
  className?: string
  style?: React.CSSProperties
  uploadAction?: string
  components?: Record<string, React.FC<any>>
  effects?: (form: Form) => void
  scope?: any
}
```

我们可以通过传递 components 和 effects 完成自定义拓展。（类似 formily1.x 的写法）[[1]](https://www.bilibili.com/video/BV1kq4y137fP?spm_id_from=333.999.0.0&t=1h32m36s)

组件封装的最佳案例，可以参看[源码](https://github.com/alibaba/designable/blob/0f3a887e75/packages/react-settings-form/src/components/index.ts)。

## 如何增加一个远程数据源

1. 直接在组件属性配置里的“响应器”里写 js 代码。(它有个好处，可以与页面其它元素各种联动)
2. 扩展自定义组件，这个组件的属性配置中可以移除“响应器”，增加“api 传参配置”。与上传组件类似。[1]

## 对组件的显示、隐藏属性，只想在渲染时生效，在配置时的设计界面不生效（即不隐藏），怎么实现？

这个涉及到“画布态”和“运行态”的概念，“画布态”是基于[Field 组件](https://github.com/alibaba/designable/blob/0f3a887e75/formily/antd/src/components/Field/preview.tsx)渲染的。

可以通过复写 `Field 组件`实现，在`ComponentTreeWidget`组件[挂载 field 组件](https://github.com/alibaba/designable/blob/0f3a887e75/formily/antd/playground/main.tsx#L181)时做替换。

这样就组件的显示/隐藏就完全由自己控制了。[[1]](https://www.bilibili.com/video/BV1kq4y137fP?spm_id_from=333.999.0.0&t=1h39m15s)

## 响应器配置，当前的模式是被动依赖，后续会支持主动依赖模式吗？

不会考虑，建议做个自定义组件。[[1]](https://www.bilibili.com/video/BV1kq4y137fP?spm_id_from=333.999.0.0&t=1h42m20s)

## 如果接入类似于 button 这种组件的话，想与其他的组件进行联动例如触发 form 的提交，触发 modal 的显示，目前的推荐方法是？（目前似乎只支持被动依赖这个不知道有没有具体的实现方案？）

建议增加带 submit 按钮的 form 组件，在点击 submit 按钮时获取 form 组件的 `props.values` 拿到表单数据。[[1]](https://www.bilibili.com/video/BV1kq4y137fP?spm_id_from=333.999.0.0&t=1h50m30s)
