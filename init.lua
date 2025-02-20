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
require("config.masonconfig")
require("config.general")
require("vimopts")
