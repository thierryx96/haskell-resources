module Lib.Utils
    ( toLower,
      maybeToEither,
      getEnv',
      leftToMaybe
    ) where

import qualified Data.Char as C (toLower)
import           System.Environment

toLower :: String -> String
toLower s = [ C.toLower toLower | toLower <- s]

maybeToEither :: a -> Maybe b -> Either a b
maybeToEither = flip maybe Right . Left

leftToMaybe :: Either a b -> Maybe a
leftToMaybe = either Just (const Nothing)

getEnv' :: String -> IO (Either String String)
getEnv' name = fmap (maybeToEither $ "missing env: " ++ name) (lookupEnv name)
