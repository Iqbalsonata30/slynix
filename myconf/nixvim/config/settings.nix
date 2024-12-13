{
  config = {
    highlight = {
      CursorLine = {
        fg = "none";
        bg = "none";
      };
      Pmenu = {
        fg = "none";
        bg = "#a559ba";
      };
      PmenuSbar = {
        fg = "none";
        bg = "#a559ba";
      };
      PmenuThumb = {
        fg = "none";
        bg = "#a559ba";
      };
      PmenuSel = {
        fg = "none";
        bg = "#20202a";
      };

      CmpItemAbbrMatch = {
        fg = "#a9b1d6";
        bg = "none";
      };
      CmpItemAbbrMatchFuzzy = {
        fg = "#a9b1d6";
        bg = "none";
      };
      CmpItemAbbr = {
        fg = "#545c7e";
        bg = "none";
      };
      CmpItemKind = {
        fg = "#9d7cd8";
        bg = "none";
      };
      CmpItemMenu = {
        fg = "#9d7cd8";
        bg = "none";
      };
      CmpItemKindSnippet = {
        fg = "#9d7cd8";
        bg = "none";
      };
    };
    extraConfigLuaPre = ''
      vim.fn.sign_define("diagnosticsignerror", { text = " ", texthl = "diagnosticerror", linehl = "", numhl = "" })
      vim.fn.sign_define("diagnosticsignwarn", { text = " ", texthl = "diagnosticwarn", linehl = "", numhl = "" })
      vim.fn.sign_define("diagnosticsignhint", { text = "󰌵", texthl = "diagnostichint", linehl = "", numhl = "" })
      vim.fn.sign_define("diagnosticsigninfo", { text = " ", texthl = "diagnosticinfo", linehl = "", numhl = "" })
    '';

    opts = {
      number = true;
      tabstop = 4;
      softtabstop = 2;
      showtabline = 2;
      expandtab = true;
      smartindent = true;
      shiftwidth = 4;
      mouse = "a";
      scrolloff = 12;
      breakindent = true;
      rnu = true;
      ignorecase = true;
      smartcase = true;
      hidden = true;
      wrap = true;
      termguicolors = true;
      swapfile = false;
      relativenumber = true;
      cmdheight = 1;
      completeopt = "menuone,noinsert";
      showmode = false;
      incsearch = true;
      updatetime = 50;
    };
  };
}
