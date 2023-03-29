#!/bin/bash

#0) create github pages repo for sea with needed content.
curl -u "Sirbeerus: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" -H "Content-Type: application/json" --data '{"name":"sea"}' https://api.github.com/user/repos

#1) styx new site sea.
styx new site sea

#2) cd sea.
cd sea

#3)commands to replace conf.nix content for deployment.
cat <<EOF > conf.nix
  {
    name = "sea";
    baseUrl = "https://Sirbeerus.github.io/sea/";
    port = 8080;
    ssl = false;
    redirects = [
      { from = "/"; to = "index.html"; }
    ];
  }
EOF

#4)commands to replace site.nix content for deployment.
cat <<EOF > site.nix
{
  imports = [
    ./default.nix
  ];

  components = {
    index = {
      type = "static";
      source = ./.;
    };
  };

  routes = {
    "/" = {
      component = "index";
    };
  };
}
EOF

#5)commands to create and needed content for default.nix for deployment if needed.
cat <<EOF > default.nix
{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  networking.hostName = "sea";
  environment.systemPackages = with pkgs; [
    haskellPackages.styx
  ];
}
EOF

#6)commands to create and content for flake.nix.
cat <<EOF > flake.nix
{
  description = "sea";

  inputs.styx.url = "https://github.com/Sirbeerus/sea";
  inputs.styx.rev = "master";

  outputs = {
    self, nixpkgs, styx, ...
  }:
  {
    sea = stx.build {
      inherit self nixpkgs styx;
      components.index.source = self.styx + "/site";
    };
  };
}
EOF

#7)commands to create deployments.nix.
cat <<EOF > deployments.nix
{
  description = "Deployment of sea to GitHub Pages";

  inputs.styx.url = "https://github.com/Sirbeerus/sea";
  inputs.styx.rev = "master";

  outputs = {
    self, nixpkgs, styx, ...
  }:
  {
    gh-pages = {
      inherit self nixpkgs styx;

      components.index.source = self.styx + "/site";
      deployments.gh-pages.enable = true;
      deployments.gh-pages.githubToken = "<GITHUB_TOKEN>";
    };
  };
}
EOF

#8)nixops commands to deploy to github page.
nixops deploy -d sea --include ./deployments.nix --activation-timeout 300 --gh-pages-token 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 --gh-pages-name Sirbeerus --gh-pages-repo sea
