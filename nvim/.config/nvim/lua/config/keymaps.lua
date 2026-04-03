-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Override LazyVim's maplocalleader setting
vim.g.maplocalleader = " "

-- Colemak Keymappings for LazyVim
local map = vim.keymap.set

-- ==================== Basic Mappings ====================
map("n", "Q", ":q<CR>", { desc = "Quit window" })
map("n", "S", ":w<CR>", { desc = "Save file" })

-- Undo operations
map("n", "l", "u", { desc = "Undo" })

vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })

-- Insert Key (Colemak remapping)
map({ "n", "v", "o" }, "k", "i", { desc = "Insert mode" })
map("n", "K", "I", { desc = "Insert at line start" })

-- ==================== Cursor Movement (Colemak) ====================
-- New cursor movement (mnei = hjkl)
-- Exclude neo-tree buffers to avoid conflicts
local function not_neo_tree()
  return vim.bo.filetype ~= "neo-tree"
end

map({ "n", "v", "o" }, "m", function()
  if not_neo_tree() then
    return "h"
  else
    return "m"
  end
end, { desc = "Left", expr = true })

map({ "n", "v", "o" }, "n", "j", { desc = "Down" })

map({ "n", "v", "o" }, "e", function()
  if not_neo_tree() then
    return "k"
  else
    return "e"
  end
end, { desc = "Up", expr = true })

map({ "n", "v", "o" }, "i", "l", { desc = "Right" })

-- M/N keys for 5 times movement (faster navigation)
map({ "n", "v", "o" }, "M", "5h", { desc = "5 chars left" })
map({ "n", "v", "o" }, "N", "5j", { desc = "5 lines down" })
map({ "n", "v", "o" }, "E", "5k", { desc = "5 lines up" })
map({ "n", "v", "o" }, "I", "5l", { desc = "5 chars right" })

-- Middle of screen
map("n", "<leader>M", "M", { desc = "Middle of screen" })

-- Text objects using Colemak 'k' for inner (consistent with k=insert mapping)
map({ "o", "x" }, "kw", "iw", { desc = "Inner word" })
map({ "o", "x" }, "ks", "is", { desc = "Inner sentence" })
map({ "o", "x" }, "kp", "ip", { desc = "Inner paragraph" })
map({ "o", "x" }, "k)", "i)", { desc = "Inner parentheses" })
map({ "o", "x" }, "k]", "i]", { desc = "Inner brackets" })
map({ "o", "x" }, "k}", "i}", { desc = "Inner braces" })
map({ "o", "x" }, 'k"', 'i"', { desc = "Inner quotes" })
map({ "o", "x" }, "k'", "i'", { desc = "Inner single quotes" })

-- Faster in-line navigation
map({ "n", "v", "o" }, "W", "5w", { desc = "5 words forward" })
map({ "n", "v", "o" }, "B", "5b", { desc = "5 words backward" })

-- set h (same as m, cursor left) to 'end of word'
map({ "n", "v", "o" }, "h", "e", { desc = "End of word" })

-- ==================== Window Management ====================
-- Use <space> + new arrow keys for moving the cursor around windows
map("n", "<leader>w", "<C-w>w", { desc = "Next window" })
map("n", "<leader>m", "<C-w>h", { desc = "Move to left window" })
map("n", "<leader>n", "<C-w>j", { desc = "Move to lower window" })
map("n", "<leader>e", "<C-w>k", { desc = "Move to upper window" })
map("n", "<leader>i", "<C-w>l", { desc = "Move to right window" })

-- Alt window navigation (works in terminal mode too)
map({ "n", "t" }, "<A-m>", "<C-w>h", { desc = "Move to left window" })
map({ "n", "t" }, "<A-n>", "<C-w>j", { desc = "Move to lower window" })
map({ "n", "t" }, "<A-e>", "<C-w>k", { desc = "Move to upper window" })
map({ "n", "t" }, "<A-i>", "<C-w>l", { desc = "Move to right window" })

-- Arrow key window navigation
map("n", "<leader><Left>", "<C-w>h", { desc = "Move to left window" })
map("n", "<leader><Down>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<leader><Up>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<leader><Right>", "<C-w>l", { desc = "Move to right window" })

-- Use s/S for search navigation (unified across all apps)
map("n", "s", "n", { desc = "Next search result" })
map("n", "S", "N", { desc = "Previous search result" })

