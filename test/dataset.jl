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

    # TODO

    cleanup_fixture(fx)    
end

# # Confirm that an alternate dtype can be specified.
# @testset "dataset_short_int" begin
#     f = exdiropen("dataset_short_int.exdir", "w")

#     dset = create_dataset(f, "foo"; shape=(63,), dtype=Int16)
#     @test isa(collect(dset), AbstractArray{Int16})
# end

# @testset "dataset_create_scalar_data" begin

# end

# @testset "dataset_create_extended_data" begin

# end

# @testset "dataset_intermediate_group" begin

# end

end
