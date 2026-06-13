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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "abeDesktop";

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  users.users = {
    abe = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.zsh;
    };
    abematic = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
        "libvirtd"
        "adbusers"
      ]; # Enable ‘sudo’ for the user.
      shell = pkgs.zsh;
      home = "/home/abematic";
      createHome = true;
    };
  };

  environment.systemPackages = with pkgs; [
    home-manager
    wayland-utils
    wget
  ];

  programs.zsh.enable = true;

  programs.steam = {
    enable = true;
  };

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  hardware.nvidia = {
    open = false;
    powerManagement.enable = true;
    modesetting.enable = true;

    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services.tailscale.enable = true;

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
  system.stateVersion = "25.11"; # Did you read the comment?

}
