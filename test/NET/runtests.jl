using Test
using GraphIO.NET

@testset "Pajek NET" begin
    for g in values(allgraphs)
        readback_test(NETFormat(), g)
    end
    fname = joinpath(testdir, "testdata", "kinship.net")
    @test length(loadgraphs(fname, NETFormat())) == 1
end


