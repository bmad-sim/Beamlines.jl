#---------------------------------------------------------------------------------------------------
# Element and Branch name matching.
#
# The syntax is similar to what is implemented in Bmad and PALS.
# A match string is broken into "atoms" of the form
# `{branch>>}{kind::}name{#N}` which are combined with the range (`:`), union (`,`), and
# intersection (`&`) operators. If the match string is a `Regex`, the branch and element names
# are Julia regular expressions that must match the whole name. If it is a `String`, they are
# matched with the Bmad wild card characters `*` and `%`.
#
# Structure of the implementation
#
# `findelements` and `findbranches` are the only public functions. They work in four steps:
#
#   1. Collect what is searched (`_search_lines`). The `Lattice`, `Branch`, or `Beamline` being
#      searched is turned into a vector of `_SearchLine`s, one per branch, each holding the
#      elements of the branch and its name. This lets the same code search all three kinds of
#      containers. An element is identified by an `_EleID`, the tuple (line index, element
#      index), so that ranges, `#N`, union, and intersection are simple operations on integers
#      and sorting the IDs puts the elements in lattice order.
#
#   2. Lex (`_lex_match_str`). The match string is split at the operators `>>`, `::`, `:`, `,`,
#      `&`, and `#` into a vector of texts and a vector of the operators between them. With a
#      `Regex` match string, operator characters inside a regex group, character class, or
#      `{n,m}` quantifier, or that are escaped, are left as part of the text.
#
#   3. Parse (`_parse_ele_atom`). The texts and operators of each atom `{branch>>}{kind::}name{#N}`
#      are parsed into an `_EleAtom`. Each branch and element name text is turned into a `Regex`
#      that matches whole names by `_name_regex`, which uses `_NameMatcher` to know whether the
#      match string was a `Regex` (and with what flags) or a `String` with Bmad wild cards.
#
#   4. Evaluate. `_eval_match_str` splits the operator sequence at `&` and then at `,`, and
#      takes the intersection of the unions. Each piece between the `,`s is evaluated by a
#      closure defined in `findelements` (or `findbranches`) that handles a single atom
#      (`_eval_ele_atom`) or a range of two atoms (`_eval_ele_range`). The resulting `_EleID`s
#      are converted back into elements.
#
# For example, `findelements(lat, "Quadrupole::q* & ring>>m1:m2")` lexes to the texts
# `["Quadrupole", "q*", "ring", "m1", "m2"]` and operators `["::", "&", ">>", ":"]`. The `&`
# splits this into the atom `Quadrupole::q*` and the range `ring>>m1:m2`. The atom matches the
# quadrupoles whose name starts with "q" in every branch, the range matches the elements from
# `m1` to `m2` in branch "ring", and the result is the intersection of the two.

"""
    Internal: struct _SearchLine

A line of elements searched by `findelements`: the elements of a `Branch`, or of a `Beamline`
when a `Beamline` is searched, along with the name of the `Branch` the elements are in. The
name is `nothing` if the elements are not in a `Branch`.
"""
struct _SearchLine
  branch_name::Union{String,Nothing}
  eles::Vector{LineElement}
end

_search_line(br::Branch) = _SearchLine(br.name, LineElement[ele for bl in br.beamlines for ele in bl.line])

function _search_line(bl::Beamline)
  if getfield(bl, :branch_index) == -1
    return _SearchLine(nothing, collect(bl.line))
  else
    return _SearchLine(getfield(bl, :branch).name, collect(bl.line))
  end
end

"""
    Internal: _search_lines(where::Union{Lattice,Branch,Beamline}) -> Vector{_SearchLine}

The lines searched by `findelements`: one per branch of a `Lattice`, the `Branch` itself, or
the `Beamline` itself. Element indexes, `#N` instances, and ranges are all relative to a line.
"""
_search_lines(bl::Beamline) = [_search_line(bl)]
_search_lines(br::Branch) = [_search_line(br)]
_search_lines(lat::Lattice) = [_search_line(br) for br in lat.branches]

_line_str(line::_SearchLine) = isnothing(line.branch_name) ? "the Beamline" : "branch \"$(line.branch_name)\""

#---------------------------------------------------------------------------------------------------
# Lexing

# Operators in the order in which they are tried. Longer operators must come before operators
# they start with.
const _MATCH_OPS = (">>", "::", ":", ",", "&", "#")

