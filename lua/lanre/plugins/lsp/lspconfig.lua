-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
	print("LSP Config not found, lsp setup not loaded")
	return
end

-- import typescript plugin safely
local typescript_setup, typescript = pcall(require, "typescript")
if not typescript_setup then
	print("Typescript LSP not found, typescript setup not loaded")
	return
end

-- local navic_setup, navic = pcall(require, "nvim-navic")
-- if not navic_setup then
-- 	print("Navic LSP not found, navic setup not loaded")
-- 	return
-- end

local keymaps_status, keymaps = pcall(require, "lanre.plugins.lsp.keymaps")
if not keymaps_status then
	print("keymaps not found" .. keymaps)
	return
end

local on_attach = keymaps.on_attach
local capabilities = keymaps.capabilities

-- vim.cmd([[
-- augroup LspBuf
--   au!
--   autocmd User lsp_setup call lsp#register_server({
--       \ 'name': 'bufls',
--       \ 'cmd': {server_info->['bufls', 'serve']},
--       \ 'whitelist': ['proto'],
--       \ })
--   autocmd FileType proto nmap <buffer> gd <plug>(lsp-definition)
-- augroup END
-- ]])

local util = lspconfig.util
local configs = require("lspconfig.configs")

-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- configure eslint
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.tsx", "*.ts", "*.jsx", "*.js" },
	command = "silent! EslintFixAll",
	group = vim.api.nvim_create_augroup("MyAutocmdsJavaScripFormatting", {}),
})

-- vim.cmd([[autocmd BufWritePre * lua vim.lsp.buf.format()]])

-- configure html server
lspconfig["html"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

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
		return vim.fn.getcwd()
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
		local params = vim.lsp.util.make_range_params()
		params.context = { only = { "source.organizeImports" } }
		-- buf_request_sync defaults to a 1000ms timeout. Depending on your
		-- machine and codebase, you may want longer. Add an additional
		-- argument after params if you find that you have to write the file
		-- twice for changes to be saved.
		-- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
		for cid, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
					vim.lsp.util.apply_workspace_edit(r.edit, enc)
				end
			end
		end
		vim.lsp.buf.format({ async = false })
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

-- configure solidity server
lspconfig["solidity"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "solidity" },
	root_dir = util.root_pattern("hardhat.config.*", ".git"),
})

-- configure sql server
lspconfig["sqlls"].setup({
	root_dir = function(fname)
		return util.root_pattern(".git", "go.mod", "config.yml")(fname) or vim.fn.getcwd()
	end,
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.sqls.setup({
	root_dir = function(fname)
		return util.root_pattern(".git", "go.mod", "config.yml")(fname) or vim.fn.getcwd()
	end,
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure python server
lspconfig["pyright"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		python = {
			venvPath = ".",
			venv = ".venv",
		},
	},
})

-- protobuf server

configs.protobuf_language_server = {
	default_config = {
		cmd = { "protobuf-language-server" },
		filetypes = { "proto", "cpp" },
		root_dir = util.root_pattern(".git"),
		single_file_support = true,
	},
}

lspconfig.protobuf_language_server.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.protols.setup({
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
