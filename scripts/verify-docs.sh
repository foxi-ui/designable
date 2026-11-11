#!/usr/bin/env bash
#
# 校验 VitePress 文档站构建产物。
#
# 用法：
#   bash scripts/verify-docs.sh [文档产物目录]
#
# 默认检查 doc-site/docs/。
#
set -euo pipefail

DOCS_DIR="${1:-doc-site/docs}"

fail() { echo -e "\033[31m[verify-docs] 错误：\033[0m $*" >&2; exit 1; }
info() { echo -e "\033[36m[verify-docs]\033[0m $*"; }

[ -d "$DOCS_DIR" ] || fail "文档产物目录不存在：$DOCS_DIR"
DOCS_DIR="$(cd "$DOCS_DIR" && pwd)"
INDEX="$DOCS_DIR/index.html"
[ -f "$INDEX" ] || fail "缺少 index.html：$INDEX"

# ---------------------------------------------------------------------------
# 1. index.html 中引用的本地资源必须存在
# ---------------------------------------------------------------------------
errors=0
js_count=0
css_count=0

while IFS= read -r ref; do
  [ -n "$ref" ] || continue

  # 跳过外链、data URI、锚点、邮件
  case "$ref" in
    //* | http://* | https://* | data:* | \#* | mailto:* | javascript:*) continue ;;
  esac

  asset="${ref%%\?*}"
  asset="${asset%%#*}"
  case "$asset" in
    /docs/*) asset="${asset#/docs/}" ;;
    /docs) continue ;;
    /*) asset="${asset#/}" ;;
    ./*) asset="${asset#./}" ;;
  esac

  # 目录链接，例如 /docs/source-reading/
  if [ -d "$DOCS_DIR/$asset" ]; then
    continue
  fi

  if [ -f "$DOCS_DIR/$asset" ]; then
    case "$asset" in
      *.js) js_count=$((js_count + 1)) ;;
      *.css) css_count=$((css_count + 1)) ;;
    esac
  else
    echo "  - 缺少资源：$ref" >&2
    errors=$((errors + 1))
  fi
done < <(
  grep -oE '(src|href)="[^"]+"' "$INDEX" \
    | sed -E 's/^(src|href)="//; s/"$//'
)

[ "$errors" -eq 0 ] || fail "index.html 引用了 $errors 个不存在的本地资源"
[ "$js_count" -gt 0 ] || fail "index.html 未引用任何本地 JS"
[ "$css_count" -gt 0 ] || fail "index.html 未引用任何本地 CSS"

# ---------------------------------------------------------------------------
# 2. 关键页面必须存在
# ---------------------------------------------------------------------------
for page in \
  getting-started.html \
  architecture.html \
  source-reading/index.html \
  source-reading/01-project-structure.html \
  appendix/sources.html \
  404.html; do
  [ -f "$DOCS_DIR/$page" ] || fail "缺少页面：$page"
done

# README.md 仅用于维护者，不应构建成页面
[ ! -f "$DOCS_DIR/README.html" ] || fail "README.md 不应被构建为页面"

# ---------------------------------------------------------------------------
# 3. 关键静态资源
# ---------------------------------------------------------------------------
[ -f "$DOCS_DIR/logo.svg" ] || fail "缺少 logo.svg"
[ -f "$DOCS_DIR/yuque/rncluc/image-01.png" ] \
  || fail "缺少转载文章配图：yuque/rncluc/image-01.png"

find "$DOCS_DIR/assets" -name '@localSearchIndex*' -print -quit 2>/dev/null \
  | grep -q . || fail "缺少本地搜索索引"

# ---------------------------------------------------------------------------
# 4. 资源路径必须带 /docs/ 前缀
# ---------------------------------------------------------------------------
if grep -qE '(src|href)="/assets/' "$INDEX"; then
  fail 'index.html 中的资源没有 /docs/ 前缀，请检查 VitePress base 配置'
fi

# ---------------------------------------------------------------------------
# 5. 发布入口不应出现开发环境地址
# ---------------------------------------------------------------------------
if grep -qE 'https?://localhost|127\.0\.0\.1' "$INDEX"; then
  fail "index.html 中出现了 localhost 地址"
fi

# ---------------------------------------------------------------------------
# 6. SEO：sitemap、每页 self canonical 与 description
# ---------------------------------------------------------------------------
SITEMAP="$DOCS_DIR/sitemap.xml"
[ -f "$SITEMAP" ] || fail "缺少 sitemap.xml"

for url in \
  'https://designable-antd.bugduo.com/docs/' \
  'https://designable-antd.bugduo.com/docs/architecture.html' \
  'https://designable-antd.bugduo.com/docs/source-reading/'; do
  grep -q "<loc>$url</loc>" "$SITEMAP" || fail "sitemap.xml 缺少 URL：$url"
done

while IFS= read -r file; do
  rel="${file#"$DOCS_DIR"/}"

  # 404 页面不应被索引，也不应出现在 sitemap 中。
  if [ "$rel" = "404.html" ]; then
    grep -q '<meta name="robots" content="noindex">' "$file" \
      || fail "404.html 缺少 noindex"
    continue
  fi

  case "$rel" in
    index.html) route="" ;;
    */index.html) route="${rel%index.html}" ;;
    *) route="$rel" ;;
  esac

  canonical="https://designable-antd.bugduo.com/docs/$route"
  grep -q "<link rel=\"canonical\" href=\"$canonical\">" "$file" \
    || fail "缺少 self canonical：$rel"
  grep -q '<meta name="description" content="[^"]\{20,\}"' "$file" \
    || fail "缺少 meta description：$rel"
done < <(find "$DOCS_DIR" -name '*.html' -type f | sort)

info "校验通过：${DOCS_DIR}（$(find "$DOCS_DIR" -type f | wc -l | tr -d ' ') 个文件）"
