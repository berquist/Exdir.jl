using Exdir
using Test

import Exdir

include("support.jl")

@testset "raw_init" begin
    fx = setup_teardown_folder()

    raw = Exdir.Raw(
        root_directory = fx.testdir,
        parent_path = "",
        object_name = "test_object",
        file = nothing,
    )

    @test raw.root_directory == fx.testdir
    @test raw.object_name == "test_object"
    @test raw.parent_path == ""
    @test raw.file === nothing
    @test raw.relative_path == "test_object"
    @test raw.name == "/test_object"

    cleanup_fixture(fx)
end

# @testset "raw_create" begin
#     (fx, f) = setup_teardown_file()

#     grp = create_group(f, "test")

#     grp2 = create_group(grp, "a")

#     @test isa(grp, Exdir.Group)

#     grp3 = create_group(grp, "b/")
#     @test isa(grp3, Exdir.Group)

#     cleanup_fixture(fx)
# end

