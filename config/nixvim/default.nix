{pkgs, ...}: {
  programs.nixvim = {
    imports = [
      ./config/keymappings.nix
      ./config/settings.nix
      ./plugins/colorscheme.nix
      ./plugins/dressing.nix
      ./plugins/gitsign.nix
      ./plugins/harpoon.nix
      ./plugins/illuminate.nix
      ./plugins/lsp.nix
      ./plugins/neotree.nix
      ./plugins/nvim-autopairs.nix
      ./plugins/smart-splits.nix
      ./plugins/treesitter.nix
      ./plugins/telescope.nix
      ./plugins/nvim-spectre.nix
    ];

    enable = true;

    plugins.lualine.enable = true;
    plugins.vim-surround.enable = true;
    plugins.web-devicons.enable = true;
    plugins.trouble.enable = true;

    extraConfigLua = ''
      local harpoon = require("harpoon")

      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

      vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
      vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
      vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
      vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

      vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
      vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
    '';
  };
}
