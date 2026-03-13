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
  done < <(find . -type f -not -path '*/.git/*' -not -name '.DS_Store' | sed 's|^\./||')

  echo "Done!"
}

main "$@"
