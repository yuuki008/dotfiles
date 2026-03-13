# Dotfiles 再構成 設計ドキュメント

**日付**: 2026-03-13
**ステータス**: 承認済み

---

## 概要

dotfilesリポジトリを整理し、XDGベースディレクトリ仕様に準拠した構造に再編成する。
WezTermをメインターミナルとして追加し、mozumasu/dotfilesの `symlink.sh` のロジック（全ファイル自動検出＋除外リスト方式）を参考にしたシンボリックリンクスクリプトを導入する。

---

## 目標

- `~/.config/` 配下にツール設定を統一（XDG準拠）
- WezTerm設定を追加
- `gh/`, `karabiner/` を dotfiles に取り込む
- `.zshrc`, `.zprofile` を `.config/zsh/` に移動
- `.ssh/config` を dotfiles で管理
- mozumasu方式のシンボリックリンクスクリプト（`.bin/symlink.sh`）に移行
- `setup` スクリプトを `brew bundle` + `symlink.sh` の呼び出しに整理

---

## ディレクトリ構造

```
dotfiles/
├── .config/
│   ├── nvim/               # Neovim設定（既存・変更なし）
│   ├── tmux/               # tmux設定（既存・変更なし）
│   ├── ranger/             # Rangerファイルマネージャー（既存・変更なし）
│   ├── starship.toml       # Starshipプロンプト（既存・変更なし）
│   ├── zsh/                # NEW: .zshrc, .zprofile を移動
│   │   ├── .zshrc
│   │   └── .zprofile
│   ├── wezterm/            # NEW: WezTermターミナル設定
│   │   └── wezterm.lua
│   ├── gh/                 # NEW: GitHub CLI設定（hosts.ymlは除外）
│   │   └── config.yml
│   └── karabiner/          # NEW: キーボードカスタマイズ設定
│       └── karabiner.json
├── .ssh/
│   └── config              # NEW: SSH接続設定（秘密鍵・known_hostsは除外）
├── .bin/                   # NEW: 管理スクリプト置き場
│   └── symlink.sh          # mozumasu方式の自動シンボリックリンクスクリプト
├── .claude/                # Claude Code設定（既存・変更なし）
├── .zshenv                 # NEW: ZDOTDIR設定（zshをXDG対応させる）
├── .gitconfig              # 既存・ルートに残す（git設定はここに一元管理）
├── .gitignore              # 既存・除外ルールを追加
├── Brewfile                # 既存・WezTermを追加
├── setup                   # 既存・brew bundle + symlink.sh を呼ぶ形に整理
├── CLAUDE.md               # 既存
└── README.md               # 既存
```

> **`.gitconfig` について**: git設定は `.gitconfig` のみに一元管理する。XDGパス（`.config/git/config`）は使用しない。両ファイルが共存すると設定が分散するため。

---

## コンポーネント詳細

### 1. ZDOTDIR設定（`.zshenv`）

zshのデフォルト設定ファイル探索パスをXDGに変更する唯一のファイル。

```bash
# .zshenv
export ZDOTDIR="$HOME/.config/zsh"
```

zshは起動時に必ず `~/.zshenv` を読む（ZDOTDIR設定前なので固定パス）。
これにより `~/.config/zsh/.zshrc` と `~/.config/zsh/.zprofile` が読まれるようになる。

**重要**: `.zshenv` のシンボリックリンクを作成してから `.zshrc`/`.zprofile` を移動する。

### 2. シンボリックリンクスクリプト（`.bin/symlink.sh`）

mozumasu/dotfilesの `symlink.sh` のロジックを参考に実装。

**動作**:
- `~/dotfiles/` 内の全**ファイル**（ディレクトリではなくファイル単位）を `find -type f` で自動検出
- 除外リストに該当するファイルはスキップ
- `~/dotfiles/<path>` → `~/<path>` のシンボリックリンクを**ファイル単位**で作成
  - 例: `~/dotfiles/.config/zsh/.zshrc` → `~/.config/zsh/.zshrc`
  - リンク先の親ディレクトリ（`~/.config/zsh/`）は `mkdir -p` で自動作成
