-- カラースキームの設定（エラーハンドリング付き）
local ok, _ = pcall(vim.cmd, "colorscheme solarized-osaka")
if not ok then
  vim.cmd("colorscheme default")
  vim.o.background = "dark"
end
