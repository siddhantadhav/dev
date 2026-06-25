return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	keys = {
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "Find Files",
		},

		{
			"<leader>fg",
			function()
				require("telescope.builtin").grep_string({
					search = vim.fn.input("Grep > "),
				})
			end,
			desc = "Live Grep (input)",
		},
	},
}
