return {
	"kyazdani42/nvim-tree.lua",
	config = function()
		vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>")
		require("nvim-tree").setup({
			reload_on_bufenter = true,
			update_focused_file = {
				enable = true,
				update_root = false,
				ignore_list = {},
			},
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
		})
	end,
}
