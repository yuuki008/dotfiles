#Default system paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Homebrew
if [ -d "/usr/local/bin" ]; then
  export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
elif [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

# Custom paths
export PATH="$HOME/dotfiles/packages/scripts/scripts:$PATH"
export PATH="$HOME/.nodebrew/current/bin:$PATH"
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
export PATH="$HOME/Library/Android/sdk/emulator:$PATH"
export PATH="$HOME/Library/Android/sdk/tools:$PATH"
export PATH="$HOME/Library/Android/sdk/tools/bin:$PATH"
export PATH="$HOME/Library/Android/sdk/cmdline-tools/latest/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.pyenv/shims:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="/usr/local/opt/curl/bin:$PATH"
export PATH="$HOME/usr/local/bin:$PATH"
export PATH="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH"
export PATH="$HOME/github/yuuki008/aoj/cli:$PATH"
# Load rbenv
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

# Load pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'

# Aliases
alias code="open -a 'Visual Studio Code'"
alias dc='docker-compose'
alias cl="clear"

# atcoder
alias ojtr='oj t -c "ruby main.rb" -d tests'
alias ojtcpp='g++ -o main main.cpp;  oj test -c ./main -d tests'

# ディレクトリ移動のショートカット
alias yuuki008="cd ~/github/yuuki008"
alias work="cd ~/github/hide-and-seek-dev"
alias note="cd ~/github/yuuki008/note"
alias dotfiles="cd ~/dotfiles"
export GPG_TTY=$(tty)

# lazygit
alias lg="lazygit"

# starship
eval "$(starship init zsh)"
