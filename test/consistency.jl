using Test

import Exdir:
    _data_to_shape_and_dtype

@testset "consistency" begin
    @testset "data_to_shape_and_dtype" begin
        default_dtype = Float64
        dim = (2, 3)
        x = rand(default_dtype, dim...)
        z = x * (1 + 1im)

        @test _data_to_shape_and_dtype(nothing, nothing, nothing) == (nothing, default_dtype)
        @test _data_to_shape_and_dtype(nothing, nothing, Int32) == (nothing, Int32)
        @test _data_to_shape_and_dtype(nothing, dim, nothing) == (dim, default_dtype)
        @test _data_to_shape_and_dtype(nothing, dim, ComplexF16) == (dim, ComplexF16)
        @test _data_to_shape_and_dtype(x, nothing, nothing) == (dim, default_dtype)
        @test _data_to_shape_and_dtype(z, nothing, nothing) == (dim, ComplexF64)
    end
end
