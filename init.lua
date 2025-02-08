---@diagnostic disable: undefined-global
--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
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

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
--- Neovim LSP configuration

require("lazy").setup({
	-- NOTE: First, some plugins that don't require any configuration

	-- Git related plugins
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",

	-- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				enable = false, -- This disables the treesitter context
			})
		end,
	},
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup()
		end,
	},
	-- NOTE: This is where your plugins related to LSP can be installed.
	--  The configuration is done below. Search for lspconfig to find it below.
	{
		-- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", tag = "legacy", opts = {} },

			-- Additional lua configuration, makes nvim stuff amazing!
			"folke/neodev.nvim",
		},
	},
	-- {
	-- 	"stevearc/conform.nvim",
	-- 	config = function()
	-- 		require("conform").setup({
	-- 			formatters_by_ft = {
	-- 				lua = { "stylua" },
	-- 				python = { "black" },
	-- 				javascript = { "prettier" },
	-- 				typescript = { "prettier" },
	-- 				html = { "prettier" },
	-- 				css = { "prettier" },
	-- 				go = { "gofmt" },
	-- 				java = {
	-- 					{
	-- 						command = "google-java-format",
	-- 						args = { "-i" },
	-- 						stdin = false, -- google-java-format modifies files directly
	-- 					},
	-- 				},
	-- 			},
	-- 			-- Optional: Format on save settings
	-- 			stop_after_first = true,
	-- 			format_on_save = {
	-- 				enabled = true, -- Enable format on save
	-- 				timeout_ms = 2000, -- Adjust timeout for larger files or slower formatters
	-- 			},
	-- 		})
	-- 		-- Key mapping to format on demand
	-- 		vim.keymap.set("n", "<leader>l", function()
	-- 			require("conform").format({ async = true }) -- Async formatting
	-- 		end, { silent = true, desc = "Format code with Conform" })
	-- 	end,
	-- },
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local null_ls = require("null-ls")

			-- Helper function to check if a command exists
			local function command_exists(command)
				local handle = io.popen("command -v " .. command .. " 2>/dev/null")
				if handle then
					local result = handle:read("*a")
					handle:close()
					return result and result:len() > 0
				end
				return false
			end

			-- Initialize sources table
			local sources = {}

			-- Add formatters if they exist
			if command_exists("google-java-format") then
				table.insert(
					sources,
					null_ls.builtins.formatting.google_java_format.with({
						filetypes = { "java" },
					})
				)
			end

			if command_exists("gofmt") then
				table.insert(
					sources,
					null_ls.builtins.formatting.gofmt.with({
						filetypes = { "go" },
					})
				)
			end

			if command_exists("prettier") then
				table.insert(
					sources,
					null_ls.builtins.formatting.prettier.with({
						filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "css", "html", "json" },
					})
				)
			end

			if command_exists("black") then
				table.insert(
					sources,
					null_ls.builtins.formatting.black.with({
						filetypes = { "python" },
					})
				)
			end

			-- Modified Lua formatter configuration
			if command_exists("stylua") then
				table.insert(
					sources,
					null_ls.builtins.formatting.stylua.with({
						filetypes = { "lua" },
						extra_args = {
							"--quote-style",
							"AutoPreferDouble",
							"--indent-type",
							"Spaces",
							"--indent-width",
							"2",
						},
					})
				)
			end

			-- Setup null-ls with on_attach
			null_ls.setup({
				sources = sources,
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						-- Enable formatting for the buffer
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ bufnr = bufnr })
							end,
						})
					end
				end,
			})

			-- Create format autogroup
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			-- Format keybinding
			vim.keymap.set("n", "<leader>l", function()
				vim.lsp.buf.format({
					async = true,
					filter = function(client)
						return client.name == "null-ls"
					end,
				})
			end, { silent = true, desc = "Format code with null-ls" })
		end,
	},

	{
		-- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",

			-- Adds LSP completion capabilities
			"hrsh7th/cmp-nvim-lsp",

			-- Adds a number of user-friendly snippets
			"rafamadriz/friendly-snippets",
		},
	},

	-- Useful plugin to show you pending keybinds.
	{               -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		config = function() -- This is the function that runs, AFTER loading
			require("which-key").setup()

			-- Document existing key chains
			require("which-key").add({
				{ "<leader>c", group = "[C]ode" },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			})
		end,
	},
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				vim.keymap.set(
					"n",
					"<leader>hp",
					require("gitsigns").preview_hunk,
					{ buffer = bufnr, desc = "Preview git hunk" }
				)

				-- don't override the built-in and fugitive keymaps
				local gs = package.loaded.gitsigns
				vim.keymap.set({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
				vim.keymap.set({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
			end,
		},
	},

	{
		-- Theme inspired by Atom
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},

	{
		-- Set lualine as statusline
		"nvim-lualine/lualine.nvim",
		-- See `:help lualine.txt`
		opts = {
			options = {
				icons_enabled = false,
				theme = "tokyonight",
				component_separators = "|",
				section_separators = "",
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { { "filename", path = 1 } }, -- This line sets the full path
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", path = 1 } }, -- Also sets full path for inactive windows
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
		},
	},

	-- {
	--   -- Add indentation guides even on blank lines
	--   'lukas-reineke/indent-blankline.nvim',
	--   -- Enable `lukas-reineke/indent-blankline.nvim`
	--   -- See `:help ibl`
	--   main = 'ibl',
	--   opts = {},
	-- },

	-- "gc" to comment visual regions/lines
	{ "numToStr/Comment.nvim", opts = {} },

	-- { 'github/copilot.vim' },

	-- Ctrlsf
	{
		"dyng/ctrlsf.vim",
		config = function()
			-- CtrlSF configuration translated to lua
			vim.g.ctrlsf_default_view_mode = "compact"
			vim.g.ctrlsf_default_root = "project"
			vim.g.ctrlsf_auto_close = {
				normal = 1,
				compact = 1,
			}
			vim.g.ctrlsf_auto_focus = {
				at = "start",
			}
		end,
	},

	-- Fuzzy Finder (files, lsp, etc)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Fuzzy Finder Algorithm which requires local dependencies to be built.
			-- Only load if `make` is available. Make sure you have the system
			-- requirements installed.
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				-- NOTE: If you are having trouble with this installation,
				--       refer to the README for telescope-fzf-native for more instructions.
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
	},

	{
		-- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
	},
	{
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
	},
	{
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
		end,
	},
	{ "mfussenegger/nvim-dap" },
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
		config = function(_, opts)
			local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
			require("dap-python").setup(path)
			require("dap").configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch Python file",
					program = "${file}", -- This variable dynamically refers to the currently open file in Neovim
				},
				{
					type = "python",
					request = "attach",
					connect = {
						port = 5681,
						host = "localhost",
					},
					name = "AR Insights",
					pathMappings = {
						{
							localRoot = "${workspaceFolder}", -- Your local project root
							remoteRoot = "/app", -- Corresponding remote path
						},
						-- Add additional mappings as needed
					},
				},
				{
					type = "python",
					request = "attach",
					connect = {
						port = 5678,
						host = "localhost",
					},
					name = "AR Insights Worker",
					pathMappings = {
						{
							localRoot = "${workspaceFolder}", -- Your local project root
							remoteRoot = "/app", -- Corresponding remote path
						},
						-- Add additional mappings as needed
					},
				},
				{
					type = "python",
					request = "attach",
					connect = {
						port = 5678,
						host = "localhost",
					},
					name = "API",
					pathMappings = {
						{
							localRoot = "${workspaceFolder}", -- Your local project root
							remoteRoot = "/usr/src/app", -- Corresponding remote path
						},
						-- Add additional mappings as needed
					},
				},
				{
					type = "python",
					request = "attach",
					connect = {
						port = 5679,
						host = "localhost",
					},
					name = "API Worker",
					pathMappings = {
						{
							localRoot = "${workspaceFolder}", -- Your local project root
							remoteRoot = "/usr/src/app", -- Corresponding remote path
						},
						-- Add additional mappings as needed
					},
				},
				{
					type = "python",
					request = "attach",
					connect = {
						port = 5678,
						host = "localhost",
					},
					name = "KCI Docker",
					pathMappings = {
						{
							localRoot = "${workspaceFolder}", -- Your local project root
							remoteRoot = ".", -- Corresponding remote path
						},
						-- Add additional mappings as needed
					},
				},
			}
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
	{
		"stevearc/conform.nvim",
		opts = {},
	},
	-- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
	--       These are some example plugins that I've included in the kickstart repository.
	--       Uncomment any of the lines below to enable them.
	-- require 'kickstart.plugins.autoformat',
	-- require 'kickstart.plugins.debug',

	-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
	--    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
	--    up-to-date with whatever is in the kickstart repo.
	--    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
	--
	--    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
	-- { import = 'custom.plugins' },
}, {})

