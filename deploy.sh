#!/usr/bin/env bash
# 工位木鱼 · 一键发布到 GitHub Pages
# ⚠️ 这一步是「对外发布」，按规矩由你本人执行。我只把命令准备好。
# 用法：bash deploy.sh
set -euo pipefail
cd "$(dirname "$0")"

REPO="${REPO:-gongwei-muyu}"
ACCOUNT="$(gh api user -q .login)"
URL="https://${ACCOUNT}.github.io/${REPO}/"

echo "→ 账号：$ACCOUNT"
echo "→ 仓库：$REPO"
echo "→ 目标地址：$URL"
echo

[ -d .git ] || git init -q -b main

git add -A
if git -c core.quotepath=false diff --cached --quiet 2>/dev/null; then
  echo "（没有新改动，直接推）"
else
  git -c user.name="$(git config user.name 2>/dev/null || echo wang)" \
      -c user.email="$(git config user.email 2>/dev/null || echo wang@localhost)" \
      commit -qm "工位木鱼 v1" || true
  echo "✅ 已提交"
fi

if ! gh repo view "$ACCOUNT/$REPO" >/dev/null 2>&1; then
  gh repo create "$ACCOUNT/$REPO" --public \
    --description "工位木鱼：敲着解压的网页。不祈福、不供奉、没有任何收费功能。" \
    --source=. --remote=origin --push
  echo "✅ 已建仓库并推送"
else
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$ACCOUNT/$REPO.git"
  git push -u origin main
  echo "✅ 已推送更新"
fi

# 开启 Pages（已开过会报错，忽略）
gh api -X POST "repos/$ACCOUNT/$REPO/pages" --input - >/dev/null 2>&1 <<'JSON' || true
{"source":{"branch":"main","path":"/"}}
JSON

echo
echo "=============================================="
echo " 约 60 秒后生效：$URL"
echo " 回滚（对外下架）：gh repo delete $ACCOUNT/$REPO --yes"
echo " 改版更新：git add -A && git commit -m '改版' && git push"
echo "=============================================="
