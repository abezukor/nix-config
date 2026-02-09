# to /etc/nixos/configuration.nix instead.
{
  ...
}:

{
  systemd.network.networks."21-debug-dongle" = {
    matchConfig.Property = "TAGS=*matic_debug_dongle*";
    networkConfig = {
      DHCP = "no";
      LinkLocalAddressing = "yes";
    };
    linkConfig.RequiredForOnline = "no";
  };
  programs.adb.enable = true;
}
