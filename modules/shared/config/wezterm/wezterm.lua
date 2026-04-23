HOME = os.getenv("HOME")

local config = wezterm.config_builder()

config.font_size = 15

config.set_environment_variables = {
  PATH = string.format("/run/current-system/sw/bin:%s/.nix-profile/bin:%s/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/sbin:/bin:/usr/sbin:/usr/bin", HOME, HOME)
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

return config
