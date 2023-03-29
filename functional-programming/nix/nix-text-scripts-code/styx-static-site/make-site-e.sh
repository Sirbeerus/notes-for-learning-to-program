#!/bin/bash


# create github pages repo for abundant-solutions-dev with needed content and given credentials
curl -H "Authorization: token ${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}" -X POST -d '{"name": "abundant-solutions-dev"}' https://api.github.com/user/repos

# clone the repo locally
git clone git@github.com:Sirbeerus/abundant-solutions-dev.git

# cd to the repo
cd abundant-solutions-dev

# stylx new site A-2
styx new site A-2


# edit template conf.nix for github site deployment
cat >conf.nix << EOF
{ lib
, ... }:
{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "https://sirbeerus.github.io/abundant-solutions-dev";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set.
  */
  theme = {
  };
}
EOF

# edit template site.nix content for my site deployment
cat >site.nix << EOF
{ lib
, ... }:
{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "https://sirbeerus.github.io/abundant-solutions-dev";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set.
  */
  theme = {
    title = "abundant-solutions-dev";
    body = "Welcome to my functional site! An exercise in futility. Join us on discord?";
    links = [
      { text = "Cardano Developers"; url = "https://developers.cardano.org/"; }
      { text = "Discord"; url = "https://discord.gg/YSnJrN9wwe"; }
      { text = "Vending Machine"; url = "https://www.wildtangz.com/vending-machine/"; }
    ];
  };
}
EOF

# create default.nix if needed
cat >default.nix << EOF
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
EOF

# create flake.nix if needed
cat >flake.nix << EOF
{
  description = "Abundant Solutions Dev";

  inputs.styx.url = builtins.fetchGit {
    url = "https://github.com/Sirbeerus/abundant-solutions-dev.git";
    rev = "master";
  };

  outputs = { self, nixpkgs, ... }: {
    site = {
      outputPath = "site";
      output = self.styx.build {
        inherit nixpkgs;
        src = ./.;
      };
    };
  };
}
EOF

# create deployments.nix if needed
cat >deployments.nix << EOF
{ nixpkgs, ... }:

let
  styx = import ./flake.nix {
    # Used packages
    inherit nixpkgs;
  };
in

{
  # Deploying the site to Github Pages
  githubPages = {
    token = "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";
    ref = "refs/heads/master";
    repo = "Sirbeerus/abundant-solutions-dev";
    path = "site";
    site = styx.site;
  };
}
EOF

# edit static folder if needed
cat >static/index.html << EOF
<html>
  <head>
    <title>Abundant Solutions Dev</title>
  </head>
  <body>
  <h1>Welcome to Abundant Solutions Dev!</h1>
  <p>An exercise in futility. Join us on discord?</p>
  <ul>
    <li><a href="https://developers.cardano.org/">Cardano Developers</a></li>
    <li><a href="https://discord.gg/YSnJrN9wwe">Discord</a></li>
    <li><a href="https://www.wildtangz.com/vending-machine/">Vending Machine</a></li>
  </ul>
  </body>
</html>
EOF

# edit themes folder if needed
cat >themes/my-theme/index.html << EOF
<html>
  <head>
    <title>Abundant Solutions Dev</title>
  </head>
  <body>
  <h1>Welcome to Abundant Solutions Dev!</h1>
  <p>An exercise in futility. Join us on discord?</p>
  <ul>
    <li><a href="https://developers.cardano.org/">Cardano Developers</a></li>
    <li><a href="https://discord.gg/YSnJrN9wwe">Discord</a></li>
    <li><a href="https://www.wildtangz.com/vending-machine/">Vending Machine</a></li>
  </ul>
  </body>
</html>
EOF

# edit data folder if needed
cat >data/my-data.json << EOF
[
  {
    "name": "Cardano Developers",
    "url": "https://developers.cardano.org/"
  },
  {
    "name": "Discord",
    "url": "https://discord.gg/YSnJrN9wwe"
  },
  {
    "name": "Vending Machine",
    "url": "https://www.wildtangz.com/vending-machine/"
  }
]
EOF

# edit or create a state file if needed
cat >state.nix << EOF
{
  resources = {
    githubPages = {
      token = "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";
      repo = "Sirbeerus/abundant-solutions-dev";
      ref = "refs/heads/master";
      path = "site";
    };
  };

  deployments.githubPages = {
    targetEnv = "staging";
    resourceStates = {
      githubPages = {
        source = {
          url = "https://github.com/Sirbeerus/abundant-solutions-dev.git";
          rev = "master";
        };
        build = {
          args = {
            src = ./.;
          };
        };
      };
    };
  };
}
EOF

# add resources for nix-ops before deployment if needed
nixops add-resource --resource githubPages --type githubPages

# nixops deployment
nixops deploy --show-trace
