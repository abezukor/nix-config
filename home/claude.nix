{ pkgs-unstable, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;
    memory.text = ''
      # Environment

      This machine runs **NixOS**. Most tools are not installed globally on
      `PATH` — they are exposed through `nix-shell` or `nix run` instead.

      ## When a command is not found

      Do not assume the tool is unavailable. Try:

      - `nix-shell -p <pkg> --run '<cmd>'` — one-shot ephemeral shell
      - `nix run nixpkgs#<pkg> -- <args>` — flakes equivalent

      The user's NixOS / home-manager config lives in `~/abe-nix/`. If a
      tool should be permanently available, add it to the appropriate
      module there rather than installing it imperatively.

      Never suggest `apt`, `brew`, `pip install --user`, or other non-Nix
      package managers to resolve missing commands on this system.
    '';
  };
  programs.zed-editor.userSettings.agent_servers.claude = { };
}
