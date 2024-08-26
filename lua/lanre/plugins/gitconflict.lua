-- import gitsigns plugin safely
local setup, gitconflict = pcall(require, "git-conflict")
if not setup then
	return
end

-- configure/enable gitsigns
gitconflict.setup()
