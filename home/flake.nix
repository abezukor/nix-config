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

    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.7.0";
    kache.url = "github:kunobi-ninja/kache/stable";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      kache,
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
            kachePackage = kache.packages.${system}.default;
            inherit
              pkgs-unstable
              host
              user
              homeDirectory
              ;
          };
          modules = [ nix-flatpak.homeManagerModules.nix-flatpak ] ++ modules;
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
            ./llm/claude.nix
            ./llm/codex.nix
            ./llm/t3code.nix
          ];
        };

        abeDesktop-abe = mkHome {
          host = "abeDesktop";
          user = "abe";
          modules = [
            ./cli.nix
            ./gui.nix
            ./llm/codex.nix
          ];
        };
        abeDesktop-abematic = mkHome {
          host = "abeDesktop";
          user = "abematic";
          modules = [
            ./cli.nix
            ./gui.nix
            ./work.nix
            ./llm/claude.nix
          ];
        };
      };
    };
}
