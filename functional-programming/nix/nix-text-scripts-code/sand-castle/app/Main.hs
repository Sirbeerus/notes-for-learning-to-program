{-# LANGUAGE OverloadedStrings, TemplateHaskell, DeriveGeneric #-}

module Main where

-- "priceUsd":"17278.9104965184755695"

import Control.Lens
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Trans.Maybe
import Data.Aeson as A
import Data.Aeson.Lens
import Data.List
import  qualified Data.Maybe as DM
import Data.Ord
import Data.Time 
import qualified Data.Vector as V
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Char8 as BS
import qualified Data.Text as T
import qualified Data.Text.IO as DT
import Data.Text.Encoding 
import Data.Scientific
import GHC.Generics
import Network.Curl as C
import Shelly as S
import System.Directory
import System.FilePath
import System.IO
import System.Process as PR
import Text.Read
import Turtle as TRT

data BtcInfo = BtcInfo
  { id :: String
  , rank :: String
  , symbol :: String
  , name :: String
  , supplyb :: Scientific
  , maxSupply :: Scientific
  , marketCapUsd :: Scientific
  , volumeUsd24Hr :: Scientific
  , priceUsd :: Scientific
  , changePct24Hr :: Scientific
  , vwap24Hr :: Scientific
  , explorer :: String
  , timestamp :: Scientific
  } deriving (Show, Generic)

instance FromJSON BtcInfo where
  parseJSON = genericParseJSON defaultOptions  

data CurrencyInfo = CurrencyInfo
  { supply        :: Scientific
  , circulation   :: Scientific
  , delegations   :: Scientific
  , stake         :: Scientific
  , d             :: Maybe Scientific
  , k             :: Scientific
  , adaBTC        :: Scientific
  , adaUSD        :: Scientific
  , adaEUR        :: Scientific
  , adaJPY        :: Scientific
  , adaGBP        :: Scientific
  , adaCAD        :: Scientific
  , adaAUD        :: Scientific
  , adaBRL        :: Scientific
  , tokens        :: Scientific
  , nfts          :: Scientific
  , nftPolicies   :: Scientific
  , policies      :: Scientific
  , load24h       :: Scientific
  , load1h        :: Scientific
  , load5m        :: Scientific
  } deriving (Show, Generic)

instance FromJSON CurrencyInfo where
  parseJSON = genericParseJSON defaultOptions

data GekInfo = GekInfo
 { idg :: String
 , coinId :: Scientific
 , nameg :: String
 , symbolg :: String
 , marketCapRank :: Scientific
 , thumb :: String
 , small :: String
 , large :: String
 , slug :: String
 , priceBtc :: Scientific
 , score :: Scientific
 } deriving (Show, Generic)

instance FromJSON GekInfo where
 parseJSON = genericParseJSON defaultOptions



processBTC :: Sh ()
processBTC = do
    -- Read the contents of the output.json file
    contents0 <- liftIO $ LBS.readFile "app/tmp/output.json"
    let jsonData = A.decode contents0 :: Maybe Value

    case jsonData of
        Nothing -> liftIO $ putStrLn "Can't parse the output.json"
        Just jsonData -> do
            -- Use lens to extract the desired values from the jsonData
            let name = jsonData ^? key "name" . _String
            let priceUsd = jsonData ^? key "priceUsd" . _String
            let changePercent24Hr = jsonData ^? key "changePercent24Hr" . _String
            -- Create an array containing an object with the extracted values
            let newJsonData = A.Array (V.fromList [object $ DM.catMaybes [
                                ("name" A..=) <$> name, 
                                ("priceUsd" A..=) <$> priceUsd, 
                                ("changePercent24Hr" A..=) <$> changePercent24Hr
                            ]])
            -- Check if the lens.json file exists
            fileExists <- liftIO $ doesFileExist "tmp/lens.json"
            -- If the file exists, overwrite it with the newJsonData
            when fileExists $ liftIO $ LBS.writeFile "tmp/lens.json" (A.encode newJsonData)
            -- If the file does not exist, create it with the newJsonData
            unless fileExists $ liftIO $ LBS.writeFile "tmp/lens.json" (A.encode newJsonData)




processDATA :: Sh ()
processDATA = do
  -- Read the contents of the file
  contents1 <- liftIO $ DT.readFile "tmp/output.json"
  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 contents1)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = DM.fromMaybe 0 (jsonData ^? key "ADABTC" . _Number)
      adaUSD = DM.fromMaybe 0 (jsonData ^? key "ADAUSD" . _Number)
  -- Create a new JSON object with the adaBTC and adaUSD values
  let newJsonData = object ["ADABTC" A..= adaBTC, "ADAUSD" A..= adaUSD]
  -- Encode the JSON object and write it to the lens.json file
  liftIO $ LBS.writeFile "tmp/lens.json" (A.encode newJsonData)


