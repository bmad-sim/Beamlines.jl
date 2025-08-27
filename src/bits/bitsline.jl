#=

Defines the BitsBeamline type: a compressed,
bytes representation of the lattice.

This is really the most complicated part of 
the entire Beamlines.jl package. The beamline 
is compressed into an array of bytes.

=#

# WE SHOULD ALLOW ANOTHER TYPE WITH VARYING LENGTH N_bytes!!
# This will benefit in cases where e.g. one element has 4 elements but 
# the rest have two

struct MultipleTrackingMethods end
struct Dense end
struct Sparse end # Sparse is NOT implemented yet but here as a placeholder 

struct BitsBeamline{
  TM,           # Equal to MultipleTrackingMethods if elements use different tracking methods, else equal to universal tracking method
  TMI,          # If MultipleTrackingMethods, then SVector{N_ele,UInt8} specifying the tracking method, else nothing
  TME,          # extras for the tracking methods, <:SVector where the SVector stores the extras for each element (will be of eltype empty union Union{} if nothing)
  DS,           # Dense or Sparse representation
  R,            # If there is repeating, then a SVector{N_ele,<:Unsigned Int} specifying how to repeat through them
  N_ele,        # EFFECTIVE number of elements (after applying the repeat optimization)
  N_bytes,      # Number of bytes per element
  BitsLineElementType # The type of the BitsLineElement representable by each element in the BitsBeamline
}
  tracking_method::TMI         
  tracking_method_extras::SVector{N_ele,TME}
  rep::R
  params::SVector{N_ele,NTuple{N_bytes,UInt8}}
end


# View 
struct BitsLineElement{
  UP<:Union{BitsUniversalParams,Nothing},
  BM<:Union{BitsBMultipoleParams,Nothing},
  BP<:Union{BitsBendParams,Nothing},
  AP<:Union{BitsAlignmentParams,Nothing},
  PP<:Union{BitsPatchParams,Nothing},
  DP<:Union{BitsApertureParams,Nothing},
}
  UniversalParams::UP
  BMultipoleParams::BM
  BendParams::BP
  AlignmentParams::AP
  PatchParams::PP
  ApertureParams::DP
end
function Base.getproperty(ble::BitsLineElement, key::Symbol)
  if key == :L
    return ble.UniversalParams.L
  else
    return getfield(ble, key)
  end
end

@inline unsafe_getparams(ele::BitsLineElement, param::Symbol) = getfield(ele, param)

function unpack_type_params(::Type{BitsBeamline{TM,TMI,TME,DS,R,N_ele,N_bytes,BitsLineElement{UP,BM,BP,AP,PP,DP}}}) where {TM,TMI,TME,DS,R,N_ele,N_bytes,UP,BM,BP,AP,PP,DP}
  return TM,TMI,TME,DS,R,N_ele,N_bytes,UP,BM,BP,AP,PP,DP
end
function unpack_type_params(::BitsBeamline{TM,TMI,TME,DS,R,N_ele,N_bytes,BitsLineElement{UP,BM,BP,AP,PP,DP}}) where {TM,TMI,TME,DS,R,N_ele,N_bytes,UP,BM,BP,AP,PP,DP}
  return TM,TMI,TME,DS,R,N_ele,N_bytes,UP,BM,BP,AP,PP,DP
end


