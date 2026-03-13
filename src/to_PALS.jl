# This is a reference to the number of the next available placeholder
# number to be assigned to unnamed elements
const PLACEHOLDER_NUM = Ref(1)

# This maps types of `AbstractParams` to the symbol representing its PALS-format name
const PARAMTYPES_TO_PALSNAMES_MAP = Dict{Type{<:AbstractParams}, Symbol}(
    BMultipoleParams => :MagneticMultipoleP,
    ApertureParams => :ApertureP,
    MetaParams => :MetaP,
    AlignmentParams => :BodyShiftP,
    BendParams => :BendP,
    RFParams => :RFP,
    PatchParams => :PatchP
)

#= TODO =#
#= 
This maps symbols of names of parameter names as they appear in 
SciBmad to the symbol of the name in PALS. If a SciBmad parameter
name isn't in this dictionary, it means that its name in PALS
is the same (or this needs to be updated). Symbols that map to
symbols that have "SciBmad" at the beginning indicate parameters
in SciBmad that don't have an equivalent in PALS.
=#
const SCIBMAD_NAME_TO_PALS_NAME_MAP = Dict{Symbol, Symbol}(
    # PatchP...
    :dx => :x_offset,
    :dy => :y_offset,
    :dz => :z_offset,
    :dx_rot => :x_rot,
    :dy_rot => :y_rot,
    :dz_rot => :z_rot,
    :dt => :SciBmad_dt,     # *
    # ApertureP...
    :x1_limit => :x_min,
    :x2_limit => :x_max,
    :y1_limit => :y_min,
    :y2_limit => :y_max,
    :aperture_shape => :shape,
    :aperture_at => :location,
    # RFP...
    :harmon_master => :harmon,
    :traveling_wave => :SciBmad_traveling_wave,     # *
    :is_crabcavity => :SciBmad_is_crabcavity,   # *
    # (MapParams) [No PALS group]
    :transport_map => :SciBmad_transport_map,   # *
    :transport_map_params => :SciBmad_transport_map_params,     # *
    # (FourPotentialParams) [No PALS group]
    :four_potential => :SciBmad_four_potential,     # *
)

#= TODO =#
#= 
This maps symbols of names of fields to values, representing the 
default value in PALS of that field, storing defaults that are
"abnormal" for their type, like nonzero values for numeric parameters.
=#
const ABNORMAL_DEFAULT_VALUES_MAP = Dict{Symbol, Any}(
    # PatchP...
    :flexible => false
    # RFP...
    :cavity_type => :STANDING_WAVE
    :n_cell => 1
    :zero_phase => :ACCELERATING
    # ApertureP... (some elements have mismatched names between SciBmad and PALS)
    :x1_limit => :null 
    :x2_limit => :null
    :y1_limit => :null 
    :y2_limit => :null 
    :aperture_shape => ""
    :aperture_at => :ENTRANCE_END
)

"""
    Internal: isdefault(field::Symbol, value)

Returns `true` if `value` is the default value that `field` can represent.
Returns `false` otherwise.

This function is used as a helper function for `scibmad_to_pals()` to 
cut out elements that store no information (besides default values).

`Dict`s' default value is {},
`Vector`s' default value is [],
`Symbol`s' default value is Symbol("")

## Arguments
- `field`   -- A `Symbol` representing the name of a parameter.
- `value`   -- The value stored at `field`
"""
function isdefault(field::Symbol, value)
    # If more defaults need to be accounted for, this may be expanded.

    # `field` is an argument so that way defaults that may be unique
    # to the information of a specific field can be accounted for.
    value_type = typeof(value)

    if (value_type <: OrderedDict)
        # A default dictionary is empty, regardless of its `field`
        return isempty(value)

    elseif (value_type <: Vector)
        # A default vector is empty, regardless of its `field`
        return isempty(value)

    elseif (value_type == Symbol)
        # Any symbol's default value is the empty symbol, regardless of its `field`
        return value === Symbol("")
    end

    # If nothing above has been satisfied, it's not a default value
    return false
end


