-- カラースキームの設定（エラーハンドリング付き）
vim.cmd [[
try
  colorscheme nightfox
catch /^Vim\%((\a\+)\)\=:E185/
  " nightfoxが見つからない場合はデフォルトカラースキームを使用
  colorscheme default
  set background=dark
endtry
]]
