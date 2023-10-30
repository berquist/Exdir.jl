using Exdir
using Test

import Exdir: NotImplementedError

include("support.jl")

@testset "group" begin

@testset "group_init" begin
    fx = setup_teardown_folder()

    grp = Exdir.Group(
        root_directory = fx.testdir,
        parent_path = "",
        object_name = "test_object",
        file = nothing
    )

    @test grp.root_directory == fx.testdir
    @test grp.object_name == "test_object"
    @test grp.parent_path == ""
    @test isnothing(grp.file)
    @test grp.relative_path == "test_object"
    @test grp.name == "/test_object"

    cleanup_fixture(fx)
end

@testset "group_init_trailing" begin
    fx = setup_teardown_folder()

    grp = Exdir.Group(
        root_directory = fx.testdir,
        parent_path = "",
        object_name = "test_object2/",
        file = nothing
    )

    @test grp.root_directory == fx.testdir
    @test grp.object_name == "test_object2/"
    @test grp.parent_path == ""
    @test isnothing(grp.file)
    @test grp.relative_path == "test_object2"
    @test grp.name == "/test_object2"

    cleanup_fixture(fx)
end

@testset "group_create" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grp2 = create_group(grp, "a")

    @test isa(grp, Exdir.Group)

    grp3 = create_group(grp, "b/")
    @test isa(grp3, Exdir.Group)

    cleanup_fixture(fx)
end

@testset "group_len" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grp2 = create_group(grp, "a")

    grp3 = create_group(grp, "b")

    @test length(grp) == 2
    @test length(grp2) == 0
    @test length(grp3) == 0

    cleanup_fixture(fx)
end

@testset "group_get" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grp2 = create_group(grp, "a")

    grp2_get = get(grp, "a")

    grp3_get = get(grp, "b")

    @test grp2 == grp2_get
    @test grp3_get === nothing

    cleanup_fixture(fx)
end

# Starting .create_group argument with /.
@testset "group_create_absolute" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "/a")

    @test_throws NotImplementedError create_group(grp, "/b")

    cleanup_fixture(fx)
end

@testset "group_create_existing_twice" begin
    f = exdir_tmpfile()

    create_group(f, "test")
    @test_throws ArgumentError create_group(f, "test")
end

@testset "group_create_intermediate" begin
    # intermediate groups can be created automatically.
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grp2 = create_group(grp, "foo/bar/baz")

    @test isa(grp["foo/bar/baz"], Exdir.Group)
    @test isa(grp2, Exdir.Group)

    @test grp2.name == "/test/foo/bar/baz"
    @test in("foo", grp)
    @test in("bar", require_group(grp, "foo"))
    @test in("baz", require_group(require_group(grp, "foo"), "bar"))
    @test grp2 == require_group(require_group(require_group(grp, "foo"), "bar"), "baz")

    cleanup_fixture(fx)
end

# Name conflict causes group creation to fail with ArgumentError.
@testset "group_create_exception" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    create_group(grp, "foo")

    @test_throws ArgumentError create_group(grp, "foo")
    @test_throws ArgumentError create_group(grp, "foo/")

    cleanup_fixture(fx)
end

# Feature: Groups can be auto-created, or opened via .require_group
# Existing group is opened and returned.
@testset "group_open_existing" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grp2 = create_group(grp, "foo")
    grp3 = require_group(grp, "foo")
    grp4 = require_group(grp, "foo/")

    @test grp2 == grp3
    @test grp2.name == grp4.name
    @test grp2 == grp4

    cleanup_fixture(fx)
end

# Group is created if it doesn't exist.
@testset "group_create" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grp2 = require_group(grp, "foo")
    @test isa(grp2, Exdir.Group)
    @test grp2.name == "/test/foo"

    cleanup_fixture(fx)
end

# Opening conflicting object results in TODOError.
@testset "group_require_exception" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    # grp.create_dataset("foo", (1,))

    # with pytest.raises(TypeError):
    #     grp.require_group("foo")

    cleanup_fixture(fx)
end

# TODO
# @testset "group_set_item_intermediate" begin
#     (_, f) = setup_teardown_file()

#     group1 = create_group(f, "group1")
#     group2 = create_group(group1, "group2")
#     group3 = create_group(group2, "group3")
#     f["group1/group2/group3/dataset"] = [1, 2, 3]

#     @test_ isa(f["group1/group2/group3/dataset"], Exdir.Dataset)
#     @test f["group1/group2/group3/dataset"].data == [1, 2, 3]

#     cleanup_fixture(fx)
# end

@testset "group_delete" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")
    create_group(grp, "foo")

    @test in("foo", grp)
    delete!(grp, "foo")
    @test !in("foo", grp)

    # alias delete_object as in HDF5.jl

    create_group(grp, "bar")

    @test in("bar", grp)
    delete_object(grp, "bar")
    @test !in("bar", grp)

    cleanup_fixture(fx)
