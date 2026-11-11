#!/usr/bin/env bash
#
# 构建 Designable Ant Design Playground，并把产物合并到统一的发布目录。
#
# 用法：
#   bash scripts/build-site.sh
#
# 环境变量：
#   SITE_OUT_DIR                   输出目录，默认仓库根目录 doc-site
#   ALLOW_UNSUPPORTED_NODE=1       跳过 Node 主版本检查
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="${SITE_OUT_DIR:-$ROOT_DIR/doc-site}"

info() { echo -e "\033[36m[build-site]\033[0m $*"; }
fail() { echo -e "\033[31m[build-site] 错误：\033[0m $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. 检查 Node 版本
# ---------------------------------------------------------------------------
NODE_MAJOR="$(node -p "process.versions.node.split('.')[0]")"
NODE_VERSION="$(node -v)"

if [ "$NODE_MAJOR" != "16" ] && [ "${ALLOW_UNSUPPORTED_NODE:-0}" != "1" ]; then
  fail "当前 Node 版本为 $NODE_VERSION，本项目使用 webpack 4 + ts-loader，已验证的构建版本是 Node 16。
  请先执行：nvm use 16
  如确实要用其他版本构建，可设置 ALLOW_UNSUPPORTED_NODE=1 跳过此检查。"
fi

if [ "$NODE_MAJOR" != "16" ]; then
  info "警告：当前 Node 版本为 $NODE_VERSION，未经验证，继续构建。"
else
  info "Node 版本：$NODE_VERSION"
fi

# ---------------------------------------------------------------------------
# 2. 清理输出目录
# ---------------------------------------------------------------------------
info "清理输出目录：$OUT_DIR"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

# webpack 的 output.path 是 formily/antd/build，但 build:playground 不会清理该目录，
# 多次构建会残留旧的 hash 文件；先清掉以保证产物确定。
rm -rf "$ROOT_DIR/formily/antd/build"

# ---------------------------------------------------------------------------
# 3. 构建 playground
# ---------------------------------------------------------------------------
# playground 的 webpack 配置会把所有 workspace 包 alias 到各自 src，
# 因此不需要先执行各 package 的 tsc 构建。
info "构建 @designable/formily-antd playground ..."
yarn workspace @designable/formily-antd build:playground

PLAYGROUND_BUILD="$ROOT_DIR/formily/antd/build"
[ -f "$PLAYGROUND_BUILD/index.html" ] || fail "构建完成但未找到 $PLAYGROUND_BUILD/index.html"

# ---------------------------------------------------------------------------
# 4. 合并到统一发布目录
# ---------------------------------------------------------------------------
info "复制构建产物到 $OUT_DIR"
cp -R "$PLAYGROUND_BUILD/." "$OUT_DIR/"

# ---------------------------------------------------------------------------
# 5. 校验产物
# ---------------------------------------------------------------------------
info "校验构建产物 ..."
bash "$ROOT_DIR/scripts/verify-site.sh" "$OUT_DIR"

info "构建完成：$OUT_DIR"
