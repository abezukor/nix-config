{ lib, pkgs, pkgs-unstable, ... }:
{
  home = {
    # Tell the Zed-bundled claude-agent-sdk to use the Nix-installed claude
    # binary instead of its own dynamically-linked one (which can't run on NixOS).
    sessionVariables.CLAUDE_CODE_EXECUTABLE = lib.getExe pkgs-unstable.claude-code;

    packages = [
      # Image paste (ctrl+v) in the Claude Code CLI shells out to wl-paste to
      # read image data off the clipboard.
      pkgs.wl-clipboard
      # Claude needs bwrap for its sandbox to work
      pkgs.bubblewrap
    ];
  };
  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;
    context = ./nixos-instructions.md;
  };
  programs.zed-editor.userSettings.agent_servers.claude = { };

}