function BitsBeamline(bl::Beamline; store_normalized=false, prep=nothing)
  if isnothing(prep)
    prep = prep_bitsbl(bl, store_normalized)
  end
  TM,TMI,TME,DS,R,N_ele,N_bytes,UP,BM,BP,AP,PP,DP = unpack_type_params(prep[1])
  rep = prep[2]

  if TM == MultipleTrackingMethods
    tracking_method = Vector{UInt8}(undef, N_ele)
  else
    tracking_method = nothing
  end
  tracking_method_extras = Vector{TME}(undef, N_ele)

  # Allocate the byte array
  params = Vector{NTuple{N_bytes,UInt8}}(undef, N_ele)

  # Helper function for the set:
  function setval(i, arr, map::UInt8, T, t)
    @assert T == promote_type(T,typeof(t))
    @reset arr[i] = map
    i += 1
    s = sizeof(T)
    @reset arr[i:i+s-1] = reinterpret(NTuple{s,UInt8}, T(t))
    i += s
    return i, arr
  end
  
  bl_idx = 1
  bbl_idx = 1
  while bl_idx <= length(bl.line)
    repeat_count = rep[bbl_idx] 
    repeat_n_eles = 0
    while true
      ele = bl.line[bl_idx]
      i = 1
      
      if TM == MultipleTrackingMethods
        tracking_method[bbl_idx] = TRACKING_METHOD_MAP[typeof(ele.tracking_method)]
      end
      tracking_method_extras[bbl_idx] = get_promoted_tm_extras(TME, ele.tracking_method)

      cur_byte_arr = ntuple(t->0xff, Val{N_bytes}())
  
      i, cur_byte_arr = setval(i, cur_byte_arr, 0x0, eltype(UP), ele.L)
  
      bmp = ele.BMultipoleParams
      if !isnothing(bmp)
        for bm in bmp
          if !(bm.tilt ≈ 0)
            # 1 -> 22 inclusive is tilt (22 multipole orders including 0)
            i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(1+bm.order), eltype(BM), bm.tilt)
          end
          if !(bm.n ≈ 0)
            n = bm.n
            if !bm.integrated
              n *= ele.L
            end
            if isnormalized(BM)
              if !bm.normalized
                n /= ele.R_ref
              end
            else
              if bm.normalized
                n *= ele.R_ref
              end
            end
            # 23 -> 44 inclusive is n (22 multipole orders including 0)
            i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(23+bm.order), eltype(BM), n)
          end
          if !(bm.s ≈ 0)
            s = bm.s
            if !bm.integrated
              s *= ele.L
            end
            if isnormalized(BM)
              if !bm.normalized
                s /= ele.R_ref
              end
            else
              if bm.normalized
                s *= ele.R_ref
              end
            end
            # 45 -> 66 inclusive is s (22 multipole orders including 0)
            i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(45+bm.order), eltype(BM), s)
          end
        end      
      end
  
      # 67 -> 70 inclusive are BendParams
      bp = ele.BendParams
      if !isnothing(bp)
        for (k,v) in enumerate((bp.g_ref,bp.tilt_ref,bp.e1,bp.e2))
          if v != 0 
            i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(k+66), eltype(BP), v)
          end
        end
      end
  
      # 71 -> 76 inclusive are AlignmentParams
      ap = ele.AlignmentParams
      if !isnothing(ap)
        for (k,v) in enumerate((ap.x_offset,ap.y_offset,ap.z_offset,ap.x_rot,ap.y_rot,ap.tilt))
          if v != 0 
            i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(k+70), eltype(AP), v)
          end
        end
      end

      # 77 -> 83 inclusive are PatchParams
      pp = ele.PatchParams
      if !isnothing(pp)
        for (k,v) in enumerate((pp.dt, pp.dx, pp.dy, pp.dz, pp.dx_rot, pp.dy_rot, pp.dz_rot))
          if v != 0 
            i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(k+76), eltype(PP), v)
          end
        end
      end

      # 84 -> 91 inclusive are ApertureParams
      dp = ele.ApertureParams
      if !isnothing(dp)
        for (k,v) in enumerate((dp.x1_limit, dp.x2_limit, dp.y1_limit, dp.y2_limit))
          if v != 0 
            i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(k+83), eltype(DP), v)
          end
        end
        # Now check dshape, dat, dswb, dactive
        if dp.aperture_shape != shape(DP)
          i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(88), UInt8, UInt8(dp.aperture_shape))
        end
        if dp.aperture_at != at(DP)
          i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(89), UInt8, UInt8(dp.aperture_at))
        end
        if dp.aperture_shifts_with_body != swb(DP)
          i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(90), Bool, dp.aperture_shifts_with_body)
        end
        if dp.aperture_shifts_with_body != active(DP)
          i, cur_byte_arr = setval(i, cur_byte_arr, UInt8(91), Bool, dp.aperture_active)
        end
      end
      
      #=if i > N_bytes
        println("here is the maximally filled one!: $bl_idx: $cur_byte_arr")
      end=#
      params[bbl_idx] = cur_byte_arr

      repeat_n_eles += 1
      bbl_idx += 1
      bl_idx += 1
      if bbl_idx > N_ele || rep[bbl_idx] != 0
        break
      end
    end
    bl_idx += repeat_n_eles*(repeat_count-1)
    # Beamline has the sequence:
    # [ 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15 ...] indexes
    # [ 5, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 6,6, 1,2,3,1,2,3,7,6]
    #
    # For this rep array:
    # [1, 2,3,4,5,  6,  7,8,9,  10,11] indexes 
    # [1, 3,0,0,0,  2,  2,0,0,  1, 1]
    #
    # We exit the loop with bbl_idx = 2 and bl_idx = 2
    # Now we get rep[bbl_idx] = 3 -> repeat_count = 3
    # add to element 2 in BBL and then:
    # End of iteration:
    # 1: bbl_idx = 3, bl_idx = 3, repeat_n_eles = 1, ele added to 2
    # 2: bbl_idx = 4, bl_idx = 4, repeat_n_eles = 2, ele added to 3
    # 3: bbl_idx = 5, bl_idx = 5, repeat_n_eles = 3, ele added to 4
    # 4: bbl_idx = 6, bl_idx = 6, repeat_n_eles = 4, ele added to 5. BREAK!

    # Now I want to not touch bbl_idx, but I need to evolve bl_idx accordingly.
    # bl_idx = 6, I need to move to 14 
    # Basically need to add repeat_n_eles*(repeat_count-1) to it?
    # 4*(3-1) = 8
    # 6+8 = 14 indeed

  end
  if R == Nothing
    rep = nothing
  end
  make_arr(t) = isnothing(t) ? nothing : SVector{N_ele,eltype(t)}(t)
  
  #return make_arr(tracking_method_extras)f
  return (prep[1])(make_arr(tracking_method),make_arr(tracking_method_extras),make_arr(rep),make_arr(params))
