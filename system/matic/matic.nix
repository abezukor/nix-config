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
  services.udev.packages = [
    maticUdevRules
    # ST-LINK access for flashing kovel with probe-rs. Named *probe-rs* so probe-rs
    # stops warning about missing rules, and ordered before 73-seat-late so uaccess applies.
    (pkgs.writeTextDir "lib/udev/rules.d/69-probe-rs.rules" ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="37[0-9a-f][0-9a-f]", MODE="0660", TAG+="uaccess"
    '')
  ];

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
