local fn = vim.fn

-- Packerを自動インストール
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Packerをインストール中... Neovimを再起動してください。")
	vim.cmd([[packadd packer.nvim]])
end

-- plugins.luaを保存したときに自動的にNeovimをリロードしてPackerSyncを実行
-- これにより、プラグインを追加・削除したときに自動的にインストール/アンインストールされる
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- 保護された呼び出しを使用（初回使用時にエラーを出さないため）
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Packerをポップアップウィンドウで表示
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- プラグインのインストール
return packer.startup(function(use)
	-- 必須プラグイン

	use({ "wbthomason/packer.nvim" }) -- パッケージマネージャー自体
	use({ "nvim-lua/plenary.nvim" })  -- 共通ユーティリティ

	-- カラースキーム
	use({ "EdenEast/nightfox.nvim" })

	use({ "nvim-lualine/lualine.nvim" })       -- ステータスライン
	use({ "windwp/nvim-autopairs" })           -- 括弧の自動補完（cmpとtreesitterと統合）
	use({ "kyazdani42/nvim-web-devicons" })    -- ファイルアイコン
	use({ "akinsho/bufferline.nvim" })         -- バッファライン

	-- 補完プラグイン
	use({ "hrsh7th/nvim-cmp" })          -- 補完エンジン本体
	use({ "hrsh7th/cmp-buffer" })        -- バッファからの補完
	use({ "hrsh7th/cmp-path" })          -- パス補完
	use({ "hrsh7th/cmp-cmdline" })       -- コマンドライン補完
	use({ "saadparwaiz1/cmp_luasnip" })  -- スニペット補完
	use({ "hrsh7th/cmp-nvim-lsp" })      -- LSPからの補完
	use({ "hrsh7th/cmp-nvim-lua" })      -- Neovim Lua API補完
	use({ "onsails/lspkind-nvim" })      -- 補完アイテムにアイコンを追加

	-- スニペット
	use({ "L3MON4D3/LuaSnip" })

	-- LSP
	use({ "neovim/nvim-lspconfig" })              -- LSP設定
	use({ "williamboman/nvim-lsp-installer" })    -- 言語サーバーインストーラー
	use({ "nvimtools/none-ls.nvim" })             -- フォーマッターとリンター用
	use({ "glepnir/lspsaga.nvim" })               -- LSP UI拡張

	-- フォーマッター
	use({ "MunifTanjim/prettier.nvim" })

	-- Git統合
	use({ "lewis6991/gitsigns.nvim" })

	-- ファジーファインダー
	use({ "nvim-telescope/telescope.nvim" })
	use({ "nvim-telescope/telescope-file-browser.nvim" })


	-- 構文解析（シンタックスハイライト向上）
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "vimdoc",       -- Vimドキュメント
          "luadoc",       -- Luaドキュメント
          "vim",          -- Vimscript
          "lua",          -- Lua
          "typescript",   -- TypeScript
          "tsx",          -- TypeScript JSX (React)
          "javascript",   -- JavaScript
          "json",         -- JSON
          "markdown",     -- Markdown
          "markdown_inline", -- Markdown inline code
        },
        highlight = {
          enable = true, -- シンタックスハイライトを有効化
          additional_vim_regex_highlighting = false, -- Vim正規表現ハイライトを無効化
        },
      })
    end
  })
  use({
    "davidmh/mdx.nvim", -- MDX専用プラグイン
    dependencies = { "nvim-treesitter/nvim-treesitter" }, -- Treesitter依存
    config = function()
      vim.treesitter.language.register("markdown", "mdx")
    end,
  })


	use({ "windwp/nvim-ts-autotag" }) -- HTMLタグの自動閉じ

  -- コメントアウトプラグイン
	use({ "tpope/vim-commentary" })

  -- デバッガ（GDB）
  use {'sakhnik/nvim-gdb', run = ':!./install.sh'}

  -- 集中執筆モード
  use({ "folke/zen-mode.nvim" })

  -- Prisma構文サポート
  use({ "pantharshit00/vim-prisma" })

  -- ファイルツリー
  use({
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons', -- ファイルアイコンを表示するために必要
    config = function()
      require'nvim-tree'.setup {
        view = {
          side = 'left', -- 左側に表示
        },
      }
    end
  })

	-- Packerクローン後に設定を自動セットアップ
	-- 全プラグインの最後に配置すること
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)

