module UnpackSinTiles
    using PythonCall
    using YAXArrays
    using Zarr
    using Statistics
    using DataStructures
    using ProgressMeter
    using Dates
    using SparseArrays

    hdf(f) = @pyconst(pyimport("pyhdf.SD").SD)(f)
    export hdf

    include("loadTile.jl")
    include("metadata.jl")
    include("pixelOperations.jl")
    include("modisTiles.jl")

    export openTile, loadTileVariable
    export getTileKeys, getTilePath
    export burnTimeSpan, updateAfterBurn!, aggTile
end

