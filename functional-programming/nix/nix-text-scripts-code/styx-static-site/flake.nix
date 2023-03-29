{
  description = "Abundant Solutions Dev";

  inputs.styx.url = builtins.fetchGit {
    url = "https://github.com/Sirbeerus/abundant-solutions-dev.git";
    rev = "master";
  };

  outputs = { self, nixpkgs, ... }: {
    site = {
      outputPath = "site";
      output = self.styx.build {
        inherit nixpkgs;
        src = ./.;
      };
    };
  };
}
