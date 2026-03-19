return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = { "^%.git/" },
    },
    pickers = {
      find_files = {
        hidden = true,
        find_command = {
          "fd",
          "--type",
          "f",
          "--hidden",
          "--no-ignore",
          "--exclude",
          ".git",
          "--exclude",
          "__pycache__",
          "--exclude",
          "*.pyc",
          "--exclude",
          "node_modules",
          "--exclude",
          ".venv",
          "--exclude",
          "*.egg-info",
        },
      },
    },
  },
}
