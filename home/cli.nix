{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      zsh
      git
      htop
      eza
      nixd
      nixfmt
    ];

    username = "abe";
    homeDirectory = "/home/abe";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "25.05";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza -lh";
      rsyncf = "rsync -zhPLa";
      # Nix Aliases
      nfu = "sudo nixos-rebuild --flake /etc/nixos switch";
      hmfu = "home-manager switch --flake ~/.config/home-manager#$(hostname)";
    };
    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };
  };

  programs.mergiraf.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
        serverAliveInterval = 3;
        hashKnownHosts = false;
      };
    };
  };
  services.ssh-agent.enable = true;
}
