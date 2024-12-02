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
    ];

    enable = true;

    plugins.lualine.enable = true;
    plugins.web-devicons.enable = true;
  };
}
