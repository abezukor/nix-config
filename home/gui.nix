{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  starplsPath = "${pkgs-unstable.starpls}/bin/starpls";
  # Wrap LibreOffice to always launch with the Light GTK theme
  # Dark theme libreoffice seems to break the buttons
  libreoffice-light = pkgs.symlinkJoin {
    name = "libreoffice-light";
    paths = [ pkgs.libreoffice ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/libreoffice \
        --set SAL_USE_VCLPLUGIN gtk3 \
        --set GTK_THEME Adwaita:light \
        --set GDK_BACKEND x11
    '';
  };
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
      libreoffice-light
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
