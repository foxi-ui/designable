# Designable 开发者手册与文档站设计（core + react + formily-antd 主线）

- 日期：2026-11-11
- 基线 commit：`3e961de`
- 状态：待评审
- 交付形态：仓库内中文 Markdown 手册 + VitePress 文档站，合并部署到现有 GitHub Pages

## 1. 背景与意图

本仓库没有 API/使用文档：各包 README 只有标题，没有 `docs/` 目录，git 历史中也从未出现过。源码约 571 个 TS/TSX 文件、3.6 万行，导出符号约 736 个，但含 JSDoc 的文件只有 9 个。新同学接入时只能读实现和 `examples/`，成本高且容易误用内部 API。

本手册的目标读者是**准备用 Designable 搭建表单设计器的团队工程师**。读者应能照着手册完成接入、理解对象生命周期、注册自定义物料，并把设计器产出的 Schema 接回 Formily 渲染。手册以可浏览的文档站形式发布在现有 Playground 域名的 `/docs/` 子路径下。

## 2. 目标（可验收的读者结果）

读完手册后，读者能够：

1. 从零搭出一个可拖拽、可选中、可撤销的最小设计器，并解释每层容器（`Designer` / `Workspace` / `Viewport`）的作用。
2. 说清 `Engine → Workbench → Workspace → Operation → Tree/Selection/History` 的对象图，以及各对象的创建、挂载、销毁时机。
3. 注册自定义物料（`createBehavior` / `createResource` / `GlobalRegistry`）并让它出现在物料面板和设置面板中。
4. 用 `@designable/formily-transformer` 在设计器 `TreeNode` 与 Formily JSON Schema 之间双向转换，完成保存/恢复。
5. 在 antd playground 的既有接线上定位扩展点：自定义组件、自定义 setter、多工作区、iframe 沙箱、主题/国际化。
6. 区分稳定公开 API 与内部实现细节，避免误依赖。
7. 通过文档站导航在手册与 Playground 之间往返，站点可搜索、支持暗色模式、移动端可读。

## 3. 非目标

- 不做全量签名级 API reference。TypeDoc 自动生成留作后续独立任务。
- 不覆盖 `@designable/formily-next`、`@designable/react-sandbox`、`@designable/shared` 的完整 API；只在主线需要时提及。
- 不覆盖 `@designable/react-settings-form` 的每个 setter，只写扩展机制与常用 setter 的用法。
- 不修改核心运行时代码；唯一允许的运行时改动是 Playground 顶部新增一个指向 `/docs/` 的链接。
- 不迁移 Playground 的技术栈，不改变其构建方式与现有页面行为。
- 不承诺与 npm 已发布版本（`1.0.0-beta.45`）的兼容性，只描述当前仓库源码行为。

## 4. 反目标（即使技术上完成也算失败）

- 只有签名清单，没有“什么时候调用、调了会发生什么”。
- 示例代码与当前源码不符、导入路径不存在或无法说服读者它能跑。
- 把内部方法写成推荐用法，导致读者依赖非稳定 API。
- 大段复制 playground 业务代码，读者看不出哪些是 Designable 必需的、哪些是示例业务。
- 文档站构建成功但资源路径错误、子路径部署后白屏、搜索不可用。
- 为了发布文档站而破坏现有 Playground 部署。

## 5. 约束

- 语言：简体中文；代码、标识符保留英文。
- 内容基准：当前工作区源码，基线 commit `3e961de`。
- 示例来源：`examples/basic`、`examples/multi-workspace`、`examples/sandbox`、`formily/antd/playground`。允许为讲解做最小化改写，但不得虚构 API。
- 文档内容：Markdown + Mermaid；站点框架使用 VitePress。
- 环境：Playground 构建要求 Node 16；文档站构建使用 Node 22（仓库内已可用）。两者在 CI 中分步切换，互不影响。
- 不新增根 workspace 依赖、不改 `package.json` 的 workspaces、不触碰 `docs-deploy/` 下现有部署说明。
- 部署：复用现有 `.github/workflows/deploy-site.yml` 与 GitHub Pages 配置（自定义域名 `designable-antd.bugduo.com`、`build_type: workflow`、HTTPS 已启用）。

## 6. 交付物

### 6.1 内容

