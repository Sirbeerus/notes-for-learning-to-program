#!/bin/bash

#1) create github pages repo for A-2 with needed content and given creditials.

curl -u "Sirbeerus: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" https://api.github.com/user/repos -d '{"name": "A-2"}'

#2) clone the repo locally.

git clone https://github.com/Sirbeerus/A-2.git

#3) cd to repo.

cd A-2

#4) styx new site A-2 (this creates these files and folders: conf.nix, data, readme.md , site.nix, themes).

styx new site A-2

#5) commands and content to edit conf.nix for github site deployment.

sed -i '1i { lib , ... }:' conf.nix

echo '{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "http://sirbeerus.github.io";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set.
  */
  theme = {
  };
}' >> conf.nix

#6)commands and content to edit site.nix content for my site deployment.

sed -i '1i { lib , ... }:' site.nix

echo '{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "http://sirbeerus.github.io";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set.
  */
  theme = {
  };
}' >> site.nix

echo '
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

}' >> site.nix

#7)commands to create and needed content for default.nix for deployment if needed.

echo '{ pkgs ? import <nixpkgs> {} }:

pkgs.styx.buildSite {

/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
  init = {
    /* Packages used by Styx
       An override can be used here.
    */
    inherit pkgs;

    /* Configuration loaded by Styx
       A list of paths, or attribute sets with paths.
    */
    config = [
      ./conf.nix
    ];

    /* Styx configuration
       The configuration of the Styx instance,
       as found in the styx package
    */
    styxConf = {};
  };

  /* Path of the site.nix file
     Should not be edited
  */
  siteFile = ./site.nix;

}' >> default.nix

#8)commands to create and content for flake.nix if needed.

echo '{
  description = "Deployment of the A-2 site";

  inputs = {
    nixpkgs.url = {
      url = builtins.fetchGit {
        url = "https://github.com/NixOS/nixpkgs";
        ref = "refs/heads/master";
        rev = "f58e0dbf2a8c182025202e9f0f88e00f7c8d90e0";
      };
    };
  };

  outputs = {
    self, nixpkgs, ...
  }:
  {
    a2-site = self.callPackage ../default.nix {
      inherit nixpkgs;
    };
  };
}' >> flake.nix


#9)commands to create deployments.nix if needed.

echo '{
  a2-site.a2-site-deployment = {
    targetEnv = "githubpages";
    targetHost = "github.com";

    deployment.targetPath = "/A-2";

    deployment.githubpages.repository = "Sirbeerus/A-2";
    deployment.githubpages.branch = "master";
    deployment.githubpages.tokenFile = "/Users/username/.github/token";
  };
}' >> deployments.nix

#10)commands and content to edit static folder if needed.

cd static
echo '<html>
<head>
  <title>abundant-solutions-dev</title>
</head>
<body>
  <h1>abundant-solutions-dev</h1>
  <p>Welcome to my functional site! An exercise in futility. Join us on discord?</p>
  <a href="https://developers.cardano.org/">Cardano Developers</a>
  <a href="https://discord.gg/YSnJrN9wwe">Discord</a>
  <a href="https://www.wildtangz.com/vending-machine/">Vending Machine</a>
</body>
</html>' >> index.html

#11)commands and content to edit themes folder if needed.

cd ../themes
echo '<html>
<head>
  <title>abundant-solutions-dev</title>
</head>
<body>
  <h1>abundant-solutions-dev</h1>
  <p>Welcome to my functional site! An exercise in futility. Join us on discord?</p>
  <a href="https://developers.cardano.org/">Cardano Developers</a>
  <a href="https://discord.gg/YSnJrN9wwe">Discord</a>
  <a href="https://www.wildtangz.com/vending-machine/">Vending Machine</a>
</body>
</html>' >> index.html

#12)commands and content to edit data folder if needed.

cd ../data
echo '{
  "title": "abundant-solutions-dev",
  "body": "Welcome to my functional site! An exercise in futility. Join us on discord?",
  "links": [
    { "url": "https://developers.cardano.org/", "text": "Cardano Developers" },
    { "url": "https://discord.gg/YSnJrN9wwe", "text": "Discord" },
    { "url": "https://www.wildtangz.com/vending-machine/", "text": "Vending Machine" }
  ]
}' >> page-data.json

#13)commands and content to add resources for nix-ops before deployment.

cd ..
echo '{
  resources.githubToken.token = builtins.readFile ~/.github/token;
  resources.githubToken.tokenFile = "/Users/username/.github/token";
}' >> deployments.nix

#14)commands and content to edit nixops deployment.

echo '{
  deploy = true;
  a2-site.targetEnv = "githubpages";
  a2-site.targetHost = "github.com";
  a2-site.deployment.targetPath = "/A-2";
  a2-site.deployment.githubpages.repository = "Sirbeerus/A-2";
  a2-site.deployment.githubpages.branch = "master";
  a2-site.deployment.githubpages.tokenFile = "/Users/username/.github/token";
}' >> deployments.nix

#should deploy to sirbeerus.github.io at the end.

nixops deploy -d A-2 --include a2-site --show-trace

# after successful deployment should be accessible at:
# http://sirbeerus.github.io/A-2/
