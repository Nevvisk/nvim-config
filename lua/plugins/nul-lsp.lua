-- this is acutally a formatter not a lsp
return {
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
}
