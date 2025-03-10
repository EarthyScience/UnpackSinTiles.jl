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
path_to_events = "/Net/Groups/BGI/tscratch/lalonso/MODIS_FIRE_EVENTS/MODIS_MCD64A1_FIRE_EVENTS_2001_2023.zarr"
ds = open_dataset(path_to_events)
# lon = lookup(ds["fire_frac"], :X)
# lat = lookup(ds["fire_frac"], :Y)
ds["fire_frac"][Ti=1]

fig, ax, plt = heatmap(ds["fire_frac"][Ti=1]; colorrange = (1e-5,1e-1),
    colorscale=log10,
    colormap=:linear_kryw_0_100_c71_n256,
    lowclip=:grey3, highclip=:grey5,
    nan_color=:grey3,
    figure = (;figure_padding=0, size =(1440, 720)))
hidespines!(ax)
hidedecorations!(ax)
save("read_test.png", fig)

# 
function yaxRaster(yax)
    # x_range = lookup(yax, :X).data
    # y_range = lookup(yax, :Y).data
    x_range = LinRange(-20015109.355798, 20015109.355798, 1441)[1:end-1]
    y_range = LinRange(10007554.677899, -10007554.677899, 721)[2:end]

    crs_sinu = yax.properties["crs"]
    ras_out = replace(x -> x==1.0f32 ? NaN : x, yax) # "_FillValue= 1.0f32"

    new_raster = Raster(ras_out.data, (Y(y_range; sampling=Intervals(Start())), X(x_range; sampling=Intervals(Start()))),
        crs=ProjString(crs_sinu))

    return new_raster
end

ras = yaxRaster(ds["fire_frac"][Ti=8000])

resampled = resample(ras; size=(720, 1440), crs=EPSG(4326), method="average")

locus_resampled  = DimensionalData.shiftlocus(Center(), resampled)


fig, ax, plt = heatmap(locus_resampled; colorrange = (1e-5,1e-1),
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