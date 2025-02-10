local M = {}
function M.setup()
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		callback = function(args)
			require("conform").format({ bufnr = args.buf })
		end,
	})
	vim.api.nvim_set_keymap("n", "<leader>i", ":PyrightOrganizeImports <CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap(
		"n",
		"<leader>ri",
		":w<CR>:!autoflake --remove-all-unused-imports --in-place % <CR><CR>",
		{ noremap = true, silent = true }
	)
	-- Custom background colour
	vim.cmd([[hi Normal guibg=#090B17]])
	vim.cmd([[hi NormalNC guibg=#090B17]])
	vim.cmd([[hi VertSplit guibg=#090B17]])
	vim.cmd([[hi StatusLine guibg=#090B17]])
	vim.cmd([[hi StatusLineNC guibg=#090B17]])
	vim.cmd([[hi TabLine guibg=#090B17]])
	vim.cmd([[hi TabLineFill guibg=#090B17]])
	vim.cmd([[hi TabLineSel guibg=#090B17]])
	vim.cmd([[hi SignColumn guibg=#090B17]])

	-- Re-open at last position
	vim.cmd([[ au BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif ]])
	vim.api.nvim_create_autocmd("InsertLeave", {
		pattern = "*.rs",
		callback = function()
			vim.api.nvim_feedkeys(":w\n", "n", false)
		end,
		desc = "Simulate typing :w and pressing Enter for Rust files",
	})
	vim.o.hlsearch = false
	vim.wo.number = true
	vim.o.mouse = "a"
	vim.o.breakindent = true
	vim.o.undofile = true
	vim.o.ignorecase = true
	vim.o.smartcase = true
	vim.wo.signcolumn = "yes"
	vim.o.updatetime = 300
	vim.o.timeoutlen = 500
	vim.o.completeopt = "menuone,noselect"
	vim.o.termguicolors = true
	vim.opt.clipboard = "unnamedplus"

	vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

	vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
	vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

	local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.highlight.on_yank()
		end,
		group = highlight_group,
		pattern = "*",
	})
	vim.keymap.set("n", "<leader>dj", vim.diagnostic.goto_next)
	vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
	vim.keymap.set("n", "<leader>dl", function()
		vim.diagnostic.setqflist()
	end, {})
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

	vim.diagnostic.config({
		virtual_text = {
			severity = vim.diagnostic.severity.ERROR, -- Show errors inline
			source = "if_many",
			prefix = "●",
			spacing = 2,
		},
		signs = true,        -- Show diagnostic signs in the sign column
		underline = true,    -- Underline problematic text
		update_in_insert = true, -- Update diagnostics while in insert mode
		severity_sort = true,
		float = {
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	})
end

return M
