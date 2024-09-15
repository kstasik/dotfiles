require('nvim-tree').setup {}

vim.keymap.set('n', '<leader>nn', ":NvimTreeToggle<CR>")
vim.keymap.set('n', '<leader>nf', ":NvimTreeFindFile<CR>")
