{
  description = "Abe's NixOs Flakes";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      # A simple reusable module to allow unfree packages
      allowUnfreeModule = {
        nixpkgs.config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        abeMaticDesktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            allowUnfreeModule
            ./abeMaticDesktop/configuration.nix
            ./matic/matic.nix
            ./gui.nix
          ];
        };
        abeDesktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            allowUnfreeModule
            ./abe_desktop/configuration.nix
            ./gui.nix
          ];
        };
      };
    };
}
