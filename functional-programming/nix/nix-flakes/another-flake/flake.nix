{
  description = "My Nix application";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      pkgs = import <nixpkgs> {};
      haskellPackages = pkgs.haskellPackages;
    in
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          ghc = haskellPackages.ghcWithPackages (self: with self; [
            self
            hello
          ]);
        in {
          devShell =
            pkgs.mkShell {
              name = "Hello";
              buildInputs = with pkgs ; [
                ghc
                ghcid
                bash
                vim
              ];

              shellHook = ''
                echo "Welcome to my awesome shell!";
              '';
            };
        });
}

