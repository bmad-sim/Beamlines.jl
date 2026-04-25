"""
    findchildren(ele::LineElement, bl::Beamline)

Finds all `LineElement`s in the Beamline `bl` with parent `ele`.
"""
findchildren(ele::LineElement, bl::Beamline) = filter(x->x.parent === ele, bl.line)
