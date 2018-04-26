{-# LANGUAGE TypeApplications #-}

module Hastory.Cli.Commands.SuggestionSpec
    ( spec
    ) where

import TestImport

import qualified Data.Text as T
import Safe (tailSafe)
import Test.Validity (forAllValid)

import Data.Hastory.Gen ()
import Data.Hastory

import Hastory.Cli.Commands.SuggestAlias

spec :: Spec
spec = do
    describe "Entry" $ do
        eqSpec @Entry
        jsonSpecOnValid @Entry
        arbitrarySpec @Entry
        genValiditySpec @Entry
    describe "commandPrefixes" $ do
        it "lists only prefixes of the command, ignoring whitespace" $
            forAllValid $ \e ->
            map T.concat (commandPrefixes e) `shouldSatisfy`
            all (`T.isPrefixOf` T.concat (T.words $ entryText e))
        it "contains only nonempty prefixes" $ forAllValid $ \e ->
            commandPrefixes e `shouldSatisfy`
            all (\p -> not $ null p || any T.null p)
    describe "aggregateSuggestions" $ do
        it "counts each command exactly once" $ forAllValid $ \es ->
            sum (map (round . snd) (aggregateSuggestions (es :: [T.Text]))) `shouldBe`
            length es
        it "is sorted by nonincreasing frequency" $ forAllValid $ \es ->
            map snd (aggregateSuggestions (es :: [T.Text])) `shouldSatisfy` and .
            (zipWith (>=) <*> tailSafe)