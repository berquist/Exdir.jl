# Returns True if cast between data types can occur according to the
# casting rule.  If from is a scalar or array scalar, also returns
# True if the scalar value can be cast without overflow or truncation
# to an integer.
#
# Parameters
# ----------
# from_ : dtype, dtype specifier, scalar, or array
#     Data type, scalar, or array to cast from.
# to : dtype or dtype specifier
#     Data type to cast to.
# casting : {'no', 'equiv', 'safe', 'same_kind', 'unsafe'}, optional
#     Controls what kind of data casting may occur.
#
#       * 'no' means the data types should not be cast at all.
#       * 'equiv' means only byte-order changes are allowed.
#       * 'safe' means only casts which can preserve values are allowed.
#       * 'same_kind' means only safe casts or casts within a kind,
#         like float64 to float32, are allowed.
#       * 'unsafe' means any data conversions may be done.
#
# Returns
# -------
# out : bool
#     True if cast can occur according to the casting rule.
#
# Notes
# -----
# .. versionchanged:: 1.17.0
#    Casting between a simple data type and a structured one is possible only
#    for "unsafe" casting.  Casting to multiple fields is allowed, but
#    casting from multiple fields is not.
#
# .. versionchanged:: 1.9.0
#    Casting from numeric to string types in 'safe' casting mode requires
#    that the string dtype length is long enough to store the maximum
#    integer/float value converted.
#
# See also
# --------
# dtype, result_type
function can_cast(dtype_from::DataType, dtype_to::DataType, casting="safe")
    if casting != "safe"
        throw(
            ArgumentError(
                "can't handle anything other than safe casting for now"
            )
        )
    end
    if dtype_from == dtype_to
        return true
    elseif supertype(dtype_from) == supertype(dtype_to)
        return sizeof(dtype_from) <= sizeof(dtype_to)
    end
    return false
end
