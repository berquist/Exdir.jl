using Test

@testset "Exdir.jl" begin
    include("support.jl")
    include("can_cast.jl")
    # include("example_hdf5.jl")
    # include("example.jl")
    include("path.jl")
    include("consistency.jl")
    include("object.jl")
    include("help_functions.jl")
    include("raw.jl")
    include("group.jl")
    # include("file.jl")
    include("prepare_write.jl")
    include("dataset.jl")
    include("attr.jl")
    include("plugins.jl")
    include("quantities.jl")
end