processGEK :: Sh ()
processGEK = do
  -- Read the contents of the file
  contents2 <- liftIO $ DT.readFile "tmp/output.json"
  -- Decode the contents of the file as a JSON object
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 contents2)) :: Maybe Value
  -- Extract the items array
  let items = jsonData ^.. key "coins" . _Array . traverse . key "item"
  -- Extract the name, symbol, and market_cap_rank values from each item
  let names = items ^.. traverse . key "name" . _String
      symbols = items ^.. traverse . key "symbol" . _String
      market_cap_ranks = items ^.. traverse . key "market_cap_rank" . _Number
  -- do something with the names, symbols, and market_cap_ranks
  liftIO $ print names
  liftIO $ print symbols
  liftIO $ print market_cap_ranks

main :: IO ()
main = shelly $ do

  -- Capture the output of the command
  output0 <- run "curl" ["--location", "--request", "GET", "api.coincap.io/v2/assets/bitcoin"] 
  -- Write the output to the file
  liftIO $ DT.writeFile "tmp/output.json" "["
  liftIO $ DT.appendFile "tmp/output.json" output0
  liftIO $ DT.appendFile "tmp/output.json" ","
  liftIO $ putStrLn "-- BITCOIN DATA --"

  output1 <- run "curl" ["https://pool.pm/total.json"]
  -- Write the output to the file
  liftIO $ DT.appendFile "tmp/output.json" output1
  liftIO $ DT.appendFile "tmp/output.json" ","
  liftIO $ putStrLn "-- ADA DENOMINTATIONS --"

  output2 <- run "curl" ["--location", "--request", "GET", "https://api.coingecko.com/api/v3/search/trending"]
  -- Append the output to the file with a comment
  liftIO $ DT.appendFile "tmp/output.json" output2
  liftIO $ DT.appendFile "tmp/output.json" "]"
  liftIO $ putStrLn "-- TRENDING COIN DATA --"

  S.run_ "wait" []
  processBTC
  --S.run_ "wait" []
 -- processDATA
  --S.run_ "wait" []
  --processGEK










{-

main :: IO ()
main = shelly $ do
  -- Capture the output of the command
  output0 <- run "curl" ["--location", "--request", "GET", "api.coincap.io/v2/assets/bitcoin"] 
  -- Write the output to the file
  liftIO $ DT.writeFile "tmp/output.json" "["
  liftIO $ DT.appendFile "tmp/output.json" output0
  liftIO $ DT.appendFile "tmp/output.json" ","
  liftIO $ putStrLn "-- BITCOIN DATA --"

  output1 <- run "curl" ["https://pool.pm/total.json"]
  -- Write the output to the file
  liftIO $ DT.appendFile "tmp/output.json" output1
  liftIO $ DT.appendFile "tmp/output.json" ","
  liftIO $ putStrLn "-- ADA DENOMINTATIONS --"

  output2 <- run "curl" ["--location", "--request", "GET", "https://api.coingecko.com/api/v3/search/trending"]
  -- Append the output to the file with a comment
  liftIO $ DT.appendFile "tmp/output.json" output2
  liftIO $ DT.appendFile "tmp/output.json" "]"
  liftIO $ putStrLn "-- TRENDING COIN DATA --"
  processDATA

-}


