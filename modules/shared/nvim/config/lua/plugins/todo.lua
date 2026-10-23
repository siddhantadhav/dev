return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },

	opts = {},

	config = function(_, opts)
		require("todo-comments").setup(opts)

		local function get_file()
			return vim.fn.stdpath("data") .. "/loclist.json"
		end

		local function save_loclist()
			local file = get_file()
			local items = vim.fn.getloclist(0)

			vim.fn.mkdir(vim.fn.fnamemodify(file, ":h"), "p")
			vim.fn.writefile({ vim.json.encode(items) }, file)
		end

		local function load_loclist()
			local file = get_file()

			if vim.fn.filereadable(file) == 0 then
				return
			end

			local data = vim.fn.readfile(file)
			local items = vim.json.decode(table.concat(data, "\n"))

			vim.fn.setloclist(0, {}, "r", { items = items })
		end

		vim.api.nvim_create_autocmd("VimEnter", {
			callback = load_loclist,
		})

		vim.keymap.set("n", "<leader>ls", save_loclist, {
			desc = "Save working plan",
		})

		vim.keymap.set("n", "<leader>ll", load_loclist, {
			desc = "Load working plan",
		})
	end,

	keys = {
		-- Telescope
		{
			"<leader>ft",
			"<cmd>TodoTelescope<cr>",
			desc = "Project TODOs",
		},

		-- Project-wide TODOs
		{
			"<leader>tq",
			"<cmd>TodoQuickFix<cr>",
			desc = "Project issues (Quickfix)",
		},

		-- Working plan (Location List)

		{
			"<leader>lo",
			"<cmd>lopen<cr>",
			desc = "Open working plan",
		},

		{
			"<leader>lc",
			function()
				vim.fn.setloclist(0, {}, "r", { items = {} })
			end,
			desc = "Clear working plan",
		},

		{
			"<leader>la",
			function()
				vim.fn.setloclist(0, {}, "a", {
					items = {
						{
							filename = vim.api.nvim_buf_get_name(0),
							lnum = vim.fn.line("."),
							col = vim.fn.col("."),
							text = vim.fn.getline("."),
						},
					},
				})
			end,
			desc = "Add current line to working plan",
		},

		{
			"<leader>ln",
			"<cmd>lnext<cr>",
			desc = "Next working step",
		},

		{
			"<leader>lp",
			"<cmd>lprev<cr>",
			desc = "Previous working step",
		},
	}

}
