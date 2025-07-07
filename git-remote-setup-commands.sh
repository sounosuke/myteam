#!/bin/bash

# Git リモートリポジトリ設定スクリプト
# 使用方法: ./git-remote-setup-commands.sh [新しいリポジトリURL]

echo "🔧 Git リモートリポジトリ設定スクリプト"
echo "=========================================="

# 引数チェック
if [ $# -eq 0 ]; then
    echo "❌ エラー: リポジトリURLを指定してください"
    echo "使用例: $0 https://github.com/username/myteam-ai-parallel-system.git"
    exit 1
fi

NEW_REPO_URL=$1

echo "📋 設定内容:"
echo "新しいリポジトリURL: $NEW_REPO_URL"
echo ""

# 現在のリモート確認
echo "🔍 現在のリモート設定:"
git remote -v

echo ""
echo "🔄 リモート設定を変更します..."

# 現在のリモートをバックアップ用に変更
echo "1. 現在のoriginをbackupに変更..."
git remote rename origin backup

# 新しいリモートを追加
echo "2. 新しいoriginを追加..."
git remote add origin "$NEW_REPO_URL"

# 設定確認
echo "3. 設定確認:"
git remote -v

echo ""
echo "📊 Git状態確認:"
git status

echo ""
echo "✅ リモート設定完了"
echo "💡 次のステップ: git push -u origin main でプッシュしてください"