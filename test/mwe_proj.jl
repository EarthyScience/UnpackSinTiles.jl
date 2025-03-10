using DimensionalData
using DimensionalData.Lookups
using Rasters, GDAL, ArchGDAL # add LERC_jll@3 # do this one first, otherwise it might not install the packages!

SINUSOIDAL_CRS = ProjString("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
# Here we make the ranges one step longer than we need and shorten them
# Because these are the starts of the intervals. y is 2:end because its reversed.

x_range = LinRange(-20015109.355798, 20015109.355798, 1441)[1:end-1]
y_range = LinRange(10007554.677899, -10007554.677899, 721)[2:end]

ra_data = rand(720, 1440)

raster = Raster(ra_data, (Y(y_range; sampling=Intervals(Start())), X(x_range; sampling=Intervals(Start()))), crs=SINUSOIDAL_CRS)

resampled = resample(raster; res=0.25, crs=EPSG(4326), method=:average)
locus_resampled  = DimensionalData.shiftlocus(Center(), resampled)