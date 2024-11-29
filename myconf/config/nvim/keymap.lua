-- keymap
-- change leader
vim.g.mapleader = " "
vim.keymap.set("n", "<space", "<nop>", { silent = true })


vim.keymap.set("n", "<C-k>", ":resize +2<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", ":resize -2<CR>", { silent = true })

vim.keymap.set("n", "<C-l>", ":vertical resize +2<CR>", { silent = true })
vim.keymap.set("n", "<C-h>", ":vertical resize -2<CR>", { silent = true })


-- copy to clipboard
vim.keymap.set({ "v", "n" }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+yg_')

-- paste to clipbord
vim.keymap.set({ "v", "n" }, "<leader>p", '"+p')
vim.keymap.set({ "v", "n" }, "<leader>P", '"+P')


-- splits
vim.keymap.set("n", "<leader>s", ":split<CR><C-w>j", { silent = true })
vim.keymap.set("n", "<leader>v", ":vsplit<CR><C-w>l", { silent = true })
