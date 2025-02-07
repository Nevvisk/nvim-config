return {
	"nvim-treesitter/nvim-treesitter-context",
	config = function()
		require("treesitter-context").setup({
			enable = false, -- This disables the treesitter context
		})
	end,
}
