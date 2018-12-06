-- | Functions for generating random typed arrays.

module Data.ArrayBuffer.Typed.Gen where

import Data.ArrayBuffer.Types
  ( Uint8ClampedArray, Uint8Array, Uint16Array, Uint32Array
  , Int8Array, Int16Array, Int32Array
  , Float32Array, Float64Array
  )
import Data.ArrayBuffer.Typed as TA

import Prelude
import Math as M
import Data.Maybe (Maybe (..))
import Data.List.Lazy (replicateM)
import Data.Int as I
import Data.String.CodeUnits as S
import Data.Float.Parse (parseFloat)
import Data.Array as Array
import Control.Monad.Gen.Class (class MonadGen, sized, chooseInt, chooseFloat)
import Partial.Unsafe (unsafePartial)


arbitraryUint8ClampedArray :: forall m. MonadGen m => m Uint8ClampedArray
arbitraryUint8ClampedArray = sized \s ->
   TA.fromArray <<< Array.fromFoldable <$> replicateM s arbitraryUByte

arbitraryUint32Array :: forall m. MonadGen m => m Uint32Array
arbitraryUint32Array = sized \s ->
   TA.fromArray <<< Array.fromFoldable <$> replicateM s arbitraryUWord

arbitraryUint16Array :: forall m. MonadGen m => m Uint16Array
arbitraryUint16Array = sized \s ->
   TA.fromArray <<< Array.fromFoldable <$> replicateM s arbitraryUNibble

arbitraryUint8Array :: forall m. MonadGen m => m Uint8Array
arbitraryUint8Array = sized \s ->
   TA.fromArray <<< Array.fromFoldable <$> replicateM s arbitraryUByte

arbitraryInt32Array :: forall m. MonadGen m => m Int32Array
arbitraryInt32Array = sized \s ->
   TA.fromArray <<< Array.fromFoldable <$> replicateM s arbitraryWord

arbitraryInt16Array :: forall m. MonadGen m => m Int16Array
arbitraryInt16Array = sized \s ->
   TA.fromArray <<< Array.fromFoldable <$> replicateM s arbitraryNibble

arbitraryInt8Array :: forall m. MonadGen m => m Int8Array
arbitraryInt8Array = sized \s ->
   TA.fromArray <<< Array.fromFoldable <$> replicateM s arbitraryByte

arbitraryFloat32Array :: forall m. MonadGen m => m Float32Array
arbitraryFloat32Array = sized \s ->
   TA.fromArray <<< Array.fromFoldable <$> replicateM s arbitraryFloat32

arbitraryFloat64Array :: forall m. MonadGen m => m Float64Array
arbitraryFloat64Array = sized \s ->
   TA.fromArray <<< Array.fromFoldable <$> replicateM s arbitraryFloat64




arbitraryUByte :: forall m. MonadGen m => m Int
arbitraryUByte = chooseInt 0 ((I.pow 2 8) - 1)

arbitraryByte :: forall m. MonadGen m => m Int
arbitraryByte =
  let j = I.pow 2 4
  in  chooseInt (negate j) (j - 1)

arbitraryUNibble :: forall m. MonadGen m => m Int
arbitraryUNibble = chooseInt 0 ((I.pow 2 16) - 1)

arbitraryNibble :: forall m. MonadGen m => m Int
arbitraryNibble =
  let j = I.pow 2 8
  in  chooseInt (negate j) (j - 1)

arbitraryUWord :: forall m. MonadGen m => m Number
arbitraryUWord = M.round <$> chooseFloat 0.0 ((M.pow 2.0 32.0) - 1.0)

arbitraryWord :: forall m. MonadGen m => m Int
arbitraryWord =
  let j = I.pow 2 16
  in  chooseInt (negate j) (j - 1)

arbitraryFloat32 :: forall m. MonadGen m => m Number
arbitraryFloat32 =
  let maxFloat32 = (1.0 - (M.pow 2.0 (-24.0))) * (M.pow 2.0 128.0)
      minFloat32 = -maxFloat32 -- because of sign bit
      reformat :: String -> String
      reformat s =
        let pre = S.takeWhile (\c -> c /= '.') s
            suf = S.dropWhile (\c -> c /= '.') s
        in  pre <> "." <> S.take 6 suf
      fix :: Number -> Number
      fix x = unsafePartial $ case parseFloat (reformat (show x)) of
        Just y -> y
  in  fix <$> chooseFloat minFloat32 maxFloat32
  -- roughly estimated because of variable precision between 6 and 9 digs

arbitraryFloat64 :: forall m. MonadGen m => m Number
arbitraryFloat64 = chooseFloat (-1.7e308) 1.7e308