{-

  #move file at end

moveLensFile :: IO ()
moveLensFile = do
  -- Current path of the lens.json file
  let src = "/Users/sirbeerus/Dropbox/Mac/Documents/programming/functional-programming/nix/nix-text-scripts-code/sand-castle/app/lens.json"
  -- Desired destination path for the lens.json file
  let dst = "/Users/sirbeerus/Dropbox/Mac/Documents/programming/calendar/lens.json"
  -- Move the file from the src path to the dst path
  renameFile src dsta


  or 


  moveLensFile :: IO ()
moveLensFile = do
  -- Current path of the lens.json file
  let src = "/Users/sirbeerus/Dropbox/Mac/Documents/programming/functional-programming/nix/nix-text-scripts-code/sand-castle/app/tmp/lens.json"
  -- Desired destination path for the lens.json file
  let dstDir = "/Users/sirbeerus/Dropbox/Mac/Documents/programming/calendar"

  -- Get the current date and time
  currentTime <- getCurrentTime
  -- Format the date and time as a string
  let dateTimeString = formatTime defaultTimeLocale "%Y-%m-%d %H:%M:%S" currentTime
  -- Construct the destination path by appending the date and time string to the dstDir path
  let dst = dstDir ++ "/market-pulse " ++ dateTimeString

  -- Check if the file exists
  fileExists <- doesFileExist src
  if fileExists
    then do
      -- Check if the destination path is valid
      dirExists <- doesDirectoryExist (takeDirectory dst)
      if dirExists
        -- Move the file from the src path to the dst path
        then renameFile src dst
        else putStrLn "Error: Invalid destination path"
    else putStrLn "Error: File does not exist"


-}


  
{-  

  # do not erase, template!
  
{-# LANGUAGE OverloadedStrings, TemplateHaskell, DeriveGeneric #-}

module Main where

import Control.Lens
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Trans.Maybe
import Data.Aeson as A
import Data.Aeson.Lens
import Data.List
import Data.Maybe (fromMaybe)
import Data.Ord
import Data.Time 
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Char8 as BS
import qualified Data.Text as T
import qualified Data.Text.IO as DT
import Data.Text.Encoding
import Data.Scientific
import GHC.Generics
import Network.Curl as C
import Shelly as S
import System.Directory
import System.FilePath
import System.IO
import System.Process as PR
import Text.Read
import Turtle as TRT

data CurrencyInfo = CurrencyInfo
  { supply        :: Scientific
  , circulation   :: Scientific
  , delegations   :: Scientific
  , stake         :: Scientific
  , d             :: Maybe Scientific
  , k             :: Scientific
  , adaBTC        :: Scientific
  , adaUSD        :: Scientific
  , adaEUR        :: Scientific
  , adaJPY        :: Scientific
  , adaGBP        :: Scientific
  , adaCAD        :: Scientific
  , adaAUD        :: Scientific
  , adaBRL        :: Scientific
  , tokens        :: Scientific
  , nfts          :: Scientific
  , nftPolicies   :: Scientific
  , policies      :: Scientific
  , load24h       :: Scientific
  , load1h        :: Scientific
  , load5m        :: Scientific
  } deriving (Show, Generic)

instance FromJSON CurrencyInfo where
  parseJSON = genericParseJSON defaultOptions


main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let responseBodyText = T.pack responseBody
      outputPath = "tmp/output.json"
  DT.writeFile outputPath responseBodyText

  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 responseBodyText)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = fromMaybe 0 (jsonData ^? key "ADABTC" . _Number)
      adaUSD = fromMaybe 0 (jsonData ^? key "ADAUSD" . _Number)
  -- Create a new JSON object with the adaBTC and adaUSD values
  let newJsonData = object ["ADABTC" A..= adaBTC, "ADAUSD" A..= adaUSD]
  -- Encode the JSON object and write it to the output file
  LBS.writeFile outputPath (A.encode newJsonData)

-}




{-

main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let responseBodyText = T.pack responseBody
      outputPath = "tmp/output.json"
  DT.writeFile outputPath responseBodyText

  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 responseBodyText)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = fromMaybe 0 (jsonData ^? key "ADABTC" . _Number)
      adaUSD = fromMaybe 0 (jsonData ^? key "ADAUSD" . _Number)
  -- Overwrite the output.json file with the adaBTC and adaUSD values
  DT.writeFile outputPath (T.pack (show adaBTC ++ "\n" ++ show adaUSD))

-}


{-

main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let outputPath = "tmp/output.json"
      responseBodyText = T.pack responseBody
  DT.writeFile outputPath responseBodyText


-}





{-

# works but needs to maintain as json, overwrites file with specified fields.


main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let responseBodyText = T.pack responseBody
      outputPath = "tmp/output.json"
  DT.writeFile outputPath responseBodyText

  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 responseBodyText)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = fromMaybe 0 (jsonData ^? key "ADABTC" . _Number)
      adaUSD = fromMaybe 0 (jsonData ^? key "ADAUSD" . _Number)
  -- Overwrite the output.json file with the adaBTC and adaUSD values
  DT.writeFile outputPath (T.pack (show adaBTC ++ "\n" ++ show adaUSD))

-}


{-

  # works overwrites file with specified fields


main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let responseBodyText = T.pack responseBody
      outputPath = "tmp/output.json"
  DT.writeFile outputPath responseBodyText

  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 responseBodyText)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = jsonData ^? key "ADABTC" . _Number
      adaUSD = jsonData ^? key "ADAUSD" . _Number
  -- Overwrite the output.json file with the adaBTC and adaUSD values
  DT.writeFile outputPath (T.pack (show adaBTC ++ "\n" ++ show adaUSD))