"""
    Internal: _lex_match_str(str::AbstractString, is_regex::Bool) -> (texts, ops)

Splits the match string `str` at the operators in `_MATCH_OPS`. Returned are the vector `ops`
of operators and the vector `texts` of the (whitespace stripped) strings between them, with
`length(texts) == length(ops) + 1`. If `is_regex` is `true`, characters that are escaped or are
within a group `(...)`, character class `[...]`, or `{n,m}` quantifier of the regex are never
treated as operators.
"""
function _lex_match_str(str::AbstractString, is_regex::Bool)
  texts = String[]
  ops = String[]
  buf = IOBuffer()
  depth = 0     # Regex group nesting depth
  s = String(str)
  i = firstindex(s)

  while i <= lastindex(s)
    c = s[i]

    if is_regex
      j = nextind(s, i)
      if c == '\\'
        j > lastindex(s) && error("Match string ends with a backslash: $str")
        if s[j] == 'Q'  # \Q...\E quotes everything in between
          k = findnext("\\E", s, j)
          stop = isnothing(k) ? lastindex(s) : last(k)
        else
          stop = j
        end
        print(buf, SubString(s, i, stop)); i = nextind(s, stop)
        continue
      elseif c == '['
        stop = _regex_class_end(s, i)
        isnothing(stop) && error("Unterminated character class in match string: $str")
        print(buf, SubString(s, i, stop)); i = nextind(s, stop)
        continue
      elseif c == '{'
        m = match(r"\G\{\s*\d*\s*(,\s*\d*\s*)?\}", s, i)
        if !isnothing(m)
          print(buf, m.match); i += ncodeunits(m.match)
          continue
        end
      elseif c == '('
        depth += 1
      elseif c == ')'
        depth -= 1
        depth < 0 && error("Unbalanced parentheses in match string: $str")
      end
    end

    if depth == 0 && startswith(SubString(s, i), ">>>")
      error("Lattice qualification (using \">>>\") is not supported. Match string: $str")
    end
    op = depth > 0 ? nothing : findfirst(op -> startswith(SubString(s, i), op), _MATCH_OPS)
    if isnothing(op)
      if c == '>' && depth == 0
        error("Parameter matching (using \">\") is not supported. Match string: $str")
      end
      print(buf, c); i = nextind(s, i)
    else
      push!(texts, strip(String(take!(buf))))
      push!(ops, _MATCH_OPS[op])
      i += ncodeunits(_MATCH_OPS[op])
    end
  end

  depth == 0 || error("Unbalanced parentheses in match string: $str")
  push!(texts, strip(String(take!(buf))))
  return texts, ops
end

# Index of the "]" that ends the regex character class that starts with the "[" at index `i`, or
# `nothing` if there is none. A "]" directly after the opening "[" or "[^" is a literal "]".
function _regex_class_end(s::String, i::Int)
  j = nextind(s, i)
  j <= lastindex(s) && s[j] == '^' && (j = nextind(s, j))
  j <= lastindex(s) && s[j] == ']' && (j = nextind(s, j))
  while j <= lastindex(s)
    c = s[j]
    if c == '\\'
      j = nextind(s, nextind(s, j))
    elseif c == '[' && j < lastindex(s) && s[nextind(s, j)] == ':'   # POSIX class like [:alpha:]
      k = findnext(":]", s, nextind(s, j))
      isnothing(k) && return nothing
      j = nextind(s, last(k))
    elseif c == ']'
      return j
    else
      j = nextind(s, j)
    end
  end
  return nothing
end

"""
    Internal: _split_at_op(texts, ops, op::String) -> Vector{Tuple{Vector{String},Vector{String}}}

Splits the `texts`/`ops` sequence returned by `_lex_match_str` at each occurrence of the
operator `op`. Each returned piece is itself a `(texts, ops)` sequence with
`length(texts) == length(ops) + 1`. For example, splitting `a, b::c` at `","` gives the pieces
`(["a"], [])` and `(["b", "c"], ["::"])`.
"""
function _split_at_op(texts::AbstractVector, ops::AbstractVector, op::String)
  pieces = Tuple{Vector{String},Vector{String}}[]
  i0 = 1
  for (i, o) in enumerate(ops)
    if o == op
      push!(pieces, (texts[i0:i], ops[i0:i-1]))
      i0 = i + 1
    end
  end
  push!(pieces, (texts[i0:end], ops[i0:end]))
  return pieces
end

#---------------------------------------------------------------------------------------------------
# Parsing

"""
    Internal: struct _NameMatcher

Holds the information needed to turn the name parts of a match string into `Regex`es.
`is_regex` is `true` if the match string was a `Regex`, in which case `compile_options` and
`match_options` are the options of that `Regex`.
"""
struct _NameMatcher
  str::String            # Full match string, used in error messages.
  is_regex::Bool
  compile_options::UInt32
  match_options::UInt32
