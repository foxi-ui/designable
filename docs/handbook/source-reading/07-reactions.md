---
title: 响应器的使用与联动
description: 介绍 Formily 响应器在 Designable 设置面板中的使用方式，包括函数上下文、常用语句、读取其他组件值、控制显隐与联动，以及常见写法和注意事项。
outline: deep
---

# 响应器的使用

::: info 来源与授权
本文转载自陈豪（xjchenhao）的语雀文章《响应器的使用》，原文链接：<https://www.yuque.com/xjchenhao/development/ktq6dm>，原文发布时间：2022-05-30。

作者在原文中声明：本文为原创文章，如需转载，请注明来源并保留原文链接 xjchenhao，谢谢！

本站仅将原文从语雀格式转换为 Markdown，并调整了标题与代码块格式，技术内容未做改动。文章版权归原作者所有；如作者要求下架，请联系删除。
:::

## 函数上下文

在配置响应器时，我们会看到边上有个案例区（Example），其中写道：

```js
/**
 * You can use the built-in context variables
 *
 * 1. `$self` is the current Field Model
 *
 * 2. `$form` is the current Form Model
 *
 * 3. `$deps` is the dependencies value
 *
 * 4. `$observable` function is used to create an persistent observable state object
 *
 * 5. `$memo` function is is used to create a persistent data
 *
 * 6. `$effect` function is used to handle side-effect logic
 *
 * 7. `$props` function is used to set component props to current field
 *
 * Document Links
 *
 * https://react.formilyjs.org/api/shared/schema#%E5%86%85%E7%BD%AE%E8%A1%A8%E8%BE%BE%E5%BC%8F%E4%BD%9C%E7%94%A8%E5%9F%9F
 **/
```

这里做下翻译：

1. $self 对象类型，存储了当前字段模型
2. $form 对象类型，存储了当前表单模型
3. $deps 数组类型，存储了当前字段的“依赖字段”，对应“配置响应器”弹窗最上面的“依赖字段”。
4. $observable 函数类型，用于创建一个持久的可观察状态对象
5. $memo 函数类型，用于创建持久化数据
6. $effect 函数类型，用于处理副作用逻辑
7. $props 函数类型，它的参数将会直接穿透给组件

- 比如用 antd 的组件制作了 designable 中的物料，通常会把组件的参数对接成“属性面板”中的配置
- 如果“属性面板”的配置参数有遗漏，可以通过$props 穿透给 antd 组件，做补位。

## 常用语句

### 取其它组件的值

1. 给其它组件设置“字段标识”，比如设置为 abc
2. 那么在配置响应器的高代码编辑区，可通过$form.values.abc 获取到它
