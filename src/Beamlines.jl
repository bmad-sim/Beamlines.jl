module Beamlines
export AbstractParams, 
       LatElement, 
       ParamDict, 
       UniversalParams, 
       BMultipoleParams, 
       EMultipoleParams,
       BeamlineParams,
       InitialBeamlineParams,
       AlignmentParams,
       PatchParams,
       BendParams,
       InheritParams,
       ApertureParams,
       MapParams,
       FourPotentialParams,
       EMFieldParams,
       MetaParams,
       IgnoreParams,
       IBSParams,
       ApertureAt,
       ApertureShape,
       PhaseRef,
       RateMeaning,
       RFParams,
       BMultipole,
       EMultipole,
       DefExpr,
       Drift,
       Solenoid,
       Quadrupole,
       Sextupole,
       Octupole,
       Multipole,
       Marker,
       SBend,
       Kicker,
       HKicker,
       VKicker,
       RFCavity,
       CrabCavity,
       BeamBeam,
       BPM,
       Map,
       Patch,
       Beamline,
       Context,
       Controller,
       set!,
       Branch,
       Lattice,

       deepcopy_no_beamline,
       
       @elements, 
       elements,

       scalarize,
       scalarize!,
       scalarize_all,
       scalar_max,
       scalar_min,

       findchildren,
       findelements,
       findbranches,

       GLOBAL_CONTEXTS,

       Fringe,
       IBSModel,

       DriftKick, MatrixKick, BendKick, SolenoidKick, Implicit, Exact, 
        SaganCavity, RK4


using Accessors, 
      AtomicAndPhysicalConstants,
      StaticArrays, 
      OrderedCollections,
      MacroTools,
      EnumX,
      ReadOnlyArrays,
      PrettyTables
      
using DataStructures: Stack

export Species

using FunctionWrappers: FunctionWrapper

# Note that LatElement and parameter structs have three things:
# 1) Fields: These are actual fields within a struct, e.g. pdict in LatElement
# 2) Properties: These are "fields" within a struct that aren't actual fields, but can 
#                be get/set using the dot syntax and/or getproperty/setproperty!. 
#                E.g., the default fallback for getproperty is getfield
# 3) Virtual properties: These are values that only exist for parameter structs within 
#                        a LatElement type, and can be calculated using different 
#                        parameter structs within the LatElement. E.g. the normalized 
#                        field strengths requires BMultipoleParams and BeamlineParams.

# Often, quantities can be get/set as properties, and NOT virtual properties.
# For example, the s position of an element can be PROPERTY of the BeamlineParams 
# struct as one can sum the lengths of each preceding element in the Beamline.

include("utils.jl")
include("energy.jl")
include("tracking_methods.jl")
include("context.jl")
include("defexpr.jl")
include("abstractparams.jl")
include("universal.jl")
include("element.jl")
include("element_kinds.jl")
include("beamline.jl")
include("branch.jl")
include("scalarize.jl")
include("bmultipole.jl")
include("emultipole.jl")
include("rf.jl")
include("bend.jl")
include("virtual.jl")
include("control.jl")
include("alignment.jl")
include("patch.jl")
include("aperture.jl")
include("ibs.jl")
include("misc.jl")
include("ignore.jl")
include("keymaps.jl")
include("element_name_handling.jl")
include("search.jl")
include("name_matching.jl")
include("element_doc.jl")
include("io.jl")

# BitsBeamline is no longer supported
# Support may continue in the future with 
# developer support
# include("bits/bitsparams.jl")
# include("bits/bitstracking.jl")
# include("bits/bitsline.jl")
# include("bits/bitselement.jl")


end