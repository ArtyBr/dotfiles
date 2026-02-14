local wibox = require("wibox")
local awful = require("awful")

local function make_popup(title, content, parent)
	local popup_widget = awful.popup({
		widget = {
			{
				{
					text = title,
					widget = wibox.widget.textbox,
				},
				content,
				layout = wibox.layout.fixed.vertical,
			},
			margins = 10,
			widget = wibox.container.margin,
		},
		placement = function(c, args)
			awful.placement.top(c)
		end,
		ontop = true,
		visible = false,
		parent = parent,
	})
	return popup_widget
end

return make_popup
