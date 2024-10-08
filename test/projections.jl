using YAXArrays, Zarr, FillArrays
using DimensionalData
using DimensionalData.Lookups
using Rasters, GeoFormatTypes
using ArchGDAL
using Extents
using Dates
using CairoMakie

store ="gs://cmip6/CMIP6/ScenarioMIP/DKRZ/MPI-ESM1-2-HR/ssp585/r1i1p1f1/3hr/tas/gn/v20190710/"
g = open_dataset(zopen(store, consolidated=true))
c = g["tas"];
ct1_slice = c[Ti = Near(Date("2015-01-01"))];
lon = lookup(ct1_slice, :lon)
lat = lookup(ct1_slice, :lat)
data = ct1_slice.data[:,:];

δlon = (lon[2]-lon[1])/2
nlon = lon .- 180 .+ δlon
ndata = circshift(data, (192,1))

heatmap(nlon, lat, ndata)
save("test.png", current_figure())

# ras = Raster()

lon_dd = X(nlon; sampling=Intervals(Start()))
lat_dd = Y(lat; sampling=Intervals(Start()))

# time = Ti(2000:2024)
ras = Raster(ndata, (lon, lat), crs=EPSG(4326));
heatmap(ras)
save("test_ras.png", current_figure())

ras_ortho = resample(ras; size=(384, 192),
    crs = GeoFormatTypes.ProjString( "+proj=ortho +type=crs"))

# trying!

x_range = LinRange(-180, 180, 1441)[1:end-1]
y_range = LinRange(90, -90, 721)[2:end]

ra_data = rand(720, 1440)

raster = Raster(ra_data, (Y(y_range; sampling=Intervals(Start())), X(x_range; sampling=Intervals(Start()))),
    crs=EPSG(4326))

resampled = resample(raster; res=0.25, crs=EPSG(4326), method=:sum)