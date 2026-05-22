{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  starplsPath = "${pkgs-unstable.starpls}/bin/starpls";
  toml = pkgs.formats.toml { };
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
      # Run Zed's Codex ACP adapter natively on NixOS (avoid Zed-downloaded dynamic binaries).
      pkgs.codex-acp
      pkgs-unstable.starpls
      pkgs-unstable.package-version-server
      # needed for claude code in zed
      pkgs-unstable.nodejs_22
      pkgs-unstable.qdirstat
      # For Libreoffice
      libreoffice-light
      pkgs.hunspell
      pkgs.hunspellDicts.en_US-large
    ];

    # Tell the Zed-bundled claude-agent-sdk to use the Nix-installed claude
    # binary instead of its own dynamically-linked one (which can't run on NixOS).
    sessionVariables.CLAUDE_CODE_EXECUTABLE = lib.getExe pkgs-unstable.claude-code;

    file = {
      ".codex/config.toml".source = toml.generate "codex-config.toml" {
        approval_policy = "on-request";
        sandbox_mode = "danger-full-access";
      };
    };

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

      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
      };

      agent_servers = {
        claude = { };
        "codex-acp" = {
          type = "custom";
          command = lib.getExe pkgs.codex-acp;
          args = [ ];
          default_model = "gpt-5.2";
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