```
docs/handbook/
├── index.md                      # 手册首页（VitePress hero）
├── getting-started.md            # 安装与最小可运行设计器
├── architecture.md               # 对象模型与数据流
├── lifecycle.md                  # 创建、挂载、事件绑定、销毁、序列化
├── tree-node.md                  # TreeNode API 与编辑操作
├── registry-and-materials.md     # 注册系统、物料、behaviors、设置面板
├── react-layer.md                # Designer 容器、Panels、Widgets、Hooks
├── formily-integration.md        # transformer、SchemaField、setters、antd 接线
├── recipes.md                    # 常见扩展场景
└── appendix/
    ├── api-index.md              # 主线包公开导出索引（手工核对，非全量）
    ├── glossary.md               # 术语表
    └── troubleshooting.md        # 常见错误与排查
```

### 6.2 站点工程

```
docs/handbook/
├── package.json                  # 仅文档站依赖（vitepress 等），不加入根 workspace
├── package-lock.json             # npm ci 使用
└── .vitepress/
    ├── config.ts                 # base '/docs/'、导航、侧边栏、搜索、Mermaid
    └── theme/
        ├── index.ts              # 默认主题扩展
        └── custom.css            # 品牌色、暗色适配、首页样式
```

### 6.3 部署改动

- 修改 `.github/workflows/deploy-site.yml`：在现有 Playground 构建之后，增加 Node 22 文档站构建、产物合并、文档站校验。
- 新增 `scripts/verify-docs.sh`：校验 `doc-site/docs/index.html` 及其本地资源、关键章节页面存在。
- 修改 `formily/antd/playground/widgets/ActionsWidget.tsx`：新增“文档”按钮，指向 `/docs/`。
- 保留 `scripts/build-site.sh`、`scripts/verify-site.sh` 的现有 Playground 行为。

## 7. 文档站技术方案

- **框架**：VitePress 1.6.4。Markdown 即内容，默认主题自带中文界面、暗色模式、移动端侧边栏、本地搜索；与 GitHub Pages 静态部署兼容。
- **源码目录**：`docs/handbook/` 作为 VitePress 根目录；`docs/superpowers/specs/` 不进入站点构建。
- **`base`**：`/docs/`，保证部署在 `https://designable-antd.bugduo.com/docs/` 时 JS/CSS/图片路径正确。
- **导航**：顶部“指南”“附录”“Playground”“GitHub”；Playground 指向 `/`，GitHub 指向 `https://github.com/foxi-ui/designable`。
- **侧边栏**：按“入门 → 架构 → 编辑 → 扩展 → 集成 → 实战 → 附录”分组，与写作顺序一致。
- **搜索**：VitePress 本地搜索（`provider: 'local'`），不依赖外部服务与索引密钥。
- **图表**：`vitepress-plugin-mermaid` + `mermaid@11`，渲染对象图和生命周期时序图；不支持时退回代码块。
- **主题**：默认主题 + 自定义品牌色/字体变量；首页使用 hero + features + 快速入口；不引入额外 UI 组件库。
- **链接策略**：章内链接用相对路径；源码位置以 `文件路径:行号` 文本给出，链接到 GitHub 对应 commit，避免行号漂移后失效到错误位置。
- **版本固定**：`vitepress@1.6.4`、`vitepress-plugin-mermaid@2.0.17`、`mermaid@11.17.2`，提交 `package-lock.json`。

## 8. 部署方案（GitHub Pages）

现状（已通过 GitHub API 核实）：

- 仓库：`foxi-ui/designable`；GitHub Pages 已启用，自定义域名 `designable-antd.bugduo.com`，`build_type: workflow`，HTTPS 强制。
- 本地存在未跟踪的 `.github/workflows/deploy-site.yml`、`scripts/build-site.sh`、`scripts/verify-site.sh`，由 `docs-deploy` 分支 push 或手动触发。
- 现有流程只构建并发布 Playground 到站点根路径。

目标站点结构：

```
https://designable-antd.bugduo.com/
├── /                    # Playground（保持现状）
├── /docs/               # 开发者手册（VitePress）
│   ├── /docs/getting-started
│   ├── /docs/architecture
│   └── /docs/appendix/...
└── CNAME / .nojekyll
```

流水线改动（单 job，顺序执行）：

