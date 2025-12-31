-- Neovim 0.11+ の新しい LSP 設定形式を使用
-- 従来のlspconfig.setup()ではなく、vim.lsp.config と vim.lsp.enable を使用

-- LSPがバッファにアタッチされたときの設定
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- <C-x><C-o> でLSP補完を有効化
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- キーマッピング
        local opts = { noremap = true, silent = true, buffer = bufnr }

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)      -- 宣言へジャンプ
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)   -- 実装へジャンプ

        -- フォーマット機能
        -- LSPサーバーがフォーマット機能を持っている場合、保存時に自動フォーマット
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("Format_" .. bufnr, { clear = true }),
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format()
                end,
            })
        end
    end,
})

-- nvim-cmpの補完機能をLSPに統合
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- 各言語サーバーの設定

-- Flow（JavaScriptの型チェッカー）
vim.lsp.config.flow = {
    cmd = { 'flow', 'lsp' },
    filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx' },
    root_markers = { '.flowconfig' },
    capabilities = capabilities,
}

-- TypeScript/JavaScript言語サーバー（MDXもサポート）
vim.lsp.config.ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "typescript", "typescriptreact", "typescript.tsx", "mdx" },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
    capabilities = capabilities,
}

-- Terraform言語サーバー
vim.lsp.config.terraformls = {
    cmd = { "terraform-ls", "serve" },
    filetypes = { "terraform", "hcl", "tf" },
    root_markers = { '.terraform', '.git' },
    capabilities = capabilities,
}

-- Go言語サーバー
vim.lsp.config.gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    capabilities = capabilities,
}

-- Swift言語サーバー
vim.lsp.config.sourcekit = {
    cmd = { 'sourcekit-lsp' },
    filetypes = { 'swift', 'objective-c', 'objective-cpp' },
    root_markers = { 'Package.swift', '.git' },
    capabilities = capabilities,
}

-- Lua言語サーバー（Neovim開発用に設定済み）
vim.lsp.config.lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" }, -- "vim"をグローバル変数として認識
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true), -- Neovimランタイムファイルをライブラリに追加
                checkThirdParty = false, -- サードパーティライブラリの確認を無効化
            },
        },
    },
    capabilities = capabilities,
}

-- C/C++言語サーバー
vim.lsp.config.clangd = {
    cmd = { "clangd", "--std=c++17" },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
    capabilities = capabilities,
}

-- Ruby言語サーバー
vim.lsp.config.solargraph = {
    cmd = { 'solargraph', 'stdio' },
    filetypes = { 'ruby' },
    root_markers = { 'Gemfile', '.git' },
    settings = {
        solargraph = {
            diagnostics = true,
        },
    },
    capabilities = capabilities,
}

-- Tailwind CSS言語サーバー
vim.lsp.config.tailwindcss = {
    cmd = { 'tailwindcss-language-server', '--stdio' },
    filetypes = { 'html', 'css', 'scss', 'sass', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte', 'astro', 'mdx' },
    root_markers = { 'tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.mjs', 'tailwind.config.ts', 'postcss.config.js', 'postcss.config.cjs', 'package.json', '.git' },
    settings = {
        tailwindCSS = {
            classAttributes = { 'class', 'className', 'classList', 'ngClass' }, -- クラス属性として認識する属性名
            lint = {
                cssConflict = 'warning',              -- CSSの競合を警告
                invalidApply = 'error',                -- 無効な@applyをエラー
                invalidConfigPath = 'error',           -- 無効な設定パスをエラー
                invalidScreen = 'error',               -- 無効なスクリーンをエラー
                invalidTailwindDirective = 'error',    -- 無効なTailwindディレクティブをエラー
                invalidVariant = 'error',              -- 無効なバリアントをエラー
                recommendedVariantOrder = 'warning',   -- 推奨バリアント順序を警告
            },
            validate = true, -- 検証を有効化
        },
    },
    capabilities = capabilities,
}

-- 設定した全てのLSPサーバーを有効化
vim.lsp.enable('flow')
vim.lsp.enable('ts_ls')
vim.lsp.enable('terraformls')
vim.lsp.enable('gopls')
vim.lsp.enable('sourcekit')
vim.lsp.enable('lua_ls')
vim.lsp.enable('clangd')
vim.lsp.enable('solargraph')
vim.lsp.enable('tailwindcss')

-- 診断（Diagnostic）の設定
vim.diagnostic.config({
    virtual_text = {
        prefix = "●", -- 診断メッセージの前に表示する記号
    },
    update_in_insert = true, -- インサートモード中も診断を更新
    float = {
        source = "always", -- フロートウィンドウに常にソース（言語サーバー名）を表示
    },
})

-- 診断記号の定義（サイン列に表示されるアイコン）
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- カーソルを止めると診断メッセージを自動表示（250ms後）
-- CursorHold: ノーマルモードでカーソルを止めたとき
-- CursorHoldI: インサートモードでカーソルを止めたとき
vim.o.updatetime = 250
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    callback = function()
        -- フロートウィンドウで診断メッセージを表示（フォーカスは移動しない）
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})
