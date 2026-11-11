#!/usr/bin/env bash
#
# 校验 playground 构建产物。
#
# 用法：
#   bash scripts/verify-site.sh [产物目录]
#
# 默认检查仓库根目录的 doc-site/。
#
set -euo pipefail

SITE_DIR="${1:-doc-site}"

fail() { echo -e "\033[31m[verify-site] 错误：\033[0m $*" >&2; exit 1; }
info() { echo -e "\033[36m[verify-site]\033[0m $*"; }

[ -d "$SITE_DIR" ] || fail "产物目录不存在：$SITE_DIR"
SITE_DIR="$(cd "$SITE_DIR" && pwd)"
INDEX="$SITE_DIR/index.html"
[ -f "$INDEX" ] || fail "缺少 index.html：$INDEX"

# ---------------------------------------------------------------------------
# 1. index.html 中引用的本地资源必须存在
# ---------------------------------------------------------------------------
errors=0
js_count=0
css_count=0

while IFS= read -r ref; do
  [ -n "$ref" ] || continue

  # 跳过外链、data URI、锚点
  case "$ref" in
    //* | http://* | https://* | data:* | \#* | mailto:* | javascript:*) continue ;;
  esac

  # 去掉 query / hash / 开头的 ./ 和 /
  asset="${ref%%\?*}"
  asset="${asset%%#*}"
  asset="${asset#./}"
  asset="${asset#/}"

  case "$asset" in
    *.js) js_count=$((js_count + 1)) ;;
    *.css) css_count=$((css_count + 1)) ;;
  esac

  if [ ! -f "$SITE_DIR/$asset" ]; then
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
# 2. 主 bundle 与关键文件
# ---------------------------------------------------------------------------
compgen -G "$SITE_DIR/playground.*.bundle.js" >/dev/null \
  || fail "缺少主 bundle：playground.*.bundle.js"

[ -s "$INDEX" ] || fail "index.html 为空"

# source map 是 inline 的，不应有本地 .map 依赖；如有 map 文件则说明构建配置变了，
# 这里只做提示，不作为失败条件。
if compgen -G "$SITE_DIR/*.map" >/dev/null; then
  info "提示：产物中包含 .map 文件（当前构建为 inline-source-map，通常不应出现）"
fi

# ---------------------------------------------------------------------------
# 3. 运行时资源：Monaco worker
# ---------------------------------------------------------------------------
# monaco-editor-webpack-plugin 会输出 worker chunk，运行时由 JS 动态加载。
if ! compgen -G "$SITE_DIR/*worker*.js" >/dev/null; then
  info "提示：未找到 monaco worker chunk，JSON schema 编辑器可能无法工作"
fi

# ---------------------------------------------------------------------------
# 4. 不应出现开发环境地址
# ---------------------------------------------------------------------------
if grep -qE 'https?://localhost|127\.0\.0\.1' "$INDEX"; then
  fail "index.html 中出现了 localhost 地址"
fi

# ---------------------------------------------------------------------------
# 5. 页面编码与 CDN 版本
# ---------------------------------------------------------------------------
# 缺少 charset 时浏览器可能按 Windows-1252 解析 UTF-8 bundle，
# 导致正则字符类报 "Range out of order in character class"。
grep -qi '<meta charset="utf-8"' "$INDEX" \
  || fail 'index.html 缺少 <meta charset="utf-8">'

# externals 的 CDN 版本必须固定：unpkg 的 latest 已指向 react 19（无 UMD）
# 和 antd 5+/6（与本 playground 不兼容）。
if grep -qE 'unpkg\.com/(react|react-dom|antd|moment)/' "$INDEX"; then
  fail "index.html 中的 unpkg 链接未固定版本"
fi

info "校验通过：${SITE_DIR}（$(find "$SITE_DIR" -type f | wc -l | tr -d ' ') 个文件）"
