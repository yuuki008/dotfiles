local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
	return
end

gitsigns.setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	signcolumn = true, -- 変更箇所をサインカラムに表示
	numhl = false, -- 行番号のハイライトを無効化
	linehl = false, -- 行全体のハイライトを無効化
	word_diff = false, -- 単語単位の差分表示を無効化
	watch_gitdir = {
		interval = 1000,
		follow_files = true,
	},
	attach_to_untracked = true, -- 未追跡ファイルにも添付
	current_line_blame = false, -- カーソル行のブレームを表示（デフォルトはオフ）
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol", -- 行末に表示
		delay = 1000,
	},
	current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil, -- デフォルトのフォーマッタを使用
	max_file_length = 40000, -- 長いファイルでのパフォーマンス対策
	preview_config = {
		-- プレビューウィンドウのオプション
		border = "single",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- ナビゲーション
		map("n", "]c", function()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				gs.next_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, desc = "次の変更箇所へ" })

		map("n", "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, desc = "前の変更箇所へ" })

		-- アクション
		map("n", "<leader>hs", gs.stage_hunk, { desc = "変更をステージ" })
		map("n", "<leader>hr", gs.reset_hunk, { desc = "変更をリセット" })
		map("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "選択範囲をステージ" })
		map("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "選択範囲をリセット" })
		map("n", "<leader>hS", gs.stage_buffer, { desc = "バッファ全体をステージ" })
		map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "ステージを取り消し" })
		map("n", "<leader>hR", gs.reset_buffer, { desc = "バッファ全体をリセット" })
		map("n", "<leader>hp", gs.preview_hunk, { desc = "変更をプレビュー" })
		map("n", "<leader>hb", function()
			gs.blame_line({ full = true })
		end, { desc = "ブレーム表示" })
		map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "ブレーム表示切替" })
		map("n", "<leader>hd", gs.diffthis, { desc = "差分表示" })
		map("n", "<leader>hD", function()
			gs.diffthis("~")
		end, { desc = "前のコミットとの差分" })
		map("n", "<leader>td", gs.toggle_deleted, { desc = "削除行の表示切替" })

		-- テキストオブジェクト
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "変更箇所を選択" })
	end,
})
