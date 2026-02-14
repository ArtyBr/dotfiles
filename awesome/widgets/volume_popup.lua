local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local make_popup = require("widgets.popup")

local volume_widget = wibox.widget({
	{
		id = "text",
		text = "Volume",
		widget = wibox.widget.textbox,
	},
	layout = wibox.layout.fixed.horizontal,
})

local volume_widget_content = wibox.widget({
	{
		id = "other_text",
		text = "Popup content",
		widget = wibox.widget.textbox,
	},
	layout = wibox.layout.fixed.horizontal,
})

local volume_popup = make_popup("Volume", volume_widget_content, volume_widget)

volume_widget:buttons(gears.table.join(awful.button({}, 1, function()
	if volume_popup then
		volume_popup.visible = not volume_popup.visible
	end
end)))

return volume_widget
