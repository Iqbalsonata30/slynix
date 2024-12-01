{
  globals.mapleader = " ";
  globals.zig_fmt_autosave = 0;
  keymaps = [
    {
      action = ":lua vim.lsp.buf.definition()<CR>";
      key = "<leader>gd";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to definition";
      };
    }

    # Telescope find file
    {
      action = ":Telescope find_files<CR>";
      key = "<leader>ff";
      options = {
        silent = true;
        noremap = true;
        desc = "Search files";
      };
    }

    # Telescope search Live Grep
    {
      action = ":Telescope live_grep<CR>";
      key = "<leader>fg";
      options = {
        silent = true;
        noremap = true;
        desc = "Search grep";
      };
    }

    # Telescope buffers
    {
      action = ":Telescope buffers<CR>";
      key = "<leader>fb";
      options = {
        silent = true;
        noremap = true;
        desc = "Search Buffer";
      };
    }

    # Telescope search help tags
    {
      action = ":Telescope help_tags<CR>";
      key = "<leader>fh";
      options = {
        silent = true;
        noremap = true;
        desc = "Find Helps";
      };
    }

    # Telescope search keymaps
    {
      action = ":Telescope keymaps<CR>";
      key = "<leader>fk";
      options = {
        silent = true;
        noremap = true;
        desc = "Search Keymaps";
      };
    }

    # Neotree toggle
    {
      action = ":Neotree toggle<CR>";
      key = "<leader>e";
      options = {
        silent = true;
        noremap = true;
      };
    }

    {
      action = ":Lspsaga diagnostic_jump_next<CR>";
      key = "[d";
      options = {
        silent = true;
        noremap = true;
      };
    }

    {
      action = ":Lspsaga diagnostic_jump_prev<CR>";
      key = "]d";
      options = {
        silent = true;
        noremap = true;
      };
    }

    {
      action = ":Lspsaga peek_definition<CR>";
      key = "<C-e>";
      options = {
        silent = true;
        noremap = true;
      };
    }
  ];
}
#
# -- keymap
# -- change leader
# vim.g.mapleader = " "
# vim.keymap.set("n", "<space", "<nop>", { silent = true })
#
#
# vim.keymap.set("n", "<C-k>", ":resize +2<CR>", { silent = true })
# vim.keymap.set("n", "<C-j>", ":resize -2<CR>", { silent = true })
#
# vim.keymap.set("n", "<C-l>", ":vertical resize +2<CR>", { silent = true })
# vim.keymap.set("n", "<C-h>", ":vertical resize -2<CR>", { silent = true })
#
#
# -- copy to clipboard
# vim.keymap.set({ "v", "n" }, "<leader>y", '"+y')
# vim.keymap.set("n", "<leader>Y", '"+yg_')
#
# -- paste to clipbord
# vim.keymap.set({ "v", "n" }, "<leader>p", '"+p')
# vim.keymap.set({ "v", "n" }, "<leader>P", '"+P')
#
#
# -- splits
# vim.keymap.set("n", "<leader>s", ":split<CR><C-w>j", { silent = true })
# vim.keymap.set("n", "<leader>v", ":vsplit<CR><C-w>l", { silent = true })
