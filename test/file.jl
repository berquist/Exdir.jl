using Exdir
using Test

import Exdir: create_object_directory,
    defaultmetadata,
    form_location,
    DATASET_TYPENAME,
    FILE_TYPENAME

# include("support.jl")

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

@testset "file" begin

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
    # TODO (?)
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
    # TODO error type
    @test_throws ArgumentError f = exdiropen(fx.testfile, "w")

    remove(fx.testfile)

    create_object_directory(fx.testfile, defaultmetadata(DATASET_TYPENAME))
    # TODO error type
    @test_throws ArgumentError f = exdiropen(fx.testfile, "w")

    remove(fx.testfile)

    @test_throws ArgumentError f = exdiropen(fx.testfile, "r")
    @test_throws ArgumentError f = exdiropen(fx.testfile, "r+")

    create_object_directory(fx.testfile, defaultmetadata(FILE_TYPENAME))

    # TODO error type
    @test_throws ArgumentError f = exdiropen(fx.testfile, "w")

    remove(fx.testfile)

    create_object_directory(fx.testfile, defaultmetadata(FILE_TYPENAME))
    f = exdiropen(fx.testfile, "w", allow_remove=true)
    remove(fx.testfile)

    create_object_directory(fx.testfile, defaultmetadata(FILE_TYPENAME))

    # Invalid open modes
    @test_throws DomainError f = exdiropen(fx.testfile, "w-")
    @test_throws DomainError f = exdiropen(fx.testfile, "x")
    @test_throws DomainError f = exdiropen(fx.testfile, "not existing")

    cleanup_fixture(fx)
end

# Mode 'w' opens file in overwrite mode.
@testset "file_create" begin
    fx = setup_teardown_folder()

    f = exdiropen(fx.testfile, "w")
    @test isa(f, Exdir.File)
    create_group(f, "foo")
    @test haskey(f, "foo")

    f = exdiropen(fx.testfile, "w", allow_remove=true)
    @test !haskey(f, "foo")
    close(f)
    # TODO error type
    @test_throws ArgumentError f = exdiropen(fx.testfile, "w")

    cleanup_fixture(fx)
end

# Mode 'w-' opens file in exclusive mode.
@testset "file_create_exclusive" begin
    fx = setup_teardown_folder()

    f = exdiropen(fx.testfile, "w-")
    @test isa(f, Exdir.File)
    close(f)
    # TODO error type
    @test_throws ArgumentError f = exdiropen(fx.testfile, "w")

    cleanup_fixture(fx)
end

# Mode 'a' opens file in append/readwrite mode, creating if necessary.
@testset "file_append" begin
    fx = setup_teardown_folder()

    f = exdiropen(fx.testfile, "a")
    @test isa(f, Exdir.File)
    create_group(f, "foo")
    @test haskey(f, "foo")

    f = exdiropen(fx.testfile, "a")
    @test haskey(f, "foo")
    create_group(f, "bar")
    @test haskey(f, "bar")

    cleanup_fixture(fx)
end

# Mode 'r' opens file in readonly mode.
@testset "file_readonly" begin
    fx = setup_teardown_folder()

    f = exdiropen(fx.testfile, "w")
    close(f)
    # assert not f
    f = exdiropen(fx.testfile, "r")
    @test isa(f, Exdir.File)
    @test_throws IOError create_group(f, "foo")
    @test_throws IOError create_dataset(f, "bar", data=(2))
    close(f)

    cleanup_fixture(fx)
end

# Mode 'r+' opens existing file in readwrite mode.
@testset "file_readwrite" begin
    fx = setup_teardown_folder()

    f = exdiropen(fx.testfile, "w")
    create_group(f, "foo")
    close(f)
    f = exdiropen(fx.testfile, "r+")
    @test haskey(f, "foo")
    create_group(f, "bar")
    @test haskey(f, "bar")
    close(f)

    cleanup_fixture(fx)
end

# Modes 'r' and 'r+' do not create files.
@testset "file_nonexistent_file" begin
    fx = setup_teardown_folder()

    @test_throws ArgumentError f = exdiropen(fx.testfile, "r")
    @test_throws ArgumentError f = exdiropen(fx.testfile, "r+")

    cleanup_fixture(fx)
end

# Invalid modes raise DomainError.
@testset "file_invalid_mode" begin
    fx = setup_teardown_folder()

    @test_throws DomainError f = exdiropen(fx.testfile, "Error mode")

    cleanup_fixture(fx)
end

# Closing a file.
@testset "file_close" begin
    fx = setup_teardown_folder()

    f = exdiropen(fx.testfile, "w")
    close(f)

    cleanup_fixture(fx)
end

# TODO naming rule implementation
# Test naming rule thorough.
@testset "file_validate_name_thorough" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

# TODO naming rule implementation
# Test naming rule strict.
@testset "file_validate_name_strict" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

# TODO naming rule implementation
# Test naming rule with error.
@testset "file_validate_name_error" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

# TODO naming rule implementation
# Test naming rule with error.
@testset "file_validate_name_none" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

# TODO naming rule implementation
# Test opening with wrong naming rule.
@testset "file_opening_with_different_validate_name" begin
    fx = setup_teardown_folder()

    cleanup_fixture(fx)
end

# Root group (by itself) is contained.
@testset "file_contains" begin
    (fx, f) = setup_teardown_file()

    create_group(f, "test")
    @test haskey(f, "/")
    @test haskey(f, "/test")

    cleanup_fixture(fx)
end

