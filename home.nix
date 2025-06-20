{ lib, pkgs, ... }:
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

    # This needs to actually be set to your username
    username = "abe";
    homeDirectory = "/home/abe";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "24.11";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ls = "eza -lh";
    };
    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };
  };

}
