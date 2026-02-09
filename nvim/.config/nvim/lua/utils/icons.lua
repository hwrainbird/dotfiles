local M = {}

M.file_extensions = {
  lua = "",
  js = "",
  jsx = "",
  ts = "",
  tsx = "",
  py = "",
  rs = "",
  go = "",
  java = "",
  md = "",
  txt = "",
  json = "",
  yaml = "",
  yml = "",
  css = "",
  scss = "",
  html = "",
  vim = "",
  sh = "",
  bash = "",
  git = "",
  config = "",
  conf = "",
  lock = "",
  toml = "",
  xml = "",
  sql = "",
  php = "",
  rb = "",
  c = "",
  cpp = "",
  cc = "",
  h = "",
  hpp = "",
  swift = "",
  kt = "",
  dart = "",
  dockerfile = "",
  makefile = "",
}

M.buffer_types = {
  help = "",
  terminal = "",
  quickfix = "",
  nofile = "",
}

function M.get_file_icon(filename)
  local ext = filename:match("%.([^%.]+)$")
  return M.file_extensions[ext] or ""
end

function M.get_buffer_icon(buftype)
  return M.buffer_types[buftype] or ""
end

return M