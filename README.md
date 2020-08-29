# Refs:

- official cheat sheet : https://hackage.haskell.org/package/CheatSheet-1.11/src/CheatSheet.pdf
- http://learnyouahaskell.com/chapters

## String Types 

**String: [Char]**
- strict list (Data.List) of chars [Char]
- inefficient (memory allocated for each definition)
- use case: every string that does not need heavy processing

```
s :: String
s = "Hello"

>> map Data.Char.toUpper s
“HELLO”

>> ‘x’ : a
“xHello”

>> a ++ “ Person!”

“Hello Person!”

>> Data.List.sort “dbca”
“abcd”
```

**Text: Data.Text/Data.Text.Lazy**
- Compiler use "Fusion" to avoid multiple allocation
- String that require processing

```
import qualified Data.Text as T
import qualified Data.Char as C

t :: T.Text
t = T.cons ‘c’ (T.map C.toLower (T.append (T.Text “Hello “) (T.Text “ Person!”)))
```

**Bytestrings: Data.ByteString/Data.ByteString.Lazy**
- List of `Word8` objects (8 bits number)
- Low level representation of string (network, serialization, database)


## String/Text/Bytestring Conversions

**String <-> Text (Data.Text/Data.Text.Lazy)**
```
import Data.Text

pack :: String -> Text
unpack :: Text -> String
```

**String <-> ByteString (Data.ByteString.Char8 - strict only)**
```
import Data.ByteString.Char8

pack :: String -> ByteString
unpack :: ByteString -> String
```

**Text (Data.Text) <-> Text (Data.Text.Lazy)**

```
import Data.Text.Lazy
toStrict :: Data.Text.Lazy.Text -> Data.Text.Text -- (Lazy to strict)
fromStrict :: Data.Text.Text -> Data.Text.Lazy.Text -- (Strict to lazy)
```

**ByteString (Data.ByteString) <-> Text (Data.ByteString.Lazy)**
```
import Data.ByteString.Lazy
toStrict ...
fromStrict ...
```

**Text (Data.Text) <-> ByteString (Data.ByteString)**
Text -> Bytestring (data format must be known)
```
import Data.Text.Encoding
encodeUtf8 :: Text -> ByteString

-- LE = Little Endian format, BE = Big Endian
encodeUtf16LE :: Text -> ByteString
encodeUtf16BE :: Text -> ByteString
encodeUtf32LE :: Text -> ByteString
encodeUtf32BE :: Text -> ByteString
```

Bytestring -> Text (data format must be known, can throw error is BS does not match format)
```
import Data.Text.Encoding

-- unsafe
decodeUtf8 :: ByteString -> Text
decodeUtf16LE :: ByteString -> Text
decodeUtf16BE :: ByteString -> Text
decodeUtf32LE :: ByteString -> Text
decodeUtf32BE :: ByteString -> Text

-- safe
decodeUtf8’ :: ByteString -> Either UnicodeException Text

```

**String Language Extensions (OverloadedStrings)**

```
-- Fails
myText :: Text
myText = “Hello”

myBytestring :: ByteString
myBytestring = “Hello”
```
```
{-# LANGUAGE OverloadedStrings #-}
-- This works!
myText :: Text
myText = “Hello”

myBytestring :: ByteString
myBytestring = “Hello”
```

Make any new type  string assignable
```
import qualified Data.String (IsString(..))

data MyType = MyType String

instance IsString MyType where
  fromString s = MyType s

myTypeAsString :: MyType
myTypeAsString = “Hello”
```
## Monad transformers [mtl]

**ExceptT**
An Either e a wrapped in any other monad, i.e. m (Either e a)


`ExceptT :: m (Either e a) -> ExceptT m Either e a`. e.g. `IO (Either String Int) -> ExceptT IO Either String Int`
`liftIO :: m a -> ExceptT m Right a` 

```
getInt :: IO (Either String Int)


runExceptT $ do -- converts: ExceptT IO Either String Int -> IO Either String Int
  i <- ExceptT getInt -- IO (Either String Int) -> ExceptT IO Either String Int
  liftIO $ print "XXX" -- -> IO() -> ExceptT IO Right Either String ()
  pure i
```

**MaybeT**

```
import Control.Monad 
import Control.Monad.Trans.Maybe 
import Control.Monad.Trans.Class 

main = do 
  password <- runMaybeT getPassword
  case password of 
    Just p  -> putStrLn "valid password!"
    Nothing -> putStrLn "invalid password!"

isValid :: String -> Bool
isValid = (>= 10) . length

getPassword :: MaybeT IO String 
getPassword = do 
  password <- lift getLine -- :: IO String -> MaybeT IO String
  guard (isValid password)
  return password 
```


## Imports

Getting all of this straight in your head is quite tricky, so here is a table (lifted directly from the language reference manual) that roughly summarises the various possibilities:

Supposing that the module Mod exports four functions named x, y, z, and (+++)...
```
Import command	What is brought into scope	Notes
import Mod	x, y, z, (+++), Mod.x, Mod.y, Mod.z, (Mod.+++)	(By default, qualified and unqualified names.)
import Mod ()	(Nothing!)	(Useful for only importing instances of typeclasses and nothing else)
import Mod (x,y, (+++))	x, y, (+++), Mod.x, Mod.y, (Mod.+++)	(Only x, y, and (+++), no z.)
import qualified Mod	Mod.x, Mod.y, Mod.z, (Mod.+++)	(Only qualified versions; no unqualified versions.)
import qualified Mod (x,y)	Mod.x, Mod.y	(Only x and y, only qualified.)
import Mod hiding (x,y,(+++))	z, Mod.z	(x and y are hidden.)
import qualified Mod hiding (x,y)	Mod.z, (Mod.+++)	(x and y are hidden.)
import Mod as Foo	x, y, z, (+++), Foo.x, Foo.y, Foo.z, (Foo.+++)	(Unqualified names as before. Qualified names use Foo instead of Mod.)
import Mod as Foo (x,y)	x, y, Foo.x, Foo.y	(Only import x and y.)
import qualified Mod as Foo	Foo.x, Foo.y, Foo.z, (Foo.+++)	(Only qualified names, using new qualifier.)
import qualified Mod as Foo (x,y)	Foo.x, Foo.y	(Only qualified versions of x and y, using new qualifier)
```




