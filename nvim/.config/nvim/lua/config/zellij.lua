local icons = require("utils.icons")
local git = require("utils.git")

local function truncate(str, max_length)
  if #str <= max_length then
    return str
  else
    return str:sub(1, max_length - 3) .. "..."
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufRead", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("ZellijPaneRename", { clear = true }),
  callback = function()
    if not vim.env.ZELLIJ then
      return
    end

    local filename = vim.fn.expand("%:t")
    local filepath = vim.fn.expand("%:p")
    local pane_name

    if filename == "" then
      pane_name = " nvim"
    elseif vim.bo.buftype ~= "" then
      local icon = icons.get_buffer_icon(vim.bo.buftype)
      pane_name = icon .. " " .. vim.bo.buftype
    else
      local icon = icons.get_file_icon(filename)
      local git_status = git.get_file_status(filepath)
      local project = git.get_project_context()

      local base_name = icon .. (git_status ~= "" and git_status .. " " or " ") .. filename

      if project ~= "" and not filename:find(project) then
        base_name = base_name .. " [" .. project .. "]"
      end

      pane_name = truncate(base_name, 25)
    end

    vim.fn.system("zellij action rename-pane '" .. pane_name:gsub("'", "'\\''") .. "'")
  end,
})
