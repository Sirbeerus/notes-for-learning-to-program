{
  description = "My Nix application";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.hello = pkgs.hello;

        devShell =
 pkgs.mkShell { 
   name = "hello-world";
   buildInputs = with pkgs ; [
   hello
   cowsay
   figlet
  ]; 

  shellHook = ''
    echo "Welcome to my awesome shell!" | figlet ;
  '' ;
              };
      });
}

