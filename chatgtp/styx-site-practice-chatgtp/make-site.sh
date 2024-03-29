#!/bin/bash

# step 1: creating the styx site
styx new site abundant-solutions-dev

# step 2: changing the directory
cd abundant-solutions-dev

# step 3: replacing the content of conf.nix for deployment
cat > conf.nix <<EOF
{
  title = "abundant-solutions-dev";
  links = [
    { url = "https://developers.cardano.org/"; title = "Cardano Dev Docs"; }
    { url = "https://discord.gg/YSnJrN9wwe"; title = "Discord"; }
    { url = "https://www.wildtangz.com/vending-machine/"; title = "Vending Machine"; }
  ];
}
EOF

# step 4: replacing the content of site.nix for deployment
cat > site.nix <<EOF
{
  title = "abundant-solutions-dev";
  description = "Welcome to my functional site! An exercise in futility. Join us on discord?";
}
EOF

# step 5: creating and needed content for default.nix for deployment
cat > default.nix <<EOF
let
  # import the conf.nix file
  conf = import ./conf.nix;
in {
  # create the site
  site = Deployable.staticSite {
    config = conf;
  };

  # deploy the site
  deploy = {
    # deploy to github
    github = Deployable.github {
      name = "Sirbeerus";
      token = "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";
      repo = "abundant-solutions-dev";
    };
  };
}
EOF

# step 6: editing the static folder
mkdir static
cat > static/index.html <<EOF
<html>
  <head>
    <title>abundant-solutions-dev</title>
  </head>
  <body>
    <h1>Welcome to my functional site! An exercise in futility. Join us on discord?</h1>
    <ul>
      <li><a href="https://developers.cardano.org/">Cardano Dev Docs</a></li>
      <li><a href="https://discord.gg/YSnJrN9wwe">Discord</a></li>
      <li><a href="https://www.wildtangz.com/vending-machine/">Vending Machine</a></li>
    </ul>
  </body>
</html>
EOF

# step 7: deploying the site
nixops deploy --show-trace
