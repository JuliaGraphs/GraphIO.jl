using Test
using ParserCombinator
using GraphIO.GML

@testset "GML" begin
    for g in values(allgraphs)
        readback_test(GMLFormat(), g, testfail=true)
    end
    write_test(GMLFormat(), allgraphs)
end
