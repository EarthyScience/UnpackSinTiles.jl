export getTileInterval
export modisTiles

# MODIS TILES
function modisTiles()
    hs = "h" .* lpad.(string.(0:35), 2, '0')
    vs = "v" .* lpad.(string.(0:17), 2, '0')
    return [h*v for v in vs, h in hs]
end


"""
    getTileInterval(hv_tile::String, n_h::Int=36, n_v::Int=18, h_bound::UnitRange=1:1440, v_bound::UnitRange=1:720)

Given a label in the format "hXXvYY", this function calculates the corresponding intervals
in the specified ranges `h_bound` and `v_bound`.

# Arguments:
- `hv_tile::String`: The input label, expected to be in the format "hXXvYY".
- `n_h::Int`: Number of intervals to divide the `h_bound` range (default is 36).
- `n_v::Int`: Number of intervals to divide the `v_bound` range (default is 18).
- `h_bound::UnitRange`: The full range of `h` (default is `1:1440`).
- `v_bound::UnitRange`: The full range of `v` (default is `1:720`).

# Returns:
- A tuple of two ranges: the interval in `h_bound` and the interval in `v_bound`.

"""
function getTileInterval(hv_tile, n_h=36, n_v=18, h_bound=1:1440, v_bound=1:720)
    # Extract the h and v indices from the label (assuming format "hXXvYY")
    h_index = parse(Int, hv_tile[2:3])
    v_index = parse(Int, hv_tile[5:6])
    
    h_step = length(h_bound) ÷ n_h
    v_step = length(v_bound) ÷ n_v
    
    # Calculate the start and end of the interval for h and v
    h_start = h_bound[1] + h_index * h_step
    h_end = h_start + h_step - 1
    
    v_start = v_bound[1] + v_index * v_step
    v_end = v_start + v_step - 1
    
    return CartesianIndices((v_start:v_end, h_start:h_end)) #h_start:h_end, v_start:v_end
end

# Example usage:
# result = getTileInterval("h35v17")
# result = getTileInterval("h01v00")
# result = getTileInterval("h00v01")

# a_test = rand(720, 1440)
# a_test[result]