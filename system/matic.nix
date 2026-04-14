# to /etc/nixos/configuration.nix instead.
{
  ...
}:

{
  systemd.network.networks."21-debug-dongle" = {
    matchConfig.Property = "TAGS=*matic_*";
    networkConfig = {
      DHCP = "no";
      LinkLocalAddressing = "yes";
    };
    linkConfig.RequiredForOnline = "no";
  };
  programs.adb.enable = true;
}
