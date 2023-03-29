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
