---
title: 全局注册与状态管理
description: GlobalRegistry 的语言、图标与行为注册机制。
outline: deep
---

# 全局注册与状态管理

::: info 来源与授权
本文转载自陈豪（xjchenhao）的语雀文章《全局注册与状态管理》，原文链接：<https://www.yuque.com/xjchenhao/development/fp8gv5>，原文发布时间：2022-02-23。

作者在原文中声明：本文为原创文章，如需转载，请注明来源并保留原文链接 xjchenhao，谢谢！

本站仅将原文从语雀格式转换为 Markdown，并调整了标题与代码块格式，技术内容未做改动。文章版权归原作者所有；如作者要求下架，请联系删除。
:::

`@designable/core`中提供了`GlobalRegistry`，可用来做语言翻译、Icon svg 代码以及全局行为的管理，可以理解为 vuex、redux。

## 全局语言翻译

通过`@designable/core`提供的全局状态管理对象`GlobalRegistry`提供的`registerDesignerLocales`方法，可以进行全局语言 map 的管理。

### 代码示例

设计器最左侧的“左侧组合布局面板的翻译配置”如下

```js
GlobalRegistry.registerDesignerLocales({
  'zh-CN': {
    panels: {
      Component: '组件',
      OutlinedTree: '大纲树',
      PropertySettings: '属性配置',
      History: '历史记录',
    },
  },
  'en-US': {
    panels: {
      Component: 'Component',
      OutlinedTree: 'Outlined Tree',
      PropertySettings: 'Property Settings',
      History: 'History',
    },
  },
  'ko-KR': {
    panels: {
      Component: '컴포넌트',
      OutlinedTree: '트리 노드',
      PropertySettings: '속성 설정',
      History: '기록',
    },
  },
})
```

组件栏里组件的“分组名翻译配置”如下

```js
GlobalRegistry.registerDesignerLocales({
  'zh-CN': {
    sources: {
      Inputs: '输入控件',
      Layouts: '布局组件',
      Arrays: '自增组件',
      Displays: '展示组件',
    },
  },
  'en-US': {
    sources: {
      Inputs: 'Inputs',
      Layouts: 'Layouts',
      Arrays: 'Arrays',
      Displays: 'Displays',
    },
  },
  'ko-KR': {
    sources: {
      Inputs: '입력',
      Layouts: '레이아웃',
      Arrays: '배열',
      Displays: '디스플레이',
    },
  },
})
```

### 格式说明

其中对象的第一层 key 为“语言类型”，第二层为“分组名”，第三层为“具体的字段翻译字段”。

DesignerLocales 中部分“分组名”是内置的，比如前面案例提及的`panels`是`@designable/react`的`CompositePanel`中内置的，需避免**命名冲突**。

如果本意就是想修改它，重新通过`GlobalRegistry.registerDesignerLocales`函数配置即可。

### 根据语言设置取值

通过`@designable/react`的`TextWidget`组件可以翻译它内部的文本。

比方说，我们做了如下注册：

```js
GlobalRegistry.registerDesignerLocales({
  'zh-CN': {
    product: {
      name: '名称',
    },
  },
  'en-US': {
    product: {
      name: 'Name',
    },
  },
})
```

通过`setDesignerLanguage`设置语言，通过`TextWidget`渲染内容：

```js
import { useDesigner, TextWidget } from '@designable/react'
GlobalRegistry.setDesignerLanguage('zh-cn') // 通常这部分时放在某个全局的组件里做“语言选择”即可，不需要每次都设置。

export const ProductNameWidget = () => {
  return <TextWidget>product.name</TextWidget>
}
```

> 很多`@designable/react`提供的组件内部都使用了`TextWidget`组件来实现语言翻译。例如`CompositePanel.Item`、`ResourceWidget`的 title 等字段。

### 内置的`registerDesignerLocales`配置

`@designable/react`提供的组件内置了以下内容。

- global
- panels
- icons
- operations

具体内容请移步[github 源码](https://github.com/alibaba/designable/tree/main/packages/react/src/locales)，这里不做赘述。

## Icon SVG 代码

在我们开始使用`@designable/react`的`Designer`组件时，就会通过`GlobalRegistry.registerDesignerIcons()`全局注册 icon 的 svg 代码。

### 内置 Icon

具体内容请移步[github 源码](https://github.com/alibaba/designable/blob/main/packages/react/src/icons/index.ts)，这里不做赘述。

我们可以通过`GlobalRegistry.getDesignerIcon()`方便的获取到对应的 svg 代码。

### 代码示例

以下是添加自己的 icon 的示例。

```js
import {GlobalRegistry} from '@designable/core';

// 全局注册icon
GlobalRegistry.registerDesignerIcons({
  'add':<svg viewBox="64 64 896 896">
  <path d="M482 152h60q8 0 8 8v704q0 8-8 8h-60q-8 0-8-8V160q0-8 8-8z"></path>
  <path d="M176 474h672q8 0 8 8v60q0 8-8 8H176q-8 0-8-8v-60q0-8 8-8z"></path>
</svg>;

export const AddIconWidget = () => {
  return GlobalRegistry.getDesignerIcon('add'); // icon取值
};
```

> 很多`@designable/react`提供的组件内部都使用了`GlobalRegistry.getDesignerIcon()`函数来实现 icon 图标的配置。例如`CompositePanel.Item`的 icon 字段等。
