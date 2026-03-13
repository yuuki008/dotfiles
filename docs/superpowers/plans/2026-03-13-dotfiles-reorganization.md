# Dotfiles 再構成 実装計画

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** dotfilesをXDG準拠に再構成し、WezTermを追加、mozumasu方式の自動シンボリックリンクスクリプトに移行する

**Architecture:** `.config/` 配下にツール設定を統一し、`.bin/symlink.sh` が全ファイルを自動検出してホームディレクトリにリンクする。zshはZDOTDIR経由でXDG対応、gitconfigはルートに一元管理。

**Tech Stack:** bash, zsh, WezTerm (Lua設定), Homebrew

**Spec:** `docs/superpowers/specs/2026-03-13-dotfiles-reorganization-design.md`

---

## Chunk 1: 安全対策・基盤整備

### Task 1: `.gitignore` に秘密情報の除外ルールを追加

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: 現在の `.gitignore` を確認**

```bash
cat ~/dotfiles/.gitignore
```

- [ ] **Step 2: SSH・GitHub CLI認証情報の除外ルールを追加**

`.gitignore` に以下を追記:

```gitignore
# SSH（秘密鍵・既知ホスト）
.ssh/id_*
.ssh/known_hosts
.ssh/authorized_keys

# GitHub CLI認証トークン
.config/gh/hosts.yml
```

- [ ] **Step 3: コミット**

```bash
cd ~/dotfiles
git add .gitignore
git commit -m "chore: add secret exclusions for ssh and gh credentials"
```

---

### Task 2: `.bin/symlink.sh` を作成する

**Files:**
- Create: `.bin/symlink.sh`

- [ ] **Step 1: `.bin/` ディレクトリを作成**

```bash
mkdir -p ~/dotfiles/.bin
```

- [ ] **Step 2: `symlink.sh` を作成**

`~/dotfiles/.bin/symlink.sh` を以下の内容で作成:

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

# シンボリックリンクを作成しないファイルのパターン
SYMLINK_EXCLUDE_FILES=(
  "^README\.md$"
  "^CLAUDE\.md$"
  "^Brewfile$"
  "^\.gitignore$"
  "^setup$"
  "^\.bin/"
  "^\.git/"
  "^\.claude/"
  "^docs/"
  "^\.ssh/id_"
  "^\.ssh/known_hosts$"
  "^\.ssh/authorized_keys$"
  "^\.config/gh/hosts\.yml$"
)

is_excluded() {
  local file="$1"
  local pattern
  for pattern in "${SYMLINK_EXCLUDE_FILES[@]}"; do
    if [[ "$file" =~ $pattern ]]; then
      return 0
    fi
  done
  return 1
}

create_symlink() {
  local file="$1"
  local target="$DOTFILES_DIR/$file"
  local link="$HOME/$file"
  local link_dir
  link_dir="$(dirname "$link")"

  # 親ディレクトリを作成
  if ! mkdir -p "$link_dir"; then
    echo "Failed to create directory: $link_dir" >&2
    return 1
  fi

  # 実ファイル（シンボリックリンクでない）が存在する場合は警告してスキップ
  if [ -f "$link" ] && [ ! -L "$link" ]; then
    echo "Warning: $link exists and is not a symlink. Skipping." >&2
    return 1
  fi

  # シンボリックリンクの作成
  if [ -L "$link" ]; then
    # 既に正しいターゲットを指している場合はスキップ
    if [ "$(readlink "$link")" = "$target" ]; then
      return 0
    fi
    # 古いターゲットを指している場合は更新
    ln -sfv "$target" "$link"
  else
    ln -sv "$target" "$link"
  fi
}

main() {
  if ! cd "$DOTFILES_DIR"; then
    echo "Error: $DOTFILES_DIR not found." >&2
    exit 1
  fi

  echo "Processing dotfiles in $DOTFILES_DIR..."

  while IFS= read -r file; do
    if is_excluded "$file"; then
      continue
    fi
    create_symlink "$file" || true
  done < <(find . -type f ! -path '*/.git/*' ! -name '.DS_Store' | sed 's|^\./||')

  echo "Done!"
}

