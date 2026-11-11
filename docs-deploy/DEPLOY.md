# Designable Ant Design Playground 部署说明

- 统一域名：`https://designable-antd.bugduo.com`
- 部署方式：GitHub Pages + GitHub Actions
- 站点内容：`formily/antd/playground`（Designable Ant Design 表单设计器）
- 构建产物：仓库根目录 `doc-site/`（已加入 `.gitignore`）

## 1. 整体架构

```text
Designable 仓库
  └─ formily/antd/playground/   (webpack 4)
        └─ 构建输出 formily/antd/build/
              └─ 复制到 doc-site/        (GitHub Pages 根目录)
```

与 Formily 文档站的多子站方案不同，本项目只有一个站点，因此 `doc-site/`
直接作为域名根目录发布，不划分子路径。

## 2. 环境要求

- Node.js **16.x**（已验证版本）
- Yarn **1.22.x**

Node 17+ 使用 OpenSSL 3，webpack 4 在部分场景需要
`--openssl-legacy-provider`；本项目尚未验证 Node 17+，因此 CI 固定使用 Node 16。

`scripts/build-site.sh` 会检查 Node 主版本，不是 16 时直接报错。确实需要尝试其他版本时可设置：

```bash
ALLOW_UNSUPPORTED_NODE=1 bash scripts/build-site.sh
```

## 3. 本地开发

```bash
nvm use 16
yarn install --frozen-lockfile --ignore-engines

yarn workspace @designable/formily-antd start
```

开发服务器：

- 地址：<http://127.0.0.1:3000>
- 配置：`formily/antd/playground/webpack.dev.ts`

## 4. 本地完整构建

```bash
nvm use 16
yarn install --frozen-lockfile --ignore-engines
bash scripts/build-site.sh
```

脚本执行顺序：

1. 检查 Node 版本。
2. 清空 `doc-site/`。
3. 执行 `yarn workspace @designable/formily-antd build:playground`。
4. 将 `formily/antd/build/` 复制到 `doc-site/`。
5. 执行 `scripts/verify-site.sh`。

playground 的 webpack 配置通过 `getWorkspaceAlias()` 把所有 workspace 包
alias 到各自的 `src`，因此**不需要**先执行各 package 的 `tsc` 构建。

单独校验产物：

```bash
bash scripts/verify-site.sh doc-site
```

本地静态预览：

```bash
npx http-server doc-site -p 8080
```

访问：<http://localhost:8080/>

## 5. 路径配置约定

站点部署在域名根目录，所有资源使用根路径，无需额外设置 `publicPath`
或 `base`。`formily/antd/playground/webpack.base.ts` 中：

```ts
output: {
  path: path.resolve(__dirname, '../build'),
  filename: '[name].[hash].bundle.js',
}
```

生产构建在 `webpack.prod.ts` 中设置了 `devtool: false`，避免
`inline-source-map` 额外增加约 3MB 体积；开发构建仍保留 source map。

如果未来要部署到子路径（例如 `/antd/`），需要在该配置中显式设置
`publicPath: '/antd/'`，并相应调整导航与资源引用。

## 6. 外部依赖

`webpack.base.ts` 将以下依赖声明为 external，由 `template.ejs` 从 unpkg 加载：

```text
moment
react
react-dom
antd
```

**CDN 版本必须固定**，当前使用：

| 依赖      | 版本   |
| --------- | ------ |
| moment    | 2.29.1 |
| react     | 17.0.2 |
| react-dom | 17.0.2 |
| antd      | 4.19.3 |

不要使用 `https://unpkg.com/react/...` 这类不带版本号的地址：

- unpkg 的 latest 已指向 React 19，而 React 19 不再提供 UMD 构建，会 404。
- antd 的 latest 已指向 5/6，与本 playground（antd 4）不兼容。

升级依赖时，需要同时更新 `template.ejs` 中的版本，并确认对应的 UMD 文件存在。

因此页面运行时需要能够访问 `unpkg.com`。其余依赖（`@formily/*`、
`monaco-editor` 等）均打包进产物。

`template.ejs` 必须包含 `<meta charset="utf-8">`。缺少时浏览器可能按
Windows-1252 解析 UTF-8 的 bundle，导致非 ASCII 正则报
`Range out of order in character class`，页面白屏。

Monaco Editor 的 worker chunk 由 `monaco-editor-webpack-plugin` 输出，
运行时按 webpack 的 publicPath 动态加载；站点位于根目录时无需额外配置。

## 7. GitHub Actions 部署流程

工作流：`.github/workflows/deploy-site.yml`

触发条件：

- push 到 `docs-deploy`
- 手动 `workflow_dispatch`

步骤：

1. Checkout
2. Setup Node 16（Yarn cache）
3. `yarn install --frozen-lockfile --ignore-engines`
4. `bash scripts/build-site.sh`
5. `bash scripts/verify-site.sh doc-site`
6. 写入 `doc-site/CNAME`，并创建 `doc-site/.nojekyll`
7. `actions/configure-pages@v5`
8. `actions/upload-pages-artifact@v3`
9. `actions/deploy-pages@v4`

构建或校验失败不会进入 deploy job。

## 8. GitHub Pages 配置

在 GitHub 仓库（`foxi-ui/designable`）：

```text
Settings -> Pages -> Build and deployment
```

- Source: `GitHub Actions`
- Custom domain: `designable-antd.bugduo.com`
- 等待 DNS 检查与证书签发后，开启 `Enforce HTTPS`

## 9. DNS 配置

在 `bugduo.com` 的 DNS 控制台添加：

| 类型  | 主机记录          | 记录值              |
| ----- | ----------------- | ------------------- |
| CNAME | `designable-antd` | `foxi-ui.github.io` |

