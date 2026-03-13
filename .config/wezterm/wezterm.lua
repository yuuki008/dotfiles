local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ==================================================
-- フォント
-- ==================================================
config.font = wezterm.font("UDEV Gothic 35NFLG")
config.font_size = 14.0

-- ==================================================
-- カラースキーム
-- ==================================================
config.color_scheme = "Tokyo Night"

-- ==================================================
-- ウィンドウ
-- ==================================================
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}
config.initial_cols = 220
config.initial_rows = 50

-- ==================================================
-- タブバー
-- ==================================================
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- ==================================================
-- キーバインド（tmux C-t プレフィックスと整合）
-- ==================================================
config.keys = {
  -- Cmd+T で新しいタブ
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  -- Cmd+W でタブを閉じる
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
  -- Cmd+数字でタブ切り替え
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
}

-- ==================================================
-- その他
-- ==================================================
config.scrollback_lines = 10000
config.enable_scroll_bar = false

return config
