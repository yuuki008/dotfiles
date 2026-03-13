-- Neovim設定ファイルのエントリーポイント

-- lazy.nvim のブートストラップ（自動インストール）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  print("lazy.nvim をインストール中... Neovim を再起動してください。")
end
vim.opt.rtp:prepend(lazypath)

-- 基本設定（プラグインより先に読み込む）
require("base")         -- 基本設定
require("autocmds")     -- 自動コマンド
require("options")      -- Vimオプション
require("keymaps")      -- キーマッピング

-- プラグイン管理（lazy.nvim）
require("lazy").setup(require("plugins"))

-- カラースキーム（プラグイン読み込み後に適用）
require("colorscheme")
