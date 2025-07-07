# GitHub リポジトリ作成手順

## 【手動作業】GitHubウェブサイトでリポジトリ作成

### 1. GitHubにアクセス
1. https://github.com にアクセス
2. サインインを確認

### 2. 新規リポジトリ作成
1. 右上の「+」ボタンをクリック
2. 「New repository」を選択

### 3. リポジトリ設定
```
Repository name: myteam
Description: AI Multi-Agent Parallel Execution System using Claude CLI and tmux
Visibility: Private ⚠️（セキュリティ配慮）
Initialize repository: チェックしない（既存プロジェクトのため）
```

### 4. 作成ボタンをクリック
「Create repository」ボタンを押して作成

### 5. リポジトリURLをコピー
作成後に表示されるHTTPS URLをコピー
例：`https://github.com/[username]/myteam.git`

## 【自動化】リモートリポジトリ設定

上記手順完了後、以下のコマンドで接続します：

```bash
# 現在のリモートをバックアップ用に変更
git remote rename origin backup

# 新しいリモートを追加
git remote add origin https://github.com/[username]/myteam.git

# リモート確認
git remote -v

# 初回プッシュ
git push -u origin main
```

## 注意事項
- プライベートリポジトリとして作成
- 認証情報の確認が必要
- 初回プッシュ時に認証が求められる場合があります