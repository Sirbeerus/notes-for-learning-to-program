#! /usr/bin/env nix-shell
#! nix-shell -p ghcid
#! nix-shell -i "ghcid -c 'ghci -Wall' -T main"



main :: IO ()
main = do
   putStrLn "Hello from the-bar.hs"


{-

#* * * * * echo 'hello from cron' >> file.txt

#* * * * * echo 'hello from cron' >> ~/NixOS/file.txt

#* * * * * /bin/bash /Users/sirbeerus/bash-scripts/the-bar.sh

#* * * * * echo 'hello from cron' >> ~/Documents/programming/calendar/file.txt

-}
