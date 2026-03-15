# ==================================================
# Homebrew
# ==================================================
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ==================================================
# uv（グローバル CLI ツール）
# ==================================================
export PATH="$HOME/.local/bin:$PATH"

# ==================================================
# Google Cloud SDK
# ==================================================
if [ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]; then
  . "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
fi
