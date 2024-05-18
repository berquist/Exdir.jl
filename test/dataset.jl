using EllipsisNotation
using Exdir
using StructArrays
using Test

import Exdir: NotImplementedError

@testset "dataset" begin

# Create a scalar dataset.
@testset "dataset_create_scalar" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=())
    @test size(dset) == ()
    # TODO
    # @test collect(dset) == 0

    cleanup_fixture(fx)
end

# Create a size-1 dataset.
@testset "dataset_create_simple" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=(1,))
    @test size(dset) == (1,)
    # TODO
    # @test collect(dset)

    cleanup_fixture(fx)
end

# Create an extended dataset.
@testset "dataset_create_extended" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=(63,))
    @test size(dset) == (63,)
    @test length(dset) == 63

    dset = create_dataset(grp, "bar"; shape=(6, 10))
    @test size(dset) == (6, 10)
    @test length(dset) == 60

    cleanup_fixture(fx)
end

# Confirm that the default dtype is Float64.
@testset "dataset_default_dtype" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=(63,))
    @test isa(collect(dset), AbstractArray{Float64})

    cleanup_fixture(fx)
end

# Missing shape raises TypeError in Python, ArgumentError in Julia.
@testset "dataset_missing_shape" begin
    (fx, f) = setup_teardown_file()

    @test_throws ArgumentError create_dataset(f, "foo")

    cleanup_fixture(fx)
end

# Confirm that an alternate dtype can be specified.
@testset "dataset_short_int" begin
    (fx, f) = setup_teardown_file()

    dset = create_dataset(f, "foo"; shape=(63,), dtype=Int16)
    @test isa(collect(dset), AbstractArray{Int16})

    cleanup_fixture(fx)
end

# Create a scalar dataset from existing array.
@testset "dataset_create_scalar_data" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    data = ones()
    dset = create_dataset(grp, "foo"; data=data)
    @test size(dset) == size(data)

    cleanup_fixture(fx)
end

# Create an extended dataset from existing data.
@testset "dataset_create_extended_data" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    data = ones(63)
    dset = create_dataset(grp, "foo"; data=data)
    @test size(dset) == size(data)

    cleanup_fixture(fx)
end

# Create dataset with missing intermediate groups.
@testset "dataset_intermediate_group" begin
    (fx, f) = setup_teardown_file()

    # Trying to create intermediate groups that are absolute should fail just
    # like when creating them on groups.
    @test_throws NotImplementedError create_dataset(f, "/foo/bar/baz"; shape=(10, 10), dtype=Int32)

    ds = create_dataset(f, "foo/bar/baz"; shape=(10, 10), dtype=Int32)
    @test isa(ds, Exdir.Dataset)
    # Checking for an absolute path in a file should work, though.
    @test "/foo/bar/baz" in f

    cleanup_fixture(fx)
end

# Create from existing data, and make it fit a new shape.
@testset "dataset_reshape" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    data = collect(Float64, 1:30)
    dset = create_dataset(grp, "foo"; shape=(10, 3), data=data)
    @test size(dset) == (10, 3)
    @test dset.data == reshape(data, (10, 3))

    cleanup_fixture(fx)
end

# Feature: Datasets can be created only if they don't exist in the file
# Create new dataset with no conflicts.
@testset "dataset_create" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    # def require_dataset(self, name, shape=None, dtype=None, exact=False,
    #                     data=None, fillvalue=None):
    dset = require_dataset(grp, "foo"; shape=(10, 3))
    @test isa(dset, Exdir.Dataset)
    @test size(dset) == (10, 3)

    dset2 = require_dataset(grp, "bar"; data=(3, 10))
    dset3 = require_dataset(grp, "bar"; data=(4, 11))
    @test isa(dset2, Exdir.Dataset)
    @test dset2[:] == [3, 10]
    @test dset3[:] == [3, 10]
    @test dset2 == dset3

    cleanup_fixture(fx)
end

# require_dataset yields existing dataset.
@testset "dataset_create_existing" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = require_dataset(grp, "foo"; shape=(10, 3), dtype=Float32)
    dset2 = require_dataset(grp, "foo"; shape=(10, 3), dtype=Float32)

    @test dset == dset2

    cleanup_fixture(fx)
end

# require_dataset with shape conflict yields TypeError in Python.
@testset "dataset_shape_conflict" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    create_dataset(grp, "foo"; shape=(10, 3))
    @test_throws DimensionMismatch require_dataset(grp, "foo"; shape=(10, 4))

    cleanup_fixture(fx)
end

# require_dataset with object type conflict yields TypeError.
@testset "dataset_type_conflict" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    create_group(grp, "foo")
    @test_throws TypeError require_dataset(grp, "foo"; shape=(10, 3))

    cleanup_fixture(fx)
end

# require_dataset with dtype conflict (strict mode) yields TypeError.
@testset "dataset_dtype_conflict" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    create_dataset(grp, "foo"; shape=(10, 3), dtype=Float64)
    @test_throws TypeError require_dataset(grp, "foo"; shape=(10, 3), dtype=UInt8)

    cleanup_fixture(fx)
