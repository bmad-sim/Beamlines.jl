#=
Return a dictionary containing the values of [line_element]'s parameters of type [parameter_type]
=#
function params_to_dict(line_element, parameter_type)
    # The accumulator that will be the dictionary formatting of the type
    acc = Dict()

    params = PARAMS_MAP[parameter_type]

    if (parameter_type == :BMultipoleParams) 
        # If this is a MultipoleParams

        for i in eachindex(params.order)
            # Loop over the number of orders stored

            # Access the "informational" vectors
            order = params.order[i]
            is_normal = params.normalized[i]
            is_integrated = params.normalized[i]

            # Build the PALS field names based on the information
            if (is_normal)
                pals_norm = string("Kn", order)
                pals_skew = string("Ks", order)
            else
                pals_norm = string("Bn", order)
                pals_skew = string("Bs", order)
            end

            if (is_integrated)
                pals_skew = string(pals_skew, "L")
                pals_norm = string(pals_field, "L")
            end

            # Populate the accumulator dictionary
            acc[string("tilt", order)] = params.tilt[i]
            acc[pals_norm] = params.n[i]
            acc[pals_skew] = params.s[i]
        end
    else
        # If this is any other parameter type

        # Just write out the values of the field names IF THEY AREN'T DEFAULT
        for field_name in propertynames(params)
            acc[field_name] = getproperty(params, field_name)
        end
    end

    return acc
end

#=
Creates the PALS representation of the given element as a dictionary or list.
=#
function pals_format(line_element)
    # Access the line_element's kind
    kind = line_element.kind

    # Create the accumulating dictionary that represents the element
    format_dict = params_to_dict(line_element, :UniversalParams)

    if (kind == "Quadrupole")
        # [line_element] is a quadrupole
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] => params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Solenoid")
        # [line_element] is a solenoid
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] => params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, TrackingP, and SolenoidP

    elseif (kind == "SBend")
        # [line_element] is an S bend
        format_dict["BendP"] => params_to_dict(line_element, :BendParams)
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] => params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Sextupole")
        # [line_element] is a sextupole
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] => params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Drift")
        # [line_element] is a drift section
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Octupole")
        # [line_element] is an octupole
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] => params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Multipole")
        # [line_element] is a multipole
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] => params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Marker")
        # [line_element] is a marker
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)

        # Missing: BodyShiftP, FloorP, ReferenceP

    elseif (kind == "Kicker")
        # [line_element] is a kicker
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] => params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)

        # Nothing in PALS about HKickers and VKickers

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "RFCavity")
        # [line_element] is an RF cavity
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] => params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)
        format_dict["RFP"] => params_to_dict(line_element, :ApertureParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, TrackingP, and SolenoidP

    elseif (kind == "CrabCavity")
        # [line_element] is a crab cavity
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MagneticMultipoleP"] => params_to_dict(line_element, :BMultipoleParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)
        format_dict["RFP"] => params_to_dict(line_element, :ApertureParams)

        # Missing: BodyShiftP, ElectricMultipoleP, FloorP, ReferenceP, ReferenceChangeP, and TrackingP

    elseif (kind == "Patch")
        # [line_element] is a patch
        format_dict["ApertureP"] => params_to_dict(line_element, :ApertureParams)
        format_dict["MetaP"] => params_to_dict(line_element, :MetaParams)
        format_dict["PatchP"] => params_to_dict(line_element, :PatchParams)

        # Missing: BodyShiftP, FloorP, ReferenceP, ReferenceChangeP, TrackingP, and SolenoidP

    end

    # Return the, now fully-formatted, element
    return Dict(
        line_element.name => format_dict
    )
end

#=
Creates a YAML file named "[new_file_name].yaml" in __TODO__ in
PALS format, given a ([lattice] : Lattice) object. 
=#
function scibmad_to_pals(lattice::Lattice, new_file_name::String)
    # Create a new PALS yaml file in write mode
    io = open(new_file_name * ".pals.yaml", "w")

    # If a key is in this set, then 
    created_elements = Set(String)

    # Create a list which represents the elements and overall construction of the particle accelerator
    facility = []

    # Populate [facility]
    for beamline in lattice.lines
        for line_element in beamline.line
            # For every element in [beamline]'s line...

            # Get the element's name
            name = line_element.name

            # Check to see if the element already exists
            if (!(name in created_elements))
                # If this line element has not already been created...

                # Push the line element onto [facility]
                push!(facility, pals_format(line_element))
                # Push the line element's name onto the set of unique elements
                push!(created_elements, name)
            end
        end
    end

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
A version of scibmad_to_pals() which can just accept a beamline 
=#
function scibmad_to_pals(beamline::Beamline, new_file_name)
    return scibmad_to_pals(Lattice(beamline), new_file_name)
end