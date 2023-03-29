{-# LANGUAGE OverloadedStrings #-}

module PickaxeTomes (processMakeFolderFiles,processBTC,processPOOL,processGekArdana,processGEK,processJpgViralNFTs,processJpgSuperVirus,processJpgClayNation,processJpgClayNationGC,processJpgSpacebudz,processJpgWorldsWithin,processJpgZombieChains,processJpgZombieHunters,processJpgZombits,processJpgRatsDao,processJpgAnetaAngel,processJpgDeepVision,processCurlCoins,processCurlNfts,processRefinedPath) where

import Shelly as S
import qualified Data.Text as T
import System.Directory
import System.FilePath
import System.IO
import System.Process as PR
import qualified Data.Text.IO as DT

processMakeFolderFiles :: Sh ()
processMakeFolderFiles = shelly $ do
    tmpExists <- test_d "tmp"
    if tmpExists 
      then do
        rawCoincapExists <- test_f "tmp/raw-coincap.json"
        when rawCoincapExists $ run_ "trash-put" ["tmp/raw-coincap.json"]
        rawPoolExists <- test_f "tmp/raw-pool.json"
        when rawPoolExists $ run_ "trash-put" ["tmp/raw-pool.json"]
        rawGekExistsArdana <- test_f "tmp/raw-gek-ardana.json"
        when rawGekExistsArdana $ run_ "trash-put" ["tmp/raw-gek-ardana.json"]   
        rawGekExistsHosky <- test_f "tmp/raw-gek-hosky.json"
        when rawGekExistsHosky $ run_ "trash-put" ["tmp/raw-gek-hosky.json"]     
        rawGekExists <- test_f "tmp/raw-gek.json"
        when rawGekExists $ run_ "trash-put" ["tmp/raw-gek.json"]

        
        rawJpgSuperVirusExists <- test_f "tmp/raw-jpg-super-virus.json"
        when rawJpgSuperVirusExists $ run_ "trash-put" ["tmp/raw-jpg-super-virus.json"]   
        rawJpgAllExists <- test_f "tmp/raw-jpg-all.json"
        when rawJpgAllExists $ run_ "trash-put" ["tmp/raw-jpg-all.json"]         


        refinedExists <- test_f "tmp/refined.json"
        when refinedExists $ run_ "trash-put" ["tmp/refined.json"]

        run_ "touch" ["tmp/raw-coincap.json"]
        run_ "touch" ["tmp/raw-pool.json"] 
        run_ "touch" ["tmp/raw-gek-ardana.json"]
        run_ "touch" ["tmp/raw-gek-hosky.json"]        
        run_ "touch" ["tmp/raw-gek.json"]

        run_ "touch" ["tmp/raw-jpg-super-virus.json"]
        run_ "touch" ["tmp/raw-jpg-all.json"]

        run_ "touch" ["tmp/refined.json"]
      else do
        run_ "mkdir" ["-p", "tmp"]
        run_ "touch" ["tmp/raw-coincap.json"]
        run_ "touch" ["tmp/raw-pool.json"]
        run_ "touch" ["tmp/raw-gek-ardana.json"] 
        run_ "touch" ["tmp/raw-gek-hosky.json"]        
        run_ "touch" ["tmp/raw-gek.json"]    

        run_ "touch" ["tmp/raw-jpg-super-virus.json"]
        run_ "touch" ["tmp/raw-jpg-all.json"]                

        run_ "touch" ["tmp/refined.json"]

    run_ "wait" []



-- COINS COINS COINS COINS COINS

processCurlCoins :: Sh ()
processCurlCoins = do

   -- Capture the output of the command
    btcinfo <- run "curl" ["--location", "--request", "GET", "api.coincap.io/v2/assets/bitcoin"]
    liftIO $ DT.writeFile "tmp/raw-coincap.json" btcinfo
    liftIO $ putStrLn "-- COINCAP DATA --"

    run_ "wait" []

   -- Capture the output of the command
    adainfo <- run "curl" ["--location", "--request", "GET", "https://pool.pm/total.json"]
    liftIO $ DT.writeFile "tmp/raw-pool.json" adainfo
    liftIO $ putStrLn "--  POOL DATA --"

    run_ "wait" []

   -- Capture the output of the command
    gekardana <- run "curl" ["--location", "--request", "GET", "https://api.coingecko.com/api/v3/coins/ardana"]
    liftIO $ DT.writeFile "tmp/raw-gek-ardana.json" gekardana
    liftIO $ putStrLn "-- GEK DATA ARDANA --"  

    run_ "wait" []

   -- Capture the output of the command
    gekhosky <- run "curl" ["--location", "--request", "GET", "https://api.coingecko.com/api/v3/coins/hosky"]
    liftIO $ DT.writeFile "tmp/raw-gek-hoksy.json" gekhosky
    liftIO $ putStrLn "-- GEK DATA HOSKY --"  



    run_ "wait" [] 

   -- Capture the output of the command
    gektrendingtopseven <- run "curl" ["--location", "--request", "GET", "https://api.coingecko.com/api/v3/search/trending"]
    liftIO $ DT.writeFile "tmp/raw-gek.json" gektrendingtopseven
    liftIO $ putStrLn "-- GEK DATA --"  




-- COINS REFINERY

processBTC :: Sh ()
processBTC = do
   output <- S.run "jq" [".data | {name: .name}", "tmp/raw-coincap.json"]
   S.writefile "tmp/refined.json" output

   output0 <- S.run "jq" [".data | {priceUsd: .priceUsd}", "tmp/raw-coincap.json"]
   S.appendfile "tmp/refined.json" output0


processPOOL :: Sh ()
processPOOL = do
   output <- S.run "jq" [" {adaUSD: .ADAUSD}", "tmp/raw-pool.json"]
   S.appendfile "tmp/refined.json" output


processGekArdana :: Sh ()
processGekArdana = do
   output <- S.run "jq" ["{name: .name, asset_platform_id: .asset_platform_id, price_usd: .market_data.current_price.usd, market_change_percentage_30d: .market_data.price_change_percentage_30d}", "tmp/raw-gek-ardana.json"]
   S.appendfile "tmp/refined.json" output   


processGEK :: Sh ()
processGEK = do
   output <- S.run "jq" [".coins[] | {name: .item.name, symbol: .item.symbol, market_cap_rank: .item.market_cap_rank}", "tmp/raw-gek.json"]
   S.appendfile "tmp/refined.json" output



-- NFTs NFTs NFTs NFTs NFTs

processCurlNfts :: Sh ()
processCurlNfts = do    

    supervirus <- run "curl" ["--location", "--request", "GET", "https://server.jpgstoreapis.com/policy/a51b52822dc9fec24c00a110d3ef509b799b06436872714ca4d4a942/sales?page=1"]
    liftIO $ DT.writeFile "tmp/raw-jpg-super-virus.json" supervirus
    liftIO $ putStrLn "-- SUPER VIRUS ASK --"  


    jpgall <- run "curl" ["--location", "--request", "GET", "https://api.cnft.tools/lists/all/new"]
    liftIO $ DT.writeFile "tmp/raw-jpg-all.json" jpgall
    liftIO $ putStrLn "-- ASK --"  


processRefinedPath :: Sh ()
processRefinedPath = do
  let refinedPath = "/Users/sirbeerus/Documents/programming/calendar/pickaxe/tmp/refined.json"
  let targetPath = "/Users/sirbeerus/Documents/programming/calendar/TheBar"

  -- check if the file already exists at the target path
  exists <- test_f targetPath
  when exists $ do
    -- move the file to trash
    run "trash-put" [T.pack targetPath]
    echo "Moved existing TheBar to trash"

  -- move the file from the refinedPath to the targetPath
  mv refinedPath targetPath
  echo "Moved refined.json to target location"



--NFT REFINERY

processJpgViralNFTs :: Sh ()
processJpgViralNFTs = do
    output <- S.run "jq" [".[] | select(.fullName == \"Viral NFT\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output



processJpgSuperVirus :: Sh ()
processJpgSuperVirus = do
   output <- S.run "jq" ["sort_by(.price_lovelace) | .[0] | {display_name: .display_name, price: .price_lovelace}" , "tmp/raw-jpg-super-virus.json"]
   S.appendfile "tmp/refined.json" output  
   

processJpgClayNation :: Sh ()
processJpgClayNation = do
    output <- S.run "jq" [".[] | select(.fullName == \"Clay Nation\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output


processJpgClayNationGC :: Sh ()
processJpgClayNationGC = do
    output <- S.run "jq" [".[] | select(.fullName == \"Claynation x Good Charlotte\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output    


processJpgSpacebudz :: Sh ()
processJpgSpacebudz = do
    output <- S.run "jq" [".[] | select(.fullName == \"SpaceBudz\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output  


processJpgWorldsWithin :: Sh ()
processJpgWorldsWithin = do
    output <- S.run "jq" [".[] | select(.fullName == \"Worlds Within\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output 

processJpgZombieChains :: Sh ()
processJpgZombieChains = do
    output <- S.run "jq" [".[] | select(.fullName == \"Zombie Chains\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output  


processJpgZombieHunters :: Sh ()
processJpgZombieHunters = do
    output <- S.run "jq" [".[] | select(.fullName == \"Zombie Hunters\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output 


processJpgZombits :: Sh ()
processJpgZombits = do
    output <- S.run "jq" [".[] | select(.fullName == \"Zombits\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output 


processJpgRatsDao :: Sh ()
processJpgRatsDao = do
    output <- S.run "jq" [".[] | select(.fullName == \"Rats Dao\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output    


processJpgAnetaAngel :: Sh ()
processJpgAnetaAngel = do
    output <- S.run "jq" [".[] | select(.fullName == \"Aneta Angels\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output 


processJpgDeepVision :: Sh ()
processJpgDeepVision = do
    output <- S.run "jq" [".[] | select(.fullName == \"Deep Vision\") | {fullName: .fullName, sevenDayVolume: .sevenDayVolume, floorPrice: .floorPrice}", "tmp/raw-jpg-all.json"]
    S.appendfile "tmp/refined.json" output 







