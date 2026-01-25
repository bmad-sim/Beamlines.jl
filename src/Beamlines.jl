module Beamlines
export AbstractParams, 
       LineElement, 
       Bunch, 
       ParamDict, 
       UniversalParams, 
       BMultipoleParams, 
       BeamlineParams,
       AlignmentParams,
       PatchParams,
       BendParams,
       InheritParams,
       ApertureParams,
       MapParams,
       FourPotentialParams,
       MetaParams,
       ApertureAt,
       ApertureShape,
       PhaseReference,
       RFParams,
       BMultipole,
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
       Beamline,
       Controller,
       Patch,
       set!,
       Lattice,

       deepcopy_no_beamline,
       
       # BitsBeamline, 

       SciBmadStandard,

       @eles, # deprecated, to be removed in next breaking release
       
       @elements, 
       elements,

       scalarize,
       scalarize!

using Accessors, 
      AtomicAndPhysicalConstants,
      StaticArrays, 
      OrderedCollections,
      MacroTools,
      EnumX,
      ReadOnlyArrays,
      PrettyTables

export Species

using FunctionWrappers: FunctionWrapper

# Note that LineElement and parameter structs have three things:
# 1) Fields: These are actual fields within a struct, e.g. pdict in LineElement
# 2) Properties: These are "fields" within a struct that aren't actual fields, but can 
#                be get/set using the dot syntax and/or getproperty/setproperty!. 
#                E.g., the default fallback for getproperty is getfield
# 3) Virtual properties: These are values that only exist for parameter structs within 
#                        a LineElement type, and can be calculated using different 
#                        parameter structs within the LineElement. E.g. the normalized 
#                        field strengths requires BMultipoleParams and BeamlineParams.

# Often, quantities can be get/set as properties, and NOT virtual properties.
# For example, the s position of an element can be PROPERTY of the BeamlineParams 
# struct as one can sum the lengths of each preceding element in the Beamline.

include("defexpr.jl")
include("element.jl")
include("beamline.jl")
include("scalarize.jl")
include("multipole.jl")
include("rf.jl")
include("bend.jl")
include("virtual.jl")
include("control.jl")
include("alignment.jl")
include("patch.jl")
include("aperture.jl")
include("misc.jl")
include("keymaps.jl")
include("element-name-handling.jl")

# BitsBeamline is no longer supported
# Support may continue in the future with 
# developer support
# include("bits/bitsparams.jl")
# include("bits/bitstracking.jl")
# include("bits/bitsline.jl")
# include("bits/bitselement.jl")


end
