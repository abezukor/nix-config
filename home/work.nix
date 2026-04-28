{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [ slack ];

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
                  "/var/cache/bazel_output_user_root:/var/cache/bazel_output_user_root",
                  "~/.bazelrc:/home/maticd/.bazelrc",
                  "~/mdk_shared:/home/maticd/mdk_shared",
                  "~/.ssh:/home/maticd/.ssh"
              ]
          }
        '';
      };
      ".bazelrc" = {
        text = ''
          startup --output_user_root=/var/cache/bazel_output_user_root
        '';
      };
    };

    sessionVariables = {
      ABE_BOT = "matic-07m-acwz7n";
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

  programs.zsh.shellAliases = {
    mdke = "docker exec -it mdk_home_abe_matic";
    mdk_bzl = "docker exec -it mdk_home_abe_matic ./tools/bazel";
    mdk_bzl_bot = "docker exec -it mdk_home_abe_matic ./tools/bazel build -c opt --config=jetson_orin";
  };
}
