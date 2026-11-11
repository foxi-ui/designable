---
title: 增加自定义组件
description: 从编辑态和渲染态两个角度讲解如何在 Designable 中注册自定义组件，涵盖模块结构、物料配置、属性面板、画布渲染和与 Formily 字段的对接步骤。
outline: deep
---

# 增加自定义组件

::: info 来源与授权
本文转载自陈豪（xjchenhao）的语雀文章《增加自定义组件》，原文链接：<https://www.yuque.com/xjchenhao/development/dhv90n>，原文发布时间：2022-03-17。

作者在原文中声明：本文为原创文章，如需转载，请注明来源并保留原文链接 xjchenhao，谢谢！

本站仅将原文从语雀格式转换为 Markdown，并调整了标题与代码块格式，技术内容未做改动。文章版权归原作者所有；如作者要求下架，请联系删除。
:::

想要拓展一个 designable 工程的自定义组件，需要拓展两个不同的组件。分别是：

1. “编辑态”组件。在编辑阶段时使用，它可能包含一些操作按钮，参看官方 demo 里的“自增表格”组件
2. “渲染态”组件。在渲染阶段时使用，它是单纯的渲染组件，是真正交付到客户端使用的组件。它可以单纯的当作 antd 的 ProComponents 使用。

## “编辑态”组件开发

自定义组件包含三个部分，分别是：

- template：组件模板
- Behavior：组件行为的描述
- Resource：组件资源的描述

### 一码胜千言

```tsx
import { createBehavior, createResource } from '@designable/core'
import { createFieldSchema } from '@designable/formily-antd'
import { DnFC } from '@designable/react'

// 组件模版，这部分可以写的很复杂
export const CustomComponent: DnFC = ({ ...props }) => {
  // props对应Resource的x-component-props
  return (
    <div>
      {/* 也可以以高级组件的形式使用：{props.children}*/}
      <input type="text" {...props} />
    </div>
  )
}

// 组件行为的描述
CustomComponent.Behavior = createBehavior({
  name: 'CustomComponent',
  extends: ['Field'], // 好像只能填Field
  selector: (node) => node.props['x-component'] === 'CustomComponent', // 与Resource的x-component的值匹配上才生效
  designerProps: {
    // createFieldSchema的值如果是空对象，则“属性配置”面板中没有“组件属性”。
    // 如果把createFieldSchema换成createVoidFieldSchema函数，字段属性一栏将只保留必要的配置项。
    propsSchema: createFieldSchema({
      type: 'object',
      properties: {
        customFieldName: {
          type: 'number',
          title: '字段属性',
          'x-decorator': 'FormItem',
          'x-component': 'NumberPicker',
          'x-component-props': {
            defaultValue: 100,
          },
        },
      },
    }),
  },

  // 语言翻译
  designerLocales: {
    'zh-CN': {
      title: '我的输入框',
      settings: {
        'x-component-props': {
          customFieldName: '自定义字段名称',
        },
      },
    },
    'en-US': {
      title: 'Input',
      settings: {
        'x-component-props': {
          customFieldName: 'customFieldName',
        },
      },
    },
  },
})

// 组件资源的描述
CustomComponent.Resource = createResource({
  icon: 'InputSource', // 体现在组件栏的icon
  elements: [
    {
      componentName: 'Field', // 好像只能填Field

      // 下面的传参 就是formily的Field的属性配置。具体见此链接的文末：https://www.formilyjs.org/zh-CN/guide/quick-start#%E5%85%B7%E4%BD%93%E7%94%A8%E4%BE%8B
      props: {
        type: 'String', // 返回的数据类型，
        title: '你好呀', // 对应“属性设置”里的标题字段
        'x-decorator': 'FormItem', // 目前只有`FormItem`值会改变组件形态为“表单字段”，填其它值跟没写没有两样。如果不希望组件以表单字段的形式呈现，不写x-decorator和title字段即可。
        'x-component': 'CustomComponent', // 对应的组件
        // 组件“属性设置”的默认值，也会体现在组件的props中。
        'x-component-props': {
          placeholder: '占位占位',
          maxLength: 3,
        },
      },
    },
  ],
})
```

### 模块结构

上述代码把组件、组件属性、组件语言翻译耦合在一个文件中，最好做如下解耦。

> 官方示例[看这里](https://github.com/alibaba/designable/blob/main/formily/antd/src/index.ts)

```bash
.
├── components
│   ├── CustomComponent
│   │   ├── index.ts
│   │   └── preview.tsx
│   └── index.ts
├── index.ts
├── locales
│   ├── Input.ts
│   ├── all.ts
│   └── index.ts
└── schemas
    ├── Input.ts
    ├── all.ts
    └── index.ts
```

## “渲染态”组件开发

渲染态的组件开发相对比较简单，参看[官方示例](https://github.com/alibaba/formily/blob/formily_next/packages/antd/src/index.ts)很容易就能写出来。

### 一码胜千言

```tsx
import React from 'react'
export const QueryList: React.FC = ({ ...props }) => {
  console.log(props) // 以此接收配置的参数。

  return (
    <div {...props}>
      <p>我是自定组件</p>
    </div>
  )
}
```
