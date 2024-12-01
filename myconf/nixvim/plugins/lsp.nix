{
  plugins = {
    lsp = {
      enable = true;

      keymaps = {
        silent = true;
        diagnostic = {
        # Navigate in diagnostics
          "<leader>k" = "goto_prev";
          "<leader>j" = "goto_next";
        };

        lspBuf = {
          gd = "definition";
          gD = "references";
          gt = "type_definition";
          gi = "implementation";
          K = "hover";
          "<F2>" = "rename";
        };
      };

      servers = {
        gopls.enable = true;
        golangci_lint_ls.enable = true;
        lua_ls.enable = true;
        zls.enable = true;
        nixd.enable = true;
        jsonls.enable = true;
        html.enable = true;
        clangd.enable = true;

      };
    };
  };

}
