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


"""
Return a dictionary whose keys are the fields associated with [parameter_type_sym]
and whose values are those that correspond to the equivalent SciBMad format fields
of [line_element].

This function is used as a helper to [ scibmad_to_pals() ] to create the dictionaries
that store the fields and field values of a parameter group.

- [line_element] is the LineElement that parameters are being extracted from.
- [parameter_type_sym] is the name of an AbstractParams group as a Symbol.
    (ex. To access MagneticMultipoleP, pass in :MagneticMultipoleP)
"""
function params_to_dict(line_element, parameter_type_sym)
    # Accumulator
    acc = Dict()

    # Access the dictionary storing all of [line_elements]'s parameters
    parameters = getfield(line_element, :pdict)

    # Access the parameter type denoted by [ parameter_type_sym ]
    parameter_type = PARAMS_MAP[parameter_type_sym]

    if (haskey(parameters, parameter_type))
        # If this group of parameters is present

        # Access the initialized parameters of type [parameter_type] in [parameters]
        parameter_group = parameters[parameter_type]

        if (parameter_type_sym == :BMultipoleParams)
            # If this is a B multipole

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

        elseif (parameter_type_sym == :UniversalParams)
            # If these are the universal parameters

            # Extract [ kind ], if present
            if (hasproperty(parameter_group, :kind))
                acc[:kind] = Symbol(getproperty(parameter_group, :kind))
            end

            # Replace [ L ] with [ length ], if it's present
            if (hasproperty(parameter_group, :L))
                acc[:length] = getproperty(parameter_group, :L)
            end

            # Put [ tracking_method ] inside of a [ SciBMad ] dictionary inside of  [ TrackingP ]
            if (hasproperty(parameter_group, :tracking_method))
                acc[:TrackingP] = Dict(:SciBMad => Dict(:tracking_method => getproperty(parameter_group, :tracking_method)))
            end

            # We do not map the name

        else
            # General case

            # Access all the fields associates with this parameter group
            fields = fieldnames(typeof(parameter_group))
            for field in fields
                if (hasproperty(parameter_group, field))
                    # If the field has been initialized

                    # Get the property
                    ret = getproperty(parameter_group, field)

                    # If it's a string, make it a symbol to remove quotation marks
                    if (typeof(ret) == String)
                        ret = Symbol(ret)
                    end

                    acc[field] = ret
                end
            end
        end
    end

    return acc
end


"""
Return a dictionary whose single key is [line_element]'s name, storing another dictionary
whose keys are [line_element]'s fields. This is the format desired by PALS.

This function is used as a helper to [ scibmad_to_pals() ] to create the entry for a single
accelerator element, along with all parameters assocaited with it.

- [line_element] is the LineElement being formatted into PALS.
"""
function pals_format(line_element)
    # Access the line_element's [ kind ]
    kind = Symbol(line_element.kind)

    # Create the accumulating dictionary that represents the element
    format_dict = params_to_dict(line_element, :UniversalParams)

    if (kind == :Quadrupole)
        # [line_element] is a quadrupole
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MagneticMultipoleP] = params_to_dict(line_element, :BMultipoleParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:BodyShiftP] = params_to_dict(line_element, :AlignmentParams)

        # Missing: ElectricMultipoleP, FloorP, ReferenceP, and ReferenceChangeP

    elseif (kind == :Solenoid)
        # [line_element] is a solenoid
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MagneticMultipoleP] = params_to_dict(line_element, :BMultipoleParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:BodyShiftP] = params_to_dict(line_element, :AlignmentParams)

        # Missing: ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and SolenoidP

    elseif (kind == :SBend)
        # [line_element] is an S bend
        format_dict[:BendP] = params_to_dict(line_element, :BendParams)
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MagneticMultipoleP] = params_to_dict(line_element, :BMultipoleParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:BodyShiftP] = params_to_dict(line_element, :AlignmentParams)

        # Missing: ElectricMultipoleP, FloorP, ReferenceP, and ReferenceChangeP

    elseif (kind == :Sextupole)
        # [line_element] is a sextupole
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MagneticMultipoleP] = params_to_dict(line_element, :BMultipoleParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:BodyShiftP] = params_to_dict(line_element, :AlignmentParams)

        # Missing: ElectricMultipoleP, FloorP, ReferenceP, and ReferenceChangeP

    elseif (kind == :Drift)
        # [line_element] is a drift section
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:BodyShiftP] = params_to_dict(line_element, :AlignmentParams)

        # Missing: FloorP, ReferenceP, and ReferenceChangeP

    elseif (kind == :Octupole)
        # [line_element] is an octupole
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MagneticMultipoleP] = params_to_dict(line_element, :BMultipoleParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:BodyShiftP] = params_to_dict(line_element, :AlignmentParams)

        # Missing: ElectricMultipoleP, FloorP, ReferenceP, and ReferenceChangeP

    elseif (kind == :Multipole)
        # [line_element] is a multipole
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MagneticMultipoleP] = params_to_dict(line_element, :BMultipoleParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:BodyShiftP] = params_to_dict(line_element, :AlignmentParams)

        # Missing: ElectricMultipoleP, FloorP, ReferenceP, and ReferenceChangeP

    elseif (kind == :Marker)
        # [line_element] is a marker
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:BodyShiftP] = params_to_dict(line_element, :AlignmentParams)

        # Missing: FloorP, ReferenceP

    elseif (kind == :Kicker || kind == :VKicker || kind == :HKicker)
        # [line_element] is a kicker
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MagneticMultipoleP] = params_to_dict(line_element, :BMultipoleParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:BodyShiftP] = params_to_dict(line_element, :AlignmentParams)

        # Nothing in PALS about HKickers and VKickers

        # Missing: ElectricMultipoleP, FloorP, ReferenceP, and ReferenceChangeP

    elseif (kind == :RFCavity)
        # [line_element] is an RF cavity
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MagneticMultipoleP] = params_to_dict(line_element, :BMultipoleParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:RFP] = params_to_dict(line_element, :ApertureParams)

        # Missing: ElectricMultipoleP, FloorP, ReferenceP, and ReferenceChangeP

    elseif (kind == :CrabCavity)
        # [line_element] is a crab cavity
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MagneticMultipoleP] = params_to_dict(line_element, :BMultipoleParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:RFP] = params_to_dict(line_element, :ApertureParams)

        # Missing: ElectricMultipoleP, FloorP, ReferenceP, and ReferenceChangeP

    elseif (kind == :Patch)
        # [line_element] is a patch
        format_dict[:ApertureP] = params_to_dict(line_element, :ApertureParams)
        format_dict[:MetaP] = params_to_dict(line_element, :MetaParams)
        format_dict[:PatchP] = params_to_dict(line_element, :PatchParams)

        # Missing: FloorP, ReferenceP, and ReferenceChangeP

    end

    # Remove any unpopulated fields from the format_dict before returning. 
    for key in keys(format_dict)
        if (isdefault(key, format_dict[key]))
            # If this is an empty field or default value

            # Remove this key value
            delete!(format_dict, key)
        end
    end

    # Return the, now fully-formatted, element
    return Dict(
        line_element.name => format_dict
    )
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