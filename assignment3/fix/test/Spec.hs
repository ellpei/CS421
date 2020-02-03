import Test.Framework (defaultMain, testGroup)
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Lib
import Test.QuickCheck
import qualified Data.HashSet as S

main :: IO ()
main = defaultMain tests

fixCos = 0.7390851332151607

tests = [
        testGroup "=G= Fix Cos" [
                testProperty "=P= Always returns 0.7390851332151607" propFixCos
        ]
        ,
        testGroup "=G= Fix mkGroup" [
                testProperty "=P= mkGroup doesn't add anything else" propMkGroupIdempotent
        ,       testProperty "=P= mkGroup on initial gets same result" propMkGroupNoneMissing
        ]
      ]

propFixCos :: Double -> Bool
propFixCos x =
      fix cos x == fixCos

propMkGroupIdempotent :: Int -> Int -> Int -> Bool
propMkGroupIdempotent md a b =
   let md' = md `mod` 100 + 10
       a' = a `mod` 99 + 1
       b' = b `mod` 99 + 1
       result = fix (mkGroup md') (S.fromList [a',b'])
    in result == mkGroup md' result

iter :: Int -> (a -> a) -> a -> a
iter 0 f x = x
iter n f x = iter (n-1) f (f x)

propMkGroupNoneMissing md a b =
   let md' = md `mod` 100 + 10
       a' = a `mod` 99 + 1
       b' = b `mod` 99 + 1
       result = iter md' (mkGroup md') (S.fromList [a',b'])
    in result == fix (mkGroup md') (S.fromList [a',b'])