1. 现有步骤不变：Node 16 → `yarn install --frozen-lockfile --ignore-engines` → `bash scripts/build-site.sh` → `bash scripts/verify-site.sh doc-site`。
2. 切换到 Node 22（`actions/setup-node`，`cache: npm`，`cache-dependency-path: docs/handbook/package-lock.json`）。
3. `npm ci --prefix docs/handbook`。
4. `npm run build --prefix docs/handbook`，产物在 `docs/handbook/.vitepress/dist`。
5. `mkdir -p doc-site/docs && cp -R docs/handbook/.vitepress/dist/. doc-site/docs/`。
6. `bash scripts/verify-docs.sh doc-site/docs`。
7. 写入 `CNAME`、`.nojekyll`，上传并部署 Pages（沿用现有 `configure-pages` / `upload-pages-artifact` / `deploy-pages`）。

发布方式：

- 工作流触发条件保持 `push: branches: [docs-deploy]` 与 `workflow_dispatch`，避免每次 main 提交都发布。
- 发布时把 `docs-deploy` 快进到包含改动的 main 提交后 push；不强制推送，不改历史。
- 不在本次改动中调整 GitHub Pages 仓库设置（已配置正确）。

## 9. 章节内容要点与核对来源

### index.md

- 手册定位、读者假设、阅读路径（接入路径 vs 扩展路径）。
- 包清单：`@designable/core`、`@designable/react`、`@designable/formily-antd`、`@designable/formily-transformer`、`@designable/formily-setters`（配套）、`@designable/react-settings-form`（按依赖关系）。
- 版本说明：内容基于仓库 HEAD；npm 最新发布为 `1.0.0-beta.45`，落后 34 个提交。

### getting-started

- 两条安装路径：
  - **仓库内开发（推荐给本仓库使用者）**：Node 16 + `yarn install` + workspace alias，示例直接解析到 `src`。
  - **外部项目接入**：安装 npm 包（当前最新 `1.0.0-beta.45`），明确标注与 HEAD 的差异风险，遇到缺失 API 以仓库源码为准。
- 最小依赖与入口：`createDesigner` → `<Designer engine>` → `<Workspace>` → `<Viewport>`。
- 完整最小示例（基于 `examples/basic/src/main.tsx` 精简）。
- 验证点：画布渲染、组件树、选中高亮、拖拽。
- 核对：`packages/core/src/models/Engine.ts`、`packages/react/src/containers/{Designer,Workspace,Viewport}.tsx`。

### architecture

- 对象图：`Engine` 持有 `Workbench`、`Screen`、`Cursor`、`Keyboard`；`Workbench` 持有多个 `Workspace`；`Workspace` 持有 `Viewport`、`Outline`、`Operation`、`History`；`Operation` 持有 `Tree`、`Selection`、`Hover`、`MoveHelper`、`TransformHelper`。
- 数据流：用户拖拽 → driver → operation/moveHelper → tree mutation → snapshot → history → 响应式更新。
- 三个视口概念：`viewport`、`outline`、`screen` 的区别。
- 核对：`packages/core/src/models/*.ts`、`packages/core/src/drivers/*.ts`。

### lifecycle

- 顺序：`new Engine` → `engine.mount()` → React `<Designer>` effect → `<Workspace>` `ensureWorkspace` → `<Viewport>` `onMount(element, contentWindow)` → 事件 attach。
- 销毁：`Viewport.onUnmount()` → `engine.unmount()`；切换 engine 时 `Designer` 的清理逻辑。
- iframe 与非 iframe 两种视口挂载差异（`contentWindow`）。
- 快照与撤销：`operation.snapshot()`、`History` 的 `onPush/onUndo/onRedo/onGoto`。
- 序列化/恢复：`workspace.serialize()` / `workspace.from()`、`engine.setCurrentTree()`。
- 核对：`Engine.ts`、`Workbench.ts`、`Workspace.ts`、`Operation.ts`、`react/containers/*.tsx`。

### tree-node

- 构造与字段：`componentName`、`props`、`children`、`sourceName`、`hidden`。
- 查询：`find`、`findAll`、`findById`、`getParents`、`previous/next/siblings`、`descendants`。
- 修改：`append`/`prepend`/`wrap`/`insertAfter`/`insertBefore`（以源码实际方法名为准）、`setProps`、`setComponentName`、`from`、`takeSnapshot`。
- 设计器行为解析：`designerProps`、`designerLocales` 从 behavior 合并的规则。
- 选择与 hover：`Selection`、`Hover` 的公开操作。
- 核对：`packages/core/src/models/TreeNode.ts`、`Selection.ts`、`Hover.ts`。