main "$@"
```

- [ ] **Step 3: 実行権限を付与**

```bash
chmod +x ~/dotfiles/.bin/symlink.sh
```

- [ ] **Step 4: ドライラン確認（実際に実行せず出力を確認）**

```bash
cd ~/dotfiles
find . -type f ! -path '*/.git/*' ! -name '.DS_Store' | sed 's|^\./||' | head -30
```

期待出力: `.config/nvim/...`, `.gitconfig`, `.zshrc` などが表示される

- [ ] **Step 5: コミット**

```bash
git add .bin/symlink.sh
git commit -m "feat: add mozumasu-style symlink script"
```

---

### Task 3: `setup` スクリプトを整理する

**Files:**
- Modify: `setup`

- [ ] **Step 1: 新しい `setup` スクリプトに書き換え**

```bash
#!/bin/sh
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ==================================================
# Homebrew インストール
# ==================================================
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apple Silicon の場合は Homebrew のパスを追加
if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ==================================================
# Homebrew パッケージのインストール
# ==================================================
echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ==================================================
# シンボリックリンクの作成
# ==================================================
echo "Creating symlinks..."
"$DOTFILES_DIR/.bin/symlink.sh"

# ==================================================
# Claude Code 固有の設定（.claude/ は symlink.sh 除外のため個別対応）
# ==================================================
chmod +x "$DOTFILES_DIR/.claude/statusline.sh"