end

@testset "group_delete_from_file" begin
    (fx, f) = setup_teardown_file()

    create_group(f, "test")

    @test in("test", f)
    delete!(f, "test")
    @test !in("test", f)

    # alias delete_object as in HDF5.jl

    create_group(f, "test2")

    @test in("test2", f)
    delete_object(f, "test2")
    @test !in("test2", f)

    cleanup_fixture(fx)
end

@testset "group_delete_raw" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")
    create_raw(grp, "foo")

    @test in("foo", grp)
    delete!(grp, "foo")
    @test !in("foo", grp)

    # alias delete_object as in HDF5.jl

    create_raw(grp, "bar")

    @test in("bar", grp)
    delete_object(grp, "bar")
    @test !in("bar", grp)

    cleanup_fixture(fx)
end

# Deleting non-existent object raises TODOError
@testset "group_nonexisting" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    # @test_throws "KeyError: No such object: 'foo' in path *" delete!(grp, "foo")
    @test_throws KeyError delete!(grp, "foo")

    cleanup_fixture(fx)
end

@testset "group_readonly_delete_exception" begin
    (fx, f) = setup_teardown_file()

    close(f)

    # TODO
    match = "Cannot change data on file in read only 'r' mode"

    cleanup_fixture(fx)
end

@testset "group_delete_dataset" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "group_open" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")
    grp2 = create_group(grp, "foo")

    grp3 = grp["foo"]
    grp4 = grp["foo/"]

    @test grp2 == grp3
    @test grp2.name == grp4.name
    @test grp2 == grp4

    @test_throws NotImplementedError grp["/test"]

    cleanup_fixture(fx)
end

@testset "group_open_deep" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")
    grp2 = create_group(grp, "a")
    grp3 = create_group(grp2, "b")

    grp4 = grp["a/b"]

    @test grp3 == grp4

    cleanup_fixture(fx)
end

@testset "group_nonexistent" begin
    (fx, f) = setup_teardown_file()

    # TODO

    cleanup_fixture(fx)
end

@testset "group_contains" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    create_group(grp, "b")

    @test in("b", grp)
    @test !in("c", grp)

    @test_throws NotImplementedError "/b" in grp

    cleanup_fixture(fx)
end

@testset "group_contains_deep" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grp2 = create_group(grp, "a")
    grp3 = create_group(grp2, "b")

    @test in("a/b", grp)

    cleanup_fixture(fx)
end

@testset "group_empty" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    @test !in("", grp)

    cleanup_fixture(fx)
end

@testset "group_dot" begin
    (fx, f) = setup_teardown_file()

    @test in(".", f)

    cleanup_fixture(fx)
end

@testset "group_root" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    @test_throws NotImplementedError "/" in grp

    cleanup_fixture(fx)
end

@testset "group_trailing_slash" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    create_group(grp, "a")
    @test "a/" in grp
    @test "a//" in grp
    @test "a///" in grp

    cleanup_fixture(fx)
end

@testset "group_keys" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    create_group(grp, "a")
    create_group(grp, "b")
    create_group(grp, "d")
    create_group(grp, "c")

    @test keys(grp) == ["a", "b", "c", "d"]

    cleanup_fixture(fx)
end

@testset "group_values" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grpa = create_group(grp, "a")
    grpb = create_group(grp, "b")
    grpd = create_group(grp, "d")
    grpc = create_group(grp, "c")

    @test values(grp) == [grpa, grpb, grpc, grpd]

    cleanup_fixture(fx)
end

@testset "group_items" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grpa = create_group(grp, "a")
    grpb = create_group(grp, "b")
    grpd = create_group(grp, "d")
    grpc = create_group(grp, "c")

    names = ["a", "b", "c", "d"]
    groups = [grpa, grpb, grpc, grpd]

    for (i, (k, v)) in enumerate(pairs(grp))
        @test k == names[i]
        @test v == groups[i]
    end

    cleanup_fixture(fx)
end

@testset "group_iter" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    create_group(grp, "a")
    create_group(grp, "b")
    create_group(grp, "c")
    create_group(grp, "d")

    lst = [x for x in grp]
    @test lst == ["a", "b", "c", "d"]

    cleanup_fixture(fx)
end

@testset "group_iter_zero" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    lst = [x for x in grp]
    @test lst == []

    cleanup_fixture(fx)
end

@testset "group_eq" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grp2 = create_group(grp, "a")

    @test grp2 == grp2
    @test grp != grp2

    cleanup_fixture(fx)
end

@testset "group_eq_parent" begin
    (fx, f) = setup_teardown_file()

    grp = create_group(f, "test")

    grp2 = create_group(grp, "a")

    grp_parent = grp2.parent

    @test grp == grp_parent

    cleanup_fixture(fx)
end

end
