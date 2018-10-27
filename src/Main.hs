-- from http://hsyl20.fr/home/posts/2018-05-22-extensible-adt.html

{-# LANGUAGE RebindableSyntax #-}

module Main where

import Interpreter.A_TypeCheck
import Interpreter.B_Add
import Interpreter.C_Mul
import Interpreter.D_Float
import Interpreter.Interpreter
import Interpreter.Utils
import Interpreter.Result

import Haskus.Utils.EADT
import Prelude hiding (fromInteger, fromRational)
import Text.Megaparsec
import Text.Megaparsec.Char as M

-- syntactic sugar


fromInteger :: (EmptyNoteF :<: xs, ValF :<: xs) => Integer -> EADT xs
fromInteger i = Val EmptyNote $ fromIntegral i
fromRational :: (EmptyNoteF :<: xs, FloatValF :<: xs) => Rational -> EADT xs
fromRational i = FloatVal EmptyNote $ realToFrac i

(.+) :: (EmptyNoteF :<: xs, AddF :<: xs) => EADT xs -> EADT xs -> EADT xs
(.+) a b = Add EmptyNote (a,b)
(.*) a b = Mul EmptyNote (a,b)

neg :: ValF :<: xs => EADT xs -> EADT xs
neg (Val α i)= Val α (-i)


-- Main

type V1_AST = EADT '[HErrorF,EmptyNoteF, ValF,AddF]
type V2_AST = EADT '[HErrorF,EmptyNoteF, ValF,AddF,MulF]
type V3_AST = EADT '[HErrorF,EmptyNoteF, ValF,AddF,MulF,FloatValF]

main :: IO ()
main = do
  let addVal = 10 .+ 5 :: V1_AST
  let mulAddVal = 3 .* (10 .+ 3) :: V2_AST
  let mulAddVal2 = (neg 3) .* (10 .+ 3) :: V2_AST
  let mulAddValFloat = 10.* 5.0 :: V3_AST
  
  putText $ showAST addVal
  putText " = "
  putTextLn $ show $ evalAST addVal

  putText $ showAST mulAddVal
  putText " = "
  putTextLn $ show $ evalAST mulAddVal

  putText $ showAST mulAddVal
  putText " -> "
  putTextLn $ showAST (demultiply mulAddVal)

  putText $ showAST mulAddVal2
  putText " = "
  putTextLn $ showAST $ demultiply (mulAddVal2)

  putTextLn $ showAST (demultiply $ (neg 2 .* 5) ::  V2_AST)
  
  putText $ showAST mulAddValFloat
  putText " -> "
  putTextLn $ showAST mulAddValFloat


  putTextLn $ showAST $ setType $ appendEADT @'[TTypeF] ((3 .+ 5).*5.0 :: V3_AST)

  putTextLn $ show $ showAST <$> parseMaybe parser "(3+1)*15.0"
  putTextLn $ show $ interpret "((2+1)*5.0)"
