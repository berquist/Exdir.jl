using Exdir
using Test

import Exdir

include("support.jl")

@testset "raw" begin

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

# Simple .create_raw call.
@testset "raw_create" begin
    (fx, f) = setup_teardown_file()

    raw = create_raw(f, "test")

    raw2 = f["test"]

    @test ispath(joinpath(f.root_directory, "test"))

    @test raw == raw2

    cleanup_fixture(fx)
end

# Raw is created if it doesn"t exist.
@testset "raw_require" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    raw = require_raw(grp, "foo")
    raw2 = require_raw(grp, "foo")

    raw3 = grp["foo"]

    @test ispath(joinpath(f.root_directory, "test", "foo"))

    @test raw == raw2
    @test raw == raw3

    cleanup_fixture(fx)
end

@testset "raw_create_twice" begin
    f = exdir_tmpfile()

    create_raw(f, "test")
    @test_throws IOError create_raw(f, "test")
end

@testset "raw_create_dataset" begin
    f = exdir_tmpfile()

    grp = create_group(f, "group")
    dset = create_dataset(grp, "dataset", shape=(1, 1))
    raw = create_raw(dset, "raw")

    @test ispath(joinpath(f.directory, "group", "dataset", "raw"))
end

end
