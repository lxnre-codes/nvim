require("forgit").setup({
	debug = false, -- enable debug logging default path is ~/.cache/nvim/forgit.log
	diff_pager = "delta", -- you can use `diff`, `diff-so-fancy`
	diff_cmd = "", -- you can use `DiffviewOpen`, `Gvdiffsplit` or `!git diff`, auto if not set
	fugitive = true, -- git fugitive installed?
	abbreviate = false, -- abvreviate some of the commands e.g. gps -> git push
	git_alias = true, -- git command extensions see: Git command alias
	show_result = "quickfix", -- show cmd result in quickfix or notify

	shell_mode = true, -- set to true if you using zsh/bash and can not run forgit commands
	height_ratio = 0.6, -- height ratio of floating window when split horizontally
	width_ratio = 0.6, -- width ratio of floating window when split vertically
	cmds_list = {}, -- additional commands to show in Forgit command list
	--  e.g. cmd_list = {text = 'Gs get_hunks', cmd = 'Gitsigns get_hunks'}
})
