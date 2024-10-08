module UnpackSinTiles
    using PythonCall
    using YAXArrays
    using Zarr
    using Statistics
    using DataStructures
    using PythonCall
    using ProgressMeter

    hdf(f) = @pyconst(pyimport("pyhdf.SD").SD)(f)
    export hdf

    include("loadTile.jl")
    include("metadata.jl")

    export openTile, loadTileVariable
    export getTileKeys, getTilePath
end

