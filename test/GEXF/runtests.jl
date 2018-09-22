using Test
using EzXML
using GraphIO.GEXF

@testset "GEXF" begin
    for g in values(allgraphs)
        write_test(GEXFFormat(), g)
    end
end
