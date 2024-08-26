local navigator_status, navigator = pcall(require, "navigator")
if not navigator_status then
	return
end

local has_lsp, lspconfig = pcall(require, "lspconfig")
if not has_lsp then
	return {
		setup = function()
			print("loading lsp config failed LSP may not working correctly")
		end,
	}
end

local util = lspconfig.util
local path_sep = require("navigator.util").path_sep()
local strip_dir_pat = path_sep .. "([^" .. path_sep .. "]+)$"
local strip_sep_pat = path_sep .. "$"
local dirname = function(pathname)
	if not pathname or #pathname == 0 then
		return
	end
	local result = pathname:gsub(strip_sep_pat, ""):gsub(strip_dir_pat, "")
	if #result == 0 then
		return "/"
	end
	return result
end

navigator.setup({
	default_mapping = false,
	treesitter_navigation = false,
	lsp = {
		enable = true,
		gopls = {
			settings = {
				gopls = {
					-- more settings: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
					-- flags = {allow_incremental_sync = true, debounce_text_changes = 500},
					-- not supported
					analyses = { unusedparams = true, unreachable = false },
					codelenses = {
						generate = true, -- show the `go generate` lens.
						gc_details = true, --  // Show a code lens toggling the display of gc's choices.
						test = true,
						tidy = true,
					},
					usePlaceholders = true,
					completeUnimported = true,
					staticcheck = true,
					matcher = "fuzzy",
					diagnosticsDelay = "500ms",
					experimentalWatchedFileDelay = "100ms",
					symbolMatcher = "fuzzy",
					gofumpt = false, -- true, -- turn on for new repos, gofmpt is good but also create code turmoils
					buildFlags = { "-tags", "integration" },
					-- buildFlags = {"-tags", "functional"}
				},
			},
			root_dir = function(fname)
				return util.root_pattern("go.mod", ".git")(fname) or dirname(fname) -- util.path.dirname(fname)
			end,
		},
	},
	-- transparency = 50,
	-- width = 0.75, -- max width ratio (number of cols for the floating window) / (window width)
	-- height = 0.3, -- max list window height, 0.3 by default
})
