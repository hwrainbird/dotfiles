return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { ".git", "node_modules", "__pycache__", ".venv", "*.pyc", "*.egg-info", ".pytest_cache", ".DS_Store" },
        },
      },
    },
  },
}
