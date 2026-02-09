local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
config.font_size = 14.0

-- Color scheme
local function scheme_for_appearance(apperance)
	if apperance:find("Dark") then
		return "Catppuccin Mocha"
	else
		return "Catppuccin Latte"
	end
end

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

-- Window
config.window_padding = {
	left = 2,
	right = 2,
	top = 0,
	bottom = 0,
}

-- Tab bar
config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"

-- Hyperlink rules (use defaults as base)
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Make username/project paths clickable as GitHub links
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
	format = "https://www.github.com/$1/$3",
})

-- URL opening with keyboard hint mode
config.keys = {
	{
		key = "u",
		mods = "CTRL|SHIFT",
		action = wezterm.action.QuickSelectArgs({
			patterns = { "https?://\\S+" },
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.open_with(url)
			end),
		}),
	},
	{
		key = "raw:50",
		action = wezterm.action.SendString("#"),
	},
}

-- Copy mode with Colemak navigation (mnei instead of hjkl)
local act = wezterm.action
config.key_tables = {
	copy_mode = {
		-- Navigation: Colemak mnei
		{ key = "m", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "n", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "e", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "i", mods = "NONE", action = act.CopyMode("MoveRight") },

		-- Fast navigation: Shift + mnei moves 5 at a time
		{
			key = "M",
			mods = "SHIFT",
			action = act.Multiple({
				act.CopyMode("MoveLeft"),
				act.CopyMode("MoveLeft"),
				act.CopyMode("MoveLeft"),
				act.CopyMode("MoveLeft"),
				act.CopyMode("MoveLeft"),
			}),
		},
		{
			key = "N",
			mods = "SHIFT",
			action = act.Multiple({
				act.CopyMode("MoveDown"),
				act.CopyMode("MoveDown"),
				act.CopyMode("MoveDown"),
				act.CopyMode("MoveDown"),
				act.CopyMode("MoveDown"),
			}),
		},
		{
			key = "E",
			mods = "SHIFT",
			action = act.Multiple({
				act.CopyMode("MoveUp"),
				act.CopyMode("MoveUp"),
				act.CopyMode("MoveUp"),
				act.CopyMode("MoveUp"),
				act.CopyMode("MoveUp"),
			}),
		},
		{
			key = "I",
			mods = "SHIFT",
			action = act.Multiple({
				act.CopyMode("MoveRight"),
				act.CopyMode("MoveRight"),
				act.CopyMode("MoveRight"),
				act.CopyMode("MoveRight"),
				act.CopyMode("MoveRight"),
			}),
		},

		-- Arrow keys still work
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },

		-- Word movement
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "Tab", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "Tab", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
		{ key = "RightArrow", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
		{ key = "LeftArrow", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },

		-- Line movement
		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "Home", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "End", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },

		-- Page/viewport movement
		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
		{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },

		-- Scrollback
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },

		-- Viewport positions
		{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
		{ key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
		{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
		{ key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },

		-- Selection modes
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
		{ key = "Space", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },

		-- Selection other end
		{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
		{ key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },

		-- Copy and exit
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({
				{ CopyTo = "ClipboardAndPrimarySelection" },
				{ CopyMode = "Close" },
			}),
		},

		-- Exit copy mode
		{
			key = "Escape",
			mods = "NONE",
			action = act.CopyMode("Close"),
		},
		{
			key = "q",
			mods = "NONE",
			action = act.CopyMode("Close"),
		},
		{
			key = "c",
			mods = "CTRL",
			action = act.CopyMode("Close"),
		},
		{
			key = "g",
			mods = "CTRL",
			action = act.CopyMode("Close"),
		},

		-- Jump/find
		{ key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
		{ key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
		{ key = "F", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
		{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
		{ key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
		{ key = "T", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
		{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
		{ key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
	},
}

return config
