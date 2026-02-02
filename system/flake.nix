{
  description = "Abe's NixOs Flakes";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };
  };

  outputs =
    { self, nixpkgs, ... }:
    {
      nixosConfigurations = {
        abeMaticDesktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            ./nvidia.nix
            ./matic.nix
          ];
        };
      };
    };
}
