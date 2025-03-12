using UnpackSinTiles
using YAXArrays, Zarr
using DimensionalData
using SparseArrays
using DelimitedFiles
using Rasters, ArchGDAL
using Rasters.Lookups
using DimensionalData.Lookups
using ProgressMeter

function yaxRaster(yax)
    x_range = lookup(yax, :X).data
    y_range = lookup(yax, :Y).data
    _data = replace(yax.data, NaN=>0)
    return Raster(_data, (Y(y_range; sampling=Intervals(Start())), X(x_range; sampling=Intervals(Start()))),
        crs=ProjString("+proj=sinu +lon_0=0 +type=crs"))
end


vegetated_land = "/Net/Groups/BGI/work_5/scratch/lalonso/VegetatedLand.zarr"
ds_veg = open_dataset(vegetated_land)

sin_ras = yaxRaster(readcubedata(ds_veg["layer"]))

resampled = resample(sin_ras; size=(720, 1440), crs=EPSG(4326), method="average")

locus_resampled = DimensionalData.shiftlocus(Center(), resampled)
new_dims = (lat(lookup(locus_resampled, :Y)), lon(lookup(locus_resampled, :X)))
zeros_to_nan = replace(locus_resampled, 0 => NaN32)

properties = Dict{String, Any}()
properties["VegetatedLand"] = "Percentage of vegetated area per pixel"
properties["PRODUCT"] = "MODIS/MCD64A1.061"
properties["crs"] = "EPSG:4326"

resampled_yax = YAXArray(new_dims, zeros_to_nan.data, properties)
ds_sampled = YAXArrays.Dataset(; (:VegLand => resampled_yax, )...)

vegetated_land_0d25 = "/Net/Groups/BGI/work_5/scratch/lalonso/VegetatedLand_0d25.zarr"

savedataset(ds_sampled, path=vegetated_land_0d25, driver=:zarr, overwrite=true)

let
    using CairoMakie
    #fig = hist(vec(Int.(lc_type1)), bins=255)
    fig = Figure(size = (1440, 720))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    hm = heatmap!(ax, -1*(locus_resampled .- 1 .- 1e-3); colorscale=log10,
        colormap=:linear_worb_100_25_c53_n256, colorrange=(1e-3, 1), highclip=:white)
    Colorbar(fig[1,2], hm)
    save("vegetated_land_fraction.png", fig)
end

let
    using CairoMakie
    #fig = hist(vec(Int.(lc_type1)), bins=255)
    fig = Figure(size = (1440, 720))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    hm = heatmap!(ax, resampled_yax,
        colormap=:linear_worb_100_25_c53_n256,)
    Colorbar(fig[1,2], hm)
    save("vegetated_land_fraction_0_1.png", fig)
end

