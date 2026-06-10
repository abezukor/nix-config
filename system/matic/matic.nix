# to /etc/nixos/configuration.nix instead.
{
  pkgs,
  ...
}:

let
  maticUdevRules = pkgs.runCommand "matic-udev-rules" { } ''
    mkdir -p $out/etc/udev/rules.d
    cp ${./60-matic-debug-conn.rules} $out/etc/udev/rules.d/60-matic-debug-conn.rules
    cp ${./61-matic-parallel-flash.rules} $out/etc/udev/rules.d/61-matic-parallel-flash.rules
  '';
in
{
  services.udev.packages = [ maticUdevRules ];

  systemd.network.networks."21-debug-dongle" = {
    matchConfig.Property = "TAGS=*matic_*";
    networkConfig = {
      DHCP = "no";
      LinkLocalAddressing = "yes";
    };
    linkConfig.RequiredForOnline = "no";
  };
  environment.systemPackages = [ pkgs.android-tools ];
}
