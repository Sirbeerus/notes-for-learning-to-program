{
  resources = {
    githubPages = {
      token = "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";
      repo = "Sirbeerus/abundant-solutions-dev";
      ref = "refs/heads/master";
      path = "site";
    };
  };

  deployments.githubPages = {
    targetEnv = "staging";
    resourceStates = {
      githubPages = {
        source = {
          url = "https://github.com/Sirbeerus/abundant-solutions-dev.git";
          rev = "master";
        };
        build = {
          args = {
            src = ./.;
          };
        };
      };
    };
  };
}
