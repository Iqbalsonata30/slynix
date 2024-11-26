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

    flake-parts.url = "github:hercules-ci/flake-parts";

  };

  outputs = { self,nixpkgs,... }@inputs:
    let 
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      lib = nixpkgs.lib;
    in { 
      inputs.pkgs = pkgs;

      nixOsConfiguration = {
        iqbalsonata = lib.nixosSystem{
          inherit system;

          modules = [
            ./hardware-configuration.nix
          ];
        };
      };

    };
      

}
