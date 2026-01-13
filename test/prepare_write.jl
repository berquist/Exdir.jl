using Exdir
using Test

import Exdir: _prepare_write

@testset "prepare_write" begin
    # Julia: _prepare_write(data, attrs::AbstractDict, meta::AbstractDict)
    # Python: def _prepare_write(data, plugins, attrs, meta):

    ret = _prepare_write(42, Dict(), Dict())
    ref1 = collect(42)
    @test ret[1] == ref1

    ret = _prepare_write("string", Dict(), Dict())
    ref1 = collect("string")
    @test ret[1] == ref1
end
