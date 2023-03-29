let
  pkgs = import <nixpkgs> {};
in
  pkgs.haskellPackages.callPackage {
    pkgs,
    ghc = pkgs.ghc;
  }