### registry-and-materials

- `GlobalRegistry`：`registerDesignerBehaviors`、`registerDesignerIcons`、`registerDesignerLocales`、`setDesignerLanguage`、查询方法。
- `createBehavior` / `createResource` / `createDesigner` 的职责与返回结构。
- Behavior 的 `selector`、`extends` 排序规则（`reSortBehaviors`）。
- 物料如何进入 `ResourceWidget`，设置面板如何由 `propsSchema` 驱动。
- 核对：`packages/core/src/registry.ts`、`externals.ts`、`types.ts`、`packages/react/src/widgets/ResourceWidget`、`examples/basic/src/main.tsx`。

### react-layer

- `Designer` Provider 与 `DesignerEngineContext`。
- 容器：`Workbench`、`Workspace`、`Viewport`、`Simulator`、`Layout`。
- 面板：`StudioPanel`、`CompositePanel`、`WorkspacePanel`、`ToolbarPanel`、`ViewportPanel`、`SettingsPanel`、`ViewPanel`。
- Widgets：`ResourceWidget`、`OutlineTreeWidget`、`HistoryWidget`、`DesignerToolsWidget`、`ViewToolsWidget`、`IconWidget`、`NodePathWidget`、`DroppableWidget`、`EmptyWidget`、`GhostWidget`。
- Hooks：按用途分组（engine/workbench/workspace/viewport/tree/selection/hover/prefix/theme），不逐个展开内部实现。
- 核对：`packages/react/src/{containers,panels,widgets,hooks,context.tsx}`。

### formily-integration

- 双向转换：`TreeNode` ↔ Formily Schema（`@designable/formily-transformer`），字段、`x-component`、`x-component-props`、`x-decorator` 的映射。
- 渲染：`SchemaField` + `createForm` 的运行时接线。
- 设置面板：`SettingsForm` 与 `propsSchema`，`DataSourceSetter`/`ReactionsSetter`/`ValidatorSetter` 的使用边界（来自 `@designable/formily-setters`，随 `@designable/formily-antd` 传递依赖提供）。
- antd playground 的完整接线：`formily/antd/playground/main.tsx` 的结构拆解（哪些是框架必需、哪些是 demo 逻辑）。
- 保存/恢复流程：编辑 → schema → 存储 → 重新载入。
- 核对：`formily/transformer/src/*`、`formily/setters/src/*`、`formily/antd/src/*`、`formily/antd/playground/main.tsx`、`packages/react-settings-form/src/*`。

### recipes

- 自定义业务组件物料（含 behavior、locales、图标、`propsSchema`）。
- 自定义设置面板/自定义 setter 的接入方式。
- 多工作区切换（`Workbench.addWorkspace/switchWorkspace`）。
- iframe 沙箱渲染（`Simulator` / `Viewport` 的 `contentWindow`）。
- 主题与国际化（`setDesignerLanguage`、`registerDesignerLocales`、`prefixCls`/`theme`）。
- 每条 recipe 给出“改动点 + 最小代码 + 验证方式”。

### 附录

- `api-index.md`：仅主线包的公开导出，按模块分组，标注“推荐 / 可用但谨慎 / 内部”，链接到章节与源码。
- `glossary.md`：Engine、Workbench、Workspace、Operation、Viewport、Outline、Screen、Behavior、Resource、Setter、Driver、Snapshot 等。
- `troubleshooting.md`：常见症状（画布不显示、拖拽无效、设置面板空白、撤销失效、iframe 事件丢失、多个 Designer 冲突、`/docs/` 子路径资源 404）与原因。

## 10. 评审问题决议

以下来自独立 builder-check 的问题，已按“内容基准 + 双安装路径”的方案收敛：

1. **示例与安装的版本基准**：以仓库 HEAD 为准。`getting-started` 同时给出仓库内 workspace 路径与 npm 安装路径，并明确 `1.0.0-beta.45` 落后 34 个提交；示例代码以 HEAD 的 API 为准，差异处加注。
2. **“稳定 / 内部”的判定**：从包入口导出且被官方示例/playground 或本文档流程使用的 API 标为“推荐”；仅导出但未被主线使用的标为“可用但谨慎”；未导出的实现细节只用于解释机制，不写成推荐用法。
3. **`@designable/formily-setters` 的定位**：作为 `@designable/formily-antd` 的配套包纳入主线说明与 API 索引，覆盖 `DataSourceSetter`/`ReactionsSetter`/`ValidatorSetter`，但不要求读者单独安装或初始化。

