{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  toml = pkgs.formats.toml { };
in
{
  home = {
    packages = [
      pkgs-unstable.codex-acp
      pkgs-unstable.codex
    ];
  };
  programs.zed-editor.userSettings.agent_servers."codex-acp" = {
    type = "custom";
    command = lib.getExe pkgs.codex-acp;
    args = [ ];
    default_model = "gpt-5.5";
  };
}
