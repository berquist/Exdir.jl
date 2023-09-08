using Exdir
using Test

import Exdir: Object, open_object, ATTRIBUTES_FILENAME, META_FILENAME

include("support.jl")

@testset "object_init" begin
    fx = setup_teardown_folder()

    obj = Object(
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
    open_object(grp2.directory)
end

@testset "object_attrs" begin
    (fx, f) = setup_teardown_file()

    obj = create_dataset(f, "test_object", shape=(1,))

    # TODO

    cleanup_fixture(fx)
end

@testset "object_meta" begin
    (fx, f) = setup_teardown_file()

    obj = create_dataset(f, "test_object", shape=(1,))

    # TODO

    cleanup_fixture(fx)
end

@testset "object_directory" begin
    (fx, f) = setup_teardown_file()

    obj = create_dataset(f, "test_object", shape=(1,))

    @test obj.directory == joinpath(fx.testfile, "test_object")
    @test obj.attributes_filename == joinpath(fx.testfile, "test_object", ATTRIBUTES_FILENAME)
    @test obj.meta_filename == joinpath(fx.testfile, "test_object", META_FILENAME)

    cleanup_fixture(fx)
end

@testset "object_create_raw" begin
    (fx, f) = setup_teardown_file()

    obj = create_dataset(f, "test_object", shape=(1,))
    create_raw(obj, "test_raw")
    @test isdir(joinpath(fx.testfile, "test_object", "test_raw"))

    @test_throws ArgumentError create_raw(obj, "test_raw")

    cleanup_fixture(fx)
end
