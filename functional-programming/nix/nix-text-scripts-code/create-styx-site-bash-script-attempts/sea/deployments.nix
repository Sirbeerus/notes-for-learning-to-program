{
  description = "Deployment of sea to GitHub Pages";

  inputs.styx.url = "https://github.com/Sirbeerus/sea";
  inputs.styx.rev = "master";

  outputs = {
    self, nixpkgs, styx, ...
  }:
  {
    gh-pages = {
      inherit self nixpkgs styx;

      components.index.source = self.styx + "/site";
      deployments.gh-pages.enable = true;
      deployments.gh-pages.githubToken = "<GITHUB_TOKEN>";
    };
  };
}
