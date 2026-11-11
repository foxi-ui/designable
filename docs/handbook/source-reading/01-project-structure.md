---
title: designable工程结构
description: Designable 仓库的目录结构与包职责。
outline: deep
---

# designable 工程结构

::: info 来源与授权
本文转载自陈豪（xjchenhao）的语雀文章《designable 工程结构》，原文链接：<https://www.yuque.com/xjchenhao/development/rncluc>，原文发布时间：2022-02-24。

作者在原文中声明：本文为原创文章，如需转载，请注明来源并保留原文链接 xjchenhao，谢谢！

本站仅将原文从语雀格式转换为 Markdown，并调整了标题与代码块格式，技术内容未做改动。文章版权归原作者所有；如作者要求下架，请联系删除。
:::

## 前言

designable 工程是 alibaba 团队开源的设计器工程，由于官网提供的[《表单设计器开发指南》](https://www.formilyjs.org/zh-CN/guide/form-builder)交付的内容太少了，遂做了如下内容补充。

阅读源码前第一步熟悉工程结构，就像看书前最好先了解书的结构和作者的思想一样，熟悉了工程结构就不容易盲人摸象。

> 同时只有能给别人讲清楚，才说明你真的懂了。

## 目录结构

```bash
.
├── CHANGELOG.md											// 更新日志
├── README.md													// 工程文档
├── examples
│   ├── basic													// designable基础工程，没有组件和属性可以配置。
│   ├── multi-workspace								// 多个展示区的designable
│   ├── sandbox												// 对应basic的沙箱工程
│   └── sandbox-multi-workspace				// 对应multi-workspace的沙箱工程
├── formily
│   ├── antd													// 适配了designable的antd组件库，相当于designable的物料，即左侧“组件区”。
│   ├── next													// 适配了designable的Fusion组件库，相当于designable的物料，即左侧“组件区”。
│   ├── setters												// 做右侧“属性设置”的模块
│   └── transformer										// 做“TreeNode与Schema格式互转”的模块
├── jest.config.js
├── lerna.json												// 多包管理lerna的配置文件
├── package.json											// 工程描述
├── packages													// 被lerna做多包管理的npm包
│   ├── core
│   ├── react
│   ├── react-sandbox
│   ├── react-settings-form
│   └── shared
├── scripts														// 工程级别的通用js
│   ├── build-style										// 发布样式，从src目录下copy到esm和lib目录下。
│   ├── global.ts											// 全局变量的配置（目前看来只有下面的jest.base.js在用）
│   ├── jest.base.js									// 单元测试工具jest的配置（目前看来工程没有完善单元测试）
│   ├── release												// 根据git提交记录，生成工程的修改日志，也就是工程根目录下的CHANGELOG.md文件
│   ├── rollup.base.js								// 工程使用rollup做构建，类似webpack
│   └── validate-commit-msg.js				// git提交时会执行此js做日志规范检查
├── tsconfig.build.json								// 在build时使用的typescript配置
├── tsconfig.jest.json								// 用jest时使用的typescript配置
└── tsconfig.json											// 开发时使用的typescript配置
```

## 文件速览

### examples

演示工程文件夹，里面是各种场景的演示工程。

> ps：事实上 formily 文件夹下还有两个演示工程，[具体见下文](#wJc7Z)。

#### basic

designable 基础工程，没有组件和属性可以配置。

![image.png](/yuque/rncluc/image-01.png)

#### multi-workspace

多个展示区的 designable，不确定能做什么，或许做弹窗之类的交互可以用。不过知道能做这件，需要用时能想到它就可以了。

![image.png](/yuque/rncluc/image-02.png)

#### sandbox\*

sandbox 以及 sandbox-multi-workspace 分别是前面两个工程的沙箱模式，但是具体是做什么用的，暂不清楚。

### formily

要基于 formily 生态完成 designable 工程的必备模块，以及相关的演示工程。

#### antd

适配了 designable 的 antd 组件库，相当于 designable 的物料，即左侧“组件区”。对应 npm 包[@formily/antd](https://www.npmjs.com/package/@formily/antd)。

同时配套了演示工程，可以在当前目录下执行 start 脚本，看到如下内容。

![image.png](/yuque/rncluc/image-03.png)

#### next

这里的 next 其实就是阿里的[Fusion 组件库](https://fusion.design/)。

所以本目录的，其实是适配了 designable 的 Fusion 组件库，相当于 designable 的物料，即左侧“组件区”。对应 npm 包[@formily/next](https://www.npmjs.com/package/@formily/next)。

同时配套了演示工程，可以在当前目录下执行 start 脚本，看到如下内容。

> 另外，我们会发现用 antd 和 Fusion 做出来的效果几乎一摸一样，说明 designable 可以适配各种上层组件库。

![image.png](/yuque/rncluc/image-04.png)

#### setters

做右侧“属性设置”的模块，对应 npm 包[@designable/formily-setters](https://www.npmjs.com/package/@designable/formily-setters)，前面的 antd 和 next 工程都依赖它而实现界面右侧的“属性配置”。

#### transformer

做“TreeNode 与 Schema 格式互转”的模块，对应 npm 包[@designable/formily-transformer](https://www.npmjs.com/package/@designable/formily-transformer)，前面的 antd 和 next 工程都依赖它实现“TreeNode 与 Schema 格式互转”。

### package.json

通过  `package.json`  文件可以看到工程依赖、yran 的 workspaces 配置、npm 脚本等信息。

#### script

先贴下代码，方便参考对照：

```json
"scripts": {
    "bootstrap": "lerna bootstrap",
    "clean": "lerna clean",
    "build": "rimraf -rf packages/*/{lib,esm} && lerna run build",
    "build:docs": "dumi build",
    "start": "dumi dev",
    "start:playground": "npm run start:basic",
    "start:basic": "yarn workspace @designable/basic-example start",
    "start:sandbox": "yarn workspace @designable/sandbox-example start",
    "start:multi-workspace": "yarn workspace @designable/multi-workspace-example start",
    "start:sandbox-multi-workspace": "yarn workspace @designable/sandbox-multi-workspace-example start",
    "test": "jest --coverage",
    "test:watch": "jest --watch",
    "test:prod": "jest --coverage --silent",
    "preversion": "npm run build && npm run lint",
    "version": "ts-node scripts/release changelog && git add -A",
    "version:alpha": "lerna version prerelease --preid alpha",
    "version:beta": "lerna version prerelease --preid beta",
    "version:rc": "lerna version prerelease --preid rc",
    "version:patch": "lerna version patch",
    "version:minor": "lerna version minor",
    "version:preminor": "lerna version preminor --preid beta",
    "version:major": "lerna version major",
    "release:github": "ts-node scripts/release release",
    "release:force": "lerna publish from-package --yes",
    "prelease:force": "lerna publish from-package --yes --dist-tag next",
    "release": "lerna publish",
    "prelease": "lerna publish --dist-tag next",
    "lint": "eslint --ext .ts,.tsx,.js  --fix",
    "postinstall": "opencollective-postinstall"
}
```

然后逐一解释：

- bootstrap 给被 lerna 管理的 npm 包，也就是 packages 目录里几个工程，一次性安装各自的依赖。
- clean 与 bootstrap 相反，清理各工程的 node_modules。
- buildbuild 出被 lerna 管理的 npm 包的结果，放在各自的 lib 和 esm 目录下，分别是对应 cjs 和 esm 两种格式。
- build:docs 生成工程主页，构建结果在工程根目录的 dist 文件夹里。（建议对照下面的 start 阅读）
- start 运行工程本身，也就是工程主页。它是基于 dumi 制作的，内容就是 README.md 的内容。
- start:*这里的*对应 examples 文件夹下的 4 个工程，使用这个命令可以快速运行这 4 个演示工程。
- test\*目前的 test 脚本似乎并没有相关的代码，仅体现了可以用 jest 做单元测试
- preversion 发版前运行一下这个脚本可以触发各依赖包的 build 和 eslint 检查。因为是 pre 开头，所以它会在执行下面的 npm run version 前先触发。
- version 根据 git 提交记录，生成工程的修改日志，也就是工程根目录下的 CHANGELOG.md 文件
- version:\*对各个模块进行版本迭代。具体来说是，标识出在上一个 tag 版本以来更新的 monorepo package，然后为这些包 prompt 出版本，在用户完成选择之后修改相关包的版本信息并且将相关的变动 commit 然后打上 tag 推送到 git remote。本质上是为一些发生变动的包进行了一个 bump version 的操作。
- release\*还有 prelease 都是发版相关脚本
- linteslint 代码检查以及 fix。
- opencollective-postinstall 运行本脚本会看到工程的众筹信息，但是 package.json 中并没有配置 collective 字段，因此暂无内容。

#### workspaces

由此可知，开发者主要是用 yarn 进行包管理，管理了如下三个 workspaces。

```json
"workspaces": [
  "packages/*",
  "formily/*",
  "examples/*"
]
```

#### lint-staged

因为安装了[lint-staged](https://www.npmjs.com/package/lint-staged)模块，因此可以配合[ghooks](https://www.npmjs.com/package/ghooks)，在`git commit`时触发`lint-staged`字段里的配置。

```json
"lint-staged": {
    "*.{ts,tsx,js}": [
      "eslint --ext .ts,.tsx,.js --fix",
      "pretty-quick --staged",
      "git add"
    ],
    "*.md": [
      "pretty-quick --staged",
      "git add"
    ]
}
```

具体来说，会对 ts、js 以及 tsx 文件，进行`eslint`格式校验与修复，并配合`pretty-quick`完成代码风格调整，如果都没有问题会对修复和调整后的代码做`git add`。（对`md`文件除了不做 eslint 检查，其它都是一样。）

#### config

```json
"config": {
    "ghooks": {
      "pre-commit": "lint-staged",
      "commit-msg": "node ./scripts/validate-commit-msg.js"
    },
    "commitizen": {
      "path": "./node_modules/cz-conventional-changelog"
    }
}
```

这里做了两个配置，分别对应[ghooks](https://www.npmjs.com/package/ghooks)和[cz-conventional-changelog](https://www.npmjs.com/package/cz-conventional-changelog)模块。

- ghooks 开启了 git hook，使用 git 的 commit 命令时会触发前面 lint-staged 字段配置的规则，以及通过 scripts/validate-commit-msg.js 对提交日志规范做检查。
- cz-conventional-changelog 配合使用 npm install -g commitizen 全局安装的 commitizen 可以很方便的创建符合提交规范的日志（如下图）。

![image.png](/yuque/rncluc/image-05.png)
