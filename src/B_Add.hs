module B_Add where

  -- this module adds the following language construct to the DSL
  --    (Val i)
  --    (Add i1 i2)
  -------------------------------------------------------

  import Utils
  import Result
  
  import Haskus.Utils.EADT
  import Data.Functor.Foldable
  
  data ValF e = ValF Int deriving (Functor)
  data AddF e = AddF e e deriving (Functor)
  
  type AddValADT = EADT '[ValF,AddF]
  


  -- define patterns, for creation and pattern matching
  
  pattern Val :: ValF :<: xs => Int -> EADT xs
  pattern Val a = VF (ValF a)
  
  pattern Add :: AddF :<: xs => EADT xs -> EADT xs -> EADT xs
  pattern Add a b = VF (AddF a b)

  

  -- show
  
  instance ShowAST ValF where
    showAST' (ValF i) = show i
  
  instance ShowAST AddF where
    showAST' (AddF u v) = "(" <> u <> " + " <> v <> ")" -- no recursive call
    
  
        
  -- Type checker
  
  instance TypeCheck ValF ys where
    typeCheck' _ = T "Int"

  instance (AddF :<: ys, ShowAST (VariantF ys), Functor (VariantF ys)) => TypeCheck AddF ys where
    typeCheck' (AddF (u,t1) (v,t2))
      | t1 == t2       = t1
      | TError _ <- t1 = t1 -- propagate errors
      | TError _ <- t2 = t2
      | otherwise = TError $ "can't add `" <> showAST u <> "` whose type is " <> show t1 <>
                            " with `" <> showAST v <> "` whose type is " <> show t2
  
  

  -- Eval: returns a Int
  
  instance Eval (ValF e) where
    eval (ValF i) = RInt i
  
  instance EvalAll xs => Eval (AddF (EADT xs)) where
    eval (AddF u v) = 
      case (evalAST u, evalAST v) of -- implicit recursion
        (RInt a, RInt b) -> RInt (a+b)
        (RError e, _) -> RError e
        (_, RError e) -> RError e
        _             -> RError $ "Error in eval(AddF)" 
