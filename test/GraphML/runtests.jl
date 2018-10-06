using Test
using EzXML
using GraphIO.GraphML

@testset "GraphML" begin
    for g in values(allgraphs)
        readback_test(GraphMLFormat(), g, testfail=true)
    end
    fname = joinpath(testdir, "testdata", "warngraph.graphml")
    
    @test_logs (:warn, "Skipping unknown node 'warnnode' - further warnings will be suppressed") match_mode=:any loadgraphs(fname, GraphMLFormat())
    @test_logs (:warn, "Skipping unknown XML element 'warnelement' - further warnings will be suppressed") match_mode=:any loadgraph(fname, "graph", GraphMLFormat())
    d = loadgraphs(fname, GraphMLFormat())
    write_test(GraphMLFormat(), d)
end

