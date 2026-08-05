{
  config,
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

  # Firefox 153 has a Wayland rendering regression (Mozilla bug 2049922)
  # which can make browser chrome text disappear. The desktop file launches
  # Firefox by name, so this higher-priority wrapper covers both application
  # launches and terminal launches without changing the backend for other apps.
  firefox-x11 = lib.hiPrio (
    pkgs.writeShellScriptBin "firefox" ''
      exec env GDK_BACKEND=x11 ${config.programs.firefox.finalPackage}/bin/firefox "$@"
    ''
  );
in
{
  home = {
    packages = [
      firefox-x11
      # For Zed
      # Run Zed's Codex ACP adapter natively on NixOS (avoid Zed-downloaded dynamic binaries).
      pkgs-unstable.starpls
      pkgs-unstable.package-version-server
      # needed for claude code in zed
      pkgs-unstable.nodejs_22
      pkgs-unstable.qdirstat
      # For Libreoffice
      libreoffice-light
      pkgs.hunspell
      pkgs.hunspellDicts.en_US-large
      # Image paste (ctrl+v) in the Claude Code CLI shells out to wl-paste to
      # read image data off the clipboard.
      pkgs.wl-clipboard
    ];

    # Tell the Zed-bundled claude-agent-sdk to use the Nix-installed claude
    # binary instead of its own dynamically-linked one (which can't run on NixOS).
    sessionVariables.CLAUDE_CODE_EXECUTABLE = lib.getExe pkgs-unstable.claude-code;

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "25.05";
  };

  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
  };

  services.flatpak = {
    enable = true;
    packages = [
      rec {
        appId = "org.adi.Scopy";
        sha256 = "sha256-2b+tFmMErkoXbxiqi/sToxuDMi4SSM6Qhim1AEUT568=";
        bundle = "${pkgs.fetchurl {
          url = "https://github.com/analogdevicesinc/scopy/releases/download/v2.2.1/Scopy-v2.2.1-Linux-x86_64.flatpak";
          inherit sha256;
        }}";
      }
    ];
  };

  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;

    userSettings = {
      soft_wrap = "editor_width";

      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
      };

      lsp = {
        starpls = {
          binary = {
            path = starplsPath;
          };
        };
        "rust-analyzer" = {
          initialization_options = {
            check = {
              command = "clippy";
            };
          };
        };
      };

      node = {
        path = lib.getExe pkgs-unstable.nodejs_22;
        npm_path = lib.getExe' pkgs-unstable.nodejs_22 "npm";
      };
    };
  };
}
