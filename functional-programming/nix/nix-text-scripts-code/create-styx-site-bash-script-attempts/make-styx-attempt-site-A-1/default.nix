let
  pkgs = import <nixpkgs> {};
  styx = pkgs.styx;
in

pkgs.stdenv.mkDerivation {
  name = "A-1";

  src = ./.;

  buildInputs = [ styx ];
  meta = {
    description = "Static Site Generated with Styx";
    homepage = "https://sirbeerus.github.io/A-1/";
    license = stdenv.lib.licenses.bsd3;
  };
}
