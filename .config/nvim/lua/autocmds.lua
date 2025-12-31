-- 自動コマンドグループの作成/取得
local augroup = vim.api.nvim_create_augroup
-- 自動コマンドの作成
local autocmd = vim.api.nvim_create_autocmd

-- ファイル保存時に行末の空白を削除
autocmd("BufWritePre", {
	pattern = "*",
	command = ":%s/\\s\\+$//e",
})

-- 新しい行で自動コメント継続を無効化
autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

-- ファイルを開いたときにカーソル位置を復元
-- 前回ファイルを閉じたときのカーソル位置を記憶して、次回開いたときにその位置に戻る
autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		-- g`" : 最後に編集した位置にジャンプ
		-- zv  : カーソル位置が折りたたまれている場合は展開
		vim.api.nvim_exec('silent! normal! g`"zv', false)
	end,
})

-- MDXファイルタイプの設定
vim.cmd([[
  augroup mdx_filetype
    autocmd!
    autocmd BufRead,BufNewFile *.mdx set filetype=mdx
  augroup END
]])
