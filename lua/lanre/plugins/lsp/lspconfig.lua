-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
	print("LSP Config not found, lsp setup not loaded")
	return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
	print("CMP Nvim LSP not found, cmp-nvim-lsp setup not loaded")
	return
end

-- import typescript plugin safely
local typescript_setup, typescript = pcall(require, "typescript")
if not typescript_setup then
	print("Typescript LSP not found, typescript setup not loaded")
	return
end

local navic_setup, navic = pcall(require, "nvim-navic")
if not navic_setup then
	print("Navic LSP not found, navic setup not loaded")
	return
end

vim.cmd([[
augroup LspBuf
  au!
  autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'bufls',
      \ 'cmd': {server_info->['bufls', 'serve']},
      \ 'whitelist': ['proto'],
      \ })
  autocmd FileType proto nmap <buffer> gd <plug>(lsp-definition)
augroup END
]])

local keymap = vim.keymap -- for conciseness

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
	-- keybind options
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- set keybinds
	keymap.set("n", "gf", "<cmd>Lspsaga finder<CR>", opts) -- show definition, references
	-- keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- got to declaration
	keymap.set("n", "gD", "<Cmd>Lspsaga goto_definition<CR>", opts) -- got to declaration
	keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
	keymap.set("n", "gT", "<Cmd>Lspsaga goto_type_definition<CR>", opts) -- got to type declaration
	keymap.set("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>", opts) -- see type definition and make edits in window
	keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- go to implementation
	keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
	keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
	keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
	keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
	keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
	keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
	keymap.set("n", "<leader>gh", "<cmd>Lspsaga hover_doc<CR>", opts) -- hover the current buffer
	keymap.set("n", "ttg", "<cmd>Lspsaga term_toggle<CR>", opts) -- hover the current buffer
	-- typescript specific keymaps (e.g. rename file and update imports)
	if client.name == "ts_ls" then
		keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- rename file and update imports
		keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- organize imports (not in youtube nvim video)
		keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- remove unused variables (not in youtube nvim video)
	end
	if client.name == "gopls" or client.name == "zls" then
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
	end

	if client.name == "bufls" then
		keymap.set("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	end
end

-- used to enable autocompletion (assign to every lsp server config)
local capabilities = cmp_nvim_lsp.default_capabilities()
local util = lspconfig.util

-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- configure html server
lspconfig["html"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure eslint
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.tsx", "*.ts", "*.jsx", "*.js" },
	command = "silent! EslintFixAll",
	group = vim.api.nvim_create_augroup("MyAutocmdsJavaScripFormatting", {}),
})

-- vim.cmd([[autocmd BufWritePre * lua vim.lsp.buf.format()]])

lspconfig["eslint"].setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		codeActionOnSave = {
			enable = true,
			mode = "all",
		},
	},
})

--configure json setup
lspconfig["jsonls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "json", "jsonc" },
	settings = {
		json = {
			-- Schemas https://www.schemastore.org
			schemas = {
				{
					fileMatch = { "package.json" },
					url = "https://json.schemastore.org/package.json",
				},
				{
					fileMatch = { "tsconfig*.json" },
					url = "https://json.schemastore.org/tsconfig.json",
				},
				{
					fileMatch = {
						".prettierrc",
						".prettierrc.json",
						"prettier.config.json",
					},
					url = "https://json.schemastore.org/prettierrc.json",
				},
				{
					fileMatch = { ".eslintrc", ".eslintrc.json" },
					url = "https://json.schemastore.org/eslintrc.json",
				},
				{
					fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
					url = "https://json.schemastore.org/babelrc.json",
				},
				{
					fileMatch = { "lerna.json" },
					url = "https://json.schemastore.org/lerna.json",
				},
				{
					fileMatch = { "now.json", "vercel.json" },
					url = "https://json.schemastore.org/now.json",
				},
				{
					fileMatch = {
						".stylelintrc",
						".stylelintrc.json",
						"stylelint.config.json",
					},
					url = "http://json.schemastore.org/stylelintrc.json",
				},
			},
		},
	},
})

-- configure liquid theme check
lspconfig["theme_check"].setup({
	root_dir = function()
		return vim.loop.cwd()
	end,
})

-- configure typescript server with plugin
typescript.setup({
	server = {
		capabilities = capabilities,
		on_attach = on_attach,
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
	end,
})

-- configure go server
lspconfig["gopls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	cmd = { "gopls", "serve" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			gofumpt = true,
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
})

-- configure php server
lspconfig["intelephense"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- lspconfig["solc"].setup({
-- 	capabilities = capabilities,
-- 	on_attach = on_attach,
-- })

-- configure solidit server
lspconfig["solidity"].setup({})

-- configure sql server
lspconfig["sqlls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "solidity" },
	root_dir = util.root_pattern("hardhat.config.*", ".git"),
})

-- configure python server
lspconfig["pyright"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure css server
lspconfig["cssls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure tailwindcss server
lspconfig["tailwindcss"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure emmet language server
lspconfig["emmet_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
})

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = { -- custom settings for lua
		Lua = {
			-- make the language server recognize "vim" global
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- make language server aware of runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})

-- configure zig server
lspconfig["zls"].setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig["dockerls"].setup({
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)

		-- Customize diagnostic filtering to ignore a specific warning
		vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
			result.diagnostics = vim.tbl_filter(function(diagnostic)
				print(diagnostic.message)
				-- Replace "Specific warning message" with the actual message you want to ignore
				return diagnostic.message ~= "Pin versions in apt get install" and diagnostic.code ~= "DL3008"
			end, result.diagnostics)

			vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
		end
	end,
})

lspconfig["rust_analyzer"].setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- EFM Language Server Configuration

local solhint = require("efmls-configs.linters.solhint")
local prettier_d = require("efmls-configs.formatters.prettier_d")
local rustfmt = require("efmls-configs.formatters.rustfmt")

local languages = {
	solidity = { solhint, prettier_d },
	rust = { rustfmt },
}

local efmls_config = {
	filetypes = vim.tbl_keys(languages),
	init_options = {
		codeAction = true,
		completion = true,
		documentFormatting = true,
		documentRangeFormatting = true,
		documentSymbol = true,
		hover = true,
	},
	settings = {
		rootMarkers = { "hardhat.config.js", ".git" },
		languages = languages,
	},
}

lspconfig.efm.setup(vim.tbl_extend("force", efmls_config, {
	on_attach = on_attach,
	capabilities = capabilities,
}))
