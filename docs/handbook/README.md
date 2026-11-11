# Designable 开发者手册（站点）

本目录是手册的 VitePress 站点源码。构建产物会合并到 Playground 的 `doc-site/docs/`，随现有 GitHub Pages 流水线一起发布。

## 本地开发

```bash
npm install
npm run dev      # http://localhost:5173/docs/
```

## 构建与预览

```bash
npm run build    # 输出到 .vitepress/dist
npm run preview  # http://localhost:4173/docs/
```

## 目录约定

- `index.md`：站点首页
- `getting-started.md` 等：正文页面
- `appendix/`：API 索引、术语表、故障排查
- `.vitepress/config.ts`：`base: '/docs/'`、导航、侧边栏、搜索、Mermaid
- `.vitepress/theme/`：品牌色与首页样式

## 内容基准

正文以仓库源码为准，基线 commit 见首页「版本基准」。npm 上的 `1.0.0-beta.45` 落后于该提交，外部安装路径需在文中标注差异。

## 转载内容

`source-reading/` 为陈豪（xjchenhao）的 Designable 源码阅读系列转载，已按作者声明保留作者、原文链接与发布时间。授权依据与完整来源见 `appendix/sources.md`。
