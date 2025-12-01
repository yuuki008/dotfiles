# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## リポジトリ概要

これはmacOS開発環境セットアップ用の個人dotfilesリポジトリです。以下の設定ファイルを管理しています:
- Neovim (LSPサポート付きメインテキストエディタ)
- tmux (ターミナルマルチプレクサ)
- zsh (シェル)
- Starship (プロンプト)
- Ranger (ファイルマネージャー)

## セットアップとインストール

### 初期セットアップ
```sh
chmod +x setup
./setup
```

セットアップスクリプトの動作:
1. Homebrewをインストール (存在しない場合)
2. このリポジトリを `~/dotfiles` にクローン
3. Brewfileを使って `brew bundle` でパッケージをインストール
4. `~/.config` から dotfiles 設定へのシンボリックリンクを作成

### パッケージのインストール
```sh
brew bundle -v --file="$HOME/dotfiles/Brewfile"
```

### シンボリックリンクの作成
設定ファイルはリポジトリから標準的な場所へシンボリックリンクされます:
- `~/.config/nvim` → `~/dotfiles/.config/nvim`
- `~/.config/starship.toml` → `~/dotfiles/.config/starship.toml`
- `~/.tmux.conf` → `~/dotfiles/.config/tmux/tmux.conf`

## Neovim設定アーキテクチャ

### モジュール構造
Neovim設定はLuaを使用し、`init.lua`から読み込まれるモジュール構造になっています:

```
.config/nvim/
├── init.lua                    # エントリーポイント、全モジュールをrequire
├── lua/
│   ├── plugins.lua            # packer.nvimによるプラグイン管理
│   ├── base.lua               # 基本設定
│   ├── options.lua            # Vimオプション
│   ├── keymaps.lua            # キーマッピング
│   ├── autocmds.lua           # 自動コマンド
│   └── colorscheme.lua        # カラースキーム設定
└── plugin/
    ├── lspconfig.lua          # LSPサーバー設定
    ├── cmp.lua                # nvim-cmp補完設定
    ├── lspsaga.lua            # LSP UI拡張
    ├── prettier.lua           # コードフォーマット
    └── zen-mode.lua           # 集中執筆モード
```

### プラグイン管理
- **マネージャー**: packer.nvim
- **自動同期**: `plugins.lua`を保存すると自動的に `:PackerSync` が実行される
- **新規プラグイン追加**: `lua/plugins.lua`を編集して `:PackerSync` を実行
- **プラグイン更新**: `:PackerUpdate`

### LSP設定 (Neovim 0.11+)
lspconfigのsetup関数ではなく、新しい `vim.lsp.config` APIを使用。設定済みサーバー:
- TypeScript/JavaScript: `ts_ls` (MDXファイルもサポート)
- Go: `gopls`
- Lua: `lua_ls` (Neovim開発用に設定済み)
- C/C++: `clangd`
- Ruby: `solargraph`
- Terraform: `terraformls`
- Swift: `sourcekit`

**自動フォーマット**: `documentFormattingProvider`機能を持つLSPサーバーで保存時に有効化されます。

**診断**: `CursorHold`イベント時に自動表示 (250ms遅延)。

### キーバインド
リーダーキー: `<Space>`

**ナビゲーション**:
- `<C-h/j/k/l>`: ウィンドウ間移動
- `gh/gl`: 前/次のタブ
- `<Space>h/l`: 行頭/行末へジャンプ

**ファイル操作**:
- `<C-p>`: Telescopeファイル検索
- `<C-g>`: Telescope live grep
- `<C-b>`: Telescopeバッファ一覧
- `<Space>e`: NvimTreeトグル

**編集**:
- `jk`: インサートモード終了
- `;`: コマンドモード入力 (`:`と入れ替え)
- `<Esc><Esc>`: 検索ハイライト解除

## tmux設定

**プレフィックスキー**: `C-t` (デフォルトの `C-b` ではない)

**キーバインド**:
- `C-t r`: 設定リロード
- `C-t h/j/k/l`: Vim風ペイン移動
- `C-t C-h/j/k/l`: ペインリサイズ (リピート可能)
- `C-S-Left/Right`: ウィンドウ移動

**機能**:
- Viモードキーバインディング
- コピーモードで `y` でシステムクリップボードへコピー (`reattach-to-user-namespace`が必要)
- Powerlineステータスバー (`.tmux.powerline.conf`から読み込み)
- macOS固有設定は `.tmux.conf.osx` から読み込み

## シェル設定

### zsh (.zshrc)
- **プロンプト**: Starship
- **言語バージョン管理**: rbenv, pyenv, nodebrew
- **パス追加**: Goバイナリ, カスタムスクリプト, Google Cloud SDK

**エイリアス**:
- `code`: Cursorエディタを開く
- `dc`: docker-compose
- `lg`: lazygit

## 設定の変更方法

### Neovimプラグインの追加
1. `.config/nvim/lua/plugins.lua`を編集
2. packerの`startup`関数内にプラグインを追加: `use 'author/plugin-name'`
3. ファイルを保存 (自動的に `:PackerSync` が実行される)
4. 必要に応じて `.config/nvim/plugin/` にプラグイン固有の設定を追加

### LSPサーバーの追加
1. `.config/nvim/plugin/lspconfig.lua`を編集
2. `vim.lsp.config.<server_name>`を使ってサーバー設定を追加
3. `vim.lsp.enable('<server_name>')`で有効化
4. 言語サーバーバイナリがインストールされていることを確認 (Brewfileまたは手動)

### システムパッケージの追加
`Brewfile`を編集して追加:
- `brew "package-name"` フォーミュラの場合
- `cask "package-name"` Caskの場合

`brew bundle`を実行してインストール。

## 重要な注意事項

- この設定はmacOSを前提としています (`pbcopy`を使用、`uname`でDarwinをチェック)
- Google Cloud SDKのパスは `/usr/local/Caskroom/google-cloud-sdk/latest/` にハードコードされています
- Neovim設定はLuaのみを使用 (Vimscriptなし)
- LSP設定はNeovim 0.11+ API (`vim.lsp.config`と`vim.lsp.enable`)を使用
