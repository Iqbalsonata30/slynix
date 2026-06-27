{
  description = "Home Manager configuration of iqbalsonata";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sketchybar-app-font = {
      url = "github:kvndrsslr/sketchybar-app-font";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    homeConfigurations."iqbalsonata" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit inputs;
      };

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [
        ./config/home/home.nix
        inputs.nixvim.homeModules.nixvim
      ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };
  };
}
