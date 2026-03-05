"""
Returns true if [value] is the default value that [field] can represent.

This function is used as a helper function for [ scibmad_to_pals() ] to 
cut out elements that store no information (besides default values).

Dictionaries' default value is {}
Vectors' default value is []
Symbols' default value is Symbol("")

- [field] is a Symbol representing the name of a parameter.
- [value] is the value stored at [field]
"""
function isdefault(field, value)
    # If more defaults need to be accounted for, this may be expanded
    value_type = typeof(value)

    if (value_type <: Dict)
        # A default dictionary is empty, regardless of its [field]
        return isempty(value)

    elseif (value_type <: Vector)
        # A default vector is empty, regardless of its [field]
        return isempty(value)

    elseif (value_type == Symbol)
        # Any symbol's default value is the empty symbol, regardless of its [field]
        return value === Symbol("")
    end

    # If nothing above has been satisfied, it's not a default value
    return false
end

#= This maps types of AbstractParams to the symbol representing its PALS-format name =#
const PARAMTYPES_TO_PALSNAMES_MAP = Dict{Type{<:AbstractParams}, Symbol}(
    BMultipoleParams => :MagneticMultipoleP,
    ApertureParams => :ApertureP,
    MetaParams => :MetaP,
    AlignmentParams => :BodyShiftP,
    BendParams => :BendP,
    RFParams => :RFP,
    PatchParams => :PatchP
)

"""
Modifies [acc] to have a new entry which stores a dictionary whose keys are parameter
names from [parameter_group] and whose values are the initialized values corresponding
to those parameter names.

This function is used as a helper to [ scibmad_to_pals() ] to create the dictionaries
that store the fields and field values of a parameter group and populate the dictionaries
associated with elements with them.

- [format_dict] is the dictionary to be modified which represents the information about a line element.
- [parameter_group] is an AbstractParams object containing the parameters to extract to [acc].
"""
function params_to_dict!(format_dict::Dict, parameter_group::T) where {T<:AbstractParams}
    # The accumulator dictionary 
    acc = Dict()
    parameter_type = nothing # This holds the type of the parameter group

    for parameter_name in propertynames(parameter_group)
        if (parameter_type == nothing)
            # Set the type of the parameter
            if haskey(PROPERTIES_MAP, parameter_name)
                parameter_type = PROPERTIES_MAP[parameter_name]
            end
        end
        if (hasproperty(parameter_group, parameter_name))
            # Get the value stored at that property
            parameter_value = getproperty(parameter_group, parameter_name)

            # If it's a string, make it a symbol to remove quotation marks
            if (typeof(parameter_value) == String)
                parameter_value = Symbol(parameter_value)
            end

            acc[parameter_name] = parameter_value
        end
    end

    format_dict[PARAMTYPES_TO_PALSNAMES_MAP[parameter_type]] = acc
end


# Handle BMultipoleParams
function params_to_dict!(format_dict::Dict, parameter_group::BMultipoleParams) 
    # The accumulator dictionary 
    acc = Dict()

    #= This code is from the override of [ show() ] in multipole.jl =#
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
    #= End code from the override of [ show() ] in multipole.jl =#

    # Modify [format_dict]
    format_dict[:MagneticMultipoleP] = acc
end


