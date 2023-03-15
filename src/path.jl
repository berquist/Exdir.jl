function name_to_asserted_group_path(name::AbstractString)
    path = name
    if isabspath(path)
        throw(ArgumentError("Absolute paths are currently not supported and unlikely to be implemented."))
    elseif splitpath(path) == [""]
        throw(ArgumentError("Getting an item on a group with path '$name' is not supported and unlikely to be implemented."))
    end
    path
end

function remove_root(path::AbstractString)
    components = splitpath(path)
    rel = if components[1] == "/"
        joinpath(components[2:length(components)])
    else
        path
    end
    rel
end
