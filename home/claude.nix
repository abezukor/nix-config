{ pkgs-unstable, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;
    context = ''
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

      ## Devshells

      Prefer a project's own devshell over ad-hoc `nix-shell -p`. Before
      concluding a command is missing, check the project root for
      `flake.nix`, `shell.nix`, or `.envrc`.

      If `.envrc` exists, the shell is cached by direnv — but the direnv
      hook does not fire in non-interactive shells, so run commands as:

      - `direnv exec . <cmd>` — run inside the cached devshell
      - `nix develop -c <cmd>` — if there is a `flake.nix` but no `.envrc`

      Fall back to `nix-shell -p <pkg>` only when the tool does not belong
      to the project.
    '';
  };
  programs.zed-editor.userSettings.agent_servers.claude = { };
}
