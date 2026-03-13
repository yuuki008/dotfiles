# zsh 設定ファイルの場所を XDG Base Directory に変更
export ZDOTDIR="$HOME/.config/zsh"

# Cargo (Rust)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
