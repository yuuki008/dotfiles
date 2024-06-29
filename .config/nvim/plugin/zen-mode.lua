local status, zen_mode = pcall(require, "zen-mode")
if (not status) then return end

zen_mode.setup {
  window = {
    backdrop = 0.95,
    width = 120,
    height = 1,
    options = {
      signcolumn = "no",
      number = false,
      relativenumber = false,
      cursorline = false,
      cursorcolumn = false,
      foldcolumn = "0",
      list = false,
    },
  },
  plugins = {
    options = {
      enabled = true,
      ruler = false,
      showcmd = false,
    },
    twilight = { enabled = true },
    gitsigns = { enabled = false },
    tmux = { enabled = false },
  },
}

vim.keymap.set('n', '<leader>z',
  function()
    require("zen-mode").toggle()
  end
)
