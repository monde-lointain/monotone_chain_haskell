# Monotone Chain Convex Hull Solver

Haskell implementation of the monotone chain convex hull solver. The solver takes a raw binary array of 2D points, consisting of signed 32-bit integers as input. Sample input files consisting of random points can be generated using `Pointgen.hs`.

## Building
Ensure you have GHC (Glasgow Haskell Compiler) and Cabal installed. Then, navigate to the project directory and run:

``` bash
cabal build
```

This will build both debug and release versions of the executables.

## Current Limitations
The program does not currently check for degenerate edges. Arrays of densely clustered points will get errors when being evaluated.

Only 32-bit signed integers are supported for point components. Floating point and other size integer types are not currently supported.
