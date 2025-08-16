using Test

import Exdir:
    can_cast

@testset "can_cast" begin
    # safe
    @test can_cast(Int32, Int32)
    @test can_cast(Int32, Int64)
    @test !can_cast(Int64, Int32)

    @test can_cast(Float32, Float32)
    @test can_cast(Float32, Float64)
    @test !can_cast(Float64, Float32)

    @test can_cast(UInt32, UInt32)
    @test can_cast(UInt32, UInt64)
    @test !can_cast(UInt64, UInt32)
end
