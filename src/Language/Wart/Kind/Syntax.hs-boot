{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
module Language.Wart.Kind.Syntax where

import Control.Applicative
import Control.Monad.Reader
import Control.Monad.Supply
import Control.Monad.UnionFind
import Data.Profunctor
import Language.Wart.Binding
import {-# SOURCE #-} qualified Language.Wart.Scheme.Syntax as Scheme
import {-# SOURCE #-} qualified Language.Wart.Type.Syntax as Type

infixr 9 ~>

bot :: (MonadSupply Int m, MonadUnionFind f m)
    => ReaderT (Binding f) m (f (Node f))

star :: (MonadSupply Int m, MonadUnionFind f m)
     => ReaderT (Binding f) m (f (Node f))

row :: (MonadSupply Int m, MonadUnionFind f m)
     => ReaderT (Binding f) m (f (Node f))

(~>) :: (MonadSupply Int m, MonadUnionFind f m)
      => ReaderT (Binding f) m (f (Node f))
      -> ReaderT (Binding f) m (f (Node f))
      -> ReaderT (Binding f) m (f (Node f))

data Binding (f :: * -> *)

data Binder (f :: * -> *)

data Node (f :: * -> *)

instance (Profunctor p, Functor f) =>
         IsBinding p f (Binding a) (Binding a) (Binder a)

instance (Choice p, Applicative f) =>
         Type.IsBinder p f (Binder a) (a (Type.Node a))

instance (Choice p, Applicative f) =>
         Scheme.IsBinder p f (Binder a) (Scheme.Node a)
