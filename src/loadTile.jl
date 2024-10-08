"""
    getTilePath(tile, in_date, root_path)

Helper function for getting the full path in a nested structure of hdf files.
"""
function getTilePath(tile, in_date, root_path)
    path_month = joinpath(root_path, in_date)
    list_files = readdir(path_month)
    # find name file for the given tile
    index = findfirst(x -> occursin(tile, x), list_files)
    if !isnothing(index) && length(index) == 1 # it should be only 1
        tile_full_name = list_files[index]
        full_path = joinpath(path_month, tile_full_name)
        return full_path
    else
        @info "Tile: $(tile) not found in directory."
        return nothing
    end
end

"""
    openTile(tile, in_date, root_path)
"""
function openTile(tile, in_date, root_path)
    full_path = getTilePath(tile, in_date, root_path)
    if !isnothing(full_path)
        return hdf(full_path)
    else
        return nothing
    end
end

"""
    openTile(tile, in_date, root_path)
"""
function getTileKeys(o)
    pyKeys = o.datasets().keys()
    return ["$k" for k in pyKeys]
end


"""
    loadTileVariable(tile, in_date, root_path, variable; close_file = true)
"""
function loadTileVariable(tile, in_date, root_path, variable; close_file = true)
    hdf_tile = openTile(tile, in_date, root_path)
    if !isnothing(hdf_tile)
        hdf_data = hdf_tile.select(variable).get()
        if close_file
            hdf_tile.end() # close hdf tile
        end
        hdf_data_jl = pyconvert(Array, hdf_data)
        return hdf_data_jl
    else
        return nothing
    end
end

function loadTileBurntYear(months_r, tile, root_path; variable = "Burn Date")
    burnYear = [spzeros(Int16, 2400,2400) for _ in 1:12]
    for i in 1:12
        bb_dates = loadTileVariable(tile, months_r[i], root_path, variable) # `nothing` propagates 'till here!
        if !isnothing(bb_dates)
            burnYear[i][:,:] .= bb_dates
        end
    end
    return burnYear
end

function dailySparse(year, tile, root_path; variable="Burn Date")
    doy_month = monthIntervals(year)
    months_r = initMonthsArray(year)
    loadedYear = loadTileBurntYear(months_r, tile, root_path; variable)
    doy_bool= map(doy_month) do (doy, indx_month)
        ba = loadedYear[indx_month]
        getPixelDayRaw(ba, doy)
    end
    return doy_bool
end

function burnTimeSpan(s_year, e_year, tile, root_path; variable = "Burn Date")
    all_years = dailySparse(s_year, tile, root_path; variable)
    @showprogress for year in s_year+1:e_year
        n_year = dailySparse(year, tile, root_path; variable)
        push!(all_years, n_year...)
    end
    return all_years
end