end

# # require_dataset with convertible type succeeds (non-strict mode)-
# @testset "dataset_dtype_close" begin
#     (fx, f) = setup_teardown_file()

#     grp = create_group(f, "test")

#     dset = create_dataset(grp, "foo"; shape=(10, 3), dtype=Int32)
#     dset2 = create_dataset(grp, "foo"; shape=(10, 3), dtype=Int16, exact=false)
#     @test dset == dset2
#     @test eltype(dset2) == Int32
#     @test dset2.dtype == Int32

#     cleanup_fixture(fx)
# end

# Feature: Datasets can be created with fill value
# Fill value is reflected in dataset contents.
@testset "dataset_create_fillval" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=(10,), fillvalue=4.0)
    @test dset[1] == 4.0
    @test dset[8] == 4.0

    cleanup_fixture(fx)
end

# Fill value works with compound types.
@testset "dataset_compound_fill" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    struct dt
        a::Float32
        b::Int64
    end
    v = StructArray{dt}((a = ones(1), b = ones(1)))[1]
    dset = create_dataset(grp, "foo"; shape=(10,), dtype=dt, fillvalue=v)

    cleanup_fixture(fx)
end

# Bogus fill value raises TypeError.
@testset "dataset_exc" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    @test_throws TypeError create_dataset(grp, "foo"; shape=(10,), dtype=Float32, fillvalue=Dict("a" => 2))

    cleanup_fixture(fx)
end

# Assignment of fixed-length byte string produces a fixed-length ASCII dataset
@testset "dataset_string" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; data="string")
    @test dset.data == "string"

    cleanup_fixture(fx)
end

# Feature: Dataset dtype is available as .dtype property in Python, eltype in Julia
# Retrieve dtype from dataset.
@testset "dataset_dtype" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=(5,), dtype=UInt8)
    @test eltype(dset) == UInt8

    cleanup_fixture(fx)
end

# Feature: Size of first axis is available via Python's len;
# For Julia, size(...) gives the full shape and length(...) gives the total number of elements.
@testset "dataset_len" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=(312, 15))
    @test size(dset) == (312, 15)
    @test length(dset) == 312 * 15

    cleanup_fixture(fx)
end

@testset "dataset_len_scalar" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; data=1)
    @test size(dset) == ()
    @test length(dset) == 1

    cleanup_fixture(fx)
end

# Feature: Iterating over a dataset yields rows in Python, which is idiomatic
# for NumPy, but yields scalars in Julia.
@testset "dataset_iter" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dtype = Float64
    data = reshape(collect(dtype, 1:30), (10, 3))
    dset = create_dataset(grp, "foo"; data=data)
    for (x, y) in zip(dset, data)
        @test isa(x, dtype)
        @test length(x) == 1
        @test size(x) == ()
        @test x == y
    end

    cleanup_fixture(fx)
end

# # Iterating over scalar dataset raises TypeError.
# @testset "dataset_iter_scalar" begin
#     (fx, f) = setup_teardown_file()

#     grp = create_group(f, "test")

#     dset = create_dataset(grp, "foo"; shape=())
#     @test_throws TypeError [x for x in dset]

#     cleanup_fixture(fx)
# end

# Trailing slashes are unconditionally ignored.
@testset "dataset_trailing_slash" begin
    (fx, f) = setup_teardown_file()

    f["dataset"] = 42
    @test "dataset/" in f

    cleanup_fixture(fx)
end

# # Feature: Compound types correctly round-trip
# # Compound types are read back in correct order.
# @testset "dataset_compound" begin
#     (fx, f) = setup_teardown_file()

#     grp = create_group(f, "test")

#     struct dt
#         weight::Float64
#         cputime::Float64
#         walltime::Float64
#         parents_offset::UInt32
#         n_parents::UInt32
#         status::UInt8
#         endpoint_type::UInt8
#     end

    # TODO
    # lo = 0
    # hi = 100
    # d = MappedDistribution(dt,
    #     Uniform(lo, hi),
    #     Uniform(lo, hi),
    #     Uniform(lo, hi),
    #     Uniform(lo, hi),
    #     Uniform(lo, hi),
    #     Uniform(lo, hi),
    #     Uniform(lo, hi)
    # )

    # dim = 16
    # testdata = StructArray{dt}(undef, dim)
    # Random.rand!(testdata)
    # testdata *= 100

#     cleanup_fixture(fx)
# end

# @testset "dataset_assign" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# Set data works correctly.
@testset "dataset_set_data" begin
    (fx, f) = setup_teardown_file()

    # TODO
    # grp = create_group(f, "test")

    # testdata = ones(10, 2)
    # grp["testdata"] = testdata

    cleanup_fixture(fx)
end

@testset "dataset_eq_false" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; data=1)
    dset2 = create_dataset(grp, "foobar"; shape=(2, 2))

    @test dset != dset2
    @test dset != 2

    cleanup_fixture(fx)
end

