-- キーマッピングのデフォルトオプション
local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- キーマップ設定用の関数
-- local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap

-- スペースキーをリーダーキーに設定
-- リーダーキーは、複数キーの組み合わせコマンドのプレフィックスとして使用
-- 例: <leader>z でZen Mode、<leader>e でファイルツリー
keymap("", "<Space>", "<Nop>", opts)  -- スペースキーのデフォルト動作を無効化
vim.g.mapleader = " "                  -- グローバルリーダーキーをスペースに設定
vim.g.maplocalleader = " "             -- ローカルリーダーキーもスペースに設定

-- モード一覧
--   normal_mode = 'n',      ノーマルモード
--   insert_mode = 'i',      インサートモード
--   visual_mode = 'v',      ビジュアルモード
--   visual_block_mode = 'x', ビジュアルブロックモード
--   term_mode = 't',        ターミナルモード
--   command_mode = 'c',     コマンドモード

-- ノーマルモード --
-- ウィンドウ間の移動を改善
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- 新しいタブを開く
keymap("n", "te", ":tabedit", opts)
-- 新しいタブを一番右に作る
keymap("n", "gn", ":tabnew<Return>", opts)
-- タブ間を移動
keymap("n", "gh", "gT", opts)
keymap("n", "gl", "gt", opts)

-- ウィンドウを分割
keymap("n", "ss", ":split<Return><C-w>w", opts)
keymap("n", "sv", ":vsplit<Return><C-w>w", opts)

-- 全選択
keymap("n", "<C-a>", "gg<S-v>G", opts)

-- x でヤンクしない（削除のみ）
keymap("n", "x", '"_x', opts)

-- 単語を後方削除（ヤンクしない）
keymap("n", "dw", 'vb"_d', opts)

-- 行の端に行く
keymap("n", "<Space>h", "^", opts)
keymap("n", "<Space>l", "$", opts)

-- ;でコマンド入力( ;と:を入れ替)
keymap("n", ";", ":", opts)

-- 行末までのヤンクにする
keymap("n", "Y", "y$", opts)

-- <Space>q で強制終了
keymap("n", "<Space>q", ":<C-u>q!<Return>", opts)

-- ESC連打で検索ハイライトを解除
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)

-- インサートモード --
-- jk を素早く入力してインサートモードを抜ける
-- Escキーに手を伸ばす必要がなくなるので、ホームポジションから手を動かさずに済む
keymap("i", "jk", "<ESC>", opts)

-- コンマの後に自動的にスペースを挿入
keymap("i", ",", ",<Space>", opts)

-- ビジュアルモード --
-- インデント後も選択を維持
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- ビジュアルモード時vで行末まで選択
keymap("v", "v", "$h", opts)

-- 2番レジスタを使いやすくした（ペースト時に上書きされない）
-- 通常のペーストは選択テキストで無名レジスタが上書きされてしまうが、2番レジスタを使えば保持される
keymap("v", "<C-p>", '"2p', opts)

-- Telescope（ファジーファインダー）のキーマッピング
keymap("n", "<C-p>", ':Telescope find_files<CR>', opts) -- ファイル検索
keymap("n", "<C-g>", ':Telescope live_grep<CR>', opts)  -- 文字列検索
keymap("n", "<C-b>", ':Telescope buffers<CR>', opts)    -- バッファ一覧
keymap("n", "<C-c>", ':Telescope commands<CR>', opts)   -- コマンド一覧
keymap("n", "<C-m>", ':Telescope keymaps<CR>', opts)    -- キーマップ一覧

-- NvimTree（ファイルツリー）のキーマッピング
keymap("n", "<Space>e", ":NvimTreeToggle<CR>", opts)

-- ターミナルモード --
-- Escでターミナルモードからノーマルモードに戻る
keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
