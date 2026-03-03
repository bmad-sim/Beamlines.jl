using Beamlines
using keymaps
using DataStructures
using YAML

#=
Return a dictionary containing the values of [line_element]'s parameters of type [parameter_type]
=#
function params_to_dict(line_element, parameter_type)
    # The accumulator that will be the dictionary formatting of the type
    acc = Dict()

    params = PARAMS_MAP[parameter_type]

    if (parameter_type == :BMultipoleParams) 
        # If this is a Multipole
        for i in eachindex(params.order)
            # Loop over the non-fixed size components

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

        # Just write out the values of the field names
        for field_name in fieldnames(params)
            acc[fieldname] = getfield(params, fieldname)
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
    format_dict = Dict(
        line_element.name => Dict(
            "kind" => kind,
            "length" => line_element.L
        )
    )

    if (kind == "Quadrupole")
        # [line_element] is a quadrupole
        format_dict["ApertureP"] => get_parameters(line_element, ApertureP)
        format_dict["BodyShiftP"] => get_parameters(line_element, BodyShiftP)
        format_dict["ElectricMultipoleP"] => get_parameters(line_element, ElectricMultipoleP)
        format_dict["FloorP"] => get_parameters(line_element, FloorP)
        format_dict["MagneticMultipoleP"] => get_parameters(line_element, MagneticMultipoleP)
        format_dict["MetaP"] => get_parameters(line_element, MetaP)
        format_dict["ReferenceP"] => get_parameters(line_element, ReferenceP)
        format_dict["ReferenceChangeP"] => get_parameters(line_element, ReferenceChangeP)
        format_dict["TrackingP"] => get_parameters(line_element, TrackingP)

    elseif (kind == "Solenoid")
        # [line_element] is a solenoid
        formal_dict["SolenoidP"] => Dict("Ksol" => line_element.Ksol)

    elseif (kind == "SBend")
        # [line_element] is a solenoid
        formal_dict[]
    end

    # Return the, now fully-formatted, element
    return format_dict
end

#=
Creates a YAML file named "[new_file_name].yaml" in __TODO__ in
PALS format, given a ([beamline] : Beamline) object. 
=#
function scibmad_to_pals(beamline, new_file_name)
    # Create a new PALS yaml file in write mode
    io = open(new_file_name * ".pals.yaml", "w")

    # If a key is in this set, then 
    created_elements = Set(String)

    # Create a list which represents the elements and overall construction of the particle accelerator
    facility = []

    # Populate [facility]
    for line_element in beamline.line
        # For every element in [beamline]'s line...

        # Get the element's name
        name = line_element.name

        # Check to see if the element already exists
        if (!(name in created_elements))
            # If this line element has not already been created...

            # Push the line element onto [facility]
            push!(facility, line_element)
            # Push the line element's name onto the set of unique elements
            push!(created_elements, name)
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