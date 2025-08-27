#=
struct BitsLineElement{
  UP<:Union{BitsUniversalParams,Nothing},
  BM<:Union{BitsBMultipoleParams,Nothing},
  BP<:Union{BitsBendParams,Nothing},
  AP<:Union{BitsAlignmentParams,Nothing},
  PP<:Union{BitsPatchParams,Nothing}
}
  UniversalParams::UP
  BMultipoleParams::BM
  BendParams::BP
  AlignmentParams::AP
  PatchParams::PP
end
=#

@inline function readval(i, arr, T)
  i += 1
  s = sizeof(T)
  slice = ntuple(i->0xff, sizeof(T))
  for j in 1:length(slice)
    @reset slice[j] = arr[i+j-1]
  end
  val = reinterpret(T, slice)
  i += s
  return i, val
end

@inline tilt_id_to_order(id) = Int8(id-1)
@inline n_id_to_order(id) = Int8(id-23)
@inline s_id_to_order(id) = Int8(id-45)


function BitsLineElement(bbl::BitsBeamline, idx::Integer=1)
  TM,TMI,TME,DS,R,N_ele,N_bytes,UP,BM,BP,AP,PP,DP = unpack_type_params(bbl)
  if DS == Sparse
    error("Sparse BitsBeamline not implemented yet!")
  end

  params::NTuple{N_bytes,UInt8} = bbl.params[idx] # Byte array we now need to process
  up::UP = UP()
  bmp::BM = BM()
  bp::BP  = BP()
  ap::AP = AP()
  pp::PP = PP()
  dp::DP = DP()


  i = 1
  bm_count = 0
  while i <= length(params) && params[i] != 0xff
    if params[i] == 0x0 # Length!
      i, L = readval(i, params, eltype(UP))
      @reset up.L = L
    end

    
    if i <= length(params) && params[i] > 0x0 && params[i] < UInt8(67) # then we have some kinda multipole business going on
      orders::SVector{length(BM),Int8} = bmp.order
      n = bmp.n
      s = bmp.s
      tilt = bmp.tilt
      ni::eltype(BM) = 0
      si::eltype(BM) = 0
      tilti::eltype(BM) = 0
      id = params[i]
      i, v = readval(i, params, eltype(BM))
      if id < UInt8(23) # tilt
        order = tilt_id_to_order(id)
        if !(order in orders)
          @reset orders[bm_count+1] = order::Int8
          bm_count += 1
        end
        bm_idx = -1
        for j in 1:length(orders)
          if orders[j] == order
            bm_idx = j
            break
          end
        end
        ni = bmp.n[bm_idx]
        if isnan(ni)
          ni = zero(eltype(BM))
        end
        si = bmp.s[bm_idx]
        if isnan(si)
          si = zero(eltype(BM))
        end
        @reset n[bm_idx] = ni
        @reset s[bm_idx] = si
        @reset tilt[bm_idx] = v
      end

      if id >= UInt8(23) && id < UInt8(45) # normal strength
        order = n_id_to_order(id)
        if !(order in orders)
          @reset orders[bm_count+1] = order::Int8
          bm_count += 1
        end
        bm_idx = -1
        for j in 1:length(orders)
          if orders[j] == order
            bm_idx = j
            break
          end
        end
        tilti = bmp.tilt[bm_idx]
        if isnan(tilti)
          tilti = zero(eltype(BM))
        end
        si = bmp.s[bm_idx]
        if isnan(si)
          si = zero(eltype(BM))
        end
        @reset n[bm_idx] = v
        @reset s[bm_idx] = si
        @reset tilt[bm_idx] = tilti
      end

      if id >= UInt8(45) # skew strength
        order = s_id_to_order(id)
        if !(order in orders)
          @reset orders[bm_count+1] = order::Int8
          bm_count += 1
        end
        bm_idx = -1
        for j in 1:length(orders)
          if orders[j] == order
            bm_idx = j
            break
          end
        end
        tilti = bmp.tilt[bm_idx]
        if isnan(tilti)
          tilti = zero(eltype(BM))
        end
        ni = bmp.n[bm_idx]
        if isnan(ni)
          ni = zero(eltype(BM))
        end
        @reset n[bm_idx] = ni
        @reset s[bm_idx] = v
        @reset tilt[bm_idx] = tilti
      end
      @reset bmp = BM(n, s, tilt, orders)
    end

    if i <= length(params) && params[i] >= UInt8(67)  && params[i] < UInt8(71) # bendparams!
      id = params[i]
      if isnan(bp.g_ref)
        @reset bp.g_ref = zero(eltype(BP))
        @reset bp.tilt_ref = zero(eltype(BP))
        @reset bp.e1 = zero(eltype(BP))
        @reset bp.e2 = zero(eltype(BP))
      end

      i, v = readval(i, params, eltype(BP))
      if id == UInt8(67)
        @reset bp.g_ref = v
      elseif id == UInt8(68)
        @reset bp.tilt_ref = v
      elseif id == UInt8(69)
        @reset bp.e1 = v
      else
        @reset bp.e2 = v
      end
    end

    if i <= length(params) && params[i] >= UInt8(71)  && params[i] < UInt8(77) # alignmentparams
      id = params[i]
      if isnan(ap.x_offset)
        @reset ap.x_offset = zero(eltype(AP))
        @reset ap.y_offset = zero(eltype(AP))
        @reset ap.z_offset = zero(eltype(AP))
        @reset ap.x_rot = zero(eltype(AP))
        @reset ap.y_rot = zero(eltype(AP))
        @reset ap.tilt = zero(eltype(AP))
      end

      i, v = readval(i, params, eltype(AP))
      if id == UInt8(71)
        @reset ap.x_offset = v
      elseif id == UInt8(72)
        @reset ap.y_offset = v
      elseif id == UInt8(73)
        @reset ap.z_offset = v
      elseif id == UInt8(74)
        @reset ap.x_rot = v
      elseif id == UInt8(75)
        @reset ap.y_rot = v
      else
        @reset ap.tilt = v
      end
    end

    if i <= length(params) && params[i] >= UInt8(77)  && params[i] < UInt8(84) # patchparams
      id = params[i]
      if isnan(pp.dt)
        @reset pp.dt = zero(eltype(PP))
        @reset pp.dx = zero(eltype(PP))
        @reset pp.dy = zero(eltype(PP))
        @reset pp.dz = zero(eltype(PP))
        @reset pp.dx_rot = zero(eltype(PP))
        @reset pp.dy_rot = zero(eltype(PP))
        @reset pp.dz_rot = zero(eltype(PP))
      end

      i, v = readval(i, params, eltype(PP))
      if id == UInt8(77)
        @reset pp.dt = v
      elseif id == UInt8(78)
        @reset pp.dx = v
      elseif id == UInt8(79)
        @reset pp.dy = v
      elseif id == UInt8(80)
        @reset pp.dz = v
      elseif id == UInt8(81)
        @reset pp.dx_rot = v
      elseif id == UInt8(82)
        @reset pp.dy_rot = v
      else
        @reset pp.dz_rot = v
      end
    end

    if i <= length(params) && params[i] >= UInt8(84)  && params[i] < UInt8(92) # apertureparams
      id = params[i]
      if isnan(dp.x1_limit)
        dp = DP(zero(eltype(DP)), zero(eltype(DP)), zero(eltype(DP)), zero(eltype(DP)), shape(DP), at(DP), swb(DP), active(DP))
      end

      if id == UInt8(84)
        i, v = readval(i, params, eltype(DP))
        dp = DP(v, dp.x2_limit, dp.y1_limit, dp.y2_limit, dp.aperture_shape, dp.aperture_at, dp.aperture_shifts_with_body, dp.aperture_active)
      elseif id == UInt8(85)
        i, v = readval(i, params, eltype(DP))
        dp = DP(dp.x1_limit, v, dp.y1_limit, dp.y2_limit, dp.aperture_shape, dp.aperture_at, dp.aperture_shifts_with_body, dp.aperture_active)
      elseif id == UInt8(86)
        i, v = readval(i, params, eltype(DP))
        dp = DP(dp.x1_limit, dp.x2_limit, v, dp.y2_limit, dp.aperture_shape, dp.aperture_at, dp.aperture_shifts_with_body, dp.aperture_active)
      elseif id == UInt8(87)
        i, v = readval(i, params, eltype(DP))
        dp = DP(dp.x1_limit, dp.x2_limit, dp.y1_limit, v, dp.aperture_shape, dp.aperture_at, dp.aperture_shifts_with_body, dp.aperture_active)
      elseif id == UInt8(88)
        i, v = readval(i, params, ApertureShape.T)
        dp = DP(dp.x1_limit, dp.x2_limit, dp.y1_limit, dp.y2_limit, v, dp.aperture_at, dp.aperture_shifts_with_body, dp.aperture_active)
      elseif id == UInt8(89)
        i, v = readval(i, params, ApertureAt.T)
        dp = DP(dp.x1_limit, dp.x2_limit, dp.y1_limit, dp.y2_limit, dp.aperture_shape, v, dp.aperture_shifts_with_body, dp.aperture_active)
      elseif id == UInt8(90)
        i, v = readval(i, params, Bool)
        dp = DP(dp.x1_limit, dp.x2_limit, dp.y1_limit, dp.y2_limit, dp.aperture_shape, dp.aperture_at, v, dp.aperture_active)
      else
        i, v = readval(i, params, Bool)
        dp = DP(dp.x1_limit, dp.x2_limit, dp.y1_limit, dp.y2_limit, dp.aperture_shape, dp.aperture_at, dp.aperture_shifts_with_body, v)
      end
    end

  end

  return BitsLineElement(up,bmp,bp,ap,pp,dp)
end
