module Interpreter.Utils where

  import Interpreter.Result
  import Control.Arrow
  import Haskus.Utils.EADT

  -- this module defines the operations we want to perform on the AST
  --    showAST
  --    typeCheck
  --    simplify
  -------------------------------------------------------
  data HErrorF e = HErrorF Text deriving (Functor)


  -- define pattern, for creation and pattern matching
  
  pattern HError :: HErrorF :<: xs => Text -> EADT xs
  pattern HError a = VF (HErrorF a)

  
  -- show
  -------------------------------------------------------
  class ShowAST (f :: * -> *) where
    showAST' :: f Text -> Text

  instance ShowAST (VariantF '[]) where
    showAST' = error "no implementation of Show for this type"

  instance (ShowAST x, ShowAST (VariantF xs))  => ShowAST (VariantF (x ': xs)) where
    showAST' v = case popVariantFHead v of
        Right u -> showAST' u
        Left  w -> showAST' w
    
  showAST :: (ShowAST (Base t), Recursive t) => t -> Text -- type inferred by GHC
  showAST = cata showAST'

  instance ShowAST HErrorF where
    showAST' (HErrorF s) = s

              
  -- eval
  -------------------------------------------------------

  instance Eval (HErrorF e) where
    eval (HErrorF e) = RError e
        

  -- transformations / recursion schemes
  -------------------------------------------------------
  bottomUp f = unfix >>> fmap (bottomUp f) >>> Fix >>> f

  -- bottom up traversal that performs an additional bottom up traversal in
  -- the transformed sub-tree when a transformation occurs. 
  bottomUpFixed :: Functor f => (Fix f -> Maybe (Fix f)) -> Fix f -> Fix f
  bottomUpFixed f = unfix >>> fmap (bottomUpFixed f) >>> Fix >>> f'
    where
        f' u = case f u of
          Nothing -> u
          Just v  -> bottomUpFixed f v
