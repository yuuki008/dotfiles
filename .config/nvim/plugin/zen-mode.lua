-- Zen Mode（集中執筆モード）の読み込み
local status, zen_mode = pcall(require, "zen-mode")
if (not status) then return end

-- Zen Modeの設定
zen_mode.setup {
  window = {
    backdrop = 0.95,  -- 背景の暗さ（0-1の範囲）
    width = 120,      -- ウィンドウ幅
    height = 1,       -- ウィンドウ高さ（1 = 100%）
    options = {
      signcolumn = "no",      -- サイン列を非表示
      number = false,          -- 行番号を非表示
      relativenumber = false,  -- 相対行番号を非表示
      cursorline = false,      -- カーソル行ハイライトを無効化
      cursorcolumn = false,    -- カーソル列ハイライトを無効化
      foldcolumn = "0",        -- 折りたたみ列を非表示
      list = false,            -- 不可視文字を非表示
    },
  },
  plugins = {
    options = {
      enabled = true,   -- プラグインオプションを有効化
      ruler = false,    -- ルーラーを非表示
      showcmd = false,  -- コマンド表示を無効化
    },
    twilight = { enabled = true },   -- 薄暗いハイライトモードを有効化
    gitsigns = { enabled = false },  -- Gitsignsを無効化
    tmux = { enabled = false },      -- tmux統合を無効化
  },
}

-- <leader>z でZen Modeの切り替え
vim.keymap.set('n', '<leader>z',
  function()
    require("zen-mode").toggle()
  end
)
