{pkgs, ...}: {
  programs.nixvim = {
    imports = [
      ./config/keymappings.nix
      ./config/settings.nix
      ./plugins/lsp.nix
      ./plugins/colorscheme.nix
    ];

    enable = true;

    plugins.lualine.enable = true;

    plugins.web-devicons.enable = true;

    #telescope
    plugins.telescope.enable = true;
    plugins.telescope.highlightTheme = "dracula-nvim";

    #neotree
    plugins.neo-tree.enable = true;
    plugins.neo-tree.enableGitStatus = true;
    plugins.neo-tree.enableDiagnostics = true;

    plugins.treesitter = {
      enable = true;
      settings.highlight.enable = true;

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        json
        lua
        zig
        typescript
        c
        gitignore
        gitcommit
        git_rebase
        go
        gomod
        html
        javascript
        objdump
        php
        sql
        terraform
        make
        markdown
        nix
        regex
        vim
        vimdoc
        yaml
      ];
    };
  };
}
