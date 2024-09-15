vim.g.mapleader = " "

local opts = { noremap = true };

vim.keymap.set("n", "<TAB>", vim.cmd.bnext, opts)
vim.keymap.set("n", "<S-TAB>", vim.cmd.bprev, opts)
vim.keymap.set("n", "zs", ":w<CR>")
-- vim.keymap.set("n", "<F6>", "<Esc>:call rust_execute_test()<Enter>", opts)

local function set_wincmd(arg, to)
    vim.keymap.set("n", "<leader>" .. arg, function() vim.cmd.wincmd(to) end, opts)
end

set_wincmd("h", "h")
set_wincmd("j", "j")
set_wincmd("k", "k")
set_wincmd("l", "l")

set_wincmd("<Left>", "h")
set_wincmd("<Down>", "j")
set_wincmd("<Up>", "k")
set_wincmd("<Right>", "l")

vim.keymap.set("n", "<M-x>", ":")
vim.keymap.set("n", "<leader>jq", ":%!jq<CR>")