-- surround settings
require("nvim-surround").setup({
	surrounds = {
		["<"] = { output = "<", embed = true, nospace = true },
		[">"] = { output = ">", embed = true, nospace = true },
	},
})
-- Autosave on switch to normal mode for rust
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*.rs",
	callback = function()
		-- Simulate typing :w and pressing Enter
		vim.api.nvim_feedkeys(":w\n", "n", false)
	end,
	desc = "Simulate typing :w and pressing Enter for Rust files",
})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = "unnamedplus"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 300
vim.o.timeoutlen = 500
-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
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
require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-u>"] = false,
				["<C-d>"] = false,
			},
		},
	},
})

-- Enable telescope fzf native, if installed
pcall(require("telescope").load_extension, "fzf")

-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
-- vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>gf", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })
vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume, { desc = "[S]earch [R]esume" })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
	require("nvim-treesitter.configs").setup({
		-- Add languages to be installed here that you want installed for treesitter
		ensure_installed = {
			"c",
			"cpp",
			"go",
			"lua",
			"python",
			"rust",
			"tsx",
			"javascript",
			"typescript",
			"vimdoc",
			"vim",
			"bash",
		},

		-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
		auto_install = false,

		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<c-space>",
				node_incremental = "<c-space>",
				scope_incremental = "<c-s>",
				node_decremental = "<M-space>",
			},
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			},
			swap = {
				enable = true,
				swap_next = {
					["<leader>a"] = "@parameter.inner",
				},
				swap_previous = {
					["<leader>A"] = "@parameter.inner",
				},
			},
		},
	})