end

function prep_bitsbl(bl::Beamline, store_normalized::Bool=false) #, arr::Type{T}=SVector{length(bl.line)}) where {T}
  # Default values:
  TM  = Nothing # Set by first element, then if any elements differ, set to MultipleTrackingMethods
  TMI = Nothing
  TME = SVector{0,Union{}}
  DS = Dense
  R   = Nothing
  N_ele = length(bl.line)
  N_bytes = zeros(Int, N_ele)

  # These are the types of the structures in BitsLineElement:
  # They default to Nothing for similar behavior as LineElement
  UP = Nothing
  BM = Nothing
  BP = Nothing
  AP = Nothing
  PP = Nothing
  DP = Nothing

  N_parameters = zeros(Int, N_ele)
  line_w_duplicates = Vector{LineElement}(undef, N_ele)

  # ApertureParams will rudimentarily check what defaults (shape, at, swb, active)
  # to store in its type via a first pass choosing the most frequently encountered options
  # This may not be optimal but it is a decent guess.
  shapes = zeros(Int, length(instances(ApertureShape.T)))
  ats = zeros(Int, length(instances(ApertureAt.T)))
  swbs = zeros(Int, 2)
  active = zeros(Int, 2)
  for ele in bl.line
    dp = ele.ApertureParams
    if !isnothing(dp)
      shapes[Int(dp.aperture_shape)+1] += 1
      ats[Int(dp.aperture_at)+1] += 1
      swbs[Int(dp.aperture_shifts_with_body)+1] += 1
      active[Int(dp.aperture_active)+1] += 1
    end
  end
  if any(shapes .!= 0)
    dshape::ApertureShape.T = ApertureShape.T(argmax(shapes)-1)
    dat::ApertureAt.T = ApertureAt.T(argmax(ats)-1)
    dswb::Bool = argmax(swbs)-1
    dactive::Bool = argmax(active)-1
  end

  for i in 1:length(bl.line)
    ele = bl.line[i]
    ele_tm = ele.tracking_method
    if TM == Nothing 
      if isbits(ele_tm)
        TM = ele_tm
      else
        TM = MultipleTrackingMethods
        TMI = SVector{N_ele,UInt8}
      end
    end

    if TM != ele_tm
      TM = MultipleTrackingMethods
      TMI = SVector{N_ele,UInt8}
    end

    ele_tme = get_tracking_method_extras(ele_tm)
    if length(ele_tme) > length(TME)
      TME = similar_type(TME, Size(ele_tme))
    end
    TME = similar_type(TME, promote_type(eltype(ele_tme), eltype(TME)))
    

    # Now onto the parameters
    ele_L = ele.L
    if UP == Nothing
      UP = BitsUniversalParams{typeof(ele_L)}
    else
      UP = BitsUniversalParams{promote_type(eltype(UP),typeof(ele_L))}
    end
    N_bytes[i] += sizeof(ele_L)
    N_parameters[i] += 1

    bmp = ele.BMultipoleParams
    if !isnothing(bmp) && length(bmp) > 0 # then we do have a multipole 
      # First check the eltypes:
      if BM == Nothing
        BM = BitsBMultipoleParams{eltype(bmp),0,store_normalized}
      end

      if length(BM) < length(bmp)
        BM = BitsBMultipoleParams{eltype(BM),length(bmp),store_normalized}
      end

      if eltype(BM) != promote_type(eltype(BM),eltype(bmp))
        BM = BitsBMultipoleParams{eltype(bmp),length(BM),store_normalized}
      end
      # Now check each multipole - we have to do this bc only 
      # unnormalized+integrated is stored in BitsBeamLine, which 
      # can cause a promotion for the eltype of BitsBMultipole
      for bm in bmp #values(bmp.bdict)
        if !(bm.tilt ≈ 0) # only store tilts when nonzero
          N_bytes[i] += sizeof(eltype(bmp)) 
          N_parameters[i] += 1
        end

        bits_strength_type = eltype(bmp)
        
        if !(bm.n ≈ 0) || !(bm.s ≈ 0) # also only store strengths when nonzero
          if store_normalized != bm.normalized
            bits_strength_type = promote_type(bits_strength_type, typeof(ele.R_ref))
          end
          if !bm.integrated
            bits_strength_type = promote_type(bits_strength_type, typeof(ele_L))
          end
          N_bytes[i] += sizeof(bits_strength_type)
          if !(bm.n ≈ 0)
            N_parameters[i] += 1
          end
          if !(bm.s ≈ 0)
            N_parameters[i] += 1
          end
          BM = BitsBMultipoleParams{promote_type(eltype(BM),bits_strength_type),length(BM),store_normalized}
        end
      end      
    end


    bp = ele.BendParams
    if !isnothing(bp)
      if BP == Nothing
        BP = BitsBendParams{eltype(bp)}
      end
      for v in (bp.g_ref,bp.tilt_ref,bp.e1,bp.e2)
        if !(v ≈ 0)
          N_bytes[i] += sizeof(v)
          N_parameters[i] += 1
          BP = BitsBendParams{promote_type(eltype(BP),typeof(v))}
        end
      end
    end

    ap = ele.AlignmentParams
    if !isnothing(ap)
      if AP == Nothing
        AP = BitsAlignmentParams{eltype(ap)}
      end
      for v in (ap.x_offset,ap.y_offset,ap.z_offset,ap.x_rot,ap.y_rot,ap.tilt)
        if !(v ≈ 0)
          N_bytes[i] += sizeof(v)
          N_parameters[i] += 1
          AP = BitsAlignmentParams{promote_type(eltype(AP),typeof(v))}
        end
      end
    end

    
    pp = ele.PatchParams
    if !isnothing(pp)
      if PP == Nothing
        PP = BitsPatchParams{eltype(pp)}
      end
      for v in (pp.dt, pp.dx, pp.dy,  pp.dz, pp.dx_rot, pp.dy_rot, pp.dz_rot)
        if !(v ≈ 0)
          N_bytes[i] += sizeof(v)
          N_parameters[i] += 1
          PP = BitsPatchParams{promote_type(eltype(PP),typeof(v))}
        end
      end
    end


    dp = ele.ApertureParams
    if !isnothing(dp)
      if DP == Nothing
        DP = BitsApertureParams{eltype(dp),dshape,dat,dswb,dactive}
      end
      for v in (dp.x1_limit, dp.x2_limit, dp.y1_limit, dp.y2_limit)
        if !(v ≈ 0)
          N_bytes[i] += sizeof(v)
          N_parameters[i] += 1
          DP = BitsApertureParams{promote_type(eltype(DP),typeof(v)),dshape,dat,dswb,dactive}
        end
        if dp.aperture_shape != dshape
          N_bytes[i] += sizeof(dp.aperture_shape)
          N_parameters[i] += 1
        end
        if dp.aperture_at != dat
          N_bytes[i] += sizeof(dp.aperture_at)
          N_parameters[i] += 1
        end
        if dp.aperture_shifts_with_body != dswb
          N_bytes[i] += sizeof(dp.aperture_shifts_with_body)
          N_parameters[i] += 1
        end
        if dp.aperture_active != dactive
          N_bytes[i] += sizeof(dp.aperture_active)
          N_parameters[i] += 1
        end
      end
    end

    # Now do the duplicates check
    j = 1   
    ele_to_add = ele
    while isassigned(line_w_duplicates, j)
      if line_w_duplicates[j] ≈ ele
        ele_to_add = line_w_duplicates[j]
        break
      end
      j += 1
    end
    line_w_duplicates[i] = ele_to_add 
  end
  bl_N_bytes = maximum(N_bytes)

  # Every parameter now needs at least 1 byte to say what it is
  i = 1
  while i <= N_ele
    if bl_N_bytes - N_bytes[i] - N_parameters[i] < 0
      bl_N_bytes += 1
      i -= 1
    end
    i += 1
  end

  # Now compress if there are repeats
  # We default to a Dense representation bc more cache friendly but 
  # if we go over 64KB we can attempt a Sparse representation
  # if that goes over too, then just use Dense bc cache friendly.

  idxs_w_duplicates = map(t->t.beamline_index, line_w_duplicates)
  rep = find_consecutive_repeats(idxs_w_duplicates)
  if length(rep) != N_ele # then we rep
    N_ele = length(rep)

    if TMI != Nothing
      TMI = similar_type(TMI, Size(N_ele))
    end
  
    max_repeats = maximum(rep)
    if max_repeats <= Int(typemax(UInt8))
      R = SVector{N_ele,UInt8}
    elseif max_repeats <= Int(typemax(UInt16))
      R = SVector{N_ele,UInt16}
    elseif max_repeats <= Int(typemax(UInt32))
      R = SVector{N_ele,UInt32}
    else
      R = SVector{N_ele,UInt}
    end
    DS = Dense
  end

  outtype = BitsBeamline{TM,TMI,TME,DS,R,N_ele,bl_N_bytes,BitsLineElement{UP,BM,BP,AP,PP,DP}}
  if sizeof(outtype) > 65536
    @warn "This BitsBeamline is size $(sizeof(outtype)), which is greater than the 65536 bytes allowed in constant memory on a CUDA GPU. Consider combining repeated consecutive elements, using Float32/Float16 for LineElement parameters, simplifying the beamline, or splitting it up into one size that fits in constant memory and the rest in global memory."
  end
  if !isbitstype(outtype)
    error("Something bad happened")
  end
  return outtype, rep
