local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local function get_tasklist(s)
	return awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		layout = {
			spacing = 10,
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					{
						{
							{
								id = "icon_role",
								widget = wibox.widget.imagebox,
							},
							left = 0,
							right = 5,
							top = 2,
							bottom = 2,
							widget = wibox.container.margin,
						},
						{
							id = "text_role",
							font = "JetBrainsMono Nerd Font 9",
							widget = wibox.widget.textbox,
						},
						layout = wibox.layout.fixed.horizontal,
					},
					left = 5,
					right = 5,
					top = 0,
					bottom = 2,
					widget = wibox.container.margin,
				},
				fg = "#FFFFFF",
				widget = wibox.container.background,
			},
			left = 0,
			right = 0,
			top = 1,
			bottom = 0,
			forced_width = 200,
			color = beautiful.bg_focus,
			widget = wibox.container.margin,
			create_callback = function(self, c, index, objects)
				local update = function()
					local is_focused = c.active or c == client.focus
					self:set_top(is_focused and 3 or 2)
				end

				c:connect_signal("property::active", update)
				c:connect_signal("property::focus", update)
				client.connect_signal("focus", function(_, cf)
					if cf == self._client then
						update()
					end
				end)

				self._client = c
				update()
			end,
		},
	})
end

return get_tasklist
