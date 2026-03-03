using Beamlines
using DataStructures

#=
Creates a YAML file named "[new_file_name].yaml" in __TODO__ in
PALS format, given a ([beamline] : Beamline) object. 
=#
function scibmad_to_pals(beamline, new_file_name)
    # Create a new PALS yaml file
    io = open(new_file_name * ".pals.yaml", "w")

    # Create a dictionary to keep track of IF line elements have been created:
    # elements that have already been created map to [ True ]
    # elements that have not map to [ False ]
    is_already_created = DefaultDict(LineElement, Bool)

    # Create a dictionary to 
    already_created = Dict()

    for line_element in beamline.line
        # For every element in [beamline]'s line...

        # Check to see if the element already exists
        if (is_already_created[line_element])
            # If this line element has already been created...

            # Use the already existing information in [already_created]
        else 
            # If this line element is new...

            # Add information to [already_created]

            # Use new information
        end

        # Write to the PALS yaml file
    end

    # Flush the PALS yaml file
    close(io)
end