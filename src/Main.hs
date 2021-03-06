-- from http://hsyl20.fr/home/posts/2018-05-22-extensible-adt.html

{-# LANGUAGE RebindableSyntax #-}

module Main where

import Interpreter.A_Nucleus
import Interpreter.B_Add
import Interpreter.C_Mul
import Interpreter.Interpreter
import Interpreter.Transfos

import Haskus.Utils.EADT
import Prelude hiding (fromInteger, fromRational)
import Text.Megaparsec


-- Main

type V1_AST = EADT '[HErrorF,EmptyNoteF, ValF,FloatValF,AddF]
type V2_AST = EADT '[HErrorF,EmptyNoteF, ValF,FloatValF,AddF,MulF]
type V3_AST = EADT '[HErrorF,EmptyNoteF, ValF,FloatValF,AddF,MulF]

main :: IO ()
main = do
  let addVal = 10 .+ 5 :: V1_AST
  let mulAddVal = (10 .+ 3) .* 3 :: V2_AST
  let mulAddVal2 = (neg 3) .* (10 .+ 3) :: V2_AST
  let mulAddValFloat = 10.* 5.0 :: V3_AST
  
  putText $ showAST addVal
  putText " = "
  putTextLn $ show $ eval addVal

  putText $ showAST mulAddVal
  putText " -> "
  putTextLn $ show $ eval (demultiply $ distribute $ mulAddVal :: V1_AST) -- OK

  putTextLn $ showAST (demultiply (distribute $ ((neg 2 .* 5) ::  V2_AST)) :: V1_AST )

  putText $ showAST mulAddVal2
  putText " = "
  putTextLn $ showAST (demultiply $ distribute $ mulAddVal2 :: V1_AST)
  
  putText $ showAST mulAddValFloat
  putText " -> "
  putTextLn $ showAST mulAddValFloat


  putTextLn $ showAST $ setType $ appendEADT @'[TypF] ((3 .+ 5).*5.0 :: V3_AST)

  putTextLn $ show $ showAST <$> parseMaybe parser "(3+1)*15.0"
  putTextLn $ show $ interpret "((2+1)*5.0)"

  putTextLn $ traceShowId "ok"