- 既存の実ファイル（非シンボリックリンク）は警告してスキップ（上書きしない）
- 既存シンボリックリンクが正しいターゲットを指している場合はスキップ
- 既存シンボリックリンクが古いターゲットを指している場合は `ln -sfv` で更新

**除外リスト**:
```
README.md, CLAUDE.md, Brewfile
.gitignore
.bin/                         # ~/dotfiles/.bin/symlink.sh を直接実行するためリンク不要
.git/
.claude/                      # Claude Codeが直接管理
docs/                         # 設計ドキュメント
setup                         # セットアップスクリプト
.ssh/id_*                     # 秘密鍵
.ssh/known_hosts              # ホスト確認情報
.ssh/authorized_keys          # 公開鍵リスト
.config/gh/hosts.yml          # GitHub CLI認証トークン
```

### 3. セットアップスクリプト（`setup`）

初回セットアップで実行する統合スクリプト。以下の順で実行:

```bash
1. Homebrew インストール（未インストール時のみ）
2. brew bundle --file=Brewfile
3. .bin/symlink.sh
```

`symlink.sh` は単体でも実行可能（冪等性あり）。設定追加後に単体実行することを想定。

### 4. WezTerm設定（`.config/wezterm/wezterm.lua`）

基本設定:
- フォント設定
- カラースキーム
- キーバインド（tmuxプレフィックス `C-t` と整合）
- ウィンドウ設定

### 5. `.gitignore` 追加ルール

```gitignore
# SSH
.ssh/id_*
.ssh/known_hosts
.ssh/authorized_keys

# GitHub CLI credentials
.config/gh/hosts.yml
```

### 6. `.ssh/config` のパーミッション

dotfilesリポジトリ内の `.ssh/config` は `600` に設定する。
シンボリックリンク自体のパーミッションではなく、リンク先の実ファイルに適用される。

```bash
chmod 600 ~/dotfiles/.ssh/config
```

---

## 移行手順

| ステップ | 内容 | 備考 |
|----------|------|------|
| 1 | `.gitignore` に秘密情報の除外ルール追加 | コミット前に必須 |
| 2 | `.bin/symlink.sh` 作成 | mozumasu方式 |
| 3 | `setup` スクリプトを整理 | brew bundle + symlink.sh 呼び出しに変更 |
| 4 | `.zshenv` 作成 → `symlink.sh` 実行して `~/.zshenv` リンクを作成 | 動作確認してから次へ |
| 5 | `.zshrc`, `.zprofile` を `.config/zsh/` に移動 → 新しいシェルで動作確認 | - |
| 6 | `gh/`, `karabiner/` を `~/.config/` からコピー | `.gitignore` 設定後 |
| 7 | `.ssh/config` を `dotfiles/.ssh/config` にコピー → `chmod 600 ~/dotfiles/.ssh/config`。`~/.ssh/` が未作成の場合は `mkdir -p ~/.ssh && chmod 700 ~/.ssh` | - |
| 8 | WezTerm設定（`.config/wezterm/wezterm.lua`）を作成 | - |
| 9 | Brewfile に wezterm を追加（未記載の場合） | - |
| 10 | `symlink.sh` を全体実行して全シンボリックリンクを作成・確認 | - |
| 11 | 旧 `setup` の不要な記述を削除 | - |

---

## リスクと対策

| リスク | 対策 |
|--------|------|
| zsh設定移動後に起動しなくなる | `.zshenv` のシンボリックリンク作成・確認後に移動（ステップ4→5の順序を守る） |
| 秘密鍵の誤コミット | `.gitignore` 追加（ステップ1）+ symlink.sh 除外リストで二重対策 |
| `~/.ssh/config` のパーミッションエラー | `chmod 600 ~/dotfiles/.ssh/config` を移行手順に明記 |
| 既存の実ファイルとの競合 | `symlink.sh` が警告してスキップ。手動でバックアップ→削除→再実行 |
| `karabiner.json` の自動生成部分 | 現状のファイルをそのまま取り込む。Karabiner-Elementsが更新した場合は `git diff` で確認 |
