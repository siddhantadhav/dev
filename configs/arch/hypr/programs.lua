-- Programs you use, shared by autostart.lua and keybindings.lua.
-- Returns a table so other modules can `local programs = require("programs")`.
return {
  terminal    = "kitty",
  fileManager = "thunar",
  menu        = "wofi --show drun",
}
