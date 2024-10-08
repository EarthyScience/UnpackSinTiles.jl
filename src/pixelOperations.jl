function getPixelDay(ba, doy)
    day_b = ba .== doy # get indices for day d
    day_mask = ba .< 1 # get indices for water, unmmaped and unburned pixels
    bmask = ba .* day_mask # compute mask
    return ba .* day_b .+ bmask # combine burnt pixels for day d, plus mask
end

# this one is just for fire or not fire, Bool, true -> 1, false -> 0
function getPixelDayRaw(ba, doy)
    day_b = ba .== doy # get indices for day d
    return day_b # ba .* day_b # ouput only 0 or 1 for that day
end

function monthIntervals(year)
    days = Date(year):Day(1):Date("$(year)-12-31")
    doy = dayofyear.(days)
    meses = Dates.month.(days)
    return Pair.(doy, meses)
end

function initMonthsArray(year)
    return ["$(year).$(m).01" for m in ["0".* string.(1:9)..., "10", "11", "12"]]
end

function getPixelTime(bSpaceTime, i,j)
    return [bSpaceTime[k][i,j] for k in eachindex(bSpaceTime)]
end

function cluster_entries(vec::Vector{T}, gap_length::Int) where T<:Number
    result = Vector{Vector{Int}}()
    n = length(vec)
    current_group = Int[]
    zero_count = 0
    for i in 1:n
        if vec[i] != zero(T)
            if zero_count >= gap_length && !isempty(current_group)
                push!(result, current_group)
                current_group = Int[]
            end
            push!(current_group, i)
            zero_count = 0
        else
            zero_count += 1
        end
    end
    if !isempty(current_group)
        push!(result, current_group)
    end
    return result
end

function normalize_groups(groups::Vector{Vector{Int}})
    normPairs = map(groups) do group
        group_length = length(group)
        normalized_value = 1 ./ group_length # 1 .// group_length
        Pair.(group, normalized_value)
    end
    return vcat(normPairs...)
end

function updateCounts!(afterBurn, nPairs, i, j)
    for (k, v) in nPairs
        afterBurn[k][i,j] = v
    end
    return nothing
end

function updateAfterBurn!(beforeBurn, afterBurn; burnWindow = 30)
    @showprogress for i in 1:size(beforeBurn[1], 1)
        for j in 1:size(beforeBurn[1], 2)
            onePix = getPixelTime(beforeBurn, i, j)
            gBurn = cluster_entries(onePix, burnWindow)
            normedPairs = normalize_groups(gBurn)
            updateCounts!(afterBurn, normedPairs, i, j)
        end
    end
    return nothing
end

function averageWindows(sMatrix, n::Int; mask=nothing)
    rows, cols = size(sMatrix)
    # Check if the matrix dimensions are divisible by n
    if rows % n != 0 || cols % n != 0
        error("Matrix dimensions must be divisible by n")
    end
    # Calculate the size of the output matrix
    new_rows, new_cols = rows ÷ n, cols ÷ n
    # Initialize the output matrix
    result = fill(NaN32, new_rows, new_cols) # ? NaN32 here and then missing ?
    n_smask = if isnothing(mask)
        new_rows * new_cols
    end
    # Iterate over the windows and calculate averages
    for i in 1:new_rows
        for j in 1:new_cols
            window = @view sMatrix[(i-1)*n+1:i*n, (j-1)*n+1:j*n]
            if !isnothing(mask)
                smask = @view mask[(i-1)*n+1:i*n, (j-1)*n+1:j*n]
                window .*= smask
                n_smask = sum(smask)
            end
            μ = sum(window) / n_smask # this is the mean per type, given by mask.
            result[i, j] = iszero(μ) ? NaN32 : μ
        end
    end
    return result
end

# TODO: include masks here! land, pfts.
# MODIS: LAND_COVER TYPE GLOBAL 500m
function aggTile(μBurn, afterBurn, tsteps; res = 60)
    @showprogress for t_step in 1:tsteps
        μBurn[:,:,t_step] = averageWindows(afterBurn[t_step], res)
    end
    return μBurn
end


function _compute_mask(m, to_vals)
    return m .== to_vals
end

function compute_mask(m, to_vals::AbstractVector)
    return m .∈ Ref(to_vals)
end