-}


{-

 #successfully curl and parses using lens prints to terminal

main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let responseBodyText = T.pack responseBody
      outputPath = "tmp/output.json"
  DT.writeFile outputPath responseBodyText

  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 responseBodyText)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = jsonData ^? key "ADABTC" . _Number
      adaUSD = jsonData ^? key "ADAUSD" . _Number
  -- Print the values
  print adaBTC
  print adaUSD

 # DO NOT ERASE

-}



{-

-- Do NOT ERASE  

# curl request, creates tmp file in app directory. outputs curl content to output.json inside tmp folder.

main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://server.jpgstoreapis.com/policy/a51b52822dc9fec24c00a110d3ef509b799b06436872714ca4d4a942/listings?page=1" []
  let outputPath = "tmp/output.json"
      responseBodyText = T.pack responseBody
  DT.writeFile outputPath responseBodyText

-- DO NOT ERASE


-}

{-

  # do not erase

  -- uses correct data type with successful curl request.

data AssetListing = AssetListing
  { assetId :: String
  , displayName :: String
  , txHash :: String
  , listingId :: Int
  , listedAt :: String
  , priceLovelace :: Int
  , listingType :: String
  } deriving (Show, Generic)

instance FromJSON AssetListing


main :: IO ()
main = do
  (_, responseBody) <- C.curlGetString "https://server.jpgstoreapis.com/policy/a51b52822dc9fec24c00a110d3ef509b799b06436872714ca4d4a942/listings?page=1" []
  putStrLn $ "Response body: " ++ responseBody

  # do not erase

-}


--  S.run_ "cat" ["Main.hs"]
--  S.run_ "ls" []
--  S.cd "/Users/sirbeerus/Dropbox/Mac/Documents/programming/functional-programming/nix/nix-text-scripts-code/sand-castle/app/tmp"
-- S.run_ "jq" [".", "output.json"]
-- S.run_ "jq" ["to_entries | map(.value)", "output.json"]
-- S.run_ "jq" [".[]", ".listings[]" , ".display_name",  "output.json"]

{-

-- DO NOT ERASE!


  # (Pickaxe REPO) , Original.

main :: IO ()
main = do
  -- Make the first request
  response <- W.get "https://server.jpgstoreapis.com/policy/a51b52822dc9fec24c00a110d3ef509b799b06436872714ca4d4a942/listings?page=1"
  let body = response ^. W.responseBody
  let listings = body ^.. values
  forM_ listings $ \listing -> do
    let displayName = listing ^. key "display_name" . _String
    let priceLovelace = listing ^. key "price_lovelace" . _String
    putStrLn ("display_name: " ++ Data.Text.unpack displayName)
    putStrLn ("price_lovelace: " ++ Data.Text.unpack priceLovelace)

  -- Make the second request
  
  (_, responseBody) <- C.curlGetString "https://cnft.tools/toolsapi/v3/projsearch" []
  putStrLn $ "Response body: " ++ responseBody

  conn <- R.connect defaultConnectInfo
  liftIO (runRedis conn ping) >>= print

-- DO NOT ERASE!

-}







{-


import Data.Aeson.Lens
import Data.List
import Data.Maybe (fromMaybe)
import Data.Ord
import Data.Time 
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Char8 as BS
import qualified Data.Text as T
import qualified Data.Text.IO as DT
import Data.Text.Encoding
import Data.Scientific (toRealFloat)
import GHC.Generics
import Network.Curl as C
import Shelly as S
import System.Directory
import System.FilePath
import System.IO
import System.Process as PR
import Text.Read
import Turtle as TRT

data CurrencyInfo = CurrencyInfo
  { adaBTC :: Double
  , adaUSD :: Double
  } deriving (Show, Generic)

instance FromJSON CurrencyInfo where
  parseJSON = genericParseJSON defaultOptions

main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let responseBodyText = T.pack responseBody
      outputPath = "tmp/output.json"
  DT.writeFile outputPath responseBodyText

  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 responseBodyText)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = fromMaybe 0 (jsonData ^? key "ADABTC" . _Number)
      adaUSD = fromMaybe 0 (jsonData ^? key "ADAUSD" . _Number)
  -- Convert the values to Doubles
  let adaBTC' = toRealFloat adaBTC
      adaUSD' = toRealFloat adaUSD
  -- Create a JSON object with the adaBTC and adaUSD values
  let newJsonData = object ["ADABTC" .= adaBTC', "ADAUSD" .= adaUSD']
  -- Write the JSON object to the output.json file
  LBS.writeFile outputPath (A.encode newJsonData)

