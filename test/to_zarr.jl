using UnpackSinTiles
using YAXArrays, Zarr
using DimensionalData
using SparseArrays
using DelimitedFiles

indx = parse(Int, ARGS[1])
# indx = 1
hvs = readdlm(joinpath(@__DIR__, "all_tiles.txt"))[:,1]
hv_tile = hvs[indx]

#SINUSOIDAL_CRS = ProjString("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")

root_path = "/Net/Groups/BGI/data/DataStructureMDI/DATA/Incoming/MODIS/MCD64A1.061/MCD64A1.061/"

# load all events for current tile
fire_events_bool = burnTimeSpan(2001, 2023, hv_tile, root_path; variable = "Burn Date")

# weighted FireEvents
afterBurn = [spzeros(Float32, 2400, 2400) for i in 1:size(fire_events_bool, 1)];
updateAfterBurn!(fire_events_bool, afterBurn; burnWindow = 30)
fire_events_bool = nothing

# aggegation, 0.25 resolution
tsteps = size(afterBurn, 1)
μBurn = fill(NaN32, 40, 40, tsteps);
agg_μBurn = aggTile(μBurn, afterBurn, tsteps; res = 60)

# open .zarr with `w` permissions
path_to_events = "/Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/MODIS_MCD64A1_FIRE_EVENTS_2001_2023.zarr"
outar = zopen(joinpath(path_to_events, "fire_frac"), "w")

# get indices in array for the current tile
hv_indices = getTileInterval(hv_tile)

# update entries!
outar[hv_indices, :] = agg_μBurn