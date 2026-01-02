-- nvim-cmp（補完エンジン）の設定
local cmp = require'cmp'
local lspkind = require 'lspkind'

-- 基本的な補完設定
cmp.setup({
  snippet = {
    -- スニペットエンジンの設定
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  -- キーマッピング
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),     -- ドキュメントを上にスクロール
    ['<C-f>'] = cmp.mapping.scroll_docs(4),      -- ドキュメントを下にスクロール
    ['<C-Space>'] = cmp.mapping.complete(),      -- 補完を開始
    ['<C-e>'] = cmp.mapping.close(),             -- 補完メニューを閉じる
    ['<CR>'] = cmp.mapping.confirm({             -- 選択した項目を確定
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    }),
  }),
  -- 補完ソースの設定（優先順位順）
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },   -- LSPからの補完（最優先）
    { name = 'luasnip' },    -- スニペット補完
  }, {
    { name = 'buffer' },     -- バッファからの補完（LSPがない場合のフォールバック）
  }),
  -- 補完メニューのフォーマット設定
  formatting = {
    format = lspkind.cmp_format({ with_text = false, maxwidth = 50 })
  }
})

-- Gitコミットメッセージ用の補完設定
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' },  -- Git関連の補完
  }, {
    { name = 'buffer' },   -- バッファからの補完
  })
})

-- 検索モード（/）用の補完設定
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }  -- バッファからの補完
  }
})

-- コマンドラインモード（:）用の補完設定
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }      -- パス補完
  }, {
    { name = 'cmdline' }   -- コマンドライン補完
  })
})
