{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.programs.t3code;

  host = "127.0.0.1";
  port = 3773;

  # t3code spawns the coding-agent CLIs (claude, codex, ...) as child processes.
  # A systemd user unit gets a bare PATH, so hand it the same directories an
  # interactive login shell would see.
  servicePath = lib.concatStringsSep ":" [
    "${config.home.profileDirectory}/bin"
    "/run/wrappers/bin"
    "/etc/profiles/per-user/${config.home.username}/bin"
    "/run/current-system/sw/bin"
  ];
in
{
  programs.t3code = {
    enable = true;
    package = pkgs-unstable.t3code;
  };

  # Run the server headlessly so the web UI is always reachable at
  # http://127.0.0.1:3773; `t3code-desktop` remains available for the GUI.
  # Pairing details are printed to the journal: `journalctl --user -u t3code`.
  systemd.user.services.t3code = {
    Unit = {
      Description = "T3 Code server";
      Documentation = "https://t3.codes";
    };

    Service = {
      ExecStart = "${lib.getExe' cfg.package "t3"} serve --mode web --host ${host} --port ${toString port}";
      WorkingDirectory = config.home.homeDirectory;
      Environment = [ "PATH=${servicePath}" ];
      Restart = "on-failure";
      RestartSec = 5;
      # Agent tool calls crash routinely. RLIMIT_CORE=1 is a kernel special case
      # that skips the core_pattern pipe entirely, so these never reach
      # systemd-coredump and DrKonqi doesn't pop up a notification. (0 isn't
      # enough: systemd-coredump still logs the crash and DrKonqi still notifies.)
      LimitCORE = 1;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
