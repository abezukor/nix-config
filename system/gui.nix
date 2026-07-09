# to /etc/nixos/configuration.nix instead.
{
  pkgs,
  ...
}:
{
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm.enable = true;

  services.displayManager.sddm.wayland.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  programs.kdeconnect.enable = true;
}
