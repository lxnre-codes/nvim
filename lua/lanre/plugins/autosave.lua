-- import autosave plugin safely
local setup, autosave = pcall(require, "autosave")
if not setup then
	return
end

-- configure/enable autosave
autosave.setup({ debounce_delay = 5000 })
