
const PROPERTIES_MAP = Dict{Symbol,Type{<:AbstractParams}}(
  :tilt0 =>  BMultipoleParams,
  :tilt1 =>  BMultipoleParams,
  :tilt2 =>  BMultipoleParams,
  :tilt3 =>  BMultipoleParams,
  :tilt4 =>  BMultipoleParams,
  :tilt5 =>  BMultipoleParams,
  :tilt6 =>  BMultipoleParams,
  :tilt7 =>  BMultipoleParams,
  :tilt8 =>  BMultipoleParams,
  :tilt9 =>  BMultipoleParams,
  :tilt10 => BMultipoleParams,
  :tilt11 => BMultipoleParams,
  :tilt12 => BMultipoleParams,
  :tilt13 => BMultipoleParams,
  :tilt14 => BMultipoleParams,
  :tilt15 => BMultipoleParams,
  :tilt16 => BMultipoleParams,
  :tilt17 => BMultipoleParams,
  :tilt18 => BMultipoleParams,
  :tilt19 => BMultipoleParams,
  :tilt20 => BMultipoleParams,
  :tilt21 => BMultipoleParams,

  :L => UniversalParams,
  :tracking_method => UniversalParams,
  :class => UniversalParams,
  :name => UniversalParams,

  :beamline => BeamlineParams,
  :beamline_index => BeamlineParams,
  :R_ref => BeamlineParams, 
  :species => BeamlineParams,
  :s => BeamlineParams,
  :s_downstream => BeamlineParams,

  :g_ref => BendParams,
  :tilt_ref => BendParams,
  :e1 => BendParams,
  :e2 => BendParams,

  :x_offset => AlignmentParams,
  :y_offset => AlignmentParams,
  :z_offset => AlignmentParams,
  :x_rot => AlignmentParams,
  :y_rot => AlignmentParams,
  :tilt => AlignmentParams,

  :dt => PatchParams,
  :dx => PatchParams,
  :dy => PatchParams,
  :dz => PatchParams,
  :dx_rot => PatchParams,
  :dy_rot => PatchParams,
  :dz_rot => PatchParams,

  :x1_limit       => ApertureParams,
  :x2_limit       => ApertureParams,
  :y1_limit       => ApertureParams,
  :y2_limit       => ApertureParams,
  :aperture_shape => ApertureParams,
  :aperture_at    => ApertureParams,
  :aperture_shifts_with_body => ApertureParams,

  :voltage => RFParams,
  :phi0 => RFParams,
  :harmon_master => RFParams,
)

const PARAMS_MAP = Dict{Symbol,Type{<:AbstractParams}}(
  :BMultipoleParams => BMultipoleParams,
  :UniversalParams => UniversalParams,
  :BeamlineParams => BeamlineParams,
  :BendParams => BendParams,
  :AlignmentParams => AlignmentParams,
  :PatchParams => PatchParams,
  :RFParams => RFParams,
  :ApertureParams => ApertureParams,
)



# Maybe we can do some trickery with FunctionWrappers
# but that will require us to Kow the return type...

# This solution is MUCH faster than AL
# AND no bookkeeper :)
