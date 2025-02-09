return {
	"rcarriga/nvim-dap-ui",
	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		dapui.setup({
			layouts = {
				{
					elements = {
						"scopes",
						"breakpoints",
						"stacks",
					},
					size = 40, -- The size of the layout
					position = "left", -- The position of the layout
				},
				{
					elements = {
						"repl",
					},
					size = 10, -- The size of the layout
					position = "bottom", -- The position of the layout
				},
				-- Add more layouts as needed
			},
		})
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end
		vim.api.nvim_set_keymap("n", "<C-g>", ":TSContextToggle<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap(
			"n",
			"<F4>",
			"<Cmd>lua require'dap'.toggle_breakpoint()<CR>",
			{ noremap = true, silent = true }
		)
		vim.api.nvim_set_keymap("n", "<F12>", '<cmd>lua require("dapui").toggle()<CR>', { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<S-Up>", '<cmd>lua require("dap").up()<CR>', { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<S-Down>", '<cmd>lua require("dap").down()<CR>', { noremap = true, silent = true })
	end,
}
