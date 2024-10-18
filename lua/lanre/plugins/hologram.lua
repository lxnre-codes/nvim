local setup, hologram = pcall(require, "hologram")
if not setup then
	return
end

hologram.setup({
	auto_display = true,
})
