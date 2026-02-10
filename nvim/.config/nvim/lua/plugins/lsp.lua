return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "gD", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", desc = "Go to definition in vsplit" },
        },
      },
    },
  },
}
