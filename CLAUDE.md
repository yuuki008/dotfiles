# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## リポジトリ概要

macOS 開発環境セットアップ用の個人 dotfiles リポジトリ。以下の設定ファイルを管理:
- Neovim (LSP サポート付きメインエディタ)
- WezTerm (ターミナルエミュレータ)
- tmux (ターミナルマルチプレクサ)
- zsh (シェル、XDG 準拠で `.config/zsh/` に配置)
- Starship (プロンプト)
- Karabiner-Elements (キーリマッピング)
- Git (グローバル ignore 含む)
- GitHub CLI (`gh`)
- SSH 設定

## セットアップとインストール

### 初期セットアップ
```sh
git clone https://github.com/yuuki008/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup
./setup
```

セットアップスクリプトの動作:
1. Homebrew をインストール (存在しない場合)
2. `Brewfile` からパッケージをインストール
3. シンボリックリンクを作成
4. macOS デフォルト設定の適用 (オプション、対話確認あり)

### 個別コマンド
```sh
# パッケージのインストール
brew bundle -v --file="$HOME/dotfiles/Brewfile"

# シンボリックリンクの作成
~/dotfiles/.bin/symlink.sh

# macOS デフォルト設定の適用
~/dotfiles/.macos
```

### シンボリックリンクの仕組み

`.bin/symlink.sh` がリポジトリ内のファイルを自動検出し `$HOME` 配下にシンボリックリンクを作成する。以下は自動除外:
- `.git/`, `.bin/`, `.claude/`, `docs/`
- `README.md`, `CLAUDE.md`, `Brewfile`, `setup`
- SSH 秘密鍵、GitHub CLI トークン

主なシンボリックリンク:
- `~/.zshenv` → `~/dotfiles/.zshenv` (ZDOTDIR を `.config/zsh/` に設定)
- `~/.config/zsh/.zshrc` → `~/dotfiles/.config/zsh/.zshrc`
- `~/.config/zsh/.zprofile` → `~/dotfiles/.config/zsh/.zprofile`
- `~/.gitconfig` → `~/dotfiles/.gitconfig`
- `~/.config/git/ignore` → `~/dotfiles/.config/git/ignore`
- `~/.config/starship.toml` → `~/dotfiles/.config/starship.toml`
- `~/.config/wezterm/` → `~/dotfiles/.config/wezterm/` (各ファイル)
- `~/.config/tmux/` → `~/dotfiles/.config/tmux/` (XDG 準拠)
- `~/.config/gh/config.yml` → `~/dotfiles/.config/gh/config.yml`
- `~/.config/karabiner/karabiner.json` → `~/dotfiles/.config/karabiner/karabiner.json`
- `~/.ssh/config` → `~/dotfiles/.ssh/config`
- `~/.config/nvim/` → `~/dotfiles/.config/nvim/` (各ファイル)

**zsh XDG サポート**: `~/.zshenv` に `ZDOTDIR=$HOME/.config/zsh` を設定し、XDG 準拠の場所から読み込む。

### マシン固有設定

`*.local` ファイル（例: `~/.config/zsh/.zshrc.local`）は `.gitignore` で除外済み。マシン固有の PATH やエイリアスを追加する場合に使用。`.zshrc` の末尾で自動読み込みされる。

## Neovim 設定アーキテクチャ

### モジュール構造
```
.config/nvim/
├── init.lua                    # エントリーポイント、全モジュールを require
├── lua/
│   ├── plugins.lua            # lazy.nvim によるプラグイン管理
│   ├── base.lua               # 基本設定
│   ├── options.lua            # Vim オプション
│   ├── keymaps.lua            # キーマッピング
│   ├── autocmds.lua           # 自動コマンド
│   └── colorscheme.lua        # カラースキーム設定
└── plugin/
    ├── lspconfig.lua          # LSP サーバー設定
    ├── cmp.lua                # nvim-cmp 補完設定
    ├── lspsaga.lua            # LSP UI 拡張
    ├── gitsigns.lua           # Git インテグレーション
    ├── prettier.lua           # コードフォーマット
    └── zen-mode.lua           # 集中執筆モード
```

### プラグイン管理
- **マネージャー**: lazy.nvim
- **新規プラグイン追加**: `lua/plugins.lua` を編集（lazy.nvim 形式のテーブルを追加）
- **プラグイン更新**: `:Lazy update`
- **プラグイン同期**: `:Lazy sync`

### LSP 設定 (Neovim 0.11+)
`vim.lsp.config` API を使用（lspconfig の setup 関数ではない）。設定済みサーバー:
- TypeScript/JavaScript: `ts_ls` (MDX ファイルもサポート)
- Go: `gopls`
- Lua: `lua_ls` (Neovim 開発用に設定済み)
- C/C++: `clangd`
- Ruby: `solargraph`
- Terraform: `terraformls`
- Swift: `sourcekit`
- JavaScript (Flow): `flow`
- Tailwind CSS: `tailwindcss`

