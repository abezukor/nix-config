{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  starplsPath = "${pkgs-unstable.starpls}/bin/starpls";
in
{
  home = {
    packages = [
      # For Zed
      pkgs-unstable.starpls
      pkgs-unstable.package-version-server
      # needed for claude code in zed
      pkgs-unstable.nodejs_24
      pkgs-unstable.qdirstat
      pkgs.libreoffice
    ];

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "25.05";
  };

  programs.firefox = {
    enable = true;
  };

  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;

    userSettings = {
      soft_wrap = "editor_width";

      lsp = {
        starpls = {
          binary = {
            path = starplsPath;
          };
        };
      };

      node = {
        path = lib.getExe pkgs-unstable.nodejs_24;
        npm_path = lib.getExe' pkgs-unstable.nodejs_24 "npm";
      };
    };
  };
}
