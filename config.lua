local module = {}

-- [ applications ] ------------------------------------------------------------
module.browser = 'firefox'
module.filemanager = 'exo-open --launch FileManager' or 'thunar'
module.gui_editor = 'subl'
module.terminal = 'xfce4-terminal'
module.lock_command = 'light-locker-command -l'

-- [ key bindings ] ------------------------------------------------------------
-- Default modkey.
module.modkey = 'Mod4'
module.altkey = 'Mod1'

-- [ appearance ] --------------------------------------------------------------
-- Select theme
module.theme = 'ayu'

-- Load colorschemes from xresources
module.xresources = false

-- colorscheme to use, choose from: light, mirage, dark
module.color_scheme = 'mirage'

-- path to your wallpaper
module.wallpaper = os.getenv("HOME") .. "/Documents/private/wallpaper/20190831_113833.jpg"

-- [ widgets ] -----------------------------------------------------------------
-- disable desktop widget
-- module.desktop_widgets = false

-- widgets to be added to wibar
module.wibar_widgets = {
	'net_down',
	'net_up',
	'vol',
	'mem',
	'cpu',
	'fs',
	'weather',
	'temp',
--	'bat',
	'datetime'
}

-- widgets to be added to the desktop pop up
module.arc_widgets = {'cpu', 'mem', 'fs'}

-- configure widgets
module.widgets_arg = {
    weather = {
        -- city and app id for the weather widget
        city_id = 2885679,
        app_id = '3e321f9414eaedbfab34983bda77a66e'
    },
    temp = {
        -- set resource for temperature widget
        thermal_zone = 'thermal_zone0'
    },
    net = {
        -- network interface
        net_interface = 'eno1'
    }
}

-- [ miscellaneous ] -----------------------------------------------------------
-- Using Tyrannical tag managment engine
module.tyrannical = false

return module
