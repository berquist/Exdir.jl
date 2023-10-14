function clean_path(path::AbstractString)
    path = normpath(path)
    if isdirpath(path)
        dirname(path)
    else
        path
    end
end

function name_to_asserted_group_path(name::AbstractString)
    path = clean_path(name)
    if isabspath(path)
        throw(NotImplementedError("Absolute paths are currently not supported and unlikely to be implemented."))
    elseif splitpath(path) == [""]
        throw(NotImplementedError("Getting an item on a group with path '$(name)' is not supported and unlikely to be implemented."))
    end
    path
end

function remove_root(path::AbstractString)
    path = clean_path(path)
    components = splitpath(path)
    if components[1] == "/"
        joinpath(components[2:length(components)])
    else
        path
    end
end

form_relative_path(parent_path::AbstractString, object_name::AbstractString) =
    joinpath(parent_path, object_name) |> clean_path
