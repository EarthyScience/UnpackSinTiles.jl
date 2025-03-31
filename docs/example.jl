using UnpackSinTiles
using Rasters
using GLMakie

# https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/61/MYD11C1/2024/001/
# https://e4ftl01.cr.usgs.gov/MOLA/MYD11C1.061/2024.12.31/

# hdf_path = joinpath(@__DIR__, "MYD11C1.A2024001.061.2024005085414.hdf")
hdf_path = joinpath(@__DIR__, "MYD11C1.A2024366.061.2025003174450.hdf")
hdf = open_hdf(hdf_path)

_keys = get_hdf_keys(hdf)

meta = parse_metadata(hdf)

# Load the LST data
lst = load_hdf_variable(hdf, "LST_Day_CMG")
lst_32 = Float32.(lst)
ras = Raster(lst_32, (Y, X))

heatmap(ras)
