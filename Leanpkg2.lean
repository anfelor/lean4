/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner, Sebastian Ullrich, Mac Malone
-/
import Leanpkg2.Cli

def main (args : List String) : IO UInt32 := do
  try
    /-
      Initializes the search path the Leanpkg2 executable
      uses when intepreting package configuration files.

      Also, in order to find the Lean stdlib (e.g., `Init`),
      the executable needs to be either colocated with Lean or
      have LEAN_PATH include the directory with its dynamic libraries.
    -/
    Lean.initSearchPath none
    let (cmd, outerArgs, innerArgs) ← Leanpkg2.splitCmdlineArgs args
    Leanpkg2.cli cmd outerArgs innerArgs
    pure 0
  catch e =>
    IO.eprintln e  -- avoid "uncaught exception: ..."
    pure 1
