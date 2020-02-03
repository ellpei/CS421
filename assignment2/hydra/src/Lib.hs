module Lib
    (chop) where
        
-- chop :: [Int] -> [Int]

chop :: [Int] -> [Int]
chop heads  
    | length chopped /= length heads = leftpad chopped (length heads)
    | otherwise = chopped
    where chopped = chopHelp heads

chopHelp :: [Int] -> [Int]
chopHelp [] = [] 
chopHelp [a] 
    | a == 0 = [0]
    | a > 0 = [a-1]
chopHelp (a:b:xs)  
    | sum (a:b:xs) == 0 = (a:b:xs)
    | a > 0 = [a-1] ++ [b+ (length (a:b:xs)-1)] ++ xs
    | otherwise = chopHelp (b:xs)  

leftpad :: [Int] -> Int -> [Int]
leftpad list len
    | length list == len = list 
    | length list < len = leftpad (0:list) len


