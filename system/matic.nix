# to /etc/nixos/configuration.nix instead.
{
  ...
}:

{
  services.udev.extraRules =
    builtins.readFile ./60-matic-debug-conn.rules
    + builtins.readFile ./61-matic-parallel-flash.rules;

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
