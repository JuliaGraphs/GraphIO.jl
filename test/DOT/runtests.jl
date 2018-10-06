using Test
using ParserCombinator
using GraphIO.DOT

@testset "DOT" begin
    g = CompleteGraph(6)
    dg = DiGraph(4)
    for e in [Edge(1,2), Edge(1,3), Edge(2,2), Edge(2,3), Edge(4,1), Edge(4,3)]
        add_edge!(dg, e)
    end
    fname = joinpath(testdir, "testdata", "twographs.dot")
    read_test(DOTFormat(), g, "g1", fname, testfail=true)
    read_test(DOTFormat(), dg, "g2", fname)
    read_test_mult(DOTFormat(), Dict{String,AbstractGraph}("g1"=>g, "g2"=>dg), fname)
end
