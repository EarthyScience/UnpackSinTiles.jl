using UnpackSinTiles
using YAXArrays, Zarr
using DimensionalData
using SparseArrays
using DelimitedFiles
using CairoMakie
using Rasters, ArchGDAL
using DimensionalData.Lookups
using GeoMakie

# open .zarr 
path_to_latlon = "/Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/MODIS_MCD64A1_FIRE_EVENTS_2001_2023_LATLON.zarr"
ds = open_dataset(path_to_latlon)
ds_slice = ds["fire_frac"][Ti=1]
lon = lookup(ds_slice, :lon)
lat = lookup(ds_slice, :lat)

fig, ax, plt = heatmap(ds_slice; x = :lon,
    colorrange = (1e-5,1e-1), # 
    colorscale=log10,
    colormap=:linear_kryw_0_100_c71_n256,
    lowclip=:grey3, highclip=:grey5,
    nan_color=:grey3,
    figure = (;figure_padding=0, size =(1440, 720)),
    axis=(; title=""))
lines!(ax, GeoMakie.coastlines(), color=:grey65, linewidth=1.25)
hidespines!(ax)
hidedecorations!(ax)
save("read_test_latlon.png", fig)
