#= TODO: tracking_method: SciBMad: SciBMad Standard =#
#= TODO: Remove quotations from YAML display =#
#= TODO: Remove default values from being displayed =#
#= TODO: Create a default naming mechanism =#

#=
Return a dictionary whose keys are the fields associated with [parameter_type_sym]
and whose values are those that correspond to the equivalent SciBMad format fields
of [line_element].
=#
function params_to_dict(line_element, parameter_type_sym)
    # Accumulator
    acc = Dict()

    parameters = getfield(line_element, :pdict)

    parameter_type = PARAMS_MAP[parameter_type_sym]

    if (haskey(parameters, parameter_type))
        # If this group of parameters is present

        parameter_group = parameters[parameter_type]

        if (parameter_type == BMultipoleParams)
            # If this is a B multipole

            #= This code is from the override of [ show() ] in multipole.jl =#
            for bm in parameter_group
                n = bm.n
                s = bm.s
                tilt = bm.tilt
                if n != 0
                    sym = BMULTIPOLE_STRENGTH_INVERSE_MAP[(true, bm.order, bm.normalized, bm.integrated)]
                    acc[string(sym)] = n
                end
                if s != 0
                    sym = BMULTIPOLE_STRENGTH_INVERSE_MAP[(false, bm.order, bm.normalized, bm.integrated)]
                    acc[string(sym)] = s
                end
                if tilt != 0
                    sym = BMULTIPOLE_TILT_INVERSE_MAP[bm.order]
                    acc[string(sym)] = tilt
                end
            end
            #= End code from the override of [ show() ] in multipole.jl =#

        else
            fields = fieldnames(typeof(parameter_group))
            for field in fields
                if (hasproperty(parameter_group, field))
                    if (field == :L)
                        # Replace "L" with "length"
                        acc["length"] = getproperty(parameter_group, field)
                    elseif (field == :name)
                        # We never display the name field
                        continue
                    else
                        acc[field] = getproperty(parameter_group, field)
                    end
                end
            end
        end
    end

    return acc
end

#=
Return a dictionary whose single key is [line_element]'s name, storing a nested dictionary
of all of [line_element]'s fields.
=#
function pals_format(line_element)
    # Access the line_element's kind
    kind = line_element.kind

    # Create the accumulating dictionary that represents the element
    format_dict = params_to_dict(line_element, :UniversalParams)

    if (kind == "Quadrupole")
        # [line_element] is a quadrupole
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] = params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Solenoid")
        # [line_element] is a solenoid
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] = params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, TrackingP, and SolenoidP

    elseif (kind == "SBend")
        # [line_element] is an S bend
        format_dict["BendP"] = params_to_dict(line_element, :BendParams)
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] = params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Sextupole")
        # [line_element] is a sextupole
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] = params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Drift")
        # [line_element] is a drift section
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Octupole")
        # [line_element] is an octupole
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] = params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Multipole")
        # [line_element] is a multipole
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] = params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Marker")
        # [line_element] is a marker
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, FloorP, ReferenceP

    elseif (kind == "Kicker")
        # [line_element] is a kicker
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] = params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)

        # Nothing in PALS about HKickers and VKickers

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "RFCavity")
        # [line_element] is an RF cavity
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] = params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)
        format_dict["RFP"] = params_to_dict(line_element, :ApertureParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, TrackingP, and SolenoidP

    elseif (kind == "CrabCavity")
        # [line_element] is a crab cavity
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] = params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)
        format_dict["RFP"] = params_to_dict(line_element, :ApertureParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Patch")
        # [line_element] is a patch
        format_dict["ApertureP"] = params_to_dict(line_element, :ApertureParams)
        format_dict["MetaP"] = params_to_dict(line_element, :MetaParams)
        format_dict["PatchP"] = params_to_dict(line_element, :PatchParams)

        # Missing: BodyShiftP, FloorP, ReferenceP, ReferenceChangeP, TrackingP, and SolenoidP

    end

    # Return the, now fully-formatted, element
    return Dict(
        line_element.name => format_dict
    )
end

#=
Creates a YAML file named "[new_file_name].yaml" in
PALS format, given a ([lattice] : Lattice) object. 
=#
function scibmad_to_pals(lattice::Lattice, new_file_name::String)
    # Create a new PALS yaml file in write mode
    io = open(new_file_name * ".pals.yaml", "w")

    # If a key is in this set, then 
    created_elements = Set{String}()
    created_branches = Set{String}()

    # Create a list which represents the elements and overall construction of the particle accelerator
    facility = []

    # Populate [facility]
    branches = []
    for beamline in lattice.beamlines
        line = []
        for line_element in beamline.line
            # For every element in [beamline]'s line...

            # Get the element's name
            name = line_element.name
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

        #= TODO How to handle names of beamlines? =#

        push!(branches, "TODO: beamline.name")
        push!(facility, 
            Dict(
                "TODO: beamline.name" => Dict(
                    "kind" => "Beamline",
                    "line" => line
                )
            )
        )
    end
    push!(facility, 
        Dict(
            "TODO: lattice.name" => Dict(
                "kind" => "Lattice",
                "branches" => branches
            )
        )
    )

    push!(facility, Dict("use" => "fodo_lattice"))

    # Encase [facility] in the proper PALS formatting
    data_to_write = Dict(
        "PALS" => Dict(
            "version" => "null",
            "facility" => facility
        )
    )

    # Write to the PALS yaml file
    YAML.write_file(new_file_name * ".pals.yaml", data_to_write)

    # Flush the PALS yaml file
    close(io)
end

#=
Creates a YAML file named "[new_file_name].yaml" in
PALS format, given a ([beamline] : Beamline) object. 
=#
function scibmad_to_pals(beamline::Beamline, new_file_name::String)
    return scibmad_to_pals(Lattice(beamline), new_file_name)
end