end


function find_consecutive_repeats(arr)
  # go through the entire array checking for the smallest patterns
  # First check each pair and see if any consecutive repeats
  # then check each triplet
  # then quad
  # etc etc
  # Note that we do NOT nest, so once a repeated pair is found, 
  # we specify the rep and the continue down the array, ignoring 
  # anything before
  #=

  Consider:
  [ 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15]
  [ 5, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 6,6,1,2,3,1,2,3,7,6]
i +3*4 + 1
  We need to know 1) number of elements in a rep, and 2) how many times 
  to rep it. The above example should return:

  [1, 3,0,0,0,  2,  2,0,0,  1, 1]

  The first number tells you how many times you should go through the 
  subsequent sequence of zeros inclusive of that element. 
  
  If 1, then no repeating (so all can be ones or zeros).
  =#
  n = length(arr)
  i = 1
  repeats = Int[]
  while i <= n
    found = false
    #println("checking range $(1:floor(Int,(n-i+1)/2))")
    for eles_per_repeat in 1:floor(Int,(n-i+1)/2)
      cur_pattern = arr[i:i+eles_per_repeat-1]
      count = 1
      #println("Checking pattern $cur_pattern")
      #=if i+(count+1)eles_per_repeat-1 <= n
        println("does it equal $(arr[i+count*eles_per_repeat:i+(count+1)eles_per_repeat-1])")
      end=#
      while i+(count+1)eles_per_repeat-1 <= n && cur_pattern == arr[i+count*eles_per_repeat:i+(count+1)eles_per_repeat-1]
        count += 1
        #=if i+(count+1)eles_per_repeat-1 <= n
          println("does it equal $(arr[i+count*eles_per_repeat:i+(count+1)eles_per_repeat-1])")
        end=#
      end
      if count > 1 
        #println("we found one! the following repeats $count times starting at $i: $cur_pattern ")
        # then we have a rep starting at index i of eles_per_repeat 
        # lengths repeating count-1 times
        append!(repeats, [count, zeros(Int, eles_per_repeat-1)...])
        i += count*eles_per_repeat
        found = true
        break
      end
    end
    if !found
      push!(repeats, 1)
      i += 1
    end
  end
  return repeats
