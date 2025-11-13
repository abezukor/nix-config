{ pkgs, ... }: {
  home = {
    packages = with pkgs; [ slack ];

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "25.05";
  };
  nixpkgs.config.allowUnfree = true;
}
