module UnpackSinTiles
    using PythonCall
    using YAXArrays
    using Zarr
    using Statistics
    using DataStructures
    using ProgressMeter
    using Dates
    using SparseArrays

    open_hdf(f) = @pyconst(pyimport("pyhdf.SD").SD)(f)
    export open_hdf

    include("loadhdf.jl")
    include("loadTile.jl")
    include("metadata.jl")
    include("pixelOperations.jl")
    include("modisTiles.jl")

    export openTile, loadTileVariable
    export getTileKeys, getTilePath
    export burnTimeSpan, updateAfterBurn!, aggTile
end

