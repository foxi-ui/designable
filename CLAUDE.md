# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A fork of Alibaba Designable: a drag-and-drop engine for building form designers, plus a
deployed antd/Formily playground and a VitePress handbook. The fork's `docs-deploy` branch is
the deployment branch (`main` is the default branch); a push to `docs-deploy` triggers
`.github/workflows/deploy-site.yml`.

Layout (Yarn 1 workspaces + Lerna, `useWorkspaces: true`):

- `packages/core` — engine, object model, events, registry, drivers, effects, shortcuts (no React).
- `packages/react` — React bindings: containers, hooks, panels, widgets, simulators.
- `packages/react-settings-form` — property panel; renders forms from `designerProps.propsSchema`.
- `packages/react-sandbox` — iframe sandbox for previewing designs in isolation.
- `packages/shared` — utilities: events, uid, geometry, idle scheduling, globalThis shim.
- `formily/antd`, `formily/next`, `formily/setters` — designable material libraries.
- `formily/transformer` — TreeNode ↔ Formily JSON Schema conversion.
- `examples/*` — standalone demo apps (`basic`, `sandbox`, `multi-workspace`, ...).
- `formily/antd/playground` — the app actually deployed at the domain root.
- `docs/handbook` — VitePress handbook published under `/docs/`.
- `scripts/` — build/verify scripts used locally and by CI; `docs-deploy/DEPLOY.md` is the
  detailed deployment reference (in Chinese).

## Commands

Use **Node 16** for anything that builds or runs the playground (`webpack 4`); the build script
hard-fails on other major versions. The handbook (VitePress 1.x) needs **Node 22**. Use Yarn 1
at the repo root with `--ignore-engines` — the root `package.json` has a stale `devEngines` field
that makes npm 10 fail.

```bash
nvm use 16
yarn install --frozen-lockfile --ignore-engines

# Deployed playground (http://127.0.0.1:3000)
yarn workspace @designable/formily-antd start

# Other demos
yarn start:basic          # examples/basic, also start:sandbox, start:multi-workspace, ...
yarn workspace @designable/formily-next start

# Build all packages (tsc cjs + esm + rollup umd; outputs lib/, esm/, dist/ — all gitignored)
yarn build
yarn workspace @designable/core build     # single package

# Full static site: playground -> doc-site/, then verify (Node 16)
bash scripts/build-site.sh
bash scripts/verify-site.sh doc-site
ALLOW_UNSUPPORTED_NODE=1 bash scripts/build-site.sh   # escape hatch, unverified

# Handbook (Node 22; http://localhost:5173/docs/)
cd docs/handbook && npm install && npm run dev
cd docs/handbook && npm run build          # .vitepress/dist
bash scripts/verify-docs.sh doc-site/docs  # after merging the handbook into doc-site

# Lint / format
yarn lint                                  # eslint --fix over .ts,.tsx,.js
yarn eslint path/to/file.ts                # single file
# Prettier: no semicolons, single quotes, 2 spaces (see .prettierrc.js)

# Tests
yarn test                                  # jest --coverage
yarn jest path/to/foo.spec.ts              # single file
yarn test:watch
```

Jest is configured in `scripts/jest.base.js` (ts-jest, jsdom, `**/__tests__/**/*.spec.[jt]s?(x)`,
global `sleep`/`prettyFormat` from `scripts/global.ts`). No spec files are currently committed,
so `yarn test` exits non-zero with "no tests found"; add specs under the matching `__tests__`
pattern.

`yarn workspace <pkg> build` is **not** required before running the playground or an example:
their webpack configs alias every workspace name to that package's `src/` via
`getWorkspaceAlias()` / `getAlias()`.

## Core architecture

**Object graph (`packages/core/src/models/`).** `Engine` owns `Workbench`, `Screen`, `Cursor`,
`Keyboard`. `Workbench` owns one or more `Workspace`s and tracks `currentWorkspace` /
`activeWorkspace` / `type` (`DESIGNABLE | PREVIEW | JSONTREE`). A `Workspace` owns an `Operation`,
two `Viewport`s (canvas and outline), and `History`. `Operation` owns the `TreeNode` tree,
`Selection`, `Hover`, `MoveHelper`, and `TransformHelper`. All of these are plain classes made
observable with `@formily/reactive` (`makeObservable()`), so React renders from them directly.

**Mutations flow through events.** Edit operations (`appendNode`, `insertBefore`, `remove`,
`wrap`, `clone`, `from`, ...) mutate the tree and dispatch typed events defined in
`packages/core/src/events/`. `Operation.snapshot()` schedules a History push on idle, and history
undo/redo dispatches events rather than restoring objects directly. When adding an edit
operation, follow this pattern rather than mutating `TreeNode` fields from outside.

