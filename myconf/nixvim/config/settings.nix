{
  config = {
    extraConfigLuaPre =
      ''
      vim.fn.sign_define("diagnosticsignerror", { text = " ", texthl = "diagnosticerror", linehl = "", numhl = "" })
      vim.fn.sign_define("diagnosticsignwarn", { text = " ", texthl = "diagnosticwarn", linehl = "", numhl = "" })
      vim.fn.sign_define("diagnosticsignhint", { text = "󰌵", texthl = "diagnostichint", linehl = "", numhl = "" })
      vim.fn.sign_define("diagnosticsigninfo", { text = " ", texthl = "diagnosticinfo", linehl = "", numhl = "" })
      '';

    opts = {
      number = true;
      tabstop = 2;
      softtabstop = 2;
      showtabline = 2;
      expandtab = true;
      smartindent = true;
      shiftwidth = 2;
      mouse = "a";
      scrolloff = 12;
      cursorline = true;
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
