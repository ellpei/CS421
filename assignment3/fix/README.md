---
codePackageName: activities/fixpoint
requiredUploadFileNames:
- Lib.hs
title: "Fix-Point Activity"
---

Suppose you enter a number into your calculator and hit the `cos` button
over and over.  Eventually, the number will converge and no longer change.
This number is the *fix-point* for `cos`.  There are many functions that
have fix-points, some of which we will use in this course.

Your job is to write a function `fix :: (a -> a) -> a -> a` that takes
a function `f` and an initial value `x`, and returns the fix-point of
that function.

We will run two test groups.  First, we will call `fix cos` on a bunch
of random integers and see that they all get the proper fix-point.

Next, we have a function `mkGroup` that takes a size `m` and a Hash Set of
initial values, and closes the group under multiplication modulo `m`.
In case you were wondering, you do that by taking multiples of the base
elements with each other modulo the size until you find them all.
Don't worry; you don't have to understand any of that.. just write `fix`
and everything will be okay.

You should also look at the Hash Set code; you don't need to understand
it now, but it will be useful later.

Here's some examples of `mkGroup` in action:

```haskell
*Lib Lib> Lib.mkGroup 17 (S.fromList [2,3])                                                                                                                   
fromList [2,3,4,6,9]                                                                                                                                          
*Lib Lib> fix (Lib.mkGroup 17) (S.fromList [2,3])                                                                                                             
fromList [16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]                                                                                                             
*Lib Lib> fix (Lib.mkGroup 17) (S.fromList [2,4])                                                                                                             
fromList [16,1,2,4,8,9,13,15]
```
You can try these examples yourself by running `stack repl`.

To test the code, run `stack test`.  We have given you the same test suite
we will use.

Place your function `fix` into `src/Lib.hs`. 
