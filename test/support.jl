using Exdir

struct ExdirFixture
    "The base location that will hold a separate Exdir directory and 'file'."
    testpath::String
    "Location that may be used for an Exdir 'file'."
    testfile::String
    "TODO I'm not sure how this differs from testfile.
    Not actually used by any of the fixture setup functions."
    testdir::String
end

# Reminder about indexing in Python tests:
# 0 -> testpath
# 1 -> testfile
# 2 -> testdir
# 3 -> f

const TESTFILE = "test.exdir"
const TESTDIR = "exdir_dir"

function setup_teardown_folder()::ExdirFixture
    tmpdir = mktempdir()
    fx = ExdirFixture(
        tmpdir,
        joinpath(tmpdir, TESTFILE),
        joinpath(tmpdir, TESTDIR)
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
        joinpath(tmpdir, TESTFILE),
        joinpath(tmpdir, TESTDIR)
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

function exdir_tmpfile()
    tmpdir = mktempdir()
    testpath = joinpath(tmpdir, TESTFILE)
    f = exdiropen(testpath, "w")
    f
    # close(f)
    # rm(tmpdir, recursive=true)
end

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
