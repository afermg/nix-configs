local wezterm = require 'wezterm'
local mux = wezterm.mux

HOME = os.getenv("HOME")

local config = wezterm.config_builder()

config.font_size = 15

local USER = os.getenv("USER") or "unknown"
-- /run/wrappers/bin must precede /run/current-system/sw/bin so that bare `sudo`
-- resolves to the setuid wrapper instead of the (non-setuid) store binary,
-- which otherwise fails with: "sudo: ... must be owned by uid 0 and have the
-- setuid bit set".
config.set_environment_variables = {
  PATH = string.format("/run/wrappers/bin:/etc/profiles/per-user/%s/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin", USER)
}

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.default_prog = { 'fish' }

config.window_decorations = "RESIZE"

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- macOS: let left alt send raw keys (for Emacs meta), right alt for diacritics
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

return config
