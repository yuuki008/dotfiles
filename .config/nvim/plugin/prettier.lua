-- Prettier（コードフォーマッター）の読み込み
local status, prettier = pcall(require, "prettier")
if (not status) then return end

-- Prettierの設定
prettier.setup {
  bin = 'prettierd', -- prettierの高速版デーモンを使用
  filetypes = {
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "scss",
    "typescript",
    "typescriptreact",
    "yaml",
  },

  -- フォーマットオプション
  arrow_parens = "always",                    -- アロー関数の引数を常に括弧で囲む
  bracket_spacing = true,                     -- オブジェクトリテラルの括弧内にスペースを入れる
  embedded_language_formatting = "auto",      -- 埋め込み言語のフォーマットを自動判定
  end_of_line = "lf",                         -- 改行コードをLFに統一
  html_whitespace_sensitivity = "css",        -- HTMLの空白の扱いをCSSルールに従う
  jsx_bracket_same_line = false,              -- JSXの閉じ括弧を新しい行に配置
  jsx_single_quote = false,                   -- JSXではダブルクォートを使用
  print_width = 80,                           -- 1行の最大文字数
  prose_wrap = "preserve",                    -- Markdownの折り返しを保持
  quote_props = "as-needed",                  -- 必要な場合のみプロパティ名をクォートで囲む
  semi = true,                                -- 文末にセミコロンを付ける
  single_quote = false,                       -- ダブルクォートを使用
  tab_width = 2,                              -- タブ幅を2スペースに設定
  trailing_comma = "es5",                     -- ES5で有効な箇所に末尾カンマを付ける
  use_tabs = false,                           -- タブではなくスペースを使用
  vue_indent_script_and_style = false,        -- Vueファイルの<script>と<style>をインデントしない
}

-- ;a でフォーマットを実行（非同期）
vim.keymap.set('n', ';a',
  function()
    vim.lsp.buf.format({ async = true })
  end
)
