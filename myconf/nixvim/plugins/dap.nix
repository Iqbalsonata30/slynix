{pkgs, ...}: {
  plugins.dap = {
    enable = true;
    extensions = {
      dap-ui.enable = true;
      dap-virtual-text.enable = true;
    };
    adapters = {
    };
  };

  extraConfigLuaPost = ''
    for _, language in ipairs(js_based_languages) do
      require("dap").configurations[language] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "''${file}",
          cwd = "''${workspaceFolder}",
        },
        {
         type = 'pwa-node',
         request = 'attach',
         name = 'Attach to Node app',
         address = 'localhost',
         port = 9229,
         cwd = "''${workspaceFolder}",
         restart = true,
        },
        {
          name = 'Debug with Firefox',
          type = 'firefox',
          request = 'launch',
          reAttach = true,
          url = 'http://localhost:3000',
          webRoot = "''${workspaceFolder}",
          firefoxExecutable = 'firefox'
        }
      }
    end

    local dap, dapui = require("dap"), require("dapui")
    require("dap.go").setup();

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open({})
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close({})
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close({})
    end

    require('telescope').load_extension('dap')
  '';

  extraPlugins = [
    pkgs.vimPlugins.telescope-dap-nvim
  ];
  keymaps = [
    # Nvim Dap
    {
      key = "<leader>du";
      mode = ["n"];
      action = "<cmd>lua require('dapui').toggle()<cr>";
      options = {
        desc = "Dap UI";
      };
    }
    {
      key = "<F5>";
      mode = ["n"];
      action = "<cmd>lua require('dap').continue()<cr>";
      options = {
        desc = "Dap continue";
      };
    }
    {
      key = "<F10>";
      mode = ["n"];
      action = "<cmd>lua require('dap').step_over()<cr>";
      options = {
        desc = "Dap Step Over";
      };
    }
    {
      key = "<F11>";
      mode = ["n"];
      action = "<cmd>lua require('dap').step_into()<cr>";
      options = {
        desc = "Dap Step Into";
      };
    }
    {
      key = "<F12>";
      mode = ["n"];
      action = "<cmd>lua require('dap').step_out()<cr>";
      options = {
        desc = "Dap Step Out";
      };
    }
    {
      key = "<leader>db";
      mode = ["n"];
      action = "<cmd>lua require('dap').toggle_breakpoint()<cr>";
      options = {
        desc = "Dap Toggle Breakpoint";
      };
    }
    {
      key = "<leader>dB";
      mode = ["n"];
      action.__raw = ''
        function()
          require 'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end
      '';
      options = {
        desc = "Dap Conditional Breakpoint";
      };
    }
  ];
}
