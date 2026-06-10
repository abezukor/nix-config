# flake.nix
# Don't copy and paste this.  Read above first if you tried to cheat and skim.
{
  description = "My Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Build a Home Manager configuration for a specific host + user.
      # Keyed as "${host}-${user}" so multiple users can coexist on the same machine.
      mkHome =
        {
          host,
          user,
          modules,
          homeDirectory ? "/home/${user}",
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              pkgs-unstable
              host
              user
              homeDirectory
              ;
          };
          inherit modules;
        };
    in
    {
      homeConfigurations = {
        # Example: use `home-manager switch --flake ~/.config/home-manager#$(hostname)-$USER`
        abeMaticDesktop-abe = mkHome {
          host = "abeMaticDesktop";
          user = "abe";
          modules = [
            ./cli.nix
            ./gui.nix
            ./work.nix
            ./claude.nix
          ];
        };

        abeDesktop-abe = mkHome {
          host = "abeDesktop";
          user = "abe";
          modules = [
            ./cli.nix
            ./gui.nix
            ./codex.nix
          ];
        };
        abeDesktop-abematic = mkHome {
          host = "abeDesktop";
          user = "abematic";
          modules = [
            ./cli.nix
            ./gui.nix
            ./work.nix
            ./claude.nix
          ];
        };
      };
    };
}
