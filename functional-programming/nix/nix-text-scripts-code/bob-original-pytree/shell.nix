let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in
with pkgs;
pkgs.mkShell {

  name = "DiagramsShell";

  buildInputs = [

    cabal-install
    direnv
    ghc
    ghcid
    hlint
    haskellPackages.haskell-language-server
    haskellPackages.cabal2nix
    stylish-haskell
    bash
    haskellPackages.zlib
    haskellPackages.diagrams
    vim
    nixops
    curl
    jq
    haskellPackages.shelly
    haskellPackages.niv
    haskellPackages.shelly-extra
    trash-cli
    haskellPackages.JuicyPixels
    haskellPackages.hfsevents
    compcert
    haskellPackages.bytestring
    glib
    pkg-config
    cairo
    pango


  ];

  shellHook = ''
    

  '';
}
