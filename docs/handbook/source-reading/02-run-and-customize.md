---
title: 运行与二开
description: 如何运行 Designable 工程并进行二次开发。
outline: deep
---

# 运行与二开

::: info 来源与授权
本文转载自陈豪（xjchenhao）的语雀文章《运行与二开》，原文链接：<https://www.yuque.com/xjchenhao/development/gaw7kwshnsmldlsi>，原文发布时间：2023-03-24。

作者在原文中声明：本文为原创文章，如需转载，请注明来源并保留原文链接 xjchenhao，谢谢！

本站仅将原文从语雀格式转换为 Markdown，并调整了标题与代码块格式，技术内容未做改动。文章版权归原作者所有；如作者要求下架，请联系删除。
:::

## 前言

如无必要，本人不建议你使用[designable](https://github.com/alibaba/designable)进行低代码页面设计器的开发，因为作者已在 github 上[明确表态](https://github.com/alibaba/designable/discussions/240#discussioncomment-5212878)，暂时不再更新。（推荐使用阿里的[Low-Code Engine](https://lowcode-engine.cn/index)进行开发）

![image.png](/yuque/gaw7kwshnsmldlsi/image-01.png)

本文档的整理也是基于这个背景下，从 antd4 升级到 antd5 的经验分享。

如果你跟我一样在坑里，或是义无反顾的决定投入 formily 生态的怀抱，那么就继续看下去吧。

## 运行

### 获取代码

本地没有代码就执行：`git clone git@github.com:alibaba/designable.git`，如果有了，就获取一下最新代码：`git pull`。

切换一下功能分支，比如：`git chekcout -b upgrade-antd5`。

### 安装依赖

为方便运行后续的命令，建议先全局安装`yarn`和`lerna`。

依次执行：

1. npm run bootstrap
2. yarn
3. npm run build

### 运行

你可以用以下两种方式运行

1. 使用 npm script 提供的 npm run start:playground 命令
2. 进入 examples/basic/目录下运行 npm run start

如果顺利你会看到如下页面：

![image.png](/yuque/gaw7kwshnsmldlsi/image-02.png)

## Antd v4 升级到 v5

待补充

## 可能遇到的问题

### build 分包时 ts 提示 toJSoN is missing

具体来说是在执行`npm run build`过程中提示以下错误

![原文配图](/yuque/gaw7kwshnsmldlsi/image-03.png)

于是我“骚”了一下，把它们都 any 了。

![原文配图](/yuque/gaw7kwshnsmldlsi/image-04.png)

等彻底跑通了，再回头从根本解决它。

> 改动文件如下：
>
> 1. src/effects/useFreeSelectionEffect.ts
> 2. src/hooks/useValidNodeOffsetRect.ts
> 3. src/widgets/AuxToolWidget/SnapLine.tsx

### 浏览器提示 antd、dayjs 的不存在

![image.png](/yuque/gaw7kwshnsmldlsi/image-05.png)

通过把`webpack.base.ts`里的`externals`配置移到`webpack.prod.ts`里可以解决。（代码片段如下）

```js
  externals: {
    react: 'React',
    'react-dom': 'ReactDOM',
    moment: 'moment',
    antd: 'antd',
  },
```

npm 模块确实不应该把 antd 等基础框架打包进去，它的体积会特别大，因此作者配置了 externals。

但写在`webpack.base.ts`里对开发环境也产生了影响，原则上我们只需要在`webpack.prod.ts`里就很足够了。

> ps：此外还有一种解决此问题的思路，就是在`template.ejs`里增加对应的资源加载。

因此，我修改了以下路径里的配置

1. examples/basic
2. examples/multi-workspace
3. examples/sandbox
4. examples/sandbox-multi-workspace
5. formily/next
6. formily/antd
