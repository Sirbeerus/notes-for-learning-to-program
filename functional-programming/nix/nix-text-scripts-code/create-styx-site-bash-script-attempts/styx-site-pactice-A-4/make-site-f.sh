#!/bin/bash

# create github pages repo for A-2 with needed content and given creditials
curl -u 'Sirbeerus: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' https://api.github.com/user/repos -d '{"name":"A-2"}'

# clone the repo locally
git clone https://github.com/Sirbeerus/A-2.git

# cd to repo
cd A-2

# create styx site
styx new site A-2

# edit conf.nix
cat >conf.nix <<EOT
{ lib
, ... }:
{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "http://sirbeerus.github.io";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set.
  */
  theme = {
  };
}
EOT

# edit site.nix
cat >site.nix <<EOT
{ lib
, ... }:
{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "http://sirbeerus.github.io";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set.
  */
  theme = {
  };
}

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
    title = "abundant-solutions-dev";
    body = "Welcome to my functional site! An exercise in futility. Join us on discord?";
    links = [
      { url = "https://developers.cardano.org/"; title = "Cardano Developer Documentation"; }
      { url = "https://discord.gg/YSnJrN9wwe"; title = "Discord Server"; }
      { url = "https://www.wildtangz.com/vending-machine/"; title = "Wildtangz Vending Machine"; }
    ];
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {
    index = {
      meta = {
        title = "abundant-solutions-dev";
      };
      content = {
        title = "abundant-solutions-dev";
        body = data.body;
        links = data.links;
      };
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
EOT

# create default.nix
cat >default.nix <<EOT
{ nixpkgs ? import <nixpkgs> {}
}:

with nixpkgs;

let
  styx = import ./site.nix {
    inherit pkgs;
  };
in
styx.site
EOT

# create flake.nix
cat >flake.nix <<EOT
{
  description = "abundant-solutions-dev";
  inputs = {
    # Base packages
    nixpkgs.url = {
      url = "https://github.com/NixOS/nixpkgs/archive/nixos-20.09.tar.gz";
      sha256 = "1q8jv2a3f6g7j6qwf6zv00njgx6zllb6x54yhfvjz9c906rjr29f";
    };
  };
  outputs = {
    out = {
      path = "result";
      outputSource = ./default.nix;
    };
  };
}
EOT

# create deployments.nix
cat >deployments.nix <<EOT
{
  resources = {
    sirbeerus = {
      type = "github";
      githubToken = "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";
    };
  };
  deployment.A-2 = {
    resources = [
      sirbeerus.githubToken
    ];
    targetHost = "github.com";
    targetPath = "Sirbeerus.github.io";
    deployScript = ''
      mkdir -p $out
      cp -r $in/* $out
    '';
    flake.inputs.A-2.url = ./flake.nix;
    flake.inputs.A-2.sha256 = "${sha256 (builtins.readFile ./flake.nix)}";
  };
}
EOT

# add resources for nixops
nixops add-resource --deployment A-2 sirbeerus.githubToken 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

# deploy site
nixops deploy --deployment A-2 --show-trace --allow-reboot

echo "Deployment complete! Your site should now be available at http://sirbeerus.github.io"
