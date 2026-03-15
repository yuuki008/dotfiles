local wezterm = require("wezterm")
local module = {}

-- =============================================================================
-- 定数
-- =============================================================================

-- Icons
local ICONS = {
  docker = wezterm.nerdfonts.md_docker,
  neovim = wezterm.nerdfonts.linux_neovim,
  ssh = wezterm.nerdfonts.md_lan,
  fallback = wezterm.nerdfonts.dev_terminal,
  zoom = wezterm.nerdfonts.md_magnify,
}

-- Icon colors (Catppuccin Mocha)
local ICON_COLORS = {
  docker = "#89b4fa",   -- blue
  neovim = "#a6e3a1",   -- green
  ssh = "#f38ba8",      -- red
}

-- Tab colors (Catppuccin Mocha)
local TAB_COLORS = {
  bar_bg = "#181825",          -- mantle（タブバー背景）
  fg_inactive = "#7f849c",     -- overlay1
  bg_inactive = "#181825",     -- mantle
  fg_active = "#cdd6f4",       -- text
  bg_active = "#313244",       -- surface0
  accent_active = "#89b4fa",   -- blue（アクティブタブのアクセント）
  accent_ssh = "#f38ba8",      -- red（SSH時のアクセント）
}

-- Powerline 区切り文字
local EDGE = {
  left = wezterm.nerdfonts.pl_left_hard_divider,
  right = wezterm.nerdfonts.pl_right_hard_divider,
}

-- =============================================================================
-- ヘルパー関数
-- =============================================================================

local function basename(path)
  return string.gsub(path or "", "(.*[/\\])(.*)", "%2")
end

local function is_ssh_process(process_name, cmdline, user_vars)
  if user_vars.ssh_host and user_vars.ssh_host ~= "" then
    return true, user_vars.ssh_host
  end
  if process_name:find("ssh") or (cmdline and cmdline:find("ssh")) then
    local host = cmdline and cmdline:match("ssh%s+([%w_%-%.]+)")
    return true, host
  end
  return false, nil
end

local function is_claude_process(process_name, pane_title)
  return process_name == "claude" or (pane_title and (pane_title:find("^✳") or pane_title:lower():find("claude")))
end

local function extract_project_name(cwd)
  if not cwd then
    return "-"
  end

  local home = os.getenv("HOME")
  if home and cwd:find("^" .. home) then
    cwd = cwd:gsub("^" .. home, "~")
  end

  -- GitHubプロジェクト名（ghq管理: ~/ghq/github.com/...）
  local _, project = cwd:match(".*/github%.com/([^/]+)/([^/]+)")
  if project then
    return project
  end

  -- 最後のディレクトリ名
  cwd = cwd:gsub("/$", "")
  return cwd:match("([^/]+)$") or cwd
end

local function get_icon_and_color(process_name, pane_title, is_ssh, is_active)
  if is_ssh then
    local color = is_active and "#ffffff" or ICON_COLORS.ssh
    return ICONS.ssh, color
  end

  if pane_title == "nvim" or process_name == "nvim" then
    return ICONS.neovim, ICON_COLORS.neovim
  end

  if process_name == "docker" or (pane_title and pane_title:find("docker")) then
    return ICONS.docker, ICON_COLORS.docker
  end

  return ICONS.fallback, is_active and TAB_COLORS.fg_active or TAB_COLORS.fg_inactive
end

local function has_zoomed_pane(panes)
  for _, pane_info in ipairs(panes) do
    if pane_info.is_zoomed then
      return true
    end
  end
  return false
end

-- =============================================================================
-- メイン処理
-- =============================================================================

function module.apply_to_config(config)
  local title_cache = {}
  local raw_cwd_cache = {}
  local ssh_host_cache = {}

  -- タイトルキャッシュの更新
  wezterm.on("update-status", function(_, pane)
    local pane_id = pane:pane_id()
    local user_vars = pane.user_vars or {}

    -- SSH中以外はタイトルキャッシュを更新
    if not (user_vars.ssh_host and user_vars.ssh_host ~= "") then
      local cwd_url = pane:get_current_working_dir()
      local cwd = cwd_url and cwd_url.file_path
      -- cwd が変わった場合のみ extract_project_name を実行
      if cwd ~= raw_cwd_cache[pane_id] then
        raw_cwd_cache[pane_id] = cwd
        title_cache[pane_id] = extract_project_name(cwd)
      end
    end
  end)

  -- タブタイトルのフォーマット
  wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
    local pane = tab.active_pane
    local pane_id = pane.pane_id
    local process_name = basename(pane.foreground_process_name)
    local pane_title = pane.title or ""
    local user_vars = pane.user_vars or {}

    -- SSH判定
    local is_ssh, ssh_host = is_ssh_process(process_name, pane.foreground_process_name or "", user_vars)
    if is_ssh and ssh_host then
      ssh_host_cache[pane_id] = ssh_host
    elseif not is_ssh then
      ssh_host_cache[pane_id] = nil
    end

    local is_active = tab.is_active

    -- 色の決定
    local bg = is_active and TAB_COLORS.bg_active or TAB_COLORS.bg_inactive
    local fg = is_active and TAB_COLORS.fg_active or TAB_COLORS.fg_inactive
    local accent = is_ssh and TAB_COLORS.accent_ssh or TAB_COLORS.accent_active
    local bar_bg = TAB_COLORS.bar_bg

    -- タイトルテキスト
    local title_text = is_ssh and (ssh_host_cache[pane_id] or "ssh") or (title_cache[pane_id] or "-")

    -- Claude Code のタイトル追加
    local claude_suffix = ""
    if is_claude_process(process_name, pane_title) and pane_title ~= "" then
      claude_suffix = " " .. pane_title
    end

    -- アイコン
    local icon, icon_color = get_icon_and_color(process_name, pane_title, is_ssh, is_active)

    -- ズームインジケーター
    local zoom_indicator = has_zoomed_pane(tab.panes) and (ICONS.zoom .. " ") or ""

    -- タイトルの整形
    local title = wezterm.truncate_right(title_text, max_width)
    local claude_title = wezterm.truncate_right(claude_suffix, max_width)

    if is_active then
      -- アクティブタブ: アクセントカラーの左エッジ + surface0 背景
      return {
        -- アクセントバー（左端の細い色帯）
        { Background = { Color = bar_bg } },
        { Text = " " },
        { Background = { Color = accent } },
        { Foreground = { Color = accent } },
        { Text = " " },
        -- 本体
        { Background = { Color = bg } },
        { Foreground = { Color = accent } },
        { Text = EDGE.left },
        { Background = { Color = bg } },
        { Foreground = { Color = icon_color } },
        { Text = " " .. icon .. " " },
        { Foreground = { Color = fg } },
        { Text = zoom_indicator },
        { Attribute = { Intensity = "Bold" } },
        { Text = title },
        { Attribute = { Intensity = "Normal" } },
        { Foreground = { Color = TAB_COLORS.accent_active } },
        { Text = claude_title },
        { Text = "  " },
        -- 右エッジ
        { Background = { Color = bar_bg } },
        { Foreground = { Color = bg } },
        { Text = EDGE.left },
      }
    else
      -- 非アクティブタブ: シンプル
      return {
        { Background = { Color = bar_bg } },
        { Text = "  " },
        { Foreground = { Color = icon_color } },
        { Text = icon .. " " },
        { Foreground = { Color = fg } },
        { Text = zoom_indicator },
        { Text = title },
        { Text = claude_title },
        { Text = "  " },
      }
    end
  end)
end

return module
