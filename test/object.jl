using Exdir
using Test

import Exdir

include("support.jl")

@testset "object_init" begin
    fx = setup_teardown_folder()

    obj = Exdir.Object(
        root_directory = fx.testdir,
        parent_path = "",
        object_name = "test_object",
        file = nothing,
    )

    @test obj.root_directory == fx.testdir
    @test obj.object_name == "test_object"
    @test obj.parent_path == ""
    @test obj.file === nothing
    @test obj.relative_path == "test_object"
    @test obj.name == "/test_object"

    cleanup_fixture(fx)
end

@testset "object_open" begin
    f = exdir_tmpfile()

    grp = create_group(f, "test")
    grp2 = create_group(grp, "test2")
    Exdir.open_object(grp2.directory)
end

# @testset "object_create" begin
#     (fx, f) = setup_teardown_file()

#     grp = create_group(f, "test")

#     grp2 = create_group(grp, "a")

#     @test isa(grp, Exdir.Group)

#     grp3 = create_group(grp, "b/")
#     @test isa(grp3, Exdir.Group)

#     cleanup_fixture(fx)
# end

