local keys = {
  {
    "<leader>a",
    function()
      require("harpoon"):list():add()
    end,
    desc = "Harpoon Add File",
  },
  {
    "<leader>h",
    function()
      local harpoon = require("harpoon")
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end,
    desc = "Harpoon Menu",
  },
}

-- <leader>1-9 select entries 1-9, <leader>0 selects entry 10
for i = 1, 10 do
  local lhs = "<leader>" .. (i == 10 and "0" or tostring(i))
  table.insert(keys, {
    lhs,
    function()
      require("harpoon"):list():select(i)
    end,
    desc = "Harpoon Select " .. i,
  })
end

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    opts = {
      settings = {
        save_on_toggle = true,
      },
    },

    keys = keys,
  },
}
