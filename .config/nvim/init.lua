-- Neovim設定ファイルのエントリーポイント
-- 各モジュールを順番に読み込む

require("plugins")      -- プラグイン管理（packer.nvim）
require("base")         -- 基本設定
require("autocmds")     -- 自動コマンド
require("options")      -- Vimオプション
require("keymaps")      -- キーマッピング
require("colorscheme")  -- カラースキーム

