{
  description = "My Nix application";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          haskellPackages = pkgs.haskellPackages;

      in {

        packages.jq     = pkgs.jq;
        packages.curl   = pkgs.curl;
        packages.cowsay = pkgs.cowsay;
                 

        devShell = pkgs.mkShell {
          buildInputs = with haskellPackages; [
            haskell-language-server
            ghcid
            cabal-install
          ];
        };
      });
}
