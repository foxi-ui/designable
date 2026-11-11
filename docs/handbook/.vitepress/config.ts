import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

const repo = 'https://github.com/foxi-ui/designable'

// 文档站与 playground 同域部署：playground 在根目录，文档在 /docs/。
const SITE_ORIGIN = 'https://designable-antd.bugduo.com'
const DOCS_BASE = '/docs/'
const DOCS_URL = `${SITE_ORIGIN}${DOCS_BASE}`

// 将 Markdown 相对路径转换为部署后的路由：
// index.md -> ''，architecture.md -> 'architecture.html'，
// source-reading/index.md -> 'source-reading/'
function toRoute(relativePath: string) {
  return relativePath
    .replace(/(^|\/)index\.md$/, '$1')
    .replace(/\.md$/, '.html')
}

export default withMermaid(
  defineConfig({
    lang: 'zh-CN',
    title: 'Designable 开发者手册',
    description:
      '从零接入 Designable 表单设计器：对象模型、生命周期、物料注册与 Formily 集成。',
    base: DOCS_BASE,
    srcExclude: ['README.md'],
    lastUpdated: true,
    // 输出 docs/sitemap.xml；hostname 以 / 结尾，VitePress 会按相对路由拼接。
    sitemap: {
      hostname: DOCS_URL,
    },
    // 为每页注入 self canonical 与页面级 Open Graph 信息。
    transformHead(ctx) {
      if (ctx.pageData.relativePath === '404.md') {
        return [['meta', { name: 'robots', content: 'noindex' }]]
      }

      const route = toRoute(ctx.pageData.relativePath)
      const canonical = `${DOCS_URL}${route}`

      return [
        ['link', { rel: 'canonical', href: canonical }],
        [
          'meta',
          {
            property: 'og:type',
            content: route === '' ? 'website' : 'article',
          },
        ],
        ['meta', { property: 'og:title', content: ctx.title }],
        ['meta', { property: 'og:description', content: ctx.description }],
        ['meta', { property: 'og:url', content: canonical }],
        [
          'meta',
          { property: 'og:site_name', content: 'Designable 开发者手册' },
        ],
        ['meta', { property: 'og:locale', content: 'zh_CN' }],
        ['meta', { name: 'twitter:card', content: 'summary' }],
      ]
    },
    head: [
      ['meta', { name: 'theme-color', content: '#2f54eb' }],
      [
        'script',
        {
          id: 'vercount-script',
          defer: '',
          src: 'https://events.vercount.one/js',
        },
      ],
    ],
    markdown: {
      lineNumbers: true,
    },
    themeConfig: {
      logo: '/logo.svg',
      siteTitle: 'Designable',
      nav: [
        { text: '指南', link: '/getting-started' },
        { text: '附录', link: '/appendix/api-index' },
        {
          text: 'Playground',
          link: 'https://designable-antd.bugduo.com/',
        },
      ],
      sidebar: [
        {
          text: '开始',
          items: [{ text: '快速开始', link: '/getting-started' }],
        },
        {
          text: '核心概念',
          items: [
            { text: '架构与对象模型', link: '/architecture' },
            { text: '生命周期', link: '/lifecycle' },
            { text: 'TreeNode 与编辑操作', link: '/tree-node' },
          ],
        },
        {
          text: '扩展与集成',
          items: [
            { text: '注册系统与物料', link: '/registry-and-materials' },
            { text: 'React 层', link: '/react-layer' },
            { text: 'Formily 集成', link: '/formily-integration' },
            { text: '实战 Recipes', link: '/recipes' },
          ],
        },
        {
          text: '源码阅读（转载）',
          items: [
            { text: '系列说明', link: '/source-reading/' },
            {
              text: '01 工程结构',
              link: '/source-reading/01-project-structure',
            },
            {
              text: '02 运行与二开',
              link: '/source-reading/02-run-and-customize',
            },
            {
              text: '03 代码提交规范',
              link: '/source-reading/03-commit-convention',
            },
            {
              text: '04 开发指南补充',
              link: '/source-reading/04-form-builder-guide-supplement',
            },
            {
              text: '05 全局注册与状态管理',
              link: '/source-reading/05-global-registry',
            },
            {
              text: '06 增加自定义组件',
              link: '/source-reading/06-custom-components',
            },
            { text: '07 响应器的使用', link: '/source-reading/07-reactions' },
            { text: '08 常见问题', link: '/source-reading/08-faq' },
          ],
        },
        {
          text: '附录',
          items: [
            { text: 'API 索引', link: '/appendix/api-index' },
            { text: '术语表', link: '/appendix/glossary' },
            { text: '故障排查', link: '/appendix/troubleshooting' },
            { text: '内容来源与授权', link: '/appendix/sources' },
          ],
        },
      ],
      search: {
        provider: 'local',
        options: {
          translations: {
            button: {
              buttonText: '搜索文档',
              buttonAriaLabel: '搜索文档',
            },
            modal: {
              noResultsText: '没有找到结果',
              resetButtonTitle: '清除查询',
              footer: {
                selectText: '选择',
                navigateText: '切换',
                closeText: '关闭',
              },
            },
          },
        },
      },
      outline: {
        level: [2, 3],
        label: '本页目录',
      },
      docFooter: {
        prev: '上一页',
        next: '下一页',
      },
      lastUpdated: {
        text: '最后更新于',
        formatOptions: {
          dateStyle: 'short',
          timeStyle: 'short',
        },
      },
      editLink: {
        pattern: `${repo}/edit/main/docs/handbook/:path`,
        text: '在 GitHub 上编辑此页',
      },
      socialLinks: [{ icon: 'github', link: repo }],
      footer: {
        message: '基于仓库当前源码整理，随代码演进更新。',
        copyright: 'Designable · 开发者手册',
      },
      sidebarMenuLabel: '菜单',
      returnToTopLabel: '回到顶部',
      darkModeSwitchLabel: '外观',
      lightModeSwitchTitle: '切换到浅色模式',
      darkModeSwitchTitle: '切换到深色模式',
      externalLinkIcon: true,
    },
    mermaid: {
      theme: 'default',
    },
  })
)
