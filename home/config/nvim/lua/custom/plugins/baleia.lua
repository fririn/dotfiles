-- baleia.nvim — render ANSI color escape codes (the `␛[32m` gibberish) as
-- actual highlighting. Handy for viewing colorized log files (Rust `tracing`,
-- Reth nodes, etc.) that were written straight to disk with color codes.
return {
	"m00qek/baleia.nvim",
	version = "*",
	cmd = { "BaleiaColorize", "BaleiaLogs" },
	keys = {
		{ "<leader>tc", "<cmd>BaleiaColorize<CR>", desc = "[T]oggle ANSI [C]olorize (baleia)" },
	},
	config = function()
		vim.g.baleia = require("baleia").setup({})

		-- Manually colorize the current buffer.
		vim.api.nvim_create_user_command("BaleiaColorize", function()
			vim.g.baleia.once(vim.api.nvim_get_current_buf())
		end, { desc = "Colorize ANSI escape codes in the current buffer" })

		-- Show baleia's own logs (for debugging the plugin).
		vim.api.nvim_create_user_command("BaleiaLogs", vim.g.baleia.logger.show, { desc = "Show baleia logs" })

		-- Auto-colorize log files on open.
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
			group = vim.api.nvim_create_augroup("baleia-auto-colorize", { clear = true }),
			pattern = { "*.log", "*.log.*" },
			callback = function(event)
				vim.g.baleia.once(event.buf)
			end,
		})
	end,
}
