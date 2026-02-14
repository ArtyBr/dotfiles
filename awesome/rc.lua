-- If LuaRocks is installed, make sure that packages installed through it are
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- @DOC_REQUIRE_SECTION@
-- Standard awesome library
Gears = require("gears")
Awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
Wibox = require("wibox")
-- Theme handling library
Beautiful = require("beautiful")
-- Notification library
Naughty = require("naughty")
Helpers = require("utils.helpers")
-- Battery module
local battery_widget = require("widgets.battery-1")
local clock_widget = require("widgets.clock")
local date_widget = require("widgets.date")
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
local net_widgets = require("widgets.wireless")
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local logout_popup = require("awesome-wm-widgets.logout-popup-widget.logout-popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
--require("layout")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
-- @DOC_ERROR_HANDLING@
Naughty.connect_signal("request::display_error", function(message, startup)
	Naughty.notification({
		urgency = "critical",
		title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
		message = message,
	})
end)
-- }}}

User = {}

User.config = {}
User.config.dark_mode = true

-- {{{ Variable definitions
-- @DOC_LOAD_THEME@
-- Themes define colours, icons, font and wallpapers.
Beautiful.init(Gears.filesystem.get_configuration_dir() .. "mytheme.lua")

-- @DOC_DEFAULT_APPLICATIONS@
-- This is used later as the default terminal and editor to run.
Terminal = "kitty"
Editor = os.getenv("EDITOR") or "nano"
Editor_cmd = Terminal .. " -e " .. Editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
Modkey = "Mod4"
-- }}}

-- {{{ Menu
-- @DOC_MENU@
-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, Awful.screen.focused())
		end,
	},
	{ "manual", Terminal .. " -e man awesome" },
	{ "edit config", Editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

-- Menubar configuration
mymainmenu = Awful.menu({
	items = {
		{ "awesome", myawesomemenu, Beautiful.awesome_icon },
		{ "open terminal", Terminal },
	},
})
mylauncher = Awful.widget.launcher({ image = Beautiful.awesome_icon, menu = mymainmenu })

tag.connect_signal("request::default_layouts", function()
	Awful.layout.append_default_layouts({
		-- awful.layout.suit.floating,
		Awful.layout.suit.tile,
		-- awful.layout.suit.tile.left,
		-- awful.layout.suit.tile.bottom,
		Awful.layout.suit.tile.top,
		Awful.layout.suit.fair,
		Awful.layout.suit.fair.horizontal,
		Awful.layout.suit.spiral,
		Awful.layout.suit.spiral.dwindle,
		Awful.layout.suit.max,
		Awful.layout.suit.max.fullscreen,
		Awful.layout.suit.magnifier,
		Awful.layout.suit.corner.nw,
	})
end)
-- }}}

-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = Awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = Wibox.widget.textclock()

