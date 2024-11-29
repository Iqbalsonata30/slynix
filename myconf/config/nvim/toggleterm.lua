require("toggleterm").setup({
	size = 40,
	open_mapping = [[<c-\>]],
	hide_numbers = true, 
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
	start_in_insert = true,
	persist_size = true,
  insert_mappings = true, 
	direction = "horizontal",
	close_on_exit = true,
	shell = vim.o.shell, 
})
function _G.set_terminal_keymaps()
	local opts = { noremap = true }
	vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
  -- vim.keymap.set("n","<C-w>",function()
  --   vim.cmd("ToggleTermToggleAll")
  -- end,opts)
  --
  -- vim.keymap.set("t","<C-p>",function()
  --   vim.cmd("TermSelect")
  -- end,opts)
  
end


-- if you only want these mappings for toggle term use term://*toggleterm#* instead
-- 
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
