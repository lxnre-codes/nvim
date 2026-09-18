local setup, nvimtree = pcall(require, "nvim-tree")

if not setup then
	return
end

-- recommended settings from nvim-tree documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- change color for arrows in tree to light blue
vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

vim.cmd("autocmd Colorscheme * highlight NvimTreeNormal guibg=none guifg=#9da5b3")

vim.cmd([[hi NvimTreeNormal guibg=NONE ctermbg=NONE]])

vim.cmd([[hi Normal guibg=NONE ctermbg=NONE]])

local function on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- Load default mappings first or custom ones
	api.config.mappings.default_on_attach(bufnr)

	-- Override 'd' to use trash (api.fs.trash) instead of permanent removal (api.fs.remove)
	vim.keymap.set({ "n", "x" }, "d", api.fs.trash, opts("Trash"))

	-- Optionally, if you still want a permanent delete key, bind it to another key like 'D'
	vim.keymap.set({ "n", "x" }, "D", api.fs.remove, opts("Delete"))
end

nvimtree.setup({
	on_attach = on_attach,
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	-- change folder arrow icons
	renderer = {
		icons = {
			glyphs = {
				folder = {
					arrow_closed = "", -- arrow when folder is closed
					arrow_open = "", -- arrow when folder is open
				},
			},
		},
	},
	-- disable window_picker for
	-- explorer to work well with
	-- window splits
	actions = {
		open_file = {
			window_picker = {
				enable = false,
			},
		},
	},
	filters = { custom = { "^.git$" } },
	view = { number = true, relativenumber = false },
})
