using Test
using GraphIO.EdgeList
using GraphIO.EdgeList: IntEdgeListFormat

@testset "EdgeList" begin
    for g in values(digraphs)
        readback_test(EdgeListFormat(), g)
        readback_test(IntEdgeListFormat(), g)
    end
end
