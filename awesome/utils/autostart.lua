local awful = require("awful")

local autostart = {}

function autostart.run()
	-- List of applications to run on startup
	local apps = {
		"copyq",
		"picom",
	}

	for _, app in ipairs(apps) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s &)", app, app))
	end

	-- Shell commands to run on startup
	awful.spawn.with_shell([[
    device=$(xinput list --name-only | grep -i Touchpad);
    if [ -n "$device" ]; then
      xinput set-prop "$device" "libinput Tapping Enabled" 1
      xinput set-prop "$device" "libinput Natural Scrolling Enabled" 1
    fi
  ]])
end

return autostart
