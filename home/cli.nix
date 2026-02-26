{ pkgs, pkgs-unstable, config, ... }:
{
  home = {
    packages = with pkgs; [
      zsh
      git
      htop
      eza
      nixd
      nixfmt
      tmux
      bat
      eza
      tio
      xxd
      usbutils
      pkgs-unstable.claude-code
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
    enableNushellIntegration = false;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      rsyncf = "rsync -zhPLa";
      # Nix Aliases
      nfu = "sudo nixos-rebuild --flake /etc/nixos switch";
      hmfu = "home-manager switch --flake ~/.config/home-manager#$(hostname)";
      cat = "bat";
      ls = "eza -lh";
    };
    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };
  };

  programs.nushell = {
    enable = false;
    shellAliases = {
      rsyncf = "rsync -zhPLa";
      nfu = "sudo nixos-rebuild --flake /etc/nixos switch";
      cat = "bat";
    };
    extraConfig = ''
      def hmfu [] { home-manager switch --flake $"($env.HOME)/.config/home-manager#(hostname)" }

      # Parse AWS credentials from text and set environment variables
      def --env aws-creds [...text: string] {
        let input = ($text | str join " ")
        let lines = ($input | lines | where {|it| ($it | str starts-with "aws_") and ($it | str contains "=")})

        for line in $lines {
          let parts = ($line | split row "=")
          if ($parts | length) >= 2 {
            let key = ($parts | get 0 | str trim)
            let value = ($parts | get 1 | str trim)

            if $key == "aws_access_key_id" {
              $env.AWS_ACCESS_KEY_ID = $value
            } else if $key == "aws_secret_access_key" {
              $env.AWS_SECRET_ACCESS_KEY = $value
            } else if $key == "aws_session_token" {
              $env.AWS_SESSION_TOKEN = $value
            }
          }
        }

        print "AWS credentials set"
        if "AWS_ACCESS_KEY_ID" in $env {
          print $"AWS_ACCESS_KEY_ID: ($env.AWS_ACCESS_KEY_ID)"
        }
      }

      $env.config.show_banner = false
      $env.config.completions.external.enable = true
      $env.config.completions.algorithm = "fuzzy"
    '';
  };

  programs.starship = {
    enable = config.programs.nushell.enable;
    enableNushellIntegration = true;
    settings = {
      git_branch.format = "[$symbol$branch]($style) ";
      git_status.format = "[$all_status$ahead_behind]($style) ";
    };
  };

  programs.htop.settings = {
    hide_kernel_threads = true;
    hide_userland_threads = true;
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
