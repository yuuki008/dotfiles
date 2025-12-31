local options = {
	encoding = "utf-8", -- 内部エンコーディング
	fileencoding = "utf-8", -- ファイル保存時のエンコーディング
	title = true, -- タイトルバーにファイル名を表示
	backup = false, -- バックアップファイルを作成しない
	clipboard = "unnamedplus", -- システムクリップボードを使用
	cmdheight = 2, -- コマンドラインの高さ
	completeopt = { "menuone", "noselect" }, -- 補完オプション
	conceallevel = 0, -- JSONやMarkdownで「隠し」記法を無効化
	hlsearch = true, -- 検索結果をハイライト
	ignorecase = true, -- 検索時に大文字小文字を無視
	mouse = "a", -- 全モードでマウスを有効化
	pumheight = 10, -- ポップアップメニューの最大高さ
	showmode = false, -- モード表示を非表示（statuslineで表示するため）
	showtabline = 2, -- タブラインを常に表示
	smartcase = true, -- 大文字が含まれる場合は大文字小文字を区別
	smartindent = true, -- スマートインデント
	swapfile = false, -- スワップファイルを作成しない
	termguicolors = true, -- 24bitカラーを有効化
	timeoutlen = 300, -- キーマッピングのタイムアウト時間（ミリ秒）
	undofile = true, -- アンドゥ履歴をファイルに保存
	updatetime = 300, -- 更新時間（ミリ秒）- CursorHoldイベントの遅延時間
	                  -- この設定により、カーソルを止めて300ms後に診断メッセージが自動表示される
	writebackup = false, -- バックアップを作成しない
	shell = "fish", -- 使用するシェル
	backupskip = { "/tmp/*", "/private/tmp/*" }, -- バックアップをスキップするパターン
	expandtab = true, -- タブをスペースに展開
	shiftwidth = 2, -- インデント幅
	tabstop = 2, -- タブ文字の幅
	cursorline = true, -- カーソル行をハイライト
	number = true, -- 行番号を表示
	relativenumber = false, -- 相対行番号を無効化
	numberwidth = 4, -- 行番号列の幅
	signcolumn = "yes", -- サイン列を常に表示
	wrap = false, -- 行の折り返しを無効化
	winblend = 0, -- ウィンドウの透明度
	wildoptions = "pum", -- コマンドライン補完をポップアップメニューで表示
	pumblend = 5, -- ポップアップメニューの透明度
	background = "dark", -- ダークモード
	scrolloff = 8, -- カーソルの上下に常に表示する行数
	sidescrolloff = 8, -- カーソルの左右に常に表示する文字数
	guifont = "monospace:h17", -- GUIフォント設定
	splitbelow = false, -- オンのとき、ウィンドウを横分割すると新しいウィンドウはカレントウィンドウの下に開かれる
	splitright = false, -- オンのとき、ウィンドウを縦分割すると新しいウィンドウはカレントウィンドウの右に開かれる
}

-- 短いメッセージに 'c' を追加（補完メニューメッセージを短縮）
vim.opt.shortmess:append("c")

-- オプションを適用
for k, v in pairs(options) do
	vim.opt[k] = v
end

-- カーソル移動で行をまたぐキーを設定
vim.cmd("set whichwrap+=<,>,[,],h,l")
-- ハイフンを単語の一部として扱う
vim.cmd([[set iskeyword+=-]])
-- 自動コメント継続を無効化（新しい行でコメントを自動挿入しない）
vim.cmd([[set formatoptions-=cro]]) -- TODO: この設定が効かない場合がある
