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
      # Image paste (ctrl+v) in the Claude Code CLI shells out to wl-paste to
      # read image data off the clipboard.
      pkgs.wl-clipboard
      # Codex really seems to expect ripgrep to be available
      pkgs.ripgrep
    ];
  };
  programs.codex = {
    enable = true;
    package = pkgs-unstable.codex;
    context = ./nixos-instructions.md;
  };
  programs.zed-editor.userSettings.agent_servers."codex-acp" = {
    type = "custom";
    command = lib.getExe pkgs.codex-acp;
    args = [ ];
    default_model = "gpt-5.6-sol";
  };
}