"""
Return a dictionary whose single key is [line_element]'s name, storing another dictionary
whose keys are [line_element]'s fields. This is the format desired by PALS.

This function is used as a helper to [ scibmad_to_pals() ] to create the entry for a single
accelerator element, along with all parameters assocaited with it.

- [line_element] is the LineElement being formatted into PALS.
"""
function pals_format(line_element) 
    # The accumulator dictionary which will become the final return dictionary
    format_dict = Dict()

    #=
    Access [line_element]'s parameter groups.
    Reminder: A LineElement's [pdict] is a dictionary mapping AbstractParams types to objects 
    containing the initialized parameters of [line_element]
    =#
    parameter_groups = getfield(line_element, :pdict)

    for parameter_group in values(parameter_groups)
        # Loop through every parameter group [line_element] has

        if (typeof(parameter_group) == UniversalParams)
            #=
            Special case: Universal Parameters contains basic information that's 
            not displayed inside of another dictionary, it should be at the "top level",
            so handle it here instead of in the helper.
            =#
            
            # Extract [ kind ], if present
            if (hasproperty(parameter_group, :kind))
                format_dict[:kind] = Symbol(getproperty(parameter_group, :kind))
            end

            # Replace [ L ] with [ length ], if it's present
            if (hasproperty(parameter_group, :L))
                format_dict[:length] = getproperty(parameter_group, :L)
            end

            # Put [ tracking_method ] inside of a [ SciBMad ] dictionary inside of  [ TrackingP ]
            if (hasproperty(parameter_group, :tracking_method))
                format_dict[:TrackingP] = Dict(:SciBMad => Dict(:tracking_method => getproperty(parameter_group, :tracking_method)))
            end

            #= TODO Handle Beamline parameters here? =#

            # We do not put the name as an element of the dictionary
        elseif (typeof(parameter_group) == BeamlineParams)
            # Special case: Beamline Parameters should be handled and grouped under TrackingP
            # this was (should be) already handled in UniversalParams case

            continue
        else
            # General case: Any other group of parameters

            # Represent the parameter group as a dictionary and add it to [format_dict]
            params_to_dict!(format_dict, parameter_group)
        end
    end
    
    # Remove any unpopulated elements from the format_dict before returning. 
    for key in keys(format_dict)
        if (isdefault(key, format_dict[key]))
            # If this is an empty field or default value

            # Remove this key value
            delete!(format_dict, key)
        end
    end

    return Dict(line_element.name => format_dict)
end


"""
Creates a YAML file named "[new_file_name].yaml" in PALS format representing [lattice]

This function is the main workhorse and purpose of this file, converting SciBMad-style
[lattice] elements into PALS-style .yaml files to be used for other purposes.

- [lattice] is the SciBMad Lattice that will be turned into a PALS YAML file.
- [new_file_name] is a String which COMES BEFORE ".pals.txt" that the resulting
    file will be named.
"""
function scibmad_to_pals(lattice::Lattice, new_file_name::String)
    # Create a new PALS yaml file in write mode
    io = open(new_file_name * ".pals.yaml", "w")

    # If a key is in this set, then it's already been created
    created_elements = Set{Symbol}()
    # created_branches = Set{Symbol}()  # Not needed until BeamLines have a [ name ]

    # Create a list which represents the overall construction of the particle accelerator
    facility = []

    branches = [] # Accumulator for the branches of the lattice

    line_counter = 1 # Counter used for naming BeamLines

    for beamline in lattice.beamlines
        # For every branch (BeamLine) in the lattice...

        # Until beamlines get their own [ name ] field,
        # it may be confusing to see if they already exist

        line = [] # Accumulator for what's in a beamline

        for line_element in beamline.line
            # For every element in [beamline]'s line...

            # Get the element's name
            name = Symbol(line_element.name)

            # Add the element's name to the beamline
            push!(line, name)

            # Check to see if the element already exists
            if (!(name in created_elements))
                # If this line element has not already been created...

                # Push the line element onto [facility]
                push!(facility, pals_format(line_element))

                # Push the line element's name onto the set of unique elements
                push!(created_elements, name)
            end
        end

        # Name beamlines using default-namer (for now), increment the counter
        # for the namer, and push the beamline onto [ facility ]
        beamline_name = string("beamline", line_counter)
        push!(branches, Symbol(beamline_name))
        line_counter += 1
        push!(facility, 
            Dict(
                Symbol(beamline_name) => Dict(
                    :kind => :Beamline,
                    :line => line
                )
            )
        )
    end
    # Push the lattice entry onto [ facility ]
    push!(facility, 
        Dict(
            :lattice => Dict(
                :kind => :Lattice,
                :branches => branches
            )
        )
    )
    # Push the lattice on as the last element of the PALS file being "used"
    push!(facility, Dict(:use => :lattice))

    # Encase [facility] in the proper PALS formatting
    data_to_write = Dict(
        :PALS => Dict(
            :version => :null, # Update with version
            :facility => facility
        )
    )

    # Write to the PALS yaml file
    YAML.write_file(new_file_name * ".pals.yaml", data_to_write)

    # Flush the PALS yaml file
    close(io)
end

# Create multiple dispatch clone for handling just a BeamLine instead of a Lattice?