-}



{-

# works but needs to maintain as json, overwrites file with specified fields.


main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let responseBodyText = T.pack responseBody
      outputPath = "tmp/output.json"
  DT.writeFile outputPath responseBodyText

  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 responseBodyText)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = fromMaybe 0 (jsonData ^? key "ADABTC" . _Number)
      adaUSD = fromMaybe 0 (jsonData ^? key "ADAUSD" . _Number)
  -- Overwrite the output.json file with the adaBTC and adaUSD values
  DT.writeFile outputPath (T.pack (show adaBTC ++ "\n" ++ show adaUSD))

-}


{-

  # works overwrites file with specified fields


main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let responseBodyText = T.pack responseBody
      outputPath = "tmp/output.json"
  DT.writeFile outputPath responseBodyText

  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 responseBodyText)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = jsonData ^? key "ADABTC" . _Number
      adaUSD = jsonData ^? key "ADAUSD" . _Number
  -- Overwrite the output.json file with the adaBTC and adaUSD values
  DT.writeFile outputPath (T.pack (show adaBTC ++ "\n" ++ show adaUSD))


-}


{-

 #successfully curl and parses using lens prints to terminal

main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://pool.pm/total.json" []
  let responseBodyText = T.pack responseBody
      outputPath = "tmp/output.json"
  DT.writeFile outputPath responseBodyText

  -- Parse the JSON data
  let Just jsonData = A.decode (LBS.fromStrict (encodeUtf8 responseBodyText)) :: Maybe Value
  -- Extract the adaBTC and adaUSD values
  let adaBTC = jsonData ^? key "ADABTC" . _Number
      adaUSD = jsonData ^? key "ADAUSD" . _Number
  -- Print the values
  print adaBTC
  print adaUSD

 # DO NOT ERASE

-}



{-

-- Do NOT ERASE  

# curl request, creates tmp file in app directory. outputs curl content to output.json inside tmp folder.

main :: IO ()
main = do
  createDirectoryIfMissing True "/tmp"
  (_, responseBody) <- C.curlGetString "https://server.jpgstoreapis.com/policy/a51b52822dc9fec24c00a110d3ef509b799b06436872714ca4d4a942/listings?page=1" []
  let outputPath = "tmp/output.json"
      responseBodyText = T.pack responseBody
  DT.writeFile outputPath responseBodyText

-- DO NOT ERASE


-}

{-

  # do not erase

  -- uses correct data type with successful curl request.

data AssetListing = AssetListing
  { assetId :: String
  , displayName :: String
  , txHash :: String
  , listingId :: Int
  , listedAt :: String
  , priceLovelace :: Int
  , listingType :: String
  } deriving (Show, Generic)

instance FromJSON AssetListing


main :: IO ()
main = do
  (_, responseBody) <- C.curlGetString "https://server.jpgstoreapis.com/policy/a51b52822dc9fec24c00a110d3ef509b799b06436872714ca4d4a942/listings?page=1" []
  putStrLn $ "Response body: " ++ responseBody

  # do not erase

-}


--  S.run_ "cat" ["Main.hs"]
--  S.run_ "ls" []
--  S.cd "/Users/sirbeerus/Dropbox/Mac/Documents/programming/functional-programming/nix/nix-text-scripts-code/sand-castle/app/tmp"
-- S.run_ "jq" [".", "output.json"]
-- S.run_ "jq" ["to_entries | map(.value)", "output.json"]
-- S.run_ "jq" [".[]", ".listings[]" , ".display_name",  "output.json"]

{-

-- DO NOT ERASE!


  # (Pickaxe REPO) , Original.

main :: IO ()
main = do
  -- Make the first request
  response <- W.get "https://server.jpgstoreapis.com/policy/a51b52822dc9fec24c00a110d3ef509b799b06436872714ca4d4a942/listings?page=1"
  let body = response ^. W.responseBody
  let listings = body ^.. values
  forM_ listings $ \listing -> do
    let displayName = listing ^. key "display_name" . _String
    let priceLovelace = listing ^. key "price_lovelace" . _String
    putStrLn ("display_name: " ++ Data.Text.unpack displayName)
    putStrLn ("price_lovelace: " ++ Data.Text.unpack priceLovelace)

  -- Make the second request
  
  (_, responseBody) <- C.curlGetString "https://cnft.tools/toolsapi/v3/projsearch" []
  putStrLn $ "Response body: " ++ responseBody

  conn <- R.connect defaultConnectInfo
  liftIO (runRedis conn ping) >>= print

-- DO NOT ERASE!

-}









