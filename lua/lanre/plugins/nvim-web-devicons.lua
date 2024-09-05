local icons_setup, icons = pcall(require, "nvim-web-devicons")
if not icons_setup then
	return
end

icons.setup({
	override = {
		zsh = {
			icon = "",
			color = "#428850",
			cterm_color = "65",
			name = "Zsh",
		},
		zig = {
			icon = "⚡",
			color = "#a1e2fe",
			cterm_color = "81",
			name = "Zig",
		},
	},
	default = true,
	strict = true,
	override_by_extension = {
		["zig"] = {
			icon = "⚡",
			color = "#a1e2fe",
			cterm_color = "81",
			name = "Zig",
		},
	},
})
