# minimal ~/abundant-solutions-dev/shell.nix file
let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in
 with pkgs;
 pkgs.mkShell {
    buildInputs = [
         ghc cabal-install cowsay
  ];
}
