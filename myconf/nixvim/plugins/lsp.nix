{
  plugins = {
    lsp = {
      enable = true;

      keymaps = {
        silent = true;
        diagnostic = {
          "<leader>k" = "goto_prev";
          "<leader>j" = "goto_next"; }; 
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
        ccls = {
          enable = true;
          autostart = true;
        };

        gopls = {
          enable = true;
          autostart = true;
          extraOptions.settings.gopls.hints = {
            assignVariableTypes = true;
            compositeLiteralFields = true;
            compositeLiteralTypes = true;
            constantValues = true;
            functionTypeParameters = true;
            parameterNames = true;
            rangeVariableTypes = true;
          };

        };
        nixd = {
          enable = true;
          autostart = true;
          settings.formatting.command = [ "nixfmt" ];
        };

        lua_ls = {
          enable = true;
          autostart = true;

        };
        zls = {
          enable = true;
          autostart = true;
        };

        dockerls.enable = true;
        dockerls.autostart = true;

        jsonls = {
          enable = true;
          autostart = true;
        };

        html = {
          enable = true;
          autostart =true;
        };
      };
    };


    lspkind = {
      enable = true;
      cmp = {
        enable  = true;
        maxWidth = 24;
        after =   ''
          function(entry, vim_item, kind)
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = " " .. (strings[1] or "") .. " "
          kind.menu = "   ⌈" .. (strings[2] or "") .. "⌋"
          return kind
          end
          '';
      };
      symbolMap = {
        Suggestion = " ";
        Error = "";
        Hint = "";
        Info = "";
        Warn = "";
        DiagnosticSignError = "";
        DiagnosticSignHint = "";
        DiagnosticSignInfo = "";
        DiagnosticSignWarn = "";
      };
    };

    lspsaga = {
      enable = true;
      lightbulb.sign = false;
      lightbulb.virtualText = true;
      lightbulb.debounce = 40;
      ui.codeAction = "⛭";
    };

    trouble.enable = true;
    lsp-format.enable = true;
    nvim-autopairs.enable = true;

    cmp = {
      autoEnableSources = true;
      settings = { 
        sources =  [
          { name = "nvim_lsp"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "nvim_lsp_document_symbol"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "yanky"; }
          { name = "buffer";}
          { name = "async_path";}
        ];
        perfomance = {
          debounce = 60;
          fetching_timeout = 200;
          max_view_entries = 30;
        };
        window = {
          completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
            border = "rounded";
            col_offset = -3;
            side_padding = 0;
          };
          documentation.border = "rounded";
        };
        formatting = {
          expandable_indicator = true;
          fields = [ "abbr" "kind" "menu" ];
        };

        mapping = {
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
        };
      };
    };
  };
}
