using Exdir
using Test

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

# Missing shape raises TypeError.
@testset "dataset_missing_shape" begin
    (fx, f) = setup_teardown_file()

    @test_throws TypeError create_dataset(f, "foo")

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
    dset = create_dataset("foo"; data=data)
    @test size(dset) == size(data)

    cleanup_fixture(fx)
end

# Create an extended dataset from existing data.
@testset "dataset_create_extended_data" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    data = ones(63)
    dset = create_dataset("foo"; data=data)
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

    dset = require_dataset(grp, "foo"; shape=(10, 3))
    @test isa(dset, Exdir.Dataset)
    @test size(dset) == (10, 3)

    dset2 = require_dataset(grp, "bar"; data=(3, 10))
    dset3 = require_dataset(grp, "bar"; data=(4, 11))
    @test isa(dset2, Exdir.Dataset)
    @test dset2[:] == (3, 10)
    @test dset3[:] == (3, 10)
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

# require_dataset with shape conflict yields TypeError.
@testset "dataset_shape_conflict" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    create_dataset(grp, "foo"; shape=(10, 3))
    @test_throws TypeError require_dataset(grp, "foo"; shape=(10, 4))

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

# require_dataset with convertible type succeeds (non-strict mode)-
@testset "dataset_dtype_close" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=(10, 3), dtype=Int32)
    dset2 = create_dataset(grp, "foo"; shape=(10, 3), dtype=Int16, exact=false)
    @test dset == dset2
    # TODO look at dset2.dtype?
    @test eltype(dset2) == Int32

    cleanup_fixture(fx)
end

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

@testset "dataset_compound" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_exc" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_string" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_dtype" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_len" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_len_scalar" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_iter" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_iter_scalar" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_trailing_slash" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_compound" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_assign" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_set_data" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_eq_false" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_eq" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_mmap" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_modify_view" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_single_index" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_single_null" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_scalar_index" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_scalar_null" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_compound_index" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_negative_stop" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_read" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_write_broadcast" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_write_element" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_write_slices" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_roundtrip" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_slice_zero_length_dimension" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_slice_other_dimension" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_slice_of_length_zero" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_modify_all" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

end