-- @DOC_FOR_EACH_SCREEN@
screen.connect_signal("request::desktop_decoration", function(s)
	-- Each screen has its own tag table.
	Awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, Awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = Awful.widget.prompt()

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = Awful.widget.layoutbox({
		screen = s,
		buttons = {
			Awful.button({}, 1, function()
				Awful.layout.inc(1)
			end),
			Awful.button({}, 3, function()
				Awful.layout.inc(-1)
			end),
			Awful.button({}, 4, function()
				Awful.layout.inc(-1)
			end),
			Awful.button({}, 5, function()
				Awful.layout.inc(1)
			end),
		},
	})

	s.mytaglist = require("my_taglist")(s)

	-- @TASKLIST_BUTTON@
	-- Create a tasklist widget
	s.mytasklist = Awful.widget.tasklist({
		screen = s,
		filter = Awful.widget.tasklist.filter.currenttags,
		layout = {
			spacing = 10,
			layout = Wibox.layout.fixed.horizontal,
		},
		-- Notice that there is *NO* wibox.wibox prefix, it is a template,
		-- not a widget instance.
		widget_template = {
			{
				{
					{
						{

							{
								id = "icon_role",
								widget = Wibox.widget.imagebox,
							},
							left = 0,
							right = 5,
							top = 2,
							bottom = 2,
							widget = Wibox.container.margin,
						},
						{
							id = "text_role",
							font = "JetBrainsMono Nerd Font 9",
							widget = Wibox.widget.textbox,
						},
						layout = Wibox.layout.fixed.horizontal,
					},
					left = 5,
					right = 5,
					top = 0,
					bottom = 2,
					widget = Wibox.container.margin,
				},
				fg = "#FFFFFF",
				widget = Wibox.container.background,
			},
			left = 0,
			right = 0,
			top = 1,
			bottom = 0,
			forced_width = 200,
			color = Beautiful.bg_focus,
			widget = Wibox.container.margin,
			create_callback = function(self, c, index, objects)
				-- This function is called when a new task is created
				local update = function()
					local is_focused = c.active or c == client.focus
					self:set_top(is_focused and 3 or 2)
				end

				-- Update when focus changes
				c:connect_signal("property::active", update)
				c:connect_signal("property::focus", update)
				client.connect_signal("focus", function(_, c)
					if c == self._client then
						update()
					end
				end)

				self._client = c
				update()
			end,
		},
	})
	-- Widget separator
	local vert_sep = Wibox.widget.textbox(" | ")

	-- @DOC_WIBAR@
	-- Create the wibox
	s.mywibox = Awful.wibar({
		position = "top",
		screen = s,
		-- @DOC_SETUP_WIDGETS@
		widget = {
			layout = Wibox.layout.align.horizontal,

			{ -- Left widgets
				s.mylayoutbox,
				vert_sep,
				layout = Wibox.layout.fixed.horizontal,
				-- mylauncher,
				s.mytaglist,
				vert_sep,
				-- s.mypromptbox,
			},
			{
				layout = Wibox.layout.fixed.horizontal,
				s.mytasklist,
			}, -- Middle widget
			{ -- Right widgets
				vert_sep,
				layout = Wibox.layout.fixed.horizontal,
				-- mykeyboardlayout,
				-- wibox.widget.systray(),
				date_widget,
				clock_widget,
				vert_sep,
				battery_widget,
				vert_sep,
				volume_widget(),
				vert_sep,
				net_widgets({ interface = "wlp3s0", popup_signal = true }),
				vert_sep,
				cpu_widget(),
				vert_sep,
			},
		},
	})
end)

-- }}}

