function _data_to_shape_and_dtype(data, shape, dtype)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/group.py#L28
    if !isnothing(data)
        if isnothing(shape)
            shape = size(data)
        end
        if isnothing(dtype)
            dtype = eltype(data)
        end
        _assert_data_shape_dtype_match(data, shape, dtype)
        return (shape, dtype)
    end
    if isnothing(dtype)
        dtype = Float64
    end
    (shape, dtype)
end

function _assert_data_shape_dtype_match(data, shape, dtype)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/group.py#L39
    if !isnothing(data)
        if !isnothing(shape) && (prod(shape) != prod(size(data)))
            error("Provided shape and size(data) do not match")
        end
        if !isnothing(dtype) && (dtype != eltype(data))
            error("Provided dtype and eltype(data) do not match")
        end
    end
end
