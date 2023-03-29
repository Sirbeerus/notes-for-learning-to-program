{
  description = "A-1";

  inputs.styx.url = "github:Sirbeerus/A-1";
  inputs.styx.rev = "master";

  outputs = { self, nixpkgs, styx }: {

    out = self.styx.buildSite {
      content = self.styx.loadSite {
        pkgs = nixpkgs;
        styx = styx;
      };
      outputDir = ./.;
    };

  };
}