@testset "dataset_eq" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; data=ones(2, 2))

    @test dset == dset

    cleanup_fixture(fx)
end

# @testset "dataset_mmap" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# @testset "dataset_modify_view" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# @testset "dataset_single_index" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# @testset "dataset_single_null" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# @testset "dataset_scalar_index" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# @testset "dataset_scalar_null" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# @testset "dataset_compound_index" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# @testset "dataset_negative_stop" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# @testset "dataset_read" begin
#     (fx, f) = setup_teardown_file()

#     # TODO

#     cleanup_fixture(fx)
# end

# Array fill from constant is supported.
@testset "dataset_write_broadcast" begin
    (fx, f) = setup_teardown_file()

    dt = Int8
    shape = (10,)
    c = 42

    dset = create_dataset(f, "x"; shape=shape, dtype=dt)
    dset[..] .= c

    data = ones(dt, shape...) * c

    @test eltype(dset) == eltype(data)
    @test isequal(dset.data, data)

    cleanup_fixture(fx)
end

# Write a single element to the array.
@testset "dataset_write_element" begin
    (fx, f) = setup_teardown_file()

    dt = Float16
    dset = create_dataset(f, "x"; shape=(10, 3), dtype=dt)

    data = dt.([1, 2, 3.0])
    dset[5] = data

    out = dset[5]
    @test eltype(out) == eltype(data)
    @test isequal(out, data)

    cleanup_fixture(fx)
end

# Write slices to array type.
@testset "dataset_write_slices" begin
    (fx, f) = setup_teardown_file()

    dt = Int32
    data1 = ones(dt, 2, 3)
    data2 = ones(dt, 4, 5, 3)

    dset = create_dataset(f, "x"; shape=(10, 9, 11), dtype=dt)

    dset[1, 1, 3:4] = data1
    @test eltype(dset[1, 1, 3:4]) == eltype(data1)
    @test isequal(dset[1, 1, 3:4], data1)

    dset[4, 2:5, 7:11] = data2
    @test eltype(dset[4, 2:5, 7:11]) == eltype(data2)
    @test isequal(dset[4, 2:5, 7:11], data2)

    cleanup_fixture(fx)
end

# Read the contents of an array and write them back.
#
# The initialization is not the same as in Python, since NumPy allows for
# fancy dtypes where Julia could resort to structs without the array having a
# dtype of object.  Use the third-party package StructArrays to efficiently
# emulate this.
@testset "dataset_roundtrip" begin
    (fx, f) = setup_teardown_file()

    data = rand(10)
    dset = create_dataset(f, "x"; data=data)

    out = dset[..]
    @test out == data
    dset[..] = out
    @test dset[..] == out
    @test dset[..] == data

    cleanup_fixture(fx)
end

# Slice a dataset with a zero in its shape vector along the zero-length
# dimension.
@testset "dataset_slice_zero_length_dimension" begin
    (fx, f) = setup_teardown_file()

    shapes = [(0,), (0, 3), (0, 2, 1)]
    for (i, shape) in enumerate(shapes)
        dset = create_dataset(f, "x$(i)"; shape=shape, dtype=Int32)
        @test size(dset) == shape
        out = dset[..]
        # not AbstractArray, which Dataset obeys TODO
        @test isa(out, Array)
        @test size(out) == shape
        out = dset[:]
        @test isa(out, Array)
        @test size(out) == shape
        if length(shape) > 1
            out = dset[:, :2]
            @test isa(out, Array)
            @test size(out) == (0, 1)
        end
    end

    cleanup_fixture(fx)
end

# Slice a dataset with a zero in its shape vector along a non-zero-length
# dimension.
@testset "dataset_slice_other_dimension" begin
    (fx, f) = setup_teardown_file()

    shapes = [(3, 0), (1, 2, 0), (2, 0, 1)]
    for (i, shape) in enumerate(shapes)
        dset = create_dataset(f, "x$(i)"; shape=shape, dtype=Int32)
        @test size(dset) == shape
        out = dset[begin:2]
        # not AbstractArray, which Dataset obeys TODO
        @test isa(out, Array)
        @test size(out) == (1, shape...)
    end

    cleanup_fixture(fx)
end

# Get a slice of length zero from a non-empty dataset.
@testset "dataset_slice_of_length_zero" begin
    (fx, f) = setup_teardown_file()

    shapes = [(3,), (2, 2,), (2, 1, 5)]
    for (i, shape) in enumerate(shapes)
        dset = create_dataset(f, "x$(i)"; data=zeros(Int32, shape))
        @test size(dset) == shape
        out = dset[2:2]
        # not AbstractArray, which Dataset obeys TODO
        @test isa(out, Array)
        @test size(out) == (0, shape...)
    end

    cleanup_fixture(fx)
end

@testset "dataset_modify_all" begin
    (fx, f) = setup_teardown_file()

    dset = create_dataset(f, "test"; data=1:10)
    n = 4
    dset.data = ones(n)
    @test dset.data == ones(n)

    cleanup_fixture(fx)
end

end
