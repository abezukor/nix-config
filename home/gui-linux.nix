{
  pkgs,
  pkgs-unstable,
  ...
}:
let
  # Wrap LibreOffice to always launch with the Light GTK theme
  # Dark theme libreoffice seems to break the buttons
  libreoffice-light = pkgs.symlinkJoin {
    name = "libreoffice-light";
    paths = [ pkgs.libreoffice ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/libreoffice \
        --set SAL_USE_VCLPLUGIN gtk3 \
        --set GTK_THEME Adwaita:light \
        --set GDK_BACKEND x11
    '';
  };
in
{
  # Linux-only GUI packages. LibreOffice and qdirstat are not built for
  # Darwin; hunspell lives here as it is only used for LibreOffice spell-check.
  home.packages = [
    pkgs-unstable.qdirstat
    libreoffice-light
    pkgs.hunspell
    pkgs.hunspellDicts.en_US-large
  ];

  # You do not need to change this if you're reading this in the future.
  # Don't ever change this after the first build.  Don't ask questions.
  home.stateVersion = "25.05";
}
