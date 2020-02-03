module Lib
    (Tree(TOp,TInt)
    ,swap
    ,calc) where

data Tree =
    TInt Integer
  | TOp String Tree Tree
  deriving (Eq)

instance Show Tree where
   show (TInt i) = show i
   show (TOp s t1 t2) = "(" ++ s ++ " " ++ show t1 
                            ++ " " ++ show t2 ++ ")"

-- Your code here!

swap :: Tree -> Tree
swap (TInt i) = (TInt i) 
swap (TOp op t1 t2) = (TOp op (swap t2) (swap t1))

calc :: Tree -> Integer
calc (TInt i) = i

calc (TOp s (TInt a) (TInt b)) 
  | s == "+" = a + b 
  | s == "-" = a - b
  | s == "*" = a * b 

calc (TOp s (TInt a)  b) 
  | s == "+" = a + calc b 
  | s == "-" = a - calc b 
  | s == "*" = a * calc b

calc (TOp s a (TInt b)) 
  | s == "+" = calc a + b 
  | s == "-" = calc a - b 
  | s == "*" = calc a * b 

calc (TOp s a b) 
  | s == "+" = calc a + calc b
  | s == "-" = calc a - calc b 
  | s == "*" = calc a * calc b 






