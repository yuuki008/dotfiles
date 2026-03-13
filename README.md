# dotfiles

macOS 開発環境セットアップ用の個人 dotfiles リポジトリです。

## 含まれる設定

| ツール | 説明 | 設定場所 |
|--------|------|----------|
| **Neovim** | LSP サポート付きメインエディタ（Lua 設定） | `.config/nvim/` |
| **WezTerm** | GPU ベースのターミナルエミュレータ | `.config/wezterm/` |
| **tmux** | ターミナルマルチプレクサ | `.config/tmux/` |
| **zsh** | シェル（XDG Base Directory 準拠） | `.config/zsh/` |
| **Starship** | クロスシェルプロンプト | `.config/starship.toml` |
| **Karabiner-Elements** | キーリマッピング | `.config/karabiner/` |
| **Git** | バージョン管理設定 + グローバル ignore | `.gitconfig`, `.config/git/` |
| **GitHub CLI** | GitHub 操作 | `.config/gh/` |
| **SSH** | SSH 接続設定 | `.ssh/config` |
| **Claude Code** | AI コーディングアシスタント設定 | `.config/claude/` |

## セットアップ

### 新しい Mac への導入

```sh
git clone https://github.com/yuuki008/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup
./setup
```

セットアップスクリプトが以下を自動実行します:

1. Homebrew のインストール（未インストールの場合）
2. `Brewfile` からパッケージをインストール
3. シンボリックリンクの作成
4. macOS デフォルト設定の適用（オプション）

### 個別操作

```sh
# パッケージのインストール
brew bundle --file="$HOME/dotfiles/Brewfile"

# シンボリックリンクの再作成
~/dotfiles/.bin/symlink.sh

# macOS デフォルト設定の適用
chmod +x ~/dotfiles/.macos
~/dotfiles/.macos
```

## ディレクトリ構成

```
~/dotfiles/
├── setup                       # 初期セットアップスクリプト
├── Brewfile                    # Homebrew パッケージ定義
├── .macos                      # macOS デフォルト設定スクリプト
├── .bin/
│   └── symlink.sh              # シンボリックリンク自動作成
├── .config/
│   ├── nvim/                   # Neovim（lazy.nvim + LSP）
│   ├── wezterm/                # WezTerm（Lua モジュール構成）
│   ├── tmux/                   # tmux（XDG 準拠）
│   ├── zsh/                    # zsh（.zshrc, .zprofile）
│   ├── starship.toml           # Starship プロンプト
│   ├── karabiner/              # Karabiner-Elements
│   ├── git/                    # Git グローバル ignore
│   ├── gh/                     # GitHub CLI
│   └── claude/                 # Claude Code
├── .gitconfig                  # Git 設定
├── .zshenv                     # ZDOTDIR 設定（XDG エントリーポイント）
├── .hushlogin                  # ログインメッセージ抑制
└── .ssh/                       # SSH 設定
```

## 主な特徴

### シンボリックリンク管理

`.bin/symlink.sh` がリポジトリ内のファイルを自動検出し、`$HOME` 配下に対応するシンボリックリンクを作成します。機密ファイル（SSH 秘密鍵、GitHub CLI トークン等）は自動除外されます。

### XDG Base Directory 準拠

zsh 設定を `~/.config/zsh/` に配置。`~/.zshenv` で `ZDOTDIR=$HOME/.config/zsh` を設定し、XDG 準拠のディレクトリ構成を実現しています。tmux も `~/.config/tmux/` に配置しています。

### マシン固有設定の分離

`*.local` ファイル（例: `~/.config/zsh/.zshrc.local`）を作成すると、Git 管理外でマシン固有の設定を追加できます。

### macOS デフォルト設定

`.macos` スクリプトで、キーリピート速度、Finder 設定、Dock 設定などの macOS システム設定を自動化しています。

## 参考

- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) - macOS デフォルト設定スクリプトの参考
- [Neovim の設定を Lua で書く](https://zenn.dev/hisasann/articles/neovim-settings-to-lua) - Neovim Lua 設定の参考
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/) - ディレクトリ構成の規約
