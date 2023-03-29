#!/bin/bash


#0) create github pages repo for earth with needed content.

curl -u sirbeerus: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 https://api.github.com/user/repos -d '{"name":"fire","description":"Static Website for fire","auto_init":true,"private":"false"}'

#1) styx new site fire. 

styx new site --system aarch64-apple-darwin fire


#2) cd fire. 

cd fire

#3)commands to replace conf.nix content for deployment.

cat > conf.nix <<EOL
{
    title = "sea";
    description = "Welcome to my functional site! An exercise in futility. Join us on discord?";

    links = [ 
        { url = "https://developers.cardano.org/"; }
        { url = "https://discord.gg/YSnJrN9wwe"; }
        { url = "https://www.wildtangz.com/vending-machine/"; }
    ];
}
EOL

#4)commands to replace site.nix content for deployment.

cat > site.nix <<EOL
{
    imports = [ ./default.nix ];
    configuration = ./conf.nix;
    resources = ./resources;
    static = ./static;
}
EOL

#5)commands to create and needed content for default.nix for deployment if needed.

cat > default.nix <<EOL
{
    inputs.styx.url = "https://github.com/Sirbeerus/styx/archive/master.tar.gz";
    outputs.styx.url = "Sirbeerus/fire";
}
EOL

#6)commands to create and content for flake.nix.

cat > flake.nix <<EOL
{
    description = "Static Website for fire";
    inputs.styx.url = "https://github.com/Sirbeerus/styx/archive/master.tar.gz";
    outputs = {
        self,
        nixpkgs,
        stix,
        site,
    }:
    {
    site = stix.callPackage ./site.nix {
        inherit self;
        inherit nixpkgs;
        inherit stix;
    };
    }
EOL

#7)commands to create deployments.nix.

cat > deployments.nix <<EOL
{
    githubPages = {
      name = "github-pages";
      deployment.targetEnv = "production";
      deployment.targetHost = "sirbeerus.github.io";
      deployment.type = "github-pages";
      deployment.token = {
        secretName = "GITHUB_TOKEN";
        value = "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";
      };
    };
}
EOL

#8)commands and content to edit static folder.

cd static
cat > index.html <<EOL
<!DOCTYPE html>
<html>
  <head>
    <title>Sea</title>
  </head>
  <body>
    <h1>Welcome to my functional site! An exercise in futility. Join us on discord?</h1>
    <ul>
        <li><a href="https://developers.cardano.org/">Cardano Developers</a></li>
        <li><a href="https://discord.gg/YSnJrN9wwe">Discord</a></li>
        <li><a href="https://www.wildtangz.com/vending-machine/">WildTangz Vending Machine</a></li>
    </ul>
  </body>
</html>
EOL

#9)commands and content to add resources for nixops before deployment.

cd ..
cat > resources.nix <<EOL
{
    resources.GITHUB_TOKEN.value = "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";
}
EOL

#10)commands and content to edit nixops deployment 

cat > deployment.nix <<EOL
{
    deployments.github-pages.enabled = true;
    deployments.github-pages.targetHost = "sirbeerus.github.io";
    deployments.github-pages.token.secretName = "GITHUB_TOKEN";
    deployments.github-pages.token.value = "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";
}
EOL



#11)commands and content to create deploy.yml

cat > .github/workflows/deploy.yml <<EOL
name: CI/CD

on:
  push:
    branches:
      - master

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        uses: nix-community/action-nixops-deploy@v2
        with:
          deployment: fire
          nix-path: "nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
          args: --allow-unsupported-system
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOL

#should deploy to sirbeerus.github.io at the end.




#11)commands and content to create deploy.yml

cat > .github/workflows/deploy.yml <<EOL
name: CI/CD

on:
  push:
    branches:
      - master

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        uses: nix-community/action-nixops-deploy@v2
        with:
          deployment: fire
          nix-path: "nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
          args: --allow-unsupported-system
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOL

nixops deploy -d fire --show-trace --allow-unsupported-system
