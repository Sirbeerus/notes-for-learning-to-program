{
    githubPages = {
      name = "github-pages";
      deployment.targetEnv = "production";
      deployment.targetHost = "sirbeerus.github.io";
      deployment.type = "github-pages";
      deployment.token = {
        secretName = "GITHUB_TOKEN";
        value = "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";
      };
    };
}