using Exdir
using Test

# Create a scalar dataset.
@testset "dataset_create_scalar" begin
    # TODO fixture
    f = exdiropen("dataset_create_scalar.exdir", "w")
    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=())
    @test size(dset) == ()
    # @test collect(dset) == 0
end

# # Create a size-1 dataset.
@testset "dataset_create_simple" begin
    f = exdiropen("dataset_create_simple.exdir", "w")
    grp = create_group(f, "test")

    dset = create_dataset(grp, "foo"; shape=(1,))
    @test size(dset) == (1,)
end

# # Create an extended dataset.
# @testset "dataset_create_extended" begin
#     f = exdiropen("dataset_create_extended.exdir", "w")
#     grp = create_group(f, "test")

#     dset = create_dataset(grp, "foo"; shape=(63,))
#     @test shape(dset) == (63,)
#     @test length(dset) == 63

#     dset = create_dataset(grp, "bar"; shape=(6, 10))
#     @test shape(dset) == (6, 10)
#     @test length(dset) == 60
# end

# # Confirm that the default dtype is Float64.
# @testset "dataset_default_dtype" begin
#     f = exdiropen("dataset_default_dtype.exdir", "w")
#     grp = create_group(f, "test")

#     dset = create_dataset(grp, "foo"; shape=(63,))
#     @test isa(collect(dset), AbstractArray{Float64})
# end

# # Missing shape raises TypeError.
# @testset "dataset_missing_shape" begin
    
# end

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
