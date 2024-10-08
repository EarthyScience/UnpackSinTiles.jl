using UnpackSinTiles
# testing funcitons!
tile = "h13v10"
# tile = "h01v08" # this one has zero fire events!
in_date = "2001.01.01"
root_path = "/Net/Groups/BGI/data/DataStructureMDI/DATA/Incoming/MODIS/MCD64A1.061/MCD64A1.061/"
# tile path
tile_path = getTilePath(tile, in_date, root_path)

o = openTile(tile, in_date, root_path)
k_vars = getTileKeys(o)

meta = parse_metadata(o)
m = meta["GridStructure"]["GRID_1"]
m_keys = ["XDim", "YDim", "UpperLeftPointMtrs", "LowerRightMtrs",
    "Projection", "ProjParams", "SphereCode", "GridOrigin"]

o.end()

# load more
d = loadTileVariable(tile, in_date, root_path, "Burn Date")


# test Zarr skeleton
# using YAXArrays, Zarr, FillArrays

# a = YAXArray(Falses(2400, 2400, 365*15))
# b = YAXArray(Zeros(Union{Missing, Int16}, 2400, 2400, 365))
# c = YAXArray(Zeros(Union{Missing, Float32}, 2400, 2400, 365))

