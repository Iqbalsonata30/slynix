{
  description = "Pinned native Linux build environment for Slyvest";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/e7439b6b14ad3cc35d05608ebca9bce01a25f5f8";
  outputs = { nixpkgs, ... }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = with pkgs; [ cargo rustc rustfmt clippy stdenv.cc pkg-config bun nodejs_24 git python3 ];
    };
  };
}
