{pkgs, ...}: {
  programs.nixvim = {
    imports = [
      ./config/keymappings.nix
      ./config/settings.nix
      ./plugins/lsp.nix
      ./plugins/colorscheme.nix
      ./plugins/neotree.nix
      ./plugins/treesitter.nix
      ./plugins/telescope.nix
      ./plugins/nvim-autopairs.nix
      ./plugins/smart-splits.nix
      ./plugins/git.nix
      ./plugins/dressing.nix
      ./plugins/indent-blankline.nix
      ./plugins/floaterm.nix
      ./plugins/zig.nix
      ./plugins/harpoon.nix
    ];

    enable = true;

    plugins.lualine.enable = true;
    plugins.vim-surround.enable = true;
    plugins.web-devicons.enable = true;
  };
}
