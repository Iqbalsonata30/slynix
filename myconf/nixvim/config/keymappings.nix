{
  globals.mapleader = " ";
  clipboard = {
    register = "unnamedplus";
    providers.xclip.enable = true;
  };

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

    # Lspsaga Peek Definition
    {
      action = ":Lspsaga peek_definition<CR>";
      key = "<C-e>";
      options = {
        silent = true;
        noremap = true;
      };
    }

    # Splits Window
    {
      action = ":vsplit<CR><C-w>l";
      key = "<leader>v";
      options = {
        silent = true;
      };
    }

    # Smart Split Move Cursor Left
    {
      action = ":lua require('smart-splits').move_cursor_left()<CR>";
      mode = "n";
      key = "<C-l>";
      options.silent = true;
    }

    # Smart Split Move Cursor Right
    {
      mode = "n";
      key = "<C-k>";
      action = ":lua require('smart-splits').move_cursor_right()<CR>";
      options.silent = true;
    }

    # Smart Split Resize Left
    {
      mode = "n";
      key = "<C-h>";
      action = ":lua require('smart-splits').resize_left()<CR>";
      options.silent = true;
    }

    # Smart Split Resize Left
    {
      mode = "n";
      key = "<C-j>";
      action = ":lua require('smart-splits').resize_right()<CR>";
      options.silent = true;
    }
  ];
}
# vim.keymap.set("n", "<leader>s", ":split<CR><C-w>j", { silent = true })
