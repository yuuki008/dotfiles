-- Neovim 0.11+ の新しい LSP 設定形式

-- キーマッピングとオプションの設定
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- Enable completion triggered by <c-x><c-o>
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Mappings
        local opts = { noremap = true, silent = true, buffer = bufnr }

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

        -- Formatting
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

-- Completion capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- LSP サーバーの設定
vim.lsp.config.flow = {
    cmd = { 'flow', 'lsp' },
    filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx' },
    root_markers = { '.flowconfig' },
    capabilities = capabilities,
}

vim.lsp.config.ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "typescript", "typescriptreact", "typescript.tsx", "mdx" },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
    capabilities = capabilities,
}

vim.lsp.config.terraformls = {
    cmd = { "terraform-ls", "serve" },
    filetypes = { "terraform", "hcl", "tf" },
    root_markers = { '.terraform', '.git' },
    capabilities = capabilities,
}

vim.lsp.config.gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    capabilities = capabilities,
}

vim.lsp.config.sourcekit = {
    cmd = { 'sourcekit-lsp' },
    filetypes = { 'swift', 'objective-c', 'objective-cpp' },
    root_markers = { 'Package.swift', '.git' },
    capabilities = capabilities,
}

vim.lsp.config.lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
        },
    },
    capabilities = capabilities,
}

vim.lsp.config.clangd = {
    cmd = { "clangd", "--std=c++17" },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
    capabilities = capabilities,
}

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

-- LSPサーバーを有効化
vim.lsp.enable('flow')
vim.lsp.enable('ts_ls')
vim.lsp.enable('terraformls')
vim.lsp.enable('gopls')
vim.lsp.enable('sourcekit')
vim.lsp.enable('lua_ls')
vim.lsp.enable('clangd')
vim.lsp.enable('solargraph')

-- Diagnostic の設定
vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
    },
    update_in_insert = true,
    float = {
        source = "always",
    },
})

-- Diagnostic symbols
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- CursorHoldイベントで診断メッセージをフロート表示
vim.o.updatetime = 250
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})