end

_NameMatcher(str::AbstractString) = _NameMatcher(str, false, 0, 0)
_NameMatcher(r::Regex) = _NameMatcher(r.pattern, true, r.compile_options, r.match_options)

"""
    Internal: _name_regex(nm::_NameMatcher, text::AbstractString) -> Regex

Regex that matches a whole name to the name part `text` of a match string. If the match string
is a `Regex`, `text` is compiled with the flags of the match string, anchored at both ends.
Otherwise `text` is a Bmad wild card pattern converted by `_wildcard_regex`.
"""
function _name_regex(nm::_NameMatcher, text::AbstractString)
  isempty(text) && error("Blank name in match string: $(nm.str)")
  if nm.is_regex
    try
      anchored = nm.compile_options | Base.PCRE.ANCHORED | Base.PCRE.ENDANCHORED
      return Regex(text, anchored, nm.match_options)
    catch err
      # Say which part of the match string is bad since the error offset is relative to the part.
      err isa ErrorException || rethrow()
      msg = replace(err.msg, r"^PCRE compilation error: " => "")
      hint = startswith(text, '*') ? " (With a Regex, use \".*\" to match any name.)" : ""
      error("Invalid regular expression \"$text\" in match string $(nm.str): $msg.$hint")
    end
  else
    return _wildcard_regex(text)
  end
end

"""
    Internal: _wildcard_regex(pattern::AbstractString) -> Regex

Converts `pattern`, which may contain the Bmad wild card characters `*` (matches any number of
characters including zero) and `%` (matches any single character), to a `Regex` that matches
whole strings. All other characters match only themselves.
"""
function _wildcard_regex(pattern::AbstractString)
  io = IOBuffer()
  print(io, "\\A")
  for c in pattern
    if c == '*'
      print(io, ".*")
    elseif c == '%'
      print(io, ".")
    elseif c in "\\^\$.|?+()[]{}#"
      print(io, '\\', c)
    else
      print(io, c)
    end
  end
  print(io, "\\z")
  return Regex(String(take!(io)))
end

_is_index(text::AbstractString) = !isempty(text) && all(isdigit, text)

"""
    Internal: struct _EleAtom

A parsed `{branch>>}{kind::}name{#N}` element match. `index` is nonzero if `name`
is an element index, and `instance` is nonzero if there is a `#N` suffix.
"""
struct _EleAtom
  branch::Union{Regex,Nothing}
  kind::Union{String,Nothing}
  name::Union{Regex,Nothing}
  index::Int
  instance::Int
end

"""
    Internal: _parse_ele_atom(nm::_NameMatcher, texts::Vector{String}, ops::Vector{String}) -> _EleAtom

Parses the `texts`/`ops` sequence of a single atom `{branch>>}{kind::}name{#N}`, where `ops`
contains only `>>`, `::`, and `#`, each at most once and in that order.
"""
function _parse_ele_atom(nm::_NameMatcher, texts::Vector{String}, ops::Vector{String})
  # The operators must appear at most once each and in this order.
  order = (">>", "::", "#")
  ranks = [findfirst(==(op), order) for op in ops]
  if !issorted(ranks; lt = <=)
    error("Malformed element match. Syntax is \"{branch>>}{kind::}name{#N}\". Match string: $(nm.str)")
  end
  part(op) = (i = findfirst(==(op), ops); isnothing(i) ? nothing : texts[i])

  branch = part(">>")
  kind = part("::")
  instance = 0
  if "#" in ops
    _is_index(texts[end]) || error("\"#\" must be followed by an integer. Match string: $(nm.str)")
    instance = parse(Int, texts[end])
    instance > 0 || error("Instance number after \"#\" must be positive. Match string: $(nm.str)")
    name = texts[end-1]
  else
    name = texts[end]
  end

  !isnothing(kind) && isempty(kind) && error("Blank element kind in match string: $(nm.str)")
  index = _is_index(name) ? parse(Int, name) : 0
  return _EleAtom(isnothing(branch) ? nothing : _name_regex(nm, branch),
                  kind,
                  index > 0 ? nothing : _name_regex(nm, name),
                  index, instance)
end

#---------------------------------------------------------------------------------------------------
# Evaluation

# An element is identified by the index of its line and its index in the line.
const _EleID = Tuple{Int,Int}

# True if a line with branch name `name` passes the branch qualifier `pattern`. No qualifier
# always passes, and a line that is not in a branch fails any qualifier.
_qualifier_match(pattern::Nothing, name) = true
_qualifier_match(pattern::Regex, name::Nothing) = false
_qualifier_match(pattern::Regex, name::String) = occursin(pattern, name)

