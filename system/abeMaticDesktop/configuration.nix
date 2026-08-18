# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.canTouchEfiVariables = true;
  };

  # Use latest kernel.
  # Nvidia drivers did not work with latest kernel, so switching to lts
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.systemd = {
    enable = true;
    # Override the cryptsetup service to add timeout and auto-poweroff
    services."systemd-cryptsetup@" = {
      overrideStrategy = "asDropin";
      serviceConfig.TimeoutSec = 300; # 5 minutes
      unitConfig.FailureAction = "poweroff-force";
    };
  };

  # Let the kernel redistribute PCI bridge windows rather than trusting the
  # BIOS layout. Needed for the FPGA card that gets dynamicially reprogrammed and needs BAR.
  #
  # amd_iommu=on and iommu=pt enable the IOMMU, which vfio-pci needs in order to
  # bind a device: without it /sys/kernel/iommu_groups is empty and there are no
  # groups to claim. Required for driving the FPGA endpoint's DMA from userspace
  # instead of writing a kernel driver. iommu=pt puts everything except assigned
  # devices in passthrough, so host devices keep native DMA performance and only
  # the assigned device pays for address translation.
  #
  # These have no effect unless the IOMMU is also enabled in the BIOS -- on this
  # board that is "IOMMU" and/or "SVM" under advanced CPU settings. Check with
  #   ls /sys/kernel/iommu_groups | wc -l
  # after rebooting; a count of 0 means the firmware side is still off.
  # pci=nocrs makes the kernel ignore the ACPI _CRS host-bridge windows and
  # allocate from the full address space itself. Without it the FPGA's domain
  # gets whatever firmware provisioned at POST, and firmware sizes that from
  # what it found in the slot: after any boot where the FPGA was unconfigured or
  # running the SPI flash demo (which has no BARs), domain c0 came up with only
  #   root bus resource [mem 0xf3300000-0xf34fffff window]   -- 2 MB
  # entirely consumed by two AMD internal bridges. The endpoint's 64 KB BAR then
  # cannot be assigned at runtime:
  #   bridge window [mem size 0x00100000]: can't assign; no space
  # and pci=realloc does not help, because it redistributes within the aperture
  # rather than growing it. A root-bus aperture cannot be resized after POST, so
  # the only alternatives were a reboot with the FPGA already live, or this.
  #
  # The BAR is 32-bit non-prefetchable and the IP offers no 64-bit option (the
  # checkbox is greyed out in every configuration mode), so it cannot be moved
  # into the domain's large above-4G window instead.
  #
  # Revert by pressing 'e' at the systemd-boot menu and deleting the parameter if
  # devices misbehave -- nocrs can allocate over regions firmware reserved but
  # did not describe in _CRS.
  # pci=nocrs was tried here and MUST NOT be re-added. It does enlarge the
  # aperture -- the kernel reports [mem 0x0-0x7ffffffffff] for every domain and
  # BAR allocation then succeeds -- but the addresses it picks are not routable.
  # Firmware's real per-domain routing on this board is:
  #     domain 00  0xf3500000-0xf39fffff
  #     domain 40  0xf0000000-0xf12fffff
  #     domain 80  0xb0000000-0xce7fffff
  #     domain c0  0xf3300000-0xf34fffff
  # With _CRS ignored the kernel gave the FPGA (domain c0) a BAR at 0xc2100000,
  # which is inside domain 80's range. The device enumerates, configuration space
  # answers over ECAM, the link trains to Gen2 -- and every BAR read returns
  # 0xffffffff, because the access is routed to a different root complex. That
  # looks exactly like a broken FPGA and is not.
  boot.kernelParams = [
    "pci=realloc"
    "amd_iommu=on"
    "iommu=pt"
  ];

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "weekly";
  };

  networking.hostName = "abeMaticDesktop";
  systemd.network.enable = true;
  networking.useDHCP = false;

  # The physical NIC is enslaved to br0 rather than addressed directly, so that
  # VMs attached to br0 in virt-manager land on the LAN as first-class hosts and
  # get their own DHCP lease from the network's server. The host keeps its own
  # DHCP address, but on the bridge instead of the NIC.
  systemd.network.netdevs."10-br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
    # STP is off: there is a single uplink, so there is no loop to break, and
    # enabling it would add ~30s of listening/learning before traffic passes --
    # long enough for DHCP on boot (and on every VM start) to time out.
    bridgeConfig.STP = false;
  };

  # Port: no address of its own, just bound into the bridge.
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "enp66s0f1";
    networkConfig.Bridge = "br0";
    linkConfig.RequiredForOnline = "enslaved";
  };

  systemd.network.networks."20-br0" = {
    matchConfig.Name = "br0";
    networkConfig = {
      DHCP = "ipv4";
      UseDomains = true;
    };
    dhcpV4Config = {
      UseDNS = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  time.timeZone = "America/Los_Angeles";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.abe = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "libvirtd"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    #shell = pkgs.nushell;
  };

  fileSystems."/home/abe/.cache" = {
    device = "/var/cache/home/abe/.cache";
    fsType = "none";
    options = [ "bind" ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    home-manager
    wayland-utils
    wget
    smartmontools
  ];
  programs.zsh.enable = true;
  programs.virt-manager.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    #reflector = true;
  };

  services.resolved.settings.Resolve = {
    MulticastDNS = "no";
    ResolveUnicastSingleLabel = "yes";
  };

  services.openssh = {
    enable = true;
    settings = {
      AuthenticationMethods = "publickey";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  #networking.nftables.enable = true;

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true;
  };

  hardware.graphics.enable32Bit = true;
  virtualisation.docker.enableNvidia = true;
  hardware.nvidia-container-toolkit.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  # virtiofs shares (<filesystem><driver type="virtiofs"/>) are served by a
  # vhost-user daemon that libvirtd discovers via JSON descriptors under
  # /var/lib/qemu/vhost-user. Without this libvirtd starts the domain and fails
  # with "Unable to find a satisfying virtiofsd".
  virtualisation.libvirtd.qemu.vhostUserPackages = [ pkgs.virtiofsd ];
  #virtualisation.waydroid.enable = true;
  services.fwupd.enable = true;
  services.flatpak.enable = true;

  # Lattice on-board FT2232H JTAG programmer (CrossLink-NX PCIe Bridge Board and
  # HW-USBN-2B). Without this the device node is root:root 0664 and the Radiant
  # programmer cannot open it -- which it reports as "The FTDI Port is busy.
  # Device already in use by another application.", a misleading message for what
  # is a plain EACCES.
  #
  # Matches on vendor/product rather than USB port: the board does not keep a
  # stable port across resets.
  #
  # This only grants access to the node. ftdi_sio still claims both channels of
  # the FT2232H, and channel A (interface 00) has to be released before libusb
  # can drive JTAG:
  #   sudo sh -c 'echo -n <iface> > /sys/bus/usb/drivers/ftdi_sio/unbind'
  # Kept as a deliberate manual step so plugging the cable in does not silently
  # remove a serial port; CI2PCIE/scripts/jtag_setup.sh does it.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0666", TAG+="uaccess"
  '';
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
