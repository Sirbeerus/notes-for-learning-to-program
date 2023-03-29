{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -Wno-missing-safe-haskell-mode #-}
module Paths_bob_pytree (
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
libdir     = "/Users/sirbeerus/.cabal/lib/x86_64-osx-ghc-8.10.4/bob-pytree-0.1.0.0-inplace-bob-pytree"
dynlibdir  = "/Users/sirbeerus/.cabal/lib/x86_64-osx-ghc-8.10.4"
datadir    = "/Users/sirbeerus/.cabal/share/x86_64-osx-ghc-8.10.4/bob-pytree-0.1.0.0"
libexecdir = "/Users/sirbeerus/.cabal/libexec/x86_64-osx-ghc-8.10.4/bob-pytree-0.1.0.0"
sysconfdir = "/Users/sirbeerus/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "bob_pytree_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "bob_pytree_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "bob_pytree_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "bob_pytree_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "bob_pytree_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "bob_pytree_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
