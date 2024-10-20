local setup, chafa = pcall(require, "chafa")
if not setup then
	return
end

chafa.setup({
	render = {
		min_padding = 5,
		show_label = true,
	},
	events = {
		update_on_nvim_resize = true,
	},
})
