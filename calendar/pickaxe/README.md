# Pickaxe
niv haskell project, runs curl request with jq to filter json files.

To start project needed to enter a <nix-shell -p ghc niv cabal-install>. initialize <niv init>. then <cabal init -i> (for interactive). Adjust packages inside .cabal accordingly in the build-depends section.

May need to adjust shellHook.


-- TERMINAL COMMANDS inside pickaxe folder.

nix-shell 
export NIXPKGS_ALLOW_INSECURE=1
nix-shell
ghcid Main.hs --run       # run inside exe folder.
cabal install --lib hedis
"       REPEATED       "  # as needed.
niv update --important for apocc error
niv add <GITHUB_AUTHOR><GITHUB_REPO_TITLE>

./the-ore.hs

cabal run 

https://dataswamp.org/~solene/2022-01-12-nix-niv-shell.html 

https://srid.ca/haskell-nix

#!/bin/bash -x

Users/sirbeerus/.nix-profile/bin/tmux attach -t pickaxeTmuxCron; cd /Users/sirbeerus/Documents/programming/calendar/pickaxe && /Users/sirbeerus/.nix-profile/bin/nix-shell shell.nix --run "cabal new-run"; /Users/sirbeerus/.nix-profile/bin/tmux detach -t pickaxeTmuxCron

0 4 * * * /bin/bash /Users/sirbeerus/bash-scripts/the-ore.sh

caffeinate -d


