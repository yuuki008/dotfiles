# Neovim 使用ガイド

このドキュメントでは、`yuuki008/dotfiles` リポジトリのNeovim設定の使用方法について詳しく説明します。

## 目次

- [導入](#導入)
- [インストール](#インストール)
- [基本操作](#基本操作)
- [プラグイン管理](#プラグイン管理)
- [主要なプラグインとその使用方法](#主要なプラグインとその使用方法)
- [カスタマイズ](#カスタマイズ)
- [ヒントとコツ](#ヒントとコツ)

## 導入

このガイドは、Neovimの基本的な使用方法と、設定ファイルのカスタマイズ方法について説明します。

## インストール

1. **リポジトリをクローン**:
    ```sh
    git clone https://github.com/yuuki008/dotfiles.git ~/dotfiles
    ```

2. **dotfilesディレクトリに移動**:
    ```sh
    cd ~/dotfiles
    ```

3. **セットアップスクリプトを実行**:
    ```sh
    ./setup.sh
    ```

4. **Neovimをインストール**:
    Neovimがシステムにインストールされていることを確認します。詳細なインストール手順は公式[Neovimインストールガイド](https://github.com/neovim/neovim/wiki/Installing-Neovim)を参照してください。

## 基本操作

### ノーマルモード (Normal Mode)
- **移動**:
  - `h` 左
  - `j` 下
  - `k` 上
  - `l` 右
- **編集**:
  - `i` インサートモードに入る
  - `dd` 行を削除
  - `yy` 行をコピー
  - `p` ペースト

### インサートモード (Insert Mode)
- **終了**:
  - `Esc` ノーマルモードに戻る

### ビジュアルモード (Visual Mode)
- **選択**:
  - `v` 文字単位で選択
  - `V` 行単位で選択

## プラグイン管理

プラグインは `packer.nvim` を使って管理されています。プラグインの設定は `~/.config/nvim/lua/plugins.lua` にあります。

### 新しいプラグインを追加する

1. `~/.config/nvim/lua/plugins.lua` を編集し、新しいプラグインをリストに追加します。
    ```lua
    use 'author/plugin-name'
    ```

2. ファイルを保存し、以下のコマンドを実行します。
    ```vim
    :PackerSync
    ```

## 主要なプラグインとその使用方法

### Packer.nvim

**Packer.nvim** は、プラグインのインストールと更新を管理するためのプラグインマネージャーです。

- **インストール**:
    ```vim
    :PackerInstall
    ```

- **更新**:
    ```vim
    :PackerUpdate
    ```

### nvim-lspconfig

**nvim-lspconfig** は、Neovim内でLSP（Language Server Protocol）を設定するためのプラグインです。

- **設定**:
    設定ファイルは `~/.config/nvim/lua/lsp.lua` にあります。

- **キー設定**:
    ```vim
    gd          - 定義に移動
    gD          - 宣言に移動
    gi          - 実装に移動
    gr          - 参照に移動
    K           - ホバーによるドキュメント表示
    ```

### nvim-treesitter

**nvim-treesitter** は、より良いシンタックスハイライトとコード解析を提供します。

- **インストール**:
    Treesitterパーサーを以下のコマンドでインストールします。
    ```vim
    :TSInstall <language>
    ```

- **設定**:
    設定ファイルは `~/.config/nvim/lua/treesitter.lua` にあります。

### Telescope.nvim

**Telescope.nvim** は、Neovim用のファジーファインダーです。

- **使用方法**:
    ```vim
    :Telescope find_files      - ファイル検索
    :Telescope live_grep       - ライブgrep
    :Telescope buffers         - バッファリスト
    :Telescope help_tags       - ヘルプタグ検索
    ```

### Lualine.nvim

**Lualine.nvim** は、Neovimのステータスラインプラグインです。

- **設定**:
    設定ファイルは `~/.config/nvim/lua/statusline.lua` にあります。

### その他のプラグイン

- **nvim-autopairs**: 括弧や引用符を自動で閉じるプラグイン。
- **nvim-web-devicons**: ファイルタイプアイコンを追加するプラグイン。
- **bufferline.nvim**: 上部にバッファラインを追加するプラグイン。

## カスタマイズ

必要に応じて設定ファイルをカスタマイズできます。設定ファイルは `~/.config/nvim/lua/` ディレクトリにあります。

## ヒントとコツ

- 設定ファイルを変更した後は、Neovimを再起動して変更を適用してください。
- プラグインを最新の状態に保つために、定期的に `:PackerSync` を実行してください。

## 貢献

貢献は大歓迎です！リポジトリをフォークして、プルリクエストを送信してください。

## ライセンス

このプロジェクトはMITライセンスの下でライセンスされています。

詳細については、[GitHubリポジトリ](https://github.com/yuuki008/dotfiles)をご覧ください。

