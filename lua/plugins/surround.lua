return {
	"kylechui/nvim-surround",
	config = function()
		require("nvim-surround").setup({
			surrounds = {
				["<"] = { output = "<", embed = true, nospace = true },
				[">"] = { output = ">", embed = true, nospace = true },
			},
		})
	end,
}
