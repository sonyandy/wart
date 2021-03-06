{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Language.Wart.Kind.Graphic
       ( module Language.Wart.Graphic
       , module Language.Wart.Kind.Syntax
       , Node (..)
       , Binder (..)
       , bot, star, row, (~>)
       ) where

import Control.Applicative
import Control.Lens
import Control.Lens.Internal.Action
import Control.Monad.Reader
import Control.Monad.Supply
import Control.Monad.UnionFind
import Data.Traversable (sequenceA)
import GHC.Generics (Generic)
import Language.Wart.BindingFlag
import Language.Wart.Graphic
import Language.Wart.Kind.Syntax
import Language.Wart.Scheme.Syntax (Scheme)
import Language.Wart.Type.Syntax (Type)

data instance Node Kind v =
  Node
  {-# UNPACK #-} !Int
  (Kind (v (Node Kind v)))
  (v BindingFlag)
  (v (Binder Kind v)) deriving Generic
instance Functor f => HasLabel f (Node Kind v)
instance HasTerm (Node Kind)
instance Functor f => HasBindingFlag (->) f (Node Kind v) (v BindingFlag)
instance Functor f => HasBinder (->) f (Node Kind v) (v (Binder Kind v))

data instance Binder Kind v
  = Scheme (Node Scheme v)
  | Type (v (Node Type v))
  | Kind (v (Node Kind v)) deriving Generic
instance (Choice p, Applicative f) => AsScheme p f (Binder Kind)
instance AsType (Binder Kind)
instance AsKind (Binder Kind)

instance (Effective m r f, MonadUnionFind v m,
          HasLabel (Const Int) (Node Scheme v),
          HasLabel (Effect m Int) (Node Type v))
      => HasLabel f (Binder Kind v) where
  label = act $ \ case
    Scheme s -> return $ s^.label
    Type v_t -> v_t^!contents.label
    Kind v_k -> v_k^!contents.label

bot :: (MonadSupply Int m, MonadUnionFind v m)
    => ReaderT (BindingFlag, Binder Kind v) m (v (Node Kind v))
bot = kind Bot

star :: (MonadSupply Int m, MonadUnionFind v m)
     => ReaderT (BindingFlag, Binder Kind v) m (v (Node Kind v))
star = kind Star

row :: (MonadSupply Int m, MonadUnionFind v m)
    => ReaderT (BindingFlag, Binder Kind v) m (v (Node Kind v))
row = kind Row

(~>) :: (MonadSupply Int m, MonadUnionFind v m)
     => ReaderT (BindingFlag, Binder Kind v) m (v (Node Kind v))
     -> ReaderT (BindingFlag, Binder Kind v) m (v (Node Kind v))
     -> ReaderT (BindingFlag, Binder Kind v) m (v (Node Kind v))
a ~> b = kind $ a :-> b

kind :: (MonadSupply Int m, MonadUnionFind v m)
     => Kind (ReaderT (BindingFlag, Binder Kind v) m (v (Node Kind v)))
     -> ReaderT (BindingFlag, Binder Kind v) m (v (Node Kind v))
kind c =
  new =<<
  Node <$>
  supply <*>
  sequenceA c <*>
  (new =<< view _1) <*>
  (new =<< view _2)
