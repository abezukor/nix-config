{ pkgs, ... }: {
  home = {
    packages = with pkgs; [ slack ];

    file = {
      ".config/mdk/mdk.json" = {
        text = ''
          {
              "environment": [
                  "HISTFILE=/home/maticd/mdk_shared/bash_history"
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
}
