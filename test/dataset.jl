using Exdir
using Test

@testset "dataset" begin

# Create a scalar dataset.
@testset "dataset_create_scalar" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=())
    @test size(dset) == ()
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

@testset "dataset_intermediate_group" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_reshape" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_create" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_create_existing" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_shape_conflict" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_type_conflict" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_dtype_conflict" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_dtype_close" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "dataset_create_fillval" begin
    (fx, f) = setup_teardown_file()

    # TODO

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
