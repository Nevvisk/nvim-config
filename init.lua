vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.wo.relativenumber = true

vim.cmd("command! TypeThis lua require'typer'.typeItOut()")

-- Scroll down/up by half a page and center the cursor
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "half page down" })

-- Quickly insert an empty new line without entering insert mode
vim.keymap.set("n", "<leader>o", "o<Esc>", { desc = "half page down" })
vim.keymap.set("n", "<leader>O", "O<Esc>", { desc = "half page down" })
-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
require("lazy").setup("plugins", {
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	"tpope/vim-sleuth",
	{ "numToStr/Comment.nvim", opts = {} },
}, {})

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

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
-- Diagnostic keymaps
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
	signs = true,          -- Show diagnostic signs in the sign column
	underline = true,      -- Underline problematic text
	update_in_insert = true, -- Update diagnostics while in insert mode
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local keymaps = require("config.keymaps")
keymaps.setup()

local on_attach = function(client, bufnr)
	keymaps.lsp_keymaps(client, bufnr)
end
-- NOTE: Remember that lua is a real programming language, and as such it is possible
-- to define small helper and utility functions so you don't have to repeat yourself
-- many times.
--
-- In this case, we create a function that lets us more easily define mappings specific
-- for LSP related items. It sets the mode, buffer and description for us each time.
require("mason").setup()
require("mason-lspconfig").setup()
local servers = {
	clangd = {},
	gopls = {},
	pyright = {},
	ruff = {},
	rust_analyzer = {},
	ts_ls = {},
	html = { filetypes = { "html", "twig", "hbs" } },
	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}
require("neodev").setup({
	library = { plugins = { "nvim-dap-ui" }, types = true },
})
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
})
mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
		})
	end,
})
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete({}),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp", keyword_length = 2 },
		{ name = "luasnip" },
	},
})
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
