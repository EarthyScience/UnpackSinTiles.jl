export parse_metadata, getTileMetadata

"""
    parse_metadata(in_hdf; metadata_field = "StructMetadata.0")

The `metadata_field` follows from the MODIS MCD64A1.061 specification product.
"""
function parse_metadata(in_hdf; metadata_field = "StructMetadata.0")
    attr = in_hdf.attributes();
    metadata_string = string.(attr[metadata_field])

    result = OrderedDict{String, Any}()
    stack = [result]
    
    for line in eachsplit(metadata_string, '\n')
        line = rstrip(line)
        level = count(x -> x == '\t', line)
        line = strip(line)
        
        if line == "END"
            break  # Stop parsing when "END" is encountered
        elseif startswith(line, "GROUP=") || startswith(line, "OBJECT=")
            key = split(line, '=', limit=2)[2]
            new_dict = OrderedDict{String, Any}()
            stack[end][key] = new_dict
            push!(stack, new_dict)
        elseif startswith(line, "END_GROUP=") || startswith(line, "END_OBJECT=")
            pop!(stack)
        elseif contains(line, "=")
            key, value = split(line, '=', limit=2)
            value = strip(value, ['"'])  # Remove quotation marks
            # Try to parse as number if possible
            try
                if contains(value, ",")  # Handle tuples
                    value = Tuple(parse(Float64, v) for v in split(value[2:end-1], ','))
                else
                    value = parse(Float64, value)
                end
            catch
                # If parsing fails, keep it as a string
            end
            stack[end][key] = value
        end
    end
    return result
end

function getTileMetadata(tile, in_date, root_path)
    o = openTile(tile, in_date, root_path)
    meta = parse_metadata(o)
    m = meta["GridStructure"]["GRID_1"]
    o.end()
    return m
end