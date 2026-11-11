---
title: 「表单设计器开发指南」的内容补充
description: 对官方《表单设计器开发指南》的补充说明。
outline: deep
---

# 「表单设计器开发指南」的内容补充

::: info 来源与授权
本文转载自陈豪（xjchenhao）的语雀文章《「表单设计器开发指南」的内容补充》，原文链接：<https://www.yuque.com/xjchenhao/development/gt1k7i>，原文发布时间：2022-03-03。

作者在原文中声明：本文为原创文章，如需转载，请注明来源并保留原文链接 xjchenhao，谢谢！

本站仅将原文从语雀格式转换为 Markdown，并调整了标题与代码块格式，技术内容未做改动。文章版权归原作者所有；如作者要求下架，请联系删除。
:::

官方使用 designable 工程开发了“[表单设计器](https://www.formilyjs.org/zh-CN/guide/form-builder)”，事实上 designable 不局限于此，做页面设计器、bi 设计器都可以。

目前[designable 工程](https://github.com/alibaba/designable)暂时没有开发文档，可以参看[这篇文章](https://www.yuque.com/xjchenhao/development/rncluc)进行了解。当然不看也可以，因为我们并不是要去开发 designable 工程，而是使用 designable 里的模块而已，就像我们只需要会用 antd 的组件库，而不需要掌握 antd 开源工程一样。

## @designable/react

### observer

observer 是一个 HOC， Function Component 变成 Reaction，每次视图重新渲染就会收集依赖，依赖更新会自动重渲染

使用方式参看：

- @formily/react 文档的 observer 部分。
- @formily/reactive 文档的 observer 部分。

### SettingsPanel

右侧配置表单布局面板。

| Name  | Description                                                             | Type     | Default |
| ----- | ----------------------------------------------------------------------- | -------- | ------- |
| title | 标题，支持 [DesignerLocales](./05-global-registry#全局语言翻译)<br>规则 | `string` | ''      |

### Workspace

工作区组件，是一个 HOC。用于管理工作区内的拖拽行为，树节点数据等等。

| Name        | Description                         | Type     | Default |
| ----------- | ----------------------------------- | -------- | ------- |
| id          | 需要多个工作区时需要各配置唯一的 ID | `string` | 'index' |
| title       | 标题                                | `string` | ''      |
| description | 描述                                | `string` | ''      |

> title 和 description 字段在源码中没有看到使用，应该是预留字段。

### WorkspacePanel

工作区布局面板，纯粹的布局组件（如果把设计器分为左中右三部分，工作区布局面板就是中间部分的“壳”），挂了`.dn-workspace-panel`样式，仅此而已。

不过它的子组件`WorkspacePanel.Item`在其它地方用的满多的，比如 ToolbarPanel、ViewportPanel 都是用它做跟组件。

#### WorkspacePanel.Item

设置`display:flex`对容器里，使用本组件，可以方便的通过`flexable`属性配置 flex-grow 和 flex-shrink 的开启与关闭。

> 如果对 flex-grow、flex-shrink 不了解，可以[看这里](https://zhuanlan.zhihu.com/p/39052660)。

一码胜千言：

```tsx
WorkspacePanel.Item = (props) => {
  const prefix = usePrefix('workspace-panel-item')
  return (
    <div
      className={prefix}
      style={{
        ...props.style,
        flexGrow: props.flexable ? 1 : 0,
        flexShrink: props.flexable ? 1 : 0,
      }}
    >
      {props.children}
    </div>
  )
}
```

### ToolbarPanel

工具栏布局面板（设计器最中心区域上面的“操作区”），包括撤销、选择、视图切换等操作。

一码胜千言：

```tsx
<WorkspacePanel.Item
  {...props}
  style={{
    display: 'flex',
    justifyContent: 'space-between',
    marginBottom: 4,
    padding: '0 4px',
    ...props.style,
  }}
>
  {props.children}
</WorkspacePanel.Item>
```

### ViewportPanel

工具栏布局面板（设计器最中心区域的“编辑区”），它用模拟器组件`Simulator`给子组件做了布局（它的介绍就在楼下）。

一码胜千言：

```tsx
<WorkspacePanel.Item {...props} flexable>
  <Simulator>{props.children}</Simulator>
</WorkspacePanel.Item>
```

### Simulator

视图模拟器组件，通过适当配置，可以实现给中间的操作区套上“手机壳”、“自适应壳“的展示。

一码胜千言：

```tsx
export const Simulator: React.FC<ISimulatorProps> = observer(
  (props: ISimulatorProps) => {
    const screen = useScreen() // useScreen()的返回值等于`globalThisPolyfill['__DESIGNABLE_ENGINE__'].screen`
    if (screen.type === ScreenType.PC)
      return <PCSimulator {...props}>{props.children}</PCSimulator>
    if (screen.type === ScreenType.Mobile)
      return <MobileSimulator {...props}>{props.children}</MobileSimulator>
    if (screen.type === ScreenType.Responsive)
      return (
        <ResponsiveSimulator {...props}>{props.children}</ResponsiveSimulator>
      )
    return <PCSimulator {...props}>{props.children}</PCSimulator>
  },
  {
    scheduler: requestIdle,
  }
)
```

### ViewPanel

视图布局面板，也就是设计器最中心区域的“壳”。它是四种视图模式（可视化设计、json、jsx、预览）的容器组件，并给子组件赋能。

| Name              | Description                                                                           | Type      | Default      |
| ----------------- | ------------------------------------------------------------------------------------- | --------- | ------------ |
| type              | 容器类型，用于标识它是什么视图模式的容器                                              | `string`  | 'DESIGNABLE' |
| scrollable        | 容器的内容溢出是否需要滚动条，如果开启样式的 overflow 等于 overlay，关闭则为 hidden。 | `boolean` | true         |
| dragTipsDirection | 可视化设计（type=DESIGNABLE）的模式时，缺省状态的操作动画，从左往右还是从右往左。     | `string`  | 'left'       |

子组件的上下文中可以获取到`ViewPanel`提供的 tree 变量，完成一次配置多处使用的设计。如下：

```jsx
<ViewportPanel style={{ height: '100%' }}>
  <ViewPanel type="DESIGNABLE" dragTipsDirection="left">
    {() => <ComponentTreeWidget components={{ Input }} />}
  </ViewPanel>

  <ViewPanel type="JSONTREE" scrollable={false}>
    {(tree, onChange) => <SchemaEditorWidget tree={tree} onChange={onChange} />}
  </ViewPanel>

  <ViewPanel type="MARKUP" scrollable={false}>
    {(tree) => <MarkupSchemaWidget tree={tree} />}
  </ViewPanel>

  <ViewPanel type="PREVIEW">
    {(tree) => <PreviewWidget tree={tree} />}
  </ViewPanel>
</ViewportPanel>
```

另外，ViewPanel 会在被导入时自动获取`workbench.type`，在四种视图模式中选择需要展示的状态。

### StudioPanel

主布局面板，整个工程的壳。

| Name    | Description      | Type        | Default |
| ------- | ---------------- | ----------- | ------- |
| logo    | 左上角的 logo 区 | `reactNode` | ---     |
| actions | 右上角的操作区   | `reactNode` | ---     |

### CompositePanel

左侧组合布局面板

| Name             | Description                                                                                                        | Type                   | Default          |
| ---------------- | ------------------------------------------------------------------------------------------------------------------ | ---------------------- | ---------------- | --- |
| direction        | 大类的分组（包含组件、大纲树、历史记录 icon 的小区域）包含放在组件板块的左侧还是右侧                               | `string`               | 'left'           |
| showNavTitle     | 是否需要在大类的 icon 下显示标题                                                                                   | `boolean`              | false            |
| defaultOpen      | 是否默认展开                                                                                                       | `boolean`              | true             |
| defaultPinning   | 是否默认“固定”面板<br>只有 direction="right"时才能看到效果，因为没有叠放在设计区上面，体现不出“固定”的作用         | `boolean`              | false            |
| defaultActiveKey | 默认展示哪个分组，注意下标从 0 开始                                                                                | `number`               | 0                |
| activeKey        | 展示哪个分组，如果是 number 则按“下标”显示，如果是 string 则与其子组件`CompositePanel.Item`<br>的`key`<br>字段对应 | `number \\             | string`          | --- |
| onChange         | 切换时触发的回调函数（开始切换就执行了，早于展示）                                                                 | `(activeKey: number \\ | string) => void` | --- |

#### CompositePanel.Item

各布局面板的配置

| Name  | Description                                                                                               | Type     | Default |
| ----- | --------------------------------------------------------------------------------------------------------- | -------- | ------- |
| title | 标题，支持 [DesignerLocales](./05-global-registry#全局语言翻译)<br>规则                                   | `string` | ---     |
| icon  | icon 标识。支持 [DesignerIcon](./05-global-registry#icon-svg-代码)<br>的内置 icon，也可以写 icon 资源路径 | `string` | ---     |
| key   | 组件标识，与 CompositePanel 组件的`activeKey`<br>字段配合使用                                             | `string` | ---     |

### ResourceWidget

组件资源编组容器。

| Name    | Description                                                             | Type                     | Default |
| ------- | ----------------------------------------------------------------------- | ------------------------ | ------- |
| title   | 标题，支持 [DesignerLocales](./05-global-registry#全局语言翻译)<br>规则 | `string`                 | ---     |
| sources | 包含的组件                                                              | `Array&lt;ReactNode&gt;` | ---     |

### useTheme

获取主题函数。执行`useTheme()`可获得`dark`or`light`。

- 如果什么都不干，获取到的永远都是'light'。
- 如果希望自己的设计器可以切换主题可以使用@designable/react 里的 Layout 组件做配置（需放在项目根目录）。

下面是“跟随系统的暗黑模式改变主题”的示例。

```tsx
import React, { useMemo } from 'react';
import {
  Layout,
} from '@designable/react';

import App from './App';

// 设置UI主题（是否暗黑模式）
const designerTheme = !window.matchMedia('(prefers-color-scheme: dark)').matches
  ? 'light'
  : 'dark';

export default function IndexPage() {
  return (
    <Layout theme={designerTheme}>
      <App />
    </Layout>
  );
```

## @designable/shared

该模块（主模块）里包含[多个子模块](https://github.com/alibaba/designable/blob/main/packages/shared/src/index.ts)。

- animation：组件的拖拽动画
- array：基础的的数组函数
- clone：拷贝函数
- coordinate：实现拖拽功能的计算函数集
- element：dom 元素的计算函数集
- event：事件引擎
- keycode：快捷键管理
- lru：实现动态缓存管理
- request-idle：封装了一下 requestIdleCallback
- scroller：实现拖拽自动滚动
- type：验证数据类型
- uid：提供了一个 uid 方法，用于给每个元素指定唯一的 key

它们里面的 api 均被注册在主模块的入口文件中，可以直接在顶层应用，例如：

```js
import { isPlainObj } from '@designable/shared' // isPlainObj是子模块types里的函数

const a = { a: 1 }
const b = [1, 2, 3]
const c = '123'

console.log(isPlainObj(a)) // true
console.log(isPlainObj(b)) // false
console.log(isPlainObj(c)) // false
```

### types

做数据类型的验证。

| Name          | Description                                                                                                |
| ------------- | ---------------------------------------------------------------------------------------------------------- |
| isStr         | 是否是字符串                                                                                               |
| isNum         | 是否是数字                                                                                                 |
| isBool        | 是否是布尔型                                                                                               |
| isFn          | 是否是函数                                                                                                 |
| isPlainObj    | 是否是字面量形式或者 new Object()形式定义的对象                                                            |
| isObj         | 是否是对象。<br>这个比较泛，例如数组也会返回为 true，需要验证严谨的 object 类型，请使用 `isPlainObj`<br>。 |
| isRegExp      | 是否是正则表达式                                                                                           |
| isArr         | 是否是数组                                                                                                 |
| isValid       | 验证值是否存在                                                                                             |
| isFn          | 是否是函数                                                                                                 |
| isHTMLElement | 是否是 html 的 dom 节点                                                                                    |

除此之外，还提供了一个取值函数。

| Name    | Description                                                                    |
| ------- | ------------------------------------------------------------------------------ |
| getType | 获取数据类型。<br>返回 Object.prototype.toString 的结果，例如：[object Number] |

### element

dom 元素的计算函数集。

| Name                  | Description                                      | Type                                                         | Default       |
| --------------------- | ------------------------------------------------ | ------------------------------------------------------------ | ------------- | ---------- |
| calcElementLayout     | 计算元素的布局方式，是水平（内链）还是垂直（块） | `(element: Element) => "vertical" \\                         | "horizontal"` | 'vertical' |
| calcElementOuterWidth | 计算元素的宽度                                   | `(innerWidth: number, style: CSSStyleDeclaration) => number` | 'vertical'    |

### coordinate

实现拖拽功能的计算函数集。

先看下定义的几个接口类型，内部一直在使用（外面能用，export 出去了）。

```ts
// 点的位置
export interface IPoint {
  x: number
  y: number
}

// 点的类形态
export class Point implements IPoint {
  x: number
  y: number
  constructor(x: number, y: number) {
    this.x = x
    this.y = y
  }
}

// 矩形，包含起点坐标以及宽高
export interface IRect {
  x: number
  y: number
  width: number
  height: number
}

// 象限，框选多个组件时使用（猜测：内部指试图区域内，外部指试图区域外）
export enum RectQuadrant {
  Inner1 = 'I1', //内部第一象限
  Inner2 = 'I2', //内部第二象限
  Inner3 = 'I3', //内部第三象限
  Inner4 = 'I4', //内部第四象限
  Outer1 = 'O1', //外部第一象限
  Outer2 = 'O2', //外部第二象限
  Outer3 = 'O3', //外部第三象限
  Outer4 = 'O4', //外部第四象限
}

export interface IPointToRectRelative {
  quadrant: RectQuadrant
  distance: number
}
```

| Name                      | Description                                                                                                                                                   | Type                                                                       | Default |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------- |
| isPointInRect             | 点是否在矩形内，前两个参数分别是点和矩形。<br>第三个参数是“是否敏感”，如果关闭，点在矩形内就可以返回 true 了；如果关闭，点在矩形的宽高-10%的范围内才返回 true | `(point: IPoint, rect: IRect, sensitive?: boolean) => boolean`             | ---     |
| getRectPoints             | 返回矩形的四个点的坐标                                                                                                                                        | `(source: IRect) => Point[]`                                               | ---     |
| isRectInRect              | 矩形是否在矩形内，前两个参数分别是点和矩形。                                                                                                                  | `(target: IRect, source: IRect) => boolean`                                | ---     |
| isCrossRectInRect         | 两个矩形是否存在交集                                                                                                                                          | `(target: IRect, source: IRect) => boolean`                                | ---     |
| calcQuadrantOfPonitToRect | 计算点在矩形的哪个象限                                                                                                                                        | `(point: IPoint, rect: IRect) => RectQuadrant`                             | ---     |
| calcDistanceOfPointToRect | 点跟矩形之间的距离                                                                                                                                            | `(point: IPoint, rect: IRect) => number`                                   | ---     |
| calcDistancePointToEdge   | 点到边之间的距离                                                                                                                                              | `(point: IPoint, rect: IRect) => number`                                   | ---     |
| isNearAfter               | 计算点的位置是否在矩形的下方或者右下方<br>比如拖拽组件时，把组件放置在另一个组件的“下方或者右下方”可以视为插入在其后面，否则就插入到其前面                    | `(point: IPoint, rect: IRect, inline?: boolean) => boolean`                | ---     |
| calcRelativeOfPointToRect | 点在矩形里的相对位置                                                                                                                                          | `(point: IPoint, rect: IRect) => IPointToRectRelative`                     | ---     |
| calcBoundingRect          | 可以把多个矩形合并计算成一个更大的矩形                                                                                                                        | `(rects: IRect[]) => IRect`                                                | ---     |
| calcRectByStartEndPoint   | 按起点和终点计算矩形                                                                                                                                          | `startPoint: IPoint, endPoint: IPoint, scrollX?: number, scrollY?: number` | ---     |

### request-idle

基于[requestIdleCallback](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/requestIdleCallback)实现“函数在浏览器空闲时被调用”。

| Name        | Description                                                                | Type                                                             | Default |
| ----------- | -------------------------------------------------------------------------- | ---------------------------------------------------------------- | ------- |
| requestIdle | 预执行函数，返回函数 requestIdleCallbackId                                 | `(callback: function, options?: { timeout?: number} ) => number` | ---     |
| cancelIdle  | 需要清除的预执行函数（如果还没有被执行的话），需传递 requestIdleCallbackId | `(id: number) => void`                                           | ---     |

### uid

只提供了一个 uid 方法，返回指定长度的随机字符串（字母+数字），用于给每个元素指定唯一的 key

| Name | Description | Type     | Default                       |
| ---- | ----------- | -------- | ----------------------------- |
| len  | 字符串长度  | `string` | 11 位包含字母数字的随机字符串 |

文件里代码蛮短的，可以读一下：

```js
let IDX = 36,
  HEX = ''
while (IDX--) HEX += IDX.toString(36) // 通过依次从36到1转十六进制，最终返回`zyxwvutsrqponmlkjihgfedcba9876543210`

export function uid(len?: number) {
  let str = '',
    num = len || 11

  while (num--) str += HEX[(Math.random() * 36) | 0] // 根据长度，给str拼接随机字符
  return str
}
```

### globalThisPolyfill

全局变量，从模块里解构出来直接用就行了。

如果在浏览器环境就是 window，如果是 node 环境 就是 global。

> 可以给全局对象增加 globalThisPolyfill 属性。
>
> 返回优先级：`window > 全局变量的 globalThisPolyfill 属性 > global`

## @designable/react-settings-form

### SettingsForm

右侧设置面板组件（具体如何作拓展配置，待完善）

| Name         | Description  | Type     | Default |
| ------------ | ------------ | -------- | ------- |
| uploadAction | 资源上传地址 | `string` | ---     |