**自動フォーマット**: `documentFormattingProvider` 機能を持つ LSP サーバーで保存時に有効化。

**診断**: `CursorHold` イベント時に自動表示 (250ms 遅延)。

### キーバインド
リーダーキー: `<Space>`

**ナビゲーション**:
- `<C-h/j/k/l>`: ウィンドウ間移動
- `gh/gl`: 前/次のタブ
- `<Space>h/l`: 行頭/行末へジャンプ

**ファイル操作**:
- `<C-p>`: Telescope ファイル検索
- `<C-g>`: Telescope live grep
- `<C-b>`: Telescope バッファ一覧
- `<Space>e`: NvimTree トグル

**編集**:
- `jk`: インサートモード終了
- `;`: コマンドモード入力 (`:` と入れ替え)
- `<Esc><Esc>`: 検索ハイライト解除

## WezTerm 設定

### モジュール構成
```
.config/wezterm/
├── wezterm.lua                 # メイン設定（モジュール読み込み）
├── keymaps.lua                 # キーバインド + リーダーキー定義
├── appearance.lua              # 外観設定（Catppuccin Mocha）
├── tab.lua                     # タブ設定
├── statusbar.lua               # ステータスバー
├── workspace.lua               # ワークスペース設定
└── modules/                    # オプショナルモジュール
    ├── opacity.lua             # 透過度切り替え
    ├── karabiner_profile.lua   # Karabiner プロファイル切り替え
    ├── claude_session.lua      # Claude セッション管理
    ├── caffeinate.lua          # スリープ防止
    └── translate.lua           # 翻訳機能
```

**リーダーキー**: `Ctrl+T`（2 秒タイムアウト）
- **注意**: tmux プレフィックスも `Ctrl+T` だが、WezTerm が先にキャプチャするため tmux 側は機能しない

**主なキーバインド**: `.config/wezterm/KEYBINDINGS.md` を参照。

## tmux 設定

設定ファイルは XDG 準拠で `~/.config/tmux/` に配置（tmux 3.1+ 対応）。

**プレフィックスキー**: `C-t`（デフォルトの `C-b` ではない）

**キーバインド**:
- `C-t r`: 設定リロード
- `C-t h/j/k/l`: Vim 風ペイン移動
- `C-t C-h/j/k/l`: ペインリサイズ（リピート可能）
- `C-S-Left/Right`: ウィンドウ移動

## シェル設定

### zsh (XDG 準拠構成)
- `~/.zshenv`: ZDOTDIR を設定するエントリーポイント
- `~/.config/zsh/.zshrc`: インタラクティブシェル設定
- `~/.config/zsh/.zprofile`: ログインシェル設定 (PATH 等)

**主な設定内容**:
- **プロンプト**: Starship
- **言語バージョン管理**: rbenv, pyenv, nvm
- **パス追加**: Go バイナリ, 自作スクリプト, Google Cloud SDK

**エイリアス**:
- `code`: Cursor エディタを開く
- `dc`: docker-compose
- `lg`: lazygit

## 設定の変更方法

### Neovim プラグインの追加
1. `.config/nvim/lua/plugins.lua` を編集
2. lazy.nvim 形式でプラグインを追加: `{ "author/plugin-name" }`
3. Neovim を再起動するか `:Lazy sync` を実行
4. 必要に応じて `.config/nvim/plugin/` にプラグイン固有の設定を追加

### LSP サーバーの追加
1. `.config/nvim/plugin/lspconfig.lua` を編集
2. `vim.lsp.config.<server_name>` でサーバー設定を追加
3. `vim.lsp.enable('<server_name>')` で有効化
4. 言語サーバーバイナリがインストールされていることを確認 (Brewfile またはパッケージマネージャー)

### システムパッケージの追加
`Brewfile` を編集して追加:
- `brew "package-name"`: フォーミュラの場合
- `cask "package-name"`: Cask の場合

`brew bundle` を実行してインストール。

## 重要な注意事項

- この設定は macOS を前提としている (`pbcopy` 使用、`uname` で Darwin チェック)
- Google Cloud SDK のパスは `/usr/local/Caskroom/google-cloud-sdk/latest/` にハードコード
- Neovim 設定は Lua のみ使用 (Vimscript なし)
- LSP 設定は Neovim 0.11+ API (`vim.lsp.config` と `vim.lsp.enable`) を使用
- Neovim の shell オプションは `fish` を使用（別途インストールが必要）
