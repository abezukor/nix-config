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
    packages = [ pkgs-unstable.codex-acp ];
    file = {
      ".codex/config.toml".source = toml.generate "codex-config.toml" {
        approval_policy = "on-request";
        sandbox_mode = "danger-full-access";
      };
    };
  };
  programs.zed-editor.userSettings.agent_servers."codex-acp" = {
    type = "custom";
    command = lib.getExe pkgs.codex-acp;
    args = [ ];
    default_model = "gpt-5.2";
  };
}
