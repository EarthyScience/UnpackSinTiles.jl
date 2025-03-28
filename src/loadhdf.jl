export get_hdf_keys
export load_hdf_variable

"""
    get_hdf_keys(hdf)

This function retrieves the keys of the datasets in the HDF file.
# Arguments
- hdf: HDF file object
"""
function get_hdf_keys(hdf)
    pyKeys = hdf.datasets().keys()
    return ["$k" for k in pyKeys]
end

"""
    load_hdf_variable(hdf, variable; close_file = true)

This function retrieves the specified variable from the HDF file and converts it to a Julia array.

# Arguments
- hdf: HDF file object
- variable: Name of the variable to load
- close_file: Whether to close the HDF file after loading (default: true)
"""
function load_hdf_variable(hdf, variable; close_file = true)
    hdf_data = hdf.select(variable).get()
    if close_file
        hdf.end() # close hdf tile
    end
    hdf_data_jl = pyconvert(Array, hdf_data)
    return hdf_data_jl
end