-- {{{ Mouse bindings
-- @DOC_ROOT_BUTTONS@
Awful.mouse.append_global_mousebindings({
	Awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	Awful.button({}, 4, Awful.tag.viewprev),
	Awful.button({}, 5, Awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings
-- @DOC_GLOBAL_KEYBINDINGS@

-- General Awesome keys
Awful.keyboard.append_global_keybindings({
	Awful.key({ Modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	Awful.key({ Modkey }, "w", function()
		mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),
	Awful.key({ Modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	Awful.key({ Modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
	Awful.key({ Modkey }, "x", function()
		Awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = Awful.screen.focused().mypromptbox.widget,
			exe_callback = Awful.util.eval,
			history_path = Awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" }),
	Awful.key({ Modkey }, "Return", function()
		Awful.spawn(Terminal)
	end, { description = "open a terminal", group = "launcher" }),
	Awful.key({ Modkey }, "b", function()
		Awful.util.spawn("firefox")
	end, { description = "launch firefox", group = "launcher" }),
	Awful.key({ Modkey }, "r", function()
		Awful.spawn.with_shell("~/.config/rofi/launchers/type-1/launcher.sh")
	end, { description = "run prompt", group = "launcher" }),
	Awful.key({ Modkey }, "v", function()
		Awful.spawn("copyq toggle")
	end, { description = "clipboard history", group = "launcher" }),
	-- Awful.key({ Modkey }, "p", function()
	-- 	menubar.show()
	-- end, { description = "show the menubar", group = "launcher" }),
	Awful.key({ Modkey, "Shift" }, "s", function()
		Awful.spawn("flameshot gui")
	end, { description = "selection screenshot", group = "screenshot" }),
	Awful.key({ Modkey, "Control" }, "s", function()
		Awful.spawn.with_shell("env XDG_CURRENT_DESKTOP=GNOME gnome-control-center")
	end, { description = "open control center", group = "settings" }),
	Awful.key({ Modkey }, "p", function()
		logout_popup.launch({
			phrases = {},
		})
	end, { description = "show logout screen", group = "settings" }),
	Awful.key({}, "XF86AudioRaiseVolume", function()
		volume_widget.inc()
	end),
	Awful.key({}, "XF86AudioLowerVolume", function()
		volume_widget.dec()
	end),
	Awful.key({}, "XF86AudioMute", function()
		volume_widget.toggle()
	end),
})

-- Tags related keybindings
Awful.keyboard.append_global_keybindings({
	Awful.key({ Modkey }, "Left", Awful.tag.viewprev, { description = "view previous", group = "tag" }),
	Awful.key({ Modkey }, "Right", Awful.tag.viewnext, { description = "view next", group = "tag" }),
	Awful.key({ Modkey }, "Escape", Awful.tag.history.restore, { description = "go back", group = "tag" }),
})

-- Focus related keybindings
Awful.keyboard.append_global_keybindings({
	Awful.key({ Modkey }, "j", function()
		Awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	Awful.key({ Modkey }, "k", function()
		Awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	Awful.key({ Modkey }, "Tab", function()
		Awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),
	Awful.key({ Modkey, "Control" }, "j", function()
		Awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	Awful.key({ Modkey, "Control" }, "k", function()
		Awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	Awful.key({ Modkey, "Control" }, "n", function()
		local c = Awful.client.restore()
		-- Focus restored client
		if c then
			c:activate({ raise = true, context = "key.unminimize" })
		end
	end, { description = "restore minimized", group = "client" }),
})

-- Layout related keybindings
Awful.keyboard.append_global_keybindings({
	Awful.key({ Modkey, "Shift" }, "j", function()
		Awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	Awful.key({ Modkey, "Shift" }, "k", function()
		Awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	Awful.key({ Modkey }, "u", Awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	Awful.key({ Modkey }, "l", function()
		Awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	Awful.key({ Modkey }, "h", function()
		Awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	Awful.key({ Modkey, "Shift" }, "h", function()
		Awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	Awful.key({ Modkey, "Shift" }, "l", function()
		Awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	Awful.key({ Modkey, "Control" }, "h", function()
		Awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	Awful.key({ Modkey, "Control" }, "l", function()
		Awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	Awful.key({ Modkey }, "space", function()
		Awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	Awful.key({ Modkey, "Shift" }, "space", function()
		Awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),
  -- Brightness

  Awful.key({ }, "XF86MonBrightnessDown", function ()
      Awful.util.spawn("brightnessctl set 5%-") end),
  Awful.key({ }, "XF86MonBrightnessUp", function ()
      Awful.util.spawn("brightnessctl set 5%+") end),
})

-- @DOC_NUMBER_KEYBINDINGS@

Awful.keyboard.append_global_keybindings({
	Awful.key({
		modifiers = { Modkey },
		keygroup = "numrow",
		description = "only view tag",
		group = "tag",
		on_press = function(index)
			local screen = Awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	}),
	Awful.key({
		modifiers = { Modkey, "Control" },
		keygroup = "numrow",
		description = "toggle tag",
		group = "tag",
		on_press = function(index)
			local screen = Awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				Awful.tag.viewtoggle(tag)
			end
		end,
	}),
	Awful.key({
		modifiers = { Modkey, "Shift" },
		keygroup = "numrow",
		description = "move focused client to tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	}),
	Awful.key({
		modifiers = { Modkey, "Control", "Shift" },
		keygroup = "numrow",
		description = "toggle focused client on tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
	}),
	Awful.key({
		modifiers = { Modkey },
		keygroup = "numpad",
		description = "select layout directly",
		group = "layout",
		on_press = function(index)
			local t = Awful.screen.focused().selected_tag
			if t then
				t.layout = t.layouts[index] or t.layout
			end
		end,
	}),
})

-- @DOC_CLIENT_BUTTONS@
client.connect_signal("request::default_mousebindings", function()
	Awful.mouse.append_client_mousebindings({
		Awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" })
		end),
		Awful.button({ Modkey }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		Awful.button({ Modkey }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)

-- @DOC_CLIENT_KEYBINDINGS@
client.connect_signal("request::default_keybindings", function()
	Awful.keyboard.append_client_keybindings({
		Awful.key({ Modkey }, "f", function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end, { description = "toggle fullscreen", group = "client" }),
		Awful.key({ Modkey, "Shift" }, "c", function(c)
			c:kill()
		end, { description = "close", group = "client" }),
		Awful.key(
			{ Modkey, "Control" },
			"space",
			Awful.client.floating.toggle,
			{ description = "toggle floating", group = "client" }
		),
		Awful.key({ Modkey, "Control" }, "Return", function(c)
			c:swap(Awful.client.getmaster())
		end, { description = "move to master", group = "client" }),
		Awful.key({ Modkey }, "o", function(c)
			c:move_to_screen()
		end, { description = "move to screen", group = "client" }),
		Awful.key({ Modkey }, "t", function(c)
			c.ontop = not c.ontop
		end, { description = "toggle keep on top", group = "client" }),
		Awful.key({ Modkey }, "n", function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end, { description = "minimize", group = "client" }),
		Awful.key({ Modkey }, "m", function(c)
			c.maximized = not c.maximized
			c:raise()
		end, { description = "(un)maximize", group = "client" }),
		Awful.key({ Modkey, "Control" }, "m", function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end, { description = "(un)maximize vertically", group = "client" }),
		Awful.key({ Modkey, "Shift" }, "m", function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end, { description = "(un)maximize horizontally", group = "client" }),
	})
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
-- @DOC_RULES@
ruled.client.connect_signal("request::rules", function()
	-- @DOC_GLOBAL_RULE@
	-- All clients will mjtch this rule.
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = Awful.client.focus.filter,
			raise = true,
			screen = Awful.screen.preferred,
			placement = Awful.placement.no_overlap + Awful.placement.no_offscreen,
		},
	})

	-- @DOC_FLOATING_RULE@
	-- Floating clients.
	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = { "copyq", "pinentry" },
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"Sxiv",
				"Tor Browser",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	})

	-- @DOC_DIALOG_RULE@
	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule({
		-- @DOC_CSD_TITLEBARS@
		id = "titlebars",
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = true },
	})

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- ruled.client.append_rule {
	--     rule       = { class = "Firefox"     },
	--     properties = { screen = 1, tag = "2" }
	-- }
end)
-- }}}

--{{{ Wallpaper
Awful.screen.connect_for_each_screen(function(s)
	Gears.wallpaper.maximized(Beautiful.wallpaper, s, { horizontal_fit_policy = "fit", vertical_fit_policy = "fit" })
end)
--}}}

-- }}}

-- Autostart
Awful.spawn.with_shell("copyq")
Awful.spawn.with_shell([[
  device=$(xinput list --name-only | grep -i Touchpad);
  if [ -n "$device" ]; then
    xinput set-prop "$device" "libinput Tapping Enabled" 1
    xinput set-prop "$device" "libinput Natural Scrolling Enabled" 1
  fi
]])
Awful.spawn.with_shell("picom")
