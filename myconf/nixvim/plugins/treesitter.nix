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
    treesitter-refactor = {
      enable = true;
      highlightDefinitions = {
        enable = true;
        # Set to false if you have an `updatetime` of ~100.
        clearOnCursorMove = true;
      };
    };
    hmts = {
      enable = true;
    };
  };
}
