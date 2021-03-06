{-# LANGUAGE CPP #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE Trustworthy #-}
#ifndef HLINT
{-# LANGUAGE UnboxedTuples #-}
#endif
module Data.STIntRef
       ( STIntRef
       , newSTIntRef
       , readSTIntRef
       , writeSTIntRef
       , modifySTIntRef
       ) where

import GHC.Exts (Int (I#),
                 MutableByteArray#,
                 newByteArray#,
                 readIntArray#,
                 sameMutableByteArray#,
                 writeIntArray#)
import GHC.ST (ST (ST))

#ifndef HLINT
#include "MachDeps.h"
#endif

data STIntRef s = STIntRef (MutableByteArray# s)

instance Eq (STIntRef s) where
  STIntRef x == STIntRef y = sameMutableByteArray# x y

newSTIntRef :: Int -> ST s (STIntRef s)
{-# INLINE newSTIntRef #-}
newSTIntRef a = ST $ \ s -> case newByteArray# SIZEOF_INT# s of
  (# s', arr #) -> case a of
    I# i -> case writeIntArray# arr 0# i s' of
      s'' -> (# s'', STIntRef arr #)

readSTIntRef :: STIntRef s -> ST s Int
{-# INLINE readSTIntRef #-}
readSTIntRef (STIntRef arr) = ST $ \ s -> case readIntArray# arr 0# s of
  (# s', i #) -> (# s', I# i #)

writeSTIntRef :: STIntRef s -> Int -> ST s ()
{-# INLINE writeSTIntRef #-}
writeSTIntRef (STIntRef arr) (I# i) = ST $ \ s -> case writeIntArray# arr 0# i s of
  s' -> (# s', () #)

modifySTIntRef :: STIntRef s -> (Int -> Int) -> ST s ()
{-# INLINE modifySTIntRef #-}
modifySTIntRef ref f = readSTIntRef ref >>= writeSTIntRef ref . f
