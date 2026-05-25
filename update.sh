#!/bin/bash
# ========================================
# yunwei001 服务器更新脚本
# ========================================
# 使用方法:
#   ./update.sh          # 从 GitHub 拉取最新代码
#   ./update.sh cache    # 拉取代码并清除缓存
#   ./update.sh force    # 强制覆盖本地修改
# ========================================

PROJECT_DIR="/var/www/yunwei001"
BRANCH="main"

cd $PROJECT_DIR

echo "========================================="
echo "  yunwei001 服务器更新"
echo "========================================="

# Check if we have a remote set up
if ! git remote | grep -q "origin"; then
    echo "❌ 未设置 Git 远程仓库"
    echo "请先运行: git remote add origin https://github.com/fredphp/yunwei001.git"
    exit 1
fi

if [ "$1" = "force" ]; then
    echo "🔄 强制更新 (覆盖本地修改)..."
    git fetch origin
    git reset --hard origin/$BRANCH
elif [ "$1" = "cache" ]; then
    echo "🔄 拉取最新代码并清除缓存..."
    git pull origin $BRANCH
    echo "🗑️  清除 Nginx FastCGI 缓存..."
    rm -rf /var/cache/nginx/fastcgi/*
    nginx -s reload
    echo "✅ 缓存已清除"
else
    echo "🔄 拉取最新代码..."
    git pull origin $BRANCH
fi

echo ""
echo "✅ 更新完成!"
echo "如果修改了 JS/CSS 文件，请记得在 header.html 中更新版本号"
echo "如果修改了 PHP 文件，FastCGI 缓存可能需要清除: rm -rf /var/cache/nginx/fastcgi/* && nginx -s reload"
