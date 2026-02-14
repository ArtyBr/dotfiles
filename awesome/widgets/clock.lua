-- Required libraries
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. "mytheme.lua")
local dpi = beautiful.xresources.apply_dpi

local clock = wibox.widget.textclock("<span> %H:%M </span>")
clock.font = beautiful.widget_text
local clock_icon = wibox.widget.textbox()
clock_icon.font = beautiful.widget_icon
clock_icon.text = " 󱑌 "

local clock_widget = wibox.widget({
	{
		clock,
		fg = beautiful.fg_clock,
		widget = wibox.container.background,
	},
	spacing = dpi(8),
	layout = wibox.layout.fixed.horizontal,
})

return clock_widget
