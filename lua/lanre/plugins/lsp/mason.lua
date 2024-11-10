-- import mason plugin safely
local mason_status, mason = pcall(require, "mason")
if not mason_status then
	return
end

-- import mason-lspconfig plugin safely
local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status then
	return
end

-- import mason-null-ls plugin safely
local mason_null_ls_status, mason_null_ls = pcall(require, "mason-null-ls")
if not mason_null_ls_status then
	return
end

mason.setup()

-- bun add -g
-- sql-language-server -> sqlls
-- @tailwindcss/language-server -> tailwindcss
-- vscode-langservers-extracted -> cssls,eslint,html,jsonls
-- pyright -> pyright
-- emmet-ls -> emmet_ls
-- intelephense -> intelephense
-- solc -> solc
-- solidity-ls -> solidity
-- typescript -> ts_ls
-- typescript-language-server -> ts_ls
-- vscode-solidity-server -> solidity_ls
-- dockerfile-language-server-nodejs -> dockerls
mason_lspconfig.setup({
	-- list of servers for mason to install
	ensure_installed = {
		-- "solidity_ls",
		-- "ts_ls",
		-- "html",
		-- "cssls",
		-- "tailwindcss",
		"lua_ls",
		-- "emmet_ls",
		-- "jsonls",
		"gopls",
		"rust_analyzer",
		"zls",
	},
	-- auto-install configured servers (with lspconfig)
	automatic_installation = true, -- not the same as ensure_installed
})

mason_null_ls.setup({
	-- list of formatters & linters for mason to install
	ensure_installed = {
		"prettierd", -- ts/js formatter
		"stylua", -- lua formatter
		"eslint_d", -- ts/js linter
		"fixjson",
	},
	-- auto-install configured formatters & linters (with null-ls)
	automatic_installation = true,
})
