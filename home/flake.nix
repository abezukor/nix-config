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
      mkPkgs = system: import nixpkgs { inherit system; };
      mkPkgsUnstable =
        system:
        import nixpkgs-unstable {
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
          system ? "x86_64-linux",
          homeDirectory ? null,
        }:
        let
          pkgs = mkPkgs system;
          pkgs-unstable = mkPkgsUnstable system;
          homeDir =
            if homeDirectory != null then
              homeDirectory
            else if pkgs.stdenv.isDarwin then
              "/Users/${user}"
            else
              "/home/${user}";
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              pkgs-unstable
              host
              user
              ;
            homeDirectory = homeDir;
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
            ./cli-linux.nix
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
            ./cli-linux.nix
            ./gui.nix
            ./codex.nix
          ];
        };
        abeDesktop-abematic = mkHome {
          host = "abeDesktop";
          user = "abematic";
          modules = [
            ./cli.nix
            ./cli-linux.nix
            ./gui.nix
            ./work.nix
            ./claude.nix
          ];
        };

        # Mac mini (Apple Silicon) — standalone Home Manager, no Linux modules.
        PlatformTeamMini-abe = mkHome {
          host = "PlatformTeamMini";
          user = "abe";
          system = "aarch64-darwin";
          modules = [
            ./cli.nix
            ./work.nix
            ./claude.nix
          ];
        };
      };
    };
}
