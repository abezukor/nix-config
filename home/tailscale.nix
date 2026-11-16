{
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      tailscale-systray
    ];
  };
  programs.zsh.shellAliases = {
    tailscale = "sudo tailscale";
  };
  systemd.user.services.tailscale-systray = {
    Unit = {
      Description = "Tailscale System Tray";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.tailscale}/bin/tailscale systray";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
