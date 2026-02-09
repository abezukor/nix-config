{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [ slack moonlight-qt ];

    file = {
      ".config/mdk/mdk.json" = {
        text = ''
          {
              "options": [
                  "--tmpfs",
                  "/tmp:rw,nosuid,nodev,exec,size=64g,mode=777"
              ],
              "environment": [
                  "ZDOTDIR=/home/maticd/mdk_shared/zshdotdir"
              ],
              "volumes": [
                  "/var/cache/home/maticd/.cache:/home/maticd/.cache",
                  "~/mdk_shared:/home/maticd/mdk_shared",
                  "~/.ssh:/home/maticd/.ssh"
              ]
          }
        '';
      };
    };

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "25.05";
  };
  nixpkgs.config.allowUnfree = true;

  programs.ssh.matchBlocks = {
    "*" = {
      extraOptions = {
        StrictHostKeyChecking = "no";
      };
    };
    "matic-* fuji-*" = {
      user = "root";
    };
    "zeus ci* bigloo" = {
      user = "admin";
    };
  };
}
