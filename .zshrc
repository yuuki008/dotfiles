# zsh設定ファイル

# デフォルトシステムパス
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Homebrew（Apple Silicon Mac用）
if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

# カスタムパス設定
export PATH="$HOME/.local/bin:$PATH"                                               # ローカルバイナリ

# Go言語の環境設定
export GOPATH="$HOME/go"                                                           # Goワークスペース
export GOROOT="$(brew --prefix go)/libexec" 2>/dev/null || export GOROOT="/usr/local/go"  # Goインストールディレクトリ
if command -v go 1>/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH)/bin:$(go env GOROOT)/bin"                   # Goバイナリパス
fi

export PATH="$HOME/dotfiles/packages/scripts/scripts:$PATH"                        # 自作スクリプト
export PATH="$HOME/.rbenv/shims:$PATH"                                             # rbenv（Ruby）
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.pyenv/shims:$PATH"                                             # pyenv（Python）
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="/usr/local/opt/curl/bin:$PATH"                                        # curl
export PATH="$HOME/usr/local/bin:$PATH"
export PATH="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH" # Google Cloud SDK
export PATH="$HOME/github/yuuki008/aoj/cli:$PATH"                                  # 競技プログラミング用CLI

# rbenvの初期化（Rubyバージョン管理）
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

# pyenvの初期化（Pythonバージョン管理）
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Google Cloud SDK設定の読み込み
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'

# エイリアス設定
alias code="open -a 'Cursor'"  # CursorエディタをVSCode代わりに開く
alias dc='docker-compose'       # docker-composeの短縮形

# lazygit（Git TUIツール）
alias lg="lazygit"

# Starship（プロンプトテーマ）の初期化
eval "$(starship init zsh)"

# nvm（Node.jsバージョン管理）の設定
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                      # nvmスクリプトを読み込み
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # bash補完を読み込み

# .nvmrcファイルがあるディレクトリに入ったときに自動的にNode.jsバージョンを切り替え
# プロジェクトごとに異なるNode.jsバージョンを使い分けられる便利な機能
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    # .nvmrcファイルが見つかった場合
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      # 指定されたバージョンがインストールされていない場合はインストール
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      # 現在のバージョンと異なる場合は切り替え
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    # .nvmrcがないディレクトリに移動した場合はデフォルトバージョンに戻す
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
# ディレクトリ変更時にload-nvmrc関数を実行
add-zsh-hook chpwd load-nvmrc
# 起動時にも実行
load-nvmrc