"""
    Internal: _eval_ele_atom(lines::Vector{_SearchLine}, a::_EleAtom) -> Vector{_EleID}

IDs of the elements in `lines` that match the atom `a`. For each line that passes the branch
qualifier, the elements are selected by name (or index), then by kind, and then the `#N`
instance is picked.
"""
function _eval_ele_atom(lines::Vector{_SearchLine}, a::_EleAtom)
  ids = _EleID[]
  for (il, line) in enumerate(lines)
    _qualifier_match(a.branch, line.branch_name) || continue
    ixs = a.index > 0 ? (a.index <= length(line.eles) ? [a.index] : Int[]) :
                        findall(ele -> occursin(a.name, ele.name), line.eles)
    !isnothing(a.kind) && filter!(ix -> line.eles[ix].kind == a.kind, ixs)
    if a.instance > 0
      ixs = a.instance <= length(ixs) ? [ixs[a.instance]] : Int[]
    end
    append!(ids, (il, ix) for ix in ixs)
  end
  return ids
end

"""
    Internal: _eval_ele_range(lines, a1::_EleAtom, a2::_EleAtom, nm::_NameMatcher) -> Vector{_EleID}

IDs of the elements in the range `a1:a2`: all elements from the element matched by `a1` to the
element matched by `a2`, inclusive. The range is evaluated separately in each line where both
`a1` and `a2` match, and wraps around the end of the line if `a2` comes before `a1`.
"""
function _eval_ele_range(lines::Vector{_SearchLine}, a1::_EleAtom, a2::_EleAtom, nm::_NameMatcher)
  ids1 = _eval_ele_atom(lines, a1)
  ids2 = _eval_ele_atom(lines, a2)
  ids = _EleID[]
  for il in intersect(first.(ids1), first.(ids2))
    ix1 = [ix for (l, ix) in ids1 if l == il]
    ix2 = [ix for (l, ix) in ids2 if l == il]
    line = lines[il]
    for (end_str, ixs) in (("Start", ix1), ("End", ix2))
      length(ixs) == 1 || error("$end_str of range matches multiple elements in $(_line_str(line)). " *
                                "Match string: $(nm.str)")
    end
    i1, i2 = ix1[1], ix2[1]
    range = i1 <= i2 ? (i1:i2) : [i1:length(line.eles); 1:i2]  # Wrap around the end
    append!(ids, (il, ix) for ix in range)
  end
  return ids
end

"""
    Internal: _eval_match_str(atom_ids::Function, nm::_NameMatcher, texts, ops) -> Vector{_EleID}

Evaluates the lexed match string `texts`/`ops` with the union (`,`) and intersection (`&`)
operators, `&` having the lower precedence. Each piece between the `,`s is evaluated by
`atom_ids(texts, ops) -> Vector{_EleID}`, which `findelements` and `findbranches` supply and
which handles a single atom or a range (`:`). Returned are the unique IDs, sorted so they are
in lattice order. `findbranches` uses `(1, branch index)` as the ID of a branch.
"""
function _eval_match_str(atom_ids::Function, nm::_NameMatcher, texts, ops)
  result = nothing
  for (t_and, o_and) in _split_at_op(texts, ops, "&")
    union_ids = Set{_EleID}()
    for (t_or, o_or) in _split_at_op(t_and, o_and, ",")
      union!(union_ids, atom_ids(t_or, o_or))
    end
    result = isnothing(result) ? union_ids : intersect!(result, union_ids)
  end
  return sort!(collect(result))
end

#---------------------------------------------------------------------------------------------------

