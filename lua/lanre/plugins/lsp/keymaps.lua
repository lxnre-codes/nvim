local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
	print("CMP Nvim LSP not found, cmp-nvim-lsp setup not loaded")
	return
end

local M = {}

local keymap = vim.keymap
-- TODO comment keymaps
local todo_comments = require("todo-comments")

keymap.set("n", "]t", function()
	todo_comments.jump_next()
end, { desc = "Next todo comment" })
keymap.set("n", "[t", function()
	todo_comments.jump_prev()
end, { desc = "Previous todo comment" })
keymap.set("n", "<leader>tdf", "<cmd>TodoQuickFix<CR>", { desc = "Show all TODOs in quickfix list" })
keymap.set("n", "<leader>tdl", "<cmd>TodoLocList<CR>", { desc = "Show all TODOs in location list" })
keymap.set("n", "<leader>tdt", "<cmd>TodoTelescope<CR>", { desc = "Show all TODOs in telescope" })

M.on_attach = function(client, bufnr)
	-- keybind options
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- set keybinds
	keymap.set("n", "gf", "<cmd>Lspsaga finder<CR>", opts)
	keymap.set("n", "gD", "<Cmd>Lspsaga goto_definition<CR>", opts)
	keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
	keymap.set("n", "gT", "<Cmd>Lspsaga goto_type_definition<CR>", opts)
	keymap.set("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>", opts)
	keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
	keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
	keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
	keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
	keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
	keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
	keymap.set("n", "<leader>gh", "<cmd>Lspsaga hover_doc<CR>", opts)
	keymap.set("n", "ttg", "<cmd>Lspsaga term_toggle<CR>", opts)

	-- typescript specific keymaps
	if client.name == "ts_ls" then
		keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>")
		keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>")
		keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>")
	end

	if client.name == "gopls" or client.name == "zls" then
		vim.api.nvim_buf_set_var(bufnr, "&omnifunc", "v:lua.vim.lsp.omnifunc")
	end

	if client.name == "bufls" then
		keymap.set("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	end
end

-- Get capabilities
M.capabilities = cmp_nvim_lsp.default_capabilities()

return M
