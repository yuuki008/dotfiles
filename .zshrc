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
alias cat="bat"
alias code="open -a 'Visual Studio Code'"
alias dc='docker-compose'

# some git comand aliases
alias pr="gh pr view --web"
alias gb="current_branch"
alias gc="gcheckout"
alias gs="git status"
alias gd="git diff"
alias gl="git log"
alias gsa="git stash apply stash@{0}"
alias gcm="git switch master"
alias gcd="git switch dev"
alias gmd="git merge dev"

# atcoder
alias ojtr='oj t -c "ruby main.rb" -d test'
alias ojtcpp='oj t -c "g++ -std=c++17 -O2 -o main main.cpp" -d test'

# nvim のショートカットキーヘルプファイルを開く
alias nvimh='nvim ~/.config/nvim/help.txt'
alias nerdth='nvim ~/.config/nvim/nerdtree_help.txt'


eval "$(starship init zsh)"
export GPG_TTY=$(tty)

