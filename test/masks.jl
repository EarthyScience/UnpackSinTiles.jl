using YAXArrays
using UnpackSinTiles

root_path = "/Net/Groups/BGI/data/DataStructureMDI/DATA/Incoming/MODIS/MCD12Q1.061/orgdata/"
lc_type_years = readdir(root_path)

# hv_tile = "h18v03"
# hv_tile = "h31v11"
# hv_tile = "h21v09"
hv_tile = "h28v11"
in_date = "2009.01.01"

new_m = getTileMetadata(hv_tile, in_date, root_path)
o_tile = openTile(hv_tile, in_date, root_path)

o_t_keys = getTileKeys(o_tile)

lc_type1 = loadTileVariable(hv_tile, in_date, root_path, "LC_Type1")

LC_TypeX_vals = Int.(lc_type1)

let 
    using CairoMakie
    #fig = hist(vec(Int.(lc_type1)), bins=255)
    fig = Figure(figure_padding=(0); size = (2500, 2500))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    heatmap!(ax, Int.(lc_type1)'[:, end:-1:1];
        colormap=Categorical(cgrad(:ground_cover, 16, categorical=true)), # tol_land_cover
        colorrange = (1,16), highclip=:black,
        lowclip= :grey13
        # lowclip= (:steelblue, 1)
        )
    save("lc_new_path_lc1_2009.png", fig)
end

veg_forms = Dict{String, AbstractArray}()
veg_forms["non_veg"] = [17, 13, 15, 16, 255]
veg_forms["tree"] = [1,2,3,4,5]
veg_forms["shrub"] = [6,7]
veg_forms["savanna"] = [8,9]
veg_forms["herb"] = [10,11,12,14]



function compute_mask(m, to_vals::AbstractVector)
    return m .∈ Ref(to_vals)
end

function compute_mask_not(m, to_vals::AbstractVector)
    return m .∉ Ref(to_vals)
end

lc_form = compute_mask_not(Int.(lc_type1), veg_forms["non_veg"])
lc_form = compute_mask(Int.(lc_type1), veg_forms["shrub"])


let
    using CairoMakie
    #fig = hist(vec(Int.(lc_type1)), bins=255)
    fig = Figure(figure_padding=(0); size = (2500, 2500))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    heatmap!(ax, Int.(tree_form)'[:, end:-1:1]; # lc_vegs
        colormap= [:grey30, :grey13], # tol_land_cover
        colorrange = (0,1),
        )
    save("lc_new_path_lc1_2009_tree_shrub.png", fig) # vegetated
end


root_path_fire = "/Net/Groups/BGI/data/DataStructureMDI/DATA/Incoming/MODIS/MCD64A1.061/MCD64A1.061/"
in_date = "2009.01.01"

hv_fire = loadTileVariable(hv_tile, in_date, root_path_fire, "Burn Date")
# fire_events = burnTimeSpan(2009, 2009, hv_tile, root_path_fire; variable = "Burn Date")
hv_fire_filter = replace(x->x==-2 ? 32 : x, hv_fire);

let 
    using CairoMakie
    #fig = hist(vec(Int.(lc_type1)), bins=255)
    fig = Figure(figure_padding=(0); size = (2500, 2500))
    ax = Axis(fig[1,1])
    hidedecorations!(ax)
    hidespines!(ax)
    heatmap!(ax, hv_fire_filter'[:, end:-1:1];
        #colormap=Categorical(cgrad(:ground_cover, 16, categorical=true)), # tol_land_cover
        colormap=:linear_kryw_0_100_c71_n256,
        colorrange = (1,31), highclip=:grey20,
        lowclip= :grey13,
        # lowclip= (:steelblue, 1)
        )
    save("fire_filter_2009.png", fig)
end