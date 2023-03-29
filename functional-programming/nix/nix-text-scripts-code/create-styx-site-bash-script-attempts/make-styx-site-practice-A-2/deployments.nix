{
  resources.githubToken.token = builtins.readFile ~/.github/token;
  resources.githubToken.tokenFile = "/Users/username/.github/token";
}
{
  deploy = true;
  a2-site.targetEnv = "githubpages";
  a2-site.targetHost = "github.com";
  a2-site.deployment.targetPath = "/A-2";
  a2-site.deployment.githubpages.repository = "Sirbeerus/A-2";
  a2-site.deployment.githubpages.branch = "master";
  a2-site.deployment.githubpages.tokenFile = "/Users/username/.github/token";
}
