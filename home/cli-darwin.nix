{ pkgs, ... }:
{
  home.packages = [ pkgs.home-manager ];

  # Darwin-only pieces of the shared CLI environment. Imported alongside
  # cli.nix on Darwin hosts; omitted on Linux where Homebrew doesn't apply.

  programs.zsh.profileExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  '';

  programs.zsh.shellAliases = {
    hmfu = "home-manager switch --flake ~/.config/home-manager#$(scutil --get LocalHostName | cut -d. -f1)-$USER";
  };
}