echo ""
echo "Setup complete!"
echo "Run 'source ~/.config/zsh/.zshrc' to apply shell changes."
```

- [ ] **Step 2: 実行権限を確認**

```bash
chmod +x ~/dotfiles/setup
```

- [ ] **Step 3: コミット**

```bash
git add setup
git commit -m "refactor: simplify setup script to use symlink.sh"
```

---

## Chunk 2: zsh のXDG移行

### Task 4: `.zshenv` を作成して ZDOTDIR を設定する

**Files:**
- Create: `.zshenv`

- [ ] **Step 1: `.zshenv` を作成**

```bash
cat > ~/dotfiles/.zshenv << 'EOF'
# zsh 設定ファイルの場所を XDG Base Directory に変更
export ZDOTDIR="$HOME/.config/zsh"
EOF
```

- [ ] **Step 2: `symlink.sh` を実行して `~/.zshenv` を作成**

```bash
~/dotfiles/.bin/symlink.sh
```

- [ ] **Step 3: シンボリックリンクの確認**

```bash
ls -la ~/.zshenv
readlink ~/.zshenv
```

期待出力:
```
~/.zshenv -> /Users/yu-home/dotfiles/.zshenv
```

- [ ] **Step 4: コミット**

```bash
cd ~/dotfiles
git add .zshenv
git commit -m "feat: add .zshenv to set ZDOTDIR for XDG zsh config"
```

---

### Task 5: `.zshrc` と `.zprofile` を `.config/zsh/` に移動する

**Files:**
- Create: `.config/zsh/.zshrc` (`.zshrc` から移動)
- Create: `.config/zsh/.zprofile` (`.zprofile` から移動)
- Delete: `.zshrc`
- Delete: `.zprofile`

- [ ] **Step 1: `.config/zsh/` ディレクトリを作成**

```bash
mkdir -p ~/dotfiles/.config/zsh
```

- [ ] **Step 2: ファイルを移動**

```bash
mv ~/dotfiles/.zshrc ~/dotfiles/.config/zsh/.zshrc
mv ~/dotfiles/.zprofile ~/dotfiles/.config/zsh/.zprofile
```

- [ ] **Step 3: `symlink.sh` を実行してリンクを作成**

```bash
~/dotfiles/.bin/symlink.sh
```

- [ ] **Step 4: シンボリックリンクの確認**

```bash
ls -la ~/.config/zsh/
readlink ~/.config/zsh/.zshrc
readlink ~/.config/zsh/.zprofile
```

期待出力:
```
~/.config/zsh/.zshrc -> /Users/yu-home/dotfiles/.config/zsh/.zshrc
~/.config/zsh/.zprofile -> /Users/yu-home/dotfiles/.config/zsh/.zprofile
```

- [ ] **Step 5: 旧シンボリックリンクを削除（存在する場合）**

```bash
[ -L ~/.zshrc ] && rm ~/.zshrc
[ -L ~/.zprofile ] && rm ~/.zprofile
```

- [ ] **Step 6: 新しいターミナルセッションで zsh が正常起動するか確認**

```bash
zsh -i -c 'echo "zsh OK: $ZDOTDIR"'
```

期待出力:
```
zsh OK: /Users/yu-home/.config/zsh
```

- [ ] **Step 7: コミット**

```bash
cd ~/dotfiles
git add .config/zsh/.zshrc .config/zsh/.zprofile
git rm .zshrc .zprofile 2>/dev/null || true
git commit -m "feat: move zsh config to .config/zsh/ for XDG compliance"
```

---

## Chunk 3: 既存設定の取り込み

### Task 6: `.gitconfig` を dotfiles に追加する

**Files:**
- Create: `.gitconfig`

- [ ] **Step 1: `~/.gitconfig` を dotfiles にコピー**

```bash
cp ~/.gitconfig ~/dotfiles/.gitconfig
```

- [ ] **Step 2: 内容を確認（秘密情報が含まれていないか）**

```bash
cat ~/dotfiles/.gitconfig
```

- [ ] **Step 3: `symlink.sh` を実行**

```bash
~/dotfiles/.bin/symlink.sh
```

- [ ] **Step 4: シンボリックリンクを確認**

```bash
readlink ~/.gitconfig
```

期待出力: `/Users/yu-home/dotfiles/.gitconfig`

- [ ] **Step 5: コミット**

```bash
cd ~/dotfiles
git add .gitconfig
git commit -m "feat: add gitconfig to dotfiles"
```

---

### Task 7: `gh/` 設定を取り込む

**Files:**
- Create: `.config/gh/config.yml` (`~/.config/gh/config.yml` からコピー)

- [ ] **Step 1: `~/.config/gh/config.yml` の内容を確認（認証情報が含まれていないか確認）**

```bash
cat ~/.config/gh/config.yml
```

`hosts.yml` は除外済みなので `config.yml` のみ取り込む。

- [ ] **Step 2: ディレクトリを作成してコピー**

```bash
mkdir -p ~/dotfiles/.config/gh
cp ~/.config/gh/config.yml ~/dotfiles/.config/gh/config.yml
```

- [ ] **Step 3: `symlink.sh` を実行**

```bash
~/dotfiles/.bin/symlink.sh
```

`hosts.yml` が除外リストに含まれているため、`~/.config/gh/hosts.yml` はリンクされないことを確認:

```bash
ls -la ~/.config/gh/
```

- [ ] **Step 4: コミット**

```bash
cd ~/dotfiles
git add .config/gh/config.yml
git commit -m "feat: add gh CLI config"
```

---

### Task 8: `karabiner/` 設定を取り込む

**Files:**
- Create: `.config/karabiner/karabiner.json`

- [ ] **Step 1: `~/.config/karabiner/` の内容を確認**

```bash
ls ~/.config/karabiner/
```

- [ ] **Step 2: `karabiner.json` のみコピー（自動生成ファイルは除く）**

```bash
mkdir -p ~/dotfiles/.config/karabiner
cp ~/.config/karabiner/karabiner.json ~/dotfiles/.config/karabiner/karabiner.json
```

- [ ] **Step 3: `symlink.sh` を実行**

```bash
~/dotfiles/.bin/symlink.sh
```

- [ ] **Step 4: シンボリックリンクの確認**

```bash
readlink ~/.config/karabiner/karabiner.json
```

期待出力: `/Users/yu-home/dotfiles/.config/karabiner/karabiner.json`

- [ ] **Step 5: コミット**

```bash
cd ~/dotfiles
git add .config/karabiner/karabiner.json
git commit -m "feat: add Karabiner-Elements config"
```

---

### Task 9: `.ssh/config` を取り込む

**Files:**
- Create: `.ssh/config`

> **注意**: `~/.ssh/config` にはVagrant自動生成のエントリが含まれている場合がある。コピー前に内容を確認し、不要なエントリを削除すること。

- [ ] **Step 1: 現在の `~/.ssh/config` を確認**

```bash
cat ~/.ssh/config
```

Vagrantエントリ（`# VAGRANT:` コメント付き）は削除を検討する。

