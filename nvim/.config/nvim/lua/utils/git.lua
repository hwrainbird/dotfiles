local M = {}

function M.get_file_status(filepath)
  if filepath == "" then
    return ""
  end

  local git_status = vim.fn.system(
    "git -C "
      .. vim.fn.shellescape(vim.fn.fnamemodify(filepath, ":h"))
      .. " status --porcelain "
      .. vim.fn.shellescape(filepath)
      .. " 2>/dev/null"
  )

  if vim.v.shell_error ~= 0 then
    return ""
  end

  git_status = git_status:gsub("%s+", "")

  if git_status == "" then
    return ""
  elseif git_status:match("^M") then
    return ""
  elseif git_status:match("^%sM") then
    return ""
  elseif git_status:match("^A") then
    return ""
  elseif git_status:match("^%?%?") then
    return ""
  elseif git_status:match("^D") then
    return ""
  else
    return ""
  end
end

function M.get_project_context()
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("%s+", "")
  if vim.v.shell_error == 0 and git_root ~= "" then
    return vim.fn.fnamemodify(git_root, ":t")
  else
    return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  end
end

return M