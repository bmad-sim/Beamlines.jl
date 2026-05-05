**General Translation and `scibmad_to_pals()`**
This package supports translating SciBmad `Branch` elements into PALS-formatted YAML files
through the `scibmad_to_pals()` method inside of the "to_PALS.jl" file. The `scibmad_to_pals()`
method takes the branch to be translated and the destination path where the created file should 
be put as arguments.

**Output Structure and `pals_format()`**
On a high level, `scibmad_to_pals()` works by iterating over every `Beamline` inside the `Branch`,
and then iterating over every `LineElement` in each `Beamline` and calling `pals_format()` on each one. 
`pals_format()` handles turning `LineElement`s into nested `OrderedDict`s which are formatted according
to the PALS standard. The dictionaries that represent `LineElement`s are populated by the information
of the `LineElement`. The first nesting layer of a `LineElement`'s PALS dictionary only stores a single
key: the name of the element, which maps to the second nested dictionary. The second nesting layer stores the
universal information of `LineElements`, like `kind`, and `length`, as well as the keys which map to the 
specialized technical "parameter groups". The parameter groups' keys on the second nesting layer are the
PALS names of those parameter groups (ex. :SolenoidP), and they each map to their own `OrderedDict`, 
which will be referred to as the "third nesting layer". The third nesting layer mostly stores the parameters
belonging to each parameter group (ex. :Ksol in the :SolenoidP group).

**Parameter Group Handling and `params_to_dict!()**
`pals_format()` works by iterating over the parameter groups contained inside the `LineElement` on the SciBmad
side, and calling `params_to_dict!()` on each one. `params_to_dict!()` mutates the dictionary passed into it to
contain a PALS-formatted dictionary (mapped to by a key that is the parameter group's name) which contains the
parameters of the parameter group as described in the previous paragraph. If another parameter group is added that
needs to be handled in a way that the general-case implementation of `params_to_dict!()` cannot handle, then 
another overloaded version of `params_to_dict!()` should be created.

**Other Functions and Data Structures**
Besides these primary three functions, the translator also uses several supporting functions and data
structures to handle the finer nuances of PALS. `PLACEHOLDER_NUM` is used for naming unnamed elements,
`PARAMTYPES_TO_PALS_NAMES` and `SCIBMAD_NAME_TO_PALS_NAME_MAP` are used for translating the names
of SciBMad parameter groups/parameters to their corresponding PALS name, and `isdefault()` is 
used for checking if various datatypes store "default" values that shouldn't be represented.
`create_begele()` and `make_reference_dict()` are used for representing the ReferenceP and
ReferenceChangeP parameter groups at the start of each beamline. 

**Miscellaneous**
The PALS-formatted YAML file created by `scibmad_to_pals()` lists every element belonging to a beamline
before putting the entry for the beamline itself. All of these beamlines are put as sub-elements of a
"master beamline" which describes the whole branch. This master beamline is the sole branch of the 
lattice at the end of the PALS file, as currently SciBmad itself does not support lattices containing
multiple branches. SciBmad also does not currently support named beamlines, so the beamlines in the
output file are just named "beamline'N'" where 'N' is an integer which increases for later-created 
beamlines. Deferred expressions are currently supported in SciBMad, but there's no current way to
retrieve the human-readable math that represents them, so they are not currently supported in the 
translator.