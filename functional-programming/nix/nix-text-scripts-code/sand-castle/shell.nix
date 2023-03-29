let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in
with pkgs;
pkgs.mkShell {

  name = "Pickaxe";

  buildInputs = [

    cabal-install
    ghc
    ghcid
    hlint
    haskellPackages.wreq
    haskellPackages.haskell-language-server
    haskellPackages.cabal2nix
    stylish-haskell
    haskellPackages.hedis
    haskellPackages.generic-data
    bash
    haskellPackages.aeson
    haskellPackages.lens
    haskellPackages.zlib
    vim
    nixops
    haskellPackages.redis
    curl
    jq
    haskellPackages.shelly
    openssl
    haskellPackages.assoc
    haskellPackages.ap-normalize
    haskellPackages.niv
    redis
    haskellPackages.HTTP
    haskellPackages.shelly-extra
    haskellPackages.turtle
  ];
}
