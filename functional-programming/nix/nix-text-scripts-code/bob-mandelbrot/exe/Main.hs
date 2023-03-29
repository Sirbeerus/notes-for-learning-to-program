{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE TypeFamilies              #-}


module Main where

import Data.Complex
import Diagrams.Backend.SVG.CmdLine
import Diagrams.Prelude hiding (magnitude,image)

quadratic c z = z*z + c

critical_orbit :: Complex Double -> [Complex Double]
critical_orbit z = iterate (quadratic z) 1

pixel = length . takeWhile (\z -> magnitude z <= 2) . take maxIter
maxIter = 132
edge = 28

side n v0 v1 =
   let sv = (v1 - v0) / fromIntegral n
   in  [v0, (v0 + sv) .. v1]

sideX = side edge (-5) 2
sideY = side edge (-5) 2

grid = map (\y -> map (:+ y) sideX) sideY

image = map (map (toSquare . pixel . critical_orbit)) grid

toSquare n = square 1 # lw medium # fc green # opacity (sqrt o)
  where o = fromIntegral n / maxIter

example = (vcat . map hcat $ image) # bgFrame 3 white

main = mainWith (example :: Diagram B)




















{-
        # origninal

{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE TypeFamilies              #-}


module Main where

import Data.Complex
import Diagrams.Backend.SVG.CmdLine
import Diagrams.Prelude hiding (magnitude,image)

quadratic c z = z*z + c

critical_orbit :: Complex Double -> [Complex Double]
critical_orbit z = iterate (quadratic z) 0

pixel = length . takeWhile (\z -> magnitude z <= 2) . take maxIter
maxIter = 32
edge = 128

side n v0 v1 =
   let sv = (v1 - v0) / fromIntegral n
   in  [v0, (v0 + sv) .. v1]

sideX = side edge (-2) 2
sideY = side edge (-2) 2

grid = map (\y -> map (:+ y) sideX) sideY

image = map (map (toSquare . pixel . critical_orbit)) grid

toSquare n = square 1 # lw medium # fc green # opacity (sqrt o)
  where o = fromIntegral n / maxIter

example = (vcat . map hcat $ image) # bgFrame 3 white

main = mainWith (example :: Diagram B)

