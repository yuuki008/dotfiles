-- Lspsaga（LSP UI拡張）の読み込み
local status, saga = pcall(require, "lspsaga")
if (not status) then return end

-- Lspsagaの設定
saga.setup({
  ui = {
    winblend = 10,              -- ウィンドウの透明度
    border = 'rounded',         -- 角丸ボーダー
    colors = {
      normal_bg = '#002b36'     -- 背景色
    }
  }
})

local keymap = vim.keymap.set

-- LSPファインダー - シンボルの参照と定義を一度に検索
keymap("n", "gf", "<cmd>Lspsaga finder<CR>")

-- コードアクション（クイックフィックス、リファクタリングなど）
keymap({"n","v"}, "ga", "<cmd>Lspsaga code_action<CR>")

-- リネーム機能
keymap("n", "gR", "<cmd>Lspsaga rename ++project<CR>")  -- プロジェクト全体リネーム

-- 定義へのナビゲーション
keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>")   -- 定義へジャンプ
keymap("n", "gp", "<cmd>Lspsaga peek_definition<CR>")   -- 定義をプレビュー（フローティングウィンドウ）

-- 型定義へのナビゲーション
keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>")   -- 型定義へジャンプ
keymap("n", "gT", "<cmd>Lspsaga peek_type_definition<CR>")   -- 型定義をプレビュー


-- 行の診断メッセージを表示
-- ++unfocus引数を渡すとフローティングウィンドウにフォーカスしない
keymap("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>")

-- カーソル位置の診断メッセージを表示
-- show_line_diagnosticsと同様に++unfocus引数をサポート
keymap("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")

-- バッファ全体の診断メッセージを表示
keymap("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")

-- 診断メッセージ間をジャンプ
-- <C-o>で前の場所に戻れる
keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")

-- エラーのみにフィルタして診断メッセージ間をジャンプ
keymap("n", "[E", function()
  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
keymap("n", "]E", function()
  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end)

-- アウトライン（シンボルツリー）の表示切り替え
keymap("n","<leader>o", "<cmd>Lspsaga outline<CR>")

-- ホバードキュメント（カーソル位置のドキュメント表示）
-- ++keep: ウィンドウを固定表示、再度押すと閉じる
keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>")

-- コールヒエラルキー（関数の呼び出し関係）
keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>") -- この関数を呼び出している場所
keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>") -- この関数が呼び出している関数

-- フローティングターミナルの表示切り替え
keymap({"n", "t"}, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")