**Interaction pipeline.** DOM `drivers` (`packages/core/src/drivers/`) turn mouse/keyboard/scroll
input into engine events; `effects` (`packages/core/src/effects/`) subscribe to those events and
drive selection, drag/drop, resize, cursor and auto-scroll; `shortcuts` implement keyboard
commands. Effects are subscribed once when the `Engine` is constructed; drivers are instantiated
per DOM container — `Engine.mount()` attaches them to the global document, and each `<Viewport>`
attaches them to its own element. `DEFAULT_DRIVERS`, `DEFAULT_EFFECTS`, `DEFAULT_SHORTCUTS` live
in `presets.ts`, and `createDesigner()` appends them to whatever the caller supplies.

**Registry and materials.** `GlobalRegistry` (`packages/core/src/registry.ts`) holds behaviors,
resources, icons and locales as observables. Behaviors are selected by a `selector(node)` and
provide `designerProps` (including `propsSchema` used by the settings panel) plus
`designerLocales`; `extends` ordering is resolved by `reSortBehaviors` (e.g. every field behavior
extends `Field`). `createBehavior` / `createResource` are the helper factories. Every material in
`formily/antd/src/components/*` is a Formily component decorated with static `Behavior` and
`Resource` (see `Input/preview.ts`): `ResourceWidget` builds the drag palette from `Resource`,
`ComponentTreeWidget` renders the tree and auto-registers the statics via
`registerDesignerBehaviors`. The selectors match Formily schema props (`x-component`,
`x-decorator`), not React component identity.

**React layer.** Containers mirror the model: `<Designer>` mounts the engine and provides
`DesignerEngineContext`; `<Workspace>` calls `workbench.ensureWorkspace`; `<Viewport>` attaches
DOM events in `useLayoutEffect`. Hooks (`useTreeNode`, `useSelected`, `useViewport`, ...) wrap
observables for rendering; widgets/panels are the visual editor chrome.

**Formily integration.** `formily/antd` wraps `@formily/antd` and adds Designable metadata;
`schemas/` are JSON Schema fragments used for property editing, `locales/` hold designer labels.
The tree stores Formily schema values in `TreeNode.props`; `@designable/formily-transformer`
converts between the tree and `{ form, schema }`, preserving node identity with
`x-designable-id`. `formily/setters` provides antd-specific property setters used by
`react-settings-form`.

## Build, verification and deployment

- `formily/antd/playground/webpack.base.ts` externalizes `react`, `react-dom`, `antd`, `moment`
  and loads them from unpkg in `playground/template.ejs`. **CDN versions must stay pinned**:
  unversioned URLs resolve to React 19 (no UMD) and antd 5/6 (incompatible), and
  `verify-site.sh` fails the build on them.
- `scripts/build-site.sh` builds the playground, copies `formily/antd/build/` into the
  gitignored `doc-site/`, then writes domain-root files from `scripts/static/` (`robots.txt`,
  `sitemap.xml`, `.well-known/`). Files that must be served at `https://…/<path>` belong in
  `scripts/static/`; the handbook's `public/` directory ends up under `/docs/`, not the root.
- `scripts/verify-site.sh` and `scripts/verify-docs.sh` gate deployment: they check referenced
  assets, key pages, `/docs/` base prefixes, fixed CDN versions, per-page canonical/description
  metadata, sitemaps, and the `.well-known` verification file. A build that fails either script
  never reaches the deploy job.
- CI (`deploy-site.yml`) builds with Node 16 + Yarn, verifies, installs/builds the handbook with
  Node 22 + `npm ci`, merges `.vitepress/dist` into `doc-site/docs/`, verifies again, writes
  `CNAME` and `.nojekyll`, and deploys via GitHub Pages.
- The handbook sets `base: '/docs/'`, generates self-canonical links in `transformHead`, and
  excludes `README.md`. New pages need a non-trivial frontmatter `description` (verify-docs
  enforces it), a sidebar entry in `.vitepress/config.ts`, and must be added to the verify list
  if they are structurally important.
- `doc-site/`, package `lib/`/`esm/`/`dist/` and `build/` are build outputs and gitignored;
  never commit them.

## Conventions

- Commit messages use conventional format `<type>(<scope>): <subject>`, validated by the
  `ghooks` commit-msg hook (`scripts/validate-commit-msg.js`) and commitlint CI; PR titles are
  checked by `check-pr-title.yml`. Recent history uses scopes such as `core`, `react`,
  `handbook`, `seo`, `deploy`.
- Code comments, the handbook, and `docs-deploy/DEPLOY.md` are Chinese; keep new prose in the
  same language as the file you touch.
- Lint-staged runs ESLint + Prettier on staged files; markdown is also formatted.
