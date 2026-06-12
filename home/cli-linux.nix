{ pkgs, ... }:
{
  programs.zsh.shellAliases = {
    hmfu = "home-manager switch --flake ~/.config/home-manager#$(hostname)-$USER";
  };

  # Linux-only pieces of the shared CLI environment. Imported alongside
  # cli.nix on Linux hosts; omitted on Darwin where these don't build/apply.
  home.packages = with pkgs; [
    usbutils
  ];

  # systemd user service — Linux only. On macOS the launchd-provided agent
  # (via SSH_AUTH_SOCK) is used instead.
  services.ssh-agent.enable = true;
}
