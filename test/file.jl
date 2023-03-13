using Exdir
using Test

import Exdir: create_object_directory,
    defaultmetadata,
    form_location,
    DATASET_TYPENAME,
    FILE_TYPENAME

include("support.jl")

"""
    remove(name)

If name is a path or directory tree, recursively delete it.
Otherwise, do nothing.
"""
function remove(name)
    if ispath(name)
        rm(name, recursive=true)
    end
end

@testset "form_location" begin
    @test form_location("/hello.exdir") == "/hello.exdir"
    @test form_location("/hello") == "/hello.exdir"
    @test form_location("/hello.exdir/") == "/hello.exdir"
    @test form_location("/hello/") == "/hello.exdir"
    # Adding a prefix (more than one path component) should have no effect.
    @test form_location("/world/hello.exdir") == "/world/hello.exdir"
    @test form_location("/world/hello") == "/world/hello.exdir"
    @test form_location("/world/hello.exdir/") == "/world/hello.exdir"
    @test form_location("/world/hello/") == "/world/hello.exdir"
end

"""
    with_suffix(path, suffix)

Ensure the path ends with the suffix either by adding it if one doesn't exist,
or replacing an existing one.

See https://docs.python.org/3/library/pathlib.html#pathlib.PurePath.with_suffix for inspiration.
"""
with_suffix(path::AbstractString, suffix::AbstractString) = splitext(path)[1] * suffix

@testset "with_suffix" begin
    @test with_suffix("foo.txt", ".txt") == "foo.txt"
    @test with_suffix("foo.txt", ".log") == "foo.log"
    @test with_suffix("foo.txt.2", ".log") == "foo.txt.log"
    @test with_suffix("foo", ".txt") == "foo.txt"
end

@testset "file_init" begin
    fx = setup_teardown_folder()

    no_exdir = joinpath(fx.testpath, "no_exdir")

    f = exdiropen(no_exdir, "w")
    close(f)
    @test is_nonraw_object_directory(with_suffix(no_exdir, ".exdir"))
    # TODO
    remove(fx.testfile)

    f = exdiropen(fx.testfile, "w")
    close(f)
    @test is_nonraw_object_directory(fx.testfile)
    remove(fx.testfile)

    f = exdiropen(fx.testfile, "a")
    close(f)
    @test is_nonraw_object_directory(fx.testfile)
    remove(fx.testfile)

    f = exdiropen(fx.testfile, "a")
    close(f)
    @test is_nonraw_object_directory(fx.testfile)
    remove(fx.testfile)

    mkpath(fx.testfile)
    # In Python, this was "w".
    @test_throws ArgumentError f = exdiropen(fx.testfile, "a")

    remove(fx.testfile)

    create_object_directory(fx.testfile, defaultmetadata(DATASET_TYPENAME))
    # In Python, this was "w".
    @test_throws ArgumentError f = exdiropen(fx.testfile, "a")

    remove(fx.testfile)

    @test_throws ArgumentError f = exdiropen(fx.testfile, "r")
    @test_throws ArgumentError f = exdiropen(fx.testfile, "r+")

    create_object_directory(fx.testfile, defaultmetadata(FILE_TYPENAME))

    # In Python, this was "w".
    @test_throws ArgumentError f = exdiropen(fx.testfile, "a")

    remove(fx.testfile)

    # create_object_directory(fx.testfile, defaultmetadata(FILE_TYPENAME))
    # f = exdiropen(fx.testfile, "w", allow_remove=true)
    # remove(fx.testfile)

    create_object_directory(fx.testfile, defaultmetadata(FILE_TYPENAME))

    # Invalid open modes
    @test_throws ArgumentError f = exdiropen(fx.testfile, "w-")
    @test_throws ArgumentError f = exdiropen(fx.testfile, "x")
    @test_throws ArgumentError f = exdiropen(fx.testfile, "not existing")

    cleanup_fixture(fx)
end

@testset "file_create" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_create_exclusive" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_append" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_readonly" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_readwrite" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_nonexistent_file" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_invalid_mode" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_close" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_validate_name_thorough" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_validate_name_strict" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_validate_name_error" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_validate_name_none" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_opening_with_different_validate_name" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_contains" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end

@testset "file_create_group" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end

@testset "file_require_group" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end

@testset "file_open" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end

@testset "file_open_mode" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

@testset "file_open_two_attrs" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end

@testset "file_exc" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end

@testset "file_close_group" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end

@testset "file_close_attrs" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end

@testset "file_close_raw" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end

@testset "file_close_dataset" begin
    (fx, f) = setup_teardown_file()

    cleanup_fixture(fx)
end
