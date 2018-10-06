using Test
using GraphIO.EdgeList

@testset "EdgeList" begin
    for g in values(digraphs)
        readback_test(EdgeListFormat(), g)
    end
end

