# flake.nix
{
  description = "My Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    {
      homeConfigurations = {
        abe = let 
          currentSystem = import ../arch.nix;
        in
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${currentSystem};
            modules = [ ./home.nix ];
          };
      };
    };
}
