module Lib
    ( mkGroup
    , IntSet
    , fix
    ) where

import Data.HashSet as S

type IntSet = S.HashSet Int


-- mkGroup -- given a modulus and a set of elements, it returns a new set in which every pair of elements
-- has been multiplied together and added to the original.
--
-- e.g. mkGroup 10 (S.fromList [2,3]) would yield set [2,3,6]


mkGroup :: Int -> IntSet -> IntSet
mkGroup modulus elements =
   S.union elements (S.fromList [(x * y) `mod` modulus | x <- S.toList elements, y <- S.toList elements])

-- fix -- given a function, takes a parameter x (think of it as an initial guess) and returns the fix-point of the function.

-- fix :: (a -> a) -> a -> a
fix f x 
    | g == x = x 
    | otherwise = fix f g 
    where g = f x 


