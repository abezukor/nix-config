{ pkgs, ... }: {
  home = {
    packages = with pkgs; [ zsh git htop eza nixd nixfmt ];

    username = "abe";
    homeDirectory = "/home/abe";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "25.05";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza -lh";
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
}
