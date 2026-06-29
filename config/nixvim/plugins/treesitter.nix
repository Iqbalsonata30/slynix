{pkgs, ...}: {
  plugins = {
    treesitter = {
      enable = true;
      settings.highlight.enable = true;
      settings.indent.enable = true;

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
    # treesitter-refactor = {
    #   enable = true;
    #   settings = {
    #     highlight_definitions = {
    #       enable = true;
    #       clear_on_cursor_move = true;
    #     };
    #   };
    # };
    
  };
}