"""
    Internal: params_to_dict!(format_dict::OrderedDict, parameter_group::T) where {T<:AbstractParams}

Modifies `format_dict` to have a new entry which stores a dictionary whose keys are parameter
names from `parameter_group` and whose values are the initialized values corresponding
to those parameter names.

This function is used as a helper to `scibmad_to_pals()` to create the dictionaries
that store the fields and field values of a parameter group and populate the dictionaries
associated with elements with them.

## Arguments
- `format_dict`     -- The dictionary to be modified which represents the information about a line element.
- `parameter_group` -- An `AbstractParams`` object containing the parameters to extract to `acc`.
"""
function params_to_dict!(format_dict::OrderedDict, parameter_group::T) where {T<:AbstractParams}
    # The accumulator dictionary 
    acc = OrderedDict()
    parameter_type = nothing # This holds the type of the parameter group

    for parameter_name in propertynames(parameter_group)
        if (isnothing(parameter_type))
            # Set the type of the parameter
            if haskey(PROPERTIES_MAP, parameter_name)
                parameter_type = PROPERTIES_MAP[parameter_name]
            end
        end

        if (haskey(SCIBMAD_NAME_TO_PALS_NAME_MAP, parameter_name))
            # Convert the SciBmad parameter name to the equivalent PALS name
            parameter_name = SCIBMAD_NAME_TO_PALS_NAME_MAP[parameter_name]
        end

        if (hasproperty(parameter_group, parameter_name))
            # Get the value stored at that property
            parameter_value = getproperty(parameter_group, parameter_name)

            # If it's a `String`, make it a `Symbol` to remove quotation marks
            if (typeof(parameter_value) == String)
                parameter_value = Symbol(parameter_value)
            end

            acc[parameter_name] = parameter_value
        end
    end

    format_dict[PARAMTYPES_TO_PALSNAMES_MAP[parameter_type]] = acc
end

# Handle BMultipoleParams
function params_to_dict!(format_dict::OrderedDict, parameter_group::BMultipoleParams) 
    # The accumulator dictionary 
    acc = OrderedDict()

    #= This code is from the override of `show()` in multipole.jl =#
    for bm in parameter_group
        n = bm.n
        s = bm.s
        tilt = bm.tilt
        if n != 0
            sym = BMULTIPOLE_STRENGTH_INVERSE_MAP[(true, bm.order, bm.normalized, bm.integrated)]
            acc[sym] = n
        end
        if s != 0
            sym = BMULTIPOLE_STRENGTH_INVERSE_MAP[(false, bm.order, bm.normalized, bm.integrated)]
            acc[sym] = s
        end
        if tilt != 0
            sym = BMULTIPOLE_TILT_INVERSE_MAP[bm.order]
            acc[sym] = tilt
        end
    end
    #= End code from the override of `show()` in multipole.jl =#

    # Modify `format_dict`
    format_dict[:MagneticMultipoleP] = acc
end