- [ ] **Step 2: `~/.ssh/` のパーミッションを確認・設定**

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ls -la ~/.ssh/ | head -3
```

- [ ] **Step 3: dotfiles に `.ssh/` ディレクトリを作成してコピー**

```bash
mkdir -p ~/dotfiles/.ssh
cp ~/.ssh/config ~/dotfiles/.ssh/config
```

- [ ] **Step 4: パーミッションを設定**

```bash
chmod 600 ~/dotfiles/.ssh/config
```

- [ ] **Step 5: `symlink.sh` を実行**

```bash
~/dotfiles/.bin/symlink.sh
```

- [ ] **Step 6: シンボリックリンクとパーミッションの確認**

```bash
ls -la ~/.ssh/config    # lrwxrwxrwx（シンボリックリンク）
ls -la ~/dotfiles/.ssh/config  # -rw------- (600)
readlink ~/.ssh/config
```

期待出力（readlink）: `/Users/yu-home/dotfiles/.ssh/config`

- [ ] **Step 7: コミット**

```bash
cd ~/dotfiles
git add .ssh/config
git commit -m "feat: add ssh config"
```

---

## Chunk 4: WezTerm 設定追加

### Task 10: Brewfile に WezTerm を追加する

**Files:**
- Modify: `Brewfile`

- [ ] **Step 1: Brewfile に wezterm を追加**

`Brewfile` の cask セクションに追記:

```ruby
cask "wezterm"
```

- [ ] **Step 2: インストール**

```bash
brew install --cask wezterm
```

- [ ] **Step 3: コミット**

```bash
cd ~/dotfiles
git add Brewfile
git commit -m "chore: add wezterm to Brewfile"
```

---

### Task 11: WezTerm 設定ファイルを作成する

**Files:**
- Create: `.config/wezterm/wezterm.lua`

- [ ] **Step 1: `.config/wezterm/` ディレクトリを作成**

```bash
mkdir -p ~/dotfiles/.config/wezterm
```

- [ ] **Step 2: `wezterm.lua` を作成**

```bash
cat > ~/dotfiles/.config/wezterm/wezterm.lua << 'EOF'
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ==================================================
-- フォント
-- ==================================================
config.font = wezterm.font("UDEV Gothic 35NFLG")
config.font_size = 14.0

-- ==================================================
-- カラースキーム
-- ==================================================
config.color_scheme = "Tokyo Night"

-- ==================================================
-- ウィンドウ
-- ==================================================
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}
config.initial_cols = 220
config.initial_rows = 50

-- ==================================================
-- タブバー
-- ==================================================
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- ==================================================
-- キーバインド（tmux C-t プレフィックスと整合）
-- ==================================================
config.keys = {
  -- Cmd+T で新しいタブ
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  -- Cmd+W でタブを閉じる
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
  -- Cmd+数字でタブ切り替え
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
}

-- ==================================================
-- その他
-- ==================================================
config.scrollback_lines = 10000
config.enable_scroll_bar = false

return config
EOF
```

> **フォントについて**: `UDEV Gothic 35NFLG` は日本語対応の人気フォント。未インストールの場合は `brew install --cask font-udev-gothic-nf` でインストール、または好みのフォント名に変更すること。

- [ ] **Step 3: `symlink.sh` を実行**

```bash
~/dotfiles/.bin/symlink.sh
```

- [ ] **Step 4: WezTerm の設定確認**

WezTermを起動して設定が読み込まれているか確認:

```bash
# wezterm.lua の構文エラーがないか確認
wezterm ls-fonts --text "test" 2>&1 | head -5 || true
```

- [ ] **Step 5: コミット**

```bash
cd ~/dotfiles
git add .config/wezterm/wezterm.lua
git commit -m "feat: add WezTerm config with Tokyo Night theme"
```

---

## Chunk 5: 最終確認・整理

### Task 12: 全シンボリックリンクの最終確認

- [ ] **Step 1: `symlink.sh` を全体実行**

```bash
~/dotfiles/.bin/symlink.sh
```

- [ ] **Step 2: 主要なリンクを確認**

```bash
echo "=== zsh ==="
readlink ~/.zshenv
readlink ~/.config/zsh/.zshrc
readlink ~/.config/zsh/.zprofile

echo "=== git ==="
readlink ~/.gitconfig

echo "=== starship ==="
readlink ~/.config/starship.toml

echo "=== nvim ==="
readlink ~/.config/nvim

echo "=== wezterm ==="
readlink ~/.config/wezterm/wezterm.lua

echo "=== gh ==="
readlink ~/.config/gh/config.yml

echo "=== karabiner ==="
readlink ~/.config/karabiner/karabiner.json

echo "=== ssh ==="
readlink ~/.ssh/config
```

- [ ] **Step 3: zsh の動作確認**

新しいターミナルを開いて以下を確認:

```bash
echo $ZDOTDIR        # /Users/yu-home/.config/zsh
echo $SHELL          # /bin/zsh
which starship       # /opt/homebrew/bin/starship
```

- [ ] **Step 4: CLAUDE.md を更新**

`CLAUDE.md` のセットアップ手順を新しい構造に合わせて更新する。特に:
- シンボリックリンク方法が `symlink.sh` に変わった旨
- zsh設定が `.config/zsh/` に移動した旨

- [ ] **Step 5: 最終コミット**

```bash
cd ~/dotfiles
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for new dotfiles structure"
```
