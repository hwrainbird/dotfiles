return {
  "hrsh7th/nvim-cmp",
  keys = {
    {
      "<M-d>",
      function()
        local cmp = require("cmp")
        vim.notify("CMP visible: " .. tostring(cmp.visible()), vim.log.levels.INFO)
      end,
      mode = "i",
      desc = "Debug: Check if cmp menu is visible",
    },
  },
}