end, 0)

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
	signs = true,      -- Show diagnostic signs in the sign column
	underline = true,  -- Underline problematic text
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
local on_attach = function(_, bufnr)
	-- NOTE: Remember that lua is a real programming language, and as such it is possible
	-- to define small helper and utility functions so you don't have to repeat yourself
	-- many times.
	--
	-- In this case, we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

	nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
	nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
	nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	-- Lesser used LSP functionality
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	nmap("<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require("mason").setup()
require("mason-lspconfig").setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
	-- clangd = {},
	-- gopls = {},
	-- pyright = {},
	-- rust_analyzer = {},
	-- tsserver = {},
	-- html = { filetypes = { 'html', 'twig', 'hbs'} },

	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}

-- Setup neovim lua configuration
require("neodev").setup({
	library = { plugins = { "nvim-dap-ui" }, types = true },
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
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

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
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
-- installing autopairs
-- use opts = {} for passing setup options
-- this is equivalent to setup({}) function

-- installing and configuring autoformatter

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
-- Custom Keymaps
-- vim.keymap.set("i", "jj", "<Esc>")

vim.api.nvim_set_keymap("n", "<leader>i", ":PyrightOrganizeImports <CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>ri",
	":w<CR>:!autoflake --remove-all-unused-imports --in-place % <CR><CR>",
	{ noremap = true, silent = true }
)

-- Center screen after jumping to mark
-- vim.o.scrolloff = 999

-- -- Copilot set accept key
-- vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', {expr=true, silent=true})
-- vim.g.copilot_no_tab_map = true

-- Toggle treesitter-context
vim.api.nvim_set_keymap("n", "<C-g>", ":TSContextToggle<CR>", { noremap = true, silent = true })

-- DAP keymaps
vim.api.nvim_set_keymap("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F4>", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F12>", '<cmd>lua require("dapui").toggle()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-Up>", '<cmd>lua require("dap").up()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-Down>", '<cmd>lua require("dap").down()<CR>', { noremap = true, silent = true })

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
