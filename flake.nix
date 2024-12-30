{
  description = "slyfox's nix configuration";

  inputs = {
    nixpkgs-master.url = "github:NixOs/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";

    sketchybar-app-font = {
      url = "github:kvndrsslr/sketchybar-app-font";
      flake = false;
    };

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.home-manager.follows = "home-manager";

    ts-rescript = {
      url = "github:nkrkv/tree-sitter-rescript";
      flake = false;
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ghostty,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      iqbalsonata = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        system = "x86_64-linux";
        modules = [
          {
            environment.systemPackages = [
              ghostty.packages.x86_64-linux.default
            ];
          }
          ./myconf/hosts
        ];
      };
    };

    homeConfigurations = {
      "nixos@iqbalsonata" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {
          inherit inputs outputs;
          hostname = "iqbalsonata";
        };
        modules = [
          ./myconf/home/default.nix
          inputs.nixvim.homeManagerModules.nixvim
        ];
      };
    };
  };
}