"""
    Internal: pals_format(line_element::LineElement) 

Return a dictionary whose single key is `line_element`'s name, storing another dictionary
whose keys are `line_element`'s fields. This is the format desired by PALS.

This function is used as a helper to `scibmad_to_pals()` to create the entry for a single
accelerator element, along with all parameters associated with it.

## Arguments
- `line_element`    -- The `LineElement` being formatted into PALS.
"""
function pals_format(line_element::LineElement) 
    # The accumulator dictionary which will become the final return dictionary
    format_dict = OrderedDict()

    #=
    Access `line_element`'s parameter groups.
    Reminder: A `LineElement`'s `pdict` is a dictionary mapping `AbstractParams` types to objects 
    containing the initialized parameters of `line_element`
    =#
    parameter_groups = getfield(line_element, :pdict)

    # Put `UniversalParams` first, if they exist
    if UniversalParams in keys(parameter_groups)
        #=
        Special case: `UniversalParams` contains basic information that's 
        not displayed inside of another dictionary, it should be at the "top level",
        so handle it here instead of in the helper.
        =#
        parameter_group = parameter_groups[UniversalParams]
        
        # Extract `kind`, if present
        if (hasproperty(parameter_group, :kind))
            format_dict[:kind] = Symbol(getproperty(parameter_group, :kind))
        end

        # Replace `L` with `length`, if it's present
        if (hasproperty(parameter_group, :L))
            format_dict[:length] = getproperty(parameter_group, :L)
        end

        # Put `tracking_method` inside of a "SciBmad" dictionary inside of "TrackingP"
        if (hasproperty(parameter_group, :tracking_method))
            tracking_method = getproperty(parameter_group, :tracking_method) # Get the tracking method
            tracking_method_type = typeof(tracking_method) # Get the type of the tracking method

            if (tracking_method_type != SciBmadStandard)
                # If the tracking method is `SciBMadStandard`, don't display the "TrackingP" dictionary

                # Create a dictionary to store the tracking information, store the type of tracking method first
                tracking_information = OrderedDict( 
                    :tracking_method => Symbol(tracking_method_type)
                )

                # At the same level, populate the tracking information with the arguments of the tracking struct
                for field_name in fieldnames(tracking_method_type)
                    tracking_information[field_name] = Symbol(getfield(tracking_method, field_name))
                end

                # Put all the tracking information under the `SciBmad` dictionary
                format_dict[:TrackingP] = OrderedDict(
                    :SciBmad => tracking_information
                )
            end
        end

        # We do not put the name as an element of the dictionary
    end

    for parameter_group in values(parameter_groups)
        # Loop through every parameter group `line_element` has

        if (typeof(parameter_group) == UniversalParams)
            # These have already been handled, continue
            continue

        elseif (typeof(parameter_group) == BeamlineParams)
            # Special case: Beamline Parameters should be handled and grouped under "TrackingP"
            # this was (should be) already handled in `UniversalParams` case
            continue

        else
            # General case: Any other group of parameters

            # Represent the parameter group as a dictionary and add it to `format_dict`
            params_to_dict!(format_dict, parameter_group)
        end
    end
    
    # Move solenoid parameters to a new parameter group called "SolenoidP"
    if (haskey(format_dict, :MagneticMultipoleP))
        # If "MagneticMultipoleP" has been initialized

        # Access the "MagneticMultipoleP" dictionary
        magnet_dict = format_dict[:MagneticMultipoleP]
        if (haskey(magnet_dict, :Ksol))
            # If the dictionary contains the parameter `Ksol`

            # Create a new parameter dictionary in format_dict called "SolenoidP", containing `Ksol`
            format_dict[:SolenoidP] = OrderedDict(
                :Ksol => magnet_dict[:Ksol]
            )

            # Remove `Ksol` from the "MagneticMultipoleP" dictionary
            delete!(magnet_dict, :Ksol)

        elseif (haskey(magnet_dict, :Bsol))
            # If the dictionary contains the parameter `Bsol`

            # Create a new parameter dictionary in format_dict called `SolenoidP`, containing "Bsol"
            format_dict[:SolenoidP] = OrderedDict(
                :Bsol => magnet_dict[:Bsol]
            )
            # Remove `Bsol` from the "MagneticMultipoleP" dictionary
            delete!(magnet_dict, :Bsol)
        end
    end

    # Remove any unpopulated elements from `format_dict` before returning. 
    for key in keys(format_dict)
        if (isdefault(key, format_dict[key]))
            # If this is an empty field or default value

            # Remove this key value
            delete!(format_dict, key)
        end
    end

    return OrderedDict(line_element.name => format_dict)
end


