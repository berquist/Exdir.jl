using Test

@testset "Exdir.jl" begin
    # include("example_hdf5.jl")
    # include("example.jl")
    include("object.jl")
    include("raw.jl")
    include("group.jl")
    include("file.jl")
    include("dataset.jl")
end
