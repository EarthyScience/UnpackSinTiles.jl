using UnpackSinTiles
using JLD2
using DelimitedFiles
using About
using ProgressMeter

# indx = parse(Int, ARGS[1]) # it should be different and come from a job-array sbatch script.
indx=268
root_path = "/Net/Groups/BGI/data/DataStructureMDI/DATA/Incoming/MODIS/MCD64A1.061/MCD64A1.061/"
path_to_events = "/Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/MODIS_MCD64A1_FIRE_EVENTS_2001_2023.jld2"

hvs = readdlm(joinpath(@__DIR__, "all_tiles.txt"))[:,1]
# `indx` should be different and come from a job-array sbatch script.
hv_tile = hvs[indx]
in_date = "2001.01.01"
new_m = getTileMetadata(hv_tile, in_date, root_path)
m_keys = ["XDim", "YDim", "UpperLeftPointMtrs", "LowerRightMtrs",
    "Projection", "ProjParams", "SphereCode", "GridOrigin"]
# https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/modis-overview/#modis-metadata
# TODO: look for BOUNDINGRECTANGLE and GRINGPOINT.
# selected_m = filter(pair -> first(pair) in m_keys, new_m)

fire_events = burnTimeSpan(2001, 2023, hv_tile, root_path; variable = "Burn Date"); # ? ~ 204MB
# about(fire_events)
path_to_events = "/Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/MODIS_MCD64A1_FIRE_EVENTS_2001_2023.zarr"


# jldopen(path_to_events, "a+") do file
#     my_hv_tile = JLD2.Group(file, hv_tile)
#     my_hv_tile["fire_events"] = fire_events
#     for k in m_keys
#         my_hv_tile[k] = new_m[k]
#     end
# end
# this fails poorly!

# file_event = jldopen(path_to_events, "r")
# close(file_event)
2.00151e7-1.89032e7
+2.2239e6 - 1.11195e6

(xlon[2] - xlon[1])*40
(-ylat[2] + ylat[1])*40

"UpperLeftPointMtrs" => (1.89032e7, -1.11195e6)
  "LowerRightMtrs"     => (2.00151e7, -2.2239e6)

      # boundaries of sinusodial projection
      UPPER_LEFT_X_METERS = -20015109.355798
      # UPPER_LEFT_Y_METERS = 10007554.677899
      # LOWER_RIGHT_X_METERS = 20015109.355798
      LOWER_RIGHT_Y_METERS = -10007554.677899
      # size across (width or height) of any equal-area sinusoidal target
      TILE_SIZE_METERS = 1111950.5197665554
      # boundaries of MODIS land grid
      TOTAL_ROWS = 18
      # TOTAL_COLUMNS = 36