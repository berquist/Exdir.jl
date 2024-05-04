using Exdir
using Test

import Exdir: IOError, Object, open_object, ATTRIBUTES_FILENAME, META_FILENAME

# include("support.jl")

@testset "object" begin

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
    # @test isa(obj.meta, Attribute)
    # assert obj.attrs.mode.value == 1
    # obj.attrs = "test value"

    # with (setup_teardown_file[1] / "test_object" / ATTRIBUTES_FILENAME).open("r", encoding="utf-8") as meta_file:
    #     meta_data = yaml.YAML(typ="safe", pure=True).load(meta_file)
    #     assert meta_data == "test value"

    cleanup_fixture(fx)
end

@testset "object_meta" begin
    (fx, f) = setup_teardown_file()

    obj = create_dataset(f, "test_object", shape=(1,))

    # TODO
    # @test isa(obj.meta, Attribute)
    # assert obj.meta.mode == exdir.core.Attribute._Mode.METADATA
    # with pytest.raises(AttributeError):
    #     obj.meta = "test value"

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

    # Python exception
    # RuntimeError: A directory with name (case independent) 'test_raw' already exists  and cannot be made according to the naming rule 'thorough'.
    @test_throws IOError create_raw(obj, "test_raw")

    cleanup_fixture(fx)
end

end
