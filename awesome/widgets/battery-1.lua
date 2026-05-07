-- Required libraries
local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local percentage = wibox.widget.textbox()
percentage.font = beautiful.widget_text
local battery_icon = wibox.widget.textbox()
battery_icon.font = beautiful.widget_icon_battery or beautiful.widget_icon

local icons = {
	[0] = "", -- <= 10%
	[10] = "", -- <= 20%
	[20] = "", -- <= 30%
	[30] = "", -- <= 40%
	[40] = "", -- <= 50%
	[50] = "", -- <= 60%
	[60] = "", -- <= 70%
	[70] = "", -- <= 80%
	[80] = "", -- <= 90%
	[90] = "", -- <= 100%
	[100] = "",
}

local battery_widget = wibox.widget({
	{
		battery_icon,
		fg = beautiful.fg_battery,
		widget = wibox.container.background,
	},
	{
		percentage,
		fg = beautiful.fg_battery,
		widget = wibox.container.background,
	},
	spacing = dpi(4),
	layout = wibox.layout.fixed.horizontal,
})

local is_locked = false
local popup = awful.popup({
	ontop = true,
	visible = false,
	border_width = 1,
	border_color = beautiful.bg_focus,
	maximum_width = 400,
	offset = { y = 5 },
	widget = {}
})

local function dismiss_popup()
	is_locked = false
	popup.visible = false
end

client.connect_signal("button::press", dismiss_popup)
awful.mouse.append_global_mousebinding(awful.button({}, 1, dismiss_popup))

local tooltip_text = ""

local function rebuild_popup()
	popup:setup({
		{
			{
				text = tooltip_text,
				font = "JetBrains Nerd Font 11",
				widget = wibox.widget.textbox,
			},
			margins = 10,
			widget = wibox.container.margin,
		},
		bg = beautiful.bg_normal,
		widget = wibox.container.background,
	})
	if not popup.visible then
		popup.visible = true
		popup:move_next_to(mouse.current_widget_geometry)
	end
end

battery_widget:buttons(gears.table.join(
	awful.button({}, 1, function()
		if is_locked then
			dismiss_popup()
		else
			is_locked = true
			rebuild_popup()
		end
	end)
))

battery_widget:connect_signal("mouse::enter", function()
	if not is_locked then
		rebuild_popup()
	end
end)

battery_widget:connect_signal("mouse::leave", function()
	if not is_locked then
		dismiss_popup()
	end
end)

--- update_widget: Updates the battery widget with the current battery status and charge level.
-- This function parses the output from the 'acpi -i' command to extract battery status, charge level, and time remaining.
-- It iterates through each line of the command output, categorizing data into battery info and capacities.
-- The function updates the battery icon and tooltip text based on the battery's current status (charging, full, or discharging).
-- If available, the tooltip also includes the time remaining for charging or discharging.
-- The battery charge percentage is displayed in the battery_value widget.
-- @param stdout The string output from the 'acpi -i' command containing battery information.
local function update_widget(stdout)
	local battery_info = {}
	local capacities = {}
	local time_remaining = nil
	local wattage = 0

	for s in stdout:gmatch("[^\r\n]+") do
		local status, charge_str, time = string.match(s, ".+: ([%a ]-), (%d?%d?%d)%%,?%s*(.-)$")
		if status ~= nil then
			table.insert(battery_info, {
				status = status,
				charge = tonumber(charge_str),
				time = time,
			})
			if time and not time:match("remaining time: unknown") then
				time_remaining = time
			end
		else
			local cap_str = string.match(s, ".+:.+last full capacity (%d+)")
			if cap_str then
				table.insert(capacities, tonumber(cap_str))
			else
				-- Parse wattage if it's a raw number from cat /sys/class/power_supply/BAT*/power_now
				local w = tonumber(s)
				if w then
					wattage = wattage + w
				end
			end
		end
	end

	local capacity = 0
	for _, cap in ipairs(capacities) do
		capacity = capacity + cap
	end

	local charge = 0
	local status
	for i, batt in ipairs(battery_info) do
		if batt.charge >= charge then
			status = batt.status
		end

		charge = charge + batt.charge * (capacities[i] or 0)
	end
	charge = (capacity > 0) and (charge / capacity) or 0

	local display_text = math.floor(charge) .. "%"
	local charge_text = ""

	if status == "Charging" then
		battery_icon.text = " "
		charge_text = "Charging: " .. math.floor(charge) .. "%"
		if wattage > 0 then
			charge_text = charge_text .. "\nPower: " .. string.format("%.1fW", wattage / 1000000)
		end
		if time_remaining then
			charge_text = charge_text .. "\nTime: " .. time_remaining
		end
	elseif status == "Full" then
		battery_icon.text = ""
		charge_text = "Battery is full"
	elseif status == "Not charging" then
		battery_icon.text = icons[math.floor(charge / 10) * 10]
		charge_text = "Not charging (plugged in): " .. math.floor(charge) .. "%"
	else
		battery_icon.text = icons[math.floor(charge / 10) * 10]
		charge_text = "Battery: " .. math.floor(charge) .. "%"
		if time_remaining then
			charge_text = charge_text .. "\n" .. time_remaining
		else
			charge_text = charge_text .. "\nTime: Not available"
		end
	end

	percentage.text = display_text
	tooltip_text = charge_text
	if popup.visible then
		rebuild_popup()
	end

	collectgarbage("collect")
end

watch([[bash -c "acpi -i; cat /sys/class/power_supply/BAT*/power_now"]], 10, function(widget, stdout)
	update_widget(stdout)
end, battery_widget)

return battery_widget
