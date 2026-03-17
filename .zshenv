# zsh 設定ファイルの場所を XDG Base Directory に変更
export ZDOTDIR="$HOME/.config/zsh"

# Claude Code の設定ディレクトリ
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"

# gog CLI のデフォルトアカウント
export GOG_ACCOUNT="y.noumura@androots.co.jp"

# Cargo (Rust)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
