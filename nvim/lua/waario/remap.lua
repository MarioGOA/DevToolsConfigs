-- Map Leaders
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Open Vim Explorer
vim.keymap.set("n", "<leader>ls", vim.cmd.Ex)

-- Clean Search
vim.keymap.set({"n", "v"}, "<leader>c", ":nohlsearch<CR>", { silent = true })

-- Move Selection
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Halp page jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keeping curson in the middle while searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste without copying - when yanked!
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Yank to system clipboard (thanks god)
vim.keymap.set({"n", "v"}, "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- Delete without copying
vim.keymap.set({"n", "v"}, "<leader>d", "\"_d")

-- Ctrl-c works for vertical edit
vim.keymap.set("i", "C-c", "<Esc>")

-- QOL
vim.keymap.set("n", "Q", "<nop>")

-- VIM tree
vim.keymap.set({"n", "v"}, "<leader>pf", ":NvimTreeToggle<CR>")

-- LSP Remaps --
vim.keymap.set({"n", "v"}, "<leader>fm", vim.lsp.buf.format, { desc = 'Format buffer'})
