{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -Wno-missing-safe-haskell-mode #-}
module Paths_pickaxe (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/sirbeerus/.cabal/bin"
libdir     = "/Users/sirbeerus/.cabal/lib/x86_64-osx-ghc-8.10.4/pickaxe-0.1.0.0-inplace-sand-castle1"
dynlibdir  = "/Users/sirbeerus/.cabal/lib/x86_64-osx-ghc-8.10.4"
datadir    = "/Users/sirbeerus/.cabal/share/x86_64-osx-ghc-8.10.4/pickaxe-0.1.0.0"
libexecdir = "/Users/sirbeerus/.cabal/libexec/x86_64-osx-ghc-8.10.4/pickaxe-0.1.0.0"
sysconfdir = "/Users/sirbeerus/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "pickaxe_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "pickaxe_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "pickaxe_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "pickaxe_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "pickaxe_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "pickaxe_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
