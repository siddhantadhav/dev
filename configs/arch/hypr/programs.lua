-- Programs you use, shared by autostart.lua and keybindings.lua.
-- Returns a table so other modules can `local programs = require("programs")`.
return {
  terminal     = "kitty",
  fileManager  = "thunar",
  -- also exported as $BROWSER / $BROWSER_CLASS (environment.lua): the rofi
  -- launcher's web searches open in it, as a tab in the running instance
  browser      = "firefox",
  browserClass = "firefox",   -- its window class, so the search tab gets focus
  -- one list: apps, clipboard, files, ssh, emoji; "=" for a calculator
  -- (configs/arch/rofi/scripts/launcher; ~/.local/bin isn't on Hyprland's PATH)
  menu         = os.getenv("HOME") .. "/.local/bin/rofi-launcher",
}
