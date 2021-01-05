--------------------------------------------------------------------------------
-- @File:   rc.lua
-- @Author: Marcel Arpogaus
-- @Date:   2019-12-03 15:34:44
--
-- @Last Modified by:   Daniel
-- @Last Modified at: 2020-10-04 19:54:17
-- [ description ] -------------------------------------------------------------
-- ...
-- [ license ] -----------------------------------------------------------------
-- MIT License
-- Copyright (c) 2020 Marcel Arpogaus
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--------------------------------------------------------------------------------
-- [ required modules ] --------------------------------------------------------
-- grab environment
local root = root

-- Standard awesome library
local awful = require('awful')

-- Theme handling library
local beautiful = require('beautiful')
local gears = require('gears')

-- Mac OSX like 'Expose' view of all clients.
local revelation = require('revelation')

-- helper functions
local helpers = require('rc.helper_functions')

-- configuration
local config = helpers.load_config()

-- ensure that there's always a client that has focus
require('awful.autofocus')

-- error handling
require('rc.error_handling')

-- connect signals
require('rc.signals')

-- [ theme ] -------------------------------------------------------------------
beautiful.init(
    string.format(
        '%s/.config/awesome/themes/%s/theme.lua', os.getenv('HOME'),
        config.theme
    )
)
beautiful.icon_theme = 'Papirus'

-- [ autorun programs ] --------------------------------------------------------
-- awful.spawn.with_shell('~/.config/awesome/autorun.sh')
awful.spawn('xrandr --dpi 144 --fb 5640x2880 --output DP-0 --mode 3840x2160 --pos 1800x240  --output DVI-D-0 --mode 1920x1200 --scale 1.5x1.5 --rotate left')

local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end
-- run_once({ "urxvtd", "unclutter -root" , "/usr/bin/nextcloud --background", "nm-applet"}) -- entries must be separated by commas
-- run_once({ "xfsettingsd", "light-locker", "unclutter -root" , "/usr/bin/nextcloud --background", "nm-applet"}) -- entries must be separated by commas
run_once({ "light-locker", "unclutter -root" , "/usr/bin/nextcloud --background", "nm-applet"}) -- entries must be separated by commas

awful.spawn('ulauncher  --no-window-shadow')


-- Initialize revelation
revelation.init()

-- [ tags ] --------------------------------------------------------------------
require('rc.tags')
--------------------------------------------------------------------------------

-- [ menu ] --------------------------------------------------------------------
local menu = require('rc.menu')
-- add exit menu to wibar
awful.util.myexitmenu = menu.exitmenu
--------------------------------------------------------------------------------

-- [ mouse bindings ] ----------------------------------------------------------
local buttons = require('rc.mouse_bindings')
awful.util.taglist_buttons = buttons.taglist_buttons
awful.util.tasklist_buttons = buttons.tasklist_buttons
root.buttons(buttons.root)
--------------------------------------------------------------------------------

-- [ key bindings ] ------------------------------------------------------------
local keys = require('rc.key_bindings')
root.keys(keys.global_keys)
--------------------------------------------------------------------------------

-- [ setup wibar and desktop widgets ] -----------------------------------------
awful.screen.set_auto_dpi_enabled(true)
awful.screen.connect_for_each_screen(function(s)
	beautiful.at_screen_connect(s)
	if (s.geometry.height > s.geometry.width) then
		gears.debug.print_warning("test screen init vertical")
		for k, v in pairs(s.tags) do
			gears.debug.print_warning(k)
			gears.debug.print_warning(v)
			v.layout = awful.layout.suit.tile.bottom
		end
	end
	-- gears.debug.print_warning("test screen")
	-- 	gears.debug.print_warning("vertical screen")

end)
--------------------------------------------------------------------------------

-- [ rules ] -------------------------------------------------------------------
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = require('rc.rules').rules
--------------------------------------------------------------------------------
