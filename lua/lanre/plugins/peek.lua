-- import autosave plugin safely
local setup, peek = pcall(require, "peek")
if not setup then
	return
end

vim.api.nvim_create_user_command("PeekOpen", peek.open, {})
vim.api.nvim_create_user_command("PeekClose", peek.close, {})

-- configure/enable peek
peek.setup({})
