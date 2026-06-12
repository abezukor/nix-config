{
  config,
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
      # Run Zed's Codex ACP adapter natively on NixOS (avoid Zed-downloaded dynamic binaries).
      pkgs-unstable.starpls
      pkgs-unstable.package-version-server
      # needed for claude code in zed
      pkgs-unstable.nodejs_22
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
