macro elements(expr_or_block)
  return _macro_elements(expr_or_block)
end

# This is kept in to prevent a breaking change for now
macro eles(expr_or_block)
  t = _macro_elements(expr_or_block)
  Base.depwarn("`@eles` is deprecated and will be removed in the next breaking release. Use `@elements` instead.", :eles; force=true)
  return t
end

function _macro_elements(expr_or_block)
  if expr_or_block isa Expr && expr_or_block.head == :block
    block = expr_or_block
    return Expr(:block, map(block.args) do x
      if x isa LineNumberNode
        return x
      end
      return add_name(x)
    end...)
  else
    expr = expr_or_block
    return add_name(expr)
  end
end

function add_name(expr)
  if @capture(expr,  name_ = rhs_) 
    namestr = String(name)
    return :($(esc(name)) = setname($(esc(rhs)), $namestr))
  else
    return :($(esc(expr)))
  end
end

function setname(ele::LineElement, name::String)
  ele.name = name
  return ele
end

setname(not_ele, name::String) = not_ele

function elements(eles_dict::AbstractDict)
  for (name, ele) in eles_dict
    if ele.name == "" # Unset
      ele.name = name
    end
  end
  return eles_dict
end

#=
  @nospecialize
  for (name, ele) in eles
    if ele.name == "" # Unset
      ele.name = name
    end
  end
  return eles
  #println(String.(keys(eles)))
  #return Dict(String.(collect(keys(eles))), values(eles))
end
=#
#=
Base.@nospecializeinfer function _elements(@nospecialize(eles))

  return eles
end=#