当前仓库 `origin` 为 `git@github.com:foxi-ui/designable.git`，因此记录值取
`foxi-ui.github.io`。如果实际部署到其他账号或组织，替换为对应的
`<账号>.github.io`。

不要填写带仓库路径的值（例如 `foxi-ui.github.io/designable`）。

## 10. 常见问题

### 构建时报 Node 版本错误

```bash
nvm use 16
node -v
```

### `Can't resolve 'xxx'`

先确认依赖已安装：

```bash
yarn install --frozen-lockfile --ignore-engines
```

playground 会把 workspace 包 alias 到 `src`，因此通常不是 `lib`/`esm`
未构建导致的。

### 页面空白，控制台报 `Range out of order in character class`

`index.html` 缺少 `<meta charset="utf-8">`，浏览器按错误编码解析了
UTF-8 的 bundle。确认 `formily/antd/playground/template.ejs` 中包含该标签，
然后重新构建。

### 页面空白，控制台报 `React is not defined` / `antd is not defined`

检查 `template.ejs` 中的 CDN 脚本是否加载成功。这些依赖是 external，
不会打进 bundle。

### CDN 脚本 404

确认 unpkg 地址带有版本号。不带版本号的地址会解析到 React 19（无 UMD）
或 antd 5/6（不兼容）。`scripts/verify-site.sh` 会检查未固定版本的链接。

### 字体或静态资源 404

检查 `formily/antd/playground/webpack.base.ts` 中相关 loader 的配置，
确认构建产物中存在对应文件，并执行：

```bash
bash scripts/verify-site.sh doc-site
```

### Monaco 编辑器无法加载 worker

确认产物中存在 `*worker*.js`，并确认 `monaco-editor-webpack-plugin`
的 publicPath 与站点实际路径一致。站点位于根目录时使用默认值即可。

### 刷新页面 404

playground 是单页应用，但只有 `/` 一个路由，不存在深链接问题。
如果未来引入前端路由，需要为 GitHub Pages 生成对应的 `index.html`。

## 11. 新增其他站点

如果以后需要把 `formily/next` playground 或 `examples/*` 也发布到同一域名下：

1. 在 `scripts/build-site.sh` 中增加对应 workspace 的构建命令。
2. 将其产物复制到 `doc-site/<name>/`，并在该站点的 webpack 配置中设置
   `output.publicPath = '/<name>/'`。
3. 在 `scripts/verify-site.sh` 中增加对应子目录与资源的校验。
4. 在主站导航中使用完整 URL（`https://designable-antd.bugduo.com/<name>/`），
   避免被当作站内路由处理。
5. 执行完整构建与本地预览。

## 12. 依赖升级注意事项

- 第一阶段不升级 webpack、React、antd、Monaco、TypeScript。
- 不修改业务 package 的依赖版本。
- 不删除 `yarn.lock`，CI 使用 `--frozen-lockfile`。
- 如未来升级 Node，需要同时验证：
  - webpack 4 与 OpenSSL 3 的兼容性（可能需要 `--openssl-legacy-provider`）
  - `ts-loader` / `less-loader` / `url-loader` 等旧 loader 的兼容性
- 如未来升级 webpack 5，需要重新验证 `monaco-editor-webpack-plugin`、
  `html-webpack-plugin`、`mini-css-extract-plugin` 与 externals 行为。

## 13. SEO 配置

### 13.1 产物中的 SEO 文件

| 文件                     | 来源                                   | 说明                                            |
| ------------------------ | -------------------------------------- | ----------------------------------------------- |
| `/robots.txt`            | `scripts/static/robots.txt`            | 由 `build-site.sh` 写入根目录，声明两个 sitemap |
| `/sitemap.xml`           | `scripts/static/sitemap.xml`           | 仅包含 playground 首页                          |
| `/docs/sitemap.xml`      | VitePress `sitemap` 配置               | 由构建生成，包含全部文档页                      |
| `/docs/*.html` canonical | `transformHead`                        | 每页指向自身的规范 URL                          |
| `/` 首页静态正文         | `formily/antd/playground/template.ejs` | CSR 之外的 h1、描述与 `/docs/` 链接             |

`scripts/verify-site.sh` 与 `scripts/verify-docs.sh` 会校验上述内容，
缺失时 CI 直接失败，避免 SEO 配置被后续改动破坏。

### 13.2 搜索引擎提交

1. **Google Search Console**
   - 添加资源 `https://designable-antd.bugduo.com`。
   - 通过 DNS TXT 或 HTML 文件完成验证。
   - 提交 `https://designable-antd.bugduo.com/sitemap.xml` 与
     `https://designable-antd.bugduo.com/docs/sitemap.xml`。
2. **Bing Webmaster Tools**
   - 可直接从 Google Search Console 导入站点与 sitemap。
3. **百度搜索资源平台**
   - 百度验证尚未接入。需要先在 `bugduo.com` DNS 添加百度提供的 TXT 记录，
     或在站点根目录放置 `baidu_verify_*.html`。
   - 验证通过后提交两个 sitemap，并使用「普通收录 → API 提交」推送新页面。
   - 注意：百度对未备案的境外托管站点收录不稳定，GitHub Pages +
     `bugduo.com` 的收录效果取决于主域备案与访问情况。

### 13.3 新增页面时

新增 Markdown 页面后：

1. 在 frontmatter 中补 `title`（约 10–16 个汉字）与
   `description`（约 70–100 个汉字），保证全站唯一。
2. 在 `.vitepress/config.ts` 的 `sidebar` 中添加入口，保证从首页 2 次点击内可达。
3. 执行 `npm run build`，确认 `sitemap.xml` 与 canonical 自动更新。
4. 重新提交 sitemap。
