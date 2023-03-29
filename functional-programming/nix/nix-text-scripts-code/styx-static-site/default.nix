{ pkgs ? import <nixpkgs> {}
, extraConf ? {}
}:

rec {

  styx = import pkgs.styx {
    # Used packages
    inherit pkgs;

    # Used configuration
    config = [
      ./conf.nix
      extraConf
    ];

    # Loaded themes
    themes = let
      styx-themes = import pkgs.styx.themes;
    in [
      # Declare the used themes here, from a package:
      #   styx-themes.generic-templates
      #  Or from a local path
      #   ./themes/my-theme
    ];

    # Environment propagated to templates
    env = { inherit data pages; };
  };

  # Propagating initialized data
  inherit (styx.themes) conf files templates env lib;

  data = {
  };

  pages = rec {
  };

  pageList = lib.pagesToList { inherit pages; };

  site = lib.mkSite { inherit files pageList; };

}
