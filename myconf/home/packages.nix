{pkgs, ...}: {
  home.packages = with pkgs; [
    bat
    nodejs
    gdb
    lldb
    yarn
    clang
    fira-code
    nerd-fonts.fira-code
    fira-code-symbols
    liberation_ttf
    noto-fonts
    noto-fonts-color-emoji
    file
    proggyfonts
    teams-for-linux
    openboard
    nodePackages_latest.prettier
    papirus-icon-theme
    sqlite
    multimarkdown
    vimPlugins.nvim-treesitter-parsers.markdown
    clang-tools
    dbeaver-bin
    vimPlugins.null-ls-nvim
    gnumake
    gopls
    php83
    sqls
    nodePackages_latest."@tailwindcss/language-server"
    nodePackages_latest."diagnostic-languageserver"
    nodePackages_latest.typescript-language-server
    vimPlugins.nvim-treesitter-parsers.typescript
    nodePackages.vscode-langservers-extracted
    vimPlugins.nvim-treesitter-parsers.angular
    bash-language-server
    flatpak
    tflint
    google-cloud-sdk
    terraform
    wireshark
    gofumpt
    stylua
    gotools
    google-chrome
    docker-compose
    ripgrep
    firefox
    discord
    spotify
    ulauncher
    libreoffice
    drawio
    go
    ccls
    lld
    zls
    zig
    docker
    man
    typescript
    man-pages
    wget
    neofetch
    eza
    htop
    glibc
    fragments
    xclip
  ];
}
