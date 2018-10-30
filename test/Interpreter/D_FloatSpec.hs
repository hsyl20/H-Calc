{-# LANGUAGE NoImplicitPrelude #-}
module Interpreter.D_FloatSpec (spec) where


  import Test.Hspec
  import Control.Exception (evaluate)
  import Relude
  
  spec :: Spec
  spec = do
    describe "Prelude.head" $ do
      it "returns the first element of a list" $ do
        viaNonEmpty head [23 ..] `shouldBe` (Just $ 23 :: Maybe Int)
  