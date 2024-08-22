function root_directory(path::AbstractString)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/exdir_object.py#L128
    path = realpath(path)
    found = false
    while !found
        (parent, pname) = splitdir(path)
        if parent == path
            return nothing
        end
        if !is_nonraw_object_directory(path)
            path = parent
            continue
        end
        meta_data = YAML.load_file(joinpath(path, META_FILENAME))
        if !haskey(meta_data, EXDIR_METANAME)
            path = parent
            continue
        end
        exdir_meta = meta_data[EXDIR_METANAME]
        if !haskey(exdir_meta, TYPE_METANAME)
            path = parent
            continue
        end
        if FILE_TYPENAME != exdir_meta[TYPE_METANAME]
            path = parent
            continue
        end
        found = true
    end
    path
end

function is_inside_exdir(path::AbstractString)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/exdir_object.py#L161
    path = realpath(path)
    !isnothing(root_directory(path))
end

function assert_inside_exdir(path::AbstractString)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/exdir_object.py#L166
    if !is_inside_exdir(path)
        error("Path " + path + " is not inside an Exdir repository.")
    end
end
