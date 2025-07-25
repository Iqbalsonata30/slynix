# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "iqbalsonata-nixos"; # Define your hostname.
  networking.extraHosts = "192.168.49.2 nginx.iqbalsonata.local";
  # networking.resolvconf.enable = true;
  # networking.firewall.allowedTCPPorts = [22 80];
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  #networking.proxy.default = "http://user:password@proxy:port/";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Enable networking
  networking.networkmanager.enable = true;
  networking.nameservers = ["10.24.252.1"];

  #  networking = {
  #  interfaces.wlp1s0 = {
  #    ipv4.addresses = [
  #      {
  #        address = "10.24.252.3";
  #        prefixLength = 24;
  #      }
  #    ];
  #  };
  #  defaultGateway = {
  #    address = "10.24.252.3";
  #    interface = "wlp1s0";
  #  };
  #};

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_IDENTIFICATION = "id_ID.UTF-8";
    LC_MEASUREMENT = "id_ID.UTF-8";
    LC_ADDRESS = "id_ID.UTF-8";
    LC_MONETARY = "id_ID.UTF-8";
    LC_NAME = "id_ID.UTF-8";
    LC_NUMERIC = "id_ID.UTF-8";
    LC_PAPER = "id_ID.UTF-8";
    LC_TELEPHONE = "id_ID.UTF-8";
    LC_TIME = "id_ID.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable docker daemon
  virtualisation.docker.enable = true;
  virtualisation.docker.liveRestore = false;

  # libvirtd
  virtualisation.libvirtd.enable = true;
  users.extraGroups.libvirtd.members  = ["iqbalsonata"];

  # Enable the Pantheon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.pantheon.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Virtual Box
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["iqbalsonata"];

  # Automatic Garbage collection
  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 30d";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pulseaudio.
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.iqbalsonata = {
    isNormalUser = true;
    description = "Iqbal Sonata";
    extraGroups = ["networkmanager" "wheel" "docker" "vboxusers"];
    shell = pkgs.fish;
    packages = with pkgs; [
      gcc
      #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    pantheon-tweaks
    xorg.libxshmfence
  ];

  #$ nix search wget

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs = {
    fish = {
      enable = true;
    };
  };

  fonts = {
    fontDir.enable = true;
  };
  # fonts.packages = with pkgs; [
  #   noto-fonts
  #   liberation_ttf
  #   noto-fonts-emoji
  #   fira-code
  #   fira-code-symbols
  #   nerd-fonts
  #   dina-font
  #   proggyfonts
  #  ];

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable the Jenkins
  # services.jenkins = {
  #   enable = true;
  # };

  # Enable the nginx
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
}
