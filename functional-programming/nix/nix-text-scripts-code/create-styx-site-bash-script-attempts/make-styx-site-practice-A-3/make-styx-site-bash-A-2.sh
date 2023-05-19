#!/bin/bash


#1) create github pages repo for A-2 with needed content and given creditials.
curl -u "Sirbeerus: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" https://api.github.com/user/repos -d '{"name":"A-2","description":"static site for abundant-solutions-dev"}'

#2) clone the repo locally.
git clone https://github.com/Sirbeerus/A-2

#3) cd to repo.
cd A-2

#4) styx new site A-2 (this creates these files and folders: conf.nix, data, readme.md , site.nix, themes).
styx new site A-2

#5) commands and content to edit conf.nix for github site deployment.
cat << EOT >> conf.nix
{ lib
, ... }:
{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "https://sirbeerus.github.io/A-2";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set.
  */
  theme = {
  };
}
EOT

#6)commands and content to edit site.nix content for my site deployment.
cat << EOT >> site.nix
{ lib
, ... }:
{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "https://sirbeerus.github.io/A-2";

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
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {
    index = {
      title = "abundant-solutions-dev";
      body = {
        text = ''
          Welcome to my functional site! An exercise in futility. Join us on discord?
        '';
        links = [
          {text = "Developers Cardano"; url = "https://developers.cardano.org/"}
          {text = "Discord"; url = "https://discord.gg/YSnJrN9wwe"}
          {text = "Vending Machine"; url = "https://www.wildtangz.com/vending-machine/"}
        ];
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

#7)commands to create and needed content for default.nix for deployment if needed.
cat << EOT >> default.nix
let
  pkgs = import <nixpkgs> {};
  styx = import ./site.nix {
    inherit pkgs;
  };
in
  styx.site
EOT

#8)commands to create and content for flake.nix if needed.
cat << EOT >> flake.nix
{
  inputs.styx.url = gitlab:Sirbeerus/A-2;
  outputs = { self, nixpkgs, styx, ... }: {
    out = {
      inherit self;
      path = "result";
      # Build the site
      buildInputs = [ styx ];
    };
  };
}
EOT

#9)commands to create deployments.nix if needed.
cat << EOT >> deployments.nix
{
  deployments.deployment = {
    inherit styx;
    targetHost = "sirbeerus.github.io";
    targetPath = "A-2";
    deployScript = ''
      echo "Deploying A-2"
      cd "$out/result"
      git init
      git remote add origin git@github.com:Sirbeerus/A-2.git
      git add .
      git commit -m "Deploying A-2"
      git push -f origin master
    '';
  };
}
EOT

#10)commands and content to edit static folder if needed.
cat << EOT >> static/readme.md

This directory contains files that are not processed by Styx and are copied as-is.
EOT

#11)commands and content to edit themes folder if needed.
cat << EOT >> themes/index.md

This directory contains themes that are used by Styx to generate the site.
EOT

#12)commands and content to edit data folder if needed.
cat << EOT >> data/readme.md

This directory contains data used by Styx to generate the site.
EOT

#13)commands and content to edit or create a state file.
cat << EOT >> state.nix
{
  environment.systemPackages = with pkgs; [
    git
  ];

  # Create a flake
  flake = {
    inputs.styx.url = gitlab:Sirbeerus/A-2;
    outputs = { self, nixpkgs, styx, ... }: {
      out = {
        inherit self;
        path = "result";
        # Build the site
        buildInputs = [ styx ];
      };
    };
  };

  # Deploy the built site
  deployments.deployment = {
    inherit styx;
    targetHost = "sirbeerus.github.io";
    targetPath = "A-2";
    deployScript = ''
      echo "Deploying A-2"
      cd "$out/result"
      git init
      git remote add origin git@github.com:Sirbeerus/A-2.git
      git add .
      git commit -m "Deploying A-2"
      git push -f origin master
    '';
  };
}
EOT

#14)commands and content to add resources for nix-ops before deployment.
cat << EOT >> resources.nix
{
  resources.deployment.styx = {
    # Fetch the flake
    fetchFromGitlab = {
      # The gitlab user
      user = "Sirbeerus";
      # The Gitlab repository name
      repo = "A-2";
    };

    # Build the flake
    buildInputs = [
      pkgs.styx
    ];
  };
}
EOT

#15)commands and content to edit nixops deployment.
cat << EOT >> deployment.nix
{
  deployment.nixops.styx = {
    resourceName = "deployment";
    inputs.styx.url = gitlab:Sirbeerus/A-2;
    outputs = { self, nixpkgs, styx, ... }: {
      out = {
        inherit self;
        path = "result";
        # Build the site
        buildInputs = [ styx ];
      };
    };
    targetHost = "sirbeerus.github.io";
    targetPath = "A-2";
    deployScript = ''
      echo "Deploying A-2"
      cd "$out/result"
      git init
      git remote add origin git@github.com:Sirbeerus/A-2.git
      git add .
      git commit -m "Deploying A-2"
      git push -f origin master
    '';
  };
}
EOT

# should deploy to sirbeerus.github.io at the end.
nixops deploy -d styx