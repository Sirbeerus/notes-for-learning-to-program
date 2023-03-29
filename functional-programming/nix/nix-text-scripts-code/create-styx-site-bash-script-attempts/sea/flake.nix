{
  description = "sea";

  inputs.styx.url = "https://github.com/Sirbeerus/sea";
  inputs.styx.rev = "master";

  outputs = {
    self, nixpkgs, styx, ...
  }:
  {
    sea = stx.build {
      inherit self nixpkgs styx;
      components.index.source = self.styx + "/site";
    };
  };
}
