/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ pkgs ? import <nixpkgs> {}
, extraConf ? {}
}:

rec {

/*-----------------------------------------------------------------------------
   Setup

   This section setup required variables
-----------------------------------------------------------------------------*/

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
      # Or from a local path
      #   ./themes/my-theme
      styx-themes.generic-templates
    ];

    # Environment propagated to templates
    env = { inherit data pages; };
  };

  # Propagating initialized data
  inherit (styx.themes) conf files templates env lib;


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = {
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {
    index = {
      title = "abundant-solutions-dev";
      body = "Welcome to my functional site! An exercise in futility. Join us on discord?";
      links = [
        {
          url = "https://developers.cardano.org/";
          text = "Cardano Developers";
        }
        {
          url = "https://discord.gg/YSnJrN9wwe";
          text = "Discord";
        }
        {
          url = "https://www.wildtangz.com/vending-machine/";
          text = "Vending Machine";
        }
      ];
    };
  };


/*-----------------------------------------------------------------------------
   Site

-----------------------------------------------------------------------------*/

  /* Converting the pages attribute set to a list
  */
  pageList = lib.pagesToList { inherit pages; };

  /* Generating the site
  */
  site = lib.mkSite { inherit files pageList; };

}
