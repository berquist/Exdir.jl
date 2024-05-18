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

function _assert_data_shape_dtype_match(data, shape::Union{Dims, Nothing}, dtype)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/group.py#L39
    if !isnothing(data)
        sz = size(data)
        if !isnothing(shape) && (prod(sz) != prod(shape))
            throw(ArgumentError("Provided shape and size(data) do not match: $shape vs $sz"))
        end
        et = eltype(data)
        if !isnothing(dtype) && (et != dtype)
            throw(ArgumentError("Provided dtype and eltype(data) do not match: $dtype vs $et"))
        end
    end
    nothing
end

"""Only scalars and arrays of scalars are allowed as fill values."""
function _assert_allowed_fillvalue(fillvalue)
    if !isnothing(fillvalue)
        # TODO
        if isa(fillvalue, AbstractDict)
            throw(
                TypeError(
                    :allowed_fillvalue,
                    "fillvalue type is not supported",
                    AbstractArray,
                    typeof(fillvalue)
                )
            )
        end
    end
end
