#!/bin/bash

#1) Create the github pages repo called A-1 with needed content. Then clone the newly created repo

#Create the repo
curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://api.github.com/user/repos -d '{"name": "A-1"}'

#Clone the repo
git clone --depth=1 https://$GITHUB_NAME:$GITHUB_TOKEN@github.com/$GITHUB_NAME/A-1.git

#2) cd to cloned repo if not in already in.
cd A-1

#3) styx new site prime-A-1 . (this creates these files and folders: conf.nix, data, readme.md , site.nix, themes).
styx new site prime-A-1 . 

#4) Commands to replace conf.nix content for deployment.
cat <<EOF > conf.nix
{ lib
, ... }:
{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "https://sirbeerus.github.io/A-1";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set.
  */
  theme = {
    generic-template.title = "abundant-solutions-dev";
  };
}
EOF

#5) Commands to replace site.nix content for deployment.
cat <<EOF > site.nix
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
EOF

#6) Commands to create and needed content files compatible with styx generic-template theme.
mkdir -p ./themes/generic-template

cat <<EOF > ./themes/generic-template/template.nix
{ lib, ... }:

let
  # The page's main content
  main = ''
    <h1>$title</h1>
    <p>$body</p>
    ${
      lib.listToString
        (map
          (x: ''<a href="$(x.url)">$(x.text)</a>'')
          links
        )
      or ''
    }
  '';
in

''
  <html>
    <head>
      <title>$title</title>
    </head>
    <body>
      $main
    </body>
  </html>
''
EOF

#7) Commands to create and content for default.nix for deployment if needed.
cat <<EOF > default.nix
let
  pkgs = import <nixpkgs> {};
  styx = pkgs.styx;
in

pkgs.stdenv.mkDerivation {
  name = "A-1";

  src = ./.;

  buildInputs = [ styx ];
  meta = {
    description = "Static Site Generated with Styx";
    homepage = "https://sirbeerus.github.io/A-1/";
    license = stdenv.lib.licenses.bsd3;
  };
}
EOF

#8) Commands to create and content for flake.nix.
cat <<EOF > flake.nix
{
  description = "A-1";

  inputs.styx.url = "github:Sirbeerus/A-1";
  inputs.styx.rev = "master";

  outputs = { self, nixpkgs, styx }: {

    out = self.styx.buildSite {
      content = self.styx.loadSite {
        pkgs = nixpkgs;
        styx = styx;
      };
      outputDir = ./.;
    };

  };
}
EOF

#9) Commands and content to edit static folder.
mkdir -p ./static

cat <<EOF > ./static/robots.txt
User-agent: *
Disallow:
EOF

#10) Commands and content to add resources for nix-ops before deployment.
nixops create deployments.nix deployments.nix

#11) Commands and content to edit nixops deployment
nixops modify -d deployments deploy-A-1 --include ./static

#12) Add ssh key for nixOps to github
cat ~/.ssh/id_rsa.pub | nixops ssh-key add -d deployments sirbeerus-github-io

#13) Add deploy command to bash script
nixops deploy -d deployments --allow-reboot --watch