"""
    findelements(where::Union{Lattice,Branch,Beamline}, pattern::Union{AbstractString,Regex}) -> Vector{LineElement}

Returns all the `LineElement`s in `where` that match `pattern`. `where` may be a `Lattice`, a
`Branch`, or a `Beamline`. The returned elements are ordered by the order of the branches
followed by their order in the branch, and each element appears at most once. No match is not an error, and an empty vector is returned.

## Syntax

The syntax is based on Bmad's. An "atom" is of the form
```
  {branch>>}{kind::}name{#N}
```
where `{...}` marks an optional part and
- `branch`   Match only elements in a `Branch` whose name matches.
- `kind`     Match only elements whose `kind` is `kind`, e.g. `Quadrupole`. This must be an exact match.
- `name`     Element name to match, or an integer element index where the first element of a
  `Branch` (or of the `Beamline` when `where` is a `Beamline`) has index 1. With an index and no
  `branch`, the element with that index in each branch searched is matched.
- `#N`       Match only the `N`th element in each branch that matches the rest of the atom.

Atoms may be combined:
```
  atom1:atom2    # Range: All elements from atom1 through atom2 inclusive.
  set1, set2     # Union.
  set1 & set2    # Intersection.
```
`&` has the lowest precedence, so `A, B & C` is the intersection of `A, B` with `C`. A range is
evaluated in each branch where both `atom1` and `atom2` match, and it is an error if either
matches more than one element in that branch. If `atom2` comes before `atom1`, the range wraps
around the end of the branch.

## Name matching

If `pattern` is a `String`, the branch and element names may use the Bmad wild card
characters `*`, which matches any number of characters (including zero), and `%`, which matches
any single character. There are no other wildcard characters here.

If `pattern` is a `Regex`, e.g. `r"q[0-9]+"`, the branch and element names are Julia regular
expressions. Each must match the whole name, so `r"Q"` does not match an element named `Q1`.
The flags of `pattern` (e.g. `i` for case insensitive) are applied to each. Operator characters
in a regex group `(...)`, character class `[...]`, or quantifier `{n,m}`, or that are escaped
with a backslash, are part of the regular expression.

Matching is case sensitive unless the `i` flag is used with a `Regex`.

## Examples
```julia
findelements(lat, "q*")                     # Elements whose name begins with "q".
findelements(lat, r"q.*")                   # Same as above using a regex.
findelements(lat, "Quadrupole::q%")         # Quadrupoles with a two character name starting with "q".
findelements(lat, "ring>>7")                # 7th element of the branch named "ring".
findelements(lat, "b*>>bpm#2")              # 2nd element named "bpm" in each branch with a name
                                            #   starting with "b".
findelements(lat, "m1:m2")                  # Elements from "m1" through "m2" in a line.
findelements(lat, "Marker::* & m1:m2")      # Markers from "m1" through "m2".
findelements(lat, "q1, q2")                 # Elements named "q1" or "q2".
findelements(lat, r"(q|s)[0-9]{1,2}")       # Regex with operator characters in a group and quantifier.
```

See also `findbranches`.
"""
function findelements(where::Union{Lattice,Branch,Beamline},
                      pattern::Union{AbstractString,Regex})
  nm = _NameMatcher(pattern)
  texts, ops = _lex_match_str(nm.str, nm.is_regex)
  lines = _search_lines(where)

  function atom_ids(texts, ops)
    pieces = _split_at_op(texts, ops, ":")
    atoms = [_parse_ele_atom(nm, t, o) for (t, o) in pieces]
    length(atoms) == 1 && return _eval_ele_atom(lines, atoms[1])
    length(atoms) == 2 && return _eval_ele_range(lines, atoms[1], atoms[2], nm)
    error("Malformed range with more than one \":\". Match string: $(nm.str)")
  end

  return LineElement[lines[il].eles[ix] for (il, ix) in _eval_match_str(atom_ids, nm, texts, ops)]
end

#---------------------------------------------------------------------------------------------------

"""
    findbranches(lat::Lattice, pattern::Union{AbstractString,Regex}) -> Vector{Branch}

Returns all the `Branch`es in `lat` that match `pattern`, in the order of the branches in `lat`.
Each branch appears at most once.

`pattern` is built from atoms that are either a branch name or an integer index of the branch
in `lat`. Atoms may be combined with `,` (union) and `&` (intersection). Names are matched as
with `findelements`: a `String` `pattern` may use the Bmad wild card characters `*` and `%`
while with a `Regex` pattern the names are Julia regular expressions that must match the whole
name.

## Examples
```julia
findbranches(lat, "ring")          # The branch named "ring".
findbranches(lat, "x*, 1")         # Branches whose name starts with "x" and the first branch.
findbranches(lat, r"b[0-9]+")      # Branches named "b" followed by digits.
```

See also `findelements`.
"""
function findbranches(lat::Lattice, pattern::Union{AbstractString,Regex})
  nm = _NameMatcher(pattern)
  texts, ops = _lex_match_str(nm.str, nm.is_regex)

  function atom_ids(texts, ops)
    isempty(ops) || error("Malformed branch match. Must be a branch name or index. Match string: $(nm.str)")
    index = _is_index(texts[1]) ? parse(Int, texts[1]) : 0
    br_regex = index > 0 ? nothing : _name_regex(nm, texts[1])
    return [(1, ib) for (ib, br) in enumerate(lat.branches)
                    if (index > 0 ? ib == index : occursin(br_regex, br.name))]
  end

  return Branch[lat.branches[ib] for (_, ib) in _eval_match_str(atom_ids, nm, texts, ops)]
end
