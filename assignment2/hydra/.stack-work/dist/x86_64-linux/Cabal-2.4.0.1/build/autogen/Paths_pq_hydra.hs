{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_pq_hydra (
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

bindir     = "/home/loulou/Github/epei2/assignment2/hydra/.stack-work/install/x86_64-linux/87c9a10f5b269794fe7ae3a73f7cd570cea52f398d0c8ebaae33d59194010dc9/8.6.3/bin"
libdir     = "/home/loulou/Github/epei2/assignment2/hydra/.stack-work/install/x86_64-linux/87c9a10f5b269794fe7ae3a73f7cd570cea52f398d0c8ebaae33d59194010dc9/8.6.3/lib/x86_64-linux-ghc-8.6.3/pq-hydra-0.1.0.0-J4YHVfU3BpAEDRk53CYohQ"
dynlibdir  = "/home/loulou/Github/epei2/assignment2/hydra/.stack-work/install/x86_64-linux/87c9a10f5b269794fe7ae3a73f7cd570cea52f398d0c8ebaae33d59194010dc9/8.6.3/lib/x86_64-linux-ghc-8.6.3"
datadir    = "/home/loulou/Github/epei2/assignment2/hydra/.stack-work/install/x86_64-linux/87c9a10f5b269794fe7ae3a73f7cd570cea52f398d0c8ebaae33d59194010dc9/8.6.3/share/x86_64-linux-ghc-8.6.3/pq-hydra-0.1.0.0"
libexecdir = "/home/loulou/Github/epei2/assignment2/hydra/.stack-work/install/x86_64-linux/87c9a10f5b269794fe7ae3a73f7cd570cea52f398d0c8ebaae33d59194010dc9/8.6.3/libexec/x86_64-linux-ghc-8.6.3/pq-hydra-0.1.0.0"
sysconfdir = "/home/loulou/Github/epei2/assignment2/hydra/.stack-work/install/x86_64-linux/87c9a10f5b269794fe7ae3a73f7cd570cea52f398d0c8ebaae33d59194010dc9/8.6.3/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "pq_hydra_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "pq_hydra_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "pq_hydra_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "pq_hydra_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "pq_hydra_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "pq_hydra_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
