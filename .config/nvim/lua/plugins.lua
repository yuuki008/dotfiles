-- プラグイン定義（lazy.nvim 形式）
-- plugin/ ディレクトリの設定ファイルと連携するプラグインは lazy = false（デフォルト）で即座に読み込む

return {
  -- ==============================
  -- 必須ユーティリティ
  -- ==============================
  { "nvim-lua/plenary.nvim" },

  -- ==============================
  -- カラースキーム
  -- ==============================
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "transparent",
      },
      sidebars = { "qf", "help" },
    },
  },

  -- ファイル名をウィンドウ上部に表示
  {
    "b0o/incline.nvim",
    dependencies = { "craftzdog/solarized-osaka.nvim" },
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local colors = require("solarized-osaka.colors").setup()
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = { guibg = colors.magenta500, guifg = colors.base4 },
            InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
          },
        },
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = { cursorline = true },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":p:~:.:h:h")
            .. "/"
            .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+]" .. filename
          end
          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },

  -- ==============================
  -- UI
  -- ==============================
  { "nvim-lualine/lualine.nvim" },          -- ステータスライン
  { "kyazdani42/nvim-web-devicons" },       -- ファイルアイコン
  { "akinsho/bufferline.nvim" },            -- バッファライン
  { "windwp/nvim-autopairs" },              -- 括弧の自動補完

  -- インデント可視化
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      chunk = {
        enable = true,
        chars = {
          horizontal_line = "─",
          vertical_line = "│",
          left_top = "╭",
          left_bottom = "╰",
          right_arrow = ">",
        },
        style = "#806d9c",
      },
    },
  },

  -- ==============================
  -- 補完プラグイン（plugin/cmp.lua で設定）
  -- ==============================
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "saadparwaiz1/cmp_luasnip" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-nvim-lua" },
  { "onsails/lspkind-nvim" },

  -- スニペット
  { "L3MON4D3/LuaSnip" },

  -- ==============================
  -- LSP（plugin/lspconfig.lua, plugin/lspsaga.lua で設定）
  -- ==============================
  { "neovim/nvim-lspconfig" },
  { "williamboman/nvim-lsp-installer" },
  { "nvimtools/none-ls.nvim" },
  { "glepnir/lspsaga.nvim" },

  -- ==============================
  -- フォーマッター（plugin/prettier.lua で設定）
  -- ==============================
  { "MunifTanjim/prettier.nvim" },

  -- ==============================
  -- Git（plugin/gitsigns.lua で設定）
  -- ==============================
  { "lewis6991/gitsigns.nvim" },

  -- Git差分ビューア
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      {
        "<leader>gd",
        function()
          local view = require("diffview.lib").get_current_view()
          if view then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Diffview トグル",
      },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "ファイル履歴" },
    },
    opts = {
      use_icons = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_horizontal", disable_diagnostics = true },
        file_history = { layout = "diff2_horizontal" },
      },
      file_panel = {
        listing_style = "tree",
        win_config = { position = "left", width = 35 },
      },
    },
  },

  -- ==============================
  -- ファジーファインダー
  -- ==============================
  { "nvim-telescope/telescope.nvim" },
  { "nvim-telescope/telescope-file-browser.nvim" },

  -- ==============================
  -- 構文解析（シンタックスハイライト向上）
  -- ==============================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Neovim 0.11+ では vim.treesitter の組み込み機能を使用
      -- ensure_installed は :TSInstall コマンドで手動管理
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
  -- MDXサポートは上記 treesitter config 内で vim.treesitter.language.register 済み

  -- HTMLタグの自動閉じ
  { "windwp/nvim-ts-autotag" },

  -- ==============================
  -- エディタ機能
  -- ==============================
  { "tpope/vim-commentary" },                       -- コメントアウト
  { "sakhnik/nvim-gdb", build = ":!./install.sh" }, -- デバッガ（GDB）
  { "folke/zen-mode.nvim" },                        -- 集中執筆モード（plugin/zen-mode.lua で設定）
  { "pantharshit00/vim-prisma" },                   -- Prisma構文サポート

  -- ファイルツリー
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { side = "left" },
      })
    end,
  },

  -- コード折りたたみ
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "VeryLazy",
    init = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    opts = {
      provider_selector = function(_, filetype, _)
        return { "treesitter", "indent" }
      end,
    },
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "全折りたたみを展開" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "全折りたたみを閉じる" },
      { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "折りたたみを展開" },
      { "zm", function() require("ufo").closeFoldsWith() end, desc = "折りたたみを閉じる" },
    },
  },

  -- 日本語ヘルプ
  {
    "vim-jp/vimdoc-ja",
    keys = { { "h", mode = "c" } },
  },
}