-- Split the screens
map("n", "se", ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>", { desc = "Split up" })
map("n", "sn", ":set splitbelow<CR>:split<CR>", { desc = "Split down" })
map("n", "sm", ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>", { desc = "Split left" })
map("n", "si", ":set splitright<CR>:vsplit<CR>", { desc = "Split right" })

-- Place the two screens up and down
map("n", "sh", "<C-w>t<C-w>K", { desc = "Arrange horizontally" })
-- Place the two screens side by side
map("n", "sv", "<C-w>t<C-w>H", { desc = "Arrange vertically" })

-- ==================== Tab Management ====================
-- Create a new tab
map("n", "tu", ":tabe<CR>", { desc = "New tab" })
map("n", "tU", ":tab split<CR>", { desc = "Split into new tab" })

-- Move around tabs
map("n", "tm", ":-tabnext<CR>", { desc = "Previous tab" })
map("n", "ti", ":+tabnext<CR>", { desc = "Next tab" })

-- Move the tabs
map("n", "tmm", ":-tabmove<CR>", { desc = "Move tab left" })
map("n", "tmi", ":+tabmove<CR>", { desc = "Move tab right" })

-- ==================== Other Useful Mappings ====================
-- Jump to next placeholder
map("n", "<leader><leader>", '<Esc>/<++><CR>:nohlsearch<CR>"_c4l', { desc = "Next placeholder" })

-- Case change
map("n", "`", "~", { desc = "Change case" })

-- Find and replace
map("n", "\\s", ":%s//g<left><left>", { desc = "Find and replace" })

-- Clear search on Escape
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- ==================== Search Navigation ====================
-- Navigate between search results (since n/N are remapped for Colemak)
map("n", "j", "n", { desc = "Next search result" })
map("n", "J", "N", { desc = "Previous search result" })

-- Custom commands for Node.js server
vim.api.nvim_create_user_command(
  "KStart",
  "!node /Users/knack/AppDev/Lib/KTL/NodeJS/NodeJS_FileServer.js &",
  { desc = "Start Node.js file server" }
)
vim.api.nvim_create_user_command("KKill", "!pkill node", { desc = "Kill Node.js server" })

-- Remove debugger statements
map("n", "<leader>rd", ":g/^\\s*debugger;\\s*$/d<CR>", { desc = "Remove debugger lines" })

-- File server keymap
map("n", "<leader>sv", ":!fileserver<CR>", { desc = "Start file server" })

-- ==================== Path Copy Keymaps ====================
map("n", "<leader>yp", ':let @+ = expand("%:p")<CR>', { desc = "Copy absolute path" })
map("n", "<leader>yr", ':let @+ = expand("%")<CR>', { desc = "Copy relative path" })
map("n", "<leader>yf", ':let @+ = expand("%:t")<CR>', { desc = "Copy filename" })
map("n", "<leader>cc", ':let @+ = expand("%:t")<CR>', { desc = "Copy filename" })

-- TaskWarrior note shortcuts (from your Kickstart config)
map("n", "<leader>x", ":s/- \\[ \\]/- [x]/<CR>:nohlsearch<CR>", { desc = "Check checkbox" })
map("n", "<leader>o", ":s/- \\[x\\]/- [ ]/<CR>:nohlsearch<CR>", { desc = "Uncheck checkbox" })
map("n", "<leader>c", "o- [ ] ", { desc = "Add checkbox" })
map("n", "<leader>ta", function()
  local line = vim.api.nvim_get_current_line()
  vim.fn.system('task add "' .. line:gsub('"', '\\"') .. '"')
  print("Added task: " .. line)
end, { desc = "[T]ask [A]dd from current line" })

map("n", "<leader>tt", function()
  local current_dir = vim.fn.expand("%:p:h")
  vim.cmd("terminal cd " .. vim.fn.shellescape(current_dir) .. " && $SHELL")
end, { desc = "Terminal in current directory" })

vim.keymap.set("n", "<leader>t", "", { desc = "+terminal/task" })

-- ==================== npm Commands ====================
-- npm commands with terminal
map("n", "<leader>nb", function()
  Snacks.terminal.open({"npm", "run", "build"}, { cwd = vim.fn.getcwd() })
end, { desc = "npm run build" })

map("n", "<leader>nd", function()
  Snacks.terminal.open({"npm", "run", "deploy"}, { cwd = vim.fn.getcwd() })
end, { desc = "npm run deploy" })