## 11. 写作与验证方法

1. **先读后写**：每章动笔前读对应源码与示例，记录 API 的 `file:line`。
2. **示例最小化**：从真实示例裁剪，删除业务逻辑，保留 import、容器组合与关键回调。
3. **API 声明核对**：文档中出现的每个方法/属性必须在源码中存在；不存在的一律删除。
4. **交叉验证**：每章完成后由独立 subagent 对照源码检查“描述与实现是否一致”，重点查生命周期顺序和参数默认值。
5. **站点验证**：
   - `npm ci && npm run build` 在 `docs/handbook` 下成功。
   - 产物中 `index.html`、各章节 HTML、搜索索引、`/docs/` 前缀资源均存在。
   - 用本地静态服务器挂载“Playground 占位页 + `/docs/`”模拟最终结构，抽查页面与资源返回 200。
   - `scripts/verify-docs.sh` 在模拟产物上通过。
6. **流水线验证**：按工作流步骤在本地执行构建与合并命令；无法本地执行 GitHub Actions 的部分，逐条核对 workflow 语法与路径。
7. **可执行性说明**：示例默认按 npm 包 import 书写；若依赖 playground 的 workspace alias，明确标注。无法在本机运行的示例不得声称已验证。

## 12. 实施顺序

1. 站点骨架：`docs/handbook` 的 VitePress 工程、导航、主题、搜索、Mermaid、首页；`npm run build` 通过。
2. 内容：README/index + getting-started（打通最小闭环，确定示例风格）。
3. 内容：architecture + lifecycle（对象模型与生命周期，核心章节）。
4. 内容：tree-node + registry-and-materials。
5. 内容：react-layer。
6. 内容：formily-integration（依赖 04–06 的概念）。
7. 内容：recipes + 附录。
8. 部署接线：workflow、`verify-docs.sh`、Playground 文档入口。
9. 全量交叉检查、术语统一、链接与子路径验证。
10. 本地完整构建；经确认后再提交并推送 `docs-deploy` 触发发布。

## 13. 留给实现者的决定

- Mermaid 与 ASCII 的具体取舍（以可读性为准）。
- 每个 API 展开到什么粒度（默认：主线用到的方法详细，其余列表带一句说明）。
- 是否在章节中嵌入源码链接（默认：附“源码位置”小节，不逐条内联）。
- 术语中文译法（如 Workbench 保留英文，Workspace 保留英文）。
- VitePress 首页视觉细节与品牌色具体取值。

## 14. 风险

- 源码几乎无注释，部分语义需从实现和示例推断；推断内容必须在文中标注依据。
- `TreeNode`（893 行）、`Viewport`（516 行）方法多且部分为内部使用；需要明确“推荐用法”边界。
- npm 最新版与 HEAD 存在 34 个提交差异，外部安装路径可能与示例不完全一致；必须在 getting-started 显著提示。
- `@designable/formily-antd` 的 playground 含有较多 demo 逻辑，需仔细剥离，避免读者误以为必需。
- 文档站与 Playground 合并部署时，`base: '/docs/'`、静态资源与 SPA 路由容易出错；以本地模拟产物验证为准。
- 现有 workflow 为未跟踪文件，且当前 `docs-deploy` 与 `main` 指向同一提交；发布流程需要在提交/推送前再次确认。

## 15. 验收标准

- 目录与 9 个正文/首页文件、3 个附录齐全，站点侧边栏与阅读路径清晰。
- 每章至少包含一个可对照源码的完整示例或时序图。
- 随机抽查 20 个文档中出现的 API，全部能在源码中定位。
- 生命周期章节的顺序与 React 容器源码一致。
- 无虚构包名、导入路径或方法名。
- 术语在全文一致，附录索引链接有效。
- `docs/handbook` 构建成功；模拟 GitHub Pages 目录下 `/docs/` 首页与抽查章节可访问，静态资源无 404。
- Playground 构建与现有校验不受影响；Playground 页面能跳转到 `/docs/`。
- 独立审查 subagent 未发现“描述与实现冲突”的高优先级问题。
