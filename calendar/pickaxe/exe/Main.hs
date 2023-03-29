{-# LANGUAGE OverloadedStrings #-}
  
module Main where

import qualified PickaxeTomes as PT

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Trans.Maybe
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Char8 as BS
import qualified Data.Text as T
import qualified Data.Text.IO as DT
import Shelly as S
import System.Directory
import System.FilePath
import System.IO
import System.Process as PR
import Text.Read

{-
main :: IO ()
main = S.shelly $ do
  S.liftIO $ putStrLn "Hello from Main."
  S.run_ "pwd" []
  PickaxeTomes.someFunc
-}

main :: IO ()
main = shelly $ do

    liftIO $ putStrLn "Hello from Main."
    run_ "pwd" []
    PT.processMakeFolderFiles
    PT.processCurlCoins
    PT.processCurlNfts
    PT.processBTC
    PT.processPOOL
    PT.processGekArdana
    PT.processGEK
    PT.processJpgViralNFTs
    PT.processJpgSuperVirus
    PT.processJpgClayNation
    PT.processJpgClayNationGC
    PT.processJpgSpacebudz
    PT.processJpgWorldsWithin
    PT.processJpgZombieChains
    PT.processJpgZombieHunters
    PT.processJpgZombits
    PT.processJpgRatsDao
    PT.processJpgAnetaAngel
    PT.processJpgDeepVision     
    PT.processRefinedPath