"""
    Internal: scibmad_to_pals(lattice::Lattice, new_file_name::String)

Creates a YAML file named "[new_file_name].yaml" in PALS format representing `lattice`

This function converts SciBmad style `Lattice` elements into PALS-formatted YAML files.

## Arguments
- `lattice`         -- The SciBmad `Lattice` that will be turned into a PALS YAML file.
- `new_file_name`   -- A `String` which COMES BEFORE ".pals.yaml" that the resulting file will be named.
"""
function scibmad_to_pals(lattice::Lattice, new_file_name::String)
    # Wipe the placeholder number ref back to 1 to undo any previous changes
    PLACEHOLDER_NUM[] = 1

    # Create a new PALS yaml file in write mode
    io = open(new_file_name * ".pals.yaml", "w")

    # If a key is in this set, then it's already been created
    created_elements = Set{Symbol}()
    # created_branches = Set{Symbol}()  # Not needed until BeamLines have a `name`

    # Create a list which represents the overall construction of the particle accelerator
    facility = []

    branches = [] # Accumulator for the branches of the lattice

    line_counter = 1 # Counter used for naming BeamLines

    for beamline in lattice.beamlines
        # For every (branch :: `BeamLine`) in the lattice...

        # Until beamlines get their own `name` field,
        # it may be confusing to see if they already exist

        line = [] # Accumulator for what's in a beamline

        for line_element in beamline.line
            # For every element in `beamline`'s line...

            if (typeof(line_element) == Beamline)
                # If this is a `Beamline`

                error("`scibmad_to_pals()` does not support beamlines inside of beamlines yet.")

                # Check if this beamline has already been created
                if (!hasproperty(line_element, :name) || !(Symbol(line_element.name) in created_elements)) 
                    error("A beamline must be initialized before it can be put inside another beamline")
                end

                # Add this beamline to the larger beamline
                push!(line, Symbol(line_element.name))

            else
                # If this is not a Beamline

                # Get the element's name
                if (hasproperty(line_element, :name) && (!isempty(line_element.name)))
                    # If the `line_element` has a `name` property, then use it as the name
                    name = Symbol(line_element.name)
                else
                    # If the `line_element` does not have a `name` property, then
                    # make its name "__unnamed__N", where N is the next unnused placeholder number
                    name = Symbol(string("__unnamed__", PLACEHOLDER_NUM[]))

                    # Set the property of this element to the unnamed placeholder so that
                    # duplicates are properly handled
                    line_element.name = String(name)

                    # Increase the placeholder number by 1
                    PLACEHOLDER_NUM[] += 1
                end

                # Add the element's name to the beamline
                push!(line, name)

                # Check to see if the element already exists
                if (!(name in created_elements))
                    # If this line element has not already been created...

                    # Push the line element onto `facility`
                    push!(facility, pals_format(line_element))

                    # Push the line element's name onto the set of unique elements
                    push!(created_elements, name)
                end
            end
        end

        # Name beamlines using default-namer (for now), increment the counter
        # for the namer, and push the beamline onto `facility`
        beamline_name = Symbol(string("beamline", line_counter))
        push!(branches, beamline_name)
        line_counter += 1
        push!(facility, 
            OrderedDict(
                beamline_name => OrderedDict(
                    :kind => :Beamline,
                    :line => line
                )
            )
        )
        push!(created_elements, beamline_name)
    end
    # Push the `lattice` entry onto `facility`
    push!(facility, 
        OrderedDict(
            :lattice => OrderedDict(
                :kind => :Lattice,
                :branches => branches
            )
        )
    )
    # Push `lattice` on as the last element of the PALS file being "used"
    push!(facility, OrderedDict(:use => :lattice))

    # Encase `facility` in the proper PALS formatting
    data_to_write = OrderedDict(
        :PALS => OrderedDict(
            :version => :null, # Update with version
            :notes => ["This file was generated by the `scibmad_to_pals()` function.", "Elements that have no `TrackingP` dictionary have `SciBmadStandard` as their tracking method."],
            :extension_names => OrderedDict(
                :names => [:SciBmad],
                :prefixes => [:SciBmad_]
            ),
            :facility => facility
        )
    )

    # Write to the PALS yaml file
    YAML.write_file(new_file_name * ".pals.yaml", data_to_write)

    # Flush the PALS yaml file
    close(io)
end

#= TODO Handle Nested Beamlines =#
#= TODO Deferred Expression =#

# Create multiple dispatch clone for handling just a `BeamLine` instead of a `Lattice`?