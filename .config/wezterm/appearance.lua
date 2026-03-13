local wezterm = require("wezterm")
local module = {}

-- =============================================================================
-- Catppuccin Mocha パレット
-- =============================================================================
module.palette = {
  base = "#1e1e2e",
  mantle = "#181825",
  crust = "#11111b",
  surface0 = "#313244",
  surface1 = "#45475a",
  surface2 = "#585b70",
  overlay0 = "#6c7086",
  overlay1 = "#7f849c",
  text = "#cdd6f4",
  subtext0 = "#a6adc8",
  subtext1 = "#bac2de",
  blue = "#89b4fa",
  green = "#a6e3a1",
  teal = "#94e2d5",
  red = "#f38ba8",
  yellow = "#f9e2af",
  mauve = "#cba6f7",
  peach = "#fab387",
  lavender = "#b4befe",
  rosewater = "#f5e0dc",
}

local p = module.palette

local appearance = {
  color_scheme = "Catppuccin Mocha",

  -- window
  window_decorations = "RESIZE",
  window_close_confirmation = "NeverPrompt",

  -- rendering
  front_end = "WebGpu",
  max_fps = 120,
  animation_fps = 120,

  -- font
  line_height = 1.1,

  -- Pane
  inactive_pane_hsb = {
    hue = 1.0,
    saturation = 0.85,
    brightness = 0.7,
  },

  -- Tab
  show_tabs_in_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  tab_bar_at_bottom = false,
  show_new_tab_button_in_tab_bar = false,
  tab_max_width = 30,
  use_fancy_tab_bar = true,
  window_frame = {
    inactive_titlebar_bg = p.mantle,
    active_titlebar_bg = p.mantle,
    font_size = 16.0,
    font = wezterm.font("HackGen Console NF"),
  },
  colors = {
    background = p.base,
    cursor_bg = p.blue,
    cursor_fg = p.crust,
    cursor_border = p.blue,
    selection_bg = p.surface2,
    selection_fg = p.text,
    tab_bar = {
      background = p.mantle,
      active_tab = {
        bg_color = p.base,
        fg_color = p.text,
      },
      inactive_tab = {
        bg_color = p.mantle,
        fg_color = p.overlay1,
      },
      inactive_tab_hover = {
        bg_color = p.surface0,
        fg_color = p.text,
      },
    },
  },
}

function module.apply_to_config(config)
  for k, v in pairs(appearance) do
    config[k] = v
  end
end

return module
