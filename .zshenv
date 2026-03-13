# zsh 設定ファイルの場所を XDG Base Directory に変更
export ZDOTDIR="$HOME/.config/zsh"

# Claude Code の設定ディレクトリ
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"

# Cargo (Rust)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
