/-
Copyright (c) 2022 Mac Malone. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mac Malone
-/
import Lake.Build.Common

namespace Lake

/-- Get the Lean library in the workspace with the configuration's name. -/
@[inline] def LeanLibConfig.get (self : LeanLibConfig)
[Monad m] [MonadError m] [MonadLake m] : m LeanLib := do
  let some lib ← findLeanLib? self.name
    | error "Lean library '{self.name}' does not exist in the workspace"
  return lib

/-- Fetch the build result of a library facet. -/
@[inline] protected def LibraryFacetDecl.fetch (lib : LeanLib)
(self : LibraryFacetDecl) [FamilyOut LibraryData self.name α] : IndexBuildM α := do
  fetch <| lib.facet self.name

/-- Fetch the build job of a library facet. -/
def LibraryFacetConfig.fetchJob (lib : LeanLib)
(self : LibraryFacetConfig name) : IndexBuildM (BuildJob Unit) :=  do
  let some getJob := self.getJob?
    | error "library facet '{self.name}' has no associated build job"
  return getJob <| ← fetch <| lib.facet self.name

/-- Fetch the build job of a library facet. -/
def LeanLib.fetchFacetJob
(name : Name) (self : LeanLib) : IndexBuildM (BuildJob Unit) :=  do
  let some config := (← getWorkspace).libraryFacetConfigs.find? name
    | error "library facet '{name}' does not exist in workspace"
  inline <| config.fetchJob self

/-! # Build Lean & Static Lib -/

/--
Collect the local modules of a library.
That is, the modules from `getModuleArray` plus their local transitive imports.
-/
partial def LeanLib.recCollectLocalModules (self : LeanLib) : IndexBuildM (Array Module) := do
  let mut mods := #[]
  let mut modSet := ModuleSet.empty
  for mod in (← self.getModuleArray) do
    (mods, modSet) ← go mod mods modSet
  return mods
where
  go root mods modSet := do
    let mut mods := mods
    let mut modSet := modSet
    unless modSet.contains root do
      modSet := modSet.insert root
      let imps ← root.imports.fetch
      for mod in imps do
        if self.isLocalModule mod.name then
          (mods, modSet) ← go mod mods modSet
      mods := mods.push root
    return (mods, modSet)

/-- The `LibraryFacetConfig` for the builtin `modulesFacet`. -/
def LeanLib.modulesFacetConfig : LibraryFacetConfig modulesFacet :=
  mkFacetConfig LeanLib.recCollectLocalModules

protected def LeanLib.recBuildLean
(self : LeanLib) : IndexBuildM (BuildJob Unit) := do
  let mods ← self.modules.fetch
  mods.foldlM (init := BuildJob.nil) fun job mod => do
    job.mix <| ← mod.leanBin.fetch

/-- The `LibraryFacetConfig` for the builtin `leanFacet`. -/
def LeanLib.leanFacetConfig : LibraryFacetConfig leanFacet :=
  mkFacetJobConfigSmall LeanLib.recBuildLean

protected def LeanLib.recBuildStatic
(self : LeanLib) : IndexBuildM (BuildJob FilePath) := do
  let mods ← self.modules.fetch
  let oJobs ← mods.concatMapM fun mod =>
    mod.nativeFacets.mapM fun facet => fetch <| mod.facet facet.name
  buildStaticLib self.staticLibFile oJobs

/-- The `LibraryFacetConfig` for the builtin `staticFacet`. -/
def LeanLib.staticFacetConfig : LibraryFacetConfig staticFacet :=
  mkFacetJobConfig LeanLib.recBuildStatic

/-! # Build Shared Lib -/

protected def LeanLib.recBuildShared
(self : LeanLib) : IndexBuildM (BuildJob FilePath) := do
  let mods ← self.modules.fetch
  let oJobs ← mods.concatMapM fun mod =>
    mod.nativeFacets.mapM fun facet => fetch <| mod.facet facet.name
  let pkgs := mods.foldl (·.insert ·.pkg) OrdPackageSet.empty |>.toArray
  let externJobs ← pkgs.concatMapM (·.externLibs.mapM (·.shared.fetch))
  buildLeanSharedLib self.sharedLibFile (oJobs ++ externJobs) self.linkArgs

/-- The `LibraryFacetConfig` for the builtin `sharedFacet`. -/
def LeanLib.sharedFacetConfig : LibraryFacetConfig sharedFacet :=
  mkFacetJobConfig LeanLib.recBuildShared

open LeanLib in
/--
A library facet name to build function map that contains builders for
the initial set of Lake library facets (e.g., `lean`, `static`, and `shared`).
-/
def initLibraryFacetConfigs : DNameMap LibraryFacetConfig :=
  DNameMap.empty
  |>.insert modulesFacet modulesFacetConfig
  |>.insert leanFacet leanFacetConfig
  |>.insert staticFacet staticFacetConfig
  |>.insert sharedFacet sharedFacetConfig
