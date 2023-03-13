struct ExdirFixture
    "x"
    testpath::String
    "y"
    testfile::String
    "z"
    testdir::String
end

function setup_teardown_folder()::ExdirFixture
    tmpdir = mktempdir()
    fx = ExdirFixture(
        tmpdir,
        joinpath(tmpdir, "test.exdir"),
        joinpath(tmpdir, "exdir_dir")
    )
    # @produce fx
    # rm(tmpdir, recursive=true)
    fx
end

# TODO leftovers from thinking about Jute.jl fixtures...
# setup_teardown_file = @local_fixture begin
function setup_teardown_file()
    tmpdir = mktempdir()
    fx = ExdirFixture(
        tmpdir,
        joinpath(tmpdir, "test.exdir"),
        joinpath(tmpdir, "exdir_dir")
    )
    f = exdiropen(fx.testfile, "w")
    # @produce (fx, f)
    # close(f)
    # rm(tmpdir, recursive=true)
    (fx, f)
end

function cleanup_fixture(fx::ExdirFixture)
    rm(fx.testpath, recursive=true)
    # TODO if fx.testfile exists, make sure it's closed, then remove the tree
end
