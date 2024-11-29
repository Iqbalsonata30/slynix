{ config, pkgs,libs, ... }:

{
  imports = [
    ./packages.nix
    ./git.nix
    ./tmux.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "iqbalsonata";
  home.homeDirectory = "/home/iqbalsonata";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release introduces backwards incompatible changes.
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
# Allow Unfree Packages
  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  #environment.
      # # "Hello, world!" when run.
    # pkgs.hello
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

  # Home Manager is pretty good at managing dotfiles. The primary way to manage plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/iqbalsonata/etc/profile.d/hm-session-vars.sh
  # home.sessionVariables = {
    # EDITOR = "emacs";
  #};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Starship
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      format = "[$symbol$version]($style)[$directory]($style)[$git_branch]($style)[$git_commit]($style)[$git_state]($style)[$git_status]($style)[$line_break]($style)[$username]($style)[$hostname]($style)[$shlvl]($style)[$jobs]($style)[$time]($style)[$status]($style)[$character]($style)";
      line_break.disabled = true;
      cmd_duration.disabled = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✖](bold red)";
        vicmd_symbol = "[❮](bold yellow)";
      };
      package.disabled = true;
    };
  };

  # Neovim 
  programs.neovim = {
      enable =  true;
      plugins =
      let 
       pluginGit = owner: repo: rev: sha256: pkgs.vimUtils.buildVimPlugin {
        pname = repo;
        version = rev;
        src = pkgs.fetchFromGitHub {
          owner = owner;
          repo = repo;
          rev = rev;
          sha256 = sha256;
        };
       };

       keymapConfig = pkgs.vimUtils.buildVimPlugin {
        name = "keymap-config";
        src = ../config/nvim/keymapconfig;
       };       

	     config = pkgs.vimUtils.buildVimPlugin {
	      name = "config";
	      src = ../config/nvim/config;
	     };
     in
     with pkgs.vimPlugins; [
       playground
       cmp-nvim-lsp
       nvim-cmp
       cmp-buffer
       luasnip
       lspkind-nvim
       null-ls-nvim
       markdown-preview-nvim
       nvim-jdtls
       dressing-nvim
       nvim-notify
       nvim-dap-ui
       nvim-dap-virtual-text
       telescope-dap-nvim
       nvim-dap-go
       nvim-web-devicons
       nvim-lspconfig
       plenary-nvim
       popup-nvim
       toggleterm-nvim
       vim-move
       vim-visual-multi
       vim-surround
        {
          plugin = config;
          type = "lua";
          config = builtins.readFile ../config/nvim/config.lua;
        }
        {
          plugin = keymapConfig;
          type = "lua";
          config = builtins.readFile ../config/nvim/keymap.lua;
        }
        {
          plugin = dracula-vim;
          type= "lua";
          config = builtins.readFile ../config/nvim/color.lua;
        }
        {
          plugin = (pluginGit "stevearc" "profile.nvim" "master" "sha256-dRHidtV/M+i/5CkeaJBQ2BMuISmnrAIqm34x7YBkSNU=" );
          type = "lua";
          config = builtins.readFile ../config/nvim/profile.lua;
        }
        {
          plugin = (pluginGit "ThePrimeagen" "harpoon" "harpoon2" "RjwNUuKQpLkRBX3F9o25Vqvpu3Ah1TCFQ5Dk4jXhsbI=" );
          type = "lua";
          config = builtins.readFile ../config/nvim/harpoon.lua;
        }

        {
      	plugin = (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars ++ [
	      nvim-treesitter-parsers.wgsl
	      nvim-treesitter-parsers.astro
	    ]
	    ));
      	type = "lua";
	      config = builtins.readFile ../config/nvim/treesitter.lua;
      }
      {
      	plugin = nvim-lspconfig;
	      type = "lua";
	      config = builtins.readFile ../config/nvim/lsp.lua;
      }
      {
        plugin = (pluginGit "lvimuser" "lsp-inlayhints.nvim" "master" "0fx0swsagjdng9m9x73wkfqnk464qk63q9wi32rhywllbm7gsflf");
        type = "lua";
      }

      {
        plugin = (pluginGit "ray-x" "go.nvim" "master" "z65o3cOoxWILDKjEUWNTK1X7riQjxAS7BGeo29049Ms=");
        type = "lua";
      }
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = builtins.readFile ../config/nvim/autopairs.lua;
      }
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/indentline.lua;
      }
      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = ''
          -- nvim-colorizer
          require("colorizer").setup()
        '';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/telescope.lua;
      }
      
      {
        plugin = nvim-dap;
        type = "lua";
        config = builtins.readFile ../config/nvim/dap.lua;
      }
      
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile ../config/nvim/filetree.lua;
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/lualine.lua;
      }
      {
        plugin = (pluginGit "numToStr" "Comment.nvim" "master" "h0kPue5Eqd5aeu4VoLH45pF0DmWWo1d8SnLICSQ63zc=");
        type = "lua";
      }
      {
        plugin = toggleterm-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/toggleterm.lua;
      }
      {
        plugin = nvim-spectre;
        type = "lua";
        config = builtins.readFile ../config/nvim/spectre.lua;
      }
    ];
  };

  
  programs.fish  = {
    enable = true;
    shellAbbrs = {
      ls = "eza -l";
      vim = "nvim";
    };
    functions = {
      fish_indent = "";
    };
  };

}
