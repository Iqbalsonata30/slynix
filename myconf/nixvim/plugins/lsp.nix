{
  plugins = {
    lsp = {
      enable = true;
      inlayHints = true;
      keymaps = {
        silent = true;
        diagnostic = {
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
          settings.formatting.command = ["nixfmt"];
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
          autostart = true;
        };
      };
    };

    lspkind = {
      enable = true;
      cmp = {
        enable = true;
        maxWidth = 50;
        ellipsisChar = "...";
        after = ''
          function(entry, vim_item, kind)
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = " " .. (strings[1] or "") .. " "
          kind.menu = "   ⌈" .. (strings[2] or "") .. "⌋"
          return kind
          end
        '';
      };
      mode = "symbol_text";
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
    nvim-colorizer.enable = true;

    cmp-nvim-lsp.enable = true;
    cmp-buffer.enable = true;
    cmp-path.enable = true;
    cmp-treesitter.enable = true;

    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          {name = "nvim_lsp";}
          {name = "nvim_lsp_signature_help";}
          {name = "nvim_lsp_document_symbol";}
          {name = "luasnip";}
          {name = "path";}
          {name = "cmp_yanky";}
          {name = "buffer";}
          {name = "async_path";}
        ];
        perfomance = {
          debounce = 60;
          fetching_timeout = 200;
          max_view_entries = 30;
        };
        window = {
          completion = {
            winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None";
            zindex = 1001;
            scrolloff = 0;
            border = "rounded";
            colOffset = 0;
            sidePadding = 1;
            scrollbar = true;
          };
          documentation = {
            border = "rounded";
            winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None";
            zindex = 1001;
            maxHeight = 20;
          };
        };
        formatting = {
          expandable_indicator = true;
          fields = ["abbr" "kind" "menu"];
          #   format = ''
          #       function(entry, item)
          #       local menu_icon = {
          #         nvim_lsp = '[LSP]',
          #         luasnip = '[SNIP]',
          #         buffer = '[BUF]',
          #         path = '[PATH]',
          #       }
          #     item.menu = menu_icon[entry.source.name]
          #       return item
          #       end
          #   '';
        };

        snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        mapping = {
          "<C-u>" = "cmp.mapping.scroll_docs(-4)";
          "<C-d>" = "cmp.mapping.scroll_docs(4)";
          "<C-p>" = "cmp.mapping.complete()";
          "<C-x>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
      };
    };

    none-ls = {
      enable = true;
      sources = {
        formatting = {
          prettier.enable = true;
          alejandra.enable = true;
          gofumpt.enable = true;
          goimports.enable = true;
          clang_format.enable = true;
          stylua.enable = true;
        };
      };
    };

    conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = true;
        formatters_by_ft = {
          css = ["prettier"];
          html = ["prettier"];
          json = ["prettier"];
          just = ["just"];
          lua = ["stylua"];
          markdown = ["prettier"];
          nix = ["alejandra"];
        };
      };
    };
  };
}
