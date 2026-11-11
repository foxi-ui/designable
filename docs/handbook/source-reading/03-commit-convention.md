---
title: 代码提交规范与校验
description: 说明 Designable 仓库基于 cz-conventional-changelog 和 validate-commit-msg 的 commit message 规范，包括提交类型、格式要求、校验流程和常见错误提示。
outline: deep
---

# designable 代码提交规范

::: info 来源与授权
本文转载自陈豪（xjchenhao）的语雀文章《designable 代码提交规范》，原文链接：<https://www.yuque.com/xjchenhao/development/tmdayt>，原文发布时间：2022-01-28。

作者在原文中声明：本文为原创文章，如需转载，请注明来源并保留原文链接 xjchenhao，谢谢！

本站仅将原文从语雀格式转换为 Markdown，并调整了标题与代码块格式，技术内容未做改动。文章版权归原作者所有；如作者要求下架，请联系删除。
:::

\*\*

designable 工程使用[cz-conventional-changelog](https://www.npmjs.com/package/cz-conventional-changelog)模块和`scripts/validate-commit-msg.js`文件做了代码提交日志的规范。

## cz-conventional-changelog

要使用 cz-conventional-changelog，需使用`npm install -g commitizen`全局安装[commitizen](https://zj-git-guide.readthedocs.io/zh_CN/latest/message/%5BCommitizen%5D%E4%BF%A1%E6%81%AF%E4%BA%A4%E4%BA%92%E5%B7%A5%E5%85%B7/)。

再在 package.json 中配置如下内容：

```js
"config": {
    "commitizen": {
      "path": "./node_modules/cz-conventional-changelog"
    }
},
```

就可以实现`git cz`代替`git commit`的效果。

这么做的好处是，执行命令后，会依次询问：

- 这次提交的类型，比如 fix、new feature、improvement 还是其它。（单选，如下图）
- 这次修改的影响范围有多大：是全局的、还是只是针对个别组件。（字符串类型，可以随意输入）
- 简要描述修改了什么，最好是一句话，相当于修改标题。（字符串类型，可以随意输入）
- 详细描述修改了什么，最好分段描述，相当于内容区（字符串类型，可以随意输入）
- 是否有突破性变化（布尔类型，输入 y 或者 n）
- 这个改变是否会造成不良影响（布尔类型，输入 y 或者 n），如果是则还会再询问你具体的影响是什么，通常填写禅道或其它 bug 管理平台的 bugId。

最终提交的日志是符合[谷歌的日志提交规范](https://docs.google.com/document/d/1rk04jEuGfk9kYzfqCuOlPTSJw3hEDZJTBN5E5f1SALo/edit)的。

![image.png](/yuque/tmdayt/image-01.png)

## validate-commit-msg.js

由于工程引入[ghooks](https://www.npmjs.com/package/ghooks)模块，开启了 git hook，因此在 git 提交时总会触发 eslint 以及`scripts/validate-commit-msg.js`的代码提交日志规范的校验。

之所以在有`cz-conventional-changelog`的情况下，还做日志规范校验是因为总有人会有意或无意地使用`git commit`做代码提交。
