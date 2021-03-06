--------------------------------------------------------------------------------
-- @File:   signals.lua
-- @Author: marcel
-- @Date:   2019-12-03 13:53:32
--
-- @Last Modified by:   Daniel
-- @Last Modified at: 2020-10-04 19:54:06
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
local awesome = awesome
local client = client
local tag = tag

-- Standard awesome library
local gears = require('gears')
local awful = require('awful')

-- Widget and layout library
local wibox = require('wibox')

-- Theme handling library
local beautiful = require('beautiful')

-- [ sequential ] -------------------------------------------------------------
-- Signal function to execute when a new client appears.
client.connect_signal(
    'manage', function(c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end

        if awesome.startup and not c.size_hints.user_position and
            not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end

        if c.floating or c.first_tag.layout.name == "floating" then
            c.titlebars_enabled = true
            -- awful.titlebar.show(c)
        else
            -- c.titlebars_enabled = false
            awful.titlebar.hide(c)
        end
    end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
    'request::titlebars', function(c)
        -- buttons for the titlebar
        local buttons = gears.table.join(
            awful.button(
                {}, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end
            ), awful.button(
                {}, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end
            )
        )

        awful.titlebar(c):setup{
            { -- Left
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    align = 'center',
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout = wibox.layout.flex.horizontal
            },
            { -- Right
                awful.titlebar.widget.floatingbutton(c),
                awful.titlebar.widget.stickybutton(c),
                awful.titlebar.widget.ontopbutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.minimizebutton(c),
                awful.titlebar.widget.closebutton(c),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
    end
)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal(
    'mouse::enter', function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and
            awful.client.focus.filter(c) then client.focus = c end

        local focused_screen = awful.screen.focused()
        if not awesome.startup and focused_screen.systray then
            focused_screen.systray:set_screen(focused_screen)
        end
    end
)

client.connect_signal(
    'focus', function(c) 
        c.border_color = beautiful.border_focus 
        c.opacity=1.0
    end
)
client.connect_signal(
    'unfocus', function(c) 
        c.border_color = beautiful.border_normal
        c.opacity=0.95
    end
)
client.connect_signal(
    'property::screen', function()
        local focused_screen = awful.screen.focused()
        if not awesome.startup and focused_screen.systray then
            focused_screen.systray:set_screen(focused_screen)
        end
    end
)

-- Disable borders on lone windows
-- Handle border sizes of clients.
for s = 1, screen.count() do
    screen[s]:connect_signal(
        'arrange', function()
            local clients = awful.client.visible(s)
            local layout = awful.layout.getname(awful.layout.get(s))

            for _, c in pairs(clients) do
                -- No borders with only one humanly visible client
                if c.maximized then
                    -- NOTE: also handled in focus, but that does not cover maximizing from a
                    -- tiled state (when the client had focus).
                    c.border_width = 0
                elseif c.floating or layout == 'floating' then
                    c.border_width = beautiful.border_width
                elseif layout == 'max' or layout == 'fullscreen' then
                    c.border_width = 0
                else
                    local tiled = awful.client.tiled(c.screen)
                    if #tiled == 1 then -- and c == tiled[1] then
                        tiled[1].border_width = 0
                        -- if layout ~= "max" and layout ~= "fullscreen" then
                        -- XXX: SLOW!
                        -- awful.client.moveresize(0, 0, 2, 0, tiled[1])
                        -- end
                    else
                        c.border_width = beautiful.border_width
                    end
                end
            end
        end
    )
end

client.connect_signal(
    'property::floating', function(c)
        -- gears.debug.print_warning("property::floating") -- logs are in ~/.xsession-errors
        -- gears.debug.print_warning(c.floating)


        -- Hide the titlebar if we are not floating
        local l = awful.layout.get(awful.screen.focused())
        -- gears.debug.print_warning(l.name)
        if c.requests_no_titlebar then
            awful.titlebar.hide(c)
        elseif c.floating or l.name == 'floating' then
            awful.titlebar.show(c)
        -- elseif l.name == 'floating' then
        --     awful.titlebar.show(c)
        else
            awful.titlebar.hide(c)
        end
    end
)

client.disconnect_signal("request::geometry", awful.ewmh.client_geometry_requests)
client.connect_signal("request::geometry", function(c, context, hints)
    if c.class == "Ulauncher" then
        -- gears.debug.print_warning("reques::geometry")
        -- gears.debug.print_warning(context)
        -- gears.debug.print_warning(hints)
        -- for k, v in pairs(hints) do
        --     gears.debug.print_warning(k, v)
        -- end
        awful.ewmh.client_geometry_requests(c, context, hints)
    end
end)


tag.connect_signal("property::layout", function(t)
    local clients = t:clients()
    -- gears.debug.print_warning("property::layout")
    for k,c in pairs(clients) do
        if c.floating or c.first_tag.layout.name == "floating" then
            awful.titlebar.show(c)
        else
            awful.titlebar.hide(c)
        end
    end
end)