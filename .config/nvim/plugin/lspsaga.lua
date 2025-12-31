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

-- LSPファインダー - シンボルの定義を検索
-- 定義が見つからない場合は非表示になる
-- "open vsplit"などのアクションを使用した後、<C-t>で元の場所に戻れる
keymap("n", "gf", "<cmd>Lspsaga lsp_finder<CR>")

-- コードアクション（クイックフィックス、リファクタリングなど）
keymap({"n","v"}, "ga", "<cmd>Lspsaga code_action<CR>")

-- ファイル全体のカーソル下の単語を全てリネーム
keymap("n", "gr", "<cmd>Lspsaga rename<CR>")

-- プロジェクト全体のカーソル下の単語を全てリネーム
-- 注意: 2つの"gr"キーマップが定義されているため、実際には後者のプロジェクト全体リネームのみが有効
keymap("n", "gr", "<cmd>Lspsaga rename ++project<CR>")

-- 定義をプレビュー表示
-- フローティングウィンドウ内で定義ファイルを編集可能
-- open/vsplit等の操作もサポート（definition_action_keysを参照）
-- タグスタックにも対応
-- <C-t>で元の場所に戻れる
keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>")

-- 定義へジャンプ
-- 注意: 2つの"gd"キーマップが定義されているため、実際には後者の定義ジャンプのみが有効
keymap("n","gd", "<cmd>Lspsaga goto_definition<CR>")

-- 型定義をプレビュー表示
-- フローティングウィンドウ内で型定義ファイルを編集可能
-- open/vsplit等の操作もサポート（definition_action_keysを参照）
-- タグスタックにも対応
-- <C-t>で元の場所に戻れる
keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>")

-- 型定義へジャンプ
-- 注意: 2つの"gt"キーマップが定義されているため、実際には後者の型定義ジャンプのみが有効
keymap("n","gt", "<cmd>Lspsaga goto_type_definition<CR>")


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
-- ドキュメントが無い場合は通知が表示される
-- 無効化するには ":Lspsaga hover_doc ++quiet" を使用
-- キーを2回押すとホバーウィンドウに入れる
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>")

-- ホバーウィンドウを右上に固定表示したい場合は++keep引数を渡す
-- 注意1: ++keepを使用した場合、再度キーを押すとホバーウィンドウが閉じる
-- 注意2: ホバーウィンドウにジャンプしたい場合は "<C-w>w" を使用
-- 注意3: 2つの"K"キーマップが定義されているため、実際には後者の++keep版のみが有効
keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>")

-- コールヒエラルキー（関数の呼び出し関係）
keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>") -- この関数を呼び出している場所
keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>") -- この関数が呼び出している関数

-- フローティングターミナルの表示切り替え
keymap({"n", "t"}, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")