# Root group (by itself) is contained.
@testset "file_create_group" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "/test")
    @test isa(grp, Exdir.Group)

    cleanup_fixture(fx)
end

# Root group (by itself) is contained.
@testset "file_require_group" begin
    (fx, f) = setup_teardown_file()

    grp = require_group(f, "/foo")
    @test isa(grp, Exdir.Group)

    cleanup_fixture(fx)
end

# thorough obj[name] opening.
@testset "file_open" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "foo")
    grp2 = f["foo"]
    grp3 = f["/foo"]
    f = f["/"]

    @test grp == grp2
    @test grp2 == grp3
    @test f == f

    cleanup_fixture(fx)
end

@testset "file_open_mode" begin
    fx = setup_teardown_folder()

    # must exist
    for mode in ["r+", "r"]
        @test_throws ArgumentError f = exdiropen(fx.testfile, mode)
    end
    # create if not exist
    for mode in ["a", "w", "w-"]
        remove(fx.testfile)
        f = exdiropen(fx.testfile, mode)
        require_dataset(f, "dset", data=range(0, 10))
        f.attrs["can_overwrite"] = 42
        f.attrs["can_overwrite"] = 14
        require_group(f, "mygroup")
    end

    remove(fx.testfile)
    f = exdiropen(fx.testfile, "w")
    close(f) # dummy close
    # read write if exist
    f = exdiropen(fx.testfile, "r+")
    require_group(f, "mygroup")
    require_dataset(f, "dset", data=range(0, 10))
    f.attrs["can_overwrite"] = 42
    f.attrs["can_overwrite"] = 14

    # read only, can not write
    f = exdiropen(fx.testfile, "r")
    @test_throws IOError require_dataset(f, "dset", data=range(0, 10))
    @test_throws IOError f.attrs["can_not_write"] = 42
    @test_throws IOError create_group(f, "mygroup")

    cleanup_fixture(fx)
end

@testset "file_open_two_attrs" begin
    (fx, f) = setup_teardown_file()

    f.attrs["can_overwrite"] = 42
    f.attrs["another_attribute"] = 14

    cleanup_fixture(fx)
end

# 'in' on closed group returns false.
@testset "file_exc" begin
    (fx, f) = setup_teardown_file()

    create_group(f, "a")
    close(f)

    # TODO
    # assert not f
    @test !haskey(f, "a")

    cleanup_fixture(fx)
end

# closed file is unable to handle.
@testset "file_close_group" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "group")

    close(f)
    # assert not f
    @test !haskey(f, "group")
    @test !haskey(f, "dataset")

    # unable to create new stuff
    mtch = "Unable to operate on closed File instance."
    @test_throws IOError create_group(f, "group")
    @test_throws IOError create_group(grp, "group")
    @test_throws IOError grp.attrs = Dict("group" => "attrs")

    cleanup_fixture(fx)
end

# closed file is unable to handle.
@testset "file_close_attrs" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "group")
    dset = create_dataset(f, "dataset", data=[1, 2, 3])
    raw = create_raw(f, "raw")
    f.attrs = Dict("file" => "attrs")
    file_attrs = f.attrs
    close(f)

    mtch = "Unable to operate on closed File instance."
    @test_throws IOError f.attrs = Dict("file" => "attrs")
    @test_throws IOError file_attrs["new"] = "yo"

    # unable to retrieve stuff
    @test_throws IOError file_attrs["file"]
    @test_throws IOError f.attrs
    @test !haskey(file_attrs, "file")

    cleanup_fixture(fx)
end

# closed file is unable to handle.
@testset "file_close_raw" begin
    (fx, f) = setup_teardown_file()

    raw = create_raw(f, "raw")
    close(f)

    @test !haskey(f, "raw")

    # unable to create new stuff
    mtch = "Unable to operate on closed File instance."
    @test_throws IOError create_raw(f, "raw")

    # unable to retrieve
    @test_throws IOError f["raw"]

    cleanup_fixture(fx)
end

# closed file is unable to handle.
@testset "file_close_dataset" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "group")
    dset = create_dataset(f, "dataset", data=[1, 2, 3])
    dset.attrs = Dict("dataset" => "attrs")
    dset_attrs = dset.attrs
    data = dset.data
    close(f)

    @test !haskey(f, "dataset")

    # unable to create new stuff
    mtch = "Unable to operate on closed File instance."

    @test_throws IOError create_dataset(f, "dataset", [1, 2, 3])
    @test_throws IOError create_dataset(grp, "dataset", [1, 2, 3])
    @test_throws IOError dset.attrs = Dict("dataset" => "attrs")
    @test_throws IOError dset_attrs["new"] = "yo"

    # unable to retrieve stuff
    @test_throws IOError dset.data
    @test_throws IOError dset.shape
    @test_throws IOError dset.dtype
    @test_throws IOError dset.attrs

    @test !haskey(dset_attrs, "dataset")

    # This is a TODO from the original Python code.
    # TODO unable to close datasets: uncomment when done
    # assert 1 not in data
    # data[:] = np.array([3,2,1]) # TODO should give error
    # f.io_mode = 1
    # assert np.array_equal(dset.data, np.array([1,2,3]))

    cleanup_fixture(fx)
end

# Feature: File objects can be used as context managers
# def test_context_manager(setup_teardown_folder):
#     """File objects can be used in with statements."""

#     no_exdir = setup_teardown_folder[2]

#     with File(no_exdir, mode="w") as f:
#         assert isinstance(f, File)

#     assert not f

end