end


# Convert BitsBeamline back to regular Beamline
# Compression is lossy - all BMultipoles are converted 
# to integrated and a uniform choice of normalized/unnormalized
function Beamline(bbl::BitsBeamline{TM}; R_ref=NaN) where {TM}

  if !isnothing(bbl.tracking_method)
    TRACKING_METHOD_INVERSE_MAP = Dict(value => key for (key, value) in TRACKING_METHOD_MAP)
  end
  if isnothing(bbl.rep)
    bl = Vector{LineElement}(undef, length(bbl.params))
    for i in 1:length(bbl.params)
      ble = BitsLineElement(bbl, i)
      le = LineElement()

      if isnothing(bbl.tracking_method)
        le.tracking_method = TM
      else
        tm_type = TRACKING_METHOD_INVERSE_MAP[bbl.tracking_method[i]]
        tme_length = length(first(Base.return_types(get_tracking_method_extras, (tm_type,))))
        le.tracking_method = tm_type(bbl.tracking_method_extras[i][1:tme_length]...)
      end

      le.L = ble.UniversalParams.L
      le.BMultipoleParams = BMultipoleParams(ble.BMultipoleParams)
      le.BendParams = BendParams(ble.BendParams)
      le.AlignmentParams = AlignmentParams(ble.AlignmentParams)
      le.PatchParams = PatchParams(ble.PatchParams)
      le.ApertureParams = ApertureParams(ble.ApertureParams)
      bl[i] = le
    end
  else
    bl = Vector{LineElement}(undef, 0)
    i = 1 
    while i <= length(bbl.params)
      repeat_count = bbl.rep[i]
      start_i = i
      #println("repeat_count = $repeat_count, start_i=$start_i")
      for j in 1:repeat_count
        i = start_i
        #println("starting again count $j")
        while true
          ble = BitsLineElement(bbl, i)
          le = LineElement()

          if isnothing(bbl.tracking_method)
            le.tracking_method = TM
          else
            tm_type = TRACKING_METHOD_INVERSE_MAP[bbl.tracking_method[i]]
            tme_length = length(first(Base.return_types(get_tracking_method_extras, (tm_type,))))
            le.tracking_method = tm_type(bbl.tracking_method_extras[i][1:tme_length]...)
          end

          le.L = ble.UniversalParams.L
          le.BMultipoleParams = BMultipoleParams(ble.BMultipoleParams)
          le.BendParams = BendParams(ble.BendParams)
          le.AlignmentParams = AlignmentParams(ble.AlignmentParams)
          le.PatchParams = PatchParams(ble.PatchParams)
          le.ApertureParams = ApertureParams(ble.ApertureParams)
          push!(bl, le)

          i += 1
          #println("i = $i")
          if i > length(bbl.rep) || bbl.rep[i] != 0
            break
          end
        end
      end
    end
  end

  return Beamline(bl; R_ref=R_ref)


end